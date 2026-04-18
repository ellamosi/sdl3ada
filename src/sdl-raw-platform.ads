with Interfaces.C.Strings;

package SDL.Raw.Platform is
   pragma Preelaborate;

   package CS renames Interfaces.C.Strings;

   function Get_Platform return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetPlatform";
end SDL.Raw.Platform;
