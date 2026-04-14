with Interfaces;
with Interfaces.C.Extensions;
with System;

with SDL.Events.Files;
with SDL.Events.Cameras;
with SDL.Events.Controllers;
with SDL.Events.Keyboards;
with SDL.Events.Mice;
with SDL.Events.Pens;
with SDL.Events.Joysticks;
with SDL.Events.Sensors;
with SDL.Events.Touches;
with SDL.Events.Windows;
with SDL.Video.Windows;

package SDL.Events.Events is
   --  Supported compatibility layer for the raw union-shaped event storage.
   --  This package remains available for source stability and for callers that
   --  need direct union-field access, but it is no longer the preferred public
   --  surface.
   --
   --  New code should use SDL.Events.Queue, which keeps the same queue
   --  operations while providing cleaner names plus helper-based event
   --  classification and typed accessors. New ergonomic additions should land
   --  in SDL.Events.Queue; this package should stay close to the underlying
   --  storage shape.

   package CE renames Interfaces.C.Extensions;

   type Event_Actions is (Add, Peek, Get) with
     Convention => C;

   for Event_Actions use
     (Add  => 0,
      Peek => 1,
      Get  => 2);

   type Event_Selector is
     (Is_Event,
      Is_Window_Event,
      Is_Keyboard_Device_Event,
      Is_Keyboard_Event,
      Is_Text_Editing_Event,
      Is_Text_Input_Event,
      Is_Mouse_Device_Event,
      Is_Mouse_Motion_Event,
      Is_Mouse_Button_Event,
      Is_Mouse_Wheel_Event,
      Is_Joystick_Axis_Event,
      Is_Joystick_Ball_Event,
      Is_Joystick_Hat_Event,
      Is_Joystick_Button_Event,
      Is_Joystick_Device_Event,
      Is_Joystick_Battery_Event,
      Is_Controller_Axis_Event,
      Is_Controller_Button_Event,
      Is_Controller_Device_Event,
      Is_Controller_Touchpad_Event,
      Is_Controller_Sensor_Event,
      Is_Sensor_Event,
      Is_Pen_Proximity_Event,
      Is_Pen_Touch_Event,
      Is_Pen_Motion_Event,
      Is_Pen_Button_Event,
      Is_Pen_Axis_Event,
      Is_Camera_Device_Event,
      Is_Touch_Finger_Event,
      Is_Drop_Event,
      Is_User_Event,
      Is_Padding_Event);

   type Event_Padding is array (1 .. 128) of Interfaces.Unsigned_8 with
     Convention     => C,
     Component_Size => 8;

   type Events (Kind : Event_Selector := Is_Event) is record
      case Kind is
         when Is_Window_Event =>
            Window       : SDL.Events.Windows.Window_Events;

         when Is_Keyboard_Device_Event =>
            Keyboard_Device : SDL.Events.Keyboards.Device_Events;

         when Is_Keyboard_Event =>
            Keyboard     : SDL.Events.Keyboards.Keyboard_Events;

         when Is_Text_Editing_Event =>
            Text_Editing : SDL.Events.Keyboards.Text_Editing_Events;

         when Is_Text_Input_Event =>
            Text_Input   : SDL.Events.Keyboards.Text_Input_Events;

         when Is_Mouse_Device_Event =>
            Mouse_Device : SDL.Events.Mice.Device_Events;

         when Is_Mouse_Motion_Event =>
            Mouse_Motion : SDL.Events.Mice.Motion_Events;

         when Is_Mouse_Button_Event =>
            Mouse_Button : SDL.Events.Mice.Button_Events;

         when Is_Mouse_Wheel_Event =>
            Mouse_Wheel  : SDL.Events.Mice.Wheel_Events;

         when Is_Joystick_Axis_Event =>
            Joystick_Axis : SDL.Events.Joysticks.Axis_Events;

         when Is_Joystick_Ball_Event =>
            Joystick_Ball : SDL.Events.Joysticks.Ball_Events;

         when Is_Joystick_Hat_Event =>
            Joystick_Hat : SDL.Events.Joysticks.Hat_Events;

         when Is_Joystick_Button_Event =>
            Joystick_Button : SDL.Events.Joysticks.Button_Events;

         when Is_Joystick_Device_Event =>
            Joystick_Device : SDL.Events.Joysticks.Device_Events;

         when Is_Joystick_Battery_Event =>
            Joystick_Battery : SDL.Events.Joysticks.Battery_Events;

         when Is_Controller_Axis_Event =>
            Controller_Axis : SDL.Events.Controllers.Axis_Events;

         when Is_Controller_Button_Event =>
            Controller_Button : SDL.Events.Controllers.Button_Events;

         when Is_Controller_Device_Event =>
            Controller_Device : SDL.Events.Controllers.Device_Events;

         when Is_Controller_Touchpad_Event =>
            Controller_Touchpad : SDL.Events.Controllers.Touchpad_Events;

         when Is_Controller_Sensor_Event =>
            Controller_Sensor : SDL.Events.Controllers.Sensor_Events;

         when Is_Sensor_Event =>
            Sensor : SDL.Events.Sensors.Update_Events;

         when Is_Pen_Proximity_Event =>
            Pen_Proximity : SDL.Events.Pens.Proximity_Events;

         when Is_Pen_Touch_Event =>
            Pen_Touch : SDL.Events.Pens.Touch_Events;

         when Is_Pen_Motion_Event =>
            Pen_Motion : SDL.Events.Pens.Motion_Events;

         when Is_Pen_Button_Event =>
            Pen_Button : SDL.Events.Pens.Button_Events;

         when Is_Pen_Axis_Event =>
            Pen_Axis : SDL.Events.Pens.Axis_Events;

         when Is_Camera_Device_Event =>
            Camera_Device : SDL.Events.Cameras.Device_Events;

         when Is_Touch_Finger_Event =>
            Touch_Finger : SDL.Events.Touches.Finger_Events;

         when Is_Drop_Event =>
            Drop         : SDL.Events.Files.Drop_Events;

         when Is_User_Event =>
            User         : SDL.Events.User_Events;

         when Is_Padding_Event =>
            Padding      : Event_Padding;

         when others =>
            Common       : SDL.Events.Common_Events;
      end case;
   end record with
     Unchecked_Union,
     Convention => C;

   pragma Obsolescent
     (Entity  => Events,
      Message => "Use SDL.Events.Queue.Event instead.");

   for Events'Size use 128 * System.Storage_Unit;

   type Event_Filter is access function
     (User_Data : in System.Address;
      Event     : access Events) return CE.bool
   with Convention => C;

   type Event_Arrays is array (Positive range <>) of aliased Events with
     Convention => C;

   Event_Error : exception;

   function Poll (Event : out Events) return Boolean with
     Inline;

   procedure Wait (Event : out Events);

   function Wait
     (Event      : out Events;
      Timeout_MS : in Interfaces.Integer_32) return Boolean with
     Inline;

   procedure Pump with
     Inline;

   function Peep
     (Items    : in out Event_Arrays;
      Action   : in Event_Actions;
      Min_Type : in SDL.Events.Event_Types := SDL.Events.First_Event;
      Max_Type : in SDL.Events.Event_Types := SDL.Events.Last_Event)
      return Natural;

   function Count
     (Min_Type : in SDL.Events.Event_Types := SDL.Events.First_Event;
      Max_Type : in SDL.Events.Event_Types := SDL.Events.Last_Event)
      return Natural;

   function Has
     (Event_Type : in SDL.Events.Event_Types) return Boolean with
     Inline;

   function Has
     (Min_Type : in SDL.Events.Event_Types;
      Max_Type : in SDL.Events.Event_Types) return Boolean with
     Inline;

   procedure Flush (Event_Type : in SDL.Events.Event_Types) with
     Inline;

   procedure Flush
     (Min_Type : in SDL.Events.Event_Types;
      Max_Type : in SDL.Events.Event_Types) with
     Inline;

   function Push (Event : in Events) return Boolean;

   procedure Set_Filter
     (Filter    : in Event_Filter;
      User_Data : in System.Address := System.Null_Address);

   function Get_Filter
     (Filter    : out Event_Filter;
      User_Data : out System.Address) return Boolean;

   function Add_Watch
     (Filter    : in Event_Filter;
      User_Data : in System.Address := System.Null_Address) return Boolean;

   procedure Remove_Watch
     (Filter    : in Event_Filter;
      User_Data : in System.Address := System.Null_Address);

   procedure Filter
     (Filter    : in Event_Filter;
      User_Data : in System.Address := System.Null_Address);

   procedure Set_Enabled
     (Event_Type : in SDL.Events.Event_Types;
      Enabled    : in Boolean);

   function Is_Enabled
     (Event_Type : in SDL.Events.Event_Types) return Boolean with
     Inline;

   function Register
     (Count : in Natural) return SDL.Events.Event_Types;

   function Get_Window_ID
     (Event : in Events) return SDL.Video.Windows.ID;

   function Get_Description (Event : in Events) return String;
end SDL.Events.Events;
