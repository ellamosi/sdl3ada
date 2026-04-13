with Interfaces.C.Extensions;
with Interfaces.C.Strings;
with System;

with SDL.Error;

package body SDL.Video.Pixel_Formats is
   package CE renames Interfaces.C.Extensions;
   package CS renames Interfaces.C.Strings;

   function SDL_Get_Pixel_Format_Details
     (Format : in Pixel_Format_Names) return Pixel_Format_Access
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetPixelFormatDetails";

   function SDL_Get_Pixel_Format_Name
     (Format : in Pixel_Format_Names) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetPixelFormatName";

   function SDL_Get_Masks_For_Pixel_Format
     (Format     : in  Pixel_Format_Names;
      Bits       : out C.int;
      Red_Mask   : out Colour_Mask;
      Green_Mask : out Colour_Mask;
      Blue_Mask  : out Colour_Mask;
      Alpha_Mask : out Colour_Mask) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetMasksForPixelFormat";

   function SDL_Get_Pixel_Format_For_Masks
     (Bits       : in C.int;
      Red_Mask   : in Colour_Mask;
      Green_Mask : in Colour_Mask;
      Blue_Mask  : in Colour_Mask;
      Alpha_Mask : in Colour_Mask) return Pixel_Format_Names
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetPixelFormatForMasks";

   procedure SDL_Get_RGB
     (Pixel   : in Unsigned_32;
      Format  : in Pixel_Format_Access;
      Palette : in System.Address;
      Red     : out SDL.Video.Palettes.Colour_Component;
      Green   : out SDL.Video.Palettes.Colour_Component;
      Blue    : out SDL.Video.Palettes.Colour_Component)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetRGB";

   procedure SDL_Get_RGBA
     (Pixel   : in Unsigned_32;
      Format  : in Pixel_Format_Access;
      Palette : in System.Address;
      Red     : out SDL.Video.Palettes.Colour_Component;
      Green   : out SDL.Video.Palettes.Colour_Component;
      Blue    : out SDL.Video.Palettes.Colour_Component;
      Alpha   : out SDL.Video.Palettes.Colour_Component)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetRGBA";

   function SDL_Map_RGB
     (Format  : in Pixel_Format_Access;
      Palette : in System.Address;
      Red     : in SDL.Video.Palettes.Colour_Component;
      Green   : in SDL.Video.Palettes.Colour_Component;
      Blue    : in SDL.Video.Palettes.Colour_Component) return Unsigned_32
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_MapRGB";

   function SDL_Map_RGBA
     (Format  : in Pixel_Format_Access;
      Palette : in System.Address;
      Red     : in SDL.Video.Palettes.Colour_Component;
      Green   : in SDL.Video.Palettes.Colour_Component;
      Blue    : in SDL.Video.Palettes.Colour_Component;
      Alpha   : in SDL.Video.Palettes.Colour_Component) return Unsigned_32
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_MapRGBA";

   function Get_Details
     (Format : in Pixel_Format_Names) return Pixel_Format_Access is
   begin
      return SDL_Get_Pixel_Format_Details (Format);
   end Get_Details;

   function Image (Format : in Pixel_Format_Names) return String is
      Name : constant CS.chars_ptr := SDL_Get_Pixel_Format_Name (Format);

      use type CS.chars_ptr;
   begin
      if Name = CS.Null_Ptr then
         return "";
      end if;

      return CS.Value (Name);
   end Image;

   procedure To_Components
     (Pixel  : in  Unsigned_32;
      Format : in  Pixel_Format_Access;
      Red    : out SDL.Video.Palettes.Colour_Component;
      Green  : out SDL.Video.Palettes.Colour_Component;
      Blue   : out SDL.Video.Palettes.Colour_Component) is
   begin
      if Format = null then
         raise SDL.Video.Video_Error with SDL.Error.Get;
      end if;

      SDL_Get_RGB (Pixel, Format, System.Null_Address, Red, Green, Blue);
   end To_Components;

   procedure To_Components
     (Pixel  : in  Unsigned_32;
      Format : in  Pixel_Format_Access;
      Red    : out SDL.Video.Palettes.Colour_Component;
      Green  : out SDL.Video.Palettes.Colour_Component;
      Blue   : out SDL.Video.Palettes.Colour_Component;
      Alpha  : out SDL.Video.Palettes.Colour_Component) is
   begin
      if Format = null then
         raise SDL.Video.Video_Error with SDL.Error.Get;
      end if;

      SDL_Get_RGBA (Pixel, Format, System.Null_Address, Red, Green, Blue, Alpha);
   end To_Components;

   function To_Pixel
     (Format : in Pixel_Format_Access;
      Red    : in SDL.Video.Palettes.Colour_Component;
      Green  : in SDL.Video.Palettes.Colour_Component;
      Blue   : in SDL.Video.Palettes.Colour_Component) return Unsigned_32 is
   begin
      if Format = null then
         raise SDL.Video.Video_Error with SDL.Error.Get;
      end if;

      return SDL_Map_RGB (Format, System.Null_Address, Red, Green, Blue);
   end To_Pixel;

   function To_Pixel
     (Format : in Pixel_Format_Access;
      Red    : in SDL.Video.Palettes.Colour_Component;
      Green  : in SDL.Video.Palettes.Colour_Component;
      Blue   : in SDL.Video.Palettes.Colour_Component;
      Alpha  : in SDL.Video.Palettes.Colour_Component) return Unsigned_32 is
   begin
      if Format = null then
         raise SDL.Video.Video_Error with SDL.Error.Get;
      end if;

      return SDL_Map_RGBA
        (Format, System.Null_Address, Red, Green, Blue, Alpha);
   end To_Pixel;

   function To_Colour
     (Pixel  : in Unsigned_32;
      Format : in Pixel_Format_Access) return SDL.Video.Palettes.Colour is
      Colour : SDL.Video.Palettes.Colour;
   begin
      To_Components
        (Pixel  => Pixel,
         Format => Format,
         Red    => Colour.Red,
         Green  => Colour.Green,
         Blue   => Colour.Blue,
         Alpha  => Colour.Alpha);

      return Colour;
   end To_Colour;

   function To_Pixel
     (Colour : in SDL.Video.Palettes.Colour;
      Format : in Pixel_Format_Access) return Unsigned_32 is
   begin
      return To_Pixel
        (Format => Format,
         Red    => Colour.Red,
         Green  => Colour.Green,
         Blue   => Colour.Blue,
         Alpha  => Colour.Alpha);
   end To_Pixel;

   function To_Name
     (Bits       : in Bits_Per_Pixels;
      Red_Mask   : in Colour_Mask;
      Green_Mask : in Colour_Mask;
      Blue_Mask  : in Colour_Mask;
      Alpha_Mask : in Colour_Mask) return Pixel_Format_Names is
   begin
      return SDL_Get_Pixel_Format_For_Masks
        (Bits       => C.int (Bits),
         Red_Mask   => Red_Mask,
         Green_Mask => Green_Mask,
         Blue_Mask  => Blue_Mask,
         Alpha_Mask => Alpha_Mask);
   end To_Name;

   function To_Masks
     (Format     : in  Pixel_Format_Names;
      Bits       : out Bits_Per_Pixels;
      Red_Mask   : out Colour_Mask;
      Green_Mask : out Colour_Mask;
      Blue_Mask  : out Colour_Mask;
      Alpha_Mask : out Colour_Mask) return Boolean
   is
      Raw_Bits : C.int := 0;
      Success  : constant Boolean :=
        Boolean
          (SDL_Get_Masks_For_Pixel_Format
             (Format,
              Raw_Bits,
              Red_Mask,
              Green_Mask,
              Blue_Mask,
              Alpha_Mask));
   begin
      if Success then
         Bits := Bits_Per_Pixels (Raw_Bits);
      else
         Bits := 0;
      end if;

      return Success;
   end To_Masks;
end SDL.Video.Pixel_Formats;
