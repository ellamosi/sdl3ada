package body SDL.Atomics is
   function Try_Lock (Lock : in out Spin_Lock) return Boolean is
      Raw_Lock : aliased SDL.Raw.Atomic.Spin_Lock :=
        SDL.Raw.Atomic.Spin_Lock (Lock);
   begin
      return Result : constant Boolean :=
        Boolean (SDL.Raw.Atomic.Try_Lock_Spinlock (Raw_Lock'Access))
      do
         Lock := Spin_Lock (Raw_Lock);
      end return;
   end Try_Lock;

   procedure Lock (Lock : in out Spin_Lock) is
      Raw_Lock : aliased SDL.Raw.Atomic.Spin_Lock :=
        SDL.Raw.Atomic.Spin_Lock (Lock);
   begin
      SDL.Raw.Atomic.Lock_Spinlock (Raw_Lock'Access);
      Lock := Spin_Lock (Raw_Lock);
   end Lock;

   procedure Unlock (Lock : in out Spin_Lock) is
      Raw_Lock : aliased SDL.Raw.Atomic.Spin_Lock :=
        SDL.Raw.Atomic.Spin_Lock (Lock);
   begin
      SDL.Raw.Atomic.Unlock_Spinlock (Raw_Lock'Access);
      Lock := Spin_Lock (Raw_Lock);
   end Unlock;

   procedure Memory_Barrier_Release is
   begin
      SDL.Raw.Atomic.Memory_Barrier_Release_Function;
   end Memory_Barrier_Release;

   procedure Memory_Barrier_Acquire is
   begin
      SDL.Raw.Atomic.Memory_Barrier_Acquire_Function;
   end Memory_Barrier_Acquire;

   function Compare_And_Swap
     (Value     : in out Atomic_Integer;
      Old_Value : in C.int;
      New_Value : in C.int) return Boolean is
   begin
      return Boolean
        (SDL.Raw.Atomic.Compare_And_Swap_Atomic_Int
           (Value.Internal'Access, Old_Value, New_Value));
   end Compare_And_Swap;

   function Set
     (Value : in out Atomic_Integer;
      To    : in C.int) return C.int is
   begin
      return SDL.Raw.Atomic.Set_Atomic_Int (Value.Internal'Access, To);
   end Set;

   function Get (Value : in Atomic_Integer) return C.int is
   begin
      return SDL.Raw.Atomic.Get_Atomic_Int (Value.Internal'Access);
   end Get;

   function Add
     (Value  : in out Atomic_Integer;
      Amount : in C.int) return C.int is
   begin
      return SDL.Raw.Atomic.Add_Atomic_Int (Value.Internal'Access, Amount);
   end Add;

   function Increment_Reference (Value : in out Atomic_Integer) return C.int is
   begin
      return Add (Value, 1);
   end Increment_Reference;

   function Decrement_Reference (Value : in out Atomic_Integer) return Boolean is
   begin
      return Add (Value, -1) = 1;
   end Decrement_Reference;

   function Compare_And_Swap
     (Value     : in out Atomic_Unsigned_32;
      Old_Value : in Interfaces.Unsigned_32;
      New_Value : in Interfaces.Unsigned_32) return Boolean is
   begin
      return Boolean
        (SDL.Raw.Atomic.Compare_And_Swap_Atomic_U32
           (Value.Internal'Access, Old_Value, New_Value));
   end Compare_And_Swap;

   function Set
     (Value : in out Atomic_Unsigned_32;
      To    : in Interfaces.Unsigned_32) return Interfaces.Unsigned_32 is
   begin
      return SDL.Raw.Atomic.Set_Atomic_U32 (Value.Internal'Access, To);
   end Set;

   function Get
     (Value : in Atomic_Unsigned_32) return Interfaces.Unsigned_32 is
   begin
      return SDL.Raw.Atomic.Get_Atomic_U32 (Value.Internal'Access);
   end Get;

   function Add
     (Value  : in out Atomic_Unsigned_32;
      Amount : in C.int) return Interfaces.Unsigned_32 is
   begin
      return SDL.Raw.Atomic.Add_Atomic_U32 (Value.Internal'Access, Amount);
   end Add;

   function Compare_And_Swap
     (Value     : in out Atomic_Pointer;
      Old_Value : in System.Address;
      New_Value : in System.Address) return Boolean is
   begin
      return Boolean
        (SDL.Raw.Atomic.Compare_And_Swap_Atomic_Pointer
           (Value.Internal'Access, Old_Value, New_Value));
   end Compare_And_Swap;

   function Set
     (Value : in out Atomic_Pointer;
      To    : in System.Address) return System.Address is
   begin
      return SDL.Raw.Atomic.Set_Atomic_Pointer (Value.Internal'Access, To);
   end Set;

   function Get (Value : in Atomic_Pointer) return System.Address is
   begin
      return SDL.Raw.Atomic.Get_Atomic_Pointer (Value.Internal'Access);
   end Get;
end SDL.Atomics;
