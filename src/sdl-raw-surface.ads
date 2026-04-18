with Interfaces;
with Interfaces.C;
with Interfaces.C.Extensions;
with System;

with SDL.Raw.Properties;

package SDL.Raw.Surface is
   pragma Preelaborate;

   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;

   subtype Pixel_Format_Name is Interfaces.Unsigned_32;
   subtype Colour_Space is Interfaces.Unsigned_32;
   subtype Blend_Mode is Interfaces.Unsigned_32;
   subtype Colour_Component is Interfaces.Unsigned_8;
   subtype Scale_Mode is C.int;
   subtype Flip_Mode is C.int;

   function Load_Surface
     (Name : in C.char_array) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_LoadSurface";

   function Load_Surface_IO
     (Source   : in System.Address;
      Close_IO : in CE.bool) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_LoadSurface_IO";

   function Load_BMP
     (Name : in C.char_array) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_LoadBMP";

   function Load_BMP_IO
     (Source   : in System.Address;
      Close_IO : in CE.bool) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_LoadBMP_IO";

   function Load_PNG
     (Name : in C.char_array) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_LoadPNG";

   function Load_PNG_IO
     (Source   : in System.Address;
      Close_IO : in CE.bool) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_LoadPNG_IO";

   function Create_Surface
     (Width  : in C.int;
      Height : in C.int;
      Format : in Pixel_Format_Name) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CreateSurface";

   function Create_Surface_From
     (Width  : in C.int;
      Height : in C.int;
      Format : in Pixel_Format_Name;
      Pixels : in System.Address;
      Pitch  : in C.int) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CreateSurfaceFrom";

   function Convert_Surface
     (Source : in System.Address;
      Format : in Pixel_Format_Name) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ConvertSurface";

   function Get_Surface_Properties
     (Self : in System.Address) return SDL.Raw.Properties.ID
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetSurfaceProperties";

   function Blit_Surface
     (Source      : in System.Address;
      Source_Area : in System.Address;
      Target      : in System.Address;
      Target_Area : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_BlitSurface";

   function Blit_Surface_Scaled
     (Source      : in System.Address;
      Source_Area : in System.Address;
      Target      : in System.Address;
      Target_Area : in System.Address;
      Mode        : in Scale_Mode) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_BlitSurfaceScaled";

   function Blit_Surface_Unchecked
     (Source      : in System.Address;
      Source_Area : in System.Address;
      Target      : in System.Address;
      Target_Area : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_BlitSurfaceUnchecked";

   function Blit_Surface_Unchecked_Scaled
     (Source      : in System.Address;
      Source_Area : in System.Address;
      Target      : in System.Address;
      Target_Area : in System.Address;
      Mode        : in Scale_Mode) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_BlitSurfaceUncheckedScaled";

   function Fill_Surface_Rect
     (Self   : in System.Address;
      Area   : in System.Address;
      Colour : in Interfaces.Unsigned_32) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_FillSurfaceRect";

   function Fill_Surface_Rects
     (Self   : in System.Address;
      Areas  : in System.Address;
      Count  : in C.int;
      Colour : in Interfaces.Unsigned_32) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_FillSurfaceRects";

   function Get_Surface_Clip_Rect
     (Self : in System.Address;
      Area : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetSurfaceClipRect";

   function Set_Surface_Clip_Rect
     (Self : in System.Address;
      Area : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetSurfaceClipRect";

   function Get_Surface_Palette
     (Self : in System.Address) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetSurfacePalette";

   function Surface_Has_Color_Key
     (Self : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SurfaceHasColorKey";

   function Get_Surface_Color_Key
     (Self : in System.Address;
      Key  : access Interfaces.Unsigned_32) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetSurfaceColorKey";

   function Set_Surface_Color_Key
     (Self   : in System.Address;
      Enable : in CE.bool;
      Key    : in Interfaces.Unsigned_32) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetSurfaceColorKey";

   function Get_Surface_Alpha_Mod
     (Self  : in System.Address;
      Alpha : access Colour_Component) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetSurfaceAlphaMod";

   function Set_Surface_Alpha_Mod
     (Self  : in System.Address;
      Alpha : in Colour_Component) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetSurfaceAlphaMod";

   function Get_Surface_Blend_Mode
     (Self : in System.Address;
      Mode : access Blend_Mode) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetSurfaceBlendMode";

   function Set_Surface_Blend_Mode
     (Self : in System.Address;
      Mode : in Blend_Mode) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetSurfaceBlendMode";

   function Get_Surface_Color_Mod
     (Self  : in System.Address;
      Red   : access Colour_Component;
      Green : access Colour_Component;
      Blue  : access Colour_Component) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetSurfaceColorMod";

   function Set_Surface_Color_Mod
     (Self  : in System.Address;
      Red   : in Colour_Component;
      Green : in Colour_Component;
      Blue  : in Colour_Component) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetSurfaceColorMod";

   function Lock_Surface
     (Self : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_LockSurface";

   procedure Unlock_Surface
     (Self : in System.Address)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_UnlockSurface";

   function Set_Surface_RLE
     (Self    : in System.Address;
      Enabled : in CE.bool) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetSurfaceRLE";

   procedure Destroy_Surface
     (Self : in System.Address)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_DestroySurface";

   procedure Free
     (Value : in System.Address)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_free";

   function Save_BMP
     (Self : in System.Address;
      File : in C.char_array) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SaveBMP";

   function Save_BMP_IO
     (Self     : in System.Address;
      Dest     : in System.Address;
      Close_IO : in CE.bool) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SaveBMP_IO";

   function Save_PNG
     (Self : in System.Address;
      File : in C.char_array) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SavePNG";

   function Save_PNG_IO
     (Self     : in System.Address;
      Dest     : in System.Address;
      Close_IO : in CE.bool) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SavePNG_IO";

   function Set_Surface_Colourspace
     (Self         : in System.Address;
      Space        : in Colour_Space) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetSurfaceColorspace";

   function Create_Surface_Palette
     (Self : in System.Address) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CreateSurfacePalette";

   function Set_Surface_Palette
     (Self    : in System.Address;
      Palette : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetSurfacePalette";

   function Add_Surface_Alternate_Image
     (Self  : in System.Address;
      Image : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_AddSurfaceAlternateImage";

   function Surface_Has_Alternate_Images
     (Self : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SurfaceHasAlternateImages";

   function Get_Surface_Images
     (Self  : in System.Address;
      Count : access C.int) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetSurfaceImages";

   procedure Remove_Surface_Alternate_Images
     (Self : in System.Address)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_RemoveSurfaceAlternateImages";

   function Surface_Has_RLE
     (Self : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SurfaceHasRLE";

   function Flip_Surface
     (Self : in System.Address;
      Mode : in Flip_Mode) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_FlipSurface";

   function Rotate_Surface
     (Self  : in System.Address;
      Angle : in C.C_float) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_RotateSurface";

   function Duplicate_Surface
     (Self : in System.Address) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_DuplicateSurface";

   function Scale_Surface
     (Self   : in System.Address;
      Width  : in C.int;
      Height : in C.int;
      Mode   : in Scale_Mode) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ScaleSurface";

   function Convert_Surface_And_Colourspace
     (Self         : in System.Address;
      Pixel_Format : in Pixel_Format_Name;
      Palette      : in System.Address;
      Space        : in Colour_Space;
      Properties   : in SDL.Raw.Properties.ID) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ConvertSurfaceAndColorspace";

   function Convert_Pixels
     (Width              : in C.int;
      Height             : in C.int;
      Source_Format      : in Pixel_Format_Name;
      Source             : in System.Address;
      Source_Pitch       : in C.int;
      Destination_Format : in Pixel_Format_Name;
      Destination        : in System.Address;
      Destination_Pitch  : in C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ConvertPixels";

   function Convert_Pixels_And_Colourspace
     (Width                    : in C.int;
      Height                   : in C.int;
      Source_Format            : in Pixel_Format_Name;
      Source_Colour_Space      : in Colour_Space;
      Source_Properties        : in SDL.Raw.Properties.ID;
      Source                   : in System.Address;
      Source_Pitch             : in C.int;
      Destination_Format       : in Pixel_Format_Name;
      Destination_Colour_Space : in Colour_Space;
      Destination_Properties   : in SDL.Raw.Properties.ID;
      Destination              : in System.Address;
      Destination_Pitch        : in C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ConvertPixelsAndColorspace";

   function Premultiply_Alpha
     (Width              : in C.int;
      Height             : in C.int;
      Source_Format      : in Pixel_Format_Name;
      Source             : in System.Address;
      Source_Pitch       : in C.int;
      Destination_Format : in Pixel_Format_Name;
      Destination        : in System.Address;
      Destination_Pitch  : in C.int;
      Linear             : in CE.bool) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_PremultiplyAlpha";

   function Premultiply_Surface_Alpha
     (Self   : in System.Address;
      Linear : in CE.bool) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_PremultiplySurfaceAlpha";

   function Clear_Surface
     (Self  : in System.Address;
      Red   : in C.C_float;
      Green : in C.C_float;
      Blue  : in C.C_float;
      Alpha : in C.C_float) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ClearSurface";

   function Stretch_Surface
     (Source      : in System.Address;
      Source_Area : in System.Address;
      Target      : in System.Address;
      Target_Area : in System.Address;
      Mode        : in Scale_Mode) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_StretchSurface";

   function Blit_Surface_Tiled
     (Source      : in System.Address;
      Source_Area : in System.Address;
      Target      : in System.Address;
      Target_Area : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_BlitSurfaceTiled";

   function Blit_Surface_Tiled_With_Scale
     (Source      : in System.Address;
      Source_Area : in System.Address;
      Scale       : in C.C_float;
      Mode        : in Scale_Mode;
      Target      : in System.Address;
      Target_Area : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_BlitSurfaceTiledWithScale";

   function Blit_Surface_9_Grid
     (Source        : in System.Address;
      Source_Area   : in System.Address;
      Left_Width    : in C.int;
      Right_Width   : in C.int;
      Top_Height    : in C.int;
      Bottom_Height : in C.int;
      Scale         : in C.C_float;
      Mode          : in Scale_Mode;
      Target        : in System.Address;
      Target_Area   : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_BlitSurface9Grid";

   function Map_Surface_RGB
     (Self  : in System.Address;
      Red   : in Colour_Component;
      Green : in Colour_Component;
      Blue  : in Colour_Component) return Interfaces.Unsigned_32
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_MapSurfaceRGB";

   function Map_Surface_RGBA
     (Self  : in System.Address;
      Red   : in Colour_Component;
      Green : in Colour_Component;
      Blue  : in Colour_Component;
      Alpha : in Colour_Component) return Interfaces.Unsigned_32
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_MapSurfaceRGBA";

   function Read_Surface_Pixel
     (Self  : in System.Address;
      X     : in C.int;
      Y     : in C.int;
      Red   : access Colour_Component;
      Green : access Colour_Component;
      Blue  : access Colour_Component;
      Alpha : access Colour_Component) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ReadSurfacePixel";

   function Read_Surface_Pixel_Float
     (Self  : in System.Address;
      X     : in C.int;
      Y     : in C.int;
      Red   : access C.C_float;
      Green : access C.C_float;
      Blue  : access C.C_float;
      Alpha : access C.C_float) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ReadSurfacePixelFloat";

   function Write_Surface_Pixel
     (Self  : in System.Address;
      X     : in C.int;
      Y     : in C.int;
      Red   : in Colour_Component;
      Green : in Colour_Component;
      Blue  : in Colour_Component;
      Alpha : in Colour_Component) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_WriteSurfacePixel";

   function Write_Surface_Pixel_Float
     (Self  : in System.Address;
      X     : in C.int;
      Y     : in C.int;
      Red   : in C.C_float;
      Green : in C.C_float;
      Blue  : in C.C_float;
      Alpha : in C.C_float) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_WriteSurfacePixelFloat";

   function Get_Surface_Colourspace
     (Self : in System.Address) return Colour_Space
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetSurfaceColorspace";
end SDL.Raw.Surface;
