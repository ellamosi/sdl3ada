with Ada.Command_Line;
with Ada.Strings.Fixed;
with Ada.Text_IO;
with Ada.Unchecked_Conversion;
with Ada.Unchecked_Deallocation;

with Interfaces.C;
with Interfaces.C.Strings;
with System;

with SDL;
with SDL.Error;
with SDL.Events;
with SDL.Events.Events;
with SDL.Events.Pens;
with SDL.Main;
with SDL.Pens;
with SDL.Timers;
with SDL.Video;
with SDL.Video.Pixel_Formats;
with SDL.Video.Rectangles;
with SDL.Video.Renderers;
with SDL.Video.Renderers.Makers;
with SDL.Video.Textures;
with SDL.Video.Textures.Makers;
with SDL.Video.Windows;

package body Drawing_Lines_App is
   package C renames Interfaces.C;
   package CS renames Interfaces.C.Strings;

   use type C.int;
   use type CS.chars_ptr;
   use type SDL.Events.Event_Types;
   use type SDL.Main.App_Results;
   use type SDL.Pens.Axes;

   Window_Width  : constant SDL.Positive_Dimension := 640;
   Window_Height : constant SDL.Positive_Dimension := 480;
   Background    : constant Float := 100.0 / 255.0;
   Invalid_Touch : constant Float := -1.0;

   type State is record
      Window          : SDL.Video.Windows.Window;
      Renderer        : SDL.Video.Renderers.Renderer;
      Render_Target   : SDL.Video.Textures.Texture;
      Pressure        : Float := 0.0;
      Previous_Touch  : SDL.Video.Rectangles.Float_Point :=
        (X => Invalid_Touch, Y => Invalid_Touch);
      Tilt_X          : Float := 0.0;
      Tilt_Y          : Float := 0.0;
      SDL_Initialized : Boolean := False;
   end record;

   type State_Access is access all State;
   type Argument_Vector_Access is access CS.chars_ptr_array;

   procedure Free_State is new Ada.Unchecked_Deallocation (State, State_Access);
   procedure Free_Argument_Vector is new Ada.Unchecked_Deallocation
     (CS.chars_ptr_array, Argument_Vector_Access);

   function To_State is new Ada.Unchecked_Conversion (System.Address, State_Access);
   function To_Address is new Ada.Unchecked_Conversion (State_Access, System.Address);

   procedure Require_SDL (Condition : in Boolean; Message : in String);
   procedure Require (Condition : in Boolean; Message : in String);
   function Trim (Item : in String) return String;
   function Format_Float (Value : in Float) return String;
   function Debug_Text (App : in State) return String;
   function To_Positive_Size (Size : in SDL.Sizes) return SDL.Positive_Sizes;
   procedure Reset_Previous_Touch (App : in out State);
   procedure Cleanup (App : in out State);

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

   procedure Require (Condition : in Boolean; Message : in String) is
   begin
      if not Condition then
         raise Program_Error with Message;
      end if;
   end Require;

   function Trim (Item : in String) return String is
     (Ada.Strings.Fixed.Trim (Item, Ada.Strings.Both));

   function Format_Float (Value : in Float) return String is
      package Float_Output is new Ada.Text_IO.Float_IO (Float);

      Buffer : String (1 .. 32);
   begin
      Float_Output.Put (To => Buffer, Item => Value, Aft => 2, Exp => 0);
      return Trim (Buffer);
   end Format_Float;

   function Debug_Text (App : in State) return String is
   begin
      return "Tilt: " & Format_Float (App.Tilt_X) & " " & Format_Float (App.Tilt_Y);
   end Debug_Text;

   function To_Positive_Size (Size : in SDL.Sizes) return SDL.Positive_Sizes is
   begin
      return
        (Width  => SDL.Positive_Dimension (Size.Width),
         Height => SDL.Positive_Dimension (Size.Height));
   end To_Positive_Size;

   procedure Reset_Previous_Touch (App : in out State) is
   begin
      App.Previous_Touch := (X => Invalid_Touch, Y => Invalid_Touch);
   end Reset_Previous_Touch;

   procedure Cleanup (App : in out State) is
   begin
      SDL.Video.Textures.Finalize (App.Render_Target);
      SDL.Video.Renderers.Finalize (App.Renderer);
      SDL.Video.Windows.Finalize (App.Window);

      if App.SDL_Initialized then
         SDL.Quit;
         App.SDL_Initialized := False;
      end if;
   end Cleanup;

   function App_Init
     (App_State : access System.Address;
      ArgC      : in C.int;
      ArgV      : access CS.chars_ptr_array) return SDL.Main.App_Results
   is
      pragma Unreferenced (ArgC, ArgV);

      App         : State_Access := new State;
      Output_Size : SDL.Sizes;
   begin
      App_State.all := System.Null_Address;

      Require_SDL
        (SDL.Set_App_Metadata
           ("Example Pen Drawing Lines",
            "1.0",
            "com.example.pen-drawing-lines"),
         "Unable to set application metadata");

      Require_SDL
        (SDL.Initialise (SDL.Enable_Video),
         "Couldn't initialize SDL");
      App.SDL_Initialized := True;

      SDL.Video.Renderers.Makers.Create
        (Window   => App.Window,
         Rend     => App.Renderer,
         Title    => "examples/pen/drawing-lines",
         Position => SDL.Video.Windows.Centered_Window_Position,
         Size     => (Width => Window_Width, Height => Window_Height),
         Flags    => SDL.Video.Windows.Windowed);

      Output_Size := SDL.Video.Renderers.Get_Output_Size (App.Renderer);
      Require
        (Output_Size.Width > 0 and then Output_Size.Height > 0,
         "Renderer output size must be positive");

      SDL.Video.Textures.Makers.Create
        (Tex      => App.Render_Target,
         Renderer => App.Renderer,
         Format   => SDL.Video.Pixel_Formats.Pixel_Format_RGBA_8888,
         Kind     => SDL.Video.Textures.Target,
         Size     => To_Positive_Size (Output_Size));

      SDL.Video.Renderers.Set_Target (App.Renderer, App.Render_Target);
      SDL.Video.Renderers.Set_Draw_Colour
        (App.Renderer, Background, Background, Background, 1.0);
      SDL.Video.Renderers.Clear (App.Renderer);
      SDL.Video.Renderers.Reset_Target (App.Renderer);
      SDL.Video.Renderers.Set_Blend_Mode
        (App.Renderer, SDL.Video.Alpha_Blend);

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
      App : constant State_Access := To_State (App_State);
   begin
      SDL.Video.Renderers.Reset_Target (App.Renderer);
      SDL.Video.Renderers.Set_Draw_Colour (App.Renderer, 0.0, 0.0, 0.0, 1.0);
      SDL.Video.Renderers.Clear (App.Renderer);
      SDL.Video.Renderers.Copy (App.Renderer, App.Render_Target);
      SDL.Video.Renderers.Debug_Text (App.Renderer, 0.0, 8.0, Debug_Text (App.all));
      SDL.Video.Renderers.Present (App.Renderer);
      return SDL.Main.App_Continue;
   end App_Iterate;

   function App_Event
     (App_State : in System.Address;
      Event     : access SDL.Events.Events.Events) return SDL.Main.App_Results
   is
      App : constant State_Access := To_State (App_State);
   begin
      if Event = null then
         return SDL.Main.App_Continue;
      end if;

      if Event.Common.Event_Type = SDL.Events.Quit then
         return SDL.Main.App_Success;
      end if;

      if App = null then
         return SDL.Main.App_Continue;
      end if;

      if Event.Common.Event_Type = SDL.Events.Pens.Motion then
         declare
            Current_X : constant Float := Float (Event.Pen_Motion.X);
            Current_Y : constant Float := Float (Event.Pen_Motion.Y);
         begin
            if App.Pressure > 0.0 then
               if App.Previous_Touch.X >= 0.0 then
                  SDL.Video.Renderers.Set_Target (App.Renderer, App.Render_Target);
                  SDL.Video.Renderers.Set_Draw_Colour
                    (App.Renderer, 0.0, 0.0, 0.0, App.Pressure);
                  SDL.Video.Renderers.Draw
                    (App.Renderer,
                     App.Previous_Touch.X,
                     App.Previous_Touch.Y,
                     Current_X,
                     Current_Y);
                  SDL.Video.Renderers.Reset_Target (App.Renderer);
               end if;

               App.Previous_Touch := (X => Current_X, Y => Current_Y);
            else
               Reset_Previous_Touch (App.all);
            end if;
         end;
      elsif Event.Common.Event_Type = SDL.Events.Pens.Axis then
         case Event.Pen_Axis.Axis is
            when SDL.Pens.Pressure =>
               App.Pressure := Float (Event.Pen_Axis.Value);

            when SDL.Pens.X_Tilt =>
               App.Tilt_X := Float (Event.Pen_Axis.Value);

            when SDL.Pens.Y_Tilt =>
               App.Tilt_Y := Float (Event.Pen_Axis.Value);

            when others =>
               null;
         end case;
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
         Args (C.size_t (Index)) := CS.New_String (Ada.Command_Line.Argument (Index));
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
              "drawing_lines exited with status"
              & Integer'Image (Integer (Exit_Code));
         end;
      end if;

      Free_Arguments (Args);
   exception
      when others =>
         Free_Arguments (Args);
         raise;
   end Run;
end Drawing_Lines_App;
