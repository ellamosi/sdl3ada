with Ada.Streams;

with Interfaces.C;
with Interfaces.C.Extensions;

with SDL.Error;

package body SDL.Audio.Streams is
   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;

   use type C.C_float;
   use type C.int;
   use type C.ptrdiff_t;
   use type Ada.Streams.Stream_Element_Offset;
   use type Property_ID;
   use type Stream_Handle;

   Empty_Bytes : constant Ada.Streams.Stream_Element_Array (1 .. 0) :=
     [others => 0];

   Empty_Channel_Map : constant SDL.Audio.Channel_Map (1 .. 0) :=
     [others => 0];

   type Stream_Handle_Array is array (C.ptrdiff_t range <>) of aliased Stream_Handle with
     Convention => C;

   type Channel_Map_Array is array (C.ptrdiff_t range <>) of aliased SDL.C.int with
     Convention => C;

   function SDL_Create_Audio_Stream
     (Source      : access constant SDL.Audio.Spec;
      Destination : access constant SDL.Audio.Spec) return Stream_Handle
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CreateAudioStream";

   function SDL_Open_Audio_Device_Stream
     (Device    : in SDL.Audio.Device_ID;
      Spec      : access constant SDL.Audio.Spec;
      Callback  : in Stream_Callback;
      User_Data : in System.Address) return Stream_Handle
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_OpenAudioDeviceStream";

   function SDL_Bind_Audio_Streams
     (Device      : in SDL.Audio.Device_ID;
      Stream_List : in System.Address;
      Num_Streams : in C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_BindAudioStreams";

   function SDL_Bind_Audio_Stream
     (Device       : in SDL.Audio.Device_ID;
      Audio_Stream : in Stream_Handle) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_BindAudioStream";

   procedure SDL_Unbind_Audio_Streams
     (Stream_List : in System.Address;
      Num_Streams : in C.int)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_UnbindAudioStreams";

   procedure SDL_Unbind_Audio_Stream
     (Audio_Stream : in Stream_Handle)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_UnbindAudioStream";

   function SDL_Get_Audio_Stream_Device
     (Audio_Stream : in Stream_Handle) return SDL.Audio.Device_ID
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetAudioStreamDevice";

   function SDL_Get_Audio_Stream_Properties
     (Audio_Stream : in Stream_Handle) return Property_ID
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetAudioStreamProperties";

   function SDL_Get_Audio_Stream_Format
     (Audio_Stream : in Stream_Handle;
      Source       : access SDL.Audio.Spec;
      Destination  : access SDL.Audio.Spec) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetAudioStreamFormat";

   function SDL_Set_Audio_Stream_Format
     (Audio_Stream : in Stream_Handle;
      Source       : access constant SDL.Audio.Spec;
      Destination  : access constant SDL.Audio.Spec) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetAudioStreamFormat";

   function SDL_Get_Audio_Stream_Frequency_Ratio
     (Audio_Stream : in Stream_Handle) return C.C_float
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetAudioStreamFrequencyRatio";

   function SDL_Set_Audio_Stream_Frequency_Ratio
     (Audio_Stream : in Stream_Handle;
      Ratio        : in C.C_float) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetAudioStreamFrequencyRatio";

   function SDL_Get_Audio_Stream_Gain
     (Audio_Stream : in Stream_Handle) return C.C_float
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetAudioStreamGain";

   function SDL_Set_Audio_Stream_Gain
     (Audio_Stream : in Stream_Handle;
      Gain         : in C.C_float) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetAudioStreamGain";

   function SDL_Get_Audio_Stream_Input_Channel_Map
     (Audio_Stream : in Stream_Handle;
      Count        : access C.int) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetAudioStreamInputChannelMap";

   function SDL_Get_Audio_Stream_Output_Channel_Map
     (Audio_Stream : in Stream_Handle;
      Count        : access C.int) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetAudioStreamOutputChannelMap";

   function SDL_Set_Audio_Stream_Input_Channel_Map
     (Audio_Stream : in Stream_Handle;
      Map          : access constant SDL.C.int;
      Count        : in C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetAudioStreamInputChannelMap";

   function SDL_Set_Audio_Stream_Output_Channel_Map
     (Audio_Stream : in Stream_Handle;
      Map          : access constant SDL.C.int;
      Count        : in C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetAudioStreamOutputChannelMap";

   function SDL_Put_Audio_Stream_Data
     (Audio_Stream : in Stream_Handle;
      Data         : in System.Address;
      Byte_Length  : in C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_PutAudioStreamData";

   function SDL_Put_Audio_Stream_Data_No_Copy
     (Audio_Stream : in Stream_Handle;
      Data         : in System.Address;
      Byte_Length  : in C.int;
      Callback     : in Data_Complete_Callback;
      User_Data    : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_PutAudioStreamDataNoCopy";

   function SDL_Put_Audio_Stream_Planar_Data
     (Audio_Stream     : in Stream_Handle;
      Channel_Buffers  : in System.Address;
      Channel_Count    : in C.int;
      Samples_Per_Chan : in C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_PutAudioStreamPlanarData";

   function SDL_Get_Audio_Stream_Data
     (Audio_Stream : in Stream_Handle;
      Data         : in System.Address;
      Byte_Length  : in C.int) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetAudioStreamData";

   function SDL_Get_Audio_Stream_Available
     (Audio_Stream : in Stream_Handle) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetAudioStreamAvailable";

   function SDL_Get_Audio_Stream_Queued
     (Audio_Stream : in Stream_Handle) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetAudioStreamQueued";

   function SDL_Flush_Audio_Stream
     (Audio_Stream : in Stream_Handle) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_FlushAudioStream";

   function SDL_Clear_Audio_Stream
     (Audio_Stream : in Stream_Handle) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ClearAudioStream";

   function SDL_Pause_Audio_Stream_Device
     (Audio_Stream : in Stream_Handle) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_PauseAudioStreamDevice";

   function SDL_Resume_Audio_Stream_Device
     (Audio_Stream : in Stream_Handle) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ResumeAudioStreamDevice";

   function SDL_Audio_Stream_Device_Paused
     (Audio_Stream : in Stream_Handle) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_AudioStreamDevicePaused";

   function SDL_Lock_Audio_Stream
     (Audio_Stream : in Stream_Handle) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_LockAudioStream";

   function SDL_Unlock_Audio_Stream
     (Audio_Stream : in Stream_Handle) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_UnlockAudioStream";

   function SDL_Set_Audio_Stream_Get_Callback
     (Audio_Stream : in Stream_Handle;
      Callback     : in Stream_Callback;
      User_Data    : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetAudioStreamGetCallback";

   function SDL_Set_Audio_Stream_Put_Callback
     (Audio_Stream : in Stream_Handle;
      Callback     : in Stream_Callback;
      User_Data    : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetAudioStreamPutCallback";

   procedure SDL_Destroy_Audio_Stream
     (Audio_Stream : in Stream_Handle)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_DestroyAudioStream";

   procedure SDL_Free (Value : in System.Address) with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_free";

   procedure Raise_Last_Error
     (Default_Message : in String := "SDL audio stream call failed");

   procedure Require_Open (Self : in Stream);

   function Copy_Channel_Map
     (Items : in System.Address;
      Count : in C.int) return SDL.Audio.Channel_Map;

   procedure Raise_Last_Error
     (Default_Message : in String := "SDL audio stream call failed")
   is
      Message : constant String := SDL.Error.Get;
   begin
      if Message = "" then
         raise Audio_Stream_Error with Default_Message;
      end if;

      raise Audio_Stream_Error with Message;
   end Raise_Last_Error;

   procedure Require_Open (Self : in Stream) is
   begin
      if not Self.Is_Open then
         raise Audio_Stream_Error with "Invalid audio stream";
      end if;
   end Require_Open;

   function Copy_Channel_Map
     (Items : in System.Address;
      Count : in C.int) return SDL.Audio.Channel_Map
   is
   begin
      if Items = System.Null_Address then
         declare
            Message : constant String := SDL.Error.Get;
         begin
            if Message /= "" then
               raise Audio_Stream_Error with Message;
            end if;
         end;

         return Empty_Channel_Map;
      end if;

      if Count <= 0 then
         SDL_Free (Items);
         return Empty_Channel_Map;
      end if;

      declare
         Raw_Map : Channel_Map_Array (0 .. C.ptrdiff_t (Count - 1));
         for Raw_Map'Address use Items;
         pragma Import (Ada, Raw_Map);

         Result : SDL.Audio.Channel_Map (1 .. Natural (Count));
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

   function Get_Handle (Self : in Stream) return Stream_Handle is
     (Self.Internal);

   function Is_Open (Self : in Stream) return Boolean is
     (Self.Internal /= System.Null_Address);

   function Create
     (Input  : in SDL.Audio.Spec;
      Output : in SDL.Audio.Spec) return Stream
   is
   begin
      return Result : Stream do
         Create (Result, Input, Output);
      end return;
   end Create;

   function Create
     (Input : in SDL.Audio.Spec) return Stream
   is
   begin
      return Result : Stream do
         Create (Result, Input);
      end return;
   end Create;

   procedure Create
     (Self   : in out Stream;
      Input  : in SDL.Audio.Spec;
      Output : in SDL.Audio.Spec)
   is
      Source_Spec      : aliased constant SDL.Audio.Spec := Input;
      Destination_Spec : aliased constant SDL.Audio.Spec := Output;
   begin
      Close (Self);

      Self.Internal :=
        SDL_Create_Audio_Stream
          (Source_Spec'Access,
           Destination_Spec'Access);

      if Self.Internal = System.Null_Address then
         Raise_Last_Error ("Audio stream creation failed");
      end if;
   end Create;

   procedure Create
     (Self  : in out Stream;
      Input : in SDL.Audio.Spec)
   is
      Source_Spec : aliased constant SDL.Audio.Spec := Input;
   begin
      Close (Self);

      Self.Internal := SDL_Create_Audio_Stream (Source_Spec'Access, null);

      if Self.Internal = System.Null_Address then
         Raise_Last_Error ("Audio stream creation failed");
      end if;
   end Create;

   function Device (Self : in Stream) return SDL.Audio.Device_ID is
   begin
      Require_Open (Self);
      return SDL_Get_Audio_Stream_Device (Self.Internal);
   end Device;

   procedure Open
     (Self          : in out Stream;
      Device        : in SDL.Audio.Device_ID := SDL.Audio.Default_Playback_Device;
      Application   : in SDL.Audio.Spec;
      Output        : out SDL.Audio.Spec;
      Sample_Frames : out Natural;
      Callback      : in Stream_Callback := null;
      User_Data     : in System.Address := System.Null_Address)
   is
      Application_Spec : aliased constant SDL.Audio.Spec := Application;
   begin
      Close (Self);

      Self.Internal :=
        SDL_Open_Audio_Device_Stream
          (Device    => Device,
           Spec      => Application_Spec'Access,
           Callback  => Callback,
           User_Data => User_Data);

      if Self.Internal = System.Null_Address then
         Raise_Last_Error ("Audio device stream open failed");
      end if;

      begin
         Output := SDL.Audio.Get_Device_Format (Self.Device, Sample_Frames);
      exception
         when others =>
            Close (Self);
            raise;
      end;
   end Open;

   procedure Open
     (Self          : in out Stream;
      Device        : in SDL.Audio.Device_ID := SDL.Audio.Default_Playback_Device;
      Output        : out SDL.Audio.Spec;
      Sample_Frames : out Natural;
      Callback      : in Stream_Callback := null;
      User_Data     : in System.Address := System.Null_Address)
   is
   begin
      Close (Self);

      Self.Internal :=
        SDL_Open_Audio_Device_Stream
          (Device    => Device,
           Spec      => null,
           Callback  => Callback,
           User_Data => User_Data);

      if Self.Internal = System.Null_Address then
         Raise_Last_Error ("Audio device stream open failed");
      end if;

      begin
         Output := SDL.Audio.Get_Device_Format (Self.Device, Sample_Frames);
      exception
         when others =>
            Close (Self);
            raise;
      end;
   end Open;

   procedure Bind
     (Self   : in Stream;
      Device : in SDL.Audio.Device_ID)
   is
   begin
      Require_Open (Self);

      if not Boolean (SDL_Bind_Audio_Stream (Device, Self.Internal)) then
         Raise_Last_Error ("Audio stream bind failed");
      end if;
   end Bind;

   procedure Bind
     (Device  : in SDL.Audio.Device_ID;
      Streams : in Stream_References)
   is
   begin
      if Streams'Length = 0 then
         return;
      end if;

      declare
         Handles : Stream_Handle_Array (0 .. C.ptrdiff_t (Streams'Length - 1));
      begin
         for Offset in 0 .. C.ptrdiff_t (Streams'Length - 1) loop
            declare
               Ref : constant Stream_Reference :=
                 Streams (Streams'First + Natural (Offset));
            begin
               if Ref = null then
                  Handles (Offset) := System.Null_Address;
               else
                  Require_Open (Ref.all);
                  Handles (Offset) := Ref.Internal;
               end if;
            end;
         end loop;

         if not Boolean
             (SDL_Bind_Audio_Streams
                (Device      => Device,
                 Stream_List => Handles (Handles'First)'Address,
                 Num_Streams => C.int (Streams'Length)))
         then
            Raise_Last_Error ("Audio stream multi-bind failed");
         end if;
      end;
   end Bind;

   procedure Unbind (Self : in Stream) is
   begin
      Require_Open (Self);
      SDL_Unbind_Audio_Stream (Self.Internal);
   end Unbind;

   procedure Unbind (Streams : in Stream_References) is
   begin
      if Streams'Length = 0 then
         return;
      end if;

      declare
         Handles : Stream_Handle_Array (0 .. C.ptrdiff_t (Streams'Length - 1));
      begin
         for Offset in 0 .. C.ptrdiff_t (Streams'Length - 1) loop
            declare
               Ref : constant Stream_Reference :=
                 Streams (Streams'First + Natural (Offset));
            begin
               if Ref = null then
                  Handles (Offset) := System.Null_Address;
               else
                  Handles (Offset) := Ref.Internal;
               end if;
            end;
         end loop;

         SDL_Unbind_Audio_Streams
           (Stream_List => Handles (Handles'First)'Address,
            Num_Streams => C.int (Streams'Length));
      end;
   end Unbind;

   procedure Put
     (Self        : in Stream_Handle;
      Data        : in System.Address;
      Byte_Length : in Positive)
   is
   begin
      if Self = System.Null_Address then
         raise Audio_Stream_Error with "Invalid audio stream";
      end if;

      if not Boolean
          (SDL_Put_Audio_Stream_Data
             (Audio_Stream => Self,
              Data         => Data,
              Byte_Length  => C.int (Byte_Length)))
      then
         Raise_Last_Error ("Audio stream put failed");
      end if;
   end Put;

   procedure Put
     (Self        : in Stream;
      Data        : in System.Address;
      Byte_Length : in Positive)
   is
   begin
      Require_Open (Self);
      Put (Self.Internal, Data, Byte_Length);
   end Put;

   procedure Put_No_Copy
     (Self        : in Stream;
      Data        : in System.Address;
      Byte_Length : in Positive;
      Callback    : in Data_Complete_Callback := null;
      User_Data   : in System.Address := System.Null_Address)
   is
   begin
      Require_Open (Self);

      if not Boolean
          (SDL_Put_Audio_Stream_Data_No_Copy
             (Audio_Stream => Self.Internal,
              Data         => Data,
              Byte_Length  => C.int (Byte_Length),
              Callback     => Callback,
              User_Data    => User_Data))
      then
         Raise_Last_Error ("Audio stream no-copy put failed");
      end if;
   end Put_No_Copy;

   procedure Put_Planar
     (Self            : in Stream;
      Channel_Buffers : in Buffer_Pointers;
      Sample_Count    : in Positive)
   is
   begin
      Require_Open (Self);

      if Channel_Buffers'Length = 0 then
         raise Audio_Stream_Error with "Planar audio input requires at least one channel buffer";
      end if;

      declare
         Raw_Buffers : Stream_Handle_Array (0 .. C.ptrdiff_t (Channel_Buffers'Length - 1));
      begin
         for Offset in 0 .. C.ptrdiff_t (Channel_Buffers'Length - 1) loop
            Raw_Buffers (Offset) :=
              Channel_Buffers (Channel_Buffers'First + Natural (Offset));
         end loop;

         if not Boolean
             (SDL_Put_Audio_Stream_Planar_Data
                (Audio_Stream     => Self.Internal,
                 Channel_Buffers  => Raw_Buffers (Raw_Buffers'First)'Address,
                 Channel_Count    => C.int (Channel_Buffers'Length),
                 Samples_Per_Chan => C.int (Sample_Count)))
         then
            Raise_Last_Error ("Planar audio stream put failed");
         end if;
      end;
   end Put_Planar;

   function Get
     (Self        : in Stream;
      Data        : in System.Address;
      Byte_Length : in Natural) return Natural
   is
      Read_Count : C.int;
   begin
      Require_Open (Self);

      if Byte_Length = 0 then
         return 0;
      end if;

      Read_Count :=
        SDL_Get_Audio_Stream_Data
          (Audio_Stream => Self.Internal,
           Data         => Data,
           Byte_Length  => C.int (Byte_Length));

      if Read_Count < 0 then
         Raise_Last_Error ("Audio stream get failed");
      end if;

      return Natural (Read_Count);
   end Get;

   function Get
     (Self        : in Stream;
      Byte_Length : in Positive) return Ada.Streams.Stream_Element_Array
   is
      Buffer    : Ada.Streams.Stream_Element_Array
        (1 .. Ada.Streams.Stream_Element_Offset (Byte_Length));
      Retrieved : constant Natural := Get (Self, Buffer'Address, Byte_Length);
   begin
      if Retrieved = 0 then
         return Empty_Bytes;
      end if;

      return Buffer (Buffer'First .. Buffer'First + Ada.Streams.Stream_Element_Offset (Retrieved) - 1);
   end Get;

   function Get_Frequency_Ratio (Self : in Stream) return Frequency_Ratio is
      Ratio : constant C.C_float := SDL_Get_Audio_Stream_Frequency_Ratio (Self.Internal);
   begin
      Require_Open (Self);

      if Ratio = 0.0 then
         Raise_Last_Error ("Audio stream frequency-ratio query failed");
      end if;

      return Frequency_Ratio (Float (Ratio));
   end Get_Frequency_Ratio;

   procedure Set_Frequency_Ratio
     (Self  : in Stream;
      Ratio : in Frequency_Ratio)
   is
   begin
      Require_Open (Self);

      if not Boolean
          (SDL_Set_Audio_Stream_Frequency_Ratio
             (Audio_Stream => Self.Internal,
              Ratio        => C.C_float (Ratio)))
      then
         Raise_Last_Error ("Audio stream frequency-ratio update failed");
      end if;
   end Set_Frequency_Ratio;

   function Get_Gain (Self : in Stream) return Float is
      Gain : constant C.C_float := SDL_Get_Audio_Stream_Gain (Self.Internal);
   begin
      Require_Open (Self);

      if Gain < 0.0 and then SDL.Error.Get /= "" then
         Raise_Last_Error ("Audio stream gain query failed");
      end if;

      return Float (Gain);
   end Get_Gain;

   procedure Set_Gain
     (Self : in Stream;
      Gain : in Float)
   is
   begin
      Require_Open (Self);

      if not Boolean
          (SDL_Set_Audio_Stream_Gain
             (Audio_Stream => Self.Internal,
              Gain         => C.C_float (Gain)))
      then
         Raise_Last_Error ("Audio stream gain update failed");
      end if;
   end Set_Gain;

   function Queued_Bytes (Self : in Stream) return Natural is
      Queued : C.int;
   begin
      Require_Open (Self);

      Queued := SDL_Get_Audio_Stream_Queued (Self.Internal);

      if Queued < 0 then
         Raise_Last_Error ("Audio stream queued-byte query failed");
      end if;

      return Natural (Queued);
   end Queued_Bytes;

   function Available_Bytes (Self : in Stream) return Natural is
      Available : C.int;
   begin
      Require_Open (Self);

      Available := SDL_Get_Audio_Stream_Available (Self.Internal);

      if Available < 0 then
         Raise_Last_Error ("Audio stream available-byte query failed");
      end if;

      return Natural (Available);
   end Available_Bytes;

   procedure Get_Format
     (Self   : in Stream;
      Input  : out SDL.Audio.Spec;
      Output : out SDL.Audio.Spec)
   is
      Input_Spec  : aliased SDL.Audio.Spec;
      Output_Spec : aliased SDL.Audio.Spec;
   begin
      Require_Open (Self);

      if not Boolean
          (SDL_Get_Audio_Stream_Format
             (Audio_Stream => Self.Internal,
              Source       => Input_Spec'Access,
              Destination  => Output_Spec'Access))
      then
         Raise_Last_Error ("Audio stream format query failed");
      end if;

      Input := Input_Spec;
      Output := Output_Spec;
   end Get_Format;

   procedure Set_Format
     (Self   : in Stream;
      Input  : in SDL.Audio.Spec;
      Output : in SDL.Audio.Spec)
   is
      Input_Spec  : aliased constant SDL.Audio.Spec := Input;
      Output_Spec : aliased constant SDL.Audio.Spec := Output;
   begin
      Require_Open (Self);

      if not Boolean
          (SDL_Set_Audio_Stream_Format
             (Audio_Stream => Self.Internal,
              Source       => Input_Spec'Access,
              Destination  => Output_Spec'Access))
      then
         Raise_Last_Error ("Audio stream format update failed");
      end if;
   end Set_Format;

   procedure Set_Input_Format
     (Self  : in Stream;
      Input : in SDL.Audio.Spec)
   is
      Input_Spec : aliased constant SDL.Audio.Spec := Input;
   begin
      Require_Open (Self);

      if not Boolean
          (SDL_Set_Audio_Stream_Format
             (Audio_Stream => Self.Internal,
              Source       => Input_Spec'Access,
              Destination  => null))
      then
         Raise_Last_Error ("Audio stream input-format update failed");
      end if;
   end Set_Input_Format;

   procedure Set_Output_Format
     (Self   : in Stream;
      Output : in SDL.Audio.Spec)
   is
      Output_Spec : aliased constant SDL.Audio.Spec := Output;
   begin
      Require_Open (Self);

      if not Boolean
          (SDL_Set_Audio_Stream_Format
             (Audio_Stream => Self.Internal,
              Source       => null,
              Destination  => Output_Spec'Access))
      then
         Raise_Last_Error ("Audio stream output-format update failed");
      end if;
   end Set_Output_Format;

   function Get_Input_Channel_Map
     (Self : in Stream) return SDL.Audio.Channel_Map
   is
      Count : aliased C.int := 0;
      Items : System.Address;
   begin
      Require_Open (Self);

      Items :=
        SDL_Get_Audio_Stream_Input_Channel_Map
          (Audio_Stream => Self.Internal,
           Count        => Count'Access);
      return Copy_Channel_Map (Items => Items, Count => Count);
   end Get_Input_Channel_Map;

   function Get_Output_Channel_Map
     (Self : in Stream) return SDL.Audio.Channel_Map
   is
      Count : aliased C.int := 0;
      Items : System.Address;
   begin
      Require_Open (Self);

      Items :=
        SDL_Get_Audio_Stream_Output_Channel_Map
          (Audio_Stream => Self.Internal,
           Count        => Count'Access);
      return Copy_Channel_Map (Items => Items, Count => Count);
   end Get_Output_Channel_Map;

   procedure Set_Input_Channel_Map
     (Self : in Stream;
      Map  : in SDL.Audio.Channel_Map)
   is
      Raw_Map : Channel_Map_Array (0 .. C.ptrdiff_t (Map'Length - 1));
   begin
      Require_Open (Self);

      if Map'Length = 0 then
         Clear_Input_Channel_Map (Self);
         return;
      end if;

      for Offset in 0 .. C.ptrdiff_t (Map'Length - 1) loop
         Raw_Map (Offset) := Map (Map'First + Natural (Offset));
      end loop;

      if not Boolean
          (SDL_Set_Audio_Stream_Input_Channel_Map
             (Audio_Stream => Self.Internal,
              Map          => Raw_Map (Raw_Map'First)'Access,
              Count        => C.int (Map'Length)))
      then
         Raise_Last_Error ("Audio stream input channel-map update failed");
      end if;
   end Set_Input_Channel_Map;

   procedure Clear_Input_Channel_Map (Self : in Stream) is
      Input_Spec  : SDL.Audio.Spec;
      Output_Spec : SDL.Audio.Spec;
   begin
      Require_Open (Self);

      Get_Format (Self, Input_Spec, Output_Spec);

      if not Boolean
          (SDL_Set_Audio_Stream_Input_Channel_Map
             (Audio_Stream => Self.Internal,
              Map          => null,
              Count        => Input_Spec.Channels))
      then
         Raise_Last_Error ("Audio stream input channel-map reset failed");
      end if;
   end Clear_Input_Channel_Map;

   procedure Set_Output_Channel_Map
     (Self : in Stream;
      Map  : in SDL.Audio.Channel_Map)
   is
      Raw_Map : Channel_Map_Array (0 .. C.ptrdiff_t (Map'Length - 1));
   begin
      Require_Open (Self);

      if Map'Length = 0 then
         Clear_Output_Channel_Map (Self);
         return;
      end if;

      for Offset in 0 .. C.ptrdiff_t (Map'Length - 1) loop
         Raw_Map (Offset) := Map (Map'First + Natural (Offset));
      end loop;

      if not Boolean
          (SDL_Set_Audio_Stream_Output_Channel_Map
             (Audio_Stream => Self.Internal,
              Map          => Raw_Map (Raw_Map'First)'Access,
              Count        => C.int (Map'Length)))
      then
         Raise_Last_Error ("Audio stream output channel-map update failed");
      end if;
   end Set_Output_Channel_Map;

   procedure Clear_Output_Channel_Map (Self : in Stream) is
      Input_Spec  : SDL.Audio.Spec;
      Output_Spec : SDL.Audio.Spec;
   begin
      Require_Open (Self);

      Get_Format (Self, Input_Spec, Output_Spec);

      if not Boolean
          (SDL_Set_Audio_Stream_Output_Channel_Map
             (Audio_Stream => Self.Internal,
              Map          => null,
              Count        => Output_Spec.Channels))
      then
         Raise_Last_Error ("Audio stream output channel-map reset failed");
      end if;
   end Clear_Output_Channel_Map;

   function Get_Properties (Self : in Stream) return Property_ID is
      Props : constant Property_ID := SDL_Get_Audio_Stream_Properties (Self.Internal);
   begin
      Require_Open (Self);

      if Props = Null_Property_ID then
         Raise_Last_Error ("Audio stream property query failed");
      end if;

      return Props;
   end Get_Properties;

   function Device_Paused (Self : in Stream) return Boolean is
   begin
      Require_Open (Self);
      return Boolean (SDL_Audio_Stream_Device_Paused (Self.Internal));
   end Device_Paused;

   procedure Pause (Self : in Stream) is
   begin
      Require_Open (Self);

      if not Boolean (SDL_Pause_Audio_Stream_Device (Self.Internal)) then
         Raise_Last_Error ("Audio stream device pause failed");
      end if;
   end Pause;

   procedure Resume (Self : in Stream) is
   begin
      Require_Open (Self);

      if not Boolean (SDL_Resume_Audio_Stream_Device (Self.Internal)) then
         Raise_Last_Error ("Audio stream device resume failed");
      end if;
   end Resume;

   procedure Lock (Self : in Stream) is
   begin
      Require_Open (Self);

      if not Boolean (SDL_Lock_Audio_Stream (Self.Internal)) then
         Raise_Last_Error ("Audio stream lock failed");
      end if;
   end Lock;

   procedure Unlock (Self : in Stream) is
   begin
      Require_Open (Self);

      if not Boolean (SDL_Unlock_Audio_Stream (Self.Internal)) then
         Raise_Last_Error ("Audio stream unlock failed");
      end if;
   end Unlock;

   procedure Flush (Self : in Stream) is
   begin
      Require_Open (Self);

      if not Boolean (SDL_Flush_Audio_Stream (Self.Internal)) then
         Raise_Last_Error ("Audio stream flush failed");
      end if;
   end Flush;

   procedure Clear (Self : in Stream) is
   begin
      Require_Open (Self);

      if not Boolean (SDL_Clear_Audio_Stream (Self.Internal)) then
         Raise_Last_Error ("Audio stream clear failed");
      end if;
   end Clear;

   procedure Set_Get_Callback
     (Self      : in Stream;
      Callback  : in Stream_Callback;
      User_Data : in System.Address := System.Null_Address)
   is
   begin
      Require_Open (Self);

      if not Boolean
          (SDL_Set_Audio_Stream_Get_Callback
             (Audio_Stream => Self.Internal,
              Callback     => Callback,
              User_Data    => User_Data))
      then
         Raise_Last_Error ("Audio stream get-callback update failed");
      end if;
   end Set_Get_Callback;

   procedure Set_Put_Callback
     (Self      : in Stream;
      Callback  : in Stream_Callback;
      User_Data : in System.Address := System.Null_Address)
   is
   begin
      Require_Open (Self);

      if not Boolean
          (SDL_Set_Audio_Stream_Put_Callback
             (Audio_Stream => Self.Internal,
              Callback     => Callback,
              User_Data    => User_Data))
      then
         Raise_Last_Error ("Audio stream put-callback update failed");
      end if;
   end Set_Put_Callback;

   procedure Close (Self : in out Stream) is
   begin
      if Self.Is_Open then
         SDL_Destroy_Audio_Stream (Self.Internal);
         Self.Internal := System.Null_Address;
      end if;
   end Close;

   overriding
   procedure Finalize (Self : in out Stream) is
   begin
      Close (Self);
   end Finalize;
end SDL.Audio.Streams;
