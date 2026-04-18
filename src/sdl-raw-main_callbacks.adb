with SDL.Main;

package body SDL.Raw.Main_Callbacks is
   pragma Warnings (Off, "all instances of");

   function SDL_AppInit
     (App_State : access System.Address;
      ArgC      : in Interfaces.C.int;
      ArgV      : in System.Address)
      return SDL.Main.App_Results
   with
     Convention    => C,
     Export        => True,
     External_Name => "SDL_AppInit";

   function SDL_AppIterate
     (App_State : in System.Address) return SDL.Main.App_Results
   with
     Convention    => C,
     Export        => True,
     External_Name => "SDL_AppIterate";

   function SDL_AppEvent
     (App_State : in System.Address;
      Event     : access SDL.Events.Events.Events) return SDL.Main.App_Results
   with
     Convention    => C,
     Export        => True,
     External_Name => "SDL_AppEvent";

   procedure SDL_AppQuit
     (App_State : in System.Address;
      Result    : in SDL.Main.App_Results)
   with
     Convention    => C,
     Export        => True,
     External_Name => "SDL_AppQuit";

   pragma Warnings (On, "all instances of");

   function SDL_AppInit
     (App_State : access System.Address;
      ArgC      : in Interfaces.C.int;
      ArgV      : in System.Address)
      return SDL.Main.App_Results is
     (App_Init (App_State, ArgC, ArgV));

   function SDL_AppIterate
     (App_State : in System.Address) return SDL.Main.App_Results is
     (App_Iterate (App_State));

   function SDL_AppEvent
     (App_State : in System.Address;
      Event     : access SDL.Events.Events.Events) return SDL.Main.App_Results is
     (App_Event (App_State, Event));

   procedure SDL_AppQuit
     (App_State : in System.Address;
      Result    : in SDL.Main.App_Results) is
   begin
      App_Quit (App_State, Result);
   end SDL_AppQuit;
end SDL.Raw.Main_Callbacks;
