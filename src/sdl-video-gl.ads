with Ada.Finalization;
with Interfaces.C;
with System;

with SDL.Video.Textures;
with SDL.Video.Windows;

package SDL.Video.GL is
   SDL_GL_Error : exception;

   type Colour_Bit_Size is range 0 .. 8 with
     Size => 8;

   type Buffer_Sizes is range 8 .. 32 with
     Static_Predicate => Buffer_Sizes in 8 | 16 | 24 | 32;

   type Depth_Buffer_Sizes is range 16 .. 32 with
     Static_Predicate => Depth_Buffer_Sizes in 16 | 24 | 32;

   type Stencil_Buffer_Sizes is range 0 .. 32 with
     Static_Predicate => Stencil_Buffer_Sizes in 0 | 8 | 16 | 24 | 32;

   type Multisample_Samples is range 0 .. 16;

   type Major_Versions is range 1 .. 4;

   type Minor_Versions is range 0 .. 6;

   type Profiles is (Core, Compatibility, ES) with
     Convention => C,
     Size       => Interfaces.C.int'Size;

   for Profiles use
     (Core          => 16#0000_0001#,
      Compatibility => 16#0000_0002#,
      ES            => 16#0000_0004#);

   type Flags is mod 2 ** 8 with
     Convention => C,
     Size       => 8;

   Context_Debug              : constant Flags := 16#01#;
   Context_Forward_Compatible : constant Flags := 16#02#;
   Context_Robust_Access      : constant Flags := 16#04#;
   Context_Reset_Isolation    : constant Flags := 16#08#;

   subtype EGL_Display is System.Address;
   subtype EGL_Config is System.Address;
   subtype EGL_Surface is System.Address;
   subtype Function_Pointer is System.Address;

   subtype EGL_Attribute is Interfaces.C.ptrdiff_t;
   subtype EGL_Integer_Attribute is Interfaces.C.int;

   type EGL_Attribute_Array_Callback is access function
     (User_Data : in System.Address) return System.Address
   with Convention => C;

   type EGL_Integer_Array_Callback is access function
     (User_Data : in System.Address;
      Display   : in EGL_Display;
      Config    : in EGL_Config) return System.Address
   with Convention => C;

   function Red_Size return Colour_Bit_Size;
   procedure Set_Red_Size (Size : in Colour_Bit_Size);

   function Green_Size return Colour_Bit_Size;
   procedure Set_Green_Size (Size : in Colour_Bit_Size);

   function Blue_Size return Colour_Bit_Size;
   procedure Set_Blue_Size (Size : in Colour_Bit_Size);

   function Alpha_Size return Colour_Bit_Size;
   procedure Set_Alpha_Size (Size : in Colour_Bit_Size);

   function Buffer_Size return Buffer_Sizes;
   procedure Set_Buffer_Size (Size : in Buffer_Sizes);

   function Is_Double_Buffered return Boolean;
   procedure Set_Double_Buffer (On : in Boolean);

   function Depth_Buffer_Size return Depth_Buffer_Sizes;
   procedure Set_Depth_Buffer_Size (Size : in Depth_Buffer_Sizes);

   function Stencil_Buffer_Size return Stencil_Buffer_Sizes;
   procedure Set_Stencil_Buffer_Size (Size : in Stencil_Buffer_Sizes);

   function Accumulator_Red_Size return Colour_Bit_Size;
   procedure Set_Accumulator_Red_Size (Size : in Colour_Bit_Size);

   function Accumulator_Green_Size return Colour_Bit_Size;
   procedure Set_Accumulator_Green_Size (Size : in Colour_Bit_Size);

   function Accumulator_Blue_Size return Colour_Bit_Size;
   procedure Set_Accumulator_Blue_Size (Size : in Colour_Bit_Size);

   function Accumulator_Alpha_Size return Colour_Bit_Size;
   procedure Set_Accumulator_Alpha_Size (Size : in Colour_Bit_Size);

   function Is_Stereo return Boolean;
   procedure Set_Stereo (On : in Boolean);

   function Is_Multisampled return Boolean;
   procedure Set_Multisampling (On : in Boolean);

   function Multisampling_Samples return Multisample_Samples;
   procedure Set_Multisampling_Samples (Samples : in Multisample_Samples);

   function Is_Accelerated return Boolean;
   procedure Set_Accelerated (On : in Boolean);

   function Context_Major_Version return Major_Versions;
   procedure Set_Context_Major_Version (Version : in Major_Versions);

   function Context_Minor_Version return Minor_Versions;
   procedure Set_Context_Minor_Version (Version : in Minor_Versions);

   function Is_Context_EGL return Boolean;
   procedure Set_Context_EGL (On : in Boolean);

   function Context_Flags return Flags;
   procedure Set_Context_Flags (Context_Flags : in Flags);

   function Context_Profile return Profiles;
   procedure Set_Context_Profile (Profile : in Profiles);

   procedure Set_Core_Context_Profile
     (Major : in Major_Versions;
      Minor : in Minor_Versions);

   function Is_Sharing_With_Current_Context return Boolean;
   procedure Set_Share_With_Current_Context (On : in Boolean);

   type Contexts is new Ada.Finalization.Limited_Controlled with private;

   procedure Create
     (Self : in out Contexts;
      From : in SDL.Video.Windows.Window);

   overriding
   procedure Finalize (Self : in out Contexts);

   function Get_Current return Contexts;

   function Get_Current_Window return SDL.Video.Windows.Window;

   procedure Get_Drawable_Size
     (Window        : in SDL.Video.Windows.Window;
      Width, Height : out SDL.Natural_Dimension);

   procedure Set_Current
     (Self : in Contexts;
      To   : in SDL.Video.Windows.Window);

   procedure Bind_Texture
     (Texture : in SDL.Video.Textures.Texture);

   procedure Bind_Texture
     (Texture : in SDL.Video.Textures.Texture;
      Size    : out SDL.Sizes);

   procedure Unbind_Texture
     (Texture : in SDL.Video.Textures.Texture);

   function Get_Proc_Address (Name : in String) return Function_Pointer;

   function Get_Current_Display return EGL_Display;

   function Get_Current_Config return EGL_Config;

   function Get_Window_Surface
     (Window : in SDL.Video.Windows.Window) return EGL_Surface;

   procedure Set_Attribute_Callbacks
     (Platform_Attributes : in EGL_Attribute_Array_Callback := null;
      Surface_Attributes  : in EGL_Integer_Array_Callback := null;
      Context_Attributes  : in EGL_Integer_Array_Callback := null;
      User_Data           : in System.Address := System.Null_Address);

   procedure Reset_Attributes;

   function Supports (Extension : in String) return Boolean;

   generic
      type Access_To_Sub_Program is private;
   function Get_Sub_Program
     (Name : in String) return Access_To_Sub_Program
   with
     Obsolescent;

   generic
      Subprogram_Name : String;
      type Access_To_Sub_Program is private;
   function Get_Subprogram return Access_To_Sub_Program;

   type Swap_Intervals is
     (Adaptive_VSync,
      Not_Synchronised,
      Synchronised)
   with
     Convention => C;

   for Swap_Intervals use
     (Adaptive_VSync   => -1,
      Not_Synchronised => 0,
      Synchronised     => 1);

   subtype Allowed_Swap_Intervals is
     Swap_Intervals range Adaptive_VSync .. Synchronised;

   function Get_Swap_Interval return Swap_Intervals;

   procedure Set_Swap_Interval (Interval : in Allowed_Swap_Intervals);

   procedure Swap (Window : in out SDL.Video.Windows.Window);

   procedure Load_Library;
   procedure Load_Library (Path : in String);
   procedure Unload_Library;
private
   type Contexts is new Ada.Finalization.Limited_Controlled with
      record
         Internal : System.Address := System.Null_Address;
         Owns     : Boolean        := False;
      end record;
end SDL.Video.GL;
