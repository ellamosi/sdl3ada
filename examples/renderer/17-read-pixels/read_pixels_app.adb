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
with SDL.Filesystems;
with SDL.Main;
with SDL.Timers;
with SDL.Video.Pixel_Formats;
with SDL.Video.Pixels;
with SDL.Video.Rectangles;
with SDL.Video.Renderers;
with SDL.Video.Renderers.Makers;
with SDL.Video.Surfaces;
with SDL.Video.Surfaces.Makers;
with SDL.Video.Textures;
with SDL.Video.Textures.Makers;
with SDL.Video.Windows;

package body Read_Pixels_App is
   package C renames Interfaces.C;
   package CS renames Interfaces.C.Strings;

   use type C.int;
   use type CS.chars_ptr;
   use type Interfaces.Unsigned_32;
   use type SDL.Events.Event_Types;
   use type SDL.Main.App_Results;
   use type SDL.Sizes;
   use type SDL.Timers.Milliseconds;
   use type SDL.Video.Pixel_Formats.Pixel_Format_Access;
   use type SDL.Video.Pixel_Formats.Pixel_Format_Names;

   Window_Width  : constant SDL.Positive_Dimension := 640;
   Window_Height : constant SDL.Positive_Dimension := 480;

   function Red_Of
     (Value : in SDL.Video.Pixels.RGBA_8888)
      return SDL.Video.Pixels.Colour_Component is
     (Value.Red);

   function Green_Of
     (Value : in SDL.Video.Pixels.RGBA_8888)
      return SDL.Video.Pixels.Colour_Component is
     (Value.Green);

   function Blue_Of
     (Value : in SDL.Video.Pixels.RGBA_8888)
      return SDL.Video.Pixels.Colour_Component is
     (Value.Blue);

   function Make_RGBA_8888
     (Alpha : in SDL.Video.Pixels.Colour_Component;
      Red   : in SDL.Video.Pixels.Colour_Component;
      Green : in SDL.Video.Pixels.Colour_Component;
      Blue  : in SDL.Video.Pixels.Colour_Component)
      return SDL.Video.Pixels.RGBA_8888 is
     (Alpha => Alpha, Red => Red, Green => Green, Blue => Blue);

   function Red_Of
     (Value : in SDL.Video.Pixels.BGRA_8888)
      return SDL.Video.Pixels.Colour_Component is
     (Value.Red);

   function Green_Of
     (Value : in SDL.Video.Pixels.BGRA_8888)
      return SDL.Video.Pixels.Colour_Component is
     (Value.Green);

   function Blue_Of
     (Value : in SDL.Video.Pixels.BGRA_8888)
      return SDL.Video.Pixels.Colour_Component is
     (Value.Blue);

   function Make_BGRA_8888
     (Alpha : in SDL.Video.Pixels.Colour_Component;
      Red   : in SDL.Video.Pixels.Colour_Component;
      Green : in SDL.Video.Pixels.Colour_Component;
      Blue  : in SDL.Video.Pixels.Colour_Component)
      return SDL.Video.Pixels.BGRA_8888 is
     (Alpha => Alpha, Red => Red, Green => Green, Blue => Blue);

   generic
      type Pixel is private;
      type Pixel_Pointer is access all Pixel;
      with function Advance
        (Reference : Pixel_Pointer;
         Offset    : C.ptrdiff_t) return Pixel_Pointer;
      with function Red_Of
        (Value : in Pixel) return SDL.Video.Pixels.Colour_Component;
      with function Green_Of
        (Value : in Pixel) return SDL.Video.Pixels.Colour_Component;
      with function Blue_Of
        (Value : in Pixel) return SDL.Video.Pixels.Colour_Component;
      with function Make_Pixel
        (Alpha : in SDL.Video.Pixels.Colour_Component;
         Red   : in SDL.Video.Pixels.Colour_Component;
         Green : in SDL.Video.Pixels.Colour_Component;
         Blue  : in SDL.Video.Pixels.Colour_Component) return Pixel;
   procedure Threshold_Packed_8888 (Image : in out SDL.Video.Surfaces.Surface);

   type State is record
      Window               : SDL.Video.Windows.Window;
      Renderer             : SDL.Video.Renderers.Renderer;
      Texture              : SDL.Video.Textures.Texture;
      Texture_Size         : SDL.Sizes := SDL.Zero_Size;
      Converted_Texture    : SDL.Video.Textures.Texture;
      Converted_Size       : SDL.Sizes := SDL.Zero_Size;
      Converted_Format     : SDL.Video.Pixel_Formats.Pixel_Format_Names :=
        SDL.Video.Pixel_Formats.Pixel_Format_Unknown;
      SDL_Initialized      : Boolean := False;
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
   function To_Positive_Size (Size : in SDL.Sizes) return SDL.Positive_Sizes;
   procedure Cleanup (App : in out State);
   procedure Recreate_Converted_Texture
     (App    : in out State;
      Format : in SDL.Video.Pixel_Formats.Pixel_Format_Names;
      Size   : in SDL.Sizes);
   procedure Threshold_Readback (Image : in out SDL.Video.Surfaces.Surface);
   procedure Process_Readback
     (App   : in out State;
      Image : in out SDL.Video.Surfaces.Surface);

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

   function To_Positive_Size (Size : in SDL.Sizes) return SDL.Positive_Sizes is
   begin
      return
        (Width  => SDL.Positive_Dimension (Size.Width),
         Height => SDL.Positive_Dimension (Size.Height));
   end To_Positive_Size;

   procedure Cleanup (App : in out State) is
   begin
      SDL.Video.Textures.Finalize (App.Converted_Texture);
      SDL.Video.Textures.Finalize (App.Texture);
      SDL.Video.Renderers.Finalize (App.Renderer);
      SDL.Video.Windows.Finalize (App.Window);

      if App.SDL_Initialized then
         SDL.Quit;
         App.SDL_Initialized := False;
      end if;
   end Cleanup;

   procedure Recreate_Converted_Texture
     (App    : in out State;
      Format : in SDL.Video.Pixel_Formats.Pixel_Format_Names;
      Size   : in SDL.Sizes) is
   begin
      if Size = App.Converted_Size
        and then Format = App.Converted_Format
        and then not SDL.Video.Textures.Is_Null (App.Converted_Texture)
      then
         return;
      end if;

      SDL.Video.Textures.Finalize (App.Converted_Texture);
      SDL.Video.Textures.Makers.Create
        (Tex      => App.Converted_Texture,
         Renderer => App.Renderer,
         Format   => Format,
         Kind     => SDL.Video.Textures.Streaming,
         Size     => To_Positive_Size (Size));
      App.Converted_Size := Size;
      App.Converted_Format := Format;
   end Recreate_Converted_Texture;

   procedure Threshold_Packed_8888 (Image : in out SDL.Video.Surfaces.Surface) is
      package Surface_Pixels is new SDL.Video.Surfaces.Pixel_Data
        (Element         => Pixel,
         Element_Pointer => Pixel_Pointer);

      Width  : constant Natural := Natural (SDL.Video.Surfaces.Size (Image).Width);
      Height : constant Natural := Natural (SDL.Video.Surfaces.Size (Image).Height);
      Locked : Boolean := False;
   begin
      SDL.Video.Surfaces.Lock (Image);
      Locked := True;

      for Y in 0 .. Height - 1 loop
         declare
            Row : constant Pixel_Pointer :=
              Surface_Pixels.Get_Row (Image, SDL.Coordinate (Y));
         begin
            for X in 0 .. Width - 1 loop
               declare
                  Current : constant Pixel_Pointer :=
                    Advance (Row, C.ptrdiff_t (X));
                  Average : constant Interfaces.Unsigned_32 :=
                    (Interfaces.Unsigned_32 (Red_Of (Current.all))
                     + Interfaces.Unsigned_32 (Green_Of (Current.all))
                     + Interfaces.Unsigned_32 (Blue_Of (Current.all))) / 3;
               begin
                  if Average = 0 then
                     Current.all :=
                       Make_Pixel
                         (Alpha => 16#FF#,
                          Red   => 16#FF#,
                          Green => 16#00#,
                          Blue  => 16#00#);
                  else
                     declare
                        Level : constant SDL.Video.Pixels.Colour_Component :=
                          (if Average > 50 then 16#FF# else 16#00#);
                     begin
                        Current.all :=
                          Make_Pixel
                            (Alpha => 16#FF#,
                             Red   => Level,
                             Green => Level,
                             Blue  => Level);
                     end;
                  end if;
               end;
            end loop;
         end;
      end loop;

      SDL.Video.Surfaces.Unlock (Image);
   exception
      when others =>
         if Locked then
            SDL.Video.Surfaces.Unlock (Image);
         end if;
         raise;
   end Threshold_Packed_8888;

   procedure Threshold_RGBA_8888 is new Threshold_Packed_8888
     (Pixel         => SDL.Video.Pixels.RGBA_8888,
      Pixel_Pointer => SDL.Video.Pixels.RGBA_8888_Access.Pointer,
      Advance       => SDL.Video.Pixels.RGBA_8888_Access."+",
      Red_Of        => Red_Of,
      Green_Of      => Green_Of,
      Blue_Of       => Blue_Of,
      Make_Pixel    => Make_RGBA_8888);

   procedure Threshold_BGRA_8888 is new Threshold_Packed_8888
     (Pixel         => SDL.Video.Pixels.BGRA_8888,
      Pixel_Pointer => SDL.Video.Pixels.BGRA_8888_Access.Pointer,
      Advance       => SDL.Video.Pixels.BGRA_8888_Access."+",
      Red_Of        => Red_Of,
      Green_Of      => Green_Of,
      Blue_Of       => Blue_Of,
      Make_Pixel    => Make_BGRA_8888);

   procedure Threshold_Readback (Image : in out SDL.Video.Surfaces.Surface) is
      Format : constant SDL.Video.Pixel_Formats.Pixel_Format_Access :=
        SDL.Video.Surfaces.Pixel_Format (Image);
   begin
      if Format = null then
         raise Program_Error with "Readback surface has no pixel format";
      end if;

      case Format.Format is
         when SDL.Video.Pixel_Formats.Pixel_Format_RGBA_8888 =>
            Threshold_RGBA_8888 (Image);

         when SDL.Video.Pixel_Formats.Pixel_Format_BGRA_8888 =>
            Threshold_BGRA_8888 (Image);

         when others =>
            raise Program_Error with
              "Unsupported readback format: "
              & SDL.Video.Pixel_Formats.Image (Format.Format);
      end case;
   end Threshold_Readback;

   procedure Process_Readback
     (App   : in out State;
      Image : in out SDL.Video.Surfaces.Surface) is
      Format : constant SDL.Video.Pixel_Formats.Pixel_Format_Access :=
        SDL.Video.Surfaces.Pixel_Format (Image);
   begin
      if Format = null then
         raise Program_Error with "Readback surface has no pixel format";
      end if;

      Threshold_Readback (Image);
      Recreate_Converted_Texture
        (App,
         Format => Format.Format,
         Size   => SDL.Video.Surfaces.Size (Image));
      SDL.Video.Textures.Update
        (Self   => App.Converted_Texture,
         Pixels => SDL.Video.Surfaces.Pixels (Image),
         Pitch  => SDL.Video.Pixels.Pitches (SDL.Video.Surfaces.Pitch (Image)));
   end Process_Readback;

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
           ("Example Renderer Read Pixels",
            "1.0",
            "com.example.renderer-read-pixels"),
         "Unable to set application metadata");

      Require_SDL
        (SDL.Initialise (SDL.Enable_Video),
         "Couldn't initialize SDL");
      App.SDL_Initialized := True;

      SDL.Video.Renderers.Makers.Create
        (Window   => App.Window,
         Rend     => App.Renderer,
         Title    => "examples/renderer/read-pixels",
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
      App        : constant State_Access := To_State (App_State);
      Now        : constant SDL.Timers.Milliseconds := SDL.Timers.Ticks;
      Rotation   : constant Long_Float :=
        Long_Float (Float (Now mod 2_000) / 2_000.0 * 360.0);
      Dst_Rect   : SDL.Video.Rectangles.Float_Rectangle :=
        (X      => Float (Window_Width - App.Texture_Size.Width) / 2.0,
         Y      => Float (Window_Height - App.Texture_Size.Height) / 2.0,
         Width  => Float (App.Texture_Size.Width),
         Height => Float (App.Texture_Size.Height));
      Center     : constant SDL.Video.Rectangles.Float_Point :=
        (X => Float (App.Texture_Size.Width) / 2.0,
         Y => Float (App.Texture_Size.Height) / 2.0);
      Readback   : SDL.Video.Surfaces.Surface;
      Converted  : SDL.Video.Surfaces.Surface;
      Format     : SDL.Video.Pixel_Formats.Pixel_Format_Access;
   begin
      SDL.Video.Renderers.Set_Draw_Colour (App.Renderer, 0.0, 0.0, 0.0, 1.0);
      SDL.Video.Renderers.Clear (App.Renderer);

      SDL.Video.Renderers.Copy_Rotated
        (Self    => App.Renderer,
         Texture => App.Texture,
         Target  => Dst_Rect,
         Angle   => Rotation,
         Centre  => Center);

      Readback := SDL.Video.Renderers.Read_Pixels (App.Renderer);
      Format := SDL.Video.Surfaces.Pixel_Format (Readback);

      -- Match the C example's fast path: accept packed RGBA/BGRA readback
      -- surfaces directly and only convert other formats.
      if Format = null
        or else
          (Format.Format /= SDL.Video.Pixel_Formats.Pixel_Format_RGBA_8888
           and then Format.Format /= SDL.Video.Pixel_Formats.Pixel_Format_BGRA_8888)
      then
         SDL.Video.Surfaces.Makers.Convert
           (Self         => Converted,
            Src          => Readback,
            Pixel_Format =>
              SDL.Video.Pixel_Formats.Get_Details
                (SDL.Video.Pixel_Formats.Pixel_Format_RGBA_8888));
         Process_Readback (App.all, Converted);
      else
         Process_Readback (App.all, Readback);
      end if;

      Dst_Rect :=
        (X      => 0.0,
         Y      => 0.0,
         Width  => Float (Window_Width) / 4.0,
         Height => Float (Window_Height) / 4.0);
      SDL.Video.Renderers.Copy_To (App.Renderer, App.Converted_Texture, Dst_Rect);

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
              "read_pixels exited with status" & Integer'Image (Integer (Exit_Code));
         end;
      end if;

      Free_Arguments (Args);
   exception
      when others =>
         Free_Arguments (Args);
         raise;
   end Run;
end Read_Pixels_App;
