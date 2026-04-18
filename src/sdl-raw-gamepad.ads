with Interfaces;
with Interfaces.C.Extensions;
with System;

with SDL.Raw.Gamepad_Events;

package SDL.Raw.Gamepad is
   pragma Preelaborate;

   package CE renames Interfaces.C.Extensions;

   subtype ID is Interfaces.Unsigned_32;

   procedure Update renames SDL.Raw.Gamepad_Events.Update;

   function Events_Enabled return CE.bool renames
     SDL.Raw.Gamepad_Events.Events_Enabled;

   procedure Set_Events_Enabled (Enabled : in CE.bool) renames
     SDL.Raw.Gamepad_Events.Set_Events_Enabled;

   function Open_Gamepad
     (Device : in ID) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_OpenGamepad";
end SDL.Raw.Gamepad;
