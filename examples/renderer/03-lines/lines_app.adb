with Ada.Command_Line;
with Ada.Numerics;
with Ada.Numerics.Elementary_Functions;
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
with SDL.Video.Rectangles;
with SDL.Video.Renderers;
with SDL.Video.Renderers.Makers;
with SDL.Video.Windows;

package body Lines_App is
   package C renames Interfaces.C;
   package CS renames Interfaces.C.Strings;
   package Random_Floats renames Ada.Numerics.Float_Random;

   use type C.int;
   use type CS.chars_ptr;
   use type SDL.Events.Event_Types;
   use type SDL.Main.App_Results;

   Window_Width  : constant SDL.Positive_Dimension := 640;
   Window_Height : constant SDL.Positive_Dimension := 480;
   Circle_Size   : constant Float := 30.0;
   Circle_Centre_X : constant Float := 320.0;
   Circle_Centre_Y : constant Float := 95.0 - (Circle_Size / 2.0);

   House_Points : constant SDL.Video.Rectangles.Float_Point_Arrays :=
     (0 => (X => 100.0, Y => 354.0),
      1 => (X => 220.0, Y => 230.0),
      2 => (X => 140.0, Y => 230.0),
      3 => (X => 320.0, Y => 100.0),
      4 => (X => 500.0, Y => 230.0),
      5 => (X => 420.0, Y => 230.0),
      6 => (X => 540.0, Y => 354.0),
      7 => (X => 400.0, Y => 354.0),
      8 => (X => 100.0, Y => 354.0));

   Random_Generator : Random_Floats.Generator;

   type State is record
      Window          : SDL.Video.Windows.Window;
      Renderer        : SDL.Video.Renderers.Renderer;
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
   function Random_Unit return Float;

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

   function Random_Unit return Float is
     (Random_Floats.Random (Random_Generator));

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
           ("Example Renderer Lines",
            "1.0",
            "com.example.renderer-lines"),
         "Unable to set application metadata");

      Require_SDL
        (SDL.Initialise (SDL.Enable_Video),
         "Couldn't initialize SDL");
      App.SDL_Initialized := True;

      SDL.Video.Renderers.Makers.Create
        (Window   => App.Window,
         Rend     => App.Renderer,
         Title    => "examples/renderer/lines",
         Position => SDL.Video.Windows.Centered_Window_Position,
         Size     => (Width => Window_Width, Height => Window_Height),
         Flags    => SDL.Video.Windows.Resizable);

      SDL.Video.Renderers.Set_Logical_Presentation
        (Self => App.Renderer,
         Size => (Width => Window_Width, Height => Window_Height),
         Mode => SDL.Video.Renderers.Letterbox_Presentation);

      Random_Floats.Reset (Random_Generator);

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
      use Ada.Numerics.Elementary_Functions;

      App : constant State_Access := To_State (App_State);
   begin
      SDL.Video.Renderers.Set_Draw_Colour
        (App.Renderer,
         (Red => 100, Green => 100, Blue => 100, Alpha => 255));
      SDL.Video.Renderers.Clear (App.Renderer);

      SDL.Video.Renderers.Set_Draw_Colour
        (App.Renderer,
         (Red => 127, Green => 49, Blue => 32, Alpha => 255));
      SDL.Video.Renderers.Draw (App.Renderer, 240, 450, 400, 450);
      SDL.Video.Renderers.Draw (App.Renderer, 240, 356, 400, 356);
      SDL.Video.Renderers.Draw (App.Renderer, 240, 356, 240, 450);
      SDL.Video.Renderers.Draw (App.Renderer, 400, 356, 400, 450);

      SDL.Video.Renderers.Set_Draw_Colour
        (App.Renderer,
         (Red => 0, Green => 255, Blue => 0, Alpha => 255));
      SDL.Video.Renderers.Draw_Connected (App.Renderer, House_Points);

      for Index in 0 .. 359 loop
         declare
            Radians : constant Float :=
              Float (Index) * Float (Ada.Numerics.Pi) / 180.0;
         begin
            SDL.Video.Renderers.Set_Draw_Colour
              (App.Renderer,
               Random_Unit,
               Random_Unit,
               Random_Unit,
               1.0);
            SDL.Video.Renderers.Draw
              (App.Renderer,
               Circle_Centre_X,
               Circle_Centre_Y,
               Circle_Centre_X + (Cos (Radians) * Circle_Size),
               Circle_Centre_Y + (Sin (Radians) * Circle_Size));
         end;
      end loop;

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
              "lines exited with status" & Integer'Image (Integer (Exit_Code));
         end;
      end if;

      Free_Arguments (Args);
   exception
      when others =>
         Free_Arguments (Args);
         raise;
   end Run;
end Lines_App;
