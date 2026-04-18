with Interfaces.C;
with Interfaces.C.Extensions;
with Interfaces.C.Pointers;
with Interfaces.C.Strings;
with System;

with SDL.C_Pointers;
with SDL.Raw.Properties;

package SDL.Raw.Sensor is
   pragma Preelaborate;

   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;
   package CS renames Interfaces.C.Strings;

   type ID is mod 2 ** 32 with
     Convention => C,
     Size       => 32;

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

   type ID_Arrays is array (C.ptrdiff_t range <>) of aliased ID with
     Convention => C;

   package ID_Pointers is new Interfaces.C.Pointers
     (Index              => C.ptrdiff_t,
      Element            => ID,
      Element_Array      => ID_Arrays,
      Default_Terminator => 0);

   procedure Free (Memory : in System.Address)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_free";

   function Get_Sensors
     (Count : access C.int) return ID_Pointers.Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetSensors";

   function Get_Sensor_Name_For_ID
     (Instance : in ID) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetSensorNameForID";

   function Get_Sensor_Type_For_ID
     (Instance : in ID) return Types
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetSensorTypeForID";

   function Get_Sensor_Non_Portable_Type_For_ID
     (Instance : in ID) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetSensorNonPortableTypeForID";

   function Open_Sensor
     (Instance : in ID) return SDL.C_Pointers.Sensor_Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_OpenSensor";

   function Get_Sensor_From_ID
     (Instance : in ID) return SDL.C_Pointers.Sensor_Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetSensorFromID";

   function Get_Sensor_Properties
     (Self : in SDL.C_Pointers.Sensor_Pointer) return SDL.Raw.Properties.ID
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetSensorProperties";

   function Get_Sensor_Name
     (Self : in SDL.C_Pointers.Sensor_Pointer) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetSensorName";

   function Get_Sensor_Type
     (Self : in SDL.C_Pointers.Sensor_Pointer) return Types
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetSensorType";

   function Get_Sensor_Non_Portable_Type
     (Self : in SDL.C_Pointers.Sensor_Pointer) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetSensorNonPortableType";

   function Get_Sensor_ID
     (Self : in SDL.C_Pointers.Sensor_Pointer) return ID
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetSensorID";

   function Get_Sensor_Data
     (Self        : in SDL.C_Pointers.Sensor_Pointer;
      Data        : in System.Address;
      Value_Count : in C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetSensorData";

   procedure Close_Sensor
     (Self : in SDL.C_Pointers.Sensor_Pointer)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CloseSensor";

   procedure Update
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_UpdateSensors";
end SDL.Raw.Sensor;
