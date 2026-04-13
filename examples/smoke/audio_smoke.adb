with Ada.Streams;
with Ada.Text_IO;
with Ada.Unchecked_Conversion;
with Interfaces;
with System;

with SDL.Audio;
with SDL.Audio.Devices;
with SDL.Audio.Sample_Formats;
with SDL.Audio.Streams;
with SDL.Properties;
with SDL.RWops;
with SDL.Timers;

procedure Audio_Smoke is
   use type Ada.Streams.Stream_Element;
   use type Ada.Streams.Stream_Element_Array;
   use type Interfaces.Integer_16;
   use type Interfaces.Unsigned_8;
   use type Interfaces.Unsigned_32;
   use type SDL.C.int;
   use type SDL.Audio.Device_ID;
   use type SDL.Audio.Sample_Format;
   use type SDL.Audio.Spec;

   subtype Sample is Interfaces.Integer_16;

   type Stereo_Frame is record
      Left  : Sample;
      Right : Sample;
   end record with
     Convention => C;

   type Frame_Array is array (Positive range <>) of aliased Stereo_Frame with
     Convention => C;

   type Mono_Samples is array (Positive range <>) of aliased Sample with
     Convention => C;

   package Stereo_Devices is new SDL.Audio.Devices
     (Frame_Type   => Stereo_Frame,
      Buffer_Index => Positive,
      Buffer_Type  => Frame_Array);

   type Callback_Count is mod 2 ** 32 with
     Atomic;

   use type Callback_Count;
   use type Stereo_Devices.Audio_Status;

   type Callback_State is new Stereo_Devices.User_Data with record
      Invocations : Callback_Count := 0;
   end record;

   type Stream_Callback_State is record
      Put_Invocations     : Callback_Count := 0;
      Get_Invocations     : Callback_Count := 0;
      No_Copy_Releases    : Callback_Count := 0;
      Postmix_Invocations : Callback_Count := 0;
   end record;

   type Stream_Callback_State_Access is access all Stream_Callback_State;
   pragma No_Strict_Aliasing (Stream_Callback_State_Access);

   function To_Stream_Callback_State is new Ada.Unchecked_Conversion
     (Source => System.Address,
      Target => Stream_Callback_State_Access);

   procedure Require (Condition : in Boolean; Message : in String);
   procedure Require (Condition : in Boolean; Message : in String) is
   begin
      if not Condition then
         raise Program_Error with Message;
      end if;
   end Require;

   function Approximately
     (Left      : in Float;
      Right     : in Float;
      Tolerance : in Float := 0.0001) return Boolean is
     (abs (Left - Right) <= Tolerance);

   function Has_Non_Zero
     (Data : in Ada.Streams.Stream_Element_Array) return Boolean
   is
   begin
      for Element of Data loop
         if Element /= 0 then
            return True;
         end if;
      end loop;

      return False;
   end Has_Non_Zero;

   function Matches_Map
     (Map      : in SDL.Audio.Channel_Map;
      Expected : in SDL.Audio.Channel_Map) return Boolean
   is
   begin
      if Map'Length /= Expected'Length then
         return False;
      end if;

      for Offset in 0 .. Map'Length - 1 loop
         if Map (Map'First + Offset) /= Expected (Expected'First + Offset) then
            return False;
         end if;
      end loop;

      return True;
   end Matches_Map;

   Tone_Frequency : constant Positive := 440;
   Tone_Frames    : constant Positive := 4_800;
   Half_Period    : constant Positive := 48_000 / (Tone_Frequency * 2);
   Amplitude      : constant Sample := 8_000;

   Requested_Spec : constant SDL.Audio.Spec :=
     (Format    => SDL.Audio.Sample_Formats.Sample_Format_S16,
      Channels  => 2,
      Frequency => 48_000);

   Tiny_WAV_Path : constant String := "/tmp/sdl3ada-audio-smoke.wav";

   Tiny_WAV : constant Ada.Streams.Stream_Element_Array :=
     (16#52#, 16#49#, 16#46#, 16#46#,
      16#28#, 16#00#, 16#00#, 16#00#,
      16#57#, 16#41#, 16#56#, 16#45#,
      16#66#, 16#6D#, 16#74#, 16#20#,
      16#10#, 16#00#, 16#00#, 16#00#,
      16#01#, 16#00#,
      16#01#, 16#00#,
      16#40#, 16#1F#, 16#00#, 16#00#,
      16#40#, 16#1F#, 16#00#, 16#00#,
      16#01#, 16#00#,
      16#08#, 16#00#,
      16#64#, 16#61#, 16#74#, 16#61#,
      16#04#, 16#00#, 16#00#, 16#00#,
      16#80#, 16#81#, 16#7F#, 16#80#);

   procedure Fill_Tone (Data : out Frame_Array);
   procedure Fill_Tone (Data : out Frame_Array) is
   begin
      for Index in Data'Range loop
         declare
            Value : constant Sample :=
              (if ((Index - 1) / Half_Period) mod 2 = 0
               then Amplitude
               else -Amplitude);
         begin
            Data (Index) := (Left => Value, Right => Value);
         end;
      end loop;
   end Fill_Tone;

   procedure Playback_Callback
     (User : in Stereo_Devices.User_Data_Access;
      Data : out Frame_Array);
   procedure Playback_Callback
     (User : in Stereo_Devices.User_Data_Access;
      Data : out Frame_Array)
   is
      State : Callback_State renames Callback_State (User.all);
   begin
      State.Invocations := State.Invocations + 1;
      Fill_Tone (Data);
   end Playback_Callback;

   procedure Stream_Put_Callback
     (User_Data         : in System.Address;
      Audio_Stream      : in SDL.Audio.Streams.Stream_Handle;
      Additional_Amount : in SDL.C.int;
      Total_Amount      : in SDL.C.int)
   with Convention => C;

   procedure Stream_Put_Callback
     (User_Data         : in System.Address;
      Audio_Stream      : in SDL.Audio.Streams.Stream_Handle;
      Additional_Amount : in SDL.C.int;
      Total_Amount      : in SDL.C.int)
   is
      pragma Unreferenced (Audio_Stream);
      pragma Unreferenced (Additional_Amount);
      pragma Unreferenced (Total_Amount);

      State : constant Stream_Callback_State_Access :=
        To_Stream_Callback_State (User_Data);
   begin
      if State /= null then
         State.Put_Invocations := State.Put_Invocations + 1;
      end if;
   end Stream_Put_Callback;

   procedure Stream_Get_Callback
     (User_Data         : in System.Address;
      Audio_Stream      : in SDL.Audio.Streams.Stream_Handle;
      Additional_Amount : in SDL.C.int;
      Total_Amount      : in SDL.C.int)
   with Convention => C;

   procedure Stream_Get_Callback
     (User_Data         : in System.Address;
      Audio_Stream      : in SDL.Audio.Streams.Stream_Handle;
      Additional_Amount : in SDL.C.int;
      Total_Amount      : in SDL.C.int)
   is
      pragma Unreferenced (Audio_Stream);
      pragma Unreferenced (Additional_Amount);
      pragma Unreferenced (Total_Amount);

      State : constant Stream_Callback_State_Access :=
        To_Stream_Callback_State (User_Data);
   begin
      if State /= null then
         State.Get_Invocations := State.Get_Invocations + 1;
      end if;
   end Stream_Get_Callback;

   procedure No_Copy_Callback
     (User_Data   : in System.Address;
      Buffer      : in System.Address;
      Byte_Length : in SDL.C.int)
   with Convention => C;

   procedure No_Copy_Callback
     (User_Data   : in System.Address;
      Buffer      : in System.Address;
      Byte_Length : in SDL.C.int)
   is
      pragma Unreferenced (Buffer);
      pragma Unreferenced (Byte_Length);

      State : constant Stream_Callback_State_Access :=
        To_Stream_Callback_State (User_Data);
   begin
      if State /= null then
         State.No_Copy_Releases := State.No_Copy_Releases + 1;
      end if;
   end No_Copy_Callback;

   procedure Postmix_Callback
     (User_Data   : in System.Address;
      Spec        : access constant SDL.Audio.Spec;
      Buffer      : in System.Address;
      Byte_Length : in SDL.C.int)
   with Convention => C;

   procedure Postmix_Callback
     (User_Data   : in System.Address;
      Spec        : access constant SDL.Audio.Spec;
      Buffer      : in System.Address;
      Byte_Length : in SDL.C.int)
   is
      State : constant Stream_Callback_State_Access :=
        To_Stream_Callback_State (User_Data);
   begin
      pragma Unreferenced (Buffer);
      pragma Unreferenced (Spec);
      pragma Unreferenced (Byte_Length);

      if State /= null then
         State.Postmix_Invocations := State.Postmix_Invocations + 1;
      end if;
   end Postmix_Callback;

   Stream              : SDL.Audio.Streams.Stream;
   Stream_Output       : SDL.Audio.Spec;
   Stream_Frames       : Natural;
   Frames              : aliased Frame_Array (1 .. Tone_Frames);
   Playback_Device     : Stereo_Devices.Device;
   Playback_Output     : Stereo_Devices.Obtained_Spec;
   Callback_Device     : Stereo_Devices.Device;
   Callback_Output     : Stereo_Devices.Obtained_Spec;
   Capture_Device      : Stereo_Devices.Device;
   Capture_Output      : Stereo_Devices.Obtained_Spec;
   Capture_Frames      : Frame_Array (1 .. 256);
   Captured            : Natural := 0;
   Callback_Data       : aliased Callback_State;
   Audio_Initialized   : Boolean := False;
begin
   Require (SDL.Audio.Initialise ("dummy"), "audio initialization failed");
   Audio_Initialized := True;

   declare
      Current_Driver     : constant String := SDL.Audio.Current_Driver_Name;
      Driver_Name_Value  : constant String := SDL.Audio.Driver_Name (1);
      Playback_IDs       : constant SDL.Audio.Device_IDs := SDL.Audio.Playback_Devices;
      Recording_IDs      : constant SDL.Audio.Device_IDs := SDL.Audio.Recording_Devices;
      Playback_Name      : constant String :=
        (if Playback_IDs'Length = 0
         then ""
         else SDL.Audio.Device_Name (Playback_IDs (Playback_IDs'First)));
      Capture_Name       : constant String :=
        (if Recording_IDs'Length = 0
         then ""
         else SDL.Audio.Device_Name (Recording_IDs (Recording_IDs'First)));
      Unbound_State      : aliased Stream_Callback_State;
      Device_State       : aliased Stream_Callback_State;
      Input_Remap        : constant SDL.Audio.Channel_Map := (1, 0);
      Output_Remap       : constant SDL.Audio.Channel_Map := (1, 0);
      Left_Channel       : aliased Mono_Samples (1 .. 4) := (100, 200, 300, 400);
      Right_Channel      : aliased Mono_Samples (1 .. 4) := (-100, -200, -300, -400);
      Direct_Playback_ID : constant SDL.Audio.Device_ID :=
        (if Playback_IDs'Length = 0
         then SDL.Audio.Default_Playback_Device
         else Playback_IDs (Playback_IDs'First));
      No_Copy_Data       : aliased Ada.Streams.Stream_Element_Array (1 .. 4) :=
        (16#11#, 16#22#, 16#33#, 16#44#);
   begin
      Require (Current_Driver = "dummy", "expected dummy audio driver");
      Require (Driver_Name_Value'Length > 0, "driver name lookup failed");
      Require
        (SDL.Audio.Format_Name (SDL.Audio.Sample_Formats.Sample_Format_S16)'Length > 0,
         "audio format naming failed");
      Require
        (SDL.Audio.Frame_Size (Requested_Spec) = Stereo_Frame'Size / System.Storage_Unit,
         "audio frame size helper disagrees with Stereo_Frame");
      Require
        (SDL.Audio.Silence_Value (SDL.Audio.Sample_Formats.Sample_Format_U8) = 16#80#,
         "unexpected silence value for unsigned 8-bit audio");
      Require
        (SDL.Audio.Silence_Value (SDL.Audio.Sample_Formats.Sample_Format_S16) = 0,
         "unexpected silence value for signed 16-bit audio");

      SDL.RWops.Save_File (Tiny_WAV_Path, Tiny_WAV);

      declare
         Loaded_Spec : SDL.Audio.Spec;
         Loaded_Data : constant Ada.Streams.Stream_Element_Array :=
           SDL.Audio.Load_WAV (Tiny_WAV_Path, Loaded_Spec);
      begin
         Require
           (Loaded_Spec.Format = SDL.Audio.Sample_Formats.Sample_Format_U8 and then
            Loaded_Spec.Channels = 1 and then
            Loaded_Spec.Frequency = 8_000,
            "path-based WAV load returned the wrong format");
         Require (Loaded_Data'Length = 4, "path-based WAV load returned the wrong size");

            declare
               Wave_Ops : constant SDL.RWops.RWops :=
                 SDL.RWops.From_File (Tiny_WAV_Path, SDL.RWops.Read_Binary);
               Loaded_IO_Spec : SDL.Audio.Spec;
               Loaded_IO_Data : constant Ada.Streams.Stream_Element_Array :=
              SDL.Audio.Load_WAV
                (Source      => Wave_Ops,
                 Spec        => Loaded_IO_Spec,
                 Close_After => True);
            Converted_Data : constant Ada.Streams.Stream_Element_Array :=
              SDL.Audio.Convert_Samples
                (Source_Spec      => Loaded_Spec,
                 Source_Data      => Loaded_Data,
                 Destination_Spec =>
                   (Format    => SDL.Audio.Sample_Formats.Sample_Format_S16,
                    Channels  => 1,
                    Frequency => 8_000));
            Converted_Address_Data : constant Ada.Streams.Stream_Element_Array :=
              SDL.Audio.Convert_Samples
                (Source_Spec      => Loaded_Spec,
                 Source_Data      => Loaded_Data'Address,
                 Source_Length    => Natural (Loaded_Data'Length),
                 Destination_Spec =>
                   (Format    => SDL.Audio.Sample_Formats.Sample_Format_S16,
                    Channels  => 1,
                    Frequency => 8_000));
               Mixed_Data : Ada.Streams.Stream_Element_Array (Converted_Data'Range) :=
                 (others => 0);
            begin
               Require (Loaded_IO_Spec = Loaded_Spec, "stream-based WAV load changed the format");
               Require (Loaded_IO_Data = Loaded_Data, "stream-based WAV load changed the data");
            Require
              (Converted_Data'Length = Loaded_Data'Length * 2,
               "audio sample conversion returned the wrong byte count");
            Require
              (Converted_Address_Data = Converted_Data,
               "audio sample conversion address overload disagrees with array overload");

            SDL.Audio.Mix
              (Destination => Mixed_Data,
               Source      => Converted_Data,
               Format      => SDL.Audio.Sample_Formats.Sample_Format_S16,
               Volume      => 0.5);
            Require (Has_Non_Zero (Mixed_Data), "audio mix helper produced only silence");
         end;
      end;

      declare
         Unbound_Stream : SDL.Audio.Streams.Stream;
         Input_Spec     : SDL.Audio.Spec;
         Output_Spec    : SDL.Audio.Spec;
      begin
            Unbound_Stream.Create (Requested_Spec, Requested_Spec);

         declare
            Props : constant SDL.Properties.Property_Set :=
              SDL.Properties.Reference (Unbound_Stream.Get_Properties);
         begin
            Require
              (Props.Get_Boolean
                 (SDL.Audio.Streams.Audio_Stream_Auto_Cleanup_Property,
                  True),
               "audio stream auto-cleanup property was not visible");
         end;

         Unbound_Stream.Get_Format (Input_Spec, Output_Spec);
         Require (Input_Spec = Requested_Spec, "audio stream input format was wrong after create");
         Require (Output_Spec = Requested_Spec, "audio stream output format was wrong after create");

            Unbound_Stream.Set_Output_Format
              ((Format    => SDL.Audio.Sample_Formats.Sample_Format_S16,
                Channels  => 2,
                Frequency => 24_000));
         Unbound_Stream.Get_Format (Input_Spec, Output_Spec);
         Require (Output_Spec.Frequency = 24_000, "audio stream output format update failed");

            Unbound_Stream.Set_Input_Format
              ((Format    => SDL.Audio.Sample_Formats.Sample_Format_S16,
                Channels  => 2,
                Frequency => 24_000));
         Unbound_Stream.Get_Format (Input_Spec, Output_Spec);
         Require (Input_Spec.Frequency = 24_000, "audio stream input format update failed");

            Unbound_Stream.Set_Format (Requested_Spec, Requested_Spec);
         Unbound_Stream.Get_Format (Input_Spec, Output_Spec);
         Require (Input_Spec = Requested_Spec, "audio stream full format reset failed on input");
         Require (Output_Spec = Requested_Spec, "audio stream full format reset failed on output");

         Unbound_Stream.Set_Frequency_Ratio (1.25);
         Require
           (Approximately (Unbound_Stream.Get_Frequency_Ratio, 1.25),
            "audio stream frequency-ratio control failed");

         Unbound_Stream.Set_Gain (0.5);
         Require
           (Approximately (Unbound_Stream.Get_Gain, 0.5),
            "audio stream gain control failed");

            Unbound_Stream.Set_Input_Channel_Map (Input_Remap);
            declare
               Current_Map : constant SDL.Audio.Channel_Map :=
                 Unbound_Stream.Get_Input_Channel_Map;
            begin
               Require
                 (Current_Map'Length = 0 or else Matches_Map (Current_Map, Input_Remap),
                  "audio stream input channel map returned unexpected values");
            end;
            Unbound_Stream.Clear_Input_Channel_Map;
         Require
           (Unbound_Stream.Get_Input_Channel_Map'Length = 0,
            "audio stream input channel map did not reset");

            Unbound_Stream.Set_Output_Channel_Map (Output_Remap);
            declare
               Current_Map : constant SDL.Audio.Channel_Map :=
                 Unbound_Stream.Get_Output_Channel_Map;
            begin
               Require
                 (Current_Map'Length = 0 or else Matches_Map (Current_Map, Output_Remap),
                  "audio stream output channel map returned unexpected values");
            end;
         Unbound_Stream.Clear_Output_Channel_Map;
         Require
           (Unbound_Stream.Get_Output_Channel_Map'Length = 0,
            "audio stream output channel map did not reset");

         Unbound_Stream.Lock;
         Unbound_Stream.Unlock;

         Unbound_Stream.Set_Put_Callback
           (Stream_Put_Callback'Unrestricted_Access, Unbound_State'Address);
         Unbound_Stream.Put_Planar
           (Channel_Buffers => (Left_Channel (1)'Address, Right_Channel (1)'Address),
            Sample_Count    => 4);
         Unbound_Stream.Flush;

         Require
           (Unbound_State.Put_Invocations > 0,
            "audio stream put callback was never invoked");
         Require
           (Unbound_Stream.Available_Bytes = 16,
            "audio stream planar put did not expose the expected converted bytes");

         declare
            Retrieved : constant Ada.Streams.Stream_Element_Array :=
              Unbound_Stream.Get (16);
         begin
            Require
              (Retrieved'Length = 16,
               "audio stream get helper returned the wrong number of bytes");
         end;

         Unbound_Stream.Set_Get_Callback
           (Stream_Get_Callback'Unrestricted_Access, Unbound_State'Address);

         declare
            Retrieved : constant Ada.Streams.Stream_Element_Array :=
              Unbound_Stream.Get (16);
         begin
            Require
              (Retrieved'Length = 0,
               "audio stream get callback test unexpectedly returned queued data");
         end;

         Require
           (Unbound_State.Get_Invocations > 0,
            "audio stream get callback was never invoked");

         Unbound_Stream.Put_No_Copy
           (Data        => No_Copy_Data'Address,
            Byte_Length => Positive (No_Copy_Data'Length),
            Callback    => No_Copy_Callback'Unrestricted_Access,
            User_Data   => Unbound_State'Address);
         Unbound_Stream.Clear;

         for Attempt in 1 .. 50 loop
            exit when Unbound_State.No_Copy_Releases > 0;
            SDL.Timers.Wait_Delay (1);
         end loop;

         Require
           (Unbound_State.No_Copy_Releases > 0,
            "audio stream no-copy completion callback was never invoked");

         Unbound_Stream.Close;
      end;

      declare
         Direct_Device : SDL.Audio.Device_ID :=
           SDL.Audio.Open_Device (Direct_Playback_ID, Requested_Spec);
         Direct_Output : SDL.Audio.Spec;
         Direct_Frames : Natural;
         Bound_A       : aliased SDL.Audio.Streams.Stream;
         Bound_B       : aliased SDL.Audio.Streams.Stream;
      begin
         begin
            Require
              (not SDL.Audio.Is_Device_Physical (Direct_Device),
               "opened audio device should be logical, not physical");
            Require
              (SDL.Audio.Is_Device_Playback (Direct_Device),
               "opened playback audio device did not report playback mode");
            Require
              (not SDL.Audio.Device_Paused (Direct_Device),
               "directly opened audio device should start unpaused");

            Direct_Output := SDL.Audio.Get_Device_Format (Direct_Device, Direct_Frames);
            declare
               Direct_Map : constant SDL.Audio.Channel_Map :=
                 SDL.Audio.Get_Device_Channel_Map (Direct_Device);
            begin
               Require
                 (Direct_Output.Channels > 0 and then Direct_Frames > 0,
                  "direct audio device format query returned invalid values");
               Require
                 (Direct_Map'Length = 0 or else Direct_Map'Length = Natural (Direct_Output.Channels),
                  "direct audio device channel map length did not match the device format");
            end;

            Require
              (SDL.Audio.Get_Device_Gain (Direct_Device) >= 0.0,
               "direct audio device gain query failed");
            SDL.Audio.Set_Device_Gain (Direct_Device, 0.5);

            SDL.Audio.Pause_Device (Direct_Device);
            Require
              (SDL.Audio.Device_Paused (Direct_Device),
               "direct audio device pause failed");
            SDL.Audio.Resume_Device (Direct_Device);
            Require
              (not SDL.Audio.Device_Paused (Direct_Device),
               "direct audio device resume failed");

            SDL.Audio.Set_Postmix_Callback
              (Direct_Device, Postmix_Callback'Unrestricted_Access, Device_State'Address);

            Bound_A.Create (Requested_Spec, Direct_Output);
            Bound_B.Create (Requested_Spec, Direct_Output);
            SDL.Audio.Streams.Bind
              (Direct_Device,
               (Bound_A'Unchecked_Access, Bound_B'Unchecked_Access));
            Require
              (Bound_A.Device = Direct_Device and then Bound_B.Device = Direct_Device,
               "multi-bind did not associate both audio streams with the device");

            Fill_Tone (Frames);
            Bound_A.Put
              (Data        => Frames (Frames'First)'Address,
               Byte_Length => Positive (Frames'Size / System.Storage_Unit));
            Bound_B.Put
              (Data        => Frames (Frames'First)'Address,
               Byte_Length => Positive (Frames'Size / System.Storage_Unit));

            for Attempt in 1 .. 500 loop
               exit when Device_State.Postmix_Invocations > 0 and then
                 Bound_A.Queued_Bytes = 0 and then
                 Bound_B.Queued_Bytes = 0;
               SDL.Timers.Wait_Delay (1);
            end loop;

            Require
              (Device_State.Postmix_Invocations > 0,
               "audio device postmix callback was never invoked");

            SDL.Audio.Streams.Unbind
              ((Bound_A'Unchecked_Access, Bound_B'Unchecked_Access));

            Bound_A.Bind (Direct_Device);
            Require (Bound_A.Device = Direct_Device, "single audio stream bind failed");
            Bound_A.Unbind;
            Require (Bound_A.Device = 0, "single audio stream unbind failed");

            Bound_A.Close;
            Bound_B.Close;
         exception
            when others =>
               Bound_A.Close;
               Bound_B.Close;
               SDL.Audio.Close_Device (Direct_Device);
               raise;
         end;

         SDL.Audio.Close_Device (Direct_Device);
      end;

      Fill_Tone (Frames);

      Stream.Open
        (Application   => Requested_Spec,
         Output        => Stream_Output,
         Sample_Frames => Stream_Frames);
      Require (Stream.Device_Paused, "opened device stream should start paused");
      Stream.Resume;
      Stream.Put
        (Data        => Frames (Frames'First)'Address,
         Byte_Length => Positive (Frames'Size / System.Storage_Unit));

      while Stream.Queued_Bytes > 0 loop
         SDL.Timers.Wait_Delay (1);
      end loop;

      Stream.Close;

      Playback_Device.Open
        (Name       => Playback_Name,
         Desired    =>
           (Mode      => Stereo_Devices.Desired,
            Frequency => 48_000,
            Format    => SDL.Audio.Sample_Formats.Sample_Format_S16,
            Channels  => 2,
            Samples   => 256),
         Obtained   => Playback_Output);

      Require (Playback_Device.Get_Status = Stereo_Devices.Paused, "playback device should open paused");
      Stereo_Devices.Queue (Playback_Device, Frames);
      Require (Playback_Device.Get_Queued_Size > 0, "queued playback data was not visible");
      Playback_Device.Pause (Pause => False);

      while Playback_Device.Get_Queued_Size > 0 loop
         SDL.Timers.Wait_Delay (1);
      end loop;

      Require (Playback_Device.Get_Status = Stereo_Devices.Stopped, "playback device did not drain");
      Playback_Device.Close;

      Callback_Device.Open
        (Name       => Playback_Name,
         Desired    =>
           (Mode      => Stereo_Devices.Desired,
            Frequency => 48_000,
            Format    => SDL.Audio.Sample_Formats.Sample_Format_S16,
            Channels  => 2,
            Samples   => 256),
         Obtained   => Callback_Output,
         Callback   => Playback_Callback'Access,
         User_Data  => Callback_Data'Access);

      Require (Callback_Device.Uses_Callback, "callback device did not record callback usage");
      Callback_Device.Pause (Pause => False);

      for Attempt in 1 .. 200 loop
         exit when Callback_Data.Invocations > 0;
         SDL.Timers.Wait_Delay (1);
      end loop;

      Require (Callback_Data.Invocations > 0, "playback callback was never invoked");
      Callback_Device.Pause (Pause => True);
      Callback_Device.Close;

      Capture_Device.Open
        (Name       => Capture_Name,
         Is_Capture => True,
         Desired    =>
           (Mode      => Stereo_Devices.Desired,
            Frequency => 48_000,
            Format    => SDL.Audio.Sample_Formats.Sample_Format_S16,
            Channels  => 2,
            Samples   => 256),
         Obtained   => Capture_Output);

      Require (Capture_Device.Is_Capture, "capture device did not retain capture mode");
      Require (Capture_Device.Get_Status = Stereo_Devices.Paused, "capture device should open paused");
      Capture_Device.Pause (Pause => False);

      for Attempt in 1 .. 200 loop
         exit when Capture_Device.Get_Available_Size > 0;
         SDL.Timers.Wait_Delay (1);
      end loop;

      Require (Capture_Device.Get_Available_Size > 0, "capture device produced no data");
      Capture_Device.Dequeue (Capture_Frames, Captured);
      Require (Captured > 0, "capture dequeue returned no frames");
      Capture_Device.Close;

      Ada.Text_IO.Put_Line
        ("audio_smoke driver=" & Current_Driver &
         " playback=" & (if Playback_Name = "" then "<default>" else Playback_Name) &
         " capture=" & (if Capture_Name = "" then "<default>" else Capture_Name) &
         " stream_freq=" & Integer (Stream_Output.Frequency)'Img &
         " stream_channels=" & Integer (Stream_Output.Channels)'Img &
         " postmix_invocations=" & Integer (Device_State.Postmix_Invocations)'Img &
         " put_callback_invocations=" & Integer (Unbound_State.Put_Invocations)'Img &
         " get_callback_invocations=" & Integer (Unbound_State.Get_Invocations)'Img &
         " no_copy_releases=" & Integer (Unbound_State.No_Copy_Releases)'Img &
         " callback_invocations=" & Integer (Callback_Data.Invocations)'Img &
         " captured_frames=" & Integer (Captured)'Img);
   end;

   SDL.Audio.Finalise;
exception
   when others =>
      if Audio_Initialized then
         SDL.Audio.Finalise;
      end if;

      raise;
end Audio_Smoke;
