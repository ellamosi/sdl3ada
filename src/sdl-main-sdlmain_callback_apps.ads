with SDL.Events.Events;

generic
   type Application_State is limited private;
   with function Initialize
     (Self : in out Application_State;
      Args : in SDL.Main.Argument_Lists) return SDL.Main.App_Results;
   with function Iterate
     (Self : in out Application_State) return SDL.Main.App_Results;
   with function Handle_Event
     (Self  : in out Application_State;
      Event : in SDL.Events.Events.Events) return SDL.Main.App_Results;
   with procedure Finalize
     (Self   : in out Application_State;
      Result : in SDL.Main.App_Results);
package SDL.Main.SDLMain_Callback_Apps is
   pragma Elaborate_Body;
end SDL.Main.SDLMain_Callback_Apps;
