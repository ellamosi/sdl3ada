with Ada.Finalization;
with Interfaces;

private with SDL.C_Pointers;

generic
   type Frame_Type is private;
   type Buffer_Index is (<>);
   type Buffer_Type is array (Buffer_Index range <>) of Frame_Type;
package SDL.Audio.Devices is
   pragma Elaborate_Body;

   Audio_Device_Error : exception;

   type Audio_Status is (Stopped, Playing, Paused);

   type Changes is mod 2 ** 32 with
     Convention => C,
     Size       => SDL.C.int'Size;

   None      : constant Changes := 16#0000_0000#;
   Frequency : constant Changes := 16#0000_0001#;
   Format    : constant Changes := 16#0000_0002#;
   Channels  : constant Changes := 16#0000_0004#;
   Samples   : constant Changes := 16#0000_0008#;
   Any       : constant Changes := Frequency or Format or Channels or Samples;

   type User_Data is tagged private;

   type User_Data_Access is access all User_Data'Class;
   pragma No_Strict_Aliasing (User_Data_Access);

   subtype Channel_Counts is SDL.Audio.Channel_Count range 1 .. 8;

   type Device is new Ada.Finalization.Limited_Controlled with private;

   type Audio_Callback is access procedure
     (User : in User_Data_Access;
      Data : out Buffer_Type);

   type Spec_Mode is (Desired, Obtained);

   type Spec (Mode : Spec_Mode) is record
      Frequency : SDL.Audio.Sample_Rate;
      Format    : SDL.Audio.Sample_Format;
      Channels  : Channel_Counts;
      Samples   : Interfaces.Unsigned_16;

      case Mode is
         when Desired =>
            null;
         when Obtained =>
            Silence : Interfaces.Unsigned_8;
            Size    : Interfaces.Unsigned_32;
      end case;
   end record;

   subtype Desired_Spec is Spec (Desired);
   subtype Obtained_Spec is Spec (Obtained);

   subtype ID is SDL.Audio.Device_ID;

   function Total_Devices (Is_Capture : in Boolean := False) return Positive;

   function Get_Name
     (Index      : in Positive;
      Is_Capture : in Boolean := False)
      return String;

   function Open
     (Name            : in String := "";
      Is_Capture      : in Boolean := False;
      Desired         : in Desired_Spec;
      Obtained        : out Obtained_Spec;
      Callback        : in Audio_Callback := null;
      User_Data       : in User_Data_Access := null;
      Allowed_Changes : in Changes := None)
      return Device;

   procedure Open
     (Self            : in out Device;
      Name            : in String := "";
      Is_Capture      : in Boolean := False;
      Desired         : in Desired_Spec;
      Obtained        : out Obtained_Spec;
      Callback        : in Audio_Callback := null;
      User_Data       : in User_Data_Access := null;
      Allowed_Changes : in Changes := None);

   procedure Queue
     (Self : in Device;
      Data : in Buffer_Type);

   procedure Dequeue
     (Self : in Device;
      Data : in out Buffer_Type;
      Last : out Natural);

   function Get_Status (Self : in Device) return Audio_Status;

   function Get_ID (Self : in Device) return ID with
     Inline;

   procedure Pause (Self : in Device; Pause : in Boolean) with
     Inline;

   function Get_Queued_Size (Self : in Device) return Interfaces.Unsigned_32 with
     Inline;

   function Get_Available_Size (Self : in Device) return Interfaces.Unsigned_32 with
     Inline;

   function Is_Capture (Self : in Device) return Boolean with
     Inline;

   function Uses_Callback (Self : in Device) return Boolean with
     Inline;

   procedure Clear_Queued (Self : in Device) with
     Inline;

   procedure Close (Self : in out Device) with
     Inline;
private
   type User_Data is new Ada.Finalization.Controlled with null record;

   type External_Data is record
      Callback  : Audio_Callback;
      User_Data : User_Data_Access;
   end record;

   type Device is new Ada.Finalization.Limited_Controlled with
      record
         Internal : ID := 0;
         Stream   : SDL.C_Pointers.Audio_Stream_Pointer := null;
         Opened   : Boolean := False;
         Capture  : Boolean := False;
         External : aliased External_Data;
      end record;

   overriding
   procedure Finalize (Self : in out Device);
end SDL.Audio.Devices;
