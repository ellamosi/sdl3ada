with SDL.Raw.Joystick_Events;

package body SDL.Events.Joysticks is
   package Raw renames SDL.Raw.Joystick_Events;

   function To_C_Bool (Value : in Boolean) return CE.bool is
     (CE.bool'Val (Boolean'Pos (Value)));

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
