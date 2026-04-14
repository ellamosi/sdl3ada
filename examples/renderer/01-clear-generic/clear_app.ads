with SDL.Main.Callback_Apps;

with Clear_Logic;

package Clear_App is new SDL.Main.Callback_Apps
  (Application_State => Clear_Logic.State,
   Initialize        => Clear_Logic.Initialize,
   Iterate           => Clear_Logic.Iterate,
   Handle_Event      => Clear_Logic.Handle_Event,
   Finalize          => Clear_Logic.Finalize);
