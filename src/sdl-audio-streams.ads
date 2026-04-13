with Ada.Finalization;
with Ada.Streams;
with System;

with SDL.Properties;

package SDL.Audio.Streams is
   Audio_Stream_Error : exception;

   subtype Frequency_Ratio is Float range 0.01 .. 100.0;
   subtype Property_ID is SDL.Properties.Property_ID;
   Null_Property_ID : constant Property_ID := SDL.Properties.Null_Property_ID;

   Audio_Stream_Auto_Cleanup_Property : constant String :=
     "SDL.audiostream.auto_cleanup";

   subtype Stream_Handle is System.Address;

   type Stream_Callback is access procedure
     (User_Data         : in System.Address;
      Audio_Stream      : in Stream_Handle;
      Additional_Amount : in SDL.C.int;
      Total_Amount      : in SDL.C.int)
   with Convention => C;

   type Data_Complete_Callback is access procedure
     (User_Data   : in System.Address;
      Buffer      : in System.Address;
      Byte_Length : in SDL.C.int)
   with Convention => C;

   type Buffer_Pointers is array (Natural range <>) of System.Address;

   type Stream is new Ada.Finalization.Limited_Controlled with private;

   type Stream_Reference is access all Stream;
   pragma No_Strict_Aliasing (Stream_Reference);

   type Stream_References is array (Natural range <>) of Stream_Reference;

   function Create
     (Input  : in SDL.Audio.Spec;
      Output : in SDL.Audio.Spec) return Stream;

   function Create
     (Input : in SDL.Audio.Spec) return Stream;

   procedure Create
     (Self   : in out Stream;
      Input  : in SDL.Audio.Spec;
      Output : in SDL.Audio.Spec);

   procedure Create
     (Self  : in out Stream;
      Input : in SDL.Audio.Spec);

   procedure Open
     (Self          : in out Stream;
      Device        : in SDL.Audio.Device_ID := SDL.Audio.Default_Playback_Device;
      Application   : in SDL.Audio.Spec;
      Output        : out SDL.Audio.Spec;
      Sample_Frames : out Natural;
      Callback      : in Stream_Callback := null;
      User_Data     : in System.Address := System.Null_Address);

   procedure Open
     (Self          : in out Stream;
      Device        : in SDL.Audio.Device_ID := SDL.Audio.Default_Playback_Device;
      Output        : out SDL.Audio.Spec;
      Sample_Frames : out Natural;
      Callback      : in Stream_Callback := null;
      User_Data     : in System.Address := System.Null_Address);

   procedure Bind
     (Self   : in Stream;
      Device : in SDL.Audio.Device_ID);

   procedure Bind
     (Device  : in SDL.Audio.Device_ID;
      Streams : in Stream_References);

   procedure Unbind (Self : in Stream);
   procedure Unbind (Streams : in Stream_References);

   procedure Put
     (Self        : in Stream_Handle;
      Data        : in System.Address;
      Byte_Length : in Positive);

   procedure Put
     (Self        : in Stream;
      Data        : in System.Address;
      Byte_Length : in Positive);

   procedure Put_No_Copy
     (Self        : in Stream;
      Data        : in System.Address;
      Byte_Length : in Positive;
      Callback    : in Data_Complete_Callback := null;
      User_Data   : in System.Address := System.Null_Address);

   procedure Put_Planar
     (Self            : in Stream;
      Channel_Buffers : in Buffer_Pointers;
      Sample_Count    : in Positive);

   function Get
     (Self        : in Stream;
      Data        : in System.Address;
      Byte_Length : in Natural) return Natural;

   function Get
     (Self        : in Stream;
      Byte_Length : in Positive) return Ada.Streams.Stream_Element_Array;

   function Get_Frequency_Ratio (Self : in Stream) return Frequency_Ratio;

   procedure Set_Frequency_Ratio
     (Self  : in Stream;
      Ratio : in Frequency_Ratio);

   function Get_Gain (Self : in Stream) return Float;

   procedure Set_Gain
     (Self : in Stream;
      Gain : in Float);

   function Queued_Bytes (Self : in Stream) return Natural;
   function Available_Bytes (Self : in Stream) return Natural;

   procedure Get_Format
     (Self   : in Stream;
      Input  : out SDL.Audio.Spec;
      Output : out SDL.Audio.Spec);

   procedure Set_Format
     (Self   : in Stream;
      Input  : in SDL.Audio.Spec;
      Output : in SDL.Audio.Spec);

   procedure Set_Input_Format
     (Self  : in Stream;
      Input : in SDL.Audio.Spec);

   procedure Set_Output_Format
     (Self   : in Stream;
      Output : in SDL.Audio.Spec);

   function Get_Input_Channel_Map
     (Self : in Stream) return SDL.Audio.Channel_Map;

   function Get_Output_Channel_Map
     (Self : in Stream) return SDL.Audio.Channel_Map;

   procedure Set_Input_Channel_Map
     (Self : in Stream;
      Map  : in SDL.Audio.Channel_Map);

   procedure Clear_Input_Channel_Map (Self : in Stream);

   procedure Set_Output_Channel_Map
     (Self : in Stream;
      Map  : in SDL.Audio.Channel_Map);

   procedure Clear_Output_Channel_Map (Self : in Stream);

   function Get_Properties (Self : in Stream) return Property_ID;

   function Device (Self : in Stream) return SDL.Audio.Device_ID;
   function Device_Paused (Self : in Stream) return Boolean;

   procedure Pause (Self : in Stream);
   procedure Resume (Self : in Stream);

   procedure Lock (Self : in Stream);
   procedure Unlock (Self : in Stream);

   procedure Flush (Self : in Stream);
   procedure Clear (Self : in Stream);

   procedure Set_Get_Callback
     (Self      : in Stream;
      Callback  : in Stream_Callback;
      User_Data : in System.Address := System.Null_Address);

   procedure Set_Put_Callback
     (Self      : in Stream;
      Callback  : in Stream_Callback;
      User_Data : in System.Address := System.Null_Address);

   procedure Close (Self : in out Stream);

   function Get_Handle (Self : in Stream) return Stream_Handle with
     Inline;

   function Is_Open (Self : in Stream) return Boolean with
     Inline;

   overriding
   procedure Finalize (Self : in out Stream);
private
   type Stream is new Ada.Finalization.Limited_Controlled with record
      Internal : Stream_Handle := System.Null_Address;
   end record;
end SDL.Audio.Streams;
