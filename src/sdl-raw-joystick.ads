with Interfaces;
with Interfaces.C.Extensions;
with System;

package SDL.Raw.Joystick is
   pragma Pure;

   package CE renames Interfaces.C.Extensions;

   subtype ID is Interfaces.Unsigned_32;

   procedure Update
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_UpdateJoysticks";

   function Events_Enabled return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_JoystickEventsEnabled";

   procedure Set_Events_Enabled (Enabled : in CE.bool)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetJoystickEventsEnabled";

   function Open_Joystick
     (Device : in ID) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_OpenJoystick";
end SDL.Raw.Joystick;
