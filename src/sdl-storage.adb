with Ada.Strings.Unbounded;
with Interfaces.C;
with Interfaces.C.Strings;

with SDL.Error;
with SDL.Raw.Filesystem;

package body SDL.Storage is
   package C renames Interfaces.C;
   package CS renames Interfaces.C.Strings;
   package FS_Raw renames SDL.Raw.Filesystem;
   package Raw renames SDL.Raw.Storage;

   use type FS_Raw.Glob_Result_Pointers.Pointer;
   use type Raw.Storage_Access;

   procedure Raise_Last_Error
     (Default_Message : in String := "SDL storage call failed");

   procedure Require_Valid (Self : in Storage);
   procedure Ensure_Unopened (Self : in Storage);

   function Props_ID
     (Properties : in SDL.Properties.Property_Set) return SDL.Properties.Property_ID
   is (Properties.Get_ID);

   function Opened
     (Handle          : in Raw.Storage_Access;
      Default_Message : in String) return Storage;

   function Copy_Glob_Result
     (Items : in FS_Raw.Glob_Result_Pointers.Pointer;
      Count : in C.int) return Path_Lists;

   function Open_Custom_Internal
     (Interface_Definition : in Storage_Interface;
      User_Data            : in System.Address) return Raw.Storage_Access;

   function Glob_Internal
     (Self    : in Storage;
      Path    : in CS.chars_ptr;
      Pattern : in CS.chars_ptr;
      Flags   : in Glob_Flags) return Path_Lists;

   procedure Raise_Last_Error
     (Default_Message : in String := "SDL storage call failed")
   is
      Message : constant String := SDL.Error.Get;
   begin
      if Message = "" then
         raise Storage_Error with Default_Message;
      end if;

      raise Storage_Error with Message;
   end Raise_Last_Error;

   procedure Require_Valid (Self : in Storage) is
   begin
      if Self.Internal = null then
         raise Storage_Error with "Invalid storage handle";
      end if;
   end Require_Valid;

   procedure Ensure_Unopened (Self : in Storage) is
   begin
      if Self.Internal /= null then
         raise Storage_Error with "Storage handle is already open";
      end if;
   end Ensure_Unopened;

   function Opened
     (Handle          : in Raw.Storage_Access;
      Default_Message : in String) return Storage
   is
   begin
      if Handle = null then
         Raise_Last_Error (Default_Message);
      end if;

      return Result : Storage do
         Result.Internal := Handle;
      end return;
   end Opened;

   function Copy_Glob_Result
     (Items : in FS_Raw.Glob_Result_Pointers.Pointer;
      Count : in C.int) return Path_Lists
   is
   begin
      if Items = null then
         Raise_Last_Error ("SDL storage glob failed");
      end if;

      if Count < 1 then
         FS_Raw.Free (Items);
         return [];
      end if;

      declare
         Result : Path_Lists (1 .. Positive (Count));
      begin
         for Index in Result'Range loop
            declare
               Position : constant FS_Raw.Glob_Result_Pointers.Pointer :=
                 Items + C.ptrdiff_t (Index - 1);
            begin
               Result (Index) :=
                 Ada.Strings.Unbounded.To_Unbounded_String
                   (CS.Value (Position.all));
            end;
         end loop;

         FS_Raw.Free (Items);
         return Result;
      exception
         when others =>
            FS_Raw.Free (Items);
            raise;
      end;
   end Copy_Glob_Result;

   function Open_Custom_Internal
     (Interface_Definition : in Storage_Interface;
      User_Data            : in System.Address) return Raw.Storage_Access
   is
      Local_Interface : aliased constant Storage_Interface := Interface_Definition;
   begin
      return Raw.Open_Storage (Local_Interface'Access, User_Data);
   end Open_Custom_Internal;

   function Glob_Internal
     (Self    : in Storage;
      Path    : in CS.chars_ptr;
      Pattern : in CS.chars_ptr;
      Flags   : in Glob_Flags) return Path_Lists
   is
      Count : aliased C.int := 0;
      Items : FS_Raw.Glob_Result_Pointers.Pointer;
   begin
      Require_Valid (Self);

      Items :=
        Raw.Glob_Storage_Directory
          (Self    => Self.Internal,
           Path    => Path,
           Pattern => Pattern,
           Flags   => Flags,
           Count   => Count'Access);
      return Copy_Glob_Result (Items => Items, Count => Count);
   end Glob_Internal;

   overriding
   procedure Finalize (Self : in out Storage) is
      Ignored : Boolean;
   begin
      if Self.Internal /= null then
         Ignored := Boolean (Raw.Close_Storage (Self.Internal));
         pragma Unreferenced (Ignored);
         Self.Internal := null;
      end if;
   end Finalize;

   function Open_Title return Storage is
   begin
      return Opened
        (Handle =>
           Raw.Open_Title_Storage
             (Override_Path => CS.Null_Ptr,
              Props         => SDL.Properties.Null_Property_ID),
         Default_Message => "Title storage open failed");
   end Open_Title;

   function Open_Title (Override_Path : in String) return Storage is
      C_Path : CS.chars_ptr := CS.New_String (Override_Path);
      Handle : Raw.Storage_Access;
   begin
      begin
         Handle :=
           Raw.Open_Title_Storage
             (Override_Path => C_Path,
              Props         => SDL.Properties.Null_Property_ID);
      exception
         when others =>
            CS.Free (C_Path);
            raise;
      end;

      CS.Free (C_Path);
      return Opened (Handle, "Title storage open failed");
   end Open_Title;

   function Open_Title
     (Properties : in SDL.Properties.Property_Set) return Storage
   is
   begin
      return Opened
        (Handle =>
           Raw.Open_Title_Storage
             (Override_Path => CS.Null_Ptr,
              Props         => Props_ID (Properties)),
         Default_Message => "Title storage open failed");
   end Open_Title;

   function Open_Title
     (Override_Path : in String;
      Properties    : in SDL.Properties.Property_Set) return Storage
   is
      C_Path : CS.chars_ptr := CS.New_String (Override_Path);
      Handle : Raw.Storage_Access;
   begin
      begin
         Handle :=
           Raw.Open_Title_Storage
             (Override_Path => C_Path,
              Props         => Props_ID (Properties));
      exception
         when others =>
            CS.Free (C_Path);
            raise;
      end;

      CS.Free (C_Path);
      return Opened (Handle, "Title storage open failed");
   end Open_Title;

   procedure Open_Title (Self : in out Storage) is
      Handle : Raw.Storage_Access;
   begin
      Ensure_Unopened (Self);

      Handle :=
        Raw.Open_Title_Storage
          (Override_Path => CS.Null_Ptr,
           Props         => SDL.Properties.Null_Property_ID);

      if Handle = null then
         Raise_Last_Error ("Title storage open failed");
      end if;

      Self.Internal := Handle;
   end Open_Title;

   procedure Open_Title
     (Self          : in out Storage;
      Override_Path : in String)
   is
      C_Path : CS.chars_ptr := CS.New_String (Override_Path);
      Handle : Raw.Storage_Access;
   begin
      Ensure_Unopened (Self);

      begin
         Handle :=
           Raw.Open_Title_Storage
             (Override_Path => C_Path,
              Props         => SDL.Properties.Null_Property_ID);
      exception
         when others =>
            CS.Free (C_Path);
            raise;
      end;

      CS.Free (C_Path);

      if Handle = null then
         Raise_Last_Error ("Title storage open failed");
      end if;

      Self.Internal := Handle;
   end Open_Title;

   procedure Open_Title
     (Self       : in out Storage;
      Properties : in SDL.Properties.Property_Set)
   is
      Handle : Raw.Storage_Access;
   begin
      Ensure_Unopened (Self);

      Handle :=
        Raw.Open_Title_Storage
          (Override_Path => CS.Null_Ptr,
           Props         => Props_ID (Properties));

      if Handle = null then
         Raise_Last_Error ("Title storage open failed");
      end if;

      Self.Internal := Handle;
   end Open_Title;

   procedure Open_Title
     (Self          : in out Storage;
      Override_Path : in String;
      Properties    : in SDL.Properties.Property_Set)
   is
      C_Path : CS.chars_ptr := CS.New_String (Override_Path);
      Handle : Raw.Storage_Access;
   begin
      Ensure_Unopened (Self);

      begin
         Handle :=
           Raw.Open_Title_Storage
             (Override_Path => C_Path,
              Props         => Props_ID (Properties));
      exception
         when others =>
            CS.Free (C_Path);
            raise;
      end;

      CS.Free (C_Path);

      if Handle = null then
         Raise_Last_Error ("Title storage open failed");
      end if;

      Self.Internal := Handle;
   end Open_Title;

   function Open_User
     (Organisation : in String;
      Application  : in String) return Storage
   is
      C_Organisation : CS.chars_ptr := CS.New_String (Organisation);
      C_Application  : CS.chars_ptr := CS.New_String (Application);
      Handle         : Raw.Storage_Access;
   begin
      begin
         Handle :=
           Raw.Open_User_Storage
             (Organisation => C_Organisation,
              Application  => C_Application,
              Props        => SDL.Properties.Null_Property_ID);
      exception
         when others =>
            CS.Free (C_Organisation);
            CS.Free (C_Application);
            raise;
      end;

      CS.Free (C_Organisation);
      CS.Free (C_Application);
      return Opened (Handle, "User storage open failed");
   end Open_User;

   function Open_User
     (Organisation : in String;
      Application  : in String;
      Properties   : in SDL.Properties.Property_Set) return Storage
   is
      C_Organisation : CS.chars_ptr := CS.New_String (Organisation);
      C_Application  : CS.chars_ptr := CS.New_String (Application);
      Handle         : Raw.Storage_Access;
   begin
      begin
         Handle :=
           Raw.Open_User_Storage
             (Organisation => C_Organisation,
              Application  => C_Application,
              Props        => Props_ID (Properties));
      exception
         when others =>
            CS.Free (C_Organisation);
            CS.Free (C_Application);
            raise;
      end;

      CS.Free (C_Organisation);
      CS.Free (C_Application);
      return Opened (Handle, "User storage open failed");
   end Open_User;

   procedure Open_User
     (Self         : in out Storage;
      Organisation : in String;
      Application  : in String)
   is
      C_Organisation : CS.chars_ptr := CS.New_String (Organisation);
      C_Application  : CS.chars_ptr := CS.New_String (Application);
      Handle         : Raw.Storage_Access;
   begin
      Ensure_Unopened (Self);

      begin
         Handle :=
           Raw.Open_User_Storage
             (Organisation => C_Organisation,
              Application  => C_Application,
              Props        => SDL.Properties.Null_Property_ID);
      exception
         when others =>
            CS.Free (C_Organisation);
            CS.Free (C_Application);
            raise;
      end;

      CS.Free (C_Organisation);
      CS.Free (C_Application);

      if Handle = null then
         Raise_Last_Error ("User storage open failed");
      end if;

      Self.Internal := Handle;
   end Open_User;

   procedure Open_User
     (Self         : in out Storage;
      Organisation : in String;
      Application  : in String;
      Properties   : in SDL.Properties.Property_Set)
   is
      C_Organisation : CS.chars_ptr := CS.New_String (Organisation);
      C_Application  : CS.chars_ptr := CS.New_String (Application);
      Handle         : Raw.Storage_Access;
   begin
      Ensure_Unopened (Self);

      begin
         Handle :=
           Raw.Open_User_Storage
             (Organisation => C_Organisation,
              Application  => C_Application,
              Props        => Props_ID (Properties));
      exception
         when others =>
            CS.Free (C_Organisation);
            CS.Free (C_Application);
            raise;
      end;

      CS.Free (C_Organisation);
      CS.Free (C_Application);

      if Handle = null then
         Raise_Last_Error ("User storage open failed");
      end if;

      Self.Internal := Handle;
   end Open_User;

   function Open_File return Storage is
   begin
      return Opened
        (Handle => Raw.Open_File_Storage (CS.Null_Ptr),
         Default_Message => "Filesystem storage open failed");
   end Open_File;

   function Open_File (Path : in String) return Storage is
      C_Path : CS.chars_ptr := CS.New_String (Path);
      Handle : Raw.Storage_Access;
   begin
      begin
         Handle := Raw.Open_File_Storage (C_Path);
      exception
         when others =>
            CS.Free (C_Path);
            raise;
      end;

      CS.Free (C_Path);
      return Opened (Handle, "Filesystem storage open failed");
   end Open_File;

   procedure Open_File (Self : in out Storage) is
      Handle : Raw.Storage_Access;
   begin
      Ensure_Unopened (Self);

      Handle := Raw.Open_File_Storage (CS.Null_Ptr);

      if Handle = null then
         Raise_Last_Error ("Filesystem storage open failed");
      end if;

      Self.Internal := Handle;
   end Open_File;

   procedure Open_File
     (Self : in out Storage;
      Path : in String)
   is
      C_Path : CS.chars_ptr := CS.New_String (Path);
      Handle : Raw.Storage_Access;
   begin
      Ensure_Unopened (Self);

      begin
         Handle := Raw.Open_File_Storage (C_Path);
      exception
         when others =>
            CS.Free (C_Path);
            raise;
      end;

      CS.Free (C_Path);

      if Handle = null then
         Raise_Last_Error ("Filesystem storage open failed");
      end if;

      Self.Internal := Handle;
   end Open_File;

   function Open
     (Interface_Definition : in Storage_Interface;
      User_Data            : in System.Address := System.Null_Address)
      return Storage
   is
   begin
      return Opened
        (Handle => Open_Custom_Internal (Interface_Definition, User_Data),
         Default_Message => "Custom storage open failed");
   end Open;

   procedure Open
     (Self                 : in out Storage;
      Interface_Definition : in Storage_Interface;
      User_Data            : in System.Address := System.Null_Address)
   is
      Handle : Raw.Storage_Access;
   begin
      Ensure_Unopened (Self);

      Handle := Open_Custom_Internal (Interface_Definition, User_Data);

      if Handle = null then
         Raise_Last_Error ("Custom storage open failed");
      end if;

      Self.Internal := Handle;
   end Open;

   procedure Close (Self : in out Storage) is
      Handle : Raw.Storage_Access;
   begin
      if Self.Internal = null then
         return;
      end if;

      Handle := Self.Internal;
      Self.Internal := null;

      if not Boolean (Raw.Close_Storage (Handle)) then
         Raise_Last_Error ("Storage close failed");
      end if;
   end Close;

   function Is_Null (Self : in Storage) return Boolean is
     (Self.Internal = null);

   function Get_Handle
     (Self : in Storage) return Storage_Handle is
     (Self.Internal);

   function Ready (Self : in Storage) return Boolean is
   begin
      Require_Valid (Self);
      return Boolean (Raw.Storage_Ready (Self.Internal));
   end Ready;

   function File_Size
     (Self : in Storage;
      Path : in String) return Sizes
   is
      C_Path : CS.chars_ptr := CS.New_String (Path);
      Length : aliased Sizes := 0;
   begin
      Require_Valid (Self);

      begin
         if not Boolean
             (Raw.Get_Storage_File_Size
                (Self   => Self.Internal,
                 Path   => C_Path,
                 Length => Length'Access))
         then
            Raise_Last_Error ("Storage file size query failed");
         end if;
      exception
         when others =>
            CS.Free (C_Path);
            raise;
      end;

      CS.Free (C_Path);
      return Length;
   end File_Size;

   procedure Read_File
     (Self        : in Storage;
      Path        : in String;
      Destination : in System.Address;
      Length      : in Sizes)
   is
      C_Path : CS.chars_ptr := CS.New_String (Path);
   begin
      Require_Valid (Self);

      begin
         if not Boolean
             (Raw.Read_Storage_File
                (Self        => Self.Internal,
                 Path        => C_Path,
                 Destination => Destination,
                 Length      => Length))
         then
            Raise_Last_Error ("Storage file read failed");
         end if;
      exception
         when others =>
            CS.Free (C_Path);
            raise;
      end;

      CS.Free (C_Path);
   end Read_File;

   procedure Write_File
     (Self   : in Storage;
      Path   : in String;
      Source : in System.Address;
      Length : in Sizes)
   is
      C_Path : CS.chars_ptr := CS.New_String (Path);
   begin
      Require_Valid (Self);

      begin
         if not Boolean
             (Raw.Write_Storage_File
                (Self   => Self.Internal,
                 Path   => C_Path,
                 Source => Source,
                 Length => Length))
         then
            Raise_Last_Error ("Storage file write failed");
         end if;
      exception
         when others =>
            CS.Free (C_Path);
            raise;
      end;

      CS.Free (C_Path);
   end Write_File;

   procedure Create_Directory
     (Self : in Storage;
      Path : in String)
   is
      C_Path : CS.chars_ptr := CS.New_String (Path);
   begin
      Require_Valid (Self);

      begin
         if not Boolean
             (Raw.Create_Storage_Directory
                (Self => Self.Internal,
                 Path => C_Path))
         then
            Raise_Last_Error ("Storage directory creation failed");
         end if;
      exception
         when others =>
            CS.Free (C_Path);
            raise;
      end;

      CS.Free (C_Path);
   end Create_Directory;

   function Enumerate_Directory
     (Self      : in Storage;
      Path      : in String;
      Callback  : in Directory_Enumeration_Callback;
      User_Data : in System.Address := System.Null_Address) return Boolean
   is
      C_Path : CS.chars_ptr := CS.New_String (Path);
      Result : Boolean;
   begin
      Require_Valid (Self);

      begin
         Result :=
           Boolean
             (Raw.Enumerate_Storage_Directory
                (Self      => Self.Internal,
                 Path      => C_Path,
                 Callback  => Callback,
                 User_Data => User_Data));
      exception
         when others =>
            CS.Free (C_Path);
            raise;
      end;

      CS.Free (C_Path);
      return Result;
   end Enumerate_Directory;

   function Enumerate_Root
     (Self      : in Storage;
      Callback  : in Directory_Enumeration_Callback;
      User_Data : in System.Address := System.Null_Address) return Boolean
   is
   begin
      Require_Valid (Self);

      return Boolean
        (Raw.Enumerate_Storage_Directory
           (Self      => Self.Internal,
            Path      => CS.Null_Ptr,
            Callback  => Callback,
            User_Data => User_Data));
   end Enumerate_Root;

   procedure Remove_Path
     (Self : in Storage;
      Path : in String)
   is
      C_Path : CS.chars_ptr := CS.New_String (Path);
   begin
      Require_Valid (Self);

      begin
         if not Boolean
             (Raw.Remove_Storage_Path
                (Self => Self.Internal,
                 Path => C_Path))
         then
            Raise_Last_Error ("Storage path removal failed");
         end if;
      exception
         when others =>
            CS.Free (C_Path);
            raise;
      end;

      CS.Free (C_Path);
   end Remove_Path;

   procedure Rename_Path
     (Self     : in Storage;
      Old_Path : in String;
      New_Path : in String)
   is
      C_Old_Path : CS.chars_ptr := CS.New_String (Old_Path);
      C_New_Path : CS.chars_ptr := CS.New_String (New_Path);
   begin
      Require_Valid (Self);

      begin
         if not Boolean
             (Raw.Rename_Storage_Path
                (Self     => Self.Internal,
                 Old_Path => C_Old_Path,
                 New_Path => C_New_Path))
         then
            Raise_Last_Error ("Storage path rename failed");
         end if;
      exception
         when others =>
            CS.Free (C_Old_Path);
            CS.Free (C_New_Path);
            raise;
      end;

      CS.Free (C_Old_Path);
      CS.Free (C_New_Path);
   end Rename_Path;

   procedure Copy_File
     (Self     : in Storage;
      Old_Path : in String;
      New_Path : in String)
   is
      C_Old_Path : CS.chars_ptr := CS.New_String (Old_Path);
      C_New_Path : CS.chars_ptr := CS.New_String (New_Path);
   begin
      Require_Valid (Self);

      begin
         if not Boolean
             (Raw.Copy_Storage_File
                (Self     => Self.Internal,
                 Old_Path => C_Old_Path,
                 New_Path => C_New_Path))
         then
            Raise_Last_Error ("Storage file copy failed");
         end if;
      exception
         when others =>
            CS.Free (C_Old_Path);
            CS.Free (C_New_Path);
            raise;
      end;

      CS.Free (C_Old_Path);
      CS.Free (C_New_Path);
   end Copy_File;

   function Get_Path_Info
     (Self : in Storage;
      Path : in String;
      Info : out Path_Information) return Boolean
   is
      C_Path   : CS.chars_ptr := CS.New_String (Path);
      Raw_Info : aliased Path_Information;
      Result   : Boolean;
   begin
      Require_Valid (Self);

      begin
         Result :=
           Boolean
             (Raw.Get_Storage_Path_Info
                (Self => Self.Internal,
                 Path => C_Path,
                 Info => Raw_Info'Access));
      exception
         when others =>
            CS.Free (C_Path);
            raise;
      end;

      CS.Free (C_Path);

      if Result then
         Info := Raw_Info;
      end if;

      return Result;
   end Get_Path_Info;

   function Exists
     (Self : in Storage;
      Path : in String) return Boolean
   is
      C_Path : CS.chars_ptr := CS.New_String (Path);
      Result : Boolean;
   begin
      Require_Valid (Self);

      begin
         Result :=
           Boolean
             (Raw.Get_Storage_Path_Info
                (Self => Self.Internal,
                 Path => C_Path,
                 Info => null));
      exception
         when others =>
            CS.Free (C_Path);
            raise;
      end;

      CS.Free (C_Path);
      return Result;
   end Exists;

   function Space_Remaining
     (Self : in Storage) return Sizes
   is
   begin
      Require_Valid (Self);
      return Raw.Get_Storage_Space_Remaining (Self.Internal);
   end Space_Remaining;

   function Glob_Directory
     (Self    : in Storage;
      Path    : in String;
      Pattern : in String;
      Flags   : in Glob_Flags := No_Glob_Flags) return Path_Lists
   is
      C_Path    : CS.chars_ptr := CS.New_String (Path);
      C_Pattern : CS.chars_ptr := CS.New_String (Pattern);
   begin
      begin
         declare
            Result : constant Path_Lists :=
              Glob_Internal
                (Self    => Self,
                 Path    => C_Path,
                 Pattern => C_Pattern,
                 Flags   => Flags);
         begin
            CS.Free (C_Path);
            CS.Free (C_Pattern);
            return Result;
         end;
      exception
         when others =>
            CS.Free (C_Path);
            CS.Free (C_Pattern);
            raise;
      end;
   end Glob_Directory;

   function Glob_Directory
     (Self  : in Storage;
      Path  : in String;
      Flags : in Glob_Flags := No_Glob_Flags) return Path_Lists
   is
      C_Path : CS.chars_ptr := CS.New_String (Path);
   begin
      begin
         declare
            Result : constant Path_Lists :=
              Glob_Internal
                (Self    => Self,
                 Path    => C_Path,
                 Pattern => CS.Null_Ptr,
                 Flags   => Flags);
         begin
            CS.Free (C_Path);
            return Result;
         end;
      exception
         when others =>
            CS.Free (C_Path);
            raise;
      end;
   end Glob_Directory;

   function Glob_Root
     (Self    : in Storage;
      Pattern : in String;
      Flags   : in Glob_Flags := No_Glob_Flags) return Path_Lists
   is
      C_Pattern : CS.chars_ptr := CS.New_String (Pattern);
   begin
      begin
         declare
            Result : constant Path_Lists :=
              Glob_Internal
                (Self    => Self,
                 Path    => CS.Null_Ptr,
                 Pattern => C_Pattern,
                 Flags   => Flags);
         begin
            CS.Free (C_Pattern);
            return Result;
         end;
      exception
         when others =>
            CS.Free (C_Pattern);
            raise;
      end;
   end Glob_Root;

   function Glob_Root
     (Self  : in Storage;
      Flags : in Glob_Flags := No_Glob_Flags) return Path_Lists
   is
   begin
      return Glob_Internal
        (Self    => Self,
         Path    => CS.Null_Ptr,
         Pattern => CS.Null_Ptr,
         Flags   => Flags);
   end Glob_Root;
end SDL.Storage;
