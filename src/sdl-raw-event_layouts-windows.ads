with Interfaces;

with SDL.Raw.Event_Types;

package SDL.Raw.Event_Layouts.Windows is
   pragma Pure;

   use type SDL.Raw.Event_Types.Event_Type;

   Window                : constant SDL.Raw.Event_Types.Event_Type := 16#0000_0200#;
   System_Window_Manager : constant SDL.Raw.Event_Types.Event_Type :=
     Window + SDL.Raw.Event_Types.Event_Type (1);
   Shown                 : constant SDL.Raw.Event_Types.Event_Type :=
     Window + SDL.Raw.Event_Types.Event_Type (2);
   Hidden                : constant SDL.Raw.Event_Types.Event_Type :=
     Window + SDL.Raw.Event_Types.Event_Type (3);
   Exposed               : constant SDL.Raw.Event_Types.Event_Type :=
     Window + SDL.Raw.Event_Types.Event_Type (4);
   Moved                 : constant SDL.Raw.Event_Types.Event_Type :=
     Window + SDL.Raw.Event_Types.Event_Type (5);
   Resized               : constant SDL.Raw.Event_Types.Event_Type :=
     Window + SDL.Raw.Event_Types.Event_Type (6);
   Size_Changed          : constant SDL.Raw.Event_Types.Event_Type :=
     Window + SDL.Raw.Event_Types.Event_Type (7);
   Minimised             : constant SDL.Raw.Event_Types.Event_Type :=
     Window + SDL.Raw.Event_Types.Event_Type (9);
   Maximised             : constant SDL.Raw.Event_Types.Event_Type :=
     Window + SDL.Raw.Event_Types.Event_Type (10);
   Restored              : constant SDL.Raw.Event_Types.Event_Type :=
     Window + SDL.Raw.Event_Types.Event_Type (11);
   Enter                 : constant SDL.Raw.Event_Types.Event_Type :=
     Window + SDL.Raw.Event_Types.Event_Type (12);
   Leave                 : constant SDL.Raw.Event_Types.Event_Type :=
     Window + SDL.Raw.Event_Types.Event_Type (13);
   Focus_Gained          : constant SDL.Raw.Event_Types.Event_Type :=
     Window + SDL.Raw.Event_Types.Event_Type (14);
   Focus_Lost            : constant SDL.Raw.Event_Types.Event_Type :=
     Window + SDL.Raw.Event_Types.Event_Type (15);
   Close                 : constant SDL.Raw.Event_Types.Event_Type :=
     Window + SDL.Raw.Event_Types.Event_Type (16);
   Hit_Test              : constant SDL.Raw.Event_Types.Event_Type :=
     Window + SDL.Raw.Event_Types.Event_Type (17);

   type Window_ID is mod 2 ** 32 with
     Convention => C,
     Size       => 32;

   type Window_Event is record
      Event_Type : SDL.Raw.Event_Types.Event_Type;
      Reserved   : Interfaces.Unsigned_32;
      Time_Stamp : Interfaces.Unsigned_64;
      ID         : Window_ID;
      Data_1     : Interfaces.Integer_32;
      Data_2     : Interfaces.Integer_32;
   end record with
     Convention => C;
end SDL.Raw.Event_Layouts.Windows;
