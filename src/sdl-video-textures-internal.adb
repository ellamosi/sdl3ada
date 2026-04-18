with SDL.Properties;

package body SDL.Video.Textures.Internal is
   use type System.Address;

   SDL_PROP_TEXTURE_ACCESS_NUMBER : constant String := "SDL.texture.access";
   SDL_PROP_TEXTURE_FORMAT_NUMBER : constant String := "SDL.texture.format";
   SDL_PROP_TEXTURE_HEIGHT_NUMBER : constant String := "SDL.texture.height";
   SDL_PROP_TEXTURE_WIDTH_NUMBER  : constant String := "SDL.texture.width";

   procedure Populate_Metadata
     (Tex : in out Texture)
   is
      Props         : constant SDL.Properties.Property_Set :=
        SDL.Properties.Reference (SDL.Video.Textures.Get_Properties (Tex));
      Access_Number : constant SDL.Properties.Property_Numbers :=
        SDL.Properties.Get_Number (Props, SDL_PROP_TEXTURE_ACCESS_NUMBER, 0);
   begin
      Tex.Pixel_Format :=
        SDL.Video.Pixel_Formats.Pixel_Format_Names
          (SDL.Properties.Get_Number (Props, SDL_PROP_TEXTURE_FORMAT_NUMBER, 0));
      Tex.Size :=
        (Width  =>
           SDL.Dimension
             (SDL.Properties.Get_Number (Props, SDL_PROP_TEXTURE_WIDTH_NUMBER, 0)),
         Height =>
           SDL.Dimension
             (SDL.Properties.Get_Number (Props, SDL_PROP_TEXTURE_HEIGHT_NUMBER, 0)));

      case Integer (Access_Number) is
         when 0 =>
            Tex.Kind := SDL.Video.Textures.Static;
         when 1 =>
            Tex.Kind := SDL.Video.Textures.Streaming;
         when 2 =>
            Tex.Kind := SDL.Video.Textures.Target;
         when others =>
            Tex.Kind := SDL.Video.Textures.Static;
      end case;
   end Populate_Metadata;

   function Make_From_Pointer
     (Value : in System.Address;
      Owns  : in Boolean := False) return Texture
   is
   begin
      return Result : Texture do
         if Value /= System.Null_Address then
            Result.Internal := Value;
            Result.Owns := Owns;
            Result.Locked := False;
            Populate_Metadata (Result);
         end if;
      end return;
   end Make_From_Pointer;
end SDL.Video.Textures.Internal;
