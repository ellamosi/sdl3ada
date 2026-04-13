with Interfaces;
with System;

package SDL.Events is
   pragma Pure;

   subtype Event_Types is Interfaces.Unsigned_32;
   subtype Time_Stamps is Interfaces.Unsigned_64;
   subtype Window_IDs is Interfaces.Unsigned_32;
   subtype Keyboard_IDs is Interfaces.Unsigned_32;

   type Button_State is (Released, Pressed) with
     Convention => C,
     Size       => 8;

   for Button_State use (Released => 0, Pressed => 1);

   First_Event               : constant Event_Types := 16#0000_0000#;
   Quit                      : constant Event_Types := 16#0000_0100#;
   App_Terminating           : constant Event_Types := 16#0000_0101#;
   App_Low_Memory            : constant Event_Types := 16#0000_0102#;
   App_Will_Enter_Background : constant Event_Types := 16#0000_0103#;
   App_Did_Enter_Background  : constant Event_Types := 16#0000_0104#;
   App_Will_Enter_Foreground : constant Event_Types := 16#0000_0105#;
   App_Did_Enter_Foreground  : constant Event_Types := 16#0000_0106#;
   Locale_Changed            : constant Event_Types := 16#0000_0107#;
   Clipboard_Update          : constant Event_Types := 16#0000_0900#;
   User                      : constant Event_Types := 16#0000_8000#;
   Last_Event                : constant Event_Types := 16#0000_FFFF#;

   type Padding_8 is mod 2 ** 8 with
     Convention => C,
     Size       => 8;

   type Padding_16 is mod 2 ** 16 with
     Convention => C,
     Size       => 16;

   type Common_Events is record
      Event_Type : Event_Types;
      Reserved   : Interfaces.Unsigned_32;
      Time_Stamp : Time_Stamps;
   end record with
     Convention => C;

   subtype Event_Codes is Interfaces.Integer_32;

   type User_Events is record
      Event_Type : Event_Types;
      Reserved   : Interfaces.Unsigned_32;
      Time_Stamp : Time_Stamps;
      Window_ID  : Window_IDs;
      Code       : Event_Codes;
      Data_1     : System.Address;
      Data_2     : System.Address;
   end record with
     Convention => C;
end SDL.Events;
