with Ada.Strings.Fixed;
with Ada.Text_IO;

with SDL;
with SDL.Error;
with SDL.Events;
with SDL.Events.Queue;
with SDL.Events.Keyboards;
with SDL.Time;
with SDL.Timers;
with SDL.Video.Renderers;
with SDL.Video.Renderers.Makers;
with SDL.Video.Windows;

procedure TestTime is
   use type SDL.Events.Event_Types;
   use type SDL.Events.Keyboards.Scan_Codes;
   use type SDL.Init_Flags;
   use type SDL.Time.Time_Formats;

   Window_Width  : constant SDL.Positive_Dimension := 760;
   Window_Height : constant SDL.Positive_Dimension := 560;

   Escape_Scan_Code : constant SDL.Events.Keyboards.Scan_Codes :=
     SDL.Events.Keyboards.Value ("Escape");
   Home_Scan_Code   : constant SDL.Events.Keyboards.Scan_Codes :=
     SDL.Events.Keyboards.Value ("Home");

   Initialised : Boolean := False;
   Running     : Boolean := True;

   Window   : SDL.Video.Windows.Window;
   Renderer : SDL.Video.Renderers.Renderer;

   Calendar_Year  : Integer := 0;
   Calendar_Month : Integer := 0;

   function Trim (Item : in String) return String is
     (Ada.Strings.Fixed.Trim (Item, Ada.Strings.Both));

   procedure Require_SDL
     (Condition : in Boolean;
      Message   : in String) is
   begin
      if not Condition then
         raise Program_Error with Message & ": " & SDL.Error.Get;
      end if;
   end Require_SDL;

   function Month_Name (Value : in Integer) return String is
   begin
      case Value is
         when 1  => return "January";
         when 2  => return "February";
         when 3  => return "March";
         when 4  => return "April";
         when 5  => return "May";
         when 6  => return "June";
         when 7  => return "July";
         when 8  => return "August";
         when 9  => return "September";
         when 10 => return "October";
         when 11 => return "November";
         when 12 => return "December";
         when others => return "Unknown";
      end case;
   end Month_Name;

   function Two_Digits (Value : in Integer) return String is
   begin
      if Value < 10 then
         return "0" & Trim (Integer'Image (Value));
      end if;

      return Trim (Integer'Image (Value));
   end Two_Digits;

   function Date_Format_Image
     (Value : in SDL.Time.Date_Formats) return String is
   begin
      case Value is
         when SDL.Time.Year_Month_Day =>
            return "yyyy-mm-dd";
         when SDL.Time.Day_Month_Year =>
            return "dd.mm.yyyy";
         when SDL.Time.Month_Day_Year =>
            return "mm/dd/yyyy";
      end case;
   end Date_Format_Image;

   function Time_Format_Image
     (Value : in SDL.Time.Time_Formats) return String is
   begin
      case Value is
         when SDL.Time.Twenty_Four_Hour =>
            return "24-hour";
         when SDL.Time.Twelve_Hour =>
            return "12-hour";
      end case;
   end Time_Format_Image;

   function Date_Image
     (Value      : in SDL.Time.Date_Time;
      Formatting : in SDL.Time.Date_Formats) return String is
   begin
      case Formatting is
         when SDL.Time.Year_Month_Day =>
            return
              Trim (Integer'Image (Integer (Value.Year)))
              & "-"
              & Two_Digits (Integer (Value.Month))
              & "-"
              & Two_Digits (Integer (Value.Day));

         when SDL.Time.Day_Month_Year =>
            return
              Two_Digits (Integer (Value.Day))
              & "."
              & Two_Digits (Integer (Value.Month))
              & "."
              & Trim (Integer'Image (Integer (Value.Year)));

         when SDL.Time.Month_Day_Year =>
            return
              Two_Digits (Integer (Value.Month))
              & "/"
              & Two_Digits (Integer (Value.Day))
              & "/"
              & Trim (Integer'Image (Integer (Value.Year)));
      end case;
   end Date_Image;

   function Time_Image
     (Value      : in SDL.Time.Date_Time;
      Formatting : in SDL.Time.Time_Formats) return String is
      Hour : Integer := Integer (Value.Hour);
   begin
      if Formatting = SDL.Time.Twelve_Hour then
         if Hour = 0 then
            return
              "12"
              & ":"
              & Two_Digits (Integer (Value.Minute))
              & ":"
              & Two_Digits (Integer (Value.Second))
              & " AM";
         elsif Hour < 12 then
            return
              Two_Digits (Hour)
              & ":"
              & Two_Digits (Integer (Value.Minute))
              & ":"
              & Two_Digits (Integer (Value.Second))
              & " AM";
         elsif Hour = 12 then
            return
              "12"
              & ":"
              & Two_Digits (Integer (Value.Minute))
              & ":"
              & Two_Digits (Integer (Value.Second))
              & " PM";
         else
            Hour := Hour - 12;

            return
              Two_Digits (Hour)
              & ":"
              & Two_Digits (Integer (Value.Minute))
              & ":"
              & Two_Digits (Integer (Value.Second))
              & " PM";
         end if;
      end if;

      return
        Two_Digits (Hour)
        & ":"
        & Two_Digits (Integer (Value.Minute))
        & ":"
        & Two_Digits (Integer (Value.Second));
   end Time_Image;

   procedure Step_Month (Month_Offset : in Integer) is
   begin
      Calendar_Month := Calendar_Month + Month_Offset;

      while Calendar_Month < 1 loop
         Calendar_Month := Calendar_Month + 12;
         Calendar_Year := Calendar_Year - 1;
      end loop;

      while Calendar_Month > 12 loop
         Calendar_Month := Calendar_Month - 12;
         Calendar_Year := Calendar_Year + 1;
      end loop;
   end Step_Month;

   procedure Draw_Line
     (Y    : in Float;
      Text : in String) is
   begin
      SDL.Video.Renderers.Debug_Text (Renderer, 20.0, Y, Text);
   end Draw_Line;

   procedure Render is
      Preferences : SDL.Time.Date_Time_Locale_Preferences :=
        SDL.Time.Get_Locale_Preferences;
      Ticks       : constant SDL.Time.Times := SDL.Time.Current;
      Local_Time  : constant SDL.Time.Date_Time := SDL.Time.To_Date_Time (Ticks);
      UTC_Time    : constant SDL.Time.Date_Time :=
        SDL.Time.To_Date_Time (Ticks, Local_Time => False);
      Day_Labels  : constant array (Natural range 0 .. 6) of String (1 .. 3) :=
        ("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat");
      First_Day   : constant Natural :=
        SDL.Time.Day_Of_Week (Calendar_Year, Calendar_Month, 1);
      Day_Count   : constant Positive :=
        SDL.Time.Days_In_Month (Calendar_Year, Calendar_Month);
      Today_Year  : constant Integer := Integer (Local_Time.Year);
      Today_Month : constant Integer := Integer (Local_Time.Month);
      Today_Day   : constant Integer := Integer (Local_Time.Day);
      Base_X      : constant Float := 28.0;
      Base_Y      : constant Float := 150.0;
      Cell_Width  : constant Float := 100.0;
      Row_Step    : constant Float := 22.0;
   begin
      SDL.Video.Renderers.Set_Draw_Colour (Renderer, 0.08, 0.10, 0.16, 1.0);
      SDL.Video.Renderers.Clear (Renderer);

      SDL.Video.Renderers.Set_Draw_Colour (Renderer, 0.95, 0.95, 0.95, 1.0);
      Draw_Line (18.0, "test/testtime");
      Draw_Line
        (42.0,
         "Local: "
         & Date_Image (Local_Time, Preferences.Date_Format)
         & " "
         & Time_Image (Local_Time, Preferences.Time_Format)
         & " (UTC offset "
         & Trim (Integer'Image (Integer (Local_Time.UTC_Offset)))
         & ")");
      Draw_Line
        (64.0,
         "UTC:   "
         & Date_Image (UTC_Time, SDL.Time.Year_Month_Day)
         & " "
         & Time_Image (UTC_Time, SDL.Time.Twenty_Four_Hour));
      Draw_Line
        (86.0,
         "Preferences: "
         & Date_Format_Image (Preferences.Date_Format)
         & ", "
         & Time_Format_Image (Preferences.Time_Format));
      Draw_Line
        (108.0,
         "Left/Right changes month, Up/Down changes year, Home resets to current month.");

      Draw_Line
        (130.0,
         Month_Name (Calendar_Month) & " " & Trim (Integer'Image (Calendar_Year)));

      for Column in Day_Labels'Range loop
         SDL.Video.Renderers.Debug_Text
           (Renderer,
            Base_X + Float (Column) * Cell_Width,
            Base_Y,
            Day_Labels (Column));
      end loop;

      for Day in 1 .. Day_Count loop
         declare
            Slot   : constant Natural := First_Day + Natural (Day - 1);
            Column : constant Natural := Slot mod 7;
            Row    : constant Natural := Slot / 7;
            X      : constant Float := Base_X + Float (Column) * Cell_Width;
            Y      : constant Float := Base_Y + Row_Step * Float (Row + 1);
         begin
            if Calendar_Year = Today_Year
              and then Calendar_Month = Today_Month
              and then Day = Today_Day
            then
               SDL.Video.Renderers.Set_Draw_Colour (Renderer, 0.40, 1.00, 0.60, 1.0);
            else
               SDL.Video.Renderers.Set_Draw_Colour (Renderer, 0.95, 0.95, 0.95, 1.0);
            end if;

            SDL.Video.Renderers.Debug_Text
              (Renderer, X, Y, Trim (Integer'Image (Day)));
         end;
      end loop;

      SDL.Video.Renderers.Present (Renderer);
   exception
      when SDL.Time.Time_Error =>
         SDL.Video.Renderers.Set_Draw_Colour (Renderer, 0.20, 0.10, 0.10, 1.0);
         SDL.Video.Renderers.Clear (Renderer);
         SDL.Video.Renderers.Set_Draw_Colour (Renderer, 1.00, 0.85, 0.85, 1.0);
         Draw_Line (18.0, "test/testtime");
         Draw_Line (42.0, "Time query failed: " & SDL.Error.Get);
         SDL.Video.Renderers.Present (Renderer);
   end Render;

   procedure Handle_Events is
      Event : SDL.Events.Queue.Event;
   begin
      while SDL.Events.Queue.Poll (Event) loop
         case Event.Common.Event_Type is
            when SDL.Events.Quit =>
               Running := False;

            when SDL.Events.Keyboards.Key_Down =>
               declare
                  Scan_Code : constant SDL.Events.Keyboards.Scan_Codes :=
                    Event.Keyboard.Key_Sym.Scan_Code;
               begin
                  if Scan_Code = Escape_Scan_Code then
                     Running := False;
                  elsif Scan_Code = Home_Scan_Code then
                     declare
                        Local_Time : constant SDL.Time.Date_Time :=
                          SDL.Time.To_Date_Time (SDL.Time.Current);
                     begin
                        Calendar_Year := Integer (Local_Time.Year);
                        Calendar_Month := Integer (Local_Time.Month);
                     end;
                  elsif Scan_Code = SDL.Events.Keyboards.Scan_Code_Left then
                     Step_Month (-1);
                  elsif Scan_Code = SDL.Events.Keyboards.Scan_Code_Right then
                     Step_Month (1);
                  elsif Scan_Code = SDL.Events.Keyboards.Scan_Code_Up then
                     Step_Month (-12);
                  elsif Scan_Code = SDL.Events.Keyboards.Scan_Code_Down then
                     Step_Month (12);
                  end if;
               end;

            when others =>
               null;
         end case;
      end loop;
   end Handle_Events;
begin
   Require_SDL
     (SDL.Set_App_Metadata
        ("SDL Test Time",
         "1.0",
         "com.example.testtime"),
      "Unable to set application metadata");

   Require_SDL
     (SDL.Initialise (SDL.Enable_Video or SDL.Enable_Events),
      "Couldn't initialize SDL");
   Initialised := True;

   declare
      Local_Time : constant SDL.Time.Date_Time :=
        SDL.Time.To_Date_Time (SDL.Time.Current);
   begin
      Calendar_Year := Integer (Local_Time.Year);
      Calendar_Month := Integer (Local_Time.Month);
   end;

   SDL.Video.Renderers.Makers.Create
     (Window   => Window,
      Rend     => Renderer,
      Title    => "test/testtime",
      Position => SDL.Video.Windows.Centered_Window_Position,
      Size     => (Width => Window_Width, Height => Window_Height),
      Flags    => SDL.Video.Windows.Resizable);

   SDL.Video.Renderers.Set_Logical_Presentation
     (Self => Renderer,
      Size => (Width => Window_Width, Height => Window_Height),
      Mode => SDL.Video.Renderers.Letterbox_Presentation);

   while Running loop
      Handle_Events;
      Render;
      SDL.Timers.Wait_Delay (33);
   end loop;

   SDL.Video.Renderers.Finalize (Renderer);
   SDL.Video.Windows.Finalize (Window);
   SDL.Quit;
exception
   when others =>
      SDL.Video.Renderers.Finalize (Renderer);
      SDL.Video.Windows.Finalize (Window);
      if Initialised then
         SDL.Quit;
      end if;
      raise;
end TestTime;
