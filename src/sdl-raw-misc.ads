with Interfaces.C.Extensions;
with Interfaces.C.Strings;

package SDL.Raw.Misc is
   pragma Preelaborate;

   package CE renames Interfaces.C.Extensions;
   package CS renames Interfaces.C.Strings;

   function Open_URL (URL : in CS.chars_ptr) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_OpenURL";
end SDL.Raw.Misc;
