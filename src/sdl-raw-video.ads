with Interfaces;
with Interfaces.C;
with System;

with SDL.Raw.Properties;

package SDL.Raw.Video is
   pragma Preelaborate;

   package C renames Interfaces.C;

   type Window_ID is mod 2 ** 32 with
     Convention => C,
     Size       => 32;

   subtype Window_Flags is Interfaces.Unsigned_64;

   function Create_Window_With_Properties
     (Props : in SDL.Raw.Properties.ID) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CreateWindowWithProperties";

   function Create_Popup_Window
     (Parent : in System.Address;
      X      : in C.int;
      Y      : in C.int;
      Width  : in C.int;
      Height : in C.int;
      Flags  : in Window_Flags) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CreatePopupWindow";

   function Get_Window_Properties
     (Value : in System.Address) return SDL.Raw.Properties.ID
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetWindowProperties";

   function Get_Window_ID
     (Value : in System.Address) return Window_ID
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetWindowID";
end SDL.Raw.Video;
