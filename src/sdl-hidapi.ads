with Ada.Finalization;
with Ada.Strings.Unbounded;
with Interfaces;
with Interfaces.C;

with SDL.C_Pointers;
with SDL.Properties;

package SDL.HIDAPI is
   pragma Elaborate_Body;

   package C renames Interfaces.C;
   package US renames Ada.Strings.Unbounded;

   HIDAPI_Error : exception;

   subtype Vendor_IDs is Interfaces.Unsigned_16;
   subtype Product_IDs is Interfaces.Unsigned_16;
   subtype Release_Numbers is Interfaces.Unsigned_16;
   subtype Usage_Pages is Interfaces.Unsigned_16;
   subtype Usage_Values is Interfaces.Unsigned_16;
   subtype Report_IDs is Interfaces.Unsigned_8;
   subtype String_Indices is Interfaces.Integer_32;
   subtype Device_Change_Counts is Interfaces.Unsigned_32;
   subtype Timeout_Milliseconds is Interfaces.Integer_32;

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

   type Byte_Lists is array (Natural range <>) of aliased Interfaces.Unsigned_8 with
     Convention     => C,
     Component_Size => 8;

   type Device_Info is record
      Path               : US.Unbounded_String := US.Null_Unbounded_String;
      Vendor_ID          : Vendor_IDs := 0;
      Product_ID         : Product_IDs := 0;
      Serial_Number      : US.Unbounded_String := US.Null_Unbounded_String;
      Release_Number     : Release_Numbers := 0;
      Manufacturer       : US.Unbounded_String := US.Null_Unbounded_String;
      Product            : US.Unbounded_String := US.Null_Unbounded_String;
      Usage_Page         : Usage_Pages := 0;
      Usage              : Usage_Values := 0;
      Interface_Number   : C.int := -1;
      Interface_Class    : C.int := 0;
      Interface_Subclass : C.int := 0;
      Interface_Protocol : C.int := 0;
      Bus_Type           : Bus_Types := Unknown_Bus;
   end record;

   type Device_Info_Lists is array (Natural range <>) of Device_Info;

   LibUSB_Device_Handle_Pointer_Property : constant String :=
     "SDL.hidapi.libusb.device.handle";

   type Device is new Ada.Finalization.Limited_Controlled with private;

   Null_Device : constant Device;

   procedure Initialise;

   procedure Shutdown;

   function Get_Device_Change_Count return Device_Change_Counts;

   function Enumerate return Device_Info_Lists;

   function Enumerate
     (Vendor_ID  : in Vendor_IDs;
      Product_ID : in Product_IDs) return Device_Info_Lists;

   function Open
     (Vendor_ID     : in Vendor_IDs;
      Product_ID    : in Product_IDs;
      Serial_Number : in String := "") return Device;

   procedure Open
     (Self          : in out Device;
      Vendor_ID     : in Vendor_IDs;
      Product_ID    : in Product_IDs;
      Serial_Number : in String := "");

   function Open_Path (Path : in String) return Device;

   procedure Open_Path
     (Self : in out Device;
      Path : in String);

   overriding
   procedure Finalize (Self : in out Device);

   procedure Close (Self : in out Device);

   function Is_Null (Self : in Device) return Boolean with
     Inline;

   function Get_Properties
     (Self : in Device) return SDL.Properties.Property_Set;

   function Get_Info (Self : in Device) return Device_Info;

   procedure Set_Nonblocking
     (Self    : in Device;
      Enabled : in Boolean);

   function Write
     (Self : in Device;
      Data : in Byte_Lists) return Natural;

   function Read
     (Self     : in Device;
      Capacity : in Positive) return Byte_Lists;

   function Read
     (Self       : in Device;
      Capacity   : in Positive;
      Timeout_MS : in Timeout_Milliseconds) return Byte_Lists;

   function Send_Feature_Report
     (Self : in Device;
      Data : in Byte_Lists) return Natural;

   function Get_Feature_Report
     (Self      : in Device;
      Report_ID : in Report_IDs;
      Capacity  : in Positive) return Byte_Lists;

   function Get_Input_Report
     (Self      : in Device;
      Report_ID : in Report_IDs;
      Capacity  : in Positive) return Byte_Lists;

   function Get_Report_Descriptor
     (Self     : in Device;
      Capacity : in Positive := 4096) return Byte_Lists;

   function Manufacturer_String
     (Self     : in Device;
      Capacity : in Positive := 256) return String;

   function Product_String
     (Self     : in Device;
      Capacity : in Positive := 256) return String;

   function Serial_Number_String
     (Self     : in Device;
      Capacity : in Positive := 256) return String;

   function Indexed_String
     (Self     : in Device;
      Index    : in String_Indices;
      Capacity : in Positive := 256) return String;

   procedure BLE_Scan (Active : in Boolean);
private
   type Device is new Ada.Finalization.Limited_Controlled with
      record
         Internal : SDL.C_Pointers.HID_Device_Pointer := null;
         Owns     : Boolean := True;
      end record;

   Null_Device : constant Device :=
     (Ada.Finalization.Limited_Controlled with
        Internal => null,
        Owns     => True);
end SDL.HIDAPI;
