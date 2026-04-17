with Interfaces.C;
with System;

package SDL.Raw.LoadSO is
   pragma Preelaborate;

   package C renames Interfaces.C;

   type Shared_Object is null record with
     Convention => C;

   type Shared_Object_Access is access all Shared_Object with
     Convention => C;

   function Load_Object
     (SO_File : in C.char_array) return Shared_Object_Access
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_LoadObject";

   procedure Unload_Object (Handle : in Shared_Object_Access)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_UnloadObject";

   function Load_Function
     (Handle : in Shared_Object_Access;
      Name   : in C.char_array) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_LoadFunction";
end SDL.Raw.LoadSO;
