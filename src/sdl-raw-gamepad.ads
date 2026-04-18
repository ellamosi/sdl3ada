with Interfaces;
with Interfaces.C.Extensions;
with System;

package SDL.Raw.Gamepad is
   pragma Pure;

   package CE renames Interfaces.C.Extensions;

   subtype ID is Interfaces.Unsigned_32;

   procedure Update
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_UpdateGamepads";

   function Events_Enabled return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GamepadEventsEnabled";

   procedure Set_Events_Enabled (Enabled : in CE.bool)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetGamepadEventsEnabled";

   function Open_Gamepad
     (Device : in ID) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_OpenGamepad";
end SDL.Raw.Gamepad;
