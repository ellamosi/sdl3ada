with Ada.Finalization;
with Ada.Strings.Unbounded;

with Interfaces;
with Interfaces.C;
with Interfaces.C.Extensions;
with System;

with SDL.C_Pointers;
with SDL.Events.Joysticks;
with SDL.Power;
with SDL.Properties;
with SDL.Sensors;

package SDL.Inputs.Joysticks is
   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;
   package US renames Ada.Strings.Unbounded;

   Joystick_Error : exception;

   type All_Devices is range 0 .. 2 ** 31 - 1 with
     Convention => C,
     Size       => 32;

   subtype Devices is All_Devices range All_Devices'First + 1 .. All_Devices'Last;

   subtype Instances is SDL.Events.Joysticks.IDs;
   type ID_Lists is array (Natural range <>) of Instances;

   subtype Vendor_IDs is Interfaces.Unsigned_16;
   subtype Product_IDs is Interfaces.Unsigned_16;
   subtype Version_Numbers is Interfaces.Unsigned_16;
   subtype CRC16_Values is Interfaces.Unsigned_16;
   subtype Player_Indices is C.int;
   subtype Battery_Percentages is C.int range -1 .. 100;
   subtype Nanoseconds is Interfaces.Unsigned_64;
   subtype LED_Components is Interfaces.Unsigned_8;

   type Byte_Lists is array (Natural range <>) of aliased Interfaces.Unsigned_8 with
     Convention     => C,
     Component_Size => 8;

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

   type GUID_Element is range 0 .. 255 with
     Convention => C,
     Size       => 8;

   type GUID_Array is array (1 .. 16) of aliased GUID_Element with
     Convention => C;

   type GUIDs is record
      Data : GUID_Array;
   end record with
     Convention => C_Pass_By_Copy;

   function Has_Joystick return Boolean;

   function Get_Joysticks return ID_Lists;

   function Total return All_Devices;

   function Instance (Device : in Devices) return Instances;

   function Name (Device : in Devices) return String;

   function Name (Instance : in Instances) return String;

   function Path (Instance : in Instances) return String;

   function Player_Index (Instance : in Instances) return Player_Indices;

   function GUID (Device : in Devices) return GUIDs;

   function GUID (Instance : in Instances) return GUIDs;

   function Vendor (Instance : in Instances) return Vendor_IDs;

   function Product (Instance : in Instances) return Product_IDs;

   function Product_Version (Instance : in Instances) return Version_Numbers;

   function Get_Type (Instance : in Instances) return Types;

   function Image (GUID : in GUIDs) return String;

   function Value (GUID : in String) return GUIDs;

   type Virtual_Touchpad_Description is record
      Finger_Count : Interfaces.Unsigned_16 := 0;
      Padding      : Interfaces.Unsigned_16 := 0;
      Padding_2    : Interfaces.Unsigned_16 := 0;
      Padding_3    : Interfaces.Unsigned_16 := 0;
   end record with
     Convention => C;

   type Virtual_Touchpad_Descriptions is
     array (Natural range <>) of aliased Virtual_Touchpad_Description with
       Convention => C;

   type Virtual_Sensor_Description is record
      Sensor_Type : SDL.Sensors.Types := SDL.Sensors.Unknown;
      Rate        : C.C_float := 0.0;
   end record with
     Convention => C;

   type Virtual_Sensor_Descriptions is
     array (Natural range <>) of aliased Virtual_Sensor_Description with
       Convention => C;

   type Virtual_Touchpad_Description_Access is access constant Virtual_Touchpad_Description with
     Convention => C;

   type Virtual_Sensor_Description_Access is access constant Virtual_Sensor_Description with
     Convention => C;

   type Update_Callback is access procedure (User_Data : System.Address) with
     Convention => C;

   type Set_Player_Index_Callback is access procedure
     (User_Data    : System.Address;
      Player_Index : Player_Indices)
   with
     Convention => C;

   type Rumble_Callback is access function
     (User_Data              : System.Address;
      Low_Frequency_Rumble   : Interfaces.Unsigned_16;
      High_Frequency_Rumble  : Interfaces.Unsigned_16)
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
      Red       : LED_Components;
      Green     : LED_Components;
      Blue      : LED_Components)
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
      Kind                : Types := Unknown;
      Vendor_ID           : Vendor_IDs := 0;
      Product_ID          : Product_IDs := 0;
      Axis_Count          : Interfaces.Unsigned_16 := 0;
      Button_Count        : Interfaces.Unsigned_16 := 0;
      Ball_Count          : Interfaces.Unsigned_16 := 0;
      Hat_Count           : Interfaces.Unsigned_16 := 0;
      Touchpad_Count      : Interfaces.Unsigned_16 := 0;
      Sensor_Count        : Interfaces.Unsigned_16 := 0;
      Button_Mask         : Interfaces.Unsigned_32 := 0;
      Axis_Mask           : Interfaces.Unsigned_32 := 0;
      Name                : US.Unbounded_String := US.Null_Unbounded_String;
      Touchpads           : Virtual_Touchpad_Description_Access := null;
      Sensors             : Virtual_Sensor_Description_Access := null;
      User_Data           : System.Address := System.Null_Address;
      Update              : Update_Callback := null;
      Set_Player_Index    : Set_Player_Index_Callback := null;
      Rumble              : Rumble_Callback := null;
      Rumble_Triggers     : Rumble_Triggers_Callback := null;
      Set_LED             : Set_LED_Callback := null;
      Send_Effect         : Send_Effect_Callback := null;
      Set_Sensors_Enabled : Set_Sensors_Enabled_Callback := null;
      Cleanup             : Cleanup_Callback := null;
   end record;

   function Attach_Virtual
     (Description : in Virtual_Description) return Instances;

   procedure Detach_Virtual (Instance : in Instances);

   function Is_Virtual (Instance : in Instances) return Boolean;

   procedure Lock;

   procedure Unlock;

   type Joystick is new Ada.Finalization.Limited_Controlled with private;

   Null_Joystick : constant Joystick;

   overriding
   procedure Finalize (Self : in out Joystick);

   overriding
   function "=" (Left, Right : in Joystick) return Boolean;

   procedure Close (Self : in out Joystick);

   function Open (Instance : in Instances) return Joystick;

   procedure Open
     (Self     : in out Joystick;
      Instance : in Instances);

   function Get (Instance : in Instances) return Joystick;

   function Get_From_Player_Index
     (Player_Index : in Player_Indices) return Joystick;

   function Axes (Self : in Joystick) return SDL.Events.Joysticks.Axes;

   function Balls (Self : in Joystick) return SDL.Events.Joysticks.Balls;

   function Buttons (Self : in Joystick) return SDL.Events.Joysticks.Buttons;

   function Hats (Self : in Joystick) return SDL.Events.Joysticks.Hats;

   function Name (Self : in Joystick) return String;

   function Path (Self : in Joystick) return String;

   function Player_Index (Self : in Joystick) return Player_Indices;

   procedure Set_Player_Index
     (Self         : in Joystick;
      Player_Index : in Player_Indices);

   function Is_Haptic (Self : in Joystick) return Boolean;

   function Is_Attached (Self : in Joystick) return Boolean;

   function GUID (Self : in Joystick) return GUIDs;

   function Instance (Self : in Joystick) return Instances;

   function Get_Properties
     (Self : in Joystick) return SDL.Properties.Property_Set;

   function Vendor (Self : in Joystick) return Vendor_IDs;

   function Product (Self : in Joystick) return Product_IDs;

   function Product_Version (Self : in Joystick) return Version_Numbers;

   function Firmware_Version (Self : in Joystick) return Version_Numbers;

   function Serial (Self : in Joystick) return String;

   function Get_Type (Self : in Joystick) return Types;

   procedure GUID_Info
     (GUID      : in GUIDs;
      Vendor    : out Vendor_IDs;
      Product   : out Product_IDs;
      Version   : out Version_Numbers;
      CRC16     : out CRC16_Values);

   function Connection_State (Self : in Joystick) return Connection_States;

   function Get_Power_Info
     (Self       : in Joystick;
      Percentage : out Battery_Percentages) return SDL.Power.State;

   function Get_Internal
     (Self : in Joystick) return SDL.C_Pointers.Joystick_Pointer
   with
     Inline;

   function Axis_Value
     (Self : in Joystick;
      Axis : in SDL.Events.Joysticks.Axes)
      return SDL.Events.Joysticks.Axes_Values;

   function Get_Axis_Initial_State
     (Self  : in Joystick;
      Axis  : in SDL.Events.Joysticks.Axes;
      Value : out SDL.Events.Joysticks.Axes_Values) return Boolean;

   procedure Ball_Value
     (Self             : in Joystick;
      Ball             : in SDL.Events.Joysticks.Balls;
      Delta_X, Delta_Y : out SDL.Events.Joysticks.Ball_Values);

   function Hat_Value
     (Self : in Joystick;
      Hat  : in SDL.Events.Joysticks.Hats)
      return SDL.Events.Joysticks.Hat_Positions;

   function Is_Button_Pressed
     (Self   : in Joystick;
      Button : in SDL.Events.Joysticks.Buttons)
      return SDL.Events.Button_State;

   procedure Rumble
     (Self                 : in Joystick;
      Low_Frequency_Rumble : in Interfaces.Unsigned_16;
      High_Frequency_Rumble : in Interfaces.Unsigned_16;
      Duration_MS          : in Interfaces.Unsigned_32);

   procedure Rumble_Triggers
     (Self         : in Joystick;
      Left_Rumble  : in Interfaces.Unsigned_16;
      Right_Rumble : in Interfaces.Unsigned_16;
      Duration_MS  : in Interfaces.Unsigned_32);

   procedure Set_LED
     (Self  : in Joystick;
      Red   : in LED_Components;
      Green : in LED_Components;
      Blue  : in LED_Components);

   procedure Send_Effect
     (Self : in Joystick;
      Data : in Byte_Lists);

   procedure Set_Virtual_Axis
     (Self  : in Joystick;
      Axis  : in SDL.Events.Joysticks.Axes;
      Value : in SDL.Events.Joysticks.Axes_Values);

   procedure Set_Virtual_Ball
     (Self             : in Joystick;
      Ball             : in SDL.Events.Joysticks.Balls;
      Delta_X, Delta_Y : in SDL.Events.Joysticks.Ball_Values);

   procedure Set_Virtual_Button
     (Self   : in Joystick;
      Button : in SDL.Events.Joysticks.Buttons;
      Down   : in Boolean);

   procedure Set_Virtual_Hat
     (Self     : in Joystick;
      Hat      : in SDL.Events.Joysticks.Hats;
      Position : in SDL.Events.Joysticks.Hat_Positions);

   procedure Set_Virtual_Touchpad
     (Self      : in Joystick;
      Touchpad  : in C.int;
      Finger    : in C.int;
      Down      : in Boolean;
      X         : in C.C_float;
      Y         : in C.C_float;
      Pressure  : in C.C_float);

   procedure Send_Virtual_Sensor_Data
     (Self             : in Joystick;
      Sensor_Type      : in SDL.Sensors.Types;
      Sensor_Timestamp : in Nanoseconds;
      Data             : in SDL.Sensors.Data_Values);
private
   function Resolve_Device (Device : in Devices) return Instances;

   type Joystick is new Ada.Finalization.Limited_Controlled with record
      Internal : SDL.C_Pointers.Joystick_Pointer := null;
      Owns     : Boolean := True;
   end record;

   Null_Joystick : constant Joystick :=
     (Ada.Finalization.Limited_Controlled with
        Internal => null,
        Owns     => True);
end SDL.Inputs.Joysticks;
