with Interfaces;
with Interfaces.C;
with Interfaces.C.Extensions;
with Interfaces.C.Pointers;
with Interfaces.C.Strings;
with System;

generic
   type Instance_Address_Type is private;
   type Surface_Type is private;
package SDL.Raw.Vulkan is
   pragma Preelaborate;

   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;
   package CS renames Interfaces.C.Strings;

   type Extension_Name_Array is
     array (C.ptrdiff_t range <>) of aliased CS.chars_ptr
   with Convention => C;

   package Extension_Pointers is new Interfaces.C.Pointers
     (Index              => C.ptrdiff_t,
      Element            => CS.chars_ptr,
      Element_Array      => Extension_Name_Array,
      Default_Terminator => CS.Null_Ptr);

   function Create_Surface
     (Window    : in System.Address;
      Instance  : in Instance_Address_Type;
      Allocator : in System.Address;
      Surface   : out Surface_Type) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_Vulkan_CreateSurface";

   procedure Destroy_Surface
     (Instance  : in Instance_Address_Type;
      Surface   : in Surface_Type;
      Allocator : in System.Address)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_Vulkan_DestroySurface";

   function Get_Instance_Extensions
     (Count : access Interfaces.Unsigned_32) return Extension_Pointers.Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_Vulkan_GetInstanceExtensions";

   function Get_Vk_Get_Instance_Proc_Addr return Instance_Address_Type
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_Vulkan_GetVkGetInstanceProcAddr";

   function Get_Presentation_Support
     (Instance           : in Instance_Address_Type;
      Physical_Device    : in System.Address;
      Queue_Family_Index : in Interfaces.Unsigned_32) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_Vulkan_GetPresentationSupport";

   function Load_Library
     (Path : in CS.chars_ptr) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_Vulkan_LoadLibrary";

   function Load_Library
     (Path : in C.char_array) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_Vulkan_LoadLibrary";

   procedure Unload_Library
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_Vulkan_UnloadLibrary";
end SDL.Raw.Vulkan;
