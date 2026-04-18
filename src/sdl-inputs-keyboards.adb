with Ada.Unchecked_Conversion;
with Interfaces.C.Strings;
with System;

with SDL.Error;
with SDL.Raw.C_Pointers;
with SDL.Raw.Keyboard;
with SDL.Raw.Properties;
with SDL.Raw.Rect;
with SDL.Raw.Video;

package body SDL.Inputs.Keyboards is
   package CS renames Interfaces.C.Strings;
   package Raw renames SDL.Raw.Keyboard;
   package Raw_Video renames SDL.Raw.Video;

   use type C.ptrdiff_t;
   use type CS.chars_ptr;
   use type Raw.ID_Pointers.Pointer;
   use type System.Address;

   function To_Address is new Ada.Unchecked_Conversion
     (Source => Raw.ID_Pointers.Pointer,
      Target => System.Address);

   function To_Public_Key_State_Access is new Ada.Unchecked_Conversion
     (Source => Raw.Key_State_Access,
      Target => Key_State_Access);

   function To_Address is new Ada.Unchecked_Conversion
     (Source => SDL.Raw.C_Pointers.Windows_Pointer,
      Target => System.Address);

   function To_Raw_Window is new Ada.Unchecked_Conversion
     (Source => System.Address,
      Target => SDL.Raw.C_Pointers.Windows_Pointer);

   function Props_ID
     (Properties : in SDL.Properties.Property_Set) return SDL.Raw.Properties.ID
   is (SDL.Raw.Properties.ID (Properties.Get_ID));

   function Focused_Window return System.Address is
     (To_Address (Raw.Get_Keyboard_Focus));

   function To_Raw
     (Value : in SDL.Video.Rectangles.Rectangle) return SDL.Raw.Rect.Rectangle is
       ((X      => Value.X,
         Y      => Value.Y,
         Width  => SDL.Raw.Rect.Dimension (Value.Width),
         Height => SDL.Raw.Rect.Dimension (Value.Height)));

   function To_Public
     (Value : in SDL.Raw.Rect.Rectangle) return SDL.Video.Rectangles.Rectangle is
       ((X      => Value.X,
         Y      => Value.Y,
         Width  => SDL.Natural_Dimension (Value.Width),
         Height => SDL.Natural_Dimension (Value.Height)));

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

   procedure Free (Items : in out Raw.ID_Pointers.Pointer);
   procedure Free (Items : in out Raw.ID_Pointers.Pointer) is
   begin
      if Items /= null then
         Raw.Free (To_Address (Items));
         Items := null;
      end if;
   end Free;

   function Copy_IDs
     (Items : in Raw.ID_Pointers.Pointer;
      Count : in C.int) return ID_Lists;
   function Copy_IDs
     (Items : in Raw.ID_Pointers.Pointer;
      Count : in C.int) return ID_Lists
   is
      Raw_Items : Raw.ID_Pointers.Pointer := Items;
   begin
      if Count <= 0 then
         Free (Raw_Items);
         return [];
      end if;

      if Raw_Items = null then
         Raise_Last_Error ("Keyboard enumeration failed");
      end if;

      declare
         Source : constant Raw.ID_Array :=
           Raw.ID_Pointers.Value (Raw_Items, C.ptrdiff_t (Count));
         Result : ID_Lists (0 .. Natural (Count) - 1);
      begin
         for Index in Result'Range loop
            Result (Index) :=
              ID (Source (Source'First + C.ptrdiff_t (Index - Result'First)));
         end loop;

         Free (Raw_Items);
         return Result;
      exception
         when others =>
            Free (Raw_Items);
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
   begin
      Require_Window (Window);

      if not Boolean (Raw.Clear_Composition (To_Raw_Window (Window))) then
         Raise_Last_Error ("SDL_ClearComposition failed");
      end if;
   end Clear_Composition_Internal;

   function Text_Input_Enabled_Internal
     (Window : in System.Address) return Boolean;
   function Text_Input_Enabled_Internal
     (Window : in System.Address) return Boolean
   is
   begin
      Require_Window (Window);
      return Boolean (Raw.Text_Input_Active (To_Raw_Window (Window)));
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
      Rectangle_Copy : aliased constant SDL.Raw.Rect.Rectangle := To_Raw (Rectangle);
   begin
      Require_Window (Window);

      if not Boolean
          (Raw.Set_Text_Input_Area
             (To_Raw_Window (Window),
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
      Local_Rectangle : aliased SDL.Raw.Rect.Rectangle := SDL.Raw.Rect.Null_Rectangle;
      Local_Cursor    : aliased C.int := 0;
   begin
      Require_Window (Window);

      if not Boolean
          (Raw.Get_Text_Input_Area
             (To_Raw_Window (Window),
              Local_Rectangle'Access,
              Local_Cursor'Access))
      then
         Raise_Last_Error ("SDL_GetTextInputArea failed");
      end if;

      Rectangle := To_Public (Local_Rectangle);
      Cursor := SDL.Coordinate (Local_Cursor);
   end Get_Text_Input_Area_Internal;

   procedure Start_Text_Input_Internal (Window : in System.Address);
   procedure Start_Text_Input_Internal (Window : in System.Address) is
   begin
      Require_Window (Window);

      if not Boolean (Raw.Start_Text_Input (To_Raw_Window (Window))) then
         Raise_Last_Error ("SDL_StartTextInput failed");
      end if;
   end Start_Text_Input_Internal;

   procedure Start_Text_Input_With_Properties_Internal
     (Window     : in System.Address;
      Properties : in SDL.Raw.Properties.ID);
   procedure Start_Text_Input_With_Properties_Internal
     (Window     : in System.Address;
      Properties : in SDL.Raw.Properties.ID)
   is
   begin
      Require_Window (Window);

      if not Boolean
          (Raw.Start_Text_Input_With_Properties
             (To_Raw_Window (Window), Properties))
      then
         Raise_Last_Error ("SDL_StartTextInputWithProperties failed");
      end if;
   end Start_Text_Input_With_Properties_Internal;

   procedure Stop_Text_Input_Internal (Window : in System.Address);
   procedure Stop_Text_Input_Internal (Window : in System.Address) is
   begin
      Require_Window (Window);

      if not Boolean (Raw.Stop_Text_Input (To_Raw_Window (Window))) then
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
   begin
      return Boolean (Raw.Has_Keyboard);
   end Has_Keyboard;

   function Get_Keyboards return ID_Lists is
      Count : aliased C.int := 0;
      Items : constant Raw.ID_Pointers.Pointer := Raw.Get_Keyboards (Count'Access);
   begin
      return Copy_IDs (Items, Count);
   end Get_Keyboards;

   function Name (Instance : in ID) return String is
      Result : constant CS.chars_ptr :=
        Raw.Get_Keyboard_Name_For_ID (Raw.ID (Instance));
   begin
      if Result = CS.Null_Ptr then
         return "";
      end if;

      return CS.Value (Result);
   end Name;

   function Get_Focus return SDL.Video.Windows.ID is
      Window : constant System.Address := Focused_Window;
   begin
      if Window = System.Null_Address then
         return 0;
      end if;

      return SDL.Video.Windows.ID
        (Raw_Video.Get_Window_ID (Raw_Video.Window_Pointer (To_Raw_Window (Window))));
   end Get_Focus;

   function Get_State return Key_State_Access is
      Num_Keys : aliased C.int := 0;
   begin
      return To_Public_Key_State_Access
        (Raw.Get_Keyboard_State (Num_Keys'Access));
   end Get_State;

   function Get_Modifiers return SDL.Events.Keyboards.Key_Modifiers is
   begin
      return SDL.Events.Keyboards.Key_Modifiers (Raw.Get_Mod_State);
   end Get_Modifiers;

   procedure Set_Modifiers
     (Modifiers : in SDL.Events.Keyboards.Key_Modifiers)
   is
   begin
      Raw.Set_Mod_State (Raw.Key_Modifier (Modifiers));
   end Set_Modifiers;

   function Supports_Screen_Keyboard return Boolean is
   begin
      return Boolean (Raw.Has_Screen_Keyboard_Support);
   end Supports_Screen_Keyboard;

   function Is_Screen_Keyboard_Visible
     (Window : in SDL.Video.Windows.Window) return Boolean
   is
   begin
      Require_Window (Window.Get_Internal);
      return Boolean (Raw.Screen_Keyboard_Shown (To_Raw_Window (Window.Get_Internal)));
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
      Window : constant System.Address := Focused_Window;
   begin
      if Window = System.Null_Address then
         return False;
      end if;

      return Boolean (Raw.Screen_Keyboard_Shown (To_Raw_Window (Window)));
   end Is_Text_Input_Shown;

   procedure Reset_Keyboard is
   begin
      Raw.Reset_Keyboard;
   end Reset_Keyboard;

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
