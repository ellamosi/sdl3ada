with Ada.Strings.Unbounded;
with Interfaces;
with Interfaces.C;

with SDL.Video.Windows;

package SDL.Message_Boxes is
   pragma Elaborate_Body;

   package C renames Interfaces.C;
   package US renames Ada.Strings.Unbounded;

   Message_Box_Error : exception;

   type Flags is mod 2 ** 32 with
     Convention => C,
     Size       => 32;

   type Button_Flags is mod 2 ** 32 with
     Convention => C,
     Size       => 32;

   Error_Box             : constant Flags := 16#0000_0010#;
   Warning_Box           : constant Flags := 16#0000_0020#;
   Information_Box       : constant Flags := 16#0000_0040#;
   Left_To_Right_Buttons : constant Flags := 16#0000_0080#;
   Right_To_Left_Buttons : constant Flags := 16#0000_0100#;

   Return_Key_Default : constant Button_Flags := 16#0000_0001#;
   Escape_Key_Default : constant Button_Flags := 16#0000_0002#;

   subtype Button_IDs is C.int;

   type Button_Data is record
      Flags     : Button_Flags := 0;
      Button_ID : Button_IDs := 0;
      Text      : US.Unbounded_String := US.Null_Unbounded_String;
   end record;

   type Button_Lists is array (Natural range <>) of Button_Data;

   type Color is record
      Red   : Interfaces.Unsigned_8 := 0;
      Green : Interfaces.Unsigned_8 := 0;
      Blue  : Interfaces.Unsigned_8 := 0;
   end record with
     Convention => C;

   type Color_Types is
     (Background,
      Text,
      Button_Border,
      Button_Background,
      Button_Selected)
   with
     Convention => C,
     Size       => C.int'Size;

   for Color_Types use
     (Background        => 0,
      Text              => 1,
      Button_Border     => 2,
      Button_Background => 3,
      Button_Selected   => 4);

   type Color_Scheme is array (Color_Types) of aliased Color with
     Convention => C;

   procedure Show_Simple
     (Title   : in String;
      Message : in String;
      Flags   : in SDL.Message_Boxes.Flags := Information_Box);

   procedure Show_Simple
     (Title   : in String;
      Message : in String;
      Window  : in SDL.Video.Windows.Window;
      Flags   : in SDL.Message_Boxes.Flags := Information_Box);

   function Show
     (Title   : in String;
      Message : in String;
      Buttons : in Button_Lists;
      Flags   : in SDL.Message_Boxes.Flags := 0) return Button_IDs;

   function Show
     (Title   : in String;
      Message : in String;
      Window  : in SDL.Video.Windows.Window;
      Buttons : in Button_Lists;
      Flags   : in SDL.Message_Boxes.Flags := 0) return Button_IDs;

   function Show
     (Title   : in String;
      Message : in String;
      Buttons : in Button_Lists;
      Colors  : in Color_Scheme;
      Flags   : in SDL.Message_Boxes.Flags := 0) return Button_IDs;

   function Show
     (Title   : in String;
      Message : in String;
      Window  : in SDL.Video.Windows.Window;
      Buttons : in Button_Lists;
      Colors  : in Color_Scheme;
      Flags   : in SDL.Message_Boxes.Flags := 0) return Button_IDs;
end SDL.Message_Boxes;
