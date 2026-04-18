with Interfaces;
with Interfaces.C;
with Interfaces.C.Extensions;
with System;

with SDL.Raw.Properties;

package SDL.Raw.Render is
   pragma Preelaborate;

   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;

   subtype Pixel_Format_Names is Interfaces.Unsigned_32;
   subtype Texture_Kind is C.int;
   subtype Texture_Scale_Mode is C.int;
   subtype Blend_Mode is Interfaces.Unsigned_32;
   subtype Colour_Component is Interfaces.Unsigned_8;
   subtype Texture_Pitch is C.int;

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

   function Get_Texture_Properties
     (Value : in System.Address) return SDL.Raw.Properties.ID
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetTextureProperties";

   function Lock_Texture
     (Value  : in System.Address;
      Area   : in System.Address;
      Target : out System.Address;
      Pitch  : out Texture_Pitch) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_LockTexture";

   function Lock_Texture_To_Surface
     (Value   : in System.Address;
      Area    : in System.Address;
      Surface : access System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_LockTextureToSurface";

   procedure Unlock_Texture (Value : in System.Address)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_UnlockTexture";

   function Update_Texture
     (Value  : in System.Address;
      Area   : in System.Address;
      Pixels : in System.Address;
      Pitch  : in Texture_Pitch) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_UpdateTexture";

   function Update_YUV_Texture
     (Value    : in System.Address;
      Area     : in System.Address;
      Y_Pixels : in System.Address;
      Y_Pitch  : in Texture_Pitch;
      U_Pixels : in System.Address;
      U_Pitch  : in Texture_Pitch;
      V_Pixels : in System.Address;
      V_Pitch  : in Texture_Pitch) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_UpdateYUVTexture";

   function Update_NV_Texture
     (Value     : in System.Address;
      Area      : in System.Address;
      Y_Pixels  : in System.Address;
      Y_Pitch   : in Texture_Pitch;
      UV_Pixels : in System.Address;
      UV_Pitch  : in Texture_Pitch) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_UpdateNVTexture";

   function Set_Texture_Palette
     (Value   : in System.Address;
      Palette : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetTexturePalette";

   function Get_Texture_Palette
     (Value : in System.Address) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetTexturePalette";

   function Set_Texture_Scale_Mode
     (Value : in System.Address;
      Scale : in Texture_Scale_Mode) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetTextureScaleMode";

   function Get_Texture_Scale_Mode
     (Value : in System.Address;
      Scale : access Texture_Scale_Mode) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetTextureScaleMode";

   function Get_Texture_Blend_Mode
     (Value : in System.Address;
      Mode  : access Blend_Mode) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetTextureBlendMode";

   function Set_Texture_Blend_Mode
     (Value : in System.Address;
      Mode  : in Blend_Mode) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetTextureBlendMode";

   function Get_Texture_Color_Mod
     (Value : in System.Address;
      Red   : access Colour_Component;
      Green : access Colour_Component;
      Blue  : access Colour_Component) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetTextureColorMod";

   function Get_Texture_Color_Mod_Float
     (Value : in System.Address;
      Red   : access C.C_float;
      Green : access C.C_float;
      Blue  : access C.C_float) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetTextureColorModFloat";

   function Set_Texture_Color_Mod
     (Value : in System.Address;
      Red   : in Colour_Component;
      Green : in Colour_Component;
      Blue  : in Colour_Component) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetTextureColorMod";

   function Set_Texture_Color_Mod_Float
     (Value : in System.Address;
      Red   : in C.C_float;
      Green : in C.C_float;
      Blue  : in C.C_float) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetTextureColorModFloat";

   function Get_Texture_Alpha_Mod
     (Value : in System.Address;
      Alpha : access Colour_Component) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetTextureAlphaMod";

   function Get_Texture_Alpha_Mod_Float
     (Value : in System.Address;
      Alpha : access C.C_float) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetTextureAlphaModFloat";

   function Set_Texture_Alpha_Mod
     (Value : in System.Address;
      Alpha : in Colour_Component) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetTextureAlphaMod";

   function Set_Texture_Alpha_Mod_Float
     (Value : in System.Address;
      Alpha : in C.C_float) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetTextureAlphaModFloat";

   function Get_Texture_Size
     (Value  : in System.Address;
      Width  : access C.C_float;
      Height : access C.C_float) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetTextureSize";

   procedure Destroy_Texture (Value : in System.Address)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_DestroyTexture";
end SDL.Raw.Render;
