with Interfaces;
with Interfaces.C;
with Interfaces.C.Extensions;
with Interfaces.C.Strings;
with System;

with SDL.Raw.Time;

package SDL.Raw.Filesystem is
   pragma Preelaborate;

   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;
   package CS renames Interfaces.C.Strings;

   type Folders is
     (Home_Folder,
      Desktop_Folder,
      Documents_Folder,
      Downloads_Folder,
      Music_Folder,
      Pictures_Folder,
      PublicShare_Folder,
      Saved_Games_Folder,
      Screenshots_Folder,
      Templates_Folder,
      Videos_Folder,
      Folder_Count)
   with
     Convention => C,
     Size       => C.int'Size;

   for Folders use
     (Home_Folder        => 0,
      Desktop_Folder     => 1,
      Documents_Folder   => 2,
      Downloads_Folder   => 3,
      Music_Folder       => 4,
      Pictures_Folder    => 5,
      PublicShare_Folder => 6,
      Saved_Games_Folder => 7,
      Screenshots_Folder => 8,
      Templates_Folder   => 9,
      Videos_Folder      => 10,
      Folder_Count       => 11);

   type Path_Types is
     (No_Path,
      File_Path,
      Directory_Path,
      Other_Path)
   with
     Convention => C,
     Size       => C.int'Size;

   for Path_Types use
     (No_Path        => 0,
      File_Path      => 1,
      Directory_Path => 2,
      Other_Path     => 3);

   type Path_Info is record
      Kind        : Path_Types;
      Size        : Interfaces.Unsigned_64;
      Created_At  : SDL.Raw.Time.Times;
      Modified_At : SDL.Raw.Time.Times;
      Accessed_At : SDL.Raw.Time.Times;
   end record with
     Convention => C;

   subtype Glob_Flags is Interfaces.Unsigned_32;

   No_Glob_Flags : constant Glob_Flags := 0;
   Case_Insensitive_Glob : constant Glob_Flags := 1;

   type Enumeration_Results is
     (Continue_Enumeration,
      Success_Enumeration,
      Failure_Enumeration)
   with
     Convention => C,
     Size       => C.int'Size;

   for Enumeration_Results use
     (Continue_Enumeration => 0,
      Success_Enumeration  => 1,
      Failure_Enumeration  => 2);

   type Enumerate_Directory_Callback is access function
     (User_Data      : in System.Address;
      Directory_Name : in CS.chars_ptr;
      File_Name      : in CS.chars_ptr) return Enumeration_Results
   with Convention => C;

   function Get_Base_Path return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetBasePath";

   function Get_Pref_Path
     (Organisation : in C.char_array;
      Application  : in C.char_array) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetPrefPath";

   function Get_User_Folder
     (Folder : in Folders) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetUserFolder";

   function Create_Directory
     (Path : in C.char_array) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CreateDirectory";

   function Enumerate_Directory
     (Path      : in C.char_array;
      Callback  : in Enumerate_Directory_Callback;
      User_Data : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_EnumerateDirectory";

   function Remove_Path
     (Path : in C.char_array) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_RemovePath";

   function Rename_Path
     (Old_Path : in C.char_array;
      New_Path : in C.char_array) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_RenamePath";

   function Copy_File
     (Old_Path : in C.char_array;
      New_Path : in C.char_array) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CopyFile";

   function Get_Path_Info
     (Path : in C.char_array;
      Info : access Path_Info) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetPathInfo";

   function Glob_Directory
     (Path    : in CS.chars_ptr;
      Pattern : in CS.chars_ptr;
      Flags   : in Glob_Flags;
      Count   : access C.int) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GlobDirectory";

   function Get_Current_Directory return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetCurrentDirectory";
end SDL.Raw.Filesystem;
