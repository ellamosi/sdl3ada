with Ada.Exceptions;
with Ada.Text_IO; use Ada.Text_IO;

with Interfaces;
with System;

with SDL;
with SDL.Error;
with SDL.Events.Events;
with SDL.Events.Mice;
with SDL.Properties;
with SDL.Video;
with SDL.Video.Palettes;
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
with SDL.Video.Windows.Makers;

procedure Render_Smoke is
   use type Interfaces.Unsigned_8;
   use type Interfaces.Unsigned_32;
   use type SDL.Dimension;
   use type SDL.Sizes;
   use type SDL.Video.Blend_Modes;
   use type SDL.Video.Palettes.Colour;
   use type SDL.Video.Palettes.Colour_Component;
   use type SDL.Video.Palettes.RGB_Colour;
   use type SDL.Video.Rectangles.Rectangle;
   use type SDL.Video.Renderers.Flip_Modes;
   use type SDL.Video.Renderers.Logical_Presentations;
   use type SDL.Video.Renderers.Texture_Address_Modes;
   use type SDL.Video.Textures.Kinds;
   use type SDL.Video.Textures.Scale_Modes;
   use type SDL.Video.Windows.ID;
   use type System.Address;

   type Pixel_Access is access all SDL.Video.Pixels.ARGB_8888;
   pragma No_Strict_Aliasing (Pixel_Access);

   package Surface_Pixels is new SDL.Video.Surfaces.Pixel_Data
     (Element         => SDL.Video.Pixels.ARGB_8888,
      Element_Pointer => Pixel_Access);

   type Pixel_Buffer is
     array (Natural range 0 .. 63) of aliased SDL.Video.Pixels.ARGB_8888
   with Convention => C;

   function Approx (Left, Right : in Float) return Boolean is
     (abs (Left - Right) <= 0.01);

   procedure Require (Condition : in Boolean; Message : in String) is
   begin
      if not Condition then
         raise Program_Error with Message;
      end if;
   end Require;

   function To_Surface_Colour
     (Self   : in SDL.Video.Surfaces.Surface;
      Colour : in SDL.Video.Palettes.Colour) return Interfaces.Unsigned_32 is
   begin
      return SDL.Video.Pixel_Formats.To_Pixel (Colour, Self.Pixel_Format);
   end To_Surface_Colour;

   Bits       : SDL.Video.Pixel_Formats.Bits_Per_Pixels;
   Red_Mask   : SDL.Video.Pixel_Formats.Colour_Mask;
   Green_Mask : SDL.Video.Pixel_Formats.Colour_Mask;
   Blue_Mask  : SDL.Video.Pixel_Formats.Colour_Mask;
   Alpha_Mask : SDL.Video.Pixel_Formats.Colour_Mask;

   Backing_Surface : SDL.Video.Surfaces.Surface;
   Source_Surface  : SDL.Video.Surfaces.Surface;
   Renderer        : SDL.Video.Renderers.Renderer;
   Target_Texture  : SDL.Video.Textures.Texture;
   Stream_Texture  : SDL.Video.Textures.Texture;
   Image_Texture   : SDL.Video.Textures.Texture;
