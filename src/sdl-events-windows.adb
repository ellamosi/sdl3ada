package body SDL.Events.Windows is
   function Get_Event_ID
     (Event_Type : in SDL.Events.Event_Types) return Window_Event_ID is
   begin
      case Event_Type is
         when SDL.Raw.Event_Layouts.Windows.Shown =>
            return Shown;
         when SDL.Raw.Event_Layouts.Windows.Hidden =>
            return Hidden;
         when SDL.Raw.Event_Layouts.Windows.Exposed =>
            return Exposed;
         when SDL.Raw.Event_Layouts.Windows.Moved =>
            return Moved;
         when SDL.Raw.Event_Layouts.Windows.Resized =>
            return Resized;
         when SDL.Raw.Event_Layouts.Windows.Size_Changed =>
            return Size_Changed;
         when SDL.Raw.Event_Layouts.Windows.Minimised =>
            return Minimised;
         when SDL.Raw.Event_Layouts.Windows.Maximised =>
            return Maximised;
         when SDL.Raw.Event_Layouts.Windows.Restored =>
            return Restored;
         when SDL.Raw.Event_Layouts.Windows.Enter =>
            return Enter;
         when SDL.Raw.Event_Layouts.Windows.Leave =>
            return Leave;
         when SDL.Raw.Event_Layouts.Windows.Focus_Gained =>
            return Focus_Gained;
         when SDL.Raw.Event_Layouts.Windows.Focus_Lost =>
            return Focus_Lost;
         when SDL.Raw.Event_Layouts.Windows.Close =>
            return Close;
         when SDL.Raw.Event_Layouts.Windows.Hit_Test =>
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
            return SDL.Raw.Event_Layouts.Windows.Shown;
         when Hidden =>
            return SDL.Raw.Event_Layouts.Windows.Hidden;
         when Exposed =>
            return SDL.Raw.Event_Layouts.Windows.Exposed;
         when Moved =>
            return SDL.Raw.Event_Layouts.Windows.Moved;
         when Resized =>
            return SDL.Raw.Event_Layouts.Windows.Resized;
         when Size_Changed =>
            return SDL.Raw.Event_Layouts.Windows.Size_Changed;
         when Minimised =>
            return SDL.Raw.Event_Layouts.Windows.Minimised;
         when Maximised =>
            return SDL.Raw.Event_Layouts.Windows.Maximised;
         when Restored =>
            return SDL.Raw.Event_Layouts.Windows.Restored;
         when Enter =>
            return SDL.Raw.Event_Layouts.Windows.Enter;
         when Leave =>
            return SDL.Raw.Event_Layouts.Windows.Leave;
         when Focus_Gained =>
            return SDL.Raw.Event_Layouts.Windows.Focus_Gained;
         when Focus_Lost =>
            return SDL.Raw.Event_Layouts.Windows.Focus_Lost;
         when Close =>
            return SDL.Raw.Event_Layouts.Windows.Close;
         when Hit_Test =>
            return SDL.Raw.Event_Layouts.Windows.Hit_Test;
      end case;
   end To_Event_Type;
end SDL.Events.Windows;
