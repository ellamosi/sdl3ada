with Interfaces.C;
with Interfaces.C.Pointers;
with Interfaces.C.Strings;

package SDL.Raw.Locale is
   pragma Preelaborate;

   package C renames Interfaces.C;
   package CS renames Interfaces.C.Strings;

   type Locale is record
      Language : CS.chars_ptr;
      Country  : CS.chars_ptr;
   end record with
     Convention => C;

   type Locale_Access is access all Locale with
     Convention => C;

   type Locale_Access_Array is
     array (C.ptrdiff_t range <>) of aliased Locale_Access
   with Convention => C;

   package Locale_Access_Pointers is new Interfaces.C.Pointers
     (Index              => C.ptrdiff_t,
      Element            => Locale_Access,
      Element_Array      => Locale_Access_Array,
      Default_Terminator => null);

   procedure Free (Locales : in Locale_Access_Pointers.Pointer)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_free";

   function Get_Preferred_Locales
     (Count : access C.int) return Locale_Access_Pointers.Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetPreferredLocales";
end SDL.Raw.Locale;
