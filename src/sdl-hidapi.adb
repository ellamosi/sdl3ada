with Ada.Strings.UTF_Encoding;
with Ada.Strings.UTF_Encoding.Wide_Strings;
with Interfaces.C.Extensions;
with Interfaces.C.Pointers;
with Interfaces.C.Strings;
with System;

with SDL.Error;

package body SDL.HIDAPI is
   package CE renames Interfaces.C.Extensions;
   package CS renames Interfaces.C.Strings;
   package UTF_Strings renames Ada.Strings.UTF_Encoding;
   package UTF_Wide_Strings renames Ada.Strings.UTF_Encoding.Wide_Strings;

   use type C.size_t;
   use type CS.chars_ptr;
   use type SDL.C_Pointers.HID_Device_Pointer;
   use type SDL.Properties.Property_ID;
   use type System.Address;

   package Wide_Char_Pointers is new Interfaces.C.Pointers
     (Index              => C.size_t,
      Element            => C.wchar_t,
      Element_Array      => C.wchar_array,
      Default_Terminator => C.wide_nul);

   use type Wide_Char_Pointers.Pointer;

   type Raw_Device_Info;
   type Raw_Device_Info_Access is access all Raw_Device_Info with
     Convention => C;

   type Raw_Device_Info is record
      Path                : CS.chars_ptr;
      Vendor_ID           : C.unsigned_short;
      Product_ID          : C.unsigned_short;
      Serial_Number       : Wide_Char_Pointers.Pointer;
      Release_Number      : C.unsigned_short;
      Manufacturer_String : Wide_Char_Pointers.Pointer;
      Product_String      : Wide_Char_Pointers.Pointer;
      Usage_Page          : C.unsigned_short;
      Usage               : C.unsigned_short;
      Interface_Number    : C.int;
      Interface_Class     : C.int;
      Interface_Subclass  : C.int;
      Interface_Protocol  : C.int;
      Bus_Type            : Bus_Types;
      Next                : Raw_Device_Info_Access;
   end record with
     Convention => C;

   function SDL_HID_Init return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_hid_init";

   function SDL_HID_Exit return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_hid_exit";

   function SDL_HID_Device_Change_Count return Device_Change_Counts
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_hid_device_change_count";

   function SDL_HID_Enumerate
     (Vendor_ID  : in C.unsigned_short;
      Product_ID : in C.unsigned_short) return Raw_Device_Info_Access
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_hid_enumerate";

   procedure SDL_HID_Free_Enumeration (Devices : in Raw_Device_Info_Access)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_hid_free_enumeration";

   function SDL_HID_Open
     (Vendor_ID     : in C.unsigned_short;
      Product_ID    : in C.unsigned_short;
      Serial_Number : in Wide_Char_Pointers.Pointer)
      return SDL.C_Pointers.HID_Device_Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_hid_open";

   function SDL_HID_Open_Path
     (Path : in CS.chars_ptr) return SDL.C_Pointers.HID_Device_Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_hid_open_path";

   function SDL_HID_Get_Properties
     (Self : in SDL.C_Pointers.HID_Device_Pointer) return SDL.Properties.Property_ID
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_hid_get_properties";

   function SDL_HID_Write
     (Self   : in SDL.C_Pointers.HID_Device_Pointer;
      Data   : in System.Address;
      Length : in C.size_t) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_hid_write";

   function SDL_HID_Read_Timeout
     (Self         : in SDL.C_Pointers.HID_Device_Pointer;
      Data         : in System.Address;
      Length       : in C.size_t;
      Milliseconds : in Timeout_Milliseconds) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_hid_read_timeout";

   function SDL_HID_Read
     (Self   : in SDL.C_Pointers.HID_Device_Pointer;
      Data   : in System.Address;
      Length : in C.size_t) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_hid_read";

   function SDL_HID_Set_Nonblocking
     (Self        : in SDL.C_Pointers.HID_Device_Pointer;
      Nonblocking : in C.int) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_hid_set_nonblocking";

   function SDL_HID_Send_Feature_Report
     (Self   : in SDL.C_Pointers.HID_Device_Pointer;
      Data   : in System.Address;
      Length : in C.size_t) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_hid_send_feature_report";

   function SDL_HID_Get_Feature_Report
     (Self   : in SDL.C_Pointers.HID_Device_Pointer;
      Data   : in System.Address;
      Length : in C.size_t) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_hid_get_feature_report";

   function SDL_HID_Get_Input_Report
     (Self   : in SDL.C_Pointers.HID_Device_Pointer;
      Data   : in System.Address;
      Length : in C.size_t) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_hid_get_input_report";

   function SDL_HID_Close
     (Self : in SDL.C_Pointers.HID_Device_Pointer) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_hid_close";

   function SDL_HID_Get_Manufacturer_String
     (Self   : in SDL.C_Pointers.HID_Device_Pointer;
      Value  : in Wide_Char_Pointers.Pointer;
      Maxlen : in C.size_t) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_hid_get_manufacturer_string";

   function SDL_HID_Get_Product_String
     (Self   : in SDL.C_Pointers.HID_Device_Pointer;
      Value  : in Wide_Char_Pointers.Pointer;
      Maxlen : in C.size_t) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_hid_get_product_string";

   function SDL_HID_Get_Serial_Number_String
     (Self   : in SDL.C_Pointers.HID_Device_Pointer;
      Value  : in Wide_Char_Pointers.Pointer;
      Maxlen : in C.size_t) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_hid_get_serial_number_string";

   function SDL_HID_Get_Indexed_String
     (Self         : in SDL.C_Pointers.HID_Device_Pointer;
      String_Index : in String_Indices;
      Value        : in Wide_Char_Pointers.Pointer;
      Maxlen       : in C.size_t) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_hid_get_indexed_string";

   function SDL_HID_Get_Device_Info
     (Self : in SDL.C_Pointers.HID_Device_Pointer) return Raw_Device_Info_Access
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_hid_get_device_info";

   function SDL_HID_Get_Report_Descriptor
     (Self     : in SDL.C_Pointers.HID_Device_Pointer;
      Buffer   : in System.Address;
      Buf_Size : in C.size_t) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_hid_get_report_descriptor";

   procedure SDL_HID_BLE_Scan (Active : in CE.bool)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_hid_ble_scan";

   function To_C_Bool (Value : in Boolean) return CE.bool is
     (CE.bool'Val (Boolean'Pos (Value)));

   procedure Raise_Last_Error
     (Default_Message : in String := "SDL HIDAPI call failed");

   procedure Raise_Last_Error
     (Default_Message : in String := "SDL HIDAPI call failed")
   is
      Message : constant String := SDL.Error.Get;
   begin
      if Message = "" then
         raise HIDAPI_Error with Default_Message;
      end if;

      raise HIDAPI_Error with Message;
   end Raise_Last_Error;

   procedure Require_Valid (Self : in Device);

   procedure Require_Valid (Self : in Device) is
   begin
      if Self.Internal = null then
         raise HIDAPI_Error with "Invalid HID device";
      end if;
   end Require_Valid;

   function To_UTF_8 (Value : in Wide_Char_Pointers.Pointer) return String is
   begin
      if Value = null then
         return "";
      end if;

      declare
         Wide_Value : constant Wide_String :=
           C.To_Ada (Wide_Char_Pointers.Value (Value));
         UTF_Value  : constant UTF_Strings.UTF_8_String :=
           UTF_Wide_Strings.Encode (Wide_Value);
      begin
         return String (UTF_Value);
      end;
   exception
      when UTF_Strings.Encoding_Error =>
         raise HIDAPI_Error with "Wide HID string contained invalid UTF data";
   end To_UTF_8;

   function Buffer_To_UTF_8 (Buffer : in C.wchar_array) return String is
      Wide_Value : constant Wide_String := C.To_Ada (Buffer);
      UTF_Value  : constant UTF_Strings.UTF_8_String :=
        UTF_Wide_Strings.Encode (Wide_Value);
   begin
      return String (UTF_Value);
   exception
      when UTF_Strings.Encoding_Error =>
         raise HIDAPI_Error with "HID string contained invalid UTF data";
   end Buffer_To_UTF_8;

   function Is_Empty_Enumeration_Message (Message : in String) return Boolean is
     (Message = "No HID devices found in the system."
      or else Message = "No HID devices with requested VID/PID found in the system.");

   function Copy_Info (Value : in Raw_Device_Info) return Device_Info is
      Result : Device_Info;
   begin
      if Value.Path /= CS.Null_Ptr then
         Result.Path := US.To_Unbounded_String (CS.Value (Value.Path));
      end if;

      Result.Vendor_ID := Vendor_IDs (Value.Vendor_ID);
      Result.Product_ID := Product_IDs (Value.Product_ID);
      Result.Serial_Number := US.To_Unbounded_String (To_UTF_8 (Value.Serial_Number));
      Result.Release_Number := Release_Numbers (Value.Release_Number);
      Result.Manufacturer :=
        US.To_Unbounded_String (To_UTF_8 (Value.Manufacturer_String));
      Result.Product := US.To_Unbounded_String (To_UTF_8 (Value.Product_String));
      Result.Usage_Page := Usage_Pages (Value.Usage_Page);
      Result.Usage := Usage_Values (Value.Usage);
      Result.Interface_Number := Value.Interface_Number;
      Result.Interface_Class := Value.Interface_Class;
      Result.Interface_Subclass := Value.Interface_Subclass;
      Result.Interface_Protocol := Value.Interface_Protocol;
      Result.Bus_Type := Value.Bus_Type;
      return Result;
   end Copy_Info;

   procedure Free_Enumeration (Devices : in out Raw_Device_Info_Access);

   procedure Free_Enumeration (Devices : in out Raw_Device_Info_Access) is
   begin
      if Devices /= null then
         SDL_HID_Free_Enumeration (Devices);
         Devices := null;
      end if;
   end Free_Enumeration;

   function Buffer_Address (Data : in Byte_Lists) return System.Address is
     (if Data'Length = 0
      then System.Null_Address
      else Data (Data'First)'Address);

   function Checked_Transfer
     (Result          : in C.int;
      Default_Message : in String) return Natural
   is
   begin
      if Result < 0 then
         Raise_Last_Error (Default_Message);
      end if;

      return Natural (Result);
   end Checked_Transfer;

   function Slice_Bytes
     (Data  : in Byte_Lists;
      Count : in Natural) return Byte_Lists
   is
   begin
      if Count = 0 then
         return [];
      end if;

      return Data (Data'First .. Data'First + Count - 1);
   end Slice_Bytes;

   procedure Initialise is
   begin
      if SDL_HID_Init < 0 then
         Raise_Last_Error ("SDL_hid_init failed");
      end if;
   end Initialise;

   procedure Shutdown is
   begin
      if SDL_HID_Exit < 0 then
         Raise_Last_Error ("SDL_hid_exit failed");
      end if;
   end Shutdown;

   function Get_Device_Change_Count return Device_Change_Counts is
   begin
      return SDL_HID_Device_Change_Count;
   end Get_Device_Change_Count;

   function Enumerate return Device_Info_Lists is
     (Enumerate (Vendor_ID => 0, Product_ID => 0));

   function Enumerate
     (Vendor_ID  : in Vendor_IDs;
      Product_ID : in Product_IDs) return Device_Info_Lists
   is
      Devices : Raw_Device_Info_Access := null;
      Current : Raw_Device_Info_Access := null;
      Count   : Natural := 0;
   begin
      SDL.Error.Clear;

      Devices :=
        SDL_HID_Enumerate
          (Vendor_ID  => C.unsigned_short (Vendor_ID),
           Product_ID => C.unsigned_short (Product_ID));

      if Devices = null then
         declare
            Message : constant String := SDL.Error.Get;
         begin
            if Message = "" or else Is_Empty_Enumeration_Message (Message) then
               SDL.Error.Clear;
               return [];
            end if;

            Raise_Last_Error ("SDL_hid_enumerate failed");
         end;
      end if;

      Current := Devices;
      while Current /= null loop
         Count := Count + 1;
         Current := Current.Next;
      end loop;

      declare
         Result : Device_Info_Lists (0 .. Count - 1);
         Index  : Natural := Result'First;
      begin
         Current := Devices;
         while Current /= null loop
            Result (Index) := Copy_Info (Current.all);
            Current := Current.Next;
            Index := Index + 1;
         end loop;

         Free_Enumeration (Devices);
         return Result;
      exception
         when others =>
            Free_Enumeration (Devices);
            raise;
      end;
   end Enumerate;

   function Open
     (Vendor_ID     : in Vendor_IDs;
      Product_ID    : in Product_IDs;
      Serial_Number : in String := "") return Device
   is
   begin
      return Result : Device do
         Open (Result, Vendor_ID, Product_ID, Serial_Number);
      end return;
   end Open;

   procedure Open
     (Self          : in out Device;
      Vendor_ID     : in Vendor_IDs;
      Product_ID    : in Product_IDs;
      Serial_Number : in String := "")
   is
      Internal : SDL.C_Pointers.HID_Device_Pointer := null;
   begin
      Close (Self);

      if Serial_Number = "" then
         Internal :=
           SDL_HID_Open
             (Vendor_ID     => C.unsigned_short (Vendor_ID),
              Product_ID    => C.unsigned_short (Product_ID),
              Serial_Number => null);
      else
         declare
            Wide_Serial : constant Wide_String :=
              UTF_Wide_Strings.Decode (Serial_Number);
            C_Serial    : aliased C.wchar_array := C.To_C (Wide_Serial);
         begin
            Internal :=
              SDL_HID_Open
                (Vendor_ID     => C.unsigned_short (Vendor_ID),
                 Product_ID    => C.unsigned_short (Product_ID),
                 Serial_Number =>
                   Wide_Char_Pointers.Pointer'
                     (C_Serial (C_Serial'First)'Unchecked_Access));
         end;
      end if;

      if Internal = null then
         Raise_Last_Error ("SDL_hid_open failed");
      end if;

      Self.Internal := Internal;
      Self.Owns := True;
   exception
      when UTF_Strings.Encoding_Error =>
         raise HIDAPI_Error with "Serial number must be valid UTF-8";
   end Open;

   function Open_Path (Path : in String) return Device is
   begin
      return Result : Device do
         Open_Path (Result, Path);
      end return;
   end Open_Path;

   procedure Open_Path
     (Self : in out Device;
      Path : in String)
   is
      C_Path   : CS.chars_ptr := CS.New_String (Path);
      Internal : SDL.C_Pointers.HID_Device_Pointer := null;
   begin
      Close (Self);

      begin
         Internal := SDL_HID_Open_Path (C_Path);
      exception
         when others =>
            CS.Free (C_Path);
            raise;
      end;

      CS.Free (C_Path);

      if Internal = null then
         Raise_Last_Error ("SDL_hid_open_path failed");
      end if;

      Self.Internal := Internal;
      Self.Owns := True;
   end Open_Path;

   overriding
   procedure Finalize (Self : in out Device) is
   begin
      Close (Self);
   end Finalize;

   procedure Close (Self : in out Device) is
      Ignored : C.int;
      pragma Unreferenced (Ignored);
   begin
      if Self.Owns and then Self.Internal /= null then
         Ignored := SDL_HID_Close (Self.Internal);
      end if;

      Self.Internal := null;
      Self.Owns := True;
   end Close;

   function Is_Null (Self : in Device) return Boolean is
     (Self.Internal = null);

   function Get_Properties
     (Self : in Device) return SDL.Properties.Property_Set
   is
      Props : SDL.Properties.Property_ID;
   begin
      Require_Valid (Self);

      Props := SDL_HID_Get_Properties (Self.Internal);
      if Props = SDL.Properties.Null_Property_ID then
         Raise_Last_Error ("SDL_hid_get_properties failed");
      end if;

      return SDL.Properties.Reference (Props);
   end Get_Properties;

   function Get_Info (Self : in Device) return Device_Info is
      Info : Raw_Device_Info_Access := null;
   begin
      Require_Valid (Self);

      Info := SDL_HID_Get_Device_Info (Self.Internal);
      if Info = null then
         Raise_Last_Error ("SDL_hid_get_device_info failed");
      end if;

      return Copy_Info (Info.all);
   end Get_Info;

   procedure Set_Nonblocking
     (Self    : in Device;
      Enabled : in Boolean)
   is
   begin
      Require_Valid (Self);

      if SDL_HID_Set_Nonblocking
          (Self.Internal, (if Enabled then 1 else 0)) < 0
      then
         Raise_Last_Error ("SDL_hid_set_nonblocking failed");
      end if;
   end Set_Nonblocking;

   function Write
     (Self : in Device;
      Data : in Byte_Lists) return Natural
   is
   begin
      Require_Valid (Self);
      return Checked_Transfer
        (SDL_HID_Write
           (Self.Internal,
            Buffer_Address (Data),
            C.size_t (Data'Length)),
         "SDL_hid_write failed");
   end Write;

   function Read
     (Self     : in Device;
      Capacity : in Positive) return Byte_Lists
   is
      Buffer : Byte_Lists (0 .. Capacity - 1) := [others => 0];
      Count  : Natural;
   begin
      Require_Valid (Self);
      Count :=
        Checked_Transfer
          (SDL_HID_Read
             (Self.Internal,
              Buffer_Address (Buffer),
              C.size_t (Buffer'Length)),
           "SDL_hid_read failed");
      return Slice_Bytes (Buffer, Count);
   end Read;

   function Read
     (Self       : in Device;
      Capacity   : in Positive;
      Timeout_MS : in Timeout_Milliseconds) return Byte_Lists
   is
      Buffer : Byte_Lists (0 .. Capacity - 1) := [others => 0];
      Count  : Natural;
   begin
      Require_Valid (Self);
      Count :=
        Checked_Transfer
          (SDL_HID_Read_Timeout
             (Self.Internal,
              Buffer_Address (Buffer),
              C.size_t (Buffer'Length),
              Timeout_MS),
           "SDL_hid_read_timeout failed");
      return Slice_Bytes (Buffer, Count);
   end Read;

   function Send_Feature_Report
     (Self : in Device;
      Data : in Byte_Lists) return Natural
   is
   begin
      Require_Valid (Self);
      return Checked_Transfer
        (SDL_HID_Send_Feature_Report
           (Self.Internal,
            Buffer_Address (Data),
            C.size_t (Data'Length)),
         "SDL_hid_send_feature_report failed");
   end Send_Feature_Report;

   function Get_Feature_Report
     (Self      : in Device;
      Report_ID : in Report_IDs;
      Capacity  : in Positive) return Byte_Lists
   is
      Buffer : Byte_Lists (0 .. Capacity - 1) := [others => 0];
      Count  : Natural;
   begin
      Require_Valid (Self);

      Buffer (Buffer'First) := Report_ID;
      Count :=
        Checked_Transfer
          (SDL_HID_Get_Feature_Report
             (Self.Internal,
              Buffer_Address (Buffer),
              C.size_t (Buffer'Length)),
           "SDL_hid_get_feature_report failed");
      return Slice_Bytes (Buffer, Count);
   end Get_Feature_Report;

   function Get_Input_Report
     (Self      : in Device;
      Report_ID : in Report_IDs;
      Capacity  : in Positive) return Byte_Lists
   is
      Buffer : Byte_Lists (0 .. Capacity - 1) := [others => 0];
      Count  : Natural;
   begin
      Require_Valid (Self);

      Buffer (Buffer'First) := Report_ID;
      Count :=
        Checked_Transfer
          (SDL_HID_Get_Input_Report
             (Self.Internal,
              Buffer_Address (Buffer),
              C.size_t (Buffer'Length)),
           "SDL_hid_get_input_report failed");
      return Slice_Bytes (Buffer, Count);
   end Get_Input_Report;

   function Get_Report_Descriptor
     (Self     : in Device;
      Capacity : in Positive := 4096) return Byte_Lists
   is
      Buffer : Byte_Lists (0 .. Capacity - 1) := [others => 0];
      Count  : Natural;
   begin
      Require_Valid (Self);

      Count :=
        Checked_Transfer
          (SDL_HID_Get_Report_Descriptor
             (Self.Internal,
              Buffer_Address (Buffer),
              C.size_t (Buffer'Length)),
           "SDL_hid_get_report_descriptor failed");
      return Slice_Bytes (Buffer, Count);
   end Get_Report_Descriptor;

   function Manufacturer_String
     (Self     : in Device;
      Capacity : in Positive := 256) return String
   is
      Buffer : aliased C.wchar_array (0 .. C.size_t (Capacity - 1)) :=
        [others => C.wide_nul];
   begin
      Require_Valid (Self);

      if SDL_HID_Get_Manufacturer_String
          (Self.Internal,
           Wide_Char_Pointers.Pointer'
             (Buffer (Buffer'First)'Unchecked_Access),
           C.size_t (Buffer'Length)) < 0
      then
         Raise_Last_Error ("SDL_hid_get_manufacturer_string failed");
      end if;

      return Buffer_To_UTF_8 (Buffer);
   end Manufacturer_String;

   function Product_String
     (Self     : in Device;
      Capacity : in Positive := 256) return String
   is
      Buffer : aliased C.wchar_array (0 .. C.size_t (Capacity - 1)) :=
        [others => C.wide_nul];
   begin
      Require_Valid (Self);

      if SDL_HID_Get_Product_String
          (Self.Internal,
           Wide_Char_Pointers.Pointer'
             (Buffer (Buffer'First)'Unchecked_Access),
           C.size_t (Buffer'Length)) < 0
      then
         Raise_Last_Error ("SDL_hid_get_product_string failed");
      end if;

      return Buffer_To_UTF_8 (Buffer);
   end Product_String;

   function Serial_Number_String
     (Self     : in Device;
      Capacity : in Positive := 256) return String
   is
      Buffer : aliased C.wchar_array (0 .. C.size_t (Capacity - 1)) :=
        [others => C.wide_nul];
   begin
      Require_Valid (Self);

      if SDL_HID_Get_Serial_Number_String
          (Self.Internal,
           Wide_Char_Pointers.Pointer'
             (Buffer (Buffer'First)'Unchecked_Access),
           C.size_t (Buffer'Length)) < 0
      then
         Raise_Last_Error ("SDL_hid_get_serial_number_string failed");
      end if;

      return Buffer_To_UTF_8 (Buffer);
   end Serial_Number_String;

   function Indexed_String
     (Self     : in Device;
      Index    : in String_Indices;
      Capacity : in Positive := 256) return String
   is
      Buffer : aliased C.wchar_array (0 .. C.size_t (Capacity - 1)) :=
        [others => C.wide_nul];
   begin
      Require_Valid (Self);

      if SDL_HID_Get_Indexed_String
          (Self.Internal,
           Index,
           Wide_Char_Pointers.Pointer'
             (Buffer (Buffer'First)'Unchecked_Access),
           C.size_t (Buffer'Length)) < 0
      then
         Raise_Last_Error ("SDL_hid_get_indexed_string failed");
      end if;

      return Buffer_To_UTF_8 (Buffer);
   end Indexed_String;

   procedure BLE_Scan (Active : in Boolean) is
   begin
      SDL_HID_BLE_Scan (To_C_Bool (Active));
   end BLE_Scan;
end SDL.HIDAPI;
