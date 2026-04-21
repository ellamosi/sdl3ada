with SDL.Raw.Event_Layouts.Files;

package SDL.Events.Files is
   Drop_File     : constant SDL.Events.Event_Types :=
     SDL.Raw.Event_Layouts.Files.Drop_File;
   Drop_Text     : constant SDL.Events.Event_Types :=
     SDL.Raw.Event_Layouts.Files.Drop_Text;
   Drop_Begin    : constant SDL.Events.Event_Types :=
     SDL.Raw.Event_Layouts.Files.Drop_Begin;
   Drop_Complete : constant SDL.Events.Event_Types :=
     SDL.Raw.Event_Layouts.Files.Drop_Complete;
   Drop_Position : constant SDL.Events.Event_Types :=
     SDL.Raw.Event_Layouts.Files.Drop_Position;

   subtype Drop_Events is SDL.Raw.Event_Layouts.Files.Drop_Event;
   --  SDL3 owns the Source and File_Name pointers for real drop events; Ada
   --  callers must not free them after dequeuing the event.
end SDL.Events.Files;
