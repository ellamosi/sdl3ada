with Interfaces.C;
with Interfaces.C.Strings;

package SDL.Raw.Version is
   pragma Preelaborate;

   package C renames Interfaces.C;
   package CS renames Interfaces.C.Strings;

   function Get_Version return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetVersion";

   function Get_Revision return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetRevision";
end SDL.Raw.Version;
