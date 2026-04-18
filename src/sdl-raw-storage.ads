with Interfaces;
with Interfaces.C;
with Interfaces.C.Extensions;
with Interfaces.C.Strings;
with System;

with SDL.Raw.Filesystem;
with SDL.Raw.Properties;

package SDL.Raw.Storage is
   pragma Preelaborate;

   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;
   package CS renames Interfaces.C.Strings;

   subtype Sizes is Interfaces.Unsigned_64;

   type Storage_Object is null record;
   type Storage_Access is access all Storage_Object with
     Convention => C;

   type Close_Callback is access function
     (User_Data : in System.Address) return CE.bool
   with Convention => C;

   type Ready_Callback is access function
     (User_Data : in System.Address) return CE.bool
   with Convention => C;

   type Enumerate_Callback is access function
     (User_Data          : in System.Address;
      Path               : in CS.chars_ptr;
      Callback           : in SDL.Raw.Filesystem.Enumerate_Directory_Callback;
      Callback_User_Data : in System.Address) return CE.bool
   with Convention => C;

   type Info_Callback is access function
     (User_Data : in System.Address;
      Path      : in CS.chars_ptr;
      Info      : access SDL.Raw.Filesystem.Path_Info) return CE.bool
   with Convention => C;

   type Read_File_Callback is access function
     (User_Data   : in System.Address;
      Path        : in CS.chars_ptr;
      Destination : in System.Address;
      Length      : in Sizes) return CE.bool
   with Convention => C;

   type Write_File_Callback is access function
     (User_Data : in System.Address;
      Path      : in CS.chars_ptr;
      Source    : in System.Address;
      Length    : in Sizes) return CE.bool
   with Convention => C;

   type Make_Directory_Callback is access function
     (User_Data : in System.Address;
      Path      : in CS.chars_ptr) return CE.bool
   with Convention => C;

   type Remove_Path_Callback is access function
     (User_Data : in System.Address;
      Path      : in CS.chars_ptr) return CE.bool
   with Convention => C;

   type Rename_Path_Callback is access function
     (User_Data : in System.Address;
      Old_Path  : in CS.chars_ptr;
      New_Path  : in CS.chars_ptr) return CE.bool
   with Convention => C;

   type Copy_File_Callback is access function
     (User_Data : in System.Address;
      Old_Path  : in CS.chars_ptr;
      New_Path  : in CS.chars_ptr) return CE.bool
   with Convention => C;

   type Space_Remaining_Callback is access function
     (User_Data : in System.Address) return Sizes
   with Convention => C;

   type Storage_Interface is record
      Version         : Interfaces.Unsigned_32 := 0;
      Close           : Close_Callback := null;
      Ready           : Ready_Callback := null;
      Enumerate       : Enumerate_Callback := null;
      Info            : Info_Callback := null;
      Read_File       : Read_File_Callback := null;
      Write_File      : Write_File_Callback := null;
      Make_Directory  : Make_Directory_Callback := null;
      Remove_Path     : Remove_Path_Callback := null;
      Rename_Path     : Rename_Path_Callback := null;
      Copy_File       : Copy_File_Callback := null;
      Space_Remaining : Space_Remaining_Callback := null;
   end record with
     Convention => C;

   Storage_Interface_Size : constant Interfaces.Unsigned_32 :=
     Interfaces.Unsigned_32 (Storage_Interface'Size / System.Storage_Unit);

   function Create_Interface return Storage_Interface is
     (Version         => Storage_Interface_Size,
      Close           => null,
      Ready           => null,
      Enumerate       => null,
      Info            => null,
      Read_File       => null,
      Write_File      => null,
      Make_Directory  => null,
      Remove_Path     => null,
      Rename_Path     => null,
      Copy_File       => null,
      Space_Remaining => null);

   function Open_Title_Storage
     (Override_Path : in CS.chars_ptr;
      Props         : in SDL.Raw.Properties.ID) return Storage_Access
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_OpenTitleStorage";

   function Open_User_Storage
     (Organisation : in CS.chars_ptr;
      Application  : in CS.chars_ptr;
      Props        : in SDL.Raw.Properties.ID) return Storage_Access
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_OpenUserStorage";

   function Open_File_Storage
     (Path : in CS.chars_ptr) return Storage_Access
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_OpenFileStorage";

   function Open_Storage
     (Interface_Definition : access constant Storage_Interface;
      User_Data            : in System.Address) return Storage_Access
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_OpenStorage";

   function Close_Storage
     (Self : in Storage_Access) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CloseStorage";

   function Storage_Ready
     (Self : in Storage_Access) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_StorageReady";

   function Get_Storage_File_Size
     (Self   : in Storage_Access;
      Path   : in CS.chars_ptr;
      Length : access Sizes) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetStorageFileSize";

   function Read_Storage_File
     (Self        : in Storage_Access;
      Path        : in CS.chars_ptr;
      Destination : in System.Address;
      Length      : in Sizes) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ReadStorageFile";

   function Write_Storage_File
     (Self   : in Storage_Access;
      Path   : in CS.chars_ptr;
      Source : in System.Address;
      Length : in Sizes) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_WriteStorageFile";

   function Create_Storage_Directory
     (Self : in Storage_Access;
      Path : in CS.chars_ptr) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CreateStorageDirectory";

   function Enumerate_Storage_Directory
     (Self      : in Storage_Access;
      Path      : in CS.chars_ptr;
      Callback  : in SDL.Raw.Filesystem.Enumerate_Directory_Callback;
      User_Data : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_EnumerateStorageDirectory";

   function Remove_Storage_Path
     (Self : in Storage_Access;
      Path : in CS.chars_ptr) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_RemoveStoragePath";

   function Rename_Storage_Path
     (Self     : in Storage_Access;
      Old_Path : in CS.chars_ptr;
      New_Path : in CS.chars_ptr) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_RenameStoragePath";

   function Copy_Storage_File
     (Self     : in Storage_Access;
      Old_Path : in CS.chars_ptr;
      New_Path : in CS.chars_ptr) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CopyStorageFile";

   function Get_Storage_Path_Info
     (Self : in Storage_Access;
      Path : in CS.chars_ptr;
      Info : access SDL.Raw.Filesystem.Path_Info) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetStoragePathInfo";

   function Get_Storage_Space_Remaining
     (Self : in Storage_Access) return Sizes
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetStorageSpaceRemaining";

   function Glob_Storage_Directory
     (Self    : in Storage_Access;
      Path    : in CS.chars_ptr;
      Pattern : in CS.chars_ptr;
      Flags   : in SDL.Raw.Filesystem.Glob_Flags;
      Count   : access C.int) return SDL.Raw.Filesystem.Glob_Result_Pointers.Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GlobStorageDirectory";
end SDL.Raw.Storage;
