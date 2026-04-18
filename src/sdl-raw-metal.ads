with System;

package SDL.Raw.Metal is
   pragma Preelaborate;

   function Create_View
     (Window : in System.Address) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_Metal_CreateView";

   procedure Destroy_View
     (View : in System.Address)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_Metal_DestroyView";

   function Get_Layer
     (View : in System.Address) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_Metal_GetLayer";
end SDL.Raw.Metal;
