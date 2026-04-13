package body SDL.Events.Windows is
   function Get_Event_ID
     (Event_Type : in SDL.Events.Event_Types) return Window_Event_ID is
   begin
      case Event_Type is
         when 16#0000_0202# =>
            return Shown;
         when 16#0000_0203# =>
            return Hidden;
         when 16#0000_0204# =>
            return Exposed;
         when 16#0000_0205# =>
            return Moved;
         when 16#0000_0206# =>
            return Resized;
         when 16#0000_0207# =>
            return Size_Changed;
         when 16#0000_0209# =>
            return Minimised;
         when 16#0000_020A# =>
            return Maximised;
         when 16#0000_020B# =>
            return Restored;
         when 16#0000_020C# =>
            return Enter;
         when 16#0000_020D# =>
            return Leave;
         when 16#0000_020E# =>
            return Focus_Gained;
         when 16#0000_020F# =>
            return Focus_Lost;
         when 16#0000_0210# =>
            return Close;
         when 16#0000_0211# =>
            return Hit_Test;
         when others =>
            return None;
      end case;
   end Get_Event_ID;

   function To_Event_Type
     (ID : in Window_Event_ID) return SDL.Events.Event_Types is
   begin
      case ID is
         when None | Take_Focus =>
            return Window;
         when Shown =>
            return 16#0000_0202#;
         when Hidden =>
            return 16#0000_0203#;
         when Exposed =>
            return 16#0000_0204#;
         when Moved =>
            return 16#0000_0205#;
         when Resized =>
            return 16#0000_0206#;
         when Size_Changed =>
            return 16#0000_0207#;
         when Minimised =>
            return 16#0000_0209#;
         when Maximised =>
            return 16#0000_020A#;
         when Restored =>
            return 16#0000_020B#;
         when Enter =>
            return 16#0000_020C#;
         when Leave =>
            return 16#0000_020D#;
         when Focus_Gained =>
            return 16#0000_020E#;
         when Focus_Lost =>
            return 16#0000_020F#;
         when Close =>
            return 16#0000_0210#;
         when Hit_Test =>
            return 16#0000_0211#;
      end case;
   end To_Event_Type;
end SDL.Events.Windows;
