with Ada.Directories;
with Ada.Exceptions;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Interfaces;
with Interfaces.C.Strings;
with System;
with System.Address_To_Access_Conversions;

with SDL.Error;
with SDL.Filesystems;
with SDL.Storage;
with SDL.Timers;

procedure Storage_Smoke is
   package CS renames Interfaces.C.Strings;
   package US renames Ada.Strings.Unbounded;

   Payload : constant String := "phase3-storage-payload";
   subtype Payload_String is String (1 .. Payload'Length);

   type Enumeration_State is record
      Count            : Natural := 0;
      Saw_Data_Dir     : Boolean := False;
      Saw_Renamed_File : Boolean := False;
   end record;

   package Enumeration_State_Pointers is new System.Address_To_Access_Conversions
     (Enumeration_State);

   Workspace_Dir : US.Unbounded_String := US.Null_Unbounded_String;

   use type Enumeration_State_Pointers.Object_Pointer;
   use type Interfaces.Unsigned_64;
   use type SDL.Filesystems.Path_Types;
   use type SDL.Storage.Sizes;

   procedure Require
     (Condition : in Boolean;
      Message   : in String);

   procedure Cleanup_Workspace (Path : in String);

   function Collect_Entries
     (User_Data      : in System.Address;
      Directory_Name : in CS.chars_ptr;
      File_Name      : in CS.chars_ptr) return SDL.Filesystems.Enumeration_Results
   with Convention => C;

   function Contains
     (Items : in SDL.Filesystems.Path_Lists;
      Name  : in String) return Boolean;

   function Wait_Until_Ready
     (Device : in SDL.Storage.Storage) return Boolean;

   procedure Require
     (Condition : in Boolean;
      Message   : in String) is
   begin
      if not Condition then
         raise Program_Error with Message;
      end if;
   end Require;

   procedure Cleanup_Workspace (Path : in String) is
   begin
      if Path /= "" and then Ada.Directories.Exists (Path) then
         Ada.Directories.Delete_Tree (Path);
      end if;
   exception
      when others =>
         null;
   end Cleanup_Workspace;

   function Collect_Entries
     (User_Data      : in System.Address;
      Directory_Name : in CS.chars_ptr;
      File_Name      : in CS.chars_ptr) return SDL.Filesystems.Enumeration_Results
   is
      pragma Unreferenced (Directory_Name);

      State : constant Enumeration_State_Pointers.Object_Pointer :=
        Enumeration_State_Pointers.To_Pointer (User_Data);
   begin
      if State = null then
         return SDL.Filesystems.Failure_Enumeration;
      end if;

      State.all.Count := State.all.Count + 1;

      declare
         Name : constant String := CS.Value (File_Name);
      begin
         if Name = "data" then
            State.all.Saw_Data_Dir := True;
         elsif Name = "renamed.txt" then
            State.all.Saw_Renamed_File := True;
         end if;
      end;

      return SDL.Filesystems.Continue_Enumeration;
   end Collect_Entries;

   function Contains
     (Items : in SDL.Filesystems.Path_Lists;
      Name  : in String) return Boolean
   is
   begin
      for Item of Items loop
         if US.To_String (Item) = Name then
            return True;
         end if;
      end loop;

      return False;
   end Contains;

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
begin
   declare
      Base_Path         : constant String := SDL.Filesystems.Base_Path;
      Current_Directory : constant String := SDL.Filesystems.Current_Directory;
      Workspace         : constant String :=
        Current_Directory & "storage_smoke_workspace";
      Data_Directory    : constant String := Workspace & "/data";
      Renamed_Subpath   : constant String := "data/renamed.txt";
      Renamed_Path      : constant String := Workspace & "/data/renamed.txt";
      Mirror_Path       : constant String := Workspace & "/mirror.txt";
      Renamed_Mirror    : constant String := Workspace & "/mirror-renamed.txt";
   begin
      Workspace_Dir := US.To_Unbounded_String (Workspace);

      Require (Base_Path'Length > 0, "Base path should not be empty");
      Require
        (Current_Directory'Length > 0,
         "Current working directory should not be empty");

      Cleanup_Workspace (Workspace);
      SDL.Filesystems.Create_Directory (Workspace);
      Require
        (SDL.Filesystems.Exists (Workspace),
         "Workspace directory was not created");

      declare
         Device         : SDL.Storage.Storage := SDL.Storage.Open_File (Workspace);
         Written_Buffer : aliased constant Payload_String := Payload;
         Read_Buffer    : aliased Payload_String := (others => Character'Val (0));
         Info           : SDL.Filesystems.Path_Information;
         Root_State     : aliased Enumeration_State;
      begin
         Require (not SDL.Storage.Is_Null (Device), "Storage handle should be valid");
         Require
           (Wait_Until_Ready (Device),
            "File storage never became ready");

         SDL.Storage.Create_Directory (Device, "data");
         SDL.Storage.Write_File
           (Self   => Device,
            Path   => "data/payload.txt",
            Source => Written_Buffer'Address,
            Length => SDL.Storage.Sizes (Written_Buffer'Length));

         Require
           (SDL.Storage.File_Size (Device, "data/payload.txt") =
              SDL.Storage.Sizes (Payload'Length),
            "Storage file size mismatch");

         SDL.Storage.Read_File
           (Self        => Device,
            Path        => "data/payload.txt",
            Destination => Read_Buffer'Address,
            Length      => SDL.Storage.Sizes (Read_Buffer'Length));

         Require (Read_Buffer = Payload, "Storage readback mismatch");
         Require
           (SDL.Storage.Get_Path_Info (Device, "data/payload.txt", Info),
            "Storage path info failed");
         Require (Info.Kind = SDL.Filesystems.File_Path, "Storage path type mismatch");
         Require
           (Info.Size = Interfaces.Unsigned_64 (Payload'Length),
            "Storage path size mismatch");

         Require
           (SDL.Storage.Enumerate_Root
              (Self      => Device,
               Callback  => Collect_Entries'Unrestricted_Access,
               User_Data => Root_State'Address),
            "Root storage enumeration failed");
         Require (Root_State.Saw_Data_Dir, "Root storage enumeration missed data dir");

         SDL.Storage.Rename_Path (Device, "data/payload.txt", Renamed_Subpath);
         SDL.Storage.Copy_File (Device, Renamed_Subpath, "data/copied.txt");

         SDL.Storage.Remove_Path (Device, "data/copied.txt");

         declare
            Available : constant SDL.Storage.Sizes :=
              SDL.Storage.Space_Remaining (Device);
         begin
            pragma Unreferenced (Available);
         end;

         SDL.Storage.Close (Device);
         Require (SDL.Storage.Is_Null (Device), "Close should clear the storage handle");
      end;

      declare
         Device      : SDL.Storage.Storage := SDL.Storage.Open_Title (Workspace);
         Read_Buffer : aliased Payload_String := (others => Character'Val (0));
         Data_State  : aliased Enumeration_State;
      begin
         Require
           (Wait_Until_Ready (Device),
            "Title storage never became ready");
         Require
           (SDL.Storage.File_Size (Device, Renamed_Subpath) =
              SDL.Storage.Sizes (Payload'Length),
            "Title storage file size mismatch");

         SDL.Storage.Read_File
           (Self        => Device,
            Path        => Renamed_Subpath,
            Destination => Read_Buffer'Address,
            Length      => SDL.Storage.Sizes (Read_Buffer'Length));

         Require (Read_Buffer = Payload, "Title storage readback mismatch");

         Require
           (SDL.Storage.Enumerate_Directory
              (Self      => Device,
               Path      => "data",
               Callback  => Collect_Entries'Unrestricted_Access,
               User_Data => Data_State'Address),
            "Title storage enumeration failed");
         Require
           (Data_State.Saw_Renamed_File,
            "Title storage enumeration missed renamed file");
      end;

      declare
         Info       : SDL.Filesystems.Path_Information;
         Root_State : aliased Enumeration_State;
      begin
         Require
           (SDL.Filesystems.Get_Path_Info (Renamed_Path, Info),
            "Filesystem path info failed");
         Require (Info.Kind = SDL.Filesystems.File_Path, "Filesystem path type mismatch");
         Require
           (Info.Size = Interfaces.Unsigned_64 (Payload'Length),
            "Filesystem path size mismatch");

         Require
           (SDL.Filesystems.Enumerate_Directory
              (Path      => Workspace,
               Callback  => Collect_Entries'Unrestricted_Access,
               User_Data => Root_State'Address),
            "Filesystem enumeration failed");
         Require
           (Root_State.Saw_Data_Dir,
            "Filesystem enumeration missed data dir");

         declare
            Matches : constant SDL.Filesystems.Path_Lists :=
              SDL.Filesystems.Glob_Directory (Workspace, "data/*.txt");
         begin
            Require
              (Contains (Matches, "data/renamed.txt"),
               "Filesystem glob missed renamed file");
         end;

         SDL.Filesystems.Copy_File (Renamed_Path, Mirror_Path);
         SDL.Filesystems.Rename_Path (Mirror_Path, Renamed_Mirror);
         Require
           (SDL.Filesystems.Exists (Renamed_Mirror),
            "Filesystem rename target was not created");
         SDL.Filesystems.Remove_Path (Renamed_Mirror);
         Require
           (not SDL.Filesystems.Exists (Renamed_Mirror),
            "Filesystem remove did not delete mirror file");

         SDL.Filesystems.Remove_Path (Renamed_Path);
         SDL.Filesystems.Remove_Path (Data_Directory);
         SDL.Filesystems.Remove_Path (Workspace);
      end;

      Require
        (not Ada.Directories.Exists (Workspace),
         "Workspace directory should have been removed");
   end;

   Ada.Text_IO.Put_Line ("Storage smoke completed successfully.");
exception
   when Error : others =>
      Cleanup_Workspace (US.To_String (Workspace_Dir));
      Ada.Text_IO.Put_Line
        ("Storage smoke failed: " & Ada.Exceptions.Exception_Message (Error));

      if SDL.Error.Get /= "" then
         Ada.Text_IO.Put_Line ("SDL error: " & SDL.Error.Get);
      end if;

      raise;
end Storage_Smoke;
