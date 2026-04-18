with Interfaces;
with Interfaces.C.Extensions;

with SDL.Raw.Event_Layouts.Joysticks;

package SDL.Events.Joysticks is
   pragma Pure;

   package CE renames Interfaces.C.Extensions;

   Axis_Motion     : constant Event_Types :=
     SDL.Raw.Event_Layouts.Joysticks.Axis_Motion;
   Ball_Motion     : constant Event_Types :=
     SDL.Raw.Event_Layouts.Joysticks.Ball_Motion;
   Hat_Motion      : constant Event_Types :=
     SDL.Raw.Event_Layouts.Joysticks.Hat_Motion;
   Button_Down     : constant Event_Types :=
     SDL.Raw.Event_Layouts.Joysticks.Button_Down;
   Button_Up       : constant Event_Types :=
     SDL.Raw.Event_Layouts.Joysticks.Button_Up;
   Device_Added    : constant Event_Types :=
     SDL.Raw.Event_Layouts.Joysticks.Device_Added;
   Device_Removed  : constant Event_Types :=
     SDL.Raw.Event_Layouts.Joysticks.Device_Removed;
   Battery_Updated : constant Event_Types :=
     SDL.Raw.Event_Layouts.Joysticks.Battery_Updated;
   Update_Complete : constant Event_Types :=
     SDL.Raw.Event_Layouts.Joysticks.Update_Complete;

   subtype IDs is SDL.Raw.Event_Layouts.Joysticks.ID;

   subtype Axes is SDL.Raw.Event_Layouts.Joysticks.Axis_Index;
   subtype Axes_Values is SDL.Raw.Event_Layouts.Joysticks.Axis_Value;

   subtype Axis_Events is SDL.Raw.Event_Layouts.Joysticks.Axis_Event;

   subtype Balls is SDL.Raw.Event_Layouts.Joysticks.Ball_Index;
   subtype Ball_Values is SDL.Raw.Event_Layouts.Joysticks.Ball_Delta;

   subtype Ball_Events is SDL.Raw.Event_Layouts.Joysticks.Ball_Event;

   subtype Hats is SDL.Raw.Event_Layouts.Joysticks.Hat_Index;
   subtype Hat_Positions is SDL.Raw.Event_Layouts.Joysticks.Hat_Position;

   Hat_Centred    : constant Hat_Positions :=
     SDL.Raw.Event_Layouts.Joysticks.Hat_Centred;
   Hat_Up         : constant Hat_Positions := SDL.Raw.Event_Layouts.Joysticks.Hat_Up;
   Hat_Right      : constant Hat_Positions :=
     SDL.Raw.Event_Layouts.Joysticks.Hat_Right;
   Hat_Down       : constant Hat_Positions :=
     SDL.Raw.Event_Layouts.Joysticks.Hat_Down;
   Hat_Left       : constant Hat_Positions := SDL.Raw.Event_Layouts.Joysticks.Hat_Left;
   Hat_Right_Up   : constant Hat_Positions :=
     SDL.Raw.Event_Layouts.Joysticks.Hat_Right_Up;
   Hat_Right_Down : constant Hat_Positions :=
     SDL.Raw.Event_Layouts.Joysticks.Hat_Right_Down;
   Hat_Left_Up    : constant Hat_Positions :=
     SDL.Raw.Event_Layouts.Joysticks.Hat_Left_Up;
   Hat_Left_Down  : constant Hat_Positions :=
     SDL.Raw.Event_Layouts.Joysticks.Hat_Left_Down;

   subtype Hat_Events is SDL.Raw.Event_Layouts.Joysticks.Hat_Event;

   subtype Buttons is SDL.Raw.Event_Layouts.Joysticks.Button_Index;

   subtype Button_Events is SDL.Raw.Event_Layouts.Joysticks.Button_Event;

   function Get_State (Event : in Button_Events) return SDL.Events.Button_State is
     (if Boolean (Event.Down) then SDL.Events.Pressed else SDL.Events.Released);

   subtype Device_Events is SDL.Raw.Event_Layouts.Joysticks.Device_Event;

   subtype Battery_Percentages is SDL.Raw.Event_Layouts.Joysticks.Battery_Percentage;

   subtype Battery_Events is SDL.Raw.Event_Layouts.Joysticks.Battery_Event;

   procedure Update;

   function Is_Polling_Enabled return Boolean;

   procedure Enable_Polling;

   procedure Disable_Polling;
end SDL.Events.Joysticks;
