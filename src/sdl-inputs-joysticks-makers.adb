with Ada.Unchecked_Conversion;
with System;

with SDL.Error;
with SDL.Raw.Joystick;

package body SDL.Inputs.Joysticks.Makers is
   package Raw renames SDL.Raw.Joystick;

   use type SDL.C_Pointers.Joystick_Pointer;

   function To_Pointer is new Ada.Unchecked_Conversion
     (Source => System.Address,
      Target => SDL.C_Pointers.Joystick_Pointer);

   function Create (Device : in Devices) return Joystick is
      Internal : constant SDL.C_Pointers.Joystick_Pointer :=
        To_Pointer (Raw.Open_Joystick (Raw.ID (Resolve_Device (Device))));
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
        To_Pointer (Raw.Open_Joystick (Raw.ID (Resolve_Device (Device))));
   begin
      if Internal = null then
         raise Joystick_Error with SDL.Error.Get;
      end if;

      Actual_Stick.Internal := Internal;
      Actual_Stick.Owns := True;
   end Create;
end SDL.Inputs.Joysticks.Makers;
