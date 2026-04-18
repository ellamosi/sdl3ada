with Interfaces;
with Interfaces.C.Extensions;
with Interfaces.C.Strings;

with SDL.Error;
with SDL.Raw.Video;

package body SDL.Video.Displays is
   package CE renames Interfaces.C.Extensions;
   package CS renames Interfaces.C.Strings;
   package Raw renames SDL.Raw.Video;

   use type Raw.Display_ID;
   use type Raw.Display_ID_Pointers.Pointer;
   use type Raw.Display_Mode_Access;
   use type Raw.Display_Mode_Pointers.Pointer;
   use type Interfaces.C.C_float;
   use type SDL.Properties.Property_ID;
   use type SDL.Video.Pixel_Formats.Pixel_Format_Names;

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

   function To_Public (Value : in Raw.Display_Mode) return Mode is
   begin
      return
        (Format       => SDL.Video.Pixel_Formats.Pixel_Format_Names (Value.Format),
         Width        => Value.Width,
         Height       => Value.Height,
         Refresh_Rate => To_Refresh_Rate (Value.Refresh_Rate),
         Driver_Data  => Value.Internal);
   end To_Public;

   function To_Public
     (Value : in Raw.Display_Orientation) return Display_Orientations is
       (Display_Orientations'Val (Raw.Display_Orientation'Pos (Value)));

   function Resolve_Display_ID
     (Display : in Display_Indices) return Raw.Display_ID
   is
      Count : aliased C.int := 0;
      List  : constant Raw.Display_ID_Pointers.Pointer :=
        Raw.Get_Displays (Count'Access);
   begin
      if List = null or else Count < C.int (Display) then
         if List /= null then
            Raw.Free (List);
         end if;

         raise Video_Error with SDL.Error.Get;
      end if;

      declare
         Position : constant Raw.Display_ID_Pointers.Pointer :=
           List + C.ptrdiff_t (Display) - C.ptrdiff_t (1);
         Result : constant Raw.Display_ID :=
           Position.all;
      begin
         Raw.Free (List);
         return Result;
      end;
   end Resolve_Display_ID;

   function Index_For_ID (ID : in Raw.Display_ID) return Display_Indices is
      Count : aliased C.int := 0;
      List  : constant Raw.Display_ID_Pointers.Pointer :=
        Raw.Get_Displays (Count'Access);
   begin
      if List = null or else Count < 1 then
         if List /= null then
            Raw.Free (List);
         end if;

         raise Video_Error with SDL.Error.Get;
      end if;

      for Index in 0 .. Natural (Count - 1) loop
         declare
            Position : constant Raw.Display_ID_Pointers.Pointer :=
              List + C.ptrdiff_t (Index);
         begin
            if Position.all = ID then
               Raw.Free (List);
               return Display_Indices (Index + 1);
            end if;
         end;
      end loop;

      Raw.Free (List);
      raise Video_Error with SDL.Error.Get;
   end Index_For_ID;

   function Primary return Display_Indices is
      ID : constant Raw.Display_ID := Raw.Get_Primary_Display;
   begin
      if ID = 0 then
         raise Video_Error with SDL.Error.Get;
      end if;

      return Index_For_ID (ID);
   end Primary;

   function Total return Display_Indices is
      Count : aliased C.int := 0;
      List  : constant Raw.Display_ID_Pointers.Pointer :=
        Raw.Get_Displays (Count'Access);
   begin
      if List = null or else Count < 1 then
         if List /= null then
            Raw.Free (List);
         end if;

         raise Video_Error with SDL.Error.Get;
      end if;

      Raw.Free (List);
      return Display_Indices (Count);
   end Total;

   function Get_Display_Name (Display : Display_Indices) return String is
      Name : constant CS.chars_ptr :=
        Raw.Get_Display_Name (Resolve_Display_ID (Display));

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
        Raw.Get_Display_Properties (Resolve_Display_ID (Display));
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
      Closest : aliased Raw.Display_Mode :=
        (Display       => 0,
         Format        =>
           Raw.Pixel_Format_Name
             (SDL.Video.Pixel_Formats.Pixel_Format_Unknown),
         Width         => 0,
         Height        => 0,
         Pixel_Density => 0.0,
         Refresh_Rate  => Interfaces.C.C_float (Wanted.Refresh_Rate),
         Refresh_Numerator   => 0,
         Refresh_Denominator => 0,
         Internal            => System.Null_Address);
   begin
      if not Boolean
          (Raw.Get_Closest_Fullscreen_Display_Mode
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
      ID       : constant Raw.Display_ID :=
        Raw.Get_Display_For_Point (Position'Address);
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
      ID     : constant Raw.Display_ID :=
        Raw.Get_Display_For_Rect (Region'Address);
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
      Value : constant Raw.Display_Mode_Access :=
        Raw.Get_Current_Display_Mode (Resolve_Display_ID (Display));
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
      Value : constant Raw.Display_Mode_Access :=
        Raw.Get_Desktop_Display_Mode (Resolve_Display_ID (Display));
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
      Modes : constant Raw.Display_Mode_Pointers.Pointer :=
        Raw.Get_Fullscreen_Display_Modes
          (Resolve_Display_ID (Display), Count'Access);
   begin
      if Modes = null or else Index >= Natural (Count) then
         if Modes /= null then
            Raw.Free (Modes);
         end if;

         return False;
      end if;

      declare
         Position : constant Raw.Display_Mode_Pointers.Pointer :=
           Modes + C.ptrdiff_t (Index);
         Value : constant Raw.Display_Mode_Access :=
           Position.all;
      begin
         if Value = null then
            Raw.Free (Modes);
            return False;
         end if;

         Target := To_Public (Value.all);
      end;

      Raw.Free (Modes);
      return True;
   end Display_Mode;

   function Total_Display_Modes
     (Display : in Display_Indices;
      Total   : out Positive) return Boolean
   is
      Count : aliased C.int := 0;
      Modes : constant Raw.Display_Mode_Pointers.Pointer :=
        Raw.Get_Fullscreen_Display_Modes
          (Resolve_Display_ID (Display), Count'Access);
   begin
      if Modes = null or else Count < 1 then
         if Modes /= null then
            Raw.Free (Modes);
         end if;

         return False;
      end if;

      Total := Positive (Count);
      Raw.Free (Modes);
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
          (Raw.Get_Display_Bounds
             (Resolve_Display_ID (Display), Result'Address))
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
          (Raw.Get_Display_Usable_Bounds
             (Resolve_Display_ID (Display), Result'Address))
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
        Raw.Get_Display_Content_Scale (Resolve_Display_ID (Display));
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
        To_Public (Raw.Get_Natural_Display_Orientation
          (Resolve_Display_ID (Display)));
   end Get_Natural_Orientation;

   function Get_Orientation
     (Display : in Display_Indices) return Display_Orientations is
   begin
      return
        To_Public (Raw.Get_Current_Display_Orientation
          (Resolve_Display_ID (Display)));
   end Get_Orientation;
end SDL.Video.Displays;
