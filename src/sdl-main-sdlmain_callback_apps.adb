with Ada.Unchecked_Conversion;

with Interfaces.C;
with Interfaces.C.Strings;
with System;

with SDL.Main.Internal_Callback_Bindings;
with SDL.Raw.Main_Callbacks;

package body SDL.Main.SDLMain_Callback_Apps is
   package C renames Interfaces.C;
   package CS renames Interfaces.C.Strings;

   type Argument_Vector_Access is access all CS.chars_ptr_array;

   function To_Argument_Vector is new Ada.Unchecked_Conversion
     (System.Address, Argument_Vector_Access);

   function Raw_App_Init
     (App_State : access System.Address;
      ArgC      : in C.int;
      ArgV      : in System.Address) return SDL.Main.App_Results;

   package Bindings is new SDL.Main.Internal_Callback_Bindings
     (Application_State => Application_State,
      Initialize        => Initialize,
      Iterate           => Iterate,
      Handle_Event      => Handle_Event,
      Finalize          => Finalize);

   function Raw_App_Init
     (App_State : access System.Address;
      ArgC      : in C.int;
      ArgV      : in System.Address) return SDL.Main.App_Results is
     (Bindings.App_Init (App_State, ArgC, To_Argument_Vector (ArgV)));

   package Callback_Exports is new SDL.Raw.Main_Callbacks
     (App_Init    =>
        Raw_App_Init,
      App_Iterate => Bindings.App_Iterate,
      App_Event   => Bindings.App_Event,
      App_Quit    => Bindings.App_Quit);

   pragma Unreferenced (Callback_Exports);
end SDL.Main.SDLMain_Callback_Apps;
