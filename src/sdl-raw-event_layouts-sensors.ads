with Interfaces;
with Interfaces.C;

with SDL.Raw.Event_Types;

package SDL.Raw.Event_Layouts.Sensors is
   pragma Pure;

   package C renames Interfaces.C;

   Update : constant SDL.Raw.Event_Types.Event_Type := 16#0000_1200#;

   type ID is mod 2 ** 32 with
     Convention => C,
     Size       => 32;

   type Data_Value_Array is array (0 .. 5) of aliased C.C_float with
     Convention     => C,
     Component_Size => C.C_float'Size;

   type Update_Event is record
      Event_Type        : SDL.Raw.Event_Types.Event_Type;
      Reserved          : Interfaces.Unsigned_32;
      Time_Stamp        : Interfaces.Unsigned_64;
      Which             : ID;
      Data              : Data_Value_Array;
      Sensor_Time_Stamp : Interfaces.Unsigned_64;
   end record with
     Convention => C;
end SDL.Raw.Event_Layouts.Sensors;
