with SDL.Events.Cameras;
with SDL.Events.Controllers;
with SDL.Events.Files;
with SDL.Events.Joysticks;
with SDL.Events.Keyboards;
with SDL.Events.Mice;
with SDL.Events.Pens;
with SDL.Events.Sensors;
with SDL.Events.Touches;
with SDL.Events.Windows;

package body SDL.Events.Queue is
   use type SDL.Events.Event_Types;
   use type Event_Selector;

   function Kind_Of (Item : in Event) return Event_Selector is
      Event_Type : constant SDL.Events.Event_Types := Item.Common.Event_Type;
   begin
      if SDL.Events.Windows.Is_Window_Event (Event_Type) then
         return Is_Window_Event;
      elsif Event_Type = SDL.Events.Keyboards.Keyboard_Added
        or else Event_Type = SDL.Events.Keyboards.Keyboard_Removed
      then
         return Is_Keyboard_Device_Event;
      elsif Event_Type = SDL.Events.Keyboards.Key_Down
        or else Event_Type = SDL.Events.Keyboards.Key_Up
      then
         return Is_Keyboard_Event;
      elsif Event_Type = SDL.Events.Keyboards.Text_Editing then
         return Is_Text_Editing_Event;
      elsif Event_Type = SDL.Events.Keyboards.Text_Input then
         return Is_Text_Input_Event;
      elsif Event_Type = SDL.Events.Mice.Mouse_Added
        or else Event_Type = SDL.Events.Mice.Mouse_Removed
      then
         return Is_Mouse_Device_Event;
      elsif Event_Type = SDL.Events.Mice.Motion then
         return Is_Mouse_Motion_Event;
      elsif Event_Type = SDL.Events.Mice.Button_Down
        or else Event_Type = SDL.Events.Mice.Button_Up
      then
         return Is_Mouse_Button_Event;
      elsif Event_Type = SDL.Events.Mice.Wheel then
         return Is_Mouse_Wheel_Event;
      elsif Event_Type = SDL.Events.Joysticks.Axis_Motion then
         return Is_Joystick_Axis_Event;
      elsif Event_Type = SDL.Events.Joysticks.Ball_Motion then
         return Is_Joystick_Ball_Event;
      elsif Event_Type = SDL.Events.Joysticks.Hat_Motion then
         return Is_Joystick_Hat_Event;
      elsif Event_Type = SDL.Events.Joysticks.Button_Down
        or else Event_Type = SDL.Events.Joysticks.Button_Up
      then
         return Is_Joystick_Button_Event;
      elsif Event_Type = SDL.Events.Joysticks.Device_Added
        or else Event_Type = SDL.Events.Joysticks.Device_Removed
        or else Event_Type = SDL.Events.Joysticks.Update_Complete
      then
         return Is_Joystick_Device_Event;
      elsif Event_Type = SDL.Events.Joysticks.Battery_Updated then
         return Is_Joystick_Battery_Event;
      elsif Event_Type = SDL.Events.Controllers.Axis_Motion then
         return Is_Controller_Axis_Event;
      elsif Event_Type = SDL.Events.Controllers.Button_Down
        or else Event_Type = SDL.Events.Controllers.Button_Up
      then
         return Is_Controller_Button_Event;
      elsif Event_Type = SDL.Events.Controllers.Device_Added
        or else Event_Type = SDL.Events.Controllers.Device_Removed
        or else Event_Type = SDL.Events.Controllers.Device_Remapped
        or else Event_Type = SDL.Events.Controllers.Update_Complete
        or else Event_Type = SDL.Events.Controllers.Steam_Handle_Updated
      then
         return Is_Controller_Device_Event;
      elsif Event_Type = SDL.Events.Controllers.Touchpad_Down
        or else Event_Type = SDL.Events.Controllers.Touchpad_Motion
        or else Event_Type = SDL.Events.Controllers.Touchpad_Up
      then
         return Is_Controller_Touchpad_Event;
      elsif Event_Type = SDL.Events.Controllers.Sensor_Update then
         return Is_Controller_Sensor_Event;
      elsif Event_Type = SDL.Events.Sensors.Update then
         return Is_Sensor_Event;
      elsif Event_Type = SDL.Events.Pens.Proximity_In
        or else Event_Type = SDL.Events.Pens.Proximity_Out
      then
         return Is_Pen_Proximity_Event;
      elsif Event_Type = SDL.Events.Pens.Touch_Down
        or else Event_Type = SDL.Events.Pens.Touch_Up
      then
         return Is_Pen_Touch_Event;
      elsif Event_Type = SDL.Events.Pens.Motion then
         return Is_Pen_Motion_Event;
      elsif Event_Type = SDL.Events.Pens.Button_Down
        or else Event_Type = SDL.Events.Pens.Button_Up
      then
         return Is_Pen_Button_Event;
      elsif Event_Type = SDL.Events.Pens.Axis then
         return Is_Pen_Axis_Event;
      elsif Event_Type = SDL.Events.Cameras.Device_Added
        or else Event_Type = SDL.Events.Cameras.Device_Removed
        or else Event_Type = SDL.Events.Cameras.Device_Approved
        or else Event_Type = SDL.Events.Cameras.Device_Denied
      then
         return Is_Camera_Device_Event;
      elsif Event_Type = SDL.Events.Touches.Finger_Down
        or else Event_Type = SDL.Events.Touches.Finger_Up
        or else Event_Type = SDL.Events.Touches.Finger_Motion
        or else Event_Type = SDL.Events.Touches.Finger_Canceled
      then
         return Is_Touch_Finger_Event;
      elsif Event_Type = SDL.Events.Files.Drop_File
        or else Event_Type = SDL.Events.Files.Drop_Text
        or else Event_Type = SDL.Events.Files.Drop_Begin
        or else Event_Type = SDL.Events.Files.Drop_Complete
        or else Event_Type = SDL.Events.Files.Drop_Position
      then
         return Is_Drop_Event;
      elsif Event_Type in SDL.Events.User .. SDL.Events.Last_Event then
         return Is_User_Event;
      else
         --  Event families without dedicated Ada payload records yet stay
         --  classified as common-only events.
         return Is_Event;
      end if;
   end Kind_Of;

   function Is_Window (Item : in Event) return Boolean is
     (Kind_Of (Item) = Is_Window_Event);

   function Is_Keyboard_Device (Item : in Event) return Boolean is
     (Kind_Of (Item) = Is_Keyboard_Device_Event);

   function Is_Keyboard (Item : in Event) return Boolean is
     (Kind_Of (Item) = Is_Keyboard_Event);

   function Is_Text_Editing (Item : in Event) return Boolean is
     (Kind_Of (Item) = Is_Text_Editing_Event);

   function Is_Text_Input (Item : in Event) return Boolean is
     (Kind_Of (Item) = Is_Text_Input_Event);

   function Is_Mouse_Device (Item : in Event) return Boolean is
     (Kind_Of (Item) = Is_Mouse_Device_Event);

   function Is_Mouse_Motion (Item : in Event) return Boolean is
     (Kind_Of (Item) = Is_Mouse_Motion_Event);

   function Is_Mouse_Button (Item : in Event) return Boolean is
     (Kind_Of (Item) = Is_Mouse_Button_Event);

   function Is_Mouse_Wheel (Item : in Event) return Boolean is
     (Kind_Of (Item) = Is_Mouse_Wheel_Event);

   function Is_Joystick_Axis (Item : in Event) return Boolean is
     (Kind_Of (Item) = Is_Joystick_Axis_Event);

   function Is_Joystick_Ball (Item : in Event) return Boolean is
     (Kind_Of (Item) = Is_Joystick_Ball_Event);

   function Is_Joystick_Hat (Item : in Event) return Boolean is
     (Kind_Of (Item) = Is_Joystick_Hat_Event);

   function Is_Joystick_Button (Item : in Event) return Boolean is
     (Kind_Of (Item) = Is_Joystick_Button_Event);

   function Is_Joystick_Device (Item : in Event) return Boolean is
     (Kind_Of (Item) = Is_Joystick_Device_Event);

   function Is_Joystick_Battery (Item : in Event) return Boolean is
     (Kind_Of (Item) = Is_Joystick_Battery_Event);

   function Is_Controller_Axis (Item : in Event) return Boolean is
     (Kind_Of (Item) = Is_Controller_Axis_Event);

   function Is_Controller_Button (Item : in Event) return Boolean is
     (Kind_Of (Item) = Is_Controller_Button_Event);

   function Is_Controller_Device (Item : in Event) return Boolean is
     (Kind_Of (Item) = Is_Controller_Device_Event);

   function Is_Controller_Touchpad (Item : in Event) return Boolean is
     (Kind_Of (Item) = Is_Controller_Touchpad_Event);

   function Is_Controller_Sensor (Item : in Event) return Boolean is
     (Kind_Of (Item) = Is_Controller_Sensor_Event);

   function Is_Sensor (Item : in Event) return Boolean is
     (Kind_Of (Item) = Is_Sensor_Event);

   function Is_Pen_Proximity (Item : in Event) return Boolean is
     (Kind_Of (Item) = Is_Pen_Proximity_Event);

   function Is_Pen_Touch (Item : in Event) return Boolean is
     (Kind_Of (Item) = Is_Pen_Touch_Event);

   function Is_Pen_Motion (Item : in Event) return Boolean is
     (Kind_Of (Item) = Is_Pen_Motion_Event);

   function Is_Pen_Button (Item : in Event) return Boolean is
     (Kind_Of (Item) = Is_Pen_Button_Event);

   function Is_Pen_Axis (Item : in Event) return Boolean is
     (Kind_Of (Item) = Is_Pen_Axis_Event);

   function Is_Camera_Device (Item : in Event) return Boolean is
     (Kind_Of (Item) = Is_Camera_Device_Event);

   function Is_Touch_Finger (Item : in Event) return Boolean is
     (Kind_Of (Item) = Is_Touch_Finger_Event);

   function Is_Drop (Item : in Event) return Boolean is
     (Kind_Of (Item) = Is_Drop_Event);

   function Is_User (Item : in Event) return Boolean is
     (Kind_Of (Item) = Is_User_Event);
end SDL.Events.Queue;
