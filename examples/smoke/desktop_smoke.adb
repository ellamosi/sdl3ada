with Ada.Exceptions;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with System;

with Interfaces;

with SDL;
with SDL.Dialogs;
with SDL.Error;
with SDL.Events.Queue;
with SDL.Message_Boxes;
with SDL.Properties;
with SDL.Timers;
with SDL.Trays;
with SDL.Video;
with SDL.Video.Surfaces;
with SDL.Video.Surfaces.Makers;
with SDL.Video.Windows;
with SDL.Video.Windows.Makers;

procedure Desktop_Smoke is
   package US renames Ada.Strings.Unbounded;

   use type SDL.Init_Flags;
   use type SDL.Trays.Entry_Flags;
   use type Interfaces.Integer_32;
   use type Interfaces.Unsigned_8;

   Tray_Callbacks : Interfaces.Integer_32 := 0;
   pragma Atomic (Tray_Callbacks);

   Dialog_Callbacks : Interfaces.Integer_32 := 0;
   pragma Atomic (Dialog_Callbacks);

   Dialog_Last_Status : Interfaces.Integer_32 := -1;
   pragma Atomic (Dialog_Last_Status);

   procedure Require (Condition : in Boolean; Message : in String) is
   begin
      if not Condition then
         raise Program_Error with Message;
      end if;
   end Require;

   function Is_Headless_Driver (Driver : in String) return Boolean is
     (Driver = "" or else Driver = "dummy" or else Driver = "offscreen");

   procedure On_Tray_Click
     (User_Data : in System.Address;
      Selected  : in SDL.Trays.Tray_Entry);

   procedure On_Tray_Click
     (User_Data : in System.Address;
      Selected  : in SDL.Trays.Tray_Entry)
   is
   begin
      pragma Unreferenced (User_Data);

      Tray_Callbacks := Tray_Callbacks + 1;
      Require (not SDL.Trays.Is_Null (Selected), "Tray callback should supply an entry");
   end On_Tray_Click;

   procedure On_Dialog_Result
     (User_Data       : in System.Address;
      Status          : in SDL.Dialogs.Statuses;
      Files           : in SDL.Dialogs.File_Path_Lists;
      Selected_Filter : in SDL.C.int;
      Error_Message   : in String);

   procedure On_Dialog_Result
     (User_Data       : in System.Address;
      Status          : in SDL.Dialogs.Statuses;
      Files           : in SDL.Dialogs.File_Path_Lists;
      Selected_Filter : in SDL.C.int;
      Error_Message   : in String)
   is
   begin
      pragma Unreferenced (User_Data, Files, Selected_Filter, Error_Message);

      Dialog_Callbacks := Dialog_Callbacks + 1;

      case Status is
         when SDL.Dialogs.Accepted =>
            Dialog_Last_Status := 0;
         when SDL.Dialogs.Cancelled =>
            Dialog_Last_Status := 1;
         when SDL.Dialogs.Failed =>
            Dialog_Last_Status := 2;
      end case;
   end On_Dialog_Result;

   procedure Exercise_Tray
     (Driver : in String;
      Window : in SDL.Video.Windows.Window)
   is
      pragma Unreferenced (Window);

      Bits       : constant := 32;
      Red_Mask   : constant Interfaces.Unsigned_32 := 16#00FF_0000#;
      Green_Mask : constant Interfaces.Unsigned_32 := 16#0000_FF00#;
      Blue_Mask  : constant Interfaces.Unsigned_32 := 16#0000_00FF#;
      Alpha_Mask : constant Interfaces.Unsigned_32 := 16#FF00_0000#;

      Icon      : SDL.Video.Surfaces.Surface;
      Tray      : SDL.Trays.Tray;
      Menu      : SDL.Trays.Menu;
      Action    : SDL.Trays.Tray_Entry;
      Toggle    : SDL.Trays.Tray_Entry;
      Nested    : SDL.Trays.Tray_Entry;
      Nested_Menu : SDL.Trays.Menu;
   begin
      if Is_Headless_Driver (Driver) then
         Ada.Text_IO.Put_Line
           ("Skipping tray runtime validation on headless video driver """
            & Driver & """");
         return;
      end if;

      SDL.Video.Surfaces.Makers.Create
        (Self       => Icon,
         Size       => (Width => 8, Height => 8),
         BPP        => SDL.Video.Surfaces.Pixel_Depths (Bits),
         Red_Mask   => SDL.Video.Surfaces.Colour_Masks (Red_Mask),
         Green_Mask => SDL.Video.Surfaces.Colour_Masks (Green_Mask),
         Blue_Mask  => SDL.Video.Surfaces.Colour_Masks (Blue_Mask),
         Alpha_Mask => SDL.Video.Surfaces.Colour_Masks (Alpha_Mask));

      begin
         SDL.Trays.Create (Self => Tray, Icon => Icon, Tooltip => "desktop-smoke");
      exception
         when E : SDL.Trays.Tray_Error =>
            Ada.Text_IO.Put_Line
              ("Skipping tray runtime validation on video driver """
               & Driver & """: " & Ada.Exceptions.Exception_Message (E));
            return;
      end;

      Menu := SDL.Trays.Create_Menu (Tray);
      Action := SDL.Trays.Append (Menu, "Open", SDL.Trays.Button);
      Toggle := SDL.Trays.Append
        (Menu, "Enabled", SDL.Trays.Checkbox or SDL.Trays.Checked);
      Nested := SDL.Trays.Append (Menu, "More", SDL.Trays.Submenu);
      Nested_Menu := SDL.Trays.Create_Submenu (Nested);

      Require
        (not SDL.Trays.Is_Null (SDL.Trays.Get_Menu (Tray)),
         "Tray menu should round-trip");
      Require
        (not SDL.Trays.Is_Null (SDL.Trays.Get_Submenu (Nested)),
         "Tray submenu should round-trip");
      Require
        (not SDL.Trays.Is_Null (SDL.Trays.Get_Parent (Action)),
         "Tray entry parent should round-trip");
      Require
        (not SDL.Trays.Is_Null (SDL.Trays.Get_Parent_Entry (Nested_Menu)),
         "Tray submenu parent entry should round-trip");
      Require
        (not SDL.Trays.Is_Null (SDL.Trays.Get_Parent_Tray (Menu)),
         "Tray menu parent tray should round-trip");

      SDL.Trays.Set_Label (Action, "Launch");
      Require
        (SDL.Trays.Get_Label (Action) = "Launch",
         "Tray entry label should round-trip");
      Require
        (not SDL.Trays.Is_Separator (Action),
         "Labeled tray entry should not be a separator");

      Require
        (SDL.Trays.Get_Checked (Toggle),
         "Checkbox tray entry should start checked");
      SDL.Trays.Set_Checked (Toggle, False);
      Require
        (not SDL.Trays.Get_Checked (Toggle),
         "Checkbox tray entry should clear");

      Require
        (SDL.Trays.Get_Enabled (Action),
         "Tray action should start enabled");
      SDL.Trays.Set_Enabled (Action, False);
      Require
        (not SDL.Trays.Get_Enabled (Action),
         "Tray action should disable");
      SDL.Trays.Set_Enabled (Action, True);

      declare
         Entries : constant SDL.Trays.Entry_Lists := SDL.Trays.Get_Entries (Menu);
      begin
         Require (Entries'Length = 3, "Tray entry enumeration length mismatch");
      end;

      SDL.Trays.Set_Callback (Action, On_Tray_Click'Unrestricted_Access);
      SDL.Trays.Click (Action);
      SDL.Trays.Update;
      SDL.Timers.Wait_Delay (10);

      Require (Tray_Callbacks > 0, "Expected tray callback after synthetic click");

      SDL.Trays.Clear_Callback (Action);
      SDL.Trays.Remove (Toggle);
      Require (SDL.Trays.Is_Null (Toggle), "Removed tray entry should clear its handle");

      SDL.Trays.Destroy (Tray);
      Require (SDL.Trays.Is_Null (Tray), "Destroyed tray should clear its handle");
   end Exercise_Tray;

   procedure Exercise_Message_Boxes
     (Driver : in String;
      Window : in SDL.Video.Windows.Window)
   is
      Buttons : constant SDL.Message_Boxes.Button_Lists :=
        (1 =>
           (Flags     => SDL.Message_Boxes.Return_Key_Default,
            Button_ID => 1,
            Text      => US.To_Unbounded_String ("OK")),
         2 =>
           (Flags     => SDL.Message_Boxes.Escape_Key_Default,
            Button_ID => 0,
            Text      => US.To_Unbounded_String ("Cancel")));

      Colors : constant SDL.Message_Boxes.Color_Scheme :=
        (SDL.Message_Boxes.Background        => (Red => 16#11#, Green => 16#22#, Blue => 16#33#),
         SDL.Message_Boxes.Text              => (Red => 16#EE#, Green => 16#EE#, Blue => 16#EE#),
         SDL.Message_Boxes.Button_Border     => (Red => 16#66#, Green => 16#66#, Blue => 16#66#),
         SDL.Message_Boxes.Button_Background => (Red => 16#22#, Green => 16#44#, Blue => 16#66#),
         SDL.Message_Boxes.Button_Selected   => (Red => 16#44#, Green => 16#88#, Blue => 16#AA#));

   begin
      Require (Buttons'Length = 2, "Custom message-box button count mismatch");
      Require
        (Colors (SDL.Message_Boxes.Text).Red = 16#EE#,
         "Custom message-box color scheme should round-trip");

      if Is_Headless_Driver (Driver) then
         Ada.Text_IO.Put_Line
           ("Skipping message-box runtime validation on headless video driver """
            & Driver & """");
         return;
      end if;

      pragma Unreferenced (Window);

      Ada.Text_IO.Put_Line
        ("Skipping message-box runtime validation on interactive video driver """
         & Driver & """ to avoid blocking the smoke run");
   end Exercise_Message_Boxes;

   procedure Exercise_Dialogs
     (Driver : in String;
      Window : in SDL.Video.Windows.Window)
   is
      Filters : constant SDL.Dialogs.File_Filter_Lists :=
        (1 =>
           (Name    => US.To_Unbounded_String ("Ada Sources"),
            Pattern => US.To_Unbounded_String ("adb;ads")),
         2 =>
           (Name    => US.To_Unbounded_String ("All Files"),
            Pattern => US.To_Unbounded_String ("*")));

      Props : SDL.Properties.Property_Set := SDL.Properties.Create;
      Callback_Access : constant SDL.Dialogs.File_Dialog_Callback :=
        On_Dialog_Result'Unrestricted_Access;
   begin
      pragma Unreferenced (Callback_Access);

      SDL.Properties.Set_Pointer
        (Props,
         SDL.Dialogs.Window_Pointer_Property,
         SDL.Video.Windows.Get_Internal (Window));
      SDL.Properties.Set_String
        (Props, SDL.Dialogs.Title_Property, "desktop-smoke dialog");
      SDL.Properties.Set_String
        (Props, SDL.Dialogs.Location_Property, ".");
      SDL.Properties.Set_Boolean
        (Props, SDL.Dialogs.Many_Property, True);

      Require
        (SDL.Properties.Get_String (Props, SDL.Dialogs.Title_Property) =
           "desktop-smoke dialog",
         "Dialog title property should round-trip");
      Require
        (SDL.Properties.Get_Boolean (Props, SDL.Dialogs.Many_Property),
         "Dialog many-select property should round-trip");
      Require (Filters'Length = 2, "Dialog filter count mismatch");

      if Is_Headless_Driver (Driver) then
         Ada.Text_IO.Put_Line
           ("Skipping dialog runtime validation on headless video driver """
            & Driver & """");
      else
         Ada.Text_IO.Put_Line
           ("Skipping dialog runtime validation on interactive video driver """
            & Driver & """ to avoid blocking the smoke run");
      end if;
   end Exercise_Dialogs;

   Window : SDL.Video.Windows.Window;
begin
   if not SDL.Initialise (SDL.Enable_Video) then
      raise Program_Error with "SDL initialization failed: " & SDL.Error.Get;
   end if;

   SDL.Video.Windows.Makers.Create
     (Win    => Window,
      Title  => "desktop-smoke",
      X      => 0,
      Y      => 0,
      Width  => 64,
      Height => 64,
      Flags  => SDL.Video.Windows.Hidden);

   declare
      Driver : constant String := SDL.Video.Current_Driver_Name;
   begin
      Ada.Text_IO.Put_Line ("Video driver: " & Driver);

      Exercise_Tray (Driver, Window);
      Exercise_Message_Boxes (Driver, Window);
      Exercise_Dialogs (Driver, Window);
   end;
end Desktop_Smoke;
