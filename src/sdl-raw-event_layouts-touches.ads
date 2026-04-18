with Interfaces;

with SDL.Raw.Event_Types;
with SDL.Raw.Touch;
with SDL.Raw.Video_Types;

package SDL.Raw.Event_Layouts.Touches is
   pragma Preelaborate;

   use type SDL.Raw.Event_Types.Event_Type;

   Finger_Down     : constant SDL.Raw.Event_Types.Event_Type := 16#0000_0700#;
   Finger_Up       : constant SDL.Raw.Event_Types.Event_Type :=
     Finger_Down + SDL.Raw.Event_Types.Event_Type (1);
   Finger_Motion   : constant SDL.Raw.Event_Types.Event_Type :=
     Finger_Down + SDL.Raw.Event_Types.Event_Type (2);
   Finger_Canceled : constant SDL.Raw.Event_Types.Event_Type :=
     Finger_Down + SDL.Raw.Event_Types.Event_Type (3);

   subtype Touch_ID is SDL.Raw.Touch.ID;
   subtype Finger_ID is SDL.Raw.Touch.Finger_ID;
   subtype Touch_Location is SDL.Raw.Touch.Location;
   subtype Touch_Distance is SDL.Raw.Touch.Distance;
   subtype Touch_Pressure is SDL.Raw.Touch.Pressure_Value;

   type Finger_Event is record
      Event_Type : SDL.Raw.Event_Types.Event_Type;
      Reserved   : Interfaces.Unsigned_32;
      Time_Stamp : Interfaces.Unsigned_64;
      Touch_ID   : SDL.Raw.Touch.ID;
      Finger_ID  : SDL.Raw.Touch.Finger_ID;
      X          : Touch_Location;
      Y          : Touch_Location;
      Delta_X    : Touch_Distance;
      Delta_Y    : Touch_Distance;
      Pressure   : Touch_Pressure;
      Window_ID  : SDL.Raw.Video_Types.Window_ID;
   end record with
     Convention => C;
end SDL.Raw.Event_Layouts.Touches;
