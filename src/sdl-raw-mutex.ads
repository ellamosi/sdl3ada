with Interfaces;
with Interfaces.C;
with Interfaces.C.Extensions;
with System;

with SDL.Raw.Atomic;
with SDL.Raw.Thread;

package SDL.Raw.Mutex is
   pragma Preelaborate;

   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;

   type Mutexes is null record;
   type Mutex_Access is access all Mutexes with
     Convention => C;

   type RW_Locks is null record;
   type RW_Lock_Access is access all RW_Locks with
     Convention => C;

   type Semaphores is null record;
   type Semaphore_Access is access all Semaphores with
     Convention => C;

   type Conditions is null record;
   type Condition_Access is access all Conditions with
     Convention => C;

   type Init_Status is
     (Init_Status_Uninitialized,
      Init_Status_Initializing,
      Init_Status_Initialized,
      Init_Status_Uninitializing)
   with
     Convention => C,
     Size       => C.int'Size;

   for Init_Status use
     (Init_Status_Uninitialized  => 0,
      Init_Status_Initializing   => 1,
      Init_Status_Initialized    => 2,
      Init_Status_Uninitializing => 3);

   type Init_State is record
      Status   : aliased SDL.Raw.Atomic.Atomic_Int := (Value => 0);
      Thread   : SDL.Raw.Thread.Thread_ID := 0;
      Reserved : System.Address := System.Null_Address;
   end record with
     Convention => C;

   function Create_Mutex return Mutex_Access with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CreateMutex";

   procedure Lock_Mutex (Self : in Mutex_Access) with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_LockMutex";

   function Try_Lock_Mutex (Self : in Mutex_Access) return CE.bool with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_TryLockMutex";

   procedure Unlock_Mutex (Self : in Mutex_Access) with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_UnlockMutex";

   procedure Destroy_Mutex (Self : in Mutex_Access) with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_DestroyMutex";

   function Create_RW_Lock return RW_Lock_Access with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CreateRWLock";

   procedure Lock_RW_Lock_For_Reading (Self : in RW_Lock_Access) with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_LockRWLockForReading";

   procedure Lock_RW_Lock_For_Writing (Self : in RW_Lock_Access) with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_LockRWLockForWriting";

   function Try_Lock_RW_Lock_For_Reading
     (Self : in RW_Lock_Access) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_TryLockRWLockForReading";

   function Try_Lock_RW_Lock_For_Writing
     (Self : in RW_Lock_Access) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_TryLockRWLockForWriting";

   procedure Unlock_RW_Lock (Self : in RW_Lock_Access) with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_UnlockRWLock";

   procedure Destroy_RW_Lock (Self : in RW_Lock_Access) with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_DestroyRWLock";

   function Create_Semaphore
     (Initial_Value : in Interfaces.Unsigned_32) return Semaphore_Access
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CreateSemaphore";

   procedure Destroy_Semaphore (Self : in Semaphore_Access) with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_DestroySemaphore";

   procedure Wait_Semaphore (Self : in Semaphore_Access) with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_WaitSemaphore";

   function Try_Wait_Semaphore (Self : in Semaphore_Access) return CE.bool with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_TryWaitSemaphore";

   function Wait_Semaphore_Timeout
     (Self       : in Semaphore_Access;
      Timeout_MS : in Interfaces.Integer_32) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_WaitSemaphoreTimeout";

   procedure Signal_Semaphore (Self : in Semaphore_Access) with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SignalSemaphore";

   function Get_Semaphore_Value
     (Self : in Semaphore_Access) return Interfaces.Unsigned_32
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetSemaphoreValue";

   function Create_Condition return Condition_Access with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CreateCondition";

   procedure Destroy_Condition (Self : in Condition_Access) with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_DestroyCondition";

   procedure Signal_Condition (Self : in Condition_Access) with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SignalCondition";

   procedure Broadcast_Condition (Self : in Condition_Access) with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_BroadcastCondition";

   procedure Wait_Condition
     (Self  : in Condition_Access;
      Guard : in Mutex_Access)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_WaitCondition";

   function Wait_Condition_Timeout
     (Self       : in Condition_Access;
      Guard      : in Mutex_Access;
      Timeout_MS : in Interfaces.Integer_32) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_WaitConditionTimeout";

   function Should_Init (State : access Init_State) return CE.bool with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ShouldInit";

   function Should_Quit (State : access Init_State) return CE.bool with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ShouldQuit";

   procedure Set_Initialized
     (State       : access Init_State;
      Initialized : in CE.bool)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetInitialized";
end SDL.Raw.Mutex;
