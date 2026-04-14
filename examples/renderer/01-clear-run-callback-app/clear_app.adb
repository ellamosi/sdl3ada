with Ada.Numerics;
with Ada.Numerics.Elementary_Functions;
with Ada.Unchecked_Conversion;
with Ada.Unchecked_Deallocation;

with Interfaces.C;
with Interfaces.C.Strings;
with System;

with SDL;
with SDL.Error;
with SDL.Events;
with SDL.Events.Events;
with SDL.Main;
with SDL.Timers;
with SDL.Video.Renderers;
with SDL.Video.Renderers.Makers;
with SDL.Video.Windows;

package body Clear_App is
   use type SDL.Events.Event_Types;
   use type SDL.Main.App_Results;

   Window_Width  : constant SDL.Positive_Dimension := 640;
   Window_Height : constant SDL.Positive_Dimension := 480;
   Colour_Phase  : constant Float := Float (2.0 * Ada.Numerics.Pi / 3.0);

   type State is record
      Window          : SDL.Video.Windows.Window;
      Renderer        : SDL.Video.Renderers.Renderer;
      SDL_Initialized : Boolean := False;
   end record;

   type State_Access is access all State;

   procedure Free_State is new Ada.Unchecked_Deallocation (State, State_Access);

   function To_State is new Ada.Unchecked_Conversion (System.Address, State_Access);
   function To_Address is new Ada.Unchecked_Conversion (State_Access, System.Address);

   procedure Require_SDL (Condition : in Boolean; Message : in String);
   procedure Cleanup (App : in out State);

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
           ("Example Renderer Clear Run Callback App",
            "1.0",
            "com.example.renderer-clear-run-callback-app"),
         "Unable to set application metadata");

      Require_SDL
        (SDL.Initialise (SDL.Enable_Video),
         "Couldn't initialize SDL");
      App.SDL_Initialized := True;

      SDL.Video.Renderers.Makers.Create
        (Window   => App.Window,
         Rend     => App.Renderer,
         Title    => "examples/renderer/clear-run-callback-app",
         Position => SDL.Video.Windows.Centered_Window_Position,
         Size     => (Width => Window_Width, Height => Window_Height),
         Flags    => SDL.Video.Windows.Resizable);

      SDL.Video.Renderers.Set_Logical_Presentation
        (Self => App.Renderer,
         Size => (Width => Window_Width, Height => Window_Height),
         Mode => SDL.Video.Renderers.Letterbox_Presentation);

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
      use Ada.Numerics.Elementary_Functions;

      App   : constant State_Access := To_State (App_State);
      Now   : constant Float := Float (SDL.Timers.Ticks) / 1000.0;
      Red   : constant Float := 0.5 + (0.5 * Sin (Now));
      Green : constant Float := 0.5 + (0.5 * Sin (Now + Colour_Phase));
      Blue  : constant Float := 0.5 + (0.5 * Sin (Now + (2.0 * Colour_Phase)));
   begin
      SDL.Video.Renderers.Set_Draw_Colour
        (App.Renderer, Red, Green, Blue, 1.0);
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
      if Event /= null and then Event.Common.Event_Type = SDL.Events.Quit then
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

   procedure Run is
   begin
      SDL.Main.Run_Callback_App
        (App_Init  => App_Init'Access,
         App_Iter  => App_Iterate'Access,
         App_Event => App_Event'Access,
         App_Quit  => App_Quit'Access);
   end Run;
end Clear_App;
