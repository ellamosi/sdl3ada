with Interfaces.C;
with Interfaces.C.Extensions;

with SDL.Error;

package body SDL.AsyncIO is
   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;
   package Raw renames SDL.Raw.AsyncIO;

   use type Raw.Async_IO_Access;
   use type Raw.Queue_Access;
   use type Raw.Signed_Sizes;
   use type System.Address;

   function To_C_Bool (Value : in Boolean) return CE.bool is
     (CE.bool'Val (Boolean'Pos (Value)));

   procedure Raise_Last_Error;
   procedure Require_Valid (Self : in Async_IO);
   procedure Require_Valid (Self : in Queue);

   procedure Raise_Last_Error is
   begin
      raise AsyncIO_Error with SDL.Error.Get;
   end Raise_Last_Error;

   procedure Require_Valid (Self : in Async_IO) is
   begin
      if Self.Internal = null then
         raise AsyncIO_Error with "Invalid async I/O handle";
      end if;
   end Require_Valid;

   procedure Require_Valid (Self : in Queue) is
   begin
      if Self.Internal = null then
         raise AsyncIO_Error with "Invalid async I/O queue";
      end if;
   end Require_Valid;

   function Open
     (File : in String;
      Mode : in String) return Async_IO
   is
      Internal : constant Raw.Async_IO_Access :=
        Raw.Async_IO_From_File
          (File => C.To_C (File),
           Mode => C.To_C (Mode));
   begin
      if Internal = null then
         Raise_Last_Error;
      end if;

      return Result : Async_IO do
         Result.Internal := Internal;
      end return;
   end Open;

   procedure Open
     (Self : in out Async_IO;
      File : in String;
      Mode : in String)
   is
      Internal : Raw.Async_IO_Access;
   begin
      if Self.Internal /= null then
         raise AsyncIO_Error with "Async I/O handle is already open";
      end if;

      Internal :=
        Raw.Async_IO_From_File
          (File => C.To_C (File),
           Mode => C.To_C (Mode));

      if Internal = null then
         Raise_Last_Error;
      end if;

      Self.Internal := Internal;
   end Open;

   function Is_Null (Self : in Async_IO) return Boolean is
     (Self.Internal = null);

   function Get_Handle
     (Self : in Async_IO) return Async_IO_Handle is
     (Self.Internal);

   function Size (Self : in Async_IO) return Sizes is
      Value : Raw.Signed_Sizes;
   begin
      Require_Valid (Self);

      Value := Raw.Get_Async_IO_Size (Self.Internal);
      if Value < 0 then
         Raise_Last_Error;
      end if;

      return Sizes (Value);
   end Size;

   procedure Read
     (Self             : in Async_IO;
      Buffer           : in System.Address;
      Offset           : in Offsets;
      Byte_Count       : in Sizes;
      Completion_Queue : in Queue;
      User_Data        : in System.Address := System.Null_Address)
   is
   begin
      Require_Valid (Self);
      Require_Valid (Completion_Queue);

      if not Boolean
          (Raw.Read_Async_IO
             (Self      => Self.Internal,
              Buffer    => Buffer,
              Offset    => Offset,
              Size      => Byte_Count,
              Queue     => Completion_Queue.Internal,
              User_Data => User_Data))
      then
         Raise_Last_Error;
      end if;
   end Read;

   procedure Write
     (Self             : in Async_IO;
      Buffer           : in System.Address;
      Offset           : in Offsets;
      Byte_Count       : in Sizes;
      Completion_Queue : in Queue;
      User_Data        : in System.Address := System.Null_Address)
   is
   begin
      Require_Valid (Self);
      Require_Valid (Completion_Queue);

      if not Boolean
          (Raw.Write_Async_IO
             (Self      => Self.Internal,
              Buffer    => Buffer,
              Offset    => Offset,
              Size      => Byte_Count,
              Queue     => Completion_Queue.Internal,
              User_Data => User_Data))
      then
         Raise_Last_Error;
      end if;
   end Write;

   procedure Close
     (Self             : in out Async_IO;
      Flush            : in Boolean;
      Completion_Queue : in Queue;
      User_Data        : in System.Address := System.Null_Address)
   is
   begin
      if Self.Internal = null then
         return;
      end if;

      Require_Valid (Completion_Queue);

      if not Boolean
          (Raw.Close_Async_IO
             (Self      => Self.Internal,
              Flush     => To_C_Bool (Flush),
              Queue     => Completion_Queue.Internal,
              User_Data => User_Data))
      then
         Raise_Last_Error;
      end if;

      Self.Internal := null;
   end Close;

   overriding
   procedure Finalize (Self : in out Queue) is
   begin
      Destroy (Self);
   end Finalize;

   function Create return Queue is
      Internal : constant Raw.Queue_Access := Raw.Create_Async_IO_Queue;
   begin
      if Internal = null then
         Raise_Last_Error;
      end if;

      return Result : Queue do
         Result.Internal := Internal;
      end return;
   end Create;

   procedure Create (Self : in out Queue) is
      Internal : constant Raw.Queue_Access := Raw.Create_Async_IO_Queue;
   begin
      Destroy (Self);

      if Internal = null then
         Raise_Last_Error;
      end if;

      Self.Internal := Internal;
   end Create;

   procedure Destroy (Self : in out Queue) is
   begin
      if Self.Internal /= null then
         Raw.Destroy_Async_IO_Queue (Self.Internal);
         Self.Internal := null;
      end if;
   end Destroy;

   function Is_Null (Self : in Queue) return Boolean is
     (Self.Internal = null);

   function Get_Result
     (Self : in Queue;
      Item : out Outcome) return Boolean
   is
      Raw_Item : aliased Outcome;
   begin
      Require_Valid (Self);

      if Boolean
          (Raw.Get_Async_IO_Result
             (Self => Self.Internal,
              Item => Raw_Item'Access))
      then
         Item := Raw_Item;
         return True;
      end if;

      return False;
   end Get_Result;

   function Wait_Result
     (Self       : in Queue;
      Item       : out Outcome;
      Timeout_MS : in Timeout_Milliseconds := Infinite_Timeout) return Boolean
   is
      Raw_Item : aliased Outcome;
   begin
      Require_Valid (Self);

      if Boolean
          (Raw.Wait_Async_IO_Result
             (Self       => Self.Internal,
              Item       => Raw_Item'Access,
              Timeout_MS => Timeout_MS))
      then
         Item := Raw_Item;
         return True;
      end if;

      return False;
   end Wait_Result;

   procedure Signal (Self : in Queue) is
   begin
      Require_Valid (Self);
      Raw.Signal_Async_IO_Queue (Self.Internal);
   end Signal;

   procedure Load_File
     (File             : in String;
      Completion_Queue : in Queue;
      User_Data        : in System.Address := System.Null_Address)
   is
   begin
      Require_Valid (Completion_Queue);

      if not Boolean
          (Raw.Load_File_Async
             (File      => C.To_C (File),
              Queue     => Completion_Queue.Internal,
              User_Data => User_Data))
      then
         Raise_Last_Error;
      end if;
   end Load_File;

   procedure Free_Buffer (Item : in out Outcome) is
   begin
      if Item.Buffer /= System.Null_Address then
         Raw.Free (Item.Buffer);
         Item.Buffer := System.Null_Address;
      end if;
   end Free_Buffer;
end SDL.AsyncIO;
