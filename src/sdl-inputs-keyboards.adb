with Ada.Unchecked_Conversion;
with Interfaces.C.Pointers;
with Interfaces.C.Extensions;
with Interfaces.C.Strings;
with System;

with SDL.Error;

package body SDL.Inputs.Keyboards is
   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;
   package CS renames Interfaces.C.Strings;

   use type C.ptrdiff_t;
   use type CS.chars_ptr;
   use type System.Address;

   type ID_Arrays is array (C.ptrdiff_t range <>) of aliased ID with
     Convention => C;

   package ID_Pointers is new Interfaces.C.Pointers
     (Index              => C.ptrdiff_t,
      Element            => ID,
      Element_Array      => ID_Arrays,
      Default_Terminator => 0);

   use type ID_Pointers.Pointer;

   function To_Address is new Ada.Unchecked_Conversion
     (Source => ID_Pointers.Pointer,
      Target => System.Address);

   function Props_ID
     (Properties : in SDL.Properties.Property_Set) return SDL.Properties.Property_ID
   is (Properties.Get_ID);

   procedure SDL_Free (Memory : in System.Address) with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_free";

   function Focused_Window return System.Address;
   function Focused_Window return System.Address is
      function SDL_Get_Keyboard_Focus return System.Address with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetKeyboardFocus";
   begin
      return SDL_Get_Keyboard_Focus;
   end Focused_Window;

   procedure Raise_Last_Error
     (Default_Message : in String := "SDL keyboard call failed");
   procedure Raise_Last_Error
     (Default_Message : in String := "SDL keyboard call failed")
   is
      Message : constant String := SDL.Error.Get;
   begin
      if Message = "" then
         raise Keyboard_Error with Default_Message;
      end if;

      raise Keyboard_Error with Message;
   end Raise_Last_Error;

   procedure Free (Items : in out ID_Pointers.Pointer);
   procedure Free (Items : in out ID_Pointers.Pointer) is
   begin
      if Items /= null then
         SDL_Free (To_Address (Items));
         Items := null;
      end if;
   end Free;

   function Copy_IDs
     (Items : in ID_Pointers.Pointer;
      Count : in C.int) return ID_Lists;
   function Copy_IDs
     (Items : in ID_Pointers.Pointer;
      Count : in C.int) return ID_Lists
   is
      Raw : ID_Pointers.Pointer := Items;
   begin
      if Count <= 0 then
         Free (Raw);
         return [];
      end if;

      if Raw = null then
         Raise_Last_Error ("Keyboard enumeration failed");
      end if;

      declare
         Source : constant ID_Arrays :=
           ID_Pointers.Value (Raw, C.ptrdiff_t (Count));
         Result : ID_Lists (0 .. Natural (Count) - 1);
      begin
         for Index in Result'Range loop
            Result (Index) :=
              Source (Source'First + C.ptrdiff_t (Index - Result'First));
         end loop;

         Free (Raw);
         return Result;
      exception
         when others =>
            Free (Raw);
            raise;
      end;
   end Copy_IDs;

   procedure Require_Window
     (Window  : in System.Address;
      Message : in String := "Invalid window");
   procedure Require_Window
     (Window  : in System.Address;
      Message : in String := "Invalid window")
   is
   begin
      if Window = System.Null_Address then
         raise Keyboard_Error with Message;
      end if;
   end Require_Window;

   procedure Require_Focused_Window (Window : out System.Address);
   procedure Require_Focused_Window (Window : out System.Address) is
   begin
      Window := Focused_Window;
      Require_Window (Window, "Keyboard focus is required");
   end Require_Focused_Window;

   procedure Clear_Composition_Internal (Window : in System.Address);
   procedure Clear_Composition_Internal (Window : in System.Address) is
      function SDL_Clear_Composition (Value : in System.Address) return CE.bool with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_ClearComposition";
   begin
      Require_Window (Window);

      if not Boolean (SDL_Clear_Composition (Window)) then
         Raise_Last_Error ("SDL_ClearComposition failed");
      end if;
   end Clear_Composition_Internal;

   function Text_Input_Enabled_Internal
     (Window : in System.Address) return Boolean;
   function Text_Input_Enabled_Internal
     (Window : in System.Address) return Boolean
   is
      function SDL_Text_Input_Active
        (Value : in System.Address) return CE.bool with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_TextInputActive";
   begin
      Require_Window (Window);
      return Boolean (SDL_Text_Input_Active (Window));
   end Text_Input_Enabled_Internal;

   procedure Set_Text_Input_Area_Internal
     (Window    : in System.Address;
      Rectangle : in SDL.Video.Rectangles.Rectangle;
      Cursor    : in SDL.Coordinate);
   procedure Set_Text_Input_Area_Internal
     (Window    : in System.Address;
      Rectangle : in SDL.Video.Rectangles.Rectangle;
      Cursor    : in SDL.Coordinate)
   is
      function SDL_Set_Text_Input_Area
        (Value  : in System.Address;
         Rect   : access constant SDL.Video.Rectangles.Rectangle;
         Cursor : in C.int) return CE.bool with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_SetTextInputArea";

      Rectangle_Copy : aliased constant SDL.Video.Rectangles.Rectangle := Rectangle;
   begin
      Require_Window (Window);

      if not Boolean
          (SDL_Set_Text_Input_Area
             (Window,
              Rectangle_Copy'Access,
              Cursor => C.int (Cursor)))
      then
         Raise_Last_Error ("SDL_SetTextInputArea failed");
      end if;
   end Set_Text_Input_Area_Internal;

   procedure Get_Text_Input_Area_Internal
     (Window    : in System.Address;
      Rectangle : out SDL.Video.Rectangles.Rectangle;
      Cursor    : out SDL.Coordinate);
   procedure Get_Text_Input_Area_Internal
     (Window    : in System.Address;
      Rectangle : out SDL.Video.Rectangles.Rectangle;
      Cursor    : out SDL.Coordinate)
   is
      function SDL_Get_Text_Input_Area
        (Value  : in System.Address;
         Rect   : access SDL.Video.Rectangles.Rectangle;
         Cursor : access C.int) return CE.bool with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetTextInputArea";

      Local_Rectangle : aliased SDL.Video.Rectangles.Rectangle;
      Local_Cursor    : aliased C.int := 0;
   begin
      Require_Window (Window);

      if not Boolean
          (SDL_Get_Text_Input_Area
             (Window,
              Local_Rectangle'Access,
              Local_Cursor'Access))
      then
         Raise_Last_Error ("SDL_GetTextInputArea failed");
      end if;

      Rectangle := Local_Rectangle;
      Cursor := SDL.Coordinate (Local_Cursor);
   end Get_Text_Input_Area_Internal;

   procedure Start_Text_Input_Internal (Window : in System.Address);
   procedure Start_Text_Input_Internal (Window : in System.Address) is
      function SDL_Start_Text_Input
        (Value : in System.Address) return CE.bool with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_StartTextInput";
   begin
      Require_Window (Window);

      if not Boolean (SDL_Start_Text_Input (Window)) then
         Raise_Last_Error ("SDL_StartTextInput failed");
      end if;
   end Start_Text_Input_Internal;

   procedure Start_Text_Input_With_Properties_Internal
     (Window     : in System.Address;
      Properties : in SDL.Properties.Property_ID);
   procedure Start_Text_Input_With_Properties_Internal
     (Window     : in System.Address;
      Properties : in SDL.Properties.Property_ID)
   is
      function SDL_Start_Text_Input_With_Properties
        (Value : in System.Address;
         Props : in SDL.Properties.Property_ID) return CE.bool with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_StartTextInputWithProperties";
   begin
      Require_Window (Window);

      if not Boolean
          (SDL_Start_Text_Input_With_Properties (Window, Properties))
      then
         Raise_Last_Error ("SDL_StartTextInputWithProperties failed");
      end if;
   end Start_Text_Input_With_Properties_Internal;

   procedure Stop_Text_Input_Internal (Window : in System.Address);
   procedure Stop_Text_Input_Internal (Window : in System.Address) is
      function SDL_Stop_Text_Input
        (Value : in System.Address) return CE.bool with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_StopTextInput";
   begin
      Require_Window (Window);

      if not Boolean (SDL_Stop_Text_Input (Window)) then
         Raise_Last_Error ("SDL_StopTextInput failed");
      end if;
   end Stop_Text_Input_Internal;

   procedure Clear_Composition is
      Window : System.Address;
   begin
      Require_Focused_Window (Window);
      Clear_Composition_Internal (Window);
   end Clear_Composition;

   procedure Clear_Composition (Window : in SDL.Video.Windows.Window) is
   begin
      Clear_Composition_Internal (Window.Get_Internal);
   end Clear_Composition;

   function Has_Keyboard return Boolean is
      function SDL_Has_Keyboard return CE.bool with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_HasKeyboard";
   begin
      return Boolean (SDL_Has_Keyboard);
   end Has_Keyboard;

   function Get_Keyboards return ID_Lists is
      function SDL_Get_Keyboards
        (Count : access C.int) return ID_Pointers.Pointer with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetKeyboards";

      Count : aliased C.int := 0;
      Items : constant ID_Pointers.Pointer := SDL_Get_Keyboards (Count'Access);
   begin
      return Copy_IDs (Items, Count);
   end Get_Keyboards;

   function Name (Instance : in ID) return String is
      function SDL_Get_Keyboard_Name_For_ID
        (Value : in ID) return CS.chars_ptr with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetKeyboardNameForID";

      Result : constant CS.chars_ptr := SDL_Get_Keyboard_Name_For_ID (Instance);
   begin
      if Result = CS.Null_Ptr then
         return "";
      end if;

      return CS.Value (Result);
   end Name;

   function Get_Focus return SDL.Video.Windows.ID is
      function SDL_Get_Window_ID (Window : in System.Address) return SDL.Video.Windows.ID with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetWindowID";

      Window : constant System.Address := Focused_Window;
   begin
      if Window = System.Null_Address then
         return 0;
      end if;

      return SDL_Get_Window_ID (Window);
   end Get_Focus;

   function Get_State return Key_State_Access is
      function SDL_Get_Keyboard_State
        (Num_Keys : access C.int) return Key_State_Access with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetKeyboardState";

      Num_Keys : aliased C.int := 0;
   begin
      return SDL_Get_Keyboard_State (Num_Keys'Access);
   end Get_State;

   function Supports_Screen_Keyboard return Boolean is
      function SDL_Has_Screen_Keyboard_Support return CE.bool with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_HasScreenKeyboardSupport";
   begin
      return Boolean (SDL_Has_Screen_Keyboard_Support);
   end Supports_Screen_Keyboard;

   function Is_Screen_Keyboard_Visible
     (Window : in SDL.Video.Windows.Window) return Boolean
   is
      function SDL_Screen_Keyboard_Shown
        (Value : in System.Address) return CE.bool with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_ScreenKeyboardShown";
   begin
      Require_Window (Window.Get_Internal);
      return Boolean
        (SDL_Screen_Keyboard_Shown (Window.Get_Internal));
   end Is_Screen_Keyboard_Visible;

   function Is_Text_Input_Enabled return Boolean is
      Window : constant System.Address := Focused_Window;
   begin
      if Window = System.Null_Address then
         return False;
      end if;

      return Text_Input_Enabled_Internal (Window);
   end Is_Text_Input_Enabled;

   function Is_Text_Input_Enabled
     (Window : in SDL.Video.Windows.Window) return Boolean
   is (Text_Input_Enabled_Internal (Window.Get_Internal));

   function Is_Text_Input_Shown return Boolean is
      function SDL_Screen_Keyboard_Shown
        (Window : in System.Address) return CE.bool with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_ScreenKeyboardShown";

      Window : constant System.Address := Focused_Window;
   begin
      if Window = System.Null_Address then
         return False;
      end if;

      return Boolean (SDL_Screen_Keyboard_Shown (Window));
   end Is_Text_Input_Shown;

   procedure Set_Text_Input_Rectangle
     (Rectangle : in SDL.Video.Rectangles.Rectangle)
   is
      Window : System.Address;
   begin
      Require_Focused_Window (Window);
      Set_Text_Input_Area_Internal (Window, Rectangle, Cursor => 0);
   end Set_Text_Input_Rectangle;

   procedure Set_Text_Input_Rectangle
     (Window    : in SDL.Video.Windows.Window;
      Rectangle : in SDL.Video.Rectangles.Rectangle;
      Cursor    : in SDL.Coordinate := 0)
   is
   begin
      Set_Text_Input_Area_Internal (Window.Get_Internal, Rectangle, Cursor);
   end Set_Text_Input_Rectangle;

   procedure Get_Text_Input_Rectangle
     (Window    : in SDL.Video.Windows.Window;
      Rectangle : out SDL.Video.Rectangles.Rectangle;
      Cursor    : out SDL.Coordinate)
   is
   begin
      Get_Text_Input_Area_Internal (Window.Get_Internal, Rectangle, Cursor);
   end Get_Text_Input_Rectangle;

   function Get_Text_Input_Rectangle
     (Window : in SDL.Video.Windows.Window;
      Cursor : out SDL.Coordinate) return SDL.Video.Rectangles.Rectangle
   is
      Rectangle : SDL.Video.Rectangles.Rectangle;
   begin
      Get_Text_Input_Rectangle (Window, Rectangle, Cursor);
      return Rectangle;
   end Get_Text_Input_Rectangle;

   procedure Get_Text_Input_Rectangle
     (Rectangle : out SDL.Video.Rectangles.Rectangle;
      Cursor    : out SDL.Coordinate)
   is
      Window : System.Address;
   begin
      Require_Focused_Window (Window);
      Get_Text_Input_Area_Internal (Window, Rectangle, Cursor);
   end Get_Text_Input_Rectangle;

   function Get_Text_Input_Rectangle
     (Cursor : out SDL.Coordinate) return SDL.Video.Rectangles.Rectangle
   is
      Rectangle : SDL.Video.Rectangles.Rectangle;
   begin
      Get_Text_Input_Rectangle (Rectangle, Cursor);
      return Rectangle;
   end Get_Text_Input_Rectangle;

   procedure Start_Text_Input is
      Window : System.Address;
   begin
      Require_Focused_Window (Window);
      Start_Text_Input_Internal (Window);
   end Start_Text_Input;

   procedure Start_Text_Input (Window : in SDL.Video.Windows.Window) is
   begin
      Start_Text_Input_Internal (Window.Get_Internal);
   end Start_Text_Input;

   procedure Start_Text_Input
     (Properties : in SDL.Properties.Property_Set)
   is
      Window : System.Address;
   begin
      Require_Focused_Window (Window);
      Start_Text_Input_With_Properties_Internal (Window, Props_ID (Properties));
   end Start_Text_Input;

   procedure Start_Text_Input
     (Window     : in SDL.Video.Windows.Window;
      Properties : in SDL.Properties.Property_Set)
   is
   begin
      Start_Text_Input_With_Properties_Internal
        (Window.Get_Internal, Props_ID (Properties));
   end Start_Text_Input;

   procedure Stop_Text_Input is
      Window : System.Address;
   begin
      Require_Focused_Window (Window);
      Stop_Text_Input_Internal (Window);
   end Stop_Text_Input;

   procedure Stop_Text_Input (Window : in SDL.Video.Windows.Window) is
   begin
      Stop_Text_Input_Internal (Window.Get_Internal);
   end Stop_Text_Input;
end SDL.Inputs.Keyboards;
