with Hello_Logic;
with SDL.Main;

procedure Hello is
begin
   SDL.Main.Run_Ada_Callback_App
     (App_Init  => Hello_Logic.Initialize'Access,
      App_Iter  => Hello_Logic.Iterate'Access,
      App_Event => Hello_Logic.Handle_Event'Access,
      App_Quit  => Hello_Logic.Finalize'Access);
end Hello;
