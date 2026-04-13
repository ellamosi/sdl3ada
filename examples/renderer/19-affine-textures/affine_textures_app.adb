with Ada.Command_Line;
with Ada.Numerics;
with Ada.Numerics.Elementary_Functions;
with Ada.Unchecked_Conversion;
with Ada.Unchecked_Deallocation;

with Interfaces.C;
with Interfaces.C.Strings;
with System;

with SDL;
with SDL.Error;
with SDL.Events;
with SDL.Events.Events;
with SDL.Filesystems;
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

package body Affine_Textures_App is
   package C renames Interfaces.C;
   package CS renames Interfaces.C.Strings;

   use type C.int;
   use type CS.chars_ptr;
   use type SDL.Events.Event_Types;
   use type SDL.Main.App_Results;
   use type SDL.Timers.Milliseconds;

   Window_Width  : constant SDL.Positive_Dimension := 640;
   Window_Height : constant SDL.Positive_Dimension := 480;

   type State is record
      Window          : SDL.Video.Windows.Window;
      Renderer        : SDL.Video.Renderers.Renderer;
      Texture         : SDL.Video.Textures.Texture;
      SDL_Initialized : Boolean := False;
   end record;

   type State_Access is access all State;
   type Argument_Vector_Access is access CS.chars_ptr_array;

   type Matrix_3x3 is array (Integer range 0 .. 2, Integer range 0 .. 2) of Float;
   type Corner_Arrays is array (Integer range 0 .. 7) of SDL.Video.Rectangles.Float_Point;

   procedure Free_State is new Ada.Unchecked_Deallocation (State, State_Access);
   procedure Free_Argument_Vector is new Ada.Unchecked_Deallocation
     (CS.chars_ptr_array, Argument_Vector_Access);

   function To_State is new Ada.Unchecked_Conversion (System.Address, State_Access);
   function To_Address is new Ada.Unchecked_Conversion (State_Access, System.Address);

   procedure Require_SDL (Condition : in Boolean; Message : in String);
   function Sample_Path return String;
   procedure Cleanup (App : in out State);
   function Scale_Pixels return Float;
   function Rotation_Matrix (Ticks : in SDL.Timers.Milliseconds) return Matrix_3x3;
   function Project_Corners (Transform : in Matrix_3x3) return Corner_Arrays;
   function Pow2 (Exponent : in Integer) return Integer;
   function Screen_Point
     (Point : in SDL.Video.Rectangles.Float_Point) return SDL.Video.Rectangles.Float_Point;

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

   function Sample_Path return String is
   begin
      return SDL.Filesystems.Base_Path & "../examples/assets/sample.png";
   end Sample_Path;

   procedure Cleanup (App : in out State) is
   begin
      SDL.Video.Textures.Finalize (App.Texture);
      SDL.Video.Renderers.Finalize (App.Renderer);
      SDL.Video.Windows.Finalize (App.Window);

      if App.SDL_Initialized then
         SDL.Quit;
         App.SDL_Initialized := False;
      end if;
   end Cleanup;

   function Scale_Pixels return Float is
   begin
      if Window_Width < Window_Height then
         return Float (Window_Width) / Ada.Numerics.Elementary_Functions.Sqrt (3.0);
      end if;

      return Float (Window_Height) / Ada.Numerics.Elementary_Functions.Sqrt (3.0);
   end Scale_Pixels;

   function Rotation_Matrix (Ticks : in SDL.Timers.Milliseconds) return Matrix_3x3 is
      use Ada.Numerics.Elementary_Functions;

      Cycle_Length : constant SDL.Timers.Milliseconds := 2_000;
      Rad : constant Float :=
        Float (Ticks mod Cycle_Length) / Float (Cycle_Length) * 2.0 * Ada.Numerics.Pi;
      Cosine : constant Float := Cos (Rad);
      Sine   : constant Float := Sin (Rad);
      Root_50 : constant Float := Sqrt (50.0);
      K0 : constant Float := 3.0 / Root_50;
      K1 : constant Float := 4.0 / Root_50;
      K2 : constant Float := 5.0 / Root_50;
   begin
      return
        (0 =>
           (0 => Cosine + (1.0 - Cosine) * K0 * K0,
            1 => -Sine * K2 + (1.0 - Cosine) * K0 * K1,
            2 => Sine * K1 + (1.0 - Cosine) * K0 * K2),
         1 =>
           (0 => Sine * K2 + (1.0 - Cosine) * K0 * K1,
            1 => Cosine + (1.0 - Cosine) * K1 * K1,
            2 => -Sine * K0 + (1.0 - Cosine) * K1 * K2),
         2 =>
           (0 => -Sine * K1 + (1.0 - Cosine) * K0 * K2,
            1 => Sine * K0 + (1.0 - Cosine) * K1 * K2,
            2 => Cosine + (1.0 - Cosine) * K2 * K2));
   end Rotation_Matrix;

   function Project_Corners (Transform : in Matrix_3x3) return Corner_Arrays is
      Result : Corner_Arrays;
   begin
      for Index in Result'Range loop
         declare
            X : constant Float := (if (Index mod 2) = 1 then -0.5 else 0.5);
            Y : constant Float := (if ((Index / 2) mod 2) = 1 then -0.5 else 0.5);
            Z : constant Float := (if ((Index / 4) mod 2) = 1 then -0.5 else 0.5);
         begin
            Result (Index) :=
              (X => Transform (0, 0) * X + Transform (0, 1) * Y + Transform (0, 2) * Z,
               Y => Transform (1, 0) * X + Transform (1, 1) * Y + Transform (1, 2) * Z);
         end;
      end loop;

      return Result;
   end Project_Corners;

   function Pow2 (Exponent : in Integer) return Integer is
   begin
      case Exponent is
         when 0 =>
            return 1;
         when 1 =>
            return 2;
         when 2 =>
            return 4;
         when others =>
            raise Constraint_Error with "Invalid power-of-two exponent";
      end case;
   end Pow2;

   function Screen_Point
     (Point : in SDL.Video.Rectangles.Float_Point) return SDL.Video.Rectangles.Float_Point
   is
      Centre_X : constant Float := Float (Window_Width) / 2.0;
      Centre_Y : constant Float := Float (Window_Height) / 2.0;
      Pixels   : constant Float := Scale_Pixels;
   begin
      return
        (X => Centre_X + Pixels * Point.X,
         Y => Centre_Y + Pixels * Point.Y);
   end Screen_Point;

   function App_Init
     (App_State : access System.Address;
      ArgC      : in C.int;
      ArgV      : access CS.chars_ptr_array) return SDL.Main.App_Results
   is
      pragma Unreferenced (ArgC, ArgV);

      App   : State_Access := new State;
      Image : SDL.Video.Surfaces.Surface;
   begin
      App_State.all := System.Null_Address;

      Require_SDL
        (SDL.Set_App_Metadata
           ("Example Renderer Affine Textures",
            "1.0",
            "com.example.renderer-affine-textures"),
         "Unable to set application metadata");

      Require_SDL
        (SDL.Initialise (SDL.Enable_Video),
         "Couldn't initialize SDL");
      App.SDL_Initialized := True;

      SDL.Video.Renderers.Makers.Create
        (Window   => App.Window,
         Rend     => App.Renderer,
         Title    => "examples/renderer/affine-textures",
         Position => SDL.Video.Windows.Centered_Window_Position,
         Size     => (Width => Window_Width, Height => Window_Height),
         Flags    => SDL.Video.Windows.Resizable);

      SDL.Video.Renderers.Set_Logical_Presentation
        (Self => App.Renderer,
         Size => (Width => Window_Width, Height => Window_Height),
         Mode => SDL.Video.Renderers.Letterbox_Presentation);

      SDL.Video.Surfaces.Makers.Load_PNG (Image, Sample_Path);
      SDL.Video.Textures.Makers.Create (App.Texture, App.Renderer, Image);

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
      App       : constant State_Access := To_State (App_State);
      Transform : constant Matrix_3x3 := Rotation_Matrix (SDL.Timers.Ticks);
      Corners   : constant Corner_Arrays := Project_Corners (Transform);
   begin
      SDL.Video.Renderers.Set_Draw_Colour
        (App.Renderer,
         Float (16#42#) / 255.0,
         Float (16#87#) / 255.0,
         Float (16#F5#) / 255.0,
         1.0);
      SDL.Video.Renderers.Clear (App.Renderer);

      for Face in 1 .. 6 loop
         declare
            Dir : constant Integer := (if Face <= 3 then Face else 7 - Face);
            Odd : constant Integer :=
              (((Face mod 2) + ((Face / 2) mod 2) + ((Face / 4) mod 2)) mod 2);
         begin
            if 0.0 < (if Odd = 1 then 1.0 else -1.0) * Transform (2, Dir - 1) then
               null;
            else
               declare
                  Origin_Index : Integer := Pow2 ((Dir - 1) mod 3);
                  Right_Index  : Integer := Pow2 ((Dir + Odd) mod 3) + Origin_Index;
                  Down_Index   : Integer := Pow2 ((Dir + (1 - Odd)) mod 3) + Origin_Index;
               begin
                  if Odd = 0 then
                     Origin_Index := 7 - Origin_Index;
                     Right_Index  := 7 - Right_Index;
                     Down_Index   := 7 - Down_Index;
                  end if;

                  SDL.Video.Renderers.Copy_Affine
                    (Self    => App.Renderer,
                     Texture => App.Texture,
                     Origin  => Screen_Point (Corners (Origin_Index)),
                     Right   => Screen_Point (Corners (Right_Index)),
                     Down    => Screen_Point (Corners (Down_Index)));
               end;
            end if;
         end;
      end loop;

      SDL.Video.Renderers.Present (App.Renderer);
      return SDL.Main.App_Continue;
   end App_Iterate;

   function App_Event
     (App_State : in System.Address;
      Event     : access SDL.Events.Events.Events) return SDL.Main.App_Results
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
              "affine_textures exited with status"
              & Integer'Image (Integer (Exit_Code));
         end;
      end if;

      Free_Arguments (Args);
   exception
      when others =>
         Free_Arguments (Args);
         raise;
   end Run;
end Affine_Textures_App;
