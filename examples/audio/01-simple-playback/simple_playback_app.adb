with Ada.Command_Line;
with Ada.Numerics;
with Ada.Numerics.Generic_Elementary_Functions;
with Ada.Unchecked_Conversion;
with Ada.Unchecked_Deallocation;

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
with SDL.Main;
with SDL.Video.Renderers;
with SDL.Video.Renderers.Makers;
with SDL.Video.Windows;

package body Simple_Playback_App is
   package C renames Interfaces.C;
   package CS renames Interfaces.C.Strings;
   package Math is new Ada.Numerics.Generic_Elementary_Functions (C.C_float);

   use type C.C_float;
   use type C.int;
   use type CS.chars_ptr;
   use type SDL.Init_Flags;
   use type SDL.Events.Event_Types;
   use type SDL.Main.App_Results;

   Window_Width  : constant SDL.Positive_Dimension := 640;
   Window_Height : constant SDL.Positive_Dimension := 480;
   Tone_Frequency   : constant Positive := 440;
   Tone_Sample_Rate : constant SDL.Audio.Sample_Rate := 8_000;
   Tone_Spec : constant SDL.Audio.Spec :=
     (Format    => SDL.Audio.Sample_Formats.Sample_Format_F32,
      Channels  => 1,
      Frequency => Tone_Sample_Rate);
   Minimum_Queued_Bytes : constant Natural :=
     (Natural (Tone_Sample_Rate) * SDL.Audio.Frame_Size (Tone_Spec)) / 2;
   Tau : constant C.C_float := 2.0 * C.C_float (Ada.Numerics.Pi);

   type Float_Sample_Array is array (Positive range <>) of aliased C.C_float with
     Convention => C;

   type State is record
      Window              : SDL.Video.Windows.Window;
      Renderer            : SDL.Video.Renderers.Renderer;
      Stream              : SDL.Audio.Streams.Stream;
      Current_Sine_Sample : Natural := 0;
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
   procedure Fill_Sine
     (Current_Sample : in out Natural;
      Buffer         : out Float_Sample_Array;
      Count          : in Positive);

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
      SDL.Audio.Streams.Close (App.Stream);
      SDL.Video.Renderers.Finalize (App.Renderer);
      SDL.Video.Windows.Finalize (App.Window);

      if App.SDL_Initialized then
         SDL.Quit;
         App.SDL_Initialized := False;
      end if;
   end Cleanup;

   procedure Fill_Sine
     (Current_Sample : in out Natural;
      Buffer         : out Float_Sample_Array;
      Count          : in Positive)
   is
   begin
      for Index in 1 .. Count loop
         declare
            Phase : constant C.C_float :=
              (C.C_float (Current_Sample) * C.C_float (Tone_Frequency))
              / C.C_float (Natural (Tone_Sample_Rate));
         begin
            Buffer (Buffer'First + Index - 1) := Math.Sin (Phase * Tau);
            Current_Sample := Current_Sample + 1;
         end;
      end loop;

      Current_Sample := Current_Sample mod Natural (Tone_Sample_Rate);

      if Count < Buffer'Length then
         for Index in Count + 1 .. Buffer'Length loop
            Buffer (Buffer'First + Index - 1) := 0.0;
         end loop;
      end if;
   end Fill_Sine;

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
           ("Example Audio Simple Playback",
            "1.0",
            "com.example.audio-simple-playback"),
         "Unable to set application metadata");

      Require_SDL
        (SDL.Initialise (SDL.Enable_Video or SDL.Enable_Audio),
         "Couldn't initialize SDL");
      App.SDL_Initialized := True;

      SDL.Video.Renderers.Makers.Create
        (Window   => App.Window,
         Rend     => App.Renderer,
         Title    => "examples/audio/simple-playback",
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
      if SDL.Audio.Streams.Queued_Bytes (App.Stream) < Minimum_Queued_Bytes then
         declare
            Samples : Float_Sample_Array (1 .. 512);
         begin
            Fill_Sine (App.Current_Sine_Sample, Samples, Samples'Length);
            SDL.Audio.Streams.Put
              (Self        => App.Stream,
               Data        => Samples'Address,
               Byte_Length => Samples'Length * SDL.Audio.Frame_Size (Tone_Spec));
         end;
      end if;

      SDL.Video.Renderers.Clear (App.Renderer);
      SDL.Video.Renderers.Present (App.Renderer);
      return SDL.Main.App_Continue;
   end App_Iterate;

   function App_Event
     (App_State : in System.Address;
      Event     : access SDL.Events.Events.Events) return SDL.Main.App_Results
   is
      pragma Unreferenced (App_State);
   begin
      if Event = null then
         return SDL.Main.App_Continue;
      end if;

      if Event.Common.Event_Type = SDL.Events.Quit then
         return SDL.Main.App_Success;
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
              "simple_playback exited with status"
              & Integer'Image (Integer (Exit_Code));
         end;
      end if;

      Free_Arguments (Args);
   exception
      when others =>
         Free_Arguments (Args);
         raise;
   end Run;
end Simple_Playback_App;
