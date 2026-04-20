with Interfaces;
with System;

with SDL.Events.Cameras;
with SDL.Events.Controllers;
with SDL.Events.Events;
with SDL.Events.Files;
with SDL.Events.Joysticks;
with SDL.Events.Keyboards;
with SDL.Events.Mice;
with SDL.Events.Pens;
with SDL.Events.Sensors;
with SDL.Events.Touches;
with SDL.Events.Windows;
with SDL.Video.Windows;

package SDL.Events.Queue is
   --  Preferred facade for SDL's event queue. This keeps the union-shaped
   --  storage available while avoiding the repetitive SDL.Events.Events names.

   subtype Event_Actions is SDL.Events.Events.Event_Actions;

   Add  : constant Event_Actions := SDL.Events.Events.Add;
   Peek : constant Event_Actions := SDL.Events.Events.Peek;
   Get  : constant Event_Actions := SDL.Events.Events.Get;

   subtype Event_Selector is SDL.Events.Events.Event_Selector;

   Is_Event : constant Event_Selector := SDL.Events.Events.Is_Event;
   Is_Window_Event : constant Event_Selector :=
     SDL.Events.Events.Is_Window_Event;
   Is_Keyboard_Device_Event : constant Event_Selector :=
     SDL.Events.Events.Is_Keyboard_Device_Event;
   Is_Keyboard_Event : constant Event_Selector :=
     SDL.Events.Events.Is_Keyboard_Event;
   Is_Text_Editing_Event : constant Event_Selector :=
     SDL.Events.Events.Is_Text_Editing_Event;
   Is_Text_Input_Event : constant Event_Selector :=
     SDL.Events.Events.Is_Text_Input_Event;
   Is_Mouse_Device_Event : constant Event_Selector :=
     SDL.Events.Events.Is_Mouse_Device_Event;
   Is_Mouse_Motion_Event : constant Event_Selector :=
     SDL.Events.Events.Is_Mouse_Motion_Event;
   Is_Mouse_Button_Event : constant Event_Selector :=
     SDL.Events.Events.Is_Mouse_Button_Event;
   Is_Mouse_Wheel_Event : constant Event_Selector :=
     SDL.Events.Events.Is_Mouse_Wheel_Event;
   Is_Joystick_Axis_Event : constant Event_Selector :=
     SDL.Events.Events.Is_Joystick_Axis_Event;
   Is_Joystick_Ball_Event : constant Event_Selector :=
     SDL.Events.Events.Is_Joystick_Ball_Event;
   Is_Joystick_Hat_Event : constant Event_Selector :=
     SDL.Events.Events.Is_Joystick_Hat_Event;
   Is_Joystick_Button_Event : constant Event_Selector :=
     SDL.Events.Events.Is_Joystick_Button_Event;
   Is_Joystick_Device_Event : constant Event_Selector :=
     SDL.Events.Events.Is_Joystick_Device_Event;
   Is_Joystick_Battery_Event : constant Event_Selector :=
     SDL.Events.Events.Is_Joystick_Battery_Event;
   Is_Controller_Axis_Event : constant Event_Selector :=
     SDL.Events.Events.Is_Controller_Axis_Event;
   Is_Controller_Button_Event : constant Event_Selector :=
     SDL.Events.Events.Is_Controller_Button_Event;
   Is_Controller_Device_Event : constant Event_Selector :=
     SDL.Events.Events.Is_Controller_Device_Event;
   Is_Controller_Touchpad_Event : constant Event_Selector :=
     SDL.Events.Events.Is_Controller_Touchpad_Event;
   Is_Controller_Sensor_Event : constant Event_Selector :=
     SDL.Events.Events.Is_Controller_Sensor_Event;
   Is_Sensor_Event : constant Event_Selector :=
     SDL.Events.Events.Is_Sensor_Event;
   Is_Pen_Proximity_Event : constant Event_Selector :=
     SDL.Events.Events.Is_Pen_Proximity_Event;
   Is_Pen_Touch_Event : constant Event_Selector :=
     SDL.Events.Events.Is_Pen_Touch_Event;
   Is_Pen_Motion_Event : constant Event_Selector :=
     SDL.Events.Events.Is_Pen_Motion_Event;
   Is_Pen_Button_Event : constant Event_Selector :=
     SDL.Events.Events.Is_Pen_Button_Event;
   Is_Pen_Axis_Event : constant Event_Selector :=
     SDL.Events.Events.Is_Pen_Axis_Event;
   Is_Camera_Device_Event : constant Event_Selector :=
     SDL.Events.Events.Is_Camera_Device_Event;
   Is_Touch_Finger_Event : constant Event_Selector :=
     SDL.Events.Events.Is_Touch_Finger_Event;
   Is_Drop_Event : constant Event_Selector :=
     SDL.Events.Events.Is_Drop_Event;
   Is_User_Event : constant Event_Selector :=
     SDL.Events.Events.Is_User_Event;
   Is_Padding_Event : constant Event_Selector :=
     SDL.Events.Events.Is_Padding_Event;

   subtype Event_Padding is SDL.Events.Events.Event_Padding;
   pragma Warnings (Off);
   subtype Event is SDL.Events.Events.Events;
   pragma Warnings (On);
   subtype Event_Filter is SDL.Events.Events.Event_Filter;
   subtype Event_Arrays is SDL.Events.Events.Event_Arrays;

   Event_Error : exception renames SDL.Events.Events.Event_Error;

   --  Classify the active union branch from Event.Common.Event_Type instead of
   --  relying on the unchecked-union discriminant.
   function Kind_Of (Item : in Event) return Event_Selector;

   function Is_Window (Item : in Event) return Boolean;
   function Is_Keyboard_Device (Item : in Event) return Boolean;
   function Is_Keyboard (Item : in Event) return Boolean;
   function Is_Text_Editing (Item : in Event) return Boolean;
   function Is_Text_Input (Item : in Event) return Boolean;
   function Is_Mouse_Device (Item : in Event) return Boolean;
   function Is_Mouse_Motion (Item : in Event) return Boolean;
   function Is_Mouse_Button (Item : in Event) return Boolean;
   function Is_Mouse_Wheel (Item : in Event) return Boolean;
   function Is_Joystick_Axis (Item : in Event) return Boolean;
   function Is_Joystick_Ball (Item : in Event) return Boolean;
   function Is_Joystick_Hat (Item : in Event) return Boolean;
   function Is_Joystick_Button (Item : in Event) return Boolean;
   function Is_Joystick_Device (Item : in Event) return Boolean;
   function Is_Joystick_Battery (Item : in Event) return Boolean;
   function Is_Controller_Axis (Item : in Event) return Boolean;
   function Is_Controller_Button (Item : in Event) return Boolean;
   function Is_Controller_Device (Item : in Event) return Boolean;
   function Is_Controller_Touchpad (Item : in Event) return Boolean;
   function Is_Controller_Sensor (Item : in Event) return Boolean;
   function Is_Sensor (Item : in Event) return Boolean;
   function Is_Pen_Proximity (Item : in Event) return Boolean;
   function Is_Pen_Touch (Item : in Event) return Boolean;
   function Is_Pen_Motion (Item : in Event) return Boolean;
   function Is_Pen_Button (Item : in Event) return Boolean;
   function Is_Pen_Axis (Item : in Event) return Boolean;
   function Is_Camera_Device (Item : in Event) return Boolean;
   function Is_Touch_Finger (Item : in Event) return Boolean;
   function Is_Drop (Item : in Event) return Boolean;
   function Is_User (Item : in Event) return Boolean;

   function As_Window
     (Item : in Event) return SDL.Events.Windows.Window_Events
   with Pre => Is_Window (Item);

   function As_Keyboard_Device
     (Item : in Event) return SDL.Events.Keyboards.Device_Events
   with Pre => Is_Keyboard_Device (Item);

   function As_Keyboard
     (Item : in Event) return SDL.Events.Keyboards.Keyboard_Events
   with Pre => Is_Keyboard (Item);

   function As_Text_Editing
     (Item : in Event) return SDL.Events.Keyboards.Text_Editing_Events
   with Pre => Is_Text_Editing (Item);

   function As_Text_Input
     (Item : in Event) return SDL.Events.Keyboards.Text_Input_Events
   with Pre => Is_Text_Input (Item);

   function As_Mouse_Device
     (Item : in Event) return SDL.Events.Mice.Device_Events
   with Pre => Is_Mouse_Device (Item);

   function As_Mouse_Motion
     (Item : in Event) return SDL.Events.Mice.Motion_Events
   with Pre => Is_Mouse_Motion (Item);

   function As_Mouse_Button
     (Item : in Event) return SDL.Events.Mice.Button_Events
   with Pre => Is_Mouse_Button (Item);

   function As_Mouse_Wheel
     (Item : in Event) return SDL.Events.Mice.Wheel_Events
   with Pre => Is_Mouse_Wheel (Item);

   function As_Joystick_Axis
     (Item : in Event) return SDL.Events.Joysticks.Axis_Events
   with Pre => Is_Joystick_Axis (Item);

   function As_Joystick_Ball
     (Item : in Event) return SDL.Events.Joysticks.Ball_Events
   with Pre => Is_Joystick_Ball (Item);

   function As_Joystick_Hat
     (Item : in Event) return SDL.Events.Joysticks.Hat_Events
   with Pre => Is_Joystick_Hat (Item);

   function As_Joystick_Button
     (Item : in Event) return SDL.Events.Joysticks.Button_Events
   with Pre => Is_Joystick_Button (Item);

   function As_Joystick_Device
     (Item : in Event) return SDL.Events.Joysticks.Device_Events
   with Pre => Is_Joystick_Device (Item);

   function As_Joystick_Battery
     (Item : in Event) return SDL.Events.Joysticks.Battery_Events
   with Pre => Is_Joystick_Battery (Item);

   function As_Controller_Axis
     (Item : in Event) return SDL.Events.Controllers.Axis_Events
   with Pre => Is_Controller_Axis (Item);

   function As_Controller_Button
     (Item : in Event) return SDL.Events.Controllers.Button_Events
   with Pre => Is_Controller_Button (Item);

   function As_Controller_Device
     (Item : in Event) return SDL.Events.Controllers.Device_Events
   with Pre => Is_Controller_Device (Item);

   function As_Controller_Touchpad
     (Item : in Event) return SDL.Events.Controllers.Touchpad_Events
   with Pre => Is_Controller_Touchpad (Item);

   function As_Controller_Sensor
     (Item : in Event) return SDL.Events.Controllers.Sensor_Events
   with Pre => Is_Controller_Sensor (Item);

   function As_Sensor
     (Item : in Event) return SDL.Events.Sensors.Update_Events
   with Pre => Is_Sensor (Item);

   function As_Pen_Proximity
     (Item : in Event) return SDL.Events.Pens.Proximity_Events
   with Pre => Is_Pen_Proximity (Item);

   function As_Pen_Touch
     (Item : in Event) return SDL.Events.Pens.Touch_Events
   with Pre => Is_Pen_Touch (Item);

   function As_Pen_Motion
     (Item : in Event) return SDL.Events.Pens.Motion_Events
   with Pre => Is_Pen_Motion (Item);

   function As_Pen_Button
     (Item : in Event) return SDL.Events.Pens.Button_Events
   with Pre => Is_Pen_Button (Item);

   function As_Pen_Axis
     (Item : in Event) return SDL.Events.Pens.Axis_Events
   with Pre => Is_Pen_Axis (Item);

   function As_Camera_Device
     (Item : in Event) return SDL.Events.Cameras.Device_Events
   with Pre => Is_Camera_Device (Item);

   function As_Touch_Finger
     (Item : in Event) return SDL.Events.Touches.Finger_Events
   with Pre => Is_Touch_Finger (Item);

   function As_Drop
     (Item : in Event) return SDL.Events.Files.Drop_Events
   with Pre => Is_Drop (Item);

   function As_User
     (Item : in Event) return SDL.Events.User_Events
   with Pre => Is_User (Item);

   function Poll (Item : out Event) return Boolean
     renames SDL.Events.Events.Poll;

   procedure Wait (Item : out Event)
     renames SDL.Events.Events.Wait;

   function Wait
     (Item       : out Event;
      Timeout_MS : in Interfaces.Integer_32) return Boolean
     renames SDL.Events.Events.Wait;

   procedure Pump
     renames SDL.Events.Events.Pump;

   function Peep
     (Items    : in out Event_Arrays;
      Action   : in Event_Actions;
      Min_Type : in SDL.Events.Event_Types := SDL.Events.First_Event;
      Max_Type : in SDL.Events.Event_Types := SDL.Events.Last_Event)
      return Natural
     renames SDL.Events.Events.Peep;

   function Count
     (Min_Type : in SDL.Events.Event_Types := SDL.Events.First_Event;
      Max_Type : in SDL.Events.Event_Types := SDL.Events.Last_Event)
      return Natural
     renames SDL.Events.Events.Count;

   function Has
     (Event_Type : in SDL.Events.Event_Types) return Boolean
     renames SDL.Events.Events.Has;

   function Has
     (Min_Type : in SDL.Events.Event_Types;
      Max_Type : in SDL.Events.Event_Types) return Boolean
     renames SDL.Events.Events.Has;

   procedure Flush
     (Event_Type : in SDL.Events.Event_Types)
     renames SDL.Events.Events.Flush;

   procedure Flush
     (Min_Type : in SDL.Events.Event_Types;
      Max_Type : in SDL.Events.Event_Types)
     renames SDL.Events.Events.Flush;

   function Push
     (Item : in Event) return Boolean
     renames SDL.Events.Events.Push;

   procedure Set_Filter
     (Filter    : in Event_Filter;
      User_Data : in System.Address := System.Null_Address)
     renames SDL.Events.Events.Set_Filter;

   function Get_Filter
     (Filter    : out Event_Filter;
      User_Data : out System.Address) return Boolean
     renames SDL.Events.Events.Get_Filter;

   function Add_Watch
     (Filter    : in Event_Filter;
      User_Data : in System.Address := System.Null_Address) return Boolean
     renames SDL.Events.Events.Add_Watch;

   procedure Remove_Watch
     (Filter    : in Event_Filter;
      User_Data : in System.Address := System.Null_Address)
     renames SDL.Events.Events.Remove_Watch;

   procedure Filter
     (Filter    : in Event_Filter;
      User_Data : in System.Address := System.Null_Address)
     renames SDL.Events.Events.Filter;

   procedure Set_Enabled
     (Event_Type : in SDL.Events.Event_Types;
      Enabled    : in Boolean)
     renames SDL.Events.Events.Set_Enabled;

   function Is_Enabled
     (Event_Type : in SDL.Events.Event_Types) return Boolean
     renames SDL.Events.Events.Is_Enabled;

   function Register
     (Count : in Natural) return SDL.Events.Event_Types
     renames SDL.Events.Events.Register;

   function Get_Window_ID
     (Item : in Event) return SDL.Video.Windows.ID
     renames SDL.Events.Events.Get_Window_ID;

   function Get_Description
     (Item : in Event) return String
     renames SDL.Events.Events.Get_Description;
end SDL.Events.Queue;
