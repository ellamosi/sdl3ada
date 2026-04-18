with Ada.Unchecked_Conversion;
with Interfaces.C;
with Interfaces.C.Extensions;
with Interfaces.C.Pointers;
with Interfaces.C.Strings;
with System;

with SDL.Audio.Sample_Formats;
with SDL.Error;
with SDL.Raw.Audio;

package body SDL.Audio.Devices is
   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;
   package CS renames Interfaces.C.Strings;
   package Raw renames SDL.Raw.Audio;

   use type C.ptrdiff_t;
   use type CS.chars_ptr;
   use type Interfaces.Unsigned_32;
   use type SDL.C_Pointers.Audio_Stream_Pointer;

   Frame_Byte_Size : constant Positive :=
     Positive (Frame_Type'Size / System.Storage_Unit);

   type ID_Arrays is array (C.ptrdiff_t range <>) of aliased ID with
     Convention => C;

   package ID_Pointers is new Interfaces.C.Pointers
     (Index              => C.ptrdiff_t,
      Element            => ID,
      Element_Array      => ID_Arrays,
      Default_Terminator => 0);

   use type ID_Pointers.Pointer;

   type External_Data_Ptr is access all External_Data;

   function To_ID_Pointers is new Ada.Unchecked_Conversion
     (Source => System.Address,
      Target => ID_Pointers.Pointer);

   function To_ID_Array_Address is new Ada.Unchecked_Conversion
     (Source => ID_Pointers.Pointer,
      Target => System.Address);

   function To_External_Data is new Ada.Unchecked_Conversion
     (Source => System.Address,
      Target => External_Data_Ptr);

   function To_Address is new Ada.Unchecked_Conversion
     (Source => SDL.C_Pointers.Audio_Stream_Pointer,
      Target => System.Address);

   function To_Stream_Pointer is new Ada.Unchecked_Conversion
     (Source => System.Address,
      Target => SDL.C_Pointers.Audio_Stream_Pointer);

   procedure Free (Value : in out ID_Pointers.Pointer);
   procedure Free (Value : in out ID_Pointers.Pointer) is
   begin
      if Value /= null then
         Raw.Free (To_ID_Array_Address (Value));
         Value := null;
      end if;
   end Free;

   procedure Require_Open (Self : in Device);
   procedure Require_Open (Self : in Device) is
   begin
      if not Self.Opened or else Self.Internal = 0 or else Self.Stream = null then
         raise Audio_Device_Error with "Invalid audio device";
      end if;
   end Require_Open;

   procedure Require_Playback (Self : in Device);
   procedure Require_Playback (Self : in Device) is
   begin
      Require_Open (Self);

      if Self.Capture then
         raise Audio_Device_Error with "Operation is only valid for playback devices";
      end if;
   end Require_Playback;

   procedure Require_Capture (Self : in Device);
   procedure Require_Capture (Self : in Device) is
   begin
      Require_Open (Self);

      if not Self.Capture then
         raise Audio_Device_Error with "Operation is only valid for recording devices";
      end if;
   end Require_Capture;

   function Enumerate_Devices
     (Is_Capture : in Boolean;
      Count      : access C.int)
      return ID_Pointers.Pointer
   is
   begin
      if Is_Capture then
         return To_ID_Pointers (Raw.Get_Audio_Recording_Devices (Count));
      end if;

      return To_ID_Pointers (Raw.Get_Audio_Playback_Devices (Count));
   end Enumerate_Devices;

   function Device_Name (Device : in ID) return String is
      Name : constant CS.chars_ptr :=
        Raw.Get_Audio_Device_Name (Raw.Device_ID (Device));
   begin
      if Name = CS.Null_Ptr then
         return "";
      end if;

      return CS.Value (Name);
   end Device_Name;

   function Resolve_Device
     (Name       : in String;
      Is_Capture : in Boolean)
      return ID
   is
      Count : aliased C.int := 0;
      Raw   : ID_Pointers.Pointer;
   begin
      if Name = "" then
         return (if Is_Capture
                 then SDL.Audio.Default_Recording_Device
                 else SDL.Audio.Default_Playback_Device);
      end if;

      Raw := Enumerate_Devices (Is_Capture, Count'Access);

      if Raw = null then
         raise Audio_Device_Error with SDL.Error.Get;
      end if;

      declare
         Devices : constant ID_Arrays := ID_Pointers.Value (Raw, C.ptrdiff_t (Count));
      begin
         for Device of Devices loop
            if Device_Name (Device) = Name then
               Free (Raw);
               return Device;
            end if;
         end loop;
      end;

      Free (Raw);
      raise Audio_Device_Error with "Audio device not found: " & Name;
   end Resolve_Device;

   function To_Requested_Audio_Spec (From : in Desired_Spec) return SDL.Audio.Spec is
     ((Format    => From.Format,
       Channels  => From.Channels,
       Frequency => From.Frequency));

   function To_Obtained_Audio_Spec (From : in Obtained_Spec) return SDL.Audio.Spec is
     ((Format    => From.Format,
       Channels  => From.Channels,
       Frequency => From.Frequency));

   function Silence_Value (Format : in SDL.Audio.Sample_Format) return Interfaces.Unsigned_8 is
   begin
      if Format = SDL.Audio.Sample_Formats.Sample_Format_U8 then
         return 16#80#;
      end if;

      return 0;
   end Silence_Value;

   function To_Obtained_Spec (Device : in ID) return Obtained_Spec is
      Internal_Spec   : aliased SDL.Audio.Spec;
      Sample_Frames   : aliased C.int := 0;
      Bytes_Per_Frame : Natural;
   begin
      if not Boolean
          (Raw.Get_Audio_Device_Format
             (Device        => Raw.Device_ID (Device),
              Spec          => Internal_Spec'Address,
              Sample_Frames => Sample_Frames'Access))
      then
         raise Audio_Device_Error with SDL.Error.Get;
      end if;

      Bytes_Per_Frame := SDL.Audio.Frame_Size (Internal_Spec);

      return
        (Mode      => Obtained,
         Frequency => Internal_Spec.Frequency,
         Format    => Internal_Spec.Format,
         Channels  => Internal_Spec.Channels,
         Samples   =>
           (if Sample_Frames <= 0
            then 0
            elsif Sample_Frames > C.int (Interfaces.Unsigned_16'Last)
            then Interfaces.Unsigned_16'Last
            else Interfaces.Unsigned_16 (Sample_Frames)),
         Silence   => Silence_Value (Internal_Spec.Format),
         Size      =>
           (if Sample_Frames <= 0
            then 0
            else Interfaces.Unsigned_32 (Bytes_Per_Frame * Natural (Sample_Frames))));
   end To_Obtained_Spec;

   function Last_Index (Length : in Positive) return Buffer_Index is
     (Buffer_Index'Val (Buffer_Index'Pos (Buffer_Index'First) + Length - 1));

   procedure Internal_Playback_Callback
     (User_Data         : in System.Address;
      Stream            : in System.Address;
      Additional_Amount : in C.int;
      Total_Amount      : in C.int)
   with Convention => C;

   procedure Internal_Playback_Callback
     (User_Data         : in System.Address;
      Stream            : in System.Address;
      Additional_Amount : in C.int;
      Total_Amount      : in C.int)
   is
      pragma Unreferenced (Total_Amount);

      External : constant External_Data_Ptr := To_External_Data (User_Data);
   begin
      if External = null or else External.Callback = null or else Additional_Amount <= 0 then
         return;
      end if;

      declare
         Requested_Frames : constant Positive :=
           Positive ((Natural (Additional_Amount) + Frame_Byte_Size - 1) / Frame_Byte_Size);
         subtype Callback_Buffer is Buffer_Type (Buffer_Index'First .. Last_Index (Requested_Frames));
         Data : Callback_Buffer;
      begin
         External.Callback (External.User_Data, Data);

         if not Boolean
             (Raw.Put_Audio_Stream_Data
                (Stream      => Stream,
                 Data        => Data'Address,
                 Byte_Length => C.int (Data'Size / System.Storage_Unit)))
         then
            null;
         end if;
      exception
         when others =>
            null;
      end;
   end Internal_Playback_Callback;

   function Total_Devices (Is_Capture : in Boolean := False) return Positive is
      Count : aliased C.int := 0;
      Raw   : ID_Pointers.Pointer := Enumerate_Devices (Is_Capture, Count'Access);
   begin
      if Raw = null then
         declare
            Message : constant String := SDL.Error.Get;
         begin
            if Message /= "" then
               raise Audio_Device_Error with Message;
            end if;
         end;
      end if;

      Free (Raw);

      if Count <= 0 then
         raise Audio_Device_Error with "No audio devices are available";
      end if;

      return Positive (Count);
   end Total_Devices;

   function Get_Name
     (Index      : in Positive;
      Is_Capture : in Boolean := False)
      return String
   is
      Count : aliased C.int := 0;
      Raw   : ID_Pointers.Pointer := Enumerate_Devices (Is_Capture, Count'Access);
   begin
      if Raw = null then
         raise Audio_Device_Error with SDL.Error.Get;
      end if;

      if C.int (Index) > Count then
         Free (Raw);
         raise Audio_Device_Error with "Audio device index is out of range";
      end if;

      declare
         Devices : constant ID_Arrays := ID_Pointers.Value (Raw, C.ptrdiff_t (Count));
         Result  : constant String :=
           Device_Name (Devices (Devices'First + C.ptrdiff_t (Index) - 1));
      begin
         Free (Raw);
         return Result;
      end;
   end Get_Name;

   function Open
     (Name            : in String := "";
      Is_Capture      : in Boolean := False;
      Desired         : in Desired_Spec;
      Obtained        : out Obtained_Spec;
      Callback        : in Audio_Callback := null;
      User_Data       : in User_Data_Access := null;
      Allowed_Changes : in Changes := None)
      return Device
   is
   begin
      return Result : Device do
         Open (Result, Name, Is_Capture, Desired, Obtained, Callback, User_Data, Allowed_Changes);
      end return;
   end Open;

   procedure Open
     (Self            : in out Device;
      Name            : in String := "";
      Is_Capture      : in Boolean := False;
      Desired         : in Desired_Spec;
      Obtained        : out Obtained_Spec;
      Callback        : in Audio_Callback := null;
      User_Data       : in User_Data_Access := null;
      Allowed_Changes : in Changes := None)
   is
      pragma Unreferenced (Allowed_Changes);

      Requested_Spec : aliased constant SDL.Audio.Spec := To_Requested_Audio_Spec (Desired);
      Device_ID      : constant ID := Resolve_Device (Name, Is_Capture);
   begin
      if Callback /= null and then Is_Capture then
         raise Audio_Device_Error with
           "Recording callbacks are not supported by this compatibility wrapper";
      end if;

      if SDL.Audio.Frame_Size (Requested_Spec) /= Frame_Byte_Size then
         raise Audio_Device_Error with
           "Frame_Type size does not match the requested audio format and channels";
      end if;

      Close (Self);

      Self.Internal :=
        ID
          (Raw.Open_Audio_Device
             (Raw.Device_ID (Device_ID), Requested_Spec'Address));

      if Self.Internal = 0 then
         raise Audio_Device_Error with SDL.Error.Get;
      end if;

      Self.Opened := True;
      Self.Capture := Is_Capture;
      Self.External.Callback := Callback;
      Self.External.User_Data := User_Data;

      if not Boolean (Raw.Pause_Audio_Device (Raw.Device_ID (Self.Internal))) then
         Close (Self);
         raise Audio_Device_Error with SDL.Error.Get;
      end if;

      Obtained := To_Obtained_Spec (Self.Internal);

      declare
         Device_Spec : aliased constant SDL.Audio.Spec := To_Obtained_Audio_Spec (Obtained);
         Source_Spec : aliased constant SDL.Audio.Spec :=
           (if Is_Capture then Device_Spec else Requested_Spec);
         Target_Spec : aliased constant SDL.Audio.Spec :=
           (if Is_Capture then Requested_Spec else Device_Spec);
      begin
         Self.Stream :=
           To_Stream_Pointer
             (Raw.Create_Audio_Stream
                (Source_Spec'Address, Target_Spec'Address));
      end;

      if Self.Stream = null then
         Close (Self);
         raise Audio_Device_Error with SDL.Error.Get;
      end if;

      if not Boolean
          (Raw.Bind_Audio_Stream
             (Raw.Device_ID (Self.Internal), To_Address (Self.Stream)))
      then
         Close (Self);
         raise Audio_Device_Error with SDL.Error.Get;
      end if;

      if Callback /= null then
         if not Boolean
             (Raw.Set_Audio_Stream_Get_Callback
                (Stream    => To_Address (Self.Stream),
                 Callback  => Internal_Playback_Callback'Unrestricted_Access,
                 User_Data => Self.External'Address))
         then
            Close (Self);
            raise Audio_Device_Error with SDL.Error.Get;
         end if;
      end if;
   end Open;

   procedure Queue
     (Self : in Device;
      Data : in Buffer_Type)
   is
   begin
      Require_Playback (Self);

      if not Boolean
          (Raw.Put_Audio_Stream_Data
             (Stream      => To_Address (Self.Stream),
              Data        => Data'Address,
              Byte_Length => C.int (Data'Size / System.Storage_Unit)))
      then
         raise Audio_Device_Error with SDL.Error.Get;
      end if;
   end Queue;

   procedure Dequeue
     (Self : in Device;
      Data : in out Buffer_Type;
      Last : out Natural)
   is
      Bytes_Read : C.int;
   begin
      Require_Capture (Self);

      if Data'Length = 0 then
         Last := 0;
         return;
      end if;

      Bytes_Read :=
        Raw.Get_Audio_Stream_Data
          (Stream      => To_Address (Self.Stream),
           Data        => Data'Address,
           Byte_Length => C.int (Data'Size / System.Storage_Unit));

      if Bytes_Read < 0 then
         raise Audio_Device_Error with SDL.Error.Get;
      end if;

      Last := Natural (Bytes_Read) / Frame_Byte_Size;
   end Dequeue;

   function Get_Status (Self : in Device) return Audio_Status is
   begin
      if not Self.Opened or else Self.Internal = 0 then
         return Stopped;
      end if;

      if Boolean (Raw.Audio_Device_Paused (Raw.Device_ID (Self.Internal))) then
         return Paused;
      end if;

      if Self.Capture or else Self.External.Callback /= null or else Get_Queued_Size (Self) > 0 then
         return Playing;
      end if;

      return Stopped;
   end Get_Status;

   function Get_ID (Self : in Device) return ID is
   begin
      return Self.Internal;
   end Get_ID;

   procedure Pause (Self : in Device; Pause : in Boolean) is
      Success : CE.bool;
   begin
      Require_Open (Self);

      Success :=
        (if Pause
         then Raw.Pause_Audio_Device (Raw.Device_ID (Self.Internal))
         else Raw.Resume_Audio_Device (Raw.Device_ID (Self.Internal)));

      if not Boolean (Success) then
         raise Audio_Device_Error with SDL.Error.Get;
      end if;
   end Pause;

   function Get_Queued_Size (Self : in Device) return Interfaces.Unsigned_32 is
      Bytes_Queued : C.int;
   begin
      Require_Open (Self);

      Bytes_Queued := Raw.Get_Audio_Stream_Queued (To_Address (Self.Stream));

      if Bytes_Queued < 0 then
         raise Audio_Device_Error with SDL.Error.Get;
      end if;

      return Interfaces.Unsigned_32 (Bytes_Queued);
   end Get_Queued_Size;

   function Get_Available_Size (Self : in Device) return Interfaces.Unsigned_32 is
      Bytes_Available : C.int;
   begin
      Require_Open (Self);

      Bytes_Available := Raw.Get_Audio_Stream_Available (To_Address (Self.Stream));

      if Bytes_Available < 0 then
         raise Audio_Device_Error with SDL.Error.Get;
      end if;

      return Interfaces.Unsigned_32 (Bytes_Available);
   end Get_Available_Size;

   function Is_Capture (Self : in Device) return Boolean is
   begin
      return Self.Opened and then Self.Capture;
   end Is_Capture;

   function Uses_Callback (Self : in Device) return Boolean is
   begin
      return Self.External.Callback /= null;
   end Uses_Callback;

   procedure Clear_Queued (Self : in Device) is
   begin
      Require_Open (Self);

      if not Boolean (Raw.Clear_Audio_Stream (To_Address (Self.Stream))) then
         raise Audio_Device_Error with SDL.Error.Get;
      end if;
   end Clear_Queued;

   procedure Close (Self : in out Device) is
   begin
      if Self.Stream /= null then
         Raw.Destroy_Audio_Stream (To_Address (Self.Stream));
         Self.Stream := null;
      end if;

      if Self.Opened and then Self.Internal /= 0 then
         Raw.Close_Audio_Device (Raw.Device_ID (Self.Internal));
      end if;

      Self.Internal := 0;
      Self.Opened := False;
      Self.Capture := False;
      Self.External.Callback := null;
      Self.External.User_Data := null;
   end Close;

   overriding
   procedure Finalize (Self : in out Device) is
   begin
      Close (Self);
   end Finalize;
end SDL.Audio.Devices;
