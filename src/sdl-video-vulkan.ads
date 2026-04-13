with Ada.Strings.Unbounded;
with Interfaces;
with System;

with SDL.Video.Windows;

generic
   type Instance_Address_Type is private;
   Instance_Null : Instance_Address_Type;
   type Surface_Type is private;
package SDL.Video.Vulkan is
   SDL_Vulkan_Error : exception;

   type Extension_Name_Arrays is
     array (Positive range <>) of Ada.Strings.Unbounded.Unbounded_String;

   Null_Extension_Name_Array : constant Extension_Name_Arrays (1 .. 1) :=
     (others => Ada.Strings.Unbounded.Null_Unbounded_String);

   procedure Create_Surface
     (Window   : in SDL.Video.Windows.Window;
      Instance : in Instance_Address_Type;
      Surface  : out Surface_Type);

   procedure Create_Surface
     (Window    : in SDL.Video.Windows.Window;
      Instance  : in Instance_Address_Type;
      Surface   : out Surface_Type;
      Allocator : in System.Address);

   procedure Destroy_Surface
     (Instance  : in Instance_Address_Type;
      Surface   : in Surface_Type;
      Allocator : in System.Address := System.Null_Address);

   procedure Get_Drawable_Size
     (Window        : in SDL.Video.Windows.Window;
      Width, Height : out SDL.Natural_Dimension);

   function Get_Instance_Extensions return Extension_Name_Arrays;

   function Get_Instance_Extensions
     (Window : in SDL.Video.Windows.Window) return Extension_Name_Arrays;

   function Get_Instance_Procedure_Address return Instance_Address_Type;

   function Get_Presentation_Support
     (Instance           : in Instance_Address_Type;
      Physical_Device    : in System.Address;
      Queue_Family_Index : in Interfaces.Unsigned_32) return Boolean;

   procedure Load_Library;
   procedure Load_Library (Path : in String);
   procedure Unload_Library;
end SDL.Video.Vulkan;
