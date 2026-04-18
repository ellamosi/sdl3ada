with Interfaces;
with Interfaces.C;

with SDL.Raw.Event_Layouts.Sensors;

package SDL.Events.Sensors is
   pragma Pure;

   package C renames Interfaces.C;

   Update : constant Event_Types := SDL.Raw.Event_Layouts.Sensors.Update;

   subtype IDs is SDL.Raw.Event_Layouts.Sensors.ID;

   subtype Data_Values is SDL.Raw.Event_Layouts.Sensors.Data_Value_Array;

   subtype Update_Events is SDL.Raw.Event_Layouts.Sensors.Update_Event;
end SDL.Events.Sensors;
