with Ada.Characters.Latin_1;
with Ada.Command_Line;
with Ada.Strings.Fixed;
with Ada.Strings.Unbounded;
with Ada.Unchecked_Conversion;
with Ada.Unchecked_Deallocation;

with Interfaces.C;
with Interfaces.C.Strings;
with System;

with SDL;
with SDL.Clipboard;
with SDL.Error;
with SDL.Events;
with SDL.Events.Queue;
with SDL.Events.Mice;
with SDL.Main;
with SDL.Time;
with SDL.Video.Rectangles;
with SDL.Video.Renderers;
with SDL.Video.Renderers.Makers;
with SDL.Video.Windows;

package body Clipboard_App is
   package C renames Interfaces.C;
   package CS renames Interfaces.C.Strings;
   package US renames Ada.Strings.Unbounded;

   use type C.int;
   use type CS.chars_ptr;
   use type SDL.Events.Event_Types;
   use type SDL.Main.App_Results;
   use type SDL.Events.Mice.Buttons;

   Window_Width  : constant SDL.Positive_Dimension := 640;
   Window_Height : constant SDL.Positive_Dimension := 480;
   Debug_Char_Size : constant Float :=
     Float (SDL.Video.Renderers.Debug_Text_Character_Size);
   Copy_Button_Text  : constant String := "Click here to copy!";
   Paste_Button_Text : constant String := "Click here to paste!";

   Current_Time_Rectangle : constant SDL.Video.Rectangles.Float_Rectangle :=
     (X      => 30.0,
      Y      => 10.0,
      Width  => 390.0,
      Height => Debug_Char_Size + 10.0);

   Copy_Button_Rectangle : constant SDL.Video.Rectangles.Float_Rectangle :=
     (X      => Current_Time_Rectangle.X + Current_Time_Rectangle.Width + 30.0,
      Y      => Current_Time_Rectangle.Y,
      Width  => (Debug_Char_Size * Float (Copy_Button_Text'Length)) + 10.0,
      Height => Current_Time_Rectangle.Height);

   Paste_Text_Rectangle : constant SDL.Video.Rectangles.Float_Rectangle :=
     (X      => 10.0,
      Y      => Current_Time_Rectangle.Y + Current_Time_Rectangle.Height + 10.0,
      Width  => 620.0,
      Height =>
        (Float (Window_Height)
           - (Current_Time_Rectangle.Y + Current_Time_Rectangle.Height + 10.0)
           - Copy_Button_Rectangle.Height)
        - 20.0);

   Paste_Button_Rectangle : constant SDL.Video.Rectangles.Float_Rectangle :=
     (X      =>
        (Float (Window_Width)
           - ((Debug_Char_Size * Float (Paste_Button_Text'Length)) + 10.0))
        / 2.0,
      Y      => Paste_Text_Rectangle.Y + Paste_Text_Rectangle.Height + 10.0,
      Width  => (Debug_Char_Size * Float (Paste_Button_Text'Length)) + 10.0,
      Height => Copy_Button_Rectangle.Height);

   type State is record
      Window          : SDL.Video.Windows.Window;
      Renderer        : SDL.Video.Renderers.Renderer;
      Current_Time    : US.Unbounded_String := US.Null_Unbounded_String;
      Pasted_Text     : US.Unbounded_String := US.Null_Unbounded_String;
      Copy_Pressed    : Boolean := False;
      Paste_Pressed   : Boolean := False;
      SDL_Initialized : Boolean := False;
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
   function Two_Digits (Value : in Natural) return String;
   function Month_Name (Month : in Integer) return String;
   function Day_Name (Day : in Integer) return String;
   function Current_Time_Image return String;
   procedure Update_Current_Time (App : in out State);
   function Event_Point
     (App   : in State;
      Event : in SDL.Events.Mice.Button_Events)
      return SDL.Video.Rectangles.Float_Point;
   procedure Render_Pasted_Text (App : in out State);

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
      Event     : access SDL.Events.Queue.Event) return SDL.Main.App_Results
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

   function Two_Digits (Value : in Natural) return String is
   begin
      if Value < 10 then
         return "0" & Trim (Natural'Image (Value));
      end if;

      return Trim (Natural'Image (Value));
   end Two_Digits;

   function Month_Name (Month : in Integer) return String is
   begin
      case Month is
         when 1 =>
            return "January";
         when 2 =>
            return "February";
         when 3 =>
            return "March";
         when 4 =>
            return "April";
         when 5 =>
            return "May";
         when 6 =>
            return "June";
         when 7 =>
            return "July";
         when 8 =>
            return "August";
         when 9 =>
            return "September";
         when 10 =>
            return "October";
         when 11 =>
            return "November";
         when 12 =>
            return "December";
         when others =>
            return "Unknown";
      end case;
   end Month_Name;

   function Day_Name (Day : in Integer) return String is
   begin
      case Day is
         when 0 =>
            return "Sunday";
         when 1 =>
            return "Monday";
         when 2 =>
            return "Tuesday";
         when 3 =>
            return "Wednesday";
         when 4 =>
            return "Thursday";
         when 5 =>
            return "Friday";
         when 6 =>
            return "Saturday";
         when others =>
            return "Unknown";
      end case;
   end Day_Name;

   function Current_Time_Image return String is
      Ticks : constant SDL.Time.Times := SDL.Time.Current;
      DT    : constant SDL.Time.Date_Time := SDL.Time.To_Date_Time (Ticks);
   begin
      return Day_Name (Integer (DT.Day_Of_Week))
        & ", "
        & Month_Name (Integer (DT.Month))
        & " "
        & Trim (Integer'Image (Integer (DT.Day)))
        & ", "
        & Trim (Integer'Image (Integer (DT.Year)))
        & "   "
        & Two_Digits (Natural (DT.Hour))
        & ":"
        & Two_Digits (Natural (DT.Minute))
        & ":"
        & Two_Digits (Natural (DT.Second));
   exception
      when SDL.Time.Time_Error =>
         return "(Don't know the current time, sorry.)";
   end Current_Time_Image;

   procedure Update_Current_Time (App : in out State) is
   begin
      App.Current_Time := US.To_Unbounded_String (Current_Time_Image);
   end Update_Current_Time;

   function Event_Point
     (App   : in State;
      Event : in SDL.Events.Mice.Button_Events)
      return SDL.Video.Rectangles.Float_Point
   is
   begin
      return SDL.Video.Renderers.Window_Coordinates_To_Render
        (App.Renderer, (X => Float (Event.X), Y => Float (Event.Y)));
   end Event_Point;

   procedure Render_Pasted_Text (App : in out State) is
      Text  : constant String := US.To_String (App.Pasted_Text);
      X     : constant Float := Paste_Text_Rectangle.X + 5.0;
      Width : constant Float := Paste_Text_Rectangle.Width - 10.0;
      Limit : constant Natural :=
        Natural (Integer (Width / Debug_Char_Size));
      Y     : Float := Paste_Text_Rectangle.Y + 5.0;
      Start : Positive := Text'First;
   begin
      if Text'Length = 0 then
         return;
      end if;

      while Start <= Text'Last loop
         exit when
           (Paste_Text_Rectangle.Y + Paste_Text_Rectangle.Height - Y)
             < Debug_Char_Size;

         declare
            Newline : constant Natural :=
              Ada.Strings.Fixed.Index
                (Text (Start .. Text'Last),
                 String'(1 => Ada.Characters.Latin_1.LF));
            Raw_End : Natural :=
              (if Newline = 0 then Text'Last else Newline - 1);
         begin
            if Raw_End >= Start and then Text (Raw_End) = Ada.Characters.Latin_1.CR then
               Raw_End := Raw_End - 1;
            end if;

            declare
               Last : constant Natural :=
                 Natural'Min (Raw_End, Start + Limit - 1);
            begin
               if Last >= Start then
                  SDL.Video.Renderers.Debug_Text
                    (App.Renderer, X, Y, Text (Start .. Last));
               end if;
            end;

            exit when Newline = 0;

            Start := Newline + 1;
            Y := Y + Debug_Char_Size + 2.0;
         end;
      end loop;
   end Render_Pasted_Text;

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
           ("Example Misc Clipboard",
            "1.0",
            "com.example.misc-clipboard"),
         "Unable to set application metadata");

      Require_SDL
        (SDL.Initialise (SDL.Enable_Video),
         "Couldn't initialize SDL");
      App.SDL_Initialized := True;

      SDL.Video.Renderers.Makers.Create
        (Window   => App.Window,
         Rend     => App.Renderer,
         Title    => "examples/misc/clipboard",
         Position => SDL.Video.Windows.Centered_Window_Position,
         Size     => (Width => Window_Width, Height => Window_Height),
         Flags    => SDL.Video.Windows.Resizable);

      SDL.Video.Renderers.Set_Logical_Presentation
        (Self => App.Renderer,
         Size => (Width => Window_Width, Height => Window_Height),
         Mode => SDL.Video.Renderers.Letterbox_Presentation);

      Update_Current_Time (App.all);

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
   begin
      Update_Current_Time (App.all);

      declare
         Current_Text : constant String := US.To_String (App.Current_Time);
      begin
         SDL.Video.Renderers.Set_Draw_Colour
           (App.Renderer, 0.0, 0.0, 0.0, 1.0);
         SDL.Video.Renderers.Clear (App.Renderer);

         SDL.Video.Renderers.Set_Draw_Colour
           (App.Renderer, 0.0, 0.0, 1.0, 1.0);
         SDL.Video.Renderers.Fill (App.Renderer, Current_Time_Rectangle);
         SDL.Video.Renderers.Set_Draw_Colour
           (App.Renderer, 1.0, 1.0, 1.0, 1.0);
         SDL.Video.Renderers.Draw (App.Renderer, Current_Time_Rectangle);

         SDL.Video.Renderers.Set_Draw_Colour
           (App.Renderer, 1.0, 1.0, 0.0, 1.0);
         SDL.Video.Renderers.Debug_Text
           (App.Renderer,
            Current_Time_Rectangle.X
              + ((Current_Time_Rectangle.Width
                    - (Debug_Char_Size * Float (Current_Text'Length)))
                   / 2.0),
            Current_Time_Rectangle.Y + 5.0,
            Current_Text);
      end;

      if App.Copy_Pressed then
         SDL.Video.Renderers.Set_Draw_Colour
           (App.Renderer, 0.0, 1.0, 0.0, 1.0);
      else
         SDL.Video.Renderers.Set_Draw_Colour
           (App.Renderer, 1.0, 0.0, 0.0, 1.0);
      end if;

      SDL.Video.Renderers.Fill (App.Renderer, Copy_Button_Rectangle);
      SDL.Video.Renderers.Set_Draw_Colour
        (App.Renderer, 1.0, 1.0, 1.0, 1.0);
      SDL.Video.Renderers.Draw (App.Renderer, Copy_Button_Rectangle);
      SDL.Video.Renderers.Debug_Text
        (App.Renderer,
         Copy_Button_Rectangle.X + 5.0,
         Copy_Button_Rectangle.Y + 5.0,
         Copy_Button_Text);

      SDL.Video.Renderers.Set_Draw_Colour
        (App.Renderer, 0.0, 53.0 / 255.0, 25.0 / 255.0, 1.0);
      SDL.Video.Renderers.Fill (App.Renderer, Paste_Text_Rectangle);
      SDL.Video.Renderers.Set_Draw_Colour
        (App.Renderer, 1.0, 1.0, 1.0, 1.0);
      SDL.Video.Renderers.Draw (App.Renderer, Paste_Text_Rectangle);

      SDL.Video.Renderers.Set_Draw_Colour
        (App.Renderer, 0.0, 219.0 / 255.0, 107.0 / 255.0, 1.0);
      Render_Pasted_Text (App.all);

      if App.Paste_Pressed then
         SDL.Video.Renderers.Set_Draw_Colour
           (App.Renderer, 0.0, 1.0, 0.0, 1.0);
      else
         SDL.Video.Renderers.Set_Draw_Colour
           (App.Renderer, 1.0, 0.0, 0.0, 1.0);
      end if;

      SDL.Video.Renderers.Fill (App.Renderer, Paste_Button_Rectangle);
      SDL.Video.Renderers.Set_Draw_Colour
        (App.Renderer, 1.0, 1.0, 1.0, 1.0);
      SDL.Video.Renderers.Draw (App.Renderer, Paste_Button_Rectangle);
      SDL.Video.Renderers.Debug_Text
        (App.Renderer,
         Paste_Button_Rectangle.X + 5.0,
         Paste_Button_Rectangle.Y + 5.0,
         Paste_Button_Text);

      SDL.Video.Renderers.Present (App.Renderer);
      return SDL.Main.App_Continue;
   end App_Iterate;

   function App_Event
     (App_State : in System.Address;
      Event     : access SDL.Events.Queue.Event) return SDL.Main.App_Results
   is
      App : constant State_Access := To_State (App_State);
   begin
      if Event = null then
         return SDL.Main.App_Continue;
      end if;

      if Event.Common.Event_Type = SDL.Events.Quit then
         return SDL.Main.App_Success;
      elsif Event.Common.Event_Type = SDL.Events.Mice.Button_Down then
         if Event.Mouse_Button.Button = SDL.Events.Mice.Left then
            declare
               Point : constant SDL.Video.Rectangles.Float_Point :=
                 Event_Point (App.all, Event.Mouse_Button);
            begin
               App.Copy_Pressed :=
                 SDL.Video.Rectangles.Inside (Point, Copy_Button_Rectangle);
               App.Paste_Pressed :=
                 SDL.Video.Rectangles.Inside (Point, Paste_Button_Rectangle);
            end;
         end if;
      elsif Event.Common.Event_Type = SDL.Events.Mice.Button_Up then
         if Event.Mouse_Button.Button = SDL.Events.Mice.Left then
            declare
               Point : constant SDL.Video.Rectangles.Float_Point :=
                 Event_Point (App.all, Event.Mouse_Button);
            begin
               if App.Copy_Pressed
                 and then SDL.Video.Rectangles.Inside
                   (Point, Copy_Button_Rectangle)
               then
                  SDL.Clipboard.Set (US.To_String (App.Current_Time));
               elsif App.Paste_Pressed
                 and then SDL.Video.Rectangles.Inside
                   (Point, Paste_Button_Rectangle)
               then
                  if SDL.Clipboard.Has_Text then
                     App.Pasted_Text :=
                       US.To_Unbounded_String (SDL.Clipboard.Get);
                  else
                     App.Pasted_Text := US.Null_Unbounded_String;
                  end if;
               end if;

               App.Copy_Pressed := False;
               App.Paste_Pressed := False;
            end;
         end if;
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
              "clipboard exited with status" & Integer'Image (Integer (Exit_Code));
         end;
      end if;

      Free_Arguments (Args);
   exception
      when others =>
         Free_Arguments (Args);
         raise;
   end Run;
end Clipboard_App;
