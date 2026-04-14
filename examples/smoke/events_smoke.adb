with Ada.Strings.Fixed;
with Ada.Text_IO;
with Ada.Unchecked_Conversion;

with Interfaces;
with Interfaces.C;
with Interfaces.C.Extensions;
with Interfaces.C.Strings;
with System;

with SDL;
with SDL.Error;
with SDL.Events;
with SDL.Events.Queue;
with SDL.Events.Files;
with SDL.Events.Keyboards;
with SDL.Events.Mice;
with SDL.Events.Touches;
with SDL.Events.Windows;
with SDL.Video.Windows;
with SDL.Video.Windows.Makers;

procedure Events_Smoke is
   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;
   package CS renames Interfaces.C.Strings;

   use type Interfaces.Integer_32;
   use type Interfaces.Unsigned_64;
   use type C.C_float;
   use type CS.chars_ptr;
   use type SDL.Events.Button_State;
   use type SDL.Events.Event_Codes;
   use type SDL.Events.Event_Types;
   use type SDL.Events.Queue.Event_Filter;
   use type SDL.Events.Keyboards.Scan_Codes;
   use type SDL.Events.Mice.Button_Clicks;
   use type SDL.Events.Mice.Button_Masks;
   use type SDL.Events.Mice.Buttons;
   use type SDL.Events.Touches.Touch_Device_Types;
   use type SDL.Events.Mice.Wheel_Directions;
   use type SDL.Events.Windows.Window_Event_ID;
   use type SDL.Init_Flags;
   use type SDL.Video.Windows.ID;
   use type System.Address;

   function To_C_Bool (Value : in Boolean) return CE.bool is
     (if Value then CE.bool'Val (1) else CE.bool'Val (0));

   function Nearly_Equal
     (Left  : in C.C_float;
      Right : in Float) return Boolean is
        (abs (Float (Left) - Right) < 0.001);

   procedure Require (Condition : in Boolean; Message : in String) is
   begin
      if not Condition then
         raise Program_Error with Message;
      end if;
   end Require;

   type Filter_State is record
      Calls       : Natural := 0;
      Reject_Type : SDL.Events.Event_Types := SDL.Events.First_Event;
   end record;

   type Watch_State is record
      Calls     : Natural := 0;
      Last_Type : SDL.Events.Event_Types := SDL.Events.First_Event;
   end record;

   type Filter_State_Access is access all Filter_State;
   pragma No_Strict_Aliasing (Filter_State_Access);

   type Watch_State_Access is access all Watch_State;
   pragma No_Strict_Aliasing (Watch_State_Access);

   function To_Filter_State is new Ada.Unchecked_Conversion
     (Source => System.Address,
      Target => Filter_State_Access);

   function To_Watch_State is new Ada.Unchecked_Conversion
     (Source => System.Address,
      Target => Watch_State_Access);

   function Reject_Filter
     (User_Data : in System.Address;
      Event     : access SDL.Events.Queue.Event) return CE.bool
   with Convention => C;

   function Watch_Filter
     (User_Data : in System.Address;
      Event     : access SDL.Events.Queue.Event) return CE.bool
   with Convention => C;

   function Reject_Filter
     (User_Data : in System.Address;
      Event     : access SDL.Events.Queue.Event) return CE.bool
   is
      State : constant Filter_State_Access := To_Filter_State (User_Data);
   begin
      if State /= null then
         State.Calls := State.Calls + 1;

         if Event /= null and then
             Event.Common.Event_Type = State.Reject_Type
         then
            return To_C_Bool (False);
         end if;
      end if;

      return To_C_Bool (True);
   end Reject_Filter;

   function Watch_Filter
     (User_Data : in System.Address;
      Event     : access SDL.Events.Queue.Event) return CE.bool
   is
      State : constant Watch_State_Access := To_Watch_State (User_Data);
   begin
      if State /= null and then Event /= null then
         State.Calls := State.Calls + 1;
         State.Last_Type := Event.Common.Event_Type;
      end if;

      return To_C_Bool (True);
   end Watch_Filter;

   SDL_Initialized : Boolean := False;
   Window_Created  : Boolean := False;
   Window          : SDL.Video.Windows.Window;

   Dropped_Name : CS.chars_ptr := CS.New_String ("synthetic-drop.gb");
   Editing_Text : CS.chars_ptr := CS.New_String ("compose");
   Input_Text   : CS.chars_ptr := CS.New_String ("z");

   Filter_Info : aliased Filter_State;
   Watch_Info  : aliased Watch_State;

   function Make_User_Event
     (Event_Type : in SDL.Events.Event_Types;
      Code       : in SDL.Events.Event_Codes)
      return SDL.Events.Queue.Event;

   function Make_Window_Event return SDL.Events.Queue.Event;
   function Make_Key_Down_Event return SDL.Events.Queue.Event;
   function Make_Text_Editing_Event return SDL.Events.Queue.Event;
   function Make_Text_Input_Event return SDL.Events.Queue.Event;
   function Make_Mouse_Motion_Event return SDL.Events.Queue.Event;
   function Make_Mouse_Button_Event return SDL.Events.Queue.Event;
   function Make_Mouse_Wheel_Event return SDL.Events.Queue.Event;
   function Make_Touch_Event return SDL.Events.Queue.Event;
   function Make_Drop_Event return SDL.Events.Queue.Event;
   function Make_Quit_Event return SDL.Events.Queue.Event;

   function Make_User_Event
     (Event_Type : in SDL.Events.Event_Types;
      Code       : in SDL.Events.Event_Codes)
      return SDL.Events.Queue.Event
   is
   begin
      return
        (Kind => SDL.Events.Queue.Is_User_Event,
         User =>
           (Event_Type => Event_Type,
            Reserved   => 0,
            Time_Stamp => 0,
            Window_ID  => SDL.Events.Window_IDs (Window.Get_ID),
            Code       => Code,
            Data_1     => Filter_Info'Address,
            Data_2     => System.Null_Address));
   end Make_User_Event;

   function Make_Window_Event return SDL.Events.Queue.Event is
   begin
      return
        (Kind   => SDL.Events.Queue.Is_Window_Event,
         Window =>
           (Event_Type => SDL.Events.Windows.To_Event_Type (SDL.Events.Windows.Moved),
            Reserved   => 0,
            Time_Stamp => 0,
            ID         => Window.Get_ID,
            Data_1     => 640,
            Data_2     => 480));
   end Make_Window_Event;

   function Make_Key_Down_Event return SDL.Events.Queue.Event is
   begin
      return
        (Kind     => SDL.Events.Queue.Is_Keyboard_Event,
         Keyboard =>
           (Event_Type => SDL.Events.Keyboards.Key_Down,
            Reserved   => 0,
            Time_Stamp => 0,
            Window_ID  => Window.Get_ID,
            Which      => 0,
            Key_Sym    =>
              (Scan_Code => SDL.Events.Keyboards.Scan_Code_Z,
               Key_Code  => SDL.Events.Keyboards.To_Key_Code (SDL.Events.Keyboards.Scan_Code_Z),
               Modifiers => SDL.Events.Keyboards.Modifier_None),
            Raw        => 0,
            Down       => To_C_Bool (True),
            Repeat     => To_C_Bool (False)));
   end Make_Key_Down_Event;

   function Make_Text_Editing_Event return SDL.Events.Queue.Event is
   begin
      return
        (Kind         => SDL.Events.Queue.Is_Text_Editing_Event,
         Text_Editing =>
           (Event_Type => SDL.Events.Keyboards.Text_Editing,
            Reserved   => 0,
            Time_Stamp => 0,
            Window_ID  => Window.Get_ID,
            Text       => Editing_Text,
            Start      => 2,
            Length     => 3));
   end Make_Text_Editing_Event;

   function Make_Text_Input_Event return SDL.Events.Queue.Event is
   begin
      return
        (Kind       => SDL.Events.Queue.Is_Text_Input_Event,
         Text_Input =>
           (Event_Type => SDL.Events.Keyboards.Text_Input,
            Reserved   => 0,
            Time_Stamp => 0,
            Window_ID  => Window.Get_ID,
            Text       => Input_Text));
   end Make_Text_Input_Event;

   function Make_Mouse_Motion_Event return SDL.Events.Queue.Event is
   begin
      return
        (Kind         => SDL.Events.Queue.Is_Mouse_Motion_Event,
         Mouse_Motion =>
           (Event_Type => SDL.Events.Mice.Motion,
            Reserved   => 0,
            Time_Stamp => 0,
            Window     => Window.Get_ID,
            Which      => 0,
            Mask       => SDL.Events.Mice.Left_Mask,
            X          => 320.5,
            Y          => 240.25,
            X_Relative => 2.0,
            Y_Relative => -3.5));
   end Make_Mouse_Motion_Event;

   function Make_Mouse_Button_Event return SDL.Events.Queue.Event is
   begin
      return
        (Kind         => SDL.Events.Queue.Is_Mouse_Button_Event,
         Mouse_Button =>
           (Event_Type => SDL.Events.Mice.Button_Down,
            Reserved   => 0,
            Time_Stamp => 0,
            Window     => Window.Get_ID,
            Which      => 0,
            Button     => SDL.Events.Mice.Left,
            Down       => To_C_Bool (True),
            Clicks     => 2,
            Padding    => 0,
            X          => 320.5,
            Y          => 240.25));
   end Make_Mouse_Button_Event;

   function Make_Mouse_Wheel_Event return SDL.Events.Queue.Event is
   begin
      return
        (Kind        => SDL.Events.Queue.Is_Mouse_Wheel_Event,
         Mouse_Wheel =>
           (Event_Type => SDL.Events.Mice.Wheel,
            Reserved   => 0,
            Time_Stamp => 0,
            Window     => Window.Get_ID,
            Which      => 0,
            X          => 1.5,
            Y          => -2.5,
            Direction  => SDL.Events.Mice.Flipped,
            Mouse_X    => 321.0,
            Mouse_Y    => 241.0,
            Integer_X  => 1,
            Integer_Y  => -2));
   end Make_Mouse_Wheel_Event;

   function Make_Touch_Event return SDL.Events.Queue.Event is
   begin
      return
        (Kind         => SDL.Events.Queue.Is_Touch_Finger_Event,
         Touch_Finger =>
           (Event_Type => SDL.Events.Touches.Finger_Motion,
            Reserved   => 0,
            Time_Stamp => 0,
            Touch_ID   => 11,
            Finger_ID  => 19,
            X          => 0.5,
            Y          => 0.75,
            Delta_X    => 0.1,
            Delta_Y    => -0.2,
            Pressure   => 0.8,
            Window_ID  => Window.Get_ID));
   end Make_Touch_Event;

   function Make_Drop_Event return SDL.Events.Queue.Event is
   begin
      return
        (Kind => SDL.Events.Queue.Is_Drop_Event,
         Drop =>
           (Event_Type => SDL.Events.Files.Drop_File,
            Reserved   => 0,
            Time_Stamp => 0,
            Window_ID  => Window.Get_ID,
            X          => 12.0,
            Y          => 34.0,
            Source     => CS.Null_Ptr,
            File_Name  => Dropped_Name));
   end Make_Drop_Event;

   function Make_Quit_Event return SDL.Events.Queue.Event is
   begin
      return
        (Kind   => SDL.Events.Queue.Is_Event,
         Common =>
           (Event_Type => SDL.Events.Quit,
            Reserved   => 0,
            Time_Stamp => 0));
   end Make_Quit_Event;

   procedure Push
     (Event   : in SDL.Events.Queue.Event;
      Message : in String) is
   begin
      if not SDL.Events.Queue.Push (Event) then
         declare
            Last_Error : constant String := SDL.Error.Get;
         begin
            if Last_Error = "" then
               raise Program_Error with Message;
            end if;

            raise Program_Error with Message & ": " & Last_Error;
         end;
      end if;
   end Push;

   Event : SDL.Events.Queue.Event;
