with Interfaces.C;
with Interfaces.C.Extensions;
with Interfaces.C.Strings;

package SDL.Raw.Error is
   pragma Preelaborate;

   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;
   package CS renames Interfaces.C.Strings;

   function Set_Error (Fmt_Str, C_Str : in C.char_array) return CE.bool
   with
     Import        => True,
     Convention    => C_Variadic_1,
     External_Name => "SDL_SetError";

   function Out_Of_Memory return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_OutOfMemory";

   function Get_Error return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetError";

   function Clear_Error return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ClearError";
end SDL.Raw.Error;
