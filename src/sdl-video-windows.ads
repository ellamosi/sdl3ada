with Ada.Finalization;
with Interfaces;
with Interfaces.C;
with System;

with SDL.Properties;
with SDL.Raw.Video_Types;
with SDL.Video.Displays;
with SDL.Video.Pixel_Formats;
with SDL.Video.Rectangles;
with SDL.Video.Surfaces;

package SDL.Video.Windows is
   Window_Error : exception;

   package C renames Interfaces.C;

   use type Interfaces.Unsigned_32;

   function Undefined_Window_Position
     (Display : Natural := 0) return SDL.Natural_Coordinate is
       (SDL.Natural_Coordinate
          (SDL.Coordinate
             (Interfaces.Unsigned_32 (Display) or 16#1FFF_0000#)));

   function Centered_Window_Position
     (Display : Natural := 0) return SDL.Natural_Coordinate is
       (SDL.Natural_Coordinate
          (SDL.Coordinate
             (Interfaces.Unsigned_32 (Display) or 16#2FFF_0000#)));

   function Centered_Window_Position
     (Display : Natural := 0) return SDL.Coordinates is
       (X => Centered_Window_Position (Display),
        Y => Centered_Window_Position (Display));

   type Window_Flags is mod 2 ** 64 with
     Convention => C;

   Windowed            : constant Window_Flags := 16#0000_0000_0000_0000#;
   Full_Screen         : constant Window_Flags := 16#0000_0000_0000_0001#;
   OpenGL              : constant Window_Flags := 16#0000_0000_0000_0002#;
   Occluded            : constant Window_Flags := 16#0000_0000_0000_0004#;
   Shown               : constant Window_Flags := Windowed;
   Hidden              : constant Window_Flags := 16#0000_0000_0000_0008#;
   Borderless          : constant Window_Flags := 16#0000_0000_0000_0010#;
   Resizable           : constant Window_Flags := 16#0000_0000_0000_0020#;
   Minimised           : constant Window_Flags := 16#0000_0000_0000_0040#;
   Maximised           : constant Window_Flags := 16#0000_0000_0000_0080#;
   Mouse_Grabbed       : constant Window_Flags := 16#0000_0000_0000_0100#;
   Input_Focus         : constant Window_Flags := 16#0000_0000_0000_0200#;
   Mouse_Focus         : constant Window_Flags := 16#0000_0000_0000_0400#;
   External            : constant Window_Flags := 16#0000_0000_0000_0800#;
   Foreign             : constant Window_Flags := External;
   Modal               : constant Window_Flags := 16#0000_0000_0000_1000#;
   High_Pixel_Density  : constant Window_Flags := 16#0000_0000_0000_2000#;
   Allow_High_DPI      : constant Window_Flags := High_Pixel_Density;
   Mouse_Capture       : constant Window_Flags := 16#0000_0000_0000_4000#;
   Mouse_Relative_Mode : constant Window_Flags := 16#0000_0000_0000_8000#;
   Input_Grabbed       : constant Window_Flags := Mouse_Grabbed;
   Always_On_Top       : constant Window_Flags := 16#0000_0000_0001_0000#;
   Utility             : constant Window_Flags := 16#0000_0000_0002_0000#;
   Skip_Taskbar        : constant Window_Flags := Utility;
   Tool_Tip            : constant Window_Flags := 16#0000_0000_0004_0000#;
   Pop_Up_Menu         : constant Window_Flags := 16#0000_0000_0008_0000#;
   Keyboard_Grabbed    : constant Window_Flags := 16#0000_0000_0010_0000#;
   Fill_Document       : constant Window_Flags := 16#0000_0000_0020_0000#;
   Vulkan              : constant Window_Flags := 16#0000_0000_1000_0000#;
   Metal               : constant Window_Flags := 16#0000_0000_2000_0000#;
   Transparent         : constant Window_Flags := 16#0000_0000_4000_0000#;
   Not_Focusable       : constant Window_Flags := 16#0000_0000_8000_0000#;
   Full_Screen_Desktop : constant Window_Flags := Full_Screen;

   subtype ID is SDL.Raw.Video_Types.Window_ID;

   type Flash_Operations is
     (Flash_Cancel,
      Flash_Briefly,
      Flash_Until_Focused)
   with
     Convention => C,
     Size       => C.int'Size;

   type Progress_States is
     (Invalid_Progress_State,
      No_Progress,
      Indeterminate_Progress,
      Normal_Progress,
      Paused_Progress,
      Error_Progress)
   with
     Convention => C,
     Size       => C.int'Size;

   for Progress_States use
     (Invalid_Progress_State => -1,
      No_Progress            => 0,
      Indeterminate_Progress => 1,
      Normal_Progress        => 2,
      Paused_Progress        => 3,
      Error_Progress         => 4);

   type Hit_Test_Results is
     (Normal_Hit,
      Draggable_Hit,
      Resize_Top_Left_Hit,
      Resize_Top_Hit,
      Resize_Top_Right_Hit,
      Resize_Right_Hit,
      Resize_Bottom_Right_Hit,
      Resize_Bottom_Hit,
      Resize_Bottom_Left_Hit,
      Resize_Left_Hit)
   with
     Convention => C,
     Size       => C.int'Size;

   type Hit_Test_Callback is access function
     (Win       : in System.Address;
      Area      : access constant SDL.Video.Rectangles.Point;
      User_Data : in System.Address) return Hit_Test_Results
   with Convention => C;

   subtype Window_Surface_V_Sync_Intervals is C.int;

   Window_Surface_V_Sync_Disabled : constant Window_Surface_V_Sync_Intervals := 0;
   Window_Surface_V_Sync_Adaptive : constant Window_Surface_V_Sync_Intervals := -1;

   type Border_Sizes is
      record
         Top    : SDL.Dimension := 0;
         Left   : SDL.Dimension := 0;
         Bottom : SDL.Dimension := 0;
         Right  : SDL.Dimension := 0;
      end record
   with Convention => C;

   type Aspect_Ratios is
      record
         Minimum : Float := 0.0;
         Maximum : Float := 0.0;
      end record
   with Convention => C;

   type Byte_Arrays is array (Natural range <>) of aliased Interfaces.Unsigned_8 with
     Convention => C;

   type ID_Lists is array (Natural range <>) of ID
   with Convention => Ada;

   type Window is new Ada.Finalization.Limited_Controlled with private;

   overriding
   procedure Finalize (Self : in out Window);

   function Is_Null (Self : in Window) return Boolean with
     Inline;

   function Get (Window_ID : in ID) return Window;

   function From_ID (Window_ID : in ID) return Window renames Get;

   function Get_Windows return ID_Lists;

   function Get_Window_IDs return ID_Lists renames Get_Windows;

   function Get_ID (Self : in Window) return ID with
     Inline;

   function Get_Display
     (Self : in Window) return SDL.Video.Displays.Display_Indices;

   function Display_Index
     (Self : in Window) return SDL.Video.Displays.Display_Indices
   renames Get_Display;

   function Get_Properties
     (Self : in Window) return SDL.Properties.Property_ID;

   function Get_Flags (Self : in Window) return Window_Flags;

   function Get_Title (Self : in Window) return String;

   function Get_Surface
     (Self : in Window) return SDL.Video.Surfaces.Surface;

   procedure Get_Position
     (Self : in Window;
      X    : out SDL.Coordinate;
      Y    : out SDL.Coordinate);

   function Get_Position (Self : in Window) return SDL.Coordinates;

   procedure Set_Position
     (Self     : in out Window;
      Position : in SDL.Coordinates);

   procedure Set_Position
     (Self : in out Window;
      X    : in SDL.Coordinate;
      Y    : in SDL.Coordinate);

   procedure Get_Size
     (Self          : in Window;
      Width, Height : out SDL.Natural_Dimension);

   function Get_Size (Self : in Window) return SDL.Sizes;

   procedure Set_Size
     (Self : in out Window;
      Size : in SDL.Positive_Sizes);

   procedure Set_Size
     (Self   : in out Window;
      Width  : in SDL.Positive_Dimension;
      Height : in SDL.Positive_Dimension);

   procedure Get_Size_In_Pixels
     (Self          : in Window;
      Width, Height : out SDL.Natural_Dimension);

   function Get_Size_In_Pixels (Self : in Window) return SDL.Sizes;

   function Get_Pixel_Density (Self : in Window) return Float;

   function Get_Display_Scale (Self : in Window) return Float;

   procedure Set_Fullscreen_Mode
     (Self : in out Window;
      Mode : in SDL.Video.Displays.Mode);

   procedure Reset_Fullscreen_Mode (Self : in out Window);

   function Get_Fullscreen_Mode
     (Self : in Window;
      Mode : out SDL.Video.Displays.Mode) return Boolean;

   function Get_ICC_Profile (Self : in Window) return Byte_Arrays;

   function Pixel_Format
     (Self : in Window) return SDL.Video.Pixel_Formats.Pixel_Format_Names;

   function Get_Pixel_Format
     (Self : in Window) return SDL.Video.Pixel_Formats.Pixel_Format_Names
   renames Pixel_Format;

   function Get_Safe_Area
     (Self : in Window) return SDL.Video.Rectangles.Rectangle;

   procedure Set_Aspect_Ratio
     (Self         : in out Window;
      Aspect_Ratio : in Aspect_Ratios);

   procedure Set_Aspect_Ratio
     (Self        : in out Window;
      Minimum     : in Float;
      Maximum     : in Float);

   function Get_Aspect_Ratio
     (Self : in Window) return Aspect_Ratios;

   function Get_Borders_Size
     (Self    : in Window;
      Borders : out Border_Sizes) return Boolean;

   function Get_Maximum_Size (Self : in Window) return SDL.Sizes;

   procedure Set_Maximum_Size
     (Self : in out Window;
      Size : in SDL.Natural_Sizes);

   procedure Set_Maximum_Size
     (Self   : in out Window;
      Width  : in SDL.Natural_Dimension;
      Height : in SDL.Natural_Dimension);

   function Get_Minimum_Size (Self : in Window) return SDL.Sizes;

   procedure Set_Minimum_Size
     (Self : in out Window;
      Size : in SDL.Natural_Sizes);

   procedure Set_Minimum_Size
     (Self   : in out Window;
      Width  : in SDL.Natural_Dimension;
      Height : in SDL.Natural_Dimension);

   procedure Set_Bordered
     (Self     : in out Window;
      Bordered : in Boolean);

   procedure Set_Resizable
     (Self      : in out Window;
      Resizable : in Boolean);

   procedure Set_Always_On_Top
     (Self   : in out Window;
      Enable : in Boolean);

   procedure Set_Fill_Document
     (Self   : in out Window;
      Enable : in Boolean);

   procedure Set_Title (Self : in Window; Title : in String);

   procedure Set_Icon
     (Self : in out Window;
      Icon : in SDL.Video.Surfaces.Surface);

   procedure Show (Self : in Window);

   procedure Hide (Self : in Window);

   procedure Maximise (Self : in Window);

   procedure Minimise (Self : in Window);

   procedure Raise_And_Focus (Self : in Window);

   procedure Restore (Self : in Window);

   procedure Set_Fullscreen
     (Self       : in out Window;
      Fullscreen : in Boolean);

   procedure Sync (Self : in Window);

   function Has_Surface (Self : in Window) return Boolean;

   procedure Set_Surface_V_Sync
     (Self     : in Window;
      Interval : in Window_Surface_V_Sync_Intervals);

   function Get_Surface_V_Sync
     (Self : in Window) return Window_Surface_V_Sync_Intervals;

   procedure Update_Surface (Self : in Window);

   procedure Update_Surface_Rectangle
     (Self      : in Window;
     Rectangle : in SDL.Video.Rectangles.Rectangle);

   procedure Update_Surface_Rectangles
     (Self       : in Window;
      Rectangles : in SDL.Video.Rectangles.Rectangle_Arrays);

   procedure Destroy_Surface (Self : in Window);

   procedure Set_Keyboard_Grab
     (Self    : in out Window;
      Grabbed : in Boolean);

   function Is_Keyboard_Grabbed (Self : in Window) return Boolean;

   procedure Set_Mouse_Grab
     (Self    : in out Window;
      Grabbed : in Boolean);

   function Is_Mouse_Grabbed (Self : in Window) return Boolean;

   function Get_Grabbed return Window;

   procedure Set_Mouse_Rect
     (Self      : in out Window;
      Rectangle : in SDL.Video.Rectangles.Rectangle);

   procedure Clear_Mouse_Rect (Self : in out Window);

   function Get_Mouse_Rect
     (Self      : in Window;
      Rectangle : out SDL.Video.Rectangles.Rectangle) return Boolean;

   procedure Set_Opacity
     (Self    : in out Window;
      Opacity : in Float);

   function Get_Opacity (Self : in Window) return Float;

   procedure Set_Parent
     (Self   : in out Window;
      Parent : in Window);

   function Get_Parent (Self : in Window) return Window;

   procedure Set_Modal
     (Self  : in out Window;
      Modal : in Boolean);

   procedure Set_Focusable
     (Self      : in out Window;
      Focusable : in Boolean);

   procedure Show_System_Menu
     (Self     : in Window;
      Position : in SDL.Coordinates);

   procedure Show_System_Menu
     (Self : in Window;
      X    : in SDL.Coordinate;
      Y    : in SDL.Coordinate);

   procedure Set_Hit_Test
     (Self      : in out Window;
      Callback  : in Hit_Test_Callback;
      User_Data : in System.Address := System.Null_Address);

   procedure Disable_Hit_Test (Self : in out Window);

   procedure Set_Shape
     (Self  : in out Window;
      Shape : in SDL.Video.Surfaces.Surface);

   procedure Clear_Shape (Self : in out Window);

   procedure Flash
     (Self      : in Window;
      Operation : in Flash_Operations);

   procedure Set_Progress_State
     (Self  : in out Window;
      State : in Progress_States);

   function Get_Progress_State
     (Self : in Window) return Progress_States;

   procedure Set_Progress_Value
     (Self  : in out Window;
      Value : in Float);

   function Get_Progress_Value
     (Self : in Window) return Float;

   function Get_Internal (Self : in Window) return System.Address with
     Inline;
private
   type Window is new Ada.Finalization.Limited_Controlled with
      record
         Internal : System.Address := System.Null_Address;
         Owns     : Boolean        := True;
      end record;
end SDL.Video.Windows;
