with SDL.Error;
with SDL.Raw.Gamepad;

package body SDL.Inputs.Joysticks.Game_Controllers.Makers is
   package Raw renames SDL.Raw.Gamepad;

   use type SDL.C_Pointers.Game_Controller_Pointer;

   function Create (Device : in Devices) return Game_Controller is
      Internal : constant SDL.C_Pointers.Game_Controller_Pointer :=
        Raw.Open_Gamepad (Raw.ID (Resolve_Device (Device)));
   begin
      if Internal = null then
         raise Game_Controller_Error with SDL.Error.Get;
      end if;

      return Result : constant Game_Controller :=
        (Ada.Finalization.Limited_Controlled with
           Internal => Internal,
           Owns     => True)
      do
         null;
      end return;
   end Create;

   procedure Create
     (Device            : in Devices;
      Actual_Controller : out Game_Controller)
   is
      Internal : constant SDL.C_Pointers.Game_Controller_Pointer :=
        Raw.Open_Gamepad (Raw.ID (Resolve_Device (Device)));
   begin
      if Internal = null then
         raise Game_Controller_Error with SDL.Error.Get;
      end if;

      Actual_Controller.Internal := Internal;
      Actual_Controller.Owns := True;
   end Create;
end SDL.Inputs.Joysticks.Game_Controllers.Makers;
