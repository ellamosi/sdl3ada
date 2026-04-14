with Ada.Command_Line;
with Ada.Unchecked_Conversion;
with Ada.Unchecked_Deallocation;

with Interfaces;
with Interfaces.C;
with Interfaces.C.Strings;
with System;

with SDL;
with SDL.Error;
with SDL.Events;
with SDL.Events.Queue;
with SDL.Main;
with SDL.Timers;
with SDL.Video.Palettes;
with SDL.Video.Pixel_Formats;
with SDL.Video.Rectangles;
with SDL.Video.Renderers;
with SDL.Video.Renderers.Makers;
with SDL.Video.Surfaces;
with SDL.Video.Textures;
with SDL.Video.Textures.Makers;
with SDL.Video.Windows;

package body Streaming_Textures_App is
   package C renames Interfaces.C;
   package CS renames Interfaces.C.Strings;

   use type C.int;
   use type CS.chars_ptr;
   use type SDL.Events.Event_Types;
   use type SDL.Main.App_Results;
   use type SDL.Timers.Milliseconds;

   Texture_Size  : constant SDL.Positive_Dimension := 150;
   Strip_Height  : constant SDL.Positive_Dimension := Texture_Size / 10;
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

   procedure Free_State is new Ada.Unchecked_Deallocation (State, State_Access);
   procedure Free_Argument_Vector is new Ada.Unchecked_Deallocation
     (CS.chars_ptr_array, Argument_Vector_Access);

   function To_State is new Ada.Unchecked_Conversion (System.Address, State_Access);
   function To_Address is new Ada.Unchecked_Conversion (State_Access, System.Address);

   procedure Require_SDL (Condition : in Boolean; Message : in String);
   procedure Cleanup (App : in out State);
   function To_Surface_Colour
     (Self             : in SDL.Video.Surfaces.Surface;
      Red, Green, Blue : in SDL.Video.Palettes.Colour_Component)
      return Interfaces.Unsigned_32;
   function Moving_Strip (Scale : in Float) return SDL.Video.Rectangles.Rectangle;
   procedure Update_Texture (App : in out State; Scale : in Float);

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
      SDL.Video.Textures.Finalize (App.Texture);
      SDL.Video.Renderers.Finalize (App.Renderer);
      SDL.Video.Windows.Finalize (App.Window);

      if App.SDL_Initialized then
         SDL.Quit;
         App.SDL_Initialized := False;
      end if;
   end Cleanup;

   function To_Surface_Colour
     (Self             : in SDL.Video.Surfaces.Surface;
      Red, Green, Blue : in SDL.Video.Palettes.Colour_Component)
      return Interfaces.Unsigned_32
   is
   begin
      return SDL.Video.Pixel_Formats.To_Pixel
        (Format => SDL.Video.Surfaces.Pixel_Format (Self),
         Red    => Red,
         Green  => Green,
         Blue   => Blue);
   end To_Surface_Colour;

   function Moving_Strip
     (Scale : in Float) return SDL.Video.Rectangles.Rectangle
   is
      Strip_Y : constant SDL.Coordinate :=
        SDL.Coordinate
          (Integer
             (Float (Texture_Size - Strip_Height) * ((Scale + 1.0) / 2.0)));
   begin
      return
        (X      => 0,
         Y      => Strip_Y,
         Width  => Texture_Size,
         Height => Strip_Height);
   end Moving_Strip;

   procedure Update_Texture (App : in out State; Scale : in Float) is
      Surface : SDL.Video.Surfaces.Surface;
   begin
      Surface := SDL.Video.Textures.Lock_To_Surface (App.Texture);

      SDL.Video.Surfaces.Fill
        (Surface,
         To_Surface_Colour (Surface, 0, 0, 0));
      SDL.Video.Surfaces.Fill
        (Surface,
         Moving_Strip (Scale),
         To_Surface_Colour (Surface, 0, 255, 0));

      SDL.Video.Textures.Unlock (App.Texture);
   exception
      when others =>
         SDL.Video.Textures.Unlock (App.Texture);
         raise;
   end Update_Texture;

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
           ("Example Renderer Streaming Textures",
            "1.0",
            "com.example.renderer-streaming-textures"),
         "Unable to set application metadata");

      Require_SDL
        (SDL.Initialise (SDL.Enable_Video),
         "Couldn't initialize SDL");
      App.SDL_Initialized := True;

      SDL.Video.Renderers.Makers.Create
        (Window   => App.Window,
         Rend     => App.Renderer,
         Title    => "examples/renderer/streaming-textures",
         Position => SDL.Video.Windows.Centered_Window_Position,
         Size     => (Width => Window_Width, Height => Window_Height),
         Flags    => SDL.Video.Windows.Resizable);

      SDL.Video.Renderers.Set_Logical_Presentation
        (Self => App.Renderer,
         Size => (Width => Window_Width, Height => Window_Height),
         Mode => SDL.Video.Renderers.Letterbox_Presentation);

      SDL.Video.Textures.Makers.Create
        (Tex      => App.Texture,
         Renderer => App.Renderer,
         Format   => SDL.Video.Pixel_Formats.Pixel_Format_RGBA_8888,
         Kind     => SDL.Video.Textures.Streaming,
         Size     => (Width => Texture_Size, Height => Texture_Size));

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
      Cycle_Length : constant SDL.Timers.Milliseconds := 2_000;
      Half_Cycle   : constant SDL.Timers.Milliseconds := 1_000;
      Half_Range   : constant Float := Float (Half_Cycle) / 2.0;
      App          : constant State_Access := To_State (App_State);
      Now          : constant SDL.Timers.Milliseconds := SDL.Timers.Ticks;
      Direction    : constant Float :=
        (if (Now mod Cycle_Length) >= Half_Cycle then 1.0 else -1.0);
      Scale        : constant Float :=
        ((Float (Now mod Half_Cycle) - Half_Range) / Half_Range) * Direction;
      Dst_Rect     : constant SDL.Video.Rectangles.Float_Rectangle :=
        (X      => Float (Window_Width - Texture_Size) / 2.0,
         Y      => Float (Window_Height - Texture_Size) / 2.0,
         Width  => Float (Texture_Size),
         Height => Float (Texture_Size));
   begin
      Update_Texture (App.all, Scale);

      SDL.Video.Renderers.Set_Draw_Colour
        (App.Renderer,
         (Red => 66, Green => 66, Blue => 66, Alpha => 255));
      SDL.Video.Renderers.Clear (App.Renderer);
      SDL.Video.Renderers.Copy_To (App.Renderer, App.Texture, Dst_Rect);
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
              "streaming_textures exited with status"
              & Integer'Image (Integer (Exit_Code));
         end;
      end if;

      Free_Arguments (Args);
   exception
      when others =>
         Free_Arguments (Args);
         raise;
   end Run;
end Streaming_Textures_App;
