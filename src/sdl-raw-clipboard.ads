with Interfaces;
with Interfaces.C;
with Interfaces.C.Pointers;
with Interfaces.C.Extensions;
with Interfaces.C.Strings;
with System;

package SDL.Raw.Clipboard is
   pragma Preelaborate;

   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;
   package CS renames Interfaces.C.Strings;

   subtype Sizes is C.size_t;

   type Byte_Array is array (C.ptrdiff_t range <>) of aliased Interfaces.Unsigned_8
   with
     Convention     => C,
     Component_Size => 8;

   package Byte_Pointers is new Interfaces.C.Pointers
     (Index              => C.ptrdiff_t,
      Element            => Interfaces.Unsigned_8,
      Element_Array      => Byte_Array,
      Default_Terminator => 0);

   type Mime_Type_Array is array (C.ptrdiff_t range <>) of aliased CS.chars_ptr
   with Convention => C;

   package Mime_Type_Pointers is new Interfaces.C.Pointers
     (Index              => C.ptrdiff_t,
      Element            => CS.chars_ptr,
      Element_Array      => Mime_Type_Array,
      Default_Terminator => null);

   type Clipboard_Data_Callback is access function
     (User_Data : in System.Address;
      Mime_Type : in CS.chars_ptr;
      Size      : access Sizes) return System.Address
   with Convention => C;

   type Clipboard_Cleanup_Callback is access procedure
     (User_Data : in System.Address)
   with Convention => C;

   procedure Free (Memory : in CS.chars_ptr)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_free";

   procedure Free (Memory : in Byte_Pointers.Pointer)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_free";

   procedure Free (Memory : in Mime_Type_Pointers.Pointer)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_free";

   function Set_Text (Text : in C.char_array) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetClipboardText";

   function Get_Text return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetClipboardText";

   function Has_Text return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_HasClipboardText";

   function Set_Primary_Selection_Text
     (Text : in C.char_array) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetPrimarySelectionText";

   function Get_Primary_Selection_Text return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetPrimarySelectionText";

   function Has_Primary_Selection_Text return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_HasPrimarySelectionText";

   function Set_Data
     (Callback       : in Clipboard_Data_Callback;
      Cleanup        : in Clipboard_Cleanup_Callback;
      User_Data      : in System.Address;
      Mime_Types     : in System.Address;
      Num_Mime_Types : in Sizes) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetClipboardData";

   function Clear_Data return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ClearClipboardData";

   function Get_Data
     (Mime_Type : in C.char_array;
      Size      : access Sizes) return Byte_Pointers.Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetClipboardData";

   function Has_Data (Mime_Type : in C.char_array) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_HasClipboardData";

   function Get_Mime_Types (Count : access Sizes) return Mime_Type_Pointers.Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetClipboardMimeTypes";
end SDL.Raw.Clipboard;
