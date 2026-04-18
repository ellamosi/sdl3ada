with Interfaces.C.Extensions;

package SDL.Raw.Joystick_Events is
   pragma Pure;

   package CE renames Interfaces.C.Extensions;

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
end SDL.Raw.Joystick_Events;
