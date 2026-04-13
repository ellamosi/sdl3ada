with Interfaces;
with Interfaces.C;
with Interfaces.C.Extensions;
with Interfaces.C.Strings;
with System;

with SDL.Raw.Atomic;
with SDL.Raw.Properties;

package SDL.Raw.Thread is
   pragma Preelaborate;

   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;
   package CS renames Interfaces.C.Strings;

   type Threads is null record;
   type Thread_Access is access all Threads with
     Convention => C;

   subtype Thread_ID is Interfaces.Unsigned_64;
   subtype TLS_ID is SDL.Raw.Atomic.Atomic_Int;

   type Thread_Priority is
     (Low_Priority,
      Normal_Priority,
      High_Priority,
      Time_Critical_Priority)
   with
     Convention => C,
     Size       => C.int'Size;

   for Thread_Priority use
     (Low_Priority           => 0,
      Normal_Priority        => 1,
      High_Priority          => 2,
      Time_Critical_Priority => 3);

   type Thread_State is
     (Unknown,
      Alive,
      Detached,
      Complete)
   with
     Convention => C,
     Size       => C.int'Size;

   for Thread_State use
     (Unknown  => 0,
      Alive    => 1,
      Detached => 2,
      Complete => 3);

   type Thread_Function is access function
     (User_Data : in System.Address) return C.int
   with Convention => C;

   type TLS_Destructor_Callback is access procedure
     (Value : in System.Address)
   with Convention => C;

   Thread_Create_Entry_Function_Property : constant String :=
     "SDL.thread.create.entry_function";
   Thread_Create_Name_Property : constant String := "SDL.thread.create.name";
   Thread_Create_User_Data_Property : constant String :=
     "SDL.thread.create.userdata";
   Thread_Create_Stack_Size_Property : constant String :=
     "SDL.thread.create.stacksize";

   function Create_Thread_Runtime
     (Callback     : in Thread_Function;
      Name         : in CS.chars_ptr;
      User_Data    : in System.Address;
      Begin_Thread : in System.Address;
      End_Thread   : in System.Address) return Thread_Access
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CreateThreadRuntime";

   function Create_Thread_With_Properties_Runtime
     (Properties   : in SDL.Raw.Properties.ID;
      Begin_Thread : in System.Address;
      End_Thread   : in System.Address) return Thread_Access
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CreateThreadWithPropertiesRuntime";

   function Get_Thread_Name (Self : in Thread_Access) return CS.chars_ptr with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetThreadName";

   function Get_Current_Thread_ID return Thread_ID with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetCurrentThreadID";

   function Get_Thread_ID (Self : in Thread_Access) return Thread_ID with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetThreadID";

   function Set_Current_Thread_Priority
     (Priority : in Thread_Priority) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetCurrentThreadPriority";

   procedure Wait_Thread
     (Self        : in Thread_Access;
      Exit_Status : access C.int)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_WaitThread";

   function Get_Thread_State (Self : in Thread_Access) return Thread_State with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetThreadState";

   procedure Detach_Thread (Self : in Thread_Access) with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_DetachThread";

   function Get_TLS (ID : access TLS_ID) return System.Address with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetTLS";

   function Set_TLS
     (ID         : access TLS_ID;
      Value      : in System.Address;
      Destructor : in TLS_Destructor_Callback) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetTLS";

   procedure Cleanup_TLS with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CleanupTLS";
end SDL.Raw.Thread;
