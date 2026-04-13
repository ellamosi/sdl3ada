with SDL.Error;

package body SDL.Inputs.Joysticks.Makers is
   use type SDL.C_Pointers.Joystick_Pointer;

   function SDL_Open_Joystick
     (Device : in Instances) return SDL.C_Pointers.Joystick_Pointer with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_OpenJoystick";

   function Create (Device : in Devices) return Joystick is
      Internal : constant SDL.C_Pointers.Joystick_Pointer :=
        SDL_Open_Joystick (Resolve_Device (Device));
   begin
      if Internal = null then
         raise Joystick_Error with SDL.Error.Get;
      end if;

      return Result : constant Joystick :=
        (Ada.Finalization.Limited_Controlled with
           Internal => Internal,
           Owns     => True)
      do
         null;
      end return;
   end Create;

   procedure Create
     (Device       : in Devices;
      Actual_Stick : out Joystick)
   is
      Internal : constant SDL.C_Pointers.Joystick_Pointer :=
        SDL_Open_Joystick (Resolve_Device (Device));
   begin
      if Internal = null then
         raise Joystick_Error with SDL.Error.Get;
      end if;

      Actual_Stick.Internal := Internal;
      Actual_Stick.Owns := True;
   end Create;
end SDL.Inputs.Joysticks.Makers;
