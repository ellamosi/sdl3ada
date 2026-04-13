with Ada.Unchecked_Conversion;
with Interfaces.C;
with Interfaces.C.Extensions;
with Interfaces.C.Pointers;
with Interfaces.C.Strings;
with System;

with SDL.Error;

package body SDL.Inputs.Joysticks.Game_Controllers is
   package CS renames Interfaces.C.Strings;

   use type C.ptrdiff_t;
   use type CS.chars_ptr;
   use type SDL.C_Pointers.Game_Controller_Pointer;
   use type SDL.C_Pointers.Joystick_Pointer;
   use type SDL.Events.Joysticks.Game_Controllers.Axes;
   use type SDL.Events.Joysticks.Game_Controllers.Buttons;
   use type Instances;
   use type SDL.Properties.Property_ID;
   use type System.Address;

   type Instance_Arrays is array (C.ptrdiff_t range <>) of aliased Instances with
     Convention => C;

   package Instance_Pointers is new Interfaces.C.Pointers
     (Index              => C.ptrdiff_t,
      Element            => Instances,
      Element_Array      => Instance_Arrays,
      Default_Terminator => 0);

   use type Instance_Pointers.Pointer;

   type String_Pointer_Arrays is array (C.ptrdiff_t range <>) of aliased CS.chars_ptr with
     Convention => C;

   package String_Pointers is new Interfaces.C.Pointers
     (Index              => C.ptrdiff_t,
      Element            => CS.chars_ptr,
      Element_Array      => String_Pointer_Arrays,
      Default_Terminator => CS.Null_Ptr);

   use type String_Pointers.Pointer;

   type SDL_Axis_Input is record
      Axis     : C.int;
      Axis_Min : C.int;
      Axis_Max : C.int;
   end record with
     Convention => C;

   type SDL_Hat_Input is record
      Hat      : C.int;
      Hat_Mask : C.int;
   end record with
     Convention => C;

   type SDL_Output_Axis is record
      Axis     : SDL.Events.Joysticks.Game_Controllers.Axes;
      Axis_Min : C.int;
      Axis_Max : C.int;
   end record with
     Convention => C;

   type SDL_Input_Values (Which : Bind_Types := None) is record
      case Which is
         when None =>
            null;

         when Button =>
            Button : C.int;

         when Axis =>
            Axis   : SDL_Axis_Input;

         when Hat =>
            Hat    : SDL_Hat_Input;
      end case;
   end record with
     Convention => C,
     Unchecked_Union;

   type SDL_Output_Values (Which : Bind_Types := None) is record
      case Which is
         when None | Hat =>
            null;

         when Button =>
            Button : SDL.Events.Joysticks.Game_Controllers.Buttons;

         when Axis =>
            Axis   : SDL_Output_Axis;
      end case;
   end record with
     Convention => C,
     Unchecked_Union;

   type SDL_Binding is record
      Input_Type  : Bind_Types;
      Input       : SDL_Input_Values;
      Output_Type : Bind_Types;
      Output      : SDL_Output_Values;
   end record with
     Convention => C;

   type SDL_Binding_Access is access all SDL_Binding with
     Convention => C;

   type SDL_Binding_Array is array (C.ptrdiff_t range <>) of aliased SDL_Binding_Access with
     Convention => C;

   package Binding_Pointers is new Interfaces.C.Pointers
     (Index              => C.ptrdiff_t,
      Element            => SDL_Binding_Access,
      Element_Array      => SDL_Binding_Array,
      Default_Terminator => null);

   use type Binding_Pointers.Pointer;

   function To_Address is new Ada.Unchecked_Conversion
     (Source => CS.chars_ptr,
      Target => System.Address);

   function To_Address is new Ada.Unchecked_Conversion
     (Source => Binding_Pointers.Pointer,
      Target => System.Address);

   function To_Address is new Ada.Unchecked_Conversion
     (Source => String_Pointers.Pointer,
      Target => System.Address);

   function To_Address is new Ada.Unchecked_Conversion
     (Source => Instance_Pointers.Pointer,
      Target => System.Address);

   procedure SDL_Free (Value : in System.Address)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_free";

   function SDL_Add_Gamepad_Mapping
     (Buffer : in C.char_array) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_AddGamepadMapping";

   function SDL_Add_Gamepad_Mappings_From_IO
     (Stream    : in SDL.RWops.Handle;
      Close_IO  : in CE.bool) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_AddGamepadMappingsFromIO";

   function SDL_Add_Gamepad_Mappings_From_File
     (Path : in C.char_array) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_AddGamepadMappingsFromFile";

   function SDL_Reload_Gamepad_Mappings return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ReloadGamepadMappings";

   function SDL_Get_Gamepad_Mappings
     (Count : access C.int) return String_Pointers.Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadMappings";

   function SDL_Get_Gamepad_Mapping_For_GUID
     (Value : in GUIDs) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadMappingForGUID";

   function SDL_Get_Gamepad_Mapping
     (Controller : in SDL.C_Pointers.Game_Controller_Pointer) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadMapping";

   function SDL_Set_Gamepad_Mapping
     (Instance : in Instances;
      Mapping  : in C.char_array) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetGamepadMapping";

   function SDL_Has_Gamepad return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_HasGamepad";

   function SDL_Get_Gamepads
     (Count : access C.int) return Instance_Pointers.Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepads";

   function SDL_Is_Gamepad
     (Value : in Instances) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_IsGamepad";

   function SDL_Get_Gamepad_Name_For_ID
     (Value : in Instances) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadNameForID";

   function SDL_Get_Gamepad_Path_For_ID
     (Value : in Instances) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadPathForID";

   function SDL_Get_Gamepad_Player_Index_For_ID
     (Value : in Instances) return Player_Indices
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadPlayerIndexForID";

   function SDL_Get_Gamepad_GUID_For_ID
     (Value : in Instances) return GUIDs
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadGUIDForID";

   function SDL_Get_Gamepad_Vendor_For_ID
     (Value : in Instances) return Vendor_IDs
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadVendorForID";

   function SDL_Get_Gamepad_Product_For_ID
     (Value : in Instances) return Product_IDs
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadProductForID";

   function SDL_Get_Gamepad_Product_Version_For_ID
     (Value : in Instances) return Version_Numbers
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadProductVersionForID";

   function SDL_Get_Gamepad_Type_For_ID
     (Value : in Instances) return Types
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadTypeForID";

   function SDL_Get_Real_Gamepad_Type_For_ID
     (Value : in Instances) return Types
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetRealGamepadTypeForID";

   function SDL_Get_Gamepad_Mapping_For_ID
     (Value : in Instances) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadMappingForID";

   function SDL_Open_Gamepad
     (Value : in Instances) return SDL.C_Pointers.Game_Controller_Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_OpenGamepad";

   function SDL_Get_Gamepad_From_ID
     (Value : in Instances) return SDL.C_Pointers.Game_Controller_Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadFromID";

   function SDL_Get_Gamepad_From_Player_Index
     (Player_Index : in Player_Indices) return SDL.C_Pointers.Game_Controller_Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadFromPlayerIndex";

   procedure SDL_Close_Gamepad
     (Value : in SDL.C_Pointers.Game_Controller_Pointer)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CloseGamepad";

   function SDL_Get_Gamepad_Properties
     (Controller : in SDL.C_Pointers.Game_Controller_Pointer)
      return SDL.Properties.Property_ID
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadProperties";

   function SDL_Get_Gamepad_ID
     (Controller : in SDL.C_Pointers.Game_Controller_Pointer) return Instances
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadID";

   function SDL_Get_Gamepad_Name
     (Controller : in SDL.C_Pointers.Game_Controller_Pointer) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadName";

   function SDL_Get_Gamepad_Path
     (Controller : in SDL.C_Pointers.Game_Controller_Pointer) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadPath";

   function SDL_Get_Gamepad_Type
     (Controller : in SDL.C_Pointers.Game_Controller_Pointer) return Types
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadType";

   function SDL_Get_Real_Gamepad_Type
     (Controller : in SDL.C_Pointers.Game_Controller_Pointer) return Types
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetRealGamepadType";

   function SDL_Get_Gamepad_Player_Index
     (Controller : in SDL.C_Pointers.Game_Controller_Pointer) return Player_Indices
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadPlayerIndex";

   function SDL_Set_Gamepad_Player_Index
     (Controller   : in SDL.C_Pointers.Game_Controller_Pointer;
      Player_Index : in Player_Indices) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetGamepadPlayerIndex";

   function SDL_Get_Gamepad_Vendor
     (Controller : in SDL.C_Pointers.Game_Controller_Pointer) return Vendor_IDs
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadVendor";

   function SDL_Get_Gamepad_Product
     (Controller : in SDL.C_Pointers.Game_Controller_Pointer) return Product_IDs
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadProduct";

   function SDL_Get_Gamepad_Product_Version
     (Controller : in SDL.C_Pointers.Game_Controller_Pointer) return Version_Numbers
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadProductVersion";

   function SDL_Get_Gamepad_Firmware_Version
     (Controller : in SDL.C_Pointers.Game_Controller_Pointer) return Version_Numbers
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadFirmwareVersion";

   function SDL_Get_Gamepad_Serial
     (Controller : in SDL.C_Pointers.Game_Controller_Pointer) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadSerial";

   function SDL_Get_Gamepad_Steam_Handle
     (Controller : in SDL.C_Pointers.Game_Controller_Pointer) return Steam_Handles
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadSteamHandle";

   function SDL_Get_Gamepad_Connection_State
     (Controller : in SDL.C_Pointers.Game_Controller_Pointer)
      return SDL.Inputs.Joysticks.Connection_States
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadConnectionState";

   function SDL_Get_Gamepad_Power_Info
     (Controller : in SDL.C_Pointers.Game_Controller_Pointer;
      Percentage : access C.int) return SDL.Power.State
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadPowerInfo";

   function SDL_Gamepad_Connected
     (Controller : in SDL.C_Pointers.Game_Controller_Pointer) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GamepadConnected";

   function SDL_Get_Gamepad_Joystick
     (Controller : in SDL.C_Pointers.Game_Controller_Pointer)
      return SDL.C_Pointers.Joystick_Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadJoystick";

   function SDL_Get_Gamepad_Bindings
     (Controller : in SDL.C_Pointers.Game_Controller_Pointer;
      Count      : access C.int) return Binding_Pointers.Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadBindings";

   function SDL_Get_Gamepad_Type_From_String
     (Name : in C.char_array) return Types
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadTypeFromString";

   function SDL_Get_Gamepad_String_For_Type
     (Kind : in Types) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadStringForType";

   function SDL_Get_Gamepad_Axis_From_String
     (Name : in C.char_array)
      return SDL.Events.Joysticks.Game_Controllers.Axes
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadAxisFromString";

   function SDL_Get_Gamepad_String_For_Axis
     (Value : in SDL.Events.Joysticks.Game_Controllers.Axes) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadStringForAxis";

   function SDL_Gamepad_Has_Axis
     (Controller : in SDL.C_Pointers.Game_Controller_Pointer;
      Axis       : in SDL.Events.Joysticks.Game_Controllers.Axes) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GamepadHasAxis";

   function SDL_Get_Gamepad_Axis
     (Controller : in SDL.C_Pointers.Game_Controller_Pointer;
      Axis       : in SDL.Events.Joysticks.Game_Controllers.Axes)
      return SDL.Events.Joysticks.Game_Controllers.LR_Axes_Values
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadAxis";

   function SDL_Get_Gamepad_Trigger_Axis
     (Controller : in SDL.C_Pointers.Game_Controller_Pointer;
      Axis       : in SDL.Events.Joysticks.Game_Controllers.Axes)
      return SDL.Events.Joysticks.Game_Controllers.Trigger_Axes_Values
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadAxis";

   function SDL_Get_Gamepad_Button_From_String
     (Name : in C.char_array)
      return SDL.Events.Joysticks.Game_Controllers.Buttons
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadButtonFromString";

   function SDL_Get_Gamepad_String_For_Button
     (Value : in SDL.Events.Joysticks.Game_Controllers.Buttons) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadStringForButton";

   function SDL_Gamepad_Has_Button
     (Controller : in SDL.C_Pointers.Game_Controller_Pointer;
      Button     : in SDL.Events.Joysticks.Game_Controllers.Buttons) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GamepadHasButton";

   function SDL_Get_Gamepad_Button
     (Controller : in SDL.C_Pointers.Game_Controller_Pointer;
      Button     : in SDL.Events.Joysticks.Game_Controllers.Buttons) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadButton";

   function SDL_Get_Gamepad_Button_Label_For_Type
     (Kind   : in Types;
      Button : in SDL.Events.Joysticks.Game_Controllers.Buttons) return Button_Labels
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadButtonLabelForType";

   function SDL_Get_Gamepad_Button_Label
     (Controller : in SDL.C_Pointers.Game_Controller_Pointer;
      Button     : in SDL.Events.Joysticks.Game_Controllers.Buttons) return Button_Labels
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadButtonLabel";

   function SDL_Get_Num_Gamepad_Touchpads
     (Controller : in SDL.C_Pointers.Game_Controller_Pointer) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetNumGamepadTouchpads";

   function SDL_Get_Num_Gamepad_Touchpad_Fingers
     (Controller : in SDL.C_Pointers.Game_Controller_Pointer;
      Touchpad   : in C.int) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetNumGamepadTouchpadFingers";

   function SDL_Get_Gamepad_Touchpad_Finger
     (Controller : in SDL.C_Pointers.Game_Controller_Pointer;
      Touchpad   : in C.int;
      Finger     : in C.int;
      Down       : access CE.bool;
      X          : access C.C_float;
      Y          : access C.C_float;
      Pressure   : access C.C_float) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadTouchpadFinger";

   function SDL_Gamepad_Has_Sensor
     (Controller  : in SDL.C_Pointers.Game_Controller_Pointer;
      Sensor_Type : in SDL.Sensors.Types) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GamepadHasSensor";

   function SDL_Set_Gamepad_Sensor_Enabled
     (Controller  : in SDL.C_Pointers.Game_Controller_Pointer;
      Sensor_Type : in SDL.Sensors.Types;
      Enabled     : in CE.bool) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetGamepadSensorEnabled";

   function SDL_Gamepad_Sensor_Enabled
     (Controller  : in SDL.C_Pointers.Game_Controller_Pointer;
      Sensor_Type : in SDL.Sensors.Types) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GamepadSensorEnabled";

   function SDL_Get_Gamepad_Sensor_Data_Rate
     (Controller  : in SDL.C_Pointers.Game_Controller_Pointer;
      Sensor_Type : in SDL.Sensors.Types) return C.C_float
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadSensorDataRate";

   function SDL_Get_Gamepad_Sensor_Data
     (Controller  : in SDL.C_Pointers.Game_Controller_Pointer;
      Sensor_Type : in SDL.Sensors.Types;
      Data        : in System.Address;
      Value_Count : in C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadSensorData";

   function SDL_Rumble_Gamepad
     (Controller      : in SDL.C_Pointers.Game_Controller_Pointer;
      Low_Frequency   : in Uint16;
      High_Frequency  : in Uint16;
      Duration_MS     : in Uint32) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_RumbleGamepad";

   function SDL_Rumble_Gamepad_Triggers
     (Controller   : in SDL.C_Pointers.Game_Controller_Pointer;
      Left_Rumble  : in Uint16;
      Right_Rumble : in Uint16;
      Duration_MS  : in Uint32) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_RumbleGamepadTriggers";

   function SDL_Set_Gamepad_LED
     (Controller : in SDL.C_Pointers.Game_Controller_Pointer;
      Red        : in LED_Components;
      Green      : in LED_Components;
      Blue       : in LED_Components) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetGamepadLED";

   function SDL_Send_Gamepad_Effect
     (Controller : in SDL.C_Pointers.Game_Controller_Pointer;
      Data       : in System.Address;
      Size       : in C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SendGamepadEffect";

   function SDL_Get_Gamepad_Apple_SF_Symbols_Name_For_Button
     (Controller : in SDL.C_Pointers.Game_Controller_Pointer;
      Button     : in SDL.Events.Joysticks.Game_Controllers.Buttons) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadAppleSFSymbolsNameForButton";

   function SDL_Get_Gamepad_Apple_SF_Symbols_Name_For_Axis
     (Controller : in SDL.C_Pointers.Game_Controller_Pointer;
      Axis       : in SDL.Events.Joysticks.Game_Controllers.Axes) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGamepadAppleSFSymbolsNameForAxis";

   procedure Raise_Last_Error
     (Default_Message : in String := "SDL gamepad call failed");

   procedure Raise_Last_Error
     (Default_Message : in String := "SDL gamepad call failed")
   is
      Message : constant String := SDL.Error.Get;
   begin
      if Message = "" then
         raise Game_Controller_Error with Default_Message;
      end if;

      raise Game_Controller_Error with Message;
   end Raise_Last_Error;

   procedure Raise_Mapping_Error
     (Default_Message : in String := "SDL gamepad mapping call failed");

   procedure Raise_Mapping_Error
     (Default_Message : in String := "SDL gamepad mapping call failed")
   is
      Message : constant String := SDL.Error.Get;
   begin
      if Message = "" then
         raise Mapping_Error with Default_Message;
      end if;

      raise Mapping_Error with Message;
   end Raise_Mapping_Error;

   function To_C_Bool (Value : in Boolean) return CE.bool is
     (if Value then CE.bool'Val (1) else CE.bool'Val (0));

   procedure Require_Valid (Self : in Game_Controller);

   procedure Require_Valid (Self : in Game_Controller) is
   begin
      if Self.Internal = null then
         raise Game_Controller_Error with "Invalid game controller";
      end if;
   end Require_Valid;

   procedure Free (Value : in out CS.chars_ptr);

   procedure Free (Value : in out CS.chars_ptr) is
   begin
      if Value /= CS.Null_Ptr then
         SDL_Free (To_Address (Value));
         Value := CS.Null_Ptr;
      end if;
   end Free;

   procedure Free (Value : in out Binding_Pointers.Pointer);

   procedure Free (Value : in out Binding_Pointers.Pointer) is
   begin
      if Value /= null then
         SDL_Free (To_Address (Value));
         Value := null;
      end if;
   end Free;

   procedure Free (Value : in out String_Pointers.Pointer);

   procedure Free (Value : in out String_Pointers.Pointer) is
   begin
      if Value /= null then
         SDL_Free (To_Address (Value));
         Value := null;
      end if;
   end Free;

   procedure Free (Value : in out Instance_Pointers.Pointer);

   procedure Free (Value : in out Instance_Pointers.Pointer) is
   begin
      if Value /= null then
         SDL_Free (To_Address (Value));
         Value := null;
      end if;
   end Free;

   function Buffer_Address
     (Data : in SDL.Inputs.Joysticks.Byte_Lists) return System.Address is
     (if Data'Length = 0 then System.Null_Address
      else Data (Data'First)'Address);

   function Float_Data_Address
     (Data : in SDL.Sensors.Data_Values) return System.Address is
     (if Data'Length = 0 then System.Null_Address
      else Data (Data'First)'Address);

   function To_Button (Index : in C.int)
      return SDL.Events.Joysticks.Game_Controllers.Buttons is
     (case Index is
         when 0  => SDL.Events.Joysticks.Game_Controllers.A,
         when 1  => SDL.Events.Joysticks.Game_Controllers.B,
         when 2  => SDL.Events.Joysticks.Game_Controllers.X,
         when 3  => SDL.Events.Joysticks.Game_Controllers.Y,
         when 4  => SDL.Events.Joysticks.Game_Controllers.Back,
         when 5  => SDL.Events.Joysticks.Game_Controllers.Guide,
         when 6  => SDL.Events.Joysticks.Game_Controllers.Start,
         when 7  => SDL.Events.Joysticks.Game_Controllers.Left_Stick,
         when 8  => SDL.Events.Joysticks.Game_Controllers.Right_Stick,
         when 9  => SDL.Events.Joysticks.Game_Controllers.Left_Shoulder,
         when 10 => SDL.Events.Joysticks.Game_Controllers.Right_Shoulder,
         when 11 => SDL.Events.Joysticks.Game_Controllers.D_Pad_Up,
         when 12 => SDL.Events.Joysticks.Game_Controllers.D_Pad_Down,
         when 13 => SDL.Events.Joysticks.Game_Controllers.D_Pad_Left,
         when 14 => SDL.Events.Joysticks.Game_Controllers.D_Pad_Right,
         when 15 => SDL.Events.Joysticks.Game_Controllers.Misc_1,
         when 16 => SDL.Events.Joysticks.Game_Controllers.Right_Paddle_1,
         when 17 => SDL.Events.Joysticks.Game_Controllers.Left_Paddle_1,
         when 18 => SDL.Events.Joysticks.Game_Controllers.Right_Paddle_2,
         when 19 => SDL.Events.Joysticks.Game_Controllers.Left_Paddle_2,
         when 20 => SDL.Events.Joysticks.Game_Controllers.Touchpad,
         when 21 => SDL.Events.Joysticks.Game_Controllers.Misc_2,
         when 22 => SDL.Events.Joysticks.Game_Controllers.Misc_3,
         when 23 => SDL.Events.Joysticks.Game_Controllers.Misc_4,
         when 24 => SDL.Events.Joysticks.Game_Controllers.Misc_5,
         when 25 => SDL.Events.Joysticks.Game_Controllers.Misc_6,
         when others => SDL.Events.Joysticks.Game_Controllers.Invalid);

   function To_Axis (Index : in C.int)
      return SDL.Events.Joysticks.Game_Controllers.Axes is
     (case Index is
         when 0      => SDL.Events.Joysticks.Game_Controllers.Left_X,
         when 1      => SDL.Events.Joysticks.Game_Controllers.Left_Y,
         when 2      => SDL.Events.Joysticks.Game_Controllers.Right_X,
         when 3      => SDL.Events.Joysticks.Game_Controllers.Right_Y,
         when 4      => SDL.Events.Joysticks.Game_Controllers.Trigger_Left,
         when 5      => SDL.Events.Joysticks.Game_Controllers.Trigger_Right,
         when others => SDL.Events.Joysticks.Game_Controllers.Invalid);

   function Null_Binding return Bindings is
     ((Which => None, Value => (Which => None)));

   function To_Compatibility (Binding : in SDL_Binding) return Bindings is
   begin
      case Binding.Input_Type is
         when None =>
            return Null_Binding;

         when Button =>
            return
              (Which => Button,
               Value => (Which => Button,
                         Button => To_Button (Binding.Input.Button)));

         when Axis =>
            return
              (Which => Axis,
               Value => (Which => Axis,
                         Axis => To_Axis (Binding.Input.Axis.Axis)));

         when Hat =>
            return
              (Which => Hat,
               Value =>
                 (Which => Hat,
                  Hat   =>
                    (Hat  => SDL.Events.Joysticks.Hats (Binding.Input.Hat.Hat),
                     Mask =>
                       SDL.Events.Joysticks.Hat_Positions
                         (Binding.Input.Hat.Hat_Mask))));
      end case;
   end To_Compatibility;

   function Copy_IDs
     (Items : in Instance_Pointers.Pointer;
      Count : in C.int) return ID_Lists;

   function Copy_IDs
     (Items : in Instance_Pointers.Pointer;
      Count : in C.int) return ID_Lists
   is
      Raw : Instance_Pointers.Pointer := Items;
   begin
      if Count <= 0 then
         Free (Raw);
         return [];
      end if;

      if Raw = null then
         Raise_Last_Error ("Gamepad enumeration failed");
      end if;

      declare
         Source : constant Instance_Arrays :=
           Instance_Pointers.Value (Raw, C.ptrdiff_t (Count));
         Result : ID_Lists (0 .. Natural (Count) - 1);
      begin
         for Index in Result'Range loop
            Result (Index) :=
              Source (Source'First + C.ptrdiff_t (Index - Result'First));
         end loop;

         Free (Raw);
         return Result;
      exception
         when others =>
            Free (Raw);
            raise;
      end;
   end Copy_IDs;

   function Copy_Mappings
     (Items : in String_Pointers.Pointer;
      Count : in C.int) return Mapping_Lists;

   function Copy_Mappings
     (Items : in String_Pointers.Pointer;
      Count : in C.int) return Mapping_Lists
   is
      Raw : String_Pointers.Pointer := Items;
   begin
      if Count <= 0 then
         Free (Raw);
         return [];
      end if;

      if Raw = null then
         Raise_Mapping_Error ("SDL_GetGamepadMappings failed");
      end if;

      declare
         Source : constant String_Pointer_Arrays :=
           String_Pointers.Value (Raw, C.ptrdiff_t (Count));
         Result : Mapping_Lists (0 .. Natural (Count) - 1);
      begin
         for Index in Result'Range loop
            declare
               Source_Index : constant C.ptrdiff_t :=
                 Source'First + C.ptrdiff_t (Index - Result'First);
            begin
               if Source (Source_Index) = CS.Null_Ptr then
                  Result (Index) := US.Null_Unbounded_String;
               else
                  Result (Index) :=
                    US.To_Unbounded_String (CS.Value (Source (Source_Index)));
               end if;
            end;
         end loop;

         Free (Raw);
         return Result;
      exception
         when others =>
            Free (Raw);
            raise;
      end;
   end Copy_Mappings;

   function Copy_Bindings
     (Items : in Binding_Pointers.Pointer;
      Count : in C.int) return Binding_Lists;

   function Copy_Bindings
     (Items : in Binding_Pointers.Pointer;
      Count : in C.int) return Binding_Lists
   is
      Raw : Binding_Pointers.Pointer := Items;
   begin
      if Count <= 0 then
         Free (Raw);
         return [];
      end if;

      if Raw = null then
         Raise_Mapping_Error ("SDL_GetGamepadBindings failed");
      end if;

      declare
         Source : constant SDL_Binding_Array :=
           Binding_Pointers.Value (Raw, C.ptrdiff_t (Count));
         Result : Binding_Lists (0 .. Natural (Count) - 1);
      begin
         for Index in Result'Range loop
            declare
               Source_Index : constant C.ptrdiff_t :=
                 Source'First + C.ptrdiff_t (Index - Result'First);
            begin
               if Source (Source_Index) = null then
                  Result (Index) := Null_Binding;
               else
                  Result (Index) := To_Compatibility (Source (Source_Index).all);
               end if;
            end;
         end loop;

         Free (Raw);
         return Result;
      exception
         when others =>
            Free (Raw);
            raise;
      end;
   end Copy_Bindings;

   procedure Add_Mapping
     (Data             : in String;
      Updated_Existing : out Boolean)
   is
      Result : constant C.int := SDL_Add_Gamepad_Mapping (C.To_C (Data));
   begin
      if Result < 0 then
         Raise_Mapping_Error ("SDL_AddGamepadMapping failed");
      end if;

      Updated_Existing := (Result = 0);
   end Add_Mapping;

   procedure Add_Mappings_From_IO
     (Stream       : in SDL.RWops.Handle;
      Close_After  : in Boolean;
      Number_Added : out Natural)
   is
      Result : C.int;
   begin
      Result := SDL_Add_Gamepad_Mappings_From_IO (Stream, To_C_Bool (Close_After));

      if Result < 0 then
         Raise_Mapping_Error ("SDL_AddGamepadMappingsFromIO failed");
      end if;

      Number_Added := Natural (Result);
   end Add_Mappings_From_IO;

   procedure Add_Mappings_From_IO
     (Stream       : in SDL.RWops.RWops;
      Number_Added : out Natural)
   is
   begin
      if SDL.RWops.Is_Null (Stream) then
         raise Mapping_Error with "Invalid RWops handle";
      end if;

      Add_Mappings_From_IO (SDL.RWops.Get_Handle (Stream), False, Number_Added);
   end Add_Mappings_From_IO;

   procedure Add_Mappings_From_File
     (Database_Filename : in String;
      Number_Added      : out Natural)
   is
      Result : constant C.int :=
        SDL_Add_Gamepad_Mappings_From_File (C.To_C (Database_Filename));
   begin
      if Result < 0 then
         Raise_Mapping_Error ("SDL_AddGamepadMappingsFromFile failed");
      end if;

      Number_Added := Natural (Result);
   end Add_Mappings_From_File;

   procedure Reload_Mappings is
   begin
      if not Boolean (SDL_Reload_Gamepad_Mappings) then
         Raise_Mapping_Error ("SDL_ReloadGamepadMappings failed");
      end if;
   end Reload_Mappings;

   function Get_Mappings return Mapping_Lists is
      Count : aliased C.int := 0;
      Items : constant String_Pointers.Pointer :=
        SDL_Get_Gamepad_Mappings (Count'Access);
   begin
      return Copy_Mappings (Items, Count);
   end Get_Mappings;

   procedure Set_Mapping
     (Instance : in Instances;
      Mapping  : in String)
   is
   begin
      if not Boolean (SDL_Set_Gamepad_Mapping (Instance, C.To_C (Mapping))) then
         Raise_Mapping_Error ("SDL_SetGamepadMapping failed");
      end if;
   end Set_Mapping;

   function Has_Gamepad return Boolean is
   begin
      return Boolean (SDL_Has_Gamepad);
   end Has_Gamepad;

   function Get_Gamepads return ID_Lists is
      Count : aliased C.int := 0;
      Items : constant Instance_Pointers.Pointer := SDL_Get_Gamepads (Count'Access);
   begin
      return Copy_IDs (Items, Count);
   end Get_Gamepads;

   overriding
   procedure Finalize (Self : in out Game_Controller) is
   begin
      if Self.Owns and then Self.Internal /= null then
         SDL_Close_Gamepad (Self.Internal);
      end if;

      Self.Internal := null;
      Self.Owns := True;
   end Finalize;

   function Axis_Value
     (Self : in Game_Controller;
      Axis : in SDL.Events.Joysticks.Game_Controllers.LR_Axes)
      return SDL.Events.Joysticks.Game_Controllers.LR_Axes_Values
   is
   begin
      Require_Valid (Self);
      return SDL_Get_Gamepad_Axis (Self.Internal, Axis);
   end Axis_Value;

   function Axis_Value
     (Self : in Game_Controller;
      Axis : in SDL.Events.Joysticks.Game_Controllers.Trigger_Axes)
      return SDL.Events.Joysticks.Game_Controllers.Trigger_Axes_Values
   is
   begin
      Require_Valid (Self);
      return SDL_Get_Gamepad_Trigger_Axis (Self.Internal, Axis);
   end Axis_Value;

   procedure Close (Self : in out Game_Controller) is
   begin
      Finalize (Self);
   end Close;

   function Open (Instance : in Instances) return Game_Controller is
   begin
      return Result : Game_Controller do
         Open (Result, Instance);
      end return;
   end Open;

   procedure Open
     (Self     : in out Game_Controller;
      Instance : in Instances)
   is
      Internal : SDL.C_Pointers.Game_Controller_Pointer := null;
   begin
      Close (Self);

      Internal := SDL_Open_Gamepad (Instance);
      if Internal = null then
         Raise_Last_Error ("SDL_OpenGamepad failed");
      end if;

      Self.Internal := Internal;
      Self.Owns := True;
   end Open;

   function Get (Instance : in Instances) return Game_Controller is
   begin
      return (Ada.Finalization.Limited_Controlled with
              Internal => SDL_Get_Gamepad_From_ID (Instance),
              Owns     => False);
   end Get;

   function Get_From_Player_Index
     (Player_Index : in Player_Indices) return Game_Controller
   is
   begin
      return (Ada.Finalization.Limited_Controlled with
              Internal => SDL_Get_Gamepad_From_Player_Index (Player_Index),
              Owns     => False);
   end Get_From_Player_Index;

   function Get_Axis
     (Axis : in String) return SDL.Events.Joysticks.Game_Controllers.Axes
   is
   begin
      return SDL_Get_Gamepad_Axis_From_String (C.To_C (Axis));
   end Get_Axis;

   function Get_Bindings (Self : in Game_Controller) return Binding_Lists is
      Count : aliased C.int := 0;
      Raw   : Binding_Pointers.Pointer;
   begin
      Require_Valid (Self);
      Raw := SDL_Get_Gamepad_Bindings (Self.Internal, Count'Access);
      return Copy_Bindings (Raw, Count);
   end Get_Bindings;

   function Get_Binding
     (Self : in Game_Controller;
      Axis : in SDL.Events.Joysticks.Game_Controllers.Axes) return Bindings
   is
      Count : aliased C.int := 0;
      Raw   : Binding_Pointers.Pointer;
   begin
      Require_Valid (Self);
      Raw := SDL_Get_Gamepad_Bindings (Self.Internal, Count'Access);

      if Raw = null then
         if SDL.Error.Get /= "" then
            Raise_Mapping_Error ("SDL_GetGamepadBindings failed");
         end if;

         return Null_Binding;
      end if;

      declare
         Copy : constant SDL_Binding_Array :=
           Binding_Pointers.Value (Raw, C.ptrdiff_t (Count));
      begin
         for Binding_Item of Copy loop
            if Binding_Item /= null
              and then Binding_Item.Output_Type = SDL.Inputs.Joysticks.Game_Controllers.Axis
              and then Binding_Item.Output.Axis.Axis = Axis
            then
               Free (Raw);
               return To_Compatibility (Binding_Item.all);
            end if;
         end loop;
      end;

      Free (Raw);
      return Null_Binding;
   end Get_Binding;

   function Get_Binding
     (Self   : in Game_Controller;
      Button : in SDL.Events.Joysticks.Game_Controllers.Buttons) return Bindings
   is
      Count : aliased C.int := 0;
      Raw   : Binding_Pointers.Pointer;
   begin
      Require_Valid (Self);
      Raw := SDL_Get_Gamepad_Bindings (Self.Internal, Count'Access);

      if Raw = null then
         if SDL.Error.Get /= "" then
            Raise_Mapping_Error ("SDL_GetGamepadBindings failed");
         end if;

         return Null_Binding;
      end if;

      declare
         Copy : constant SDL_Binding_Array :=
           Binding_Pointers.Value (Raw, C.ptrdiff_t (Count));
      begin
         for Binding_Item of Copy loop
            if Binding_Item /= null
              and then Binding_Item.Output_Type = SDL.Inputs.Joysticks.Game_Controllers.Button
              and then Binding_Item.Output.Button = Button
            then
               Free (Raw);
               return To_Compatibility (Binding_Item.all);
            end if;
         end loop;
      end;

      Free (Raw);
      return Null_Binding;
   end Get_Binding;

   function Get_Button
     (Button_Name : in String) return SDL.Events.Joysticks.Game_Controllers.Buttons
   is
   begin
      return SDL_Get_Gamepad_Button_From_String (C.To_C (Button_Name));
   end Get_Button;

   function Get_Joystick (Self : in Game_Controller) return Joystick is
   begin
      Require_Valid (Self);

      return Result : constant Joystick :=
        (Ada.Finalization.Limited_Controlled with
           Internal => SDL_Get_Gamepad_Joystick (Self.Internal),
           Owns     => False)
      do
         null;
      end return;
   end Get_Joystick;

   function Get_Mapping (Self : in Game_Controller) return String is
      Result : CS.chars_ptr;
   begin
      Require_Valid (Self);
      Result := SDL_Get_Gamepad_Mapping (Self.Internal);

      if Result = CS.Null_Ptr then
         return "";
      end if;

      declare
         Value : constant String := CS.Value (Result);
      begin
         Free (Result);
         return Value;
      end;
   end Get_Mapping;

   function Get_Mapping (Controller : in GUIDs) return String is
      Result : CS.chars_ptr := SDL_Get_Gamepad_Mapping_For_GUID (Controller);
   begin
      if Result = CS.Null_Ptr then
         return "";
      end if;

      declare
         Value : constant String := CS.Value (Result);
      begin
         Free (Result);
         return Value;
      end;
   end Get_Mapping;

   function Get_Mapping (Instance : in Instances) return String is
      Result : CS.chars_ptr := SDL_Get_Gamepad_Mapping_For_ID (Instance);
   begin
      if Result = CS.Null_Ptr then
         return "";
      end if;

      declare
         Value : constant String := CS.Value (Result);
      begin
         Free (Result);
         return Value;
      end;
   end Get_Mapping;

   function Get_Name (Self : in Game_Controller) return String is
      Result : CS.chars_ptr;
   begin
      Require_Valid (Self);
      Result := SDL_Get_Gamepad_Name (Self.Internal);

      if Result = CS.Null_Ptr then
         return "";
      end if;

      return CS.Value (Result);
   end Get_Name;

   function Get_Name (Device : in Devices) return String is
     (Get_Name (Resolve_Device (Device)));

   function Get_Name (Instance : in Instances) return String is
      Result : constant CS.chars_ptr := SDL_Get_Gamepad_Name_For_ID (Instance);
   begin
      if Result = CS.Null_Ptr then
         return "";
      end if;

      return CS.Value (Result);
   end Get_Name;

   function Get_Path (Self : in Game_Controller) return String is
      Result : CS.chars_ptr;
   begin
      Require_Valid (Self);
      Result := SDL_Get_Gamepad_Path (Self.Internal);

      if Result = CS.Null_Ptr then
         return "";
      end if;

      return CS.Value (Result);
   end Get_Path;

   function Get_Path (Instance : in Instances) return String is
      Result : constant CS.chars_ptr := SDL_Get_Gamepad_Path_For_ID (Instance);
   begin
      if Result = CS.Null_Ptr then
         return "";
      end if;

      return CS.Value (Result);
   end Get_Path;

   function Player_Index (Self : in Game_Controller) return Player_Indices is
   begin
      Require_Valid (Self);
      return SDL_Get_Gamepad_Player_Index (Self.Internal);
   end Player_Index;

   function Player_Index (Instance : in Instances) return Player_Indices is
   begin
      return SDL_Get_Gamepad_Player_Index_For_ID (Instance);
   end Player_Index;

   procedure Set_Player_Index
     (Self         : in Game_Controller;
      Player_Index : in Player_Indices)
   is
   begin
      Require_Valid (Self);

      if not Boolean (SDL_Set_Gamepad_Player_Index (Self.Internal, Player_Index)) then
         Raise_Last_Error ("SDL_SetGamepadPlayerIndex failed");
      end if;
   end Set_Player_Index;

   function GUID (Instance : in Instances) return GUIDs is
   begin
      return SDL_Get_Gamepad_GUID_For_ID (Instance);
   end GUID;

   function Get_Type (Self : in Game_Controller) return Types is
   begin
      Require_Valid (Self);
      return SDL_Get_Gamepad_Type (Self.Internal);
   end Get_Type;

   function Get_Type (Instance : in Instances) return Types is
   begin
      return SDL_Get_Gamepad_Type_For_ID (Instance);
   end Get_Type;

   function Get_Real_Type (Self : in Game_Controller) return Types is
   begin
      Require_Valid (Self);
      return SDL_Get_Real_Gamepad_Type (Self.Internal);
   end Get_Real_Type;

   function Get_Real_Type (Instance : in Instances) return Types is
   begin
      return SDL_Get_Real_Gamepad_Type_For_ID (Instance);
   end Get_Real_Type;

   function Vendor (Self : in Game_Controller) return Vendor_IDs is
   begin
      Require_Valid (Self);
      return SDL_Get_Gamepad_Vendor (Self.Internal);
   end Vendor;

   function Vendor (Instance : in Instances) return Vendor_IDs is
   begin
      return SDL_Get_Gamepad_Vendor_For_ID (Instance);
   end Vendor;

   function Product (Self : in Game_Controller) return Product_IDs is
   begin
      Require_Valid (Self);
      return SDL_Get_Gamepad_Product (Self.Internal);
   end Product;

   function Product (Instance : in Instances) return Product_IDs is
   begin
      return SDL_Get_Gamepad_Product_For_ID (Instance);
   end Product;

   function Product_Version (Self : in Game_Controller) return Version_Numbers is
   begin
      Require_Valid (Self);
      return SDL_Get_Gamepad_Product_Version (Self.Internal);
   end Product_Version;

   function Product_Version (Instance : in Instances) return Version_Numbers is
   begin
      return SDL_Get_Gamepad_Product_Version_For_ID (Instance);
   end Product_Version;

   function Firmware_Version (Self : in Game_Controller) return Version_Numbers is
   begin
      Require_Valid (Self);
      return SDL_Get_Gamepad_Firmware_Version (Self.Internal);
   end Firmware_Version;

   function Serial (Self : in Game_Controller) return String is
      Result : CS.chars_ptr;
   begin
      Require_Valid (Self);
      Result := SDL_Get_Gamepad_Serial (Self.Internal);

      if Result = CS.Null_Ptr then
         return "";
      end if;

      return CS.Value (Result);
   end Serial;

   function Steam_Handle (Self : in Game_Controller) return Steam_Handles is
   begin
      Require_Valid (Self);
      return SDL_Get_Gamepad_Steam_Handle (Self.Internal);
   end Steam_Handle;

   function Connection_State
     (Self : in Game_Controller) return SDL.Inputs.Joysticks.Connection_States
   is
   begin
      Require_Valid (Self);
      return SDL_Get_Gamepad_Connection_State (Self.Internal);
   end Connection_State;

   function Get_Power_Info
     (Self       : in Game_Controller;
      Percentage : out Battery_Percentages) return SDL.Power.State
   is
      Raw_Percentage : aliased C.int := -1;
   begin
      Require_Valid (Self);
      Percentage := -1;

      declare
         Result : constant SDL.Power.State :=
           SDL_Get_Gamepad_Power_Info (Self.Internal, Raw_Percentage'Access);
      begin
         Percentage := Battery_Percentages (Raw_Percentage);
         return Result;
      end;
   end Get_Power_Info;

   function Get_Properties
     (Self : in Game_Controller) return SDL.Properties.Property_Set
   is
   begin
      Require_Valid (Self);
      return SDL.Properties.Reference (SDL_Get_Gamepad_Properties (Self.Internal));
   end Get_Properties;

   function Get_ID (Self : in Game_Controller) return Instances is
      Result : Instances;
   begin
      Require_Valid (Self);
      Result := SDL_Get_Gamepad_ID (Self.Internal);

      if Result = 0 then
         Raise_Last_Error ("SDL_GetGamepadID failed");
      end if;

      return Result;
   end Get_ID;

   function Image
     (Axis : in SDL.Events.Joysticks.Game_Controllers.Axes) return String
   is
      Result : constant CS.chars_ptr := SDL_Get_Gamepad_String_For_Axis (Axis);
   begin
      if Result = CS.Null_Ptr then
         return "";
      end if;

      return CS.Value (Result);
   end Image;

   function Image
     (Button : in SDL.Events.Joysticks.Game_Controllers.Buttons) return String
   is
      Result : constant CS.chars_ptr := SDL_Get_Gamepad_String_For_Button (Button);
   begin
      if Result = CS.Null_Ptr then
         return "";
      end if;

      return CS.Value (Result);
   end Image;

   function Image (Kind : in Types) return String is
      Result : constant CS.chars_ptr := SDL_Get_Gamepad_String_For_Type (Kind);
   begin
      if Result = CS.Null_Ptr then
         return "";
      end if;

      return CS.Value (Result);
   end Image;

   function Type_From_String (Value : in String) return Types is
   begin
      return SDL_Get_Gamepad_Type_From_String (C.To_C (Value));
   end Type_From_String;

   function Is_Attached (Self : in Game_Controller) return Boolean is
   begin
      Require_Valid (Self);
      return Boolean (SDL_Gamepad_Connected (Self.Internal));
   end Is_Attached;

   function Has_Axis
     (Self : in Game_Controller;
      Axis : in SDL.Events.Joysticks.Game_Controllers.Axes) return Boolean
   is
   begin
      Require_Valid (Self);
      return Boolean (SDL_Gamepad_Has_Axis (Self.Internal, Axis));
   end Has_Axis;

   function Is_Button_Pressed
     (Self   : in Game_Controller;
      Button : in SDL.Events.Joysticks.Game_Controllers.Buttons)
      return SDL.Events.Button_State
   is
   begin
      Require_Valid (Self);

      if Boolean (SDL_Get_Gamepad_Button (Self.Internal, Button)) then
         return SDL.Events.Pressed;
      end if;

      return SDL.Events.Released;
   end Is_Button_Pressed;

   function Has_Button
     (Self   : in Game_Controller;
      Button : in SDL.Events.Joysticks.Game_Controllers.Buttons) return Boolean
   is
   begin
      Require_Valid (Self);
      return Boolean (SDL_Gamepad_Has_Button (Self.Internal, Button));
   end Has_Button;

   function Is_Game_Controller (Device : in Devices) return Boolean is
   begin
      return Boolean (SDL_Is_Gamepad (Resolve_Device (Device)));
   end Is_Game_Controller;

   function Button_Label_For_Type
     (Kind   : in Types;
      Button : in SDL.Events.Joysticks.Game_Controllers.Buttons)
      return Button_Labels
   is
   begin
      return SDL_Get_Gamepad_Button_Label_For_Type (Kind, Button);
   end Button_Label_For_Type;

   function Button_Label
     (Self   : in Game_Controller;
      Button : in SDL.Events.Joysticks.Game_Controllers.Buttons)
      return Button_Labels
   is
   begin
      Require_Valid (Self);
      return SDL_Get_Gamepad_Button_Label (Self.Internal, Button);
   end Button_Label;

   function Touchpads (Self : in Game_Controller) return Natural is
      Result : C.int;
   begin
      Require_Valid (Self);
      Result := SDL_Get_Num_Gamepad_Touchpads (Self.Internal);

      if Result < 0 then
         Raise_Last_Error ("SDL_GetNumGamepadTouchpads failed");
      end if;

      return Natural (Result);
   end Touchpads;

   function Touchpad_Fingers
     (Self     : in Game_Controller;
      Touchpad : in C.int) return Natural
   is
      Result : C.int;
   begin
      Require_Valid (Self);
      Result := SDL_Get_Num_Gamepad_Touchpad_Fingers (Self.Internal, Touchpad);

      if Result < 0 then
         Raise_Last_Error ("SDL_GetNumGamepadTouchpadFingers failed");
      end if;

      return Natural (Result);
   end Touchpad_Fingers;

   function Touchpad_Finger
     (Self     : in Game_Controller;
      Touchpad : in C.int;
      Finger   : in C.int) return Touchpad_Finger_State
   is
      Down     : aliased CE.bool := CE.bool'Val (0);
      X        : aliased C.C_float := 0.0;
      Y        : aliased C.C_float := 0.0;
      Pressure : aliased C.C_float := 0.0;
   begin
      Require_Valid (Self);

      if not Boolean
          (SDL_Get_Gamepad_Touchpad_Finger
             (Self.Internal,
              Touchpad,
              Finger,
              Down'Access,
              X'Access,
              Y'Access,
              Pressure'Access))
      then
         Raise_Last_Error ("SDL_GetGamepadTouchpadFinger failed");
      end if;

      return
        (Down     => Boolean (Down),
         X        => X,
         Y        => Y,
         Pressure => Pressure);
   end Touchpad_Finger;

   function Has_Sensor
     (Self        : in Game_Controller;
      Sensor_Type : in SDL.Sensors.Types) return Boolean
   is
   begin
      Require_Valid (Self);
      return Boolean (SDL_Gamepad_Has_Sensor (Self.Internal, Sensor_Type));
   end Has_Sensor;

   procedure Set_Sensor_Enabled
     (Self        : in Game_Controller;
      Sensor_Type : in SDL.Sensors.Types;
      Enabled     : in Boolean)
   is
   begin
      Require_Valid (Self);

      if not Boolean
          (SDL_Set_Gamepad_Sensor_Enabled
             (Self.Internal,
              Sensor_Type,
              To_C_Bool (Enabled)))
      then
         Raise_Last_Error ("SDL_SetGamepadSensorEnabled failed");
      end if;
   end Set_Sensor_Enabled;

   function Sensor_Enabled
     (Self        : in Game_Controller;
      Sensor_Type : in SDL.Sensors.Types) return Boolean
   is
   begin
      Require_Valid (Self);
      return Boolean (SDL_Gamepad_Sensor_Enabled (Self.Internal, Sensor_Type));
   end Sensor_Enabled;

   function Sensor_Data_Rate
     (Self        : in Game_Controller;
      Sensor_Type : in SDL.Sensors.Types) return C.C_float
   is
   begin
      Require_Valid (Self);
      return SDL_Get_Gamepad_Sensor_Data_Rate (Self.Internal, Sensor_Type);
   end Sensor_Data_Rate;

   procedure Get_Sensor_Data
     (Self        : in Game_Controller;
      Sensor_Type : in SDL.Sensors.Types;
      Data        : out SDL.Sensors.Data_Values)
   is
   begin
      Require_Valid (Self);

      if not Boolean
          (SDL_Get_Gamepad_Sensor_Data
             (Self.Internal,
              Sensor_Type,
              Float_Data_Address (Data),
              C.int (Data'Length)))
      then
         Raise_Last_Error ("SDL_GetGamepadSensorData failed");
      end if;
   end Get_Sensor_Data;

   function Get_Sensor_Data
     (Self        : in Game_Controller;
      Sensor_Type : in SDL.Sensors.Types;
      Value_Count : in Positive) return SDL.Sensors.Data_Values
   is
      Result : SDL.Sensors.Data_Values (0 .. Value_Count - 1) := [others => 0.0];
   begin
      Get_Sensor_Data (Self, Sensor_Type, Result);
      return Result;
   end Get_Sensor_Data;

   function Has_Rumble (Self : in Game_Controller) return Boolean is
      Properties : constant SDL.Properties.Property_Set :=
        SDL.Properties.Reference (SDL_Get_Gamepad_Properties (Self.Internal));
   begin
      Require_Valid (Self);

      if SDL.Properties.Is_Null (Properties) then
         return False;
      end if;

      return SDL.Properties.Get_Boolean
        (Properties, "SDL.joystick.cap.rumble");
   end Has_Rumble;

   function Rumble
     (Self           : in Game_Controller;
      Low_Frequency  : in Uint16;
      High_Frequency : in Uint16;
      Duration       : in Uint32) return Integer
   is
   begin
      Require_Valid (Self);

      if Boolean
          (SDL_Rumble_Gamepad
             (Self.Internal,
              Low_Frequency,
              High_Frequency,
              Duration))
      then
         return 0;
      end if;

      return -1;
   end Rumble;

   procedure Rumble_Triggers
     (Self         : in Game_Controller;
      Left_Rumble  : in Uint16;
      Right_Rumble : in Uint16;
      Duration     : in Uint32)
   is
   begin
      Require_Valid (Self);

      if not Boolean
          (SDL_Rumble_Gamepad_Triggers
             (Self.Internal,
              Left_Rumble,
              Right_Rumble,
              Duration))
      then
         Raise_Last_Error ("SDL_RumbleGamepadTriggers failed");
      end if;
   end Rumble_Triggers;

   procedure Set_LED
     (Self  : in Game_Controller;
      Red   : in LED_Components;
      Green : in LED_Components;
      Blue  : in LED_Components)
   is
   begin
      Require_Valid (Self);

      if not Boolean (SDL_Set_Gamepad_LED (Self.Internal, Red, Green, Blue)) then
         Raise_Last_Error ("SDL_SetGamepadLED failed");
      end if;
   end Set_LED;

   procedure Send_Effect
     (Self : in Game_Controller;
      Data : in SDL.Inputs.Joysticks.Byte_Lists)
   is
   begin
      Require_Valid (Self);

      if not Boolean
          (SDL_Send_Gamepad_Effect
             (Self.Internal,
              Buffer_Address (Data),
              C.int (Data'Length)))
      then
         Raise_Last_Error ("SDL_SendGamepadEffect failed");
      end if;
   end Send_Effect;

   function Apple_SF_Symbol_Name
     (Self   : in Game_Controller;
      Button : in SDL.Events.Joysticks.Game_Controllers.Buttons) return String
   is
      Result : CS.chars_ptr;
   begin
      Require_Valid (Self);
      Result := SDL_Get_Gamepad_Apple_SF_Symbols_Name_For_Button (Self.Internal, Button);

      if Result = CS.Null_Ptr then
         return "";
      end if;

      return CS.Value (Result);
   end Apple_SF_Symbol_Name;

   function Apple_SF_Symbol_Name
     (Self : in Game_Controller;
      Axis : in SDL.Events.Joysticks.Game_Controllers.Axes) return String
   is
      Result : CS.chars_ptr;
   begin
      Require_Valid (Self);
      Result := SDL_Get_Gamepad_Apple_SF_Symbols_Name_For_Axis (Self.Internal, Axis);

      if Result = CS.Null_Ptr then
         return "";
      end if;

      return CS.Value (Result);
   end Apple_SF_Symbol_Name;
end SDL.Inputs.Joysticks.Game_Controllers;
