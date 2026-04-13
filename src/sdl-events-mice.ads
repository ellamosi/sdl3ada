with Ada.Unchecked_Conversion;
with Interfaces;
with Interfaces.C;
with Interfaces.C.Extensions;

with SDL.Video.Windows;

package SDL.Events.Mice is
   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;

   use type Interfaces.C.C_float;

   Motion        : constant SDL.Events.Event_Types := 16#0000_0400#;
   Button_Down   : constant SDL.Events.Event_Types := 16#0000_0401#;
   Button_Up     : constant SDL.Events.Event_Types := 16#0000_0402#;
   Wheel         : constant SDL.Events.Event_Types := 16#0000_0403#;
   Mouse_Added   : constant SDL.Events.Event_Types := 16#0000_0404#;
   Mouse_Removed : constant SDL.Events.Event_Types := 16#0000_0405#;

   type IDs is range 0 .. 2 ** 32 - 1 with
     Convention => C,
     Size       => 32;

   Touch_Mouse_ID : constant IDs := IDs'Last;

   type Buttons is (Left,
                    Middle,
                    Right,
                    X_1,
                    X_2) with
     Convention => C,
     Size       => 8;

   for Buttons use (Left   => 1,
                    Middle => 2,
                    Right  => 3,
                    X_1    => 4,
                    X_2    => 5);

   type Button_Masks is mod 2 ** 32 with
     Convention => C,
     Size       => 32;

   function Convert is new Ada.Unchecked_Conversion
     (Source => Interfaces.Unsigned_32,
      Target => Button_Masks);

   function Left_Mask return Button_Masks is
     (Convert (Interfaces.Shift_Left (1, Buttons'Pos (Left)))) with
     Inline => True;

   function Middle_Mask return Button_Masks is
     (Convert (Interfaces.Shift_Left (1, Buttons'Pos (Middle)))) with
     Inline => True;

   function Right_Mask return Button_Masks is
     (Convert (Interfaces.Shift_Left (1, Buttons'Pos (Right)))) with
     Inline => True;

   function X_1_Mask return Button_Masks is
     (Convert (Interfaces.Shift_Left (1, Buttons'Pos (X_1)))) with
     Inline => True;

   function X_2_Mask return Button_Masks is
     (Convert (Interfaces.Shift_Left (1, Buttons'Pos (X_2)))) with
     Inline => True;

   subtype Coordinates is Interfaces.C.C_float;
   subtype Movement_Values is Coordinates;
   subtype Wheel_Values is Coordinates;

   type Motion_Events is record
      Event_Type : SDL.Events.Event_Types;
      Reserved   : Interfaces.Unsigned_32;
      Time_Stamp : SDL.Events.Time_Stamps;
      Window     : SDL.Video.Windows.ID;
      Which      : IDs;
      Mask       : Button_Masks;
      X          : Coordinates;
      Y          : Coordinates;
      X_Relative : Movement_Values;
      Y_Relative : Movement_Values;
   end record with
     Convention => C;

   type Device_Events is record
      Event_Type : SDL.Events.Event_Types;
      Reserved   : Interfaces.Unsigned_32;
      Time_Stamp : SDL.Events.Time_Stamps;
      Which      : IDs;
   end record with
     Convention => C;

   type Button_Clicks is range 0 .. 255 with
     Convention => C,
     Size       => 8;

   type Button_Events is record
      Event_Type : SDL.Events.Event_Types;
      Reserved   : Interfaces.Unsigned_32;
      Time_Stamp : SDL.Events.Time_Stamps;
      Window     : SDL.Video.Windows.ID;
      Which      : IDs;
      Button     : Buttons;
      Down       : CE.bool;
      Clicks     : Button_Clicks;
      Padding    : Interfaces.Unsigned_8;
      X          : Coordinates;
      Y          : Coordinates;
   end record with
     Convention => C;

   function Get_State
     (Event : in Button_Events) return SDL.Events.Button_State is
       (if Boolean (Event.Down) then SDL.Events.Pressed else SDL.Events.Released);

   type Wheel_Directions is (Normal, Flipped) with
     Convention => C;

   function Flip_Wheel_Value (Value : in Wheel_Values) return Wheel_Values is
     (-Value);

   type Wheel_Events is record
      Event_Type : SDL.Events.Event_Types;
      Reserved   : Interfaces.Unsigned_32;
      Time_Stamp : SDL.Events.Time_Stamps;
      Window     : SDL.Video.Windows.ID;
      Which      : IDs;
      X          : Wheel_Values;
      Y          : Wheel_Values;
      Direction  : Wheel_Directions;
      Mouse_X    : Coordinates;
      Mouse_Y    : Coordinates;
      Integer_X  : Interfaces.Integer_32;
      Integer_Y  : Interfaces.Integer_32;
   end record with
     Convention => C;
end SDL.Events.Mice;
