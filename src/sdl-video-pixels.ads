with Interfaces;
with Interfaces.C;
with Interfaces.C.Pointers;

package SDL.Video.Pixels is
   pragma Preelaborate;

   package C renames Interfaces.C;

   subtype Colour_Component is Interfaces.Unsigned_8;

   type Pitches is new C.int with
     Size       => 32,
     Convention => C;

   type ARGB_8888 is
      record
         Alpha : Colour_Component;
         Red   : Colour_Component;
         Green : Colour_Component;
         Blue  : Colour_Component;
      end record with
     Size       => 32,
     Convention => C;

   for ARGB_8888 use
      record
         Blue  at 0 range  0 ..  7;
         Green at 0 range  8 .. 15;
         Red   at 0 range 16 .. 23;
         Alpha at 0 range 24 .. 31;
      end record;

   type ARGB_8888_Array is array (SDL.Dimension range <>) of aliased ARGB_8888;

   package ARGB_8888_Access is new Interfaces.C.Pointers
     (Index              => SDL.Dimension,
      Element            => ARGB_8888,
      Element_Array      => ARGB_8888_Array,
      Default_Terminator => ARGB_8888'(others => 0));

   type RGBA_8888 is
      record
         Alpha : Colour_Component;
         Red   : Colour_Component;
         Green : Colour_Component;
         Blue  : Colour_Component;
      end record with
     Size       => 32,
     Convention => C;

   for RGBA_8888 use
      record
         Alpha at 0 range  0 ..  7;
         Blue  at 0 range  8 .. 15;
         Green at 0 range 16 .. 23;
         Red   at 0 range 24 .. 31;
      end record;

   type RGBA_8888_Array is array (SDL.Dimension range <>) of aliased RGBA_8888;

   package RGBA_8888_Access is new Interfaces.C.Pointers
     (Index              => SDL.Dimension,
      Element            => RGBA_8888,
      Element_Array      => RGBA_8888_Array,
      Default_Terminator => RGBA_8888'(others => 0));

   type ABGR_8888 is
      record
         Alpha : Colour_Component;
         Red   : Colour_Component;
         Green : Colour_Component;
         Blue  : Colour_Component;
      end record with
     Size       => 32,
     Convention => C;

   for ABGR_8888 use
      record
         Red   at 0 range  0 ..  7;
         Green at 0 range  8 .. 15;
         Blue  at 0 range 16 .. 23;
         Alpha at 0 range 24 .. 31;
      end record;

   type ABGR_8888_Array is array (SDL.Dimension range <>) of aliased ABGR_8888;

   package ABGR_8888_Access is new Interfaces.C.Pointers
     (Index              => SDL.Dimension,
      Element            => ABGR_8888,
      Element_Array      => ABGR_8888_Array,
      Default_Terminator => ABGR_8888'(others => 0));

   type BGRA_8888 is
      record
         Alpha : Colour_Component;
         Red   : Colour_Component;
         Green : Colour_Component;
         Blue  : Colour_Component;
      end record with
     Size       => 32,
     Convention => C;

   for BGRA_8888 use
      record
         Alpha at 0 range  0 ..  7;
         Red   at 0 range  8 .. 15;
         Green at 0 range 16 .. 23;
         Blue  at 0 range 24 .. 31;
      end record;

   type BGRA_8888_Array is array (SDL.Dimension range <>) of aliased BGRA_8888;

   package BGRA_8888_Access is new Interfaces.C.Pointers
     (Index              => SDL.Dimension,
      Element            => BGRA_8888,
      Element_Array      => BGRA_8888_Array,
      Default_Terminator => BGRA_8888'(others => 0));

   generic
      type Index is (<>);
      type Element is private;
      type Element_Array_1D is array (Index range <>) of aliased Element;
      pragma Warnings (Off, """Element_Array_2D"" is not referenced");
      type Element_Array_2D is array (Index range <>, Index range <>) of aliased Element;
      pragma Warnings (On, """Element_Array_2D"" is not referenced");
      Default_Terminator : Element;
   package Texture_Data is
      package Texture_Data_1D is new Interfaces.C.Pointers
        (Index              => Index,
         Element            => Element,
         Element_Array      => Element_Array_1D,
         Default_Terminator => Default_Terminator);

      subtype Pointer is Texture_Data_1D.Pointer;
   end Texture_Data;
end SDL.Video.Pixels;
