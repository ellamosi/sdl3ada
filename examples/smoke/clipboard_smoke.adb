with Ada.Exceptions;
with Ada.Streams;
with Ada.Strings.Unbounded;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Unchecked_Conversion;
with Interfaces.C.Strings;
with System;

with SDL;
with SDL.Clipboard;
with SDL.Error;
with SDL.Raw.Clipboard;

procedure Clipboard_Smoke is
   package CS renames Interfaces.C.Strings;
   package US renames Ada.Strings.Unbounded;

   use type Ada.Streams.Stream_Element;
   use type Ada.Streams.Stream_Element_Array;
   use type Ada.Streams.Stream_Element_Offset;
   use type CS.chars_ptr;
   use type SDL.Init_Flags;

   type Callback_State is record
      Requests : Natural := 0;
      Cleans   : Natural := 0;
   end record;

   type Callback_State_Access is access all Callback_State;
   pragma No_Strict_Aliasing (Callback_State_Access);

   function To_Callback_State is new Ada.Unchecked_Conversion
     (Source => System.Address,
      Target => Callback_State_Access);

   function To_Bytes
     (Value : in String) return Ada.Streams.Stream_Element_Array;

   function Matches
     (Left  : in Ada.Streams.Stream_Element_Array;
      Right : in Ada.Streams.Stream_Element_Array) return Boolean;

   procedure Require (Condition : in Boolean; Message : in String);

   function Clipboard_Data
     (User_Data : in System.Address;
      Mime_Type : in CS.chars_ptr;
      Size      : access SDL.Raw.Clipboard.Sizes) return System.Address
   with Convention => C;

   procedure Clipboard_Cleanup
     (User_Data : in System.Address)
   with Convention => C;

   function To_Bytes
     (Value : in String) return Ada.Streams.Stream_Element_Array
   is
      Result : Ada.Streams.Stream_Element_Array
        (1 .. Ada.Streams.Stream_Element_Offset (Value'Length));
   begin
      for Index in Value'Range loop
         Result
           (Ada.Streams.Stream_Element_Offset
              (Index - Value'First + 1)) :=
           Ada.Streams.Stream_Element (Character'Pos (Value (Index)));
      end loop;

      return Result;
   end To_Bytes;

   function Matches
     (Left  : in Ada.Streams.Stream_Element_Array;
      Right : in Ada.Streams.Stream_Element_Array) return Boolean
   is
   begin
      if Left'Length /= Right'Length then
         return False;
      end if;

      for Offset in 0 .. Left'Length - 1 loop
         if Left (Left'First + Ada.Streams.Stream_Element_Offset (Offset)) /=
             Right (Right'First + Ada.Streams.Stream_Element_Offset (Offset))
         then
            return False;
         end if;
      end loop;

      return True;
   end Matches;

   procedure Require (Condition : in Boolean; Message : in String) is
   begin
      if not Condition then
         raise Program_Error with Message;
      end if;
   end Require;

   Clipboard_Text : constant SDL.Clipboard.UTF_Strings.UTF_8_String :=
     "sdl3ada clipboard smoke";
   Primary_Text : constant SDL.Clipboard.UTF_Strings.UTF_8_String :=
     "sdl3ada primary selection";
   Clipboard_Payload : aliased constant String := "clipboard-payload";
   Payload_Bytes : constant Ada.Streams.Stream_Element_Array :=
     To_Bytes (Clipboard_Payload);

   State : aliased Callback_State;

   function Clipboard_Data
     (User_Data : in System.Address;
      Mime_Type : in CS.chars_ptr;
      Size      : access SDL.Raw.Clipboard.Sizes) return System.Address
   is
      pragma Unreferenced (Mime_Type);

      Local_State : constant Callback_State_Access :=
        To_Callback_State (User_Data);
   begin
      if Local_State /= null then
         Local_State.Requests := Local_State.Requests + 1;
      end if;

      if Size /= null then
         Size.all := Clipboard_Payload'Length;
      end if;

      return Clipboard_Payload'Address;
   end Clipboard_Data;

   procedure Clipboard_Cleanup
     (User_Data : in System.Address)
   is
      Local_State : constant Callback_State_Access :=
        To_Callback_State (User_Data);
   begin
      if Local_State /= null then
         Local_State.Cleans := Local_State.Cleans + 1;
      end if;
   end Clipboard_Cleanup;

   SDL_Initialized : Boolean := False;
begin
   if not SDL.Initialise (SDL.Enable_Video or SDL.Enable_Events) then
      raise Program_Error with "SDL initialization failed: " & SDL.Error.Get;
   end if;

   SDL_Initialized := True;

   SDL.Clipboard.Set (Clipboard_Text);
   Require (SDL.Clipboard.Has_Text, "Clipboard text was not reported");
   Require (not SDL.Clipboard.Is_Empty, "Clipboard text unexpectedly empty");
   Require (SDL.Clipboard.Get = Clipboard_Text, "Clipboard text round-trip mismatch");

   SDL.Clipboard.Set_Primary_Selection (Primary_Text);
   Require
     (SDL.Clipboard.Has_Primary_Selection_Text,
      "Primary selection was not reported");
   Require
     (SDL.Clipboard.Get_Primary_Selection = Primary_Text,
      "Primary selection round-trip mismatch");

   SDL.Clipboard.Set_Data
     (Callback   => Clipboard_Data'Unrestricted_Access,
      Mime_Types =>
        [US.To_Unbounded_String ("text/plain"),
         US.To_Unbounded_String ("application/x-sdl3ada-clipboard")],
      Cleanup    => Clipboard_Cleanup'Unrestricted_Access,
      User_Data  => State'Address);

   Require
     (SDL.Clipboard.Has_Data ("text/plain"),
      "Clipboard data MIME type was not reported");
   Require
     (SDL.Clipboard.Has_Data ("application/x-sdl3ada-clipboard"),
      "Custom clipboard MIME type was not reported");

   declare
      Retrieved : constant Ada.Streams.Stream_Element_Array :=
        SDL.Clipboard.Get_Data ("text/plain");
      Mime_Types : constant SDL.Clipboard.Mime_Type_Lists :=
        SDL.Clipboard.Get_Mime_Types;
   begin
      pragma Unreferenced (Mime_Types);

      Require
        (Matches (Retrieved, Payload_Bytes),
         "Clipboard data payload mismatch");
      Require (State.Requests > 0, "Clipboard data callback was not invoked");
   end;

   SDL.Clipboard.Clear_Data;
   Require (State.Cleans > 0, "Clipboard cleanup callback was not invoked");
   Require
     (not SDL.Clipboard.Has_Data ("application/x-sdl3ada-clipboard"),
      "Clipboard data remained after clear");

   SDL.Quit;
   Put_Line ("clipboard_smoke completed successfully.");
exception
   when Error : others =>
      if SDL_Initialized then
         SDL.Quit;
      end if;

      Put_Line
        ("clipboard_smoke failed: " &
         Ada.Exceptions.Exception_Message (Error));

      declare
         Message : constant String := SDL.Error.Get;
      begin
         if Message /= "" then
            Put_Line ("SDL error: " & Message);
         end if;
      end;

      raise;
end Clipboard_Smoke;
