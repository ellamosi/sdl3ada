with Interfaces;
with Interfaces.C;
with Interfaces.C.Extensions;
with Interfaces.C.Pointers;
with Interfaces.C.Strings;
with System;

with SDL.C_Pointers;

package SDL.Raw.Mouse is
   pragma Preelaborate;

   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;
   package CS renames Interfaces.C.Strings;

   type ID is mod 2 ** 32 with
     Convention => C,
     Size       => 32;

   subtype Time_Stamp is Interfaces.Unsigned_64;
   subtype Movement_Value is C.C_float;

   type Button_Mask is mod 2 ** 32 with
     Convention => C,
     Size       => 32;

   type ID_Array is array (C.ptrdiff_t range <>) of aliased ID with
     Convention => C;

   package ID_Pointers is new Interfaces.C.Pointers
     (Index              => C.ptrdiff_t,
      Element            => ID,
      Element_Array      => ID_Array,
      Default_Terminator => 0);

   type Motion_Value_Access is access all Movement_Value with
     Convention => C;

   type Motion_Transform_Callback is access procedure
     (User_Data  : in System.Address;
      Timestamp  : in Time_Stamp;
      Window     : in System.Address;
      Mouse      : in ID;
      X          : in Motion_Value_Access;
      Y          : in Motion_Value_Access)
   with Convention => C;

   subtype Duration_Milliseconds is Interfaces.Unsigned_32;

   type Cursor_Frame is record
      Surface  : System.Address;
      Duration : Duration_Milliseconds;
   end record with
     Convention => C;

   type Cursor_Frame_Array is array (Positive range <>) of aliased Cursor_Frame with
     Convention => C;

   type System_Cursor is
     (Default,
      Text,
      Wait,
      Crosshair,
      Progress,
      NWSE_Resize,
      NESW_Resize,
      EW_Resize,
      NS_Resize,
      Move,
      Not_Allowed,
      Pointer,
      NW_Resize,
      N_Resize,
      NE_Resize,
      E_Resize,
      SE_Resize,
      S_Resize,
      SW_Resize,
      W_Resize)
   with
     Convention => C,
     Size       => C.int'Size;

   for System_Cursor use
     (Default     => 0,
      Text        => 1,
      Wait        => 2,
      Crosshair   => 3,
      Progress    => 4,
      NWSE_Resize => 5,
      NESW_Resize => 6,
      EW_Resize   => 7,
      NS_Resize   => 8,
      Move        => 9,
      Not_Allowed => 10,
      Pointer     => 11,
      NW_Resize   => 12,
      N_Resize    => 13,
      NE_Resize   => 14,
      E_Resize    => 15,
      SE_Resize   => 16,
      S_Resize    => 17,
      SW_Resize   => 18,
      W_Resize    => 19);

   procedure Free (Memory : in System.Address)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_free";

   function Has_Mouse return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_HasMouse";

   function Get_Mice
     (Count : access C.int) return ID_Pointers.Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetMice";

   function Get_Mouse_Name_For_ID
     (Value : in ID) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetMouseNameForID";

   function Get_Mouse_Focus return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetMouseFocus";

   function Capture_Mouse (Enabled : in CE.bool) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CaptureMouse";

   function Get_Global_Mouse_State
     (X : out Movement_Value;
      Y : out Movement_Value) return Button_Mask
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGlobalMouseState";

   function Get_Mouse_State
     (X : out Movement_Value;
      Y : out Movement_Value) return Button_Mask
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetMouseState";

   function Get_Window_Relative_Mouse_Mode
     (Value : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetWindowRelativeMouseMode";

   function Set_Window_Relative_Mouse_Mode
     (Value   : in System.Address;
      Enabled : in CE.bool) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetWindowRelativeMouseMode";

   function Get_Relative_Mouse_State
     (X : out Movement_Value;
      Y : out Movement_Value) return Button_Mask
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetRelativeMouseState";

   function Set_Relative_Mouse_Transform
     (Transform : in Motion_Transform_Callback;
      Data      : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetRelativeMouseTransform";

   function Show_Cursor return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ShowCursor";

   function Hide_Cursor return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_HideCursor";

   function Cursor_Visible return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CursorVisible";

   function Warp_Mouse_Global
     (X : in Movement_Value;
      Y : in Movement_Value) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_WarpMouseGlobal";

   procedure Warp_Mouse_In_Window
     (Window : in System.Address;
      X      : in Movement_Value;
      Y      : in Movement_Value)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_WarpMouseInWindow";

   function Create_Cursor
     (Bits   : access constant Interfaces.Unsigned_8;
      Mask   : access constant Interfaces.Unsigned_8;
      Width  : in C.int;
      Height : in C.int;
      Hot_X  : in C.int;
      Hot_Y  : in C.int) return SDL.C_Pointers.Cursor_Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CreateCursor";

   function Create_Color_Cursor
     (Surface : in System.Address;
      Hot_X   : in C.int;
      Hot_Y   : in C.int) return SDL.C_Pointers.Cursor_Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CreateColorCursor";

   function Create_Animated_Cursor
     (Value       : access Cursor_Frame;
      Frame_Count : in C.int;
      Hot_X       : in C.int;
      Hot_Y       : in C.int) return SDL.C_Pointers.Cursor_Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CreateAnimatedCursor";

   function Create_System_Cursor
     (Cursor_Name : in System_Cursor) return SDL.C_Pointers.Cursor_Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CreateSystemCursor";

   function Get_Cursor return SDL.C_Pointers.Cursor_Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetCursor";

   function Get_Default_Cursor return SDL.C_Pointers.Cursor_Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetDefaultCursor";

   function Set_Cursor
     (Value : in SDL.C_Pointers.Cursor_Pointer) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetCursor";

   procedure Destroy_Cursor
     (Value : in SDL.C_Pointers.Cursor_Pointer)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_DestroyCursor";
end SDL.Raw.Mouse;
