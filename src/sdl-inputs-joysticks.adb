with Ada.Unchecked_Conversion;
with Interfaces.C.Strings;

with SDL.Error;
with SDL.Raw.Haptic;
with SDL.Raw.Joystick;
with SDL.Raw.Power;
with SDL.Raw.Sensor;

package body SDL.Inputs.Joysticks is
   package CS renames Interfaces.C.Strings;
   package Raw renames SDL.Raw.Joystick;

   use type C.ptrdiff_t;
   use type CS.chars_ptr;
   use type Raw.ID_Pointers.Pointer;
   use type SDL.C_Pointers.Joystick_Pointer;
   use type SDL.Events.Joysticks.IDs;
   use type System.Address;

   function To_Address is new Ada.Unchecked_Conversion
     (Source => Raw.ID_Pointers.Pointer,
      Target => System.Address);

   function To_Address is new Ada.Unchecked_Conversion
     (Source => SDL.C_Pointers.Joystick_Pointer,
      Target => System.Address);

   function To_Raw_ID (Value : in Instances) return Raw.ID is
     (Raw.ID (Value));

   function To_Public_ID (Value : in Raw.ID) return Instances is
     (Instances (Value));

   function To_Raw_Player_Index
     (Value : in Player_Indices) return Raw.Player_Index is
     (Raw.Player_Index (Value));

   function To_Public_Player_Index
     (Value : in Raw.Player_Index) return Player_Indices is
     (Player_Indices (Value));

   function To_Raw_GUID is new Ada.Unchecked_Conversion
     (Source => GUIDs,
      Target => Raw.GUID);

   function To_Public_GUID is new Ada.Unchecked_Conversion
     (Source => Raw.GUID,
      Target => GUIDs);

   function To_Raw_Type is new Ada.Unchecked_Conversion
     (Source => Types,
      Target => Raw.Types);

   function To_Public_Type is new Ada.Unchecked_Conversion
     (Source => Raw.Types,
      Target => Types);

   function To_Public_Connection_State is new Ada.Unchecked_Conversion
     (Source => Raw.Connection_States,
      Target => Connection_States);

   function To_Public_Power_State is new Ada.Unchecked_Conversion
     (Source => SDL.Raw.Power.State,
      Target => SDL.Power.State);

   function To_Raw_Sensor_Type is new Ada.Unchecked_Conversion
     (Source => SDL.Sensors.Types,
      Target => SDL.Raw.Sensor.Types);

   function To_Raw_Touchpad_Description_Access is new Ada.Unchecked_Conversion
     (Source => Virtual_Touchpad_Description_Access,
      Target => Raw.Virtual_Touchpad_Description_Access);

   function To_Raw_Sensor_Description_Access is new Ada.Unchecked_Conversion
     (Source => Virtual_Sensor_Description_Access,
      Target => Raw.Virtual_Sensor_Description_Access);

   function To_Raw_Update_Callback is new Ada.Unchecked_Conversion
     (Source => Update_Callback,
      Target => Raw.Update_Callback);

   function To_Raw_Set_Player_Index_Callback is new Ada.Unchecked_Conversion
     (Source => Set_Player_Index_Callback,
      Target => Raw.Set_Player_Index_Callback);

   function To_Raw_Rumble_Callback is new Ada.Unchecked_Conversion
     (Source => Rumble_Callback,
      Target => Raw.Rumble_Callback);

   function To_Raw_Rumble_Triggers_Callback is new Ada.Unchecked_Conversion
     (Source => Rumble_Triggers_Callback,
      Target => Raw.Rumble_Triggers_Callback);

   function To_Raw_Set_LED_Callback is new Ada.Unchecked_Conversion
     (Source => Set_LED_Callback,
      Target => Raw.Set_LED_Callback);

   function To_Raw_Send_Effect_Callback is new Ada.Unchecked_Conversion
     (Source => Send_Effect_Callback,
      Target => Raw.Send_Effect_Callback);

   function To_Raw_Set_Sensors_Enabled_Callback is new Ada.Unchecked_Conversion
     (Source => Set_Sensors_Enabled_Callback,
      Target => Raw.Set_Sensors_Enabled_Callback);

   function To_Raw_Cleanup_Callback is new Ada.Unchecked_Conversion
     (Source => Cleanup_Callback,
      Target => Raw.Cleanup_Callback);

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
     (CE.bool'Val (Boolean'Pos (Value)));

   procedure Require_Valid (Self : in Joystick);

   procedure Require_Valid (Self : in Joystick) is
   begin
      if Self.Internal = null then
         raise Joystick_Error with "Invalid joystick";
      end if;
   end Require_Valid;

   procedure Free (Value : in out Raw.ID_Pointers.Pointer);

   procedure Free (Value : in out Raw.ID_Pointers.Pointer) is
   begin
      if Value /= null then
         Raw.Free (To_Address (Value));
         Value := null;
      end if;
   end Free;

   function Copy_IDs
     (Items : in Raw.ID_Pointers.Pointer;
      Count : in C.int) return ID_Lists;

   function Copy_IDs
     (Items : in Raw.ID_Pointers.Pointer;
      Count : in C.int) return ID_Lists
   is
      Raw_Items : Raw.ID_Pointers.Pointer := Items;
   begin
      if Count <= 0 then
         Free (Raw_Items);
         return [];
      end if;

      if Raw_Items = null then
         Raise_Last_Error ("Joystick enumeration failed");
      end if;

      declare
         Source : constant Raw.ID_Array :=
           Raw.ID_Pointers.Value (Raw_Items, C.ptrdiff_t (Count));
         Result : ID_Lists (0 .. Natural (Count) - 1);
      begin
         for Index in Result'Range loop
            Result (Index) :=
              To_Public_ID
                (Source (Source'First + C.ptrdiff_t (Index - Result'First)));
         end loop;

         Free (Raw_Items);
         return Result;
      exception
         when others =>
            Free (Raw_Items);
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
      return Boolean (Raw.Has_Joystick);
   end Has_Joystick;

   function Get_Joysticks return ID_Lists is
      Count : aliased C.int := 0;
      Items : constant Raw.ID_Pointers.Pointer := Raw.Get_Joysticks (Count'Access);
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
      Result : constant CS.chars_ptr :=
        Raw.Get_Joystick_Name_For_ID (To_Raw_ID (Instance));
   begin
      if Result = CS.Null_Ptr then
         return "";
      end if;

      return CS.Value (Result);
   end Name;

   function Path (Instance : in Instances) return String is
      Result : constant CS.chars_ptr :=
        Raw.Get_Joystick_Path_For_ID (To_Raw_ID (Instance));
   begin
      if Result = CS.Null_Ptr then
         return "";
      end if;

      return CS.Value (Result);
   end Path;

   function Player_Index (Instance : in Instances) return Player_Indices is
   begin
      return To_Public_Player_Index
        (Raw.Get_Joystick_Player_Index_For_ID (To_Raw_ID (Instance)));
   end Player_Index;

   function GUID (Device : in Devices) return GUIDs is
     (GUID (Resolve_Device (Device)));

   function GUID (Instance : in Instances) return GUIDs is
   begin
      return To_Public_GUID
        (Raw.Get_Joystick_GUID_For_ID (To_Raw_ID (Instance)));
   end GUID;

   function Vendor (Instance : in Instances) return Vendor_IDs is
   begin
      return Vendor_IDs (Raw.Get_Joystick_Vendor_For_ID (To_Raw_ID (Instance)));
   end Vendor;

   function Product (Instance : in Instances) return Product_IDs is
   begin
      return Product_IDs (Raw.Get_Joystick_Product_For_ID (To_Raw_ID (Instance)));
   end Product;

   function Product_Version (Instance : in Instances) return Version_Numbers is
   begin
      return Version_Numbers
        (Raw.Get_Joystick_Product_Version_For_ID (To_Raw_ID (Instance)));
   end Product_Version;

   function Get_Type (Instance : in Instances) return Types is
   begin
      return To_Public_Type (Raw.Get_Joystick_Type_For_ID (To_Raw_ID (Instance)));
   end Get_Type;

   function Image (GUID : in GUIDs) return String is
      Buffer : C.char_array (0 .. 32) := (others => C.nul);
   begin
      Raw.GUID_To_String (To_Raw_GUID (GUID), Buffer, C.int (Buffer'Length));
      return C.To_Ada (Buffer);
   end Image;

   function Value (GUID : in String) return GUIDs is
     (To_Public_GUID (Raw.String_To_GUID (C.To_C (GUID))));

   function Attach_Virtual
     (Description : in Virtual_Description) return Instances
   is
      Name_Ptr : CS.chars_ptr := CS.Null_Ptr;
      Raw_Description : aliased Raw.Virtual_Description :=
        (Version             => Interfaces.Unsigned_32
           (Raw.Virtual_Description'Size / System.Storage_Unit),
         Kind                => Interfaces.Unsigned_16
           (Raw.Types'Pos (To_Raw_Type (Description.Kind))),
         Padding             => 0,
         Vendor              => Raw.Vendor_ID (Description.Vendor_ID),
         Product             => Raw.Product_ID (Description.Product_ID),
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
         Touchpads           => To_Raw_Touchpad_Description_Access
           (Description.Touchpads),
         Sensors             => To_Raw_Sensor_Description_Access
           (Description.Sensors),
         User_Data           => Description.User_Data,
         Update              => To_Raw_Update_Callback (Description.Update),
         Set_Player_Index    => To_Raw_Set_Player_Index_Callback
           (Description.Set_Player_Index),
         Rumble              => To_Raw_Rumble_Callback (Description.Rumble),
         Rumble_Triggers     => To_Raw_Rumble_Triggers_Callback
           (Description.Rumble_Triggers),
         Set_LED             => To_Raw_Set_LED_Callback (Description.Set_LED),
         Send_Effect         => To_Raw_Send_Effect_Callback
           (Description.Send_Effect),
         Set_Sensors_Enabled => To_Raw_Set_Sensors_Enabled_Callback
           (Description.Set_Sensors_Enabled),
         Cleanup             => To_Raw_Cleanup_Callback (Description.Cleanup));

      Result : Instances := 0;
   begin
      if US.Length (Description.Name) > 0 then
         Name_Ptr := CS.New_String (US.To_String (Description.Name));
         Raw_Description.Name := Name_Ptr;
      end if;

      Result := To_Public_ID
        (Raw.Attach_Virtual_Joystick (Raw_Description'Access));
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
      if not Boolean (Raw.Detach_Virtual_Joystick (To_Raw_ID (Instance))) then
         Raise_Last_Error ("SDL_DetachVirtualJoystick failed");
      end if;
   end Detach_Virtual;

   function Is_Virtual (Instance : in Instances) return Boolean is
   begin
      return Boolean (Raw.Is_Joystick_Virtual (To_Raw_ID (Instance)));
   end Is_Virtual;

   procedure Lock is
   begin
      Raw.Lock_Joysticks;
   end Lock;

   procedure Unlock is
   begin
      Raw.Unlock_Joysticks;
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

      Internal := Raw.Open_Joystick (To_Raw_ID (Instance));
      if Internal = null then
         Raise_Last_Error ("SDL_OpenJoystick failed");
      end if;

      Self.Internal := Internal;
      Self.Owns := True;
   end Open;

   function Get (Instance : in Instances) return Joystick is
   begin
      return (Ada.Finalization.Limited_Controlled with
              Internal => Raw.Get_Joystick_From_ID (To_Raw_ID (Instance)),
              Owns     => False);
   end Get;

   function Get_From_Player_Index
     (Player_Index : in Player_Indices) return Joystick
   is
   begin
      return (Ada.Finalization.Limited_Controlled with
              Internal => Raw.Get_Joystick_From_Player_Index
                (To_Raw_Player_Index (Player_Index)),
              Owns     => False);
   end Get_From_Player_Index;

   overriding
   procedure Finalize (Self : in out Joystick) is
   begin
      if Self.Owns and then Self.Internal /= null then
         Raw.Close_Joystick (Self.Internal);
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
      Result := Raw.Get_Num_Joystick_Axes (Self.Internal);

      if Result < 0 then
         Raise_Last_Error ("SDL_GetNumJoystickAxes failed");
      end if;

      return SDL.Events.Joysticks.Axes (Result);
   end Axes;

   function Balls (Self : in Joystick) return SDL.Events.Joysticks.Balls is
      Result : C.int;
   begin
      Require_Valid (Self);
      Result := Raw.Get_Num_Joystick_Balls (Self.Internal);

      if Result < 0 then
         Raise_Last_Error ("SDL_GetNumJoystickBalls failed");
      end if;

      return SDL.Events.Joysticks.Balls (Result);
   end Balls;

   function Buttons (Self : in Joystick) return SDL.Events.Joysticks.Buttons is
      Result : C.int;
   begin
      Require_Valid (Self);
      Result := Raw.Get_Num_Joystick_Buttons (Self.Internal);

      if Result < 0 then
         Raise_Last_Error ("SDL_GetNumJoystickButtons failed");
      end if;

      return SDL.Events.Joysticks.Buttons (Result);
   end Buttons;

   function Hats (Self : in Joystick) return SDL.Events.Joysticks.Hats is
      Result : C.int;
   begin
      Require_Valid (Self);
      Result := Raw.Get_Num_Joystick_Hats (Self.Internal);

      if Result < 0 then
         Raise_Last_Error ("SDL_GetNumJoystickHats failed");
      end if;

      return SDL.Events.Joysticks.Hats (Result);
   end Hats;

   function Name (Self : in Joystick) return String is
      Result : CS.chars_ptr;
   begin
      Require_Valid (Self);
      Result := Raw.Get_Joystick_Name (Self.Internal);

      if Result = CS.Null_Ptr then
         return "";
      end if;

      return CS.Value (Result);
   end Name;

   function Path (Self : in Joystick) return String is
      Result : CS.chars_ptr;
   begin
      Require_Valid (Self);
      Result := Raw.Get_Joystick_Path (Self.Internal);

      if Result = CS.Null_Ptr then
         return "";
      end if;

      return CS.Value (Result);
   end Path;

   function Player_Index (Self : in Joystick) return Player_Indices is
   begin
      Require_Valid (Self);
      return To_Public_Player_Index (Raw.Get_Joystick_Player_Index (Self.Internal));
   end Player_Index;

   procedure Set_Player_Index
     (Self         : in Joystick;
      Player_Index : in Player_Indices)
   is
   begin
      Require_Valid (Self);

      if not Boolean
          (Raw.Set_Joystick_Player_Index
             (Self.Internal, To_Raw_Player_Index (Player_Index)))
      then
         Raise_Last_Error ("SDL_SetJoystickPlayerIndex failed");
      end if;
   end Set_Player_Index;

   function Is_Haptic (Self : in Joystick) return Boolean is
   begin
      Require_Valid (Self);
      return Boolean (SDL.Raw.Haptic.Is_Joystick_Haptic (To_Address (Self.Internal)));
   end Is_Haptic;

   function Is_Attached (Self : in Joystick) return Boolean is
   begin
      Require_Valid (Self);
      return Boolean (Raw.Joystick_Connected (Self.Internal));
   end Is_Attached;

   function GUID (Self : in Joystick) return GUIDs is
   begin
      Require_Valid (Self);
      return To_Public_GUID (Raw.Get_Joystick_GUID (Self.Internal));
   end GUID;

   function Instance (Self : in Joystick) return Instances is
      Result : Instances;
   begin
      Require_Valid (Self);
      Result := To_Public_ID (Raw.Get_Joystick_ID (Self.Internal));

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
      return SDL.Properties.Reference
        (SDL.Properties.Property_ID (Raw.Get_Joystick_Properties (Self.Internal)));
   end Get_Properties;

   function Vendor (Self : in Joystick) return Vendor_IDs is
   begin
      Require_Valid (Self);
      return Vendor_IDs (Raw.Get_Joystick_Vendor (Self.Internal));
   end Vendor;

   function Product (Self : in Joystick) return Product_IDs is
   begin
      Require_Valid (Self);
      return Product_IDs (Raw.Get_Joystick_Product (Self.Internal));
   end Product;

   function Product_Version (Self : in Joystick) return Version_Numbers is
   begin
      Require_Valid (Self);
      return Version_Numbers (Raw.Get_Joystick_Product_Version (Self.Internal));
   end Product_Version;

   function Firmware_Version (Self : in Joystick) return Version_Numbers is
   begin
      Require_Valid (Self);
      return Version_Numbers (Raw.Get_Joystick_Firmware_Version (Self.Internal));
   end Firmware_Version;

   function Serial (Self : in Joystick) return String is
      Result : CS.chars_ptr;
   begin
      Require_Valid (Self);
      Result := Raw.Get_Joystick_Serial (Self.Internal);

      if Result = CS.Null_Ptr then
         return "";
      end if;

      return CS.Value (Result);
   end Serial;

   function Get_Type (Self : in Joystick) return Types is
   begin
      Require_Valid (Self);
      return To_Public_Type (Raw.Get_Joystick_Type (Self.Internal));
   end Get_Type;

   procedure GUID_Info
     (GUID      : in GUIDs;
      Vendor    : out Vendor_IDs;
      Product   : out Product_IDs;
      Version   : out Version_Numbers;
      CRC16     : out CRC16_Values)
   is
      Vendor_Value  : aliased Raw.Vendor_ID := 0;
      Product_Value : aliased Raw.Product_ID := 0;
      Version_Value : aliased Raw.Version_Number := 0;
      CRC16_Value   : aliased Raw.CRC16_Value := 0;
   begin
      Raw.Get_Joystick_GUID_Info
        (To_Raw_GUID (GUID),
         Vendor_Value'Access,
         Product_Value'Access,
         Version_Value'Access,
         CRC16_Value'Access);
      Vendor := Vendor_IDs (Vendor_Value);
      Product := Product_IDs (Product_Value);
      Version := Version_Numbers (Version_Value);
      CRC16 := CRC16_Values (CRC16_Value);
   end GUID_Info;

   function Connection_State (Self : in Joystick) return Connection_States is
   begin
      Require_Valid (Self);
      return To_Public_Connection_State
        (Raw.Get_Joystick_Connection_State (Self.Internal));
   end Connection_State;

   function Get_Power_Info
     (Self       : in Joystick;
      Percentage : out Battery_Percentages) return SDL.Power.State
   is
      Raw_Percentage : aliased C.int := -1;
   begin
      Require_Valid (Self);

      declare
         Result : constant SDL.Raw.Power.State :=
           Raw.Get_Joystick_Power_Info (Self.Internal, Raw_Percentage'Access);
      begin
         Percentage := Battery_Percentages (Raw_Percentage);
         return To_Public_Power_State (Result);
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
      return SDL.Events.Joysticks.Axes_Values
        (Raw.Get_Joystick_Axis (Self.Internal, C.int (Axis)));
   end Axis_Value;

   function Get_Axis_Initial_State
     (Self  : in Joystick;
     Axis  : in SDL.Events.Joysticks.Axes;
      Value : out SDL.Events.Joysticks.Axes_Values) return Boolean
   is
      Raw_Value : aliased Raw.Axis_Value := 0;
   begin
      Require_Valid (Self);

      if not Boolean
          (Raw.Get_Joystick_Axis_Initial_State
             (Self.Internal,
              C.int (Axis),
              Raw_Value'Access))
      then
         Value := 0;
         return False;
      end if;

      Value := SDL.Events.Joysticks.Axes_Values (Raw_Value);
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
          (Raw.Get_Joystick_Ball (Self.Internal, C.int (Ball), X'Access, Y'Access))
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
      return SDL.Events.Joysticks.Hat_Positions
        (Raw.Get_Joystick_Hat (Self.Internal, C.int (Hat)));
   end Hat_Value;

   function Is_Button_Pressed
     (Self   : in Joystick;
      Button : in SDL.Events.Joysticks.Buttons)
      return SDL.Events.Button_State
   is
   begin
      Require_Valid (Self);

      if Boolean (Raw.Get_Joystick_Button (Self.Internal, C.int (Button))) then
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
          (Raw.Rumble_Joystick
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
          (Raw.Rumble_Joystick_Triggers
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

      if not Boolean
          (Raw.Set_Joystick_LED
             (Self.Internal,
              Raw.LED_Component (Red),
              Raw.LED_Component (Green),
              Raw.LED_Component (Blue)))
      then
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
          (Raw.Send_Joystick_Effect
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
          (Raw.Set_Joystick_Virtual_Axis
             (Self.Internal,
              C.int (Axis),
              Raw.Axis_Value (Value)))
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
          (Raw.Set_Joystick_Virtual_Ball
             (Self.Internal,
              C.int (Ball),
              Raw.Ball_Delta (Delta_X),
              Raw.Ball_Delta (Delta_Y)))
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
          (Raw.Set_Joystick_Virtual_Button
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
          (Raw.Set_Joystick_Virtual_Hat
             (Self.Internal,
              C.int (Hat),
              Raw.Hat_Position (Position)))
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
          (Raw.Set_Joystick_Virtual_Touchpad
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
          (Raw.Send_Joystick_Virtual_Sensor_Data
             (Self.Internal,
              To_Raw_Sensor_Type (Sensor_Type),
              Sensor_Timestamp,
              Float_Data_Address (Data),
              C.int (Data'Length)))
      then
         Raise_Last_Error ("SDL_SendJoystickVirtualSensorData failed");
      end if;
   end Send_Virtual_Sensor_Data;
end SDL.Inputs.Joysticks;
