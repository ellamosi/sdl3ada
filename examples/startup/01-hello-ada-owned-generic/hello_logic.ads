with SDL.Main.Callback_Apps;

with SDL.Events.Events;
with SDL.Main;
with SDL.Video.Windows;

package Hello_Logic is
   type State is limited record
      Window          : SDL.Video.Windows.Window;
      SDL_Initialized : Boolean := False;
   end record;

   function Initialize
     (Self : in out State;
      Args : in SDL.Main.Argument_Lists) return SDL.Main.App_Results;

   function Iterate
     (Self : in out State) return SDL.Main.App_Results;

   function Handle_Event
     (Self  : in out State;
      Event : in SDL.Events.Events.Events) return SDL.Main.App_Results;

   procedure Finalize
     (Self   : in out State;
      Result : in SDL.Main.App_Results);

   package App is new SDL.Main.Callback_Apps
     (Application_State => State,
      Initialize        => Initialize,
      Iterate           => Iterate,
      Handle_Event      => Handle_Event,
      Finalize          => Finalize);

   procedure Run renames App.Run;
end Hello_Logic;
