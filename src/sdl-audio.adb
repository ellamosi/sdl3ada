with Ada.Streams;

with Interfaces.C;
with Interfaces.C.Extensions;
with Interfaces.C.Strings;

with SDL.Audio.Sample_Formats;
with SDL.Error;
with SDL.Hints;

package body SDL.Audio is
   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;
   package CS renames Interfaces.C.Strings;

   use type C.C_float;
   use type C.int;
   use type C.ptrdiff_t;
   use type CS.chars_ptr;
   use type Ada.Streams.Stream_Element_Offset;
   use type Interfaces.Unsigned_32;
   use type System.Address;

   Empty_Bytes : constant Ada.Streams.Stream_Element_Array (1 .. 0) :=
     [others => 0];

   function SDL_Get_Num_Audio_Drivers return C.int with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetNumAudioDrivers";

   function SDL_Get_Audio_Driver (Index : in C.int) return CS.chars_ptr with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetAudioDriver";

   function SDL_Get_Current_Audio_Driver return CS.chars_ptr with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetCurrentAudioDriver";

   function SDL_Get_Audio_Playback_Devices
     (Count : access C.int) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetAudioPlaybackDevices";

   function SDL_Get_Audio_Recording_Devices
     (Count : access C.int) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetAudioRecordingDevices";

   function SDL_Get_Audio_Device_Name
     (Device : in Device_ID) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetAudioDeviceName";

   function SDL_Open_Audio_Device
     (Device : in Device_ID;
      Spec   : access constant SDL.Audio.Spec) return Device_ID
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_OpenAudioDevice";

   function SDL_Get_Audio_Device_Format
     (Device        : in Device_ID;
      Spec          : access SDL.Audio.Spec;
      Sample_Frames : access C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetAudioDeviceFormat";

   function SDL_Get_Audio_Device_Channel_Map
     (Device : in Device_ID;
      Count  : access C.int) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetAudioDeviceChannelMap";

   function SDL_Is_Audio_Device_Physical
     (Device : in Device_ID) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_IsAudioDevicePhysical";

   function SDL_Is_Audio_Device_Playback
     (Device : in Device_ID) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_IsAudioDevicePlayback";

   function SDL_Pause_Audio_Device
     (Device : in Device_ID) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_PauseAudioDevice";

   function SDL_Resume_Audio_Device
     (Device : in Device_ID) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ResumeAudioDevice";

   function SDL_Audio_Device_Paused
     (Device : in Device_ID) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_AudioDevicePaused";

   function SDL_Get_Audio_Device_Gain
     (Device : in Device_ID) return C.C_float
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetAudioDeviceGain";

   function SDL_Set_Audio_Device_Gain
     (Device : in Device_ID;
      Gain   : in C.C_float) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetAudioDeviceGain";

   procedure SDL_Close_Audio_Device (Device : in Device_ID) with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CloseAudioDevice";

   function SDL_Get_Audio_Format_Name
     (Format : in Sample_Format) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetAudioFormatName";

   function SDL_Set_Audio_Postmix_Callback
     (Device    : in Device_ID;
      Callback  : in Postmix_Callback;
      User_Data : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetAudioPostmixCallback";

   function SDL_Load_WAV_IO
     (Source      : in SDL.RWops.Handle;
      Close_IO    : in CE.bool;
      Spec        : access SDL.Audio.Spec;
      Audio_Data  : access System.Address;
      Audio_Size  : access Interfaces.Unsigned_32) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_LoadWAV_IO";

   function SDL_Load_WAV
     (Path       : in CS.chars_ptr;
      Spec       : access SDL.Audio.Spec;
      Audio_Data : access System.Address;
      Audio_Size : access Interfaces.Unsigned_32) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_LoadWAV";

   function SDL_Mix_Audio
     (Destination : in System.Address;
      Source      : in System.Address;
      Format      : in Sample_Format;
      Byte_Length : in Interfaces.Unsigned_32;
      Volume      : in C.C_float) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_MixAudio";

   function SDL_Convert_Audio_Samples
     (Source_Spec      : access constant SDL.Audio.Spec;
      Source_Data      : in System.Address;
      Source_Length    : in C.int;
      Destination_Spec : access constant SDL.Audio.Spec;
      Destination_Data : access System.Address;
      Destination_Size : access C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ConvertAudioSamples";

   function SDL_Get_Silence_Value_For_Format
     (Format : in Sample_Format) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetSilenceValueForFormat";

   procedure SDL_Free (Value : in System.Address) with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_free";

   type Raw_Device_ID_Array is array (C.ptrdiff_t range <>) of aliased Device_ID with
     Convention => C;

   type Raw_Channel_Map is array (C.ptrdiff_t range <>) of aliased C.int with
     Convention => C;

   procedure Raise_Last_Error
     (Default_Message : in String := "SDL audio call failed");

   function Copy_Buffer
     (Buffer      : in System.Address;
      Byte_Length : in Natural) return Ada.Streams.Stream_Element_Array;

   function Copy_Device_List
     (Items : in System.Address;
      Count : in C.int) return Device_IDs;

   function Copy_Channel_Map
     (Items : in System.Address;
      Count : in C.int) return Channel_Map;

   procedure Raise_Last_Error
     (Default_Message : in String := "SDL audio call failed")
   is
      Message : constant String := SDL.Error.Get;
   begin
      if Message = "" then
         raise Audio_Error with Default_Message;
      end if;

      raise Audio_Error with Message;
   end Raise_Last_Error;

   function Copy_Buffer
     (Buffer      : in System.Address;
      Byte_Length : in Natural) return Ada.Streams.Stream_Element_Array
   is
   begin
      if Byte_Length = 0 then
         if Buffer /= System.Null_Address then
            SDL_Free (Buffer);
         end if;

         return Empty_Bytes;
      end if;

      if Buffer = System.Null_Address then
         Raise_Last_Error ("SDL audio buffer allocation failed");
      end if;

      declare
         Bytes : Ada.Streams.Stream_Element_Array
           (1 .. Ada.Streams.Stream_Element_Offset (Byte_Length));
         for Bytes'Address use Buffer;
         pragma Import (Ada, Bytes);

         Result : constant Ada.Streams.Stream_Element_Array := Bytes;
      begin
         SDL_Free (Buffer);
         return Result;
      exception
         when others =>
            SDL_Free (Buffer);
            raise;
      end;
   end Copy_Buffer;

   function Copy_Device_List
     (Items : in System.Address;
      Count : in C.int) return Device_IDs
   is
   begin
      if Items = System.Null_Address then
         declare
            Message : constant String := SDL.Error.Get;
         begin
            if Message /= "" then
               raise Audio_Error with Message;
            end if;
         end;

         return [];
      end if;

      if Count <= 0 then
         SDL_Free (Items);
         return [];
      end if;

      declare
         Raw_Devices : Raw_Device_ID_Array (0 .. C.ptrdiff_t (Count - 1));
         for Raw_Devices'Address use Items;
         pragma Import (Ada, Raw_Devices);

         Result : Device_IDs (1 .. Natural (Count));
      begin
         for Index in Result'Range loop
            Result (Index) := Raw_Devices (C.ptrdiff_t (Index - 1));
         end loop;

         SDL_Free (Items);
         return Result;
      exception
         when others =>
            SDL_Free (Items);
            raise;
      end;
   end Copy_Device_List;

   function Copy_Channel_Map
     (Items : in System.Address;
      Count : in C.int) return Channel_Map
   is
   begin
      if Items = System.Null_Address then
         declare
            Message : constant String := SDL.Error.Get;
         begin
            if Message /= "" then
               raise Audio_Error with Message;
            end if;
         end;

         return [];
      end if;

      if Count <= 0 then
         SDL_Free (Items);
         return [];
      end if;

      declare
         Raw_Map : Raw_Channel_Map (0 .. C.ptrdiff_t (Count - 1));
         for Raw_Map'Address use Items;
         pragma Import (Ada, Raw_Map);

         Result : Channel_Map (1 .. Natural (Count));
      begin
         for Index in Result'Range loop
            Result (Index) := Raw_Map (C.ptrdiff_t (Index - 1));
         end loop;

         SDL_Free (Items);
         return Result;
      exception
         when others =>
            SDL_Free (Items);
            raise;
      end;
   end Copy_Channel_Map;

   function Initialise (Name : in String := "") return Boolean is
   begin
      if Name /= "" then
         begin
            SDL.Hints.Set (SDL.Hints.Audio_Driver, Name);
         exception
            when SDL.Hints.Hint_Error =>
               null;
         end;
      end if;

      return SDL.Initialise_Sub_System (SDL.Enable_Audio);
   end Initialise;

   procedure Finalise is
   begin
      SDL.Finalise_Sub_System (SDL.Enable_Audio);
   end Finalise;

   function Total_Drivers return Positive is
      Count : constant C.int := SDL_Get_Num_Audio_Drivers;
   begin
      if Count < 0 then
         raise Audio_Error with SDL.Error.Get;
      end if;

      if Count = 0 then
         raise Audio_Error with "No audio drivers are available";
      end if;

      return Positive (Count);
   end Total_Drivers;

   function Driver_Name (Index : in Positive) return String is
      Name : constant CS.chars_ptr := SDL_Get_Audio_Driver (C.int (Index) - 1);
   begin
      if Name = CS.Null_Ptr then
         declare
            Message : constant String := SDL.Error.Get;
         begin
            if Message /= "" then
               raise Audio_Error with Message;
            end if;
         end;

         raise Audio_Error with "Audio driver index is out of range";
      end if;

      return CS.Value (Name);
   end Driver_Name;

   function Current_Driver_Name return String is
      Name : constant CS.chars_ptr := SDL_Get_Current_Audio_Driver;
   begin
      if Name = CS.Null_Ptr then
         declare
            Message : constant String := SDL.Error.Get;
         begin
            if Message /= "" then
               raise Audio_Error with Message;
            end if;
         end;

         raise Audio_Error with "Audio subsystem is not initialized";
      end if;

      return CS.Value (Name);
   end Current_Driver_Name;

   function Playback_Devices return Device_IDs is
      Count : aliased C.int := 0;
      Items : constant System.Address :=
        SDL_Get_Audio_Playback_Devices (Count'Access);
   begin
      return Copy_Device_List (Items => Items, Count => Count);
   end Playback_Devices;

   function Recording_Devices return Device_IDs is
      Count : aliased C.int := 0;
      Items : constant System.Address :=
        SDL_Get_Audio_Recording_Devices (Count'Access);
   begin
      return Copy_Device_List (Items => Items, Count => Count);
   end Recording_Devices;

   function Device_Name (Device : in Device_ID) return String is
      Name : constant CS.chars_ptr := SDL_Get_Audio_Device_Name (Device);
   begin
      if Name = CS.Null_Ptr then
         Raise_Last_Error ("Audio device lookup failed");
      end if;

      return CS.Value (Name);
   end Device_Name;

   function Open_Device
     (Device    : in Device_ID;
      Requested : in Spec) return Device_ID
   is
      Requested_Spec : aliased constant Spec := Requested;
      Opened_Device  : constant Device_ID :=
        SDL_Open_Audio_Device (Device, Requested_Spec'Access);
   begin
      if Opened_Device = 0 then
         Raise_Last_Error ("Audio device open failed");
      end if;

      return Opened_Device;
   end Open_Device;

   function Open_Device
     (Device : in Device_ID := Default_Playback_Device) return Device_ID
   is
      Opened_Device : constant Device_ID := SDL_Open_Audio_Device (Device, null);
   begin
      if Opened_Device = 0 then
         Raise_Last_Error ("Audio device open failed");
      end if;

      return Opened_Device;
   end Open_Device;

   procedure Close_Device (Device : in Device_ID) is
   begin
      SDL_Close_Audio_Device (Device);
   end Close_Device;

   procedure Pause_Device (Device : in Device_ID) is
   begin
      if not Boolean (SDL_Pause_Audio_Device (Device)) then
         Raise_Last_Error ("Audio device pause failed");
      end if;
   end Pause_Device;

   procedure Resume_Device (Device : in Device_ID) is
   begin
      if not Boolean (SDL_Resume_Audio_Device (Device)) then
         Raise_Last_Error ("Audio device resume failed");
      end if;
   end Resume_Device;

   function Device_Paused (Device : in Device_ID) return Boolean is
   begin
      return Boolean (SDL_Audio_Device_Paused (Device));
   end Device_Paused;

   function Get_Device_Format
     (Device        : in Device_ID;
      Sample_Frames : out Natural) return Spec
   is
      Format_Details : aliased Spec;
      Frames         : aliased C.int := 0;
   begin
      if not Boolean
          (SDL_Get_Audio_Device_Format
             (Device        => Device,
              Spec          => Format_Details'Access,
              Sample_Frames => Frames'Access))
      then
         Raise_Last_Error ("Audio device format query failed");
      end if;

      Sample_Frames := (if Frames > 0 then Natural (Frames) else 0);
      return Format_Details;
   end Get_Device_Format;

   function Get_Device_Channel_Map (Device : in Device_ID) return Channel_Map is
      Count : aliased C.int := 0;
      Items : constant System.Address :=
        SDL_Get_Audio_Device_Channel_Map (Device, Count'Access);
   begin
      return Copy_Channel_Map (Items => Items, Count => Count);
   end Get_Device_Channel_Map;

   function Is_Device_Physical (Device : in Device_ID) return Boolean is
   begin
      return Boolean (SDL_Is_Audio_Device_Physical (Device));
   end Is_Device_Physical;

   function Is_Device_Playback (Device : in Device_ID) return Boolean is
   begin
      return Boolean (SDL_Is_Audio_Device_Playback (Device));
   end Is_Device_Playback;

   function Get_Device_Gain (Device : in Device_ID) return Float is
      Gain : constant C.C_float := SDL_Get_Audio_Device_Gain (Device);
   begin
      if Gain < 0.0 and then SDL.Error.Get /= "" then
         Raise_Last_Error ("Audio device gain query failed");
      end if;

      return Float (Gain);
   end Get_Device_Gain;

   procedure Set_Device_Gain
     (Device : in Device_ID;
      Gain   : in Float)
   is
   begin
      if not Boolean
          (SDL_Set_Audio_Device_Gain
             (Device => Device,
              Gain   => C.C_float (Gain)))
      then
         Raise_Last_Error ("Audio device gain update failed");
      end if;
   end Set_Device_Gain;

   procedure Set_Postmix_Callback
     (Device    : in Device_ID;
      Callback  : in Postmix_Callback;
      User_Data : in System.Address := System.Null_Address)
   is
   begin
      if not Boolean
          (SDL_Set_Audio_Postmix_Callback
             (Device    => Device,
              Callback  => Callback,
              User_Data => User_Data))
      then
         Raise_Last_Error ("Audio postmix callback update failed");
      end if;
   end Set_Postmix_Callback;

   function Format_Name (Format : in Sample_Format) return String is
      Name : constant CS.chars_ptr := SDL_Get_Audio_Format_Name (Format);
   begin
      if Name = CS.Null_Ptr then
         return "";
      end if;

      return CS.Value (Name);
   end Format_Name;

   function Silence_Value
     (Format : in Sample_Format) return Interfaces.Unsigned_8
   is
      Value : constant C.int := SDL_Get_Silence_Value_For_Format (Format);
   begin
      if Value < 0 and then SDL.Error.Get /= "" then
         Raise_Last_Error ("Audio silence value query failed");
      end if;

      return Interfaces.Unsigned_8 (Value);
   end Silence_Value;

   function Frame_Size
     (Format   : in Sample_Format;
      Channels : in Channel_Count)
      return Natural
   is
   begin
      return SDL.Audio.Sample_Formats.Byte_Size (Format) * Natural (Channels);
   end Frame_Size;

   function Frame_Size (Value : in Spec) return Natural is
   begin
      return Frame_Size (Value.Format, Value.Channels);
   end Frame_Size;

   function Load_WAV
     (Source      : in SDL.RWops.RWops;
      Spec        : out SDL.Audio.Spec;
      Close_After : in Boolean := False)
      return Ada.Streams.Stream_Element_Array
   is
      Loaded_Spec : aliased SDL.Audio.Spec;
      Data        : aliased System.Address := System.Null_Address;
      Byte_Length : aliased Interfaces.Unsigned_32 := 0;
   begin
      if not Boolean
          (SDL_Load_WAV_IO
             (Source      => SDL.RWops.Get_Handle (Source),
              Close_IO    => CE.bool'Val (Boolean'Pos (Close_After)),
              Spec        => Loaded_Spec'Access,
              Audio_Data  => Data'Access,
              Audio_Size  => Byte_Length'Access))
      then
         Raise_Last_Error ("WAV load from stream failed");
      end if;

      Spec := Loaded_Spec;
      return Copy_Buffer (Data, Natural (Byte_Length));
   end Load_WAV;

   function Load_WAV
     (Path : in String;
      Spec : out SDL.Audio.Spec)
      return Ada.Streams.Stream_Element_Array
   is
      C_Path      : CS.chars_ptr := CS.New_String (Path);
      Loaded_Spec : aliased SDL.Audio.Spec;
      Data        : aliased System.Address := System.Null_Address;
      Byte_Length : aliased Interfaces.Unsigned_32 := 0;
   begin
      begin
         if not Boolean
             (SDL_Load_WAV
                (Path       => C_Path,
                 Spec       => Loaded_Spec'Access,
                 Audio_Data => Data'Access,
                 Audio_Size => Byte_Length'Access))
         then
            Raise_Last_Error ("WAV load from path failed");
         end if;

         declare
            Result : constant Ada.Streams.Stream_Element_Array :=
              Copy_Buffer (Data, Natural (Byte_Length));
         begin
            CS.Free (C_Path);
            Spec := Loaded_Spec;
            return Result;
         end;
      exception
         when others =>
            CS.Free (C_Path);
            raise;
      end;
   end Load_WAV;

   procedure Mix
     (Destination : in System.Address;
      Source      : in System.Address;
      Format      : in Sample_Format;
      Byte_Length : in Interfaces.Unsigned_32;
      Volume      : in Float := 1.0)
   is
   begin
      if Byte_Length = 0 then
         return;
      end if;

      if not Boolean
          (SDL_Mix_Audio
             (Destination => Destination,
              Source      => Source,
              Format      => Format,
              Byte_Length => Byte_Length,
              Volume      => C.C_float (Volume)))
      then
         Raise_Last_Error ("Audio mix failed");
      end if;
   end Mix;

   procedure Mix
     (Destination : in out Ada.Streams.Stream_Element_Array;
      Source      : in Ada.Streams.Stream_Element_Array;
      Format      : in Sample_Format;
      Volume      : in Float := 1.0)
   is
   begin
      if Destination'Length /= Source'Length then
         raise Audio_Error with
           "Audio mix requires destination and source buffers of equal length";
      end if;

      if Destination'Length = 0 then
         return;
      end if;

      Mix
        (Destination => Destination'Address,
         Source      => Source'Address,
         Format      => Format,
         Byte_Length => Interfaces.Unsigned_32 (Destination'Length),
         Volume      => Volume);
   end Mix;

   function Convert_Samples
     (Source_Spec      : in Spec;
      Source_Data      : in System.Address;
      Source_Length    : in Natural;
      Destination_Spec : in Spec)
      return Ada.Streams.Stream_Element_Array
   is
      Input_Spec    : aliased constant Spec := Source_Spec;
      Output_Spec   : aliased constant Spec := Destination_Spec;
      Converted     : aliased System.Address := System.Null_Address;
      Converted_Len : aliased C.int := 0;
   begin
      if Source_Length = 0 then
         return Empty_Bytes;
      end if;

      if not Boolean
          (SDL_Convert_Audio_Samples
             (Source_Spec      => Input_Spec'Access,
              Source_Data      => Source_Data,
              Source_Length    => C.int (Source_Length),
              Destination_Spec => Output_Spec'Access,
              Destination_Data => Converted'Access,
              Destination_Size => Converted_Len'Access))
      then
         Raise_Last_Error ("Audio sample conversion failed");
      end if;

      return Copy_Buffer
        (Buffer      => Converted,
         Byte_Length => Natural (Converted_Len));
   end Convert_Samples;

   function Convert_Samples
     (Source_Spec      : in Spec;
      Source_Data      : in Ada.Streams.Stream_Element_Array;
      Destination_Spec : in Spec)
      return Ada.Streams.Stream_Element_Array
   is
   begin
      if Source_Data'Length = 0 then
         return Empty_Bytes;
      end if;

      return Convert_Samples
        (Source_Spec      => Source_Spec,
         Source_Data      => Source_Data'Address,
         Source_Length    => Natural (Source_Data'Length),
         Destination_Spec => Destination_Spec);
   end Convert_Samples;
end SDL.Audio;
