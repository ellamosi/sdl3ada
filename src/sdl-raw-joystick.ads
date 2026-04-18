with Interfaces;
with Interfaces.C;
with Interfaces.C.Extensions;
with Interfaces.C.Pointers;
with Interfaces.C.Strings;
with System;

with SDL.Raw.C_Pointers;
with SDL.Raw.Joystick_Events;
with SDL.Raw.Power;
with SDL.Raw.Properties;
with SDL.Raw.Sensor;

package SDL.Raw.Joystick is
   pragma Preelaborate;

   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;
   package CS renames Interfaces.C.Strings;

   type ID is mod 2 ** 32 with
     Convention => C,
     Size       => 32;

   subtype Vendor_ID is Interfaces.Unsigned_16;
   subtype Product_ID is Interfaces.Unsigned_16;
   subtype Version_Number is Interfaces.Unsigned_16;
   subtype CRC16_Value is Interfaces.Unsigned_16;
   subtype Player_Index is C.int;
   subtype Nanoseconds is Interfaces.Unsigned_64;
   subtype LED_Component is Interfaces.Unsigned_8;

   type Types is
     (Unknown,
      Gamepad,
      Wheel,
      Arcade_Stick,
      Flight_Stick,
      Dance_Pad,
      Guitar,
      Drum_Kit,
      Arcade_Pad,
      Throttle,
      Type_Count)
   with
     Convention => C,
     Size       => C.int'Size;

   for Types use
     (Unknown       => 0,
      Gamepad       => 1,
      Wheel         => 2,
      Arcade_Stick  => 3,
      Flight_Stick  => 4,
      Dance_Pad     => 5,
      Guitar        => 6,
      Drum_Kit      => 7,
      Arcade_Pad    => 8,
      Throttle      => 9,
      Type_Count    => 10);

   type Connection_States is
     (Connection_Invalid,
      Connection_Unknown,
      Connection_Wired,
      Connection_Wireless)
   with
     Convention => C,
     Size       => C.int'Size;

   for Connection_States use
     (Connection_Invalid  => -1,
      Connection_Unknown  => 0,
      Connection_Wired    => 1,
      Connection_Wireless => 2);

   type Signed_16 is range -32_768 .. 32_767 with
     Convention => C,
     Size       => 16;

   subtype Axis_Value is Signed_16;
   subtype Ball_Delta is Signed_16;

   type Hat_Position is mod 2 ** 8 with
     Convention => C,
     Size       => 8;

   type GUID_Array is array (1 .. 16) of aliased Interfaces.Unsigned_8 with
     Convention => C;

   type GUID is record
      Data : GUID_Array;
   end record with
     Convention => C_Pass_By_Copy;

   type ID_Array is array (C.ptrdiff_t range <>) of aliased ID with
     Convention => C;

   package ID_Pointers is new Interfaces.C.Pointers
     (Index              => C.ptrdiff_t,
      Element            => ID,
      Element_Array      => ID_Array,
      Default_Terminator => 0);

   type Virtual_Touchpad_Description is record
      Finger_Count : Interfaces.Unsigned_16;
      Padding_1    : Interfaces.Unsigned_16 := 0;
      Padding_2    : Interfaces.Unsigned_16 := 0;
      Padding_3    : Interfaces.Unsigned_16 := 0;
   end record with
     Convention => C;

   type Virtual_Sensor_Description is record
      Sensor_Type : SDL.Raw.Sensor.Types;
      Rate        : C.C_float;
   end record with
     Convention => C;

   type Virtual_Touchpad_Description_Access is access constant Virtual_Touchpad_Description with
     Convention => C;

   type Virtual_Sensor_Description_Access is access constant Virtual_Sensor_Description with
     Convention => C;

   type Update_Callback is access procedure (User_Data : System.Address) with
     Convention => C;

   type Set_Player_Index_Callback is access procedure
     (User_Data    : System.Address;
      Index        : Player_Index)
   with
     Convention => C;

   type Rumble_Callback is access function
     (User_Data             : System.Address;
      Low_Frequency_Rumble  : Interfaces.Unsigned_16;
      High_Frequency_Rumble : Interfaces.Unsigned_16)
      return CE.bool
   with
     Convention => C;

   type Rumble_Triggers_Callback is access function
     (User_Data    : System.Address;
      Left_Rumble  : Interfaces.Unsigned_16;
      Right_Rumble : Interfaces.Unsigned_16)
      return CE.bool
   with
     Convention => C;

   type Set_LED_Callback is access function
     (User_Data : System.Address;
      Red       : LED_Component;
      Green     : LED_Component;
      Blue      : LED_Component)
      return CE.bool
   with
     Convention => C;

   type Send_Effect_Callback is access function
     (User_Data : System.Address;
      Data      : System.Address;
      Size      : C.int)
      return CE.bool
   with
     Convention => C;

   type Set_Sensors_Enabled_Callback is access function
     (User_Data : System.Address;
      Enabled   : CE.bool)
      return CE.bool
   with
     Convention => C;

   type Cleanup_Callback is access procedure (User_Data : System.Address) with
     Convention => C;

   type Virtual_Description is record
      Version             : Interfaces.Unsigned_32;
      Kind                : Interfaces.Unsigned_16;
      Padding             : Interfaces.Unsigned_16 := 0;
      Vendor              : Vendor_ID;
      Product             : Product_ID;
      Axis_Count          : Interfaces.Unsigned_16;
      Button_Count        : Interfaces.Unsigned_16;
      Ball_Count          : Interfaces.Unsigned_16;
      Hat_Count           : Interfaces.Unsigned_16;
      Touchpad_Count      : Interfaces.Unsigned_16;
      Sensor_Count        : Interfaces.Unsigned_16;
      Padding_2           : Interfaces.Unsigned_16 := 0;
      Padding_3           : Interfaces.Unsigned_16 := 0;
      Button_Mask         : Interfaces.Unsigned_32;
      Axis_Mask           : Interfaces.Unsigned_32;
      Name                : CS.chars_ptr;
      Touchpads           : Virtual_Touchpad_Description_Access;
      Sensors             : Virtual_Sensor_Description_Access;
      User_Data           : System.Address;
      Update              : Update_Callback;
      Set_Player_Index    : Set_Player_Index_Callback;
      Rumble              : Rumble_Callback;
      Rumble_Triggers     : Rumble_Triggers_Callback;
      Set_LED             : Set_LED_Callback;
      Send_Effect         : Send_Effect_Callback;
      Set_Sensors_Enabled : Set_Sensors_Enabled_Callback;
      Cleanup             : Cleanup_Callback;
   end record with
     Convention => C;

   procedure Update renames SDL.Raw.Joystick_Events.Update;

   function Events_Enabled return CE.bool renames
     SDL.Raw.Joystick_Events.Events_Enabled;

   procedure Set_Events_Enabled (Enabled : in CE.bool) renames
     SDL.Raw.Joystick_Events.Set_Events_Enabled;

   procedure Free (Memory : in System.Address)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_free";

   function Has_Joystick return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_HasJoystick";

   function Get_Joysticks
     (Count : access C.int) return ID_Pointers.Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetJoysticks";

   function Get_Joystick_Name_For_ID
     (Instance : in ID) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetJoystickNameForID";

   function Get_Joystick_Path_For_ID
     (Instance : in ID) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetJoystickPathForID";

   function Get_Joystick_Player_Index_For_ID
     (Instance : in ID) return Player_Index
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetJoystickPlayerIndexForID";

   function Get_Joystick_GUID_For_ID
     (Instance : in ID) return GUID
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetJoystickGUIDForID";

   function Get_Joystick_Vendor_For_ID
     (Instance : in ID) return Vendor_ID
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetJoystickVendorForID";

   function Get_Joystick_Product_For_ID
     (Instance : in ID) return Product_ID
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetJoystickProductForID";

   function Get_Joystick_Product_Version_For_ID
     (Instance : in ID) return Version_Number
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetJoystickProductVersionForID";

   function Get_Joystick_Type_For_ID
     (Instance : in ID) return Types
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetJoystickTypeForID";

   function Open_Joystick
     (Device : in ID) return SDL.Raw.C_Pointers.Joystick_Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_OpenJoystick";

   function Get_Joystick_From_ID
     (Instance : in ID) return SDL.Raw.C_Pointers.Joystick_Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetJoystickFromID";

   function Get_Joystick_From_Player_Index
     (Index : in Player_Index) return SDL.Raw.C_Pointers.Joystick_Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetJoystickFromPlayerIndex";

   function Attach_Virtual_Joystick
     (Description : access constant Virtual_Description) return ID
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_AttachVirtualJoystick";

   function Detach_Virtual_Joystick
     (Instance : in ID) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_DetachVirtualJoystick";

   function Is_Joystick_Virtual
     (Instance : in ID) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_IsJoystickVirtual";

   procedure Lock_Joysticks
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_LockJoysticks";

   procedure Unlock_Joysticks
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_UnlockJoysticks";

   function Get_Joystick_Properties
     (Self : in SDL.Raw.C_Pointers.Joystick_Pointer) return SDL.Raw.Properties.ID
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetJoystickProperties";

   function Get_Joystick_Name
     (Self : in SDL.Raw.C_Pointers.Joystick_Pointer) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetJoystickName";

   function Get_Joystick_Path
     (Self : in SDL.Raw.C_Pointers.Joystick_Pointer) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetJoystickPath";

   function Get_Joystick_Player_Index
     (Self : in SDL.Raw.C_Pointers.Joystick_Pointer) return Player_Index
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetJoystickPlayerIndex";

   function Set_Joystick_Player_Index
     (Self         : in SDL.Raw.C_Pointers.Joystick_Pointer;
      Index        : in Player_Index) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetJoystickPlayerIndex";

   function Get_Joystick_GUID
     (Self : in SDL.Raw.C_Pointers.Joystick_Pointer) return GUID
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetJoystickGUID";

   function Get_Joystick_Vendor
     (Self : in SDL.Raw.C_Pointers.Joystick_Pointer) return Vendor_ID
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetJoystickVendor";

   function Get_Joystick_Product
     (Self : in SDL.Raw.C_Pointers.Joystick_Pointer) return Product_ID
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetJoystickProduct";

   function Get_Joystick_Product_Version
     (Self : in SDL.Raw.C_Pointers.Joystick_Pointer) return Version_Number
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetJoystickProductVersion";

   function Get_Joystick_Firmware_Version
     (Self : in SDL.Raw.C_Pointers.Joystick_Pointer) return Version_Number
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetJoystickFirmwareVersion";

   function Get_Joystick_Serial
     (Self : in SDL.Raw.C_Pointers.Joystick_Pointer) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetJoystickSerial";

   function Get_Joystick_Type
     (Self : in SDL.Raw.C_Pointers.Joystick_Pointer) return Types
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetJoystickType";

   procedure Get_Joystick_GUID_Info
     (Value   : in GUID;
      Vendor  : access Vendor_ID;
      Product : access Product_ID;
      Version : access Version_Number;
      CRC16   : access CRC16_Value)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetJoystickGUIDInfo";

   function Joystick_Connected
     (Self : in SDL.Raw.C_Pointers.Joystick_Pointer) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_JoystickConnected";

   function Get_Joystick_ID
     (Self : in SDL.Raw.C_Pointers.Joystick_Pointer) return ID
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetJoystickID";

   function Get_Num_Joystick_Axes
     (Self : in SDL.Raw.C_Pointers.Joystick_Pointer) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetNumJoystickAxes";

   function Get_Num_Joystick_Balls
     (Self : in SDL.Raw.C_Pointers.Joystick_Pointer) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetNumJoystickBalls";

   function Get_Num_Joystick_Hats
     (Self : in SDL.Raw.C_Pointers.Joystick_Pointer) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetNumJoystickHats";

   function Get_Num_Joystick_Buttons
     (Self : in SDL.Raw.C_Pointers.Joystick_Pointer) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetNumJoystickButtons";

   procedure Close_Joystick
     (Self : in SDL.Raw.C_Pointers.Joystick_Pointer)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CloseJoystick";

   function Get_Joystick_Connection_State
     (Self : in SDL.Raw.C_Pointers.Joystick_Pointer) return Connection_States
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetJoystickConnectionState";

   function Get_Joystick_Power_Info
     (Self       : in SDL.Raw.C_Pointers.Joystick_Pointer;
      Percentage : access C.int) return SDL.Raw.Power.State
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetJoystickPowerInfo";

   function Get_Joystick_Axis
     (Self : in SDL.Raw.C_Pointers.Joystick_Pointer;
      Axis : in C.int) return Axis_Value
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetJoystickAxis";

   function Get_Joystick_Axis_Initial_State
     (Self  : in SDL.Raw.C_Pointers.Joystick_Pointer;
      Axis  : in C.int;
      State : access Axis_Value) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetJoystickAxisInitialState";

   function Get_Joystick_Ball
     (Self  : in SDL.Raw.C_Pointers.Joystick_Pointer;
      Ball  : in C.int;
      X, Y  : access C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetJoystickBall";

   function Get_Joystick_Hat
     (Self : in SDL.Raw.C_Pointers.Joystick_Pointer;
      Hat  : in C.int) return Hat_Position
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetJoystickHat";

   function Get_Joystick_Button
     (Self   : in SDL.Raw.C_Pointers.Joystick_Pointer;
      Button : in C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetJoystickButton";

   function Rumble_Joystick
     (Self                  : in SDL.Raw.C_Pointers.Joystick_Pointer;
      Low_Frequency_Rumble  : in Interfaces.Unsigned_16;
      High_Frequency_Rumble : in Interfaces.Unsigned_16;
      Duration_MS           : in Interfaces.Unsigned_32) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_RumbleJoystick";

   function Rumble_Joystick_Triggers
     (Self         : in SDL.Raw.C_Pointers.Joystick_Pointer;
      Left_Rumble  : in Interfaces.Unsigned_16;
      Right_Rumble : in Interfaces.Unsigned_16;
      Duration_MS  : in Interfaces.Unsigned_32) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_RumbleJoystickTriggers";

   function Set_Joystick_LED
     (Self  : in SDL.Raw.C_Pointers.Joystick_Pointer;
      Red   : in LED_Component;
      Green : in LED_Component;
      Blue  : in LED_Component) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetJoystickLED";

   function Send_Joystick_Effect
     (Self : in SDL.Raw.C_Pointers.Joystick_Pointer;
      Data : in System.Address;
      Size : in C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SendJoystickEffect";

   function Set_Joystick_Virtual_Axis
     (Self  : in SDL.Raw.C_Pointers.Joystick_Pointer;
      Axis  : in C.int;
      Value : in Axis_Value) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetJoystickVirtualAxis";

   function Set_Joystick_Virtual_Ball
     (Self : in SDL.Raw.C_Pointers.Joystick_Pointer;
      Ball : in C.int;
      Xrel : in Ball_Delta;
      Yrel : in Ball_Delta) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetJoystickVirtualBall";

   function Set_Joystick_Virtual_Button
     (Self   : in SDL.Raw.C_Pointers.Joystick_Pointer;
      Button : in C.int;
      Down   : in CE.bool) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetJoystickVirtualButton";

   function Set_Joystick_Virtual_Hat
     (Self  : in SDL.Raw.C_Pointers.Joystick_Pointer;
      Hat   : in C.int;
      Value : in Hat_Position) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetJoystickVirtualHat";

   function Set_Joystick_Virtual_Touchpad
     (Self     : in SDL.Raw.C_Pointers.Joystick_Pointer;
      Touchpad : in C.int;
      Finger   : in C.int;
      Down     : in CE.bool;
      X        : in C.C_float;
      Y        : in C.C_float;
      Pressure : in C.C_float) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetJoystickVirtualTouchpad";

   function Send_Joystick_Virtual_Sensor_Data
     (Self             : in SDL.Raw.C_Pointers.Joystick_Pointer;
      Sensor_Type      : in SDL.Raw.Sensor.Types;
      Sensor_Timestamp : in Nanoseconds;
      Data             : in System.Address;
      Value_Count      : in C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SendJoystickVirtualSensorData";

   procedure GUID_To_String
     (Value  : in GUID;
      Buffer : out C.char_array;
      Size   : in C.int)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GUIDToString";

   function String_To_GUID
     (Buffer : in C.char_array) return GUID
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_StringToGUID";
end SDL.Raw.Joystick;
