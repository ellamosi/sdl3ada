with Interfaces;

package SDL.Raw.Event_Types is
   pragma Pure;

   subtype Event_Type is Interfaces.Unsigned_32;

   First_Event               : constant Event_Type := 16#0000_0000#;
   Quit                      : constant Event_Type := 16#0000_0100#;
   App_Terminating           : constant Event_Type := 16#0000_0101#;
   App_Low_Memory            : constant Event_Type := 16#0000_0102#;
   App_Will_Enter_Background : constant Event_Type := 16#0000_0103#;
   App_Did_Enter_Background  : constant Event_Type := 16#0000_0104#;
   App_Will_Enter_Foreground : constant Event_Type := 16#0000_0105#;
   App_Did_Enter_Foreground  : constant Event_Type := 16#0000_0106#;
   Locale_Changed            : constant Event_Type := 16#0000_0107#;
   Clipboard_Update          : constant Event_Type := 16#0000_0900#;
   User                      : constant Event_Type := 16#0000_8000#;
   Last_Event                : constant Event_Type := 16#0000_FFFF#;
end SDL.Raw.Event_Types;
