with Interfaces;
with Interfaces.C;
with Interfaces.C.Extensions;
with Interfaces.C.Strings;
with System;

package SDL.Raw.MessageBox is
   pragma Preelaborate;

   package CE renames Interfaces.C.Extensions;
   package CS renames Interfaces.C.Strings;

   subtype Flags is Interfaces.Unsigned_32;
   subtype Button_ID is Interfaces.C.int;

   function Show_Message_Box
     (Data      : in System.Address;
      Button_ID : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ShowMessageBox";

   function Show_Simple_Message_Box
     (Kind    : in Flags;
      Title   : in CS.chars_ptr;
      Message : in CS.chars_ptr;
      Window  : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ShowSimpleMessageBox";
end SDL.Raw.MessageBox;
