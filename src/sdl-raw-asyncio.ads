with Interfaces;
with Interfaces.C;
with Interfaces.C.Extensions;
with System;

package SDL.Raw.AsyncIO is
   pragma Preelaborate;

   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;

   type Async_IO_Object is null record;
   type Async_IO_Access is access all Async_IO_Object with
     Convention => C;

   type Queue_Object is null record;
   type Queue_Access is access all Queue_Object with
     Convention => C;

   subtype Offsets is Interfaces.Unsigned_64;
   subtype Sizes is Interfaces.Unsigned_64;
   subtype Signed_Sizes is Interfaces.Integer_64;
   subtype Timeout_Milliseconds is Interfaces.Integer_32;

   Infinite_Timeout : constant Timeout_Milliseconds :=
     Timeout_Milliseconds (-1);

   type Task_Types is
     (Read_Task,
      Write_Task,
      Close_Task)
   with
     Convention => C,
     Size       => C.int'Size;

   for Task_Types use
     (Read_Task  => 0,
      Write_Task => 1,
      Close_Task => 2);

   type Results is
     (Complete,
      Failure,
      Canceled)
   with
     Convention => C,
     Size       => C.int'Size;

   for Results use
     (Complete => 0,
      Failure  => 1,
      Canceled => 2);

   type Outcome is record
      Async_IO_Handle   : Async_IO_Access := null;
      Task_Type         : Task_Types := Read_Task;
      Result            : Results := Complete;
      Buffer            : System.Address := System.Null_Address;
      Offset            : Offsets := 0;
      Bytes_Requested   : Sizes := 0;
      Bytes_Transferred : Sizes := 0;
      User_Data         : System.Address := System.Null_Address;
   end record
   with Convention => C;

   function Async_IO_From_File
     (File : in C.char_array;
      Mode : in C.char_array) return Async_IO_Access
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_AsyncIOFromFile";

   function Get_Async_IO_Size
     (Self : in Async_IO_Access) return Signed_Sizes
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetAsyncIOSize";

   function Read_Async_IO
     (Self      : in Async_IO_Access;
      Buffer    : in System.Address;
      Offset    : in Offsets;
      Size      : in Sizes;
      Queue     : in Queue_Access;
      User_Data : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ReadAsyncIO";

   function Write_Async_IO
     (Self      : in Async_IO_Access;
      Buffer    : in System.Address;
      Offset    : in Offsets;
      Size      : in Sizes;
      Queue     : in Queue_Access;
      User_Data : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_WriteAsyncIO";

   function Close_Async_IO
     (Self      : in Async_IO_Access;
      Flush     : in CE.bool;
      Queue     : in Queue_Access;
      User_Data : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CloseAsyncIO";

   function Create_Async_IO_Queue return Queue_Access with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CreateAsyncIOQueue";

   procedure Destroy_Async_IO_Queue (Self : in Queue_Access) with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_DestroyAsyncIOQueue";

   function Get_Async_IO_Result
     (Self : in Queue_Access;
      Item : access Outcome) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetAsyncIOResult";

   function Wait_Async_IO_Result
     (Self       : in Queue_Access;
      Item       : access Outcome;
      Timeout_MS : in Timeout_Milliseconds) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_WaitAsyncIOResult";

   procedure Signal_Async_IO_Queue (Self : in Queue_Access) with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SignalAsyncIOQueue";

   function Load_File_Async
     (File      : in C.char_array;
      Queue     : in Queue_Access;
      User_Data : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_LoadFileAsync";
end SDL.Raw.AsyncIO;
