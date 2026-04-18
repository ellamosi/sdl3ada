with Interfaces;
with Interfaces.C;
with Interfaces.C.Extensions;
with Interfaces.C.Pointers;
with Interfaces.C.Strings;
with System;

with SDL.Raw.Properties;

package SDL.Raw.HIDAPI is
   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;
   package CS renames Interfaces.C.Strings;

   subtype Device_Change_Counts is Interfaces.Unsigned_32;
   subtype String_Indices is Interfaces.Integer_32;
   subtype Timeout_Milliseconds is Interfaces.Integer_32;

   package Wide_Char_Pointers is new Interfaces.C.Pointers
     (Index              => C.size_t,
      Element            => C.wchar_t,
      Element_Array      => C.wchar_array,
      Default_Terminator => C.wide_nul);

   type Bus_Types is
     (Unknown_Bus,
      USB,
      Bluetooth,
      I2C,
      SPI)
   with
     Convention => C,
     Size       => C.int'Size;

   for Bus_Types use
     (Unknown_Bus => 16#00#,
      USB         => 16#01#,
      Bluetooth   => 16#02#,
      I2C         => 16#03#,
      SPI         => 16#04#);

   type Device_Info;
   type Device_Info_Access is access all Device_Info with
     Convention => C;

   type Device_Info is record
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
      Next                : Device_Info_Access;
   end record
   with Convention => C;

   function HID_Init return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_hid_init";

   function HID_Exit return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_hid_exit";

   function HID_Device_Change_Count return Device_Change_Counts
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_hid_device_change_count";

   function HID_Enumerate
     (Vendor_ID  : in C.unsigned_short;
      Product_ID : in C.unsigned_short) return Device_Info_Access
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_hid_enumerate";

   procedure HID_Free_Enumeration (Devices : in Device_Info_Access)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_hid_free_enumeration";

   function HID_Open
     (Vendor_ID     : in C.unsigned_short;
      Product_ID    : in C.unsigned_short;
      Serial_Number : in Wide_Char_Pointers.Pointer)
      return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_hid_open";

   function HID_Open_Path
     (Path : in CS.chars_ptr) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_hid_open_path";

   function HID_Get_Properties
     (Self : in System.Address) return SDL.Raw.Properties.ID
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_hid_get_properties";

   function HID_Write
     (Self   : in System.Address;
      Data   : in System.Address;
      Length : in C.size_t) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_hid_write";

   function HID_Read_Timeout
     (Self         : in System.Address;
      Data         : in System.Address;
      Length       : in C.size_t;
      Milliseconds : in Timeout_Milliseconds) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_hid_read_timeout";

   function HID_Read
     (Self   : in System.Address;
      Data   : in System.Address;
      Length : in C.size_t) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_hid_read";

   function HID_Set_Nonblocking
     (Self        : in System.Address;
      Nonblocking : in C.int) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_hid_set_nonblocking";

   function HID_Send_Feature_Report
     (Self   : in System.Address;
      Data   : in System.Address;
      Length : in C.size_t) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_hid_send_feature_report";

   function HID_Get_Feature_Report
     (Self   : in System.Address;
      Data   : in System.Address;
      Length : in C.size_t) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_hid_get_feature_report";

   function HID_Get_Input_Report
     (Self   : in System.Address;
      Data   : in System.Address;
      Length : in C.size_t) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_hid_get_input_report";

   function HID_Close
     (Self : in System.Address) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_hid_close";

   function HID_Get_Manufacturer_String
     (Self   : in System.Address;
      Value  : in Wide_Char_Pointers.Pointer;
      Maxlen : in C.size_t) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_hid_get_manufacturer_string";

   function HID_Get_Product_String
     (Self   : in System.Address;
      Value  : in Wide_Char_Pointers.Pointer;
      Maxlen : in C.size_t) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_hid_get_product_string";

   function HID_Get_Serial_Number_String
     (Self   : in System.Address;
      Value  : in Wide_Char_Pointers.Pointer;
      Maxlen : in C.size_t) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_hid_get_serial_number_string";

   function HID_Get_Indexed_String
     (Self         : in System.Address;
      String_Index : in String_Indices;
      Value        : in Wide_Char_Pointers.Pointer;
      Maxlen       : in C.size_t) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_hid_get_indexed_string";

   function HID_Get_Device_Info
     (Self : in System.Address) return Device_Info_Access
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_hid_get_device_info";

   function HID_Get_Report_Descriptor
     (Self     : in System.Address;
      Buffer   : in System.Address;
      Buf_Size : in C.size_t) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_hid_get_report_descriptor";

   procedure HID_BLE_Scan (Active : in CE.bool)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_hid_ble_scan";
end SDL.Raw.HIDAPI;
