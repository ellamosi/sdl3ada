with Ada.Numerics;
with Ada.Numerics.Elementary_Functions;

with SDL;
with SDL.Error;
with SDL.Events;
with SDL.Timers;
with SDL.Video.Renderers;
with SDL.Video.Renderers.Makers;
with SDL.Video.Windows;

package body Clear_Logic is
   use type SDL.Events.Event_Types;

   Window_Width  : constant SDL.Positive_Dimension := 640;
   Window_Height : constant SDL.Positive_Dimension := 480;
   Colour_Phase  : constant Float := Float (2.0 * Ada.Numerics.Pi / 3.0);

   procedure Require_SDL (Condition : in Boolean; Message : in String);

   procedure Require_SDL (Condition : in Boolean; Message : in String) is
   begin
      if not Condition then
         raise Program_Error with Message & ": " & SDL.Error.Get;
      end if;
   end Require_SDL;

   function Initialize
     (Self : in out State;
      Args : in SDL.Main.Argument_Lists) return SDL.Main.App_Results
   is
      pragma Unreferenced (Args);
   begin
      Require_SDL
        (SDL.Set_App_Metadata
           ("Example Renderer Clear Generic",
            "1.0",
            "com.example.renderer-clear-generic"),
         "Unable to set application metadata");

      Require_SDL
        (SDL.Initialise (SDL.Enable_Video),
         "Couldn't initialize SDL");
      Self.SDL_Initialized := True;

      SDL.Video.Renderers.Makers.Create
        (Window   => Self.Window,
         Rend     => Self.Renderer,
         Title    => "examples/renderer/clear-generic",
         Position => SDL.Video.Windows.Centered_Window_Position,
         Size     => (Width => Window_Width, Height => Window_Height),
         Flags    => SDL.Video.Windows.Resizable);

      SDL.Video.Renderers.Set_Logical_Presentation
        (Self => Self.Renderer,
         Size => (Width => Window_Width, Height => Window_Height),
         Mode => SDL.Video.Renderers.Letterbox_Presentation);

      return SDL.Main.App_Continue;
   end Initialize;

   function Iterate
     (Self : in out State) return SDL.Main.App_Results
   is
      use Ada.Numerics.Elementary_Functions;

      Now   : constant Float := Float (SDL.Timers.Ticks) / 1000.0;
      Red   : constant Float := 0.5 + (0.5 * Sin (Now));
      Green : constant Float := 0.5 + (0.5 * Sin (Now + Colour_Phase));
      Blue  : constant Float := 0.5 + (0.5 * Sin (Now + (2.0 * Colour_Phase)));
   begin
      SDL.Video.Renderers.Set_Draw_Colour
        (Self.Renderer, Red, Green, Blue, 1.0);
      SDL.Video.Renderers.Clear (Self.Renderer);
      SDL.Video.Renderers.Present (Self.Renderer);
      return SDL.Main.App_Continue;
   end Iterate;

   function Handle_Event
     (Self  : in out State;
      Event : in SDL.Events.Events.Events) return SDL.Main.App_Results
   is
      pragma Unreferenced (Self);
   begin
      if Event.Common.Event_Type = SDL.Events.Quit then
         return SDL.Main.App_Success;
      end if;

      return SDL.Main.App_Continue;
   end Handle_Event;

   procedure Finalize
     (Self   : in out State;
      Result : in SDL.Main.App_Results)
   is
      pragma Unreferenced (Result);
   begin
      SDL.Video.Renderers.Finalize (Self.Renderer);
      SDL.Video.Windows.Finalize (Self.Window);

      if Self.SDL_Initialized then
         SDL.Quit;
         Self.SDL_Initialized := False;
      end if;
   end Finalize;
end Clear_Logic;
