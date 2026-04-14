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
with SDL.Events.Queue;
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

package body Color_Mods_App is
   package C renames Interfaces.C;
   package CS renames Interfaces.C.Strings;

   use type C.int;
   use type CS.chars_ptr;
   use type SDL.Events.Event_Types;
   use type SDL.Main.App_Results;

   Window_Width  : constant SDL.Positive_Dimension := 640;
   Window_Height : constant SDL.Positive_Dimension := 480;
   Colour_Phase  : constant Float := Float (2.0 * Ada.Numerics.Pi / 3.0);

   type State is record
      Window          : SDL.Video.Windows.Window;
      Renderer        : SDL.Video.Renderers.Renderer;
      Texture         : SDL.Video.Textures.Texture;
      Texture_Size    : SDL.Sizes := SDL.Zero_Size;
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
   function Sample_Path return String;
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
           ("Example Renderer Color Mods",
            "1.0",
            "com.example.renderer-color-mods"),
         "Unable to set application metadata");

      Require_SDL
        (SDL.Initialise (SDL.Enable_Video),
         "Couldn't initialize SDL");
      App.SDL_Initialized := True;

      SDL.Video.Renderers.Makers.Create
        (Window   => App.Window,
         Rend     => App.Renderer,
         Title    => "examples/renderer/color-mods",
         Position => SDL.Video.Windows.Centered_Window_Position,
         Size     => (Width => Window_Width, Height => Window_Height),
         Flags    => SDL.Video.Windows.Resizable);

      SDL.Video.Renderers.Set_Logical_Presentation
        (Self => App.Renderer,
         Size => (Width => Window_Width, Height => Window_Height),
         Mode => SDL.Video.Renderers.Letterbox_Presentation);

      SDL.Video.Surfaces.Makers.Load_PNG (Image, Sample_Path);
      App.Texture_Size := SDL.Video.Surfaces.Size (Image);
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
      use Ada.Numerics.Elementary_Functions;

      App : constant State_Access := To_State (App_State);
      Now : constant Float := Float (SDL.Timers.Ticks) / 1000.0;
      Red : constant Float := 0.5 + 0.5 * Sin (Now);
      Green : constant Float := 0.5 + 0.5 * Sin (Now + Colour_Phase);
      Blue : constant Float := 0.5 + 0.5 * Sin (Now + (2.0 * Colour_Phase));
      Dst_Rect : SDL.Video.Rectangles.Float_Rectangle :=
        (X      => 0.0,
         Y      => 0.0,
         Width  => Float (App.Texture_Size.Width),
         Height => Float (App.Texture_Size.Height));
   begin
      SDL.Video.Renderers.Set_Draw_Colour (App.Renderer, 0.0, 0.0, 0.0, 1.0);
      SDL.Video.Renderers.Clear (App.Renderer);

      SDL.Video.Textures.Set_Colour (App.Texture, 0.0, 0.0, 1.0);
      SDL.Video.Renderers.Copy_To (App.Renderer, App.Texture, Dst_Rect);

      Dst_Rect.X := Float (Window_Width - App.Texture_Size.Width) / 2.0;
      Dst_Rect.Y := Float (Window_Height - App.Texture_Size.Height) / 2.0;
      SDL.Video.Textures.Set_Colour (App.Texture, Red, Green, Blue);
      SDL.Video.Renderers.Copy_To (App.Renderer, App.Texture, Dst_Rect);

      Dst_Rect.X := Float (Window_Width - App.Texture_Size.Width);
      Dst_Rect.Y := Float (Window_Height - App.Texture_Size.Height);
      SDL.Video.Textures.Set_Colour (App.Texture, 1.0, 0.0, 0.0);
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
              "color_mods exited with status" & Integer'Image (Integer (Exit_Code));
         end;
      end if;

      Free_Arguments (Args);
   exception
      when others =>
         Free_Arguments (Args);
         raise;
   end Run;
end Color_Mods_App;
