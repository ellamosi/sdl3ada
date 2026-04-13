with Ada.Unchecked_Conversion;
with Interfaces.C.Extensions;
with Interfaces.C.Strings;
with System;
with System.Storage_Elements;

with SDL.C_Pointers;
with SDL.Error;

package body SDL.Processes is
   package CE renames Interfaces.C.Extensions;
   package CS renames Interfaces.C.Strings;
   package Raw renames SDL.Raw.Process;
   package SSE renames System.Storage_Elements;

   use type C.size_t;
   use type CS.chars_ptr;
   use type Raw.Process_Access;
   use type SSE.Integer_Address;
   use type SDL.C_Pointers.IO_Stream_Pointer;
   use type System.Address;

   type C_String_Array is array (Positive range <>) of aliased CS.chars_ptr with
     Convention => C;

   function To_C_Bool (Value : in Boolean) return CE.bool is
     (CE.bool'Val (Boolean'Pos (Value)));

   function To_Chars_Ptr is new Ada.Unchecked_Conversion
     (Source => System.Address,
      Target => CS.chars_ptr);

   function To_IO_Stream_Pointer is new Ada.Unchecked_Conversion
     (Source => System.Address,
      Target => SDL.C_Pointers.IO_Stream_Pointer);

   procedure SDL_Free (Memory : in System.Address) with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_free";

   function SDL_Write_IO
     (Context : in SDL.C_Pointers.IO_Stream_Pointer;
      Ptr     : in System.Address;
      Size    : in C.size_t) return C.size_t
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_WriteIO";

   function SDL_Close_IO
     (Context : in SDL.C_Pointers.IO_Stream_Pointer) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CloseIO";

   procedure Raise_Last_Error;
   procedure Require_Valid (Self : in Process);
   procedure Free_C_Arguments (Items : in out C_String_Array);

   function Create_Internal
     (Arguments  : in Argument_List;
      Pipe_Stdio : in Boolean) return Raw.Process_Access;

   function Create_Internal
     (Arguments  : in Argument_List;
      Properties : in SDL.Properties.Property_Set) return Raw.Process_Access;

   function Has_Stream_Property
     (Self : in Process;
      Name : in String) return Boolean;

   procedure Close_Stream_Property
     (Self : in Process;
      Name : in String);

   procedure Raise_Last_Error is
   begin
      raise Process_Error with SDL.Error.Get;
   end Raise_Last_Error;

   procedure Require_Valid (Self : in Process) is
   begin
      if Self.Internal = null then
         raise Process_Error with "Invalid process";
      end if;
   end Require_Valid;

   procedure Free_C_Arguments (Items : in out C_String_Array) is
   begin
      for Item of Items loop
         if Item /= CS.Null_Ptr then
            CS.Free (Item);
         end if;
      end loop;
   end Free_C_Arguments;

   function Create_Internal
     (Arguments  : in Argument_List;
      Pipe_Stdio : in Boolean) return Raw.Process_Access
   is
      C_Arguments : C_String_Array (1 .. Arguments'Length + 1) :=
        (others => CS.Null_Ptr);
      Cursor   : Positive := C_Arguments'First;
      Internal : Raw.Process_Access;
   begin
      begin
         for Argument of Arguments loop
            C_Arguments (Cursor) := CS.New_String (US.To_String (Argument));
            Cursor := Cursor + 1;
         end loop;

         Internal :=
           Raw.Create_Process
             (Args       => C_Arguments'Address,
              Pipe_Stdio => To_C_Bool (Pipe_Stdio));

         if Internal = null then
            Raise_Last_Error;
         end if;
      exception
         when others =>
            Free_C_Arguments (C_Arguments);
            raise;
      end;

      Free_C_Arguments (C_Arguments);
      return Internal;
   end Create_Internal;

   function Create_Internal
     (Arguments  : in Argument_List;
      Properties : in SDL.Properties.Property_Set) return Raw.Process_Access
   is
      Temp_Properties : SDL.Properties.Property_Set := SDL.Properties.Create;
      C_Arguments     : C_String_Array (1 .. Arguments'Length + 1) :=
        (others => CS.Null_Ptr);
      Cursor   : Positive := C_Arguments'First;
      Internal : Raw.Process_Access;
   begin
      begin
         if not SDL.Properties.Is_Null (Properties) then
            SDL.Properties.Copy
              (Source      => Properties,
               Destination => Temp_Properties);
         end if;

         for Argument of Arguments loop
            C_Arguments (Cursor) := CS.New_String (US.To_String (Argument));
            Cursor := Cursor + 1;
         end loop;

         Temp_Properties.Set_Pointer
           (Name  => Process_Create_Args_Property,
            Value => C_Arguments'Address);

         Internal :=
           Raw.Create_Process_With_Properties
             (Temp_Properties.Get_ID);

         if Internal = null then
            Raise_Last_Error;
         end if;
      exception
         when others =>
            Free_C_Arguments (C_Arguments);
            raise;
      end;

      Free_C_Arguments (C_Arguments);
      return Internal;
   end Create_Internal;

   function Has_Stream_Property
     (Self : in Process;
      Name : in String) return Boolean
   is
   begin
      if Self.Internal = null then
         return False;
      end if;

      declare
         Props : constant SDL.Properties.Property_Set := Get_Properties (Self);
      begin
         return Props.Get_Pointer (Name) /= System.Null_Address;
      end;
   end Has_Stream_Property;

   procedure Close_Stream_Property
     (Self : in Process;
      Name : in String)
   is
   begin
      Require_Valid (Self);

      declare
         Props   : constant SDL.Properties.Property_Set := Get_Properties (Self);
         Address : constant System.Address := Props.Get_Pointer (Name);
      begin
         if Address = System.Null_Address then
            return;
         end if;

         if not Boolean (SDL_Close_IO (To_IO_Stream_Pointer (Address))) then
            Raise_Last_Error;
         end if;

         Props.Clear (Name);
      end;
   end Close_Stream_Property;

   overriding
   procedure Finalize (Self : in out Process) is
   begin
      Destroy (Self);
   end Finalize;

   function Create
     (Arguments   : in Argument_List;
      Pipe_Stdio  : in Boolean := False) return Process
   is
      Internal : constant Raw.Process_Access :=
        Create_Internal (Arguments, Pipe_Stdio);
   begin
      return Result : Process do
         Result.Internal := Internal;
      end return;
   end Create;

   procedure Create
     (Self        : in out Process;
      Arguments   : in Argument_List;
      Pipe_Stdio  : in Boolean := False)
   is
      Internal : constant Raw.Process_Access :=
        Create_Internal (Arguments, Pipe_Stdio);
   begin
      Destroy (Self);
      Self.Internal := Internal;
   end Create;

   function Create
     (Arguments  : in Argument_List;
      Properties : in SDL.Properties.Property_Set) return Process
   is
      Internal : constant Raw.Process_Access :=
        Create_Internal (Arguments, Properties);
   begin
      return Result : Process do
         Result.Internal := Internal;
      end return;
   end Create;

   procedure Create
     (Self       : in out Process;
      Arguments  : in Argument_List;
      Properties : in SDL.Properties.Property_Set)
   is
      Internal : constant Raw.Process_Access :=
        Create_Internal (Arguments, Properties);
   begin
      Destroy (Self);
      Self.Internal := Internal;
   end Create;

   procedure Destroy (Self : in out Process) is
   begin
      if Self.Internal /= null then
         Raw.Destroy_Process (Self.Internal);
         Self.Internal := null;
      end if;
   end Destroy;

   function Is_Null (Self : in Process) return Boolean is
     (Self.Internal = null);

   function Get_Handle
     (Self : in Process) return Process_Handle is
     (Self.Internal);

   function Get_Properties
     (Self : in Process) return SDL.Properties.Property_Set is
   begin
      Require_Valid (Self);
      return SDL.Properties.Reference
        (Raw.Get_Process_Properties (Self.Internal));
   end Get_Properties;

   function PID
     (Self : in Process) return SDL.Properties.Property_Numbers
   is
      Props : constant SDL.Properties.Property_Set := Get_Properties (Self);
   begin
      return Props.Get_Number (Process_PID_Property);
   end PID;

   function Is_Background (Self : in Process) return Boolean is
      Props : constant SDL.Properties.Property_Set := Get_Properties (Self);
   begin
      return Props.Get_Boolean (Process_Background_Property);
   end Is_Background;

   function Has_Input (Self : in Process) return Boolean is
     (Has_Stream_Property (Self, Process_Stdin_Property));

   function Has_Output (Self : in Process) return Boolean is
     (Has_Stream_Property (Self, Process_Stdout_Property));

   function Has_Error_Output (Self : in Process) return Boolean is
     (Has_Stream_Property (Self, Process_Stderr_Property));

   procedure Write_Input
     (Self : in Process;
      Data : in String)
   is
      Stream        : SDL.C_Pointers.IO_Stream_Pointer;
      Bytes_Written : C.size_t;
      Remaining     : C.size_t := C.size_t (Data'Length);
      Address       : System.Address := Data'Address;
   begin
      Require_Valid (Self);

      if Data'Length = 0 then
         return;
      end if;

      Stream := Raw.Get_Process_Input (Self.Internal);
      if Stream = null then
         Raise_Last_Error;
      end if;

      while Remaining > 0 loop
         Bytes_Written :=
           SDL_Write_IO
             (Context => Stream,
              Ptr     => Address,
              Size    => Remaining);

         if Bytes_Written = 0 then
            Raise_Last_Error;
         end if;

         Remaining := Remaining - Bytes_Written;
         Address :=
           SSE.To_Address
             (SSE.To_Integer (Address) + SSE.Integer_Address (Bytes_Written));
      end loop;
   end Write_Input;

   procedure Close_Input (Self : in Process) is
   begin
      Close_Stream_Property (Self, Process_Stdin_Property);
   end Close_Input;

   procedure Close_Output (Self : in Process) is
   begin
      Close_Stream_Property (Self, Process_Stdout_Property);
   end Close_Output;

   procedure Close_Error_Output (Self : in Process) is
   begin
      Close_Stream_Property (Self, Process_Stderr_Property);
   end Close_Error_Output;

   function Read_All_Output
     (Self      : in Process;
      Exit_Code : out C.int) return String
   is
      Data_Size : aliased C.size_t := 0;
      Status    : aliased C.int := -1;
      Buffer    : System.Address;
   begin
      Require_Valid (Self);

      Exit_Code := -1;

      Buffer :=
        Raw.Read_Process
          (Self      => Self.Internal,
           Data_Size => Data_Size'Access,
           Exit_Code => Status'Access);

      if Buffer = System.Null_Address then
         if SDL.Error.Get /= "" then
            Raise_Last_Error;
         end if;

         Exit_Code := Status;
         return "";
      end if;

      declare
         Value : constant String :=
           CS.Value (To_Chars_Ptr (Buffer), Data_Size);
      begin
         SDL_Free (Buffer);
         Exit_Code := Status;
         return Value;
      exception
         when others =>
            SDL_Free (Buffer);
            raise;
      end;
   end Read_All_Output;

   function Wait
     (Self      : in Process;
      Block     : in Boolean := True;
      Exit_Code : out C.int) return Boolean
   is
      Status : aliased C.int := -1;
   begin
      Require_Valid (Self);

      if Boolean
          (Raw.Wait_Process
             (Self      => Self.Internal,
              Block     => To_C_Bool (Block),
              Exit_Code => Status'Access))
      then
         Exit_Code := Status;
         return True;
      end if;

      Exit_Code := Status;
      return False;
   end Wait;

   function Kill
     (Self  : in Process;
      Force : in Boolean := False) return Boolean
   is
   begin
      Require_Valid (Self);
      return Boolean
        (Raw.Kill_Process (Self.Internal, To_C_Bool (Force)));
   end Kill;
end SDL.Processes;
