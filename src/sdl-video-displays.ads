with Interfaces.C;
with System;

with SDL.Properties;
with SDL.Video.Pixel_Formats;
with SDL.Video.Rectangles;

package SDL.Video.Displays is
   pragma Elaborate_Body;

   package C renames Interfaces.C;

   type Refresh_Rates is range 0 .. 400 with
     Size       => C.int'Size,
     Convention => C;

   type Mode is
      record
         Format       : SDL.Video.Pixel_Formats.Pixel_Format_Names;
         Width        : C.int;
         Height       : C.int;
         Refresh_Rate : Refresh_Rates;
         Driver_Data  : System.Address;
      end record with
     Convention => C;

   type Access_Mode is access all Mode with
     Convention => C;

   type Display_Indices is new Positive;

   type Display_Orientations is
     (Orientation_Unknown,
      Orientation_Landscape,
      Orientation_Landscape_Flipped,
      Orientation_Portrait,
      Orientation_Portrait_Flipped)
   with
     Convention => C,
     Size       => C.int'Size;

   function Primary return Display_Indices;

   function Total return Display_Indices;

   function Get_Display_Name (Display : Display_Indices) return String;

   function Get_Properties
     (Display : in Display_Indices) return SDL.Properties.Property_ID;

   function Closest_Mode
     (Display : in Display_Indices;
      Wanted  : in Mode;
      Target  : out Mode) return Boolean;

   function Get_Display_Index_From_Point
     (Point : in Rectangles.Point) return Display_Indices;

   function Get_Display_Index_From_Rectangle
     (Area : in Rectangles.Rectangle) return Display_Indices;

   function Current_Mode
     (Display : in Display_Indices;
     Target  : out Mode) return Boolean;

   function Desktop_Mode
     (Display : in Display_Indices;
      Target  : out Mode) return Boolean;

   function Display_Mode
     (Display : in Display_Indices;
      Index   : in Natural;
      Target  : out Mode) return Boolean;

   function Total_Display_Modes
     (Display : in Display_Indices;
      Total   : out Positive) return Boolean;

   function Total_Display_Modes
     (Display : in Display_Indices) return Positive;

   function Display_Bounds
     (Display : in Display_Indices;
      Bounds  : out Rectangles.Rectangle) return Boolean
   with
     Obsolescent;

   function Get_Bounds
     (Display : in Display_Indices;
      Bounds  : out Rectangles.Rectangle) return Boolean renames Display_Bounds;

   function Get_Usable_Bounds
     (Display : in Display_Indices;
      Bounds  : out Rectangles.Rectangle) return Boolean;

   procedure Get_Display_DPI
     (Display    : in Display_Indices;
      Diagonal   : out Float;
      Horizontal : out Float;
      Vertical   : out Float);

   procedure Get_Display_DPI
     (Display    : in Display_Indices;
      Horizontal : out Float;
      Vertical   : out Float);

   function Get_Display_Horizontal_DPI
     (Display : in Display_Indices) return Float;

   function Get_Display_Vertical_DPI
     (Display : in Display_Indices) return Float;

   function Get_Content_Scale
     (Display : in Display_Indices) return Float;

   function Get_Natural_Orientation
     (Display : in Display_Indices) return Display_Orientations;

   function Get_Orientation
     (Display : in Display_Indices) return Display_Orientations;
end SDL.Video.Displays;
