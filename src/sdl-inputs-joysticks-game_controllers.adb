with Ada.Unchecked_Conversion;
with Interfaces.C.Strings;
with System;

with SDL.Error;
with SDL.Raw.Gamepad;
with SDL.Raw.Joystick;
with SDL.Raw.Power;
with SDL.Raw.Sensor;

package body SDL.Inputs.Joysticks.Game_Controllers is
   package CS renames Interfaces.C.Strings;
   package Raw renames SDL.Raw.Gamepad;

   use type C.ptrdiff_t;
   use type Raw.Axes;
   use type Raw.Binding_Access;
   use type CS.chars_ptr;
   use type Raw.Binding_Types;
   use type Raw.Buttons;
   use type Raw.Binding_Pointers.Pointer;
   use type Raw.ID_Pointers.Pointer;
   use type Raw.String_Pointers.Pointer;
   use type SDL.C_Pointers.Game_Controller_Pointer;
   use type Instances;

   function To_Raw_ID (Value : in Instances) return Raw.ID is
     (Raw.ID (Value));

   function To_Public_ID (Value : in Raw.ID) return Instances is
     (Instances (Value));

   function To_Raw_GUID is new Ada.Unchecked_Conversion
     (Source => GUIDs,
      Target => Raw.GUID);

   function To_Public_GUID is new Ada.Unchecked_Conversion
     (Source => Raw.GUID,
      Target => GUIDs);

   function To_Raw_Player_Index
     (Value : in Player_Indices) return Raw.Player_Index is
     (Raw.Player_Index (Value));

   function To_Public_Player_Index
     (Value : in Raw.Player_Index) return Player_Indices is
     (Player_Indices (Value));

   function To_Raw_Type is new Ada.Unchecked_Conversion
     (Source => Types,
      Target => Raw.Types);

   function To_Public_Type is new Ada.Unchecked_Conversion
     (Source => Raw.Types,
      Target => Types);

   function To_Raw_Axis is new Ada.Unchecked_Conversion
     (Source => SDL.Events.Joysticks.Game_Controllers.Axes,
      Target => Raw.Axes);

   function To_Public_Axis is new Ada.Unchecked_Conversion
     (Source => Raw.Axes,
      Target => SDL.Events.Joysticks.Game_Controllers.Axes);

   function To_Raw_Button is new Ada.Unchecked_Conversion
     (Source => SDL.Events.Joysticks.Game_Controllers.Buttons,
      Target => Raw.Buttons);

   function To_Public_Button is new Ada.Unchecked_Conversion
     (Source => Raw.Buttons,
      Target => SDL.Events.Joysticks.Game_Controllers.Buttons);

   function To_Public_Button_Label is new Ada.Unchecked_Conversion
     (Source => Raw.Button_Labels,
      Target => Button_Labels);

   function To_Public_Connection_State is new Ada.Unchecked_Conversion
     (Source => Raw.Connection_States,
      Target => SDL.Inputs.Joysticks.Connection_States);

   function To_Public_Power_State is new Ada.Unchecked_Conversion
     (Source => SDL.Raw.Power.State,
      Target => SDL.Power.State);

   function To_Raw_Sensor_Type is new Ada.Unchecked_Conversion
     (Source => SDL.Sensors.Types,
      Target => SDL.Raw.Sensor.Types);

   function To_Address is new Ada.Unchecked_Conversion
     (Source => CS.chars_ptr,
      Target => System.Address);

   function To_Address is new Ada.Unchecked_Conversion
     (Source => Raw.Binding_Pointers.Pointer,
      Target => System.Address);

   function To_Address is new Ada.Unchecked_Conversion
     (Source => Raw.String_Pointers.Pointer,
      Target => System.Address);

   function To_Address is new Ada.Unchecked_Conversion
     (Source => Raw.ID_Pointers.Pointer,
      Target => System.Address);

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
     (CE.bool'Val (Boolean'Pos (Value)));

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
         Raw.Free (To_Address (Value));
         Value := CS.Null_Ptr;
      end if;
   end Free;

   procedure Free (Value : in out Raw.Binding_Pointers.Pointer);

   procedure Free (Value : in out Raw.Binding_Pointers.Pointer) is
   begin
      if Value /= null then
         Raw.Free (To_Address (Value));
         Value := null;
      end if;
   end Free;

   procedure Free (Value : in out Raw.String_Pointers.Pointer);

   procedure Free (Value : in out Raw.String_Pointers.Pointer) is
   begin
      if Value /= null then
         Raw.Free (To_Address (Value));
         Value := null;
      end if;
   end Free;

   procedure Free (Value : in out Raw.ID_Pointers.Pointer);

   procedure Free (Value : in out Raw.ID_Pointers.Pointer) is
   begin
      if Value /= null then
         Raw.Free (To_Address (Value));
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

   function To_Compatibility (Binding : in Raw.Binding) return Bindings is
   begin
      case Binding.Input_Type is
         when Raw.None =>
            return Null_Binding;

         when Raw.Button =>
            return
              (Which => Button,
               Value => (Which => Button,
                         Button => To_Button (Binding.Input.Button)));

         when Raw.Axis =>
            return
              (Which => Axis,
               Value => (Which => Axis,
                         Axis => To_Axis (Binding.Input.Axis.Axis)));

         when Raw.Hat =>
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
         Raise_Last_Error ("Gamepad enumeration failed");
      end if;

      declare
         Source : constant SDL.Raw.Joystick.ID_Array :=
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

   function Copy_Mappings
     (Items : in Raw.String_Pointers.Pointer;
      Count : in C.int) return Mapping_Lists;

   function Copy_Mappings
     (Items : in Raw.String_Pointers.Pointer;
      Count : in C.int) return Mapping_Lists
   is
      Raw_Items : Raw.String_Pointers.Pointer := Items;
   begin
      if Count <= 0 then
         Free (Raw_Items);
         return [];
      end if;

      if Raw_Items = null then
         Raise_Mapping_Error ("SDL_GetGamepadMappings failed");
      end if;

      declare
         Source : constant Raw.String_Pointer_Array :=
           Raw.String_Pointers.Value (Raw_Items, C.ptrdiff_t (Count));
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

         Free (Raw_Items);
         return Result;
      exception
         when others =>
            Free (Raw_Items);
            raise;
      end;
   end Copy_Mappings;

   function Copy_Bindings
     (Items : in Raw.Binding_Pointers.Pointer;
      Count : in C.int) return Binding_Lists;

   function Copy_Bindings
     (Items : in Raw.Binding_Pointers.Pointer;
      Count : in C.int) return Binding_Lists
   is
      Raw_Items : Raw.Binding_Pointers.Pointer := Items;
   begin
      if Count <= 0 then
         Free (Raw_Items);
         return [];
      end if;

      if Raw_Items = null then
         Raise_Mapping_Error ("SDL_GetGamepadBindings failed");
      end if;

      declare
         Source : constant Raw.Binding_Array :=
           Raw.Binding_Pointers.Value (Raw_Items, C.ptrdiff_t (Count));
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

         Free (Raw_Items);
         return Result;
      exception
         when others =>
            Free (Raw_Items);
            raise;
      end;
   end Copy_Bindings;

   procedure Add_Mapping
     (Data             : in String;
      Updated_Existing : out Boolean)
   is
      Result : constant C.int := Raw.Add_Gamepad_Mapping (C.To_C (Data));
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
      Result := Raw.Add_Gamepad_Mappings_From_IO (Stream, To_C_Bool (Close_After));

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
        Raw.Add_Gamepad_Mappings_From_File (C.To_C (Database_Filename));
   begin
      if Result < 0 then
         Raise_Mapping_Error ("SDL_AddGamepadMappingsFromFile failed");
      end if;

      Number_Added := Natural (Result);
   end Add_Mappings_From_File;

   procedure Reload_Mappings is
   begin
      if not Boolean (Raw.Reload_Gamepad_Mappings) then
         Raise_Mapping_Error ("SDL_ReloadGamepadMappings failed");
      end if;
   end Reload_Mappings;

   function Get_Mappings return Mapping_Lists is
      Count : aliased C.int := 0;
      Items : constant Raw.String_Pointers.Pointer :=
        Raw.Get_Gamepad_Mappings (Count'Access);
   begin
      return Copy_Mappings (Items, Count);
   end Get_Mappings;

   procedure Set_Mapping
     (Instance : in Instances;
      Mapping  : in String)
   is
   begin
      if not Boolean
          (Raw.Set_Gamepad_Mapping (To_Raw_ID (Instance), C.To_C (Mapping)))
      then
         Raise_Mapping_Error ("SDL_SetGamepadMapping failed");
      end if;
   end Set_Mapping;

   function Has_Gamepad return Boolean is
   begin
      return Boolean (Raw.Has_Gamepad);
   end Has_Gamepad;

   function Get_Gamepads return ID_Lists is
      Count : aliased C.int := 0;
      Items : constant Raw.ID_Pointers.Pointer := Raw.Get_Gamepads (Count'Access);
   begin
      return Copy_IDs (Items, Count);
   end Get_Gamepads;

   overriding
   procedure Finalize (Self : in out Game_Controller) is
   begin
      if Self.Owns and then Self.Internal /= null then
         Raw.Close_Gamepad (Self.Internal);
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
      return SDL.Events.Joysticks.Game_Controllers.LR_Axes_Values
        (Raw.Get_Gamepad_Axis (Self.Internal, To_Raw_Axis (Axis)));
   end Axis_Value;

   function Axis_Value
     (Self : in Game_Controller;
      Axis : in SDL.Events.Joysticks.Game_Controllers.Trigger_Axes)
      return SDL.Events.Joysticks.Game_Controllers.Trigger_Axes_Values
   is
   begin
      Require_Valid (Self);
      return SDL.Events.Joysticks.Game_Controllers.Trigger_Axes_Values
        (Raw.Get_Gamepad_Axis (Self.Internal, To_Raw_Axis (Axis)));
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

      Internal := Raw.Open_Gamepad (To_Raw_ID (Instance));
      if Internal = null then
         Raise_Last_Error ("SDL_OpenGamepad failed");
      end if;

      Self.Internal := Internal;
      Self.Owns := True;
   end Open;

   function Get (Instance : in Instances) return Game_Controller is
   begin
      return (Ada.Finalization.Limited_Controlled with
              Internal => Raw.Get_Gamepad_From_ID (To_Raw_ID (Instance)),
              Owns     => False);
   end Get;

   function Get_From_Player_Index
     (Player_Index : in Player_Indices) return Game_Controller
   is
   begin
      return (Ada.Finalization.Limited_Controlled with
              Internal => Raw.Get_Gamepad_From_Player_Index
                (To_Raw_Player_Index (Player_Index)),
              Owns     => False);
   end Get_From_Player_Index;

   function Get_Axis
     (Axis : in String) return SDL.Events.Joysticks.Game_Controllers.Axes
   is
   begin
      return To_Public_Axis (Raw.Get_Gamepad_Axis_From_String (C.To_C (Axis)));
   end Get_Axis;

   function Get_Bindings (Self : in Game_Controller) return Binding_Lists is
      Count     : aliased C.int := 0;
      Raw_Items : Raw.Binding_Pointers.Pointer;
   begin
      Require_Valid (Self);
      Raw_Items := Raw.Get_Gamepad_Bindings (Self.Internal, Count'Access);
      return Copy_Bindings (Raw_Items, Count);
   end Get_Bindings;

   function Get_Binding
     (Self : in Game_Controller;
      Axis : in SDL.Events.Joysticks.Game_Controllers.Axes) return Bindings
   is
      Count     : aliased C.int := 0;
      Raw_Items : Raw.Binding_Pointers.Pointer;
   begin
      Require_Valid (Self);
      Raw_Items := Raw.Get_Gamepad_Bindings (Self.Internal, Count'Access);

      if Raw_Items = null then
         if SDL.Error.Get /= "" then
            Raise_Mapping_Error ("SDL_GetGamepadBindings failed");
         end if;

         return Null_Binding;
      end if;

      declare
         Copy : constant Raw.Binding_Array :=
           Raw.Binding_Pointers.Value (Raw_Items, C.ptrdiff_t (Count));
      begin
         for Binding_Item of Copy loop
            if Binding_Item /= null
              and then Binding_Item.Output_Type = Raw.Axis
              and then Binding_Item.Output.Axis.Axis = To_Raw_Axis (Axis)
            then
               Free (Raw_Items);
               return To_Compatibility (Binding_Item.all);
            end if;
         end loop;
      end;

      Free (Raw_Items);
      return Null_Binding;
   end Get_Binding;

   function Get_Binding
     (Self   : in Game_Controller;
      Button : in SDL.Events.Joysticks.Game_Controllers.Buttons) return Bindings
   is
      Count     : aliased C.int := 0;
      Raw_Items : Raw.Binding_Pointers.Pointer;
   begin
      Require_Valid (Self);
      Raw_Items := Raw.Get_Gamepad_Bindings (Self.Internal, Count'Access);

      if Raw_Items = null then
         if SDL.Error.Get /= "" then
            Raise_Mapping_Error ("SDL_GetGamepadBindings failed");
         end if;

         return Null_Binding;
      end if;

      declare
         Copy : constant Raw.Binding_Array :=
           Raw.Binding_Pointers.Value (Raw_Items, C.ptrdiff_t (Count));
      begin
         for Binding_Item of Copy loop
            if Binding_Item /= null
              and then Binding_Item.Output_Type = Raw.Button
              and then Binding_Item.Output.Button = To_Raw_Button (Button)
            then
               Free (Raw_Items);
               return To_Compatibility (Binding_Item.all);
            end if;
         end loop;
      end;

      Free (Raw_Items);
      return Null_Binding;
   end Get_Binding;

   function Get_Button
     (Button_Name : in String) return SDL.Events.Joysticks.Game_Controllers.Buttons
   is
   begin
      return To_Public_Button
        (Raw.Get_Gamepad_Button_From_String (C.To_C (Button_Name)));
   end Get_Button;

   function Get_Joystick (Self : in Game_Controller) return Joystick is
   begin
      Require_Valid (Self);

      return Result : constant Joystick :=
        (Ada.Finalization.Limited_Controlled with
           Internal => Raw.Get_Gamepad_Joystick (Self.Internal),
           Owns     => False)
      do
         null;
      end return;
   end Get_Joystick;

   function Get_Mapping (Self : in Game_Controller) return String is
      Result : CS.chars_ptr;
   begin
      Require_Valid (Self);
      Result := Raw.Get_Gamepad_Mapping (Self.Internal);

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
      Result : CS.chars_ptr := Raw.Get_Gamepad_Mapping_For_GUID (To_Raw_GUID (Controller));
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
      Result : CS.chars_ptr := Raw.Get_Gamepad_Mapping_For_ID (To_Raw_ID (Instance));
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
      Result := Raw.Get_Gamepad_Name (Self.Internal);

      if Result = CS.Null_Ptr then
         return "";
      end if;

      return CS.Value (Result);
   end Get_Name;

   function Get_Name (Device : in Devices) return String is
     (Get_Name (Resolve_Device (Device)));

   function Get_Name (Instance : in Instances) return String is
      Result : constant CS.chars_ptr :=
        Raw.Get_Gamepad_Name_For_ID (To_Raw_ID (Instance));
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
      Result := Raw.Get_Gamepad_Path (Self.Internal);

      if Result = CS.Null_Ptr then
         return "";
      end if;

      return CS.Value (Result);
   end Get_Path;

   function Get_Path (Instance : in Instances) return String is
      Result : constant CS.chars_ptr :=
        Raw.Get_Gamepad_Path_For_ID (To_Raw_ID (Instance));
   begin
      if Result = CS.Null_Ptr then
         return "";
      end if;

      return CS.Value (Result);
   end Get_Path;

   function Player_Index (Self : in Game_Controller) return Player_Indices is
   begin
      Require_Valid (Self);
      return To_Public_Player_Index (Raw.Get_Gamepad_Player_Index (Self.Internal));
   end Player_Index;

   function Player_Index (Instance : in Instances) return Player_Indices is
   begin
      return To_Public_Player_Index
        (Raw.Get_Gamepad_Player_Index_For_ID (To_Raw_ID (Instance)));
   end Player_Index;

   procedure Set_Player_Index
     (Self         : in Game_Controller;
      Player_Index : in Player_Indices)
   is
   begin
      Require_Valid (Self);

      if not Boolean
          (Raw.Set_Gamepad_Player_Index
             (Self.Internal, To_Raw_Player_Index (Player_Index)))
      then
         Raise_Last_Error ("SDL_SetGamepadPlayerIndex failed");
      end if;
   end Set_Player_Index;

   function GUID (Instance : in Instances) return GUIDs is
   begin
      return To_Public_GUID (Raw.Get_Gamepad_GUID_For_ID (To_Raw_ID (Instance)));
   end GUID;

   function Get_Type (Self : in Game_Controller) return Types is
   begin
      Require_Valid (Self);
      return To_Public_Type (Raw.Get_Gamepad_Type (Self.Internal));
   end Get_Type;

   function Get_Type (Instance : in Instances) return Types is
   begin
      return To_Public_Type (Raw.Get_Gamepad_Type_For_ID (To_Raw_ID (Instance)));
   end Get_Type;

   function Get_Real_Type (Self : in Game_Controller) return Types is
   begin
      Require_Valid (Self);
      return To_Public_Type (Raw.Get_Real_Gamepad_Type (Self.Internal));
   end Get_Real_Type;

   function Get_Real_Type (Instance : in Instances) return Types is
   begin
      return To_Public_Type
        (Raw.Get_Real_Gamepad_Type_For_ID (To_Raw_ID (Instance)));
   end Get_Real_Type;

   function Vendor (Self : in Game_Controller) return Vendor_IDs is
   begin
      Require_Valid (Self);
      return Vendor_IDs (Raw.Get_Gamepad_Vendor (Self.Internal));
   end Vendor;

   function Vendor (Instance : in Instances) return Vendor_IDs is
   begin
      return Vendor_IDs (Raw.Get_Gamepad_Vendor_For_ID (To_Raw_ID (Instance)));
   end Vendor;

   function Product (Self : in Game_Controller) return Product_IDs is
   begin
      Require_Valid (Self);
      return Product_IDs (Raw.Get_Gamepad_Product (Self.Internal));
   end Product;

   function Product (Instance : in Instances) return Product_IDs is
   begin
      return Product_IDs (Raw.Get_Gamepad_Product_For_ID (To_Raw_ID (Instance)));
   end Product;

   function Product_Version (Self : in Game_Controller) return Version_Numbers is
   begin
      Require_Valid (Self);
      return Version_Numbers (Raw.Get_Gamepad_Product_Version (Self.Internal));
   end Product_Version;

   function Product_Version (Instance : in Instances) return Version_Numbers is
   begin
      return Version_Numbers
        (Raw.Get_Gamepad_Product_Version_For_ID (To_Raw_ID (Instance)));
   end Product_Version;

   function Firmware_Version (Self : in Game_Controller) return Version_Numbers is
   begin
      Require_Valid (Self);
      return Version_Numbers (Raw.Get_Gamepad_Firmware_Version (Self.Internal));
   end Firmware_Version;

   function Serial (Self : in Game_Controller) return String is
      Result : CS.chars_ptr;
   begin
      Require_Valid (Self);
      Result := Raw.Get_Gamepad_Serial (Self.Internal);

      if Result = CS.Null_Ptr then
         return "";
      end if;

      return CS.Value (Result);
   end Serial;

   function Steam_Handle (Self : in Game_Controller) return Steam_Handles is
   begin
      Require_Valid (Self);
      return Steam_Handles (Raw.Get_Gamepad_Steam_Handle (Self.Internal));
   end Steam_Handle;

   function Connection_State
     (Self : in Game_Controller) return SDL.Inputs.Joysticks.Connection_States
   is
   begin
      Require_Valid (Self);
      return To_Public_Connection_State
        (Raw.Get_Gamepad_Connection_State (Self.Internal));
   end Connection_State;

   function Get_Power_Info
     (Self       : in Game_Controller;
      Percentage : out Battery_Percentages) return SDL.Power.State
   is
      Raw_Percentage : aliased C.int := -1;
   begin
      Require_Valid (Self);

      declare
         Result : constant SDL.Raw.Power.State :=
           Raw.Get_Gamepad_Power_Info (Self.Internal, Raw_Percentage'Access);
      begin
         Percentage := Battery_Percentages (Raw_Percentage);
         return To_Public_Power_State (Result);
      end;
   end Get_Power_Info;

   function Get_Properties
     (Self : in Game_Controller) return SDL.Properties.Property_Set
   is
   begin
      Require_Valid (Self);
      return SDL.Properties.Reference
        (SDL.Properties.Property_ID (Raw.Get_Gamepad_Properties (Self.Internal)));
   end Get_Properties;

   function Get_ID (Self : in Game_Controller) return Instances is
      Result : Instances;
   begin
      Require_Valid (Self);
      Result := To_Public_ID (Raw.Get_Gamepad_ID (Self.Internal));

      if Result = 0 then
         Raise_Last_Error ("SDL_GetGamepadID failed");
      end if;

      return Result;
   end Get_ID;

   function Image
     (Axis : in SDL.Events.Joysticks.Game_Controllers.Axes) return String
   is
      Result : constant CS.chars_ptr :=
        Raw.Get_Gamepad_String_For_Axis (To_Raw_Axis (Axis));
   begin
      if Result = CS.Null_Ptr then
         return "";
      end if;

      return CS.Value (Result);
   end Image;

   function Image
     (Button : in SDL.Events.Joysticks.Game_Controllers.Buttons) return String
   is
      Result : constant CS.chars_ptr :=
        Raw.Get_Gamepad_String_For_Button (To_Raw_Button (Button));
   begin
      if Result = CS.Null_Ptr then
         return "";
      end if;

      return CS.Value (Result);
   end Image;

   function Image (Kind : in Types) return String is
      Result : constant CS.chars_ptr :=
        Raw.Get_Gamepad_String_For_Type (To_Raw_Type (Kind));
   begin
      if Result = CS.Null_Ptr then
         return "";
      end if;

      return CS.Value (Result);
   end Image;

   function Type_From_String (Value : in String) return Types is
   begin
      return To_Public_Type (Raw.Get_Gamepad_Type_From_String (C.To_C (Value)));
   end Type_From_String;

   function Is_Attached (Self : in Game_Controller) return Boolean is
   begin
      Require_Valid (Self);
      return Boolean (Raw.Gamepad_Connected (Self.Internal));
   end Is_Attached;

   function Has_Axis
     (Self : in Game_Controller;
      Axis : in SDL.Events.Joysticks.Game_Controllers.Axes) return Boolean
   is
   begin
      Require_Valid (Self);
      return Boolean (Raw.Gamepad_Has_Axis (Self.Internal, To_Raw_Axis (Axis)));
   end Has_Axis;

   function Is_Button_Pressed
     (Self   : in Game_Controller;
      Button : in SDL.Events.Joysticks.Game_Controllers.Buttons)
      return SDL.Events.Button_State
   is
   begin
      Require_Valid (Self);

      if Boolean (Raw.Get_Gamepad_Button (Self.Internal, To_Raw_Button (Button))) then
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
      return Boolean (Raw.Gamepad_Has_Button (Self.Internal, To_Raw_Button (Button)));
   end Has_Button;

   function Is_Game_Controller (Device : in Devices) return Boolean is
   begin
      return Boolean (Raw.Is_Gamepad (To_Raw_ID (Resolve_Device (Device))));
   end Is_Game_Controller;

   function Button_Label_For_Type
     (Kind   : in Types;
      Button : in SDL.Events.Joysticks.Game_Controllers.Buttons)
      return Button_Labels
   is
   begin
      return To_Public_Button_Label
        (Raw.Get_Gamepad_Button_Label_For_Type
           (To_Raw_Type (Kind), To_Raw_Button (Button)));
   end Button_Label_For_Type;

   function Button_Label
     (Self   : in Game_Controller;
      Button : in SDL.Events.Joysticks.Game_Controllers.Buttons)
      return Button_Labels
   is
   begin
      Require_Valid (Self);
      return To_Public_Button_Label
        (Raw.Get_Gamepad_Button_Label (Self.Internal, To_Raw_Button (Button)));
   end Button_Label;

   function Touchpads (Self : in Game_Controller) return Natural is
      Result : C.int;
   begin
      Require_Valid (Self);
      Result := Raw.Get_Num_Gamepad_Touchpads (Self.Internal);

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
      Result := Raw.Get_Num_Gamepad_Touchpad_Fingers (Self.Internal, Touchpad);

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
          (Raw.Get_Gamepad_Touchpad_Finger
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
      return Boolean
        (Raw.Gamepad_Has_Sensor (Self.Internal, To_Raw_Sensor_Type (Sensor_Type)));
   end Has_Sensor;

   procedure Set_Sensor_Enabled
     (Self        : in Game_Controller;
      Sensor_Type : in SDL.Sensors.Types;
      Enabled     : in Boolean)
   is
   begin
      Require_Valid (Self);

      if not Boolean
          (Raw.Set_Gamepad_Sensor_Enabled
             (Self.Internal,
              To_Raw_Sensor_Type (Sensor_Type),
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
      return Boolean
        (Raw.Gamepad_Sensor_Enabled
           (Self.Internal, To_Raw_Sensor_Type (Sensor_Type)));
   end Sensor_Enabled;

   function Sensor_Data_Rate
     (Self        : in Game_Controller;
      Sensor_Type : in SDL.Sensors.Types) return C.C_float
   is
   begin
      Require_Valid (Self);
      return Raw.Get_Gamepad_Sensor_Data_Rate
        (Self.Internal, To_Raw_Sensor_Type (Sensor_Type));
   end Sensor_Data_Rate;

   procedure Get_Sensor_Data
     (Self        : in Game_Controller;
      Sensor_Type : in SDL.Sensors.Types;
      Data        : out SDL.Sensors.Data_Values)
   is
   begin
      Require_Valid (Self);

      if not Boolean
          (Raw.Get_Gamepad_Sensor_Data
             (Self.Internal,
              To_Raw_Sensor_Type (Sensor_Type),
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
        SDL.Properties.Reference
          (SDL.Properties.Property_ID (Raw.Get_Gamepad_Properties (Self.Internal)));
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
          (Raw.Rumble_Gamepad
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
          (Raw.Rumble_Gamepad_Triggers
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

      if not Boolean
          (Raw.Set_Gamepad_LED
             (Self.Internal,
              Raw.LED_Component (Red),
              Raw.LED_Component (Green),
              Raw.LED_Component (Blue)))
      then
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
          (Raw.Send_Gamepad_Effect
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
      Result := Raw.Get_Gamepad_Apple_SF_Symbols_Name_For_Button
        (Self.Internal, To_Raw_Button (Button));

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
      Result := Raw.Get_Gamepad_Apple_SF_Symbols_Name_For_Axis
        (Self.Internal, To_Raw_Axis (Axis));

      if Result = CS.Null_Ptr then
         return "";
      end if;

      return CS.Value (Result);
   end Apple_SF_Symbol_Name;
end SDL.Inputs.Joysticks.Game_Controllers;
