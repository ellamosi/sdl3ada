with Interfaces;
with Interfaces.C;
with Interfaces.C.Extensions;

with SDL.Raw.Event_Types;

package SDL.Raw.Event_Layouts.Mice is
   pragma Pure;

   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;

   use type SDL.Raw.Event_Types.Event_Type;

   Motion        : constant SDL.Raw.Event_Types.Event_Type := 16#0000_0400#;
   Button_Down   : constant SDL.Raw.Event_Types.Event_Type :=
     Motion + SDL.Raw.Event_Types.Event_Type (1);
   Button_Up     : constant SDL.Raw.Event_Types.Event_Type :=
     Motion + SDL.Raw.Event_Types.Event_Type (2);
   Wheel         : constant SDL.Raw.Event_Types.Event_Type :=
     Motion + SDL.Raw.Event_Types.Event_Type (3);
   Mouse_Added   : constant SDL.Raw.Event_Types.Event_Type :=
     Motion + SDL.Raw.Event_Types.Event_Type (4);
   Mouse_Removed : constant SDL.Raw.Event_Types.Event_Type :=
     Motion + SDL.Raw.Event_Types.Event_Type (5);

   type ID is range 0 .. 2 ** 32 - 1 with
     Convention => C,
     Size       => 32;

   Touch_Mouse_ID : constant ID := ID'Last;

   type Button is
     (Left,
      Middle,
      Right,
      X_1,
      X_2)
   with
     Convention => C,
     Size       => 8;

   for Button use
     (Left   => 1,
      Middle => 2,
      Right  => 3,
      X_1    => 4,
      X_2    => 5);

   type Button_Mask is mod 2 ** 32 with
     Convention => C,
     Size       => 32;

   subtype Coordinate is C.C_float;
   subtype Movement_Value is Coordinate;
   subtype Wheel_Value is Coordinate;

   type Window_ID is mod 2 ** 32 with
     Convention => C,
     Size       => 32;

   type Motion_Event is record
      Event_Type : SDL.Raw.Event_Types.Event_Type;
      Reserved   : Interfaces.Unsigned_32;
      Time_Stamp : Interfaces.Unsigned_64;
      Window     : Window_ID;
      Which      : ID;
      Mask       : Button_Mask;
      X          : Coordinate;
      Y          : Coordinate;
      X_Relative : Movement_Value;
      Y_Relative : Movement_Value;
   end record with
     Convention => C;

   type Device_Event is record
      Event_Type : SDL.Raw.Event_Types.Event_Type;
      Reserved   : Interfaces.Unsigned_32;
      Time_Stamp : Interfaces.Unsigned_64;
      Which      : ID;
   end record with
     Convention => C;

   type Button_Click is range 0 .. 255 with
     Convention => C,
     Size       => 8;

   type Button_Event is record
      Event_Type : SDL.Raw.Event_Types.Event_Type;
      Reserved   : Interfaces.Unsigned_32;
      Time_Stamp : Interfaces.Unsigned_64;
      Window     : Window_ID;
      Which      : ID;
      Button     : SDL.Raw.Event_Layouts.Mice.Button;
      Down       : CE.bool;
      Clicks     : Button_Click;
      Padding    : Interfaces.Unsigned_8;
      X          : Coordinate;
      Y          : Coordinate;
   end record with
     Convention => C;

   type Wheel_Direction is (Normal, Flipped) with
     Convention => C;

   type Wheel_Event is record
      Event_Type : SDL.Raw.Event_Types.Event_Type;
      Reserved   : Interfaces.Unsigned_32;
      Time_Stamp : Interfaces.Unsigned_64;
      Window     : Window_ID;
      Which      : ID;
      X          : Wheel_Value;
      Y          : Wheel_Value;
      Direction  : Wheel_Direction;
      Mouse_X    : Coordinate;
      Mouse_Y    : Coordinate;
      Integer_X  : Interfaces.Integer_32;
      Integer_Y  : Interfaces.Integer_32;
   end record with
     Convention => C;
end SDL.Raw.Event_Layouts.Mice;
