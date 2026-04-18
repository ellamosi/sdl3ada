with Interfaces;
with Interfaces.C;
with Interfaces.C.Extensions;
with Interfaces.C.Pointers;
with Interfaces.C.Strings;
with System;

with SDL.C_Pointers;
with SDL.Raw.Gamepad_Events;
with SDL.Raw.Joystick;
with SDL.Raw.Power;
with SDL.Raw.Properties;
with SDL.Raw.Sensor;

package SDL.Raw.Gamepad is
   pragma Preelaborate;

   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;
   package CS renames Interfaces.C.Strings;

   subtype ID is SDL.Raw.Joystick.ID;
   subtype GUID is SDL.Raw.Joystick.GUID;
   subtype Vendor_ID is SDL.Raw.Joystick.Vendor_ID;
   subtype Product_ID is SDL.Raw.Joystick.Product_ID;
   subtype Version_Number is SDL.Raw.Joystick.Version_Number;
   subtype Player_Index is SDL.Raw.Joystick.Player_Index;
   subtype LED_Component is SDL.Raw.Joystick.LED_Component;
   subtype Axis_Value is SDL.Raw.Joystick.Axis_Value;
   subtype Connection_States is SDL.Raw.Joystick.Connection_States;
   subtype Steam_Handle is Interfaces.Unsigned_64;

   package ID_Pointers renames SDL.Raw.Joystick.ID_Pointers;

   type Types is
     (Unknown,
      Standard,
      Xbox_360,
      Xbox_One,
      PS3,
      PS4,
      PS5,
      Nintendo_Switch_Pro,
      Nintendo_Switch_Joycon_Left,
      Nintendo_Switch_Joycon_Right,
      Nintendo_Switch_Joycon_Pair,
      GameCube,
      Type_Count)
   with
     Convention => C,
     Size       => C.int'Size;

   for Types use
     (Unknown                     => 0,
      Standard                    => 1,
      Xbox_360                    => 2,
      Xbox_One                    => 3,
      PS3                         => 4,
      PS4                         => 5,
      PS5                         => 6,
      Nintendo_Switch_Pro         => 7,
      Nintendo_Switch_Joycon_Left => 8,
      Nintendo_Switch_Joycon_Right => 9,
      Nintendo_Switch_Joycon_Pair => 10,
      GameCube                    => 11,
      Type_Count                  => 12);

   type Buttons is
     (Invalid_Button,
      South,
      East,
      West,
      North,
      Back,
      Guide,
      Start,
      Left_Stick,
      Right_Stick,
      Left_Shoulder,
      Right_Shoulder,
      Dpad_Up,
      Dpad_Down,
      Dpad_Left,
      Dpad_Right,
      Misc_1,
      Right_Paddle_1,
      Left_Paddle_1,
      Right_Paddle_2,
      Left_Paddle_2,
      Touchpad,
      Misc_2,
      Misc_3,
      Misc_4,
      Misc_5,
      Misc_6,
      Button_Count)
   with
     Convention => C,
     Size       => C.int'Size;

   for Buttons use
     (Invalid_Button => -1,
      South          => 0,
      East           => 1,
      West           => 2,
      North          => 3,
      Back           => 4,
      Guide          => 5,
      Start          => 6,
      Left_Stick     => 7,
      Right_Stick    => 8,
      Left_Shoulder  => 9,
      Right_Shoulder => 10,
      Dpad_Up        => 11,
      Dpad_Down      => 12,
      Dpad_Left      => 13,
      Dpad_Right     => 14,
      Misc_1         => 15,
      Right_Paddle_1 => 16,
      Left_Paddle_1  => 17,
      Right_Paddle_2 => 18,
      Left_Paddle_2  => 19,
      Touchpad       => 20,
      Misc_2         => 21,
      Misc_3         => 22,
      Misc_4         => 23,
      Misc_5         => 24,
      Misc_6         => 25,
      Button_Count   => 26);

   type Button_Labels is
     (Unknown_Label,
      Label_A,
      Label_B,
      Label_X,
      Label_Y,
      Label_Cross,
      Label_Circle,
      Label_Square,
      Label_Triangle)
   with
     Convention => C,
     Size       => C.int'Size;

   for Button_Labels use
     (Unknown_Label => 0,
      Label_A       => 1,
      Label_B       => 2,
      Label_X       => 3,
      Label_Y       => 4,
      Label_Cross   => 5,
      Label_Circle  => 6,
      Label_Square  => 7,
      Label_Triangle => 8);

   type Axes is
     (Invalid_Axis,
      Left_X,
      Left_Y,
      Right_X,
      Right_Y,
      Left_Trigger,
      Right_Trigger,
      Axis_Count)
   with
     Convention => C,
     Size       => C.int'Size;

   for Axes use
     (Invalid_Axis  => -1,
      Left_X        => 0,
      Left_Y        => 1,
      Right_X       => 2,
      Right_Y       => 3,
      Left_Trigger  => 4,
      Right_Trigger => 5,
      Axis_Count    => 6);

   type Binding_Types is
     (None,
      Button,
      Axis,
      Hat)
   with
     Convention => C,
     Size       => C.int'Size;

   for Binding_Types use
     (None   => 0,
      Button => 1,
      Axis   => 2,
      Hat    => 3);

   type String_Pointer_Array is array (C.ptrdiff_t range <>) of aliased CS.chars_ptr with
     Convention => C;

   package String_Pointers is new Interfaces.C.Pointers
     (Index              => C.ptrdiff_t,
      Element            => CS.chars_ptr,
      Element_Array      => String_Pointer_Array,
      Default_Terminator => null);

   type Axis_Input is record
      Axis     : C.int;
      Axis_Min : C.int;
      Axis_Max : C.int;
   end record with
     Convention => C;

   type Hat_Input is record
      Hat      : C.int;
      Hat_Mask : C.int;
   end record with
     Convention => C;

   type Output_Axis is record
      Axis     : Axes;
      Axis_Min : C.int;
      Axis_Max : C.int;
   end record with
     Convention => C;

   type Input_Values (Kind : Binding_Types := None) is record
      case Kind is
         when None =>
            null;

         when Button =>
            Button : C.int;

         when Axis =>
            Axis   : Axis_Input;

         when Hat =>
            Hat    : Hat_Input;
      end case;
   end record with
     Convention => C,
     Unchecked_Union;

   type Output_Values (Kind : Binding_Types := None) is record
      case Kind is
         when None | Hat =>
            null;

         when Button =>
            Button : Buttons;

         when Axis =>
            Axis   : Output_Axis;
      end case;
   end record with
     Convention => C,
     Unchecked_Union;

   type Binding is record
      Input_Type  : Binding_Types;
      Input       : Input_Values;
      Output_Type : Binding_Types;
      Output      : Output_Values;
   end record with
     Convention => C;

   type Binding_Access is access all Binding with
     Convention => C;

   type Binding_Array is array (C.ptrdiff_t range <>) of aliased Binding_Access with
     Convention => C;

   package Binding_Pointers is new Interfaces.C.Pointers
     (Index              => C.ptrdiff_t,
      Element            => Binding_Access,
      Element_Array      => Binding_Array,
      Default_Terminator => null);

   procedure Update renames SDL.Raw.Gamepad_Events.Update;

   function Events_Enabled return CE.bool renames
     SDL.Raw.Gamepad_Events.Events_Enabled;

   procedure Set_Events_Enabled (Enabled : in CE.bool) renames
     SDL.Raw.Gamepad_Events.Set_Events_Enabled;

   procedure Free (Value : in System.Address)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_free";

   function Add_Gamepad_Mapping
     (Buffer : in C.char_array) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_AddGamepadMapping";

   function Add_Gamepad_Mappings_From_IO
     (Stream   : in SDL.C_Pointers.IO_Stream_Pointer;
      Close_IO : in CE.bool) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_AddGamepadMappingsFromIO";

   function Add_Gamepad_Mappings_From_File
     (Path : in C.char_array) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_AddGamepadMappingsFromFile";

   function Reload_Gamepad_Mappings return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ReloadGamepadMappings";

   function Get_Gamepad_Mappings
     (Count : access C.int) return String_Pointers.Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadMappings";

   function Get_Gamepad_Mapping_For_GUID
     (Value : in GUID) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadMappingForGUID";

   function Get_Gamepad_Mapping
     (Controller : in SDL.C_Pointers.Game_Controller_Pointer) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadMapping";

   function Set_Gamepad_Mapping
     (Instance : in ID;
      Mapping  : in C.char_array) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetGamepadMapping";

   function Has_Gamepad return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_HasGamepad";

   function Get_Gamepads
     (Count : access C.int) return ID_Pointers.Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepads";

   function Is_Gamepad
     (Value : in ID) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_IsGamepad";

   function Get_Gamepad_Name_For_ID
     (Value : in ID) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadNameForID";

   function Get_Gamepad_Path_For_ID
     (Value : in ID) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadPathForID";

   function Get_Gamepad_Player_Index_For_ID
     (Value : in ID) return Player_Index
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadPlayerIndexForID";

   function Get_Gamepad_GUID_For_ID
     (Value : in ID) return GUID
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadGUIDForID";

   function Get_Gamepad_Vendor_For_ID
     (Value : in ID) return Vendor_ID
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadVendorForID";

   function Get_Gamepad_Product_For_ID
     (Value : in ID) return Product_ID
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadProductForID";

   function Get_Gamepad_Product_Version_For_ID
     (Value : in ID) return Version_Number
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadProductVersionForID";

   function Get_Gamepad_Type_For_ID
     (Value : in ID) return Types
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadTypeForID";

   function Get_Real_Gamepad_Type_For_ID
     (Value : in ID) return Types
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetRealGamepadTypeForID";

   function Get_Gamepad_Mapping_For_ID
     (Value : in ID) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadMappingForID";

   function Open_Gamepad
     (Device : in ID) return SDL.C_Pointers.Game_Controller_Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_OpenGamepad";

   function Get_Gamepad_From_ID
     (Value : in ID) return SDL.C_Pointers.Game_Controller_Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadFromID";

   function Get_Gamepad_From_Player_Index
     (Index : in Player_Index) return SDL.C_Pointers.Game_Controller_Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadFromPlayerIndex";

   procedure Close_Gamepad
     (Self : in SDL.C_Pointers.Game_Controller_Pointer)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CloseGamepad";

   function Get_Gamepad_Properties
     (Self : in SDL.C_Pointers.Game_Controller_Pointer) return SDL.Raw.Properties.ID
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadProperties";

   function Get_Gamepad_ID
     (Self : in SDL.C_Pointers.Game_Controller_Pointer) return ID
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadID";

   function Get_Gamepad_Name
     (Self : in SDL.C_Pointers.Game_Controller_Pointer) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadName";

   function Get_Gamepad_Path
     (Self : in SDL.C_Pointers.Game_Controller_Pointer) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadPath";

   function Get_Gamepad_Type
     (Self : in SDL.C_Pointers.Game_Controller_Pointer) return Types
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadType";

   function Get_Real_Gamepad_Type
     (Self : in SDL.C_Pointers.Game_Controller_Pointer) return Types
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetRealGamepadType";

   function Get_Gamepad_Player_Index
     (Self : in SDL.C_Pointers.Game_Controller_Pointer) return Player_Index
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadPlayerIndex";

   function Set_Gamepad_Player_Index
     (Self  : in SDL.C_Pointers.Game_Controller_Pointer;
      Index : in Player_Index) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetGamepadPlayerIndex";

   function Get_Gamepad_Vendor
     (Self : in SDL.C_Pointers.Game_Controller_Pointer) return Vendor_ID
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadVendor";

   function Get_Gamepad_Product
     (Self : in SDL.C_Pointers.Game_Controller_Pointer) return Product_ID
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadProduct";

   function Get_Gamepad_Product_Version
     (Self : in SDL.C_Pointers.Game_Controller_Pointer) return Version_Number
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadProductVersion";

   function Get_Gamepad_Firmware_Version
     (Self : in SDL.C_Pointers.Game_Controller_Pointer) return Version_Number
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadFirmwareVersion";

   function Get_Gamepad_Serial
     (Self : in SDL.C_Pointers.Game_Controller_Pointer) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadSerial";

   function Get_Gamepad_Steam_Handle
     (Self : in SDL.C_Pointers.Game_Controller_Pointer) return Steam_Handle
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadSteamHandle";

   function Get_Gamepad_Connection_State
     (Self : in SDL.C_Pointers.Game_Controller_Pointer) return Connection_States
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadConnectionState";

   function Get_Gamepad_Power_Info
     (Self       : in SDL.C_Pointers.Game_Controller_Pointer;
      Percentage : access C.int) return SDL.Raw.Power.State
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadPowerInfo";

   function Gamepad_Connected
     (Self : in SDL.C_Pointers.Game_Controller_Pointer) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GamepadConnected";

   function Get_Gamepad_Joystick
     (Self : in SDL.C_Pointers.Game_Controller_Pointer) return SDL.C_Pointers.Joystick_Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadJoystick";

   function Get_Gamepad_Bindings
     (Self  : in SDL.C_Pointers.Game_Controller_Pointer;
      Count : access C.int) return Binding_Pointers.Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadBindings";

   function Get_Gamepad_Type_From_String
     (Name : in C.char_array) return Types
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadTypeFromString";

   function Get_Gamepad_String_For_Type
     (Value : in Types) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadStringForType";

   function Get_Gamepad_Axis_From_String
     (Name : in C.char_array) return Axes
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadAxisFromString";

   function Get_Gamepad_String_For_Axis
     (Value : in Axes) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadStringForAxis";

   function Gamepad_Has_Axis
     (Self : in SDL.C_Pointers.Game_Controller_Pointer;
      Axis : in Axes) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GamepadHasAxis";

   function Get_Gamepad_Axis
     (Self : in SDL.C_Pointers.Game_Controller_Pointer;
      Axis : in Axes) return Axis_Value
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadAxis";

   function Get_Gamepad_Button_From_String
     (Name : in C.char_array) return Buttons
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadButtonFromString";

   function Get_Gamepad_String_For_Button
     (Value : in Buttons) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadStringForButton";

   function Gamepad_Has_Button
     (Self   : in SDL.C_Pointers.Game_Controller_Pointer;
      Button : in Buttons) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GamepadHasButton";

   function Get_Gamepad_Button
     (Self   : in SDL.C_Pointers.Game_Controller_Pointer;
      Button : in Buttons) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadButton";

   function Get_Gamepad_Button_Label_For_Type
     (Kind   : in Types;
      Button : in Buttons) return Button_Labels
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadButtonLabelForType";

   function Get_Gamepad_Button_Label
     (Self   : in SDL.C_Pointers.Game_Controller_Pointer;
      Button : in Buttons) return Button_Labels
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadButtonLabel";

   function Get_Num_Gamepad_Touchpads
     (Self : in SDL.C_Pointers.Game_Controller_Pointer) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetNumGamepadTouchpads";

   function Get_Num_Gamepad_Touchpad_Fingers
     (Self     : in SDL.C_Pointers.Game_Controller_Pointer;
      Touchpad : in C.int) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetNumGamepadTouchpadFingers";

   function Get_Gamepad_Touchpad_Finger
     (Self     : in SDL.C_Pointers.Game_Controller_Pointer;
      Touchpad : in C.int;
      Finger   : in C.int;
      Down     : access CE.bool;
      X        : access C.C_float;
      Y        : access C.C_float;
      Pressure : access C.C_float) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadTouchpadFinger";

   function Gamepad_Has_Sensor
     (Self        : in SDL.C_Pointers.Game_Controller_Pointer;
      Sensor_Type : in SDL.Raw.Sensor.Types) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GamepadHasSensor";

   function Set_Gamepad_Sensor_Enabled
     (Self        : in SDL.C_Pointers.Game_Controller_Pointer;
      Sensor_Type : in SDL.Raw.Sensor.Types;
      Enabled     : in CE.bool) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetGamepadSensorEnabled";

   function Gamepad_Sensor_Enabled
     (Self        : in SDL.C_Pointers.Game_Controller_Pointer;
      Sensor_Type : in SDL.Raw.Sensor.Types) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GamepadSensorEnabled";

   function Get_Gamepad_Sensor_Data_Rate
     (Self        : in SDL.C_Pointers.Game_Controller_Pointer;
      Sensor_Type : in SDL.Raw.Sensor.Types) return C.C_float
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadSensorDataRate";

   function Get_Gamepad_Sensor_Data
     (Self        : in SDL.C_Pointers.Game_Controller_Pointer;
      Sensor_Type : in SDL.Raw.Sensor.Types;
      Data        : in System.Address;
      Value_Count : in C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadSensorData";

   function Rumble_Gamepad
     (Self           : in SDL.C_Pointers.Game_Controller_Pointer;
      Low_Frequency  : in Interfaces.Unsigned_16;
      High_Frequency : in Interfaces.Unsigned_16;
      Duration       : in Interfaces.Unsigned_32) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_RumbleGamepad";

   function Rumble_Gamepad_Triggers
     (Self         : in SDL.C_Pointers.Game_Controller_Pointer;
      Left_Rumble  : in Interfaces.Unsigned_16;
      Right_Rumble : in Interfaces.Unsigned_16;
      Duration     : in Interfaces.Unsigned_32) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_RumbleGamepadTriggers";

   function Set_Gamepad_LED
     (Self  : in SDL.C_Pointers.Game_Controller_Pointer;
      Red   : in LED_Component;
      Green : in LED_Component;
      Blue  : in LED_Component) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetGamepadLED";

   function Send_Gamepad_Effect
     (Self : in SDL.C_Pointers.Game_Controller_Pointer;
      Data : in System.Address;
      Size : in C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SendGamepadEffect";

   function Get_Gamepad_Apple_SF_Symbols_Name_For_Button
     (Self   : in SDL.C_Pointers.Game_Controller_Pointer;
      Button : in Buttons) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadAppleSFSymbolsNameForButton";

   function Get_Gamepad_Apple_SF_Symbols_Name_For_Axis
     (Self : in SDL.C_Pointers.Game_Controller_Pointer;
      Axis : in Axes) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadAppleSFSymbolsNameForAxis";
end SDL.Raw.Gamepad;
