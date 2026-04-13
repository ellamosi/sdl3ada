with Ada.Finalization;
with Interfaces.C;
with System;

with SDL.Properties;
with SDL.Video.Palettes;
with SDL.Video.Pixel_Formats;
with SDL.Video.Pixels;
with SDL.Video.Rectangles;
with SDL.Video.Surfaces;

package SDL.Video.Textures is
   Texture_Error : exception;

   type Scale_Modes is (Invalid, Nearest, Linear, Pixel_Art) with
     Convention => C,
     Size       => Interfaces.C.int'Size;

   for Scale_Modes use
     (Invalid   => -1,
      Nearest   => 0,
      Linear    => 1,
      Pixel_Art => 2);

   type Kinds is (Static, Streaming, Target) with
     Convention => C,
     Size       => Interfaces.C.int'Size;

   for Kinds use
     (Static    => 0,
      Streaming => 1,
      Target    => 2);

   type Texture is new Ada.Finalization.Limited_Controlled with private;

   overriding
   procedure Finalize (Self : in out Texture);

   function Is_Null (Self : in Texture) return Boolean with
     Inline;

   function Get_Properties
     (Self : in Texture) return SDL.Properties.Property_ID;

   generic
      type Pixel_Pointer_Type is private;
   procedure Lock
     (Self   : in out Texture;
      Pixels : out Pixel_Pointer_Type);

   generic
      type Pixel_Pointer_Type is private;
   procedure Lock_Area
     (Self   : in out Texture;
      Area   : in SDL.Video.Rectangles.Rectangle;
      Pixels : out Pixel_Pointer_Type;
      Pitch  : out SDL.Video.Pixels.Pitches);

   function Lock_To_Surface
     (Self : in out Texture) return SDL.Video.Surfaces.Surface;

   function Lock_To_Surface
     (Self : in out Texture;
      Area : in SDL.Video.Rectangles.Rectangle)
      return SDL.Video.Surfaces.Surface;

   procedure Unlock (Self : in out Texture);

   procedure Update
     (Self   : in out Texture;
      Pixels : in System.Address;
      Pitch  : in SDL.Video.Pixels.Pitches);

   procedure Update
     (Self   : in out Texture;
      Area   : in SDL.Video.Rectangles.Rectangle;
      Pixels : in System.Address;
      Pitch  : in SDL.Video.Pixels.Pitches);

   procedure Update_YUV
     (Self     : in out Texture;
      Area     : in SDL.Video.Rectangles.Rectangle;
      Y_Pixels : in System.Address;
      Y_Pitch  : in SDL.Video.Pixels.Pitches;
      U_Pixels : in System.Address;
      U_Pitch  : in SDL.Video.Pixels.Pitches;
      V_Pixels : in System.Address;
      V_Pitch  : in SDL.Video.Pixels.Pitches);

   procedure Update_NV
     (Self      : in out Texture;
      Area      : in SDL.Video.Rectangles.Rectangle;
      Y_Pixels  : in System.Address;
      Y_Pitch   : in SDL.Video.Pixels.Pitches;
      UV_Pixels : in System.Address;
      UV_Pitch  : in SDL.Video.Pixels.Pitches);

   procedure Set_Palette
     (Self    : in out Texture;
     Palette : in SDL.Video.Palettes.Palette);

   function Get_Palette
     (Self : in Texture) return SDL.Video.Palettes.Palette;

   procedure Set_Scale_Mode
     (Self : in out Texture;
      Mode : in Scale_Modes);

   function Get_Scale_Mode (Self : in Texture) return Scale_Modes;

   function Get_Blend_Mode
     (Self : in Texture) return SDL.Video.Blend_Modes;

   procedure Set_Blend_Mode
     (Self : in out Texture;
      Mode : in SDL.Video.Blend_Modes);

   function Get_Colour
     (Self : in Texture) return SDL.Video.Palettes.RGB_Colour;

   procedure Get_Colour
     (Self        : in Texture;
      Red, Green  : out Float;
      Blue        : out Float);

   procedure Set_Colour
     (Self   : in out Texture;
      Colour : in SDL.Video.Palettes.RGB_Colour);

   procedure Set_Colour
     (Self       : in out Texture;
      Red, Green : in Float;
      Blue       : in Float);

   function Get_Alpha
     (Self : in Texture) return SDL.Video.Palettes.Colour_Component;

   function Get_Alpha_Float (Self : in Texture) return Float;

   procedure Set_Alpha
     (Self  : in out Texture;
      Alpha : in SDL.Video.Palettes.Colour_Component);

   procedure Set_Alpha
     (Self  : in out Texture;
      Alpha : in Float);

   procedure Query
     (Self              : in Texture;
      Pixel_Format_Name : out SDL.Video.Pixel_Formats.Pixel_Format_Names;
      Kind              : out Kinds;
      Size              : out SDL.Sizes);

   function Get_Pixel_Format
     (Self : in Texture) return SDL.Video.Pixel_Formats.Pixel_Format_Names;

   function Get_Kind (Self : in Texture) return Kinds;

   procedure Get_Size
     (Self          : in Texture;
      Width, Height : out Float);

   function Get_Size (Self : in Texture) return SDL.Sizes;

   function Get_Internal (Self : in Texture) return System.Address with
     Inline;
private
   type Texture is new Ada.Finalization.Limited_Controlled with
      record
         Internal     : System.Address := System.Null_Address;
         Owns         : Boolean        := True;
         Locked       : Boolean        := False;
         Size         : SDL.Sizes      := SDL.Zero_Size;
         Pixel_Format : SDL.Video.Pixel_Formats.Pixel_Format_Names :=
           SDL.Video.Pixel_Formats.Pixel_Format_Unknown;
         Kind         : Kinds := Static;
      end record;
end SDL.Video.Textures;
