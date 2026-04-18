with Interfaces;
with SDL.Raw.Event_Layouts;
with SDL.Raw.Event_Types;

package SDL.Events is
   pragma Pure;

   subtype Event_Types is SDL.Raw.Event_Types.Event_Type;
   subtype Time_Stamps is Interfaces.Unsigned_64;
   subtype Window_IDs is Interfaces.Unsigned_32;
   subtype Keyboard_IDs is Interfaces.Unsigned_32;

   type Button_State is (Released, Pressed) with
     Convention => C,
     Size       => 8;

   for Button_State use (Released => 0, Pressed => 1);

   First_Event               : constant Event_Types := SDL.Raw.Event_Types.First_Event;
   Quit                      : constant Event_Types := SDL.Raw.Event_Types.Quit;
   App_Terminating           : constant Event_Types := SDL.Raw.Event_Types.App_Terminating;
   App_Low_Memory            : constant Event_Types := SDL.Raw.Event_Types.App_Low_Memory;
   App_Will_Enter_Background : constant Event_Types := SDL.Raw.Event_Types.App_Will_Enter_Background;
   App_Did_Enter_Background  : constant Event_Types := SDL.Raw.Event_Types.App_Did_Enter_Background;
   App_Will_Enter_Foreground : constant Event_Types := SDL.Raw.Event_Types.App_Will_Enter_Foreground;
   App_Did_Enter_Foreground  : constant Event_Types := SDL.Raw.Event_Types.App_Did_Enter_Foreground;
   Locale_Changed            : constant Event_Types := SDL.Raw.Event_Types.Locale_Changed;
   Clipboard_Update          : constant Event_Types := SDL.Raw.Event_Types.Clipboard_Update;
   User                      : constant Event_Types := SDL.Raw.Event_Types.User;
   Last_Event                : constant Event_Types := SDL.Raw.Event_Types.Last_Event;

   type Padding_8 is mod 2 ** 8 with
     Convention => C,
     Size       => 8;

   type Padding_16 is mod 2 ** 16 with
     Convention => C,
     Size       => 16;

   subtype Common_Events is SDL.Raw.Event_Layouts.Common_Event;

   subtype Event_Codes is SDL.Raw.Event_Layouts.Event_Code;

   subtype User_Events is SDL.Raw.Event_Layouts.User_Event;
end SDL.Events;
