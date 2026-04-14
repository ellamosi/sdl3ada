with System;

with Ada.Strings.Unbounded;
with Ada.Exceptions;
with Ada.Text_IO;

with Interfaces;
with Interfaces.C;
with Interfaces.C.Extensions;

with SDL;
with SDL.Error;
with SDL.Events;
with SDL.Events.Controllers;
with SDL.Events.Queue;
with SDL.Events.Joysticks;
with SDL.Events.Joysticks.Game_Controllers;
with SDL.Events.Keyboards;
with SDL.Events.Mice;
with SDL.Inputs.Joysticks;
with SDL.Inputs.Joysticks.Game_Controllers;
with SDL.Inputs.Joysticks.Game_Controllers.Makers;
with SDL.Inputs.Joysticks.Makers;
with SDL.Inputs.Keyboards;
with SDL.Inputs.Mice;
with SDL.Inputs.Mice.Cursors;
with SDL.Power;
with SDL.Properties;
with SDL.RWops;
with SDL.Sensors;
with SDL.Video.Rectangles;
with SDL.Video.Surfaces;
with SDL.Video.Surfaces.Makers;
with SDL.Video.Windows;
with SDL.Video.Windows.Makers;

procedure Input_Smoke is
   package US renames Ada.Strings.Unbounded;
   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;

   use type SDL.Init_Flags;
   use type SDL.Events.Button_State;
   use type SDL.Events.Controllers.Axes;
   use type SDL.Events.Controllers.Axes_Values;
   use type SDL.Events.Event_Types;
   use type SDL.Events.Joysticks.Axes;
   use type SDL.Events.Joysticks.Axes_Values;
   use type SDL.Events.Joysticks.Buttons;
   use type SDL.Events.Joysticks.Hats;
   use type SDL.Events.Joysticks.IDs;
   use type SDL.Events.Joysticks.Hat_Positions;
   use type SDL.Events.Joysticks.Game_Controllers.Axes;
   use type SDL.Events.Joysticks.Game_Controllers.LR_Axes_Values;
   use type SDL.Events.Joysticks.Game_Controllers.Buttons;
   use type SDL.Events.Keyboards.Key_Modifiers;
   use type SDL.Events.Keyboards.Scan_Codes;
   use type SDL.Inputs.Joysticks.All_Devices;
   use type SDL.Inputs.Joysticks.Player_Indices;
   use type SDL.Inputs.Joysticks.Types;
   use type SDL.Inputs.Joysticks.Game_Controllers.Button_Labels;
   use type SDL.Inputs.Joysticks.Game_Controllers.Types;
   use type SDL.Inputs.Keyboards.Key_State_Access;
   use type SDL.Inputs.Mice.Motion_Value_Access;
   use type SDL.Video.Rectangles.Rectangle;
   use type SDL.Video.Windows.ID;
   use type SDL.Coordinate;
   use type Interfaces.Unsigned_16;
   use type Interfaces.Unsigned_8;
   use type Interfaces.Unsigned_32;
   use type Interfaces.Unsigned_64;
   use type Interfaces.Integer_32;
   use type C.C_float;

   Mapping_GUID   : constant String :=
     "341a3608000000000000504944564944";
   Known_Mapping_GUID : constant String :=
     "03000000c82d00001930000000000000";
   Mapping_String : constant String :=
     Mapping_GUID
     & ",Phase3 Test Pad,"
     & "a:b1,b:b2,y:b3,x:b0,start:b9,guide:b12,back:b8,"
     & "dpup:h0.1,dpleft:h0.8,dpdown:h0.4,dpright:h0.2,"
     & "leftshoulder:b4,rightshoulder:b5,leftstick:b10,rightstick:b11,"
     & "leftx:a0,lefty:a1,rightx:a2,righty:a3,lefttrigger:b6,righttrigger:b7";
   IO_Mapping_GUID : constant String :=
     "ff008316550900001472000000007601";
   IO_Mapping_String : constant String :=
     IO_Mapping_GUID
     & ",Phase5 IO Test Pad,"
     & "a:b0,b:b1,x:b2,y:b3,back:b4,start:b5,"
     & "leftx:a0,lefty:a1,rightx:a2,righty:a3,lefttrigger:a4,righttrigger:a5,"
     & "platform:macOS,";
   Virtual_Name : constant String := "Phase5 Virtual Pad";

   function To_C_Bool (Value : in Boolean) return CE.bool is
     (if Value then CE.bool'Val (1) else CE.bool'Val (0));

   procedure Require (Condition : in Boolean; Message : in String) is
   begin
      if not Condition then
         raise Program_Error with Message;
      end if;
   end Require;

   procedure Scale_Mouse_Motion
     (User_Data  : in System.Address;
      Time_Stamp : in SDL.Events.Time_Stamps;
      Window     : in System.Address;
      Mouse      : in SDL.Inputs.Mice.ID;
      X          : in SDL.Inputs.Mice.Motion_Value_Access;
      Y          : in SDL.Inputs.Mice.Motion_Value_Access)
   with Convention => C;

   procedure Scale_Mouse_Motion
     (User_Data  : in System.Address;
      Time_Stamp : in SDL.Events.Time_Stamps;
      Window     : in System.Address;
      Mouse      : in SDL.Inputs.Mice.ID;
      X          : in SDL.Inputs.Mice.Motion_Value_Access;
      Y          : in SDL.Inputs.Mice.Motion_Value_Access)
   is
   begin
      pragma Unreferenced (User_Data, Time_Stamp, Window, Mouse);

      if X /= null then
         X.all := X.all * 0.5;
      end if;

      if Y /= null then
         Y.all := Y.all * 0.5;
      end if;
   end Scale_Mouse_Motion;

   function SDL_Push_Event
     (Event : access SDL.Events.Queue.Event) return CE.bool with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_PushEvent";

   procedure Push (Event : aliased in out SDL.Events.Queue.Event) is
   begin
      if not Boolean (SDL_Push_Event (Event'Access)) then
         raise Program_Error with "SDL_PushEvent failed: " & SDL.Error.Get;
      end if;
   end Push;

   Virtual_Update_Calls : Natural := 0;
   Virtual_Player_Index : SDL.Inputs.Joysticks.Player_Indices := -1;
   Virtual_Rumble_Low   : Interfaces.Unsigned_16 := 0;
   Virtual_Rumble_High  : Interfaces.Unsigned_16 := 0;
   Virtual_Trigger_Left : Interfaces.Unsigned_16 := 0;
   Virtual_Trigger_Right : Interfaces.Unsigned_16 := 0;
   Virtual_LED_Red      : Interfaces.Unsigned_8 := 0;
   Virtual_LED_Green    : Interfaces.Unsigned_8 := 0;
   Virtual_LED_Blue     : Interfaces.Unsigned_8 := 0;
   Virtual_Effect_Size  : C.int := 0;
   Virtual_Sensors_Enabled : Boolean := False;

   procedure Virtual_Update (User_Data : in System.Address) with Convention => C;

   procedure Virtual_Update (User_Data : in System.Address) is
   begin
      pragma Unreferenced (User_Data);
      Virtual_Update_Calls := Virtual_Update_Calls + 1;
   end Virtual_Update;

   procedure Virtual_Set_Player_Index
     (User_Data    : in System.Address;
      Player_Index : in SDL.Inputs.Joysticks.Player_Indices)
   with Convention => C;

   procedure Virtual_Set_Player_Index
     (User_Data    : in System.Address;
      Player_Index : in SDL.Inputs.Joysticks.Player_Indices)
   is
   begin
      pragma Unreferenced (User_Data);
      Virtual_Player_Index := Player_Index;
   end Virtual_Set_Player_Index;

   function Virtual_Rumble
     (User_Data              : in System.Address;
      Low_Frequency_Rumble   : in Interfaces.Unsigned_16;
      High_Frequency_Rumble  : in Interfaces.Unsigned_16) return CE.bool
   with Convention => C;

   function Virtual_Rumble
     (User_Data              : in System.Address;
      Low_Frequency_Rumble   : in Interfaces.Unsigned_16;
      High_Frequency_Rumble  : in Interfaces.Unsigned_16) return CE.bool
   is
   begin
      pragma Unreferenced (User_Data);
      Virtual_Rumble_Low := Low_Frequency_Rumble;
      Virtual_Rumble_High := High_Frequency_Rumble;
      return To_C_Bool (True);
   end Virtual_Rumble;

   function Virtual_Rumble_Triggers
     (User_Data    : in System.Address;
      Left_Rumble  : in Interfaces.Unsigned_16;
      Right_Rumble : in Interfaces.Unsigned_16) return CE.bool
   with Convention => C;

   function Virtual_Rumble_Triggers
     (User_Data    : in System.Address;
      Left_Rumble  : in Interfaces.Unsigned_16;
      Right_Rumble : in Interfaces.Unsigned_16) return CE.bool
   is
   begin
      pragma Unreferenced (User_Data);
      Virtual_Trigger_Left := Left_Rumble;
      Virtual_Trigger_Right := Right_Rumble;
      return To_C_Bool (True);
   end Virtual_Rumble_Triggers;

   function Virtual_Set_LED
     (User_Data : in System.Address;
      Red       : in Interfaces.Unsigned_8;
      Green     : in Interfaces.Unsigned_8;
      Blue      : in Interfaces.Unsigned_8) return CE.bool
   with Convention => C;

   function Virtual_Set_LED
     (User_Data : in System.Address;
      Red       : in Interfaces.Unsigned_8;
      Green     : in Interfaces.Unsigned_8;
      Blue      : in Interfaces.Unsigned_8) return CE.bool
   is
   begin
      pragma Unreferenced (User_Data);
      Virtual_LED_Red := Red;
      Virtual_LED_Green := Green;
      Virtual_LED_Blue := Blue;
      return To_C_Bool (True);
   end Virtual_Set_LED;

   function Virtual_Send_Effect
     (User_Data : in System.Address;
      Data      : in System.Address;
      Size      : in C.int) return CE.bool
   with Convention => C;

   function Virtual_Send_Effect
     (User_Data : in System.Address;
      Data      : in System.Address;
      Size      : in C.int) return CE.bool
   is
   begin
      pragma Unreferenced (User_Data, Data);
      Virtual_Effect_Size := Size;
      return To_C_Bool (True);
   end Virtual_Send_Effect;

   function Virtual_Set_Sensors_Enabled
     (User_Data : in System.Address;
      Enabled   : in CE.bool) return CE.bool
   with Convention => C;

   function Virtual_Set_Sensors_Enabled
     (User_Data : in System.Address;
      Enabled   : in CE.bool) return CE.bool
   is
   begin
      pragma Unreferenced (User_Data);
      Virtual_Sensors_Enabled := Boolean (Enabled);
      return To_C_Bool (True);
   end Virtual_Set_Sensors_Enabled;

   SDL_Initialized   : Boolean := False;
   Window_Created    : Boolean := False;
   Joystick_Open     : Boolean := False;
   Controller_Open   : Boolean := False;

   Window     : SDL.Video.Windows.Window;
   Cursor     : SDL.Inputs.Mice.Cursors.Cursor;
   Joystick   : SDL.Inputs.Joysticks.Joystick;
   Controller : SDL.Inputs.Joysticks.Game_Controllers.Game_Controller;

   Modifiers  : SDL.Events.Keyboards.Key_Modifiers;
   Buttons    : SDL.Events.Mice.Button_Masks;
   Mouse_X    : SDL.Events.Mice.Movement_Values;
   Mouse_Y    : SDL.Events.Mice.Movement_Values;
   Event      : SDL.Events.Queue.Event;
   Capture_State : SDL.Inputs.Mice.Supported;

   Joystick_Axis_Event : aliased SDL.Events.Queue.Event :=
     (Kind          => SDL.Events.Queue.Is_Joystick_Axis_Event,
      Joystick_Axis =>
        (Event_Type => SDL.Events.Joysticks.Axis_Motion,
         Reserved   => 0,
         Time_Stamp => 0,
         Which      => 17,
         Axis       => 2,
         Padding_1  => 0,
         Padding_2  => 0,
         Padding_3  => 0,
         Value      => 1_234,
         Padding_4  => 0));

   Joystick_Button_Event : aliased SDL.Events.Queue.Event :=
     (Kind            => SDL.Events.Queue.Is_Joystick_Button_Event,
      Joystick_Button =>
        (Event_Type => SDL.Events.Joysticks.Button_Down,
         Reserved   => 0,
         Time_Stamp => 0,
         Which      => 17,
         Button     => 5,
         Down       => To_C_Bool (True),
         Padding_1  => 0,
         Padding_2  => 0));

   Joystick_Device_Event : aliased SDL.Events.Queue.Event :=
     (Kind            => SDL.Events.Queue.Is_Joystick_Device_Event,
      Joystick_Device =>
        (Event_Type => SDL.Events.Joysticks.Device_Added,
         Reserved   => 0,
         Time_Stamp => 0,
         Which      => 99));

   Controller_Axis_Event : aliased SDL.Events.Queue.Event :=
     (Kind            => SDL.Events.Queue.Is_Controller_Axis_Event,
      Controller_Axis =>
        (Event_Type => SDL.Events.Controllers.Axis_Motion,
         Reserved   => 0,
         Time_Stamp => 0,
         Which      => 17,
         Axis       => SDL.Events.Controllers.Left_X,
         Padding_1  => 0,
         Padding_2  => 0,
         Padding_3  => 0,
         Value      => -2_048,
         Padding_4  => 0));

   Controller_Button_Event : aliased SDL.Events.Queue.Event :=
     (Kind              => SDL.Events.Queue.Is_Controller_Button_Event,
      Controller_Button =>
        (Event_Type => SDL.Events.Controllers.Button_Down,
         Reserved   => 0,
         Time_Stamp => 0,
         Which      => 17,
         Button     => SDL.Events.Controllers.A,
         Down       => To_C_Bool (True),
         Padding_1  => 0,
         Padding_2  => 0));

   Controller_Device_Event : aliased SDL.Events.Queue.Event :=
     (Kind              => SDL.Events.Queue.Is_Controller_Device_Event,
      Controller_Device =>
        (Event_Type => SDL.Events.Controllers.Device_Remapped,
         Reserved   => 0,
         Time_Stamp => 0,
         Which      => 17));

   Controller_Touchpad_Event : aliased SDL.Events.Queue.Event :=
     (Kind                => SDL.Events.Queue.Is_Controller_Touchpad_Event,
      Controller_Touchpad =>
        (Event_Type => SDL.Events.Controllers.Touchpad_Motion,
         Reserved   => 0,
         Time_Stamp => 0,
         Which      => 17,
         Touchpad   => 1,
         Finger     => 0,
         X          => 0.25,
         Y          => 0.75,
         Pressure   => 0.5));

   Controller_Sensor_Event : aliased SDL.Events.Queue.Event :=
     (Kind              => SDL.Events.Queue.Is_Controller_Sensor_Event,
      Controller_Sensor =>
        (Event_Type        => SDL.Events.Controllers.Sensor_Update,
         Reserved          => 0,
         Time_Stamp        => 0,
         Which             => 17,
         Sensor            => 3,
         Data              => (0 => 1.0, 1 => 2.0, 2 => 3.0),
         Sensor_Time_Stamp => 123));

   procedure Drain_Events is
      Drained : SDL.Events.Queue.Event;
   begin
      while SDL.Events.Queue.Poll (Drained) loop
         null;
      end loop;
   end Drain_Events;
begin
   if not SDL.Initialise
       (SDL.Enable_Video or SDL.Enable_Events or SDL.Enable_Joystick or SDL.Enable_Gamepad)
   then
      raise Program_Error with "SDL initialization failed: " & SDL.Error.Get;
   end if;

   SDL_Initialized := True;

   SDL.Video.Windows.Makers.Create
     (Win    => Window,
      Title  => "sdl3ada input smoke",
      X      => SDL.Video.Windows.Centered_Window_Position,
      Y      => SDL.Video.Windows.Centered_Window_Position,
      Width  => 96,
      Height => 96);
   Window_Created := True;

   while SDL.Events.Queue.Poll (Event) loop
      null;
   end loop;

   Require
     (SDL.Inputs.Keyboards.Get_State /= null,
      "SDL_GetKeyboardState returned a null state pointer");

   declare
      Keyboard_IDs : constant SDL.Inputs.Keyboards.ID_Lists :=
        SDL.Inputs.Keyboards.Get_Keyboards;
   begin
      Require
        ((Keyboard_IDs'Length = 0) = (not SDL.Inputs.Keyboards.Has_Keyboard),
         "Keyboard enumeration did not match SDL_HasKeyboard");

      for Keyboard_ID of Keyboard_IDs loop
         declare
            Keyboard_Name : constant String :=
              SDL.Inputs.Keyboards.Name (Keyboard_ID);
         begin
            pragma Unreferenced (Keyboard_Name);
         end;
      end loop;
   end;

   Modifiers := SDL.Inputs.Keyboards.Get_Modifiers;
   SDL.Inputs.Keyboards.Set_Modifiers
     (SDL.Events.Keyboards.Modifier_Left_Shift);
   Require
     (SDL.Inputs.Keyboards.Get_Modifiers = SDL.Events.Keyboards.Modifier_Left_Shift,
      "Modifier round-trip failed");
   SDL.Inputs.Keyboards.Set_Modifiers (Modifiers);

   declare
      Derived_Key       : constant SDL.Events.Keyboards.Key_Codes :=
        SDL.Events.Keyboards.To_Key_Code
          (SDL.Events.Keyboards.Scan_Code_Space,
           SDL.Events.Keyboards.Modifier_None,
           Key_Event => False);
      Roundtrip_Modifier : SDL.Events.Keyboards.Key_Modifiers;
      Text_Props        : SDL.Properties.Property_Set := SDL.Properties.Create;
      Text_Rectangle    : constant SDL.Video.Rectangles.Rectangle :=
        (X => 1, Y => 2, Width => 8, Height => 12);
      Retrieved_Rect    : SDL.Video.Rectangles.Rectangle;
      Cursor_Offset     : SDL.Coordinate := -1;
   begin
      Require
        (Derived_Key = SDL.Events.Keyboards.To_Key_Code
           (SDL.Events.Keyboards.Scan_Code_Space),
         "Explicit scancode-to-keycode translation mismatched the default path");
      Require
        (SDL.Events.Keyboards.To_Scan_Code (Derived_Key, Roundtrip_Modifier) =
           SDL.Events.Keyboards.Scan_Code_Space,
         "Keycode-to-scancode round-trip failed");

      SDL.Properties.Set_Number
        (Text_Props,
         SDL.Inputs.Keyboards.Text_Input_Type_Property,
         SDL.Properties.Property_Numbers
           (SDL.Inputs.Keyboards.Text_Input_Types'Pos
              (SDL.Inputs.Keyboards.Number_Password_Visible)));
      SDL.Properties.Set_Number
        (Text_Props,
         SDL.Inputs.Keyboards.Text_Input_Capitalization_Property,
         SDL.Properties.Property_Numbers
           (SDL.Inputs.Keyboards.Capitalizations'Pos
              (SDL.Inputs.Keyboards.Capitalize_None)));
      SDL.Properties.Set_Boolean
        (Text_Props,
         SDL.Inputs.Keyboards.Text_Input_Autocorrect_Property,
         False);
      SDL.Properties.Set_Boolean
        (Text_Props,
         SDL.Inputs.Keyboards.Text_Input_Multiline_Property,
         False);

      SDL.Inputs.Keyboards.Start_Text_Input (Window, Text_Props);
      Require
        (SDL.Inputs.Keyboards.Is_Text_Input_Enabled (Window),
         "Text input did not enable on the explicit window");
      SDL.Inputs.Keyboards.Set_Text_Input_Rectangle
        (Window, Text_Rectangle, Cursor => 3);
      SDL.Inputs.Keyboards.Get_Text_Input_Rectangle
        (Window, Retrieved_Rect, Cursor_Offset);
      Require
        (Retrieved_Rect = Text_Rectangle and then Cursor_Offset = 3,
         "Text-input area round-trip failed");
      SDL.Inputs.Keyboards.Clear_Composition (Window);
      SDL.Inputs.Keyboards.Stop_Text_Input (Window);
      Require
        (not SDL.Inputs.Keyboards.Is_Text_Input_Enabled (Window),
         "Text input remained enabled after stop");
      pragma Unreferenced (Roundtrip_Modifier);
   end;

   Buttons := SDL.Inputs.Mice.Get_State (Mouse_X, Mouse_Y);
   Buttons := SDL.Inputs.Mice.Get_Global_State (Mouse_X, Mouse_Y);
   Buttons := SDL.Inputs.Mice.Get_Relative_State (Mouse_X, Mouse_Y);
   pragma Unreferenced (Buttons);

   declare
      Mouse_IDs : constant SDL.Inputs.Mice.ID_Lists := SDL.Inputs.Mice.Get_Mice;
   begin
      Require
        ((Mouse_IDs'Length = 0) = (not SDL.Inputs.Mice.Has_Mouse),
         "Mouse enumeration did not match SDL_HasMouse");

      for Mouse_ID of Mouse_IDs loop
         declare
            Mouse_Name : constant String := SDL.Inputs.Mice.Name (Mouse_ID);
         begin
            pragma Unreferenced (Mouse_Name);
         end;
      end loop;
   end;

   Capture_State := SDL.Inputs.Mice.Capture (False);
   pragma Unreferenced (Capture_State);
   SDL.Inputs.Mice.Show_Cursor (True);

   begin
      declare
         Cursor_A : SDL.Video.Surfaces.Surface;
         Cursor_B : SDL.Video.Surfaces.Surface;
         Frames   : constant SDL.Inputs.Mice.Cursors.Frame_Lists :=
           (1 => (Image => Cursor_A, Duration => 10),
            2 => (Image => Cursor_B, Duration => 0));
         Bitmap   : constant SDL.Inputs.Mice.Cursors.Bitmap_Data :=
           (16#18#, 16#3C#, 16#7E#, 16#FF#,
            16#FF#, 16#7E#, 16#3C#, 16#18#);
         Mask     : constant SDL.Inputs.Mice.Cursors.Bitmap_Data :=
           (16#FF#, 16#FF#, 16#FF#, 16#FF#,
            16#FF#, 16#FF#, 16#FF#, 16#FF#);
      begin
         SDL.Video.Surfaces.Makers.Create
           (Cursor_A,
            Size       => (Width => 8, Height => 8),
            BPP        => 32,
            Red_Mask   => 16#00FF_0000#,
            Blue_Mask  => 16#0000_00FF#,
            Green_Mask => 16#0000_FF00#,
            Alpha_Mask => 16#FF00_0000#);
         SDL.Video.Surfaces.Makers.Create
           (Cursor_B,
            Size       => (Width => 8, Height => 8),
            BPP        => 32,
            Red_Mask   => 16#00FF_0000#,
            Blue_Mask  => 16#0000_00FF#,
            Green_Mask => 16#0000_FF00#,
            Alpha_Mask => 16#FF00_0000#);

         Cursor.Create_System_Cursor (SDL.Inputs.Mice.Cursors.Arrow);
         Cursor.Set_Cursor;
         Cursor.Get_Cursor;
         Cursor.Get_Default_Cursor;

         if not Cursor.Is_Null then
            Cursor.Set_Cursor;
         end if;

         Cursor.Create_Colour_Cursor (Cursor_A, (X => 0, Y => 0));
         Cursor.Set_Cursor;

         Cursor.Create_Animated_Cursor
           (Frames   => Frames,
            Hot_Spot => (X => 0, Y => 0));
         Cursor.Set_Cursor;

         Cursor.Create_Bitmap_Cursor
           (Data     => Bitmap,
            Mask     => Mask,
            Size     => (Width => 8, Height => 8),
            Hot_Spot => (X => 0, Y => 0));
         Cursor.Set_Cursor;
      end;
   exception
      when SDL.Inputs.Mice.Mice_Error =>
         Ada.Text_IO.Put_Line
           ("Skipping cursor probe on this video backend: " & SDL.Error.Get);
         SDL.Error.Clear;
   end;

   declare
      Window_Has_Input_Focus : constant Boolean :=
        SDL.Inputs.Keyboards.Get_Focus = Window.Get_ID
        or else SDL.Inputs.Mice.Get_Focus = Window.Get_ID;
   begin
      if Window_Has_Input_Focus then
         SDL.Inputs.Mice.Set_Relative_Transform
           (Scale_Mouse_Motion'Unrestricted_Access);
         SDL.Inputs.Mice.Set_Relative_Mode (Window, True);
         Require
           (SDL.Inputs.Mice.In_Relative_Mode (Window),
            "Relative mouse mode did not enable for the explicit window");
         SDL.Inputs.Mice.Set_Relative_Mode (Window, False);
         SDL.Inputs.Mice.Clear_Relative_Transform;
      else
         Ada.Text_IO.Put_Line
           ("Skipping relative-mode probe without input focus on the smoke window");
      end if;
   end;

   if SDL.Inputs.Keyboards.Get_Focus /= 0 then
      SDL.Inputs.Mice.Set_Relative_Mode (True);
      Require
        (SDL.Inputs.Mice.In_Relative_Mode,
         "Relative mouse mode did not enable");
      SDL.Inputs.Mice.Set_Relative_Mode (False);
   end if;

   Require
     (SDL.Inputs.Joysticks.Image
        (SDL.Inputs.Joysticks.Value (Mapping_GUID)) = Mapping_GUID,
      "GUID round-trip failed");

   declare
      Updated_Existing : Boolean := False;
   begin
      SDL.Inputs.Joysticks.Game_Controllers.Add_Mapping
        (Mapping_String, Updated_Existing);
      Require
        (not Updated_Existing,
         "Synthetic gamepad mapping unexpectedly replaced an existing entry");

      declare
         Mapping : constant String :=
           SDL.Inputs.Joysticks.Game_Controllers.Get_Mapping
             (SDL.Inputs.Joysticks.Value (Known_Mapping_GUID));
      begin
         Require
           (Mapping'Length > 0,
            "Gamepad mapping lookup by GUID returned an empty string");
      end;
   end;

   Require
     (SDL.Inputs.Joysticks.Game_Controllers.Get_Axis ("leftx")
        = SDL.Events.Joysticks.Game_Controllers.Left_X,
      "Gamepad axis string lookup failed");
   Require
     (SDL.Inputs.Joysticks.Game_Controllers.Get_Button ("a")
        = SDL.Events.Joysticks.Game_Controllers.A,
      "Gamepad button string lookup failed");

   declare
      Mapping_File_Data : aliased constant String := IO_Mapping_String & ASCII.LF;
      Mapping_Stream    : SDL.RWops.RWops :=
        SDL.RWops.From_Const_Memory
          (Mapping_File_Data'Address,
           Mapping_File_Data'Length);
      Added_From_IO     : Natural := 0;
   begin
      SDL.Inputs.Joysticks.Game_Controllers.Add_Mappings_From_IO
        (Mapping_Stream, Added_From_IO);
      SDL.RWops.Close (Mapping_Stream);

      Require
        (Added_From_IO = 1,
         "Gamepad mapping load from IO did not add the synthetic mapping");

      declare
         All_Mappings : constant
           SDL.Inputs.Joysticks.Game_Controllers.Mapping_Lists :=
             SDL.Inputs.Joysticks.Game_Controllers.Get_Mappings;
      begin
         if All_Mappings'Length > 0 then
            null;
         end if;
      end;
   end;

   SDL.Inputs.Joysticks.Game_Controllers.Reload_Mappings;
   Require
     (SDL.Inputs.Joysticks.Game_Controllers.Type_From_String ("ps5")
        = SDL.Inputs.Joysticks.Game_Controllers.PS5,
      "Gamepad type string lookup failed");
   Require
     (SDL.Inputs.Joysticks.Game_Controllers.Image
        (SDL.Inputs.Joysticks.Game_Controllers.Standard)'Length > 0,
      "Gamepad type image lookup returned an empty string");
   Require
     (SDL.Inputs.Joysticks.Game_Controllers.Button_Label_For_Type
        (SDL.Inputs.Joysticks.Game_Controllers.PS5,
         SDL.Events.Joysticks.Game_Controllers.A)
         = SDL.Inputs.Joysticks.Game_Controllers.Label_Cross,
      "Gamepad button label lookup for PS5 south button failed");

   declare
      Touchpad_Description :
        constant SDL.Inputs.Joysticks.Virtual_Touchpad_Description_Access :=
          new SDL.Inputs.Joysticks.Virtual_Touchpad_Description'
            (Finger_Count => 2, Padding => 0, Padding_2 => 0, Padding_3 => 0);
      Sensor_Description :
        constant SDL.Inputs.Joysticks.Virtual_Sensor_Description_Access :=
          new SDL.Inputs.Joysticks.Virtual_Sensor_Description'
            (Sensor_Type => SDL.Sensors.Accelerometer, Rate => 60.0);
      Virtual_Description : constant SDL.Inputs.Joysticks.Virtual_Description :=
        (Kind                => SDL.Inputs.Joysticks.Gamepad,
         Vendor_ID           => 16#045E#,
         Product_ID          => 16#028E#,
         Axis_Count          => 6,
         Button_Count        => 6,
         Ball_Count          => 0,
         Hat_Count           => 1,
         Touchpad_Count      => 1,
         Sensor_Count        => 1,
         Button_Mask         =>
           Interfaces.Shift_Left (Interfaces.Unsigned_32 (1), 0),
         Axis_Mask           =>
           Interfaces.Shift_Left (Interfaces.Unsigned_32 (1), 0),
         Name                => US.To_Unbounded_String (Virtual_Name),
         Touchpads           => Touchpad_Description,
         Sensors             => Sensor_Description,
         User_Data           => System.Null_Address,
         Update              => Virtual_Update'Unrestricted_Access,
         Set_Player_Index    => Virtual_Set_Player_Index'Unrestricted_Access,
         Rumble              => Virtual_Rumble'Unrestricted_Access,
         Rumble_Triggers     => Virtual_Rumble_Triggers'Unrestricted_Access,
         Set_LED             => Virtual_Set_LED'Unrestricted_Access,
         Send_Effect         => Virtual_Send_Effect'Unrestricted_Access,
         Set_Sensors_Enabled => Virtual_Set_Sensors_Enabled'Unrestricted_Access,
         Cleanup             => null);
      Virtual_Sensor_Data : constant SDL.Sensors.Data_Values :=
        (0 => 1.0, 1 => 2.0, 2 => 3.0);
      Effect_Data : constant SDL.Inputs.Joysticks.Byte_Lists :=
        (0 => 16#AA#, 1 => 16#55#);
      Virtual_Instance : SDL.Events.Joysticks.IDs := 0;
      Virtual_GUID     : SDL.Inputs.Joysticks.GUIDs;
      Virtual_Joystick : SDL.Inputs.Joysticks.Joystick;
      Virtual_Gamepad  : SDL.Inputs.Joysticks.Game_Controllers.Game_Controller;
      Virtual_Joystick_Open : Boolean := False;
      Virtual_Gamepad_Open  : Boolean := False;
   begin
      Virtual_Update_Calls := 0;
      Virtual_Player_Index := -1;
      Virtual_Rumble_Low := 0;
      Virtual_Rumble_High := 0;
      Virtual_Trigger_Left := 0;
      Virtual_Trigger_Right := 0;
      Virtual_LED_Red := 0;
      Virtual_LED_Green := 0;
      Virtual_LED_Blue := 0;
      Virtual_Effect_Size := 0;
      Virtual_Sensors_Enabled := False;

      Virtual_Instance := SDL.Inputs.Joysticks.Attach_Virtual (Virtual_Description);
      Drain_Events;

      Require
        (SDL.Inputs.Joysticks.Is_Virtual (Virtual_Instance),
         "Attached virtual joystick did not report as virtual");
      Require
        (SDL.Inputs.Joysticks.Has_Joystick,
         "SDL_HasJoystick returned false after attaching a virtual device");

      declare
         IDs   : constant SDL.Inputs.Joysticks.ID_Lists :=
           SDL.Inputs.Joysticks.Get_Joysticks;
         Found : Boolean := False;
      begin
         for ID of IDs loop
            if ID = Virtual_Instance then
               Found := True;
               exit;
            end if;
         end loop;

         if Found then
            null;
         end if;
      end;

      Require
        (SDL.Inputs.Joysticks.Name (Virtual_Instance) = Virtual_Name,
         "Virtual joystick name lookup by ID failed");
      Require
        (SDL.Inputs.Joysticks.Vendor (Virtual_Instance) = 16#045E#,
         "Virtual joystick vendor lookup by ID failed");
      Require
        (SDL.Inputs.Joysticks.Product (Virtual_Instance) = 16#028E#,
         "Virtual joystick product lookup by ID failed");
      Require
        (SDL.Inputs.Joysticks.Get_Type (Virtual_Instance) = SDL.Inputs.Joysticks.Gamepad,
         "Virtual joystick type lookup by ID failed");

      Virtual_GUID := SDL.Inputs.Joysticks.GUID (Virtual_Instance);

      declare
         GUID_Vendor  : SDL.Inputs.Joysticks.Vendor_IDs := 0;
         GUID_Product : SDL.Inputs.Joysticks.Product_IDs := 0;
         GUID_Version : SDL.Inputs.Joysticks.Version_Numbers := 0;
         GUID_CRC16   : SDL.Inputs.Joysticks.CRC16_Values := 0;
      begin
         SDL.Inputs.Joysticks.GUID_Info
           (Virtual_GUID, GUID_Vendor, GUID_Product, GUID_Version, GUID_CRC16);
         pragma Unreferenced (GUID_Vendor, GUID_Product, GUID_Version, GUID_CRC16);
      end;

      SDL.Inputs.Joysticks.Game_Controllers.Set_Mapping
        (Virtual_Instance,
         SDL.Inputs.Joysticks.Image (Virtual_GUID)
         & "," & Virtual_Name & ","
         & "a:b0,b:b1,x:b2,y:b3,back:b4,start:b5,leftx:a0,lefty:a1,"
         & "rightx:a2,righty:a3,lefttrigger:a4,righttrigger:a5");
      SDL.Events.Joysticks.Update;
      SDL.Events.Joysticks.Game_Controllers.Update;
      Drain_Events;

      Require
        (SDL.Inputs.Joysticks.Game_Controllers.Has_Gamepad,
         "SDL_HasGamepad returned false after mapping a virtual gamepad");

      declare
         IDs   : constant SDL.Inputs.Joysticks.ID_Lists :=
           SDL.Inputs.Joysticks.Game_Controllers.Get_Gamepads;
         Found : Boolean := False;
      begin
         for ID of IDs loop
            if ID = Virtual_Instance then
               Found := True;
               exit;
            end if;
         end loop;

         if Found then
            null;
         end if;
      end;

      SDL.Inputs.Joysticks.Open (Virtual_Joystick, Virtual_Instance);
      Virtual_Joystick_Open := True;
      SDL.Inputs.Joysticks.Game_Controllers.Open (Virtual_Gamepad, Virtual_Instance);
      Virtual_Gamepad_Open := True;

      Require
        (SDL.Inputs.Joysticks.Instance (Virtual_Joystick) = Virtual_Instance,
         "Opened virtual joystick did not round-trip its instance ID");
      Require
        (SDL.Inputs.Joysticks.Game_Controllers.Get_ID (Virtual_Gamepad) = Virtual_Instance,
         "Opened virtual gamepad did not round-trip its instance ID");

      SDL.Inputs.Joysticks.Set_Player_Index (Virtual_Joystick, 2);
      Require
        (Virtual_Player_Index = 2
           and then SDL.Inputs.Joysticks.Player_Index (Virtual_Joystick) = 2,
         "Virtual joystick player-index round-trip failed");
      SDL.Inputs.Joysticks.Game_Controllers.Set_Player_Index (Virtual_Gamepad, 2);
      Require
        (SDL.Inputs.Joysticks.Game_Controllers.Player_Index (Virtual_Gamepad) = 2,
         "Virtual gamepad player-index round-trip failed");

      declare
         Borrowed_Joystick : constant SDL.Inputs.Joysticks.Joystick :=
           SDL.Inputs.Joysticks.Get_From_Player_Index (2);
         Borrowed_Gamepad  : constant
           SDL.Inputs.Joysticks.Game_Controllers.Game_Controller :=
             SDL.Inputs.Joysticks.Game_Controllers.Get_From_Player_Index (2);
      begin
         Require
           (SDL.Inputs.Joysticks.Instance (Borrowed_Joystick) = Virtual_Instance,
            "Borrowed joystick lookup by player index failed");
         Require
           (SDL.Inputs.Joysticks.Game_Controllers.Get_ID (Borrowed_Gamepad) =
              Virtual_Instance,
            "Borrowed gamepad lookup by player index failed");
      end;

      SDL.Inputs.Joysticks.Set_Virtual_Axis (Virtual_Joystick, 0, 2_345);
      SDL.Inputs.Joysticks.Set_Virtual_Button (Virtual_Joystick, 0, True);
      SDL.Inputs.Joysticks.Set_Virtual_Hat
        (Virtual_Joystick, 0, SDL.Events.Joysticks.Hat_Right_Up);
      SDL.Inputs.Joysticks.Set_Virtual_Touchpad
        (Virtual_Joystick, 0, 0, True, 0.25, 0.75, 0.5);
      SDL.Inputs.Joysticks.Send_Virtual_Sensor_Data
        (Virtual_Joystick,
         SDL.Sensors.Accelerometer,
         123,
         Virtual_Sensor_Data);
      SDL.Events.Joysticks.Update;
      SDL.Events.Joysticks.Game_Controllers.Update;

      Require
        (Virtual_Update_Calls > 0,
         "Virtual joystick update callback did not run");
      Require
        (SDL.Inputs.Joysticks.Axis_Value (Virtual_Joystick, 0) = 2_345,
         "Virtual joystick axis state did not round-trip");
      Require
        (SDL.Inputs.Joysticks.Hat_Value (Virtual_Joystick, 0) =
           SDL.Events.Joysticks.Hat_Right_Up,
         "Virtual joystick hat state did not round-trip");
      Require
        (SDL.Inputs.Joysticks.Is_Button_Pressed (Virtual_Joystick, 0) =
           SDL.Events.Pressed,
         "Virtual joystick button state did not round-trip");

      declare
         Initial_State_Available : Boolean := False;
         Initial_State           : SDL.Events.Joysticks.Axes_Values := 0;
         Joystick_Properties     : constant SDL.Properties.Property_Set :=
           SDL.Inputs.Joysticks.Get_Properties (Virtual_Joystick);
         Joystick_Power_Percent  : SDL.Inputs.Joysticks.Battery_Percentages := -1;
         Joystick_Power_State    : constant SDL.Power.State :=
           SDL.Inputs.Joysticks.Get_Power_Info
             (Virtual_Joystick, Joystick_Power_Percent);
      begin
         Initial_State_Available :=
           SDL.Inputs.Joysticks.Get_Axis_Initial_State
             (Virtual_Joystick, 0, Initial_State);
         Require
           (not SDL.Properties.Is_Null (Joystick_Properties),
            "Virtual joystick properties unexpectedly came back null");
         pragma Unreferenced
           (Initial_State_Available,
            Initial_State,
            Joystick_Power_Percent,
            Joystick_Power_State);
      end;

      SDL.Inputs.Joysticks.Rumble (Virtual_Joystick, 11, 22, 33);
      Require
        (Virtual_Rumble_Low = 11 and then Virtual_Rumble_High = 22,
         "Virtual joystick rumble callback did not receive the expected data");
      SDL.Inputs.Joysticks.Rumble_Triggers (Virtual_Joystick, 44, 55, 66);
      Require
        (Virtual_Trigger_Left = 44 and then Virtual_Trigger_Right = 55,
         "Virtual joystick trigger rumble callback did not receive the expected data");
      SDL.Inputs.Joysticks.Set_LED (Virtual_Joystick, 1, 2, 3);
      Require
        (Virtual_LED_Red = 1 and then Virtual_LED_Green = 2 and then Virtual_LED_Blue = 3,
         "Virtual joystick LED callback did not receive the expected data");
      SDL.Inputs.Joysticks.Send_Effect (Virtual_Joystick, Effect_Data);
      Require
        (Virtual_Effect_Size = 2,
         "Virtual joystick effect callback did not receive the expected payload size");

      Require
        (SDL.Inputs.Joysticks.Game_Controllers.Get_Name (Virtual_Instance) = Virtual_Name,
         "Virtual gamepad name lookup by ID failed");
      Require
        (SDL.Inputs.Joysticks.Game_Controllers.Get_Mapping (Virtual_Instance)'Length > 0,
         "Virtual gamepad mapping lookup by ID returned an empty string");
      Require
        (SDL.Inputs.Joysticks.Game_Controllers.Get_Mapping (Virtual_Gamepad)'Length > 0,
         "Virtual gamepad mapping lookup by handle returned an empty string");
      Require
        (SDL.Inputs.Joysticks.Game_Controllers.Has_Axis
           (Virtual_Gamepad, SDL.Events.Joysticks.Game_Controllers.Left_X),
         "Virtual gamepad did not report the mapped left X axis");
      Require
        (SDL.Inputs.Joysticks.Game_Controllers.Has_Button
           (Virtual_Gamepad, SDL.Events.Joysticks.Game_Controllers.A),
         "Virtual gamepad did not report the mapped south button");
      Require
        (SDL.Inputs.Joysticks.Game_Controllers.Axis_Value
           (Virtual_Gamepad, SDL.Events.Joysticks.Game_Controllers.Left_X) = 2_345,
         "Virtual gamepad left X axis did not round-trip");
      Require
        (SDL.Inputs.Joysticks.Game_Controllers.Is_Button_Pressed
           (Virtual_Gamepad, SDL.Events.Joysticks.Game_Controllers.A) =
             SDL.Events.Pressed,
         "Virtual gamepad south button did not round-trip");
      Require
        (SDL.Inputs.Joysticks.Game_Controllers.Touchpads (Virtual_Gamepad) = 1,
         "Virtual gamepad touchpad count did not round-trip");
      Require
        (SDL.Inputs.Joysticks.Game_Controllers.Touchpad_Fingers
           (Virtual_Gamepad, 0) = 2,
         "Virtual gamepad touchpad finger count did not round-trip");

      declare
         Touch_State : constant
           SDL.Inputs.Joysticks.Game_Controllers.Touchpad_Finger_State :=
             SDL.Inputs.Joysticks.Game_Controllers.Touchpad_Finger
               (Virtual_Gamepad, 0, 0);
         Gamepad_Properties : constant SDL.Properties.Property_Set :=
           SDL.Inputs.Joysticks.Game_Controllers.Get_Properties (Virtual_Gamepad);
         Gamepad_Power_Percent : SDL.Inputs.Joysticks.Battery_Percentages := -1;
         Gamepad_Power_State : constant SDL.Power.State :=
           SDL.Inputs.Joysticks.Game_Controllers.Get_Power_Info
             (Virtual_Gamepad, Gamepad_Power_Percent);
         Binding_List : constant
           SDL.Inputs.Joysticks.Game_Controllers.Binding_Lists :=
             SDL.Inputs.Joysticks.Game_Controllers.Get_Bindings (Virtual_Gamepad);
      begin
         Require
           (Touch_State.Down and then Touch_State.X = 0.25 and then Touch_State.Y = 0.75,
            "Virtual gamepad touchpad finger state did not round-trip");
         Require
           (SDL.Inputs.Joysticks.Game_Controllers.Has_Sensor
              (Virtual_Gamepad, SDL.Sensors.Accelerometer),
            "Virtual gamepad did not report its synthetic accelerometer");
         SDL.Inputs.Joysticks.Game_Controllers.Set_Sensor_Enabled
           (Virtual_Gamepad, SDL.Sensors.Accelerometer, True);
         Require
           (Virtual_Sensors_Enabled
              and then SDL.Inputs.Joysticks.Game_Controllers.Sensor_Enabled
                (Virtual_Gamepad, SDL.Sensors.Accelerometer),
            "Virtual gamepad sensor enablement did not round-trip");
         declare
            Sensor_Rate : constant C.C_float :=
              SDL.Inputs.Joysticks.Game_Controllers.Sensor_Data_Rate
                (Virtual_Gamepad, SDL.Sensors.Accelerometer);
            Sensor_Data : constant SDL.Sensors.Data_Values :=
              SDL.Inputs.Joysticks.Game_Controllers.Get_Sensor_Data
                (Virtual_Gamepad, SDL.Sensors.Accelerometer, 3);
         begin
            if Sensor_Rate > 0.0 or else Sensor_Data (2) /= C.C_float (0.0) then
               null;
            end if;
         end;
         Require
           (not SDL.Properties.Is_Null (Gamepad_Properties),
            "Virtual gamepad properties unexpectedly came back null");
         if Binding_List'Length > 0 then
            null;
         end if;
         pragma Unreferenced (Gamepad_Power_Percent, Gamepad_Power_State);
      end;

      Require
        (SDL.Inputs.Joysticks.Game_Controllers.Button_Label
           (Virtual_Gamepad, SDL.Events.Joysticks.Game_Controllers.A)
           /= SDL.Inputs.Joysticks.Game_Controllers.Unknown_Label,
         "Virtual gamepad button-label lookup returned Unknown_Label");

      Require
        (SDL.Inputs.Joysticks.Game_Controllers.Rumble
           (Virtual_Gamepad, 100, 200, 30) = 0,
         "Virtual gamepad rumble returned failure");
      Require
        (Virtual_Rumble_Low = 100 and then Virtual_Rumble_High = 200,
         "Virtual gamepad rumble callback did not receive the expected data");
      SDL.Inputs.Joysticks.Game_Controllers.Rumble_Triggers
        (Virtual_Gamepad, 300, 400, 30);
      Require
        (Virtual_Trigger_Left = 300 and then Virtual_Trigger_Right = 400,
         "Virtual gamepad trigger rumble callback did not receive the expected data");
      SDL.Inputs.Joysticks.Game_Controllers.Set_LED (Virtual_Gamepad, 9, 8, 7);
      Require
        (Virtual_LED_Red = 9 and then Virtual_LED_Green = 8 and then Virtual_LED_Blue = 7,
         "Virtual gamepad LED callback did not receive the expected data");
      SDL.Inputs.Joysticks.Game_Controllers.Send_Effect (Virtual_Gamepad, Effect_Data);
      Require
        (Virtual_Effect_Size = 2,
         "Virtual gamepad effect callback did not receive the expected payload size");

      declare
         Button_Symbol : constant String :=
           SDL.Inputs.Joysticks.Game_Controllers.Apple_SF_Symbol_Name
             (Virtual_Gamepad, SDL.Events.Joysticks.Game_Controllers.A);
         Axis_Symbol   : constant String :=
           SDL.Inputs.Joysticks.Game_Controllers.Apple_SF_Symbol_Name
             (Virtual_Gamepad, SDL.Events.Joysticks.Game_Controllers.Left_X);
         Real_Type     : constant SDL.Inputs.Joysticks.Game_Controllers.Types :=
           SDL.Inputs.Joysticks.Game_Controllers.Get_Real_Type (Virtual_Gamepad);
         Steam_Handle  : constant Interfaces.Unsigned_64 :=
           SDL.Inputs.Joysticks.Game_Controllers.Steam_Handle (Virtual_Gamepad);
         Connection    : constant SDL.Inputs.Joysticks.Connection_States :=
           SDL.Inputs.Joysticks.Game_Controllers.Connection_State (Virtual_Gamepad);
      begin
         pragma Unreferenced (Axis_Symbol, Button_Symbol, Connection, Real_Type, Steam_Handle);
      end;

      SDL.Inputs.Joysticks.Game_Controllers.Close (Virtual_Gamepad);
      Virtual_Gamepad_Open := False;
      SDL.Inputs.Joysticks.Close (Virtual_Joystick);
      Virtual_Joystick_Open := False;
      SDL.Inputs.Joysticks.Detach_Virtual (Virtual_Instance);
   exception
      when others =>
         if Virtual_Gamepad_Open then
            SDL.Inputs.Joysticks.Game_Controllers.Close (Virtual_Gamepad);
         end if;

         if Virtual_Joystick_Open then
            SDL.Inputs.Joysticks.Close (Virtual_Joystick);
         end if;

         if Virtual_Instance /= 0 then
            begin
               SDL.Inputs.Joysticks.Detach_Virtual (Virtual_Instance);
            exception
               when others =>
                  null;
            end;
         end if;

         raise;
   end;

   declare
      Device_Total : constant SDL.Inputs.Joysticks.All_Devices :=
        SDL.Inputs.Joysticks.Total;
      First_Gamepad : SDL.Inputs.Joysticks.All_Devices := 0;
   begin
      Ada.Text_IO.Put_Line
        ("Joystick devices detected:"
         & Integer'Image (Integer (Device_Total)));

      if Device_Total > 0 then
         Ada.Text_IO.Put_Line
           ("First joystick name: "
            & SDL.Inputs.Joysticks.Name (SDL.Inputs.Joysticks.Devices (1)));

         SDL.Inputs.Joysticks.Makers.Create (1, Joystick);
         Joystick_Open := True;

         declare
            Axis_Count   : constant SDL.Events.Joysticks.Axes :=
              SDL.Inputs.Joysticks.Axes (Joystick);
            Ball_Count   : constant SDL.Events.Joysticks.Balls :=
              SDL.Inputs.Joysticks.Balls (Joystick);
            Button_Count : constant SDL.Events.Joysticks.Buttons :=
              SDL.Inputs.Joysticks.Buttons (Joystick);
            Hat_Count    : constant SDL.Events.Joysticks.Hats :=
              SDL.Inputs.Joysticks.Hats (Joystick);
            Attached     : constant Boolean :=
              SDL.Inputs.Joysticks.Is_Attached (Joystick);
            Haptic       : constant Boolean :=
              SDL.Inputs.Joysticks.Is_Haptic (Joystick);
         begin
            pragma Unreferenced (Attached, Ball_Count, Haptic);

            if Axis_Count > 0 then
               declare
                  Axis_Zero : constant SDL.Events.Joysticks.Axes_Values :=
                    SDL.Inputs.Joysticks.Axis_Value (Joystick, 0);
               begin
                  pragma Unreferenced (Axis_Zero);
               end;
            end if;

            if Hat_Count > 0 then
               declare
                  Hat_Zero : constant SDL.Events.Joysticks.Hat_Positions :=
                    SDL.Inputs.Joysticks.Hat_Value (Joystick, 0);
               begin
                  pragma Unreferenced (Hat_Zero);
               end;
            end if;

            if Button_Count > 0 then
               declare
                  Button_Zero : constant SDL.Events.Button_State :=
                    SDL.Inputs.Joysticks.Is_Button_Pressed (Joystick, 0);
               begin
                  pragma Unreferenced (Button_Zero);
               end;
            end if;
         end;

         for Index in 1 .. Natural (Device_Total) loop
            declare
               Device : constant SDL.Inputs.Joysticks.Devices :=
                 SDL.Inputs.Joysticks.Devices (Index);
            begin
               if SDL.Inputs.Joysticks.Game_Controllers.Is_Game_Controller (Device) then
                  First_Gamepad := SDL.Inputs.Joysticks.All_Devices (Index);
                  exit;
               end if;
            end;
         end loop;

         if First_Gamepad > 0 then
            SDL.Inputs.Joysticks.Game_Controllers.Makers.Create
              (SDL.Inputs.Joysticks.Devices (First_Gamepad), Controller);
            Controller_Open := True;

            declare
               Name_Value    : constant String :=
                 SDL.Inputs.Joysticks.Game_Controllers.Get_Name (Controller);
               Mapping_Value : constant String :=
                 SDL.Inputs.Joysticks.Game_Controllers.Get_Mapping (Controller);
               Attached      : constant Boolean :=
                 SDL.Inputs.Joysticks.Game_Controllers.Is_Attached (Controller);
               Has_Rumble    : constant Boolean :=
                 SDL.Inputs.Joysticks.Game_Controllers.Has_Rumble (Controller);
               Button_State  : constant SDL.Events.Button_State :=
                 SDL.Inputs.Joysticks.Game_Controllers.Is_Button_Pressed
                   (Controller, SDL.Events.Joysticks.Game_Controllers.A);
               Left_X_Value  : constant
                 SDL.Events.Joysticks.Game_Controllers.LR_Axes_Values :=
                   SDL.Inputs.Joysticks.Game_Controllers.Axis_Value
                     (Controller, SDL.Events.Joysticks.Game_Controllers.Left_X);
               Trigger_Value : constant
                 SDL.Events.Joysticks.Game_Controllers.Trigger_Axes_Values :=
                   SDL.Inputs.Joysticks.Game_Controllers.Axis_Value
                     (Controller, SDL.Events.Joysticks.Game_Controllers.Trigger_Left);
               Left_X_Bind   : constant
                 SDL.Inputs.Joysticks.Game_Controllers.Bindings :=
                   SDL.Inputs.Joysticks.Game_Controllers.Get_Binding
                     (Controller, SDL.Events.Joysticks.Game_Controllers.Left_X);
               A_Bind        : constant
                 SDL.Inputs.Joysticks.Game_Controllers.Bindings :=
                   SDL.Inputs.Joysticks.Game_Controllers.Get_Binding
                     (Controller, SDL.Events.Joysticks.Game_Controllers.A);
               Backing_Stick : constant SDL.Inputs.Joysticks.Joystick :=
                 SDL.Inputs.Joysticks.Game_Controllers.Get_Joystick (Controller);
            begin
               pragma Unreferenced
                 (A_Bind,
                  Attached,
                  Backing_Stick,
                  Button_State,
                  Has_Rumble,
                  Left_X_Bind,
                  Left_X_Value,
                  Mapping_Value,
                  Name_Value,
                  Trigger_Value);
            end;
         end if;
      end if;
   end;

   declare
      Joystick_Polling  : constant Boolean := SDL.Events.Joysticks.Is_Polling_Enabled;
      Controller_Polling : constant Boolean :=
        SDL.Events.Joysticks.Game_Controllers.Is_Polling_Enabled;
   begin
      SDL.Events.Joysticks.Disable_Polling;
      Require
        (not SDL.Events.Joysticks.Is_Polling_Enabled,
         "Joystick polling did not disable");
      SDL.Events.Joysticks.Enable_Polling;
      Require
        (SDL.Events.Joysticks.Is_Polling_Enabled,
         "Joystick polling did not enable");

      if not Joystick_Polling then
         SDL.Events.Joysticks.Disable_Polling;
      end if;

      SDL.Events.Joysticks.Game_Controllers.Disable_Polling;
      Require
        (not SDL.Events.Joysticks.Game_Controllers.Is_Polling_Enabled,
         "Gamepad polling did not disable");
      SDL.Events.Joysticks.Game_Controllers.Enable_Polling;
      Require
        (SDL.Events.Joysticks.Game_Controllers.Is_Polling_Enabled,
         "Gamepad polling did not enable");

      if not Controller_Polling then
         SDL.Events.Joysticks.Game_Controllers.Disable_Polling;
      end if;
   end;

   Drain_Events;

   Push (Joystick_Axis_Event);
   Push (Joystick_Button_Event);
   Push (Joystick_Device_Event);
   Push (Controller_Axis_Event);
   Push (Controller_Button_Event);
   Push (Controller_Device_Event);
   Push (Controller_Touchpad_Event);
   Push (Controller_Sensor_Event);

   Require (SDL.Events.Queue.Poll (Event), "Missing synthetic joystick axis event");
   Require
     (Event.Common.Event_Type = SDL.Events.Joysticks.Axis_Motion
        and then Event.Joystick_Axis.Which = 17
        and then Event.Joystick_Axis.Value = 1_234,
      "Synthetic joystick axis event payload mismatch");

   Require (SDL.Events.Queue.Poll (Event), "Missing synthetic joystick button event");
   Require
     (SDL.Events.Joysticks.Get_State (Event.Joystick_Button) = SDL.Events.Pressed,
      "Synthetic joystick button event payload mismatch");

   Require (SDL.Events.Queue.Poll (Event), "Missing synthetic joystick device event");
   Require
     (Event.Joystick_Device.Event_Type = SDL.Events.Joysticks.Device_Added
        and then Event.Joystick_Device.Which = 99,
      "Synthetic joystick device event payload mismatch");

   Require (SDL.Events.Queue.Poll (Event), "Missing synthetic controller axis event");
   Require
     (Event.Controller_Axis.Axis = SDL.Events.Controllers.Left_X
        and then Event.Controller_Axis.Value = -2_048,
      "Synthetic controller axis event payload mismatch");

   Require (SDL.Events.Queue.Poll (Event), "Missing synthetic controller button event");
   Require
     (SDL.Events.Controllers.Get_State (Event.Controller_Button) = SDL.Events.Pressed,
      "Synthetic controller button event payload mismatch");

   Require (SDL.Events.Queue.Poll (Event), "Missing synthetic controller device event");
   Require
     (Event.Controller_Device.Event_Type = SDL.Events.Controllers.Device_Remapped,
      "Synthetic controller device event payload mismatch");

   Require (SDL.Events.Queue.Poll (Event), "Missing synthetic controller touchpad event");
   Require
     (Event.Controller_Touchpad.Touchpad = 1
        and then Event.Controller_Touchpad.Finger = 0,
      "Synthetic controller touchpad event payload mismatch");

   Require (SDL.Events.Queue.Poll (Event), "Missing synthetic controller sensor event");
   Require
     (Event.Controller_Sensor.Sensor = 3
        and then Event.Controller_Sensor.Data (2) = C.C_float (3.0),
      "Synthetic controller sensor event payload mismatch");

   if Controller_Open then
      SDL.Inputs.Joysticks.Game_Controllers.Close (Controller);
      Controller_Open := False;
   end if;

   if Joystick_Open then
      SDL.Inputs.Joysticks.Close (Joystick);
      Joystick_Open := False;
   end if;

   SDL.Inputs.Mice.Cursors.Finalize (Cursor);

   if Window_Created then
      SDL.Video.Windows.Finalize (Window);
      Window_Created := False;
   end if;

   SDL.Quit;
   SDL_Initialized := False;

   Ada.Text_IO.Put_Line ("Input smoke completed successfully.");
exception
   when Error : others =>
      if Controller_Open then
         SDL.Inputs.Joysticks.Game_Controllers.Close (Controller);
      end if;

      if Joystick_Open then
         SDL.Inputs.Joysticks.Close (Joystick);
      end if;

      SDL.Inputs.Mice.Cursors.Finalize (Cursor);

      if Window_Created then
         SDL.Video.Windows.Finalize (Window);
      end if;

      if SDL_Initialized then
         SDL.Quit;
      end if;

      Ada.Text_IO.Put_Line
        ("Input smoke failed: " & Ada.Exceptions.Exception_Message (Error));

      declare
         Message : constant String := SDL.Error.Get;
      begin
         if Message /= "" then
            Ada.Text_IO.Put_Line ("SDL error: " & Message);
         end if;
      end;

      raise;
end Input_Smoke;
