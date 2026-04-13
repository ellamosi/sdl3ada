with System;

with SDL.Properties;
with SDL.Video.Renderers;
with SDL.Video.Surfaces;

package SDL.Video.Textures.Makers is
   procedure Create
     (Tex      : in out SDL.Video.Textures.Texture;
      Renderer : in SDL.Video.Renderers.Renderer;
      Format   : in SDL.Video.Pixel_Formats.Pixel_Format_Names;
      Kind     : in SDL.Video.Textures.Kinds;
      Size     : in SDL.Positive_Sizes);

   procedure Create
     (Tex      : in out SDL.Video.Textures.Texture;
      Renderer : in SDL.Video.Renderers.Renderer;
      Surface  : in SDL.Video.Surfaces.Surface);

   procedure Create
     (Tex        : in out SDL.Video.Textures.Texture;
      Renderer   : in SDL.Video.Renderers.Renderer;
      Properties : in SDL.Properties.Property_Set);
private
   function Make_Texture_From_Pointer
     (Internal : in System.Address;
      Owns     : in Boolean := False) return SDL.Video.Textures.Texture
   with
     Export     => True,
     Convention => Ada,
     External_Name => "sdl_video_textures_makers__make_texture_from_pointer";
end SDL.Video.Textures.Makers;
