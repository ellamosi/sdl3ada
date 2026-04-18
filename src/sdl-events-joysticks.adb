with SDL.Raw.Joystick;

package body SDL.Events.Joysticks is
   package Raw renames SDL.Raw.Joystick;

   function To_C_Bool (Value : in Boolean) return CE.bool is
     (if Value then CE.bool'Val (1) else CE.bool'Val (0));

   procedure Update is
   begin
      Raw.Update;
   end Update;

   function Is_Polling_Enabled return Boolean is
   begin
      return Boolean (Raw.Events_Enabled);
   end Is_Polling_Enabled;

   procedure Enable_Polling is
   begin
      Raw.Set_Events_Enabled (To_C_Bool (True));
   end Enable_Polling;

   procedure Disable_Polling is
   begin
      Raw.Set_Events_Enabled (To_C_Bool (False));
   end Disable_Polling;
end SDL.Events.Joysticks;
