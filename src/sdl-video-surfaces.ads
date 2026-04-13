with Ada.Finalization;
with Ada.Strings.UTF_Encoding;
with Interfaces;
with Interfaces.C;
with System;

with SDL.Raw.Properties;
with SDL.RWops;
with SDL.Video.Palettes;
with SDL.Video.Pixel_Formats;
with SDL.Video.Rectangles;

package SDL.Video.Surfaces is
   pragma Preelaborate;
   pragma Elaborate_Body;

   package C renames Interfaces.C;
   package UTF_Strings renames Ada.Strings.UTF_Encoding;

   Surface_Error : exception;

   type Pixel_Depths is new Positive with
     Convention       => C,
     Static_Predicate => Pixel_Depths in 1 | 2 | 4 | 8 | 12 | 15 | 16 | 24 | 32;

   type Colour_Masks is mod 2 ** 32 with
     Convention => C;

   type Scale_Modes is (Invalid, Nearest, Linear, Pixel_Art) with
     Convention => C,
     Size       => C.int'Size;

   for Scale_Modes use
     (Invalid   => -1,
      Nearest   => 0,
      Linear    => 1,
      Pixel_Art => 2);

   type Flip_Modes is
     (No_Flip,
      Horizontal_Flip,
      Vertical_Flip,
      Horizontal_And_Vertical_Flip)
   with
     Convention => C,
     Size       => C.int'Size;

   for Flip_Modes use
     (No_Flip                     => 0,
      Horizontal_Flip             => 1,
      Vertical_Flip               => 2,
      Horizontal_And_Vertical_Flip => 3);

   type Float_Colour is
      record
         Red   : C.C_float := 0.0;
         Green : C.C_float := 0.0;
         Blue  : C.C_float := 0.0;
         Alpha : C.C_float := 0.0;
      end record
   with Convention => C;

   type Internal_Surface is private;
   type Internal_Surface_Pointer is access all Internal_Surface with
     Convention => C;

   type Surface is new Ada.Finalization.Controlled with private;

   Null_Surface : constant Surface;

   type Surface_Lists is array (Natural range <>) of Surface;

   subtype Colour_Spaces is Interfaces.Unsigned_32;

   Unknown_Colour_Space : constant Colour_Spaces := 0;

   function Pixel_Format
     (Self : in Surface) return SDL.Video.Pixel_Formats.Pixel_Format_Access
   with
     Inline => True;

   function Size (Self : in Surface) return SDL.Sizes with
     Inline => True;

   function Pitch (Self : in Surface) return C.int with
     Inline => True;

   function Pixels (Self : in Surface) return System.Address with
     Inline => True;

   function Get_Properties
     (Self : in Surface) return SDL.Raw.Properties.ID;

   function Get_Colour_Space (Self : in Surface) return Colour_Spaces;

   procedure Set_Colour_Space
     (Self : in out Surface;
      Now  : in Colour_Spaces);

   function Get_Palette
     (Self : in Surface) return SDL.Video.Palettes.Palette;

   procedure Create_Palette (Self : in out Surface);

   procedure Set_Palette
     (Self    : in out Surface;
      Colours : in SDL.Video.Palettes.Palette);

   procedure Add_Alternate_Image
     (Self  : in out Surface;
      Image : in Surface);

   function Has_Alternate_Images (Self : in Surface) return Boolean;

   function Get_Images (Self : in Surface) return Surface_Lists;

   procedure Remove_Alternate_Images (Self : in out Surface);

   generic
      type Element is private;
      type Element_Pointer is access all Element;
   package Pixel_Data is
      function Get (Self : in Surface) return Element_Pointer with
        Inline => True;

      function Get_Row
        (Self : in Surface;
         Y    : in SDL.Coordinate) return Element_Pointer
      with
        Inline => True,
        Pre    => Y in 0 .. Self.Size.Height - 1;
   end Pixel_Data;

   generic
      type Data is private;
      type Data_Pointer is access all Data;
   package User_Data is
      function Get (Self : in Surface) return Data_Pointer;

      procedure Set (Self : in out Surface; Data : in Data_Pointer);
   end User_Data;

   function Duplicate (Self : in Surface) return Surface;

   function Rotate
     (Self  : in Surface;
      Angle : in Float) return Surface;

   function Scale
     (Self : in Surface;
      Size : in SDL.Sizes;
      Mode : in Scale_Modes := Linear) return Surface;

   function Convert
     (Self         : in Surface;
      Pixel_Format : in SDL.Video.Pixel_Formats.Pixel_Format_Access;
      Palette      : in SDL.Video.Palettes.Palette :=
        SDL.Video.Palettes.Empty_Palette;
      Colour_Space : in Colour_Spaces := Unknown_Colour_Space;
      Properties   : in SDL.Raw.Properties.ID := SDL.Raw.Properties.No_Properties)
      return Surface;

   procedure Convert_Pixels
     (Size               : in SDL.Sizes;
      Source_Format      : in SDL.Video.Pixel_Formats.Pixel_Format_Names;
      Source             : in System.Address;
      Source_Pitch       : in C.int;
      Destination_Format : in SDL.Video.Pixel_Formats.Pixel_Format_Names;
      Destination        : in System.Address;
      Destination_Pitch  : in C.int);

   procedure Convert_Pixels
     (Size                    : in SDL.Sizes;
      Source_Format           : in SDL.Video.Pixel_Formats.Pixel_Format_Names;
      Source_Colour_Space     : in Colour_Spaces;
      Source_Properties       : in SDL.Raw.Properties.ID :=
        SDL.Raw.Properties.No_Properties;
      Source                  : in System.Address;
      Source_Pitch            : in C.int;
      Destination_Format      : in SDL.Video.Pixel_Formats.Pixel_Format_Names;
      Destination_Colour_Space : in Colour_Spaces;
      Destination_Properties  : in SDL.Raw.Properties.ID :=
        SDL.Raw.Properties.No_Properties;
      Destination             : in System.Address;
      Destination_Pitch       : in C.int);

   procedure Premultiply_Alpha
     (Size               : in SDL.Sizes;
      Source_Format      : in SDL.Video.Pixel_Formats.Pixel_Format_Names;
      Source             : in System.Address;
      Source_Pitch       : in C.int;
      Destination_Format : in SDL.Video.Pixel_Formats.Pixel_Format_Names;
      Destination        : in System.Address;
      Destination_Pitch  : in C.int;
      Linear             : in Boolean := False);

   procedure Premultiply_Alpha
     (Self   : in out Surface;
      Linear : in Boolean := False);

   procedure Clear
     (Self   : in out Surface;
      Colour : in Float_Colour);

   procedure Blit
     (Self   : in out Surface;
      Source : in Surface);

   procedure Blit
     (Self        : in out Surface;
      Self_Area   : in out Rectangles.Rectangle;
      Source      : in Surface;
      Source_Area : in out Rectangles.Rectangle);

   procedure Blit_Scaled
     (Self   : in out Surface;
      Source : in Surface);

   procedure Blit_Scaled
     (Self        : in out Surface;
      Self_Area   : in out Rectangles.Rectangle;
      Source      : in Surface;
      Source_Area : in Rectangles.Rectangle := Rectangles.Null_Rectangle);

   procedure Lower_Blit
     (Self        : in out Surface;
      Self_Area   : in Rectangles.Rectangle;
      Source      : in Surface;
      Source_Area : in Rectangles.Rectangle);

   procedure Lower_Blit_Scaled
     (Self        : in out Surface;
      Self_Area   : in Rectangles.Rectangle;
      Source      : in Surface;
      Source_Area : in Rectangles.Rectangle);

   procedure Fill
     (Self   : in out Surface;
      Colour : in Interfaces.Unsigned_32);

   procedure Fill
     (Self   : in out Surface;
      Area   : in Rectangles.Rectangle;
      Colour : in Interfaces.Unsigned_32);

   procedure Fill
     (Self   : in out Surface;
      Areas  : in Rectangles.Rectangle_Arrays;
      Colour : in Interfaces.Unsigned_32);

   procedure Stretch
     (Self   : in out Surface;
      Source : in Surface;
      Mode   : in Scale_Modes := Linear);

   procedure Stretch
     (Self        : in out Surface;
      Self_Area   : in Rectangles.Rectangle;
      Source      : in Surface;
      Source_Area : in Rectangles.Rectangle;
      Mode        : in Scale_Modes := Linear);

   procedure Blit_Tiled
     (Self   : in out Surface;
      Source : in Surface);

   procedure Blit_Tiled
     (Self        : in out Surface;
      Self_Area   : in Rectangles.Rectangle;
      Source      : in Surface;
      Source_Area : in Rectangles.Rectangle);

   procedure Blit_Tiled_With_Scale
     (Self   : in out Surface;
      Source : in Surface;
      Scale  : in Float;
      Mode   : in Scale_Modes := Linear);

   procedure Blit_Tiled_With_Scale
     (Self        : in out Surface;
      Self_Area   : in Rectangles.Rectangle;
      Source      : in Surface;
      Source_Area : in Rectangles.Rectangle;
      Scale       : in Float;
      Mode        : in Scale_Modes := Linear);

   procedure Blit_9_Grid
     (Self          : in out Surface;
      Source        : in Surface;
      Left_Width    : in SDL.Dimension;
      Right_Width   : in SDL.Dimension;
      Top_Height    : in SDL.Dimension;
      Bottom_Height : in SDL.Dimension;
      Scale         : in Float := 0.0;
      Mode          : in Scale_Modes := Linear);

   procedure Blit_9_Grid
     (Self          : in out Surface;
      Self_Area     : in Rectangles.Rectangle;
      Source        : in Surface;
      Source_Area   : in Rectangles.Rectangle;
      Left_Width    : in SDL.Dimension;
      Right_Width   : in SDL.Dimension;
      Top_Height    : in SDL.Dimension;
      Bottom_Height : in SDL.Dimension;
      Scale         : in Float := 0.0;
      Mode          : in Scale_Modes := Linear);

   function Clip_Rectangle
     (Self : in Surface) return Rectangles.Rectangle
   with
     Inline => True;

   procedure Set_Clip_Rectangle
     (Self : in out Surface;
      Now  : in Rectangles.Rectangle)
   with
     Inline => True;

   function Colour_Key
     (Self : in Surface) return Palettes.Colour
   with
     Inline => True;

   procedure Set_Colour_Key
     (Self   : in out Surface;
      Now    : in Palettes.Colour;
      Enable : in Boolean := True)
   with
     Inline => True;

   function Alpha_Blend
     (Self : in Surface) return Palettes.Colour_Component
   with
     Inline => True;

   procedure Set_Alpha_Blend
     (Self : in out Surface;
      Now  : in Palettes.Colour_Component)
   with
     Inline => True;

   function Blend_Mode (Self : in Surface) return SDL.Video.Blend_Modes with
     Inline => True;

   procedure Set_Blend_Mode
     (Self : in out Surface;
      Now  : in SDL.Video.Blend_Modes)
   with
     Inline => True;

   function Colour (Self : in Surface) return Palettes.RGB_Colour with
     Inline => True;

   procedure Set_Colour
     (Self : in out Surface;
      Now  : in Palettes.RGB_Colour)
   with
     Inline => True;

   function Map_Colour
     (Self   : in Surface;
      Colour : in Palettes.RGB_Colour) return Interfaces.Unsigned_32;

   function Map_Colour
     (Self   : in Surface;
      Colour : in Palettes.Colour) return Interfaces.Unsigned_32;

   function Read_Pixel
     (Self : in Surface;
      X    : in SDL.Coordinate;
      Y    : in SDL.Coordinate) return Palettes.Colour;

   function Read_Pixel_Float
     (Self : in Surface;
      X    : in SDL.Coordinate;
      Y    : in SDL.Coordinate) return Float_Colour;

   procedure Write_Pixel
     (Self   : in out Surface;
      X      : in SDL.Coordinate;
      Y      : in SDL.Coordinate;
      Colour : in Palettes.Colour);

   procedure Write_Pixel_Float
     (Self   : in out Surface;
      X      : in SDL.Coordinate;
      Y      : in SDL.Coordinate;
      Colour : in Float_Colour);

   procedure Lock (Self : in out Surface) with
     Inline => True;

   procedure Unlock (Self : in out Surface) with
     Inline => True;

   function Must_Lock (Self : in Surface) return Boolean with
     Inline => True;

   function Has_RLE (Self : in Surface) return Boolean with
     Inline => True;

   procedure Set_RLE
     (Self    : in out Surface;
     Enabled : in Boolean)
   with
     Inline => True;

   procedure Flip
     (Self : in out Surface;
      Mode : in Flip_Modes)
   with
     Inline => True;

   procedure Save_BMP
     (Self      : in Surface;
      File_Name : in UTF_Strings.UTF_String);

   procedure Save_BMP
     (Self        : in Surface;
      Destination : in SDL.RWops.RWops;
      Close_After : in Boolean := False);

   procedure Save_PNG
     (Self      : in Surface;
      File_Name : in UTF_Strings.UTF_String);

   procedure Save_PNG
     (Self        : in Surface;
      Destination : in SDL.RWops.RWops;
      Close_After : in Boolean := False);

   overriding
   procedure Initialize (Self : in out Surface) renames Adjust;

   overriding
   procedure Adjust (Self : in out Surface);

   overriding
   procedure Finalize (Self : in out Surface);
private
   type Surface_Flags is mod 2 ** 32 with
     Convention => C;

   Preallocated : constant Surface_Flags := 16#0000_0001#;
   Lock_Needed  : constant Surface_Flags := 16#0000_0002#;
   Locked       : constant Surface_Flags := 16#0000_0004#;
   SIMD_Aligned : constant Surface_Flags := 16#0000_0008#;

   type Internal_Surface is
      record
         Flags           : Surface_Flags := 0;
         Format          : SDL.Video.Pixel_Formats.Pixel_Format_Names :=
           SDL.Video.Pixel_Formats.Pixel_Format_Unknown;
         Width           : SDL.Dimension := 0;
         Height          : SDL.Dimension := 0;
         Pitch           : C.int := 0;
         Pixels          : System.Address := System.Null_Address;
         Reference_Count : C.int := 0;
         Reserved        : System.Address := System.Null_Address;
      end record with
     Convention => C;

   type Surface is new Ada.Finalization.Controlled with
      record
         Internal : Internal_Surface_Pointer := null;
         Owns     : Boolean := True;
      end record;

   Null_Surface : constant Surface :=
     (Ada.Finalization.Controlled with
      Internal => null,
      Owns     => True);
end SDL.Video.Surfaces;
