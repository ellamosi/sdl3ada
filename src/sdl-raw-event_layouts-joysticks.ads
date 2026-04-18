with Interfaces;
with Interfaces.C;
with Interfaces.C.Extensions;

with SDL.Raw.Event_Types;
with SDL.Raw.Power;

package SDL.Raw.Event_Layouts.Joysticks is
   pragma Pure;

   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;

   use type SDL.Raw.Event_Types.Event_Type;

   Axis_Motion     : constant SDL.Raw.Event_Types.Event_Type := 16#0000_0600#;
   Ball_Motion     : constant SDL.Raw.Event_Types.Event_Type :=
     Axis_Motion + SDL.Raw.Event_Types.Event_Type (1);
   Hat_Motion      : constant SDL.Raw.Event_Types.Event_Type :=
     Axis_Motion + SDL.Raw.Event_Types.Event_Type (2);
   Button_Down     : constant SDL.Raw.Event_Types.Event_Type :=
     Axis_Motion + SDL.Raw.Event_Types.Event_Type (3);
   Button_Up       : constant SDL.Raw.Event_Types.Event_Type :=
     Axis_Motion + SDL.Raw.Event_Types.Event_Type (4);
   Device_Added    : constant SDL.Raw.Event_Types.Event_Type :=
     Axis_Motion + SDL.Raw.Event_Types.Event_Type (5);
   Device_Removed  : constant SDL.Raw.Event_Types.Event_Type :=
     Axis_Motion + SDL.Raw.Event_Types.Event_Type (6);
   Battery_Updated : constant SDL.Raw.Event_Types.Event_Type :=
     Axis_Motion + SDL.Raw.Event_Types.Event_Type (7);
   Update_Complete : constant SDL.Raw.Event_Types.Event_Type :=
     Axis_Motion + SDL.Raw.Event_Types.Event_Type (8);

   type ID is mod 2 ** 32 with
     Convention => C,
     Size       => 32;

   type Axis_Index is range 0 .. 255 with
     Convention => C,
     Size       => 8;

   type Axis_Value is range -32_768 .. 32_767 with
     Convention => C,
     Size       => 16;

   type Axis_Event is record
      Event_Type : SDL.Raw.Event_Types.Event_Type;
      Reserved   : Interfaces.Unsigned_32;
      Time_Stamp : Interfaces.Unsigned_64;
      Which      : ID;
      Axis       : Axis_Index;
      Padding_1  : Interfaces.Unsigned_8;
      Padding_2  : Interfaces.Unsigned_8;
      Padding_3  : Interfaces.Unsigned_8;
      Value      : Axis_Value;
      Padding_4  : Interfaces.Unsigned_16;
   end record with
     Convention => C;

   type Ball_Index is range 0 .. 255 with
     Convention => C,
     Size       => 8;

   subtype Ball_Delta is Axis_Value;

   type Ball_Event is record
      Event_Type : SDL.Raw.Event_Types.Event_Type;
      Reserved   : Interfaces.Unsigned_32;
      Time_Stamp : Interfaces.Unsigned_64;
      Which      : ID;
      Ball       : Ball_Index;
      Padding_1  : Interfaces.Unsigned_8;
      Padding_2  : Interfaces.Unsigned_8;
      Padding_3  : Interfaces.Unsigned_8;
      X_Relative : Ball_Delta;
      Y_Relative : Ball_Delta;
   end record with
     Convention => C;

   type Hat_Index is range 0 .. 255 with
     Convention => C,
     Size       => 8;

   type Hat_Position is mod 2 ** 8 with
     Convention => C,
     Size       => 8;

   Hat_Centred    : constant Hat_Position := 0;
   Hat_Up         : constant Hat_Position := 1;
   Hat_Right      : constant Hat_Position := 2;
   Hat_Down       : constant Hat_Position := 4;
   Hat_Left       : constant Hat_Position := 8;
   Hat_Right_Up   : constant Hat_Position := Hat_Right or Hat_Up;
   Hat_Right_Down : constant Hat_Position := Hat_Right or Hat_Down;
   Hat_Left_Up    : constant Hat_Position := Hat_Left or Hat_Up;
   Hat_Left_Down  : constant Hat_Position := Hat_Left or Hat_Down;

   type Hat_Event is record
      Event_Type : SDL.Raw.Event_Types.Event_Type;
      Reserved   : Interfaces.Unsigned_32;
      Time_Stamp : Interfaces.Unsigned_64;
      Which      : ID;
      Hat        : Hat_Index;
      Position   : Hat_Position;
      Padding_1  : Interfaces.Unsigned_8;
      Padding_2  : Interfaces.Unsigned_8;
   end record with
     Convention => C;

   type Button_Index is range 0 .. 255 with
     Convention => C,
     Size       => 8;

   type Button_Event is record
      Event_Type : SDL.Raw.Event_Types.Event_Type;
      Reserved   : Interfaces.Unsigned_32;
      Time_Stamp : Interfaces.Unsigned_64;
      Which      : ID;
      Button     : Button_Index;
      Down       : CE.bool;
      Padding_1  : Interfaces.Unsigned_8;
      Padding_2  : Interfaces.Unsigned_8;
   end record with
     Convention => C;

   type Device_Event is record
      Event_Type : SDL.Raw.Event_Types.Event_Type;
      Reserved   : Interfaces.Unsigned_32;
      Time_Stamp : Interfaces.Unsigned_64;
      Which      : ID;
   end record with
     Convention => C;

   subtype Battery_Percentage is C.int range -1 .. 100;
   subtype Power_State is SDL.Raw.Power.State;

   type Battery_Event is record
      Event_Type : SDL.Raw.Event_Types.Event_Type;
      Reserved   : Interfaces.Unsigned_32;
      Time_Stamp : Interfaces.Unsigned_64;
      Which      : ID;
      State      : Power_State;
      Percent    : Battery_Percentage;
   end record with
     Convention => C;
end SDL.Raw.Event_Layouts.Joysticks;
