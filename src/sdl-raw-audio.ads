with Interfaces;
with Interfaces.C;
with Interfaces.C.Extensions;
with Interfaces.C.Strings;
with System;

with SDL.Raw.Properties;

package SDL.Raw.Audio is
   pragma Preelaborate;

   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;
   package CS renames Interfaces.C.Strings;

   subtype Device_ID is Interfaces.Unsigned_32;
   subtype Property_ID is SDL.Raw.Properties.ID;
   subtype Sample_Format is Interfaces.Unsigned_32;

   Unknown : constant Sample_Format := 16#0000#;

   Sample_Format_U8 : constant Sample_Format := 16#0008#;
   Sample_Format_S8 : constant Sample_Format := 16#8008#;

   Sample_Format_S16LSB : constant Sample_Format := 16#8010#;
   Sample_Format_S16MSB : constant Sample_Format := 16#9010#;

   Sample_Format_S32LSB : constant Sample_Format := 16#8020#;
   Sample_Format_S32MSB : constant Sample_Format := 16#9020#;

   Sample_Format_F32LSB : constant Sample_Format := 16#8120#;
   Sample_Format_F32MSB : constant Sample_Format := 16#9120#;

   type Postmix_Callback is access procedure
     (User_Data   : in System.Address;
      Spec        : in System.Address;
      Buffer      : in System.Address;
      Byte_Length : in C.int)
   with Convention => C;

   type Stream_Callback is access procedure
     (User_Data         : in System.Address;
      Stream            : in System.Address;
      Additional_Amount : in C.int;
      Total_Amount      : in C.int)
   with Convention => C;

   type Data_Complete_Callback is access procedure
     (User_Data   : in System.Address;
      Buffer      : in System.Address;
      Byte_Length : in C.int)
   with Convention => C;

   function Get_Num_Audio_Drivers return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetNumAudioDrivers";

   function Get_Audio_Driver
     (Index : in C.int) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetAudioDriver";

   function Get_Current_Audio_Driver return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetCurrentAudioDriver";

   function Get_Audio_Playback_Devices
     (Count : access C.int) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetAudioPlaybackDevices";

   function Get_Audio_Recording_Devices
     (Count : access C.int) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetAudioRecordingDevices";

   function Get_Audio_Device_Name
     (Device : in Device_ID) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetAudioDeviceName";

   function Open_Audio_Device
     (Device : in Device_ID;
      Spec   : in System.Address) return Device_ID
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_OpenAudioDevice";

   function Get_Audio_Device_Format
     (Device        : in Device_ID;
      Spec          : in System.Address;
      Sample_Frames : access C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetAudioDeviceFormat";

   function Get_Audio_Device_Channel_Map
     (Device : in Device_ID;
      Count  : access C.int) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetAudioDeviceChannelMap";

   function Is_Audio_Device_Physical
     (Device : in Device_ID) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_IsAudioDevicePhysical";

   function Is_Audio_Device_Playback
     (Device : in Device_ID) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_IsAudioDevicePlayback";

   function Pause_Audio_Device
     (Device : in Device_ID) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_PauseAudioDevice";

   function Resume_Audio_Device
     (Device : in Device_ID) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ResumeAudioDevice";

   function Audio_Device_Paused
     (Device : in Device_ID) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_AudioDevicePaused";

   function Get_Audio_Device_Gain
     (Device : in Device_ID) return C.C_float
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetAudioDeviceGain";

   function Set_Audio_Device_Gain
     (Device : in Device_ID;
      Gain   : in C.C_float) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetAudioDeviceGain";

   procedure Close_Audio_Device
     (Device : in Device_ID)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CloseAudioDevice";

   function Get_Audio_Format_Name
     (Format : in Sample_Format) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetAudioFormatName";

   function Set_Audio_Postmix_Callback
     (Device    : in Device_ID;
      Callback  : in Postmix_Callback;
      User_Data : in System.Address) return CE.bool
  with
    Import        => True,
    Convention    => C,
    External_Name => "SDL_SetAudioPostmixCallback";

   function Create_Audio_Stream
     (Source      : in System.Address;
      Destination : in System.Address) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CreateAudioStream";

   function Open_Audio_Device_Stream
     (Device    : in Device_ID;
      Spec      : in System.Address;
      Callback  : in Stream_Callback;
      User_Data : in System.Address) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_OpenAudioDeviceStream";

   function Bind_Audio_Streams
     (Device      : in Device_ID;
      Stream_List : in System.Address;
      Num_Streams : in C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_BindAudioStreams";

   function Bind_Audio_Stream
     (Device : in Device_ID;
      Stream : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_BindAudioStream";

   procedure Unbind_Audio_Streams
     (Stream_List : in System.Address;
      Num_Streams : in C.int)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_UnbindAudioStreams";

   procedure Unbind_Audio_Stream
     (Stream : in System.Address)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_UnbindAudioStream";

   function Get_Audio_Stream_Device
     (Stream : in System.Address) return Device_ID
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetAudioStreamDevice";

   function Get_Audio_Stream_Properties
     (Stream : in System.Address) return Property_ID
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetAudioStreamProperties";

   function Get_Audio_Stream_Format
     (Stream       : in System.Address;
      Source       : in System.Address;
      Destination  : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetAudioStreamFormat";

   function Set_Audio_Stream_Format
     (Stream       : in System.Address;
      Source       : in System.Address;
      Destination  : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetAudioStreamFormat";

   function Get_Audio_Stream_Frequency_Ratio
     (Stream : in System.Address) return C.C_float
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetAudioStreamFrequencyRatio";

   function Set_Audio_Stream_Frequency_Ratio
     (Stream : in System.Address;
      Ratio  : in C.C_float) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetAudioStreamFrequencyRatio";

   function Get_Audio_Stream_Gain
     (Stream : in System.Address) return C.C_float
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetAudioStreamGain";

   function Set_Audio_Stream_Gain
     (Stream : in System.Address;
      Gain   : in C.C_float) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetAudioStreamGain";

   function Get_Audio_Stream_Input_Channel_Map
     (Stream : in System.Address;
      Count  : access C.int) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetAudioStreamInputChannelMap";

   function Get_Audio_Stream_Output_Channel_Map
     (Stream : in System.Address;
      Count  : access C.int) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetAudioStreamOutputChannelMap";

   function Set_Audio_Stream_Input_Channel_Map
     (Stream : in System.Address;
      Map    : in System.Address;
      Count  : in C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetAudioStreamInputChannelMap";

   function Set_Audio_Stream_Output_Channel_Map
     (Stream : in System.Address;
      Map    : in System.Address;
      Count  : in C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetAudioStreamOutputChannelMap";

   function Put_Audio_Stream_Data
     (Stream      : in System.Address;
      Data        : in System.Address;
      Byte_Length : in C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_PutAudioStreamData";

   function Put_Audio_Stream_Data_No_Copy
     (Stream      : in System.Address;
      Data        : in System.Address;
      Byte_Length : in C.int;
      Callback    : in Data_Complete_Callback;
      User_Data   : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_PutAudioStreamDataNoCopy";

   function Put_Audio_Stream_Planar_Data
     (Stream           : in System.Address;
      Channel_Buffers  : in System.Address;
      Channel_Count    : in C.int;
      Samples_Per_Chan : in C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_PutAudioStreamPlanarData";

   function Get_Audio_Stream_Data
     (Stream      : in System.Address;
      Data        : in System.Address;
      Byte_Length : in C.int) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetAudioStreamData";

   function Get_Audio_Stream_Queued
     (Stream : in System.Address) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetAudioStreamQueued";

   function Get_Audio_Stream_Available
     (Stream : in System.Address) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetAudioStreamAvailable";

   function Clear_Audio_Stream
     (Stream : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ClearAudioStream";

   function Flush_Audio_Stream
     (Stream : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_FlushAudioStream";

   function Pause_Audio_Stream_Device
     (Stream : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_PauseAudioStreamDevice";

   function Resume_Audio_Stream_Device
     (Stream : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ResumeAudioStreamDevice";

   function Audio_Stream_Device_Paused
     (Stream : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_AudioStreamDevicePaused";

   function Lock_Audio_Stream
     (Stream : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_LockAudioStream";

   function Unlock_Audio_Stream
     (Stream : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_UnlockAudioStream";

   procedure Destroy_Audio_Stream
     (Stream : in System.Address)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_DestroyAudioStream";

   function Set_Audio_Stream_Get_Callback
     (Stream    : in System.Address;
      Callback  : in Stream_Callback;
      User_Data : in System.Address)
      return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetAudioStreamGetCallback";

   function Set_Audio_Stream_Put_Callback
     (Stream    : in System.Address;
      Callback  : in Stream_Callback;
      User_Data : in System.Address)
      return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetAudioStreamPutCallback";

   function Load_WAV_IO
     (Source      : in System.Address;
      Close_IO    : in CE.bool;
      Spec        : in System.Address;
      Audio_Data  : access System.Address;
      Audio_Size  : access Interfaces.Unsigned_32) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_LoadWAV_IO";

   function Load_WAV
     (Path       : in CS.chars_ptr;
      Spec       : in System.Address;
      Audio_Data : access System.Address;
      Audio_Size : access Interfaces.Unsigned_32) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_LoadWAV";

   function Mix_Audio
     (Destination : in System.Address;
      Source      : in System.Address;
      Format      : in Sample_Format;
      Byte_Length : in Interfaces.Unsigned_32;
      Volume      : in C.C_float) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_MixAudio";

   function Convert_Audio_Samples
     (Source_Spec      : in System.Address;
      Source_Data      : in System.Address;
      Source_Length    : in C.int;
      Destination_Spec : in System.Address;
      Destination_Data : access System.Address;
      Destination_Size : access C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ConvertAudioSamples";

   function Get_Silence_Value_For_Format
     (Format : in Sample_Format) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetSilenceValueForFormat";

   procedure Free (Value : in System.Address)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_free";
end SDL.Raw.Audio;
