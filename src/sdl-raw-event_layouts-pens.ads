with Interfaces;
with Interfaces.C;
with Interfaces.C.Extensions;

with SDL.Raw.Event_Types;
with SDL.Raw.Pen;

package SDL.Raw.Event_Layouts.Pens is
   pragma Pure;

   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;

   use type SDL.Raw.Event_Types.Event_Type;

   Proximity_In  : constant SDL.Raw.Event_Types.Event_Type := 16#0000_1300#;
   Proximity_Out : constant SDL.Raw.Event_Types.Event_Type :=
     Proximity_In + SDL.Raw.Event_Types.Event_Type (1);
   Touch_Down    : constant SDL.Raw.Event_Types.Event_Type :=
     Proximity_In + SDL.Raw.Event_Types.Event_Type (2);
   Touch_Up      : constant SDL.Raw.Event_Types.Event_Type :=
     Proximity_In + SDL.Raw.Event_Types.Event_Type (3);
   Button_Down   : constant SDL.Raw.Event_Types.Event_Type :=
     Proximity_In + SDL.Raw.Event_Types.Event_Type (4);
   Button_Up     : constant SDL.Raw.Event_Types.Event_Type :=
     Proximity_In + SDL.Raw.Event_Types.Event_Type (5);
   Motion        : constant SDL.Raw.Event_Types.Event_Type :=
     Proximity_In + SDL.Raw.Event_Types.Event_Type (6);
   Axis          : constant SDL.Raw.Event_Types.Event_Type :=
     Proximity_In + SDL.Raw.Event_Types.Event_Type (7);

   subtype ID is SDL.Raw.Pen.ID;
   subtype Input_Flags is SDL.Raw.Pen.Input_Flags;
   subtype Axis_Kind is SDL.Raw.Pen.Axes;

   subtype Coordinate is C.C_float;

   type Window_ID is mod 2 ** 32 with
     Convention => C,
     Size       => 32;

   type Proximity_Event is record
      Event_Type : SDL.Raw.Event_Types.Event_Type;
      Reserved   : Interfaces.Unsigned_32;
      Time_Stamp : Interfaces.Unsigned_64;
      Window     : Window_ID;
      Which      : ID;
   end record with
     Convention => C;

   type Motion_Event is record
      Event_Type : SDL.Raw.Event_Types.Event_Type;
      Reserved   : Interfaces.Unsigned_32;
      Time_Stamp : Interfaces.Unsigned_64;
      Window     : Window_ID;
      Which      : ID;
      Pen_State  : Input_Flags;
      X          : Coordinate;
      Y          : Coordinate;
   end record with
     Convention => C;

   type Touch_Event is record
      Event_Type : SDL.Raw.Event_Types.Event_Type;
      Reserved   : Interfaces.Unsigned_32;
      Time_Stamp : Interfaces.Unsigned_64;
      Window     : Window_ID;
      Which      : ID;
      Pen_State  : Input_Flags;
      X          : Coordinate;
      Y          : Coordinate;
      Eraser     : CE.bool;
      Down       : CE.bool;
   end record with
     Convention => C;

   type Button_Index is range 0 .. 255 with
     Convention => C,
     Size       => 8;

   type Button_Event is record
      Event_Type : SDL.Raw.Event_Types.Event_Type;
      Reserved   : Interfaces.Unsigned_32;
      Time_Stamp : Interfaces.Unsigned_64;
      Window     : Window_ID;
      Which      : ID;
      Pen_State  : Input_Flags;
      X          : Coordinate;
      Y          : Coordinate;
      Button     : Button_Index;
      Down       : CE.bool;
   end record with
     Convention => C;

   type Axis_Event is record
      Event_Type : SDL.Raw.Event_Types.Event_Type;
      Reserved   : Interfaces.Unsigned_32;
      Time_Stamp : Interfaces.Unsigned_64;
      Window     : Window_ID;
      Which      : ID;
      Pen_State  : Input_Flags;
      X          : Coordinate;
      Y          : Coordinate;
      Axis       : SDL.Raw.Event_Layouts.Pens.Axis_Kind;
      Value      : Coordinate;
   end record with
     Convention => C;
end SDL.Raw.Event_Layouts.Pens;
