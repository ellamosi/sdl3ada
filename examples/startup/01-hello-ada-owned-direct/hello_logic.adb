with System;

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

   function App_Init
     (App_State : access System.Address;
      ArgC      : in C.int;
      ArgV      : access CS.chars_ptr_array) return SDL.Main.App_Results
   is
      pragma Unreferenced (ArgC, ArgV);
   begin
      if App_State /= null then
         App_State.all := System.Null_Address;
      end if;

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
   end App_Init;

   function App_Iterate
     (App_State : in System.Address) return SDL.Main.App_Results
   is
      pragma Unreferenced (App_State);
   begin
      SDL.Timers.Wait_Delay (16);
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
      pragma Unreferenced (App_State, Result);
   begin
      Cleanup;
   end App_Quit;
end Hello_Logic;