begin
   if not SDL.Initialise (SDL.Enable_Video) then
      raise Program_Error with "SDL initialization failed: " & SDL.Error.Get;
   end if;

   Require
     (SDL.Video.Pixel_Formats.To_Masks
        (Format     => SDL.Video.Pixel_Formats.Pixel_Format_ARGB_8888,
         Bits       => Bits,
         Red_Mask   => Red_Mask,
         Green_Mask => Green_Mask,
         Blue_Mask  => Blue_Mask,
         Alpha_Mask => Alpha_Mask),
      "Unable to resolve ARGB8888 masks");

   SDL.Video.Surfaces.Makers.Create
     (Self       => Backing_Surface,
      Size       => (Width => 64, Height => 64),
      BPP        => SDL.Video.Surfaces.Pixel_Depths (Bits),
      Red_Mask   => SDL.Video.Surfaces.Colour_Masks (Red_Mask),
      Green_Mask => SDL.Video.Surfaces.Colour_Masks (Green_Mask),
      Blue_Mask  => SDL.Video.Surfaces.Colour_Masks (Blue_Mask),
      Alpha_Mask => SDL.Video.Surfaces.Colour_Masks (Alpha_Mask));

   SDL.Video.Surfaces.Makers.Create
     (Self       => Source_Surface,
      Size       => (Width => 8, Height => 8),
      BPP        => SDL.Video.Surfaces.Pixel_Depths (Bits),
      Red_Mask   => SDL.Video.Surfaces.Colour_Masks (Red_Mask),
      Green_Mask => SDL.Video.Surfaces.Colour_Masks (Green_Mask),
      Blue_Mask  => SDL.Video.Surfaces.Colour_Masks (Blue_Mask),
      Alpha_Mask => SDL.Video.Surfaces.Colour_Masks (Alpha_Mask));

   SDL.Video.Surfaces.Fill
     (Self   => Source_Surface,
      Area   => (X => 0, Y => 0, Width => 8, Height => 8),
      Colour =>
        To_Surface_Colour
          (Source_Surface,
           (Red => 16#D0#, Green => 16#40#, Blue => 16#30#, Alpha => 16#FF#)));

   SDL.Video.Renderers.Makers.Create (Renderer, Backing_Surface);

   Require (SDL.Video.Renderers.Name (Renderer) /= "", "Expected renderer name");
   Require
     (SDL.Video.Renderers.Get_Window_ID (Renderer) = 0,
      "Expected software renderer to have no window");
   Require
     (SDL.Video.Renderers.Get_Properties (Renderer) /= SDL.Properties.Null_Property_ID,
      "Expected renderer properties");
   Require
     (SDL.Video.Renderers.Get_Output_Size (Renderer) = (Width => 64, Height => 64),
      "Unexpected render output size");
   Require
     (SDL.Video.Renderers.Get_Current_Output_Size (Renderer) = (Width => 64, Height => 64),
      "Unexpected current render output size");
   Require
     (SDL.Video.Renderers.Get_Metal_Layer (Renderer) = System.Null_Address,
      "Expected no Metal layer on the software renderer");
   Require
     (SDL.Video.Renderers.Get_Metal_Command_Encoder (Renderer) = System.Null_Address,
      "Expected no Metal command encoder on the software renderer");

   declare
      Name : constant String := SDL.Video.Renderers.Name (Renderer);
   begin
      if Name = "vulkan" then
         SDL.Video.Renderers.Add_Vulkan_Render_Semaphores
           (Self            => Renderer,
            Wait_Stage_Mask => 0);
      else
         Put_Line
           ("Skipping renderer Vulkan semaphore validation on renderer """
            & Name & """");
      end if;
   end;

   SDL.Video.Renderers.Set_Blend_Mode (Renderer, SDL.Video.Alpha_Blend);
   Require
     (SDL.Video.Renderers.Get_Blend_Mode (Renderer) = SDL.Video.Alpha_Blend,
      "Renderer blend-mode round trip failed");

   SDL.Video.Renderers.Set_Draw_Colour
     (Renderer,
      (Red => 16#22#, Green => 16#44#, Blue => 16#66#, Alpha => 16#FF#));
   Require
     (SDL.Video.Renderers.Get_Draw_Colour (Renderer) =
        (Red => 16#22#, Green => 16#44#, Blue => 16#66#, Alpha => 16#FF#),
      "Renderer byte draw-color round trip failed");

   SDL.Video.Renderers.Set_Draw_Colour (Renderer, 0.25, 0.50, 0.75, 1.0);

   declare
      Red   : Float := 0.0;
      Green : Float := 0.0;
      Blue  : Float := 0.0;
      Alpha : Float := 0.0;
   begin
      SDL.Video.Renderers.Get_Draw_Colour (Renderer, Red, Green, Blue, Alpha);
      Require
        (Approx (Red, 0.25)
         and then Approx (Green, 0.50)
         and then Approx (Blue, 0.75)
         and then Approx (Alpha, 1.0),
         "Renderer float draw-color round trip failed");
   end;

   SDL.Video.Renderers.Set_Colour_Scale (Renderer, 1.0);
   Require
     (Approx (SDL.Video.Renderers.Get_Colour_Scale (Renderer), 1.0),
      "Renderer colour-scale round trip failed");

   SDL.Video.Renderers.Set_Viewport
     (Renderer,
      (X => 0, Y => 0, Width => 32, Height => 32));
   Require
     (SDL.Video.Renderers.Is_Viewport_Set (Renderer),
      "Expected viewport state to be enabled");
   Require
     (SDL.Video.Renderers.Get_Viewport (Renderer) =
        (X => 0, Y => 0, Width => 32, Height => 32),
      "Viewport round trip failed");

   SDL.Video.Renderers.Set_Clip
     (Renderer,
      (X => 2, Y => 2, Width => 24, Height => 24));
   Require
     (SDL.Video.Renderers.Is_Clip_Enabled (Renderer),
      "Expected clip state to be enabled");
   Require
     (SDL.Video.Renderers.Get_Clip (Renderer) =
        (X => 2, Y => 2, Width => 24, Height => 24),
      "Clip round trip failed");

   SDL.Video.Renderers.Set_Scale (Renderer, 1.5, 1.25);

   declare
      Scale : constant SDL.Video.Rectangles.Float_Point :=
        SDL.Video.Renderers.Get_Scale (Renderer);
   begin
      Require
        (Approx (Scale.X, 1.5) and then Approx (Scale.Y, 1.25),
         "Scale round trip failed");
   end;

   SDL.Video.Renderers.Set_Logical_Presentation
     (Renderer,
      Size => (Width => 32, Height => 32),
      Mode => SDL.Video.Renderers.Letterbox_Presentation);

   declare
      Width  : SDL.Natural_Dimension := 0;
      Height : SDL.Natural_Dimension := 0;
      Mode   : SDL.Video.Renderers.Logical_Presentations :=
        SDL.Video.Renderers.Logical_Presentation_Disabled;
   begin
      SDL.Video.Renderers.Get_Logical_Presentation
        (Renderer, Width, Height, Mode);
      Require
        (Width = 32
         and then Height = 32
         and then Mode = SDL.Video.Renderers.Letterbox_Presentation,
         "Logical presentation round trip failed");
   end;

   Require
     (SDL.Video.Renderers.Get_Safe_Area (Renderer).Width > 0,
      "Expected non-empty render safe area");

   SDL.Video.Renderers.Reset_Viewport (Renderer);
   SDL.Video.Renderers.Disable_Clip (Renderer);
   SDL.Video.Renderers.Set_Scale (Renderer, 1.0, 1.0);

   SDL.Video.Textures.Makers.Create
     (Tex      => Target_Texture,
      Renderer => Renderer,
      Format   => SDL.Video.Pixel_Formats.Pixel_Format_ARGB_8888,
      Kind     => SDL.Video.Textures.Target,
      Size     => (Width => 32, Height => 32));

   SDL.Video.Textures.Makers.Create
     (Tex      => Stream_Texture,
      Renderer => Renderer,
      Format   => SDL.Video.Pixel_Formats.Pixel_Format_ARGB_8888,
      Kind     => SDL.Video.Textures.Streaming,
      Size     => (Width => 8, Height => 8));

   SDL.Video.Textures.Makers.Create
     (Tex      => Image_Texture,
      Renderer => Renderer,
      Surface  => Source_Surface);

   Require
     (SDL.Video.Textures.Get_Properties (Target_Texture) /=
        SDL.Properties.Null_Property_ID,
      "Expected texture properties");
   Require
     (SDL.Video.Textures.Get_Kind (Target_Texture) = SDL.Video.Textures.Target,
      "Unexpected target texture kind");

   SDL.Video.Renderers.Set_Default_Texture_Scale_Mode
     (Renderer, SDL.Video.Textures.Pixel_Art);
   Require
     (SDL.Video.Renderers.Get_Default_Texture_Scale_Mode (Renderer) =
        SDL.Video.Textures.Pixel_Art,
      "Default texture scale-mode round trip failed");

   SDL.Video.Textures.Set_Scale_Mode
     (Target_Texture, SDL.Video.Textures.Pixel_Art);
   Require
     (SDL.Video.Textures.Get_Scale_Mode (Target_Texture) =
        SDL.Video.Textures.Pixel_Art,
      "Texture scale-mode round trip failed");

   SDL.Video.Textures.Set_Blend_Mode
     (Stream_Texture, SDL.Video.Alpha_Blend);
   Require
     (SDL.Video.Textures.Get_Blend_Mode (Stream_Texture) =
        SDL.Video.Alpha_Blend,
      "Texture blend-mode round trip failed");

   declare
      Indexed_Texture : SDL.Video.Textures.Texture;
      Palette_Colours : constant SDL.Video.Palettes.Colour_Arrays (0 .. 1) :=
        ((Red => 16#10#, Green => 16#20#, Blue => 16#30#, Alpha => 16#FF#),
         (Red => 16#F0#, Green => 16#E0#, Blue => 16#D0#, Alpha => 16#FF#));
      Texture_Palette : SDL.Video.Palettes.Palette := SDL.Video.Palettes.Create (2);
   begin
      SDL.Video.Palettes.Set_Colours (Texture_Palette, Palette_Colours);

      SDL.Video.Textures.Makers.Create
        (Tex      => Indexed_Texture,
         Renderer => Renderer,
         Format   => SDL.Video.Pixel_Formats.Pixel_Format_Index_8,
         Kind     => SDL.Video.Textures.Static,
         Size     => (Width => 2, Height => 1));
      SDL.Video.Textures.Set_Palette (Indexed_Texture, Texture_Palette);

      declare
         Retrieved_Palette : SDL.Video.Palettes.Palette :=
           SDL.Video.Textures.Get_Palette (Indexed_Texture);
         Entry_Count : Natural := 0;
      begin
         Require
           (SDL.Video.Palettes.Get_Internal (Retrieved_Palette) /=
              System.Null_Address,
            "Expected indexed texture palette");

         for Colour_Entry of Retrieved_Palette loop
            case Entry_Count is
               when 0 =>
                  Require
                    (Colour_Entry = Palette_Colours (0),
                     "Indexed texture palette first entry mismatch");
               when 1 =>
                  Require
                    (Colour_Entry = Palette_Colours (1),
                     "Indexed texture palette second entry mismatch");
               when others =>
                  null;
            end case;

            Entry_Count := Entry_Count + 1;
         end loop;

         Require (Entry_Count = 2, "Unexpected indexed texture palette size");
         SDL.Video.Palettes.Free (Retrieved_Palette);
      exception
         when others =>
            SDL.Video.Palettes.Free (Retrieved_Palette);
            raise;
      end;

      SDL.Video.Palettes.Free (Texture_Palette);
   exception
      when others =>
         SDL.Video.Palettes.Free (Texture_Palette);
         raise;
   end;

   declare
      Custom_Blend : constant SDL.Video.Blend_Modes :=
        SDL.Video.Compose_Custom_Blend_Mode
          (Source_Colour_Factor      => SDL.Video.Source_Alpha_Factor,
           Destination_Colour_Factor => SDL.Video.One_Minus_Source_Alpha_Factor,
           Colour_Operation          => SDL.Video.Add_Operation,
           Source_Alpha_Factor       => SDL.Video.One_Factor,
           Destination_Alpha_Factor  => SDL.Video.One_Minus_Source_Alpha_Factor,
           Alpha_Operation           => SDL.Video.Add_Operation);
      Renderer_Name : constant String := SDL.Video.Renderers.Name (Renderer);
   begin
      Require
        (Custom_Blend /= SDL.Video.Invalid_Blend_Mode,
         "Custom blend composition returned the invalid sentinel");

      if Renderer_Name /= "software" then
         SDL.Video.Renderers.Set_Blend_Mode (Renderer, Custom_Blend);
         Require
           (SDL.Video.Renderers.Get_Blend_Mode (Renderer) = Custom_Blend,
            "Renderer custom blend-mode round trip failed");
         SDL.Video.Renderers.Set_Blend_Mode (Renderer, SDL.Video.Alpha_Blend);

         SDL.Video.Textures.Set_Blend_Mode (Stream_Texture, Custom_Blend);
         Require
           (SDL.Video.Textures.Get_Blend_Mode (Stream_Texture) = Custom_Blend,
            "Texture custom blend-mode round trip failed");
         SDL.Video.Textures.Set_Blend_Mode (Stream_Texture, SDL.Video.Alpha_Blend);
      else
         Put_Line ("Skipping custom blend-mode application on software renderer");
      end if;
   end;

   declare
      Event_Window   : SDL.Video.Windows.Window;
      Window_Renderer : SDL.Video.Renderers.Renderer;
   begin
      SDL.Video.Windows.Makers.Create
        (Win    => Event_Window,
         Title  => "render-smoke-event-conversion",
         X      => 0,
         Y      => 0,
         Width  => 64,
         Height => 64,
         Flags  => SDL.Video.Windows.Hidden);
      SDL.Video.Renderers.Makers.Create
        (Rend   => Window_Renderer,
         Window => Event_Window,
         Flags  => SDL.Video.Renderers.Software);
      SDL.Video.Renderers.Set_Logical_Presentation
        (Window_Renderer,
         Size => (Width => 32, Height => 32),
         Mode => SDL.Video.Renderers.Stretch_Presentation);

      Require
        (SDL.Video.Renderers.Get_Window_ID (Window_Renderer) =
           SDL.Video.Windows.Get_ID (Event_Window),
         "Window renderer did not retain the expected window");

      declare
         Origin : constant SDL.Video.Rectangles.Float_Point :=
           SDL.Video.Renderers.Window_Coordinates_To_Render
             (Window_Renderer, (X => 0.0, Y => 0.0));
         Expected_Position : constant SDL.Video.Rectangles.Float_Point :=
           SDL.Video.Renderers.Window_Coordinates_To_Render
             (Window_Renderer, (X => 16.0, Y => 24.0));
         Relative_End : constant SDL.Video.Rectangles.Float_Point :=
           SDL.Video.Renderers.Window_Coordinates_To_Render
             (Window_Renderer, (X => 8.0, Y => 12.0));
         Event : SDL.Events.Events.Events :=
           (Kind         => SDL.Events.Events.Is_Mouse_Motion_Event,
            Mouse_Motion =>
              (Event_Type => SDL.Events.Mice.Motion,
               Reserved   => 0,
               Time_Stamp => 0,
               Window     => SDL.Video.Windows.Get_ID (Event_Window),
               Which      => 0,
               Mask       => 0,
               X          => 16.0,
               Y          => 24.0,
               X_Relative => 8.0,
               Y_Relative => 12.0));
      begin
         SDL.Video.Renderers.Convert_Event_Coordinates (Window_Renderer, Event);

         Require
           (Approx (Float (Event.Mouse_Motion.X), Expected_Position.X)
            and then Approx (Float (Event.Mouse_Motion.Y), Expected_Position.Y),
            "Converted mouse event coordinates mismatch");
         Require
           (Approx
              (Float (Event.Mouse_Motion.X_Relative),
               Relative_End.X - Origin.X)
            and then Approx
              (Float (Event.Mouse_Motion.Y_Relative),
               Relative_End.Y - Origin.Y),
            "Converted mouse event relative coordinates mismatch");
      end;
   end;

   SDL.Video.Textures.Set_Colour
     (Stream_Texture,
      (Red => 16#88#, Green => 16#44#, Blue => 16#22#));
   Require
     (SDL.Video.Textures.Get_Colour (Stream_Texture) =
        (Red => 16#88#, Green => 16#44#, Blue => 16#22#),
      "Texture colour round trip failed");

   SDL.Video.Textures.Set_Alpha (Stream_Texture, 16#C0#);
   Require
     (SDL.Video.Textures.Get_Alpha (Stream_Texture) = 16#C0#,
      "Texture byte alpha round trip failed");

   SDL.Video.Textures.Set_Alpha (Stream_Texture, 0.50);
   Require
     (Approx (SDL.Video.Textures.Get_Alpha_Float (Stream_Texture), 0.50),
      "Texture float alpha round trip failed");

   declare
      Pixels : aliased Pixel_Buffer :=
        (others =>
           (Alpha => 16#FF#, Red => 16#30#, Green => 16#A0#, Blue => 16#D0#));
      Locked_Surface : SDL.Video.Surfaces.Surface :=
        SDL.Video.Textures.Lock_To_Surface (Stream_Texture);
   begin
      SDL.Video.Textures.Unlock (Stream_Texture);
      SDL.Video.Textures.Update
        (Stream_Texture,
         Pixels'Address,
         SDL.Video.Pixels.Pitches (8 * 4));
      SDL.Video.Surfaces.Finalize (Locked_Surface);
   end;

   SDL.Video.Renderers.Set_Target (Renderer, Target_Texture);
   Require
     (not SDL.Video.Textures.Is_Null
        (SDL.Video.Renderers.Get_Target (Renderer)),
      "Expected render target round trip");

   SDL.Video.Renderers.Set_Texture_Address_Modes
     (Renderer,
      SDL.Video.Renderers.Wrap_Addressing,
      SDL.Video.Renderers.Clamp_Addressing);

   declare
      U_Mode : SDL.Video.Renderers.Texture_Address_Modes :=
        SDL.Video.Renderers.Invalid_Address_Mode;
      V_Mode : SDL.Video.Renderers.Texture_Address_Modes :=
        SDL.Video.Renderers.Invalid_Address_Mode;
   begin
      SDL.Video.Renderers.Get_Texture_Address_Modes
        (Renderer, U_Mode, V_Mode);
      Require
        (U_Mode = SDL.Video.Renderers.Wrap_Addressing
         and then V_Mode = SDL.Video.Renderers.Clamp_Addressing,
         "Texture address-mode round trip failed");
   end;

   SDL.Video.Renderers.Set_Draw_Colour
     (Renderer,
      (Red => 16#10#, Green => 16#20#, Blue => 16#30#, Alpha => 16#FF#));
   SDL.Video.Renderers.Clear (Renderer);

   SDL.Video.Renderers.Fill
     (Renderer,
      SDL.Video.Rectangles.Float_Rectangle'
        (X => 6.0, Y => 6.0, Width => 10.0, Height => 10.0));
   SDL.Video.Renderers.Draw
     (Renderer,
      SDL.Video.Rectangles.Float_Rectangle'
        (X => 20.0, Y => 4.0, Width => 6.0, Height => 6.0));
   SDL.Video.Renderers.Draw
     (Renderer,
      SDL.Video.Rectangles.Float_Line_Segment'
        (Start  => (X => 1.0, Y => 30.0),
         Finish => (X => 30.0, Y => 1.0)));

   SDL.Video.Renderers.Copy_To
     (Renderer,
      Stream_Texture,
      SDL.Video.Rectangles.Float_Rectangle'
        (X => 4.0, Y => 4.0, Width => 12.0, Height => 12.0));
   SDL.Video.Renderers.Copy_Rotated
     (Renderer,
      Image_Texture,
      Source => SDL.Video.Rectangles.Float_Rectangle'
        (X => 0.0, Y => 0.0, Width => 8.0, Height => 8.0),
      Target => SDL.Video.Rectangles.Float_Rectangle'
        (X => 16.0, Y => 16.0, Width => 12.0, Height => 12.0),
      Angle  => 15.0,
      Centre => SDL.Video.Rectangles.Float_Point'(X => 6.0, Y => 6.0),
      Flip   => SDL.Video.Renderers.Horizontal_Flip);
   SDL.Video.Renderers.Copy_Tiled
     (Renderer,
      Stream_Texture,
      Source => SDL.Video.Rectangles.Float_Rectangle'
        (X => 0.0, Y => 0.0, Width => 4.0, Height => 4.0),
      Scale  => 1.0,
      Target => SDL.Video.Rectangles.Float_Rectangle'
        (X => 0.0, Y => 20.0, Width => 12.0, Height => 12.0));
   SDL.Video.Renderers.Copy_Affine
     (Renderer,
      Stream_Texture,
      Origin => SDL.Video.Rectangles.Float_Point'(X => 20.0, Y => 2.0),
      Right  => SDL.Video.Rectangles.Float_Point'(X => 30.0, Y => 3.0),
      Down   => SDL.Video.Rectangles.Float_Point'(X => 18.0, Y => 14.0));
   SDL.Video.Renderers.Copy_9_Grid
     (Renderer,
      Image_Texture,
      Source        => SDL.Video.Rectangles.Float_Rectangle'
        (X => 0.0, Y => 0.0, Width => 8.0, Height => 8.0),
      Left_Width    => 2.0,
      Right_Width   => 2.0,
      Top_Height    => 2.0,
      Bottom_Height => 2.0,
      Scale         => 1.0,
      Target        => SDL.Video.Rectangles.Float_Rectangle'
        (X => 12.0, Y => 20.0, Width => 18.0, Height => 10.0));

   declare
      Vertices : constant SDL.Video.Renderers.Vertex_Arrays (0 .. 2) :=
        ((Position           => (X => 4.0, Y => 18.0),
          Colour             => (Red => 1.0, Green => 0.0, Blue => 0.0, Alpha => 1.0),
          Texture_Coordinate => (X => 0.0, Y => 0.0)),
         (Position           => (X => 14.0, Y => 30.0),
          Colour             => (Red => 0.0, Green => 1.0, Blue => 0.0, Alpha => 1.0),
          Texture_Coordinate => (X => 0.0, Y => 0.0)),
         (Position           => (X => 24.0, Y => 18.0),
          Colour             => (Red => 0.0, Green => 0.0, Blue => 1.0, Alpha => 1.0),
          Texture_Coordinate => (X => 0.0, Y => 0.0)));
      Indices : constant SDL.Video.Renderers.Index_Arrays (0 .. 2) := (0, 1, 2);
      Readback : SDL.Video.Surfaces.Surface;
      Pixel    : Pixel_Access;
   begin
      SDL.Video.Renderers.Render_Geometry (Renderer, Vertices);
      SDL.Video.Renderers.Render_Geometry (Renderer, Vertices, Indices);
      SDL.Video.Renderers.Debug_Text (Renderer, (X => 1.0, Y => 1.0), "dbg");

      Readback := SDL.Video.Renderers.Read_Pixels (Renderer);
      Require
        (Readback.Size = (Width => 32, Height => 32),
         "Unexpected render-target readback size");

      Readback.Lock;
      Pixel := Surface_Pixels.Get (Readback);
      Require (Pixel /= null, "Readback pixel pointer is null");
      Require
        (Pixel.all.Alpha = 16#FF#
         and then Pixel.all.Red = 16#10#
         and then Pixel.all.Green = 16#20#
         and then Pixel.all.Blue = 16#30#,
         "Unexpected render-target clear pixel");
      Readback.Unlock;
   end;

   SDL.Video.Renderers.Reset_Target (Renderer);
   SDL.Video.Renderers.Copy_To
     (Renderer,
      Target_Texture,
      SDL.Video.Rectangles.Float_Rectangle'
        (X => 0.0, Y => 0.0, Width => 32.0, Height => 32.0));
   SDL.Video.Renderers.Flush (Renderer);
   SDL.Video.Renderers.Present (Renderer);

   declare
      Readback : SDL.Video.Surfaces.Surface :=
        SDL.Video.Renderers.Read_Pixels
          (Renderer, (X => 0, Y => 0, Width => 1, Height => 1));
      Pixel : Pixel_Access;
   begin
      Readback.Lock;
      Pixel := Surface_Pixels.Get (Readback);
      Require (Pixel /= null, "Final readback pixel pointer is null");
      Require
        (Pixel.all.Alpha = 16#FF#, "Expected non-transparent final readback pixel");
      Readback.Unlock;
   end;

   SDL.Video.Textures.Finalize (Image_Texture);
   SDL.Video.Textures.Finalize (Stream_Texture);
   SDL.Video.Textures.Finalize (Target_Texture);
   SDL.Video.Renderers.Finalize (Renderer);
   SDL.Video.Surfaces.Finalize (Source_Surface);
   SDL.Video.Surfaces.Finalize (Backing_Surface);
   SDL.Quit;

   Put_Line ("Render smoke completed successfully.");
exception
   when Error : others =>
      SDL.Video.Textures.Finalize (Image_Texture);
      SDL.Video.Textures.Finalize (Stream_Texture);
      SDL.Video.Textures.Finalize (Target_Texture);
      SDL.Video.Renderers.Finalize (Renderer);
      SDL.Video.Surfaces.Finalize (Source_Surface);
      SDL.Video.Surfaces.Finalize (Backing_Surface);
      SDL.Quit;

      Put_Line ("Render smoke failed: " & Ada.Exceptions.Exception_Message (Error));

      declare
         Message : constant String := SDL.Error.Get;
      begin
         if Message /= "" then
            Put_Line ("SDL error: " & Message);
         end if;
      end;

      raise;
end Render_Smoke;
