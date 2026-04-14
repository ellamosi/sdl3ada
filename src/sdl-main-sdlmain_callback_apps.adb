with Ada.Unchecked_Conversion;

with Interfaces.C;
with Interfaces.C.Strings;
with System;

with SDL.Main.Internal_Callback_Bindings;

package body SDL.Main.SDLMain_Callback_Apps is
   package C renames Interfaces.C;
   package CS renames Interfaces.C.Strings;

   type Argument_Vector_Access is access all CS.chars_ptr_array;

   function To_Argument_Vector is new Ada.Unchecked_Conversion
     (System.Address, Argument_Vector_Access);

   package Bindings is new SDL.Main.Internal_Callback_Bindings
     (Application_State => Application_State,
      Initialize        => Initialize,
      Iterate           => Iterate,
      Handle_Event      => Handle_Event,
      Finalize          => Finalize);

   pragma Warnings (Off, "all instances of");

   function SDL_AppInit
     (App_State : access System.Address;
      ArgC      : in C.int;
      ArgV      : in System.Address) return SDL.Main.App_Results
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
      ArgC      : in C.int;
      ArgV      : in System.Address) return SDL.Main.App_Results is
     (Bindings.App_Init (App_State, ArgC, To_Argument_Vector (ArgV)));

   function SDL_AppIterate
     (App_State : in System.Address) return SDL.Main.App_Results is
     (Bindings.App_Iterate (App_State));

   function SDL_AppEvent
     (App_State : in System.Address;
      Event     : access SDL.Events.Events.Events) return SDL.Main.App_Results is
     (Bindings.App_Event (App_State, Event));

   procedure SDL_AppQuit
     (App_State : in System.Address;
      Result    : in SDL.Main.App_Results) is
   begin
      Bindings.App_Quit (App_State, Result);
   end SDL_AppQuit;
end SDL.Main.SDLMain_Callback_Apps;
