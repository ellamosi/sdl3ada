with Ada.Command_Line;
with Ada.Exceptions;
with Ada.Numerics.Float_Random;
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
with SDL.Events.Events;
with SDL.Events.Joysticks;
with SDL.Inputs.Joysticks;
with SDL.Main;
with SDL.Video.Palettes;
with SDL.Video.Rectangles;
with SDL.Video.Renderers;
with SDL.Video.Renderers.Makers;
with SDL.Video.Windows;

package body Joystick_Polling_App is
   package C renames Interfaces.C;
   package CS renames Interfaces.C.Strings;
   package Random_Floats renames Ada.Numerics.Float_Random;

   use type C.int;
   use type CS.chars_ptr;
   use type SDL.Init_Flags;
   use type SDL.Events.Button_State;
   use type SDL.Events.Event_Types;
   use type SDL.Events.Joysticks.Hat_Positions;
   use type SDL.Events.Joysticks.IDs;
   use type SDL.Main.App_Results;

   Window_Width  : constant SDL.Positive_Dimension := 640;
   Window_Height : constant SDL.Positive_Dimension := 480;
   Debug_Char_Size : constant Float :=
     Float (SDL.Video.Renderers.Debug_Text_Character_Size);

   subtype Colour_Index is Natural range 0 .. 63;
   type Colour_List is array (Colour_Index) of SDL.Video.Palettes.Colour;

   Random_Generator : Random_Floats.Generator;

   type State is record
      Window          : SDL.Video.Windows.Window;
      Renderer        : SDL.Video.Renderers.Renderer;
      Joystick        : SDL.Inputs.Joysticks.Joystick;
      Colours         : Colour_List := [others => SDL.Video.Palettes.Null_Colour];
      Joystick_Open   : Boolean := False;
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
   procedure Cleanup (App : in out State);
   function Trim (Item : in String) return String;
   function ID_Image (Value : in SDL.Events.Joysticks.IDs) return String;
   function Random_Colour return SDL.Video.Palettes.Colour;
   function To_Float
     (Value : in SDL.Video.Palettes.Colour_Component) return Float;
   procedure Set_Draw_Colour
     (Renderer : in out SDL.Video.Renderers.Renderer;
      Colour   : in SDL.Video.Palettes.Colour);
   function Centered_X (Text : in String; Width : in Float) return Float;

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
      if App.Joystick_Open then
         SDL.Inputs.Joysticks.Close (App.Joystick);
         App.Joystick_Open := False;
      end if;

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
     (Renderer : in out SDL.Video.Renderers.Renderer;
      Colour   : in SDL.Video.Palettes.Colour) is
   begin
      SDL.Video.Renderers.Set_Draw_Colour
        (Renderer,
         To_Float (Colour.Red),
         To_Float (Colour.Green),
         To_Float (Colour.Blue),
         To_Float (Colour.Alpha));
   end Set_Draw_Colour;

   function Centered_X (Text : in String; Width : in Float) return Float is
     ((Width - (Debug_Char_Size * Float (Text'Length))) / 2.0);

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
           ("Example Input Joystick Polling",
            "1.0",
            "com.example.input-joystick-polling"),
         "Unable to set application metadata");

      Require_SDL
        (SDL.Initialise (SDL.Enable_Video or SDL.Enable_Joystick),
         "Couldn't initialize SDL");
      App.SDL_Initialized := True;

      SDL.Video.Renderers.Makers.Create
        (Window   => App.Window,
         Rend     => App.Renderer,
         Title    => "examples/input/joystick-polling",
         Position => SDL.Video.Windows.Centered_Window_Position,
         Size     => (Width => Window_Width, Height => Window_Height),
         Flags    => SDL.Video.Windows.Resizable);

      Random_Floats.Reset (Random_Generator);
      for Index in App.Colours'Range loop
         App.Colours (Index) := Random_Colour;
      end loop;

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
      App        : constant State_Access := To_State (App_State);
      Window_Size : constant SDL.Sizes := SDL.Video.Windows.Get_Size (App.Window);
      Text       : constant String :=
        (if App.Joystick_Open
         then SDL.Inputs.Joysticks.Name (App.Joystick)
         else "Plug in a joystick, please.");
      Size       : constant Float := 30.0;
      Mid_X      : constant Float := Float (Window_Size.Width) / 2.0;
   begin
      SDL.Video.Renderers.Set_Draw_Colour (App.Renderer, 0.0, 0.0, 0.0, 1.0);
      SDL.Video.Renderers.Clear (App.Renderer);

      if App.Joystick_Open then
         declare
            Total_Axes : constant Natural :=
              Natural (SDL.Inputs.Joysticks.Axes (App.Joystick));
         begin
            if Total_Axes > 0 then
               declare
                  Y : Float := (Float (Window_Size.Height) - (Float (Total_Axes) * Size)) / 2.0;
               begin
                  for Index in 0 .. Total_Axes - 1 loop
                     declare
                        Colour : constant SDL.Video.Palettes.Colour :=
                          App.Colours (Colour_Index (Index mod App.Colours'Length));
                        Value  : constant Float :=
                          Float
                            (SDL.Inputs.Joysticks.Axis_Value
                               (App.Joystick, SDL.Events.Joysticks.Axes (Index)))
                          / 32767.0;
                        DX     : constant Float := Mid_X + (Value * Mid_X);
                        Box    : constant SDL.Video.Rectangles.Float_Rectangle :=
                          (X      => Float'Min (DX, Mid_X),
                           Y      => Y,
                           Width  => abs (Mid_X - DX),
                           Height => Size);
                     begin
                        Set_Draw_Colour (App.Renderer, Colour);
                        SDL.Video.Renderers.Fill (App.Renderer, Box);
                        Y := Y + Size;
                     end;
                  end loop;
               end;
            end if;
         end;

         declare
            Total_Buttons : constant Natural :=
              Natural (SDL.Inputs.Joysticks.Buttons (App.Joystick));
         begin
            if Total_Buttons > 0 then
               declare
                  X : Float :=
                    (Float (Window_Size.Width) - (Float (Total_Buttons) * Size)) / 2.0;
               begin
                  for Index in 0 .. Total_Buttons - 1 loop
                     declare
                        Colour : constant SDL.Video.Palettes.Colour :=
                          App.Colours (Colour_Index (Index mod App.Colours'Length));
                        Box    : constant SDL.Video.Rectangles.Float_Rectangle :=
                          (X => X, Y => 0.0, Width => Size, Height => Size);
                     begin
                        if SDL.Inputs.Joysticks.Is_Button_Pressed
                             (App.Joystick, SDL.Events.Joysticks.Buttons (Index))
                           = SDL.Events.Pressed
                        then
                           Set_Draw_Colour (App.Renderer, Colour);
                        else
                           SDL.Video.Renderers.Set_Draw_Colour
                             (App.Renderer, 0.0, 0.0, 0.0, 1.0);
                        end if;

                        SDL.Video.Renderers.Fill (App.Renderer, Box);
                        SDL.Video.Renderers.Set_Draw_Colour
                          (App.Renderer, 1.0, 1.0, 1.0, 1.0);
                        SDL.Video.Renderers.Draw (App.Renderer, Box);
                        X := X + Size;
                     end;
                  end loop;
               end;
            end if;
         end;

         declare
            Total_Hats : constant Natural :=
              Natural (SDL.Inputs.Joysticks.Hats (App.Joystick));
         begin
            if Total_Hats > 0 then
               declare
                  X : Float :=
                    ((Float (Window_Size.Width) - (Float (Total_Hats) * (Size * 2.0)))
                       / 2.0)
                    + (Size / 2.0);
                  Y : constant Float := Float (Window_Size.Height) - Size;
               begin
                  for Index in 0 .. Total_Hats - 1 loop
                     declare
                        Colour : constant SDL.Video.Palettes.Colour :=
                          App.Colours (Colour_Index (Index mod App.Colours'Length));
                        Third  : constant Float := Size / 3.0;
                        Cross  : constant SDL.Video.Rectangles.Float_Rectangle_Arrays :=
                          (0 =>
                             (X => X, Y => Y + Third, Width => Size, Height => Third),
                           1 =>
                             (X => X + Third, Y => Y, Width => Third, Height => Size));
                        Hat    : constant SDL.Events.Joysticks.Hat_Positions :=
                          SDL.Inputs.Joysticks.Hat_Value
                            (App.Joystick, SDL.Events.Joysticks.Hats (Index));
                     begin
                        SDL.Video.Renderers.Set_Draw_Colour
                          (App.Renderer, 90.0 / 255.0, 90.0 / 255.0, 90.0 / 255.0, 1.0);
                        SDL.Video.Renderers.Fill (App.Renderer, Cross);
                        Set_Draw_Colour (App.Renderer, Colour);

                        if (Hat and SDL.Events.Joysticks.Hat_Up) /=
                             SDL.Events.Joysticks.Hat_Centred
                        then
                           SDL.Video.Renderers.Fill
                             (App.Renderer,
                              SDL.Video.Rectangles.Float_Rectangle'
                                (X      => X + Third,
                                 Y      => Y,
                                 Width  => Third,
                                 Height => Third));
                        end if;

                        if (Hat and SDL.Events.Joysticks.Hat_Right) /=
                             SDL.Events.Joysticks.Hat_Centred
                        then
                           SDL.Video.Renderers.Fill
                             (App.Renderer,
                              SDL.Video.Rectangles.Float_Rectangle'
                                (X      => X + (Third * 2.0),
                                 Y      => Y + Third,
                                 Width  => Third,
                                 Height => Third));
                        end if;

                        if (Hat and SDL.Events.Joysticks.Hat_Down) /=
                             SDL.Events.Joysticks.Hat_Centred
                        then
                           SDL.Video.Renderers.Fill
                             (App.Renderer,
                              SDL.Video.Rectangles.Float_Rectangle'
                                (X      => X + Third,
                                 Y      => Y + (Third * 2.0),
                                 Width  => Third,
                                 Height => Third));
                        end if;

                        if (Hat and SDL.Events.Joysticks.Hat_Left) /=
                             SDL.Events.Joysticks.Hat_Centred
                        then
                           SDL.Video.Renderers.Fill
                             (App.Renderer,
                              SDL.Video.Rectangles.Float_Rectangle'
                                (X      => X,
                                 Y      => Y + Third,
                                 Width  => Third,
                                 Height => Third));
                        end if;

                        X := X + (Size * 2.0);
                     end;
                  end loop;
               end;
            end if;
         end;
      end if;

      SDL.Video.Renderers.Set_Draw_Colour (App.Renderer, 1.0, 1.0, 1.0, 1.0);
      SDL.Video.Renderers.Debug_Text
        (App.Renderer,
         Centered_X (Text, Float (Window_Size.Width)),
         (Float (Window_Size.Height) - Debug_Char_Size) / 2.0,
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
      elsif Event.Common.Event_Type = SDL.Events.Joysticks.Device_Added then
         if not App.Joystick_Open then
            begin
               SDL.Inputs.Joysticks.Open (App.Joystick, Event.Joystick_Device.Which);
               App.Joystick_Open := True;
            exception
               when Error : others =>
                  Ada.Text_IO.Put_Line
                    ("Failed to open joystick ID "
                     & ID_Image (Event.Joystick_Device.Which)
                     & ": "
                     & Ada.Exceptions.Exception_Message (Error));
            end;
         end if;
      elsif Event.Common.Event_Type = SDL.Events.Joysticks.Device_Removed then
         if App.Joystick_Open
           and then SDL.Inputs.Joysticks.Instance (App.Joystick) =
             Event.Joystick_Device.Which
         then
            SDL.Inputs.Joysticks.Close (App.Joystick);
            App.Joystick_Open := False;
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
              "joystick_polling exited with status"
              & Integer'Image (Integer (Exit_Code));
         end;
      end if;

      Free_Arguments (Args);
   exception
      when others =>
         Free_Arguments (Args);
         raise;
   end Run;
end Joystick_Polling_App;
