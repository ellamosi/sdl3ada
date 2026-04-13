with Interfaces;
with Interfaces.C;
with Interfaces.C.Extensions;
with Interfaces.C.Strings;
with System;

package SDL.Raw.Properties is
   pragma Preelaborate;

   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;
   package CS renames Interfaces.C.Strings;

   subtype ID is Interfaces.Unsigned_32;
   No_Properties : constant ID := 0;

   subtype Numbers is Interfaces.Integer_64;
   subtype Floats is C.C_float;

   type Property_Types is
     (Invalid_Type,
      Pointer_Type,
      String_Type,
      Number_Type,
      Float_Type,
      Boolean_Type)
   with
     Convention => C,
     Size       => C.int'Size;

   for Property_Types use
     (Invalid_Type => 0,
      Pointer_Type => 1,
      String_Type  => 2,
      Number_Type  => 3,
      Float_Type   => 4,
      Boolean_Type => 5);

   type Cleanup_Callback is access procedure
     (User_Data : in System.Address;
      Value     : in System.Address)
   with Convention => C;

   type Enumerate_Callback is access procedure
     (User_Data : in System.Address;
      Props     : in ID;
      Name      : in CS.chars_ptr)
   with Convention => C;

   Name_Property : constant String := "SDL.name";

   function Get_Global_Properties return ID with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGlobalProperties";

   function Create_Properties return ID with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CreateProperties";

   function Copy_Properties
     (Source      : in ID;
      Destination : in ID) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CopyProperties";

   function Lock_Properties (Props : in ID) return CE.bool with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_LockProperties";

   procedure Unlock_Properties (Props : in ID) with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_UnlockProperties";

   function Set_Pointer_Property_With_Cleanup
     (Props     : in ID;
      Name      : in C.char_array;
      Value     : in System.Address;
      Cleanup   : in Cleanup_Callback;
      User_Data : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetPointerPropertyWithCleanup";

   function Set_Pointer_Property
     (Props : in ID;
      Name  : in C.char_array;
      Value : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetPointerProperty";

   function Set_String_Property
     (Props : in ID;
      Name  : in C.char_array;
      Value : in CS.chars_ptr) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetStringProperty";

   function Set_Number_Property
     (Props : in ID;
      Name  : in C.char_array;
      Value : in Numbers) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetNumberProperty";

   function Set_Float_Property
     (Props : in ID;
      Name  : in C.char_array;
      Value : in Floats) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetFloatProperty";

   function Set_Boolean_Property
     (Props : in ID;
      Name  : in C.char_array;
      Value : in CE.bool) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetBooleanProperty";

   function Has_Property
     (Props : in ID;
      Name  : in C.char_array) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_HasProperty";

   function Get_Property_Type
     (Props : in ID;
      Name  : in C.char_array) return Property_Types
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetPropertyType";

   function Get_Pointer_Property
     (Props   : in ID;
      Name    : in C.char_array;
      Default : in System.Address) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetPointerProperty";

   function Get_String_Property
     (Props   : in ID;
      Name    : in C.char_array;
      Default : in CS.chars_ptr) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetStringProperty";

   function Get_Number_Property
     (Props   : in ID;
      Name    : in C.char_array;
      Default : in Numbers) return Numbers
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetNumberProperty";

   function Get_Float_Property
     (Props   : in ID;
      Name    : in C.char_array;
      Default : in Floats) return Floats
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetFloatProperty";

   function Get_Boolean_Property
     (Props   : in ID;
      Name    : in C.char_array;
      Default : in CE.bool) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetBooleanProperty";

   function Clear_Property
     (Props : in ID;
      Name  : in C.char_array) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ClearProperty";

   function Enumerate_Properties
     (Props     : in ID;
      Callback  : in Enumerate_Callback;
      User_Data : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_EnumerateProperties";

   procedure Destroy_Properties (Props : in ID) with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_DestroyProperties";
end SDL.Raw.Properties;
