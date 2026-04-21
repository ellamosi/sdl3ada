with Interfaces.C;
with Interfaces.C.Extensions;

with SDL.Raw.Event_Layouts.Pens;

package SDL.Events.Pens is
   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;

   Proximity_In  : constant Event_Types := SDL.Raw.Event_Layouts.Pens.Proximity_In;
   Proximity_Out : constant Event_Types := SDL.Raw.Event_Layouts.Pens.Proximity_Out;
   Touch_Down    : constant Event_Types := SDL.Raw.Event_Layouts.Pens.Touch_Down;
   Touch_Up      : constant Event_Types := SDL.Raw.Event_Layouts.Pens.Touch_Up;
   Button_Down   : constant Event_Types := SDL.Raw.Event_Layouts.Pens.Button_Down;
   Button_Up     : constant Event_Types := SDL.Raw.Event_Layouts.Pens.Button_Up;
   Motion        : constant Event_Types := SDL.Raw.Event_Layouts.Pens.Motion;
   Axis          : constant Event_Types := SDL.Raw.Event_Layouts.Pens.Axis;

   subtype IDs is SDL.Raw.Event_Layouts.Pens.ID;
   subtype Coordinates is SDL.Raw.Event_Layouts.Pens.Coordinate;

   subtype Proximity_Events is SDL.Raw.Event_Layouts.Pens.Proximity_Event;

   subtype Motion_Events is SDL.Raw.Event_Layouts.Pens.Motion_Event;

   subtype Touch_Events is SDL.Raw.Event_Layouts.Pens.Touch_Event;

   function Get_State (Event : in Touch_Events) return SDL.Events.Button_State is
     (if Boolean (Event.Down) then SDL.Events.Pressed else SDL.Events.Released);

   subtype Button_Indices is SDL.Raw.Event_Layouts.Pens.Button_Index;

   subtype Button_Events is SDL.Raw.Event_Layouts.Pens.Button_Event;

   function Get_State (Event : in Button_Events) return SDL.Events.Button_State is
     (if Boolean (Event.Down) then SDL.Events.Pressed else SDL.Events.Released);

   subtype Axis_Events is SDL.Raw.Event_Layouts.Pens.Axis_Event;
end SDL.Events.Pens;
