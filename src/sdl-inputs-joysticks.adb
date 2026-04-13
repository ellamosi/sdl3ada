with Ada.Unchecked_Conversion;
with Interfaces.C;
with Interfaces.C.Extensions;
with Interfaces.C.Pointers;
with Interfaces.C.Strings;
with System;

with SDL.Error;

package body SDL.Inputs.Joysticks is
   package CS renames Interfaces.C.Strings;

   use type C.ptrdiff_t;
   use type CS.chars_ptr;
   use type SDL.C_Pointers.Joystick_Pointer;
   use type SDL.Events.Joysticks.IDs;
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

   type Raw_Virtual_Description is record
      Version             : Interfaces.Unsigned_32;
      Kind                : Interfaces.Unsigned_16;
      Padding             : Interfaces.Unsigned_16;
      Vendor_ID           : Vendor_IDs;
      Product_ID          : Product_IDs;
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

   function To_Address is new Ada.Unchecked_Conversion
     (Source => Instance_Pointers.Pointer,
      Target => System.Address);

   procedure SDL_Free (Memory : in System.Address)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_free";

   function SDL_Has_Joystick return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_HasJoystick";

   function SDL_Get_Joysticks
     (Count : access C.int) return Instance_Pointers.Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetJoysticks";

   function SDL_Get_Joystick_Name_For_ID
     (Instance : in Instances) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetJoystickNameForID";

   function SDL_Get_Joystick_Path_For_ID
     (Instance : in Instances) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetJoystickPathForID";

   function SDL_Get_Joystick_Player_Index_For_ID
     (Instance : in Instances) return Player_Indices
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetJoystickPlayerIndexForID";

   function SDL_Get_Joystick_GUID_For_ID
     (Instance : in Instances) return GUIDs
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetJoystickGUIDForID";

   function SDL_Get_Joystick_Vendor_For_ID
     (Instance : in Instances) return Vendor_IDs
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetJoystickVendorForID";

   function SDL_Get_Joystick_Product_For_ID
     (Instance : in Instances) return Product_IDs
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetJoystickProductForID";

   function SDL_Get_Joystick_Product_Version_For_ID
     (Instance : in Instances) return Version_Numbers
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetJoystickProductVersionForID";

   function SDL_Get_Joystick_Type_For_ID
     (Instance : in Instances) return Types
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetJoystickTypeForID";

   function SDL_Open_Joystick
     (Instance : in Instances) return SDL.C_Pointers.Joystick_Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_OpenJoystick";

   function SDL_Get_Joystick_From_ID
     (Instance : in Instances) return SDL.C_Pointers.Joystick_Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetJoystickFromID";

   function SDL_Get_Joystick_From_Player_Index
     (Player_Index : in Player_Indices) return SDL.C_Pointers.Joystick_Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetJoystickFromPlayerIndex";

   function SDL_Attach_Virtual_Joystick
     (Description : access constant Raw_Virtual_Description) return Instances
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_AttachVirtualJoystick";

   function SDL_Detach_Virtual_Joystick
     (Instance : in Instances) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_DetachVirtualJoystick";

   function SDL_Is_Joystick_Virtual
     (Instance : in Instances) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_IsJoystickVirtual";

   procedure SDL_Lock_Joysticks
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_LockJoysticks";

   procedure SDL_Unlock_Joysticks
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_UnlockJoysticks";

   procedure SDL_Close_Joystick
     (Value : in SDL.C_Pointers.Joystick_Pointer)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CloseJoystick";

   function SDL_Get_Joystick_Properties
     (Self : in SDL.C_Pointers.Joystick_Pointer) return SDL.Properties.Property_ID
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetJoystickProperties";

   function SDL_Get_Joystick_Name
     (Self : in SDL.C_Pointers.Joystick_Pointer) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetJoystickName";

   function SDL_Get_Joystick_Path
     (Self : in SDL.C_Pointers.Joystick_Pointer) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetJoystickPath";

   function SDL_Get_Joystick_Player_Index
     (Self : in SDL.C_Pointers.Joystick_Pointer) return Player_Indices
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetJoystickPlayerIndex";

   function SDL_Set_Joystick_Player_Index
     (Self         : in SDL.C_Pointers.Joystick_Pointer;
      Player_Index : in Player_Indices) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetJoystickPlayerIndex";

   function SDL_Is_Joystick_Haptic
     (Value : in SDL.C_Pointers.Joystick_Pointer) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_IsJoystickHaptic";

   function SDL_Joystick_Connected
     (Value : in SDL.C_Pointers.Joystick_Pointer) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_JoystickConnected";

   function SDL_Get_Joystick_GUID
     (Value : in SDL.C_Pointers.Joystick_Pointer) return GUIDs
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetJoystickGUID";

   function SDL_Get_Joystick_Vendor
     (Self : in SDL.C_Pointers.Joystick_Pointer) return Vendor_IDs
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetJoystickVendor";

   function SDL_Get_Joystick_Product
     (Self : in SDL.C_Pointers.Joystick_Pointer) return Product_IDs
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetJoystickProduct";

   function SDL_Get_Joystick_Product_Version
     (Self : in SDL.C_Pointers.Joystick_Pointer) return Version_Numbers
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetJoystickProductVersion";

   function SDL_Get_Joystick_Firmware_Version
     (Self : in SDL.C_Pointers.Joystick_Pointer) return Version_Numbers
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetJoystickFirmwareVersion";

   function SDL_Get_Joystick_Serial
     (Self : in SDL.C_Pointers.Joystick_Pointer) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetJoystickSerial";

   function SDL_Get_Joystick_Type
     (Self : in SDL.C_Pointers.Joystick_Pointer) return Types
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetJoystickType";

   procedure SDL_Get_Joystick_GUID_Info
     (GUID    : in GUIDs;
      Vendor  : access Vendor_IDs;
      Product : access Product_IDs;
      Version : access Version_Numbers;
      CRC16   : access CRC16_Values)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetJoystickGUIDInfo";

   function SDL_Get_Joystick_ID
     (Value : in SDL.C_Pointers.Joystick_Pointer) return Instances
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetJoystickID";

   function SDL_Get_Num_Joystick_Axes
     (Value : in SDL.C_Pointers.Joystick_Pointer) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetNumJoystickAxes";

   function SDL_Get_Num_Joystick_Balls
     (Value : in SDL.C_Pointers.Joystick_Pointer) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetNumJoystickBalls";

   function SDL_Get_Num_Joystick_Hats
     (Value : in SDL.C_Pointers.Joystick_Pointer) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetNumJoystickHats";

   function SDL_Get_Num_Joystick_Buttons
     (Value : in SDL.C_Pointers.Joystick_Pointer) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetNumJoystickButtons";

   function SDL_Get_Joystick_Connection_State
     (Self : in SDL.C_Pointers.Joystick_Pointer) return Connection_States
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetJoystickConnectionState";

   function SDL_Get_Joystick_Power_Info
     (Self       : in SDL.C_Pointers.Joystick_Pointer;
      Percentage : access C.int) return SDL.Power.State
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetJoystickPowerInfo";

   function SDL_Get_Joystick_Axis
     (Value : in SDL.C_Pointers.Joystick_Pointer;
      Axis  : in C.int) return SDL.Events.Joysticks.Axes_Values
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetJoystickAxis";

   function SDL_Get_Joystick_Axis_Initial_State
     (Value : in SDL.C_Pointers.Joystick_Pointer;
      Axis  : in C.int;
      State : access SDL.Events.Joysticks.Axes_Values) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetJoystickAxisInitialState";

   function SDL_Get_Joystick_Ball
     (Value : in SDL.C_Pointers.Joystick_Pointer;
      Ball  : in C.int;
      X, Y  : access C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetJoystickBall";

   function SDL_Get_Joystick_Hat
     (Value : in SDL.C_Pointers.Joystick_Pointer;
      Hat   : in C.int) return SDL.Events.Joysticks.Hat_Positions
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetJoystickHat";

   function SDL_Get_Joystick_Button
     (Value  : in SDL.C_Pointers.Joystick_Pointer;
      Button : in C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetJoystickButton";

   function SDL_Rumble_Joystick
     (Self                  : in SDL.C_Pointers.Joystick_Pointer;
      Low_Frequency_Rumble  : in Interfaces.Unsigned_16;
      High_Frequency_Rumble : in Interfaces.Unsigned_16;
      Duration_MS           : in Interfaces.Unsigned_32) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_RumbleJoystick";

   function SDL_Rumble_Joystick_Triggers
     (Self         : in SDL.C_Pointers.Joystick_Pointer;
      Left_Rumble  : in Interfaces.Unsigned_16;
      Right_Rumble : in Interfaces.Unsigned_16;
      Duration_MS  : in Interfaces.Unsigned_32) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_RumbleJoystickTriggers";

   function SDL_Set_Joystick_LED
     (Self  : in SDL.C_Pointers.Joystick_Pointer;
      Red   : in LED_Components;
      Green : in LED_Components;
      Blue  : in LED_Components) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetJoystickLED";

   function SDL_Send_Joystick_Effect
     (Self : in SDL.C_Pointers.Joystick_Pointer;
      Data : in System.Address;
      Size : in C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SendJoystickEffect";

   function SDL_Set_Joystick_Virtual_Axis
     (Self  : in SDL.C_Pointers.Joystick_Pointer;
      Axis  : in C.int;
      Value : in SDL.Events.Joysticks.Axes_Values) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetJoystickVirtualAxis";

   function SDL_Set_Joystick_Virtual_Ball
     (Self : in SDL.C_Pointers.Joystick_Pointer;
      Ball : in C.int;
      Xrel : in SDL.Events.Joysticks.Ball_Values;
      Yrel : in SDL.Events.Joysticks.Ball_Values) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetJoystickVirtualBall";

   function SDL_Set_Joystick_Virtual_Button
     (Self   : in SDL.C_Pointers.Joystick_Pointer;
      Button : in C.int;
      Down   : in CE.bool) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetJoystickVirtualButton";

   function SDL_Set_Joystick_Virtual_Hat
     (Self  : in SDL.C_Pointers.Joystick_Pointer;
      Hat   : in C.int;
      Value : in SDL.Events.Joysticks.Hat_Positions) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetJoystickVirtualHat";

   function SDL_Set_Joystick_Virtual_Touchpad
     (Self     : in SDL.C_Pointers.Joystick_Pointer;
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

   function SDL_Send_Joystick_Virtual_Sensor_Data
     (Self             : in SDL.C_Pointers.Joystick_Pointer;
      Sensor_Type      : in SDL.Sensors.Types;
      Sensor_Timestamp : in Nanoseconds;
      Data             : in System.Address;
      Value_Count      : in C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SendJoystickVirtualSensorData";

   procedure Raise_Last_Error
     (Default_Message : in String := "SDL joystick call failed");

   procedure Raise_Last_Error
     (Default_Message : in String := "SDL joystick call failed")
   is
      Message : constant String := SDL.Error.Get;
   begin
      if Message = "" then
         raise Joystick_Error with Default_Message;
      end if;

      raise Joystick_Error with Message;
   end Raise_Last_Error;

   function To_C_Bool (Value : in Boolean) return CE.bool is
     (if Value then CE.bool'Val (1) else CE.bool'Val (0));

   procedure Require_Valid (Self : in Joystick);

   procedure Require_Valid (Self : in Joystick) is
   begin
      if Self.Internal = null then
         raise Joystick_Error with "Invalid joystick";
      end if;
   end Require_Valid;

   procedure Free (Value : in out Instance_Pointers.Pointer);

   procedure Free (Value : in out Instance_Pointers.Pointer) is
   begin
      if Value /= null then
         SDL_Free (To_Address (Value));
         Value := null;
      end if;
   end Free;

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
         Raise_Last_Error ("Joystick enumeration failed");
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

   function Buffer_Address (Data : in Byte_Lists) return System.Address is
     (if Data'Length = 0 then System.Null_Address
      else Data (Data'First)'Address);

   function Float_Data_Address
     (Data : in SDL.Sensors.Data_Values) return System.Address is
     (if Data'Length = 0 then System.Null_Address
      else Data (Data'First)'Address);

   function Has_Joystick return Boolean is
   begin
      return Boolean (SDL_Has_Joystick);
   end Has_Joystick;

   function Get_Joysticks return ID_Lists is
      Count : aliased C.int := 0;
      Items : constant Instance_Pointers.Pointer := SDL_Get_Joysticks (Count'Access);
   begin
      return Copy_IDs (Items, Count);
   end Get_Joysticks;

   function Total return All_Devices is
   begin
      return All_Devices (Get_Joysticks'Length);
   end Total;

   function Resolve_Device (Device : in Devices) return Instances is
      IDs : constant ID_Lists := Get_Joysticks;
   begin
      if IDs'Length = 0 then
         raise Joystick_Error with "No joystick devices are available";
      end if;

      if Natural (Device) > IDs'Length then
         raise Joystick_Error with "Joystick device index is out of range";
      end if;

      return IDs (Natural (Device) - 1);
   end Resolve_Device;

   function Instance (Device : in Devices) return Instances is
     (Resolve_Device (Device));

   function Name (Device : in Devices) return String is
     (Name (Resolve_Device (Device)));

   function Name (Instance : in Instances) return String is
      Result : constant CS.chars_ptr := SDL_Get_Joystick_Name_For_ID (Instance);
   begin
      if Result = CS.Null_Ptr then
         return "";
      end if;

      return CS.Value (Result);
   end Name;

   function Path (Instance : in Instances) return String is
      Result : constant CS.chars_ptr := SDL_Get_Joystick_Path_For_ID (Instance);
   begin
      if Result = CS.Null_Ptr then
         return "";
      end if;

      return CS.Value (Result);
   end Path;

   function Player_Index (Instance : in Instances) return Player_Indices is
   begin
      return SDL_Get_Joystick_Player_Index_For_ID (Instance);
   end Player_Index;

   function GUID (Device : in Devices) return GUIDs is
     (GUID (Resolve_Device (Device)));

   function GUID (Instance : in Instances) return GUIDs is
   begin
      return SDL_Get_Joystick_GUID_For_ID (Instance);
   end GUID;

   function Vendor (Instance : in Instances) return Vendor_IDs is
   begin
      return SDL_Get_Joystick_Vendor_For_ID (Instance);
   end Vendor;

   function Product (Instance : in Instances) return Product_IDs is
   begin
      return SDL_Get_Joystick_Product_For_ID (Instance);
   end Product;

   function Product_Version (Instance : in Instances) return Version_Numbers is
   begin
      return SDL_Get_Joystick_Product_Version_For_ID (Instance);
   end Product_Version;

   function Get_Type (Instance : in Instances) return Types is
   begin
      return SDL_Get_Joystick_Type_For_ID (Instance);
   end Get_Type;

   function Image (GUID : in GUIDs) return String is
      procedure SDL_GUID_To_String
        (Value  : in GUIDs;
         Buffer : out C.char_array;
         Size   : in C.int)
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GUIDToString";

      Buffer : C.char_array (0 .. 32) := (others => C.nul);
   begin
      SDL_GUID_To_String (GUID, Buffer, C.int (Buffer'Length));
      return C.To_Ada (Buffer);
   end Image;

   function Value (GUID : in String) return GUIDs is
      function SDL_GUID_From_String
        (Buffer : in C.char_array) return GUIDs
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_StringToGUID";
   begin
      return SDL_GUID_From_String (C.To_C (GUID));
   end Value;

   function Attach_Virtual
     (Description : in Virtual_Description) return Instances
   is
      Name_Ptr : CS.chars_ptr := CS.Null_Ptr;
      Raw      : aliased Raw_Virtual_Description :=
        (Version             => Interfaces.Unsigned_32
           (Raw_Virtual_Description'Size / System.Storage_Unit),
         Kind                => Interfaces.Unsigned_16 (Types'Pos (Description.Kind)),
         Padding             => 0,
         Vendor_ID           => Description.Vendor_ID,
         Product_ID          => Description.Product_ID,
         Axis_Count          => Description.Axis_Count,
         Button_Count        => Description.Button_Count,
         Ball_Count          => Description.Ball_Count,
         Hat_Count           => Description.Hat_Count,
         Touchpad_Count      => Description.Touchpad_Count,
         Sensor_Count        => Description.Sensor_Count,
         Padding_2           => 0,
         Padding_3           => 0,
         Button_Mask         => Description.Button_Mask,
         Axis_Mask           => Description.Axis_Mask,
         Name                => CS.Null_Ptr,
         Touchpads           => Description.Touchpads,
         Sensors             => Description.Sensors,
         User_Data           => Description.User_Data,
         Update              => Description.Update,
         Set_Player_Index    => Description.Set_Player_Index,
         Rumble              => Description.Rumble,
         Rumble_Triggers     => Description.Rumble_Triggers,
         Set_LED             => Description.Set_LED,
         Send_Effect         => Description.Send_Effect,
         Set_Sensors_Enabled => Description.Set_Sensors_Enabled,
         Cleanup             => Description.Cleanup);

      Result : Instances := 0;
   begin
      if US.Length (Description.Name) > 0 then
         Name_Ptr := CS.New_String (US.To_String (Description.Name));
         Raw.Name := Name_Ptr;
      end if;

      Result := SDL_Attach_Virtual_Joystick (Raw'Access);
      if Result = 0 then
         Raise_Last_Error ("SDL_AttachVirtualJoystick failed");
      end if;

      if Name_Ptr /= CS.Null_Ptr then
         CS.Free (Name_Ptr);
      end if;

      return Result;
   exception
      when others =>
         if Name_Ptr /= CS.Null_Ptr then
            CS.Free (Name_Ptr);
         end if;

         raise;
   end Attach_Virtual;

   procedure Detach_Virtual (Instance : in Instances) is
   begin
      if not Boolean (SDL_Detach_Virtual_Joystick (Instance)) then
         Raise_Last_Error ("SDL_DetachVirtualJoystick failed");
      end if;
   end Detach_Virtual;

   function Is_Virtual (Instance : in Instances) return Boolean is
   begin
      return Boolean (SDL_Is_Joystick_Virtual (Instance));
   end Is_Virtual;

   procedure Lock is
   begin
      SDL_Lock_Joysticks;
   end Lock;

   procedure Unlock is
   begin
      SDL_Unlock_Joysticks;
   end Unlock;

   function Open (Instance : in Instances) return Joystick is
   begin
      return Result : Joystick do
         Open (Result, Instance);
      end return;
   end Open;

   procedure Open
     (Self     : in out Joystick;
      Instance : in Instances)
   is
      Internal : SDL.C_Pointers.Joystick_Pointer := null;
   begin
      Close (Self);

      Internal := SDL_Open_Joystick (Instance);
      if Internal = null then
         Raise_Last_Error ("SDL_OpenJoystick failed");
      end if;

      Self.Internal := Internal;
      Self.Owns := True;
   end Open;

   function Get (Instance : in Instances) return Joystick is
   begin
      return (Ada.Finalization.Limited_Controlled with
              Internal => SDL_Get_Joystick_From_ID (Instance),
              Owns     => False);
   end Get;

   function Get_From_Player_Index
     (Player_Index : in Player_Indices) return Joystick
   is
   begin
      return (Ada.Finalization.Limited_Controlled with
              Internal => SDL_Get_Joystick_From_Player_Index (Player_Index),
              Owns     => False);
   end Get_From_Player_Index;

   overriding
   procedure Finalize (Self : in out Joystick) is
   begin
      if Self.Owns and then Self.Internal /= null then
         SDL_Close_Joystick (Self.Internal);
      end if;

      Self.Internal := null;
      Self.Owns := True;
   end Finalize;

   overriding
   function "=" (Left, Right : in Joystick) return Boolean is
   begin
      return Left.Internal = Right.Internal and then Left.Owns = Right.Owns;
   end "=";

   procedure Close (Self : in out Joystick) is
   begin
      Finalize (Self);
   end Close;

   function Axes (Self : in Joystick) return SDL.Events.Joysticks.Axes is
      Result : C.int;
   begin
      Require_Valid (Self);
      Result := SDL_Get_Num_Joystick_Axes (Self.Internal);

      if Result < 0 then
         Raise_Last_Error ("SDL_GetNumJoystickAxes failed");
      end if;

      return SDL.Events.Joysticks.Axes (Result);
   end Axes;

   function Balls (Self : in Joystick) return SDL.Events.Joysticks.Balls is
      Result : C.int;
   begin
      Require_Valid (Self);
      Result := SDL_Get_Num_Joystick_Balls (Self.Internal);

      if Result < 0 then
         Raise_Last_Error ("SDL_GetNumJoystickBalls failed");
      end if;

      return SDL.Events.Joysticks.Balls (Result);
   end Balls;

   function Buttons (Self : in Joystick) return SDL.Events.Joysticks.Buttons is
      Result : C.int;
   begin
      Require_Valid (Self);
      Result := SDL_Get_Num_Joystick_Buttons (Self.Internal);

      if Result < 0 then
         Raise_Last_Error ("SDL_GetNumJoystickButtons failed");
      end if;

      return SDL.Events.Joysticks.Buttons (Result);
   end Buttons;

   function Hats (Self : in Joystick) return SDL.Events.Joysticks.Hats is
      Result : C.int;
   begin
      Require_Valid (Self);
      Result := SDL_Get_Num_Joystick_Hats (Self.Internal);

      if Result < 0 then
         Raise_Last_Error ("SDL_GetNumJoystickHats failed");
      end if;

      return SDL.Events.Joysticks.Hats (Result);
   end Hats;

   function Name (Self : in Joystick) return String is
      Result : CS.chars_ptr;
   begin
      Require_Valid (Self);
      Result := SDL_Get_Joystick_Name (Self.Internal);

      if Result = CS.Null_Ptr then
         return "";
      end if;

      return CS.Value (Result);
   end Name;

   function Path (Self : in Joystick) return String is
      Result : CS.chars_ptr;
   begin
      Require_Valid (Self);
      Result := SDL_Get_Joystick_Path (Self.Internal);

      if Result = CS.Null_Ptr then
         return "";
      end if;

      return CS.Value (Result);
   end Path;

   function Player_Index (Self : in Joystick) return Player_Indices is
   begin
      Require_Valid (Self);
      return SDL_Get_Joystick_Player_Index (Self.Internal);
   end Player_Index;

   procedure Set_Player_Index
     (Self         : in Joystick;
      Player_Index : in Player_Indices)
   is
   begin
      Require_Valid (Self);

      if not Boolean (SDL_Set_Joystick_Player_Index (Self.Internal, Player_Index)) then
         Raise_Last_Error ("SDL_SetJoystickPlayerIndex failed");
      end if;
   end Set_Player_Index;

   function Is_Haptic (Self : in Joystick) return Boolean is
   begin
      Require_Valid (Self);
      return Boolean (SDL_Is_Joystick_Haptic (Self.Internal));
   end Is_Haptic;

   function Is_Attached (Self : in Joystick) return Boolean is
   begin
      Require_Valid (Self);
      return Boolean (SDL_Joystick_Connected (Self.Internal));
   end Is_Attached;

   function GUID (Self : in Joystick) return GUIDs is
   begin
      Require_Valid (Self);
      return SDL_Get_Joystick_GUID (Self.Internal);
   end GUID;

   function Instance (Self : in Joystick) return Instances is
      Result : Instances;
   begin
      Require_Valid (Self);
      Result := SDL_Get_Joystick_ID (Self.Internal);

      if Result = 0 then
         Raise_Last_Error ("SDL_GetJoystickID failed");
      end if;

      return Result;
   end Instance;

   function Get_Properties
     (Self : in Joystick) return SDL.Properties.Property_Set
   is
   begin
      Require_Valid (Self);
      return SDL.Properties.Reference (SDL_Get_Joystick_Properties (Self.Internal));
   end Get_Properties;

   function Vendor (Self : in Joystick) return Vendor_IDs is
   begin
      Require_Valid (Self);
      return SDL_Get_Joystick_Vendor (Self.Internal);
   end Vendor;

   function Product (Self : in Joystick) return Product_IDs is
   begin
      Require_Valid (Self);
      return SDL_Get_Joystick_Product (Self.Internal);
   end Product;

   function Product_Version (Self : in Joystick) return Version_Numbers is
   begin
      Require_Valid (Self);
      return SDL_Get_Joystick_Product_Version (Self.Internal);
   end Product_Version;

   function Firmware_Version (Self : in Joystick) return Version_Numbers is
   begin
      Require_Valid (Self);
      return SDL_Get_Joystick_Firmware_Version (Self.Internal);
   end Firmware_Version;

   function Serial (Self : in Joystick) return String is
      Result : CS.chars_ptr;
   begin
      Require_Valid (Self);
      Result := SDL_Get_Joystick_Serial (Self.Internal);

      if Result = CS.Null_Ptr then
         return "";
      end if;

      return CS.Value (Result);
   end Serial;

   function Get_Type (Self : in Joystick) return Types is
   begin
      Require_Valid (Self);
      return SDL_Get_Joystick_Type (Self.Internal);
   end Get_Type;

   procedure GUID_Info
     (GUID      : in GUIDs;
      Vendor    : out Vendor_IDs;
      Product   : out Product_IDs;
      Version   : out Version_Numbers;
      CRC16     : out CRC16_Values)
   is
      Vendor_Value  : aliased Vendor_IDs := 0;
      Product_Value : aliased Product_IDs := 0;
      Version_Value : aliased Version_Numbers := 0;
      CRC16_Value   : aliased CRC16_Values := 0;
   begin
      SDL_Get_Joystick_GUID_Info
        (GUID,
         Vendor_Value'Access,
         Product_Value'Access,
         Version_Value'Access,
         CRC16_Value'Access);
      Vendor := Vendor_Value;
      Product := Product_Value;
      Version := Version_Value;
      CRC16 := CRC16_Value;
   end GUID_Info;

   function Connection_State (Self : in Joystick) return Connection_States is
   begin
      Require_Valid (Self);
      return SDL_Get_Joystick_Connection_State (Self.Internal);
   end Connection_State;

   function Get_Power_Info
     (Self       : in Joystick;
      Percentage : out Battery_Percentages) return SDL.Power.State
   is
      Raw_Percentage : aliased C.int := -1;
   begin
      Require_Valid (Self);
      Percentage := -1;

      declare
         Result : constant SDL.Power.State :=
           SDL_Get_Joystick_Power_Info (Self.Internal, Raw_Percentage'Access);
      begin
         Percentage := Battery_Percentages (Raw_Percentage);
         return Result;
      end;
   end Get_Power_Info;

   function Get_Internal
     (Self : in Joystick) return SDL.C_Pointers.Joystick_Pointer is
   begin
      return Self.Internal;
   end Get_Internal;

   function Axis_Value
     (Self : in Joystick;
      Axis : in SDL.Events.Joysticks.Axes)
      return SDL.Events.Joysticks.Axes_Values
   is
   begin
      Require_Valid (Self);
      return SDL_Get_Joystick_Axis (Self.Internal, C.int (Axis));
   end Axis_Value;

   function Get_Axis_Initial_State
     (Self  : in Joystick;
      Axis  : in SDL.Events.Joysticks.Axes;
      Value : out SDL.Events.Joysticks.Axes_Values) return Boolean
   is
      Raw_Value : aliased SDL.Events.Joysticks.Axes_Values := 0;
   begin
      Require_Valid (Self);

      if not Boolean
          (SDL_Get_Joystick_Axis_Initial_State
             (Self.Internal,
              C.int (Axis),
              Raw_Value'Access))
      then
         Value := 0;
         return False;
      end if;

      Value := Raw_Value;
      return True;
   end Get_Axis_Initial_State;

   procedure Ball_Value
     (Self             : in Joystick;
      Ball             : in SDL.Events.Joysticks.Balls;
      Delta_X, Delta_Y : out SDL.Events.Joysticks.Ball_Values)
   is
      X : aliased C.int := 0;
      Y : aliased C.int := 0;
   begin
      Require_Valid (Self);

      if not Boolean
          (SDL_Get_Joystick_Ball (Self.Internal, C.int (Ball), X'Access, Y'Access))
      then
         Raise_Last_Error ("SDL_GetJoystickBall failed");
      end if;

      Delta_X := SDL.Events.Joysticks.Ball_Values (X);
      Delta_Y := SDL.Events.Joysticks.Ball_Values (Y);
   end Ball_Value;

   function Hat_Value
     (Self : in Joystick;
      Hat  : in SDL.Events.Joysticks.Hats)
      return SDL.Events.Joysticks.Hat_Positions
   is
   begin
      Require_Valid (Self);
      return SDL_Get_Joystick_Hat (Self.Internal, C.int (Hat));
   end Hat_Value;

   function Is_Button_Pressed
     (Self   : in Joystick;
      Button : in SDL.Events.Joysticks.Buttons)
      return SDL.Events.Button_State
   is
   begin
      Require_Valid (Self);

      if Boolean (SDL_Get_Joystick_Button (Self.Internal, C.int (Button))) then
         return SDL.Events.Pressed;
      end if;

      return SDL.Events.Released;
   end Is_Button_Pressed;

   procedure Rumble
     (Self                  : in Joystick;
      Low_Frequency_Rumble  : in Interfaces.Unsigned_16;
      High_Frequency_Rumble : in Interfaces.Unsigned_16;
      Duration_MS           : in Interfaces.Unsigned_32)
   is
   begin
      Require_Valid (Self);

      if not Boolean
          (SDL_Rumble_Joystick
             (Self.Internal,
              Low_Frequency_Rumble,
              High_Frequency_Rumble,
              Duration_MS))
      then
         Raise_Last_Error ("SDL_RumbleJoystick failed");
      end if;
   end Rumble;

   procedure Rumble_Triggers
     (Self         : in Joystick;
      Left_Rumble  : in Interfaces.Unsigned_16;
      Right_Rumble : in Interfaces.Unsigned_16;
      Duration_MS  : in Interfaces.Unsigned_32)
   is
   begin
      Require_Valid (Self);

      if not Boolean
          (SDL_Rumble_Joystick_Triggers
             (Self.Internal,
              Left_Rumble,
              Right_Rumble,
              Duration_MS))
      then
         Raise_Last_Error ("SDL_RumbleJoystickTriggers failed");
      end if;
   end Rumble_Triggers;

   procedure Set_LED
     (Self  : in Joystick;
      Red   : in LED_Components;
      Green : in LED_Components;
      Blue  : in LED_Components)
   is
   begin
      Require_Valid (Self);

      if not Boolean (SDL_Set_Joystick_LED (Self.Internal, Red, Green, Blue)) then
         Raise_Last_Error ("SDL_SetJoystickLED failed");
      end if;
   end Set_LED;

   procedure Send_Effect
     (Self : in Joystick;
      Data : in Byte_Lists)
   is
   begin
      Require_Valid (Self);

      if not Boolean
          (SDL_Send_Joystick_Effect
             (Self.Internal,
              Buffer_Address (Data),
              C.int (Data'Length)))
      then
         Raise_Last_Error ("SDL_SendJoystickEffect failed");
      end if;
   end Send_Effect;

   procedure Set_Virtual_Axis
     (Self  : in Joystick;
      Axis  : in SDL.Events.Joysticks.Axes;
      Value : in SDL.Events.Joysticks.Axes_Values)
   is
   begin
      Require_Valid (Self);

      if not Boolean
          (SDL_Set_Joystick_Virtual_Axis
             (Self.Internal,
              C.int (Axis),
              Value))
      then
         Raise_Last_Error ("SDL_SetJoystickVirtualAxis failed");
      end if;
   end Set_Virtual_Axis;

   procedure Set_Virtual_Ball
     (Self             : in Joystick;
      Ball             : in SDL.Events.Joysticks.Balls;
      Delta_X, Delta_Y : in SDL.Events.Joysticks.Ball_Values)
   is
   begin
      Require_Valid (Self);

      if not Boolean
          (SDL_Set_Joystick_Virtual_Ball
             (Self.Internal,
              C.int (Ball),
              Delta_X,
              Delta_Y))
      then
         Raise_Last_Error ("SDL_SetJoystickVirtualBall failed");
      end if;
   end Set_Virtual_Ball;

   procedure Set_Virtual_Button
     (Self   : in Joystick;
      Button : in SDL.Events.Joysticks.Buttons;
      Down   : in Boolean)
   is
   begin
      Require_Valid (Self);

      if not Boolean
          (SDL_Set_Joystick_Virtual_Button
             (Self.Internal,
              C.int (Button),
              To_C_Bool (Down)))
      then
         Raise_Last_Error ("SDL_SetJoystickVirtualButton failed");
      end if;
   end Set_Virtual_Button;

   procedure Set_Virtual_Hat
     (Self     : in Joystick;
      Hat      : in SDL.Events.Joysticks.Hats;
      Position : in SDL.Events.Joysticks.Hat_Positions)
   is
   begin
      Require_Valid (Self);

      if not Boolean
          (SDL_Set_Joystick_Virtual_Hat
             (Self.Internal,
              C.int (Hat),
              Position))
      then
         Raise_Last_Error ("SDL_SetJoystickVirtualHat failed");
      end if;
   end Set_Virtual_Hat;

   procedure Set_Virtual_Touchpad
     (Self      : in Joystick;
      Touchpad  : in C.int;
      Finger    : in C.int;
      Down      : in Boolean;
      X         : in C.C_float;
      Y         : in C.C_float;
      Pressure  : in C.C_float)
   is
   begin
      Require_Valid (Self);

      if not Boolean
          (SDL_Set_Joystick_Virtual_Touchpad
             (Self.Internal,
              Touchpad,
              Finger,
              To_C_Bool (Down),
              X,
              Y,
              Pressure))
      then
         Raise_Last_Error ("SDL_SetJoystickVirtualTouchpad failed");
      end if;
   end Set_Virtual_Touchpad;

   procedure Send_Virtual_Sensor_Data
     (Self             : in Joystick;
      Sensor_Type      : in SDL.Sensors.Types;
      Sensor_Timestamp : in Nanoseconds;
      Data             : in SDL.Sensors.Data_Values)
   is
   begin
      Require_Valid (Self);

      if not Boolean
          (SDL_Send_Joystick_Virtual_Sensor_Data
             (Self.Internal,
              Sensor_Type,
              Sensor_Timestamp,
              Float_Data_Address (Data),
              C.int (Data'Length)))
      then
         Raise_Last_Error ("SDL_SendJoystickVirtualSensorData failed");
      end if;
   end Send_Virtual_Sensor_Data;
end SDL.Inputs.Joysticks;
