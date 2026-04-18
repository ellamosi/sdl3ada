with Ada.Iterator_Interfaces;
with Interfaces;
with Interfaces.C;
with Interfaces.C.Pointers;
with System;

with SDL.Raw.Pixels;

package SDL.Video.Palettes is
   pragma Preelaborate;
   pragma Elaborate_Body;

   package C renames Interfaces.C;

   subtype Colour_Component is Interfaces.Unsigned_8;

   type Colour is
      record
         Red   : Colour_Component := 0;
         Green : Colour_Component := 0;
         Blue  : Colour_Component := 0;
         Alpha : Colour_Component := 0;
      end record with
     Convention => C,
     Size       => 32;

   Null_Colour : constant Colour := (others => 0);

   pragma Warnings (Off, "8 bits of ""RGB_Colour"" unused");
   type RGB_Colour is
      record
         Red   : Colour_Component := 0;
         Green : Colour_Component := 0;
         Blue  : Colour_Component := 0;
      end record with
     Convention => C,
     Size       => 32;
   pragma Warnings (On, "8 bits of ""RGB_Colour"" unused");

   Null_RGB_Colour : constant RGB_Colour := (others => 0);

   type Colour_Arrays is array (C.size_t range <>) of aliased Colour with
     Convention => C;

   type Cursor is private;

   No_Element : constant Cursor;

   function Element (Position : in Cursor) return Colour;

   function Has_Element (Position : in Cursor) return Boolean with
     Inline;

   package Palette_Iterator_Interfaces is new
     Ada.Iterator_Interfaces (Cursor, Has_Element);

   type Palette is tagged limited private with
     Default_Iterator  => Iterate,
     Iterator_Element  => Colour,
     Constant_Indexing => Constant_Reference;

   type Palette_Access is access Palette;

   function Constant_Reference
     (Container : aliased Palette;
      Position  : Cursor) return Colour;

   function Iterate
     (Container : Palette)
      return Palette_Iterator_Interfaces.Forward_Iterator'Class;

   function Create (Total_Colours : in Positive) return Palette;

   function Duplicate (Container : in Palette) return Palette;

   procedure Set_Colours
     (Container : in out Palette;
      Colours   : in Colour_Arrays;
      First     : in Natural := 0);

   procedure Free (Container : in out Palette);

   function Get_Internal (Container : in Palette) return System.Address with
     Inline;

   Empty_Palette : constant Palette;
private
   package Colour_Array_Pointer is new Interfaces.C.Pointers
     (Index              => C.size_t,
      Element            => Colour,
      Element_Array      => Colour_Arrays,
      Default_Terminator => (others => 0));

   subtype Internal_Palette is SDL.Raw.Pixels.Palette;
   subtype Internal_Palette_Access is SDL.Raw.Pixels.Palette_Access;

   type Palette is tagged limited
      record
         Data : Internal_Palette_Access;
      end record;

   type Palette_Constant_Access is access constant Palette'Class;

   type Cursor is
      record
         Container : Palette_Constant_Access;
         Index     : Natural;
         Current   : Colour_Array_Pointer.Pointer;
      end record;

   No_Element : constant Cursor :=
     (Container => null,
      Index     => Natural'First,
      Current   => null);

   Empty_Palette : constant Palette := (Data => null);
end SDL.Video.Palettes;
