with Interfaces;
with Interfaces.C;
with Interfaces.C.Extensions;
with Interfaces.C.Strings;
with System;

package SDL.Raw.Audio is
   pragma Preelaborate;

   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;
   package CS renames Interfaces.C.Strings;

   subtype Device_ID is Interfaces.Unsigned_32;
   subtype Sample_Format is Interfaces.Unsigned_32;

   type Postmix_Callback is access procedure
     (User_Data   : in System.Address;
      Spec        : in System.Address;
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
