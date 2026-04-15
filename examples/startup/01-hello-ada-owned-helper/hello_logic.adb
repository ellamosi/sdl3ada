with SDL;
with SDL.Error;
with SDL.Events;
with SDL.Timers;
with SDL.Video.Windows;
with SDL.Video.Windows.Makers;

package body Hello_Logic is
   use type SDL.Events.Event_Types;

   Window_Width  : constant SDL.Positive_Dimension := 480;
   Window_Height : constant SDL.Positive_Dimension := 320;

   Hello_Window    : SDL.Video.Windows.Window;
   SDL_Initialized : Boolean := False;

   procedure Cleanup is
   begin
      if not SDL.Video.Windows.Is_Null (Hello_Window) then
         SDL.Video.Windows.Finalize (Hello_Window);
      end if;

      if SDL_Initialized then
         SDL.Quit;
         SDL_Initialized := False;
      end if;
   end Cleanup;

   function Initialize
     (Args : in SDL.Main.Argument_Lists) return SDL.Main.App_Results
   is
      pragma Unreferenced (Args);
   begin
      if not SDL.Initialise (SDL.Enable_Video) then
         raise SDL.Main.Main_Error with
           "Couldn't initialize SDL: " & SDL.Error.Get;
      end if;
      SDL_Initialized := True;

      SDL.Video.Windows.Makers.Create
        (Win      => Hello_Window,
         Title    => "Hello, SDL3Ada",
         Position => SDL.Video.Windows.Centered_Window_Position,
         Size     => (Width => Window_Width, Height => Window_Height));

      return SDL.Main.App_Continue;
   exception
      when others =>
         Cleanup;
         raise;
   end Initialize;

   function Iterate return SDL.Main.App_Results is
   begin
      SDL.Timers.Wait_Delay (16);
      return SDL.Main.App_Continue;
   end Iterate;

   function Handle_Event
     (Event : in SDL.Events.Events.Events) return SDL.Main.App_Results
   is
   begin
      if Event.Common.Event_Type = SDL.Events.Quit then
         return SDL.Main.App_Success;
      end if;

      return SDL.Main.App_Continue;
   end Handle_Event;

   procedure Finalize
     (Result : in SDL.Main.App_Results)
   is
      pragma Unreferenced (Result);
   begin
      Cleanup;
   end Finalize;
end Hello_Logic;
