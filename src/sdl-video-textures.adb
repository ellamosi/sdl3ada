with Ada.Unchecked_Conversion;

with SDL.Error;
with SDL.Raw.Render;
with SDL.Video.Palettes.Internal;
with SDL.Video.Surfaces.Internal;

package body SDL.Video.Textures is
   package Raw renames SDL.Raw.Render;
   package Palette_Internal renames SDL.Video.Palettes.Internal;
   package Surface_Internal renames SDL.Video.Surfaces.Internal;

   use type System.Address;

   SDL_PROP_TEXTURE_ACCESS_NUMBER : constant String := "SDL.texture.access";
   SDL_PROP_TEXTURE_FORMAT_NUMBER : constant String := "SDL.texture.format";
   SDL_PROP_TEXTURE_HEIGHT_NUMBER : constant String := "SDL.texture.height";
   SDL_PROP_TEXTURE_WIDTH_NUMBER  : constant String := "SDL.texture.width";

   function To_Internal_Surface_Pointer is new Ada.Unchecked_Conversion
     (Source => System.Address,
      Target => SDL.Video.Surfaces.Internal_Surface_Pointer);

   function To_Scale_Mode (Value : in Raw.Texture_Scale_Mode) return Scale_Modes is
   begin
      case Integer (Value) is
         when -1 =>
            return Invalid;
         when 0 =>
            return Nearest;
         when 1 =>
            return Linear;
         when 2 =>
            return Pixel_Art;
         when others =>
            return Invalid;
      end case;
   end To_Scale_Mode;

   function To_Raw (Value : in Scale_Modes) return Raw.Texture_Scale_Mode is
   begin
      case Value is
         when Invalid =>
            return -1;
         when Nearest =>
            return 0;
         when Linear =>
            return 1;
         when Pixel_Art =>
            return 2;
      end case;
   end To_Raw;

   procedure Raise_Texture_Error
     (Default_Message : in String := "SDL texture call failed");

   procedure Raise_Texture_Error
     (Default_Message : in String := "SDL texture call failed")
   is
      Message : constant String := SDL.Error.Get;
   begin
      if Message = "" then
         raise Texture_Error with Default_Message;
      end if;

      raise Texture_Error with Message;
   end Raise_Texture_Error;

   procedure Require_Texture (Self : in Texture);

   procedure Require_Texture (Self : in Texture) is
   begin
      if Self.Internal = System.Null_Address then
         raise Texture_Error with "Invalid texture";
      end if;
   end Require_Texture;

   procedure Query_Metadata
     (Self              : in Texture;
      Pixel_Format_Name : out SDL.Video.Pixel_Formats.Pixel_Format_Names;
      Kind              : out Kinds;
      Size              : out SDL.Sizes);

   procedure Query_Metadata
     (Self              : in Texture;
      Pixel_Format_Name : out SDL.Video.Pixel_Formats.Pixel_Format_Names;
      Kind              : out Kinds;
      Size              : out SDL.Sizes)
   is
      Props         : constant SDL.Properties.Property_Set :=
        SDL.Properties.Reference (Raw.Get_Texture_Properties (Self.Internal));
      Access_Number : constant SDL.Properties.Property_Numbers :=
        SDL.Properties.Get_Number (Props, SDL_PROP_TEXTURE_ACCESS_NUMBER, 0);
   begin
      Require_Texture (Self);

      Pixel_Format_Name :=
        SDL.Video.Pixel_Formats.Pixel_Format_Names
          (SDL.Properties.Get_Number (Props, SDL_PROP_TEXTURE_FORMAT_NUMBER, 0));
      Size :=
        (Width  =>
           SDL.Dimension
             (SDL.Properties.Get_Number (Props, SDL_PROP_TEXTURE_WIDTH_NUMBER, 0)),
         Height =>
           SDL.Dimension
             (SDL.Properties.Get_Number (Props, SDL_PROP_TEXTURE_HEIGHT_NUMBER, 0)));

      case Integer (Access_Number) is
         when 0 =>
            Kind := Static;
         when 1 =>
            Kind := Streaming;
         when 2 =>
            Kind := Target;
         when others =>
            Kind := Static;
      end case;
   end Query_Metadata;

   function Is_Null (Self : in Texture) return Boolean is
     (Self.Internal = System.Null_Address);

   function Get_Internal (Self : in Texture) return System.Address is
     (Self.Internal);

   function Get_Properties
     (Self : in Texture) return SDL.Properties.Property_ID
   is
   begin
      Require_Texture (Self);
      return Raw.Get_Texture_Properties (Self.Internal);
   end Get_Properties;

   procedure Lock
     (Self   : in out Texture;
      Pixels : out Pixel_Pointer_Type)
   is
      function To_Pixel_Pointer_Type is new Ada.Unchecked_Conversion
        (Source => System.Address,
         Target => Pixel_Pointer_Type);

      Raw_Pixels  : System.Address := System.Null_Address;
      Dummy_Pitch : Raw.Texture_Pitch := 0;
   begin
      Require_Texture (Self);

      if Self.Locked then
         raise Texture_Error with "Texture already locked";
      end if;

      if not Boolean
          (Raw.Lock_Texture
             (Self.Internal, System.Null_Address, Raw_Pixels, Dummy_Pitch))
      then
         Raise_Texture_Error;
      end if;

      Pixels := To_Pixel_Pointer_Type (Raw_Pixels);
      Self.Locked := True;
   end Lock;

   procedure Lock_Area
     (Self   : in out Texture;
      Area   : in SDL.Video.Rectangles.Rectangle;
      Pixels : out Pixel_Pointer_Type;
      Pitch  : out SDL.Video.Pixels.Pitches)
   is
      function To_Pixel_Pointer_Type is new Ada.Unchecked_Conversion
        (Source => System.Address,
         Target => Pixel_Pointer_Type);

      Raw_Area : aliased constant SDL.Video.Rectangles.Rectangle := Area;
      Raw_Pixels : System.Address := System.Null_Address;
      Raw_Pitch  : Raw.Texture_Pitch := 0;
   begin
      Require_Texture (Self);

      if Self.Locked then
         raise Texture_Error with "Texture already locked";
      end if;

      if not Boolean
          (Raw.Lock_Texture
             (Self.Internal, Raw_Area'Address, Raw_Pixels, Raw_Pitch))
      then
         Raise_Texture_Error;
      end if;

      Pixels := To_Pixel_Pointer_Type (Raw_Pixels);
      Pitch := SDL.Video.Pixels.Pitches (Raw_Pitch);
      Self.Locked := True;
   end Lock_Area;

   function Lock_To_Surface
     (Self : in out Texture) return SDL.Video.Surfaces.Surface
   is
      Internal : aliased System.Address := System.Null_Address;
   begin
      Require_Texture (Self);

      if Self.Locked then
         raise Texture_Error with "Texture already locked";
      end if;

      if not Boolean
          (Raw.Lock_Texture_To_Surface
             (Self.Internal, System.Null_Address, Internal'Access))
      then
         Raise_Texture_Error;
      end if;

      Self.Locked := True;
      return Surface_Internal.Make_From_Pointer
        (To_Internal_Surface_Pointer (Internal), Owns => False);
   end Lock_To_Surface;

   function Lock_To_Surface
     (Self : in out Texture;
      Area : in SDL.Video.Rectangles.Rectangle)
      return SDL.Video.Surfaces.Surface
   is
      Raw_Area : aliased constant SDL.Video.Rectangles.Rectangle := Area;
      Internal : aliased System.Address := System.Null_Address;
   begin
      Require_Texture (Self);

      if Self.Locked then
         raise Texture_Error with "Texture already locked";
      end if;

      if not Boolean
          (Raw.Lock_Texture_To_Surface
             (Self.Internal, Raw_Area'Address, Internal'Access))
      then
         Raise_Texture_Error;
      end if;

      Self.Locked := True;
      return Surface_Internal.Make_From_Pointer
        (To_Internal_Surface_Pointer (Internal), Owns => False);
   end Lock_To_Surface;

   procedure Unlock (Self : in out Texture) is
   begin
      if Self.Internal = System.Null_Address or else not Self.Locked then
         return;
      end if;

      Raw.Unlock_Texture (Self.Internal);
      Self.Locked := False;
   end Unlock;

   procedure Update
     (Self   : in out Texture;
      Pixels : in System.Address;
      Pitch  : in SDL.Video.Pixels.Pitches)
   is
   begin
      Require_Texture (Self);

      if not Boolean
          (Raw.Update_Texture
              (Self.Internal,
              System.Null_Address,
              Pixels,
              Raw.Texture_Pitch (Pitch)))
      then
         Raise_Texture_Error;
      end if;
   end Update;

   procedure Update
     (Self   : in out Texture;
      Area   : in SDL.Video.Rectangles.Rectangle;
      Pixels : in System.Address;
      Pitch  : in SDL.Video.Pixels.Pitches)
   is
      Raw_Area : aliased constant SDL.Video.Rectangles.Rectangle := Area;
   begin
      Require_Texture (Self);

      if not Boolean
          (Raw.Update_Texture
              (Self.Internal,
              Raw_Area'Address,
              Pixels,
              Raw.Texture_Pitch (Pitch)))
      then
         Raise_Texture_Error;
      end if;
   end Update;

   procedure Update_YUV
     (Self     : in out Texture;
      Area     : in SDL.Video.Rectangles.Rectangle;
      Y_Pixels : in System.Address;
      Y_Pitch  : in SDL.Video.Pixels.Pitches;
      U_Pixels : in System.Address;
      U_Pitch  : in SDL.Video.Pixels.Pitches;
      V_Pixels : in System.Address;
      V_Pitch  : in SDL.Video.Pixels.Pitches)
   is
      Raw_Area : aliased constant SDL.Video.Rectangles.Rectangle := Area;
   begin
      Require_Texture (Self);

      if not Boolean
          (Raw.Update_YUV_Texture
             (Self.Internal,
              Raw_Area'Address,
              Y_Pixels,
              Raw.Texture_Pitch (Y_Pitch),
              U_Pixels,
              Raw.Texture_Pitch (U_Pitch),
              V_Pixels,
              Raw.Texture_Pitch (V_Pitch)))
      then
         Raise_Texture_Error;
      end if;
   end Update_YUV;

   procedure Update_NV
     (Self      : in out Texture;
      Area      : in SDL.Video.Rectangles.Rectangle;
      Y_Pixels  : in System.Address;
      Y_Pitch   : in SDL.Video.Pixels.Pitches;
      UV_Pixels : in System.Address;
      UV_Pitch  : in SDL.Video.Pixels.Pitches)
   is
      Raw_Area : aliased constant SDL.Video.Rectangles.Rectangle := Area;
   begin
      Require_Texture (Self);

      if not Boolean
          (Raw.Update_NV_Texture
             (Self.Internal,
              Raw_Area'Address,
              Y_Pixels,
              Raw.Texture_Pitch (Y_Pitch),
              UV_Pixels,
              Raw.Texture_Pitch (UV_Pitch)))
      then
         Raise_Texture_Error;
      end if;
   end Update_NV;

   procedure Set_Palette
     (Self    : in out Texture;
      Palette : in SDL.Video.Palettes.Palette)
   is
   begin
      Require_Texture (Self);

      if not Boolean
          (Raw.Set_Texture_Palette
             (Self.Internal, SDL.Video.Palettes.Get_Internal (Palette)))
      then
         Raise_Texture_Error;
      end if;
   end Set_Palette;

   function Get_Palette
     (Self : in Texture) return SDL.Video.Palettes.Palette
   is
      Internal : System.Address;
   begin
      Require_Texture (Self);

      Internal := Raw.Get_Texture_Palette (Self.Internal);
      return Result : SDL.Video.Palettes.Palette do
         Palette_Internal.Copy_From_Pointer (Internal, Result);
      end return;
   end Get_Palette;

   procedure Set_Scale_Mode
     (Self : in out Texture;
      Mode : in Scale_Modes)
   is
   begin
      Require_Texture (Self);

      if not Boolean
          (Raw.Set_Texture_Scale_Mode (Self.Internal, To_Raw (Mode)))
      then
         Raise_Texture_Error;
      end if;
   end Set_Scale_Mode;

   function Get_Scale_Mode (Self : in Texture) return Scale_Modes is
      Result : aliased Raw.Texture_Scale_Mode := To_Raw (Invalid);
   begin
      Require_Texture (Self);

      if not Boolean
          (Raw.Get_Texture_Scale_Mode (Self.Internal, Result'Access))
      then
         Raise_Texture_Error;
      end if;

      return To_Scale_Mode (Result);
   end Get_Scale_Mode;

   function Get_Blend_Mode
     (Self : in Texture) return SDL.Video.Blend_Modes
   is
      Result : aliased Raw.Blend_Mode := Raw.Blend_Mode (SDL.Video.None);
   begin
      Require_Texture (Self);

      if not Boolean
          (Raw.Get_Texture_Blend_Mode (Self.Internal, Result'Access))
      then
         Raise_Texture_Error;
      end if;

      return SDL.Video.Blend_Modes (Result);
   end Get_Blend_Mode;

   procedure Set_Blend_Mode
     (Self : in out Texture;
      Mode : in SDL.Video.Blend_Modes)
   is
   begin
      Require_Texture (Self);

      if not Boolean
          (Raw.Set_Texture_Blend_Mode
             (Self.Internal, Raw.Blend_Mode (Mode)))
      then
         Raise_Texture_Error;
      end if;
   end Set_Blend_Mode;

   function Get_Colour
     (Self : in Texture) return SDL.Video.Palettes.RGB_Colour
   is
      Red   : aliased Raw.Colour_Component := 0;
      Green : aliased Raw.Colour_Component := 0;
      Blue  : aliased Raw.Colour_Component := 0;
   begin
      Require_Texture (Self);

      if not Boolean
          (Raw.Get_Texture_Color_Mod
             (Self.Internal,
              Red'Access,
              Green'Access,
              Blue'Access))
      then
         Raise_Texture_Error;
      end if;

      return (Red => Red, Green => Green, Blue => Blue);
   end Get_Colour;

   procedure Get_Colour
     (Self        : in Texture;
      Red, Green  : out Float;
      Blue        : out Float)
   is
      Raw_Red   : aliased Raw.C.C_float := 0.0;
      Raw_Green : aliased Raw.C.C_float := 0.0;
      Raw_Blue  : aliased Raw.C.C_float := 0.0;
   begin
      Require_Texture (Self);

      if not Boolean
          (Raw.Get_Texture_Color_Mod_Float
             (Self.Internal,
              Raw_Red'Access,
              Raw_Green'Access,
              Raw_Blue'Access))
      then
         Raise_Texture_Error;
      end if;

      Red := Float (Raw_Red);
      Green := Float (Raw_Green);
      Blue := Float (Raw_Blue);
   end Get_Colour;

   procedure Set_Colour
     (Self   : in out Texture;
      Colour : in SDL.Video.Palettes.RGB_Colour)
   is
   begin
      Require_Texture (Self);

      if not Boolean
          (Raw.Set_Texture_Color_Mod
             (Self.Internal, Colour.Red, Colour.Green, Colour.Blue))
      then
         Raise_Texture_Error;
      end if;
   end Set_Colour;

   procedure Set_Colour
     (Self       : in out Texture;
      Red, Green : in Float;
      Blue       : in Float)
   is
   begin
      Require_Texture (Self);

      if not Boolean
          (Raw.Set_Texture_Color_Mod_Float
             (Self.Internal,
              Raw.C.C_float (Red),
              Raw.C.C_float (Green),
              Raw.C.C_float (Blue)))
      then
         Raise_Texture_Error;
      end if;
   end Set_Colour;

   function Get_Alpha
     (Self : in Texture) return SDL.Video.Palettes.Colour_Component
   is
      Result : aliased Raw.Colour_Component := 0;
   begin
      Require_Texture (Self);

      if not Boolean
          (Raw.Get_Texture_Alpha_Mod (Self.Internal, Result'Access))
      then
         Raise_Texture_Error;
      end if;

      return Result;
   end Get_Alpha;

   function Get_Alpha_Float (Self : in Texture) return Float is
      Result : aliased Raw.C.C_float := 0.0;
   begin
      Require_Texture (Self);

      if not Boolean
          (Raw.Get_Texture_Alpha_Mod_Float (Self.Internal, Result'Access))
      then
         Raise_Texture_Error;
      end if;

      return Float (Result);
   end Get_Alpha_Float;

   procedure Set_Alpha
     (Self  : in out Texture;
      Alpha : in SDL.Video.Palettes.Colour_Component)
   is
   begin
      Require_Texture (Self);

      if not Boolean
          (Raw.Set_Texture_Alpha_Mod (Self.Internal, Alpha))
      then
         Raise_Texture_Error;
      end if;
   end Set_Alpha;

   procedure Set_Alpha
     (Self  : in out Texture;
      Alpha : in Float)
   is
   begin
      Require_Texture (Self);

      if not Boolean
          (Raw.Set_Texture_Alpha_Mod_Float
             (Self.Internal, Raw.C.C_float (Alpha)))
      then
         Raise_Texture_Error;
      end if;
   end Set_Alpha;

   procedure Query
     (Self              : in Texture;
      Pixel_Format_Name : out SDL.Video.Pixel_Formats.Pixel_Format_Names;
      Kind              : out Kinds;
      Size              : out SDL.Sizes) is
   begin
      Query_Metadata (Self, Pixel_Format_Name, Kind, Size);
   end Query;

   function Get_Pixel_Format
     (Self : in Texture) return SDL.Video.Pixel_Formats.Pixel_Format_Names
   is
      Kind : Kinds := Static;
      Size : SDL.Sizes := SDL.Zero_Size;
      Result : SDL.Video.Pixel_Formats.Pixel_Format_Names :=
        SDL.Video.Pixel_Formats.Pixel_Format_Unknown;
   begin
      Query_Metadata (Self, Result, Kind, Size);
      return Result;
   end Get_Pixel_Format;

   function Get_Kind (Self : in Texture) return Kinds is
      Format : SDL.Video.Pixel_Formats.Pixel_Format_Names :=
        SDL.Video.Pixel_Formats.Pixel_Format_Unknown;
      Size   : SDL.Sizes := SDL.Zero_Size;
      Result : Kinds := Static;
   begin
      Query_Metadata (Self, Format, Result, Size);
      return Result;
   end Get_Kind;

   procedure Get_Size
     (Self          : in Texture;
     Width, Height : out Float)
   is
      Raw_Width  : aliased Raw.C.C_float := 0.0;
      Raw_Height : aliased Raw.C.C_float := 0.0;
   begin
      Require_Texture (Self);

      if not Boolean
          (Raw.Get_Texture_Size
             (Self.Internal, Raw_Width'Access, Raw_Height'Access))
      then
         Raise_Texture_Error;
      end if;

      Width := Float (Raw_Width);
      Height := Float (Raw_Height);
   end Get_Size;

   function Get_Size (Self : in Texture) return SDL.Sizes is
      Format : SDL.Video.Pixel_Formats.Pixel_Format_Names :=
        SDL.Video.Pixel_Formats.Pixel_Format_Unknown;
      Kind   : Kinds := Static;
      Result : SDL.Sizes := SDL.Zero_Size;
   begin
      Query_Metadata (Self, Format, Kind, Result);
      return Result;
   end Get_Size;

   overriding
   procedure Finalize (Self : in out Texture) is
   begin
      if Self.Owns and then Self.Internal /= System.Null_Address then
         Raw.Destroy_Texture (Self.Internal);
      end if;

      Self.Internal := System.Null_Address;
      Self.Owns := True;
      Self.Locked := False;
      Self.Size := SDL.Zero_Size;
      Self.Pixel_Format := SDL.Video.Pixel_Formats.Pixel_Format_Unknown;
      Self.Kind := Static;
   end Finalize;
end SDL.Video.Textures;
