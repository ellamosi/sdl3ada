with Interfaces;

with SDL.Raw.Event_Types;

package SDL.Raw.Event_Layouts.Cameras is
   pragma Pure;

   use type SDL.Raw.Event_Types.Event_Type;

   Device_Added    : constant SDL.Raw.Event_Types.Event_Type := 16#0000_1400#;
   Device_Removed  : constant SDL.Raw.Event_Types.Event_Type :=
     Device_Added + SDL.Raw.Event_Types.Event_Type (1);
   Device_Approved : constant SDL.Raw.Event_Types.Event_Type :=
     Device_Added + SDL.Raw.Event_Types.Event_Type (2);
   Device_Denied   : constant SDL.Raw.Event_Types.Event_Type :=
     Device_Added + SDL.Raw.Event_Types.Event_Type (3);

   type ID is mod 2 ** 32 with
     Convention => C,
     Size       => 32;

   type Device_Event is record
      Event_Type : SDL.Raw.Event_Types.Event_Type;
      Reserved   : Interfaces.Unsigned_32;
      Time_Stamp : Interfaces.Unsigned_64;
      Which      : ID;
   end record with
     Convention => C;
end SDL.Raw.Event_Layouts.Cameras;
