with Interfaces.C.Extensions;

with SDL.Error;
with SDL.Raw.Atomic;

package body SDL.Mutexes is
   package CE renames Interfaces.C.Extensions;

   use type SDL.Raw.Mutex.Condition_Access;
   use type SDL.Raw.Mutex.Mutex_Access;
   use type SDL.Raw.Mutex.RW_Lock_Access;
   use type SDL.Raw.Mutex.Semaphore_Access;

   function To_C_Bool (Value : in Boolean) return CE.bool is
     (CE.bool'Val (Boolean'Pos (Value)));

   procedure Raise_Last_Error;
   procedure Raise_Last_Error is
   begin
      raise Mutex_Error with SDL.Error.Get;
   end Raise_Last_Error;

   procedure Require_Valid (Self : in Mutex);
   procedure Require_Valid (Self : in Mutex) is
   begin
      if Self.Internal = null then
         raise Mutex_Error with "Invalid mutex";
      end if;
   end Require_Valid;

   procedure Require_Valid (Self : in RW_Lock);
   procedure Require_Valid (Self : in RW_Lock) is
   begin
      if Self.Internal = null then
         raise Mutex_Error with "Invalid read/write lock";
      end if;
   end Require_Valid;

   procedure Require_Valid (Self : in Semaphore);
   procedure Require_Valid (Self : in Semaphore) is
   begin
      if Self.Internal = null then
         raise Mutex_Error with "Invalid semaphore";
      end if;
   end Require_Valid;

   procedure Require_Valid (Self : in Condition);
   procedure Require_Valid (Self : in Condition) is
   begin
      if Self.Internal = null then
         raise Mutex_Error with "Invalid condition";
      end if;
   end Require_Valid;

   function Status (State : in Init_State) return Init_Status is
      Value : constant Interfaces.C.int :=
        SDL.Raw.Atomic.Get_Atomic_Int (State.Internal.Status'Access);
   begin
      return Init_Status'Val (Value);
   end Status;

   function Should_Init (State : in out Init_State) return Boolean is
   begin
      return Boolean (SDL.Raw.Mutex.Should_Init (State.Internal'Access));
   end Should_Init;

   function Should_Quit (State : in out Init_State) return Boolean is
   begin
      return Boolean (SDL.Raw.Mutex.Should_Quit (State.Internal'Access));
   end Should_Quit;

   procedure Set_Initialized
     (State       : in out Init_State;
      Initialized : in Boolean) is
   begin
      SDL.Raw.Mutex.Set_Initialized
        (State.Internal'Access, To_C_Bool (Initialized));
   end Set_Initialized;

   overriding
   procedure Finalize (Self : in out Mutex) is
   begin
      Destroy (Self);
   end Finalize;

   function Create return Mutex is
      Internal : constant SDL.Raw.Mutex.Mutex_Access :=
        SDL.Raw.Mutex.Create_Mutex;
   begin
      if Internal = null then
         Raise_Last_Error;
      end if;

      return Result : Mutex do
         Result.Internal := Internal;
      end return;
   end Create;

   procedure Create (Self : in out Mutex) is
      Internal : constant SDL.Raw.Mutex.Mutex_Access :=
        SDL.Raw.Mutex.Create_Mutex;
   begin
      Destroy (Self);

      if Internal = null then
         Raise_Last_Error;
      end if;

      Self.Internal := Internal;
   end Create;

   procedure Destroy (Self : in out Mutex) is
   begin
      if Self.Internal /= null then
         SDL.Raw.Mutex.Destroy_Mutex (Self.Internal);
         Self.Internal := null;
      end if;
   end Destroy;

   function Is_Null (Self : in Mutex) return Boolean is
     (Self.Internal = null);

   procedure Lock (Self : in Mutex) is
   begin
      Require_Valid (Self);
      SDL.Raw.Mutex.Lock_Mutex (Self.Internal);
   end Lock;

   function Try_Lock (Self : in Mutex) return Boolean is
   begin
      Require_Valid (Self);
      return Boolean (SDL.Raw.Mutex.Try_Lock_Mutex (Self.Internal));
   end Try_Lock;

   procedure Unlock (Self : in Mutex) is
   begin
      Require_Valid (Self);
      SDL.Raw.Mutex.Unlock_Mutex (Self.Internal);
   end Unlock;

   overriding
   procedure Finalize (Self : in out RW_Lock) is
   begin
      Destroy (Self);
   end Finalize;

   function Create return RW_Lock is
      Internal : constant SDL.Raw.Mutex.RW_Lock_Access :=
        SDL.Raw.Mutex.Create_RW_Lock;
   begin
      if Internal = null then
         Raise_Last_Error;
      end if;

      return Result : RW_Lock do
         Result.Internal := Internal;
      end return;
   end Create;

   procedure Create (Self : in out RW_Lock) is
      Internal : constant SDL.Raw.Mutex.RW_Lock_Access :=
        SDL.Raw.Mutex.Create_RW_Lock;
   begin
      Destroy (Self);

      if Internal = null then
         Raise_Last_Error;
      end if;

      Self.Internal := Internal;
   end Create;

   procedure Destroy (Self : in out RW_Lock) is
   begin
      if Self.Internal /= null then
         SDL.Raw.Mutex.Destroy_RW_Lock (Self.Internal);
         Self.Internal := null;
      end if;
   end Destroy;

   function Is_Null (Self : in RW_Lock) return Boolean is
     (Self.Internal = null);

   procedure Lock_For_Reading (Self : in RW_Lock) is
   begin
      Require_Valid (Self);
      SDL.Raw.Mutex.Lock_RW_Lock_For_Reading (Self.Internal);
   end Lock_For_Reading;

   procedure Lock_For_Writing (Self : in RW_Lock) is
   begin
      Require_Valid (Self);
      SDL.Raw.Mutex.Lock_RW_Lock_For_Writing (Self.Internal);
   end Lock_For_Writing;

   function Try_Lock_For_Reading (Self : in RW_Lock) return Boolean is
   begin
      Require_Valid (Self);
      return Boolean
        (SDL.Raw.Mutex.Try_Lock_RW_Lock_For_Reading (Self.Internal));
   end Try_Lock_For_Reading;

   function Try_Lock_For_Writing (Self : in RW_Lock) return Boolean is
   begin
      Require_Valid (Self);
      return Boolean
        (SDL.Raw.Mutex.Try_Lock_RW_Lock_For_Writing (Self.Internal));
   end Try_Lock_For_Writing;

   procedure Unlock (Self : in RW_Lock) is
   begin
      Require_Valid (Self);
      SDL.Raw.Mutex.Unlock_RW_Lock (Self.Internal);
   end Unlock;

   overriding
   procedure Finalize (Self : in out Semaphore) is
   begin
      Destroy (Self);
   end Finalize;

   function Create
     (Initial_Value : in Interfaces.Unsigned_32 := 0) return Semaphore
   is
      Internal : constant SDL.Raw.Mutex.Semaphore_Access :=
        SDL.Raw.Mutex.Create_Semaphore (Initial_Value);
   begin
      if Internal = null then
         Raise_Last_Error;
      end if;

      return Result : Semaphore do
         Result.Internal := Internal;
      end return;
   end Create;

   procedure Create
     (Self          : in out Semaphore;
      Initial_Value : in Interfaces.Unsigned_32 := 0)
   is
      Internal : constant SDL.Raw.Mutex.Semaphore_Access :=
        SDL.Raw.Mutex.Create_Semaphore (Initial_Value);
   begin
      Destroy (Self);

      if Internal = null then
         Raise_Last_Error;
      end if;

      Self.Internal := Internal;
   end Create;

   procedure Destroy (Self : in out Semaphore) is
   begin
      if Self.Internal /= null then
         SDL.Raw.Mutex.Destroy_Semaphore (Self.Internal);
         Self.Internal := null;
      end if;
   end Destroy;

   function Is_Null (Self : in Semaphore) return Boolean is
     (Self.Internal = null);

   procedure Wait (Self : in Semaphore) is
   begin
      Require_Valid (Self);
      SDL.Raw.Mutex.Wait_Semaphore (Self.Internal);
   end Wait;

   function Try_Wait (Self : in Semaphore) return Boolean is
   begin
      Require_Valid (Self);
      return Boolean (SDL.Raw.Mutex.Try_Wait_Semaphore (Self.Internal));
   end Try_Wait;

   function Wait_Timeout
     (Self       : in Semaphore;
      Timeout_MS : in Timeout_Milliseconds) return Boolean is
   begin
      Require_Valid (Self);
      return Boolean
        (SDL.Raw.Mutex.Wait_Semaphore_Timeout (Self.Internal, Timeout_MS));
   end Wait_Timeout;

   procedure Signal (Self : in Semaphore) is
   begin
      Require_Valid (Self);
      SDL.Raw.Mutex.Signal_Semaphore (Self.Internal);
   end Signal;

   function Value (Self : in Semaphore) return Interfaces.Unsigned_32 is
   begin
      Require_Valid (Self);
      return SDL.Raw.Mutex.Get_Semaphore_Value (Self.Internal);
   end Value;

   overriding
   procedure Finalize (Self : in out Condition) is
   begin
      Destroy (Self);
   end Finalize;

   function Create return Condition is
      Internal : constant SDL.Raw.Mutex.Condition_Access :=
        SDL.Raw.Mutex.Create_Condition;
   begin
      if Internal = null then
         Raise_Last_Error;
      end if;

      return Result : Condition do
         Result.Internal := Internal;
      end return;
   end Create;

   procedure Create (Self : in out Condition) is
      Internal : constant SDL.Raw.Mutex.Condition_Access :=
        SDL.Raw.Mutex.Create_Condition;
   begin
      Destroy (Self);

      if Internal = null then
         Raise_Last_Error;
      end if;

      Self.Internal := Internal;
   end Create;

   procedure Destroy (Self : in out Condition) is
   begin
      if Self.Internal /= null then
         SDL.Raw.Mutex.Destroy_Condition (Self.Internal);
         Self.Internal := null;
      end if;
   end Destroy;

   function Is_Null (Self : in Condition) return Boolean is
     (Self.Internal = null);

   procedure Signal (Self : in Condition) is
   begin
      Require_Valid (Self);
      SDL.Raw.Mutex.Signal_Condition (Self.Internal);
   end Signal;

   procedure Broadcast (Self : in Condition) is
   begin
      Require_Valid (Self);
      SDL.Raw.Mutex.Broadcast_Condition (Self.Internal);
   end Broadcast;

   procedure Wait
     (Self  : in Condition;
      Guard : in Mutex_Reference) is
   begin
      Require_Valid (Self);
      if Guard = null then
         raise Mutex_Error with "Invalid mutex";
      end if;

      Require_Valid (Guard.all);
      SDL.Raw.Mutex.Wait_Condition (Self.Internal, Guard.all.Internal);
   end Wait;

   function Wait_Timeout
     (Self       : in Condition;
      Guard      : in Mutex_Reference;
      Timeout_MS : in Timeout_Milliseconds) return Boolean is
   begin
      Require_Valid (Self);
      if Guard = null then
         raise Mutex_Error with "Invalid mutex";
      end if;

      Require_Valid (Guard.all);
      return Boolean
        (SDL.Raw.Mutex.Wait_Condition_Timeout
           (Self.Internal, Guard.all.Internal, Timeout_MS));
   end Wait_Timeout;
end SDL.Mutexes;
