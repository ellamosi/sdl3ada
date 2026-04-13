with System;

with SDL.Error;
with SDL.Properties;
with SDL.Video.Surfaces.Makers;

package body SDL.Video.Textures.Makers is
   use type System.Address;

   SDL_PROP_TEXTURE_ACCESS_NUMBER : constant String := "SDL.texture.access";
   SDL_PROP_TEXTURE_FORMAT_NUMBER : constant String := "SDL.texture.format";
   SDL_PROP_TEXTURE_HEIGHT_NUMBER : constant String := "SDL.texture.height";
   SDL_PROP_TEXTURE_WIDTH_NUMBER  : constant String := "SDL.texture.width";

   function SDL_Create_Texture
     (Target     : in System.Address;
      Pixel      : in SDL.Video.Pixel_Formats.Pixel_Format_Names;
      Kind_Value : in SDL.Video.Textures.Kinds;
      Width      : in SDL.Dimension;
      Height     : in SDL.Dimension) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CreateTexture";

   function SDL_Create_Texture_From_Surface
     (Renderer : in System.Address;
      Surface  : in SDL.Video.Surfaces.Internal_Surface_Pointer) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CreateTextureFromSurface";

   function SDL_Create_Texture_With_Properties
     (Renderer : in System.Address;
      Props    : in SDL.Properties.Property_ID) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CreateTextureWithProperties";

   function Get_Internal_Surface
     (Self : in SDL.Video.Surfaces.Surface)
      return SDL.Video.Surfaces.Internal_Surface_Pointer
   with
     Import     => True,
     Convention => Ada;

   procedure Populate_Metadata
     (Tex : in out SDL.Video.Textures.Texture);

   procedure Populate_Metadata
     (Tex : in out SDL.Video.Textures.Texture)
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

   procedure Adopt
     (Tex      : in out SDL.Video.Textures.Texture;
      Internal : in System.Address;
      Owns     : in Boolean);

   procedure Adopt
     (Tex      : in out SDL.Video.Textures.Texture;
      Internal : in System.Address;
      Owns     : in Boolean)
   is
   begin
      if Internal = System.Null_Address then
         raise Texture_Error with SDL.Error.Get;
      end if;

      SDL.Video.Textures.Finalize (Tex);
      Tex.Internal := Internal;
      Tex.Owns := Owns;
      Tex.Locked := False;
      Populate_Metadata (Tex);
   end Adopt;

   procedure Create
     (Tex      : in out SDL.Video.Textures.Texture;
      Renderer : in SDL.Video.Renderers.Renderer;
      Format   : in SDL.Video.Pixel_Formats.Pixel_Format_Names;
      Kind     : in SDL.Video.Textures.Kinds;
      Size     : in SDL.Positive_Sizes)
   is
      Internal : System.Address;
   begin
      if SDL.Video.Renderers.Get_Internal (Renderer) = System.Null_Address then
         raise Texture_Error with "Invalid renderer";
      end if;

      Internal :=
        SDL_Create_Texture
          (Target     => SDL.Video.Renderers.Get_Internal (Renderer),
           Pixel      => Format,
           Kind_Value => Kind,
           Width      => Size.Width,
           Height     => Size.Height);

      Adopt (Tex, Internal, Owns => True);
      Tex.Size := SDL.Sizes'(Width => Size.Width, Height => Size.Height);
      Tex.Pixel_Format := Format;
      Tex.Kind := Kind;
   end Create;

   procedure Create
     (Tex      : in out SDL.Video.Textures.Texture;
      Renderer : in SDL.Video.Renderers.Renderer;
      Surface  : in SDL.Video.Surfaces.Surface)
   is
      Internal : System.Address;
   begin
      if SDL.Video.Renderers.Get_Internal (Renderer) = System.Null_Address then
         raise Texture_Error with "Invalid renderer";
      end if;

      Internal :=
        SDL_Create_Texture_From_Surface
          (SDL.Video.Renderers.Get_Internal (Renderer),
           Get_Internal_Surface (Surface));

      Adopt (Tex, Internal, Owns => True);
   end Create;

   procedure Create
     (Tex        : in out SDL.Video.Textures.Texture;
      Renderer   : in SDL.Video.Renderers.Renderer;
      Properties : in SDL.Properties.Property_Set)
   is
      Internal : System.Address;
   begin
      if SDL.Video.Renderers.Get_Internal (Renderer) = System.Null_Address then
         raise Texture_Error with "Invalid renderer";
      end if;

      Internal :=
        SDL_Create_Texture_With_Properties
          (SDL.Video.Renderers.Get_Internal (Renderer),
           SDL.Properties.Get_ID (Properties));

      Adopt (Tex, Internal, Owns => True);
   end Create;

   function Make_Texture_From_Pointer
     (Internal : in System.Address;
      Owns     : in Boolean := False) return SDL.Video.Textures.Texture
   is
   begin
      return Result : SDL.Video.Textures.Texture do
         if Internal /= System.Null_Address then
            Result.Internal := Internal;
            Result.Owns := Owns;
            Result.Locked := False;
            Populate_Metadata (Result);
         end if;
      end return;
   end Make_Texture_From_Pointer;
end SDL.Video.Textures.Makers;
