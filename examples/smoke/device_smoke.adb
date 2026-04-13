with Ada.Exceptions;
with Ada.Strings.Unbounded;
with Ada.Text_IO;

with Interfaces;
with Interfaces.C.Extensions;

with SDL;
with SDL.Cameras;
with SDL.Error;
with SDL.Events.Cameras;
with SDL.Events.Events;
with SDL.Events.Pens;
with SDL.Events.Sensors;
with SDL.HIDAPI;
with SDL.Haptics;
with SDL.Pens;
with SDL.Properties;
with SDL.Sensors;
with SDL.Video.Surfaces;

procedure Device_Smoke is
   package CE renames Interfaces.C.Extensions;

   use type SDL.Cameras.Camera;
   use type SDL.Cameras.ID;
   use type SDL.C.C_float;
   use type SDL.Events.Button_State;
   use type Interfaces.Unsigned_16;
   use type SDL.Haptics.Effect_Types;
   use type SDL.Haptics.Features;
   use type SDL.Haptics.Haptic;
   use type SDL.Haptics.ID;
   use type SDL.HIDAPI.Device;
   use type SDL.Pens.Axes;
   use type SDL.Init_Flags;
   use type SDL.Pens.Device_Types;
   use type SDL.Pens.ID;
   use type SDL.Pens.Input_Flags;
   use type SDL.Properties.Property_Set;
   use type SDL.C.int;
   use type SDL.Events.Event_Types;
   use type SDL.Events.Cameras.IDs;
   use type SDL.Events.Pens.Button_Indices;
   use type SDL.Sensors.ID;
   use type SDL.Sensors.Sensor;
   use type SDL.Video.Surfaces.Surface;

   procedure Require (Condition : in Boolean; Message : in String) is
   begin
      if not Condition then
         raise Program_Error with Message;
      end if;
   end Require;

   function SDL_Push_Event
     (Event : access SDL.Events.Events.Events) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_PushEvent";

   procedure Push (Event : aliased in out SDL.Events.Events.Events) is
   begin
      if not Boolean (SDL_Push_Event (Event'Access)) then
         raise Program_Error with "SDL_PushEvent failed: " & SDL.Error.Get;
      end if;
   end Push;

   Event : SDL.Events.Events.Events;

   procedure Drain_Events is
   begin
      while SDL.Events.Events.Poll (Event) loop
         null;
      end loop;
   end Drain_Events;

   procedure Require_Event
     (Expected : in SDL.Events.Event_Types;
      Label    : in String;
      Limit    : in Positive := 32)
   is
      Seen : Boolean := False;
   begin
      for Attempt in 1 .. Limit loop
         exit when not SDL.Events.Events.Poll (Event);

         if Event.Common.Event_Type = Expected then
            Seen := True;
            exit;
         end if;
      end loop;

      Require (Seen, "Expected " & Label & " event");
   end Require_Event;

   Sensor_Event : aliased SDL.Events.Events.Events :=
     (Kind   => SDL.Events.Events.Is_Sensor_Event,
      Sensor =>
        (Event_Type        => SDL.Events.Sensors.Update,
         Reserved          => 0,
         Time_Stamp        => 0,
         Which             => 1,
         Data              => (0 => 1.0,
                               1 => 2.0,
                               2 => 3.0,
                               3 => 4.0,
                               4 => 5.0,
                               5 => 6.0),
         Sensor_Time_Stamp => 123));

   Camera_Event : aliased SDL.Events.Events.Events :=
     (Kind          => SDL.Events.Events.Is_Camera_Device_Event,
      Camera_Device =>
        (Event_Type => SDL.Events.Cameras.Device_Approved,
         Reserved   => 0,
         Time_Stamp => 0,
         Which      => 7));

   Pen_Axis_Event : aliased SDL.Events.Events.Events :=
     (Kind     => SDL.Events.Events.Is_Pen_Axis_Event,
      Pen_Axis =>
        (Event_Type => SDL.Events.Pens.Axis,
         Reserved   => 0,
         Time_Stamp => 0,
         Window     => 0,
         Which      => 9,
         Pen_State  => SDL.Pens.Input_Down or SDL.Pens.Input_Button_1,
         X          => 12.0,
         Y          => 34.0,
         Axis       => SDL.Pens.Pressure,
         Value      => 0.5));

   procedure Exercise_Sensors is
      IDs : constant SDL.Sensors.ID_Lists := SDL.Sensors.Get_Sensors;
   begin
      Ada.Text_IO.Put_Line ("Sensor count:" & Natural'Image (IDs'Length));

      if IDs'Length = 0 then
         Ada.Text_IO.Put_Line ("Skipping live sensor validation: no sensors detected");
         return;
      end if;

      declare
         Device : SDL.Sensors.Sensor := SDL.Sensors.Open (IDs (IDs'First));
         Props  : constant SDL.Properties.Property_Set :=
           SDL.Sensors.Get_Properties (Device);
      begin
         Require
           (SDL.Sensors.Get_ID (Device) = IDs (IDs'First),
            "Opened sensor ID did not round-trip");
         Require
           (not SDL.Properties.Is_Null (Props),
            "Sensor properties should not be null");

         SDL.Sensors.Update;

         begin
            declare
               Values : constant SDL.Sensors.Data_Values :=
                 SDL.Sensors.Get_Data (Device, 3);
            begin
               Require (Values'Length = 3, "Sensor data read length mismatch");
            end;
         exception
            when E : SDL.Sensors.Sensor_Error =>
               Ada.Text_IO.Put_Line
                 ("Skipping live sensor read: "
                  & Ada.Exceptions.Exception_Message (E));
         end;
      exception
         when E : SDL.Sensors.Sensor_Error =>
            Ada.Text_IO.Put_Line
              ("Skipping sensor open/query validation: "
               & Ada.Exceptions.Exception_Message (E));
      end;
   end Exercise_Sensors;

   procedure Exercise_Cameras is
      Camera_Driver_Count : constant Natural := SDL.Cameras.Total_Drivers;
      IDs                 : constant SDL.Cameras.ID_Lists := SDL.Cameras.Get_Cameras;
   begin
      Ada.Text_IO.Put_Line
        ("Camera driver count:" & Natural'Image (Camera_Driver_Count));
      Ada.Text_IO.Put_Line
        ("Camera count:" & Natural'Image (IDs'Length));

      if Camera_Driver_Count > 0 then
         Ada.Text_IO.Put_Line
           ("First camera driver: " & SDL.Cameras.Driver_Name (1));
      end if;

      if IDs'Length = 0 then
         Ada.Text_IO.Put_Line ("Skipping live camera validation: no cameras detected");
         return;
      end if;

      declare
         Device : SDL.Cameras.Camera := SDL.Cameras.Open (IDs (IDs'First));
         Props  : constant SDL.Properties.Property_Set :=
           SDL.Cameras.Get_Properties (Device);
         Stamp  : SDL.Cameras.Timestamp_Nanoseconds := 0;
         Frame  : SDL.Video.Surfaces.Surface :=
           SDL.Cameras.Acquire_Frame (Device, Stamp);
      begin
         Require
           (SDL.Cameras.Get_ID (Device) = IDs (IDs'First),
            "Opened camera ID did not round-trip");
         Require
           (not SDL.Properties.Is_Null (Props),
            "Camera properties should not be null");

         declare
            Formats : constant SDL.Cameras.Spec_Lists :=
              SDL.Cameras.Supported_Formats (IDs (IDs'First));
            Actual  : SDL.Cameras.Spec;
         begin
            Ada.Text_IO.Put_Line
              ("Camera format candidates:" & Natural'Image (Formats'Length));

            if SDL.Cameras.Get_Format (Device, Actual) then
               Require
                 (Actual.Width >= 0 and then Actual.Height >= 0,
                  "Camera format dimensions must be non-negative");
            else
               Ada.Text_IO.Put_Line
                 ("Camera format unavailable yet; permission may still be pending");
            end if;
         end;

         if Frame /= SDL.Video.Surfaces.Null_Surface then
            SDL.Cameras.Release_Frame (Device, Frame);
            Require
              (Frame = SDL.Video.Surfaces.Null_Surface,
               "Released camera frame should be cleared");
         else
            Ada.Text_IO.Put_Line
              ("No camera frame available yet; permission may still be pending");
         end if;
      exception
         when E : SDL.Cameras.Camera_Error =>
            Ada.Text_IO.Put_Line
              ("Skipping camera open/query validation: "
               & Ada.Exceptions.Exception_Message (E));
      end;
   end Exercise_Cameras;

   procedure Exercise_Haptics is
      IDs : constant SDL.Haptics.ID_Lists := SDL.Haptics.Get_Haptics;
   begin
      Ada.Text_IO.Put_Line ("Haptic count:" & Natural'Image (IDs'Length));

      if IDs'Length = 0 then
         Ada.Text_IO.Put_Line ("Skipping live haptic validation: no haptic devices detected");
         return;
      end if;

      declare
         Device : SDL.Haptics.Haptic := SDL.Haptics.Open (IDs (IDs'First));
         Probe  : constant SDL.Haptics.Effect :=
           (Kind     => SDL.Haptics.Constant_Data,
            Constant_Info =>
              (Kind          => SDL.Haptics.Constant_Effect,
               Heading       => (Encoding => SDL.Haptics.Cartesian,
                                 Values   => (0 => 0, 1 => 1, 2 => 0)),
               Length        => 100,
               Start_Delay   => 0,
               Button        => 0,
               Interval      => 0,
               Level         => 0,
               Attack_Length => 0,
               Attack_Level  => 0,
               Fade_Length   => 0,
               Fade_Level    => 0));
         Max_Effects : constant Natural := SDL.Haptics.Get_Max_Effects (Device);
         Max_Playing : constant Natural :=
           SDL.Haptics.Get_Max_Playing_Effects (Device);
         Axis_Count  : constant Natural := SDL.Haptics.Get_Num_Axes (Device);
         Supported   : constant Boolean := SDL.Haptics.Effect_Supported (Device, Probe);
      begin
         Require
           (SDL.Haptics.Get_ID (Device) = IDs (IDs'First),
            "Opened haptic ID did not round-trip");
         Ada.Text_IO.Put_Line ("Haptic max effects:" & Natural'Image (Max_Effects));
         Ada.Text_IO.Put_Line ("Haptic max playing:" & Natural'Image (Max_Playing));
         Ada.Text_IO.Put_Line ("Haptic axes:" & Natural'Image (Axis_Count));
         Ada.Text_IO.Put_Line ("Constant effect supported:" & Boolean'Image (Supported));

         if SDL.Haptics.Supports_Rumble (Device) then
            begin
               SDL.Haptics.Initialise_Rumble (Device);
            exception
               when E : SDL.Haptics.Haptic_Error =>
                  Ada.Text_IO.Put_Line
                    ("Skipping rumble init: "
                     & Ada.Exceptions.Exception_Message (E));
            end;
         end if;
      exception
         when E : SDL.Haptics.Haptic_Error =>
            Ada.Text_IO.Put_Line
              ("Skipping haptic open/query validation: "
               & Ada.Exceptions.Exception_Message (E));
      end;
   end Exercise_Haptics;

   procedure Exercise_Pens is
      Proximity : constant SDL.Events.Pens.Proximity_Events :=
        (Event_Type => SDL.Events.Pens.Proximity_In,
         Reserved   => 0,
         Time_Stamp => 0,
         Window     => 0,
         Which      => 1);
      Touch : constant SDL.Events.Pens.Touch_Events :=
        (Event_Type => SDL.Events.Pens.Touch_Down,
         Reserved   => 0,
         Time_Stamp => 0,
         Window     => 0,
         Which      => 2,
         Pen_State  => SDL.Pens.Input_Down or SDL.Pens.Input_Button_1,
         X          => 10.0,
         Y          => 20.0,
         Eraser     => CE.bool'Val (0),
         Down       => CE.bool'Val (1));
      Motion : constant SDL.Events.Pens.Motion_Events :=
        (Event_Type => SDL.Events.Pens.Motion,
         Reserved   => 0,
         Time_Stamp => 0,
         Window     => 0,
         Which      => 3,
         Pen_State  => SDL.Pens.Input_In_Proximity,
         X          => 30.0,
         Y          => 40.0);
      Button : constant SDL.Events.Pens.Button_Events :=
        (Event_Type => SDL.Events.Pens.Button_Down,
         Reserved   => 0,
         Time_Stamp => 0,
         Window     => 0,
         Which      => 4,
         Pen_State  => SDL.Pens.Input_Button_2,
         X          => 50.0,
         Y          => 60.0,
         Button     => 2,
         Down       => CE.bool'Val (1));
   begin
      SDL.Events.Events.Set_Enabled (SDL.Events.Pens.Proximity_In, True);
      SDL.Events.Events.Set_Enabled (SDL.Events.Pens.Proximity_Out, True);
      SDL.Events.Events.Set_Enabled (SDL.Events.Pens.Touch_Down, True);
      SDL.Events.Events.Set_Enabled (SDL.Events.Pens.Touch_Up, True);
      SDL.Events.Events.Set_Enabled (SDL.Events.Pens.Button_Down, True);
      SDL.Events.Events.Set_Enabled (SDL.Events.Pens.Button_Up, True);
      SDL.Events.Events.Set_Enabled (SDL.Events.Pens.Motion, True);
      SDL.Events.Events.Set_Enabled (SDL.Events.Pens.Axis, True);

      Require
        (SDL.Events.Events.Is_Enabled (SDL.Events.Pens.Axis),
         "Pen axis events should be enabled");
      Require
        (Proximity.Which = 1,
         "Pen proximity event aggregate mismatch");
      Require
        (SDL.Events.Pens.Get_State (Touch) = SDL.Events.Pressed
         and then SDL.Pens.Has_Flag (Touch.Pen_State, SDL.Pens.Input_Down),
         "Pen touch event aggregate mismatch");
      Require
        (Motion.X = 30.0 and then Motion.Y = 40.0,
         "Pen motion event aggregate mismatch");
      Require
        (Button.Button = 2
         and then SDL.Events.Pens.Get_State (Button) = SDL.Events.Pressed,
         "Pen button event aggregate mismatch");
      Require
        (Pen_Axis_Event.Pen_Axis.Axis = SDL.Pens.Pressure
         and then Pen_Axis_Event.Pen_Axis.Which = 9,
         "Pen axis event aggregate mismatch");

      SDL.Error.Clear;
      Require
        (SDL.Pens.Get_Device_Type (0) = SDL.Pens.Invalid,
         "Invalid pen device type should round-trip");
      SDL.Error.Clear;

      Drain_Events;
      Push (Pen_Axis_Event);
      Require_Event (SDL.Events.Pens.Axis, "a pen axis");
      Require
        (Event.Pen_Axis.Axis = SDL.Pens.Pressure
         and then Event.Pen_Axis.Which = 9,
         "Pushed pen axis event did not round-trip");
   end Exercise_Pens;

   procedure Exercise_HIDAPI is
      Initialised : Boolean := False;
   begin
      begin
         SDL.HIDAPI.Initialise;
         Initialised := True;
      exception
         when E : SDL.HIDAPI.HIDAPI_Error =>
            Ada.Text_IO.Put_Line
              ("Skipping HIDAPI initialisation: "
               & Ada.Exceptions.Exception_Message (E));
            return;
      end;

      Ada.Text_IO.Put_Line
        ("HIDAPI device change count:"
         & Interfaces.Unsigned_32'Image (SDL.HIDAPI.Get_Device_Change_Count));

      declare
         Devices : constant SDL.HIDAPI.Device_Info_Lists := SDL.HIDAPI.Enumerate;
      begin
         Ada.Text_IO.Put_Line ("HIDAPI device count:" & Natural'Image (Devices'Length));

         if Devices'Length = 0 then
            Ada.Text_IO.Put_Line
              ("Skipping live HIDAPI validation: no HID devices detected");
         else
            declare
               Info : constant SDL.HIDAPI.Device_Info := Devices (Devices'First);
               Path : constant String := Ada.Strings.Unbounded.To_String (Info.Path);
            begin
               Require
                 (Path /= "",
                  "Enumerated HID device should have a non-empty path");

               declare
                  Device : SDL.HIDAPI.Device := SDL.HIDAPI.Open_Path (Path);
                  Props  : constant SDL.Properties.Property_Set :=
                    SDL.HIDAPI.Get_Properties (Device);
                  Opened_Info : constant SDL.HIDAPI.Device_Info :=
                    SDL.HIDAPI.Get_Info (Device);
               begin
                  Require
                    (not SDL.Properties.Is_Null (Props),
                     "HID device properties should not be null");
                  Require
                    (Opened_Info.Vendor_ID = Info.Vendor_ID
                     and then Opened_Info.Product_ID = Info.Product_ID,
                     "Opened HID device info did not round-trip");

                  SDL.HIDAPI.Set_Nonblocking (Device, True);

                  declare
                     Descriptor : constant SDL.HIDAPI.Byte_Lists :=
                       SDL.HIDAPI.Get_Report_Descriptor (Device, 256);
                     Input      : constant SDL.HIDAPI.Byte_Lists :=
                       SDL.HIDAPI.Read (Device, 64);
                  begin
                     Ada.Text_IO.Put_Line
                       ("HID report descriptor bytes:"
                        & Natural'Image (Descriptor'Length));
                     Ada.Text_IO.Put_Line
                       ("HID nonblocking read bytes:"
                        & Natural'Image (Input'Length));
                  exception
                     when E : SDL.HIDAPI.HIDAPI_Error =>
                        Ada.Text_IO.Put_Line
                          ("Skipping HID report/read validation: "
                           & Ada.Exceptions.Exception_Message (E));
                  end;

                  begin
                     declare
                        Manufacturer : constant String :=
                          SDL.HIDAPI.Manufacturer_String (Device);
                        Product_Name : constant String :=
                          SDL.HIDAPI.Product_String (Device);
                        Serial       : constant String :=
                          SDL.HIDAPI.Serial_Number_String (Device);
                     begin
                        Ada.Text_IO.Put_Line
                          ("HID manufacturer length:"
                           & Natural'Image (Manufacturer'Length));
                        Ada.Text_IO.Put_Line
                          ("HID product length:"
                           & Natural'Image (Product_Name'Length));
                        Ada.Text_IO.Put_Line
                          ("HID serial length:"
                           & Natural'Image (Serial'Length));
                     end;
                  exception
                     when E : SDL.HIDAPI.HIDAPI_Error =>
                        Ada.Text_IO.Put_Line
                          ("Skipping HID string validation: "
                           & Ada.Exceptions.Exception_Message (E));
                  end;
               exception
                  when E : SDL.HIDAPI.HIDAPI_Error =>
                     Ada.Text_IO.Put_Line
                       ("Skipping HID open/query validation: "
                        & Ada.Exceptions.Exception_Message (E));
               end;
            end;
         end if;
      exception
         when E : SDL.HIDAPI.HIDAPI_Error =>
            Ada.Text_IO.Put_Line
              ("Skipping HIDAPI enumeration: "
               & Ada.Exceptions.Exception_Message (E));
      end;

      if Initialised then
         begin
            SDL.HIDAPI.Shutdown;
         exception
            when E : SDL.HIDAPI.HIDAPI_Error =>
               Ada.Text_IO.Put_Line
                 ("Skipping HIDAPI shutdown validation: "
                  & Ada.Exceptions.Exception_Message (E));
         end;
      end if;
   end Exercise_HIDAPI;
begin
   if not SDL.Initialise
       (SDL.Enable_Events or SDL.Enable_Haptic or SDL.Enable_Sensor
        or SDL.Enable_Camera or SDL.Enable_Joystick)
   then
      raise Program_Error with "SDL initialization failed: " & SDL.Error.Get;
   end if;

   Drain_Events;

   SDL.Events.Events.Set_Enabled (SDL.Events.Sensors.Update, True);
   SDL.Events.Events.Set_Enabled (SDL.Events.Cameras.Device_Added, True);
   SDL.Events.Events.Set_Enabled (SDL.Events.Cameras.Device_Removed, True);
   SDL.Events.Events.Set_Enabled (SDL.Events.Cameras.Device_Approved, True);
   SDL.Events.Events.Set_Enabled (SDL.Events.Cameras.Device_Denied, True);
   Require
     (SDL.Events.Events.Is_Enabled (SDL.Events.Cameras.Device_Approved),
      "Camera device approved events should be enabled");
   Require
     (Camera_Event.Camera_Device.Event_Type = SDL.Events.Cameras.Device_Approved
      and then Camera_Event.Camera_Device.Which = 7,
      "Camera device event aggregate mismatch");

   Push (Sensor_Event);
   Require_Event (SDL.Events.Sensors.Update, "a sensor");

   Exercise_Sensors;
   Exercise_Cameras;
   Exercise_Haptics;
   Exercise_Pens;
   Exercise_HIDAPI;

   SDL.Quit;
   Ada.Text_IO.Put_Line ("Device smoke completed successfully.");
exception
   when others =>
      SDL.Quit;
      raise;
end Device_Smoke;
