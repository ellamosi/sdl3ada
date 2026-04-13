with Interfaces;
with Interfaces.C;

with SDL.Video.Palettes;

package SDL.Video.Pixel_Formats is
   pragma Preelaborate;
   pragma Elaborate_Body;

   package C renames Interfaces.C;

   subtype Unsigned_32 is Interfaces.Unsigned_32;
   subtype Colour_Mask is Unsigned_32;

   type Bits_Per_Pixels is range 0 .. 32 with
     Convention => C;

   type Bytes_Per_Pixels is range 0 .. 16 with
     Convention => C;

   type Pixel_Format_Names is mod 2 ** 32 with
     Convention => C;

   Pixel_Format_Unknown   : constant Pixel_Format_Names := 16#0000_0000#;
   Pixel_Format_Index_8   : constant Pixel_Format_Names := 16#1300_0801#;
   Pixel_Format_RGB_332   : constant Pixel_Format_Names := 16#1411_0801#;
   Pixel_Format_XRGB_4444 : constant Pixel_Format_Names := 16#1512_0C02#;
   Pixel_Format_RGB_444   : constant Pixel_Format_Names := Pixel_Format_XRGB_4444;
   Pixel_Format_XRGB_1555 : constant Pixel_Format_Names := 16#1513_0F02#;
   Pixel_Format_RGB_555   : constant Pixel_Format_Names := Pixel_Format_XRGB_1555;
   Pixel_Format_XBGR_1555 : constant Pixel_Format_Names := 16#1553_0F02#;
   Pixel_Format_BGR_555   : constant Pixel_Format_Names := Pixel_Format_XBGR_1555;
   Pixel_Format_ARGB_4444 : constant Pixel_Format_Names := 16#1532_1002#;
   Pixel_Format_RGBA_4444 : constant Pixel_Format_Names := 16#1542_1002#;
   Pixel_Format_ABGR_4444 : constant Pixel_Format_Names := 16#1572_1002#;
   Pixel_Format_BGRA_4444 : constant Pixel_Format_Names := 16#1582_1002#;
   Pixel_Format_ARGB_1555 : constant Pixel_Format_Names := 16#1533_1002#;
   Pixel_Format_RGBA_5551 : constant Pixel_Format_Names := 16#1544_1002#;
   Pixel_Format_ABGR_1555 : constant Pixel_Format_Names := 16#1573_1002#;
   Pixel_Format_BGRA_5551 : constant Pixel_Format_Names := 16#1584_1002#;
   Pixel_Format_RGB_565   : constant Pixel_Format_Names := 16#1515_1002#;
   Pixel_Format_BGR_565   : constant Pixel_Format_Names := 16#1555_1002#;
   Pixel_Format_RGB_24    : constant Pixel_Format_Names := 16#1710_1803#;
   Pixel_Format_BGR_24    : constant Pixel_Format_Names := 16#1740_1803#;
   Pixel_Format_XRGB_8888 : constant Pixel_Format_Names := 16#1616_1804#;
   Pixel_Format_RGB_888   : constant Pixel_Format_Names := Pixel_Format_XRGB_8888;
   Pixel_Format_RGBX_8888 : constant Pixel_Format_Names := 16#1626_1804#;
   Pixel_Format_XBGR_8888 : constant Pixel_Format_Names := 16#1656_1804#;
   Pixel_Format_BGR_888   : constant Pixel_Format_Names := Pixel_Format_XBGR_8888;
   Pixel_Format_BGRX_8888 : constant Pixel_Format_Names := 16#1666_1804#;
   Pixel_Format_ARGB_8888 : constant Pixel_Format_Names := 16#1636_2004#;
   Pixel_Format_RGBA_8888 : constant Pixel_Format_Names := 16#1646_2004#;
   Pixel_Format_ABGR_8888 : constant Pixel_Format_Names := 16#1676_2004#;
   Pixel_Format_BGRA_8888 : constant Pixel_Format_Names := 16#1686_2004#;
   Pixel_Format_ARGB_2101010 : constant Pixel_Format_Names := 16#1637_2004#;

   type Padding_Array is array (Positive range 1 .. 2) of Interfaces.Unsigned_8 with
     Convention => C;

   type Pixel_Format is
      record
         Format          : Pixel_Format_Names;
         Bits_Per_Pixel  : Interfaces.Unsigned_8;
         Bytes_Per_Pixel : Interfaces.Unsigned_8;
         Padding         : Padding_Array := (others => 0);
         Red_Mask        : Colour_Mask;
         Green_Mask      : Colour_Mask;
         Blue_Mask       : Colour_Mask;
         Alpha_Mask      : Colour_Mask;
         Red_Bits        : Interfaces.Unsigned_8;
         Green_Bits      : Interfaces.Unsigned_8;
         Blue_Bits       : Interfaces.Unsigned_8;
         Alpha_Bits      : Interfaces.Unsigned_8;
         Red_Shift       : Interfaces.Unsigned_8;
         Green_Shift     : Interfaces.Unsigned_8;
         Blue_Shift      : Interfaces.Unsigned_8;
         Alpha_Shift     : Interfaces.Unsigned_8;
      end record with
     Convention => C;

   type Pixel_Format_Access is access constant Pixel_Format with
     Convention => C;

   function Get_Details
     (Format : in Pixel_Format_Names) return Pixel_Format_Access;

   function Image (Format : in Pixel_Format_Names) return String;

   procedure To_Components
     (Pixel  : in  Unsigned_32;
      Format : in  Pixel_Format_Access;
      Red    : out SDL.Video.Palettes.Colour_Component;
      Green  : out SDL.Video.Palettes.Colour_Component;
      Blue   : out SDL.Video.Palettes.Colour_Component);

   procedure To_Components
     (Pixel  : in  Unsigned_32;
      Format : in  Pixel_Format_Access;
      Red    : out SDL.Video.Palettes.Colour_Component;
      Green  : out SDL.Video.Palettes.Colour_Component;
      Blue   : out SDL.Video.Palettes.Colour_Component;
      Alpha  : out SDL.Video.Palettes.Colour_Component);

   function To_Pixel
     (Format : in Pixel_Format_Access;
      Red    : in SDL.Video.Palettes.Colour_Component;
      Green  : in SDL.Video.Palettes.Colour_Component;
      Blue   : in SDL.Video.Palettes.Colour_Component) return Unsigned_32;

   function To_Pixel
     (Format : in Pixel_Format_Access;
      Red    : in SDL.Video.Palettes.Colour_Component;
      Green  : in SDL.Video.Palettes.Colour_Component;
      Blue   : in SDL.Video.Palettes.Colour_Component;
      Alpha  : in SDL.Video.Palettes.Colour_Component) return Unsigned_32;

   function To_Colour
     (Pixel  : in Unsigned_32;
      Format : in Pixel_Format_Access) return SDL.Video.Palettes.Colour;

   function To_Pixel
     (Colour : in SDL.Video.Palettes.Colour;
      Format : in Pixel_Format_Access) return Unsigned_32;

   function To_Name
     (Bits       : in Bits_Per_Pixels;
      Red_Mask   : in Colour_Mask;
      Green_Mask : in Colour_Mask;
      Blue_Mask  : in Colour_Mask;
      Alpha_Mask : in Colour_Mask) return Pixel_Format_Names;

   function To_Masks
     (Format     : in  Pixel_Format_Names;
      Bits       : out Bits_Per_Pixels;
      Red_Mask   : out Colour_Mask;
      Green_Mask : out Colour_Mask;
      Blue_Mask  : out Colour_Mask;
      Alpha_Mask : out Colour_Mask) return Boolean;
end SDL.Video.Pixel_Formats;
