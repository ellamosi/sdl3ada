with Interfaces;
with Interfaces.C;
with Interfaces.C.Strings;

with SDL.Raw.Event_Types;
with SDL.Raw.Video_Types;

package SDL.Raw.Event_Layouts.Files is
   pragma Preelaborate;

   package C renames Interfaces.C;
   package CS renames Interfaces.C.Strings;

   use type SDL.Raw.Event_Types.Event_Type;

   Drop_File     : constant SDL.Raw.Event_Types.Event_Type := 16#0000_1000#;
   Drop_Text     : constant SDL.Raw.Event_Types.Event_Type :=
     Drop_File + SDL.Raw.Event_Types.Event_Type (1);
   Drop_Begin    : constant SDL.Raw.Event_Types.Event_Type :=
     Drop_File + SDL.Raw.Event_Types.Event_Type (2);
   Drop_Complete : constant SDL.Raw.Event_Types.Event_Type :=
     Drop_File + SDL.Raw.Event_Types.Event_Type (3);
   Drop_Position : constant SDL.Raw.Event_Types.Event_Type :=
     Drop_File + SDL.Raw.Event_Types.Event_Type (4);

   subtype Window_Identifier is SDL.Raw.Video_Types.Window_ID;

   type Drop_Event is record
      Event_Type : SDL.Raw.Event_Types.Event_Type;
      Reserved   : Interfaces.Unsigned_32;
      Time_Stamp : Interfaces.Unsigned_64;
      Window_ID  : Window_Identifier;
      X          : C.C_float;
      Y          : C.C_float;
      Source     : CS.chars_ptr;
      File_Name  : CS.chars_ptr;
   end record with
     Convention => C;
end SDL.Raw.Event_Layouts.Files;
