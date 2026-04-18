with Interfaces;
with Interfaces.C;
with Interfaces.C.Extensions;
with System;

package SDL.Raw.Surface is
   pragma Preelaborate;

   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;

   subtype Pixel_Format_Name is Interfaces.Unsigned_32;

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
end SDL.Raw.Surface;
