with Interfaces;
with Interfaces.C;

with SDL.Video.Windows;

package SDL.Events.Touches is
   Touch_Error : exception;

   Finger_Down     : constant SDL.Events.Event_Types := 16#0000_0700#;
   Finger_Up       : constant SDL.Events.Event_Types := 16#0000_0701#;
   Finger_Motion   : constant SDL.Events.Event_Types := 16#0000_0702#;
   Finger_Canceled : constant SDL.Events.Event_Types := 16#0000_0703#;

   --  SDL3 retired the SDL2 dollar/multigesture stream. These constants stay
   --  reserved for compatibility, and the record types remain inert carriers
   --  for callers that still model the old SDL2 data.
   Dollar_Gesture       : constant SDL.Events.Event_Types := 16#0000_0800#;
   Dollar_Record        : constant SDL.Events.Event_Types := 16#0000_0801#;
   Dollar_Multi_Gesture : constant SDL.Events.Event_Types := 16#0000_0802#;

   subtype Touch_IDs is Interfaces.Unsigned_64;
   subtype Finger_IDs is Interfaces.Unsigned_64;
   subtype Gesture_IDs is Interfaces.Unsigned_64;

   type Touch_Device_Types is
     (Invalid_Touch_Device,
      Direct_Touch_Device,
      Indirect_Absolute_Touch_Device,
      Indirect_Relative_Touch_Device)
   with
     Convention => C,
     Size       => Interfaces.C.int'Size;

   for Touch_Device_Types use
     (Invalid_Touch_Device           => -1,
      Direct_Touch_Device            => 0,
      Indirect_Absolute_Touch_Device => 1,
      Indirect_Relative_Touch_Device => 2);

   subtype Touch_Locations is Interfaces.C.C_float;
   subtype Touch_Distances is Interfaces.C.C_float;
   subtype Touch_Pressures is Interfaces.C.C_float;

   type Finger is record
      ID       : Finger_IDs := 0;
      X        : Touch_Locations := 0.0;
      Y        : Touch_Locations := 0.0;
      Pressure : Touch_Pressures := 0.0;
   end record with
     Convention => C;

   type ID_Lists is array (Natural range <>) of Touch_IDs;
   type Finger_Lists is array (Natural range <>) of Finger;

   type Finger_Events is record
      Event_Type : SDL.Events.Event_Types;
      Reserved   : Interfaces.Unsigned_32;
      Time_Stamp : SDL.Events.Time_Stamps;
      Touch_ID   : Touch_IDs;
      Finger_ID  : Finger_IDs;
      X          : Touch_Locations;
      Y          : Touch_Locations;
      Delta_X    : Touch_Distances;
      Delta_Y    : Touch_Distances;
      Pressure   : Touch_Pressures;
      Window_ID  : SDL.Video.Windows.ID;
   end record with
     Convention => C;

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
