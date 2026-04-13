with Interfaces;
with Interfaces.C;
with Interfaces.C.Strings;

with SDL.Video.Windows;

package SDL.Events.Files is
   Drop_File     : constant SDL.Events.Event_Types := 16#0000_1000#;
   Drop_Text     : constant SDL.Events.Event_Types := 16#0000_1001#;
   Drop_Begin    : constant SDL.Events.Event_Types := 16#0000_1002#;
   Drop_Complete : constant SDL.Events.Event_Types := 16#0000_1003#;
   Drop_Position : constant SDL.Events.Event_Types := 16#0000_1004#;

   type Drop_Events is record
      Event_Type : SDL.Events.Event_Types;
      Reserved   : Interfaces.Unsigned_32;
      Time_Stamp : SDL.Events.Time_Stamps;
      Window_ID  : SDL.Video.Windows.ID;
      X          : Interfaces.C.C_float;
      Y          : Interfaces.C.C_float;
      Source     : Interfaces.C.Strings.chars_ptr;
      File_Name  : Interfaces.C.Strings.chars_ptr;
      --  SDL3 owns these pointers for real drop events; Ada callers must not
      --  free them after dequeuing the event.
   end record with
     Convention => C;
end SDL.Events.Files;
