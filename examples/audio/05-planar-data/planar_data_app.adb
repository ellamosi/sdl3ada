with Ada.Command_Line;
with Ada.Numerics;
with Ada.Numerics.Generic_Elementary_Functions;
with Ada.Unchecked_Conversion;
with Ada.Unchecked_Deallocation;

with Interfaces;
with Interfaces.C;
with Interfaces.C.Strings;
with System;

with SDL;
with SDL.Audio;
with SDL.Audio.Sample_Formats;
with SDL.Audio.Streams;
with SDL.Error;
with SDL.Events;
with SDL.Events.Events;
with SDL.Events.Mice;
with SDL.Main;
with SDL.Video.Rectangles;
with SDL.Video.Renderers;
with SDL.Video.Renderers.Makers;
with SDL.Video.Windows;

package body Planar_Data_App is
   package C renames Interfaces.C;
   package CS renames Interfaces.C.Strings;
   package Math is new Ada.Numerics.Generic_Elementary_Functions (Float);

   use type C.int;
   use type CS.chars_ptr;
   use type SDL.Init_Flags;
   use type SDL.Events.Event_Types;
   use type SDL.Events.Mice.Buttons;
   use type SDL.Main.App_Results;

   Window_Width  : constant SDL.Positive_Dimension := 640;
   Window_Height : constant SDL.Positive_Dimension := 480;
   Tone_Sample_Rate : constant SDL.Audio.Sample_Rate := 4_000;
   Tone_Spec : constant SDL.Audio.Spec :=
     (Format    => SDL.Audio.Sample_Formats.Sample_Format_U8,
      Channels  => 2,
      Frequency => Tone_Sample_Rate);
   Debug_Char_Size : constant Float :=
     Float (SDL.Video.Renderers.Debug_Text_Character_Size);

   Left_Button : constant SDL.Video.Rectangles.Float_Rectangle :=
     (X => 100.0, Y => 170.0, Width => 100.0, Height => 100.0);
   Right_Button : constant SDL.Video.Rectangles.Float_Rectangle :=
     (X => 440.0, Y => 170.0, Width => 100.0, Height => 100.0);

   type Unsigned_8_Array is array (Positive range <>) of aliased Interfaces.Unsigned_8 with
     Convention => C;

   function Make_Tone
     (Sample_Count : in Positive;
      Frequency    : in Positive) return Unsigned_8_Array;

   subtype Playing_State is Integer range -1 .. 1;

   type State is record
      Window          : SDL.Video.Windows.Window;
      Renderer        : SDL.Video.Renderers.Renderer;
      Stream          : SDL.Audio.Streams.Stream;
      Playing_Sound   : Playing_State := 0;
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
   function Centered_X
     (Text : in String;
      Area : in SDL.Video.Rectangles.Float_Rectangle) return Float;
   procedure Render_Button
     (App          : in out State;
      Rectangle    : in SDL.Video.Rectangles.Float_Rectangle;
      Label        : in String;
      Button_Value : in Playing_State);

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

   function Make_Tone
     (Sample_Count : in Positive;
      Frequency    : in Positive) return Unsigned_8_Array
   is
      Result : Unsigned_8_Array (1 .. Sample_Count);
      Tau    : constant Float := 2.0 * Ada.Numerics.Pi;
   begin
      for Index in Result'Range loop
         declare
            Position : constant Float :=
              Float (Index - Result'First) / Float (Natural (Tone_Sample_Rate));
            Envelope : constant Float :=
              1.0 - (Float (Index - Result'First) / Float (Sample_Count));
            Value : constant Integer :=
              Integer
                (128.0
                 + (96.0
                    * Envelope
                    * Math.Sin (Tau * Float (Frequency) * Position)));
         begin
            if Value < 0 then
               Result (Index) := 0;
            elsif Value > 255 then
               Result (Index) := 255;
            else
               Result (Index) := Interfaces.Unsigned_8 (Value);
            end if;
         end;
      end loop;

      return Result;
   end Make_Tone;

   Left_Tone  : constant Unsigned_8_Array := Make_Tone (1_870, 660);
   Right_Tone : constant Unsigned_8_Array := Make_Tone (1_777, 990);

   procedure Require_SDL (Condition : in Boolean; Message : in String) is
   begin
      if not Condition then
         raise Program_Error with Message & ": " & SDL.Error.Get;
      end if;
   end Require_SDL;

   procedure Cleanup (App : in out State) is
   begin
      SDL.Audio.Streams.Close (App.Stream);
      SDL.Video.Renderers.Finalize (App.Renderer);
      SDL.Video.Windows.Finalize (App.Window);

      if App.SDL_Initialized then
         SDL.Quit;
         App.SDL_Initialized := False;
      end if;
   end Cleanup;

   function Centered_X
     (Text : in String;
      Area : in SDL.Video.Rectangles.Float_Rectangle) return Float
   is
   begin
      return Area.X
        + ((Area.Width - (Debug_Char_Size * Float (Text'Length))) / 2.0);
   end Centered_X;

   procedure Render_Button
     (App          : in out State;
      Rectangle    : in SDL.Video.Rectangles.Float_Rectangle;
      Label        : in String;
      Button_Value : in Playing_State)
   is
      X : constant Float := Centered_X (Label, Rectangle);
      Y : constant Float :=
        Rectangle.Y + ((Rectangle.Height - Debug_Char_Size) / 2.0);
   begin
      if App.Playing_Sound = Button_Value then
         SDL.Video.Renderers.Set_Draw_Colour (App.Renderer, 0.0, 1.0, 0.0, 1.0);
      else
         SDL.Video.Renderers.Set_Draw_Colour (App.Renderer, 0.0, 0.0, 1.0, 1.0);
      end if;

      SDL.Video.Renderers.Fill (App.Renderer, Rectangle);
      SDL.Video.Renderers.Set_Draw_Colour (App.Renderer, 1.0, 1.0, 1.0, 1.0);
      SDL.Video.Renderers.Debug_Text (App.Renderer, X, Y, Label);
   end Render_Button;

   function App_Init
     (App_State : access System.Address;
      ArgC      : in C.int;
      ArgV      : access CS.chars_ptr_array) return SDL.Main.App_Results
   is
      pragma Unreferenced (ArgC, ArgV);

      App           : State_Access := new State;
      Opened_Spec   : SDL.Audio.Spec;
      Sample_Frames : Natural := 0;
   begin
      App_State.all := System.Null_Address;

      Require_SDL
        (SDL.Set_App_Metadata
           ("Example Audio Planar Data",
            "1.0",
            "com.example.audio-planar-data"),
         "Unable to set application metadata");

      Require_SDL
        (SDL.Initialise (SDL.Enable_Video or SDL.Enable_Audio),
         "Couldn't initialize SDL");
      App.SDL_Initialized := True;

      SDL.Video.Renderers.Makers.Create
        (Window   => App.Window,
         Rend     => App.Renderer,
         Title    => "examples/audio/planar-data",
         Position => SDL.Video.Windows.Centered_Window_Position,
         Size     => (Width => Window_Width, Height => Window_Height),
         Flags    => SDL.Video.Windows.Resizable);

      SDL.Video.Renderers.Set_Logical_Presentation
        (Self => App.Renderer,
         Size => (Width => Window_Width, Height => Window_Height),
         Mode => SDL.Video.Renderers.Letterbox_Presentation);

      SDL.Audio.Streams.Open
        (Self          => App.Stream,
         Device        => SDL.Audio.Default_Playback_Device,
         Application   => Tone_Spec,
         Output        => Opened_Spec,
         Sample_Frames => Sample_Frames);

      App_State.all := To_Address (App);
      SDL.Audio.Streams.Resume (App.Stream);
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
      if App.Playing_Sound /= 0
        and then SDL.Audio.Streams.Queued_Bytes (App.Stream) = 0
      then
         App.Playing_Sound := 0;
      end if;

      SDL.Video.Renderers.Set_Draw_Colour (App.Renderer, 0.0, 0.0, 0.0, 1.0);
      SDL.Video.Renderers.Clear (App.Renderer);

      Render_Button (App.all, Left_Button, "LEFT", -1);
      Render_Button (App.all, Right_Button, "RIGHT", 1);

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
      elsif Event.Common.Event_Type = SDL.Events.Mice.Button_Down
        and then Event.Mouse_Button.Button = SDL.Events.Mice.Left
        and then App.Playing_Sound = 0
      then
         declare
            Window_Point : constant SDL.Video.Rectangles.Float_Point :=
              (X => Float (Event.Mouse_Button.X),
               Y => Float (Event.Mouse_Button.Y));
            Render_Point : constant SDL.Video.Rectangles.Float_Point :=
              SDL.Video.Renderers.Window_Coordinates_To_Render
                (App.Renderer, Window_Point);
         begin
            if SDL.Video.Rectangles.Inside (Render_Point, Left_Button) then
               declare
                  Planes : constant SDL.Audio.Streams.Buffer_Pointers (1 .. 2) :=
                    (1 => Left_Tone'Address,
                     2 => System.Null_Address);
               begin
                  SDL.Audio.Streams.Put_Planar
                    (Self            => App.Stream,
                     Channel_Buffers => Planes,
                     Sample_Count    => Left_Tone'Length);
                  SDL.Audio.Streams.Flush (App.Stream);
                  App.Playing_Sound := -1;
               end;
            elsif SDL.Video.Rectangles.Inside (Render_Point, Right_Button) then
               declare
                  Planes : constant SDL.Audio.Streams.Buffer_Pointers (1 .. 2) :=
                    (1 => System.Null_Address,
                     2 => Right_Tone'Address);
               begin
                  SDL.Audio.Streams.Put_Planar
                    (Self            => App.Stream,
                     Channel_Buffers => Planes,
                     Sample_Count    => Right_Tone'Length);
                  SDL.Audio.Streams.Flush (App.Stream);
                  App.Playing_Sound := 1;
               end;
            end if;
         end;
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
              "planar_data exited with status"
              & Integer'Image (Integer (Exit_Code));
         end;
      end if;

      Free_Arguments (Args);
   exception
      when others =>
         Free_Arguments (Args);
         raise;
   end Run;
end Planar_Data_App;
