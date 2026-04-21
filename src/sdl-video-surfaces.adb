with Ada.Unchecked_Conversion;
with Interfaces.C.Extensions;
with System.Storage_Elements;

with SDL.Error;
with SDL.Raw.Pixels;
with SDL.Raw.Surface;
with SDL.Video.Palettes.Internal;
with SDL.Video.Surfaces.Internal;

package body SDL.Video.Surfaces is
   package CE renames Interfaces.C.Extensions;
   package Palette_Internal renames SDL.Video.Palettes.Internal;
   package Raw_Pixels renames SDL.Raw.Pixels;
   package Raw_Properties renames SDL.Raw.Properties;
   package Raw_Surface renames SDL.Raw.Surface;
   package Surface_Internal renames SDL.Video.Surfaces.Internal;

   Default_Scale_Mode : constant Scale_Modes := Linear;

   Surface_User_Data_Property : constant String := "SDL3Ada.surface.user_data";

   type Surface_Address_Access is access all System.Address with Convention => C;

   Address_Stride : constant System.Storage_Elements.Storage_Offset :=
     System.Storage_Elements.Storage_Offset
       (System.Address'Size / System.Storage_Unit);

   use type SDL.Video.Pixel_Formats.Pixel_Format_Access;
   use type Interfaces.Unsigned_32;
   use type Rectangles.Rectangle;
   use type System.Address;
   use type System.Storage_Elements.Storage_Offset;

   function To_Address is new Ada.Unchecked_Conversion
     (Source => Internal_Surface_Pointer,
      Target => System.Address);

   function To_Address is new Ada.Unchecked_Conversion
     (Source => SDL.RWops.Handle,
      Target => System.Address);

   function To_Internal_Surface_Pointer is new Ada.Unchecked_Conversion
     (Source => System.Address,
      Target => Internal_Surface_Pointer);

   function To_Raw_Details is new Ada.Unchecked_Conversion
     (Source => SDL.Video.Pixel_Formats.Pixel_Format_Access,
      Target => Raw_Pixels.Pixel_Format_Details_Access);

   function To_Raw_Palette is new Ada.Unchecked_Conversion
     (Source => System.Address,
      Target => Raw_Pixels.Palette_Access);

   function To_Surface_Address_Access is new Ada.Unchecked_Conversion
     (Source => System.Address,
      Target => Surface_Address_Access);

   function To_Address
     (Value : access constant Rectangles.Rectangle) return System.Address is
       (if Value = null then System.Null_Address else Value.all'Address);

   function To_Address
     (Value : in Rectangles.Rectangle_Arrays) return System.Address is
       (if Value'Length = 0
        then System.Null_Address
        else Value (Value'First)'Address);

   function Surface_List_Item_Address
     (Base  : in System.Address;
      Index : in C.ptrdiff_t) return System.Address is
       (System.Storage_Elements."+"
          (Base,
           Address_Stride *
             System.Storage_Elements.Storage_Offset (Index)));

   function Surface_List_Item
     (Base  : in System.Address;
      Index : in C.ptrdiff_t) return System.Address is
       (To_Surface_Address_Access
          (Surface_List_Item_Address (Base, Index)).all);

   function To_Raw (Value : in Scale_Modes) return Raw_Surface.Scale_Mode is
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

   function To_Raw (Value : in Flip_Modes) return Raw_Surface.Flip_Mode is
   begin
      case Value is
         when No_Flip =>
            return 0;
         when Horizontal_Flip =>
            return 1;
         when Vertical_Flip =>
            return 2;
         when Horizontal_And_Vertical_Flip =>
            return 3;
      end case;
   end To_Raw;

   function To_Raw
     (Value : in SDL.Video.Blend_Modes) return Raw_Surface.Blend_Mode is
       (Raw_Surface.Blend_Mode (Value));

   function To_Raw
     (Value : in SDL.Video.Pixel_Formats.Pixel_Format_Names)
      return Raw_Surface.Pixel_Format_Name is
       (Raw_Surface.Pixel_Format_Name (Value));

   function To_Raw
     (Value : in Colour_Spaces) return Raw_Surface.Colour_Space is
       (Raw_Surface.Colour_Space (Value));

   function To_Public
     (Value : in Raw_Surface.Blend_Mode) return SDL.Video.Blend_Modes is
       (SDL.Video.Blend_Modes (Value));

   function To_Public
     (Value : in Raw_Surface.Colour_Space) return Colour_Spaces is
       (Colour_Spaces (Value));

   function SDL_Get_Surface_Properties
     (Self : in Internal_Surface_Pointer) return Raw_Properties.ID is
       (Raw_Surface.Get_Surface_Properties (To_Address (Self)));

   function SDL_Blit_Surface
     (Source      : in Internal_Surface_Pointer;
      Source_Area : access constant Rectangles.Rectangle;
      Target      : in Internal_Surface_Pointer;
      Target_Area : access constant Rectangles.Rectangle) return CE.bool is
       (Raw_Surface.Blit_Surface
          (To_Address (Source),
           To_Address (Source_Area),
           To_Address (Target),
           To_Address (Target_Area)));

   function SDL_Blit_Surface_Scaled
     (Source      : in Internal_Surface_Pointer;
      Source_Area : access constant Rectangles.Rectangle;
      Target      : in Internal_Surface_Pointer;
      Target_Area : access constant Rectangles.Rectangle;
      Mode        : in Scale_Modes) return CE.bool is
       (Raw_Surface.Blit_Surface_Scaled
          (To_Address (Source),
           To_Address (Source_Area),
           To_Address (Target),
           To_Address (Target_Area),
           To_Raw (Mode)));

   function SDL_Blit_Surface_Unchecked
     (Source      : in Internal_Surface_Pointer;
      Source_Area : access constant Rectangles.Rectangle;
      Target      : in Internal_Surface_Pointer;
      Target_Area : access constant Rectangles.Rectangle) return CE.bool is
       (Raw_Surface.Blit_Surface_Unchecked
          (To_Address (Source),
           To_Address (Source_Area),
           To_Address (Target),
           To_Address (Target_Area)));

   function SDL_Blit_Surface_Unchecked_Scaled
     (Source      : in Internal_Surface_Pointer;
      Source_Area : access constant Rectangles.Rectangle;
      Target      : in Internal_Surface_Pointer;
      Target_Area : access constant Rectangles.Rectangle;
      Mode        : in Scale_Modes) return CE.bool is
       (Raw_Surface.Blit_Surface_Unchecked_Scaled
          (To_Address (Source),
           To_Address (Source_Area),
           To_Address (Target),
           To_Address (Target_Area),
           To_Raw (Mode)));

   function SDL_Fill_Surface_Rect
     (Self   : in Internal_Surface_Pointer;
      Area   : access constant Rectangles.Rectangle;
      Colour : in Interfaces.Unsigned_32) return CE.bool is
       (Raw_Surface.Fill_Surface_Rect
          (To_Address (Self), To_Address (Area), Colour));

   function SDL_Fill_Surface_Rects
     (Self   : in Internal_Surface_Pointer;
      Areas  : in Rectangles.Rectangle_Arrays;
      Count  : in C.int;
      Colour : in Interfaces.Unsigned_32) return CE.bool is
       (Raw_Surface.Fill_Surface_Rects
          (To_Address (Self), To_Address (Areas), Count, Colour));

   function SDL_Get_Surface_Clip_Rect
     (Self : in Internal_Surface_Pointer;
      Area : access Rectangles.Rectangle) return CE.bool is
       (Raw_Surface.Get_Surface_Clip_Rect
          (To_Address (Self), To_Address (Area)));

   function SDL_Set_Surface_Clip_Rect
     (Self : in Internal_Surface_Pointer;
      Area : access constant Rectangles.Rectangle) return CE.bool is
       (Raw_Surface.Set_Surface_Clip_Rect
          (To_Address (Self), To_Address (Area)));

   function SDL_Get_Surface_Palette
     (Self : in Internal_Surface_Pointer) return System.Address is
       (Raw_Surface.Get_Surface_Palette (To_Address (Self)));

   function SDL_Surface_Has_Color_Key
     (Self : in Internal_Surface_Pointer) return CE.bool is
       (Raw_Surface.Surface_Has_Color_Key (To_Address (Self)));

   function SDL_Get_Surface_Color_Key
     (Self : in Internal_Surface_Pointer;
      Key  : access Interfaces.Unsigned_32) return CE.bool is
       (Raw_Surface.Get_Surface_Color_Key (To_Address (Self), Key));

   function SDL_Set_Surface_Color_Key
     (Self   : in Internal_Surface_Pointer;
      Enable : in CE.bool;
      Key    : in Interfaces.Unsigned_32) return CE.bool is
       (Raw_Surface.Set_Surface_Color_Key (To_Address (Self), Enable, Key));

   function SDL_Get_Surface_Alpha_Mod
     (Self  : in Internal_Surface_Pointer;
      Alpha : access Palettes.Colour_Component) return CE.bool is
       (Raw_Surface.Get_Surface_Alpha_Mod (To_Address (Self), Alpha));

   function SDL_Set_Surface_Alpha_Mod
     (Self  : in Internal_Surface_Pointer;
      Alpha : in Palettes.Colour_Component) return CE.bool is
       (Raw_Surface.Set_Surface_Alpha_Mod (To_Address (Self), Alpha));

   function SDL_Get_Surface_Blend_Mode
     (Self : in Internal_Surface_Pointer;
      Mode : access SDL.Video.Blend_Modes) return CE.bool
   is
      Raw_Mode : aliased Raw_Surface.Blend_Mode := To_Raw (SDL.Video.None);
      Success  : constant CE.bool :=
        Raw_Surface.Get_Surface_Blend_Mode (To_Address (Self), Raw_Mode'Access);
   begin
      if Boolean (Success) then
         Mode.all := To_Public (Raw_Mode);
      end if;

      return Success;
   end SDL_Get_Surface_Blend_Mode;

   function SDL_Set_Surface_Blend_Mode
     (Self : in Internal_Surface_Pointer;
      Mode : in SDL.Video.Blend_Modes) return CE.bool is
       (Raw_Surface.Set_Surface_Blend_Mode
          (To_Address (Self), To_Raw (Mode)));

   function SDL_Get_Surface_Color_Mod
     (Self  : in Internal_Surface_Pointer;
      Red   : access Palettes.Colour_Component;
      Green : access Palettes.Colour_Component;
      Blue  : access Palettes.Colour_Component) return CE.bool is
       (Raw_Surface.Get_Surface_Color_Mod (To_Address (Self), Red, Green, Blue));

   function SDL_Set_Surface_Color_Mod
     (Self  : in Internal_Surface_Pointer;
      Red   : in Palettes.Colour_Component;
      Green : in Palettes.Colour_Component;
      Blue  : in Palettes.Colour_Component) return CE.bool is
       (Raw_Surface.Set_Surface_Color_Mod (To_Address (Self), Red, Green, Blue));

   function SDL_Lock_Surface
     (Self : in Internal_Surface_Pointer) return CE.bool is
       (Raw_Surface.Lock_Surface (To_Address (Self)));

   procedure SDL_Unlock_Surface
     (Self : in Internal_Surface_Pointer) is
   begin
      Raw_Surface.Unlock_Surface (To_Address (Self));
   end SDL_Unlock_Surface;

   function SDL_Set_Surface_RLE
     (Self    : in Internal_Surface_Pointer;
      Enabled : in CE.bool) return CE.bool is
       (Raw_Surface.Set_Surface_RLE (To_Address (Self), Enabled));

   procedure SDL_Destroy_Surface
     (Self : in Internal_Surface_Pointer) is
   begin
      Raw_Surface.Destroy_Surface (To_Address (Self));
   end SDL_Destroy_Surface;

   procedure SDL_Free
     (Value : in System.Address) is
   begin
      Raw_Surface.Free (Value);
   end SDL_Free;

   procedure SDL_Get_RGBA
     (Pixel   : in Interfaces.Unsigned_32;
      Format  : in SDL.Video.Pixel_Formats.Pixel_Format_Access;
      Palette : in System.Address;
      Red     : out Palettes.Colour_Component;
      Green   : out Palettes.Colour_Component;
      Blue    : out Palettes.Colour_Component;
      Alpha   : out Palettes.Colour_Component)
   is
      Raw_Red   : Raw_Pixels.Colour_Component;
      Raw_Green : Raw_Pixels.Colour_Component;
      Raw_Blue  : Raw_Pixels.Colour_Component;
      Raw_Alpha : Raw_Pixels.Colour_Component;
   begin
      Raw_Pixels.Get_RGBA
        (Pixel   => Pixel,
         Format  => To_Raw_Details (Format),
         Palette => To_Raw_Palette (Palette),
         Red     => Raw_Red,
         Green   => Raw_Green,
         Blue    => Raw_Blue,
         Alpha   => Raw_Alpha);

      Red := Raw_Red;
      Green := Raw_Green;
      Blue := Raw_Blue;
      Alpha := Raw_Alpha;
   end SDL_Get_RGBA;

   function SDL_Save_BMP
     (Self : in Internal_Surface_Pointer;
      File : in C.char_array) return CE.bool is
       (Raw_Surface.Save_BMP (To_Address (Self), File));

   function SDL_Save_BMP_IO
     (Self     : in Internal_Surface_Pointer;
      Dest     : in SDL.RWops.Handle;
      Close_IO : in CE.bool) return CE.bool is
       (Raw_Surface.Save_BMP_IO
          (To_Address (Self), To_Address (Dest), Close_IO));

   function SDL_Save_PNG
     (Self : in Internal_Surface_Pointer;
      File : in C.char_array) return CE.bool is
       (Raw_Surface.Save_PNG (To_Address (Self), File));

   function SDL_Save_PNG_IO
     (Self     : in Internal_Surface_Pointer;
      Dest     : in SDL.RWops.Handle;
      Close_IO : in CE.bool) return CE.bool is
       (Raw_Surface.Save_PNG_IO
          (To_Address (Self), To_Address (Dest), Close_IO));

   function SDL_Set_Surface_Colourspace
     (Self         : in Internal_Surface_Pointer;
      Colour_Space : in Colour_Spaces) return CE.bool is
       (Raw_Surface.Set_Surface_Colourspace
          (To_Address (Self), To_Raw (Colour_Space)));

   function SDL_Create_Surface_Palette
     (Self : in Internal_Surface_Pointer) return System.Address is
       (Raw_Surface.Create_Surface_Palette (To_Address (Self)));

   function SDL_Set_Surface_Palette
     (Self    : in Internal_Surface_Pointer;
      Palette : in System.Address) return CE.bool is
       (Raw_Surface.Set_Surface_Palette (To_Address (Self), Palette));

   function SDL_Add_Surface_Alternate_Image
     (Self  : in Internal_Surface_Pointer;
      Image : in Internal_Surface_Pointer) return CE.bool is
       (Raw_Surface.Add_Surface_Alternate_Image
          (To_Address (Self), To_Address (Image)));

   function SDL_Surface_Has_Alternate_Images
     (Self : in Internal_Surface_Pointer) return CE.bool is
       (Raw_Surface.Surface_Has_Alternate_Images (To_Address (Self)));

   function SDL_Get_Surface_Images
     (Self  : in Internal_Surface_Pointer;
      Count : access C.int) return System.Address is
       (Raw_Surface.Get_Surface_Images (To_Address (Self), Count));

   procedure SDL_Remove_Surface_Alternate_Images
     (Self : in Internal_Surface_Pointer) is
   begin
      Raw_Surface.Remove_Surface_Alternate_Images (To_Address (Self));
   end SDL_Remove_Surface_Alternate_Images;

   function SDL_Surface_Has_RLE
     (Self : in Internal_Surface_Pointer) return CE.bool is
       (Raw_Surface.Surface_Has_RLE (To_Address (Self)));

   function SDL_Flip_Surface
     (Self : in Internal_Surface_Pointer;
      Mode : in Flip_Modes) return CE.bool is
       (Raw_Surface.Flip_Surface (To_Address (Self), To_Raw (Mode)));

   function SDL_Rotate_Surface
     (Self  : in Internal_Surface_Pointer;
      Angle : in C.C_float) return Internal_Surface_Pointer is
       (To_Internal_Surface_Pointer
          (Raw_Surface.Rotate_Surface (To_Address (Self), Angle)));

   function SDL_Duplicate_Surface
     (Self : in Internal_Surface_Pointer) return Internal_Surface_Pointer is
       (To_Internal_Surface_Pointer
          (Raw_Surface.Duplicate_Surface (To_Address (Self))));

   function SDL_Scale_Surface
     (Self   : in Internal_Surface_Pointer;
      Width  : in C.int;
      Height : in C.int;
      Mode   : in Scale_Modes) return Internal_Surface_Pointer is
       (To_Internal_Surface_Pointer
          (Raw_Surface.Scale_Surface
             (To_Address (Self), Width, Height, To_Raw (Mode))));

   function SDL_Convert_Surface_And_Colourspace
     (Self         : in Internal_Surface_Pointer;
      Pixel_Format : in SDL.Video.Pixel_Formats.Pixel_Format_Names;
      Palette      : in System.Address;
      Colour_Space : in Colour_Spaces;
      Properties   : in Raw_Properties.ID) return Internal_Surface_Pointer is
       (To_Internal_Surface_Pointer
          (Raw_Surface.Convert_Surface_And_Colourspace
             (To_Address (Self),
              To_Raw (Pixel_Format),
              Palette,
              To_Raw (Colour_Space),
              Properties)));

   function SDL_Convert_Pixels
     (Width              : in C.int;
      Height             : in C.int;
      Source_Format      : in SDL.Video.Pixel_Formats.Pixel_Format_Names;
      Source             : in System.Address;
      Source_Pitch       : in C.int;
      Destination_Format : in SDL.Video.Pixel_Formats.Pixel_Format_Names;
      Destination        : in System.Address;
      Destination_Pitch  : in C.int) return CE.bool is
       (Raw_Surface.Convert_Pixels
          (Width,
           Height,
           To_Raw (Source_Format),
           Source,
           Source_Pitch,
           To_Raw (Destination_Format),
           Destination,
           Destination_Pitch));

   function SDL_Convert_Pixels_And_Colourspace
     (Width                    : in C.int;
      Height                   : in C.int;
      Source_Format            : in SDL.Video.Pixel_Formats.Pixel_Format_Names;
      Source_Colour_Space      : in Colour_Spaces;
      Source_Properties        : in Raw_Properties.ID;
      Source                   : in System.Address;
      Source_Pitch             : in C.int;
      Destination_Format       : in SDL.Video.Pixel_Formats.Pixel_Format_Names;
      Destination_Colour_Space : in Colour_Spaces;
      Destination_Properties   : in Raw_Properties.ID;
      Destination              : in System.Address;
      Destination_Pitch        : in C.int) return CE.bool is
       (Raw_Surface.Convert_Pixels_And_Colourspace
          (Width,
           Height,
           To_Raw (Source_Format),
           To_Raw (Source_Colour_Space),
           Source_Properties,
           Source,
           Source_Pitch,
           To_Raw (Destination_Format),
           To_Raw (Destination_Colour_Space),
           Destination_Properties,
           Destination,
           Destination_Pitch));

   function SDL_Premultiply_Alpha
     (Width              : in C.int;
      Height             : in C.int;
      Source_Format      : in SDL.Video.Pixel_Formats.Pixel_Format_Names;
      Source             : in System.Address;
      Source_Pitch       : in C.int;
      Destination_Format : in SDL.Video.Pixel_Formats.Pixel_Format_Names;
      Destination        : in System.Address;
      Destination_Pitch  : in C.int;
      Linear             : in CE.bool) return CE.bool is
       (Raw_Surface.Premultiply_Alpha
          (Width,
           Height,
           To_Raw (Source_Format),
           Source,
           Source_Pitch,
           To_Raw (Destination_Format),
           Destination,
           Destination_Pitch,
           Linear));

   function SDL_Premultiply_Surface_Alpha
     (Self   : in Internal_Surface_Pointer;
      Linear : in CE.bool) return CE.bool is
       (Raw_Surface.Premultiply_Surface_Alpha (To_Address (Self), Linear));

   function SDL_Clear_Surface
     (Self  : in Internal_Surface_Pointer;
      Red   : in C.C_float;
      Green : in C.C_float;
      Blue  : in C.C_float;
      Alpha : in C.C_float) return CE.bool is
       (Raw_Surface.Clear_Surface (To_Address (Self), Red, Green, Blue, Alpha));

   function SDL_Stretch_Surface
     (Source      : in Internal_Surface_Pointer;
      Source_Area : access constant Rectangles.Rectangle;
      Target      : in Internal_Surface_Pointer;
      Target_Area : access constant Rectangles.Rectangle;
      Mode        : in Scale_Modes) return CE.bool is
       (Raw_Surface.Stretch_Surface
          (To_Address (Source),
           To_Address (Source_Area),
           To_Address (Target),
           To_Address (Target_Area),
           To_Raw (Mode)));

   function SDL_Blit_Surface_Tiled
     (Source      : in Internal_Surface_Pointer;
      Source_Area : access constant Rectangles.Rectangle;
      Target      : in Internal_Surface_Pointer;
      Target_Area : access constant Rectangles.Rectangle) return CE.bool is
       (Raw_Surface.Blit_Surface_Tiled
          (To_Address (Source),
           To_Address (Source_Area),
           To_Address (Target),
           To_Address (Target_Area)));

   function SDL_Blit_Surface_Tiled_With_Scale
     (Source      : in Internal_Surface_Pointer;
      Source_Area : access constant Rectangles.Rectangle;
      Scale       : in C.C_float;
      Mode        : in Scale_Modes;
      Target      : in Internal_Surface_Pointer;
      Target_Area : access constant Rectangles.Rectangle) return CE.bool is
       (Raw_Surface.Blit_Surface_Tiled_With_Scale
          (To_Address (Source),
           To_Address (Source_Area),
           Scale,
           To_Raw (Mode),
           To_Address (Target),
           To_Address (Target_Area)));

   function SDL_Blit_Surface_9_Grid
     (Source        : in Internal_Surface_Pointer;
      Source_Area   : access constant Rectangles.Rectangle;
      Left_Width    : in C.int;
      Right_Width   : in C.int;
      Top_Height    : in C.int;
      Bottom_Height : in C.int;
      Scale         : in C.C_float;
      Mode          : in Scale_Modes;
      Target        : in Internal_Surface_Pointer;
      Target_Area   : access constant Rectangles.Rectangle) return CE.bool is
       (Raw_Surface.Blit_Surface_9_Grid
          (To_Address (Source),
           To_Address (Source_Area),
           Left_Width,
           Right_Width,
           Top_Height,
           Bottom_Height,
           Scale,
           To_Raw (Mode),
           To_Address (Target),
           To_Address (Target_Area)));

   function SDL_Map_Surface_RGB
     (Self  : in Internal_Surface_Pointer;
      Red   : in Palettes.Colour_Component;
      Green : in Palettes.Colour_Component;
      Blue  : in Palettes.Colour_Component) return Interfaces.Unsigned_32 is
       (Raw_Surface.Map_Surface_RGB (To_Address (Self), Red, Green, Blue));

   function SDL_Map_Surface_RGBA
     (Self  : in Internal_Surface_Pointer;
      Red   : in Palettes.Colour_Component;
      Green : in Palettes.Colour_Component;
      Blue  : in Palettes.Colour_Component;
      Alpha : in Palettes.Colour_Component) return Interfaces.Unsigned_32 is
       (Raw_Surface.Map_Surface_RGBA
          (To_Address (Self), Red, Green, Blue, Alpha));

   function SDL_Read_Surface_Pixel
     (Self  : in Internal_Surface_Pointer;
      X     : in C.int;
      Y     : in C.int;
      Red   : access Palettes.Colour_Component;
      Green : access Palettes.Colour_Component;
      Blue  : access Palettes.Colour_Component;
      Alpha : access Palettes.Colour_Component) return CE.bool is
       (Raw_Surface.Read_Surface_Pixel
          (To_Address (Self), X, Y, Red, Green, Blue, Alpha));

   function SDL_Read_Surface_Pixel_Float
     (Self  : in Internal_Surface_Pointer;
      X     : in C.int;
      Y     : in C.int;
      Red   : access C.C_float;
      Green : access C.C_float;
      Blue  : access C.C_float;
      Alpha : access C.C_float) return CE.bool is
       (Raw_Surface.Read_Surface_Pixel_Float
          (To_Address (Self), X, Y, Red, Green, Blue, Alpha));

   function SDL_Write_Surface_Pixel
     (Self  : in Internal_Surface_Pointer;
      X     : in C.int;
      Y     : in C.int;
      Red   : in Palettes.Colour_Component;
      Green : in Palettes.Colour_Component;
      Blue  : in Palettes.Colour_Component;
      Alpha : in Palettes.Colour_Component) return CE.bool is
       (Raw_Surface.Write_Surface_Pixel
          (To_Address (Self), X, Y, Red, Green, Blue, Alpha));

   function SDL_Write_Surface_Pixel_Float
     (Self  : in Internal_Surface_Pointer;
      X     : in C.int;
      Y     : in C.int;
      Red   : in C.C_float;
      Green : in C.C_float;
      Blue  : in C.C_float;
      Alpha : in C.C_float) return CE.bool is
       (Raw_Surface.Write_Surface_Pixel_Float
          (To_Address (Self), X, Y, Red, Green, Blue, Alpha));

   function SDL_Get_Surface_Colourspace
     (Self : in Internal_Surface_Pointer) return Colour_Spaces is
       (To_Public (Raw_Surface.Get_Surface_Colourspace (To_Address (Self))));

   function To_C_Bool (Value : in Boolean) return CE.bool is
     (CE.bool'Val (Boolean'Pos (Value)));

   procedure Ensure_Valid (Self : in Surface) is
   begin
      if Self.Internal = null then
         raise Surface_Error with "Invalid surface";
      end if;
   end Ensure_Valid;

   function Surface_Palette (Self : in Surface) return System.Address is
   begin
      Ensure_Valid (Self);
      return SDL_Get_Surface_Palette (Self.Internal);
   end Surface_Palette;

   function Surface_Details
     (Self : in Surface) return SDL.Video.Pixel_Formats.Pixel_Format_Access is
      Details : SDL.Video.Pixel_Formats.Pixel_Format_Access;
   begin
      Ensure_Valid (Self);

      Details := SDL.Video.Pixel_Formats.Get_Details (Self.Internal.Format);

      if Details = null then
         raise Surface_Error with SDL.Error.Get;
      end if;

      return Details;
   end Surface_Details;

   function Map_Colour
     (Self   : in Surface;
      Colour : in Palettes.Colour) return Interfaces.Unsigned_32 is
   begin
      Ensure_Valid (Self);
      return SDL_Map_Surface_RGBA
        (Self.Internal,
         Colour.Red,
         Colour.Green,
         Colour.Blue,
         Colour.Alpha);
   end Map_Colour;

   function Pixel_Format
     (Self : in Surface) return SDL.Video.Pixel_Formats.Pixel_Format_Access is
   begin
      if Self.Internal = null then
         return null;
      end if;

      return SDL.Video.Pixel_Formats.Get_Details (Self.Internal.Format);
   end Pixel_Format;

   function Size (Self : in Surface) return SDL.Sizes is
   begin
      if Self.Internal = null then
         return SDL.Zero_Size;
      end if;

      return (Width => Self.Internal.Width, Height => Self.Internal.Height);
   end Size;

   function Pitch (Self : in Surface) return C.int is
   begin
      if Self.Internal = null then
         return 0;
      end if;

      return Self.Internal.Pitch;
   end Pitch;

   function Pixels (Self : in Surface) return System.Address is
   begin
      Ensure_Valid (Self);

      if Must_Lock (Self) and then (Self.Internal.Flags and Locked) /= Locked then
         raise Surface_Error with "Surface must be locked before pixel access";
      end if;

      return Self.Internal.Pixels;
   end Pixels;

   function Get_Properties
     (Self : in Surface) return Raw_Properties.ID
   is
      Props : Raw_Properties.ID;
   begin
      Ensure_Valid (Self);

      Props := SDL_Get_Surface_Properties (Self.Internal);
      if Props = Raw_Properties.No_Properties then
         declare
            Error_Message : constant String := SDL.Error.Get;
         begin
            if Error_Message /= "" then
               raise Surface_Error with Error_Message;
            end if;

            raise Surface_Error with "SDL_GetSurfaceProperties failed";
         end;
      end if;

      return Props;
   end Get_Properties;

   function Get_Colour_Space (Self : in Surface) return Colour_Spaces is
   begin
      Ensure_Valid (Self);
      return SDL_Get_Surface_Colourspace (Self.Internal);
   end Get_Colour_Space;

   procedure Set_Colour_Space
     (Self : in out Surface;
      Now  : in Colour_Spaces)
   is
   begin
      Ensure_Valid (Self);

      if not Boolean (SDL_Set_Surface_Colourspace (Self.Internal, Now)) then
         raise Surface_Error with SDL.Error.Get;
      end if;
   end Set_Colour_Space;

   function Get_Palette
     (Self : in Surface) return SDL.Video.Palettes.Palette
   is
      Internal : constant System.Address := Surface_Palette (Self);
   begin
      return Result : SDL.Video.Palettes.Palette do
         Palette_Internal.Copy_From_Pointer (Internal, Result);
      end return;
   end Get_Palette;

   procedure Create_Palette (Self : in out Surface) is
      Created : System.Address := System.Null_Address;
   begin
      Ensure_Valid (Self);

      Created := SDL_Create_Surface_Palette (Self.Internal);

      if Created = System.Null_Address then
         raise Surface_Error with SDL.Error.Get;
      end if;
   end Create_Palette;

   procedure Set_Palette
     (Self    : in out Surface;
      Colours : in SDL.Video.Palettes.Palette)
   is
   begin
      Ensure_Valid (Self);

      if not Boolean
          (SDL_Set_Surface_Palette
             (Self.Internal, SDL.Video.Palettes.Get_Internal (Colours)))
      then
         raise Surface_Error with SDL.Error.Get;
      end if;
   end Set_Palette;

   procedure Add_Alternate_Image
     (Self  : in out Surface;
      Image : in Surface)
   is
   begin
      Ensure_Valid (Self);
      Ensure_Valid (Image);

      if not Boolean
          (SDL_Add_Surface_Alternate_Image (Self.Internal, Image.Internal))
      then
         raise Surface_Error with SDL.Error.Get;
      end if;
   end Add_Alternate_Image;

   function Has_Alternate_Images (Self : in Surface) return Boolean is
   begin
      Ensure_Valid (Self);
      return Boolean (SDL_Surface_Has_Alternate_Images (Self.Internal));
   end Has_Alternate_Images;

   function Get_Images (Self : in Surface) return Surface_Lists is
      Count : aliased C.int := 0;
      Raw   : System.Address := System.Null_Address;
   begin
      Ensure_Valid (Self);

      Raw := SDL_Get_Surface_Images (Self.Internal, Count'Access);

      if Count <= 0 then
         if Raw /= System.Null_Address then
            SDL_Free (Raw);
         end if;

         return Result : Surface_Lists (1 .. 0) do
            null;
         end return;
      end if;

      if Raw = System.Null_Address then
         raise Surface_Error with SDL.Error.Get;
      end if;

      return Result : Surface_Lists (0 .. Natural (Count) - 1) do
         for Index in Result'Range loop
            Result (Index) :=
              Surface_Internal.Make_From_Pointer
                (To_Internal_Surface_Pointer
                   (Surface_List_Item
                      (Raw,
                       C.ptrdiff_t (Index - Result'First))),
                 Owns => False);
         end loop;

         SDL_Free (Raw);
      exception
         when others =>
            SDL_Free (Raw);
            raise;
      end return;
   end Get_Images;

   procedure Remove_Alternate_Images (Self : in out Surface) is
   begin
      Ensure_Valid (Self);
      SDL_Remove_Surface_Alternate_Images (Self.Internal);
   end Remove_Alternate_Images;

   function Duplicate (Self : in Surface) return Surface is
      Duplicate_Surface : Internal_Surface_Pointer := null;
   begin
      Ensure_Valid (Self);

      Duplicate_Surface := SDL_Duplicate_Surface (Self.Internal);

      if Duplicate_Surface = null then
         raise Surface_Error with SDL.Error.Get;
      end if;

      return Surface_Internal.Make_From_Pointer
        (Duplicate_Surface, Owns => True);
   end Duplicate;

   function Rotate
     (Self  : in Surface;
      Angle : in Float) return Surface
   is
      Rotated : Internal_Surface_Pointer := null;
   begin
      Ensure_Valid (Self);

      Rotated := SDL_Rotate_Surface (Self.Internal, C.C_float (Angle));

      if Rotated = null then
         raise Surface_Error with SDL.Error.Get;
      end if;

      return Surface_Internal.Make_From_Pointer (Rotated, Owns => True);
   end Rotate;

   function Scale
     (Self : in Surface;
      Size : in SDL.Sizes;
      Mode : in Scale_Modes := Linear) return Surface
   is
      Scaled : Internal_Surface_Pointer := null;
   begin
      Ensure_Valid (Self);

      Scaled :=
        SDL_Scale_Surface
          (Self.Internal,
           C.int (Size.Width),
           C.int (Size.Height),
           Mode);

      if Scaled = null then
         raise Surface_Error with SDL.Error.Get;
      end if;

      return Surface_Internal.Make_From_Pointer (Scaled, Owns => True);
   end Scale;

   function Convert
     (Self         : in Surface;
      Pixel_Format : in SDL.Video.Pixel_Formats.Pixel_Format_Access;
      Palette      : in SDL.Video.Palettes.Palette :=
        SDL.Video.Palettes.Empty_Palette;
      Colour_Space : in Colour_Spaces := Unknown_Colour_Space;
      Properties   : in SDL.Raw.Properties.ID := SDL.Raw.Properties.No_Properties)
      return Surface
   is
      Converted : Internal_Surface_Pointer;
   begin
      Ensure_Valid (Self);

      if Pixel_Format = null then
         raise Surface_Error with "Invalid pixel format";
      end if;

      Converted :=
        SDL_Convert_Surface_And_Colourspace
          (Self.Internal,
           Pixel_Format.Format,
           SDL.Video.Palettes.Get_Internal (Palette),
           Colour_Space,
           Properties);

      if Converted = null then
         raise Surface_Error with SDL.Error.Get;
      end if;

      return Surface_Internal.Make_From_Pointer (Converted, Owns => True);
   end Convert;

   procedure Convert_Pixels
     (Size               : in SDL.Sizes;
      Source_Format      : in SDL.Video.Pixel_Formats.Pixel_Format_Names;
      Source             : in System.Address;
      Source_Pitch       : in C.int;
      Destination_Format : in SDL.Video.Pixel_Formats.Pixel_Format_Names;
      Destination        : in System.Address;
      Destination_Pitch  : in C.int)
   is
   begin
      if not Boolean
          (SDL_Convert_Pixels
             (C.int (Size.Width),
              C.int (Size.Height),
              Source_Format,
              Source,
              Source_Pitch,
              Destination_Format,
              Destination,
              Destination_Pitch))
      then
         raise Surface_Error with SDL.Error.Get;
      end if;
   end Convert_Pixels;

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
      Destination_Pitch       : in C.int)
   is
   begin
      if not Boolean
          (SDL_Convert_Pixels_And_Colourspace
             (C.int (Size.Width),
              C.int (Size.Height),
              Source_Format,
              Source_Colour_Space,
              Source_Properties,
              Source,
              Source_Pitch,
              Destination_Format,
              Destination_Colour_Space,
              Destination_Properties,
              Destination,
              Destination_Pitch))
      then
         raise Surface_Error with SDL.Error.Get;
      end if;
   end Convert_Pixels;

   procedure Premultiply_Alpha
     (Size               : in SDL.Sizes;
      Source_Format      : in SDL.Video.Pixel_Formats.Pixel_Format_Names;
      Source             : in System.Address;
      Source_Pitch       : in C.int;
      Destination_Format : in SDL.Video.Pixel_Formats.Pixel_Format_Names;
      Destination        : in System.Address;
      Destination_Pitch  : in C.int;
      Linear             : in Boolean := False)
   is
   begin
      if not Boolean
          (SDL_Premultiply_Alpha
             (C.int (Size.Width),
              C.int (Size.Height),
              Source_Format,
              Source,
              Source_Pitch,
              Destination_Format,
              Destination,
              Destination_Pitch,
              To_C_Bool (Linear)))
      then
         raise Surface_Error with SDL.Error.Get;
      end if;
   end Premultiply_Alpha;

   procedure Premultiply_Alpha
     (Self   : in out Surface;
      Linear : in Boolean := False)
   is
   begin
      Ensure_Valid (Self);

      if not Boolean
          (SDL_Premultiply_Surface_Alpha (Self.Internal, To_C_Bool (Linear)))
      then
         raise Surface_Error with SDL.Error.Get;
      end if;
   end Premultiply_Alpha;

   procedure Clear
     (Self   : in out Surface;
      Colour : in Float_Colour)
   is
   begin
      Ensure_Valid (Self);

      if not Boolean
          (SDL_Clear_Surface
             (Self.Internal,
              Colour.Red,
              Colour.Green,
              Colour.Blue,
              Colour.Alpha))
      then
         raise Surface_Error with SDL.Error.Get;
      end if;
   end Clear;

   package body Pixel_Data is
      use System.Storage_Elements;

      function Get (Self : in Surface) return Element_Pointer is
         function Convert is new Ada.Unchecked_Conversion
           (System.Address, Element_Pointer);
      begin
         return Convert (Self.Pixels);
      end Get;

      function Get_Row
        (Self : in Surface;
         Y    : in SDL.Coordinate) return Element_Pointer
      is
         function Convert is new Ada.Unchecked_Conversion
           (System.Address, Element_Pointer);
      begin
         return Convert
           (Self.Pixels
            + Storage_Offset (Self.Internal.Pitch) * Storage_Offset (Y));
      end Get_Row;
   end Pixel_Data;

   package body User_Data is
      function To_Address is new Ada.Unchecked_Conversion
        (Data_Pointer, System.Address);
      function To_Data_Pointer is new Ada.Unchecked_Conversion
        (System.Address, Data_Pointer);

      function Get (Self : in Surface) return Data_Pointer is
         Props : constant Raw_Properties.ID :=
           SDL_Get_Surface_Properties (Self.Internal);
      begin
         if Self.Internal = null or else Props = Raw_Properties.No_Properties then
            return null;
         end if;

         return To_Data_Pointer
           (Raw_Properties.Get_Pointer_Property
              (Props,
               C.To_C (Surface_User_Data_Property),
               System.Null_Address));
      end Get;

      procedure Set (Self : in out Surface; Data : in Data_Pointer) is
         Props : constant Raw_Properties.ID :=
           SDL_Get_Surface_Properties (Self.Internal);
      begin
         Ensure_Valid (Self);

         if Props = Raw_Properties.No_Properties then
            raise Surface_Error with SDL.Error.Get;
         end if;

         if not Boolean
             (Raw_Properties.Set_Pointer_Property
                (Props,
                 C.To_C (Surface_User_Data_Property),
                 To_Address (Data)))
         then
            raise Surface_Error with SDL.Error.Get;
         end if;
      end Set;
   end User_Data;

   procedure Blit
     (Self   : in out Surface;
      Source : in Surface)
   is
   begin
      Ensure_Valid (Self);
      Ensure_Valid (Source);

      if not Boolean
          (SDL_Blit_Surface (Source.Internal, null, Self.Internal, null))
      then
         raise Surface_Error with SDL.Error.Get;
      end if;
   end Blit;

   procedure Blit
     (Self        : in out Surface;
      Self_Area   : in out Rectangles.Rectangle;
      Source      : in Surface;
      Source_Area : in out Rectangles.Rectangle)
   is
      Target_Area : aliased Rectangles.Rectangle := Self_Area;
      Input_Area  : aliased Rectangles.Rectangle := Source_Area;
      Source_Ptr  : access constant Rectangles.Rectangle := null;
      Target_Ptr  : access constant Rectangles.Rectangle := null;
   begin
      Ensure_Valid (Self);
      Ensure_Valid (Source);

      if Source_Area /= Rectangles.Null_Rectangle then
         Source_Ptr := Input_Area'Access;
      end if;

      if Self_Area /= Rectangles.Null_Rectangle then
         Target_Ptr := Target_Area'Access;
      end if;

      if not Boolean
          (SDL_Blit_Surface
             (Source.Internal, Source_Ptr, Self.Internal, Target_Ptr))
      then
         raise Surface_Error with SDL.Error.Get;
      end if;
   end Blit;

   procedure Blit_Scaled
     (Self   : in out Surface;
      Source : in Surface)
   is
   begin
      Ensure_Valid (Self);
      Ensure_Valid (Source);

      if not Boolean
          (SDL_Blit_Surface_Scaled
             (Source.Internal,
              null,
              Self.Internal,
              null,
              Default_Scale_Mode))
      then
         raise Surface_Error with SDL.Error.Get;
      end if;
   end Blit_Scaled;

   procedure Blit_Scaled
     (Self        : in out Surface;
      Self_Area   : in out Rectangles.Rectangle;
      Source      : in Surface;
      Source_Area : in Rectangles.Rectangle := Rectangles.Null_Rectangle)
   is
      Target_Area : aliased Rectangles.Rectangle := Self_Area;
      Input_Area  : aliased Rectangles.Rectangle := Source_Area;
      Source_Ptr  : access constant Rectangles.Rectangle := null;
      Target_Ptr  : access constant Rectangles.Rectangle := null;
   begin
      Ensure_Valid (Self);
      Ensure_Valid (Source);

      if Source_Area /= Rectangles.Null_Rectangle then
         Source_Ptr := Input_Area'Access;
      end if;

      if Self_Area /= Rectangles.Null_Rectangle then
         Target_Ptr := Target_Area'Access;
      end if;

      if not Boolean
          (SDL_Blit_Surface_Scaled
             (Source.Internal,
              Source_Ptr,
              Self.Internal,
              Target_Ptr,
              Default_Scale_Mode))
      then
         raise Surface_Error with SDL.Error.Get;
      end if;
   end Blit_Scaled;

   procedure Lower_Blit
     (Self        : in out Surface;
      Self_Area   : in Rectangles.Rectangle;
      Source      : in Surface;
      Source_Area : in Rectangles.Rectangle)
   is
      Target_Area : aliased Rectangles.Rectangle := Self_Area;
      Input_Area  : aliased Rectangles.Rectangle := Source_Area;
   begin
      Ensure_Valid (Self);
      Ensure_Valid (Source);

      if not Boolean
          (SDL_Blit_Surface_Unchecked
             (Source.Internal,
              Input_Area'Access,
              Self.Internal,
              Target_Area'Access))
      then
         raise Surface_Error with SDL.Error.Get;
      end if;
   end Lower_Blit;

   procedure Lower_Blit_Scaled
     (Self        : in out Surface;
      Self_Area   : in Rectangles.Rectangle;
      Source      : in Surface;
      Source_Area : in Rectangles.Rectangle)
   is
      Target_Area : aliased Rectangles.Rectangle := Self_Area;
      Input_Area  : aliased Rectangles.Rectangle := Source_Area;
   begin
      Ensure_Valid (Self);
      Ensure_Valid (Source);

      if not Boolean
          (SDL_Blit_Surface_Unchecked_Scaled
             (Source.Internal,
              Input_Area'Access,
              Self.Internal,
              Target_Area'Access,
              Default_Scale_Mode))
      then
         raise Surface_Error with SDL.Error.Get;
      end if;
   end Lower_Blit_Scaled;

   procedure Fill
     (Self   : in out Surface;
      Colour : in Interfaces.Unsigned_32)
   is
   begin
      Ensure_Valid (Self);

      if not Boolean
          (SDL_Fill_Surface_Rect (Self.Internal, null, Colour))
      then
         raise Surface_Error with SDL.Error.Get;
      end if;
   end Fill;

   procedure Fill
     (Self   : in out Surface;
      Area   : in Rectangles.Rectangle;
      Colour : in Interfaces.Unsigned_32)
   is
      Target_Area : aliased Rectangles.Rectangle := Area;
   begin
      Ensure_Valid (Self);

      if not Boolean
          (SDL_Fill_Surface_Rect (Self.Internal, Target_Area'Access, Colour))
      then
         raise Surface_Error with SDL.Error.Get;
      end if;
   end Fill;

   procedure Fill
     (Self   : in out Surface;
      Areas  : in Rectangles.Rectangle_Arrays;
      Colour : in Interfaces.Unsigned_32)
   is
   begin
      Ensure_Valid (Self);

      if not Boolean
          (SDL_Fill_Surface_Rects
             (Self.Internal, Areas, C.int (Areas'Length), Colour))
      then
         raise Surface_Error with SDL.Error.Get;
      end if;
   end Fill;

   procedure Stretch
     (Self   : in out Surface;
      Source : in Surface;
      Mode   : in Scale_Modes := Linear)
   is
   begin
      Ensure_Valid (Self);
      Ensure_Valid (Source);

      if not Boolean
          (SDL_Stretch_Surface
             (Source.Internal, null, Self.Internal, null, Mode))
      then
         raise Surface_Error with SDL.Error.Get;
      end if;
   end Stretch;

   procedure Stretch
     (Self        : in out Surface;
      Self_Area   : in Rectangles.Rectangle;
      Source      : in Surface;
      Source_Area : in Rectangles.Rectangle;
      Mode        : in Scale_Modes := Linear)
   is
      Target_Area : aliased Rectangles.Rectangle := Self_Area;
      Input_Area  : aliased Rectangles.Rectangle := Source_Area;
   begin
      Ensure_Valid (Self);
      Ensure_Valid (Source);

      if not Boolean
          (SDL_Stretch_Surface
             (Source.Internal,
              Input_Area'Access,
              Self.Internal,
              Target_Area'Access,
              Mode))
      then
         raise Surface_Error with SDL.Error.Get;
      end if;
   end Stretch;

   procedure Blit_Tiled
     (Self   : in out Surface;
      Source : in Surface)
   is
   begin
      Ensure_Valid (Self);
      Ensure_Valid (Source);

      if not Boolean
          (SDL_Blit_Surface_Tiled (Source.Internal, null, Self.Internal, null))
      then
         raise Surface_Error with SDL.Error.Get;
      end if;
   end Blit_Tiled;

   procedure Blit_Tiled
     (Self        : in out Surface;
      Self_Area   : in Rectangles.Rectangle;
      Source      : in Surface;
      Source_Area : in Rectangles.Rectangle)
   is
      Target_Area : aliased Rectangles.Rectangle := Self_Area;
      Input_Area  : aliased Rectangles.Rectangle := Source_Area;
   begin
      Ensure_Valid (Self);
      Ensure_Valid (Source);

      if not Boolean
          (SDL_Blit_Surface_Tiled
             (Source.Internal,
              Input_Area'Access,
              Self.Internal,
              Target_Area'Access))
      then
         raise Surface_Error with SDL.Error.Get;
      end if;
   end Blit_Tiled;

   procedure Blit_Tiled_With_Scale
     (Self   : in out Surface;
      Source : in Surface;
      Scale  : in Float;
      Mode   : in Scale_Modes := Linear)
   is
   begin
      Ensure_Valid (Self);
      Ensure_Valid (Source);

      if not Boolean
          (SDL_Blit_Surface_Tiled_With_Scale
             (Source.Internal,
              null,
              C.C_float (Scale),
              Mode,
              Self.Internal,
              null))
      then
         raise Surface_Error with SDL.Error.Get;
      end if;
   end Blit_Tiled_With_Scale;

   procedure Blit_Tiled_With_Scale
     (Self        : in out Surface;
      Self_Area   : in Rectangles.Rectangle;
      Source      : in Surface;
      Source_Area : in Rectangles.Rectangle;
      Scale       : in Float;
      Mode        : in Scale_Modes := Linear)
   is
      Target_Area : aliased Rectangles.Rectangle := Self_Area;
      Input_Area  : aliased Rectangles.Rectangle := Source_Area;
   begin
      Ensure_Valid (Self);
      Ensure_Valid (Source);

      if not Boolean
          (SDL_Blit_Surface_Tiled_With_Scale
             (Source.Internal,
              Input_Area'Access,
              C.C_float (Scale),
              Mode,
              Self.Internal,
              Target_Area'Access))
      then
         raise Surface_Error with SDL.Error.Get;
      end if;
   end Blit_Tiled_With_Scale;

   procedure Blit_9_Grid
     (Self          : in out Surface;
      Source        : in Surface;
      Left_Width    : in SDL.Dimension;
      Right_Width   : in SDL.Dimension;
      Top_Height    : in SDL.Dimension;
      Bottom_Height : in SDL.Dimension;
      Scale         : in Float := 0.0;
      Mode          : in Scale_Modes := Linear)
   is
   begin
      Ensure_Valid (Self);
      Ensure_Valid (Source);

      if not Boolean
          (SDL_Blit_Surface_9_Grid
             (Source.Internal,
              null,
              C.int (Left_Width),
              C.int (Right_Width),
              C.int (Top_Height),
              C.int (Bottom_Height),
              C.C_float (Scale),
              Mode,
              Self.Internal,
              null))
      then
         raise Surface_Error with SDL.Error.Get;
      end if;
   end Blit_9_Grid;

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
      Mode          : in Scale_Modes := Linear)
   is
      Target_Area : aliased Rectangles.Rectangle := Self_Area;
      Input_Area  : aliased Rectangles.Rectangle := Source_Area;
   begin
      Ensure_Valid (Self);
      Ensure_Valid (Source);

      if not Boolean
          (SDL_Blit_Surface_9_Grid
             (Source.Internal,
              Input_Area'Access,
              C.int (Left_Width),
              C.int (Right_Width),
              C.int (Top_Height),
              C.int (Bottom_Height),
              C.C_float (Scale),
              Mode,
              Self.Internal,
              Target_Area'Access))
      then
         raise Surface_Error with SDL.Error.Get;
      end if;
   end Blit_9_Grid;

   function Clip_Rectangle
     (Self : in Surface) return Rectangles.Rectangle
   is
      Area : aliased Rectangles.Rectangle := Rectangles.Null_Rectangle;
   begin
      Ensure_Valid (Self);

      if not Boolean (SDL_Get_Surface_Clip_Rect (Self.Internal, Area'Access)) then
         raise Surface_Error with SDL.Error.Get;
      end if;

      return Area;
   end Clip_Rectangle;

   procedure Set_Clip_Rectangle
     (Self : in out Surface;
      Now  : in Rectangles.Rectangle)
   is
      Area : aliased Rectangles.Rectangle := Now;
      Ptr  : access constant Rectangles.Rectangle := Area'Access;
   begin
      Ensure_Valid (Self);

      if Now = Rectangles.Null_Rectangle then
         Ptr := null;
      end if;

      if not Boolean (SDL_Set_Surface_Clip_Rect (Self.Internal, Ptr)) then
         raise Surface_Error with SDL.Error.Get;
      end if;
   end Set_Clip_Rectangle;

   function Colour_Key
     (Self : in Surface) return Palettes.Colour
   is
      Key    : aliased Interfaces.Unsigned_32 := 0;
      Colour : Palettes.Colour;
   begin
      Ensure_Valid (Self);

      if not Boolean (SDL_Surface_Has_Color_Key (Self.Internal)) then
         raise Surface_Error with "No colour key set for this surface";
      end if;

      if not Boolean (SDL_Get_Surface_Color_Key (Self.Internal, Key'Access)) then
         raise Surface_Error with SDL.Error.Get;
      end if;

      SDL_Get_RGBA
        (Pixel   => Key,
         Format  => Surface_Details (Self),
         Palette => Surface_Palette (Self),
         Red     => Colour.Red,
         Green   => Colour.Green,
         Blue    => Colour.Blue,
         Alpha   => Colour.Alpha);

      return Colour;
   end Colour_Key;

   procedure Set_Colour_Key
     (Self   : in out Surface;
      Now    : in Palettes.Colour;
      Enable : in Boolean := True)
   is
   begin
      Ensure_Valid (Self);

      if not Boolean
          (SDL_Set_Surface_Color_Key
             (Self.Internal,
              CE.bool'Val (if Enable then 1 else 0),
              Map_Colour (Self, Now)))
      then
         raise Surface_Error with SDL.Error.Get;
      end if;
   end Set_Colour_Key;

   function Alpha_Blend
     (Self : in Surface) return Palettes.Colour_Component
   is
      Alpha : aliased Palettes.Colour_Component := 0;
   begin
      Ensure_Valid (Self);

      if not Boolean (SDL_Get_Surface_Alpha_Mod (Self.Internal, Alpha'Access)) then
         raise Surface_Error with SDL.Error.Get;
      end if;

      return Alpha;
   end Alpha_Blend;

   procedure Set_Alpha_Blend
     (Self : in out Surface;
      Now  : in Palettes.Colour_Component)
   is
   begin
      Ensure_Valid (Self);

      if not Boolean (SDL_Set_Surface_Alpha_Mod (Self.Internal, Now)) then
         raise Surface_Error with SDL.Error.Get;
      end if;
   end Set_Alpha_Blend;

   function Blend_Mode (Self : in Surface) return SDL.Video.Blend_Modes is
      Mode : aliased SDL.Video.Blend_Modes := SDL.Video.None;
   begin
      Ensure_Valid (Self);

      if not Boolean (SDL_Get_Surface_Blend_Mode (Self.Internal, Mode'Access)) then
         raise Surface_Error with SDL.Error.Get;
      end if;

      return Mode;
   end Blend_Mode;

   procedure Set_Blend_Mode
     (Self : in out Surface;
      Now  : in SDL.Video.Blend_Modes)
   is
   begin
      Ensure_Valid (Self);

      if not Boolean (SDL_Set_Surface_Blend_Mode (Self.Internal, Now)) then
         raise Surface_Error with SDL.Error.Get;
      end if;
   end Set_Blend_Mode;

   function Colour (Self : in Surface) return Palettes.RGB_Colour is
      Red   : aliased Palettes.Colour_Component := 0;
      Green : aliased Palettes.Colour_Component := 0;
      Blue  : aliased Palettes.Colour_Component := 0;
   begin
      Ensure_Valid (Self);

      if not Boolean
          (SDL_Get_Surface_Color_Mod
             (Self.Internal, Red'Access, Green'Access, Blue'Access))
      then
         raise Surface_Error with SDL.Error.Get;
      end if;

      return (Red => Red, Green => Green, Blue => Blue);
   end Colour;

   procedure Set_Colour
     (Self : in out Surface;
      Now  : in Palettes.RGB_Colour)
   is
   begin
      Ensure_Valid (Self);

      if not Boolean
          (SDL_Set_Surface_Color_Mod
             (Self.Internal, Now.Red, Now.Green, Now.Blue))
      then
         raise Surface_Error with SDL.Error.Get;
      end if;
   end Set_Colour;

   function Map_Colour
     (Self   : in Surface;
      Colour : in Palettes.RGB_Colour) return Interfaces.Unsigned_32
   is
   begin
      Ensure_Valid (Self);
      return SDL_Map_Surface_RGB
        (Self.Internal,
         Colour.Red,
         Colour.Green,
         Colour.Blue);
   end Map_Colour;

   function Read_Pixel
     (Self : in Surface;
      X    : in SDL.Coordinate;
      Y    : in SDL.Coordinate) return Palettes.Colour
   is
      Red   : aliased Palettes.Colour_Component := 0;
      Green : aliased Palettes.Colour_Component := 0;
      Blue  : aliased Palettes.Colour_Component := 0;
      Alpha : aliased Palettes.Colour_Component := 0;
   begin
      Ensure_Valid (Self);

      if not Boolean
          (SDL_Read_Surface_Pixel
             (Self.Internal,
              C.int (X),
              C.int (Y),
              Red'Access,
              Green'Access,
              Blue'Access,
              Alpha'Access))
      then
         raise Surface_Error with SDL.Error.Get;
      end if;

      return (Red => Red, Green => Green, Blue => Blue, Alpha => Alpha);
   end Read_Pixel;

   function Read_Pixel_Float
     (Self : in Surface;
      X    : in SDL.Coordinate;
      Y    : in SDL.Coordinate) return Float_Colour
   is
      Red   : aliased C.C_float := 0.0;
      Green : aliased C.C_float := 0.0;
      Blue  : aliased C.C_float := 0.0;
      Alpha : aliased C.C_float := 0.0;
   begin
      Ensure_Valid (Self);

      if not Boolean
          (SDL_Read_Surface_Pixel_Float
             (Self.Internal,
              C.int (X),
              C.int (Y),
              Red'Access,
              Green'Access,
              Blue'Access,
              Alpha'Access))
      then
         raise Surface_Error with SDL.Error.Get;
      end if;

      return (Red => Red, Green => Green, Blue => Blue, Alpha => Alpha);
   end Read_Pixel_Float;

   procedure Write_Pixel
     (Self   : in out Surface;
      X      : in SDL.Coordinate;
      Y      : in SDL.Coordinate;
      Colour : in Palettes.Colour)
   is
   begin
      Ensure_Valid (Self);

      if not Boolean
          (SDL_Write_Surface_Pixel
             (Self.Internal,
              C.int (X),
              C.int (Y),
              Colour.Red,
              Colour.Green,
              Colour.Blue,
              Colour.Alpha))
      then
         raise Surface_Error with SDL.Error.Get;
      end if;
   end Write_Pixel;

   procedure Write_Pixel_Float
     (Self   : in out Surface;
      X      : in SDL.Coordinate;
      Y      : in SDL.Coordinate;
      Colour : in Float_Colour)
   is
   begin
      Ensure_Valid (Self);

      if not Boolean
          (SDL_Write_Surface_Pixel_Float
             (Self.Internal,
              C.int (X),
              C.int (Y),
              Colour.Red,
              Colour.Green,
              Colour.Blue,
              Colour.Alpha))
      then
         raise Surface_Error with SDL.Error.Get;
      end if;
   end Write_Pixel_Float;

   procedure Lock (Self : in out Surface) is
   begin
      Ensure_Valid (Self);

      if not Boolean (SDL_Lock_Surface (Self.Internal)) then
         raise Surface_Error with SDL.Error.Get;
      end if;
   end Lock;

   procedure Unlock (Self : in out Surface) is
   begin
      if Self.Internal /= null then
         SDL_Unlock_Surface (Self.Internal);
      end if;
   end Unlock;

   function Must_Lock (Self : in Surface) return Boolean is
   begin
      return Self.Internal /= null
        and then (Self.Internal.Flags and Lock_Needed) = Lock_Needed;
   end Must_Lock;

   function Has_RLE (Self : in Surface) return Boolean is
   begin
      Ensure_Valid (Self);
      return Boolean (SDL_Surface_Has_RLE (Self.Internal));
   end Has_RLE;

   procedure Set_RLE
     (Self    : in out Surface;
     Enabled : in Boolean)
   is
   begin
      Ensure_Valid (Self);

      if not Boolean
          (SDL_Set_Surface_RLE
             (Self.Internal, CE.bool'Val (if Enabled then 1 else 0)))
      then
         raise Surface_Error with SDL.Error.Get;
      end if;
   end Set_RLE;

   procedure Flip
     (Self : in out Surface;
      Mode : in Flip_Modes)
   is
   begin
      Ensure_Valid (Self);

      if not Boolean (SDL_Flip_Surface (Self.Internal, Mode)) then
         raise Surface_Error with SDL.Error.Get;
      end if;
   end Flip;

   procedure Save_BMP
     (Self      : in Surface;
      File_Name : in UTF_Strings.UTF_String)
   is
   begin
      Ensure_Valid (Self);

      if not Boolean
          (SDL_Save_BMP (Self.Internal, C.To_C (String (File_Name))))
      then
         raise Surface_Error with SDL.Error.Get;
      end if;
   end Save_BMP;

   procedure Save_BMP
     (Self        : in Surface;
      Destination : in SDL.RWops.RWops;
      Close_After : in Boolean := False)
   is
   begin
      Ensure_Valid (Self);

      if SDL.RWops.Is_Null (Destination) then
         raise Surface_Error with "Invalid RWops handle";
      end if;

      if not Boolean
          (SDL_Save_BMP_IO
             (Self.Internal,
              SDL.RWops.Get_Handle (Destination),
              To_C_Bool (Close_After)))
      then
         raise Surface_Error with SDL.Error.Get;
      end if;
   end Save_BMP;

   procedure Save_PNG
     (Self      : in Surface;
      File_Name : in UTF_Strings.UTF_String)
   is
   begin
      Ensure_Valid (Self);

      if not Boolean
          (SDL_Save_PNG (Self.Internal, C.To_C (String (File_Name))))
      then
         raise Surface_Error with SDL.Error.Get;
      end if;
   end Save_PNG;

   procedure Save_PNG
     (Self        : in Surface;
      Destination : in SDL.RWops.RWops;
      Close_After : in Boolean := False)
   is
   begin
      Ensure_Valid (Self);

      if SDL.RWops.Is_Null (Destination) then
         raise Surface_Error with "Invalid RWops handle";
      end if;

      if not Boolean
          (SDL_Save_PNG_IO
             (Self.Internal,
              SDL.RWops.Get_Handle (Destination),
              To_C_Bool (Close_After)))
      then
         raise Surface_Error with SDL.Error.Get;
      end if;
   end Save_PNG;

   overriding
   procedure Adjust (Self : in out Surface) is
   begin
      if Self.Internal /= null and then Self.Owns then
         Self.Internal.Reference_Count := Self.Internal.Reference_Count + 1;
      end if;
   end Adjust;

   overriding
   procedure Finalize (Self : in out Surface) is
   begin
      if Self.Internal /= null and then Self.Owns then
         SDL_Destroy_Surface (Self.Internal);
      end if;

      Self.Internal := null;
      Self.Owns := True;
   end Finalize;
end SDL.Video.Surfaces;
