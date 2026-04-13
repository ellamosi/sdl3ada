with Interfaces;
with Interfaces.C;
with Interfaces.C.Extensions;

with SDL.Pens;
with SDL.Video.Windows;

package SDL.Events.Pens is
   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;

   use type Event_Types;

   Proximity_In  : constant Event_Types := 16#0000_1300#;
   Proximity_Out : constant Event_Types := Proximity_In + Event_Types (1);
   Touch_Down    : constant Event_Types := Proximity_In + Event_Types (2);
   Touch_Up      : constant Event_Types := Proximity_In + Event_Types (3);
   Button_Down   : constant Event_Types := Proximity_In + Event_Types (4);
   Button_Up     : constant Event_Types := Proximity_In + Event_Types (5);
   Motion        : constant Event_Types := Proximity_In + Event_Types (6);
   Axis          : constant Event_Types := Proximity_In + Event_Types (7);

   subtype IDs is SDL.Pens.ID;
   subtype Coordinates is C.C_float;

   type Proximity_Events is record
      Event_Type : Event_Types;
      Reserved   : Interfaces.Unsigned_32;
      Time_Stamp : Time_Stamps;
      Window     : SDL.Video.Windows.ID;
      Which      : IDs;
   end record with
     Convention => C;

   type Motion_Events is record
      Event_Type : Event_Types;
      Reserved   : Interfaces.Unsigned_32;
      Time_Stamp : Time_Stamps;
      Window     : SDL.Video.Windows.ID;
      Which      : IDs;
      Pen_State  : SDL.Pens.Input_Flags;
      X          : Coordinates;
      Y          : Coordinates;
   end record with
     Convention => C;

   type Touch_Events is record
      Event_Type : Event_Types;
      Reserved   : Interfaces.Unsigned_32;
      Time_Stamp : Time_Stamps;
      Window     : SDL.Video.Windows.ID;
      Which      : IDs;
      Pen_State  : SDL.Pens.Input_Flags;
      X          : Coordinates;
      Y          : Coordinates;
      Eraser     : CE.bool;
      Down       : CE.bool;
   end record with
     Convention => C;

   function Get_State (Event : in Touch_Events) return SDL.Events.Button_State is
     (if Boolean (Event.Down) then SDL.Events.Pressed else SDL.Events.Released);

   type Button_Indices is range 0 .. 255 with
     Convention => C,
     Size       => 8;

   type Button_Events is record
      Event_Type : Event_Types;
      Reserved   : Interfaces.Unsigned_32;
      Time_Stamp : Time_Stamps;
      Window     : SDL.Video.Windows.ID;
      Which      : IDs;
      Pen_State  : SDL.Pens.Input_Flags;
      X          : Coordinates;
      Y          : Coordinates;
      Button     : Button_Indices;
      Down       : CE.bool;
   end record with
     Convention => C;

   function Get_State (Event : in Button_Events) return SDL.Events.Button_State is
     (if Boolean (Event.Down) then SDL.Events.Pressed else SDL.Events.Released);

   type Axis_Events is record
      Event_Type : Event_Types;
      Reserved   : Interfaces.Unsigned_32;
      Time_Stamp : Time_Stamps;
      Window     : SDL.Video.Windows.ID;
      Which      : IDs;
      Pen_State  : SDL.Pens.Input_Flags;
      X          : Coordinates;
      Y          : Coordinates;
      Axis       : SDL.Pens.Axes;
      Value      : Coordinates;
   end record with
     Convention => C;
end SDL.Events.Pens;
