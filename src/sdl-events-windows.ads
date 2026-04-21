with SDL.Raw.Event_Layouts.Windows;

package SDL.Events.Windows is
   --  SDL3 emits one event type per window change instead of SDL2's shared
   --  Window + Event_ID encoding. The helpers below preserve the old logical
   --  categories without fabricating a non-native record layout.
   Window                : constant SDL.Events.Event_Types :=
     SDL.Raw.Event_Layouts.Windows.Window;
   System_Window_Manager : constant SDL.Events.Event_Types :=
     SDL.Raw.Event_Layouts.Windows.System_Window_Manager;

   type Window_Event_ID is
     (None,
      Shown,
      Hidden,
      Exposed,
      Moved,
      Resized,
      Size_Changed,
      Minimised,
      Maximised,
      Restored,
      Enter,
      Leave,
      Focus_Gained,
      Focus_Lost,
      Close,
      Take_Focus,
      Hit_Test);

   subtype Window_Events is SDL.Raw.Event_Layouts.Windows.Window_Event;

   function Is_Window_Event (Event_Type : in SDL.Events.Event_Types) return Boolean is
     (Event_Type in SDL.Raw.Event_Layouts.Windows.Shown
      .. SDL.Raw.Event_Layouts.Windows.Hit_Test);

   function Get_Event_ID
     (Event_Type : in SDL.Events.Event_Types) return Window_Event_ID;

   function Get_Event_ID
     (Event : in Window_Events) return Window_Event_ID is
       (Get_Event_ID (Event.Event_Type));

   function To_Event_Type
     (ID : in Window_Event_ID) return SDL.Events.Event_Types;
end SDL.Events.Windows;
