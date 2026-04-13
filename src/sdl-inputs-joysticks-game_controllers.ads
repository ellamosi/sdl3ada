with Ada.Finalization;
with Ada.Strings.Unbounded;
with Interfaces;
with Interfaces.C;

with SDL.Events.Joysticks.Game_Controllers;
with SDL.Power;
with SDL.Properties;
with SDL.RWops;
with SDL.Sensors;

private with SDL.C_Pointers;

package SDL.Inputs.Joysticks.Game_Controllers is
   package C renames Interfaces.C;
   package US renames Ada.Strings.Unbounded;

   type Bind_Types is (None, Button, Axis, Hat) with
     Convention => C;

   type Hat_Bindings is record
      Hat  : SDL.Events.Joysticks.Hats;
      Mask : SDL.Events.Joysticks.Hat_Positions;
   end record with
     Convention => C;

   type Binding_Values (Which : Bind_Types := None) is record
      case Which is
         when None =>
            null;

         when Button =>
            Button : SDL.Events.Joysticks.Game_Controllers.Buttons;

         when Axis =>
            Axis   : SDL.Events.Joysticks.Game_Controllers.Axes;

         when Hat =>
            Hat    : Hat_Bindings;
      end case;
   end record with
     Unchecked_Union;

   type Bindings is record
      Which : Bind_Types;
      Value : Binding_Values;
   end record with
     Convention => C;

   type Binding_Lists is array (Natural range <>) of Bindings;

   Mapping_Error : exception;
   Game_Controller_Error : exception;

   subtype ID_Lists is SDL.Inputs.Joysticks.ID_Lists;
   subtype Vendor_IDs is SDL.Inputs.Joysticks.Vendor_IDs;
   subtype Product_IDs is SDL.Inputs.Joysticks.Product_IDs;
   subtype Version_Numbers is SDL.Inputs.Joysticks.Version_Numbers;
   subtype Battery_Percentages is SDL.Inputs.Joysticks.Battery_Percentages;
   subtype Player_Indices is SDL.Inputs.Joysticks.Player_Indices;
   subtype LED_Components is SDL.Inputs.Joysticks.LED_Components;
   subtype Steam_Handles is Interfaces.Unsigned_64;

   type Types is
     (Unknown,
      Standard,
      Xbox_360,
      Xbox_One,
      PS3,
      PS4,
      PS5,
      Nintendo_Switch_Pro,
      Nintendo_Switch_JoyCon_Left,
      Nintendo_Switch_JoyCon_Right,
      Nintendo_Switch_JoyCon_Pair,
      GameCube,
      Type_Count)
   with
     Convention => C,
     Size       => C.int'Size;

   for Types use
     (Unknown                       => 0,
      Standard                      => 1,
      Xbox_360                      => 2,
      Xbox_One                      => 3,
      PS3                           => 4,
      PS4                           => 5,
      PS5                           => 6,
      Nintendo_Switch_Pro           => 7,
      Nintendo_Switch_JoyCon_Left   => 8,
      Nintendo_Switch_JoyCon_Right  => 9,
      Nintendo_Switch_JoyCon_Pair   => 10,
      GameCube                      => 11,
      Type_Count                    => 12);

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

   type Mapping_Lists is array (Natural range <>) of US.Unbounded_String;

   type Touchpad_Finger_State is record
      Down     : Boolean := False;
      X        : C.C_float := 0.0;
      Y        : C.C_float := 0.0;
      Pressure : C.C_float := 0.0;
   end record;

   type Game_Controller is new Ada.Finalization.Limited_Controlled with private;

   Null_Game_Controller : constant Game_Controller;

   overriding
   procedure Finalize (Self : in out Game_Controller);

   subtype Uint16 is Interfaces.Unsigned_16;
   subtype Uint32 is Interfaces.Unsigned_32;

   procedure Add_Mapping
     (Data             : in String;
      Updated_Existing : out Boolean);

   procedure Add_Mappings_From_IO
     (Stream       : in SDL.RWops.Handle;
      Close_After  : in Boolean;
      Number_Added : out Natural);

   procedure Add_Mappings_From_IO
     (Stream       : in SDL.RWops.RWops;
      Number_Added : out Natural);

   procedure Add_Mappings_From_File
     (Database_Filename : in String;
      Number_Added      : out Natural);

   procedure Reload_Mappings;

   function Get_Mappings return Mapping_Lists;

   procedure Set_Mapping
     (Instance : in Instances;
      Mapping  : in String);

   function Has_Gamepad return Boolean;

   function Get_Gamepads return ID_Lists;

   function Axis_Value
     (Self : in Game_Controller;
      Axis : in SDL.Events.Joysticks.Game_Controllers.LR_Axes)
      return SDL.Events.Joysticks.Game_Controllers.LR_Axes_Values;

   function Axis_Value
     (Self : in Game_Controller;
      Axis : in SDL.Events.Joysticks.Game_Controllers.Trigger_Axes)
      return SDL.Events.Joysticks.Game_Controllers.Trigger_Axes_Values;

   procedure Close (Self : in out Game_Controller);

   function Open (Instance : in Instances) return Game_Controller;

   procedure Open
     (Self     : in out Game_Controller;
      Instance : in Instances);

   function Get (Instance : in Instances) return Game_Controller;

   function Get_From_Player_Index
     (Player_Index : in Player_Indices) return Game_Controller;

   function Get_Axis
     (Axis : in String) return SDL.Events.Joysticks.Game_Controllers.Axes;

   function Get_Bindings (Self : in Game_Controller) return Binding_Lists;

   function Get_Binding
     (Self : in Game_Controller;
      Axis : in SDL.Events.Joysticks.Game_Controllers.Axes) return Bindings;

   function Get_Binding
     (Self   : in Game_Controller;
      Button : in SDL.Events.Joysticks.Game_Controllers.Buttons) return Bindings;

   function Get_Button
     (Button_Name : in String) return SDL.Events.Joysticks.Game_Controllers.Buttons;

   function Get_Joystick (Self : in Game_Controller) return Joystick;

   function Get_Mapping (Self : in Game_Controller) return String;

   function Get_Mapping (Controller : in GUIDs) return String;

   function Get_Mapping (Instance : in Instances) return String;

   function Get_Name (Self : in Game_Controller) return String;

   function Get_Name (Device : in Devices) return String;

   function Get_Name (Instance : in Instances) return String;

   function Get_Path (Self : in Game_Controller) return String;

   function Get_Path (Instance : in Instances) return String;

   function Player_Index (Self : in Game_Controller) return Player_Indices;

   function Player_Index (Instance : in Instances) return Player_Indices;

   procedure Set_Player_Index
     (Self         : in Game_Controller;
      Player_Index : in Player_Indices);

   function GUID (Instance : in Instances) return GUIDs;

   function Get_Type (Self : in Game_Controller) return Types;

   function Get_Type (Instance : in Instances) return Types;

   function Get_Real_Type (Self : in Game_Controller) return Types;

   function Get_Real_Type (Instance : in Instances) return Types;

   function Vendor (Self : in Game_Controller) return Vendor_IDs;

   function Vendor (Instance : in Instances) return Vendor_IDs;

   function Product (Self : in Game_Controller) return Product_IDs;

   function Product (Instance : in Instances) return Product_IDs;

   function Product_Version (Self : in Game_Controller) return Version_Numbers;

   function Product_Version (Instance : in Instances) return Version_Numbers;

   function Firmware_Version (Self : in Game_Controller) return Version_Numbers;

   function Serial (Self : in Game_Controller) return String;

   function Steam_Handle (Self : in Game_Controller) return Steam_Handles;

   function Connection_State
     (Self : in Game_Controller) return SDL.Inputs.Joysticks.Connection_States;

   function Get_Power_Info
     (Self       : in Game_Controller;
      Percentage : out Battery_Percentages) return SDL.Power.State;

   function Get_Properties
     (Self : in Game_Controller) return SDL.Properties.Property_Set;

   function Get_ID (Self : in Game_Controller) return Instances;

   function Image
     (Axis : in SDL.Events.Joysticks.Game_Controllers.Axes) return String;

   function Image
     (Button : in SDL.Events.Joysticks.Game_Controllers.Buttons) return String;

   function Image (Kind : in Types) return String;

   function Type_From_String (Value : in String) return Types;

   function Is_Attached (Self : in Game_Controller) return Boolean;

   function Has_Axis
     (Self : in Game_Controller;
      Axis : in SDL.Events.Joysticks.Game_Controllers.Axes) return Boolean;

   function Is_Button_Pressed
     (Self   : in Game_Controller;
      Button : in SDL.Events.Joysticks.Game_Controllers.Buttons)
      return SDL.Events.Button_State;

   function Has_Button
     (Self   : in Game_Controller;
      Button : in SDL.Events.Joysticks.Game_Controllers.Buttons) return Boolean;

   function Is_Game_Controller (Device : in Devices) return Boolean;

   function Button_Label_For_Type
     (Kind   : in Types;
      Button : in SDL.Events.Joysticks.Game_Controllers.Buttons)
      return Button_Labels;

   function Button_Label
     (Self   : in Game_Controller;
      Button : in SDL.Events.Joysticks.Game_Controllers.Buttons)
      return Button_Labels;

   function Touchpads (Self : in Game_Controller) return Natural;

   function Touchpad_Fingers
     (Self     : in Game_Controller;
      Touchpad : in C.int) return Natural;

   function Touchpad_Finger
     (Self     : in Game_Controller;
      Touchpad : in C.int;
      Finger   : in C.int) return Touchpad_Finger_State;

   function Has_Sensor
     (Self        : in Game_Controller;
      Sensor_Type : in SDL.Sensors.Types) return Boolean;

   procedure Set_Sensor_Enabled
     (Self        : in Game_Controller;
      Sensor_Type : in SDL.Sensors.Types;
      Enabled     : in Boolean);

   function Sensor_Enabled
     (Self        : in Game_Controller;
      Sensor_Type : in SDL.Sensors.Types) return Boolean;

   function Sensor_Data_Rate
     (Self        : in Game_Controller;
      Sensor_Type : in SDL.Sensors.Types) return C.C_float;

   procedure Get_Sensor_Data
     (Self        : in Game_Controller;
      Sensor_Type : in SDL.Sensors.Types;
      Data        : out SDL.Sensors.Data_Values);

   function Get_Sensor_Data
     (Self        : in Game_Controller;
      Sensor_Type : in SDL.Sensors.Types;
      Value_Count : in Positive) return SDL.Sensors.Data_Values;

   function Has_Rumble (Self : in Game_Controller) return Boolean;

   function Rumble
     (Self           : in Game_Controller;
      Low_Frequency  : in Uint16;
      High_Frequency : in Uint16;
      Duration       : in Uint32) return Integer;

   procedure Rumble_Triggers
     (Self         : in Game_Controller;
      Left_Rumble  : in Uint16;
      Right_Rumble : in Uint16;
      Duration     : in Uint32);

   procedure Set_LED
     (Self  : in Game_Controller;
      Red   : in LED_Components;
      Green : in LED_Components;
      Blue  : in LED_Components);

   procedure Send_Effect
     (Self : in Game_Controller;
      Data : in SDL.Inputs.Joysticks.Byte_Lists);

   function Apple_SF_Symbol_Name
     (Self   : in Game_Controller;
      Button : in SDL.Events.Joysticks.Game_Controllers.Buttons) return String;

   function Apple_SF_Symbol_Name
     (Self : in Game_Controller;
      Axis : in SDL.Events.Joysticks.Game_Controllers.Axes) return String;
private
   type Game_Controller is new Ada.Finalization.Limited_Controlled with record
      Internal : SDL.C_Pointers.Game_Controller_Pointer := null;
      Owns     : Boolean := True;
   end record;

   Null_Game_Controller : constant Game_Controller :=
     (Ada.Finalization.Limited_Controlled with
        Internal => null,
        Owns     => True);
end SDL.Inputs.Joysticks.Game_Controllers;
