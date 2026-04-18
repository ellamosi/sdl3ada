with System;

package SDL.Video.Palettes.Internal is
   pragma Preelaborate;

   procedure Copy_From_Pointer
     (Value  : in System.Address;
      Result : out Palette);
end SDL.Video.Palettes.Internal;
