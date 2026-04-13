with Ada.Directories;
with Ada.Strings.Fixed;
with Ada.Text_IO;
with Interfaces;
with Interfaces.C.Strings;
with System;

with SDL;
with SDL.Error;
with SDL.Filesystems;
with SDL.Storage;
with SDL.Time;
with SDL.Timers;

procedure TestFilesystem is
   package CS renames Interfaces.C.Strings;

   use type SDL.Filesystems.Path_Types;
   use type SDL.Time.Times;

   Initialised     : Boolean := False;
   Current_Storage : access SDL.Storage.Storage := null;

   function Trim (Item : in String) return String is
     (Ada.Strings.Fixed.Trim (Item, Ada.Strings.Both));

   procedure Require_SDL
     (Condition : in Boolean;
      Message   : in String) is
   begin
      if not Condition then
         raise Program_Error with Message & ": " & SDL.Error.Get;
      end if;
   end Require_SDL;

   function Join_Path
     (Directory_Name : in String;
      File_Name      : in String) return String is
   begin
      if Directory_Name = "" then
         return File_Name;
      elsif Directory_Name (Directory_Name'Last) = '/' then
         return Directory_Name & File_Name;
      else
         return Directory_Name & "/" & File_Name;
      end if;
   end Join_Path;

   function Path_Type_Image
     (Value : in SDL.Filesystems.Path_Types) return String is
   begin
      case Value is
         when SDL.Filesystems.File_Path =>
            return "FILE";
         when SDL.Filesystems.Directory_Path =>
            return "DIRECTORY";
         when SDL.Filesystems.Other_Path =>
            return "OTHER";
         when SDL.Filesystems.Missing_Path =>
            return "MISSING";
      end case;
   end Path_Type_Image;

   function Timestamp_Image (Value : in SDL.Time.Times) return String is
   begin
      if Value = 0 then
         return "0";
      end if;

      declare
         Date_Time : constant SDL.Time.Date_Time :=
           SDL.Time.To_Date_Time (Value);
      begin
         return
           Trim (Integer'Image (Integer (Date_Time.Year)))
           & "-"
           & Trim (Integer'Image (Integer (Date_Time.Month)))
           & "-"
           & Trim (Integer'Image (Integer (Date_Time.Day)))
           & " "
           & Trim (Integer'Image (Integer (Date_Time.Hour)))
           & ":"
           & Trim (Integer'Image (Integer (Date_Time.Minute)))
           & ":"
           & Trim (Integer'Image (Integer (Date_Time.Second)));
      exception
         when SDL.Time.Time_Error =>
            return Trim (Interfaces.Integer_64'Image (Value));
      end;
   end Timestamp_Image;

   procedure Print_Path_Info
     (Prefix : in String;
      Path   : in String;
      Info   : in SDL.Filesystems.Path_Information) is
   begin
      Ada.Text_IO.Put_Line
        (Prefix
         & " "
         & Path
         & " (type="
         & Path_Type_Image (Info.Kind)
         & ", size="
         & Trim (Interfaces.Unsigned_64'Image (Info.Size))
         & ", create="
         & Timestamp_Image (Info.Created_At)
         & ", mod="
         & Timestamp_Image (Info.Modified_At)
         & ", access="
         & Timestamp_Image (Info.Accessed_At)
         & ")");
   end Print_Path_Info;

   function Print_Filesystem_Entry
     (User_Data      : in System.Address;
      Directory_Name : in CS.chars_ptr;
      File_Name      : in CS.chars_ptr) return SDL.Filesystems.Enumeration_Results
   with Convention => C;

   function Print_Filesystem_Entry
     (User_Data      : in System.Address;
      Directory_Name : in CS.chars_ptr;
      File_Name      : in CS.chars_ptr) return SDL.Filesystems.Enumeration_Results
   is
      pragma Unreferenced (User_Data);

      Full_Path : constant String :=
        Join_Path (CS.Value (Directory_Name), CS.Value (File_Name));
      Info      : SDL.Filesystems.Path_Information;
   begin
      if SDL.Filesystems.Get_Path_Info (Full_Path, Info) then
         Print_Path_Info ("DIRECTORY", Full_Path, Info);
      else
         Ada.Text_IO.Put_Line
           ("DIRECTORY " & Full_Path & " (query failed: " & SDL.Error.Get & ")");
      end if;

      return SDL.Filesystems.Continue_Enumeration;
   end Print_Filesystem_Entry;

   function Print_Storage_Entry
     (User_Data      : in System.Address;
      Directory_Name : in CS.chars_ptr;
      File_Name      : in CS.chars_ptr) return SDL.Filesystems.Enumeration_Results
   with Convention => C;

   function Print_Storage_Entry
     (User_Data      : in System.Address;
      Directory_Name : in CS.chars_ptr;
      File_Name      : in CS.chars_ptr) return SDL.Filesystems.Enumeration_Results
   is
      pragma Unreferenced (User_Data);

      Relative_Path : constant String :=
        Join_Path (CS.Value (Directory_Name), CS.Value (File_Name));
      Info          : SDL.Storage.Path_Information;
   begin
      if Current_Storage /= null
        and then SDL.Storage.Get_Path_Info (Current_Storage.all, Relative_Path, Info)
      then
         Print_Path_Info ("STORAGE", Relative_Path, Info);
      else
         Ada.Text_IO.Put_Line
           ("STORAGE " & Relative_Path & " (query failed: " & SDL.Error.Get & ")");
      end if;

      return SDL.Filesystems.Continue_Enumeration;
   end Print_Storage_Entry;

   function Wait_Until_Ready
     (Device : in SDL.Storage.Storage) return Boolean
   is
   begin
      for Attempt in 1 .. 200 loop
         if SDL.Storage.Ready (Device) then
            return True;
         end if;

         SDL.Timers.Wait_Delay (5);
      end loop;

      return False;
   end Wait_Until_Ready;

   procedure Cleanup_Workspace (Path : in String) is
   begin
      if Path /= "" and then Ada.Directories.Exists (Path) then
         Ada.Directories.Delete_Tree (Path);
      end if;
   exception
      when others =>
         null;
   end Cleanup_Workspace;

   procedure Print_User_Folder
     (Label  : in String;
      Folder : in SDL.Filesystems.Folders) is
   begin
      Ada.Text_IO.Put_Line
        (Label & ": " & String (SDL.Filesystems.User_Folder (Folder)));
   exception
      when SDL.Filesystems.Filesystems_Error =>
         Ada.Text_IO.Put_Line (Label & ": unavailable (" & SDL.Error.Get & ")");
   end Print_User_Folder;
begin
   Require_SDL
     (SDL.Set_App_Metadata
        ("SDL Test Filesystem",
         "1.0",
         "com.example.testfilesystem"),
      "Unable to set application metadata");

   Require_SDL
     (SDL.Initialise (SDL.Null_Init_Flags),
      "Couldn't initialize SDL");
   Initialised := True;

   declare
      Current_Directory : constant String :=
        String (SDL.Filesystems.Current_Directory);
      Workspace         : constant String :=
        Ada.Directories.Compose (Current_Directory, "testfilesystem_workspace");
      Alpha_Text        : aliased constant String := "alpha";
      Beta_Text         : aliased constant String := "beta";
   begin
      Ada.Text_IO.Put_Line ("Base path: " & String (SDL.Filesystems.Base_Path));
      Ada.Text_IO.Put_Line ("Current directory: " & Current_Directory);
      Ada.Text_IO.Put_Line
        ("Preferences path: "
         & String (SDL.Filesystems.Preferences_Path ("EllaMosi", "testfilesystem")));
      Print_User_Folder ("Home folder", SDL.Filesystems.Home_Folder);
      Print_User_Folder ("Documents folder", SDL.Filesystems.Documents_Folder);
      Print_User_Folder ("Downloads folder", SDL.Filesystems.Downloads_Folder);

      Cleanup_Workspace (Workspace);
      SDL.Filesystems.Create_Directory (Workspace);

      declare
         Device : aliased SDL.Storage.Storage := SDL.Storage.Open_File (Workspace);
      begin
         Require_SDL
           (not SDL.Storage.Is_Null (Device),
            "Storage handle should be valid");
         Require_SDL
           (Wait_Until_Ready (Device),
            "File storage never became ready");

         SDL.Storage.Write_File
           (Self   => Device,
            Path   => "alpha.txt",
            Source => Alpha_Text'Address,
            Length => SDL.Storage.Sizes (Alpha_Text'Length));
         SDL.Storage.Create_Directory (Device, "nested");
         SDL.Storage.Write_File
           (Self   => Device,
            Path   => "nested/beta.txt",
            Source => Beta_Text'Address,
            Length => SDL.Storage.Sizes (Beta_Text'Length));

         declare
            Info : SDL.Filesystems.Path_Information;
         begin
            if SDL.Filesystems.Get_Path_Info
                (Ada.Directories.Compose (Workspace, "alpha.txt"), Info)
            then
               Print_Path_Info ("DIRECTORY", Ada.Directories.Compose (Workspace, "alpha.txt"), Info);
            end if;

            if SDL.Filesystems.Get_Path_Info
                (Ada.Directories.Compose (Workspace, "nested"), Info)
            then
               Print_Path_Info ("DIRECTORY", Ada.Directories.Compose (Workspace, "nested"), Info);
            end if;
         end;

         Ada.Text_IO.Put_Line ("Filesystem enumeration of workspace:");
         if not SDL.Filesystems.Enumerate_Directory
             (Workspace, Print_Filesystem_Entry'Unrestricted_Access)
         then
            Ada.Text_IO.Put_Line
              ("  enumeration failed: " & SDL.Error.Get);
         end if;

         Ada.Text_IO.Put_Line ("Filesystem enumeration of nested/:");
         if not SDL.Filesystems.Enumerate_Directory
             (Ada.Directories.Compose (Workspace, "nested"),
              Print_Filesystem_Entry'Unrestricted_Access)
         then
            Ada.Text_IO.Put_Line
              ("  nested enumeration failed: " & SDL.Error.Get);
         end if;

         declare
            Matches : constant SDL.Filesystems.Path_Lists :=
              SDL.Filesystems.Glob_Directory (Workspace, "*.txt");
         begin
            Ada.Text_IO.Put_Line ("Filesystem glob (*.txt):");
            for Item of Matches loop
               Ada.Text_IO.Put_Line ("  " & SDL.Filesystems.US.To_String (Item));
            end loop;
         end;

         Current_Storage := Device'Unchecked_Access;

         Ada.Text_IO.Put_Line ("Storage enumeration of root:");
         if not SDL.Storage.Enumerate_Root
             (Device, Print_Storage_Entry'Unrestricted_Access)
         then
            Ada.Text_IO.Put_Line
              ("  storage root enumeration failed: " & SDL.Error.Get);
         end if;

         Ada.Text_IO.Put_Line ("Storage enumeration of nested/:");
         if not SDL.Storage.Enumerate_Directory
             (Device,
              "nested",
              Print_Storage_Entry'Unrestricted_Access)
         then
            Ada.Text_IO.Put_Line
              ("  storage nested enumeration failed: " & SDL.Error.Get);
         end if;

         declare
            Matches : constant SDL.Storage.Path_Lists :=
              SDL.Storage.Glob_Root (Device, "*.txt");
         begin
            Ada.Text_IO.Put_Line ("Storage glob (*.txt):");
            for Item of Matches loop
               Ada.Text_IO.Put_Line ("  " & SDL.Filesystems.US.To_String (Item));
            end loop;
         end;

         Current_Storage := null;
         SDL.Storage.Close (Device);
      end;

      Cleanup_Workspace (Workspace);
   end;

   SDL.Quit;
exception
   when others =>
      if Initialised then
         SDL.Quit;
      end if;
      raise;
end TestFilesystem;
