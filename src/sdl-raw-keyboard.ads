with Interfaces;
with Interfaces.C;
with Interfaces.C.Extensions;
with Interfaces.C.Pointers;
with Interfaces.C.Strings;
with System;

with SDL.Raw.Properties;

package SDL.Raw.Keyboard is
   pragma Preelaborate;

   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;
   package CS renames Interfaces.C.Strings;

   type ID is mod 2 ** 32 with
     Convention => C,
     Size       => 32;

   subtype Key_Modifier is Interfaces.Unsigned_16;

   type Scan_Code is range 0 .. 512 with
     Convention => C,
     Size       => 32;

   type ID_Array is array (C.ptrdiff_t range <>) of aliased ID with
     Convention => C;

   package ID_Pointers is new Interfaces.C.Pointers
     (Index              => C.ptrdiff_t,
      Element            => ID,
      Element_Array      => ID_Array,
      Default_Terminator => 0);

   type Key_State_Array is array (Scan_Code) of Boolean with
     Convention => C;

   type Key_State_Access is access constant Key_State_Array with
     Convention => C;

   procedure Free (Memory : in System.Address)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_free";

   function Get_Keyboard_Focus return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetKeyboardFocus";

   function Clear_Composition (Window : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ClearComposition";

   function Has_Keyboard return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_HasKeyboard";

   function Get_Keyboards
     (Count : access C.int) return ID_Pointers.Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetKeyboards";

   function Get_Keyboard_Name_For_ID
     (Value : in ID) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetKeyboardNameForID";

   function Get_Keyboard_State
     (Num_Keys : access C.int) return Key_State_Access
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetKeyboardState";

   function Get_Mod_State return Key_Modifier
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetModState";

   procedure Set_Mod_State (Modifiers : in Key_Modifier)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetModState";

   function Has_Screen_Keyboard_Support return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_HasScreenKeyboardSupport";

   function Screen_Keyboard_Shown
     (Window : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ScreenKeyboardShown";

   function Text_Input_Active
     (Window : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_TextInputActive";

   procedure Reset_Keyboard
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ResetKeyboard";

   function Set_Text_Input_Area
     (Window : in System.Address;
      Rect   : in System.Address;
      Cursor : in C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetTextInputArea";

   function Get_Text_Input_Area
     (Window : in System.Address;
      Rect   : in System.Address;
      Cursor : access C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetTextInputArea";

   function Start_Text_Input
     (Window : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_StartTextInput";

   function Start_Text_Input_With_Properties
     (Window : in System.Address;
      Props  : in SDL.Raw.Properties.ID) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_StartTextInputWithProperties";

   function Stop_Text_Input
     (Window : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_StopTextInput";
end SDL.Raw.Keyboard;
