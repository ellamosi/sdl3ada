with Interfaces;
with Interfaces.C;
with Interfaces.C.Extensions;
with Interfaces.C.Strings;

with SDL.Video.Windows;

package SDL.Events.Keyboards is
   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;

   use type Interfaces.Unsigned_16;

   subtype Key_Codes is Interfaces.Unsigned_32;
   subtype Key_Modifiers is Interfaces.Unsigned_16;

   type Scan_Codes is range 0 .. 512 with
     Convention => C,
     Size       => 32;

   Key_Down                : constant SDL.Events.Event_Types := 16#0000_0300#;
   Key_Up                  : constant SDL.Events.Event_Types := 16#0000_0301#;
   Text_Editing            : constant SDL.Events.Event_Types := 16#0000_0302#;
   Text_Input              : constant SDL.Events.Event_Types := 16#0000_0303#;
   Key_Map_Changed         : constant SDL.Events.Event_Types := 16#0000_0304#;
   Keyboard_Added          : constant SDL.Events.Event_Types := 16#0000_0305#;
   Keyboard_Removed        : constant SDL.Events.Event_Types := 16#0000_0306#;
   Text_Editing_Candidates : constant SDL.Events.Event_Types := 16#0000_0307#;
   Screen_Keyboard_Shown   : constant SDL.Events.Event_Types := 16#0000_0308#;
   Screen_Keyboard_Hidden  : constant SDL.Events.Event_Types := 16#0000_0309#;

   Modifier_None          : constant Key_Modifiers := 16#00_00#;
   Modifier_Left_Shift    : constant Key_Modifiers := 16#00_01#;
   Modifier_Right_Shift   : constant Key_Modifiers := 16#00_02#;
   Modifier_Left_Control  : constant Key_Modifiers := 16#00_40#;
   Modifier_Right_Control : constant Key_Modifiers := 16#00_80#;
   Modifier_Left_Alt      : constant Key_Modifiers := 16#01_00#;
   Modifier_Right_Alt     : constant Key_Modifiers := 16#02_00#;
   Modifier_Left_GUI      : constant Key_Modifiers := 16#04_00#;
   Modifier_Right_GUI     : constant Key_Modifiers := 16#08_00#;
   Modifier_Num           : constant Key_Modifiers := 16#10_00#;
   Modifier_Caps          : constant Key_Modifiers := 16#20_00#;
   Modifier_Mode          : constant Key_Modifiers := 16#40_00#;
   Modifier_Control       : constant Key_Modifiers := Modifier_Left_Control or Modifier_Right_Control;
   Modifier_Shift         : constant Key_Modifiers := Modifier_Left_Shift or Modifier_Right_Shift;
   Modifier_Alt           : constant Key_Modifiers := Modifier_Left_Alt or Modifier_Right_Alt;
   Modifier_GUI           : constant Key_Modifiers := Modifier_Left_GUI or Modifier_Right_GUI;
   Modifier_Reserved      : constant Key_Modifiers := 16#80_00#;

   Scan_Code_Unknown   : constant Scan_Codes := 0;
   Scan_Code_Return    : constant Scan_Codes := 40;
   Scan_Code_Backspace : constant Scan_Codes := 42;
   Scan_Code_Space     : constant Scan_Codes := 44;
   Scan_Code_Right     : constant Scan_Codes := 79;
   Scan_Code_Left      : constant Scan_Codes := 80;
   Scan_Code_Down      : constant Scan_Codes := 81;
   Scan_Code_Up        : constant Scan_Codes := 82;
   Scan_Code_X         : constant Scan_Codes := 27;
   Scan_Code_Z         : constant Scan_Codes := 29;

   type Key_Symbols is record
      Scan_Code : Scan_Codes;
      Key_Code  : Key_Codes;
      Modifiers : Key_Modifiers;
   end record with
     Convention => C;

   type Keyboard_Events is record
      Event_Type : SDL.Events.Event_Types;
      Reserved   : Interfaces.Unsigned_32;
      Time_Stamp : SDL.Events.Time_Stamps;
      Window_ID  : SDL.Video.Windows.ID;
      Which      : SDL.Events.Keyboard_IDs;
      Key_Sym    : Key_Symbols;
      Raw        : Interfaces.Unsigned_16;
      Down       : CE.bool;
      Repeat     : CE.bool;
   end record with
     Convention => C;

   type Device_Events is record
      Event_Type : SDL.Events.Event_Types;
      Reserved   : Interfaces.Unsigned_32;
      Time_Stamp : SDL.Events.Time_Stamps;
      Which      : SDL.Events.Keyboard_IDs;
   end record with
     Convention => C;

   subtype Cursor_Positions is Interfaces.Integer_32;
   subtype Text_Lengths is Interfaces.Integer_32;

   type Text_Editing_Events is record
      Event_Type : SDL.Events.Event_Types;
      Reserved   : Interfaces.Unsigned_32;
      Time_Stamp : SDL.Events.Time_Stamps;
      Window_ID  : SDL.Video.Windows.ID;
      Text       : Interfaces.C.Strings.chars_ptr;
      Start      : Cursor_Positions;
      Length     : Text_Lengths;
   end record with
     Convention => C;

   type Text_Input_Events is record
      Event_Type : SDL.Events.Event_Types;
      Reserved   : Interfaces.Unsigned_32;
      Time_Stamp : SDL.Events.Time_Stamps;
      Window_ID  : SDL.Video.Windows.ID;
      Text       : Interfaces.C.Strings.chars_ptr;
   end record with
     Convention => C;

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
