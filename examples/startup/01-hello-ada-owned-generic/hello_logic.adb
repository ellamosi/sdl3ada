with SDL;
with SDL.Error;
with SDL.Events;
with SDL.Main;
with SDL.Timers;
with SDL.Video.Windows;
with SDL.Video.Windows.Makers;

package body Hello_Logic is
   use type SDL.Events.Event_Types;

   Window_Width  : constant SDL.Positive_Dimension := 480;
   Window_Height : constant SDL.Positive_Dimension := 320;

   function Initialize
     (Self : in out State;
      Args : in SDL.Main.Argument_Lists) return SDL.Main.App_Results
   is
      pragma Unreferenced (Args);
   begin
      if not SDL.Initialise (SDL.Enable_Video) then
         raise SDL.Main.Main_Error with
           "Couldn't initialize SDL: " & SDL.Error.Get;
      end if;
      Self.SDL_Initialized := True;

      SDL.Video.Windows.Makers.Create
        (Win      => Self.Window,
         Title    => "Hello, SDL3Ada",
         Position => SDL.Video.Windows.Centered_Window_Position,
         Size     => (Width => Window_Width, Height => Window_Height));

      return SDL.Main.App_Continue;
   end Initialize;

   function Iterate
     (Self : in out State) return SDL.Main.App_Results
   is
      pragma Unreferenced (Self);
   begin
      SDL.Timers.Wait_Delay (16);
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
      if not SDL.Video.Windows.Is_Null (Self.Window) then
         SDL.Video.Windows.Finalize (Self.Window);
      end if;

      if Self.SDL_Initialized then
         SDL.Quit;
         Self.SDL_Initialized := False;
      end if;
   end Finalize;
end Hello_Logic;
