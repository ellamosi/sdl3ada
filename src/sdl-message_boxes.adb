with Ada.Unchecked_Deallocation;
with Interfaces.C.Extensions;
with Interfaces.C.Strings;
with System;

with SDL.Error;

package body SDL.Message_Boxes is
   package CE renames Interfaces.C.Extensions;
   package CS renames Interfaces.C.Strings;

   use type CS.chars_ptr;

   type Internal_Button_Data is record
      Flags     : Button_Flags := 0;
      Button_ID : Button_IDs := 0;
      Text      : CS.chars_ptr := CS.Null_Ptr;
   end record with
     Convention => C;

   type Internal_Button_Arrays is array (Natural range <>) of aliased Internal_Button_Data
   with Convention => C;

   type Internal_Button_Array_Access is access Internal_Button_Arrays;

   type String_Pointer_Lists is array (Natural range <>) of CS.chars_ptr;
   type String_Pointer_List_Access is access String_Pointer_Lists;

   type Internal_Message_Box_Data is record
      Flags        : SDL.Message_Boxes.Flags := 0;
      Window       : System.Address := System.Null_Address;
      Title        : CS.chars_ptr := CS.Null_Ptr;
      Message      : CS.chars_ptr := CS.Null_Ptr;
      Num_Buttons  : C.int := 0;
      Buttons      : System.Address := System.Null_Address;
      Color_Scheme : System.Address := System.Null_Address;
   end record with
     Convention => C;

   procedure Free is new Ada.Unchecked_Deallocation
     (Object => Internal_Button_Arrays, Name => Internal_Button_Array_Access);

   procedure Free is new Ada.Unchecked_Deallocation
     (Object => String_Pointer_Lists, Name => String_Pointer_List_Access);

   function SDL_Show_Message_Box
     (Data      : access constant Internal_Message_Box_Data;
      Button_ID : access Button_IDs) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ShowMessageBox";

   function SDL_Show_Simple_Message_Box
     (Flags   : in SDL.Message_Boxes.Flags;
      Title   : in CS.chars_ptr;
      Message : in CS.chars_ptr;
      Window  : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ShowSimpleMessageBox";

   procedure Raise_Last_Error
     (Default_Message : in String := "SDL message box call failed");

   procedure Raise_Last_Error
     (Default_Message : in String := "SDL message box call failed")
   is
      Message : constant String := SDL.Error.Get;
   begin
      if Message = "" then
         raise Message_Box_Error with Default_Message;
      end if;

      raise Message_Box_Error with Message;
   end Raise_Last_Error;

   procedure Release
     (Title   : in out CS.chars_ptr;
      Message : in out CS.chars_ptr;
      Buttons : in out Internal_Button_Array_Access;
      Labels  : in out String_Pointer_List_Access);

   procedure Release
     (Title   : in out CS.chars_ptr;
      Message : in out CS.chars_ptr;
      Buttons : in out Internal_Button_Array_Access;
      Labels  : in out String_Pointer_List_Access)
   is
   begin
      if Title /= CS.Null_Ptr then
         CS.Free (Title);
         Title := CS.Null_Ptr;
      end if;

      if Message /= CS.Null_Ptr then
         CS.Free (Message);
         Message := CS.Null_Ptr;
      end if;

      if Labels /= null then
         for Label of Labels.all loop
            if Label /= CS.Null_Ptr then
               CS.Free (Label);
            end if;
         end loop;
      end if;

      Free (Buttons);
      Free (Labels);
   end Release;

   procedure Show_Simple
     (Title   : in String;
      Message : in String;
      Flags   : in SDL.Message_Boxes.Flags := Information_Box) is
   begin
      Show_Simple
        (Title   => Title,
         Message => Message,
         Window  => SDL.Video.Windows.Get (0),
         Flags   => Flags);
   end Show_Simple;

   procedure Show_Simple
     (Title   : in String;
      Message : in String;
      Window  : in SDL.Video.Windows.Window;
      Flags   : in SDL.Message_Boxes.Flags := Information_Box)
   is
      C_Title   : CS.chars_ptr := CS.New_String (Title);
      C_Message : CS.chars_ptr := CS.New_String (Message);
   begin
      begin
         if not Boolean
           (SDL_Show_Simple_Message_Box
              (Flags   => Flags,
               Title   => C_Title,
               Message => C_Message,
               Window  => SDL.Video.Windows.Get_Internal (Window)))
         then
            Raise_Last_Error;
         end if;
      exception
         when others =>
            CS.Free (C_Title);
            CS.Free (C_Message);
            raise;
      end;

      CS.Free (C_Title);
      CS.Free (C_Message);
   end Show_Simple;

   function Show_Internal
     (Title       : in String;
      Message     : in String;
      Window      : in System.Address;
      Buttons     : in Button_Lists;
      Color_Scheme : access constant SDL.Message_Boxes.Color_Scheme;
      Flags       : in SDL.Message_Boxes.Flags) return Button_IDs
   is
      C_Title     : CS.chars_ptr := CS.Null_Ptr;
      C_Message   : CS.chars_ptr := CS.Null_Ptr;
      Button_List : Internal_Button_Array_Access := null;
      Labels      : String_Pointer_List_Access := null;
      ID          : aliased Button_IDs := -1;
      Data        : aliased Internal_Message_Box_Data;
   begin
      if Buttons'Length = 0 then
         raise Message_Box_Error with "Message boxes require at least one button";
      end if;

      C_Title := CS.New_String (Title);
      C_Message := CS.New_String (Message);
      Button_List := new Internal_Button_Arrays (0 .. Buttons'Length - 1);
      Labels := new String_Pointer_Lists (0 .. Buttons'Length - 1);

      for Offset in 0 .. Buttons'Length - 1 loop
         declare
            Index : constant Natural := Buttons'First + Offset;
         begin
            Labels (Offset) := CS.New_String (US.To_String (Buttons (Index).Text));
            Button_List (Offset) :=
              (Flags     => Buttons (Index).Flags,
               Button_ID => Buttons (Index).Button_ID,
               Text      => Labels (Offset));
         end;
      end loop;

      Data :=
        (Flags        => Flags,
         Window       => Window,
         Title        => C_Title,
         Message      => C_Message,
         Num_Buttons  => C.int (Buttons'Length),
         Buttons      => Button_List (Button_List'First)'Address,
         Color_Scheme =>
           (if Color_Scheme = null
            then System.Null_Address
            else Color_Scheme.all'Address));

      if not Boolean (SDL_Show_Message_Box (Data'Access, ID'Access)) then
         Raise_Last_Error;
      end if;

      Release (C_Title, C_Message, Button_List, Labels);
      return ID;
   exception
      when others =>
         Release (C_Title, C_Message, Button_List, Labels);
         raise;
   end Show_Internal;

   function Show
     (Title   : in String;
      Message : in String;
      Buttons : in Button_Lists;
      Flags   : in SDL.Message_Boxes.Flags := 0) return Button_IDs is
   begin
      return Show_Internal
        (Title        => Title,
         Message      => Message,
         Window       => System.Null_Address,
         Buttons      => Buttons,
         Color_Scheme => null,
         Flags        => Flags);
   end Show;

   function Show
     (Title   : in String;
      Message : in String;
      Window  : in SDL.Video.Windows.Window;
      Buttons : in Button_Lists;
      Flags   : in SDL.Message_Boxes.Flags := 0) return Button_IDs is
   begin
      return Show_Internal
        (Title        => Title,
         Message      => Message,
         Window       => SDL.Video.Windows.Get_Internal (Window),
         Buttons      => Buttons,
         Color_Scheme => null,
         Flags        => Flags);
   end Show;

   function Show
     (Title   : in String;
      Message : in String;
      Buttons : in Button_Lists;
      Colors  : in Color_Scheme;
      Flags   : in SDL.Message_Boxes.Flags := 0) return Button_IDs is
      Local_Colors : aliased constant Color_Scheme := Colors;
   begin
      return Show_Internal
        (Title        => Title,
         Message      => Message,
         Window       => System.Null_Address,
         Buttons      => Buttons,
         Color_Scheme => Local_Colors'Access,
         Flags        => Flags);
   end Show;

   function Show
     (Title   : in String;
     Message : in String;
     Window  : in SDL.Video.Windows.Window;
     Buttons : in Button_Lists;
     Colors  : in Color_Scheme;
     Flags   : in SDL.Message_Boxes.Flags := 0) return Button_IDs is
      Local_Colors : aliased constant Color_Scheme := Colors;
   begin
      return Show_Internal
        (Title        => Title,
         Message      => Message,
         Window       => SDL.Video.Windows.Get_Internal (Window),
         Buttons      => Buttons,
         Color_Scheme => Local_Colors'Access,
         Flags        => Flags);
   end Show;
end SDL.Message_Boxes;
