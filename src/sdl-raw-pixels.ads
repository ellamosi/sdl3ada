with Interfaces;
with Interfaces.C;
with Interfaces.C.Extensions;
with Interfaces.C.Strings;

package SDL.Raw.Pixels is
   pragma Preelaborate;

   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;
   package CS renames Interfaces.C.Strings;

   subtype U32 is Interfaces.Unsigned_32;
   subtype Colour_Mask is U32;
   subtype Colour_Component is Interfaces.Unsigned_8;
   subtype Pixel_Format_Name is U32;

   type Colour is record
      Red   : Colour_Component := 0;
      Green : Colour_Component := 0;
      Blue  : Colour_Component := 0;
      Alpha : Colour_Component := 0;
   end record
   with
     Convention => C,
     Size       => 32;

   Null_Colour : constant Colour := (others => 0);

   type Colour_Array is array (C.size_t range <>) of aliased Colour with
     Convention => C;

   type Colour_Access is access all Colour with
     Convention => C;

   type Padding_Array is array (Positive range 1 .. 2) of Interfaces.Unsigned_8 with
     Convention => C;

   type Pixel_Format_Details is record
      Format          : Pixel_Format_Name;
      Bits_Per_Pixel  : Interfaces.Unsigned_8;
      Bytes_Per_Pixel : Interfaces.Unsigned_8;
      Padding         : Padding_Array := (others => 0);
      Red_Mask        : Colour_Mask;
      Green_Mask      : Colour_Mask;
      Blue_Mask       : Colour_Mask;
      Alpha_Mask      : Colour_Mask;
      Red_Bits        : Interfaces.Unsigned_8;
      Green_Bits      : Interfaces.Unsigned_8;
      Blue_Bits       : Interfaces.Unsigned_8;
      Alpha_Bits      : Interfaces.Unsigned_8;
      Red_Shift       : Interfaces.Unsigned_8;
      Green_Shift     : Interfaces.Unsigned_8;
      Blue_Shift      : Interfaces.Unsigned_8;
      Alpha_Shift     : Interfaces.Unsigned_8;
   end record
   with Convention => C;

   type Pixel_Format_Details_Access is access constant Pixel_Format_Details with
     Convention => C;

   type Palette is record
      Total     : C.int;
      Colours   : Colour_Access;
      Version   : Interfaces.Unsigned_32;
      Ref_Count : C.int;
   end record
   with Convention => C;

   type Palette_Access is access all Palette with
     Convention => C;

   function Get_Pixel_Format_Details
     (Format : in Pixel_Format_Name) return Pixel_Format_Details_Access
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetPixelFormatDetails";

   function Get_Pixel_Format_Name
     (Format : in Pixel_Format_Name) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetPixelFormatName";

   function Get_Masks_For_Pixel_Format
     (Format     : in  Pixel_Format_Name;
      Bits       : out C.int;
      Red_Mask   : out Colour_Mask;
      Green_Mask : out Colour_Mask;
      Blue_Mask  : out Colour_Mask;
      Alpha_Mask : out Colour_Mask) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetMasksForPixelFormat";

   function Get_Pixel_Format_For_Masks
     (Bits       : in C.int;
      Red_Mask   : in Colour_Mask;
      Green_Mask : in Colour_Mask;
      Blue_Mask  : in Colour_Mask;
      Alpha_Mask : in Colour_Mask) return Pixel_Format_Name
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetPixelFormatForMasks";

   procedure Get_RGB
     (Pixel   : in U32;
      Format  : in Pixel_Format_Details_Access;
      Palette : in Palette_Access;
      Red     : out Colour_Component;
      Green   : out Colour_Component;
      Blue    : out Colour_Component)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetRGB";

   procedure Get_RGBA
     (Pixel   : in U32;
      Format  : in Pixel_Format_Details_Access;
      Palette : in Palette_Access;
      Red     : out Colour_Component;
      Green   : out Colour_Component;
      Blue    : out Colour_Component;
      Alpha   : out Colour_Component)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetRGBA";

   function Map_RGB
     (Format  : in Pixel_Format_Details_Access;
      Palette : in Palette_Access;
      Red     : in Colour_Component;
      Green   : in Colour_Component;
      Blue    : in Colour_Component) return U32
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_MapRGB";

   function Map_RGBA
     (Format  : in Pixel_Format_Details_Access;
      Palette : in Palette_Access;
      Red     : in Colour_Component;
      Green   : in Colour_Component;
      Blue    : in Colour_Component;
      Alpha   : in Colour_Component) return U32
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_MapRGBA";

   function Create_Palette
     (Total_Colours : in C.int) return Palette_Access
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CreatePalette";

   function Set_Palette_Colors
     (Container : in Palette_Access;
      Colours   : access constant Colour;
      First     : in C.int;
      Total     : in C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetPaletteColors";

   procedure Destroy_Palette
     (Container : in Palette_Access)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_DestroyPalette";
end SDL.Raw.Pixels;
