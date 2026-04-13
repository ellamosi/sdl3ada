package SDL.Inputs.Joysticks.Game_Controllers.Makers is
   function Create (Device : in Devices) return Game_Controller;

   procedure Create
     (Device            : in Devices;
      Actual_Controller : out Game_Controller);
end SDL.Inputs.Joysticks.Game_Controllers.Makers;
