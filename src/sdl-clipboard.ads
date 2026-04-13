with Ada.Streams;
with Ada.Strings.Unbounded;
with Ada.Strings.UTF_Encoding;
with System;

with SDL.Raw.Clipboard;

package SDL.Clipboard is
   pragma Elaborate_Body;

   package UTF_Strings renames Ada.Strings.UTF_Encoding;
   package US renames Ada.Strings.Unbounded;

   Clipboard_Error : exception;

   subtype Clipboard_Data_Callback is SDL.Raw.Clipboard.Clipboard_Data_Callback;
   subtype Clipboard_Cleanup_Callback is
     SDL.Raw.Clipboard.Clipboard_Cleanup_Callback;

   type Mime_Type_Lists is array (Positive range <>) of US.Unbounded_String;

   function Get return UTF_Strings.UTF_8_String;
   function Has_Text return Boolean;
   function Is_Empty return Boolean;

   procedure Set (Text : in UTF_Strings.UTF_8_String);

   function Get_Primary_Selection return UTF_Strings.UTF_8_String;
   function Has_Primary_Selection_Text return Boolean;

   procedure Set_Primary_Selection (Text : in UTF_Strings.UTF_8_String);

   procedure Set_Data
     (Callback   : in Clipboard_Data_Callback;
      Mime_Types : in Mime_Type_Lists;
      Cleanup    : in Clipboard_Cleanup_Callback := null;
      User_Data  : in System.Address := System.Null_Address);

   procedure Clear_Data;

   function Get_Data
     (Mime_Type : in String) return Ada.Streams.Stream_Element_Array;

   function Has_Data (Mime_Type : in String) return Boolean;

   function Get_Mime_Types return Mime_Type_Lists;
end SDL.Clipboard;
