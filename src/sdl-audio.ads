with Ada.Streams;
with Interfaces;
with System;

with SDL.RWops;

package SDL.Audio is
   pragma Preelaborate;

   Audio_Error : exception;

   type Device_ID is mod 2 ** 32 with
     Convention => C;

   type Device_IDs is array (Natural range <>) of Device_ID;

   Default_Playback_Device  : constant Device_ID := 16#FFFF_FFFF#;
   Default_Recording_Device : constant Device_ID := 16#FFFF_FFFE#;

   --  SDL_AudioFormat is declared as a C enum, so keep the Ada ABI 32-bit
   --  even though the meaningful flag bits currently fit in 16 bits.
   type Sample_Format is mod 2 ** 32 with
     Convention => C;

   subtype Channel_Count is SDL.C.int range 1 .. SDL.C.int'Last;
   subtype Sample_Rate is SDL.C.int range 1 .. SDL.C.int'Last;

   type Spec is record
      Format    : Sample_Format;
      Channels  : Channel_Count;
      Frequency : Sample_Rate;
   end record with
     Convention => C;

   type Channel_Map is array (Natural range <>) of SDL.C.int;

   type Postmix_Callback is access procedure
     (User_Data   : in System.Address;
      Spec        : access constant SDL.Audio.Spec;
      Buffer      : in System.Address;
      Byte_Length : in SDL.C.int)
   with Convention => C;

   function Initialise (Name : in String := "") return Boolean;

   procedure Finalise;

   function Total_Drivers return Positive;

   function Driver_Name (Index : in Positive) return String;

   function Current_Driver_Name return String;

   function Playback_Devices return Device_IDs;
   function Recording_Devices return Device_IDs;

   function Device_Name (Device : in Device_ID) return String;

   function Open_Device
     (Device    : in Device_ID;
      Requested : in Spec) return Device_ID;

   function Open_Device
     (Device : in Device_ID := Default_Playback_Device) return Device_ID;

   procedure Close_Device (Device : in Device_ID);
   procedure Pause_Device (Device : in Device_ID);
   procedure Resume_Device (Device : in Device_ID);

   function Device_Paused (Device : in Device_ID) return Boolean;

   function Get_Device_Format
     (Device        : in Device_ID;
      Sample_Frames : out Natural) return Spec;

   function Get_Device_Channel_Map (Device : in Device_ID) return Channel_Map;

   function Is_Device_Physical (Device : in Device_ID) return Boolean;
   function Is_Device_Playback (Device : in Device_ID) return Boolean;

   function Get_Device_Gain (Device : in Device_ID) return Float;

   procedure Set_Device_Gain
     (Device : in Device_ID;
      Gain   : in Float);

   procedure Set_Postmix_Callback
     (Device    : in Device_ID;
      Callback  : in Postmix_Callback;
      User_Data : in System.Address := System.Null_Address);

   function Format_Name (Format : in Sample_Format) return String;

   function Silence_Value
     (Format : in Sample_Format) return Interfaces.Unsigned_8;

   function Frame_Size
     (Format   : in Sample_Format;
      Channels : in Channel_Count)
      return Natural;

   function Frame_Size (Value : in Spec) return Natural;

   function Load_WAV
     (Source      : in SDL.RWops.RWops;
      Spec        : out SDL.Audio.Spec;
      Close_After : in Boolean := False)
      return Ada.Streams.Stream_Element_Array;

   function Load_WAV
     (Path : in String;
      Spec : out SDL.Audio.Spec)
      return Ada.Streams.Stream_Element_Array;

   procedure Mix
     (Destination : in System.Address;
      Source      : in System.Address;
      Format      : in Sample_Format;
      Byte_Length : in Interfaces.Unsigned_32;
      Volume      : in Float := 1.0);

   procedure Mix
     (Destination : in out Ada.Streams.Stream_Element_Array;
      Source      : in Ada.Streams.Stream_Element_Array;
      Format      : in Sample_Format;
      Volume      : in Float := 1.0);

   function Convert_Samples
     (Source_Spec      : in Spec;
      Source_Data      : in System.Address;
      Source_Length    : in Natural;
      Destination_Spec : in Spec)
      return Ada.Streams.Stream_Element_Array;

   function Convert_Samples
     (Source_Spec      : in Spec;
      Source_Data      : in Ada.Streams.Stream_Element_Array;
      Destination_Spec : in Spec)
      return Ada.Streams.Stream_Element_Array;
end SDL.Audio;
