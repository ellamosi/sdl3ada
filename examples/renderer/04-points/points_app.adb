with Ada.Command_Line;
with Ada.Numerics.Float_Random;
with Ada.Unchecked_Conversion;
with Ada.Unchecked_Deallocation;

with Interfaces.C;
with Interfaces.C.Strings;
with System;

with SDL;
with SDL.Error;
with SDL.Events;
with SDL.Events.Queue;
with SDL.Main;
with SDL.Timers;
with SDL.Video.Rectangles;
with SDL.Video.Renderers;
with SDL.Video.Renderers.Makers;
with SDL.Video.Windows;

package body Points_App is
   package C renames Interfaces.C;
   package CS renames Interfaces.C.Strings;
   package Random_Floats renames Ada.Numerics.Float_Random;

   use type C.int;
   use type CS.chars_ptr;
   use type SDL.Events.Event_Types;
   use type SDL.Main.App_Results;
   use type SDL.Timers.Milliseconds;

   Window_Width           : constant SDL.Positive_Dimension := 640;
   Window_Height          : constant SDL.Positive_Dimension := 480;
   Min_Pixels_Per_Second  : constant Float := 30.0;
   Max_Pixels_Per_Second  : constant Float := 60.0;

   subtype Point_Indices is C.size_t range 0 .. 499;
   type Point_Speed_Arrays is array (Point_Indices) of Float;

   Random_Generator : Random_Floats.Generator;

   type State is record
      Window          : SDL.Video.Windows.Window;
      Renderer        : SDL.Video.Renderers.Renderer;
      Last_Time       : SDL.Timers.Milliseconds := 0;
      Points          : SDL.Video.Rectangles.Float_Point_Arrays (Point_Indices) :=
        (others => (others => 0.0));
      Point_Speeds    : Point_Speed_Arrays := (others => 0.0);
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
   function Random_Float (Minimum, Maximum : in Float) return Float;

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
      Event     : access SDL.Events.Queue.Event) return SDL.Main.App_Results
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
      SDL.Video.Renderers.Finalize (App.Renderer);
      SDL.Video.Windows.Finalize (App.Window);

      if App.SDL_Initialized then
         SDL.Quit;
         App.SDL_Initialized := False;
      end if;
   end Cleanup;

   function Random_Float (Minimum, Maximum : in Float) return Float is
     (Minimum + Random_Floats.Random (Random_Generator) * (Maximum - Minimum));

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
           ("Example Renderer Points",
            "1.0",
            "com.example.renderer-points"),
         "Unable to set application metadata");

      Require_SDL
        (SDL.Initialise (SDL.Enable_Video),
         "Couldn't initialize SDL");
      App.SDL_Initialized := True;

      SDL.Video.Renderers.Makers.Create
        (Window   => App.Window,
         Rend     => App.Renderer,
         Title    => "examples/renderer/points",
         Position => SDL.Video.Windows.Centered_Window_Position,
         Size     => (Width => Window_Width, Height => Window_Height),
         Flags    => SDL.Video.Windows.Resizable);

      SDL.Video.Renderers.Set_Logical_Presentation
        (Self => App.Renderer,
         Size => (Width => Window_Width, Height => Window_Height),
         Mode => SDL.Video.Renderers.Letterbox_Presentation);

      Random_Floats.Reset (Random_Generator);

      for Index in App.Points'Range loop
         App.Points (Index) :=
           (X => Random_Float (0.0, Float (Window_Width)),
            Y => Random_Float (0.0, Float (Window_Height)));
         App.Point_Speeds (Index) :=
           Random_Float (Min_Pixels_Per_Second, Max_Pixels_Per_Second);
      end loop;

      App.Last_Time := SDL.Timers.Ticks;

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
      App     : constant State_Access := To_State (App_State);
      Now     : constant SDL.Timers.Milliseconds := SDL.Timers.Ticks;
      Elapsed : constant Float := Float (Now - App.Last_Time) / 1000.0;
   begin
      for Index in App.Points'Range loop
         declare
            Distance : constant Float := Elapsed * App.Point_Speeds (Index);
         begin
            App.Points (Index).X := App.Points (Index).X + Distance;
            App.Points (Index).Y := App.Points (Index).Y + Distance;

            if App.Points (Index).X >= Float (Window_Width)
              or else App.Points (Index).Y >= Float (Window_Height)
            then
               if Random_Floats.Random (Random_Generator) >= 0.5 then
                  App.Points (Index).X := Random_Float (0.0, Float (Window_Width));
                  App.Points (Index).Y := 0.0;
               else
                  App.Points (Index).X := 0.0;
                  App.Points (Index).Y := Random_Float (0.0, Float (Window_Height));
               end if;

               App.Point_Speeds (Index) :=
                 Random_Float (Min_Pixels_Per_Second, Max_Pixels_Per_Second);
            end if;
         end;
      end loop;

      App.Last_Time := Now;

      SDL.Video.Renderers.Set_Draw_Colour
        (App.Renderer,
         (Red => 0, Green => 0, Blue => 0, Alpha => 255));
      SDL.Video.Renderers.Clear (App.Renderer);

      SDL.Video.Renderers.Set_Draw_Colour
        (App.Renderer,
         (Red => 255, Green => 255, Blue => 255, Alpha => 255));
      SDL.Video.Renderers.Draw (App.Renderer, App.Points);

      SDL.Video.Renderers.Present (App.Renderer);
      return SDL.Main.App_Continue;
   end App_Iterate;

   function App_Event
     (App_State : in System.Address;
      Event     : access SDL.Events.Queue.Event) return SDL.Main.App_Results
   is
      pragma Unreferenced (App_State);
   begin
      if Event /= null and then Event.Common.Event_Type = SDL.Events.Quit then
         return SDL.Main.App_Success;
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
              "points exited with status" & Integer'Image (Integer (Exit_Code));
         end;
      end if;

      Free_Arguments (Args);
   exception
      when others =>
         Free_Arguments (Args);
         raise;
   end Run;
end Points_App;
