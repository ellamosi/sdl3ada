with Interfaces;

with SDL.Video.Windows;

package SDL.Events.Windows is
   --  SDL3 emits one event type per window change instead of SDL2's shared
   --  Window + Event_ID encoding. The helpers below preserve the old logical
   --  categories without fabricating a non-native record layout.
   Window                : constant SDL.Events.Event_Types := 16#0000_0200#;
   System_Window_Manager : constant SDL.Events.Event_Types := 16#0000_0201#;

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

   type Window_Events is record
      Event_Type : SDL.Events.Event_Types;
      Reserved   : Interfaces.Unsigned_32;
      Time_Stamp : SDL.Events.Time_Stamps;
      ID         : SDL.Video.Windows.ID;
      Data_1     : Interfaces.Integer_32;
      Data_2     : Interfaces.Integer_32;
   end record with
     Convention => C;

   function Is_Window_Event (Event_Type : in SDL.Events.Event_Types) return Boolean is
     (Event_Type in 16#0000_0202# .. 16#0000_021A#);

   function Get_Event_ID
     (Event_Type : in SDL.Events.Event_Types) return Window_Event_ID;

   function Get_Event_ID
     (Event : in Window_Events) return Window_Event_ID is
       (Get_Event_ID (Event.Event_Type));

   function To_Event_Type
     (ID : in Window_Event_ID) return SDL.Events.Event_Types;
end SDL.Events.Windows;
