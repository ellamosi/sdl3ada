with System;

package SDL.Video.Textures.Internal is
   procedure Populate_Metadata
     (Tex : in out Texture);

   function Make_From_Pointer
     (Value : in System.Address;
      Owns  : in Boolean := False) return Texture;
end SDL.Video.Textures.Internal;
