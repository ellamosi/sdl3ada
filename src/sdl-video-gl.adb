with Ada.Unchecked_Conversion;
with Interfaces.C.Extensions;
with Interfaces.C.Strings;

with SDL.Error;
with SDL.Raw.Video;

package body SDL.Video.GL is
   package CE renames Interfaces.C.Extensions;
   package CS renames Interfaces.C.Strings;
   package Raw renames SDL.Raw.Video;

   use type System.Address;

   type Attributes is
     (Attribute_Red_Size,
      Attribute_Green_Size,
      Attribute_Blue_Size,
      Attribute_Alpha_Size,
      Attribute_Buffer_Size,
      Attribute_Double_Buffer,
      Attribute_Depth_Buffer_Size,
      Attribute_Stencil_Size,
      Attribute_Accumulator_Red_Size,
      Attribute_Accumulator_Green_Size,
      Attribute_Accumulator_Blue_Size,
      Attribute_Accumulator_Alpha_Size,
      Attribute_Stereo,
      Attribute_Multisample_Buffers,
      Attribute_Multisample_Samples,
      Attribute_Accelerated,
      Attribute_Retained_Backing,
      Attribute_Context_Major_Version,
      Attribute_Context_Minor_Version,
      Attribute_Context_Flags,
      Attribute_Context_Profile,
      Attribute_Share_With_Current_Context,
      Attribute_EGL_Platform)
   with
     Convention => C,
     Size       => C.int'Size;

   for Attributes use
     (Attribute_Red_Size                  => 0,
      Attribute_Green_Size                => 1,
      Attribute_Blue_Size                 => 2,
      Attribute_Alpha_Size                => 3,
      Attribute_Buffer_Size               => 4,
      Attribute_Double_Buffer             => 5,
      Attribute_Depth_Buffer_Size         => 6,
      Attribute_Stencil_Size              => 7,
      Attribute_Accumulator_Red_Size      => 8,
      Attribute_Accumulator_Green_Size    => 9,
      Attribute_Accumulator_Blue_Size     => 10,
      Attribute_Accumulator_Alpha_Size    => 11,
      Attribute_Stereo                    => 12,
      Attribute_Multisample_Buffers       => 13,
      Attribute_Multisample_Samples       => 14,
      Attribute_Accelerated               => 15,
      Attribute_Retained_Backing          => 16,
      Attribute_Context_Major_Version     => 17,
      Attribute_Context_Minor_Version     => 18,
      Attribute_Context_Flags             => 19,
      Attribute_Context_Profile           => 20,
      Attribute_Share_With_Current_Context => 21,
      Attribute_EGL_Platform              => 27);

   function To_Int is new Ada.Unchecked_Conversion
     (Source => Profiles,
      Target => C.int);

   function To_Raw (Value : in Attributes) return Raw.GL_Attribute is
     (Raw.GL_Attribute'Val (Attributes'Pos (Value)));

   function Get_Attribute_Int (Attr : in Attributes) return C.int;
   function Get_Attribute_Int (Attr : in Attributes) return C.int is
      Value : aliased C.int := 0;
   begin
      if not Boolean (Raw.Get_GL_Attribute (To_Raw (Attr), Value'Access)) then
         raise SDL_GL_Error with SDL.Error.Get;
      end if;

      return Value;
   end Get_Attribute_Int;

   procedure Set_Attribute_Int
     (Attr  : in Attributes;
      Value : in C.int);
   procedure Set_Attribute_Int
     (Attr  : in Attributes;
      Value : in C.int)
   is
   begin
      if not Boolean (Raw.Set_GL_Attribute (To_Raw (Attr), Value)) then
         raise SDL_GL_Error with SDL.Error.Get;
      end if;
   end Set_Attribute_Int;

   function Get_Attribute_Boolean (Attr : in Attributes) return Boolean is
     (Get_Attribute_Int (Attr) /= 0);

   procedure Set_Attribute_Boolean
     (Attr : in Attributes;
      On   : in Boolean) is
   begin
      Set_Attribute_Int (Attr, (if On then 1 else 0));
   end Set_Attribute_Boolean;

   function Red_Size return Colour_Bit_Size is
     (Colour_Bit_Size (Get_Attribute_Int (Attribute_Red_Size)));

   procedure Set_Red_Size (Size : in Colour_Bit_Size) is
   begin
      Set_Attribute_Int (Attribute_Red_Size, C.int (Size));
   end Set_Red_Size;

   function Green_Size return Colour_Bit_Size is
     (Colour_Bit_Size (Get_Attribute_Int (Attribute_Green_Size)));

   procedure Set_Green_Size (Size : in Colour_Bit_Size) is
   begin
      Set_Attribute_Int (Attribute_Green_Size, C.int (Size));
   end Set_Green_Size;

   function Blue_Size return Colour_Bit_Size is
     (Colour_Bit_Size (Get_Attribute_Int (Attribute_Blue_Size)));

   procedure Set_Blue_Size (Size : in Colour_Bit_Size) is
   begin
      Set_Attribute_Int (Attribute_Blue_Size, C.int (Size));
   end Set_Blue_Size;

   function Alpha_Size return Colour_Bit_Size is
     (Colour_Bit_Size (Get_Attribute_Int (Attribute_Alpha_Size)));

   procedure Set_Alpha_Size (Size : in Colour_Bit_Size) is
   begin
      Set_Attribute_Int (Attribute_Alpha_Size, C.int (Size));
   end Set_Alpha_Size;

   function Buffer_Size return Buffer_Sizes is
     (Buffer_Sizes (Get_Attribute_Int (Attribute_Buffer_Size)));

   procedure Set_Buffer_Size (Size : in Buffer_Sizes) is
   begin
      Set_Attribute_Int (Attribute_Buffer_Size, C.int (Size));
   end Set_Buffer_Size;

   function Is_Double_Buffered return Boolean is
     (Get_Attribute_Boolean (Attribute_Double_Buffer));

   procedure Set_Double_Buffer (On : in Boolean) is
   begin
      Set_Attribute_Boolean (Attribute_Double_Buffer, On);
   end Set_Double_Buffer;

   function Depth_Buffer_Size return Depth_Buffer_Sizes is
     (Depth_Buffer_Sizes (Get_Attribute_Int (Attribute_Depth_Buffer_Size)));

   procedure Set_Depth_Buffer_Size (Size : in Depth_Buffer_Sizes) is
   begin
      Set_Attribute_Int (Attribute_Depth_Buffer_Size, C.int (Size));
   end Set_Depth_Buffer_Size;

   function Stencil_Buffer_Size return Stencil_Buffer_Sizes is
     (Stencil_Buffer_Sizes (Get_Attribute_Int (Attribute_Stencil_Size)));

   procedure Set_Stencil_Buffer_Size (Size : in Stencil_Buffer_Sizes) is
   begin
      Set_Attribute_Int (Attribute_Stencil_Size, C.int (Size));
   end Set_Stencil_Buffer_Size;

   function Accumulator_Red_Size return Colour_Bit_Size is
     (Colour_Bit_Size (Get_Attribute_Int (Attribute_Accumulator_Red_Size)));

   procedure Set_Accumulator_Red_Size (Size : in Colour_Bit_Size) is
   begin
      Set_Attribute_Int (Attribute_Accumulator_Red_Size, C.int (Size));
   end Set_Accumulator_Red_Size;

   function Accumulator_Green_Size return Colour_Bit_Size is
     (Colour_Bit_Size (Get_Attribute_Int (Attribute_Accumulator_Green_Size)));

   procedure Set_Accumulator_Green_Size (Size : in Colour_Bit_Size) is
   begin
      Set_Attribute_Int (Attribute_Accumulator_Green_Size, C.int (Size));
   end Set_Accumulator_Green_Size;

   function Accumulator_Blue_Size return Colour_Bit_Size is
     (Colour_Bit_Size (Get_Attribute_Int (Attribute_Accumulator_Blue_Size)));

   procedure Set_Accumulator_Blue_Size (Size : in Colour_Bit_Size) is
   begin
      Set_Attribute_Int (Attribute_Accumulator_Blue_Size, C.int (Size));
   end Set_Accumulator_Blue_Size;

   function Accumulator_Alpha_Size return Colour_Bit_Size is
     (Colour_Bit_Size (Get_Attribute_Int (Attribute_Accumulator_Alpha_Size)));

   procedure Set_Accumulator_Alpha_Size (Size : in Colour_Bit_Size) is
   begin
      Set_Attribute_Int (Attribute_Accumulator_Alpha_Size, C.int (Size));
   end Set_Accumulator_Alpha_Size;

   function Is_Stereo return Boolean is
     (Get_Attribute_Boolean (Attribute_Stereo));

   procedure Set_Stereo (On : in Boolean) is
   begin
      Set_Attribute_Boolean (Attribute_Stereo, On);
   end Set_Stereo;

   function Is_Multisampled return Boolean is
     (Get_Attribute_Boolean (Attribute_Multisample_Buffers));

   procedure Set_Multisampling (On : in Boolean) is
   begin
      Set_Attribute_Boolean (Attribute_Multisample_Buffers, On);
   end Set_Multisampling;

   function Multisampling_Samples return Multisample_Samples is
     (Multisample_Samples (Get_Attribute_Int (Attribute_Multisample_Samples)));

   procedure Set_Multisampling_Samples
     (Samples : in Multisample_Samples) is
   begin
      Set_Attribute_Int (Attribute_Multisample_Samples, C.int (Samples));
   end Set_Multisampling_Samples;

   function Is_Accelerated return Boolean is
     (Get_Attribute_Boolean (Attribute_Accelerated));

   procedure Set_Accelerated (On : in Boolean) is
   begin
      Set_Attribute_Boolean (Attribute_Accelerated, On);
   end Set_Accelerated;

   function Context_Major_Version return Major_Versions is
     (Major_Versions (Get_Attribute_Int (Attribute_Context_Major_Version)));

   procedure Set_Context_Major_Version
     (Version : in Major_Versions) is
   begin
      Set_Attribute_Int (Attribute_Context_Major_Version, C.int (Version));
   end Set_Context_Major_Version;

   function Context_Minor_Version return Minor_Versions is
     (Minor_Versions (Get_Attribute_Int (Attribute_Context_Minor_Version)));

   procedure Set_Context_Minor_Version
     (Version : in Minor_Versions) is
   begin
      Set_Attribute_Int (Attribute_Context_Minor_Version, C.int (Version));
   end Set_Context_Minor_Version;

   function Is_Context_EGL return Boolean is
     (Get_Attribute_Int (Attribute_EGL_Platform) /= 0);

   procedure Set_Context_EGL (On : in Boolean) is
   begin
      if not On then
         Set_Attribute_Int (Attribute_EGL_Platform, 0);
         return;
      end if;

      raise SDL_GL_Error with
        "SDL3 removed the SDL2-style boolean EGL selector; use SDL3 EGL "
        & "platform configuration instead";
   end Set_Context_EGL;

   function Context_Flags return Flags is
     (Flags (C.unsigned (Get_Attribute_Int (Attribute_Context_Flags))));

   procedure Set_Context_Flags
     (Context_Flags : in Flags) is
   begin
      Set_Attribute_Int
        (Attribute_Context_Flags, C.int (Interfaces.Unsigned_32 (Context_Flags)));
   end Set_Context_Flags;

   function Context_Profile return Profiles is
      Value : constant C.int := Get_Attribute_Int (Attribute_Context_Profile);
   begin
      case Value is
         when 16#0000_0001# =>
            return Core;
         when 16#0000_0002# =>
            return Compatibility;
         when 16#0000_0004# =>
            return ES;
         when others =>
            raise SDL_GL_Error with "Unknown OpenGL profile mask";
      end case;
   end Context_Profile;

   procedure Set_Context_Profile (Profile : in Profiles) is
   begin
      Set_Attribute_Int (Attribute_Context_Profile, To_Int (Profile));
   end Set_Context_Profile;

   procedure Set_Core_Context_Profile
     (Major : in Major_Versions;
      Minor : in Minor_Versions) is
   begin
      Set_Context_Profile (Core);
      Set_Context_Major_Version (Major);
      Set_Context_Minor_Version (Minor);
   end Set_Core_Context_Profile;

   function Is_Sharing_With_Current_Context return Boolean is
     (Get_Attribute_Boolean (Attribute_Share_With_Current_Context));

   procedure Set_Share_With_Current_Context
     (On : in Boolean) is
   begin
      Set_Attribute_Boolean (Attribute_Share_With_Current_Context, On);
   end Set_Share_With_Current_Context;

   procedure Create
     (Self : in out Contexts;
      From : in SDL.Video.Windows.Window)
   is
      Context : constant System.Address :=
        Raw.Create_GL_Context (SDL.Video.Windows.Get_Internal (From));
   begin
      if Context = System.Null_Address then
         raise SDL_GL_Error with SDL.Error.Get;
      end if;

      Self.Internal := Context;
      Self.Owns := True;
   end Create;

   overriding
   procedure Finalize (Self : in out Contexts) is
      Ignored : CE.bool;
   begin
      if Self.Owns and then Self.Internal /= System.Null_Address then
         Ignored := Raw.Destroy_GL_Context (Self.Internal);
         pragma Unreferenced (Ignored);
      end if;

      Self.Internal := System.Null_Address;
      Self.Owns := False;
   end Finalize;

   function Get_Current return Contexts is
   begin
      return Result : constant Contexts :=
        (Ada.Finalization.Limited_Controlled with
         Internal => Raw.Get_Current_GL_Context,
         Owns     => False)
      do
         if Result.Internal = System.Null_Address then
            raise SDL_GL_Error with SDL.Error.Get;
         end if;
      end return;
   end Get_Current;

   function Get_Current_Window return SDL.Video.Windows.Window is
      Window_Ptr : constant System.Address := Raw.Get_Current_GL_Window;
   begin
      if Window_Ptr = System.Null_Address then
         return SDL.Video.Windows.Get (0);
      end if;

      return SDL.Video.Windows.Get
        (SDL.Video.Windows.ID (Raw.Get_Window_ID (Window_Ptr)));
   end Get_Current_Window;

   procedure Get_Drawable_Size
     (Window        : in SDL.Video.Windows.Window;
      Width, Height : out SDL.Natural_Dimension)
   is
      Raw_Width  : aliased C.int := 0;
      Raw_Height : aliased C.int := 0;
   begin
      if not Boolean
          (Raw.Get_Window_Size_In_Pixels
             (SDL.Video.Windows.Get_Internal (Window),
              Raw_Width'Access,
              Raw_Height'Access))
      then
         raise SDL_GL_Error with SDL.Error.Get;
      end if;

      Width := SDL.Natural_Dimension (Raw_Width);
      Height := SDL.Natural_Dimension (Raw_Height);
   end Get_Drawable_Size;

   procedure Set_Current
     (Self : in Contexts;
      To   : in SDL.Video.Windows.Window)
   is
   begin
      if not Boolean
          (Raw.Make_GL_Current
             (SDL.Video.Windows.Get_Internal (To), Self.Internal))
      then
         raise SDL_GL_Error with SDL.Error.Get;
      end if;
   end Set_Current;

   procedure Bind_Texture
     (Texture : in SDL.Video.Textures.Texture) is
   begin
      pragma Unreferenced (Texture);
      raise SDL_GL_Error with
        "SDL_GL_BindTexture was removed in SDL3 and is not emulated";
   end Bind_Texture;

   procedure Bind_Texture
     (Texture : in SDL.Video.Textures.Texture;
      Size    : out SDL.Sizes) is
   begin
      pragma Unreferenced (Texture);
      Size := SDL.Zero_Size;

      raise SDL_GL_Error with
        "SDL_GL_BindTexture was removed in SDL3 and is not emulated";
   end Bind_Texture;

   procedure Unbind_Texture
     (Texture : in SDL.Video.Textures.Texture) is
   begin
      pragma Unreferenced (Texture);
      raise SDL_GL_Error with
        "SDL_GL_UnbindTexture was removed in SDL3 and is not emulated";
   end Unbind_Texture;

   function Get_Proc_Address (Name : in String) return Function_Pointer is
   begin
      return Raw.EGL_Get_Proc_Address (C.To_C (Name));
   end Get_Proc_Address;

   function Get_Current_Display return EGL_Display is
   begin
      return Raw.Get_Current_EGL_Display;
   end Get_Current_Display;

   function Get_Current_Config return EGL_Config is
   begin
      return Raw.Get_Current_EGL_Config;
   end Get_Current_Config;

   function Get_Window_Surface
     (Window : in SDL.Video.Windows.Window) return EGL_Surface
   is
   begin
      if SDL.Video.Windows.Is_Null (Window) then
         return System.Null_Address;
      end if;

      return Raw.Get_EGL_Window_Surface (SDL.Video.Windows.Get_Internal (Window));
   end Get_Window_Surface;

   procedure Set_Attribute_Callbacks
     (Platform_Attributes : in EGL_Attribute_Array_Callback := null;
      Surface_Attributes  : in EGL_Integer_Array_Callback := null;
      Context_Attributes  : in EGL_Integer_Array_Callback := null;
      User_Data           : in System.Address := System.Null_Address)
   is
      function To_Raw is new Ada.Unchecked_Conversion
        (Source => EGL_Attribute_Array_Callback,
         Target => Raw.EGL_Attribute_Array_Callback);

      function To_Raw is new Ada.Unchecked_Conversion
        (Source => EGL_Integer_Array_Callback,
         Target => Raw.EGL_Integer_Array_Callback);
   begin
      Raw.Set_EGL_Attribute_Callbacks
        (Platform_Attributes => To_Raw (Platform_Attributes),
         Surface_Attributes  => To_Raw (Surface_Attributes),
         Context_Attributes  => To_Raw (Context_Attributes),
         User_Data           => User_Data);
   end Set_Attribute_Callbacks;

   procedure Reset_Attributes is
   begin
      Raw.Reset_GL_Attributes;
   end Reset_Attributes;

   function Get_Sub_Program
     (Name : in String) return Access_To_Sub_Program is
      function To_Sub_Program is new Ada.Unchecked_Conversion
        (Source => System.Address,
         Target => Access_To_Sub_Program);
   begin
      return To_Sub_Program (Raw.GL_Get_Proc_Address (C.To_C (Name)));
   end Get_Sub_Program;

   function Get_Subprogram return Access_To_Sub_Program is
      function To_Sub_Program is new Ada.Unchecked_Conversion
        (Source => System.Address,
         Target => Access_To_Sub_Program);
   begin
      return To_Sub_Program (Raw.GL_Get_Proc_Address (C.To_C (Subprogram_Name)));
   end Get_Subprogram;

   function Supports (Extension : in String) return Boolean is
      C_Name : CS.chars_ptr := CS.New_String (Extension);
      Result : constant Boolean :=
        Boolean (Raw.GL_Extension_Supported (C_Name));
   begin
      CS.Free (C_Name);
      return Result;
   end Supports;

   function Get_Swap_Interval return Swap_Intervals is
      Interval : aliased C.int := 0;
      Ignored  : constant CE.bool :=
        Raw.Get_GL_Swap_Interval (Interval'Access);
      pragma Unreferenced (Ignored);
   begin
      case Interval is
         when -1 =>
            return Adaptive_VSync;
         when 1 =>
            return Synchronised;
         when others =>
            return Not_Synchronised;
      end case;
   end Get_Swap_Interval;

   procedure Set_Swap_Interval
     (Interval : in Allowed_Swap_Intervals) is
   begin
      if not Boolean
          (Raw.Set_GL_Swap_Interval
             (case Interval is
                 when Adaptive_VSync   => -1,
                 when Not_Synchronised => 0,
                 when Synchronised     => 1))
      then
         raise SDL_GL_Error with SDL.Error.Get;
      end if;
   end Set_Swap_Interval;

   procedure Swap (Window : in out SDL.Video.Windows.Window) is
   begin
      if not Boolean
          (Raw.Swap_GL_Window (SDL.Video.Windows.Get_Internal (Window)))
      then
         raise SDL_GL_Error with SDL.Error.Get;
      end if;
   end Swap;

   procedure Load_Library is
   begin
      if not Boolean (Raw.Load_GL_Library (CS.Null_Ptr)) then
         raise SDL_GL_Error with SDL.Error.Get;
      end if;
   end Load_Library;

   procedure Load_Library (Path : in String) is
   begin
      if not Boolean (Raw.Load_GL_Library (C.To_C (Path))) then
         raise SDL_GL_Error with SDL.Error.Get;
      end if;
   end Load_Library;

   procedure Unload_Library is
   begin
      Raw.Unload_GL_Library;
   end Unload_Library;
end SDL.Video.GL;
