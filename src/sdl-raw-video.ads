with Interfaces;
with Interfaces.C;
with Interfaces.C.Extensions;
with Interfaces.C.Strings;
with System;

with SDL.Raw.Properties;

package SDL.Raw.Video is
   pragma Preelaborate;

   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;
   package CS renames Interfaces.C.Strings;

   type Window_ID is mod 2 ** 32 with
     Convention => C,
     Size       => 32;

   subtype Window_Flags is Interfaces.Unsigned_64;
   subtype Blend_Mode is Interfaces.Unsigned_32;

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

   function Get_Window_Size_In_Pixels
     (Value  : in System.Address;
      Width  : access C.int;
      Height : access C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetWindowSizeInPixels";
end SDL.Raw.Video;
