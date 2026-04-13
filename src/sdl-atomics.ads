with Interfaces;
with Interfaces.C;
with System;

with SDL.Raw.Atomic;

package SDL.Atomics is
   pragma Preelaborate;

   package C renames Interfaces.C;

   type Spin_Lock is new SDL.Raw.Atomic.Spin_Lock;

   Unlocked : constant Spin_Lock := 0;

   type Atomic_Integer is private;
   type Atomic_Unsigned_32 is private;
   type Atomic_Pointer is private;

   function Try_Lock (Lock : in out Spin_Lock) return Boolean;
   procedure Lock (Lock : in out Spin_Lock);
   procedure Unlock (Lock : in out Spin_Lock);

   procedure Memory_Barrier_Release;
   procedure Memory_Barrier_Acquire;

   function Compare_And_Swap
     (Value     : in out Atomic_Integer;
      Old_Value : in C.int;
      New_Value : in C.int) return Boolean;

   function Set
     (Value : in out Atomic_Integer;
      To    : in C.int) return C.int;

   function Get (Value : in Atomic_Integer) return C.int;

   function Add
     (Value  : in out Atomic_Integer;
      Amount : in C.int) return C.int;

   function Increment_Reference (Value : in out Atomic_Integer) return C.int;
   function Decrement_Reference (Value : in out Atomic_Integer) return Boolean;

   function Compare_And_Swap
     (Value     : in out Atomic_Unsigned_32;
      Old_Value : in Interfaces.Unsigned_32;
      New_Value : in Interfaces.Unsigned_32) return Boolean;

   function Set
     (Value : in out Atomic_Unsigned_32;
      To    : in Interfaces.Unsigned_32) return Interfaces.Unsigned_32;

   function Get (Value : in Atomic_Unsigned_32) return Interfaces.Unsigned_32;

   function Add
     (Value  : in out Atomic_Unsigned_32;
      Amount : in C.int) return Interfaces.Unsigned_32;

   function Compare_And_Swap
     (Value     : in out Atomic_Pointer;
      Old_Value : in System.Address;
      New_Value : in System.Address) return Boolean;

   function Set
     (Value : in out Atomic_Pointer;
      To    : in System.Address) return System.Address;

   function Get (Value : in Atomic_Pointer) return System.Address;
private
   type Atomic_Integer is record
      Internal : aliased SDL.Raw.Atomic.Atomic_Int := (Value => 0);
   end record;

   type Atomic_Unsigned_32 is record
      Internal : aliased SDL.Raw.Atomic.Atomic_U32 := (Value => 0);
   end record;

   type Atomic_Pointer is record
      Internal : aliased System.Address := System.Null_Address;
   end record;
end SDL.Atomics;
