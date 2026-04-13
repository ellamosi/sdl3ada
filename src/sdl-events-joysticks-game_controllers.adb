with Interfaces.C.Extensions;

package body SDL.Events.Joysticks.Game_Controllers is
   package CE renames Interfaces.C.Extensions;

   function To_C_Bool (Value : in Boolean) return CE.bool is
     (if Value then CE.bool'Val (1) else CE.bool'Val (0));

   function SDL_Gamepad_Events_Enabled return CE.bool with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GamepadEventsEnabled";

   procedure SDL_Set_Gamepad_Events_Enabled (Enabled : in CE.bool) with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetGamepadEventsEnabled";

   function Is_Polling_Enabled return Boolean is
   begin
      return Boolean (SDL_Gamepad_Events_Enabled);
   end Is_Polling_Enabled;

   procedure Enable_Polling is
   begin
      SDL_Set_Gamepad_Events_Enabled (To_C_Bool (True));
   end Enable_Polling;

   procedure Disable_Polling is
   begin
      SDL_Set_Gamepad_Events_Enabled (To_C_Bool (False));
   end Disable_Polling;
end SDL.Events.Joysticks.Game_Controllers;
