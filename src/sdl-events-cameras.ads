with Interfaces;

package SDL.Events.Cameras is
   pragma Pure;

   use type Event_Types;

   Device_Added    : constant Event_Types := 16#0000_1400#;
   Device_Removed  : constant Event_Types := Device_Added + Event_Types (1);
   Device_Approved : constant Event_Types := Device_Added + Event_Types (2);
   Device_Denied   : constant Event_Types := Device_Added + Event_Types (3);

   type IDs is mod 2 ** 32 with
     Convention => C,
     Size       => 32;

   type Device_Events is record
      Event_Type : Event_Types;
      Reserved   : Interfaces.Unsigned_32;
      Time_Stamp : Time_Stamps;
      Which      : IDs;
   end record with
     Convention => C;
end SDL.Events.Cameras;
