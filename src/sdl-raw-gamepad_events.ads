with Interfaces.C.Extensions;

package SDL.Raw.Gamepad_Events is
   pragma Pure;

   package CE renames Interfaces.C.Extensions;

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
end SDL.Raw.Gamepad_Events;
