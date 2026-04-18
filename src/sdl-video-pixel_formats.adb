with Ada.Unchecked_Conversion;

with Interfaces.C.Strings;
with System;

with SDL.Error;
with SDL.Raw.Pixels;

package body SDL.Video.Pixel_Formats is
   package CS renames Interfaces.C.Strings;
   package Raw renames SDL.Raw.Pixels;

   function To_Raw_Pixel_Format_Access is new Ada.Unchecked_Conversion
     (Source => Pixel_Format_Access,
      Target => Raw.Pixel_Format_Details_Access);

   function To_Public_Pixel_Format_Access is new Ada.Unchecked_Conversion
     (Source => Raw.Pixel_Format_Details_Access,
      Target => Pixel_Format_Access);

   function Get_Details
     (Format : in Pixel_Format_Names) return Pixel_Format_Access is
   begin
      return To_Public_Pixel_Format_Access
        (Raw.Get_Pixel_Format_Details (Raw.Pixel_Format_Name (Format)));
   end Get_Details;

   function Image (Format : in Pixel_Format_Names) return String is
      Name : constant CS.chars_ptr :=
        Raw.Get_Pixel_Format_Name (Raw.Pixel_Format_Name (Format));

      use type CS.chars_ptr;
   begin
      if Name = CS.Null_Ptr then
         return "";
      end if;

      return CS.Value (Name);
   end Image;

   procedure To_Components
     (Pixel  : in  Unsigned_32;
      Format : in  Pixel_Format_Access;
      Red    : out SDL.Video.Palettes.Colour_Component;
      Green  : out SDL.Video.Palettes.Colour_Component;
      Blue   : out SDL.Video.Palettes.Colour_Component) is
   begin
      if Format = null then
         raise SDL.Video.Video_Error with SDL.Error.Get;
      end if;

      Raw.Get_RGB
        (Pixel   => Raw.U32 (Pixel),
         Format  => To_Raw_Pixel_Format_Access (Format),
         Palette => System.Null_Address,
         Red     => Red,
         Green   => Green,
         Blue    => Blue);
   end To_Components;

   procedure To_Components
     (Pixel  : in  Unsigned_32;
      Format : in  Pixel_Format_Access;
      Red    : out SDL.Video.Palettes.Colour_Component;
      Green  : out SDL.Video.Palettes.Colour_Component;
      Blue   : out SDL.Video.Palettes.Colour_Component;
      Alpha  : out SDL.Video.Palettes.Colour_Component) is
   begin
      if Format = null then
         raise SDL.Video.Video_Error with SDL.Error.Get;
      end if;

      Raw.Get_RGBA
        (Pixel   => Raw.U32 (Pixel),
         Format  => To_Raw_Pixel_Format_Access (Format),
         Palette => System.Null_Address,
         Red     => Red,
         Green   => Green,
         Blue    => Blue,
         Alpha   => Alpha);
   end To_Components;

   function To_Pixel
     (Format : in Pixel_Format_Access;
      Red    : in SDL.Video.Palettes.Colour_Component;
      Green  : in SDL.Video.Palettes.Colour_Component;
      Blue   : in SDL.Video.Palettes.Colour_Component) return Unsigned_32 is
   begin
      if Format = null then
         raise SDL.Video.Video_Error with SDL.Error.Get;
      end if;

      return Unsigned_32
        (Raw.Map_RGB
           (Format  => To_Raw_Pixel_Format_Access (Format),
            Palette => System.Null_Address,
            Red     => Red,
            Green   => Green,
            Blue    => Blue));
   end To_Pixel;

   function To_Pixel
     (Format : in Pixel_Format_Access;
      Red    : in SDL.Video.Palettes.Colour_Component;
      Green  : in SDL.Video.Palettes.Colour_Component;
      Blue   : in SDL.Video.Palettes.Colour_Component;
      Alpha  : in SDL.Video.Palettes.Colour_Component) return Unsigned_32 is
   begin
      if Format = null then
         raise SDL.Video.Video_Error with SDL.Error.Get;
      end if;

      return Unsigned_32
        (Raw.Map_RGBA
           (Format  => To_Raw_Pixel_Format_Access (Format),
            Palette => System.Null_Address,
            Red     => Red,
            Green   => Green,
            Blue    => Blue,
            Alpha   => Alpha));
   end To_Pixel;

   function To_Colour
     (Pixel  : in Unsigned_32;
      Format : in Pixel_Format_Access) return SDL.Video.Palettes.Colour is
      Colour : SDL.Video.Palettes.Colour;
   begin
      To_Components
        (Pixel  => Pixel,
         Format => Format,
         Red    => Colour.Red,
         Green  => Colour.Green,
         Blue   => Colour.Blue,
         Alpha  => Colour.Alpha);

      return Colour;
   end To_Colour;

   function To_Pixel
     (Colour : in SDL.Video.Palettes.Colour;
      Format : in Pixel_Format_Access) return Unsigned_32 is
   begin
      return To_Pixel
        (Format => Format,
         Red    => Colour.Red,
         Green  => Colour.Green,
         Blue   => Colour.Blue,
         Alpha  => Colour.Alpha);
   end To_Pixel;

   function To_Name
     (Bits       : in Bits_Per_Pixels;
      Red_Mask   : in Colour_Mask;
      Green_Mask : in Colour_Mask;
      Blue_Mask  : in Colour_Mask;
      Alpha_Mask : in Colour_Mask) return Pixel_Format_Names is
   begin
      return Pixel_Format_Names
        (Raw.Get_Pixel_Format_For_Masks
           (Bits       => C.int (Bits),
            Red_Mask   => Raw.Colour_Mask (Red_Mask),
            Green_Mask => Raw.Colour_Mask (Green_Mask),
            Blue_Mask  => Raw.Colour_Mask (Blue_Mask),
            Alpha_Mask => Raw.Colour_Mask (Alpha_Mask)));
   end To_Name;

   function To_Masks
     (Format     : in  Pixel_Format_Names;
      Bits       : out Bits_Per_Pixels;
      Red_Mask   : out Colour_Mask;
      Green_Mask : out Colour_Mask;
      Blue_Mask  : out Colour_Mask;
      Alpha_Mask : out Colour_Mask) return Boolean
   is
      Raw_Bits : C.int := 0;
      Success  : constant Boolean :=
        Boolean
          (Raw.Get_Masks_For_Pixel_Format
             (Raw.Pixel_Format_Name (Format),
              Raw_Bits,
              Red_Mask,
              Green_Mask,
              Blue_Mask,
              Alpha_Mask));
   begin
      if Success then
         Bits := Bits_Per_Pixels (Raw_Bits);
      else
         Bits := 0;
      end if;

      return Success;
   end To_Masks;
end SDL.Video.Pixel_Formats;
