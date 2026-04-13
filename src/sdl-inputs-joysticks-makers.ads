package SDL.Inputs.Joysticks.Makers is
   function Create (Device : in Devices) return Joystick;

   procedure Create
     (Device       : in Devices;
      Actual_Stick : out Joystick);
end SDL.Inputs.Joysticks.Makers;
