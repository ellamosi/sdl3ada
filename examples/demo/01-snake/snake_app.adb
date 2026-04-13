with Ada.Command_Line;
with Ada.Exceptions;
with Ada.Numerics.Discrete_Random;
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
with SDL.Events.Joysticks;
with SDL.Events.Keyboards;
with SDL.Inputs.Joysticks;
with SDL.Main;
with SDL.Timers;
with SDL.Video.Rectangles;
with SDL.Video.Renderers;
with SDL.Video.Renderers.Makers;
with SDL.Video.Windows;

package body Snake_App is
   package C renames Interfaces.C;
   package CS renames Interfaces.C.Strings;

   use type C.int;
   use type CS.chars_ptr;
   use type SDL.Init_Flags;
   use type SDL.Events.Event_Types;
   use type SDL.Events.Joysticks.Hat_Positions;
   use type SDL.Events.Joysticks.IDs;
   use type SDL.Events.Keyboards.Scan_Codes;
   use type SDL.Main.App_Results;
   use type SDL.Timers.Milliseconds;

   Step_Rate_In_Milliseconds  : constant SDL.Timers.Milliseconds := 125;
   Snake_Block_Size_In_Pixels : constant Positive := 24;
   Snake_Game_Width           : constant Positive := 24;
   Snake_Game_Height          : constant Positive := 18;
   Snake_Food_Count           : constant Positive := 4;
   Snake_Matrix_Size          : constant Positive :=
     Snake_Game_Width * Snake_Game_Height;
   Window_Width               : constant SDL.Positive_Dimension :=
     SDL.Positive_Dimension
       (Snake_Block_Size_In_Pixels * Snake_Game_Width);
   Window_Height              : constant SDL.Positive_Dimension :=
     SDL.Positive_Dimension
       (Snake_Block_Size_In_Pixels * Snake_Game_Height);
   Block_Size                 : constant Float :=
     Float (Snake_Block_Size_In_Pixels);

   Escape_Scan_Code : constant SDL.Events.Keyboards.Scan_Codes :=
     SDL.Events.Keyboards.Value ("Escape");
   Q_Scan_Code      : constant SDL.Events.Keyboards.Scan_Codes :=
     SDL.Events.Keyboards.Value ("Q");
   R_Scan_Code      : constant SDL.Events.Keyboards.Scan_Codes :=
     SDL.Events.Keyboards.Value ("R");

   type Snake_Directions is
     (Snake_Dir_Right,
      Snake_Dir_Up,
      Snake_Dir_Left,
      Snake_Dir_Down);

   type Positions is record
      X : Integer := 0;
      Y : Integer := 0;
   end record;

   type Segment_Lists is
     array (Positive range 1 .. Snake_Matrix_Size) of Positions;
   type Food_Lists is array (Positive range 1 .. Snake_Food_Count) of Positions;

   type Random_Cell_Indices is range 0 .. Snake_Matrix_Size - 1;
   package Random_Cells is new Ada.Numerics.Discrete_Random (Random_Cell_Indices);

   type Snake_State is record
      Segments          : Segment_Lists := [others => (X => 0, Y => 0)];
      Foods             : Food_Lists := [others => (X => 0, Y => 0)];
      Length            : Positive := 1;
      Current_Direction : Snake_Directions := Snake_Dir_Right;
      Next_Direction    : Snake_Directions := Snake_Dir_Right;
      Pending_Growth    : Natural := 0;
   end record;

   type State is record
      Window          : SDL.Video.Windows.Window;
      Renderer        : SDL.Video.Renderers.Renderer;
      Joystick        : SDL.Inputs.Joysticks.Joystick;
      Snake           : Snake_State;
      Last_Step       : SDL.Timers.Milliseconds := 0;
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

   Cell_Generator : Random_Cells.Generator;

   procedure Require_SDL (Condition : in Boolean; Message : in String);
   procedure Cleanup (App : in out State);
   function Wrap_X (Value : in Integer) return Integer;
   function Wrap_Y (Value : in Integer) return Integer;
   function Move
     (Item      : in Positions;
      Direction : in Snake_Directions) return Positions;
   function Is_Occupied_By_Snake
     (Game        : in Snake_State;
      Item        : in Positions;
      Ignore_Tail : in Boolean := False) return Boolean;
   function Is_Occupied_By_Food
     (Game         : in Snake_State;
      Item         : in Positions;
      Excluded_Slot : in Natural := 0) return Boolean;
   function Food_Slot
     (Game : in Snake_State;
      Item : in Positions) return Natural;
   function Position_From_Index
     (Index : in Random_Cell_Indices) return Positions;
   procedure Spawn_Food
     (Game : in out Snake_State;
      Slot : in Positive);
   procedure Reset (Game : in out Snake_State);
   procedure Redirect
     (Game      : in out Snake_State;
      Direction : in Snake_Directions);
   procedure Step (Game : in out Snake_State);
   procedure Draw_Cell
     (Renderer : in out SDL.Video.Renderers.Renderer;
      Item     : in Positions);
   function Handle_Key_Event
     (Game     : in out Snake_State;
      Key_Code : in SDL.Events.Keyboards.Scan_Codes) return SDL.Main.App_Results;
   function Handle_Hat_Event
     (Game : in out Snake_State;
      Hat  : in SDL.Events.Joysticks.Hat_Positions) return SDL.Main.App_Results;

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

   function Wrap_X (Value : in Integer) return Integer is
   begin
      if Value < 0 then
         return Snake_Game_Width - 1;
      elsif Value >= Snake_Game_Width then
         return 0;
      end if;

      return Value;
   end Wrap_X;

   function Wrap_Y (Value : in Integer) return Integer is
   begin
      if Value < 0 then
         return Snake_Game_Height - 1;
      elsif Value >= Snake_Game_Height then
         return 0;
      end if;

      return Value;
   end Wrap_Y;

   function Move
     (Item      : in Positions;
      Direction : in Snake_Directions) return Positions
   is
      Result : Positions := Item;
   begin
      case Direction is
         when Snake_Dir_Right =>
            Result.X := Wrap_X (Result.X + 1);
         when Snake_Dir_Up =>
            Result.Y := Wrap_Y (Result.Y - 1);
         when Snake_Dir_Left =>
            Result.X := Wrap_X (Result.X - 1);
         when Snake_Dir_Down =>
            Result.Y := Wrap_Y (Result.Y + 1);
      end case;

      return Result;
   end Move;

   function Is_Occupied_By_Snake
     (Game        : in Snake_State;
      Item        : in Positions;
      Ignore_Tail : in Boolean := False) return Boolean
   is
      Last_Index : Natural := Game.Length;
   begin
      if Ignore_Tail and then Last_Index > 0 then
         Last_Index := Last_Index - 1;
      end if;

      if Last_Index = 0 then
         return False;
      end if;

      for Index in 1 .. Last_Index loop
         if Game.Segments (Index) = Item then
            return True;
         end if;
      end loop;

      return False;
   end Is_Occupied_By_Snake;

   function Is_Occupied_By_Food
     (Game          : in Snake_State;
      Item          : in Positions;
      Excluded_Slot : in Natural := 0) return Boolean
   is
   begin
      for Index in Game.Foods'Range loop
         if Natural (Index) /= Excluded_Slot
           and then Game.Foods (Index) = Item
         then
            return True;
         end if;
      end loop;

      return False;
   end Is_Occupied_By_Food;

   function Food_Slot
     (Game : in Snake_State;
      Item : in Positions) return Natural
   is
   begin
      for Index in Game.Foods'Range loop
         if Game.Foods (Index) = Item then
            return Natural (Index);
         end if;
      end loop;

      return 0;
   end Food_Slot;

   function Position_From_Index
     (Index : in Random_Cell_Indices) return Positions
   is
      Flat : constant Integer := Integer (Index);
   begin
      return
        (X => Flat mod Snake_Game_Width,
         Y => Flat / Snake_Game_Width);
   end Position_From_Index;

   procedure Spawn_Food
     (Game : in out Snake_State;
      Slot : in Positive)
   is
      Candidate : Positions;
   begin
      loop
         Candidate := Position_From_Index (Random_Cells.Random (Cell_Generator));

         exit when
           (not Is_Occupied_By_Snake (Game, Candidate))
             and then
           (not Is_Occupied_By_Food (Game, Candidate, Natural (Slot)));
      end loop;

      Game.Foods (Slot) := Candidate;
   end Spawn_Food;

   procedure Reset (Game : in out Snake_State) is
      Centre : constant Positions :=
        (X => Snake_Game_Width / 2,
         Y => Snake_Game_Height / 2);
   begin
      Game.Segments := [others => Centre];
      Game.Length := 1;
      Game.Current_Direction := Snake_Dir_Right;
      Game.Next_Direction := Snake_Dir_Right;
      Game.Pending_Growth := 3;

      for Index in Game.Foods'Range loop
         Spawn_Food (Game, Index);
      end loop;
   end Reset;

   procedure Redirect
     (Game      : in out Snake_State;
      Direction : in Snake_Directions)
   is
   begin
      case Direction is
         when Snake_Dir_Right =>
            if Game.Current_Direction /= Snake_Dir_Left then
               Game.Next_Direction := Direction;
            end if;

         when Snake_Dir_Up =>
            if Game.Current_Direction /= Snake_Dir_Down then
               Game.Next_Direction := Direction;
            end if;

         when Snake_Dir_Left =>
            if Game.Current_Direction /= Snake_Dir_Right then
               Game.Next_Direction := Direction;
            end if;

         when Snake_Dir_Down =>
            if Game.Current_Direction /= Snake_Dir_Up then
               Game.Next_Direction := Direction;
            end if;
      end case;
   end Redirect;

   procedure Step (Game : in out Snake_State) is
      Tail_Will_Move : constant Boolean := Game.Pending_Growth = 0;
      New_Head       : constant Positions :=
        Move (Game.Segments (1), Game.Next_Direction);
      Eaten_Food_Slot : constant Natural := Food_Slot (Game, New_Head);
   begin
      if Is_Occupied_By_Snake
           (Game        => Game,
            Item        => New_Head,
            Ignore_Tail => Tail_Will_Move)
      then
         Reset (Game);
         return;
      end if;

      Game.Current_Direction := Game.Next_Direction;

      if Tail_Will_Move then
         for Index in reverse 2 .. Game.Length loop
            Game.Segments (Index) := Game.Segments (Index - 1);
         end loop;
      else
         for Index in reverse 2 .. Game.Length + 1 loop
            Game.Segments (Index) := Game.Segments (Index - 1);
         end loop;

         Game.Length := Game.Length + 1;
         Game.Pending_Growth := Game.Pending_Growth - 1;
      end if;

      Game.Segments (1) := New_Head;

      if Eaten_Food_Slot /= 0 then
         if Game.Length + Snake_Food_Count - 1 >= Snake_Matrix_Size then
            Reset (Game);
            return;
         end if;

         Spawn_Food (Game, Positive (Eaten_Food_Slot));
         Game.Pending_Growth := Game.Pending_Growth + 1;
      end if;
   end Step;

   procedure Draw_Cell
     (Renderer : in out SDL.Video.Renderers.Renderer;
      Item     : in Positions)
   is
      Rectangle : constant SDL.Video.Rectangles.Float_Rectangle :=
        (X      => Float (Item.X * Snake_Block_Size_In_Pixels),
         Y      => Float (Item.Y * Snake_Block_Size_In_Pixels),
         Width  => Block_Size,
         Height => Block_Size);
   begin
      SDL.Video.Renderers.Fill (Renderer, Rectangle);
   end Draw_Cell;

   function Handle_Key_Event
     (Game     : in out Snake_State;
      Key_Code : in SDL.Events.Keyboards.Scan_Codes) return SDL.Main.App_Results
   is
   begin
      if Key_Code = Escape_Scan_Code or else Key_Code = Q_Scan_Code then
         return SDL.Main.App_Success;
      elsif Key_Code = R_Scan_Code then
         Reset (Game);
      elsif Key_Code = SDL.Events.Keyboards.Scan_Code_Right then
         Redirect (Game, Snake_Dir_Right);
      elsif Key_Code = SDL.Events.Keyboards.Scan_Code_Up then
         Redirect (Game, Snake_Dir_Up);
      elsif Key_Code = SDL.Events.Keyboards.Scan_Code_Left then
         Redirect (Game, Snake_Dir_Left);
      elsif Key_Code = SDL.Events.Keyboards.Scan_Code_Down then
         Redirect (Game, Snake_Dir_Down);
      end if;

      return SDL.Main.App_Continue;
   end Handle_Key_Event;

   function Handle_Hat_Event
     (Game : in out Snake_State;
      Hat  : in SDL.Events.Joysticks.Hat_Positions) return SDL.Main.App_Results
   is
   begin
      case Hat is
         when SDL.Events.Joysticks.Hat_Right =>
            Redirect (Game, Snake_Dir_Right);

         when SDL.Events.Joysticks.Hat_Up =>
            Redirect (Game, Snake_Dir_Up);

         when SDL.Events.Joysticks.Hat_Left =>
            Redirect (Game, Snake_Dir_Left);

         when SDL.Events.Joysticks.Hat_Down =>
            Redirect (Game, Snake_Dir_Down);

         when others =>
            null;
      end case;

      return SDL.Main.App_Continue;
   end Handle_Hat_Event;

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
           ("Example Snake game",
            "1.0",
            "com.example.Snake"),
         "Unable to set application metadata");

      Require_SDL
        (SDL.Set_App_Metadata_Property
           (SDL.App_Metadata_URL_Property,
            "https://examples.libsdl.org/SDL3/demo/01-snake/"),
         "Unable to set application URL metadata");
      Require_SDL
        (SDL.Set_App_Metadata_Property
           (SDL.App_Metadata_Creator_Property,
            "SDL team"),
         "Unable to set application creator metadata");
      Require_SDL
        (SDL.Set_App_Metadata_Property
           (SDL.App_Metadata_Copyright_Property,
            "Placed in the public domain"),
         "Unable to set application copyright metadata");
      Require_SDL
        (SDL.Set_App_Metadata_Property
           (SDL.App_Metadata_Type_Property,
            "game"),
         "Unable to set application type metadata");

      Require_SDL
        (SDL.Initialise (SDL.Enable_Video or SDL.Enable_Joystick),
         "Couldn't initialize SDL");
      App.SDL_Initialized := True;

      SDL.Video.Renderers.Makers.Create
        (Window   => App.Window,
         Rend     => App.Renderer,
         Title    => "examples/demo/snake",
         Position => SDL.Video.Windows.Centered_Window_Position,
         Size     => (Width => Window_Width, Height => Window_Height),
         Flags    => SDL.Video.Windows.Resizable);

      SDL.Video.Renderers.Set_Logical_Presentation
        (Self => App.Renderer,
         Size => (Width => Window_Width, Height => Window_Height),
         Mode => SDL.Video.Renderers.Letterbox_Presentation);

      Random_Cells.Reset (Cell_Generator);
      Reset (App.Snake);
      App.Last_Step := SDL.Timers.Ticks;

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
      Now : constant SDL.Timers.Milliseconds := SDL.Timers.Ticks;
   begin
      while Now - App.Last_Step >= Step_Rate_In_Milliseconds loop
         Step (App.Snake);
         App.Last_Step := App.Last_Step + Step_Rate_In_Milliseconds;
      end loop;

      SDL.Video.Renderers.Set_Draw_Colour (App.Renderer, 0.0, 0.0, 0.0, 1.0);
      SDL.Video.Renderers.Clear (App.Renderer);

      SDL.Video.Renderers.Set_Draw_Colour (App.Renderer, 80.0 / 255.0, 80.0 / 255.0, 1.0, 1.0);
      for Item of App.Snake.Foods loop
         Draw_Cell (App.Renderer, Item);
      end loop;

      SDL.Video.Renderers.Set_Draw_Colour (App.Renderer, 0.0, 128.0 / 255.0, 0.0, 1.0);
      for Index in 2 .. App.Snake.Length loop
         Draw_Cell (App.Renderer, App.Snake.Segments (Index));
      end loop;

      SDL.Video.Renderers.Set_Draw_Colour (App.Renderer, 1.0, 1.0, 0.0, 1.0);
      Draw_Cell (App.Renderer, App.Snake.Segments (1));

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
                     & SDL.Events.Joysticks.IDs'Image (Event.Joystick_Device.Which)
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
      elsif Event.Common.Event_Type = SDL.Events.Joysticks.Hat_Motion then
         return Handle_Hat_Event (App.Snake, Event.Joystick_Hat.Position);
      elsif Event.Common.Event_Type = SDL.Events.Keyboards.Key_Down then
         return Handle_Key_Event (App.Snake, Event.Keyboard.Key_Sym.Scan_Code);
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

      Free_Arguments (Args);

      if Exit_Code /= 0 then
         raise Program_Error with "snake exited with status" & Integer'Image (Integer (Exit_Code));
      end if;
   exception
      when others =>
         Free_Arguments (Args);
         raise;
   end Run;
end Snake_App;
