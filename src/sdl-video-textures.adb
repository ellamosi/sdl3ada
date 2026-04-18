with Interfaces.C.Extensions;

with SDL.Error;
with SDL.Video.Palettes.Internal;
with SDL.Video.Surfaces.Internal;

package body SDL.Video.Textures is
   package CE renames Interfaces.C.Extensions;
   package Palette_Internal renames SDL.Video.Palettes.Internal;
   package Surface_Internal renames SDL.Video.Surfaces.Internal;

   use type System.Address;

   SDL_PROP_TEXTURE_ACCESS_NUMBER : constant String := "SDL.texture.access";
   SDL_PROP_TEXTURE_FORMAT_NUMBER : constant String := "SDL.texture.format";
   SDL_PROP_TEXTURE_HEIGHT_NUMBER : constant String := "SDL.texture.height";
   SDL_PROP_TEXTURE_WIDTH_NUMBER  : constant String := "SDL.texture.width";

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
      function SDL_Get_Texture_Properties
        (Value : in System.Address) return SDL.Properties.Property_ID
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetTextureProperties";

      Props         : constant SDL.Properties.Property_Set :=
        SDL.Properties.Reference (SDL_Get_Texture_Properties (Self.Internal));
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
      function SDL_Get_Texture_Properties
        (Value : in System.Address) return SDL.Properties.Property_ID
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetTextureProperties";
   begin
      Require_Texture (Self);
      return SDL_Get_Texture_Properties (Self.Internal);
   end Get_Properties;

   procedure Lock
     (Self   : in out Texture;
      Pixels : out Pixel_Pointer_Type)
   is
      function SDL_Lock_Texture
        (Value  : in System.Address;
         Area   : in System.Address;
         Target : out Pixel_Pointer_Type;
         Pitch  : out SDL.Video.Pixels.Pitches) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_LockTexture";

      Dummy_Pitch : SDL.Video.Pixels.Pitches := 0;
   begin
      Require_Texture (Self);

      if Self.Locked then
         raise Texture_Error with "Texture already locked";
      end if;

      if not Boolean
          (SDL_Lock_Texture
             (Self.Internal, System.Null_Address, Pixels, Dummy_Pitch))
      then
         Raise_Texture_Error;
      end if;

      Self.Locked := True;
   end Lock;

   procedure Lock_Area
     (Self   : in out Texture;
      Area   : in SDL.Video.Rectangles.Rectangle;
      Pixels : out Pixel_Pointer_Type;
      Pitch  : out SDL.Video.Pixels.Pitches)
   is
      function SDL_Lock_Texture
        (Value  : in System.Address;
         Area   : in System.Address;
         Target : out Pixel_Pointer_Type;
         Pitch  : out SDL.Video.Pixels.Pitches) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_LockTexture";

      Raw_Area : aliased constant SDL.Video.Rectangles.Rectangle := Area;
   begin
      Require_Texture (Self);

      if Self.Locked then
         raise Texture_Error with "Texture already locked";
      end if;

      if not Boolean
          (SDL_Lock_Texture
             (Self.Internal, Raw_Area'Address, Pixels, Pitch))
      then
         Raise_Texture_Error;
      end if;

      Self.Locked := True;
   end Lock_Area;

   function Lock_To_Surface
     (Self : in out Texture) return SDL.Video.Surfaces.Surface
   is
      function SDL_Lock_Texture_To_Surface
        (Value   : in System.Address;
         Area    : in System.Address;
         Surface : access SDL.Video.Surfaces.Internal_Surface_Pointer)
         return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_LockTextureToSurface";

      Internal : aliased SDL.Video.Surfaces.Internal_Surface_Pointer := null;
   begin
      Require_Texture (Self);

      if Self.Locked then
         raise Texture_Error with "Texture already locked";
      end if;

      if not Boolean
          (SDL_Lock_Texture_To_Surface
             (Self.Internal, System.Null_Address, Internal'Access))
      then
         Raise_Texture_Error;
      end if;

      Self.Locked := True;
      return Surface_Internal.Make_From_Pointer (Internal, Owns => False);
   end Lock_To_Surface;

   function Lock_To_Surface
     (Self : in out Texture;
      Area : in SDL.Video.Rectangles.Rectangle)
      return SDL.Video.Surfaces.Surface
   is
      function SDL_Lock_Texture_To_Surface
        (Value   : in System.Address;
         Area    : in System.Address;
         Surface : access SDL.Video.Surfaces.Internal_Surface_Pointer)
         return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_LockTextureToSurface";

      Raw_Area : aliased constant SDL.Video.Rectangles.Rectangle := Area;
      Internal : aliased SDL.Video.Surfaces.Internal_Surface_Pointer := null;
   begin
      Require_Texture (Self);

      if Self.Locked then
         raise Texture_Error with "Texture already locked";
      end if;

      if not Boolean
          (SDL_Lock_Texture_To_Surface
             (Self.Internal, Raw_Area'Address, Internal'Access))
      then
         Raise_Texture_Error;
      end if;

      Self.Locked := True;
      return Surface_Internal.Make_From_Pointer (Internal, Owns => False);
   end Lock_To_Surface;

   procedure Unlock (Self : in out Texture) is
      procedure SDL_Unlock_Texture (Value : in System.Address) with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_UnlockTexture";
   begin
      if Self.Internal = System.Null_Address or else not Self.Locked then
         return;
      end if;

      SDL_Unlock_Texture (Self.Internal);
      Self.Locked := False;
   end Unlock;

   procedure Update
     (Self   : in out Texture;
      Pixels : in System.Address;
      Pitch  : in SDL.Video.Pixels.Pitches)
   is
      function SDL_Update_Texture
        (Value  : in System.Address;
         Area   : in System.Address;
         Pixels : in System.Address;
         Pitch  : in SDL.Video.Pixels.Pitches) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_UpdateTexture";
   begin
      Require_Texture (Self);

      if not Boolean
          (SDL_Update_Texture
             (Self.Internal, System.Null_Address, Pixels, Pitch))
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
      function SDL_Update_Texture
        (Value  : in System.Address;
         Area   : in System.Address;
         Pixels : in System.Address;
         Pitch  : in SDL.Video.Pixels.Pitches) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_UpdateTexture";

      Raw_Area : aliased constant SDL.Video.Rectangles.Rectangle := Area;
   begin
      Require_Texture (Self);

      if not Boolean
          (SDL_Update_Texture
             (Self.Internal, Raw_Area'Address, Pixels, Pitch))
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
      function SDL_Update_YUV_Texture
        (Value    : in System.Address;
         Area     : in System.Address;
         Y_Pixels : in System.Address;
         Y_Pitch  : in SDL.Video.Pixels.Pitches;
         U_Pixels : in System.Address;
         U_Pitch  : in SDL.Video.Pixels.Pitches;
         V_Pixels : in System.Address;
         V_Pitch  : in SDL.Video.Pixels.Pitches) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_UpdateYUVTexture";

      Raw_Area : aliased constant SDL.Video.Rectangles.Rectangle := Area;
   begin
      Require_Texture (Self);

      if not Boolean
          (SDL_Update_YUV_Texture
             (Self.Internal,
              Raw_Area'Address,
              Y_Pixels,
              Y_Pitch,
              U_Pixels,
              U_Pitch,
              V_Pixels,
              V_Pitch))
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
      function SDL_Update_NV_Texture
        (Value     : in System.Address;
         Area      : in System.Address;
         Y_Pixels  : in System.Address;
         Y_Pitch   : in SDL.Video.Pixels.Pitches;
         UV_Pixels : in System.Address;
         UV_Pitch  : in SDL.Video.Pixels.Pitches) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_UpdateNVTexture";

      Raw_Area : aliased constant SDL.Video.Rectangles.Rectangle := Area;
   begin
      Require_Texture (Self);

      if not Boolean
          (SDL_Update_NV_Texture
             (Self.Internal,
              Raw_Area'Address,
              Y_Pixels,
              Y_Pitch,
              UV_Pixels,
              UV_Pitch))
      then
         Raise_Texture_Error;
      end if;
   end Update_NV;

   procedure Set_Palette
     (Self    : in out Texture;
      Palette : in SDL.Video.Palettes.Palette)
   is
      function SDL_Set_Texture_Palette
        (Value   : in System.Address;
         Palette : in System.Address) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_SetTexturePalette";
   begin
      Require_Texture (Self);

      if not Boolean
          (SDL_Set_Texture_Palette
             (Self.Internal, SDL.Video.Palettes.Get_Internal (Palette)))
      then
         Raise_Texture_Error;
      end if;
   end Set_Palette;

   function Get_Palette
     (Self : in Texture) return SDL.Video.Palettes.Palette
   is
      function SDL_Get_Texture_Palette
        (Value : in System.Address) return System.Address
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetTexturePalette";

      Internal : System.Address;
   begin
      Require_Texture (Self);

      Internal := SDL_Get_Texture_Palette (Self.Internal);
      return Result : SDL.Video.Palettes.Palette do
         Palette_Internal.Copy_From_Pointer (Internal, Result);
      end return;
   end Get_Palette;

   procedure Set_Scale_Mode
     (Self : in out Texture;
      Mode : in Scale_Modes)
   is
      function SDL_Set_Texture_Scale_Mode
        (Value : in System.Address;
         Scale : in Scale_Modes) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_SetTextureScaleMode";
   begin
      Require_Texture (Self);

      if not Boolean (SDL_Set_Texture_Scale_Mode (Self.Internal, Mode)) then
         Raise_Texture_Error;
      end if;
   end Set_Scale_Mode;

   function Get_Scale_Mode (Self : in Texture) return Scale_Modes is
      function SDL_Get_Texture_Scale_Mode
        (Value : in System.Address;
         Scale : access Scale_Modes) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetTextureScaleMode";

      Result : aliased Scale_Modes := Invalid;
   begin
      Require_Texture (Self);

      if not Boolean (SDL_Get_Texture_Scale_Mode (Self.Internal, Result'Access)) then
         Raise_Texture_Error;
      end if;

      return Result;
   end Get_Scale_Mode;

   function Get_Blend_Mode
     (Self : in Texture) return SDL.Video.Blend_Modes
   is
      function SDL_Get_Texture_Blend_Mode
        (Value : in System.Address;
         Mode  : access SDL.Video.Blend_Modes) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetTextureBlendMode";

      Result : aliased SDL.Video.Blend_Modes := SDL.Video.None;
   begin
      Require_Texture (Self);

      if not Boolean (SDL_Get_Texture_Blend_Mode (Self.Internal, Result'Access)) then
         Raise_Texture_Error;
      end if;

      return Result;
   end Get_Blend_Mode;

   procedure Set_Blend_Mode
     (Self : in out Texture;
      Mode : in SDL.Video.Blend_Modes)
   is
      function SDL_Set_Texture_Blend_Mode
        (Value : in System.Address;
         Mode  : in SDL.Video.Blend_Modes) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_SetTextureBlendMode";
   begin
      Require_Texture (Self);

      if not Boolean (SDL_Set_Texture_Blend_Mode (Self.Internal, Mode)) then
         Raise_Texture_Error;
      end if;
   end Set_Blend_Mode;

   function Get_Colour
     (Self : in Texture) return SDL.Video.Palettes.RGB_Colour
   is
      function SDL_Get_Texture_Color_Mod
        (Value : in System.Address;
         Red   : access SDL.Video.Palettes.Colour_Component;
         Green : access SDL.Video.Palettes.Colour_Component;
         Blue  : access SDL.Video.Palettes.Colour_Component) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetTextureColorMod";

      Red   : aliased SDL.Video.Palettes.Colour_Component := 0;
      Green : aliased SDL.Video.Palettes.Colour_Component := 0;
      Blue  : aliased SDL.Video.Palettes.Colour_Component := 0;
   begin
      Require_Texture (Self);

      if not Boolean
          (SDL_Get_Texture_Color_Mod
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
      function SDL_Get_Texture_Color_Mod_Float
        (Value : in System.Address;
         Red   : access Float;
         Green : access Float;
         Blue  : access Float) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetTextureColorModFloat";

      Raw_Red   : aliased Float := 0.0;
      Raw_Green : aliased Float := 0.0;
      Raw_Blue  : aliased Float := 0.0;
   begin
      Require_Texture (Self);

      if not Boolean
          (SDL_Get_Texture_Color_Mod_Float
             (Self.Internal,
              Raw_Red'Access,
              Raw_Green'Access,
              Raw_Blue'Access))
      then
         Raise_Texture_Error;
      end if;

      Red := Raw_Red;
      Green := Raw_Green;
      Blue := Raw_Blue;
   end Get_Colour;

   procedure Set_Colour
     (Self   : in out Texture;
      Colour : in SDL.Video.Palettes.RGB_Colour)
   is
      function SDL_Set_Texture_Color_Mod
        (Value : in System.Address;
         Red   : in SDL.Video.Palettes.Colour_Component;
         Green : in SDL.Video.Palettes.Colour_Component;
         Blue  : in SDL.Video.Palettes.Colour_Component) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_SetTextureColorMod";
   begin
      Require_Texture (Self);

      if not Boolean
          (SDL_Set_Texture_Color_Mod
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
      function SDL_Set_Texture_Color_Mod_Float
        (Value : in System.Address;
         Red   : in Float;
         Green : in Float;
         Blue  : in Float) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_SetTextureColorModFloat";
   begin
      Require_Texture (Self);

      if not Boolean
          (SDL_Set_Texture_Color_Mod_Float (Self.Internal, Red, Green, Blue))
      then
         Raise_Texture_Error;
      end if;
   end Set_Colour;

   function Get_Alpha
     (Self : in Texture) return SDL.Video.Palettes.Colour_Component
   is
      function SDL_Get_Texture_Alpha_Mod
        (Value : in System.Address;
         Alpha : access SDL.Video.Palettes.Colour_Component) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetTextureAlphaMod";

      Result : aliased SDL.Video.Palettes.Colour_Component := 0;
   begin
      Require_Texture (Self);

      if not Boolean
          (SDL_Get_Texture_Alpha_Mod (Self.Internal, Result'Access))
      then
         Raise_Texture_Error;
      end if;

      return Result;
   end Get_Alpha;

   function Get_Alpha_Float (Self : in Texture) return Float is
      function SDL_Get_Texture_Alpha_Mod_Float
        (Value : in System.Address;
         Alpha : access Float) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetTextureAlphaModFloat";

      Result : aliased Float := 0.0;
   begin
      Require_Texture (Self);

      if not Boolean
          (SDL_Get_Texture_Alpha_Mod_Float (Self.Internal, Result'Access))
      then
         Raise_Texture_Error;
      end if;

      return Result;
   end Get_Alpha_Float;

   procedure Set_Alpha
     (Self  : in out Texture;
      Alpha : in SDL.Video.Palettes.Colour_Component)
   is
      function SDL_Set_Texture_Alpha_Mod
        (Value : in System.Address;
         Alpha : in SDL.Video.Palettes.Colour_Component) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_SetTextureAlphaMod";
   begin
      Require_Texture (Self);

      if not Boolean
          (SDL_Set_Texture_Alpha_Mod (Self.Internal, Alpha))
      then
         Raise_Texture_Error;
      end if;
   end Set_Alpha;

   procedure Set_Alpha
     (Self  : in out Texture;
      Alpha : in Float)
   is
      function SDL_Set_Texture_Alpha_Mod_Float
        (Value : in System.Address;
         Alpha : in Float) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_SetTextureAlphaModFloat";
   begin
      Require_Texture (Self);

      if not Boolean
          (SDL_Set_Texture_Alpha_Mod_Float (Self.Internal, Alpha))
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
      function SDL_Get_Texture_Size
        (Value  : in System.Address;
         Width  : access Float;
         Height : access Float) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetTextureSize";

      Raw_Width  : aliased Float := 0.0;
      Raw_Height : aliased Float := 0.0;
   begin
      Require_Texture (Self);

      if not Boolean
          (SDL_Get_Texture_Size
             (Self.Internal, Raw_Width'Access, Raw_Height'Access))
      then
         Raise_Texture_Error;
      end if;

      Width := Raw_Width;
      Height := Raw_Height;
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
      procedure SDL_Destroy_Texture (Value : in System.Address) with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_DestroyTexture";
   begin
      if Self.Owns and then Self.Internal /= System.Null_Address then
         SDL_Destroy_Texture (Self.Internal);
      end if;

      Self.Internal := System.Null_Address;
      Self.Owns := True;
      Self.Locked := False;
      Self.Size := SDL.Zero_Size;
      Self.Pixel_Format := SDL.Video.Pixel_Formats.Pixel_Format_Unknown;
      Self.Kind := Static;
   end Finalize;
end SDL.Video.Textures;
