with SDL.Events.Events;
with SDL.Main;

package Hello_Logic is
   function Initialize
     (Args : in SDL.Main.Argument_Lists) return SDL.Main.App_Results;

   function Iterate return SDL.Main.App_Results;

   function Handle_Event
     (Event : in SDL.Events.Events.Events) return SDL.Main.App_Results;

   procedure Finalize
     (Result : in SDL.Main.App_Results);
end Hello_Logic;
