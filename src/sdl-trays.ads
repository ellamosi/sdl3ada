with Ada.Finalization;
with Interfaces.C;
with System;

with SDL.Video.Surfaces;

package SDL.Trays is
   pragma Elaborate_Body;

   package C renames Interfaces.C;

   Tray_Error : exception;

   type Entry_Flags is mod 2 ** 32 with
     Convention => C,
     Size       => 32;

   Button   : constant Entry_Flags := 16#0000_0001#;
   Checkbox : constant Entry_Flags := 16#0000_0002#;
   Submenu  : constant Entry_Flags := 16#0000_0004#;
   Disabled : constant Entry_Flags := 16#8000_0000#;
   Checked  : constant Entry_Flags := 16#4000_0000#;

   subtype Entry_Positions is C.int;
   Append_Position : constant Entry_Positions := -1;

   type Tray is new Ada.Finalization.Limited_Controlled with private;
   type Menu is private;
   type Tray_Entry is private;

   Null_Tray  : constant Tray;
   Null_Menu  : constant Menu;
   Null_Entry : constant Tray_Entry;

   type Entry_Lists is array (Natural range <>) of Tray_Entry;

   type Tray_Callback is access procedure
     (User_Data : in System.Address;
      Selected  : in Tray_Entry);

   function Create
     (Icon    : in SDL.Video.Surfaces.Surface := SDL.Video.Surfaces.Null_Surface;
      Tooltip : in String := "") return Tray;

   procedure Create
     (Self    : out Tray;
      Icon    : in SDL.Video.Surfaces.Surface := SDL.Video.Surfaces.Null_Surface;
      Tooltip : in String := "");

   overriding
   procedure Finalize (Self : in out Tray);

   procedure Destroy (Self : in out Tray);

   function Is_Null (Self : in Tray) return Boolean with
     Inline;

   function Is_Null (Self : in Menu) return Boolean with
     Inline;

   function Is_Null (Self : in Tray_Entry) return Boolean with
     Inline;

   procedure Set_Icon
     (Self : in Tray;
      Icon : in SDL.Video.Surfaces.Surface := SDL.Video.Surfaces.Null_Surface);

   procedure Set_Tooltip
     (Self    : in Tray;
      Tooltip : in String := "");

   function Create_Menu (Self : in Tray) return Menu;
   function Get_Menu (Self : in Tray) return Menu;

   function Create_Submenu (Self : in Tray_Entry) return Menu;
   function Get_Submenu (Self : in Tray_Entry) return Menu;

   function Get_Entries (Self : in Menu) return Entry_Lists;

   procedure Remove (Self : in out Tray_Entry);

   function Insert_At
     (Self     : in Menu;
      Position : in Entry_Positions;
      Label    : in String;
      Flags    : in Entry_Flags) return Tray_Entry;

   function Append
     (Self  : in Menu;
      Label : in String;
      Flags : in Entry_Flags) return Tray_Entry;

   function Insert_Separator_At
     (Self     : in Menu;
      Position : in Entry_Positions := Append_Position) return Tray_Entry;

   procedure Set_Label
     (Self  : in Tray_Entry;
      Label : in String);

   function Get_Label (Self : in Tray_Entry) return String;
   function Is_Separator (Self : in Tray_Entry) return Boolean;

   procedure Set_Checked
     (Self    : in Tray_Entry;
      Enabled : in Boolean);

   function Get_Checked (Self : in Tray_Entry) return Boolean;

   procedure Set_Enabled
     (Self    : in Tray_Entry;
      Enabled : in Boolean);

   function Get_Enabled (Self : in Tray_Entry) return Boolean;

   procedure Set_Callback
     (Self      : in Tray_Entry;
      Callback  : in Tray_Callback;
      User_Data : in System.Address := System.Null_Address);

   procedure Clear_Callback (Self : in Tray_Entry);

   procedure Click (Self : in Tray_Entry);

   function Get_Parent (Self : in Tray_Entry) return Menu;
   function Get_Parent_Entry (Self : in Menu) return Tray_Entry;
   function Get_Parent_Tray (Self : in Menu) return Tray;

   procedure Update;
private
   type Tray is new Ada.Finalization.Limited_Controlled with
      record
         Internal : System.Address := System.Null_Address;
         Owns     : Boolean := True;
      end record;

   type Menu is record
      Internal : System.Address := System.Null_Address;
   end record;

   type Tray_Entry is record
      Internal : System.Address := System.Null_Address;
   end record;

   Null_Tray : constant Tray :=
     (Ada.Finalization.Limited_Controlled with
        Internal => System.Null_Address,
        Owns     => True);

   Null_Menu : constant Menu := (Internal => System.Null_Address);
   Null_Entry : constant Tray_Entry := (Internal => System.Null_Address);
end SDL.Trays;
