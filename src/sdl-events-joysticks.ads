with Interfaces;
with Interfaces.C;
with Interfaces.C.Extensions;

with SDL.Power;

package SDL.Events.Joysticks is
   pragma Pure;

   package CE renames Interfaces.C.Extensions;

   use type Event_Types;

   Axis_Motion      : constant Event_Types := 16#0000_0600#;
   Ball_Motion      : constant Event_Types := Axis_Motion + Event_Types (1);
   Hat_Motion       : constant Event_Types := Axis_Motion + Event_Types (2);
   Button_Down      : constant Event_Types := Axis_Motion + Event_Types (3);
   Button_Up        : constant Event_Types := Axis_Motion + Event_Types (4);
   Device_Added     : constant Event_Types := Axis_Motion + Event_Types (5);
   Device_Removed   : constant Event_Types := Axis_Motion + Event_Types (6);
   Battery_Updated  : constant Event_Types := Axis_Motion + Event_Types (7);
   Update_Complete  : constant Event_Types := Axis_Motion + Event_Types (8);

   type IDs is mod 2 ** 32 with
     Convention => C,
     Size       => 32;

   type Axes is range 0 .. 255 with
     Convention => C,
     Size       => 8;

   type Axes_Values is range -32_768 .. 32_767 with
     Convention => C,
     Size       => 16;

   type Axis_Events is record
      Event_Type : Event_Types;
      Reserved   : Interfaces.Unsigned_32;
      Time_Stamp : Time_Stamps;
      Which      : IDs;
      Axis       : Axes;
      Padding_1  : Padding_8;
      Padding_2  : Padding_8;
      Padding_3  : Padding_8;
      Value      : Axes_Values;
      Padding_4  : Padding_16;
   end record with
     Convention => C;

   type Balls is range 0 .. 255 with
     Convention => C,
     Size       => 8;

   type Ball_Values is range -32_768 .. 32_767 with
     Convention => C,
     Size       => 16;

   type Ball_Events is record
      Event_Type : Event_Types;
      Reserved   : Interfaces.Unsigned_32;
      Time_Stamp : Time_Stamps;
      Which      : IDs;
      Ball       : Balls;
      Padding_1  : Padding_8;
      Padding_2  : Padding_8;
      Padding_3  : Padding_8;
      X_Relative : Ball_Values;
      Y_Relative : Ball_Values;
   end record with
     Convention => C;

   type Hats is range 0 .. 255 with
     Convention => C,
     Size       => 8;

   type Hat_Positions is mod 2 ** 8 with
     Convention => C,
     Size       => 8;

   Hat_Centred    : constant Hat_Positions := 0;
   Hat_Up         : constant Hat_Positions := 1;
   Hat_Right      : constant Hat_Positions := 2;
   Hat_Down       : constant Hat_Positions := 4;
   Hat_Left       : constant Hat_Positions := 8;
   Hat_Right_Up   : constant Hat_Positions := Hat_Right or Hat_Up;
   Hat_Right_Down : constant Hat_Positions := Hat_Right or Hat_Down;
   Hat_Left_Up    : constant Hat_Positions := Hat_Left or Hat_Up;
   Hat_Left_Down  : constant Hat_Positions := Hat_Left or Hat_Down;

   type Hat_Events is record
      Event_Type : Event_Types;
      Reserved   : Interfaces.Unsigned_32;
      Time_Stamp : Time_Stamps;
      Which      : IDs;
      Hat        : Hats;
      Position   : Hat_Positions;
      Padding_1  : Padding_8;
      Padding_2  : Padding_8;
   end record with
     Convention => C;

   type Buttons is range 0 .. 255 with
     Convention => C,
     Size       => 8;

   type Button_Events is record
      Event_Type : Event_Types;
      Reserved   : Interfaces.Unsigned_32;
      Time_Stamp : Time_Stamps;
      Which      : IDs;
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
      Which      : IDs;
   end record with
     Convention => C;

   subtype Battery_Percentages is Interfaces.C.int range -1 .. 100;

   type Battery_Events is record
      Event_Type : Event_Types;
      Reserved   : Interfaces.Unsigned_32;
      Time_Stamp : Time_Stamps;
      Which      : IDs;
      State      : SDL.Power.State;
      Percent    : Battery_Percentages;
   end record with
     Convention => C;

   procedure Update;

   function Is_Polling_Enabled return Boolean;

   procedure Enable_Polling;

   procedure Disable_Polling;
end SDL.Events.Joysticks;
