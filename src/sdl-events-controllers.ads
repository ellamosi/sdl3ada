with Interfaces;
with Interfaces.C;
with Interfaces.C.Extensions;

with SDL.Events.Joysticks;

package SDL.Events.Controllers is
   pragma Pure;

   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;

   use type Event_Types;

   Axis_Motion          : constant Event_Types := 16#0000_0650#;
   Button_Down          : constant Event_Types := Axis_Motion + Event_Types (1);
   Button_Up            : constant Event_Types := Axis_Motion + Event_Types (2);
   Device_Added         : constant Event_Types := Axis_Motion + Event_Types (3);
   Device_Removed       : constant Event_Types := Axis_Motion + Event_Types (4);
   Device_Remapped      : constant Event_Types := Axis_Motion + Event_Types (5);
   Touchpad_Down        : constant Event_Types := Axis_Motion + Event_Types (6);
   Touchpad_Motion      : constant Event_Types := Axis_Motion + Event_Types (7);
   Touchpad_Up          : constant Event_Types := Axis_Motion + Event_Types (8);
   Sensor_Update        : constant Event_Types := Axis_Motion + Event_Types (9);
   Update_Complete      : constant Event_Types := Axis_Motion + Event_Types (10);
   Steam_Handle_Updated : constant Event_Types := Axis_Motion + Event_Types (11);

   type Axes is
     (Invalid,
      Left_X,
      Left_Y,
      Right_X,
      Right_Y,
      Left_Trigger,
      Right_Trigger) with
     Convention => C,
     Size       => 8;

   for Axes use
     (Invalid       => -1,
      Left_X        => 0,
      Left_Y        => 1,
      Right_X       => 2,
      Right_Y       => 3,
      Left_Trigger  => 4,
      Right_Trigger => 5);

   type Axes_Values is range -32_768 .. 32_767 with
     Convention => C,
     Size       => 16;

   type Axis_Events is record
      Event_Type : Event_Types;
      Reserved   : Interfaces.Unsigned_32;
      Time_Stamp : Time_Stamps;
      Which      : SDL.Events.Joysticks.IDs;
      Axis       : Axes;
      Padding_1  : Padding_8;
      Padding_2  : Padding_8;
      Padding_3  : Padding_8;
      Value      : Axes_Values;
      Padding_4  : Padding_16;
   end record with
     Convention => C;

   type Buttons is
     (Invalid,
      A,
      B,
      X,
      Y,
      Back,
      Guide,
      Start,
      Left_Stick,
      Right_Stick,
      Left_Shoulder,
      Right_Shoulder,
      Pad_Up,
      Pad_Down,
      Pad_Left,
      Pad_Right,
      Misc_1,
      Right_Paddle_1,
      Left_Paddle_1,
      Right_Paddle_2,
      Left_Paddle_2,
      Touchpad,
      Misc_2,
      Misc_3,
      Misc_4,
      Misc_5,
      Misc_6) with
     Convention => C,
     Size       => 8;

   for Buttons use
     (Invalid          => -1,
      A                => 0,
      B                => 1,
      X                => 2,
      Y                => 3,
      Back             => 4,
      Guide            => 5,
      Start            => 6,
      Left_Stick       => 7,
      Right_Stick      => 8,
      Left_Shoulder    => 9,
      Right_Shoulder   => 10,
      Pad_Up           => 11,
      Pad_Down         => 12,
      Pad_Left         => 13,
      Pad_Right        => 14,
      Misc_1           => 15,
      Right_Paddle_1   => 16,
      Left_Paddle_1    => 17,
      Right_Paddle_2   => 18,
      Left_Paddle_2    => 19,
      Touchpad         => 20,
      Misc_2           => 21,
      Misc_3           => 22,
      Misc_4           => 23,
      Misc_5           => 24,
      Misc_6           => 25);

   type Button_Events is record
      Event_Type : Event_Types;
      Reserved   : Interfaces.Unsigned_32;
      Time_Stamp : Time_Stamps;
      Which      : SDL.Events.Joysticks.IDs;
      Button     : Buttons;
      Down       : CE.bool;
      Padding_1  : Padding_8;
      Padding_2  : Padding_8;
   end record with
     Convention => C;

   function Get_State (Event : in Button_Events) return SDL.Events.Button_State is
     (if Boolean (Event.Down) then SDL.Events.Pressed else SDL.Events.Released);

   type Device_Events is record
      Event_Type : Event_Types;
      Reserved   : Interfaces.Unsigned_32;
      Time_Stamp : Time_Stamps;
      Which      : SDL.Events.Joysticks.IDs;
   end record with
     Convention => C;

   subtype Touchpad_Indices is Interfaces.Integer_32;
   subtype Finger_Indices is Interfaces.Integer_32;
   subtype Coordinates is C.C_float;
   subtype Pressure_Values is C.C_float;

   type Touchpad_Events is record
      Event_Type : Event_Types;
      Reserved   : Interfaces.Unsigned_32;
      Time_Stamp : Time_Stamps;
      Which      : SDL.Events.Joysticks.IDs;
      Touchpad   : Touchpad_Indices;
      Finger     : Finger_Indices;
      X          : Coordinates;
      Y          : Coordinates;
      Pressure   : Pressure_Values;
   end record with
     Convention => C;

   subtype Sensor_Types is Interfaces.Integer_32;

   type Sensor_Data is array (0 .. 2) of aliased C.C_float with
     Convention     => C,
     Component_Size => C.C_float'Size;

   type Sensor_Events is record
      Event_Type       : Event_Types;
      Reserved         : Interfaces.Unsigned_32;
      Time_Stamp       : Time_Stamps;
      Which            : SDL.Events.Joysticks.IDs;
      Sensor           : Sensor_Types;
      Data             : Sensor_Data;
      Sensor_Time_Stamp : Time_Stamps;
   end record with
     Convention => C;
end SDL.Events.Controllers;
