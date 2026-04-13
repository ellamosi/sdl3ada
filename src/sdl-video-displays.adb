with Interfaces;
with Interfaces.C;
with Interfaces.C.Extensions;
with Interfaces.C.Pointers;
with Interfaces.C.Strings;
with System;

with SDL.Error;

package body SDL.Video.Displays is
   package CE renames Interfaces.C.Extensions;
   package CS renames Interfaces.C.Strings;

   subtype Display_ID is Interfaces.Unsigned_32;

   type Display_ID_Array is array (C.ptrdiff_t range <>) of aliased Display_ID with
     Convention => C;

   package Display_ID_Pointers is new Interfaces.C.Pointers
     (Index              => C.ptrdiff_t,
      Element            => Display_ID,
      Element_Array      => Display_ID_Array,
      Default_Terminator => 0);

   type Internal_Mode is
      record
         Display        : Display_ID;
         Format         : SDL.Video.Pixel_Formats.Pixel_Format_Names;
         Width          : C.int;
         Height         : C.int;
         Pixel_Density  : Interfaces.C.C_float;
         Refresh_Rate   : Interfaces.C.C_float;
         Refresh_Num    : C.int;
         Refresh_Denom  : C.int;
         Driver_Data    : System.Address;
      end record with
     Convention => C;

   type Internal_Mode_Access is access all Internal_Mode with
     Convention => C;

   type Internal_Mode_Pointer_Array is
     array (C.ptrdiff_t range <>) of aliased Internal_Mode_Access with
       Convention => C;

   package Internal_Mode_Pointers is new Interfaces.C.Pointers
     (Index              => C.ptrdiff_t,
      Element            => Internal_Mode_Access,
      Element_Array      => Internal_Mode_Pointer_Array,
      Default_Terminator => null);

   use type Display_ID;
   use type Display_ID_Pointers.Pointer;
   use type Internal_Mode_Access;
   use type Internal_Mode_Pointers.Pointer;
   use type Interfaces.C.C_float;
   use type SDL.Video.Pixel_Formats.Pixel_Format_Names;

   function SDL_Get_Displays
     (Count : access C.int) return Display_ID_Pointers.Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetDisplays";

   function SDL_Get_Primary_Display return Display_ID
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetPrimaryDisplay";

   procedure SDL_Free (Values : in Display_ID_Pointers.Pointer) with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_free";

   procedure SDL_Free (Values : in Internal_Mode_Pointers.Pointer) with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_free";

   function SDL_Get_Display_Name
     (ID : in Display_ID) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetDisplayName";

   function SDL_Get_Display_Properties
     (ID : in Display_ID) return SDL.Properties.Property_ID
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetDisplayProperties";

   function SDL_Get_Closest_Fullscreen_Display_Mode
     (ID                         : in Display_ID;
      Width                      : in C.int;
      Height                     : in C.int;
      Refresh_Rate               : in Interfaces.C.C_float;
      Include_High_Density_Modes : in CE.bool;
      Closest                    : access Internal_Mode) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetClosestFullscreenDisplayMode";

   function SDL_Get_Display_For_Point
     (Point : access constant Rectangles.Point) return Display_ID
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetDisplayForPoint";

   function SDL_Get_Display_For_Rectangle
     (Area : access constant Rectangles.Rectangle) return Display_ID
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetDisplayForRect";

   function SDL_Get_Current_Display_Mode
     (ID : in Display_ID) return Internal_Mode_Access
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetCurrentDisplayMode";

   function SDL_Get_Desktop_Display_Mode
     (ID : in Display_ID) return Internal_Mode_Access
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetDesktopDisplayMode";

   function SDL_Get_Fullscreen_Display_Modes
     (ID    : in Display_ID;
      Count : access C.int) return Internal_Mode_Pointers.Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetFullscreenDisplayModes";

   function SDL_Get_Display_Bounds
     (ID    : in Display_ID;
      Bounds : access Rectangles.Rectangle) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetDisplayBounds";

   function SDL_Get_Display_Usable_Bounds
     (ID     : in Display_ID;
      Bounds : access Rectangles.Rectangle) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetDisplayUsableBounds";

   function SDL_Get_Display_Content_Scale
     (ID : in Display_ID) return Interfaces.C.C_float
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetDisplayContentScale";

   function SDL_Get_Current_Display_Orientation
     (ID : in Display_ID) return Display_Orientations
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetCurrentDisplayOrientation";

   function SDL_Get_Natural_Display_Orientation
     (ID : in Display_ID) return Display_Orientations
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetNaturalDisplayOrientation";

   function To_Refresh_Rate
     (Value : in Interfaces.C.C_float) return Refresh_Rates is
   begin
      if Value <= Interfaces.C.C_float (0.0) then
         return Refresh_Rates'First;
      elsif Value >= Interfaces.C.C_float (Refresh_Rates'Last) then
         return Refresh_Rates'Last;
      else
         return Refresh_Rates (Integer (Float (Value) + 0.5));
      end if;
   end To_Refresh_Rate;

   function To_Public (Value : in Internal_Mode) return Mode is
   begin
      return
        (Format       => Value.Format,
         Width        => Value.Width,
         Height       => Value.Height,
         Refresh_Rate => To_Refresh_Rate (Value.Refresh_Rate),
         Driver_Data  => Value.Driver_Data);
   end To_Public;

   function Resolve_Display_ID
     (Display : in Display_Indices) return Display_ID
   is
      Count : aliased C.int := 0;
      List  : Display_ID_Pointers.Pointer := SDL_Get_Displays (Count'Access);
   begin
      if List = null or else Count < C.int (Display) then
         if List /= null then
            SDL_Free (List);
         end if;

         raise Video_Error with SDL.Error.Get;
      end if;

      declare
         Position : constant Display_ID_Pointers.Pointer :=
           List + C.ptrdiff_t (Display) - C.ptrdiff_t (1);
         Result : constant Display_ID :=
           Position.all;
      begin
         SDL_Free (List);
         return Result;
      end;
   end Resolve_Display_ID;

   function Index_For_ID (ID : in Display_ID) return Display_Indices is
      Count : aliased C.int := 0;
      List  : Display_ID_Pointers.Pointer := SDL_Get_Displays (Count'Access);
   begin
      if List = null or else Count < 1 then
         if List /= null then
            SDL_Free (List);
         end if;

         raise Video_Error with SDL.Error.Get;
      end if;

      for Index in 0 .. Natural (Count - 1) loop
         declare
            Position : constant Display_ID_Pointers.Pointer :=
              List + C.ptrdiff_t (Index);
         begin
            if Position.all = ID then
               SDL_Free (List);
               return Display_Indices (Index + 1);
            end if;
         end;
      end loop;

      SDL_Free (List);
      raise Video_Error with SDL.Error.Get;
   end Index_For_ID;

   function Primary return Display_Indices is
      ID : constant Display_ID := SDL_Get_Primary_Display;
   begin
      if ID = 0 then
         raise Video_Error with SDL.Error.Get;
      end if;

      return Index_For_ID (ID);
   end Primary;

   function Total return Display_Indices is
      Count : aliased C.int := 0;
      List  : Display_ID_Pointers.Pointer := SDL_Get_Displays (Count'Access);
   begin
      if List = null or else Count < 1 then
         if List /= null then
            SDL_Free (List);
         end if;

         raise Video_Error with SDL.Error.Get;
      end if;

      SDL_Free (List);
      return Display_Indices (Count);
   end Total;

   function Get_Display_Name (Display : Display_Indices) return String is
      Name : constant CS.chars_ptr :=
        SDL_Get_Display_Name (Resolve_Display_ID (Display));

      use type CS.chars_ptr;
   begin
      if Name = CS.Null_Ptr then
         return "";
      end if;

      return CS.Value (Name);
   end Get_Display_Name;

   function Get_Properties
     (Display : in Display_Indices) return SDL.Properties.Property_ID
   is
      Props : constant SDL.Properties.Property_ID :=
        SDL_Get_Display_Properties (Resolve_Display_ID (Display));
   begin
      if Props = SDL.Properties.Null_Property_ID then
         raise Video_Error with SDL.Error.Get;
      end if;

      return Props;
   end Get_Properties;

   function Closest_Mode
     (Display : in Display_Indices;
      Wanted  : in Mode;
      Target  : out Mode) return Boolean
   is
      Closest : aliased Internal_Mode :=
        (Display       => 0,
         Format        => SDL.Video.Pixel_Formats.Pixel_Format_Unknown,
         Width         => 0,
         Height        => 0,
         Pixel_Density => 0.0,
         Refresh_Rate  => Interfaces.C.C_float (Wanted.Refresh_Rate),
         Refresh_Num   => 0,
         Refresh_Denom => 0,
         Driver_Data   => System.Null_Address);
   begin
      if not Boolean
          (SDL_Get_Closest_Fullscreen_Display_Mode
             (ID                         => Resolve_Display_ID (Display),
              Width                      => Wanted.Width,
              Height                     => Wanted.Height,
              Refresh_Rate               => Interfaces.C.C_float (Wanted.Refresh_Rate),
              Include_High_Density_Modes => CE.bool'Val (1),
              Closest                    => Closest'Access))
      then
         return False;
      end if;

      Target := To_Public (Closest);

      return
        Wanted.Format = SDL.Video.Pixel_Formats.Pixel_Format_Unknown
          or else Target.Format = Wanted.Format;
   end Closest_Mode;

   function Get_Display_Index_From_Point
     (Point : in Rectangles.Point) return Display_Indices
   is
      Position : aliased Rectangles.Point := Point;
      ID       : constant Display_ID :=
        SDL_Get_Display_For_Point (Position'Access);
   begin
      if ID = 0 then
         raise Video_Error with SDL.Error.Get;
      end if;

      return Index_For_ID (ID);
   end Get_Display_Index_From_Point;

   function Get_Display_Index_From_Rectangle
     (Area : in Rectangles.Rectangle) return Display_Indices
   is
      Region : aliased Rectangles.Rectangle := Area;
      ID     : constant Display_ID :=
        SDL_Get_Display_For_Rectangle (Region'Access);
   begin
      if ID = 0 then
         raise Video_Error with SDL.Error.Get;
      end if;

      return Index_For_ID (ID);
   end Get_Display_Index_From_Rectangle;

   function Current_Mode
     (Display : in Display_Indices;
      Target  : out Mode) return Boolean
   is
      Value : constant Internal_Mode_Access :=
        SDL_Get_Current_Display_Mode (Resolve_Display_ID (Display));
   begin
      if Value = null then
         return False;
      end if;

      Target := To_Public (Value.all);
      return True;
   end Current_Mode;

   function Desktop_Mode
     (Display : in Display_Indices;
      Target  : out Mode) return Boolean
   is
      Value : constant Internal_Mode_Access :=
        SDL_Get_Desktop_Display_Mode (Resolve_Display_ID (Display));
   begin
      if Value = null then
         return False;
      end if;

      Target := To_Public (Value.all);
      return True;
   end Desktop_Mode;

   function Display_Mode
     (Display : in Display_Indices;
      Index   : in Natural;
      Target  : out Mode) return Boolean
   is
      Count : aliased C.int := 0;
      Modes : Internal_Mode_Pointers.Pointer :=
        SDL_Get_Fullscreen_Display_Modes
          (Resolve_Display_ID (Display), Count'Access);
   begin
      if Modes = null or else Index >= Natural (Count) then
         if Modes /= null then
            SDL_Free (Modes);
         end if;

         return False;
      end if;

      declare
         Position : constant Internal_Mode_Pointers.Pointer :=
           Modes + C.ptrdiff_t (Index);
         Value : constant Internal_Mode_Access :=
           Position.all;
      begin
         if Value = null then
            SDL_Free (Modes);
            return False;
         end if;

         Target := To_Public (Value.all);
      end;

      SDL_Free (Modes);
      return True;
   end Display_Mode;

   function Total_Display_Modes
     (Display : in Display_Indices;
      Total   : out Positive) return Boolean
   is
      Count : aliased C.int := 0;
      Modes : Internal_Mode_Pointers.Pointer :=
        SDL_Get_Fullscreen_Display_Modes
          (Resolve_Display_ID (Display), Count'Access);
   begin
      if Modes = null or else Count < 1 then
         if Modes /= null then
            SDL_Free (Modes);
         end if;

         return False;
      end if;

      Total := Positive (Count);
      SDL_Free (Modes);
      return True;
   end Total_Display_Modes;

   function Total_Display_Modes
     (Display : in Display_Indices) return Positive
   is
      Result : Positive;
   begin
      if not Total_Display_Modes (Display, Result) then
         raise Video_Error with SDL.Error.Get;
      end if;

      return Result;
   end Total_Display_Modes;

   function Display_Bounds
     (Display : in Display_Indices;
      Bounds  : out Rectangles.Rectangle) return Boolean
   is
      Result : aliased Rectangles.Rectangle := Rectangles.Null_Rectangle;
   begin
      if not Boolean
          (SDL_Get_Display_Bounds
             (Resolve_Display_ID (Display), Result'Access))
      then
         return False;
      end if;

      Bounds := Result;
      return True;
   end Display_Bounds;

   function Get_Usable_Bounds
     (Display : in Display_Indices;
      Bounds  : out Rectangles.Rectangle) return Boolean
   is
      Result : aliased Rectangles.Rectangle := Rectangles.Null_Rectangle;
   begin
      if not Boolean
          (SDL_Get_Display_Usable_Bounds
             (Resolve_Display_ID (Display), Result'Access))
      then
         return False;
      end if;

      Bounds := Result;
      return True;
   end Get_Usable_Bounds;

   procedure Get_Display_DPI
     (Display    : in Display_Indices;
      Diagonal   : out Float;
      Horizontal : out Float;
      Vertical   : out Float)
   is
      Scale : constant Float := Get_Content_Scale (Display);
      DPI   : constant Float := Scale * 96.0;
   begin
      Diagonal := DPI;
      Horizontal := DPI;
      Vertical := DPI;
   end Get_Display_DPI;

   procedure Get_Display_DPI
     (Display    : in Display_Indices;
      Horizontal : out Float;
      Vertical   : out Float)
   is
      Diagonal : Float;
   begin
      Get_Display_DPI (Display, Diagonal, Horizontal, Vertical);
   end Get_Display_DPI;

   function Get_Display_Horizontal_DPI
     (Display : in Display_Indices) return Float
   is
      Horizontal : Float;
      Vertical   : Float;
   begin
      Get_Display_DPI (Display, Horizontal, Vertical);
      return Horizontal;
   end Get_Display_Horizontal_DPI;

   function Get_Display_Vertical_DPI
     (Display : in Display_Indices) return Float
   is
      Horizontal : Float;
      Vertical   : Float;
   begin
      Get_Display_DPI (Display, Horizontal, Vertical);
      return Vertical;
   end Get_Display_Vertical_DPI;

   function Get_Content_Scale
     (Display : in Display_Indices) return Float
   is
      Scale : constant Interfaces.C.C_float :=
        SDL_Get_Display_Content_Scale (Resolve_Display_ID (Display));
   begin
      if Scale <= 0.0 then
         raise Video_Error with SDL.Error.Get;
      end if;

      return Float (Scale);
   end Get_Content_Scale;

   function Get_Natural_Orientation
     (Display : in Display_Indices) return Display_Orientations is
   begin
      return
        SDL_Get_Natural_Display_Orientation (Resolve_Display_ID (Display));
   end Get_Natural_Orientation;

   function Get_Orientation
     (Display : in Display_Indices) return Display_Orientations is
   begin
      return
        SDL_Get_Current_Display_Orientation (Resolve_Display_ID (Display));
   end Get_Orientation;
end SDL.Video.Displays;
