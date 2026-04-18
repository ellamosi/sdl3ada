with Interfaces;

package SDL.Raw.Keyboard_Types is
   pragma Pure;

   use type Interfaces.Unsigned_16;

   type ID is mod 2 ** 32 with
     Convention => C,
     Size       => 32;

   subtype Key_Modifier is Interfaces.Unsigned_16;

   type Scan_Code is range 0 .. 512 with
     Convention => C,
     Size       => 32;

   subtype Key_Code is Interfaces.Unsigned_32;

   Modifier_None          : constant Key_Modifier := 16#00_00#;
   Modifier_Left_Shift    : constant Key_Modifier := 16#00_01#;
   Modifier_Right_Shift   : constant Key_Modifier := 16#00_02#;
   Modifier_Left_Control  : constant Key_Modifier := 16#00_40#;
   Modifier_Right_Control : constant Key_Modifier := 16#00_80#;
   Modifier_Left_Alt      : constant Key_Modifier := 16#01_00#;
   Modifier_Right_Alt     : constant Key_Modifier := 16#02_00#;
   Modifier_Left_GUI      : constant Key_Modifier := 16#04_00#;
   Modifier_Right_GUI     : constant Key_Modifier := 16#08_00#;
   Modifier_Num           : constant Key_Modifier := 16#10_00#;
   Modifier_Caps          : constant Key_Modifier := 16#20_00#;
   Modifier_Mode          : constant Key_Modifier := 16#40_00#;
   Modifier_Control       : constant Key_Modifier :=
     Modifier_Left_Control or Modifier_Right_Control;
   Modifier_Shift         : constant Key_Modifier :=
     Modifier_Left_Shift or Modifier_Right_Shift;
   Modifier_Alt           : constant Key_Modifier :=
     Modifier_Left_Alt or Modifier_Right_Alt;
   Modifier_GUI           : constant Key_Modifier :=
     Modifier_Left_GUI or Modifier_Right_GUI;
   Modifier_Reserved      : constant Key_Modifier := 16#80_00#;

   Scan_Code_Unknown   : constant Scan_Code := 0;
   Scan_Code_Return    : constant Scan_Code := 40;
   Scan_Code_Backspace : constant Scan_Code := 42;
   Scan_Code_Space     : constant Scan_Code := 44;
   Scan_Code_Right     : constant Scan_Code := 79;
   Scan_Code_Left      : constant Scan_Code := 80;
   Scan_Code_Down      : constant Scan_Code := 81;
   Scan_Code_Up        : constant Scan_Code := 82;
   Scan_Code_X         : constant Scan_Code := 27;
   Scan_Code_Z         : constant Scan_Code := 29;
end SDL.Raw.Keyboard_Types;
