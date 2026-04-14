with Interfaces.C;
with Interfaces.C.Strings;
with System;

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
package SDL.Main.Internal_Callback_Bindings is
   pragma Elaborate_Body;

   package C renames Interfaces.C;
   package CS renames Interfaces.C.Strings;

   function App_Init
     (App_State : access System.Address;
      ArgC      : in C.int;
      ArgV      : access CS.chars_ptr_array) return SDL.Main.App_Results
   with Convention => C;

   function App_Iterate
     (App_State : in System.Address) return SDL.Main.App_Results
   with Convention => C;

   function App_Event
     (App_State : in System.Address;
      Event     : access SDL.Events.Events.Events) return SDL.Main.App_Results
   with Convention => C;

   procedure App_Quit
     (App_State : in System.Address;
      Result    : in SDL.Main.App_Results)
   with Convention => C;

   procedure Run;
private
   App_Init_Access  : constant SDL.Main.App_Init_Callback := App_Init'Access;
   App_Iter_Access  : constant SDL.Main.App_Iterate_Callback := App_Iterate'Access;
   App_Event_Access : constant SDL.Main.App_Event_Callback := App_Event'Access;
   App_Quit_Access  : constant SDL.Main.App_Quit_Callback := App_Quit'Access;
end SDL.Main.Internal_Callback_Bindings;
