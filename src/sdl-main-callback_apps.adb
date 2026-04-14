with SDL.Main.Internal_Callback_Bindings;

package body SDL.Main.Callback_Apps is
   package Bindings is new SDL.Main.Internal_Callback_Bindings
     (Application_State => Application_State,
      Initialize        => Initialize,
      Iterate           => Iterate,
      Handle_Event      => Handle_Event,
      Finalize          => Finalize);

   procedure Run renames Bindings.Run;
end SDL.Main.Callback_Apps;
