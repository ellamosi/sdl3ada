with Ada.Unchecked_Conversion;
with Interfaces.C.Extensions;
with Interfaces.C.Pointers;
with Interfaces.C.Strings;
with System;

with SDL.Error;

package body SDL.Sensors is
   package CE renames Interfaces.C.Extensions;
   package CS renames Interfaces.C.Strings;

   use type C.ptrdiff_t;
   use type CS.chars_ptr;
   use type SDL.C_Pointers.Sensor_Pointer;
   use type SDL.Properties.Property_ID;
   use type System.Address;

   type ID_Arrays is array (C.ptrdiff_t range <>) of aliased ID with
     Convention => C;

   package ID_Pointers is new Interfaces.C.Pointers
     (Index              => C.ptrdiff_t,
      Element            => ID,
      Element_Array      => ID_Arrays,
      Default_Terminator => 0);

   use type ID_Pointers.Pointer;

   function To_Address is new Ada.Unchecked_Conversion
     (Source => ID_Pointers.Pointer,
      Target => System.Address);

   procedure SDL_Free (Memory : in System.Address) with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_free";

   function SDL_Get_Sensors
     (Count : access C.int) return ID_Pointers.Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetSensors";

   function SDL_Get_Sensor_Name_For_ID
     (Instance : in ID) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetSensorNameForID";

   function SDL_Get_Sensor_Type_For_ID
     (Instance : in ID) return Types
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetSensorTypeForID";

   function SDL_Get_Sensor_Non_Portable_Type_For_ID
     (Instance : in ID) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetSensorNonPortableTypeForID";

   function SDL_Open_Sensor
     (Instance : in ID) return SDL.C_Pointers.Sensor_Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_OpenSensor";

   function SDL_Get_Sensor_From_ID
     (Instance : in ID) return SDL.C_Pointers.Sensor_Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetSensorFromID";

   function SDL_Get_Sensor_Properties
     (Self : in SDL.C_Pointers.Sensor_Pointer) return SDL.Properties.Property_ID
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetSensorProperties";

   function SDL_Get_Sensor_Name
     (Self : in SDL.C_Pointers.Sensor_Pointer) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetSensorName";

   function SDL_Get_Sensor_Type
     (Self : in SDL.C_Pointers.Sensor_Pointer) return Types
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetSensorType";

   function SDL_Get_Sensor_Non_Portable_Type
     (Self : in SDL.C_Pointers.Sensor_Pointer) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetSensorNonPortableType";

   function SDL_Get_Sensor_ID
     (Self : in SDL.C_Pointers.Sensor_Pointer) return ID
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetSensorID";

   function SDL_Get_Sensor_Data
     (Self       : in SDL.C_Pointers.Sensor_Pointer;
      Data       : in System.Address;
      Value_Count : in C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetSensorData";

   procedure SDL_Close_Sensor
     (Self : in SDL.C_Pointers.Sensor_Pointer)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CloseSensor";

   procedure Raise_Last_Error
     (Default_Message : in String := "SDL sensor call failed");

   procedure Raise_Last_Error
     (Default_Message : in String := "SDL sensor call failed")
   is
      Message : constant String := SDL.Error.Get;
   begin
      if Message = "" then
         raise Sensor_Error with Default_Message;
      end if;

      raise Sensor_Error with Message;
   end Raise_Last_Error;

   procedure Require_Valid (Self : in Sensor);

   procedure Require_Valid (Self : in Sensor) is
   begin
      if Self.Internal = null then
         raise Sensor_Error with "Invalid sensor";
      end if;
   end Require_Valid;

   procedure Free (Items : in out ID_Pointers.Pointer);

   procedure Free (Items : in out ID_Pointers.Pointer) is
   begin
      if Items /= null then
         SDL_Free (To_Address (Items));
         Items := null;
      end if;
   end Free;

   function Copy_IDs
     (Items : in ID_Pointers.Pointer;
      Count : in C.int) return ID_Lists;

   function Copy_IDs
     (Items : in ID_Pointers.Pointer;
      Count : in C.int) return ID_Lists
   is
      Raw : ID_Pointers.Pointer := Items;
   begin
      if Count <= 0 then
         Free (Raw);
         return [];
      end if;

      if Raw = null then
         Raise_Last_Error ("Sensor enumeration failed");
      end if;

      declare
         Source : constant ID_Arrays :=
           ID_Pointers.Value (Raw, C.ptrdiff_t (Count));
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

   function Get_Sensors return ID_Lists is
      Count : aliased C.int := 0;
      Items : constant ID_Pointers.Pointer := SDL_Get_Sensors (Count'Access);
   begin
      return Copy_IDs (Items, Count);
   end Get_Sensors;

   function Name (Instance : in ID) return String is
      Value : constant CS.chars_ptr := SDL_Get_Sensor_Name_For_ID (Instance);
   begin
      if Value = CS.Null_Ptr then
         return "";
      end if;

      return CS.Value (Value);
   end Name;

   function Get_Type (Instance : in ID) return Types is
   begin
      return SDL_Get_Sensor_Type_For_ID (Instance);
   end Get_Type;

   function Get_Non_Portable_Type (Instance : in ID) return C.int is
   begin
      return SDL_Get_Sensor_Non_Portable_Type_For_ID (Instance);
   end Get_Non_Portable_Type;

   function Open (Instance : in ID) return Sensor is
   begin
      return Result : Sensor do
         Open (Result, Instance);
      end return;
   end Open;

   procedure Open
     (Self     : in out Sensor;
      Instance : in ID)
   is
      Internal : SDL.C_Pointers.Sensor_Pointer := null;
   begin
      Close (Self);

      Internal := SDL_Open_Sensor (Instance);
      if Internal = null then
         Raise_Last_Error ("SDL_OpenSensor failed");
      end if;

      Self.Internal := Internal;
      Self.Owns := True;
   end Open;

   function Get (Instance : in ID) return Sensor is
   begin
      return (Ada.Finalization.Limited_Controlled with
              Internal => SDL_Get_Sensor_From_ID (Instance),
              Owns     => False);
   end Get;

   overriding
   procedure Finalize (Self : in out Sensor) is
   begin
      Close (Self);
   end Finalize;

   procedure Close (Self : in out Sensor) is
   begin
      if Self.Owns and then Self.Internal /= null then
         SDL_Close_Sensor (Self.Internal);
      end if;

      Self.Internal := null;
      Self.Owns := True;
   end Close;

   function Is_Null (Self : in Sensor) return Boolean is
     (Self.Internal = null);

   function Get_ID (Self : in Sensor) return ID is
      Result : ID;
   begin
      if Self.Internal = null then
         return 0;
      end if;

      Result := SDL_Get_Sensor_ID (Self.Internal);
      if Result = 0 then
         Raise_Last_Error ("SDL_GetSensorID failed");
      end if;

      return Result;
   end Get_ID;

   function Get_Properties
     (Self : in Sensor) return SDL.Properties.Property_Set
   is
      Props : SDL.Properties.Property_ID;
   begin
      Require_Valid (Self);

      Props := SDL_Get_Sensor_Properties (Self.Internal);
      if Props = SDL.Properties.Null_Property_ID then
         Raise_Last_Error ("SDL_GetSensorProperties failed");
      end if;

      return SDL.Properties.Reference (Props);
   end Get_Properties;

   function Name (Self : in Sensor) return String is
      Value : CS.chars_ptr;
   begin
      Require_Valid (Self);

      Value := SDL_Get_Sensor_Name (Self.Internal);
      if Value = CS.Null_Ptr then
         return "";
      end if;

      return CS.Value (Value);
   end Name;

   function Get_Type (Self : in Sensor) return Types is
   begin
      Require_Valid (Self);
      return SDL_Get_Sensor_Type (Self.Internal);
   end Get_Type;

   function Get_Non_Portable_Type (Self : in Sensor) return C.int is
   begin
      Require_Valid (Self);
      return SDL_Get_Sensor_Non_Portable_Type (Self.Internal);
   end Get_Non_Portable_Type;

   procedure Get_Data
     (Self : in Sensor;
      Data : out Data_Values)
   is
      Buffer_Address : constant System.Address :=
        (if Data'Length = 0
         then System.Null_Address
         else Data (Data'First)'Address);
   begin
      Require_Valid (Self);

      if not Boolean
          (SDL_Get_Sensor_Data
             (Self.Internal, Buffer_Address, C.int (Data'Length)))
      then
         Raise_Last_Error ("SDL_GetSensorData failed");
      end if;
   end Get_Data;

   function Get_Data
     (Self       : in Sensor;
      Value_Count : in Positive) return Data_Values
   is
      Result : Data_Values (0 .. Value_Count - 1);
   begin
      Get_Data (Self, Result);
      return Result;
   end Get_Data;

   function Get_Internal
     (Self : in Sensor) return SDL.C_Pointers.Sensor_Pointer is
   begin
      return Self.Internal;
   end Get_Internal;
end SDL.Sensors;
