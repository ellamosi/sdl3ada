with Interfaces.C;
with System;

with SDL.Raw.Main;

generic
   with function App_Init
     (App_State : access System.Address;
      ArgC      : in Interfaces.C.int;
      ArgV      : in System.Address)
      return SDL.Raw.Main.App_Results;
   with function App_Iterate
     (App_State : in System.Address) return SDL.Raw.Main.App_Results;
   with function App_Event
     (App_State : in System.Address;
      Event     : in System.Address) return SDL.Raw.Main.App_Results;
   with procedure App_Quit
     (App_State : in System.Address;
      Result    : in SDL.Raw.Main.App_Results);
package SDL.Raw.Main_Callbacks is
   pragma Elaborate_Body;
end SDL.Raw.Main_Callbacks;
