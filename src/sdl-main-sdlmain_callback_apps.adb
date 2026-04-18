with Ada.Unchecked_Conversion;

with Interfaces.C;
with Interfaces.C.Strings;
with System;

with SDL.Main.Internal_Callback_Bindings;
with SDL.Raw.Main;
with SDL.Raw.Main_Callbacks;

package body SDL.Main.SDLMain_Callback_Apps is
   package C renames Interfaces.C;
   package CS renames Interfaces.C.Strings;

   type Argument_Vector_Access is access all CS.chars_ptr_array;
   type Event_Access is access all SDL.Events.Events.Events;

   function To_Argument_Vector is new Ada.Unchecked_Conversion
     (System.Address, Argument_Vector_Access);
   function To_Event_Access is new Ada.Unchecked_Conversion
     (System.Address, Event_Access);

   function Raw_App_Init
     (App_State : access System.Address;
      ArgC      : in C.int;
      ArgV      : in System.Address) return SDL.Raw.Main.App_Results;
   function Raw_App_Iterate
     (App_State : in System.Address) return SDL.Raw.Main.App_Results;
   function Raw_App_Event
     (App_State : in System.Address;
      Event     : in System.Address) return SDL.Raw.Main.App_Results;
   procedure Raw_App_Quit
     (App_State : in System.Address;
      Result    : in SDL.Raw.Main.App_Results);

   package Bindings is new SDL.Main.Internal_Callback_Bindings
     (Application_State => Application_State,
      Initialize        => Initialize,
      Iterate           => Iterate,
      Handle_Event      => Handle_Event,
      Finalize          => Finalize);

   function Raw_App_Init
     (App_State : access System.Address;
      ArgC      : in C.int;
      ArgV      : in System.Address) return SDL.Raw.Main.App_Results is
     (SDL.Raw.Main.App_Results
        (Bindings.App_Init (App_State, ArgC, To_Argument_Vector (ArgV))));

   function Raw_App_Iterate
     (App_State : in System.Address) return SDL.Raw.Main.App_Results is
     (SDL.Raw.Main.App_Results (Bindings.App_Iterate (App_State)));

   function Raw_App_Event
     (App_State : in System.Address;
      Event     : in System.Address) return SDL.Raw.Main.App_Results is
     (SDL.Raw.Main.App_Results
        (Bindings.App_Event (App_State, To_Event_Access (Event))));

   procedure Raw_App_Quit
     (App_State : in System.Address;
      Result    : in SDL.Raw.Main.App_Results) is
   begin
      Bindings.App_Quit (App_State, SDL.Main.App_Results (Result));
   end Raw_App_Quit;

   package Callback_Exports is new SDL.Raw.Main_Callbacks
     (App_Init    =>
        Raw_App_Init,
      App_Iterate => Raw_App_Iterate,
      App_Event   => Raw_App_Event,
      App_Quit    => Raw_App_Quit);

   pragma Unreferenced (Callback_Exports);
end SDL.Main.SDLMain_Callback_Apps;
