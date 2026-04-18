with Interfaces;
with Interfaces.C;
with Interfaces.C.Extensions;
with Interfaces.C.Pointers;
with Interfaces.C.Strings;
with System;

with SDL.Raw.Properties;

package SDL.Raw.Video is
   pragma Preelaborate;

   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;
   package CS renames Interfaces.C.Strings;

   type Display_ID is mod 2 ** 32 with
     Convention => C,
     Size       => 32;

   subtype Pixel_Format_Name is Interfaces.Unsigned_32;

   type Display_Mode is record
      Display              : Display_ID;
      Format               : Pixel_Format_Name;
      Width                : C.int;
      Height               : C.int;
      Pixel_Density        : C.C_float;
      Refresh_Rate         : C.C_float;
      Refresh_Numerator    : C.int;
      Refresh_Denominator  : C.int;
      Internal             : System.Address;
   end record with
     Convention => C;

   type Display_Mode_Access is access all Display_Mode with
     Convention => C;

   type Display_Orientation is
     (Orientation_Unknown,
      Orientation_Landscape,
      Orientation_Landscape_Flipped,
      Orientation_Portrait,
      Orientation_Portrait_Flipped)
   with
     Convention => C,
     Size       => C.int'Size;

   for Display_Orientation use
     (Orientation_Unknown            => 0,
      Orientation_Landscape          => 1,
      Orientation_Landscape_Flipped  => 2,
      Orientation_Portrait           => 3,
      Orientation_Portrait_Flipped   => 4);

   type Display_ID_Array is array (C.ptrdiff_t range <>) of aliased Display_ID with
     Convention => C;

   package Display_ID_Pointers is new Interfaces.C.Pointers
     (Index              => C.ptrdiff_t,
      Element            => Display_ID,
      Element_Array      => Display_ID_Array,
      Default_Terminator => 0);

   type Display_Mode_Pointer_Array is
     array (C.ptrdiff_t range <>) of aliased Display_Mode_Access with
       Convention => C;

   package Display_Mode_Pointers is new Interfaces.C.Pointers
     (Index              => C.ptrdiff_t,
      Element            => Display_Mode_Access,
      Element_Array      => Display_Mode_Pointer_Array,
      Default_Terminator => null);

   type GL_Attribute is
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

   for GL_Attribute use
     (Attribute_Red_Size                   => 0,
      Attribute_Green_Size                 => 1,
      Attribute_Blue_Size                  => 2,
      Attribute_Alpha_Size                 => 3,
      Attribute_Buffer_Size                => 4,
      Attribute_Double_Buffer              => 5,
      Attribute_Depth_Buffer_Size          => 6,
      Attribute_Stencil_Size               => 7,
      Attribute_Accumulator_Red_Size       => 8,
      Attribute_Accumulator_Green_Size     => 9,
      Attribute_Accumulator_Blue_Size      => 10,
      Attribute_Accumulator_Alpha_Size     => 11,
      Attribute_Stereo                     => 12,
      Attribute_Multisample_Buffers        => 13,
      Attribute_Multisample_Samples        => 14,
      Attribute_Accelerated                => 15,
      Attribute_Retained_Backing           => 16,
      Attribute_Context_Major_Version      => 17,
      Attribute_Context_Minor_Version      => 18,
      Attribute_Context_Flags              => 19,
      Attribute_Context_Profile            => 20,
      Attribute_Share_With_Current_Context => 21,
      Attribute_EGL_Platform               => 27);

   type EGL_Attribute_Array_Callback is access function
     (User_Data : in System.Address) return System.Address
   with Convention => C;

   type EGL_Integer_Array_Callback is access function
     (User_Data : in System.Address;
      Display   : in System.Address;
      Config    : in System.Address) return System.Address
   with Convention => C;

   type Window_ID is mod 2 ** 32 with
     Convention => C,
     Size       => 32;

   subtype Window_Flags is Interfaces.Unsigned_64;
   subtype Flash_Operation is C.int;
   subtype Progress_State is C.int;
   subtype Window_Surface_V_Sync_Interval is C.int;
   subtype Hit_Test_Result is C.int;
   subtype Blend_Mode is Interfaces.Unsigned_32;

   type Window_Hit_Test_Point is
      record
         X : C.int;
         Y : C.int;
      end record
   with Convention => C;

   type Window_Hit_Test_Point_Access is
     access constant Window_Hit_Test_Point
   with Convention => C;

   type Window_Hit_Test_Callback is access function
     (Win       : in System.Address;
      Area      : in Window_Hit_Test_Point_Access;
      User_Data : in System.Address) return Hit_Test_Result
   with Convention => C;

   type Blend_Operation is
     (Add_Operation,
      Subtract_Operation,
      Reverse_Subtract_Operation,
      Minimum_Operation,
      Maximum_Operation)
   with
     Convention => C,
     Size       => C.int'Size;

   for Blend_Operation use
     (Add_Operation              => 16#1#,
      Subtract_Operation         => 16#2#,
      Reverse_Subtract_Operation => 16#3#,
      Minimum_Operation          => 16#4#,
      Maximum_Operation          => 16#5#);

   type Blend_Factor is
     (Zero_Factor,
      One_Factor,
      Source_Colour_Factor,
      One_Minus_Source_Colour_Factor,
      Source_Alpha_Factor,
      One_Minus_Source_Alpha_Factor,
      Destination_Colour_Factor,
      One_Minus_Destination_Colour_Factor,
      Destination_Alpha_Factor,
      One_Minus_Destination_Alpha_Factor)
   with
     Convention => C,
     Size       => C.int'Size;

   for Blend_Factor use
     (Zero_Factor                        => 16#1#,
      One_Factor                         => 16#2#,
      Source_Colour_Factor               => 16#3#,
      One_Minus_Source_Colour_Factor     => 16#4#,
      Source_Alpha_Factor                => 16#5#,
      One_Minus_Source_Alpha_Factor      => 16#6#,
      Destination_Colour_Factor          => 16#7#,
      One_Minus_Destination_Colour_Factor => 16#8#,
      Destination_Alpha_Factor           => 16#9#,
      One_Minus_Destination_Alpha_Factor => 16#A#);

   type System_Theme is
     (Unknown_Theme,
      Light_Theme,
      Dark_Theme)
   with
     Convention => C,
     Size       => C.int'Size;

   function Get_Num_Video_Drivers return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetNumVideoDrivers";

   function Get_Video_Driver
     (Index : in C.int) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetVideoDriver";

   function Get_Current_Video_Driver return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetCurrentVideoDriver";

   function Get_System_Theme return System_Theme
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetSystemTheme";

   function Compose_Custom_Blend_Mode
     (Source_Colour_Factor      : in Blend_Factor;
      Destination_Colour_Factor : in Blend_Factor;
      Colour_Operation          : in Blend_Operation;
      Source_Alpha_Factor       : in Blend_Factor;
      Destination_Alpha_Factor  : in Blend_Factor;
      Alpha_Operation           : in Blend_Operation) return Blend_Mode
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ComposeCustomBlendMode";

   function Screen_Saver_Enabled return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ScreenSaverEnabled";

   function Enable_Screen_Saver return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_EnableScreenSaver";

   function Disable_Screen_Saver return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_DisableScreenSaver";

   function Set_GL_Attribute
     (Attr  : in GL_Attribute;
      Value : in C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GL_SetAttribute";

   function Get_GL_Attribute
     (Attr  : in GL_Attribute;
      Value : access C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GL_GetAttribute";

   function Get_Displays
     (Count : access C.int) return Display_ID_Pointers.Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetDisplays";

   function Get_Primary_Display return Display_ID
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetPrimaryDisplay";

   procedure Free (Values : in Display_ID_Pointers.Pointer)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_free";

   procedure Free (Values : in Display_Mode_Pointers.Pointer)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_free";

   procedure Free (Value : in System.Address)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_free";

   function Get_Display_Name
     (ID : in Display_ID) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetDisplayName";

   function Get_Display_Properties
     (ID : in Display_ID) return SDL.Raw.Properties.ID
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetDisplayProperties";

   function Get_Closest_Fullscreen_Display_Mode
     (ID                         : in Display_ID;
      Width                      : in C.int;
      Height                     : in C.int;
      Refresh_Rate               : in C.C_float;
      Include_High_Density_Modes : in CE.bool;
      Closest                    : access Display_Mode) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetClosestFullscreenDisplayMode";

   function Get_Display_For_Point
     (Point : in System.Address) return Display_ID
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetDisplayForPoint";

   function Get_Display_For_Rect
     (Area : in System.Address) return Display_ID
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetDisplayForRect";

   function Get_Current_Display_Mode
     (ID : in Display_ID) return Display_Mode_Access
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetCurrentDisplayMode";

   function Get_Desktop_Display_Mode
     (ID : in Display_ID) return Display_Mode_Access
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetDesktopDisplayMode";

   function Get_Fullscreen_Display_Modes
     (ID    : in Display_ID;
      Count : access C.int) return Display_Mode_Pointers.Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetFullscreenDisplayModes";

   function Get_Display_Bounds
     (ID     : in Display_ID;
      Bounds : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetDisplayBounds";

   function Get_Display_Usable_Bounds
     (ID     : in Display_ID;
      Bounds : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetDisplayUsableBounds";

   function Get_Display_Content_Scale
     (ID : in Display_ID) return C.C_float
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetDisplayContentScale";

   function Get_Current_Display_Orientation
     (ID : in Display_ID) return Display_Orientation
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetCurrentDisplayOrientation";

   function Get_Natural_Display_Orientation
     (ID : in Display_ID) return Display_Orientation
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetNaturalDisplayOrientation";

   function Create_GL_Context
     (Window : in System.Address) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GL_CreateContext";

   function Destroy_GL_Context
     (Context : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GL_DestroyContext";

   function Get_Current_GL_Context return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GL_GetCurrentContext";

   function Get_Current_GL_Window return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GL_GetCurrentWindow";

   function Make_GL_Current
     (Window  : in System.Address;
      Context : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GL_MakeCurrent";

   function EGL_Get_Proc_Address
     (Proc : in C.char_array) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_EGL_GetProcAddress";

   function Get_Current_EGL_Display return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_EGL_GetCurrentDisplay";

   function Get_Current_EGL_Config return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_EGL_GetCurrentConfig";

   function Get_EGL_Window_Surface
     (Value : in System.Address) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_EGL_GetWindowSurface";

   procedure Set_EGL_Attribute_Callbacks
     (Platform_Attributes : in EGL_Attribute_Array_Callback;
      Surface_Attributes  : in EGL_Integer_Array_Callback;
      Context_Attributes  : in EGL_Integer_Array_Callback;
      User_Data           : in System.Address)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_EGL_SetAttributeCallbacks";

   procedure Reset_GL_Attributes
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GL_ResetAttributes";

   function GL_Get_Proc_Address
     (Proc : in C.char_array) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GL_GetProcAddress";

   function GL_Extension_Supported
     (Name : in CS.chars_ptr) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GL_ExtensionSupported";

   function Get_GL_Swap_Interval
     (Interval : access C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GL_GetSwapInterval";

   function Set_GL_Swap_Interval
     (Value : in C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GL_SetSwapInterval";

   function Swap_GL_Window
     (Value : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GL_SwapWindow";

   function Load_GL_Library
     (Path : in CS.chars_ptr) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GL_LoadLibrary";

   function Load_GL_Library
     (Value : in C.char_array) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GL_LoadLibrary";

   procedure Unload_GL_Library
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GL_UnloadLibrary";

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

   function Get_Window_From_ID
     (ID : in Window_ID) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetWindowFromID";

   function Get_Windows
     (Count : access C.int) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetWindows";

   function Get_Display_For_Window
     (Value : in System.Address) return Display_ID
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetDisplayForWindow";

   function Get_Window_Size_In_Pixels
     (Value  : in System.Address;
      Width  : access C.int;
      Height : access C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetWindowSizeInPixels";

   function Get_Window_Flags
     (Value : in System.Address) return Window_Flags
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetWindowFlags";

   function Get_Window_Title
     (Value : in System.Address) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetWindowTitle";

   function Set_Window_Title
     (Value : in System.Address;
      Text  : in C.char_array) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetWindowTitle";

   function Get_Window_Surface
     (Value : in System.Address) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetWindowSurface";

   function Set_Window_Icon
     (Value : in System.Address;
      Icon  : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetWindowIcon";

   function Get_Window_Position
     (Value : in System.Address;
      X     : access C.int;
      Y     : access C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetWindowPosition";

   function Set_Window_Position
     (Value : in System.Address;
      X     : in C.int;
      Y     : in C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetWindowPosition";

   function Get_Window_Size
     (Value  : in System.Address;
      Width  : access C.int;
      Height : access C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetWindowSize";

   function Set_Window_Size
     (Value  : in System.Address;
      Width  : in C.int;
      Height : in C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetWindowSize";

   function Get_Window_Pixel_Density
     (Value : in System.Address) return C.C_float
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetWindowPixelDensity";

   function Get_Window_Display_Scale
     (Value : in System.Address) return C.C_float
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetWindowDisplayScale";

   function Set_Window_Fullscreen_Mode
     (Value : in System.Address;
      Mode  : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetWindowFullscreenMode";

   function Get_Closest_Fullscreen_Display_Mode
     (ID                         : in Display_ID;
      Width                      : in C.int;
      Height                     : in C.int;
      Refresh_Rate               : in C.C_float;
      Include_High_Density_Modes : in CE.bool;
      Closest                    : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetClosestFullscreenDisplayMode";

   function Get_Window_Fullscreen_Mode
     (Value : in System.Address) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetWindowFullscreenMode";

   function Get_Window_ICC_Profile
     (Value : in System.Address;
      Size  : access C.size_t) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetWindowICCProfile";

   function Get_Window_Pixel_Format
     (Value : in System.Address) return Pixel_Format_Name
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetWindowPixelFormat";

   function Get_Window_Safe_Area
     (Value : in System.Address;
      Area  : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetWindowSafeArea";

   function Set_Window_Aspect_Ratio
     (Value   : in System.Address;
      Minimum : in C.C_float;
      Maximum : in C.C_float) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetWindowAspectRatio";

   function Get_Window_Aspect_Ratio
     (Value   : in System.Address;
      Minimum : access C.C_float;
      Maximum : access C.C_float) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetWindowAspectRatio";

   function Get_Window_Borders_Size
     (Value  : in System.Address;
      Top    : access C.int;
      Left   : access C.int;
      Bottom : access C.int;
      Right  : access C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetWindowBordersSize";

   function Get_Window_Minimum_Size
     (Value  : in System.Address;
      Width  : access C.int;
      Height : access C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetWindowMinimumSize";

   function Set_Window_Minimum_Size
     (Value  : in System.Address;
      Width  : in C.int;
      Height : in C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetWindowMinimumSize";

   function Get_Window_Maximum_Size
     (Value  : in System.Address;
      Width  : access C.int;
      Height : access C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetWindowMaximumSize";

   function Set_Window_Maximum_Size
     (Value  : in System.Address;
      Width  : in C.int;
      Height : in C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetWindowMaximumSize";

   function Set_Window_Bordered
     (Value    : in System.Address;
      Bordered : in CE.bool) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetWindowBordered";

   function Set_Window_Resizable
     (Value     : in System.Address;
      Resizable : in CE.bool) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetWindowResizable";

   function Set_Window_Always_On_Top
     (Value  : in System.Address;
      Enable : in CE.bool) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetWindowAlwaysOnTop";

   function Set_Window_Fill_Document
     (Value  : in System.Address;
      Enable : in CE.bool) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetWindowFillDocument";

   function Show_Window
     (Value : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ShowWindow";

   function Hide_Window
     (Value : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_HideWindow";

   function Maximize_Window
     (Value : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_MaximizeWindow";

   function Minimize_Window
     (Value : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_MinimizeWindow";

   function Raise_Window
     (Value : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_RaiseWindow";

   function Restore_Window
     (Value : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_RestoreWindow";

   function Set_Window_Fullscreen
     (Value      : in System.Address;
      Fullscreen : in CE.bool) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetWindowFullscreen";

   function Sync_Window
     (Value : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SyncWindow";

   function Window_Has_Surface
     (Value : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_WindowHasSurface";

   function Set_Window_Surface_VSync
     (Value    : in System.Address;
      Interval : in Window_Surface_V_Sync_Interval) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetWindowSurfaceVSync";

   function Get_Window_Surface_VSync
     (Value    : in System.Address;
      Interval : access Window_Surface_V_Sync_Interval) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetWindowSurfaceVSync";

   function Update_Window_Surface
     (Value : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_UpdateWindowSurface";

   function Update_Window_Surface_Rects
     (Value      : in System.Address;
      Rectangles : in System.Address;
      Total      : in C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_UpdateWindowSurfaceRects";

   function Destroy_Window_Surface
     (Value : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_DestroyWindowSurface";

   function Set_Window_Keyboard_Grab
     (Value   : in System.Address;
      Grabbed : in CE.bool) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetWindowKeyboardGrab";

   function Get_Window_Keyboard_Grab
     (Value : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetWindowKeyboardGrab";

   function Set_Window_Mouse_Grab
     (Value   : in System.Address;
      Grabbed : in CE.bool) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetWindowMouseGrab";

   function Get_Window_Mouse_Grab
     (Value : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetWindowMouseGrab";

   function Get_Grabbed_Window return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGrabbedWindow";

   function Set_Window_Mouse_Rect
     (Value     : in System.Address;
      Rectangle : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetWindowMouseRect";

   function Get_Window_Mouse_Rect
     (Value : in System.Address) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetWindowMouseRect";

   function Set_Window_Opacity
     (Value   : in System.Address;
      Opacity : in C.C_float) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetWindowOpacity";

   function Get_Window_Opacity
     (Value : in System.Address) return C.C_float
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetWindowOpacity";

   function Set_Window_Parent
     (Value  : in System.Address;
      Parent : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetWindowParent";

   function Get_Window_Parent
     (Value : in System.Address) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetWindowParent";

   function Set_Window_Modal
     (Value : in System.Address;
      Modal : in CE.bool) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetWindowModal";

   function Set_Window_Focusable
     (Value     : in System.Address;
      Focusable : in CE.bool) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetWindowFocusable";

   function Show_Window_System_Menu
     (Value : in System.Address;
      X     : in C.int;
      Y     : in C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ShowWindowSystemMenu";

   function Set_Window_Hit_Test
     (Value     : in System.Address;
      Callback  : in Window_Hit_Test_Callback;
      User_Data : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetWindowHitTest";

   function Set_Window_Shape
     (Value : in System.Address;
      Shape : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetWindowShape";

   function Flash_Window
     (Value     : in System.Address;
      Operation : in Flash_Operation) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_FlashWindow";

   function Set_Window_Progress_State
     (Value : in System.Address;
      State : in Progress_State) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetWindowProgressState";

   function Get_Window_Progress_State
     (Value : in System.Address) return Progress_State
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetWindowProgressState";

   function Set_Window_Progress_Value
     (Value : in System.Address;
      Scale : in C.C_float) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetWindowProgressValue";

   function Get_Window_Progress_Value
     (Value : in System.Address) return C.C_float
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetWindowProgressValue";

   procedure Destroy_Window
     (Value : in System.Address)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_DestroyWindow";
end SDL.Raw.Video;
