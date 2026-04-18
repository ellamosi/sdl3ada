with Interfaces;
with Interfaces.C;
with Interfaces.C.Extensions;
with System;

package SDL.Raw.Pixels is
   pragma Preelaborate;

   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;

   type Palette is record
      Total     : C.int;
      Colours   : System.Address;
      Version   : Interfaces.Unsigned_32;
      Ref_Count : C.int;
   end record
   with Convention => C;

   type Palette_Access is access all Palette with
     Convention => C;

   function Create_Palette
     (Total_Colours : in C.int) return Palette_Access
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CreatePalette";

   function Set_Palette_Colors
     (Container : in Palette_Access;
      Colours   : in System.Address;
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
