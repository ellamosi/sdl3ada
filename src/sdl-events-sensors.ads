with Interfaces;
with Interfaces.C;

package SDL.Events.Sensors is
   pragma Pure;

   package C renames Interfaces.C;

   Update : constant Event_Types := 16#0000_1200#;

   type IDs is mod 2 ** 32 with
     Convention => C,
     Size       => 32;

   type Data_Values is array (0 .. 5) of aliased C.C_float with
     Convention     => C,
     Component_Size => C.C_float'Size;

   type Update_Events is record
      Event_Type       : Event_Types;
      Reserved         : Interfaces.Unsigned_32;
      Time_Stamp       : Time_Stamps;
      Which            : IDs;
      Data             : Data_Values;
      Sensor_Time_Stamp : Time_Stamps;
   end record with
     Convention => C;
end SDL.Events.Sensors;
