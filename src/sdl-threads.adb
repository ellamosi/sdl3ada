with Ada.Unchecked_Conversion;
with Interfaces.C.Strings;

with SDL.Error;

package body SDL.Threads is
   package CS renames Interfaces.C.Strings;

   use type CS.chars_ptr;
   use type SDL.Raw.Thread.Thread_Access;

   function To_Address is new Ada.Unchecked_Conversion
     (Source => Thread_Function,
      Target => System.Address);

   procedure Raise_Last_Error;
   procedure Raise_Last_Error is
   begin
      raise Thread_Error with SDL.Error.Get;
   end Raise_Last_Error;

   function Create_Internal
     (Callback  : in Thread_Function;
      Name      : in String;
      User_Data : in System.Address := System.Null_Address)
      return SDL.Raw.Thread.Thread_Access;

   function Create_Internal
     (Properties : in SDL.Properties.Property_Set)
      return SDL.Raw.Thread.Thread_Access;

   function Create_Internal
     (Callback  : in Thread_Function;
      Name      : in String;
      User_Data : in System.Address := System.Null_Address)
      return SDL.Raw.Thread.Thread_Access
   is
      C_Name   : CS.chars_ptr := CS.New_String (Name);
      Internal : SDL.Raw.Thread.Thread_Access;
   begin
      begin
         Internal :=
           SDL.Raw.Thread.Create_Thread_Runtime
             (Callback     => Callback,
              Name         => C_Name,
              User_Data    => User_Data,
              Begin_Thread => System.Null_Address,
              End_Thread   => System.Null_Address);

         if Internal = null then
            Raise_Last_Error;
         end if;
      exception
         when others =>
            CS.Free (C_Name);
            raise;
      end;

      CS.Free (C_Name);
      return Internal;
   end Create_Internal;

   function Create_Internal
     (Properties : in SDL.Properties.Property_Set)
      return SDL.Raw.Thread.Thread_Access
   is
      Internal : constant SDL.Raw.Thread.Thread_Access :=
        SDL.Raw.Thread.Create_Thread_With_Properties_Runtime
          (Properties.Get_ID, System.Null_Address, System.Null_Address);
   begin
      if Internal = null then
         Raise_Last_Error;
      end if;

      return Internal;
   end Create_Internal;

   procedure Require_Valid (Self : in Thread);
   procedure Require_Valid (Self : in Thread) is
   begin
      if Self.Internal = null then
         raise Thread_Error with "Invalid thread";
      end if;
   end Require_Valid;

   overriding
   procedure Finalize (Self : in out Thread) is
   begin
      Detach (Self);
   end Finalize;

   function Create
     (Callback  : in Thread_Function;
      Name      : in String;
      User_Data : in System.Address := System.Null_Address) return Thread
   is
      Internal : constant SDL.Raw.Thread.Thread_Access :=
        Create_Internal (Callback, Name, User_Data);
   begin
      return Result : Thread do
         Result.Internal := Internal;
      end return;
   end Create;

   procedure Create
     (Self      : in out Thread;
      Callback  : in Thread_Function;
      Name      : in String;
      User_Data : in System.Address := System.Null_Address)
   is
      Internal : constant SDL.Raw.Thread.Thread_Access :=
        Create_Internal (Callback, Name, User_Data);
   begin
      Detach (Self);
      Self.Internal := Internal;
   end Create;

   function Create (Properties : in SDL.Properties.Property_Set) return Thread is
      Internal : constant SDL.Raw.Thread.Thread_Access :=
        Create_Internal (Properties);
   begin
      return Result : Thread do
         Result.Internal := Internal;
      end return;
   end Create;

   procedure Create
     (Self       : in out Thread;
      Properties : in SDL.Properties.Property_Set)
   is
      Internal : constant SDL.Raw.Thread.Thread_Access :=
        Create_Internal (Properties);
   begin
      Detach (Self);
      Self.Internal := Internal;
   end Create;

   procedure Set_Create_Entry_Function
     (Properties : in SDL.Properties.Property_Set;
      Callback   : in Thread_Function) is
   begin
      Properties.Set_Pointer
        (Name  => Thread_Create_Entry_Function_Property,
         Value => To_Address (Callback));
   end Set_Create_Entry_Function;

   function Is_Null (Self : in Thread) return Boolean is
     (Self.Internal = null);

   function Get_Name (Self : in Thread) return String is
      Name : CS.chars_ptr;
   begin
      Require_Valid (Self);

      Name := SDL.Raw.Thread.Get_Thread_Name (Self.Internal);
      if Name = CS.Null_Ptr then
         return "";
      end if;

      return CS.Value (Name);
   end Get_Name;

   function Current_ID return Thread_ID is
     (SDL.Raw.Thread.Get_Current_Thread_ID);

   function Get_ID (Self : in Thread) return Thread_ID is
   begin
      Require_Valid (Self);
      return SDL.Raw.Thread.Get_Thread_ID (Self.Internal);
   end Get_ID;

   function State (Self : in Thread) return States is
   begin
      Require_Valid (Self);
      return SDL.Raw.Thread.Get_Thread_State (Self.Internal);
   end State;

   function Set_Current_Priority (Priority : in Priorities) return Boolean is
   begin
      return Boolean (SDL.Raw.Thread.Set_Current_Thread_Priority (Priority));
   end Set_Current_Priority;

   procedure Wait
     (Self        : in out Thread;
      Exit_Status : out C.int)
   is
      Local_Status : aliased C.int := -1;
   begin
      Exit_Status := -1;

      if Self.Internal = null then
         return;
      end if;

      SDL.Raw.Thread.Wait_Thread (Self.Internal, Local_Status'Access);
      Self.Internal := null;
      Exit_Status := Local_Status;
   end Wait;

   procedure Wait (Self : in out Thread) is
      Exit_Status : C.int;
   begin
      Wait (Self, Exit_Status);
   end Wait;

   procedure Detach (Self : in out Thread) is
   begin
      if Self.Internal /= null then
         SDL.Raw.Thread.Detach_Thread (Self.Internal);
         Self.Internal := null;
      end if;
   end Detach;

   function Get_TLS (ID : in out TLS_ID) return System.Address is
   begin
      return SDL.Raw.Thread.Get_TLS (ID.Internal'Access);
   end Get_TLS;

   function Set_TLS
     (ID         : in out TLS_ID;
      Value      : in System.Address;
      Destructor : in TLS_Destructor_Callback := null) return Boolean is
   begin
      return Boolean
        (SDL.Raw.Thread.Set_TLS (ID.Internal'Access, Value, Destructor));
   end Set_TLS;

   procedure Cleanup_TLS is
   begin
      SDL.Raw.Thread.Cleanup_TLS;
   end Cleanup_TLS;
end SDL.Threads;
