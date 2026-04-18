with Ada.Finalization;
with Interfaces;
with Interfaces.C;

with SDL.C_Pointers;
with SDL.Properties;

package SDL.Sensors is
   pragma Elaborate_Body;

   package C renames Interfaces.C;

   Sensor_Error : exception;

   type ID is mod 2 ** 32 with
     Convention => C,
     Size       => 32;

   type ID_Lists is array (Natural range <>) of ID;

   type Types is
     (Invalid,
      Unknown,
      Accelerometer,
      Gyroscope,
      Accelerometer_Left,
      Gyroscope_Left,
      Accelerometer_Right,
      Gyroscope_Right,
      Sensor_Count)
   with
     Convention => C,
     Size       => C.int'Size;

   for Types use
     (Invalid             => -1,
      Unknown             => 0,
      Accelerometer       => 1,
      Gyroscope           => 2,
      Accelerometer_Left  => 3,
      Gyroscope_Left      => 4,
      Accelerometer_Right => 5,
      Gyroscope_Right     => 6,
      Sensor_Count        => 7);

   Standard_Gravity : constant C.C_float := 9.80665;

   type Data_Values is array (Natural range <>) of aliased C.C_float with
     Convention     => C,
     Component_Size => C.C_float'Size;

   type Sensor is new Ada.Finalization.Limited_Controlled with private;

   function Get_Sensors return ID_Lists;

   function Name (Instance : in ID) return String;

   function Get_Type (Instance : in ID) return Types;

   function Get_Non_Portable_Type (Instance : in ID) return C.int;

   function Open (Instance : in ID) return Sensor;

   procedure Open
     (Self     : in out Sensor;
      Instance : in ID);

   function Get (Instance : in ID) return Sensor;

   overriding
   procedure Finalize (Self : in out Sensor);

   procedure Close (Self : in out Sensor);

   function Is_Null (Self : in Sensor) return Boolean with
     Inline;

   function Get_ID (Self : in Sensor) return ID;

   function Get_Properties
     (Self : in Sensor) return SDL.Properties.Property_Set;

   function Name (Self : in Sensor) return String;

   function Get_Type (Self : in Sensor) return Types;

   function Get_Non_Portable_Type (Self : in Sensor) return C.int;

   procedure Get_Data
     (Self : in Sensor;
      Data : out Data_Values);

   function Get_Data
     (Self       : in Sensor;
      Value_Count : in Positive) return Data_Values;

   procedure Update;

   function Get_Internal
     (Self : in Sensor) return SDL.C_Pointers.Sensor_Pointer
   with
     Inline;
private
   type Sensor is new Ada.Finalization.Limited_Controlled with
      record
         Internal : SDL.C_Pointers.Sensor_Pointer := null;
         Owns     : Boolean := True;
      end record;
end SDL.Sensors;
