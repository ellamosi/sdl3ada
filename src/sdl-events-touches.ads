with Interfaces;
with Interfaces.C;

with SDL.Raw.Event_Layouts.Touches;
with SDL.Raw.Touch;

package SDL.Events.Touches is
   Touch_Error : exception;

   Finger_Down     : constant SDL.Events.Event_Types :=
     SDL.Raw.Event_Layouts.Touches.Finger_Down;
   Finger_Up       : constant SDL.Events.Event_Types :=
     SDL.Raw.Event_Layouts.Touches.Finger_Up;
   Finger_Motion   : constant SDL.Events.Event_Types :=
     SDL.Raw.Event_Layouts.Touches.Finger_Motion;
   Finger_Canceled : constant SDL.Events.Event_Types :=
     SDL.Raw.Event_Layouts.Touches.Finger_Canceled;

   --  SDL3 retired the SDL2 dollar/multigesture stream. These constants stay
   --  reserved for compatibility, and the record types remain inert carriers
   --  for callers that still model the old SDL2 data.
   Dollar_Gesture       : constant SDL.Events.Event_Types := 16#0000_0800#;
   Dollar_Record        : constant SDL.Events.Event_Types := 16#0000_0801#;
   Dollar_Multi_Gesture : constant SDL.Events.Event_Types := 16#0000_0802#;

   subtype Touch_IDs is SDL.Raw.Touch.ID;
   subtype Finger_IDs is SDL.Raw.Touch.Finger_ID;
   subtype Gesture_IDs is Interfaces.Unsigned_64;

   subtype Touch_Device_Types is SDL.Raw.Touch.Device_Type;

   Invalid_Touch_Device           : constant Touch_Device_Types :=
     SDL.Raw.Touch.Invalid_Touch_Device;
   Direct_Touch_Device            : constant Touch_Device_Types :=
     SDL.Raw.Touch.Direct_Touch_Device;
   Indirect_Absolute_Touch_Device : constant Touch_Device_Types :=
     SDL.Raw.Touch.Indirect_Absolute_Touch_Device;
   Indirect_Relative_Touch_Device : constant Touch_Device_Types :=
     SDL.Raw.Touch.Indirect_Relative_Touch_Device;

   subtype Touch_Locations is SDL.Raw.Touch.Location;
   subtype Touch_Distances is SDL.Raw.Touch.Distance;
   subtype Touch_Pressures is SDL.Raw.Touch.Pressure_Value;

   subtype Finger is SDL.Raw.Touch.Finger;

   type ID_Lists is array (Natural range <>) of Touch_IDs;
   type Finger_Lists is array (Natural range <>) of Finger;

   subtype Finger_Events is SDL.Raw.Event_Layouts.Touches.Finger_Event;

   subtype Finger_Rotations is Interfaces.C.C_float;
   subtype Finger_Pinches is Interfaces.C.C_float;

   type Fingers_Touching is range 0 .. 2 ** 16 - 1 with
     Convention => C,
     Size       => 16;

   type Multi_Gesture_Events is record
      Event_Type : SDL.Events.Event_Types;
      Time_Stamp : SDL.Events.Time_Stamps;
      Touch_ID   : Touch_IDs;
      Theta      : Finger_Rotations;
      Distance   : Finger_Pinches;
      Centre_X   : Touch_Locations;
      Centre_Y   : Touch_Locations;
      Fingers    : Fingers_Touching;
      Padding    : SDL.Events.Padding_16;
   end record with
     Convention => C;

   subtype Dollar_Errors is Interfaces.C.C_float;

   type Dollar_Events is record
      Event_Type : SDL.Events.Event_Types;
      Time_Stamp : SDL.Events.Time_Stamps;
      Touch_ID   : Touch_IDs;
      Gesture_ID : Gesture_IDs;
      Fingers    : Fingers_Touching;
      Error      : Dollar_Errors;
      Centre_X   : Touch_Locations;
      Centre_Y   : Touch_Locations;
   end record with
     Convention => C;

   function Get_Touches return ID_Lists;

   function Name (Instance : in Touch_IDs) return String;

   function Device_Type
     (Instance : in Touch_IDs) return Touch_Device_Types;

   function Get_Fingers
     (Instance : in Touch_IDs) return Finger_Lists;
end SDL.Events.Touches;
