with Interfaces;
with Interfaces.C;
with Interfaces.C.Extensions;
with Interfaces.C.Strings;

with SDL.Raw.Event_Types;
with SDL.Raw.Keyboard_Types;
with SDL.Raw.Video_Types;

package SDL.Raw.Event_Layouts.Keyboards is
   pragma Preelaborate;

   package CE renames Interfaces.C.Extensions;
   package CS renames Interfaces.C.Strings;

   use type SDL.Raw.Event_Types.Event_Type;

   Key_Down                : constant SDL.Raw.Event_Types.Event_Type := 16#0000_0300#;
   Key_Up                  : constant SDL.Raw.Event_Types.Event_Type :=
     Key_Down + SDL.Raw.Event_Types.Event_Type (1);
   Text_Editing            : constant SDL.Raw.Event_Types.Event_Type :=
     Key_Down + SDL.Raw.Event_Types.Event_Type (2);
   Text_Input              : constant SDL.Raw.Event_Types.Event_Type :=
     Key_Down + SDL.Raw.Event_Types.Event_Type (3);
   Key_Map_Changed         : constant SDL.Raw.Event_Types.Event_Type :=
     Key_Down + SDL.Raw.Event_Types.Event_Type (4);
   Keyboard_Added          : constant SDL.Raw.Event_Types.Event_Type :=
     Key_Down + SDL.Raw.Event_Types.Event_Type (5);
   Keyboard_Removed        : constant SDL.Raw.Event_Types.Event_Type :=
     Key_Down + SDL.Raw.Event_Types.Event_Type (6);
   Text_Editing_Candidates : constant SDL.Raw.Event_Types.Event_Type :=
     Key_Down + SDL.Raw.Event_Types.Event_Type (7);
   Screen_Keyboard_Shown   : constant SDL.Raw.Event_Types.Event_Type :=
     Key_Down + SDL.Raw.Event_Types.Event_Type (8);
   Screen_Keyboard_Hidden  : constant SDL.Raw.Event_Types.Event_Type :=
     Key_Down + SDL.Raw.Event_Types.Event_Type (9);

   type Key_Symbol is record
      Scan_Code : SDL.Raw.Keyboard_Types.Scan_Code;
      Key_Code  : SDL.Raw.Keyboard_Types.Key_Code;
      Modifiers : SDL.Raw.Keyboard_Types.Key_Modifier;
   end record with
     Convention => C;

   type Keyboard_Event is record
      Event_Type : SDL.Raw.Event_Types.Event_Type;
      Reserved   : Interfaces.Unsigned_32;
      Time_Stamp : Interfaces.Unsigned_64;
      Window_ID  : SDL.Raw.Video_Types.Window_ID;
      Which      : SDL.Raw.Keyboard_Types.ID;
      Key_Sym    : Key_Symbol;
      Raw        : Interfaces.Unsigned_16;
      Down       : CE.bool;
      Repeat     : CE.bool;
   end record with
     Convention => C;

   type Device_Event is record
      Event_Type : SDL.Raw.Event_Types.Event_Type;
      Reserved   : Interfaces.Unsigned_32;
      Time_Stamp : Interfaces.Unsigned_64;
      Which      : SDL.Raw.Keyboard_Types.ID;
   end record with
     Convention => C;

   subtype Cursor_Position is Interfaces.Integer_32;
   subtype Text_Length is Interfaces.Integer_32;

   type Text_Editing_Event is record
      Event_Type : SDL.Raw.Event_Types.Event_Type;
      Reserved   : Interfaces.Unsigned_32;
      Time_Stamp : Interfaces.Unsigned_64;
      Window_ID  : SDL.Raw.Video_Types.Window_ID;
      Text       : CS.chars_ptr;
      Start      : Cursor_Position;
      Length     : Text_Length;
   end record with
     Convention => C;

   type Text_Input_Event is record
      Event_Type : SDL.Raw.Event_Types.Event_Type;
      Reserved   : Interfaces.Unsigned_32;
      Time_Stamp : Interfaces.Unsigned_64;
      Window_ID  : SDL.Raw.Video_Types.Window_ID;
      Text       : CS.chars_ptr;
   end record with
     Convention => C;
end SDL.Raw.Event_Layouts.Keyboards;
