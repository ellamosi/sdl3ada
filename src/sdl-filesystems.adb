with Interfaces.C;
with Interfaces.C.Strings;

with SDL.Error;

package body SDL.Filesystems is
   package C renames Interfaces.C;
   package CS renames Interfaces.C.Strings;
   package Raw renames SDL.Raw.Filesystem;

   use type CS.chars_ptr;
   use type Raw.Glob_Result_Pointers.Pointer;

   procedure Raise_Last_Error
     (Default_Message : in String := "SDL filesystem call failed");

   function Copy_Glob_Result
     (Items : in Raw.Glob_Result_Pointers.Pointer;
      Count : in C.int) return Path_Lists;

   procedure Raise_Last_Error
     (Default_Message : in String := "SDL filesystem call failed")
   is
      Message : constant String := SDL.Error.Get;
   begin
      if Message = "" then
         raise Filesystems_Error with Default_Message;
      end if;

      raise Filesystems_Error with Message;
   end Raise_Last_Error;

   function Copy_Glob_Result
     (Items : in Raw.Glob_Result_Pointers.Pointer;
      Count : in C.int) return Path_Lists
   is
   begin
      if Items = null then
         Raise_Last_Error ("SDL directory glob failed");
      end if;

      if Count < 1 then
         Raw.Free (Items);
         return [];
      end if;

      declare
         Result : Path_Lists (1 .. Positive (Count));
      begin
         for Index in Result'Range loop
            declare
               Position : constant Raw.Glob_Result_Pointers.Pointer :=
                 Items + C.ptrdiff_t (Index - 1);
            begin
               Result (Index) :=
                 US.To_Unbounded_String (CS.Value (Position.all));
            end;
         end loop;

         Raw.Free (Items);
         return Result;
      exception
         when others =>
            Raw.Free (Items);
            raise;
      end;
   end Copy_Glob_Result;

   function Base_Path return UTF_Strings.UTF_String is
      C_Path : constant CS.chars_ptr := Raw.Get_Base_Path;
   begin
      if C_Path = CS.Null_Ptr then
         Raise_Last_Error ("Application base path is unavailable");
      end if;

      --  SDL3 documents SDL_GetBasePath as returning a const string owned by
      --  the library, just like SDL_GetUserFolder.
      return CS.Value (C_Path);
   end Base_Path;

   function Preferences_Path
     (Organisation : in UTF_Strings.UTF_String;
      Application  : in UTF_Strings.UTF_String) return UTF_Strings.UTF_String
   is
      C_Path : constant CS.chars_ptr :=
        Raw.Get_Pref_Path
          (Organisation => C.To_C (Organisation),
           Application  => C.To_C (Application));
   begin
      if C_Path = CS.Null_Ptr then
         Raise_Last_Error ("Application preferences path is unavailable");
      end if;

      declare
         Ada_Path : constant UTF_Strings.UTF_String := CS.Value (C_Path);
      begin
         Raw.Free (C_Path);
         return Ada_Path;
      end;
   end Preferences_Path;

   function User_Folder
     (Folder : in Folders) return UTF_Strings.UTF_String
   is
      C_Path : constant CS.chars_ptr := Raw.Get_User_Folder (Folder);
   begin
      if C_Path = CS.Null_Ptr then
         Raise_Last_Error ("Requested user folder is unavailable");
      end if;

      return CS.Value (C_Path);
   end User_Folder;

   function Current_Directory return UTF_Strings.UTF_String is
      C_Path : constant CS.chars_ptr := Raw.Get_Current_Directory;
   begin
      if C_Path = CS.Null_Ptr then
         Raise_Last_Error ("Current working directory is unavailable");
      end if;

      declare
         Ada_Path : constant UTF_Strings.UTF_String := CS.Value (C_Path);
      begin
         Raw.Free (C_Path);
         return Ada_Path;
      end;
   end Current_Directory;

   procedure Create_Directory (Path : in String) is
   begin
      if not Boolean (Raw.Create_Directory (C.To_C (Path))) then
         Raise_Last_Error ("Directory creation failed");
      end if;
   end Create_Directory;

   function Enumerate_Directory
     (Path      : in String;
      Callback  : in Directory_Enumeration_Callback;
      User_Data : in System.Address := System.Null_Address) return Boolean
   is
   begin
      return Boolean
        (Raw.Enumerate_Directory
           (Path      => C.To_C (Path),
            Callback  => Callback,
            User_Data => User_Data));
   end Enumerate_Directory;

   procedure Remove_Path (Path : in String) is
   begin
      if not Boolean (Raw.Remove_Path (C.To_C (Path))) then
         Raise_Last_Error ("Path removal failed");
      end if;
   end Remove_Path;

   procedure Rename_Path
     (Old_Path : in String;
      New_Path : in String) is
   begin
      if not Boolean
          (Raw.Rename_Path
             (Old_Path => C.To_C (Old_Path),
              New_Path => C.To_C (New_Path)))
      then
         Raise_Last_Error ("Path rename failed");
      end if;
   end Rename_Path;

   procedure Copy_File
     (Old_Path : in String;
      New_Path : in String) is
   begin
      if not Boolean
          (Raw.Copy_File
             (Old_Path => C.To_C (Old_Path),
              New_Path => C.To_C (New_Path)))
      then
         Raise_Last_Error ("File copy failed");
      end if;
   end Copy_File;

   function Get_Path_Info
     (Path : in String;
      Info : out Path_Information) return Boolean
   is
      Raw_Info : aliased Path_Information;
   begin
      if Boolean
          (Raw.Get_Path_Info
             (Path => C.To_C (Path),
              Info => Raw_Info'Access))
      then
         Info := Raw_Info;
         return True;
      end if;

      return False;
   end Get_Path_Info;

   function Exists (Path : in String) return Boolean is
   begin
      return Boolean
        (Raw.Get_Path_Info
           (Path => C.To_C (Path),
            Info => null));
   end Exists;

   function Glob_Directory
     (Path    : in String;
      Pattern : in String;
      Flags   : in Glob_Flags := No_Glob_Flags) return Path_Lists
   is
      Count     : aliased C.int := 0;
      C_Path    : CS.chars_ptr := CS.New_String (Path);
      C_Pattern : CS.chars_ptr := CS.New_String (Pattern);
      Items     : Raw.Glob_Result_Pointers.Pointer;
   begin
      begin
         Items :=
           Raw.Glob_Directory
             (Path    => C_Path,
              Pattern => C_Pattern,
              Flags   => Flags,
              Count   => Count'Access);
      exception
         when others =>
            CS.Free (C_Path);
            CS.Free (C_Pattern);
            raise;
      end;

      CS.Free (C_Path);
      CS.Free (C_Pattern);
      return Copy_Glob_Result (Items => Items, Count => Count);
   end Glob_Directory;

   function Glob_Directory
     (Path  : in String;
      Flags : in Glob_Flags := No_Glob_Flags) return Path_Lists
   is
      Count  : aliased C.int := 0;
      C_Path : CS.chars_ptr := CS.New_String (Path);
      Items  : Raw.Glob_Result_Pointers.Pointer;
   begin
      begin
         Items :=
           Raw.Glob_Directory
             (Path    => C_Path,
              Pattern => CS.Null_Ptr,
              Flags   => Flags,
              Count   => Count'Access);
      exception
         when others =>
            CS.Free (C_Path);
            raise;
      end;

      CS.Free (C_Path);
      return Copy_Glob_Result (Items => Items, Count => Count);
   end Glob_Directory;
end SDL.Filesystems;