begin
   if not SDL.Initialise (SDL.Enable_Video or SDL.Enable_Events) then
      Ada.Text_IO.Put_Line ("SDL initialization failed: " & SDL.Error.Get);
      raise Program_Error with "SDL initialization failed";
   end if;

   SDL_Initialized := True;

   SDL.Video.Windows.Makers.Create
     (Win    => Window,
      Title  => "sdl3ada events smoke",
      X      => SDL.Video.Windows.Centered_Window_Position,
      Y      => SDL.Video.Windows.Centered_Window_Position,
      Width  => 64,
      Height => 64,
      Flags  => SDL.Video.Windows.Hidden);
   Window_Created := True;

   declare
      Touches : constant SDL.Events.Touches.ID_Lists :=
        SDL.Events.Touches.Get_Touches;
   begin
      if Touches'Length = 0 then
         Ada.Text_IO.Put_Line ("No touch devices reported.");
      else
         for Touch of Touches loop
            declare
               Name    : constant String := SDL.Events.Touches.Name (Touch);
               Kind    : constant SDL.Events.Touches.Touch_Device_Types :=
                 SDL.Events.Touches.Device_Type (Touch);
               Fingers : constant SDL.Events.Touches.Finger_Lists :=
                 SDL.Events.Touches.Get_Fingers (Touch);
            begin
               Require
                 (Kind /= SDL.Events.Touches.Invalid_Touch_Device,
                  "Touch device type query returned invalid");
               Ada.Text_IO.Put_Line
                 ("Touch device:"
                  & Interfaces.Unsigned_64'Image (Touch)
                  & " type="
                  & SDL.Events.Touches.Touch_Device_Types'Image (Kind)
                  & " name="""
                  & Name
                  & """ active fingers="
                  & Integer'Image (Fingers'Length));
            end;
         end loop;
      end if;
   end;

   SDL.Events.Queue.Pump;
   SDL.Events.Queue.Flush (SDL.Events.First_Event, SDL.Events.Last_Event);

   Require
     (SDL.Events.Keyboards.Value ("Z") = SDL.Events.Keyboards.Scan_Code_Z,
      "Scancode lookup for Z failed");
   Require
     (SDL.Events.Keyboards.Image (SDL.Events.Keyboards.Scan_Code_Space) = "Space",
      "Scancode name lookup for Space failed");
   Require
     (SDL.Events.Keyboards.Value ("Space") =
        SDL.Events.Keyboards.To_Key_Code (SDL.Events.Keyboards.Scan_Code_Space),
      "Keycode lookup for Space failed");
   Require
     (SDL.Events.Keyboards.To_Scan_Code (SDL.Events.Keyboards.Value ("Space")) =
        SDL.Events.Keyboards.Scan_Code_Space,
      "Keycode-to-scancode conversion for Space failed");

   declare
      Saved_Filter    : SDL.Events.Queue.Event_Filter := null;
      Saved_User_Data : System.Address := System.Null_Address;
   begin
      Require
        (not SDL.Events.Queue.Get_Filter (Saved_Filter, Saved_User_Data),
         "Unexpected event filter was already set");
      Require
        (Saved_Filter = null and then Saved_User_Data = System.Null_Address,
         "Unexpected saved event filter metadata");
   end;

   declare
      Custom_First  : constant SDL.Events.Event_Types :=
        SDL.Events.Queue.Register (2);
      Custom_Second : constant SDL.Events.Event_Types := Custom_First + 1;
      Description   : constant String :=
        SDL.Events.Queue.Get_Description (Make_Window_Event);
   begin
      Require (Custom_First /= 0, "Custom event registration failed");
      Require
        (Ada.Strings.Fixed.Index (Description, "SDL_EVENT_WINDOW_MOVED") > 0,
         "Event description did not include the window event name");
      Require
        (SDL.Events.Queue.Get_Window_ID (Make_Window_Event) = Window.Get_ID,
         "Get_Window_ID did not resolve the synthetic window event");

      Require
        (not SDL.Events.Queue.Wait (Event, 1),
         "Timed wait unexpectedly observed an event");

      Require
        (SDL.Events.Queue.Is_Enabled (Custom_First),
         "Custom event type was not enabled by default");
      SDL.Events.Queue.Set_Enabled (Custom_First, False);
      Require
        (not SDL.Events.Queue.Is_Enabled (Custom_First),
         "Custom event type was not disabled");
      SDL.Events.Queue.Set_Enabled (Custom_First, True);
      Require
        (SDL.Events.Queue.Is_Enabled (Custom_First),
         "Custom event type was not re-enabled");

      Filter_Info.Reject_Type := Custom_First;
      SDL.Events.Queue.Set_Filter
        (Reject_Filter'Unrestricted_Access, Filter_Info'Address);

      declare
         Saved_Filter    : SDL.Events.Queue.Event_Filter := null;
         Saved_User_Data : System.Address := System.Null_Address;
      begin
         Require
           (SDL.Events.Queue.Get_Filter (Saved_Filter, Saved_User_Data),
            "Configured event filter was not reported");
         Require
           (Saved_Filter /= null and then Saved_User_Data = Filter_Info'Address,
            "Configured event filter metadata mismatch");
      end;

      Require
        (not SDL.Events.Queue.Push (Make_User_Event (Custom_First, 11)),
         "Filtered custom event should not have been queued");
      Require
        (Filter_Info.Calls > 0,
         "Event filter callback was not invoked");
      Require
        (not SDL.Events.Queue.Has (Custom_First),
         "Filtered custom event unexpectedly reached the queue");

      SDL.Events.Queue.Set_Filter (null);

      declare
         Saved_Filter    : SDL.Events.Queue.Event_Filter := null;
         Saved_User_Data : System.Address := System.Null_Address;
      begin
         Require
           (not SDL.Events.Queue.Get_Filter (Saved_Filter, Saved_User_Data),
            "Event filter still reported after clear");
      end;

      Require
        (SDL.Events.Queue.Add_Watch
           (Watch_Filter'Unrestricted_Access, Watch_Info'Address),
         "Event watch registration failed");
      Push
        (Make_User_Event (Custom_First, 12),
         "Watch custom event push failed");
      Require
        (Watch_Info.Calls > 0 and then Watch_Info.Last_Type = Custom_First,
         "Event watch did not observe the synthetic custom event");
      SDL.Events.Queue.Remove_Watch
        (Watch_Filter'Unrestricted_Access, Watch_Info'Address);

      declare
         Calls_Before : constant Natural := Watch_Info.Calls;
      begin
         Push
           (Make_User_Event (Custom_First, 13),
            "Post-remove custom event push failed");
         Require
           (Watch_Info.Calls = Calls_Before,
            "Removed event watch was still invoked");
      end;

      SDL.Events.Queue.Flush (Custom_First);
      Require
        (not SDL.Events.Queue.Has (Custom_First),
         "Flush did not remove the queued custom event");

      declare
         Queued_Custom_Events : SDL.Events.Queue.Event_Arrays (1 .. 2) :=
           (Make_User_Event (Custom_First, 21),
            Make_User_Event (Custom_Second, 22));
         Peeked_Custom_Events : SDL.Events.Queue.Event_Arrays (1 .. 2);
         Got_Custom_Events    : SDL.Events.Queue.Event_Arrays (1 .. 2);
      begin
         Require
           (SDL.Events.Queue.Peep (Queued_Custom_Events, SDL.Events.Queue.Add) = 2,
            "Peep add did not enqueue the expected custom events");
         Require
           (SDL.Events.Queue.Count (Custom_First, Custom_Second) = 2,
            "Count did not observe the queued custom events");
         Require
           (SDL.Events.Queue.Peep
              (Peeked_Custom_Events,
               SDL.Events.Queue.Peek,
               Custom_First,
               Custom_Second) = 2,
            "Peep peek did not inspect the queued custom events");
         Require
           (Peeked_Custom_Events (1).Common.Event_Type = Custom_First and then
              Peeked_Custom_Events (2).Common.Event_Type = Custom_Second,
            "Peep peek did not preserve custom event order");
         Require
           (SDL.Events.Queue.Count (Custom_First, Custom_Second) = 2,
            "Peep peek should not remove queued events");
         Require
           (SDL.Events.Queue.Peep
              (Got_Custom_Events,
               SDL.Events.Queue.Get,
               Custom_First,
               Custom_Second) = 2,
            "Peep get did not dequeue the custom events");
         Require
           (Got_Custom_Events (1).User.Code = 21 and then
              Got_Custom_Events (2).User.Code = 22,
            "Peep get did not preserve custom event payloads");
         Require
           (not SDL.Events.Queue.Has (Custom_First, Custom_Second),
            "Custom events remained queued after peep get");
      end;

      Push
        (Make_User_Event (Custom_First, 31),
         "First filtered-queue custom event push failed");
      Push
        (Make_User_Event (Custom_Second, 32),
         "Second filtered-queue custom event push failed");
      Filter_Info.Calls := 0;
      Filter_Info.Reject_Type := Custom_First;
      SDL.Events.Queue.Filter
        (Reject_Filter'Unrestricted_Access, Filter_Info'Address);
      Require
        (Filter_Info.Calls >= 2,
         "Filter callback did not run across the queued custom events");
      Require
        (not SDL.Events.Queue.Has (Custom_First),
         "Queue filter did not remove the rejected custom event");
      Require
        (SDL.Events.Queue.Has (Custom_Second),
         "Queue filter unexpectedly removed the accepted custom event");
      SDL.Events.Queue.Flush (Custom_First, Custom_Second);
      Require
        (not SDL.Events.Queue.Has (Custom_First, Custom_Second),
         "Range flush did not clear the remaining custom events");
   end;

   Push (Make_Window_Event, "Window event push failed");
   Push (Make_Key_Down_Event, "Key-down event push failed");
   Push (Make_Text_Editing_Event, "Text-editing event push failed");
   Push (Make_Text_Input_Event, "Text-input event push failed");
   Push (Make_Mouse_Motion_Event, "Mouse-motion event push failed");
   Push (Make_Mouse_Button_Event, "Mouse-button event push failed");
   Push (Make_Mouse_Wheel_Event, "Mouse-wheel event push failed");
   Push (Make_Touch_Event, "Touch event push failed");
   Push (Make_Drop_Event, "Drop event push failed");
   Push (Make_Quit_Event, "Quit event push failed");

   SDL.Events.Queue.Wait (Event);
   Require
     (Event.Common.Event_Type = SDL.Events.Windows.To_Event_Type (SDL.Events.Windows.Moved),
      "Wait did not dequeue the synthetic window event");
   Require
     (SDL.Events.Windows.Get_Event_ID (Event.Window) = SDL.Events.Windows.Moved,
      "Window event type did not map to the expected compatibility ID");
   Require
     (Event.Window.ID = Window.Get_ID and then
        Event.Window.Data_1 = 640 and then Event.Window.Data_2 = 480,
      "Window event did not preserve the expected payload");

   Require
     (SDL.Events.Queue.Poll (Event),
      "Poll did not dequeue the synthetic key-down event");
   Require
     (Event.Common.Event_Type = SDL.Events.Keyboards.Key_Down,
      "Expected a key-down event");
   Require
     (Event.Keyboard.Key_Sym.Scan_Code = SDL.Events.Keyboards.Scan_Code_Z,
      "Keyboard event did not preserve the scan code");
   Require
     (SDL.Events.Keyboards.Get_State (Event.Keyboard) = SDL.Events.Pressed,
      "Keyboard event did not preserve the key state");

   Require
     (SDL.Events.Queue.Poll (Event),
      "Poll did not dequeue the synthetic text-editing event");
   Require
     (Event.Common.Event_Type = SDL.Events.Keyboards.Text_Editing,
      "Expected a text-editing event");
   Require
     (CS.Value (Event.Text_Editing.Text) = "compose" and then
        Event.Text_Editing.Start = 2 and then Event.Text_Editing.Length = 3,
      "Text-editing event did not preserve the composition payload");

   Require
     (SDL.Events.Queue.Poll (Event),
      "Poll did not dequeue the synthetic text-input event");
   Require
     (Event.Common.Event_Type = SDL.Events.Keyboards.Text_Input,
      "Expected a text-input event");
   Require
     (CS.Value (Event.Text_Input.Text) = "z",
      "Text-input event did not preserve the input text");

   Require
     (SDL.Events.Queue.Poll (Event),
      "Poll did not dequeue the synthetic mouse-motion event");
   Require
     (Event.Common.Event_Type = SDL.Events.Mice.Motion,
      "Expected a mouse-motion event");
   Require
     (Event.Mouse_Motion.Mask = SDL.Events.Mice.Left_Mask and then
        Nearly_Equal (Event.Mouse_Motion.X, 320.5) and then
        Nearly_Equal (Event.Mouse_Motion.Y, 240.25) and then
        Nearly_Equal (Event.Mouse_Motion.X_Relative, 2.0) and then
        Nearly_Equal (Event.Mouse_Motion.Y_Relative, -3.5),
      "Mouse-motion event did not preserve the motion payload");

   Require
     (SDL.Events.Queue.Poll (Event),
      "Poll did not dequeue the synthetic mouse-button event");
   Require
     (Event.Common.Event_Type = SDL.Events.Mice.Button_Down,
      "Expected a mouse-button event");
   Require
     (Event.Mouse_Button.Button = SDL.Events.Mice.Left and then
        SDL.Events.Mice.Get_State (Event.Mouse_Button) = SDL.Events.Pressed and then
        Event.Mouse_Button.Clicks = 2,
      "Mouse-button event did not preserve the button payload");

   Require
     (SDL.Events.Queue.Poll (Event),
      "Poll did not dequeue the synthetic mouse-wheel event");
   Require
     (Event.Common.Event_Type = SDL.Events.Mice.Wheel,
      "Expected a mouse-wheel event");
   Require
     (Event.Mouse_Wheel.Direction = SDL.Events.Mice.Flipped and then
        Event.Mouse_Wheel.Integer_X = 1 and then Event.Mouse_Wheel.Integer_Y = -2 and then
        Nearly_Equal (Event.Mouse_Wheel.X, 1.5) and then
        Nearly_Equal (Event.Mouse_Wheel.Y, -2.5),
      "Mouse-wheel event did not preserve the wheel payload");

   Require
     (SDL.Events.Queue.Poll (Event),
      "Poll did not dequeue the synthetic touch event");
   Require
     (Event.Common.Event_Type = SDL.Events.Touches.Finger_Motion,
      "Expected a touch-finger event");
   Require
     (Event.Touch_Finger.Touch_ID = 11 and then
        Event.Touch_Finger.Finger_ID = 19 and then
        Event.Touch_Finger.Window_ID = Window.Get_ID and then
        Nearly_Equal (Event.Touch_Finger.X, 0.5) and then
        Nearly_Equal (Event.Touch_Finger.Y, 0.75) and then
        Nearly_Equal (Event.Touch_Finger.Pressure, 0.8),
      "Touch event did not preserve the finger payload");

   Require
     (SDL.Events.Queue.Poll (Event),
      "Poll did not dequeue the synthetic drop event");
   Require
     (Event.Common.Event_Type = SDL.Events.Files.Drop_File,
      "Expected a drop-file event");
   Require
     (CS.Value (Event.Drop.File_Name) = "synthetic-drop.gb" and then
        Nearly_Equal (Event.Drop.X, 12.0) and then
        Nearly_Equal (Event.Drop.Y, 34.0),
      "Drop event did not preserve the drop payload");

   Require
     (SDL.Events.Queue.Poll (Event),
      "Poll did not dequeue the synthetic quit event");
   Require (Event.Common.Event_Type = SDL.Events.Quit, "Expected a quit event");

   Require
     (not SDL.Events.Queue.Poll (Event),
      "Event queue should be empty");

   Ada.Text_IO.Put_Line
     ("Scancode name for Space: " &
        SDL.Events.Keyboards.Image (SDL.Events.Keyboards.Scan_Code_Space));
   Ada.Text_IO.Put_Line
     ("Keycode name for Space: " &
        SDL.Events.Keyboards.Image
          (SDL.Events.Keyboards.To_Key_Code (SDL.Events.Keyboards.Scan_Code_Space)));
   Ada.Text_IO.Put_Line ("Synthetic drop filename: " & CS.Value (Dropped_Name));
   Ada.Text_IO.Put_Line ("Event smoke completed successfully.");

   SDL.Video.Windows.Finalize (Window);
   Window_Created := False;
   CS.Free (Dropped_Name);
   Dropped_Name := CS.Null_Ptr;
   CS.Free (Editing_Text);
   Editing_Text := CS.Null_Ptr;
   CS.Free (Input_Text);
   Input_Text := CS.Null_Ptr;
   SDL.Finalise;
exception
   when others =>
      SDL.Events.Queue.Set_Filter (null);

      if Window_Created then
         SDL.Video.Windows.Finalize (Window);
      end if;

      if Dropped_Name /= CS.Null_Ptr then
         CS.Free (Dropped_Name);
      end if;

      if Editing_Text /= CS.Null_Ptr then
         CS.Free (Editing_Text);
      end if;

      if Input_Text /= CS.Null_Ptr then
         CS.Free (Input_Text);
      end if;

      if SDL_Initialized then
         SDL.Finalise;
      end if;

      raise;
end Events_Smoke;
