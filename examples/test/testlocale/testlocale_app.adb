with Ada.Command_Line;
with Ada.Strings.Fixed;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Unchecked_Conversion;
with Ada.Unchecked_Deallocation;

with Interfaces.C;
with Interfaces.C.Strings;
with System;

with SDL;
with SDL.Error;
with SDL.Events;
with SDL.Events.Events;
with SDL.Locale;
with SDL.Main;
with SDL.Time;
with SDL.Video.Renderers;
with SDL.Video.Renderers.Makers;
with SDL.Video.Windows;

package body TestLocale_App is
   package C renames Interfaces.C;
   package CS renames Interfaces.C.Strings;
   package US renames Ada.Strings.Unbounded;

   use type C.int;
   use type CS.chars_ptr;
   use type SDL.Events.Event_Types;
   use type SDL.Main.App_Results;

   Window_Width     : constant SDL.Positive_Dimension := 640;
   Window_Height    : constant SDL.Positive_Dimension := 480;
   Line_Step        : constant Float := 12.0;
   Max_Locale_Lines : constant Positive := 18;

   type Locale_Line_List is array (Positive range 1 .. Max_Locale_Lines) of
     US.Unbounded_String;

   type State is record
      Window              : SDL.Video.Windows.Window;
      Renderer            : SDL.Video.Renderers.Renderer;
      Locale_Lines        : Locale_Line_List :=
        [others => US.Null_Unbounded_String];
      Header_Line         : US.Unbounded_String := US.Null_Unbounded_String;
      Date_Format_Line    : US.Unbounded_String := US.Null_Unbounded_String;
      Time_Format_Line    : US.Unbounded_String := US.Null_Unbounded_String;
      Status_Line         : US.Unbounded_String := US.Null_Unbounded_String;
      Footer_Line         : US.Unbounded_String := US.Null_Unbounded_String;
      Locale_Total        : Natural := 0;
      Visible_Line_Count  : Natural := 0;
      Locale_Change_Count : Natural := 0;
      SDL_Initialized     : Boolean := False;
   end record;

   type State_Access is access all State;
   type Argument_Vector_Access is access CS.chars_ptr_array;

   procedure Free_State is new Ada.Unchecked_Deallocation (State, State_Access);
   procedure Free_Argument_Vector is new Ada.Unchecked_Deallocation
     (CS.chars_ptr_array, Argument_Vector_Access);

   function To_State is new Ada.Unchecked_Conversion (System.Address, State_Access);
   function To_Address is new Ada.Unchecked_Conversion (State_Access, System.Address);

   procedure Require_SDL (Condition : in Boolean; Message : in String);
   procedure Cleanup (App : in out State);
   function Trim (Item : in String) return String;
   function Locale_Image (Item : in SDL.Locale.Locale) return String;
   function Date_Format_Image
     (Value : in SDL.Time.Date_Formats) return String;
   function Time_Format_Image
     (Value : in SDL.Time.Time_Formats) return String;
   procedure Log_Locales (Locales : in SDL.Locale.Locale_List);
   procedure Refresh_Locale_View (App : in out State);

   function App_Init
     (App_State : access System.Address;
      ArgC      : in C.int;
      ArgV      : access CS.chars_ptr_array) return SDL.Main.App_Results
   with Convention => C;

   function App_Iterate
     (App_State : in System.Address) return SDL.Main.App_Results
   with Convention => C;

   function App_Event
     (App_State : in System.Address;
      Event     : access SDL.Events.Events.Events) return SDL.Main.App_Results
   with Convention => C;

   procedure App_Quit
     (App_State : in System.Address;
      Result    : in SDL.Main.App_Results)
   with Convention => C;

   procedure Require_SDL (Condition : in Boolean; Message : in String) is
   begin
      if not Condition then
         raise Program_Error with Message & ": " & SDL.Error.Get;
      end if;
   end Require_SDL;

   procedure Cleanup (App : in out State) is
   begin
      SDL.Video.Renderers.Finalize (App.Renderer);
      SDL.Video.Windows.Finalize (App.Window);

      if App.SDL_Initialized then
         SDL.Quit;
         App.SDL_Initialized := False;
      end if;
   end Cleanup;

   function Trim (Item : in String) return String is
     (Ada.Strings.Fixed.Trim (Item, Ada.Strings.Both));

   function Locale_Image (Item : in SDL.Locale.Locale) return String is
      Language : constant String := US.To_String (Item.Language);
      Country  : constant String := US.To_String (Item.Country);
   begin
      if Country = "" then
         return Language;
      end if;

      return Language & "_" & Country;
   end Locale_Image;

   function Date_Format_Image
     (Value : in SDL.Time.Date_Formats) return String is
   begin
      case Value is
         when SDL.Time.Year_Month_Day =>
            return "year-month-day";
         when SDL.Time.Day_Month_Year =>
            return "day-month-year";
         when SDL.Time.Month_Day_Year =>
            return "month-day-year";
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

   procedure Log_Locales (Locales : in SDL.Locale.Locale_List) is
   begin
      Ada.Text_IO.Put_Line ("Locales, in order of preference:");

      if Locales'Length = 0 then
         Ada.Text_IO.Put_Line (" - (none reported)");
      else
         for Item of Locales loop
            Ada.Text_IO.Put_Line (" - " & Locale_Image (Item));
         end loop;
      end if;

      Ada.Text_IO.Put_Line
        (Trim (Natural'Image (Locales'Length)) & " locales seen.");
   end Log_Locales;

   procedure Refresh_Locale_View (App : in out State) is
   begin
      for Index in App.Locale_Lines'Range loop
         App.Locale_Lines (Index) := US.Null_Unbounded_String;
      end loop;

      App.Visible_Line_Count := 0;
      App.Header_Line := US.To_Unbounded_String ("Preferred locales:");
      App.Footer_Line :=
        US.To_Unbounded_String
          ("Change your system locale preferences to trigger SDL_EVENT_LOCALE_CHANGED.");
      App.Status_Line :=
        US.To_Unbounded_String
          ("Locale change events: "
           & Trim (Natural'Image (App.Locale_Change_Count)));

      declare
         Preferences : constant SDL.Time.Date_Time_Locale_Preferences :=
           SDL.Time.Get_Locale_Preferences;
      begin
         App.Date_Format_Line :=
           US.To_Unbounded_String
             ("Date format: " & Date_Format_Image (Preferences.Date_Format));
         App.Time_Format_Line :=
           US.To_Unbounded_String
             ("Time format: " & Time_Format_Image (Preferences.Time_Format));
      exception
         when SDL.Time.Time_Error =>
            App.Date_Format_Line :=
              US.To_Unbounded_String ("Date format: unavailable");
            App.Time_Format_Line :=
              US.To_Unbounded_String ("Time format: unavailable");
      end;

      declare
         Locales : constant SDL.Locale.Locale_List := SDL.Locale.Preferred;
         Visible : constant Natural :=
           Natural'Min (Locales'Length, Max_Locale_Lines);
      begin
         App.Locale_Total := Locales'Length;
         App.Visible_Line_Count := Visible;

         Log_Locales (Locales);

         if Locales'Length = 0 then
            App.Visible_Line_Count := 1;
            App.Locale_Lines (1) :=
              US.To_Unbounded_String (" - (none reported)");
         else
            for Index in 1 .. Visible loop
               App.Locale_Lines (Index) :=
                 US.To_Unbounded_String
                   (" - " & Locale_Image (Locales (Locales'First + Index - 1)));
            end loop;
         end if;

         App.Window.Set_Title
           ("test/testlocale ("
            & Trim (Natural'Image (Locales'Length))
            & " locales)");
      exception
         when SDL.Locale.Locale_Error =>
            declare
               Message : constant String := SDL.Error.Get;
            begin
               App.Locale_Total := 0;
               App.Visible_Line_Count := 1;
               App.Locale_Lines (1) :=
                 US.To_Unbounded_String
                   (" - locale query failed: "
                    & (if Message /= "" then Message else "unknown error"));
               App.Window.Set_Title ("test/testlocale (error)");
               Ada.Text_IO.Put_Line
                 ("Couldn't determine locales: "
                  & (if Message /= "" then Message else "unknown error"));
            end;
      end;
   end Refresh_Locale_View;

   function App_Init
     (App_State : access System.Address;
      ArgC      : in C.int;
      ArgV      : access CS.chars_ptr_array) return SDL.Main.App_Results
   is
      pragma Unreferenced (ArgC, ArgV);

      App : State_Access := new State;
   begin
      App_State.all := System.Null_Address;

      Require_SDL
        (SDL.Set_App_Metadata
           ("SDL Test Locale",
            "1.0",
            "com.example.testlocale"),
         "Unable to set application metadata");

      Require_SDL
        (SDL.Initialise (SDL.Enable_Video),
         "Couldn't initialize SDL");
      App.SDL_Initialized := True;

      SDL.Video.Renderers.Makers.Create
        (Window   => App.Window,
         Rend     => App.Renderer,
         Title    => "test/testlocale",
         Position => SDL.Video.Windows.Centered_Window_Position,
         Size     => (Width => Window_Width, Height => Window_Height),
         Flags    => SDL.Video.Windows.Resizable);

      SDL.Video.Renderers.Set_Logical_Presentation
        (Self => App.Renderer,
         Size => (Width => Window_Width, Height => Window_Height),
         Mode => SDL.Video.Renderers.Letterbox_Presentation);

      Refresh_Locale_View (App.all);

      App_State.all := To_Address (App);
      return SDL.Main.App_Continue;
   exception
      when others =>
         Cleanup (App.all);
         Free_State (App);
         raise;
   end App_Init;

   function App_Iterate
     (App_State : in System.Address) return SDL.Main.App_Results
   is
      App : constant State_Access := To_State (App_State);
      Y   : Float := 20.0;
   begin
      SDL.Video.Renderers.Set_Draw_Colour
        (App.Renderer, 19.0 / 255.0, 24.0 / 255.0, 38.0 / 255.0, 1.0);
      SDL.Video.Renderers.Clear (App.Renderer);

      SDL.Video.Renderers.Set_Draw_Colour
        (App.Renderer, 1.0, 1.0, 1.0, 1.0);
      SDL.Video.Renderers.Debug_Text
        (App.Renderer, 20.0, Y, US.To_String (App.Header_Line));
      Y := Y + Line_Step;

      SDL.Video.Renderers.Set_Draw_Colour
        (App.Renderer, 0.7, 0.85, 1.0, 1.0);
      SDL.Video.Renderers.Debug_Text
        (App.Renderer, 20.0, Y, US.To_String (App.Date_Format_Line));
      Y := Y + Line_Step;
      SDL.Video.Renderers.Debug_Text
        (App.Renderer, 20.0, Y, US.To_String (App.Time_Format_Line));
      Y := Y + (Line_Step * 2.0);

      SDL.Video.Renderers.Set_Draw_Colour
        (App.Renderer, 1.0, 0.85, 0.4, 1.0);
      SDL.Video.Renderers.Debug_Text
        (App.Renderer, 20.0, Y, US.To_String (App.Status_Line));
      Y := Y + (Line_Step * 2.0);

      SDL.Video.Renderers.Set_Draw_Colour
        (App.Renderer, 0.75, 1.0, 0.75, 1.0);

      for Index in 1 .. App.Visible_Line_Count loop
         SDL.Video.Renderers.Debug_Text
           (App.Renderer, 20.0, Y, US.To_String (App.Locale_Lines (Index)));
         Y := Y + Line_Step;
      end loop;

      if App.Locale_Total > App.Visible_Line_Count then
         SDL.Video.Renderers.Set_Draw_Colour
           (App.Renderer, 0.85, 0.85, 0.85, 1.0);
         SDL.Video.Renderers.Debug_Text
           (App.Renderer,
            20.0,
            Y,
            " - ... and "
            & Trim (Natural'Image (App.Locale_Total - App.Visible_Line_Count))
            & " more");
      end if;

      SDL.Video.Renderers.Set_Draw_Colour
        (App.Renderer, 0.85, 0.85, 0.85, 1.0);
      SDL.Video.Renderers.Debug_Text
        (App.Renderer, 20.0, 440.0, US.To_String (App.Footer_Line));

      SDL.Video.Renderers.Present (App.Renderer);
      return SDL.Main.App_Continue;
   end App_Iterate;

   function App_Event
     (App_State : in System.Address;
      Event     : access SDL.Events.Events.Events) return SDL.Main.App_Results
   is
      App : constant State_Access := To_State (App_State);
   begin
      if Event = null then
         return SDL.Main.App_Continue;
      end if;

      if Event.Common.Event_Type = SDL.Events.Quit then
         return SDL.Main.App_Success;
      elsif Event.Common.Event_Type = SDL.Events.Locale_Changed then
         App.Locale_Change_Count := App.Locale_Change_Count + 1;
         Refresh_Locale_View (App.all);
      end if;

      return SDL.Main.App_Continue;
   end App_Event;

   procedure App_Quit
     (App_State : in System.Address;
      Result    : in SDL.Main.App_Results)
   is
      pragma Unreferenced (Result);

      App : State_Access := To_State (App_State);
   begin
      if App = null then
         return;
      end if;

      Cleanup (App.all);
      Free_State (App);
   end App_Quit;

   procedure Free_Arguments (Items : in out Argument_Vector_Access) is
   begin
      if Items = null then
         return;
      end if;

      for Index in Items'Range loop
         if Items (Index) /= CS.Null_Ptr then
            CS.Free (Items (Index));
            Items (Index) := CS.Null_Ptr;
         end if;
      end loop;

      Free_Argument_Vector (Items);
   end Free_Arguments;

   procedure Run is
      Arg_Count : constant Natural := Ada.Command_Line.Argument_Count + 1;
      Args      : Argument_Vector_Access := null;
      Exit_Code : C.int := 0;
   begin
      Args := new CS.chars_ptr_array (0 .. C.size_t (Arg_Count));

      for Index in Args'Range loop
         Args (Index) := CS.Null_Ptr;
      end loop;

      Args (0) := CS.New_String (Ada.Command_Line.Command_Name);
      for Index in 1 .. Ada.Command_Line.Argument_Count loop
         Args (C.size_t (Index)) :=
           CS.New_String (Ada.Command_Line.Argument (Index));
      end loop;

      Exit_Code :=
        SDL.Main.Enter_App_Main_Callbacks
          (ArgC      => C.int (Arg_Count),
           ArgV      => Args (Args'First)'Address,
           App_Init  => App_Init'Access,
           App_Iter  => App_Iterate'Access,
           App_Event => App_Event'Access,
           App_Quit  => App_Quit'Access);

      if Exit_Code /= 0 then
         declare
            Message : constant String := SDL.Error.Get;
         begin
            if Message /= "" then
               raise Program_Error with Message;
            end if;

            raise Program_Error with
              "testlocale exited with status" & Integer'Image (Integer (Exit_Code));
         end;
      end if;

      Free_Arguments (Args);
   exception
      when others =>
         Free_Arguments (Args);
         raise;
   end Run;
end TestLocale_App;
