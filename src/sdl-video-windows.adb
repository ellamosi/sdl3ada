with Ada.Unchecked_Conversion;
with Interfaces.C.Extensions;
with Interfaces.C.Pointers;
with Interfaces.C.Strings;

with SDL.Error;
with SDL.Raw.Rect;
with SDL.Raw.Video;
with SDL.Video.Surfaces.Internal;

package body SDL.Video.Windows is
   package CE renames Interfaces.C.Extensions;
   package CS renames Interfaces.C.Strings;
   package Raw_Rect renames SDL.Raw.Rect;
   package Raw_Video renames SDL.Raw.Video;
   package Surface_Internal renames SDL.Video.Surfaces.Internal;

   subtype Display_ID is Raw_Video.Display_ID;

   type Display_ID_Array is array (C.ptrdiff_t range <>) of aliased Display_ID with
     Convention => C;

   package Display_ID_Pointers is new Interfaces.C.Pointers
     (Index              => C.ptrdiff_t,
      Element            => Display_ID,
      Element_Array      => Display_ID_Array,
      Default_Terminator => 0);

   type U8_Array is
     array (C.ptrdiff_t range <>) of aliased Interfaces.Unsigned_8
   with Convention => C;

   package U8_Pointers is new Interfaces.C.Pointers
     (Index              => C.ptrdiff_t,
      Element            => Interfaces.Unsigned_8,
      Element_Array      => U8_Array,
      Default_Terminator => 0);

   type Window_Address_Array is
     array (C.ptrdiff_t range <>) of aliased System.Address
   with Convention => C;

   package Window_Address_Pointers is new Interfaces.C.Pointers
     (Index              => C.ptrdiff_t,
      Element            => System.Address,
      Element_Array      => Window_Address_Array,
      Default_Terminator => System.Null_Address);

   subtype Internal_Mode is Raw_Video.Display_Mode;
   subtype Internal_Mode_Access is Raw_Video.Display_Mode_Access;

   type Rectangle_Access is access constant SDL.Video.Rectangles.Rectangle with
     Convention => C;

   function To_Display_ID_Pointers is new Ada.Unchecked_Conversion
     (Source => Raw_Video.Display_ID_Pointers.Pointer,
      Target => Display_ID_Pointers.Pointer);

   function To_Raw_Display_ID_Pointers is new Ada.Unchecked_Conversion
     (Source => Display_ID_Pointers.Pointer,
      Target => Raw_Video.Display_ID_Pointers.Pointer);

   function To_U8_Pointer is new Ada.Unchecked_Conversion
     (Source => System.Address,
      Target => U8_Pointers.Pointer);

   function To_Window_Address_Pointers is new Ada.Unchecked_Conversion
     (Source => Raw_Video.Window_Pointers.Pointer,
      Target => Window_Address_Pointers.Pointer);

   function To_Address is new Ada.Unchecked_Conversion
     (Source => Window_Address_Pointers.Pointer,
      Target => System.Address);

   function To_Window_Pointer is new Ada.Unchecked_Conversion
     (Source => System.Address,
      Target => Raw_Video.Window_Pointer);

   function To_Window_Address is new Ada.Unchecked_Conversion
     (Source => Raw_Video.Window_Pointer,
      Target => System.Address);

   function To_Surface_Pointer is new Ada.Unchecked_Conversion
     (Source => SDL.Video.Surfaces.Internal_Surface_Pointer,
      Target => Raw_Video.Surface_Pointer);

   function To_Internal_Surface_Pointer is new Ada.Unchecked_Conversion
     (Source => Raw_Video.Surface_Pointer,
      Target => SDL.Video.Surfaces.Internal_Surface_Pointer);

   function To_Rectangle_Access is new Ada.Unchecked_Conversion
     (Source => Raw_Rect.Rectangle_Access,
      Target => Rectangle_Access);

   function To_Raw_Hit_Test_Callback is new Ada.Unchecked_Conversion
     (Source => Hit_Test_Callback,
      Target => Raw_Video.Window_Hit_Test_Callback);

   function To_Raw
     (Value : in SDL.Video.Rectangles.Rectangle) return Raw_Rect.Rectangle is
       ((X      => Value.X,
         Y      => Value.Y,
         Width  => Raw_Rect.Dimension (Value.Width),
         Height => Raw_Rect.Dimension (Value.Height)));

   function To_Public
     (Value : in Raw_Rect.Rectangle) return SDL.Video.Rectangles.Rectangle is
       ((X      => Value.X,
         Y      => Value.Y,
         Width  => SDL.Natural_Dimension (Value.Width),
         Height => SDL.Natural_Dimension (Value.Height)));

   function To_Raw
     (Value : in Flash_Operations) return Raw_Video.Flash_Operation is
   begin
      case Value is
         when Flash_Cancel =>
            return 0;
         when Flash_Briefly =>
            return 1;
         when Flash_Until_Focused =>
            return 2;
      end case;
   end To_Raw;

   function To_Raw
     (Value : in Progress_States) return Raw_Video.Progress_State is
   begin
      case Value is
         when Invalid_Progress_State =>
            return -1;
         when No_Progress =>
            return 0;
         when Indeterminate_Progress =>
            return 1;
         when Normal_Progress =>
            return 2;
         when Paused_Progress =>
            return 3;
         when Error_Progress =>
            return 4;
      end case;
   end To_Raw;

   function To_Public
     (Value : in Raw_Video.Progress_State) return Progress_States is
   begin
      case Value is
         when -1 =>
            return Invalid_Progress_State;
         when 0 =>
            return No_Progress;
         when 1 =>
            return Indeterminate_Progress;
         when 2 =>
            return Normal_Progress;
         when 3 =>
            return Paused_Progress;
         when 4 =>
            return Error_Progress;
         when others =>
            return Invalid_Progress_State;
      end case;
   end To_Public;

   use type System.Address;
   use type C.C_float;
   use type C.ptrdiff_t;
   use type C.size_t;
   use type Display_ID;
   use type Display_ID_Pointers.Pointer;
   use type CS.chars_ptr;
   use type Raw_Video.Display_Mode_Access;
   use type SDL.Video.Pixel_Formats.Pixel_Format_Names;
   use type SDL.Video.Surfaces.Internal_Surface_Pointer;
   use type Window_Address_Pointers.Pointer;

   function SDL_Get_Displays
     (Count : access C.int) return Display_ID_Pointers.Pointer is
       (To_Display_ID_Pointers (Raw_Video.Get_Displays (Count)));

   procedure SDL_Free (Values : in Display_ID_Pointers.Pointer) is
   begin
      Raw_Video.Free (To_Raw_Display_ID_Pointers (Values));
   end SDL_Free;

   procedure SDL_Free (Value : in System.Address) is
   begin
      Raw_Video.Free (Value);
   end SDL_Free;

   function SDL_Get_Window_ID
     (Value : in System.Address) return ID is
       (ID (Raw_Video.Get_Window_ID (To_Window_Pointer (Value))));

   function SDL_Get_Window_From_ID
     (Window_ID : in ID) return System.Address is
       (To_Window_Address
          (Raw_Video.Get_Window_From_ID (Raw_Video.Window_ID (Window_ID))));

   function SDL_Get_Windows
     (Count : access C.int) return Window_Address_Pointers.Pointer is
       (To_Window_Address_Pointers (Raw_Video.Get_Windows (Count)));

   function SDL_Get_Display_For_Window
     (Value : in System.Address) return Display_ID is
       (Raw_Video.Get_Display_For_Window (To_Window_Pointer (Value)));

   function SDL_Get_Window_Properties
     (Value : in System.Address) return SDL.Properties.Property_ID is
       (SDL.Properties.Property_ID
          (Raw_Video.Get_Window_Properties (To_Window_Pointer (Value))));

   function SDL_Get_Window_Flags
     (Value : in System.Address) return Window_Flags is
       (Window_Flags (Raw_Video.Get_Window_Flags (To_Window_Pointer (Value))));

   function SDL_Get_Window_Title
     (Value : in System.Address) return CS.chars_ptr is
       (Raw_Video.Get_Window_Title (To_Window_Pointer (Value)));

   function SDL_Set_Window_Title
     (Value : in System.Address;
      Text  : in C.char_array) return CE.bool is
       (Raw_Video.Set_Window_Title (To_Window_Pointer (Value), Text));

   function SDL_Get_Window_Surface
     (Value : in System.Address)
      return SDL.Video.Surfaces.Internal_Surface_Pointer is
       (To_Internal_Surface_Pointer
          (Raw_Video.Get_Window_Surface (To_Window_Pointer (Value))));

   function SDL_Set_Window_Icon
     (Value : in System.Address;
      Icon  : in SDL.Video.Surfaces.Internal_Surface_Pointer) return CE.bool is
       (Raw_Video.Set_Window_Icon
          (To_Window_Pointer (Value), To_Surface_Pointer (Icon)));

   function SDL_Get_Window_Position
     (Value : in System.Address;
      X     : access C.int;
      Y     : access C.int) return CE.bool is
       (Raw_Video.Get_Window_Position (To_Window_Pointer (Value), X, Y));

   function SDL_Set_Window_Position
     (Value : in System.Address;
      X     : in SDL.Coordinate;
      Y     : in SDL.Coordinate) return CE.bool is
       (Raw_Video.Set_Window_Position
          (To_Window_Pointer (Value), C.int (X), C.int (Y)));

   function SDL_Get_Window_Size
     (Value  : in System.Address;
      Width  : access C.int;
      Height : access C.int) return CE.bool is
       (Raw_Video.Get_Window_Size (To_Window_Pointer (Value), Width, Height));

   function SDL_Set_Window_Size
     (Value  : in System.Address;
      Width  : in SDL.Positive_Dimension;
      Height : in SDL.Positive_Dimension) return CE.bool is
       (Raw_Video.Set_Window_Size
          (To_Window_Pointer (Value), C.int (Width), C.int (Height)));

   function SDL_Get_Window_Size_In_Pixels
     (Value  : in System.Address;
      Width  : access C.int;
      Height : access C.int) return CE.bool is
       (Raw_Video.Get_Window_Size_In_Pixels
          (To_Window_Pointer (Value), Width, Height));

   function SDL_Get_Window_Pixel_Density
     (Value : in System.Address) return C.C_float is
       (Raw_Video.Get_Window_Pixel_Density (To_Window_Pointer (Value)));

   function SDL_Get_Window_Display_Scale
     (Value : in System.Address) return C.C_float is
       (Raw_Video.Get_Window_Display_Scale (To_Window_Pointer (Value)));

   function SDL_Set_Window_Fullscreen_Mode
     (Value : in System.Address;
      Mode  : access constant Internal_Mode) return CE.bool is
       (Raw_Video.Set_Window_Fullscreen_Mode (To_Window_Pointer (Value), Mode));

   function SDL_Get_Closest_Fullscreen_Display_Mode
     (ID                         : in Display_ID;
      Width                      : in C.int;
      Height                     : in C.int;
      Refresh_Rate               : in C.C_float;
      Include_High_Density_Modes : in CE.bool;
      Closest                    : access Internal_Mode) return CE.bool is
       (Raw_Video.Get_Closest_Fullscreen_Display_Mode
          (Raw_Video.Display_ID (ID),
           Width,
           Height,
           Refresh_Rate,
           Include_High_Density_Modes,
           Closest));

   function SDL_Get_Window_Fullscreen_Mode
     (Value : in System.Address) return Internal_Mode_Access is
       (Raw_Video.Get_Window_Fullscreen_Mode (To_Window_Pointer (Value)));

   function SDL_Get_Window_ICC_Profile
     (Value : in System.Address;
      Size  : access C.size_t) return System.Address is
       (Raw_Video.Get_Window_ICC_Profile (To_Window_Pointer (Value), Size));

   function SDL_Get_Window_Pixel_Format
     (Value : in System.Address) return SDL.Video.Pixel_Formats.Pixel_Format_Names is
       (SDL.Video.Pixel_Formats.Pixel_Format_Names
          (Raw_Video.Get_Window_Pixel_Format (To_Window_Pointer (Value))));

   function SDL_Get_Window_Safe_Area
     (Value : in System.Address;
      Area  : access SDL.Video.Rectangles.Rectangle) return CE.bool
   is
   begin
      if Area = null then
         return Raw_Video.Get_Window_Safe_Area (To_Window_Pointer (Value), null);
      end if;

      declare
         Converted : aliased Raw_Rect.Rectangle := Raw_Rect.Null_Rectangle;
         Result    : constant CE.bool :=
           Raw_Video.Get_Window_Safe_Area
             (To_Window_Pointer (Value), Converted'Access);
      begin
         if Boolean (Result) then
            Area.all := To_Public (Converted);
         end if;

         return Result;
      end;
   end SDL_Get_Window_Safe_Area;

   function SDL_Set_Window_Aspect_Ratio
     (Value   : in System.Address;
      Minimum : in C.C_float;
      Maximum : in C.C_float) return CE.bool is
       (Raw_Video.Set_Window_Aspect_Ratio
          (To_Window_Pointer (Value), Minimum, Maximum));

   function SDL_Get_Window_Aspect_Ratio
     (Value   : in System.Address;
      Minimum : access C.C_float;
      Maximum : access C.C_float) return CE.bool is
       (Raw_Video.Get_Window_Aspect_Ratio
          (To_Window_Pointer (Value), Minimum, Maximum));

   function SDL_Get_Window_Borders_Size
     (Value  : in System.Address;
      Top    : access C.int;
      Left   : access C.int;
      Bottom : access C.int;
      Right  : access C.int) return CE.bool is
       (Raw_Video.Get_Window_Borders_Size
          (To_Window_Pointer (Value), Top, Left, Bottom, Right));

   function SDL_Get_Window_Minimum_Size
     (Value  : in System.Address;
      Width  : access C.int;
      Height : access C.int) return CE.bool is
       (Raw_Video.Get_Window_Minimum_Size
          (To_Window_Pointer (Value), Width, Height));

   function SDL_Set_Window_Minimum_Size
     (Value  : in System.Address;
      Width  : in SDL.Natural_Dimension;
      Height : in SDL.Natural_Dimension) return CE.bool is
       (Raw_Video.Set_Window_Minimum_Size
          (To_Window_Pointer (Value), C.int (Width), C.int (Height)));

   function SDL_Get_Window_Maximum_Size
     (Value  : in System.Address;
      Width  : access C.int;
      Height : access C.int) return CE.bool is
       (Raw_Video.Get_Window_Maximum_Size
          (To_Window_Pointer (Value), Width, Height));

   function SDL_Set_Window_Maximum_Size
     (Value  : in System.Address;
      Width  : in SDL.Natural_Dimension;
      Height : in SDL.Natural_Dimension) return CE.bool is
       (Raw_Video.Set_Window_Maximum_Size
          (To_Window_Pointer (Value), C.int (Width), C.int (Height)));

   function SDL_Set_Window_Bordered
     (Value    : in System.Address;
      Bordered : in CE.bool) return CE.bool is
       (Raw_Video.Set_Window_Bordered (To_Window_Pointer (Value), Bordered));

   function SDL_Set_Window_Resizable
     (Value     : in System.Address;
      Resizable : in CE.bool) return CE.bool is
       (Raw_Video.Set_Window_Resizable (To_Window_Pointer (Value), Resizable));

   function SDL_Set_Window_Always_On_Top
     (Value  : in System.Address;
      Enable : in CE.bool) return CE.bool is
       (Raw_Video.Set_Window_Always_On_Top
          (To_Window_Pointer (Value), Enable));

   function SDL_Set_Window_Fill_Document
     (Value  : in System.Address;
      Enable : in CE.bool) return CE.bool is
       (Raw_Video.Set_Window_Fill_Document
          (To_Window_Pointer (Value), Enable));

   function SDL_Show_Window
     (Value : in System.Address) return CE.bool is
       (Raw_Video.Show_Window (To_Window_Pointer (Value)));

   function SDL_Hide_Window
     (Value : in System.Address) return CE.bool is
       (Raw_Video.Hide_Window (To_Window_Pointer (Value)));

   function SDL_Maximize_Window
     (Value : in System.Address) return CE.bool is
       (Raw_Video.Maximize_Window (To_Window_Pointer (Value)));

   function SDL_Minimize_Window
     (Value : in System.Address) return CE.bool is
       (Raw_Video.Minimize_Window (To_Window_Pointer (Value)));

   function SDL_Raise_Window
     (Value : in System.Address) return CE.bool is
       (Raw_Video.Raise_Window (To_Window_Pointer (Value)));

   function SDL_Restore_Window
     (Value : in System.Address) return CE.bool is
       (Raw_Video.Restore_Window (To_Window_Pointer (Value)));

   function SDL_Set_Window_Fullscreen
     (Value      : in System.Address;
      Fullscreen : in CE.bool) return CE.bool is
       (Raw_Video.Set_Window_Fullscreen
          (To_Window_Pointer (Value), Fullscreen));

   function SDL_Sync_Window
     (Value : in System.Address) return CE.bool is
       (Raw_Video.Sync_Window (To_Window_Pointer (Value)));

   function SDL_Window_Has_Surface
     (Value : in System.Address) return CE.bool is
       (Raw_Video.Window_Has_Surface (To_Window_Pointer (Value)));

   function SDL_Set_Window_Surface_VSync
     (Value    : in System.Address;
      Interval : in Window_Surface_V_Sync_Intervals) return CE.bool is
       (Raw_Video.Set_Window_Surface_VSync
          (To_Window_Pointer (Value), Interval));

   function SDL_Get_Window_Surface_VSync
     (Value    : in System.Address;
      Interval : access Window_Surface_V_Sync_Intervals) return CE.bool is
       (Raw_Video.Get_Window_Surface_VSync
          (To_Window_Pointer (Value), Interval));

   function SDL_Update_Window_Surface
     (Value : in System.Address) return CE.bool is
       (Raw_Video.Update_Window_Surface (To_Window_Pointer (Value)));

   function SDL_Update_Window_Surface_Rects
     (Value      : in System.Address;
      Rectangles : access constant SDL.Video.Rectangles.Rectangle;
      Total      : in C.int) return CE.bool
   is
   begin
      if Rectangles = null then
         return
           Raw_Video.Update_Window_Surface_Rects
             (To_Window_Pointer (Value), null, Total);
      end if;

      declare
         Converted : aliased constant Raw_Rect.Rectangle := To_Raw (Rectangles.all);
      begin
         return
           Raw_Video.Update_Window_Surface_Rects
             (To_Window_Pointer (Value), Converted'Access, Total);
      end;
   end SDL_Update_Window_Surface_Rects;

   function SDL_Update_Window_Surface_Rects
     (Value      : in System.Address;
      Rectangles : in SDL.Video.Rectangles.Rectangle_Arrays;
      Total      : in C.int) return CE.bool
   is
      Count : constant C.int := C.int'Min (Total, C.int (Rectangles'Length));
   begin
      if Count <= 0 then
         return
           Raw_Video.Update_Window_Surface_Rects
             (To_Window_Pointer (Value), null, 0);
      end if;

      declare
         Converted : Raw_Rect.Rectangle_Array (0 .. C.size_t (Count - 1));
      begin
         for Index in Converted'Range loop
            Converted (Index) :=
              To_Raw
                (Rectangles
                   (Rectangles'First + Index - Converted'First));
         end loop;

         return
           Raw_Video.Update_Window_Surface_Rects
             (To_Window_Pointer (Value), Converted (Converted'First)'Access, Count);
      end;
   end SDL_Update_Window_Surface_Rects;

   function SDL_Destroy_Window_Surface
     (Value : in System.Address) return CE.bool is
       (Raw_Video.Destroy_Window_Surface (To_Window_Pointer (Value)));

   function SDL_Set_Window_Keyboard_Grab
     (Value   : in System.Address;
      Grabbed : in CE.bool) return CE.bool is
       (Raw_Video.Set_Window_Keyboard_Grab
          (To_Window_Pointer (Value), Grabbed));

   function SDL_Get_Window_Keyboard_Grab
     (Value : in System.Address) return CE.bool is
       (Raw_Video.Get_Window_Keyboard_Grab (To_Window_Pointer (Value)));

   function SDL_Set_Window_Mouse_Grab
     (Value   : in System.Address;
      Grabbed : in CE.bool) return CE.bool is
       (Raw_Video.Set_Window_Mouse_Grab
          (To_Window_Pointer (Value), Grabbed));

   function SDL_Get_Window_Mouse_Grab
     (Value : in System.Address) return CE.bool is
       (Raw_Video.Get_Window_Mouse_Grab (To_Window_Pointer (Value)));

   function SDL_Get_Grabbed_Window return System.Address
   is
     (To_Window_Address (Raw_Video.Get_Grabbed_Window));

   function SDL_Set_Window_Mouse_Rect
     (Value     : in System.Address;
      Rectangle : access constant SDL.Video.Rectangles.Rectangle) return CE.bool
   is
   begin
      if Rectangle = null then
         return Raw_Video.Set_Window_Mouse_Rect (To_Window_Pointer (Value), null);
      end if;

      declare
         Converted : aliased constant Raw_Rect.Rectangle := To_Raw (Rectangle.all);
      begin
         return
           Raw_Video.Set_Window_Mouse_Rect
             (To_Window_Pointer (Value), Converted'Access);
      end;
   end SDL_Set_Window_Mouse_Rect;

   function SDL_Get_Window_Mouse_Rect
     (Value : in System.Address)
      return access constant SDL.Video.Rectangles.Rectangle is
       (To_Rectangle_Access
          (Raw_Video.Get_Window_Mouse_Rect (To_Window_Pointer (Value))));

   function SDL_Set_Window_Opacity
     (Value   : in System.Address;
      Opacity : in C.C_float) return CE.bool is
       (Raw_Video.Set_Window_Opacity (To_Window_Pointer (Value), Opacity));

   function SDL_Get_Window_Opacity
     (Value : in System.Address) return C.C_float is
       (Raw_Video.Get_Window_Opacity (To_Window_Pointer (Value)));

   function SDL_Set_Window_Parent
     (Value  : in System.Address;
      Parent : in System.Address) return CE.bool is
       (Raw_Video.Set_Window_Parent
          (To_Window_Pointer (Value), To_Window_Pointer (Parent)));

   function SDL_Get_Window_Parent
     (Value : in System.Address) return System.Address is
       (To_Window_Address
          (Raw_Video.Get_Window_Parent (To_Window_Pointer (Value))));

   function SDL_Set_Window_Modal
     (Value : in System.Address;
      Modal : in CE.bool) return CE.bool is
       (Raw_Video.Set_Window_Modal (To_Window_Pointer (Value), Modal));

   function SDL_Set_Window_Focusable
     (Value     : in System.Address;
      Focusable : in CE.bool) return CE.bool is
       (Raw_Video.Set_Window_Focusable
          (To_Window_Pointer (Value), Focusable));

   function SDL_Show_Window_System_Menu
     (Value : in System.Address;
      X     : in SDL.Coordinate;
      Y     : in SDL.Coordinate) return CE.bool is
       (Raw_Video.Show_Window_System_Menu
          (To_Window_Pointer (Value), C.int (X), C.int (Y)));

   function SDL_Set_Window_Hit_Test
     (Value     : in System.Address;
      Callback  : in Hit_Test_Callback;
      User_Data : in System.Address) return CE.bool is
       (Raw_Video.Set_Window_Hit_Test
          (To_Window_Pointer (Value), To_Raw_Hit_Test_Callback (Callback), User_Data));

   function SDL_Set_Window_Shape
     (Value : in System.Address;
      Shape : in SDL.Video.Surfaces.Internal_Surface_Pointer) return CE.bool is
       (Raw_Video.Set_Window_Shape
          (To_Window_Pointer (Value), To_Surface_Pointer (Shape)));

   function SDL_Flash_Window
     (Value     : in System.Address;
      Operation : in Flash_Operations) return CE.bool is
       (Raw_Video.Flash_Window (To_Window_Pointer (Value), To_Raw (Operation)));

   function SDL_Set_Window_Progress_State
     (Value : in System.Address;
      State : in Progress_States) return CE.bool is
       (Raw_Video.Set_Window_Progress_State
          (To_Window_Pointer (Value), To_Raw (State)));

   function SDL_Get_Window_Progress_State
     (Value : in System.Address) return Progress_States is
       (To_Public
          (Raw_Video.Get_Window_Progress_State (To_Window_Pointer (Value))));

   function SDL_Set_Window_Progress_Value
     (Value : in System.Address;
      Scale : in C.C_float) return CE.bool is
       (Raw_Video.Set_Window_Progress_Value
          (To_Window_Pointer (Value), Scale));

   function SDL_Get_Window_Progress_Value
     (Value : in System.Address) return C.C_float is
       (Raw_Video.Get_Window_Progress_Value (To_Window_Pointer (Value)));

   procedure SDL_Destroy_Window (Value : in System.Address) is
   begin
      Raw_Video.Destroy_Window (To_Window_Pointer (Value));
   end SDL_Destroy_Window;

   function To_C_Bool (Value : in Boolean) return CE.bool is
     (CE.bool'Val (Boolean'Pos (Value)));

   procedure Require_Window (Self : in Window) is
   begin
      if Self.Internal = System.Null_Address then
         raise Window_Error with "Invalid window";
      end if;
   end Require_Window;

   procedure Raise_Window_Error is
   begin
      raise Window_Error with SDL.Error.Get;
   end Raise_Window_Error;

   function Index_For_ID (ID : in Display_ID) return SDL.Video.Displays.Display_Indices is
      Count : aliased C.int := 0;
      List  : constant Display_ID_Pointers.Pointer := SDL_Get_Displays (Count'Access);
   begin
      if List = null or else Count < 1 then
         if List /= null then
            SDL_Free (List);
         end if;

         raise Window_Error with SDL.Error.Get;
      end if;

      for Index in 0 .. Natural (Count - 1) loop
         declare
            Position : constant Display_ID_Pointers.Pointer :=
              List + C.ptrdiff_t (Index);
         begin
            if Position.all = ID then
               SDL_Free (List);
               return SDL.Video.Displays.Display_Indices (Index + 1);
            end if;
         end;
      end loop;

      SDL_Free (List);
      raise Window_Error with SDL.Error.Get;
   end Index_For_ID;

   function To_Refresh_Rate
     (Value : in C.C_float) return SDL.Video.Displays.Refresh_Rates is
   begin
      if Value <= C.C_float (0.0) then
         return SDL.Video.Displays.Refresh_Rates'First;
      elsif Value >= C.C_float (SDL.Video.Displays.Refresh_Rates'Last) then
         return SDL.Video.Displays.Refresh_Rates'Last;
      else
         return SDL.Video.Displays.Refresh_Rates (Integer (Float (Value) + 0.5));
      end if;
   end To_Refresh_Rate;

   function To_Public
     (Value : in Internal_Mode) return SDL.Video.Displays.Mode is
   begin
      return
        (Format       => SDL.Video.Pixel_Formats.Pixel_Format_Names (Value.Format),
         Width        => Value.Width,
         Height       => Value.Height,
         Refresh_Rate => To_Refresh_Rate (Value.Refresh_Rate),
         Driver_Data  => Value.Internal);
   end To_Public;

   function To_Internal
     (Value : in SDL.Video.Displays.Mode) return Internal_Mode is
   begin
      return
        (Display       => 0,
         Format        => Raw_Video.Pixel_Format_Name (Value.Format),
         Width         => Value.Width,
         Height        => Value.Height,
         Pixel_Density => 0.0,
         Refresh_Rate  => C.C_float (Value.Refresh_Rate),
         Refresh_Numerator   => 0,
         Refresh_Denominator => 0,
         Internal            => Value.Driver_Data);
   end To_Internal;

   function Make_Window_From_Pointer
     (Internal : in System.Address;
      Owns     : in Boolean := False) return Window is
   begin
      return Result : Window do
         Result.Internal := Internal;
         Result.Owns := Owns;
      end return;
   end Make_Window_From_Pointer;

   function Get_Internal (Self : in Window) return System.Address is
     (Self.Internal);

   function Is_Null (Self : in Window) return Boolean is
     (Self.Internal = System.Null_Address);

   function Get (Window_ID : in ID) return Window is
   begin
      return Make_Window_From_Pointer
        (SDL_Get_Window_From_ID (Window_ID), Owns => False);
   end Get;

   function Get_Windows return ID_Lists is
      Count : aliased C.int := 0;
      Raw   : constant Window_Address_Pointers.Pointer := SDL_Get_Windows (Count'Access);
   begin
      if Count <= 0 then
         if Raw /= null then
            SDL_Free (To_Address (Raw));
         end if;

         return [];
      end if;

      if Raw = null then
         Raise_Window_Error;
      end if;

      declare
         Source : constant Window_Address_Array :=
           Window_Address_Pointers.Value (Raw, C.ptrdiff_t (Count));
      begin
         return Result : ID_Lists (0 .. Natural (Count) - 1) do
            for Index in Result'Range loop
               declare
                  Window_Ptr : constant System.Address :=
                    Source (Source'First + C.ptrdiff_t (Index - Result'First));
               begin
                  Result (Index) :=
                    (if Window_Ptr = System.Null_Address
                     then 0
                     else SDL_Get_Window_ID (Window_Ptr));
               end;
            end loop;

            SDL_Free (To_Address (Raw));
         exception
            when others =>
               SDL_Free (To_Address (Raw));
               raise;
         end return;
      end;
   end Get_Windows;

   function Get_ID (Self : in Window) return ID is
   begin
      if Self.Internal = System.Null_Address then
         return 0;
      end if;

      return SDL_Get_Window_ID (Self.Internal);
   end Get_ID;

   function Get_Display
     (Self : in Window) return SDL.Video.Displays.Display_Indices is
   begin
      Require_Window (Self);

      declare
         Current_Display : constant Display_ID :=
           SDL_Get_Display_For_Window (Self.Internal);
      begin
         if Current_Display = 0 then
            Raise_Window_Error;
         end if;

         return Index_For_ID (Current_Display);
      end;
   end Get_Display;

   function Get_Properties
     (Self : in Window) return SDL.Properties.Property_ID
   is
      Props : SDL.Properties.Property_ID;
   begin
      Require_Window (Self);

      Props := SDL_Get_Window_Properties (Self.Internal);

      if Props = SDL.Properties.Null_Property_ID then
         Raise_Window_Error;
      end if;

      return Props;
   end Get_Properties;

   function Get_Flags (Self : in Window) return Window_Flags is
   begin
      Require_Window (Self);
      return SDL_Get_Window_Flags (Self.Internal);
   end Get_Flags;

   function Get_Title (Self : in Window) return String is
   begin
      Require_Window (Self);

      declare
         Title : constant CS.chars_ptr := SDL_Get_Window_Title (Self.Internal);
      begin
         if Title = CS.Null_Ptr then
            return "";
         end if;

         return CS.Value (Title);
      end;
   end Get_Title;

   function Get_Surface
     (Self : in Window) return SDL.Video.Surfaces.Surface
   is
   begin
      Require_Window (Self);

      declare
         Surface : constant SDL.Video.Surfaces.Internal_Surface_Pointer :=
           SDL_Get_Window_Surface (Self.Internal);
      begin
         if Surface = null then
            Raise_Window_Error;
         end if;

         return Surface_Internal.Make_From_Pointer (Surface, Owns => False);
      end;
   end Get_Surface;

   procedure Get_Position
     (Self : in Window;
      X    : out SDL.Coordinate;
      Y    : out SDL.Coordinate)
   is
      Raw_X : aliased C.int := 0;
      Raw_Y : aliased C.int := 0;
   begin
      Require_Window (Self);

      if not Boolean
          (SDL_Get_Window_Position
             (Self.Internal, Raw_X'Access, Raw_Y'Access))
      then
         Raise_Window_Error;
      end if;

      X := SDL.Coordinate (Raw_X);
      Y := SDL.Coordinate (Raw_Y);
   end Get_Position;

   function Get_Position (Self : in Window) return SDL.Coordinates is
      X : SDL.Coordinate;
      Y : SDL.Coordinate;
   begin
      Get_Position (Self, X, Y);
      return (X => X, Y => Y);
   end Get_Position;

   procedure Set_Position
     (Self     : in out Window;
      Position : in SDL.Coordinates) is
   begin
      Set_Position (Self, Position.X, Position.Y);
   end Set_Position;

   procedure Set_Position
     (Self : in out Window;
      X    : in SDL.Coordinate;
      Y    : in SDL.Coordinate) is
   begin
      Require_Window (Self);

      if not Boolean (SDL_Set_Window_Position (Self.Internal, X, Y)) then
         Raise_Window_Error;
      end if;
   end Set_Position;

   procedure Get_Size
     (Self          : in Window;
      Width, Height : out SDL.Natural_Dimension)
   is
      Raw_Width  : aliased C.int := 0;
      Raw_Height : aliased C.int := 0;
   begin
      Require_Window (Self);

      if not Boolean
          (SDL_Get_Window_Size
             (Self.Internal, Raw_Width'Access, Raw_Height'Access))
      then
         Raise_Window_Error;
      end if;

      Width := SDL.Natural_Dimension (Raw_Width);
      Height := SDL.Natural_Dimension (Raw_Height);
   end Get_Size;

   function Get_Size (Self : in Window) return SDL.Sizes is
      Width  : SDL.Natural_Dimension;
      Height : SDL.Natural_Dimension;
   begin
      Get_Size (Self, Width, Height);
      return (Width => Width, Height => Height);
   end Get_Size;

   procedure Set_Size
     (Self : in out Window;
      Size : in SDL.Positive_Sizes) is
   begin
      Set_Size (Self, Size.Width, Size.Height);
   end Set_Size;

   procedure Set_Size
     (Self   : in out Window;
      Width  : in SDL.Positive_Dimension;
      Height : in SDL.Positive_Dimension) is
   begin
      Require_Window (Self);

      if not Boolean (SDL_Set_Window_Size (Self.Internal, Width, Height)) then
         Raise_Window_Error;
      end if;
   end Set_Size;

   procedure Get_Size_In_Pixels
     (Self          : in Window;
      Width, Height : out SDL.Natural_Dimension)
   is
      Raw_Width  : aliased C.int := 0;
      Raw_Height : aliased C.int := 0;
   begin
      Require_Window (Self);

      if not Boolean
          (SDL_Get_Window_Size_In_Pixels
             (Self.Internal, Raw_Width'Access, Raw_Height'Access))
      then
         Raise_Window_Error;
      end if;

      Width := SDL.Natural_Dimension (Raw_Width);
      Height := SDL.Natural_Dimension (Raw_Height);
   end Get_Size_In_Pixels;

   function Get_Size_In_Pixels (Self : in Window) return SDL.Sizes is
      Width  : SDL.Natural_Dimension;
      Height : SDL.Natural_Dimension;
   begin
      Get_Size_In_Pixels (Self, Width, Height);
      return (Width => Width, Height => Height);
   end Get_Size_In_Pixels;

   function Get_Pixel_Density (Self : in Window) return Float is
   begin
      Require_Window (Self);

      declare
         Density : constant C.C_float :=
           SDL_Get_Window_Pixel_Density (Self.Internal);
      begin
         if Density <= 0.0 then
            Raise_Window_Error;
         end if;

         return Float (Density);
      end;
   end Get_Pixel_Density;

   function Get_Display_Scale (Self : in Window) return Float is
   begin
      Require_Window (Self);

      declare
         Scale : constant C.C_float :=
           SDL_Get_Window_Display_Scale (Self.Internal);
      begin
         if Scale <= 0.0 then
            Raise_Window_Error;
         end if;

         return Float (Scale);
      end;
   end Get_Display_Scale;

   procedure Set_Fullscreen_Mode
     (Self : in out Window;
      Mode : in SDL.Video.Displays.Mode)
   is
      Direct   : aliased constant Internal_Mode := To_Internal (Mode);
      Resolved : aliased Internal_Mode :=
        (Display       => 0,
         Format        => Raw_Video.Pixel_Format_Name
           (SDL.Video.Pixel_Formats.Pixel_Format_Unknown),
         Width         => 0,
         Height        => 0,
         Pixel_Density => 0.0,
         Refresh_Rate  => 0.0,
         Refresh_Numerator   => 0,
         Refresh_Denominator => 0,
         Internal            => System.Null_Address);
   begin
      Require_Window (Self);

      if not Boolean
          (SDL_Set_Window_Fullscreen_Mode (Self.Internal, Direct'Access))
      then
         declare
            Display : constant Display_ID :=
              SDL_Get_Display_For_Window (Self.Internal);
         begin
            if Display = 0 then
               Raise_Window_Error;
            end if;

            if Boolean
                (SDL_Get_Closest_Fullscreen_Display_Mode
                   (ID                         => Display,
                    Width                      => Mode.Width,
                    Height                     => Mode.Height,
                    Refresh_Rate               => C.C_float (Mode.Refresh_Rate),
                    Include_High_Density_Modes => To_C_Bool (True),
                    Closest                    => Resolved'Access))
              and then Boolean
                (SDL_Set_Window_Fullscreen_Mode
                   (Self.Internal, Resolved'Access))
            then
               return;
            end if;

            Raise_Window_Error;
         end;
      end if;
   end Set_Fullscreen_Mode;

   procedure Reset_Fullscreen_Mode (Self : in out Window) is
   begin
      Require_Window (Self);

      if not Boolean
          (SDL_Set_Window_Fullscreen_Mode (Self.Internal, null))
      then
         Raise_Window_Error;
      end if;
   end Reset_Fullscreen_Mode;

   function Get_Fullscreen_Mode
     (Self : in Window;
      Mode : out SDL.Video.Displays.Mode) return Boolean is
   begin
      Require_Window (Self);

      declare
         Internal : constant Internal_Mode_Access :=
           SDL_Get_Window_Fullscreen_Mode (Self.Internal);
      begin
         if Internal = null then
            return False;
         end if;

         Mode := To_Public (Internal.all);
         return True;
      end;
   end Get_Fullscreen_Mode;

   function Get_ICC_Profile (Self : in Window) return Byte_Arrays is
      Size  : aliased C.size_t := 0;
      Data  : System.Address := System.Null_Address;
      Bytes : U8_Pointers.Pointer := null;
   begin
      Require_Window (Self);

      Data := SDL_Get_Window_ICC_Profile (Self.Internal, Size'Access);
      Bytes := To_U8_Pointer (Data);

      if Data = System.Null_Address then
         Raise_Window_Error;
      end if;

      if Size = 0 then
         SDL_Free (Data);
         return Result : Byte_Arrays (1 .. 0) do
            null;
         end return;
      end if;

      return Result : Byte_Arrays (0 .. Natural (Size) - 1) do
         for Index in Result'Range loop
            declare
               Position : constant U8_Pointers.Pointer :=
                 U8_Pointers."+" (Bytes, C.ptrdiff_t (Index));
            begin
               Result (Index) := Position.all;
            end;
         end loop;

         SDL_Free (Data);
      end return;
   end Get_ICC_Profile;

   function Pixel_Format
     (Self : in Window) return SDL.Video.Pixel_Formats.Pixel_Format_Names is
   begin
      Require_Window (Self);

      declare
         Format : constant SDL.Video.Pixel_Formats.Pixel_Format_Names :=
           SDL_Get_Window_Pixel_Format (Self.Internal);
      begin
         if Format = SDL.Video.Pixel_Formats.Pixel_Format_Unknown then
            Raise_Window_Error;
         end if;

         return Format;
      end;
   end Pixel_Format;

   function Get_Safe_Area
     (Self : in Window) return SDL.Video.Rectangles.Rectangle
   is
      Result : aliased SDL.Video.Rectangles.Rectangle :=
        SDL.Video.Rectangles.Null_Rectangle;
   begin
      Require_Window (Self);

      if not Boolean
          (SDL_Get_Window_Safe_Area (Self.Internal, Result'Access))
      then
         Raise_Window_Error;
      end if;

      return Result;
   end Get_Safe_Area;

   procedure Set_Aspect_Ratio
     (Self         : in out Window;
      Aspect_Ratio : in Aspect_Ratios) is
   begin
      Set_Aspect_Ratio (Self, Aspect_Ratio.Minimum, Aspect_Ratio.Maximum);
   end Set_Aspect_Ratio;

   procedure Set_Aspect_Ratio
     (Self    : in out Window;
      Minimum : in Float;
      Maximum : in Float) is
   begin
      Require_Window (Self);

      if not Boolean
          (SDL_Set_Window_Aspect_Ratio
             (Self.Internal, C.C_float (Minimum), C.C_float (Maximum)))
      then
         Raise_Window_Error;
      end if;
   end Set_Aspect_Ratio;

   function Get_Aspect_Ratio
     (Self : in Window) return Aspect_Ratios
   is
      Minimum : aliased C.C_float := 0.0;
      Maximum : aliased C.C_float := 0.0;
   begin
      Require_Window (Self);

      if not Boolean
          (SDL_Get_Window_Aspect_Ratio
             (Self.Internal, Minimum'Access, Maximum'Access))
      then
         Raise_Window_Error;
      end if;

      return (Minimum => Float (Minimum), Maximum => Float (Maximum));
   end Get_Aspect_Ratio;

   function Get_Borders_Size
     (Self    : in Window;
      Borders : out Border_Sizes) return Boolean
   is
      Top    : aliased C.int := 0;
      Left   : aliased C.int := 0;
      Bottom : aliased C.int := 0;
      Right  : aliased C.int := 0;
   begin
      Require_Window (Self);

      if not Boolean
          (SDL_Get_Window_Borders_Size
             (Self.Internal,
              Top'Access,
              Left'Access,
              Bottom'Access,
              Right'Access))
      then
         Borders := (Top => 0, Left => 0, Bottom => 0, Right => 0);
         return False;
      end if;

      Borders :=
        (Top    => SDL.Dimension (Top),
         Left   => SDL.Dimension (Left),
         Bottom => SDL.Dimension (Bottom),
         Right  => SDL.Dimension (Right));
      return True;
   end Get_Borders_Size;

   function Get_Maximum_Size (Self : in Window) return SDL.Sizes is
      Width  : aliased C.int := 0;
      Height : aliased C.int := 0;
   begin
      Require_Window (Self);

      if not Boolean
          (SDL_Get_Window_Maximum_Size
             (Self.Internal, Width'Access, Height'Access))
      then
         Raise_Window_Error;
      end if;

      return
        (Width  => SDL.Natural_Dimension (Width),
         Height => SDL.Natural_Dimension (Height));
   end Get_Maximum_Size;

   procedure Set_Maximum_Size
     (Self : in out Window;
      Size : in SDL.Natural_Sizes) is
   begin
      Set_Maximum_Size (Self, Size.Width, Size.Height);
   end Set_Maximum_Size;

   procedure Set_Maximum_Size
     (Self   : in out Window;
      Width  : in SDL.Natural_Dimension;
      Height : in SDL.Natural_Dimension) is
   begin
      Require_Window (Self);

      if not Boolean
          (SDL_Set_Window_Maximum_Size (Self.Internal, Width, Height))
      then
         Raise_Window_Error;
      end if;
   end Set_Maximum_Size;

   function Get_Minimum_Size (Self : in Window) return SDL.Sizes is
      Width  : aliased C.int := 0;
      Height : aliased C.int := 0;
   begin
      Require_Window (Self);

      if not Boolean
          (SDL_Get_Window_Minimum_Size
             (Self.Internal, Width'Access, Height'Access))
      then
         Raise_Window_Error;
      end if;

      return
        (Width  => SDL.Natural_Dimension (Width),
         Height => SDL.Natural_Dimension (Height));
   end Get_Minimum_Size;

   procedure Set_Minimum_Size
     (Self : in out Window;
      Size : in SDL.Natural_Sizes) is
   begin
      Set_Minimum_Size (Self, Size.Width, Size.Height);
   end Set_Minimum_Size;

   procedure Set_Minimum_Size
     (Self   : in out Window;
      Width  : in SDL.Natural_Dimension;
      Height : in SDL.Natural_Dimension) is
   begin
      Require_Window (Self);

      if not Boolean
          (SDL_Set_Window_Minimum_Size (Self.Internal, Width, Height))
      then
         Raise_Window_Error;
      end if;
   end Set_Minimum_Size;

   procedure Set_Bordered
     (Self     : in out Window;
      Bordered : in Boolean) is
   begin
      Require_Window (Self);

      if not Boolean
          (SDL_Set_Window_Bordered (Self.Internal, To_C_Bool (Bordered)))
      then
         Raise_Window_Error;
      end if;
   end Set_Bordered;

   procedure Set_Resizable
     (Self      : in out Window;
      Resizable : in Boolean) is
   begin
      Require_Window (Self);

      if not Boolean
          (SDL_Set_Window_Resizable (Self.Internal, To_C_Bool (Resizable)))
      then
         Raise_Window_Error;
      end if;
   end Set_Resizable;

   procedure Set_Always_On_Top
     (Self   : in out Window;
      Enable : in Boolean) is
   begin
      Require_Window (Self);

      if not Boolean
          (SDL_Set_Window_Always_On_Top (Self.Internal, To_C_Bool (Enable)))
      then
         Raise_Window_Error;
      end if;
   end Set_Always_On_Top;

   procedure Set_Fill_Document
     (Self   : in out Window;
      Enable : in Boolean) is
   begin
      Require_Window (Self);

      if not Boolean
          (SDL_Set_Window_Fill_Document (Self.Internal, To_C_Bool (Enable)))
      then
         Raise_Window_Error;
      end if;
   end Set_Fill_Document;

   procedure Set_Title (Self : in Window; Title : in String) is
   begin
      Require_Window (Self);

      if not Boolean (SDL_Set_Window_Title (Self.Internal, C.To_C (Title))) then
         Raise_Window_Error;
      end if;
   end Set_Title;

   procedure Set_Icon
     (Self : in out Window;
      Icon : in SDL.Video.Surfaces.Surface)
   is
   begin
      Require_Window (Self);

      if not Boolean
          (SDL_Set_Window_Icon
             (Self.Internal, Surface_Internal.Get_Internal (Icon)))
      then
         Raise_Window_Error;
      end if;
   end Set_Icon;

   procedure Show (Self : in Window) is
   begin
      Require_Window (Self);

      if not Boolean (SDL_Show_Window (Self.Internal)) then
         Raise_Window_Error;
      end if;
   end Show;

   procedure Hide (Self : in Window) is
   begin
      Require_Window (Self);

      if not Boolean (SDL_Hide_Window (Self.Internal)) then
         Raise_Window_Error;
      end if;
   end Hide;

   procedure Maximise (Self : in Window) is
   begin
      Require_Window (Self);

      if not Boolean (SDL_Maximize_Window (Self.Internal)) then
         Raise_Window_Error;
      end if;
   end Maximise;

   procedure Minimise (Self : in Window) is
   begin
      Require_Window (Self);

      if not Boolean (SDL_Minimize_Window (Self.Internal)) then
         Raise_Window_Error;
      end if;
   end Minimise;

   procedure Raise_And_Focus (Self : in Window) is
   begin
      Require_Window (Self);

      if not Boolean (SDL_Raise_Window (Self.Internal)) then
         Raise_Window_Error;
      end if;
   end Raise_And_Focus;

   procedure Restore (Self : in Window) is
   begin
      Require_Window (Self);

      if not Boolean (SDL_Restore_Window (Self.Internal)) then
         Raise_Window_Error;
      end if;
   end Restore;

   procedure Set_Fullscreen
     (Self       : in out Window;
      Fullscreen : in Boolean) is
   begin
      Require_Window (Self);

      if not Boolean
          (SDL_Set_Window_Fullscreen (Self.Internal, To_C_Bool (Fullscreen)))
      then
         Raise_Window_Error;
      end if;
   end Set_Fullscreen;

   procedure Sync (Self : in Window) is
   begin
      Require_Window (Self);

      if not Boolean (SDL_Sync_Window (Self.Internal)) then
         Raise_Window_Error;
      end if;
   end Sync;

   function Has_Surface (Self : in Window) return Boolean is
   begin
      Require_Window (Self);
      return Boolean (SDL_Window_Has_Surface (Self.Internal));
   end Has_Surface;

   procedure Set_Surface_V_Sync
     (Self     : in Window;
      Interval : in Window_Surface_V_Sync_Intervals) is
   begin
      Require_Window (Self);

      if not Boolean
          (SDL_Set_Window_Surface_VSync (Self.Internal, Interval))
      then
         Raise_Window_Error;
      end if;
   end Set_Surface_V_Sync;

   function Get_Surface_V_Sync
     (Self : in Window) return Window_Surface_V_Sync_Intervals
   is
      Interval : aliased Window_Surface_V_Sync_Intervals := 0;
   begin
      Require_Window (Self);

      if not Boolean
          (SDL_Get_Window_Surface_VSync (Self.Internal, Interval'Access))
      then
         Raise_Window_Error;
      end if;

      return Interval;
   end Get_Surface_V_Sync;

   procedure Update_Surface (Self : in Window) is
   begin
      Require_Window (Self);

      if not Boolean (SDL_Update_Window_Surface (Self.Internal)) then
         Raise_Window_Error;
      end if;
   end Update_Surface;

   procedure Update_Surface_Rectangle
     (Self      : in Window;
      Rectangle : in SDL.Video.Rectangles.Rectangle)
   is
      Area : aliased SDL.Video.Rectangles.Rectangle := Rectangle;
   begin
      Require_Window (Self);

      if not Boolean
          (SDL_Update_Window_Surface_Rects
             (Self.Internal, Area'Access, 1))
      then
         Raise_Window_Error;
      end if;
   end Update_Surface_Rectangle;

   procedure Update_Surface_Rectangles
     (Self       : in Window;
      Rectangles : in SDL.Video.Rectangles.Rectangle_Arrays) is
   begin
      Require_Window (Self);

      if not Boolean
          (SDL_Update_Window_Surface_Rects
             (Self.Internal, Rectangles, C.int (Rectangles'Length)))
      then
         Raise_Window_Error;
      end if;
   end Update_Surface_Rectangles;

   procedure Destroy_Surface (Self : in Window) is
   begin
      Require_Window (Self);

      if not Boolean (SDL_Destroy_Window_Surface (Self.Internal)) then
         Raise_Window_Error;
      end if;
   end Destroy_Surface;

   procedure Set_Keyboard_Grab
     (Self    : in out Window;
      Grabbed : in Boolean) is
   begin
      Require_Window (Self);

      if not Boolean
          (SDL_Set_Window_Keyboard_Grab
             (Self.Internal, To_C_Bool (Grabbed)))
      then
         Raise_Window_Error;
      end if;
   end Set_Keyboard_Grab;

   function Is_Keyboard_Grabbed (Self : in Window) return Boolean is
   begin
      Require_Window (Self);
      return Boolean (SDL_Get_Window_Keyboard_Grab (Self.Internal));
   end Is_Keyboard_Grabbed;

   procedure Set_Mouse_Grab
     (Self    : in out Window;
      Grabbed : in Boolean) is
   begin
      Require_Window (Self);

      if not Boolean
          (SDL_Set_Window_Mouse_Grab
             (Self.Internal, To_C_Bool (Grabbed)))
      then
         Raise_Window_Error;
      end if;
   end Set_Mouse_Grab;

   function Is_Mouse_Grabbed (Self : in Window) return Boolean is
   begin
      Require_Window (Self);
      return Boolean (SDL_Get_Window_Mouse_Grab (Self.Internal));
   end Is_Mouse_Grabbed;

   function Get_Grabbed return Window is
   begin
      return Make_Window_From_Pointer (SDL_Get_Grabbed_Window, Owns => False);
   end Get_Grabbed;

   procedure Set_Mouse_Rect
     (Self      : in out Window;
      Rectangle : in SDL.Video.Rectangles.Rectangle)
   is
      Area : aliased SDL.Video.Rectangles.Rectangle := Rectangle;
   begin
      Require_Window (Self);

      if not Boolean
          (SDL_Set_Window_Mouse_Rect (Self.Internal, Area'Unchecked_Access))
      then
         Raise_Window_Error;
      end if;
   end Set_Mouse_Rect;

   procedure Clear_Mouse_Rect (Self : in out Window) is
   begin
      Require_Window (Self);

      if not Boolean (SDL_Set_Window_Mouse_Rect (Self.Internal, null)) then
         Raise_Window_Error;
      end if;
   end Clear_Mouse_Rect;

   function Get_Mouse_Rect
     (Self      : in Window;
      Rectangle : out SDL.Video.Rectangles.Rectangle) return Boolean is
   begin
      Require_Window (Self);

      declare
         Area : constant access constant SDL.Video.Rectangles.Rectangle :=
           SDL_Get_Window_Mouse_Rect (Self.Internal);
      begin
         if Area = null then
            Rectangle := SDL.Video.Rectangles.Null_Rectangle;
            return False;
         end if;

         Rectangle := Area.all;
         return True;
      end;
   end Get_Mouse_Rect;

   procedure Set_Opacity
     (Self    : in out Window;
      Opacity : in Float) is
   begin
      Require_Window (Self);

      if not Boolean
          (SDL_Set_Window_Opacity (Self.Internal, C.C_float (Opacity)))
      then
         Raise_Window_Error;
      end if;
   end Set_Opacity;

   function Get_Opacity (Self : in Window) return Float is
   begin
      Require_Window (Self);

      declare
         Opacity : constant C.C_float := SDL_Get_Window_Opacity (Self.Internal);
      begin
         if Opacity < 0.0 then
            Raise_Window_Error;
         end if;

         return Float (Opacity);
      end;
   end Get_Opacity;

   procedure Set_Parent
     (Self   : in out Window;
      Parent : in Window) is
   begin
      Require_Window (Self);

      if not Boolean
          (SDL_Set_Window_Parent (Self.Internal, Parent.Internal))
      then
         Raise_Window_Error;
      end if;
   end Set_Parent;

   function Get_Parent (Self : in Window) return Window is
   begin
      Require_Window (Self);
      return Make_Window_From_Pointer
        (SDL_Get_Window_Parent (Self.Internal), Owns => False);
   end Get_Parent;

   procedure Set_Modal
     (Self  : in out Window;
      Modal : in Boolean) is
   begin
      Require_Window (Self);

      if not Boolean
          (SDL_Set_Window_Modal (Self.Internal, To_C_Bool (Modal)))
      then
         Raise_Window_Error;
      end if;
   end Set_Modal;

   procedure Set_Focusable
     (Self      : in out Window;
      Focusable : in Boolean) is
   begin
      Require_Window (Self);

      if not Boolean
          (SDL_Set_Window_Focusable (Self.Internal, To_C_Bool (Focusable)))
      then
         Raise_Window_Error;
      end if;
   end Set_Focusable;

   procedure Show_System_Menu
     (Self     : in Window;
      Position : in SDL.Coordinates) is
   begin
      Show_System_Menu (Self, Position.X, Position.Y);
   end Show_System_Menu;

   procedure Show_System_Menu
     (Self : in Window;
      X    : in SDL.Coordinate;
      Y    : in SDL.Coordinate) is
   begin
      Require_Window (Self);

      if not Boolean
          (SDL_Show_Window_System_Menu (Self.Internal, X, Y))
      then
         Raise_Window_Error;
      end if;
   end Show_System_Menu;

   procedure Set_Hit_Test
     (Self      : in out Window;
      Callback  : in Hit_Test_Callback;
      User_Data : in System.Address := System.Null_Address) is
   begin
      Require_Window (Self);

      if not Boolean
          (SDL_Set_Window_Hit_Test (Self.Internal, Callback, User_Data))
      then
         Raise_Window_Error;
      end if;
   end Set_Hit_Test;

   procedure Disable_Hit_Test (Self : in out Window) is
   begin
      Require_Window (Self);

      if not Boolean
          (SDL_Set_Window_Hit_Test
             (Self.Internal, null, System.Null_Address))
      then
         Raise_Window_Error;
      end if;
   end Disable_Hit_Test;

   procedure Set_Shape
     (Self  : in out Window;
      Shape : in SDL.Video.Surfaces.Surface)
   is
   begin
      Require_Window (Self);

      if not Boolean
          (SDL_Set_Window_Shape
             (Self.Internal, Surface_Internal.Get_Internal (Shape)))
      then
         Raise_Window_Error;
      end if;
   end Set_Shape;

   procedure Clear_Shape (Self : in out Window) is
   begin
      Require_Window (Self);

      if not Boolean (SDL_Set_Window_Shape (Self.Internal, null)) then
         Raise_Window_Error;
      end if;
   end Clear_Shape;

   procedure Flash
     (Self      : in Window;
      Operation : in Flash_Operations) is
   begin
      Require_Window (Self);

      if not Boolean (SDL_Flash_Window (Self.Internal, Operation)) then
         Raise_Window_Error;
      end if;
   end Flash;

   procedure Set_Progress_State
     (Self  : in out Window;
      State : in Progress_States) is
   begin
      Require_Window (Self);

      if not Boolean
          (SDL_Set_Window_Progress_State (Self.Internal, State))
      then
         Raise_Window_Error;
      end if;
   end Set_Progress_State;

   function Get_Progress_State
     (Self : in Window) return Progress_States is
   begin
      Require_Window (Self);

      declare
         State : constant Progress_States :=
           SDL_Get_Window_Progress_State (Self.Internal);
      begin
         if State = Invalid_Progress_State then
            Raise_Window_Error;
         end if;

         return State;
      end;
   end Get_Progress_State;

   procedure Set_Progress_Value
     (Self  : in out Window;
      Value : in Float) is
   begin
      Require_Window (Self);

      if not Boolean
          (SDL_Set_Window_Progress_Value (Self.Internal, C.C_float (Value)))
      then
         Raise_Window_Error;
      end if;
   end Set_Progress_Value;

   function Get_Progress_Value
     (Self : in Window) return Float is
   begin
      Require_Window (Self);

      declare
         Value : constant C.C_float :=
           SDL_Get_Window_Progress_Value (Self.Internal);
      begin
         if Value < 0.0 then
            Raise_Window_Error;
         end if;

         return Float (Value);
      end;
   end Get_Progress_Value;

   overriding
   procedure Finalize (Self : in out Window) is
   begin
      if Self.Owns and then Self.Internal /= System.Null_Address then
         SDL_Destroy_Window (Self.Internal);
         Self.Internal := System.Null_Address;
      end if;
   end Finalize;
end SDL.Video.Windows;
