with Ada.Unchecked_Conversion;
with Ada.Unchecked_Deallocation;
with Interfaces.C.Extensions;
with Interfaces.C.Pointers;
with Interfaces.C.Strings;

with SDL.Error;

package body SDL.Dialogs is
   package CE renames Interfaces.C.Extensions;
   package CS renames Interfaces.C.Strings;

   type Internal_File_Filter is record
      Name    : CS.chars_ptr := CS.Null_Ptr;
      Pattern : CS.chars_ptr := CS.Null_Ptr;
   end record with
     Convention => C;

   type Internal_File_Filter_Arrays is
     array (Natural range <>) of aliased Internal_File_Filter
   with Convention => C;

   type Internal_File_Filter_Array_Access is access Internal_File_Filter_Arrays;

   type String_Pointer_Lists is array (Natural range <>) of CS.chars_ptr;
   type String_Pointer_List_Access is access String_Pointer_Lists;

   type C_String_Pointer_Arrays is array (C.ptrdiff_t range <>) of aliased CS.chars_ptr
   with Convention => C;

   package C_String_Pointers is new Interfaces.C.Pointers
     (Index              => C.ptrdiff_t,
      Element            => CS.chars_ptr,
      Element_Array      => C_String_Pointer_Arrays,
      Default_Terminator => CS.Null_Ptr);

   type Dialog_Context is record
      Callback         : File_Dialog_Callback := null;
      User_Data        : System.Address := System.Null_Address;
      Default_Location : CS.chars_ptr := CS.Null_Ptr;
      Filters          : Internal_File_Filter_Array_Access := null;
      Filter_Names     : String_Pointer_List_Access := null;
      Filter_Patterns  : String_Pointer_List_Access := null;
   end record;

   type Dialog_Context_Access is access Dialog_Context;

   procedure Free is new Ada.Unchecked_Deallocation
     (Object => Dialog_Context, Name => Dialog_Context_Access);

   procedure Free is new Ada.Unchecked_Deallocation
     (Object => Internal_File_Filter_Arrays,
      Name   => Internal_File_Filter_Array_Access);

   procedure Free is new Ada.Unchecked_Deallocation
     (Object => String_Pointer_Lists, Name => String_Pointer_List_Access);

   use type C.ptrdiff_t;
   use type C_String_Pointers.Pointer;
   use type CS.chars_ptr;
   use type System.Address;

   function To_Address is new Ada.Unchecked_Conversion
     (Source => Dialog_Context_Access,
      Target => System.Address);

   function To_Context is new Ada.Unchecked_Conversion
     (Source => System.Address,
      Target => Dialog_Context_Access);

   function To_C_Bool (Value : in Boolean) return CE.bool is
     (if Value then CE.bool'Val (1) else CE.bool'Val (0));

   type Internal_File_Dialog_Callback is access procedure
     (User_Data : in System.Address;
      File_List : in C_String_Pointers.Pointer;
      Filter    : in C.int)
   with Convention => C;

   procedure SDL_Show_Open_File_Dialog
     (Callback         : in Internal_File_Dialog_Callback;
      User_Data        : in System.Address;
      Window           : in System.Address;
      Filters          : in System.Address;
      Filter_Count     : in C.int;
      Default_Location : in CS.chars_ptr;
      Allow_Many       : in CE.bool)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ShowOpenFileDialog";

   procedure SDL_Show_Save_File_Dialog
     (Callback         : in Internal_File_Dialog_Callback;
      User_Data        : in System.Address;
      Window           : in System.Address;
      Filters          : in System.Address;
      Filter_Count     : in C.int;
      Default_Location : in CS.chars_ptr)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ShowSaveFileDialog";

   procedure SDL_Show_Open_Folder_Dialog
     (Callback         : in Internal_File_Dialog_Callback;
      User_Data        : in System.Address;
      Window           : in System.Address;
      Default_Location : in CS.chars_ptr;
      Allow_Many       : in CE.bool)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ShowOpenFolderDialog";

   procedure SDL_Show_File_Dialog_With_Properties
     (Kind       : in File_Dialog_Type;
      Callback   : in Internal_File_Dialog_Callback;
      User_Data  : in System.Address;
      Properties : in SDL.Properties.Property_ID)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ShowFileDialogWithProperties";

   procedure Release (Context : in out Dialog_Context_Access);

   procedure Release (Context : in out Dialog_Context_Access) is
   begin
      if Context = null then
         return;
      end if;

      if Context.Filter_Names /= null then
         for Value of Context.Filter_Names.all loop
            if Value /= CS.Null_Ptr then
               CS.Free (Value);
            end if;
         end loop;
      end if;

      if Context.Filter_Patterns /= null then
         for Value of Context.Filter_Patterns.all loop
            if Value /= CS.Null_Ptr then
               CS.Free (Value);
            end if;
         end loop;
      end if;

      if Context.Default_Location /= CS.Null_Ptr then
         CS.Free (Context.Default_Location);
      end if;

      Free (Context.Filters);
      Free (Context.Filter_Names);
      Free (Context.Filter_Patterns);
      Free (Context);
   end Release;

   procedure Raise_Invalid_Callback is
   begin
      raise Dialog_Error with "File dialog callback must not be null";
   end Raise_Invalid_Callback;

   function Create_Context
     (Callback         : in File_Dialog_Callback;
      User_Data        : in System.Address;
      Default_Location : in String;
      Filters          : in File_Filter_Lists) return Dialog_Context_Access
   is
      Context : Dialog_Context_Access := new Dialog_Context;
   begin
      if Callback = null then
         Raise_Invalid_Callback;
      end if;

      Context.Callback := Callback;
      Context.User_Data := User_Data;

      begin
         if Default_Location /= "" then
            Context.Default_Location := CS.New_String (Default_Location);
         end if;

         if Filters'Length > 0 then
            Context.Filters := new Internal_File_Filter_Arrays (0 .. Filters'Length - 1);
            Context.Filter_Names := new String_Pointer_Lists (0 .. Filters'Length - 1);
            Context.Filter_Patterns := new String_Pointer_Lists (0 .. Filters'Length - 1);

            for Offset in 0 .. Filters'Length - 1 loop
               declare
                  Index : constant Natural := Filters'First + Offset;
               begin
                  Context.Filter_Names (Offset) :=
                    CS.New_String (US.To_String (Filters (Index).Name));
                  Context.Filter_Patterns (Offset) :=
                    CS.New_String (US.To_String (Filters (Index).Pattern));
                  Context.Filters (Offset) :=
                    (Name    => Context.Filter_Names (Offset),
                     Pattern => Context.Filter_Patterns (Offset));
               end;
            end loop;
         end if;

         return Context;
      exception
         when others =>
            Release (Context);
            raise;
      end;
   end Create_Context;

   function To_Files (List : in C_String_Pointers.Pointer) return File_Path_Lists is
      Count : Natural := 0;
   begin
      if List = null or else List.all = CS.Null_Ptr then
         return (1 .. 0 => <>);
      end if;

      loop
         declare
            Position : constant C_String_Pointers.Pointer :=
              List + C.ptrdiff_t (Count);
         begin
            exit when Position = null or else Position.all = CS.Null_Ptr;
         end;

         Count := Count + 1;
      end loop;

      return Result : File_Path_Lists (1 .. Count) do
         for Index in Result'Range loop
            declare
               Position : constant C_String_Pointers.Pointer :=
                 List + C.ptrdiff_t (Index - Result'First);
            begin
               Result (Index) := US.To_Unbounded_String (CS.Value (Position.all));
            end;
         end loop;
      end return;
   end To_Files;

   procedure Dialog_Trampoline
     (User_Data : in System.Address;
      File_List : in C_String_Pointers.Pointer;
      Filter    : in C.int)
   with Convention => C;

   procedure Dialog_Trampoline
     (User_Data : in System.Address;
      File_List : in C_String_Pointers.Pointer;
      Filter    : in C.int)
   is
      Context : Dialog_Context_Access := To_Context (User_Data);
   begin
      if Context = null then
         return;
      end if;

      begin
         if File_List = null then
            declare
               Message : constant String := SDL.Error.Get;
            begin
               Context.Callback
                 (User_Data       => Context.User_Data,
                  Status          => Failed,
                  Files           => (1 .. 0 => <>),
                  Selected_Filter => Filter,
                  Error_Message   => Message);
            end;
         elsif File_List.all = CS.Null_Ptr then
            Context.Callback
              (User_Data       => Context.User_Data,
               Status          => Cancelled,
               Files           => (1 .. 0 => <>),
               Selected_Filter => Filter,
               Error_Message   => "");
         else
            declare
               Files : constant File_Path_Lists := To_Files (File_List);
            begin
               Context.Callback
                 (User_Data       => Context.User_Data,
                  Status          => Accepted,
                  Files           => Files,
                  Selected_Filter => Filter,
                  Error_Message   => "");
            end;
         end if;
      exception
         when others =>
            Release (Context);
            raise;
      end;

      Release (Context);
   end Dialog_Trampoline;

   function Filter_Address (Context : in Dialog_Context_Access) return System.Address is
   begin
      if Context = null or else Context.Filters = null or else Context.Filters'Length = 0 then
         return System.Null_Address;
      end if;

      return Context.Filters (Context.Filters'First)'Address;
   end Filter_Address;

   procedure Launch_Open_File_Dialog
     (Callback         : in File_Dialog_Callback;
      Window           : in System.Address;
      Filters          : in File_Filter_Lists;
      Default_Location : in String;
      Allow_Many       : in Boolean;
      User_Data        : in System.Address)
   is
      Context : Dialog_Context_Access :=
        Create_Context (Callback, User_Data, Default_Location, Filters);
   begin
      SDL_Show_Open_File_Dialog
        (Callback         => Dialog_Trampoline'Access,
         User_Data        => To_Address (Context),
         Window           => Window,
         Filters          => Filter_Address (Context),
         Filter_Count     => C.int (Filters'Length),
         Default_Location => Context.Default_Location,
         Allow_Many       => To_C_Bool (Allow_Many));
   exception
      when others =>
         Release (Context);
         raise;
   end Launch_Open_File_Dialog;

   procedure Launch_Save_File_Dialog
     (Callback         : in File_Dialog_Callback;
      Window           : in System.Address;
      Filters          : in File_Filter_Lists;
      Default_Location : in String;
      User_Data        : in System.Address)
   is
      Context : Dialog_Context_Access :=
        Create_Context (Callback, User_Data, Default_Location, Filters);
   begin
      SDL_Show_Save_File_Dialog
        (Callback         => Dialog_Trampoline'Access,
         User_Data        => To_Address (Context),
         Window           => Window,
         Filters          => Filter_Address (Context),
         Filter_Count     => C.int (Filters'Length),
         Default_Location => Context.Default_Location);
   exception
      when others =>
         Release (Context);
         raise;
   end Launch_Save_File_Dialog;

   procedure Launch_Open_Folder_Dialog
     (Callback         : in File_Dialog_Callback;
      Window           : in System.Address;
      Default_Location : in String;
      Allow_Many       : in Boolean;
      User_Data        : in System.Address)
   is
      Context : Dialog_Context_Access :=
        Create_Context (Callback, User_Data, Default_Location, (1 .. 0 => <>));
   begin
      SDL_Show_Open_Folder_Dialog
        (Callback         => Dialog_Trampoline'Access,
         User_Data        => To_Address (Context),
         Window           => Window,
         Default_Location => Context.Default_Location,
         Allow_Many       => To_C_Bool (Allow_Many));
   exception
      when others =>
         Release (Context);
         raise;
   end Launch_Open_Folder_Dialog;

   procedure Show_Open_File_Dialog
     (Callback         : in File_Dialog_Callback;
      Default_Location : in String := "";
      Allow_Many       : in Boolean := False;
      User_Data        : in System.Address := System.Null_Address) is
   begin
      Launch_Open_File_Dialog
        (Callback         => Callback,
         Window           => System.Null_Address,
         Filters          => (1 .. 0 => <>),
         Default_Location => Default_Location,
         Allow_Many       => Allow_Many,
         User_Data        => User_Data);
   end Show_Open_File_Dialog;

   procedure Show_Open_File_Dialog
     (Callback         : in File_Dialog_Callback;
      Window           : in SDL.Video.Windows.Window;
      Default_Location : in String := "";
      Allow_Many       : in Boolean := False;
      User_Data        : in System.Address := System.Null_Address) is
   begin
      Launch_Open_File_Dialog
        (Callback         => Callback,
         Window           => SDL.Video.Windows.Get_Internal (Window),
         Filters          => (1 .. 0 => <>),
         Default_Location => Default_Location,
         Allow_Many       => Allow_Many,
         User_Data        => User_Data);
   end Show_Open_File_Dialog;

   procedure Show_Open_File_Dialog
     (Callback         : in File_Dialog_Callback;
      Filters          : in File_Filter_Lists;
      Default_Location : in String := "";
      Allow_Many       : in Boolean := False;
      User_Data        : in System.Address := System.Null_Address) is
   begin
      Launch_Open_File_Dialog
        (Callback         => Callback,
         Window           => System.Null_Address,
         Filters          => Filters,
         Default_Location => Default_Location,
         Allow_Many       => Allow_Many,
         User_Data        => User_Data);
   end Show_Open_File_Dialog;

   procedure Show_Open_File_Dialog
     (Callback         : in File_Dialog_Callback;
      Window           : in SDL.Video.Windows.Window;
      Filters          : in File_Filter_Lists;
      Default_Location : in String := "";
      Allow_Many       : in Boolean := False;
      User_Data        : in System.Address := System.Null_Address) is
   begin
      Launch_Open_File_Dialog
        (Callback         => Callback,
         Window           => SDL.Video.Windows.Get_Internal (Window),
         Filters          => Filters,
         Default_Location => Default_Location,
         Allow_Many       => Allow_Many,
         User_Data        => User_Data);
   end Show_Open_File_Dialog;

   procedure Show_Save_File_Dialog
     (Callback         : in File_Dialog_Callback;
      Default_Location : in String := "";
      User_Data        : in System.Address := System.Null_Address) is
   begin
      Launch_Save_File_Dialog
        (Callback         => Callback,
         Window           => System.Null_Address,
         Filters          => (1 .. 0 => <>),
         Default_Location => Default_Location,
         User_Data        => User_Data);
   end Show_Save_File_Dialog;

   procedure Show_Save_File_Dialog
     (Callback         : in File_Dialog_Callback;
      Window           : in SDL.Video.Windows.Window;
      Default_Location : in String := "";
      User_Data        : in System.Address := System.Null_Address) is
   begin
      Launch_Save_File_Dialog
        (Callback         => Callback,
         Window           => SDL.Video.Windows.Get_Internal (Window),
         Filters          => (1 .. 0 => <>),
         Default_Location => Default_Location,
         User_Data        => User_Data);
   end Show_Save_File_Dialog;

   procedure Show_Save_File_Dialog
     (Callback         : in File_Dialog_Callback;
      Filters          : in File_Filter_Lists;
      Default_Location : in String := "";
      User_Data        : in System.Address := System.Null_Address) is
   begin
      Launch_Save_File_Dialog
        (Callback         => Callback,
         Window           => System.Null_Address,
         Filters          => Filters,
         Default_Location => Default_Location,
         User_Data        => User_Data);
   end Show_Save_File_Dialog;

   procedure Show_Save_File_Dialog
     (Callback         : in File_Dialog_Callback;
      Window           : in SDL.Video.Windows.Window;
      Filters          : in File_Filter_Lists;
      Default_Location : in String := "";
      User_Data        : in System.Address := System.Null_Address) is
   begin
      Launch_Save_File_Dialog
        (Callback         => Callback,
         Window           => SDL.Video.Windows.Get_Internal (Window),
         Filters          => Filters,
         Default_Location => Default_Location,
         User_Data        => User_Data);
   end Show_Save_File_Dialog;

   procedure Show_Open_Folder_Dialog
     (Callback         : in File_Dialog_Callback;
      Default_Location : in String := "";
      Allow_Many       : in Boolean := False;
      User_Data        : in System.Address := System.Null_Address) is
   begin
      Launch_Open_Folder_Dialog
        (Callback         => Callback,
         Window           => System.Null_Address,
         Default_Location => Default_Location,
         Allow_Many       => Allow_Many,
         User_Data        => User_Data);
   end Show_Open_Folder_Dialog;

   procedure Show_Open_Folder_Dialog
     (Callback         : in File_Dialog_Callback;
      Window           : in SDL.Video.Windows.Window;
      Default_Location : in String := "";
      Allow_Many       : in Boolean := False;
      User_Data        : in System.Address := System.Null_Address) is
   begin
      Launch_Open_Folder_Dialog
        (Callback         => Callback,
         Window           => SDL.Video.Windows.Get_Internal (Window),
         Default_Location => Default_Location,
         Allow_Many       => Allow_Many,
         User_Data        => User_Data);
   end Show_Open_Folder_Dialog;

   procedure Show_File_Dialog_With_Properties
     (Kind       : in File_Dialog_Type;
      Callback   : in File_Dialog_Callback;
      Properties : in SDL.Properties.Property_Set;
      User_Data  : in System.Address := System.Null_Address)
   is
      Effective_Properties : SDL.Properties.Property_Set := SDL.Properties.Create;
      Context              : Dialog_Context_Access :=
        Create_Context (Callback, User_Data, "", (1 .. 0 => <>));
   begin
      SDL.Properties.Copy (Properties, Effective_Properties);

      SDL_Show_File_Dialog_With_Properties
        (Kind       => Kind,
         Callback   => Dialog_Trampoline'Access,
         User_Data  => To_Address (Context),
         Properties => SDL.Properties.Get_ID (Effective_Properties));
   exception
      when others =>
         Release (Context);
         raise;
   end Show_File_Dialog_With_Properties;

   procedure Show_File_Dialog_With_Properties
     (Kind       : in File_Dialog_Type;
      Callback   : in File_Dialog_Callback;
      Properties : in SDL.Properties.Property_Set;
      Filters    : in File_Filter_Lists;
      User_Data  : in System.Address := System.Null_Address)
   is
      Effective_Properties : SDL.Properties.Property_Set := SDL.Properties.Create;
      Context              : Dialog_Context_Access :=
        Create_Context (Callback, User_Data, "", Filters);
   begin
      SDL.Properties.Copy (Properties, Effective_Properties);

      if Filters'Length > 0 then
         SDL.Properties.Set_Pointer
           (Effective_Properties,
            Filters_Pointer_Property,
            Filter_Address (Context));
         SDL.Properties.Set_Number
           (Effective_Properties,
            Filter_Count_Property,
            SDL.Properties.Property_Numbers (Filters'Length));
      end if;

      SDL_Show_File_Dialog_With_Properties
        (Kind       => Kind,
         Callback   => Dialog_Trampoline'Access,
         User_Data  => To_Address (Context),
         Properties => SDL.Properties.Get_ID (Effective_Properties));
   exception
      when others =>
         Release (Context);
         raise;
   end Show_File_Dialog_With_Properties;
end SDL.Dialogs;
