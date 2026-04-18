with Interfaces.C;
with Interfaces.C.Strings;
with System;

with SDL.Events.Events;
with SDL.Main;

generic
   with function App_Init
     (App_State : access System.Address;
      ArgC      : in Interfaces.C.int;
      ArgV      : in System.Address)
      return SDL.Main.App_Results;
   with function App_Iterate
     (App_State : in System.Address) return SDL.Main.App_Results;
   with function App_Event
     (App_State : in System.Address;
      Event     : access SDL.Events.Events.Events) return SDL.Main.App_Results;
   with procedure App_Quit
     (App_State : in System.Address;
      Result    : in SDL.Main.App_Results);
package SDL.Raw.Main_Callbacks is
   pragma Elaborate_Body;
end SDL.Raw.Main_Callbacks;
