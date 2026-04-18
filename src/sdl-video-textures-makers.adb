with Ada.Unchecked_Conversion;

with SDL.Error;
with SDL.Raw.Render;
with SDL.Video.Surfaces.Internal;
with SDL.Video.Textures.Internal;

package body SDL.Video.Textures.Makers is
   package Raw renames SDL.Raw.Render;
   package Surface_Internal renames SDL.Video.Surfaces.Internal;
   package Texture_Internal renames SDL.Video.Textures.Internal;

   use type System.Address;

   function To_Address is new Ada.Unchecked_Conversion
     (Source => SDL.Video.Surfaces.Internal_Surface_Pointer,
      Target => System.Address);

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
      Texture_Internal.Populate_Metadata (Tex);
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
        Raw.Create_Texture
          (Target     => SDL.Video.Renderers.Get_Internal (Renderer),
           Pixel      => Raw.Pixel_Format_Names (Format),
           Kind_Value => Raw.Texture_Kind (SDL.Video.Textures.Kinds'Pos (Kind)),
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
        Raw.Create_Texture_From_Surface
          (SDL.Video.Renderers.Get_Internal (Renderer),
           To_Address (Surface_Internal.Get_Internal (Surface)));

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
        Raw.Create_Texture_With_Properties
          (SDL.Video.Renderers.Get_Internal (Renderer),
           SDL.Properties.Get_ID (Properties));

      Adopt (Tex, Internal, Owns => True);
   end Create;
end SDL.Video.Textures.Makers;
