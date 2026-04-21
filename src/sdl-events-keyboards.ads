with Interfaces;
with Interfaces.C;
with Interfaces.C.Extensions;
with Interfaces.C.Strings;

with SDL.Raw.Event_Layouts.Keyboards;
with SDL.Raw.Keyboard_Types;

package SDL.Events.Keyboards is
   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;

   subtype Key_Codes is SDL.Raw.Keyboard_Types.Key_Code;
   subtype Key_Modifiers is SDL.Raw.Keyboard_Types.Key_Modifier;
   subtype Scan_Codes is SDL.Raw.Keyboard_Types.Scan_Code;

   Key_Down                : constant SDL.Events.Event_Types :=
     SDL.Raw.Event_Layouts.Keyboards.Key_Down;
   Key_Up                  : constant SDL.Events.Event_Types :=
     SDL.Raw.Event_Layouts.Keyboards.Key_Up;
   Text_Editing            : constant SDL.Events.Event_Types :=
     SDL.Raw.Event_Layouts.Keyboards.Text_Editing;
   Text_Input              : constant SDL.Events.Event_Types :=
     SDL.Raw.Event_Layouts.Keyboards.Text_Input;
   Key_Map_Changed         : constant SDL.Events.Event_Types :=
     SDL.Raw.Event_Layouts.Keyboards.Key_Map_Changed;
   Keyboard_Added          : constant SDL.Events.Event_Types :=
     SDL.Raw.Event_Layouts.Keyboards.Keyboard_Added;
   Keyboard_Removed        : constant SDL.Events.Event_Types :=
     SDL.Raw.Event_Layouts.Keyboards.Keyboard_Removed;
   Text_Editing_Candidates : constant SDL.Events.Event_Types :=
     SDL.Raw.Event_Layouts.Keyboards.Text_Editing_Candidates;
   Screen_Keyboard_Shown   : constant SDL.Events.Event_Types :=
     SDL.Raw.Event_Layouts.Keyboards.Screen_Keyboard_Shown;
   Screen_Keyboard_Hidden  : constant SDL.Events.Event_Types :=
     SDL.Raw.Event_Layouts.Keyboards.Screen_Keyboard_Hidden;

   Modifier_None          : constant Key_Modifiers := SDL.Raw.Keyboard_Types.Modifier_None;
   Modifier_Left_Shift    : constant Key_Modifiers :=
     SDL.Raw.Keyboard_Types.Modifier_Left_Shift;
   Modifier_Right_Shift   : constant Key_Modifiers :=
     SDL.Raw.Keyboard_Types.Modifier_Right_Shift;
   Modifier_Left_Control  : constant Key_Modifiers :=
     SDL.Raw.Keyboard_Types.Modifier_Left_Control;
   Modifier_Right_Control : constant Key_Modifiers :=
     SDL.Raw.Keyboard_Types.Modifier_Right_Control;
   Modifier_Left_Alt      : constant Key_Modifiers :=
     SDL.Raw.Keyboard_Types.Modifier_Left_Alt;
   Modifier_Right_Alt     : constant Key_Modifiers :=
     SDL.Raw.Keyboard_Types.Modifier_Right_Alt;
   Modifier_Left_GUI      : constant Key_Modifiers :=
     SDL.Raw.Keyboard_Types.Modifier_Left_GUI;
   Modifier_Right_GUI     : constant Key_Modifiers :=
     SDL.Raw.Keyboard_Types.Modifier_Right_GUI;
   Modifier_Num           : constant Key_Modifiers := SDL.Raw.Keyboard_Types.Modifier_Num;
   Modifier_Caps          : constant Key_Modifiers := SDL.Raw.Keyboard_Types.Modifier_Caps;
   Modifier_Mode          : constant Key_Modifiers := SDL.Raw.Keyboard_Types.Modifier_Mode;
   Modifier_Control       : constant Key_Modifiers :=
     SDL.Raw.Keyboard_Types.Modifier_Control;
   Modifier_Shift         : constant Key_Modifiers := SDL.Raw.Keyboard_Types.Modifier_Shift;
   Modifier_Alt           : constant Key_Modifiers := SDL.Raw.Keyboard_Types.Modifier_Alt;
   Modifier_GUI           : constant Key_Modifiers := SDL.Raw.Keyboard_Types.Modifier_GUI;
   Modifier_Reserved      : constant Key_Modifiers :=
     SDL.Raw.Keyboard_Types.Modifier_Reserved;

   Scan_Code_Unknown   : constant Scan_Codes := SDL.Raw.Keyboard_Types.Scan_Code_Unknown;
   Scan_Code_Return    : constant Scan_Codes := SDL.Raw.Keyboard_Types.Scan_Code_Return;
   Scan_Code_Backspace : constant Scan_Codes :=
     SDL.Raw.Keyboard_Types.Scan_Code_Backspace;
   Scan_Code_Space     : constant Scan_Codes := SDL.Raw.Keyboard_Types.Scan_Code_Space;
   Scan_Code_Right     : constant Scan_Codes := SDL.Raw.Keyboard_Types.Scan_Code_Right;
   Scan_Code_Left      : constant Scan_Codes := SDL.Raw.Keyboard_Types.Scan_Code_Left;
   Scan_Code_Down      : constant Scan_Codes := SDL.Raw.Keyboard_Types.Scan_Code_Down;
   Scan_Code_Up        : constant Scan_Codes := SDL.Raw.Keyboard_Types.Scan_Code_Up;
   Scan_Code_X         : constant Scan_Codes := SDL.Raw.Keyboard_Types.Scan_Code_X;
   Scan_Code_Z         : constant Scan_Codes := SDL.Raw.Keyboard_Types.Scan_Code_Z;

   subtype Key_Symbols is SDL.Raw.Event_Layouts.Keyboards.Key_Symbol;

   subtype Keyboard_Events is SDL.Raw.Event_Layouts.Keyboards.Keyboard_Event;

   subtype Device_Events is SDL.Raw.Event_Layouts.Keyboards.Device_Event;

   subtype Cursor_Positions is SDL.Raw.Event_Layouts.Keyboards.Cursor_Position;
   subtype Text_Lengths is SDL.Raw.Event_Layouts.Keyboards.Text_Length;

   subtype Text_Editing_Events is SDL.Raw.Event_Layouts.Keyboards.Text_Editing_Event;

   subtype Text_Input_Events is SDL.Raw.Event_Layouts.Keyboards.Text_Input_Event;

   function Value (Name : in String) return Scan_Codes with
     Inline;

   function Image (Scan_Code : in Scan_Codes) return String with
     Inline;

   function Value (Name : in String) return Key_Codes with
     Inline;

   function Image (Key_Code : in Key_Codes) return String with
     Inline;

   function Set_Name
     (Scan_Code : in Scan_Codes;
      Name      : in Interfaces.C.Strings.chars_ptr) return Boolean with
     Inline;

   function To_Key_Code
     (Scan_Code : in Scan_Codes;
      Modifiers : in Key_Modifiers;
      Key_Event : in Boolean) return Key_Codes with
     Inline;

   function To_Key_Code (Scan_Code : in Scan_Codes) return Key_Codes with
     Inline;

   function To_Scan_Code
     (Key_Code  : in Key_Codes;
      Modifiers : out Key_Modifiers) return Scan_Codes with
     Inline;

   function To_Scan_Code (Key_Code : in Key_Codes) return Scan_Codes with
     Inline;

   function Get_State (Event : in Keyboard_Events) return SDL.Events.Button_State is
     (if Boolean (Event.Down) then SDL.Events.Pressed else SDL.Events.Released);
end SDL.Events.Keyboards;
