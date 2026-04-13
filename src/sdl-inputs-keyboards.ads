with Interfaces;
with Interfaces.C;

with SDL.Events.Keyboards;
with SDL.Properties;
with SDL.Video.Rectangles;
with SDL.Video.Windows;

package SDL.Inputs.Keyboards is
   Keyboard_Error : exception;

   subtype ID is SDL.Events.Keyboard_IDs;
   type ID_Lists is array (Natural range <>) of ID;

   type Text_Input_Types is
     (Text,
      Text_Name,
      Text_Email,
      Text_Username,
      Text_Password_Hidden,
      Text_Password_Visible,
      Number,
      Number_Password_Hidden,
      Number_Password_Visible)
   with
     Convention => C,
     Size       => Interfaces.C.int'Size;

   type Capitalizations is
     (Capitalize_None,
      Capitalize_Sentences,
      Capitalize_Words,
      Capitalize_Letters)
   with
     Convention => C,
     Size       => Interfaces.C.int'Size;

   Text_Input_Type_Property : constant String := "SDL.textinput.type";
   Text_Input_Capitalization_Property : constant String :=
     "SDL.textinput.capitalization";
   Text_Input_Autocorrect_Property : constant String :=
     "SDL.textinput.autocorrect";
   Text_Input_Multiline_Property : constant String := "SDL.textinput.multiline";
   Android_Input_Type_Property : constant String :=
     "SDL.textinput.android.inputtype";

   procedure Clear_Composition;
   procedure Clear_Composition (Window : in SDL.Video.Windows.Window);

   function Has_Keyboard return Boolean;

   function Get_Keyboards return ID_Lists;

   function Name (Instance : in ID) return String;

   function Get_Focus return SDL.Video.Windows.ID;

   type Key_State_Array is array (SDL.Events.Keyboards.Scan_Codes) of Boolean with
     Convention => C;

   type Key_State_Access is access constant Key_State_Array with
     Convention => C;

   function Get_State return Key_State_Access;

   function Get_Modifiers return SDL.Events.Keyboards.Key_Modifiers with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetModState";

   procedure Set_Modifiers
     (Modifiers : in SDL.Events.Keyboards.Key_Modifiers) with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetModState";

   function Supports_Screen_Keyboard return Boolean;

   function Is_Screen_Keyboard_Visible
     (Window : in SDL.Video.Windows.Window) return Boolean;

   function Is_Text_Input_Enabled return Boolean;
   function Is_Text_Input_Enabled
     (Window : in SDL.Video.Windows.Window) return Boolean;

   function Is_Text_Input_Shown return Boolean;

   procedure Reset_Keyboard with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ResetKeyboard";

   procedure Set_Text_Input_Rectangle
     (Rectangle : in SDL.Video.Rectangles.Rectangle);
   procedure Set_Text_Input_Rectangle
     (Window    : in SDL.Video.Windows.Window;
      Rectangle : in SDL.Video.Rectangles.Rectangle;
      Cursor    : in SDL.Coordinate := 0);

   procedure Get_Text_Input_Rectangle
     (Window    : in SDL.Video.Windows.Window;
      Rectangle : out SDL.Video.Rectangles.Rectangle;
      Cursor    : out SDL.Coordinate);

   function Get_Text_Input_Rectangle
     (Window : in SDL.Video.Windows.Window;
      Cursor : out SDL.Coordinate) return SDL.Video.Rectangles.Rectangle;

   procedure Get_Text_Input_Rectangle
     (Rectangle : out SDL.Video.Rectangles.Rectangle;
      Cursor    : out SDL.Coordinate);

   function Get_Text_Input_Rectangle
     (Cursor : out SDL.Coordinate) return SDL.Video.Rectangles.Rectangle;

   procedure Start_Text_Input;
   procedure Start_Text_Input (Window : in SDL.Video.Windows.Window);
   procedure Start_Text_Input
     (Properties : in SDL.Properties.Property_Set);
   procedure Start_Text_Input
     (Window     : in SDL.Video.Windows.Window;
      Properties : in SDL.Properties.Property_Set);

   procedure Stop_Text_Input;
   procedure Stop_Text_Input (Window : in SDL.Video.Windows.Window);
end SDL.Inputs.Keyboards;
