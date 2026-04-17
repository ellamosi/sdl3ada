with Interfaces.C;
with Interfaces.C.Extensions;
with Interfaces.C.Strings;
with System;

package SDL.Raw.Hints is
   pragma Preelaborate;

   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;
   package CS renames Interfaces.C.Strings;

   type Priorities is (Default, Normal, Override) with
     Convention => C;

   type Hint_Callback is access procedure
     (User_Data : in System.Address;
      Name      : in CS.chars_ptr;
      Old_Value : in CS.chars_ptr;
      New_Value : in CS.chars_ptr)
   with Convention => C;

   procedure Reset_Hints
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ResetHints";

   function Get_Hint (Name : in C.char_array) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetHint";

   function Get_Hint_Boolean
     (Name          : in C.char_array;
      Default_Value : in CE.bool) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetHintBoolean";

   function Set_Hint
     (Name  : in C.char_array;
      Value : in C.char_array) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetHint";

   function Set_Hint_With_Priority
     (Name  : in C.char_array;
      Value : in C.char_array;
      P     : in Priorities) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetHintWithPriority";

   function Reset_Hint (Name : in C.char_array) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ResetHint";

   function Add_Hint_Callback
     (Name      : in C.char_array;
      Callback  : in Hint_Callback;
      User_Data : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_AddHintCallback";

   procedure Remove_Hint_Callback
     (Name      : in C.char_array;
      Callback  : in Hint_Callback;
      User_Data : in System.Address)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_RemoveHintCallback";
end SDL.Raw.Hints;
