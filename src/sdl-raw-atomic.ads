with Interfaces;
with Interfaces.C;
with Interfaces.C.Extensions;
with System;

package SDL.Raw.Atomic is
   pragma Preelaborate;

   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;

   type Spin_Lock is new C.int with
     Convention => C;

   type Atomic_Int is record
      Value : aliased C.int := 0;
   end record with
     Convention => C;

   type Atomic_U32 is record
      Value : aliased Interfaces.Unsigned_32 := 0;
   end record with
     Convention => C;

   function Try_Lock_Spinlock (Lock : access Spin_Lock) return CE.bool with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_TryLockSpinlock";

   procedure Lock_Spinlock (Lock : access Spin_Lock) with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_LockSpinlock";

   procedure Unlock_Spinlock (Lock : access Spin_Lock) with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_UnlockSpinlock";

   procedure Memory_Barrier_Release_Function with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_MemoryBarrierReleaseFunction";

   procedure Memory_Barrier_Acquire_Function with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_MemoryBarrierAcquireFunction";

   function Compare_And_Swap_Atomic_Int
     (Value     : access Atomic_Int;
      Old_Value : in C.int;
      New_Value : in C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CompareAndSwapAtomicInt";

   function Set_Atomic_Int
     (Value     : access Atomic_Int;
      New_Value : in C.int) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetAtomicInt";

   function Get_Atomic_Int (Value : access constant Atomic_Int) return C.int with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetAtomicInt";

   function Add_Atomic_Int
     (Value  : access Atomic_Int;
      Amount : in C.int) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_AddAtomicInt";

   function Compare_And_Swap_Atomic_U32
     (Value     : access Atomic_U32;
      Old_Value : in Interfaces.Unsigned_32;
      New_Value : in Interfaces.Unsigned_32) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CompareAndSwapAtomicU32";

   function Set_Atomic_U32
     (Value     : access Atomic_U32;
      New_Value : in Interfaces.Unsigned_32) return Interfaces.Unsigned_32
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetAtomicU32";

   function Get_Atomic_U32
     (Value : access constant Atomic_U32) return Interfaces.Unsigned_32
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetAtomicU32";

   function Add_Atomic_U32
     (Value  : access Atomic_U32;
      Amount : in C.int) return Interfaces.Unsigned_32
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_AddAtomicU32";

   function Compare_And_Swap_Atomic_Pointer
     (Value     : access System.Address;
      Old_Value : in System.Address;
      New_Value : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CompareAndSwapAtomicPointer";

   function Set_Atomic_Pointer
     (Value     : access System.Address;
      New_Value : in System.Address) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetAtomicPointer";

   function Get_Atomic_Pointer
     (Value : access constant System.Address) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetAtomicPointer";
end SDL.Raw.Atomic;
