with Ada.Strings.Unbounded;
with Ada.Strings.UTF_Encoding;
with System;

with SDL.Raw.Filesystem;

package SDL.Filesystems is
   pragma Elaborate_Body;

   package UTF_Strings renames Ada.Strings.UTF_Encoding;
   package US renames Ada.Strings.Unbounded;

   Filesystems_Error : exception;

   subtype Folders is SDL.Raw.Filesystem.Folders;
   subtype Path_Types is SDL.Raw.Filesystem.Path_Types;
   subtype Path_Information is SDL.Raw.Filesystem.Path_Info;
   subtype Glob_Flags is SDL.Raw.Filesystem.Glob_Flags;
   subtype Enumeration_Results is SDL.Raw.Filesystem.Enumeration_Results;
   subtype Directory_Enumeration_Callback is
     SDL.Raw.Filesystem.Enumerate_Directory_Callback;

   Home_Folder : constant Folders := SDL.Raw.Filesystem.Home_Folder;
   Desktop_Folder : constant Folders := SDL.Raw.Filesystem.Desktop_Folder;
   Documents_Folder : constant Folders := SDL.Raw.Filesystem.Documents_Folder;
   Downloads_Folder : constant Folders := SDL.Raw.Filesystem.Downloads_Folder;
   Music_Folder : constant Folders := SDL.Raw.Filesystem.Music_Folder;
   Pictures_Folder : constant Folders := SDL.Raw.Filesystem.Pictures_Folder;
   PublicShare_Folder : constant Folders :=
     SDL.Raw.Filesystem.PublicShare_Folder;
   Saved_Games_Folder : constant Folders :=
     SDL.Raw.Filesystem.Saved_Games_Folder;
   Screenshots_Folder : constant Folders :=
     SDL.Raw.Filesystem.Screenshots_Folder;
   Templates_Folder : constant Folders := SDL.Raw.Filesystem.Templates_Folder;
   Videos_Folder : constant Folders := SDL.Raw.Filesystem.Videos_Folder;

   Missing_Path : constant Path_Types := SDL.Raw.Filesystem.No_Path;
   File_Path : constant Path_Types := SDL.Raw.Filesystem.File_Path;
   Directory_Path : constant Path_Types := SDL.Raw.Filesystem.Directory_Path;
   Other_Path : constant Path_Types := SDL.Raw.Filesystem.Other_Path;

   No_Glob_Flags : constant Glob_Flags := SDL.Raw.Filesystem.No_Glob_Flags;
   Case_Insensitive_Glob : constant Glob_Flags :=
     SDL.Raw.Filesystem.Case_Insensitive_Glob;

   Continue_Enumeration : constant Enumeration_Results :=
     SDL.Raw.Filesystem.Continue_Enumeration;
   Success_Enumeration : constant Enumeration_Results :=
     SDL.Raw.Filesystem.Success_Enumeration;
   Failure_Enumeration : constant Enumeration_Results :=
     SDL.Raw.Filesystem.Failure_Enumeration;

   type Path_Lists is array (Positive range <>) of US.Unbounded_String;

   function Base_Path return UTF_Strings.UTF_String;

   function Preferences_Path
     (Organisation : in UTF_Strings.UTF_String;
      Application  : in UTF_Strings.UTF_String) return UTF_Strings.UTF_String;

   function User_Folder
     (Folder : in Folders) return UTF_Strings.UTF_String;

   function Current_Directory return UTF_Strings.UTF_String;

   procedure Create_Directory (Path : in String);

   function Enumerate_Directory
     (Path      : in String;
      Callback  : in Directory_Enumeration_Callback;
      User_Data : in System.Address := System.Null_Address) return Boolean;

   procedure Remove_Path (Path : in String);

   procedure Rename_Path
     (Old_Path : in String;
      New_Path : in String);

   procedure Copy_File
     (Old_Path : in String;
      New_Path : in String);

   function Get_Path_Info
     (Path : in String;
      Info : out Path_Information) return Boolean;

   function Exists (Path : in String) return Boolean;

   function Glob_Directory
     (Path    : in String;
      Pattern : in String;
      Flags   : in Glob_Flags := No_Glob_Flags) return Path_Lists;

   function Glob_Directory
     (Path  : in String;
      Flags : in Glob_Flags := No_Glob_Flags) return Path_Lists;
end SDL.Filesystems;
