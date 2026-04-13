with Ada.Command_Line;
with Ada.Exceptions;
with Ada.Strings.Fixed;
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
with SDL.Events.Controllers;
with SDL.Events.Events;
with SDL.Events.Joysticks;
with SDL.Events.Joysticks.Game_Controllers;
with SDL.Filesystems;
with SDL.Inputs.Joysticks.Game_Controllers;
with SDL.Main;
with SDL.Timers;
with SDL.Video.Rectangles;
with SDL.Video.Renderers;
with SDL.Video.Renderers.Makers;
with SDL.Video.Surfaces;
with SDL.Video.Surfaces.Makers;
with SDL.Video.Textures;
with SDL.Video.Textures.Makers;
with SDL.Video.Windows;

package body Gamepad_Polling_App is
   package C renames Interfaces.C;
   package CS renames Interfaces.C.Strings;
   package Gamepad_Events renames SDL.Events.Joysticks.Game_Controllers;

   use type C.int;
   use type CS.chars_ptr;
   use type SDL.Init_Flags;
   use type SDL.Events.Button_State;
   use type SDL.Events.Event_Types;
   use type SDL.Events.Joysticks.IDs;
   use type SDL.Main.App_Results;
   use type SDL.Timers.Milliseconds;

   Window_Width  : constant SDL.Positive_Dimension := 640;
   Window_Height : constant SDL.Positive_Dimension := 480;
   Debug_Char_Size : constant Float :=
     Float (SDL.Video.Renderers.Debug_Text_Character_Size);
   Thumb_Deadzone : constant Integer := 1_000;

   subtype Displayed_Buttons is Gamepad_Events.Buttons range
     Gamepad_Events.A .. Gamepad_Events.Misc_1;

   Button_Rectangles : constant array (Displayed_Buttons) of
     SDL.Video.Rectangles.Float_Rectangle :=
       (Gamepad_Events.A              => (X => 497.0, Y => 266.0, Width => 38.0, Height => 38.0),
        Gamepad_Events.B              => (X => 550.0, Y => 217.0, Width => 38.0, Height => 38.0),
        Gamepad_Events.X              => (X => 445.0, Y => 221.0, Width => 38.0, Height => 38.0),
        Gamepad_Events.Y              => (X => 499.0, Y => 173.0, Width => 38.0, Height => 38.0),
        Gamepad_Events.Back           => (X => 235.0, Y => 228.0, Width => 32.0, Height => 29.0),
        Gamepad_Events.Guide          => (X => 287.0, Y => 195.0, Width => 69.0, Height => 69.0),
        Gamepad_Events.Start          => (X => 377.0, Y => 228.0, Width => 32.0, Height => 29.0),
        Gamepad_Events.Left_Stick     => (X => 91.0, Y => 234.0, Width => 63.0, Height => 63.0),
        Gamepad_Events.Right_Stick    => (X => 381.0, Y => 354.0, Width => 63.0, Height => 63.0),
        Gamepad_Events.Left_Shoulder  => (X => 74.0, Y => 73.0, Width => 102.0, Height => 29.0),
        Gamepad_Events.Right_Shoulder => (X => 468.0, Y => 73.0, Width => 102.0, Height => 29.0),
        Gamepad_Events.D_Pad_Up       => (X => 207.0, Y => 316.0, Width => 32.0, Height => 32.0),
        Gamepad_Events.D_Pad_Down     => (X => 207.0, Y => 384.0, Width => 32.0, Height => 32.0),
        Gamepad_Events.D_Pad_Left     => (X => 173.0, Y => 351.0, Width => 32.0, Height => 32.0),
        Gamepad_Events.D_Pad_Right    => (X => 242.0, Y => 351.0, Width => 32.0, Height => 32.0),
        Gamepad_Events.Misc_1         => (X => 310.0, Y => 286.0, Width => 23.0, Height => 27.0));

   type State is record
      Window             : SDL.Video.Windows.Window;
      Renderer           : SDL.Video.Renderers.Renderer;
      Texture            : SDL.Video.Textures.Texture;
      Gamepad            : SDL.Inputs.Joysticks.Game_Controllers.Game_Controller;
      Gamepad_Open       : Boolean := False;
      Left_Thumb_Active  : Boolean := False;
      Right_Thumb_Active : Boolean := False;
      Left_Thumb_Last    : SDL.Timers.Milliseconds := 0;
      Right_Thumb_Last   : SDL.Timers.Milliseconds := 0;
      SDL_Initialized    : Boolean := False;
   end record;

   type State_Access is access all State;
   type Argument_Vector_Access is access CS.chars_ptr_array;

   procedure Free_State is new Ada.Unchecked_Deallocation (State, State_Access);
   procedure Free_Argument_Vector is new Ada.Unchecked_Deallocation
     (CS.chars_ptr_array, Argument_Vector_Access);

   function To_State is new Ada.Unchecked_Conversion (System.Address, State_Access);
   function To_Address is new Ada.Unchecked_Conversion (State_Access, System.Address);

   procedure Require_SDL (Condition : in Boolean; Message : in String);
   procedure Cleanup (App : in out State);
   function Trim (Item : in String) return String;
   function ID_Image (Value : in SDL.Events.Joysticks.IDs) return String;
   function Texture_Path return String;
   function Centered_X (Text : in String) return Float;

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

   procedure Cleanup (App : in out State) is
   begin
      if App.Gamepad_Open then
         SDL.Inputs.Joysticks.Game_Controllers.Close (App.Gamepad);
         App.Gamepad_Open := False;
      end if;

      SDL.Video.Textures.Finalize (App.Texture);
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

   function Texture_Path return String is
     (SDL.Filesystems.Base_Path & "../examples/assets/gamepad_front.png");

   function Centered_X (Text : in String) return Float is
     ((Float (Window_Width) - (Debug_Char_Size * Float (Text'Length))) / 2.0);

   function App_Init
     (App_State : access System.Address;
      ArgC      : in C.int;
      ArgV      : access CS.chars_ptr_array) return SDL.Main.App_Results
   is
      pragma Unreferenced (ArgC, ArgV);

      App     : State_Access := new State;
      Surface : SDL.Video.Surfaces.Surface;
   begin
      App_State.all := System.Null_Address;

      Require_SDL
        (SDL.Set_App_Metadata
           ("Example Input Gamepad Polling",
            "1.0",
            "com.example.input-gamepad-polling"),
         "Unable to set application metadata");

      Require_SDL
        (SDL.Initialise (SDL.Enable_Video or SDL.Enable_Gamepad),
         "Couldn't initialize SDL");
      App.SDL_Initialized := True;

      SDL.Video.Renderers.Makers.Create
        (Window   => App.Window,
         Rend     => App.Renderer,
         Title    => "examples/input/gamepad-polling",
         Position => SDL.Video.Windows.Centered_Window_Position,
         Size     => (Width => Window_Width, Height => Window_Height),
         Flags    => SDL.Video.Windows.Resizable);

      SDL.Video.Renderers.Set_Logical_Presentation
        (Self => App.Renderer,
         Size => (Width => Window_Width, Height => Window_Height),
         Mode => SDL.Video.Renderers.Stretch_Presentation);

      SDL.Video.Surfaces.Makers.Load_PNG (Surface, Texture_Path);
      SDL.Video.Textures.Makers.Create
        (Tex      => App.Texture,
         Renderer => App.Renderer,
         Surface  => Surface);

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
      App  : constant State_Access := To_State (App_State);
      Text : constant String :=
        (if App.Gamepad_Open
         then SDL.Inputs.Joysticks.Game_Controllers.Get_Name (App.Gamepad)
         else "Plug in a gamepad, please.");
      Now  : constant SDL.Timers.Milliseconds := SDL.Timers.Ticks;
   begin
      SDL.Video.Renderers.Set_Draw_Colour (App.Renderer, 1.0, 1.0, 1.0, 1.0);
      SDL.Video.Renderers.Clear (App.Renderer);

      if App.Gamepad_Open then
         SDL.Video.Renderers.Copy (App.Renderer, App.Texture);
         SDL.Video.Renderers.Set_Draw_Colour (App.Renderer, 0.0, 1.0, 0.0, 1.0);

         for Button in Button_Rectangles'Range loop
            if SDL.Inputs.Joysticks.Game_Controllers.Is_Button_Pressed
                 (App.Gamepad, Button)
               = SDL.Events.Pressed
            then
               SDL.Video.Renderers.Fill (App.Renderer, Button_Rectangles (Button));
            end if;
         end loop;

         SDL.Video.Renderers.Set_Draw_Colour (App.Renderer, 1.0, 1.0, 0.0, 1.0);

         declare
            Axis_X : constant Gamepad_Events.LR_Axes_Values :=
              SDL.Inputs.Joysticks.Game_Controllers.Axis_Value
                (App.Gamepad, Gamepad_Events.Left_X);
            Axis_Y : constant Gamepad_Events.LR_Axes_Values :=
              SDL.Inputs.Joysticks.Game_Controllers.Axis_Value
                (App.Gamepad, Gamepad_Events.Left_Y);
         begin
            if abs (Integer (Axis_X)) > Thumb_Deadzone
              or else abs (Integer (Axis_Y)) > Thumb_Deadzone
            then
               App.Left_Thumb_Active := True;
               App.Left_Thumb_Last := Now;
            end if;

            if App.Left_Thumb_Active and then (Now - App.Left_Thumb_Last) < 500 then
               SDL.Video.Renderers.Fill
                 (App.Renderer,
                  SDL.Video.Rectangles.Float_Rectangle'
                    (X      => 107.0 + ((Float (Axis_X) / 32767.0) * 30.0),
                     Y      => 252.0 + ((Float (Axis_Y) / 32767.0) * 30.0),
                     Width  => 30.0,
                     Height => 30.0));
            end if;
         end;

         declare
            Axis_X : constant Gamepad_Events.LR_Axes_Values :=
              SDL.Inputs.Joysticks.Game_Controllers.Axis_Value
                (App.Gamepad, Gamepad_Events.Right_X);
            Axis_Y : constant Gamepad_Events.LR_Axes_Values :=
              SDL.Inputs.Joysticks.Game_Controllers.Axis_Value
                (App.Gamepad, Gamepad_Events.Right_Y);
         begin
            if abs (Integer (Axis_X)) > Thumb_Deadzone
              or else abs (Integer (Axis_Y)) > Thumb_Deadzone
            then
               App.Right_Thumb_Active := True;
               App.Right_Thumb_Last := Now;
            end if;

            if App.Right_Thumb_Active and then (Now - App.Right_Thumb_Last) < 500 then
               SDL.Video.Renderers.Fill
                 (App.Renderer,
                  SDL.Video.Rectangles.Float_Rectangle'
                    (X      => 397.0 + ((Float (Axis_X) / 32767.0) * 30.0),
                     Y      => 370.0 + ((Float (Axis_Y) / 32767.0) * 30.0),
                     Width  => 30.0,
                     Height => 30.0));
            end if;
         end;

         declare
            Axis_Y : constant Gamepad_Events.Trigger_Axes_Values :=
              SDL.Inputs.Joysticks.Game_Controllers.Axis_Value
                (App.Gamepad, Gamepad_Events.Trigger_Left);
         begin
            if Integer (Axis_Y) > Thumb_Deadzone then
               declare
                  Height : constant Float := (Float (Axis_Y) / 32767.0) * 65.0;
               begin
                  SDL.Video.Renderers.Fill
                    (App.Renderer,
                     SDL.Video.Rectangles.Float_Rectangle'
                       (X      => 127.0,
                        Y      => 1.0 + (65.0 - Height),
                        Width  => 37.0,
                        Height => Height));
               end;
            end if;
         end;

         declare
            Axis_Y : constant Gamepad_Events.Trigger_Axes_Values :=
              SDL.Inputs.Joysticks.Game_Controllers.Axis_Value
                (App.Gamepad, Gamepad_Events.Trigger_Right);
         begin
            if Integer (Axis_Y) > Thumb_Deadzone then
               declare
                  Height : constant Float := (Float (Axis_Y) / 32767.0) * 65.0;
               begin
                  SDL.Video.Renderers.Fill
                    (App.Renderer,
                     SDL.Video.Rectangles.Float_Rectangle'
                       (X      => 481.0,
                        Y      => 1.0 + (65.0 - Height),
                        Width  => 37.0,
                        Height => Height));
               end;
            end if;
         end;
      end if;

      SDL.Video.Renderers.Set_Draw_Colour (App.Renderer, 0.0, 0.0, 1.0, 1.0);
      SDL.Video.Renderers.Debug_Text
        (App.Renderer,
         Centered_X (Text),
         (if App.Gamepad_Open
          then Float (Window_Height) - (Debug_Char_Size + 2.0)
          else (Float (Window_Height) - Debug_Char_Size) / 2.0),
         Text);
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
      elsif Event.Common.Event_Type = SDL.Events.Controllers.Device_Added then
         if not App.Gamepad_Open then
            begin
               SDL.Inputs.Joysticks.Game_Controllers.Open
                 (App.Gamepad, Event.Controller_Device.Which);
               App.Gamepad_Open := True;
            exception
               when Error : others =>
                  Ada.Text_IO.Put_Line
                    ("Failed to open gamepad ID "
                     & ID_Image (Event.Controller_Device.Which)
                     & ": "
                     & Ada.Exceptions.Exception_Message (Error));
            end;
         end if;
      elsif Event.Common.Event_Type = SDL.Events.Controllers.Device_Removed then
         if App.Gamepad_Open
           and then SDL.Inputs.Joysticks.Game_Controllers.Get_ID (App.Gamepad) =
             Event.Controller_Device.Which
         then
            SDL.Inputs.Joysticks.Game_Controllers.Close (App.Gamepad);
            App.Gamepad_Open := False;
            App.Left_Thumb_Active := False;
            App.Right_Thumb_Active := False;
         end if;
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
              "gamepad_polling exited with status"
              & Integer'Image (Integer (Exit_Code));
         end;
      end if;

      Free_Arguments (Args);
   exception
      when others =>
         Free_Arguments (Args);
         raise;
   end Run;
end Gamepad_Polling_App;
