with Interfaces;
with Interfaces.C;
with Interfaces.C.Extensions;
with Interfaces.C.Pointers;
with Interfaces.C.Strings;
with System;

package SDL.Raw.Touch is
   pragma Preelaborate;

   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;
   package CS renames Interfaces.C.Strings;

   subtype ID is Interfaces.Unsigned_64;
   subtype Finger_ID is Interfaces.Unsigned_64;
   subtype Location is Interfaces.C.C_float;
   subtype Distance is Interfaces.C.C_float;
   subtype Pressure_Value is Interfaces.C.C_float;

   type Device_Type is
     (Invalid_Touch_Device,
      Direct_Touch_Device,
      Indirect_Absolute_Touch_Device,
      Indirect_Relative_Touch_Device)
   with
     Convention => C,
     Size       => C.int'Size;

   for Device_Type use
     (Invalid_Touch_Device           => -1,
      Direct_Touch_Device            => 0,
      Indirect_Absolute_Touch_Device => 1,
      Indirect_Relative_Touch_Device => 2);

   type Finger is record
      ID       : Finger_ID := 0;
      X        : Location := 0.0;
      Y        : Location := 0.0;
      Pressure : Pressure_Value := 0.0;
   end record
   with Convention => C;

   type ID_Array is array (C.ptrdiff_t range <>) of aliased ID with
     Convention => C;

   package ID_Pointers is new Interfaces.C.Pointers
     (Index              => C.ptrdiff_t,
      Element            => ID,
      Element_Array      => ID_Array,
      Default_Terminator => 0);

   type Finger_Access is access all Finger with
     Convention => C;

   type Finger_Access_Array is
     array (C.ptrdiff_t range <>) of aliased Finger_Access
   with Convention => C;

   package Finger_Pointers is new Interfaces.C.Pointers
     (Index              => C.ptrdiff_t,
      Element            => Finger_Access,
      Element_Array      => Finger_Access_Array,
      Default_Terminator => null);

   procedure Free (Memory : in System.Address)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_free";

   function Get_Touch_Devices
     (Count : access C.int) return ID_Pointers.Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetTouchDevices";

   function Get_Touch_Device_Name
     (Instance : in ID) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetTouchDeviceName";

   function Get_Touch_Device_Type
     (Instance : in ID) return Device_Type
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetTouchDeviceType";

   function Get_Touch_Fingers
     (Instance : in ID;
      Count    : access C.int) return Finger_Pointers.Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetTouchFingers";
end SDL.Raw.Touch;
