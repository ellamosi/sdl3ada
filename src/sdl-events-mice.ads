with Ada.Unchecked_Conversion;
with Interfaces;
with Interfaces.C;
with Interfaces.C.Extensions;

with SDL.Raw.Event_Layouts.Mice;

package SDL.Events.Mice is
   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;

   use type Interfaces.C.C_float;

   Motion        : constant SDL.Events.Event_Types :=
     SDL.Raw.Event_Layouts.Mice.Motion;
   Button_Down   : constant SDL.Events.Event_Types :=
     SDL.Raw.Event_Layouts.Mice.Button_Down;
   Button_Up     : constant SDL.Events.Event_Types :=
     SDL.Raw.Event_Layouts.Mice.Button_Up;
   Wheel         : constant SDL.Events.Event_Types :=
     SDL.Raw.Event_Layouts.Mice.Wheel;
   Mouse_Added   : constant SDL.Events.Event_Types :=
     SDL.Raw.Event_Layouts.Mice.Mouse_Added;
   Mouse_Removed : constant SDL.Events.Event_Types :=
     SDL.Raw.Event_Layouts.Mice.Mouse_Removed;

   subtype IDs is SDL.Raw.Event_Layouts.Mice.ID;

   Touch_Mouse_ID : constant IDs := SDL.Raw.Event_Layouts.Mice.Touch_Mouse_ID;

   subtype Buttons is SDL.Raw.Event_Layouts.Mice.Button;

   Left   : constant Buttons := SDL.Raw.Event_Layouts.Mice.Left;
   Middle : constant Buttons := SDL.Raw.Event_Layouts.Mice.Middle;
   Right  : constant Buttons := SDL.Raw.Event_Layouts.Mice.Right;
   X_1    : constant Buttons := SDL.Raw.Event_Layouts.Mice.X_1;
   X_2    : constant Buttons := SDL.Raw.Event_Layouts.Mice.X_2;

   subtype Button_Masks is SDL.Raw.Event_Layouts.Mice.Button_Mask;

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

   subtype Coordinates is SDL.Raw.Event_Layouts.Mice.Coordinate;
   subtype Movement_Values is SDL.Raw.Event_Layouts.Mice.Movement_Value;
   subtype Wheel_Values is SDL.Raw.Event_Layouts.Mice.Wheel_Value;

   subtype Motion_Events is SDL.Raw.Event_Layouts.Mice.Motion_Event;
   subtype Device_Events is SDL.Raw.Event_Layouts.Mice.Device_Event;

   subtype Button_Clicks is SDL.Raw.Event_Layouts.Mice.Button_Click;

   subtype Button_Events is SDL.Raw.Event_Layouts.Mice.Button_Event;

   function Get_State
     (Event : in Button_Events) return SDL.Events.Button_State is
       (if Boolean (Event.Down) then SDL.Events.Pressed else SDL.Events.Released);

   subtype Wheel_Directions is SDL.Raw.Event_Layouts.Mice.Wheel_Direction;

   Normal  : constant Wheel_Directions := SDL.Raw.Event_Layouts.Mice.Normal;
   Flipped : constant Wheel_Directions := SDL.Raw.Event_Layouts.Mice.Flipped;

   function Flip_Wheel_Value (Value : in Wheel_Values) return Wheel_Values is
     (-Value);

   subtype Wheel_Events is SDL.Raw.Event_Layouts.Mice.Wheel_Event;
end SDL.Events.Mice;
