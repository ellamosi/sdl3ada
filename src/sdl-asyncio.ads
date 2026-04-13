with Ada.Finalization;
with System;

with SDL.Raw.AsyncIO;

package SDL.AsyncIO is
   pragma Elaborate_Body;

   AsyncIO_Error : exception;

   subtype Offsets is SDL.Raw.AsyncIO.Offsets;
   subtype Sizes is SDL.Raw.AsyncIO.Sizes;
   subtype Timeout_Milliseconds is SDL.Raw.AsyncIO.Timeout_Milliseconds;

   Infinite_Timeout : constant Timeout_Milliseconds :=
     SDL.Raw.AsyncIO.Infinite_Timeout;

   subtype Task_Types is SDL.Raw.AsyncIO.Task_Types;
   subtype Results is SDL.Raw.AsyncIO.Results;
   subtype Async_IO_Handle is SDL.Raw.AsyncIO.Async_IO_Access;
   subtype Outcome is SDL.Raw.AsyncIO.Outcome;

   Read_Task  : constant Task_Types := SDL.Raw.AsyncIO.Read_Task;
   Write_Task : constant Task_Types := SDL.Raw.AsyncIO.Write_Task;
   Close_Task : constant Task_Types := SDL.Raw.AsyncIO.Close_Task;

   Complete : constant Results := SDL.Raw.AsyncIO.Complete;
   Failure  : constant Results := SDL.Raw.AsyncIO.Failure;
   Canceled : constant Results := SDL.Raw.AsyncIO.Canceled;

   type Async_IO is limited private;
   type Queue is new Ada.Finalization.Limited_Controlled with private;

   overriding
   procedure Finalize (Self : in out Queue);

   function Open
     (File : in String;
      Mode : in String) return Async_IO;

   procedure Open
     (Self : in out Async_IO;
      File : in String;
      Mode : in String);

   function Is_Null (Self : in Async_IO) return Boolean with
     Inline;

   function Get_Handle
     (Self : in Async_IO) return Async_IO_Handle with
     Inline;

   function Size (Self : in Async_IO) return Sizes;

   procedure Read
     (Self             : in Async_IO;
      Buffer           : in System.Address;
      Offset           : in Offsets;
      Byte_Count       : in Sizes;
      Completion_Queue : in Queue;
      User_Data        : in System.Address := System.Null_Address);

   procedure Write
     (Self             : in Async_IO;
      Buffer           : in System.Address;
      Offset           : in Offsets;
      Byte_Count       : in Sizes;
      Completion_Queue : in Queue;
      User_Data        : in System.Address := System.Null_Address);

   procedure Close
     (Self             : in out Async_IO;
      Flush            : in Boolean;
      Completion_Queue : in Queue;
      User_Data        : in System.Address := System.Null_Address);

   function Create return Queue;
   procedure Create (Self : in out Queue);
   procedure Destroy (Self : in out Queue);

   function Is_Null (Self : in Queue) return Boolean with
     Inline;

   function Get_Result
     (Self : in Queue;
      Item : out Outcome) return Boolean;

   function Wait_Result
     (Self       : in Queue;
      Item       : out Outcome;
      Timeout_MS : in Timeout_Milliseconds := Infinite_Timeout) return Boolean;

   procedure Signal (Self : in Queue);

   procedure Load_File
     (File             : in String;
      Completion_Queue : in Queue;
      User_Data        : in System.Address := System.Null_Address);

   procedure Free_Buffer (Item : in out Outcome);
private
   type Async_IO is limited record
      Internal : SDL.Raw.AsyncIO.Async_IO_Access := null;
   end record;

   type Queue is new Ada.Finalization.Limited_Controlled with
      record
         Internal : SDL.Raw.AsyncIO.Queue_Access := null;
      end record;
end SDL.AsyncIO;
