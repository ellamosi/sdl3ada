with Ada.Directories;
with Ada.Exceptions;
with Ada.Text_IO; use Ada.Text_IO;
with System;

with Interfaces;

with SDL;
with SDL.Error;
with SDL.Properties;
with SDL.RWops;
with SDL.Video;
with SDL.Video.Displays;
with SDL.Video.Palettes;
with SDL.Video.Pixel_Formats;
with SDL.Video.Pixels;
with SDL.Video.Rectangles;
with SDL.Video.Surfaces;
with SDL.Video.Surfaces.Makers;
with SDL.Video.Windows;
with SDL.Video.Windows.Makers;

procedure Video_Foundation_Smoke is
   use type Interfaces.Unsigned_32;
   use type System.Address;
   use type SDL.Dimension;
   use type SDL.Properties.Property_ID;
   use type SDL.Sizes;
   use type SDL.Video.Blend_Modes;
   use type SDL.Video.Displays.Display_Indices;
   use type SDL.Video.Displays.Display_Orientations;
   use type SDL.Video.Palettes.Colour;
   use type SDL.Video.Palettes.Colour_Component;
   use type SDL.Video.Pixel_Formats.Pixel_Format_Names;
   use type SDL.Video.Rectangles.Rectangle;
   use type SDL.Video.Windows.ID;

   type Pixel_Access is access all SDL.Video.Pixels.ARGB_8888;
   pragma No_Strict_Aliasing (Pixel_Access);

   package Surface_Pixels is new SDL.Video.Surfaces.Pixel_Data
     (Element         => SDL.Video.Pixels.ARGB_8888,
      Element_Pointer => Pixel_Access);

   type Pixel_Matrix is
     array (Integer range <>, Integer range <>) of SDL.Video.Pixels.ARGB_8888;

   procedure Create_Surface_From_Array is new SDL.Video.Surfaces.Makers.Create_From_Array
     (Element       => SDL.Video.Pixels.ARGB_8888,
      Index         => Integer,
      Element_Array => Pixel_Matrix);

   procedure Require (Condition : in Boolean; Message : in String) is
   begin
      if not Condition then
         raise Program_Error with Message;
      end if;
   end Require;

   function Nearly_Equal
     (Left      : in Float;
      Right     : in Float;
      Tolerance : in Float := 0.05) return Boolean is
   begin
      return abs (Left - Right) <= Tolerance;
   end Nearly_Equal;

   procedure Delete_If_Exists (Path : in String) is
   begin
      if Ada.Directories.Exists (Path) then
         Ada.Directories.Delete_File (Path);
      end if;
   exception
      when Ada.Directories.Name_Error | Ada.Directories.Use_Error =>
         null;
   end Delete_If_Exists;

   procedure Require_Top_Left_Pixel
     (Image   : in out SDL.Video.Surfaces.Surface;
      Red     : in SDL.Video.Palettes.Colour_Component;
      Green   : in SDL.Video.Palettes.Colour_Component;
      Blue    : in SDL.Video.Palettes.Colour_Component;
      Message : in String)
   is
      Buffer : Pixel_Access;
   begin
      SDL.Video.Surfaces.Lock (Image);
      Buffer := Surface_Pixels.Get (Image);
      Require (Buffer /= null, Message & " pixel pointer is null");
      Require
        (Buffer.all.Red = Red
         and then Buffer.all.Green = Green
         and then Buffer.all.Blue = Blue,
         Message);
      SDL.Video.Surfaces.Unlock (Image);
   end Require_Top_Left_Pixel;

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

   Source      : SDL.Video.Surfaces.Surface;
   Target      : SDL.Video.Surfaces.Surface;
   Converted   : SDL.Video.Surfaces.Surface;
   Array_Based : SDL.Video.Surfaces.Surface;
   Window      : SDL.Video.Windows.Window;

   Window_Surface : SDL.Video.Surfaces.Surface;
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

   declare
      A            : constant SDL.Video.Rectangles.Rectangle :=
        (X => 0, Y => 0, Width => 4, Height => 4);
      B            : constant SDL.Video.Rectangles.Rectangle :=
        (X => 2, Y => 2, Width => 4, Height => 4);
      Intersection : SDL.Video.Rectangles.Rectangle;
      Unioned      : SDL.Video.Rectangles.Rectangle;
      Enclosed     : SDL.Video.Rectangles.Rectangle;
      Points       : SDL.Video.Rectangles.Point_Arrays (0 .. 1) :=
        ((X => 1, Y => 1),
         (X => 5, Y => 3));
   begin
      Require
        (SDL.Video.Rectangles.Has_Intersected (A, B),
         "Expected rectangle intersection");
      Require
        (SDL.Video.Rectangles.Intersects (A, B, Intersection),
         "Expected rectangle intersection details");
      Require
        (Intersection.Width = 2 and then Intersection.Height = 2,
         "Unexpected rectangle intersection size");

      Unioned := SDL.Video.Rectangles.Union (A, B);
      Require
        (Unioned.Width = 6 and then Unioned.Height = 6,
         "Unexpected rectangle union size");

      SDL.Video.Rectangles.Enclose (Points, Enclosed);
      Require
        (Enclosed.Width = 5 and then Enclosed.Height = 3,
         "Unexpected enclosing rectangle");
   end;

   declare
      Displays_Total : constant SDL.Video.Displays.Display_Indices :=
        SDL.Video.Displays.Total;
      Primary        : constant SDL.Video.Displays.Display_Indices :=
        SDL.Video.Displays.Primary;
      Bounds         : SDL.Video.Rectangles.Rectangle;
      Usable         : SDL.Video.Rectangles.Rectangle;
      Mode           : SDL.Video.Displays.Mode;
      Total_Modes    : Positive;
      Scale          : Float;
      DPI            : Float;
      Props          : constant SDL.Properties.Property_Set :=
        SDL.Properties.Reference (SDL.Video.Displays.Get_Properties (1));
      Natural_Orientation : constant SDL.Video.Displays.Display_Orientations :=
        SDL.Video.Displays.Get_Natural_Orientation (1);
      Current_Orientation : constant SDL.Video.Displays.Display_Orientations :=
        SDL.Video.Displays.Get_Orientation (1);
   begin
      Require (Displays_Total >= 1, "Expected at least one display");
      Require (Primary >= 1, "Expected a primary display");
      Require (SDL.Video.Displays.Display_Bounds (1, Bounds), "Missing display bounds");
      Require (SDL.Video.Displays.Get_Usable_Bounds (1, Usable), "Missing usable bounds");
      Require (SDL.Video.Displays.Current_Mode (1, Mode), "Missing current display mode");
      Require (SDL.Video.Displays.Desktop_Mode (1, Mode), "Missing desktop display mode");
      Require
        (SDL.Video.Displays.Get_Display_Index_From_Rectangle (Bounds) = 1,
         "Expected display bounds to resolve back to display 1");

      if SDL.Video.Displays.Total_Display_Modes (1, Total_Modes) then
         Require (Total_Modes >= 1, "Expected at least one display mode");
         Require
           (SDL.Video.Displays.Display_Mode (1, 0, Mode),
            "Missing first fullscreen display mode");
      else
         Require
           (not SDL.Video.Displays.Display_Mode (1, 0, Mode),
           "Expected display mode enumeration failure to be reported");
      end if;

      Require
        (SDL.Properties.Get_ID (Props) /= SDL.Properties.Null_Property_ID,
         "Expected display properties");

      Scale := SDL.Video.Displays.Get_Content_Scale (1);
      Require (Scale > 0.0, "Expected positive display content scale");

      DPI := SDL.Video.Displays.Get_Display_Horizontal_DPI (1);
      Require (DPI > 0.0, "Expected positive display DPI approximation");

      pragma Unreferenced (Natural_Orientation, Current_Orientation);
   end;

   declare
      Palette : SDL.Video.Palettes.Palette := SDL.Video.Palettes.Create (2);
      Colours : SDL.Video.Palettes.Colour_Arrays (0 .. 1) :=
        ((Red => 16#10#, Green => 16#20#, Blue => 16#30#, Alpha => 16#FF#),
         (Red => 16#AA#, Green => 16#BB#, Blue => 16#CC#, Alpha => 16#FF#));
      Count : Natural := 0;
   begin
      SDL.Video.Palettes.Set_Colours (Palette, Colours);

      for Item of Palette loop
         Count := Count + 1;

         case Count is
            when 1 =>
               Require (Item = Colours (0), "Unexpected first palette entry");
            when 2 =>
               Require (Item = Colours (1), "Unexpected second palette entry");
            when others =>
               raise Program_Error with "Unexpected extra palette entry";
         end case;
      end loop;

      Require (Count = 2, "Palette iteration length mismatch");

      SDL.Video.Palettes.Free (Palette);
   end;

   SDL.Video.Surfaces.Makers.Create
     (Self       => Source,
      Size       => (Width => 8, Height => 8),
      BPP        => SDL.Video.Surfaces.Pixel_Depths (Bits),
      Red_Mask   => SDL.Video.Surfaces.Colour_Masks (Red_Mask),
      Green_Mask => SDL.Video.Surfaces.Colour_Masks (Green_Mask),
      Blue_Mask  => SDL.Video.Surfaces.Colour_Masks (Blue_Mask),
      Alpha_Mask => SDL.Video.Surfaces.Colour_Masks (Alpha_Mask));

   SDL.Video.Surfaces.Makers.Create
     (Self       => Target,
      Size       => (Width => 8, Height => 8),
      BPP        => SDL.Video.Surfaces.Pixel_Depths (Bits),
      Red_Mask   => SDL.Video.Surfaces.Colour_Masks (Red_Mask),
      Green_Mask => SDL.Video.Surfaces.Colour_Masks (Green_Mask),
      Blue_Mask  => SDL.Video.Surfaces.Colour_Masks (Blue_Mask),
      Alpha_Mask => SDL.Video.Surfaces.Colour_Masks (Alpha_Mask));

   declare
      Pixel : constant Interfaces.Unsigned_32 :=
        To_Surface_Colour
          (Source,
           (Red => 16#FF#, Green => 16#40#, Blue => 16#20#, Alpha => 16#FF#));
      Areas : SDL.Video.Rectangles.Rectangle_Arrays (0 .. 1) :=
        ((X => 0, Y => 0, Width => 2, Height => 2),
         (X => 4, Y => 4, Width => 2, Height => 2));
      Buffer : Pixel_Access;
   begin
      SDL.Video.Surfaces.Fill
        (Self   => Source,
         Area   => (X => 0, Y => 0, Width => 8, Height => 8),
         Colour => Pixel);
      SDL.Video.Surfaces.Fill
        (Self   => Target,
         Areas  => Areas,
         Colour => Pixel);

      SDL.Video.Surfaces.Set_Clip_Rectangle
        (Target,
         (X => 0, Y => 0, Width => 8, Height => 8));
      Require
        (Target.Clip_Rectangle = (X => 0, Y => 0, Width => 8, Height => 8),
         "Unexpected clip rectangle");

      SDL.Video.Surfaces.Blit (Target, Source);
      SDL.Video.Surfaces.Lock (Target);
      Buffer := Surface_Pixels.Get (Target);
      Require (Buffer /= null, "Surface pixel pointer is null");
      Require (Buffer.all.Red = 16#FF#, "Unexpected blitted surface pixel");
      SDL.Video.Surfaces.Unlock (Target);

      SDL.Video.Surfaces.Set_Colour_Key
        (Source,
         (Red => 16#01#, Green => 16#02#, Blue => 16#03#, Alpha => 16#FF#));
      Require (Source.Colour_Key.Green = 16#02#, "Colour key round-trip failed");

      SDL.Video.Surfaces.Set_Alpha_Blend (Source, 16#80#);
      Require (Source.Alpha_Blend = 16#80#, "Alpha modulation round-trip failed");

      SDL.Video.Surfaces.Set_Blend_Mode (Source, SDL.Video.Alpha_Blend);
      Require (Source.Blend_Mode = SDL.Video.Alpha_Blend, "Blend mode round-trip failed");

      SDL.Video.Surfaces.Set_Colour
        (Source,
         (Red => 16#77#, Green => 16#55#, Blue => 16#33#));
      Require (Source.Colour.Red = 16#77#, "Colour modulation round-trip failed");
   end;

   declare
      procedure Create_ARGB_Surface
        (Image  : in out SDL.Video.Surfaces.Surface;
         Width  : in SDL.Dimension;
         Height : in SDL.Dimension) is
      begin
         SDL.Video.Surfaces.Makers.Create
           (Self       => Image,
            Size       => (Width => Width, Height => Height),
            BPP        => SDL.Video.Surfaces.Pixel_Depths (Bits),
            Red_Mask   => SDL.Video.Surfaces.Colour_Masks (Red_Mask),
            Green_Mask => SDL.Video.Surfaces.Colour_Masks (Green_Mask),
            Blue_Mask  => SDL.Video.Surfaces.Colour_Masks (Blue_Mask),
            Alpha_Mask => SDL.Video.Surfaces.Colour_Masks (Alpha_Mask));
      end Create_ARGB_Surface;

      procedure Create_Indexed_Surface
        (Image  : in out SDL.Video.Surfaces.Surface;
         Width  : in SDL.Dimension;
         Height : in SDL.Dimension) is
      begin
         SDL.Video.Surfaces.Makers.Create
           (Self       => Image,
            Size       => (Width => Width, Height => Height),
            BPP        => 8,
            Red_Mask   => 0,
            Green_Mask => 0,
            Blue_Mask  => 0,
            Alpha_Mask => 0);
      end Create_Indexed_Surface;

      function Has_Size
        (Images : in SDL.Video.Surfaces.Surface_Lists;
         Size   : in SDL.Sizes) return Boolean is
      begin
         for Image of Images loop
            if Image.Size = Size then
               return True;
            end if;
         end loop;

         return False;
      end Has_Size;

      Indexed_Source      : SDL.Video.Surfaces.Surface;
      Alternate_Image     : SDL.Video.Surfaces.Surface;
      Flip_Test           : SDL.Video.Surfaces.Surface;
      Duplicate_Copy      : SDL.Video.Surfaces.Surface;
      Rotated_Copy        : SDL.Video.Surfaces.Surface;
      Scaled_Copy         : SDL.Video.Surfaces.Surface;
      Converted_Copy      : SDL.Video.Surfaces.Surface;
      Raw_Copy            : SDL.Video.Surfaces.Surface;
      Raw_Copy_Colour     : SDL.Video.Surfaces.Surface;
      Alpha_Source        : SDL.Video.Surfaces.Surface;
      Alpha_Target        : SDL.Video.Surfaces.Surface;
      Stretched_Target    : SDL.Video.Surfaces.Surface;
      Tile_Source         : SDL.Video.Surfaces.Surface;
      Tile_Target         : SDL.Video.Surfaces.Surface;
      Tile_Scaled_Target  : SDL.Video.Surfaces.Surface;
      Grid_Source         : SDL.Video.Surfaces.Surface;
      Grid_Target         : SDL.Video.Surfaces.Surface;

      Palette : SDL.Video.Palettes.Palette := SDL.Video.Palettes.Create (2);
      Colours : SDL.Video.Palettes.Colour_Arrays (0 .. 1) :=
        ((Red => 16#22#, Green => 16#44#, Blue => 16#66#, Alpha => 16#FF#),
         (Red => 16#88#, Green => 16#AA#, Blue => 16#CC#, Alpha => 16#FF#));
      Indexed_Colour_Space : SDL.Video.Surfaces.Colour_Spaces;
      Pixel                : SDL.Video.Palettes.Colour;
      Float_Pixel          : SDL.Video.Surfaces.Float_Colour;
      Mapped_RGB           : Interfaces.Unsigned_32;
      Mapped_RGBA          : Interfaces.Unsigned_32;
   begin
      Create_Indexed_Surface (Indexed_Source, 2, 2);
      Create_Indexed_Surface (Alternate_Image, 4, 4);

      SDL.Video.Surfaces.Create_Palette (Indexed_Source);
      declare
         Palette_View : SDL.Video.Palettes.Palette :=
           SDL.Video.Surfaces.Get_Palette (Indexed_Source);
      begin
         Require
           (SDL.Video.Palettes.Get_Internal (Palette_View) /= System.Null_Address,
            "Expected created surface palette");
         SDL.Video.Palettes.Free (Palette_View);
      end;

      SDL.Video.Palettes.Set_Colours (Palette, Colours);
      SDL.Video.Surfaces.Set_Palette (Indexed_Source, Palette);
      declare
         Palette_View : SDL.Video.Palettes.Palette :=
           SDL.Video.Surfaces.Get_Palette (Indexed_Source);
         Count        : Natural := 0;
      begin
         for Item of Palette_View loop
            Count := Count + 1;
            exit when Count > 2;

            case Count is
               when 1 =>
                  Require (Item = Colours (0), "Unexpected first surface palette colour");
               when 2 =>
                  Require (Item = Colours (1), "Unexpected second surface palette colour");
               when others =>
                  null;
            end case;
         end loop;

         SDL.Video.Palettes.Free (Palette_View);
      end;

      Indexed_Colour_Space := Indexed_Source.Get_Colour_Space;
      SDL.Video.Surfaces.Set_Colour_Space (Indexed_Source, Indexed_Colour_Space);
      Require
        (Indexed_Source.Get_Colour_Space = Indexed_Colour_Space,
         "Surface colourspace round-trip failed");

      SDL.Video.Surfaces.Add_Alternate_Image (Indexed_Source, Alternate_Image);
      Require
        (SDL.Video.Surfaces.Has_Alternate_Images (Indexed_Source),
         "Expected alternate images to be present");
      declare
         Images : constant SDL.Video.Surfaces.Surface_Lists :=
           SDL.Video.Surfaces.Get_Images (Indexed_Source);
      begin
         Require (Images'Length >= 2, "Expected alternate image enumeration");
         Require
           (Has_Size (Images, (Width => 2, Height => 2)),
            "Expected primary image in alternate image enumeration");
         Require
           (Has_Size (Images, (Width => 4, Height => 4)),
            "Expected alternate image in alternate image enumeration");
      end;
      SDL.Video.Surfaces.Remove_Alternate_Images (Indexed_Source);
      Require
        (not SDL.Video.Surfaces.Has_Alternate_Images (Indexed_Source),
         "Expected alternate images to be removed");

      Mapped_RGB :=
        SDL.Video.Surfaces.Map_Colour
          (Source,
           SDL.Video.Palettes.RGB_Colour'
             (Red => 16#11#, Green => 16#22#, Blue => 16#33#));
      Mapped_RGBA :=
        SDL.Video.Surfaces.Map_Colour
          (Source,
           SDL.Video.Palettes.Colour'
             (Red => 16#44#, Green => 16#55#, Blue => 16#66#, Alpha => 16#80#));

      SDL.Video.Surfaces.Fill (Target, Mapped_RGB);
      Pixel := SDL.Video.Surfaces.Read_Pixel (Target, 0, 0);
      Require
        (Pixel.Red = 16#11# and then Pixel.Green = 16#22# and then Pixel.Blue = 16#33#,
         "Surface RGB mapping round-trip failed");

      SDL.Video.Surfaces.Fill (Target, Mapped_RGBA);
      Pixel := SDL.Video.Surfaces.Read_Pixel (Target, 0, 0);
      Require
        (Pixel.Red = 16#44# and then Pixel.Green = 16#55# and then Pixel.Blue = 16#66#,
         "Surface RGBA mapping round-trip failed");

      SDL.Video.Surfaces.Write_Pixel
        (Target,
         1,
         1,
         (Red => 16#21#, Green => 16#43#, Blue => 16#65#, Alpha => 16#87#));
      Pixel := SDL.Video.Surfaces.Read_Pixel (Target, 1, 1);
      Require
        (Pixel = (Red => 16#21#, Green => 16#43#, Blue => 16#65#, Alpha => 16#87#),
         "Surface pixel write/read round-trip failed");

      SDL.Video.Surfaces.Clear
        (Target,
         (Red => 0.25, Green => 0.5, Blue => 0.75, Alpha => 1.0));
      Float_Pixel := SDL.Video.Surfaces.Read_Pixel_Float (Target, 0, 0);
      Require
        (Nearly_Equal (Float (Float_Pixel.Red), 0.25)
         and then Nearly_Equal (Float (Float_Pixel.Green), 0.5)
         and then Nearly_Equal (Float (Float_Pixel.Blue), 0.75)
         and then Nearly_Equal (Float (Float_Pixel.Alpha), 1.0),
         "Surface float clear/read round-trip failed");

      SDL.Video.Surfaces.Write_Pixel_Float
        (Target,
         2,
         2,
         (Red => 0.5, Green => 0.125, Blue => 0.25, Alpha => 1.0));
      Float_Pixel := SDL.Video.Surfaces.Read_Pixel_Float (Target, 2, 2);
      Require
        (Nearly_Equal (Float (Float_Pixel.Red), 0.5)
         and then Nearly_Equal (Float (Float_Pixel.Green), 0.125)
         and then Nearly_Equal (Float (Float_Pixel.Blue), 0.25)
         and then Nearly_Equal (Float (Float_Pixel.Alpha), 1.0),
         "Surface float pixel write/read round-trip failed");

      SDL.Video.Surfaces.Set_RLE (Source, True);
      Require (SDL.Video.Surfaces.Has_RLE (Source), "Expected RLE-enabled surface");
      SDL.Video.Surfaces.Set_RLE (Source, False);

      Create_ARGB_Surface (Flip_Test, 2, 1);
      SDL.Video.Surfaces.Write_Pixel
        (Flip_Test,
         0,
         0,
         (Red => 16#F0#, Green => 0, Blue => 0, Alpha => 16#FF#));
      SDL.Video.Surfaces.Write_Pixel
        (Flip_Test,
         1,
         0,
         (Red => 0, Green => 0, Blue => 16#F0#, Alpha => 16#FF#));
      SDL.Video.Surfaces.Flip (Flip_Test, SDL.Video.Surfaces.Horizontal_Flip);
      Require
        (SDL.Video.Surfaces.Read_Pixel (Flip_Test, 0, 0).Blue = 16#F0#
         and then SDL.Video.Surfaces.Read_Pixel (Flip_Test, 1, 0).Red = 16#F0#,
         "Surface flip failed");

      Duplicate_Copy := SDL.Video.Surfaces.Duplicate (Source);
      Require (Duplicate_Copy.Size = Source.Size, "Surface duplicate size mismatch");
      Require
        (SDL.Video.Surfaces.Read_Pixel (Duplicate_Copy, 0, 0).Red = 16#FF#,
         "Surface duplicate pixel mismatch");

      Rotated_Copy := SDL.Video.Surfaces.Rotate (Flip_Test, 90.0);
      Require
        (Rotated_Copy.Size = (Width => 1, Height => 2),
         "Surface rotate size mismatch");

      Scaled_Copy :=
        SDL.Video.Surfaces.Scale
          (Flip_Test,
           (Width => 4, Height => 2),
           SDL.Video.Surfaces.Nearest);
      Require
        (Scaled_Copy.Size = (Width => 4, Height => 2),
         "Surface scale size mismatch");

      Converted_Copy :=
        SDL.Video.Surfaces.Convert
          (Source,
           Source.Pixel_Format,
           Colour_Space => Source.Get_Colour_Space);
      Require
        (Converted_Copy.Size = Source.Size,
         "Surface colorspace conversion size mismatch");
      Require
        (SDL.Video.Surfaces.Read_Pixel (Converted_Copy, 0, 0).Red = 16#FF#,
         "Surface colorspace conversion pixel mismatch");

      Create_ARGB_Surface (Raw_Copy, 8, 8);
      SDL.Video.Surfaces.Lock (Source);
      SDL.Video.Surfaces.Lock (Raw_Copy);
      SDL.Video.Surfaces.Convert_Pixels
        (Size               => Source.Size,
         Source_Format      => Source.Pixel_Format.Format,
         Source             => Source.Pixels,
         Source_Pitch       => Source.Pitch,
         Destination_Format => Raw_Copy.Pixel_Format.Format,
         Destination        => Raw_Copy.Pixels,
         Destination_Pitch  => Raw_Copy.Pitch);
      SDL.Video.Surfaces.Unlock (Raw_Copy);
      SDL.Video.Surfaces.Unlock (Source);
      Require
        (SDL.Video.Surfaces.Read_Pixel (Raw_Copy, 0, 0).Red = 16#FF#,
         "Surface raw pixel conversion mismatch");

      Create_ARGB_Surface (Raw_Copy_Colour, 8, 8);
      SDL.Video.Surfaces.Lock (Source);
      SDL.Video.Surfaces.Lock (Raw_Copy_Colour);
      SDL.Video.Surfaces.Convert_Pixels
        (Size                     => Source.Size,
         Source_Format            => Source.Pixel_Format.Format,
         Source_Colour_Space      => Source.Get_Colour_Space,
         Source                   => Source.Pixels,
         Source_Pitch             => Source.Pitch,
         Destination_Format       => Raw_Copy_Colour.Pixel_Format.Format,
         Destination_Colour_Space => Raw_Copy_Colour.Get_Colour_Space,
         Destination              => Raw_Copy_Colour.Pixels,
         Destination_Pitch        => Raw_Copy_Colour.Pitch);
      SDL.Video.Surfaces.Unlock (Raw_Copy_Colour);
      SDL.Video.Surfaces.Unlock (Source);
      Require
        (SDL.Video.Surfaces.Read_Pixel (Raw_Copy_Colour, 0, 0).Red = 16#FF#,
         "Surface colorspace pixel conversion mismatch");

      Create_ARGB_Surface (Alpha_Source, 1, 1);
      Create_ARGB_Surface (Alpha_Target, 1, 1);
      SDL.Video.Surfaces.Write_Pixel
        (Alpha_Source,
         0,
         0,
         (Red => 16#80#, Green => 16#40#, Blue => 16#20#, Alpha => 16#80#));
      SDL.Video.Surfaces.Lock (Alpha_Source);
      SDL.Video.Surfaces.Lock (Alpha_Target);
      SDL.Video.Surfaces.Premultiply_Alpha
        (Size               => Alpha_Source.Size,
         Source_Format      => Alpha_Source.Pixel_Format.Format,
         Source             => Alpha_Source.Pixels,
         Source_Pitch       => Alpha_Source.Pitch,
         Destination_Format => Alpha_Target.Pixel_Format.Format,
         Destination        => Alpha_Target.Pixels,
         Destination_Pitch  => Alpha_Target.Pitch,
         Linear             => False);
      SDL.Video.Surfaces.Unlock (Alpha_Target);
      SDL.Video.Surfaces.Unlock (Alpha_Source);
      Pixel := SDL.Video.Surfaces.Read_Pixel (Alpha_Target, 0, 0);
      Require
        (Pixel.Red < 16#80# and then Pixel.Green < 16#40# and then Pixel.Blue < 16#20#,
         "Surface raw premultiply alpha did not reduce colour channels");

      SDL.Video.Surfaces.Premultiply_Alpha (Alpha_Source, Linear => False);
      Pixel := SDL.Video.Surfaces.Read_Pixel (Alpha_Source, 0, 0);
      Require
        (Pixel.Red < 16#80# and then Pixel.Green < 16#40# and then Pixel.Blue < 16#20#,
         "Surface premultiply alpha did not reduce colour channels");

      Create_ARGB_Surface (Stretched_Target, 4, 4);
      SDL.Video.Surfaces.Stretch
        (Stretched_Target, Flip_Test, SDL.Video.Surfaces.Nearest);
      Require
        (SDL.Video.Surfaces.Read_Pixel (Stretched_Target, 0, 0).Blue = 16#F0#,
         "Surface stretch failed");

      Create_ARGB_Surface (Tile_Source, 1, 1);
      SDL.Video.Surfaces.Write_Pixel
        (Tile_Source,
         0,
         0,
         (Red => 0, Green => 16#90#, Blue => 0, Alpha => 16#FF#));
      Create_ARGB_Surface (Tile_Target, 3, 3);
      SDL.Video.Surfaces.Blit_Tiled (Tile_Target, Tile_Source);
      Require
        (SDL.Video.Surfaces.Read_Pixel (Tile_Target, 2, 2).Green = 16#90#,
         "Surface tiled blit failed");

      Create_ARGB_Surface (Tile_Scaled_Target, 4, 4);
      SDL.Video.Surfaces.Blit_Tiled_With_Scale
        (Tile_Scaled_Target,
         Tile_Source,
         2.0,
         SDL.Video.Surfaces.Nearest);
      Require
        (SDL.Video.Surfaces.Read_Pixel (Tile_Scaled_Target, 3, 3).Green = 16#90#,
         "Surface tiled scaled blit failed");

      Create_ARGB_Surface (Grid_Source, 3, 3);
      SDL.Video.Surfaces.Fill
        (Grid_Source,
         SDL.Video.Surfaces.Map_Colour
           (Grid_Source,
            SDL.Video.Palettes.RGB_Colour'
              (Red => 16#55#, Green => 16#11#, Blue => 16#22#)));
      Create_ARGB_Surface (Grid_Target, 6, 6);
      SDL.Video.Surfaces.Blit_9_Grid
        (Grid_Target,
         Grid_Source,
         Left_Width    => 1,
         Right_Width   => 1,
         Top_Height    => 1,
         Bottom_Height => 1,
         Scale         => 0.0,
         Mode          => SDL.Video.Surfaces.Linear);
      Require
        (SDL.Video.Surfaces.Read_Pixel (Grid_Target, 0, 0).Red = 16#55#,
         "Surface 9-grid blit failed");

      SDL.Video.Palettes.Free (Palette);
   end;

   declare
      Bmp_Path    : constant String := "/tmp/sdl3ada-surface-smoke.bmp";
      Png_Path    : constant String := "/tmp/sdl3ada-surface-smoke.png";
      Bmp_IO_Path : constant String := "/tmp/sdl3ada-surface-smoke-io.bmp";
      Png_IO_Path : constant String := "/tmp/sdl3ada-surface-smoke-io.png";

      procedure Cleanup_Files is
      begin
         Delete_If_Exists (Bmp_Path);
         Delete_If_Exists (Png_Path);
         Delete_If_Exists (Bmp_IO_Path);
         Delete_If_Exists (Png_IO_Path);
      end Cleanup_Files;

      procedure Verify_Loaded_Surface
        (Image   : in SDL.Video.Surfaces.Surface;
         Message : in String) is
         Normalized : SDL.Video.Surfaces.Surface;
      begin
         Require (Image.Size = (Width => 8, Height => 8), Message & " size mismatch");
         SDL.Video.Surfaces.Makers.Convert
           (Self         => Normalized,
            Src          => Image,
            Pixel_Format =>
              SDL.Video.Pixel_Formats.Get_Details
                (SDL.Video.Pixel_Formats.Pixel_Format_ARGB_8888));
         Require_Top_Left_Pixel
           (Image   => Normalized,
            Red     => 16#FF#,
            Green   => 16#40#,
            Blue    => 16#20#,
            Message => Message & " pixel mismatch");
      end Verify_Loaded_Surface;
   begin
      Cleanup_Files;

      SDL.Video.Surfaces.Save_BMP (Source, Bmp_Path);
      SDL.Video.Surfaces.Save_PNG (Source, Png_Path);
      SDL.Video.Surfaces.Save_BMP
        (Self        => Source,
         Destination =>
           SDL.RWops.From_File (Bmp_IO_Path, SDL.RWops.Create_To_Write_Binary),
         Close_After => True);
      SDL.Video.Surfaces.Save_PNG
        (Self        => Source,
         Destination =>
           SDL.RWops.From_File (Png_IO_Path, SDL.RWops.Create_To_Write_Binary),
         Close_After => True);

      Require (Ada.Directories.Exists (Bmp_Path), "BMP save did not create a file");
      Require (Ada.Directories.Exists (Png_Path), "PNG save did not create a file");
      Require (Ada.Directories.Exists (Bmp_IO_Path), "BMP IO save did not create a file");
      Require (Ada.Directories.Exists (Png_IO_Path), "PNG IO save did not create a file");

      declare
         Loaded : SDL.Video.Surfaces.Surface;
      begin
         SDL.Video.Surfaces.Makers.Create (Loaded, Png_Path);
         Verify_Loaded_Surface (Loaded, "Generic file load");
         SDL.Video.Surfaces.Finalize (Loaded);

         SDL.Video.Surfaces.Makers.Create
           (Self        => Loaded,
            Source      => SDL.RWops.From_File (Png_Path, SDL.RWops.Read_Binary),
            Close_After => True);
         Verify_Loaded_Surface (Loaded, "Generic IO load");
         SDL.Video.Surfaces.Finalize (Loaded);

         SDL.Video.Surfaces.Makers.Load_BMP (Loaded, Bmp_Path);
         Verify_Loaded_Surface (Loaded, "BMP file load");
         SDL.Video.Surfaces.Finalize (Loaded);

         SDL.Video.Surfaces.Makers.Load_BMP
           (Self        => Loaded,
            Source      => SDL.RWops.From_File (Bmp_Path, SDL.RWops.Read_Binary),
            Close_After => True);
         Verify_Loaded_Surface (Loaded, "BMP IO load");
         SDL.Video.Surfaces.Finalize (Loaded);

         SDL.Video.Surfaces.Makers.Load_PNG (Loaded, Png_Path);
         Verify_Loaded_Surface (Loaded, "PNG file load");
         SDL.Video.Surfaces.Finalize (Loaded);

         SDL.Video.Surfaces.Makers.Load_PNG
           (Self        => Loaded,
            Source      => SDL.RWops.From_File (Png_Path, SDL.RWops.Read_Binary),
            Close_After => True);
         Verify_Loaded_Surface (Loaded, "PNG IO load");
         SDL.Video.Surfaces.Finalize (Loaded);
      end;

      Cleanup_Files;
   exception
      when others =>
         Cleanup_Files;
         raise;
   end;

   declare
      Pixels : aliased Pixel_Matrix :=
        (( (Alpha => 16#FF#, Red => 16#11#, Green => 16#22#, Blue => 16#33#),
           (Alpha => 16#FF#, Red => 16#44#, Green => 16#55#, Blue => 16#66#)),
         ( (Alpha => 16#FF#, Red => 16#77#, Green => 16#88#, Blue => 16#99#),
           (Alpha => 16#FF#, Red => 16#AA#, Green => 16#BB#, Blue => 16#CC#)));
   begin
      Create_Surface_From_Array
        (Self       => Array_Based,
         Pixels     => Pixels'Access,
         Red_Mask   => SDL.Video.Surfaces.Colour_Masks (Red_Mask),
         Green_Mask => SDL.Video.Surfaces.Colour_Masks (Green_Mask),
         Blue_Mask  => SDL.Video.Surfaces.Colour_Masks (Blue_Mask),
         Alpha_Mask => SDL.Video.Surfaces.Colour_Masks (Alpha_Mask));

      Require (Array_Based.Size = (Width => 2, Height => 2), "Array surface size mismatch");
   end;

   SDL.Video.Surfaces.Makers.Convert
     (Self         => Converted,
      Src          => Source,
      Pixel_Format =>
        SDL.Video.Pixel_Formats.Get_Details
          (SDL.Video.Pixel_Formats.Pixel_Format_BGRA_8888));
   Require
     (Converted.Pixel_Format.Format = SDL.Video.Pixel_Formats.Pixel_Format_BGRA_8888,
      "Converted surface format mismatch");

   SDL.Video.Windows.Makers.Create
     (Win    => Window,
      Title  => "video foundation smoke",
      X      => 0,
      Y      => 0,
      Width  => 8,
      Height => 8,
      Flags  => SDL.Video.Windows.Hidden);

   begin
      Require (Window.Get_ID /= 0, "Expected a valid window ID");
      Window.Set_Icon (Source);
      Window_Surface := Window.Get_Surface;
      SDL.Video.Surfaces.Blit (Window_Surface, Source);
      Window.Update_Surface;
      Window.Update_Surface_Rectangle ((X => 0, Y => 0, Width => 4, Height => 4));

      declare
         Regions : SDL.Video.Rectangles.Rectangle_Arrays (0 .. 1) :=
           ((X => 0, Y => 0, Width => 2, Height => 2),
            (X => 2, Y => 2, Width => 2, Height => 2));
      begin
         Window.Update_Surface_Rectangles (Regions);
      end;

      SDL.Video.Surfaces.Finalize (Window_Surface);
   exception
      when SDL.Video.Windows.Window_Error =>
         SDL.Video.Surfaces.Finalize (Window_Surface);

         declare
            Message : constant String := SDL.Error.Get;
         begin
            if Message /= "" then
               Put_Line ("Window surface probe skipped: " & Message);
               SDL.Error.Clear;
            end if;
         end;
   end;

   SDL.Video.Windows.Finalize (Window);
   SDL.Video.Surfaces.Finalize (Array_Based);
   SDL.Video.Surfaces.Finalize (Converted);
   SDL.Video.Surfaces.Finalize (Target);
   SDL.Video.Surfaces.Finalize (Source);
   SDL.Quit;
   Put_Line ("Video foundation smoke completed successfully.");
exception
   when Error : others =>
      SDL.Video.Surfaces.Finalize (Window_Surface);
      SDL.Video.Windows.Finalize (Window);
      SDL.Video.Surfaces.Finalize (Array_Based);
      SDL.Video.Surfaces.Finalize (Converted);
      SDL.Video.Surfaces.Finalize (Target);
      SDL.Video.Surfaces.Finalize (Source);
      SDL.Quit;
      Put_Line
        ("Video foundation smoke failed: "
         & Ada.Exceptions.Exception_Message (Error));

      declare
         Message : constant String := SDL.Error.Get;
      begin
         if Message /= "" then
            Put_Line ("SDL error: " & Message);
         end if;
      end;

      raise;
end Video_Foundation_Smoke;
