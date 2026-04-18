with SDL.Raw.Event_Layouts.Cameras;

package SDL.Events.Cameras is
   pragma Pure;

   subtype IDs is SDL.Raw.Event_Layouts.Cameras.ID;

   Device_Added    : constant Event_Types :=
     SDL.Raw.Event_Layouts.Cameras.Device_Added;
   Device_Removed  : constant Event_Types :=
     SDL.Raw.Event_Layouts.Cameras.Device_Removed;
   Device_Approved : constant Event_Types :=
     SDL.Raw.Event_Layouts.Cameras.Device_Approved;
   Device_Denied   : constant Event_Types :=
     SDL.Raw.Event_Layouts.Cameras.Device_Denied;

   subtype Device_Events is SDL.Raw.Event_Layouts.Cameras.Device_Event;
end SDL.Events.Cameras;
