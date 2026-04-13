with Ada.Unchecked_Conversion;
with Interfaces.C.Extensions;
with System;

with SDL.Error;

package body SDL.Video.Surfaces.Makers is
   package CE renames Interfaces.C.Extensions;

   use type SDL.Video.Pixel_Formats.Pixel_Format_Access;
   use type SDL.Video.Pixel_Formats.Pixel_Format_Names;

   function SDL_Load_Surface
     (Name : in C.char_array) return Internal_Surface_Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_LoadSurface";

   function SDL_Load_Surface_IO
     (Source   : in SDL.RWops.Handle;
      Close_IO : in CE.bool) return Internal_Surface_Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_LoadSurface_IO";

   function SDL_Load_BMP
     (Name : in C.char_array) return Internal_Surface_Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_LoadBMP";

   function SDL_Load_BMP_IO
     (Source   : in SDL.RWops.Handle;
      Close_IO : in CE.bool) return Internal_Surface_Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_LoadBMP_IO";

   function SDL_Load_PNG
     (Name : in C.char_array) return Internal_Surface_Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_LoadPNG";

   function SDL_Load_PNG_IO
     (Source   : in SDL.RWops.Handle;
      Close_IO : in CE.bool) return Internal_Surface_Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_LoadPNG_IO";

   function To_C_Bool (Value : in Boolean) return CE.bool is
     (CE.bool'Val (Boolean'Pos (Value)));

   procedure Adopt
     (Self     : in out Surface;
      Internal : in Internal_Surface_Pointer);

   procedure Adopt
     (Self     : in out Surface;
      Internal : in Internal_Surface_Pointer)
   is
   begin
      if Internal = null then
         raise Surface_Error with SDL.Error.Get;
      end if;

      SDL.Video.Surfaces.Finalize (Self);
      Self.Internal := Internal;
      Self.Owns := True;
   end Adopt;

   function Resolve_Format
     (BPP        : in Pixel_Depths;
      Red_Mask   : in Colour_Masks;
      Green_Mask : in Colour_Masks;
      Blue_Mask  : in Colour_Masks;
      Alpha_Mask : in Colour_Masks)
      return SDL.Video.Pixel_Formats.Pixel_Format_Names
   is
      Format : constant SDL.Video.Pixel_Formats.Pixel_Format_Names :=
        SDL.Video.Pixel_Formats.To_Name
          (Bits       => SDL.Video.Pixel_Formats.Bits_Per_Pixels (BPP),
           Red_Mask   => Interfaces.Unsigned_32 (Red_Mask),
           Green_Mask => Interfaces.Unsigned_32 (Green_Mask),
           Blue_Mask  => Interfaces.Unsigned_32 (Blue_Mask),
           Alpha_Mask => Interfaces.Unsigned_32 (Alpha_Mask));
   begin
      if Format = SDL.Video.Pixel_Formats.Pixel_Format_Unknown then
         raise Surface_Error with "Unsupported surface format masks";
      end if;

      return Format;
   end Resolve_Format;

   procedure Create
     (Self       : in out Surface;
      Size       : in SDL.Sizes;
      BPP        : in Pixel_Depths;
      Red_Mask   : in Colour_Masks;
      Blue_Mask  : in Colour_Masks;
      Green_Mask : in Colour_Masks;
      Alpha_Mask : in Colour_Masks)
   is
      function SDL_Create_Surface
        (Width  : in SDL.Dimension;
         Height : in SDL.Dimension;
         Format : in SDL.Video.Pixel_Formats.Pixel_Format_Names)
         return Internal_Surface_Pointer
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_CreateSurface";

      Internal : constant Internal_Surface_Pointer :=
        SDL_Create_Surface
          (Width  => Size.Width,
           Height => Size.Height,
           Format =>
             Resolve_Format
               (BPP        => BPP,
                Red_Mask   => Red_Mask,
                Green_Mask => Green_Mask,
                Blue_Mask  => Blue_Mask,
                Alpha_Mask => Alpha_Mask));
   begin
      Adopt (Self, Internal);
   end Create;

   procedure Create_From
     (Self       : in out Surface;
      Pixels     : in Element_Pointer;
      Size       : in SDL.Sizes;
      BPP        : in Pixel_Depths := Element'Size;
      Pitch      : in System.Storage_Elements.Storage_Offset;
      Red_Mask   : in Colour_Masks;
      Green_Mask : in Colour_Masks;
      Blue_Mask  : in Colour_Masks;
      Alpha_Mask : in Colour_Masks)
   is
      function To_Address is new Ada.Unchecked_Conversion
        (Element_Pointer, System.Address);

      function SDL_Create_Surface_From
        (Width  : in SDL.Dimension;
         Height : in SDL.Dimension;
         Format : in SDL.Video.Pixel_Formats.Pixel_Format_Names;
         Pixels : in System.Address;
         Pitch  : in C.int) return Internal_Surface_Pointer
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_CreateSurfaceFrom";

      Internal : constant Internal_Surface_Pointer :=
        SDL_Create_Surface_From
          (Width  => Size.Width,
           Height => Size.Height,
           Format =>
             Resolve_Format
               (BPP        => BPP,
                Red_Mask   => Red_Mask,
                Green_Mask => Green_Mask,
                Blue_Mask  => Blue_Mask,
                Alpha_Mask => Alpha_Mask),
           Pixels => To_Address (Pixels),
           Pitch  => C.int (Pitch));
   begin
      Adopt (Self, Internal);
   end Create_From;

   procedure Create_From_Array
     (Self       : in out Surface;
      Pixels     : access Element_Array;
      Red_Mask   : in Colour_Masks;
      Green_Mask : in Colour_Masks;
      Blue_Mask  : in Colour_Masks;
      Alpha_Mask : in Colour_Masks)
   is
      use System.Storage_Elements;

      function SDL_Create_Surface_From
        (Width  : in SDL.Dimension;
         Height : in SDL.Dimension;
         Format : in SDL.Video.Pixel_Formats.Pixel_Format_Names;
         Pixels : in System.Address;
         Pitch  : in C.int) return Internal_Surface_Pointer
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_CreateSurfaceFrom";

      Pitch : constant Storage_Offset :=
        (if Pixels'Length (1) > 1 then
            Pixels (Index'Succ (Pixels'First (1)), Pixels'First (2))'Address
              - Pixels (Pixels'First (1), Pixels'First (2))'Address
         else
            Storage_Offset ((Element'Size / System.Storage_Unit) * Pixels'Length (2)));

      Internal : constant Internal_Surface_Pointer :=
        SDL_Create_Surface_From
          (Width  => SDL.Dimension (Pixels'Length (2)),
           Height => SDL.Dimension (Pixels'Length (1)),
           Format =>
             Resolve_Format
               (BPP        => Element'Size,
                Red_Mask   => Red_Mask,
                Green_Mask => Green_Mask,
                Blue_Mask  => Blue_Mask,
                Alpha_Mask => Alpha_Mask),
           Pixels => Pixels (Pixels'First (1), Pixels'First (2))'Address,
           Pitch  => C.int (Pitch));
   begin
      Adopt (Self, Internal);
   end Create_From_Array;

   procedure Create
     (Self      : in out Surface;
      File_Name : in UTF_Strings.UTF_String)
   is
      Internal : constant Internal_Surface_Pointer :=
        SDL_Load_Surface (C.To_C (String (File_Name)));
   begin
      Adopt (Self, Internal);
   end Create;

   procedure Create
     (Self        : in out Surface;
      Source      : in SDL.RWops.RWops;
      Close_After : in Boolean := False)
   is
      Internal : Internal_Surface_Pointer;
   begin
      if SDL.RWops.Is_Null (Source) then
         raise Surface_Error with "Invalid RWops handle";
      end if;

      Internal :=
        SDL_Load_Surface_IO
          (Source   => SDL.RWops.Get_Handle (Source),
           Close_IO => To_C_Bool (Close_After));

      Adopt (Self, Internal);
   end Create;

   procedure Load_BMP
     (Self      : in out Surface;
      File_Name : in UTF_Strings.UTF_String)
   is
      Internal : constant Internal_Surface_Pointer :=
        SDL_Load_BMP (C.To_C (String (File_Name)));
   begin
      Adopt (Self, Internal);
   end Load_BMP;

   procedure Load_BMP
     (Self        : in out Surface;
      Source      : in SDL.RWops.RWops;
      Close_After : in Boolean := False)
   is
      Internal : Internal_Surface_Pointer;
   begin
      if SDL.RWops.Is_Null (Source) then
         raise Surface_Error with "Invalid RWops handle";
      end if;

      Internal :=
        SDL_Load_BMP_IO
          (Source   => SDL.RWops.Get_Handle (Source),
           Close_IO => To_C_Bool (Close_After));

      Adopt (Self, Internal);
   end Load_BMP;

   procedure Load_PNG
     (Self      : in out Surface;
      File_Name : in UTF_Strings.UTF_String)
   is
      Internal : constant Internal_Surface_Pointer :=
        SDL_Load_PNG (C.To_C (String (File_Name)));
   begin
      Adopt (Self, Internal);
   end Load_PNG;

   procedure Load_PNG
     (Self        : in out Surface;
      Source      : in SDL.RWops.RWops;
      Close_After : in Boolean := False)
   is
      Internal : Internal_Surface_Pointer;
   begin
      if SDL.RWops.Is_Null (Source) then
         raise Surface_Error with "Invalid RWops handle";
      end if;

      Internal :=
        SDL_Load_PNG_IO
          (Source   => SDL.RWops.Get_Handle (Source),
           Close_IO => To_C_Bool (Close_After));

      Adopt (Self, Internal);
   end Load_PNG;

   procedure Convert
     (Self         : in out Surface;
      Src          : SDL.Video.Surfaces.Surface;
      Pixel_Format : SDL.Video.Pixel_Formats.Pixel_Format_Access)
   is
      function SDL_Convert_Surface
        (Source : in Internal_Surface_Pointer;
         Format : in SDL.Video.Pixel_Formats.Pixel_Format_Names)
         return Internal_Surface_Pointer
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_ConvertSurface";

      Internal : Internal_Surface_Pointer;
   begin
      if Pixel_Format = null then
         raise Surface_Error with "Invalid pixel format";
      end if;

      Internal :=
        SDL_Convert_Surface
          (Source => Src.Internal,
           Format => Pixel_Format.Format);

      if Internal = null then
         raise Surface_Error with SDL.Error.Get;
      end if;

      SDL.Video.Surfaces.Finalize (Self);
      Self.Internal := Internal;
      Self.Owns := True;
   end Convert;

   function Get_Internal_Surface
     (Self : in Surface) return Internal_Surface_Pointer is
   begin
      return Self.Internal;
   end Get_Internal_Surface;

   function Make_Surface_From_Pointer
     (S    : in Internal_Surface_Pointer;
      Owns : in Boolean := False) return Surface is
   begin
      return (Ada.Finalization.Controlled with Internal => S, Owns => Owns);
   end Make_Surface_From_Pointer;
end SDL.Video.Surfaces.Makers;
