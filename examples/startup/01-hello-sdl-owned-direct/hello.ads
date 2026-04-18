with Interfaces.C;
with System;

with SDL.Events.Events;
with SDL.Main;

package Hello is
   package C renames Interfaces.C;

   function App_Init
     (App_State : access System.Address;
      ArgC      : in C.int;
      ArgV      : in System.Address)
      return SDL.Main.App_Results
   with
     Convention    => C,
     Export        => True,
     External_Name => "SDL_AppInit";

   function App_Iterate
     (App_State : in System.Address) return SDL.Main.App_Results
   with
     Convention    => C,
     Export        => True,
     External_Name => "SDL_AppIterate";

   function App_Event
     (App_State : in System.Address;
      Event     : access SDL.Events.Events.Events) return SDL.Main.App_Results
   with
     Convention    => C,
     Export        => True,
     External_Name => "SDL_AppEvent";

   procedure App_Quit
     (App_State : in System.Address;
      Result    : in SDL.Main.App_Results)
   with
     Convention    => C,
     Export        => True,
     External_Name => "SDL_AppQuit";
end Hello;
