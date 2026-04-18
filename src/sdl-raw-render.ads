with Interfaces;
with Interfaces.C;
with System;

with SDL.Raw.Properties;

package SDL.Raw.Render is
   pragma Preelaborate;

   package C renames Interfaces.C;

   subtype Pixel_Format_Names is Interfaces.Unsigned_32;
   subtype Texture_Kind is C.int;

   function Create_Texture
     (Target     : in System.Address;
      Pixel      : in Pixel_Format_Names;
      Kind_Value : in Texture_Kind;
      Width      : in C.int;
      Height     : in C.int) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CreateTexture";

   function Create_Texture_From_Surface
     (Renderer : in System.Address;
      Surface  : in System.Address) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CreateTextureFromSurface";

   function Create_Texture_With_Properties
     (Renderer : in System.Address;
      Props    : in SDL.Raw.Properties.ID) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CreateTextureWithProperties";

   function Create_Renderer_With_Properties
     (Props : in SDL.Raw.Properties.ID) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CreateRendererWithProperties";

   function Create_Software_Renderer
     (Surface : in System.Address) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CreateSoftwareRenderer";

   function Create_GPU_Renderer
     (Device : in System.Address;
      Window : in System.Address) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CreateGPURenderer";
end SDL.Raw.Render;
