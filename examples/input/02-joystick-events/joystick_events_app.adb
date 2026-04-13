with Ada.Command_Line;
with Ada.Exceptions;
with Ada.Numerics.Float_Random;
with Ada.Strings.Fixed;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Unchecked_Conversion;
with Ada.Unchecked_Deallocation;

with Interfaces;
with Interfaces.C;
with Interfaces.C.Strings;
with System;

with SDL;
with SDL.Error;
with SDL.Events;
with SDL.Events.Events;
with SDL.Events.Joysticks;
with SDL.Inputs.Joysticks;
with SDL.Main;
with SDL.Power;
with SDL.Timers;
with SDL.Video.Palettes;
with SDL.Video.Renderers;
with SDL.Video.Renderers.Makers;
with SDL.Video.Windows;

package body Joystick_Events_App is
   package C renames Interfaces.C;
   package CS renames Interfaces.C.Strings;
   package Random_Floats renames Ada.Numerics.Float_Random;
   package US renames Ada.Strings.Unbounded;

   use type C.int;
   use type CS.chars_ptr;
   use type SDL.Init_Flags;
   use type SDL.Events.Button_State;
   use type SDL.Events.Event_Types;
   use type SDL.Events.Joysticks.Hat_Positions;
   use type SDL.Events.Joysticks.IDs;
   use type SDL.Main.App_Results;
   use type SDL.Power.State;
   use type SDL.Timers.Milliseconds;

   Window_Width  : constant SDL.Positive_Dimension := 640;
   Window_Height : constant SDL.Positive_Dimension := 480;
   Debug_Char_Size : constant Float :=
     Float (SDL.Video.Renderers.Debug_Text_Character_Size);
   Motion_Event_Cooldown : constant SDL.Timers.Milliseconds := 40;
   Message_Lifetime      : constant Float := 3_500.0;
   Max_Open_Joysticks    : constant Positive := 16;
   Max_Messages          : constant Positive := 64;

   subtype Colour_Index is Natural range 0 .. 63;
   type Colour_List is array (Colour_Index) of SDL.Video.Palettes.Colour;

   type Message_Record is record
      Text       : US.Unbounded_String := US.Null_Unbounded_String;
      Colour     : SDL.Video.Palettes.Colour := SDL.Video.Palettes.Null_Colour;
      Start_Tick : SDL.Timers.Milliseconds := 0;
   end record;

   Null_Message : constant Message_Record :=
     (Text       => US.Null_Unbounded_String,
      Colour     => SDL.Video.Palettes.Null_Colour,
      Start_Tick => 0);

   type Message_List is array (Positive range 1 .. Max_Messages) of Message_Record;

   type Joystick_Access is access SDL.Inputs.Joysticks.Joystick;

   type Joystick_Slot is record
      ID     : SDL.Events.Joysticks.IDs := 0;
      Device : Joystick_Access := null;
   end record;

   type Joystick_Slot_List is
     array (Positive range 1 .. Max_Open_Joysticks) of Joystick_Slot;

   Random_Generator : Random_Floats.Generator;

   type State is record
      Window               : SDL.Video.Windows.Window;
      Renderer             : SDL.Video.Renderers.Renderer;
      Colours              : Colour_List := [others => SDL.Video.Palettes.Null_Colour];
      Joysticks            : Joystick_Slot_List;
      Messages             : Message_List := [others => Null_Message];
      Message_Count        : Natural := 0;
      Axis_Cooldown_Tick   : SDL.Timers.Milliseconds := 0;
      Ball_Cooldown_Tick   : SDL.Timers.Milliseconds := 0;
      SDL_Initialized      : Boolean := False;
   end record;

   type State_Access is access all State;
   type Argument_Vector_Access is access CS.chars_ptr_array;

   procedure Free_State is new Ada.Unchecked_Deallocation (State, State_Access);
   procedure Free_Argument_Vector is new Ada.Unchecked_Deallocation
     (CS.chars_ptr_array, Argument_Vector_Access);
   procedure Free_Joystick is new Ada.Unchecked_Deallocation
     (SDL.Inputs.Joysticks.Joystick, Joystick_Access);

   function To_State is new Ada.Unchecked_Conversion (System.Address, State_Access);
   function To_Address is new Ada.Unchecked_Conversion (State_Access, System.Address);

   procedure Require_SDL (Condition : in Boolean; Message : in String);
   procedure Cleanup (App : in out State);
   procedure Close_Slot (Slot : in out Joystick_Slot);
   function Trim (Item : in String) return String;
   function ID_Image (Value : in SDL.Events.Joysticks.IDs) return String;
   function Int_Image (Value : in Integer) return String;
   function Random_Colour return SDL.Video.Palettes.Colour;
   function To_Float
     (Value : in SDL.Video.Palettes.Colour_Component) return Float;
   procedure Set_Draw_Colour
     (Renderer    : in out SDL.Video.Renderers.Renderer;
      Colour      : in SDL.Video.Palettes.Colour;
      Alpha_Scale : in Float := 1.0);
   function Centered_X (Text : in String; Width : in Float) return Float;
   function Hat_State_Image
     (Value : in SDL.Events.Joysticks.Hat_Positions) return String;
   function Battery_State_Image (Value : in SDL.Power.State) return String;
   procedure Find_Slot
     (App   : in State;
      ID    : in SDL.Events.Joysticks.IDs;
      Index : out Natural);
   procedure Find_Free_Slot (App : in State; Index : out Natural);
   procedure Add_Message
     (App  : in out State;
      ID   : in SDL.Events.Joysticks.IDs;
      Text : in String);
   procedure Prune_Expired_Messages
     (App : in out State;
      Now : in SDL.Timers.Milliseconds);

   function App_Init
     (App_State : access System.Address;
      ArgC      : in C.int;
      ArgV      : access CS.chars_ptr_array) return SDL.Main.App_Results
   with Convention => C;

   function App_Iterate
     (App_State : in System.Address) return SDL.Main.App_Results
   with Convention => C;

   function App_Event
     (App_State : in System.Address;
      Event     : access SDL.Events.Events.Events) return SDL.Main.App_Results
   with Convention => C;

   procedure App_Quit
     (App_State : in System.Address;
      Result    : in SDL.Main.App_Results)
   with Convention => C;

   procedure Require_SDL (Condition : in Boolean; Message : in String) is
   begin
      if not Condition then
         raise Program_Error with Message & ": " & SDL.Error.Get;
      end if;
   end Require_SDL;

   procedure Close_Slot (Slot : in out Joystick_Slot) is
   begin
      if Slot.Device /= null then
         SDL.Inputs.Joysticks.Close (Slot.Device.all);
         Free_Joystick (Slot.Device);
      end if;

      Slot.ID := 0;
   end Close_Slot;

   procedure Cleanup (App : in out State) is
   begin
      for Index in App.Joysticks'Range loop
         Close_Slot (App.Joysticks (Index));
      end loop;

      SDL.Video.Renderers.Finalize (App.Renderer);
      SDL.Video.Windows.Finalize (App.Window);

      if App.SDL_Initialized then
         SDL.Quit;
         App.SDL_Initialized := False;
      end if;
   end Cleanup;

   function Trim (Item : in String) return String is
     (Ada.Strings.Fixed.Trim (Item, Ada.Strings.Both));

   function ID_Image (Value : in SDL.Events.Joysticks.IDs) return String is
     (Trim (Interfaces.Unsigned_32'Image (Interfaces.Unsigned_32 (Value))));

   function Int_Image (Value : in Integer) return String is
     (Trim (Integer'Image (Value)));

   function Random_Colour return SDL.Video.Palettes.Colour is
      function Random_Component return SDL.Video.Palettes.Colour_Component is
      begin
         return
           SDL.Video.Palettes.Colour_Component
             (Integer (Random_Floats.Random (Random_Generator) * 255.0));
      end Random_Component;
   begin
      return
        (Red   => Random_Component,
         Green => Random_Component,
         Blue  => Random_Component,
         Alpha => 255);
   end Random_Colour;

   function To_Float
     (Value : in SDL.Video.Palettes.Colour_Component) return Float is
     (Float (Value) / 255.0);

   procedure Set_Draw_Colour
     (Renderer    : in out SDL.Video.Renderers.Renderer;
      Colour      : in SDL.Video.Palettes.Colour;
      Alpha_Scale : in Float := 1.0) is
   begin
      SDL.Video.Renderers.Set_Draw_Colour
        (Renderer,
         To_Float (Colour.Red),
         To_Float (Colour.Green),
         To_Float (Colour.Blue),
         To_Float (Colour.Alpha) * Alpha_Scale);
   end Set_Draw_Colour;

   function Centered_X (Text : in String; Width : in Float) return Float is
     ((Width - (Debug_Char_Size * Float (Text'Length))) / 2.0);

   function Hat_State_Image
     (Value : in SDL.Events.Joysticks.Hat_Positions) return String is
   begin
      case Value is
         when SDL.Events.Joysticks.Hat_Centred =>
            return "CENTERED";
         when SDL.Events.Joysticks.Hat_Up =>
            return "UP";
         when SDL.Events.Joysticks.Hat_Right =>
            return "RIGHT";
         when SDL.Events.Joysticks.Hat_Down =>
            return "DOWN";
         when SDL.Events.Joysticks.Hat_Left =>
            return "LEFT";
         when SDL.Events.Joysticks.Hat_Right_Up =>
            return "RIGHT+UP";
         when SDL.Events.Joysticks.Hat_Right_Down =>
            return "RIGHT+DOWN";
         when SDL.Events.Joysticks.Hat_Left_Up =>
            return "LEFT+UP";
         when SDL.Events.Joysticks.Hat_Left_Down =>
            return "LEFT+DOWN";
         when others =>
            return "UNKNOWN";
      end case;
   end Hat_State_Image;

   function Battery_State_Image (Value : in SDL.Power.State) return String is
   begin
      case Value is
         when SDL.Power.Error =>
            return "ERROR";
         when SDL.Power.Unknown =>
            return "UNKNOWN";
         when SDL.Power.Battery =>
            return "ON BATTERY";
         when SDL.Power.No_Battery =>
            return "NO BATTERY";
         when SDL.Power.Charging =>
            return "CHARGING";
         when SDL.Power.Charged =>
            return "CHARGED";
      end case;
   end Battery_State_Image;

   procedure Find_Slot
     (App   : in State;
      ID    : in SDL.Events.Joysticks.IDs;
      Index : out Natural) is
   begin
      for Candidate in App.Joysticks'Range loop
         if App.Joysticks (Candidate).Device /= null
           and then App.Joysticks (Candidate).ID = ID
         then
            Index := Candidate;
            return;
         end if;
      end loop;

      Index := 0;
   end Find_Slot;

   procedure Find_Free_Slot (App : in State; Index : out Natural) is
   begin
      for Candidate in App.Joysticks'Range loop
         if App.Joysticks (Candidate).Device = null then
            Index := Candidate;
            return;
         end if;
      end loop;

      Index := 0;
   end Find_Free_Slot;

   procedure Add_Message
     (App  : in out State;
      ID   : in SDL.Events.Joysticks.IDs;
      Text : in String)
   is
      Slot : Natural := App.Message_Count + 1;
   begin
      if App.Message_Count = Max_Messages then
         for Index in 1 .. Max_Messages - 1 loop
            App.Messages (Index) := App.Messages (Index + 1);
         end loop;

         Slot := Max_Messages;
      else
         App.Message_Count := App.Message_Count + 1;
      end if;

      App.Messages (Slot) :=
        (Text       => US.To_Unbounded_String (Text),
         Colour     =>
           App.Colours
             (Colour_Index
                (Natural
                   (Interfaces.Unsigned_32 (ID)
                      mod Interfaces.Unsigned_32 (App.Colours'Length)))),
         Start_Tick => SDL.Timers.Ticks);
   end Add_Message;

   procedure Prune_Expired_Messages
     (App : in out State;
      Now : in SDL.Timers.Milliseconds)
   is
      New_Count : Natural := 0;
   begin
      for Index in 1 .. App.Message_Count loop
         declare
            Life : constant Float :=
              Float
                (Interfaces.Unsigned_64
                   (Now - App.Messages (Index).Start_Tick))
              / Message_Lifetime;
         begin
            if Life < 1.0 then
               New_Count := New_Count + 1;
               if New_Count /= Index then
                  App.Messages (New_Count) := App.Messages (Index);
               end if;
            end if;
         end;
      end loop;

      if New_Count < App.Message_Count then
         for Index in New_Count + 1 .. App.Message_Count loop
            App.Messages (Index) := Null_Message;
         end loop;
      end if;

      App.Message_Count := New_Count;
   end Prune_Expired_Messages;

   function App_Init
     (App_State : access System.Address;
      ArgC      : in C.int;
      ArgV      : access CS.chars_ptr_array) return SDL.Main.App_Results
   is
      pragma Unreferenced (ArgC, ArgV);

      App : State_Access := new State;
   begin
      App_State.all := System.Null_Address;

      Require_SDL
        (SDL.Set_App_Metadata
           ("Example Input Joystick Events",
            "1.0",
            "com.example.input-joystick-events"),
         "Unable to set application metadata");

      Require_SDL
        (SDL.Initialise (SDL.Enable_Video or SDL.Enable_Joystick),
         "Couldn't initialize SDL");
      App.SDL_Initialized := True;

      SDL.Video.Renderers.Makers.Create
        (Window   => App.Window,
         Rend     => App.Renderer,
         Title    => "examples/input/joystick-events",
         Position => SDL.Video.Windows.Centered_Window_Position,
         Size     => (Width => Window_Width, Height => Window_Height),
         Flags    => SDL.Video.Windows.Resizable);

      Random_Floats.Reset (Random_Generator);
      App.Colours (0) := (Red => 255, Green => 255, Blue => 255, Alpha => 255);
      for Index in Colour_Index range 1 .. Colour_Index'Last loop
         App.Colours (Index) := Random_Colour;
      end loop;

      Add_Message (App.all, 0, "Please plug in a joystick.");

      App_State.all := To_Address (App);
      return SDL.Main.App_Continue;
   exception
      when others =>
         Cleanup (App.all);
         Free_State (App);
         raise;
   end App_Init;

   function App_Iterate
     (App_State : in System.Address) return SDL.Main.App_Results
   is
      App         : constant State_Access := To_State (App_State);
      Now         : constant SDL.Timers.Milliseconds := SDL.Timers.Ticks;
      Window_Size : constant SDL.Sizes := SDL.Video.Windows.Get_Size (App.Window);
      Previous_Y  : Float := 0.0;
   begin
      SDL.Video.Renderers.Set_Draw_Colour (App.Renderer, 0.0, 0.0, 0.0, 1.0);
      SDL.Video.Renderers.Clear (App.Renderer);

      Prune_Expired_Messages (App.all, Now);

      for Index in 1 .. App.Message_Count loop
         declare
            Text : constant String := US.To_String (App.Messages (Index).Text);
            Life : constant Float :=
              Float
                (Interfaces.Unsigned_64
                   (Now - App.Messages (Index).Start_Tick))
              / Message_Lifetime;
            X    : constant Float := Centered_X (Text, Float (Window_Size.Width));
            Y    : constant Float := Float (Window_Size.Height) * Life;
         begin
            if Previous_Y /= 0.0 and then (Previous_Y - Y) < Debug_Char_Size then
               App.Messages (Index).Start_Tick := Now;
               exit;
            end if;

            Set_Draw_Colour
              (App.Renderer, App.Messages (Index).Colour, 1.0 - Life);
            SDL.Video.Renderers.Debug_Text (App.Renderer, X, Y, Text);

            Previous_Y := Y;
         end;
      end loop;

      SDL.Video.Renderers.Present (App.Renderer);
      return SDL.Main.App_Continue;
   end App_Iterate;

   function App_Event
     (App_State : in System.Address;
      Event     : access SDL.Events.Events.Events) return SDL.Main.App_Results
   is
      App : constant State_Access := To_State (App_State);
   begin
      if Event.Common.Event_Type = SDL.Events.Quit then
         return SDL.Main.App_Success;
      elsif Event.Common.Event_Type = SDL.Events.Joysticks.Device_Added then
         declare
            Slot_Index : Natural := 0;
            Which      : constant SDL.Events.Joysticks.IDs :=
              Event.Joystick_Device.Which;
         begin
            Find_Free_Slot (App.all, Slot_Index);

            if Slot_Index = 0 then
               Add_Message
                 (App.all,
                  Which,
                  "Joystick #" & ID_Image (Which) & " add ignored: no free slots");
            else
               App.Joysticks (Slot_Index).Device :=
                 new SDL.Inputs.Joysticks.Joystick;

               begin
                  SDL.Inputs.Joysticks.Open
                    (App.Joysticks (Slot_Index).Device.all, Which);
                  App.Joysticks (Slot_Index).ID := Which;

                  Add_Message
                    (App.all,
                     Which,
                     "Joystick #"
                     & ID_Image (Which)
                     & " ('"
                     & SDL.Inputs.Joysticks.Name
                         (App.Joysticks (Slot_Index).Device.all)
                     & "') added");
               exception
                  when Error : others =>
                     Add_Message
                       (App.all,
                        Which,
                        "Joystick #"
                        & ID_Image (Which)
                        & " add, but not opened: "
                        & Ada.Exceptions.Exception_Message (Error));
                     Close_Slot (App.Joysticks (Slot_Index));
               end;
            end if;
         end;
      elsif Event.Common.Event_Type = SDL.Events.Joysticks.Device_Removed then
         declare
            Slot_Index : Natural := 0;
            Which      : constant SDL.Events.Joysticks.IDs :=
              Event.Joystick_Device.Which;
         begin
            Find_Slot (App.all, Which, Slot_Index);

            if Slot_Index /= 0 then
               Close_Slot (App.Joysticks (Slot_Index));
            end if;

            Add_Message
              (App.all, Which, "Joystick #" & ID_Image (Which) & " removed");
         end;
      elsif Event.Common.Event_Type = SDL.Events.Joysticks.Axis_Motion then
         declare
            Now : constant SDL.Timers.Milliseconds := SDL.Timers.Ticks;
         begin
            if Now >= App.Axis_Cooldown_Tick then
               App.Axis_Cooldown_Tick := Now + Motion_Event_Cooldown;
               Add_Message
                 (App.all,
                  Event.Joystick_Axis.Which,
                  "Joystick #"
                  & ID_Image (Event.Joystick_Axis.Which)
                  & " axis "
                  & Int_Image (Integer (Event.Joystick_Axis.Axis))
                  & " -> "
                  & Int_Image (Integer (Event.Joystick_Axis.Value)));
            end if;
         end;
      elsif Event.Common.Event_Type = SDL.Events.Joysticks.Ball_Motion then
         declare
            Now : constant SDL.Timers.Milliseconds := SDL.Timers.Ticks;
         begin
            if Now >= App.Ball_Cooldown_Tick then
               App.Ball_Cooldown_Tick := Now + Motion_Event_Cooldown;
               Add_Message
                 (App.all,
                  Event.Joystick_Ball.Which,
                  "Joystick #"
                  & ID_Image (Event.Joystick_Ball.Which)
                  & " ball "
                  & Int_Image (Integer (Event.Joystick_Ball.Ball))
                  & " -> "
                  & Int_Image (Integer (Event.Joystick_Ball.X_Relative))
                  & ", "
                  & Int_Image (Integer (Event.Joystick_Ball.Y_Relative)));
            end if;
         end;
      elsif Event.Common.Event_Type = SDL.Events.Joysticks.Hat_Motion then
         Add_Message
           (App.all,
            Event.Joystick_Hat.Which,
            "Joystick #"
            & ID_Image (Event.Joystick_Hat.Which)
            & " hat "
            & Int_Image (Integer (Event.Joystick_Hat.Hat))
            & " -> "
            & Hat_State_Image (Event.Joystick_Hat.Position));
      elsif Event.Common.Event_Type = SDL.Events.Joysticks.Button_Up
        or else Event.Common.Event_Type = SDL.Events.Joysticks.Button_Down
      then
         Add_Message
           (App.all,
            Event.Joystick_Button.Which,
            "Joystick #"
            & ID_Image (Event.Joystick_Button.Which)
            & " button "
            & Int_Image (Integer (Event.Joystick_Button.Button))
            & " -> "
            & (if SDL.Events.Joysticks.Get_State (Event.Joystick_Button) =
                   SDL.Events.Pressed
               then "PRESSED"
               else "RELEASED"));
      elsif Event.Common.Event_Type = SDL.Events.Joysticks.Battery_Updated then
         Add_Message
           (App.all,
            Event.Joystick_Battery.Which,
            "Joystick #"
            & ID_Image (Event.Joystick_Battery.Which)
            & " battery -> "
            & Battery_State_Image (Event.Joystick_Battery.State)
            & " - "
            & Int_Image (Integer (Event.Joystick_Battery.Percent))
            & "%");
      end if;

      return SDL.Main.App_Continue;
   end App_Event;

   procedure App_Quit
     (App_State : in System.Address;
      Result    : in SDL.Main.App_Results)
   is
      pragma Unreferenced (Result);

      App : State_Access := To_State (App_State);
   begin
      if App = null then
         return;
      end if;

      Cleanup (App.all);
      Free_State (App);
   end App_Quit;

   procedure Free_Arguments (Items : in out Argument_Vector_Access) is
   begin
      if Items = null then
         return;
      end if;

      for Index in Items'Range loop
         if Items (Index) /= CS.Null_Ptr then
            CS.Free (Items (Index));
            Items (Index) := CS.Null_Ptr;
         end if;
      end loop;

      Free_Argument_Vector (Items);
   end Free_Arguments;

   procedure Run is
      Arg_Count : constant Natural := Ada.Command_Line.Argument_Count + 1;
      Args      : Argument_Vector_Access := null;
      Exit_Code : C.int := 0;
   begin
      Args := new CS.chars_ptr_array (0 .. C.size_t (Arg_Count));

      for Index in Args'Range loop
         Args (Index) := CS.Null_Ptr;
      end loop;

      Args (0) := CS.New_String (Ada.Command_Line.Command_Name);
      for Index in 1 .. Ada.Command_Line.Argument_Count loop
         Args (C.size_t (Index)) :=
           CS.New_String (Ada.Command_Line.Argument (Index));
      end loop;

      Exit_Code :=
        SDL.Main.Enter_App_Main_Callbacks
          (ArgC      => C.int (Arg_Count),
           ArgV      => Args (Args'First)'Address,
           App_Init  => App_Init'Access,
           App_Iter  => App_Iterate'Access,
           App_Event => App_Event'Access,
           App_Quit  => App_Quit'Access);

      if Exit_Code /= 0 then
         declare
            Message : constant String := SDL.Error.Get;
         begin
            if Message /= "" then
               raise Program_Error with Message;
            end if;

            raise Program_Error with
              "joystick_events exited with status"
              & Integer'Image (Integer (Exit_Code));
         end;
      end if;

      Free_Arguments (Args);
   exception
      when others =>
         Free_Arguments (Args);
         raise;
   end Run;
end Joystick_Events_App;
