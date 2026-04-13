package body SDL.Events.Joysticks is
   function To_C_Bool (Value : in Boolean) return CE.bool is
     (if Value then CE.bool'Val (1) else CE.bool'Val (0));

   function SDL_Joystick_Events_Enabled return CE.bool with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_JoystickEventsEnabled";

   procedure SDL_Set_Joystick_Events_Enabled (Enabled : in CE.bool) with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetJoystickEventsEnabled";

   function Is_Polling_Enabled return Boolean is
   begin
      return Boolean (SDL_Joystick_Events_Enabled);
   end Is_Polling_Enabled;

   procedure Enable_Polling is
   begin
      SDL_Set_Joystick_Events_Enabled (To_C_Bool (True));
   end Enable_Polling;

   procedure Disable_Polling is
   begin
      SDL_Set_Joystick_Events_Enabled (To_C_Bool (False));
   end Disable_Polling;
end SDL.Events.Joysticks;
