with Ada.Finalization;
with Interfaces;
with System;

with SDL.Filesystems;
with SDL.Properties;
with SDL.Raw.Storage;

package SDL.Storage is
   pragma Elaborate_Body;

   Storage_Error : exception;

   subtype Sizes is SDL.Raw.Storage.Sizes;
   subtype Storage_Handle is SDL.Raw.Storage.Storage_Access;
   subtype Storage_Interface is SDL.Raw.Storage.Storage_Interface;
   subtype Close_Callback is SDL.Raw.Storage.Close_Callback;
   subtype Ready_Callback is SDL.Raw.Storage.Ready_Callback;
   subtype Enumerate_Callback is SDL.Raw.Storage.Enumerate_Callback;
   subtype Info_Callback is SDL.Raw.Storage.Info_Callback;
   subtype Read_File_Callback is SDL.Raw.Storage.Read_File_Callback;
   subtype Write_File_Callback is SDL.Raw.Storage.Write_File_Callback;
   subtype Make_Directory_Callback is SDL.Raw.Storage.Make_Directory_Callback;
   subtype Remove_Path_Callback is SDL.Raw.Storage.Remove_Path_Callback;
   subtype Rename_Path_Callback is SDL.Raw.Storage.Rename_Path_Callback;
   subtype Copy_File_Callback is SDL.Raw.Storage.Copy_File_Callback;
   subtype Space_Remaining_Callback is
     SDL.Raw.Storage.Space_Remaining_Callback;

   Storage_Interface_Size : constant Interfaces.Unsigned_32 :=
     SDL.Raw.Storage.Storage_Interface_Size;

   function Create_Interface return Storage_Interface
     renames SDL.Raw.Storage.Create_Interface;

   subtype Path_Information is SDL.Filesystems.Path_Information;
   subtype Glob_Flags is SDL.Filesystems.Glob_Flags;
   subtype Path_Lists is SDL.Filesystems.Path_Lists;
   subtype Directory_Enumeration_Callback is
     SDL.Filesystems.Directory_Enumeration_Callback;

   No_Glob_Flags : constant Glob_Flags := SDL.Filesystems.No_Glob_Flags;
   Case_Insensitive_Glob : constant Glob_Flags :=
     SDL.Filesystems.Case_Insensitive_Glob;

   type Storage is new Ada.Finalization.Limited_Controlled with private;

   overriding
   procedure Finalize (Self : in out Storage);

   function Open_Title return Storage;
   function Open_Title (Override_Path : in String) return Storage;
   function Open_Title
     (Properties : in SDL.Properties.Property_Set) return Storage;
   function Open_Title
     (Override_Path : in String;
      Properties    : in SDL.Properties.Property_Set) return Storage;

   procedure Open_Title (Self : in out Storage);
   procedure Open_Title
     (Self          : in out Storage;
      Override_Path : in String);
   procedure Open_Title
     (Self       : in out Storage;
      Properties : in SDL.Properties.Property_Set);
   procedure Open_Title
     (Self          : in out Storage;
      Override_Path : in String;
      Properties    : in SDL.Properties.Property_Set);

   function Open_User
     (Organisation : in String;
      Application  : in String) return Storage;
   function Open_User
     (Organisation : in String;
      Application  : in String;
      Properties   : in SDL.Properties.Property_Set) return Storage;

   procedure Open_User
     (Self         : in out Storage;
      Organisation : in String;
      Application  : in String);
   procedure Open_User
     (Self         : in out Storage;
      Organisation : in String;
      Application  : in String;
      Properties   : in SDL.Properties.Property_Set);

   function Open_File return Storage;
   function Open_File (Path : in String) return Storage;

   procedure Open_File (Self : in out Storage);
   procedure Open_File
     (Self : in out Storage;
      Path : in String);

   function Open
     (Interface_Definition : in Storage_Interface;
      User_Data            : in System.Address := System.Null_Address)
      return Storage;

   procedure Open
     (Self                 : in out Storage;
      Interface_Definition : in Storage_Interface;
      User_Data            : in System.Address := System.Null_Address);

   procedure Close (Self : in out Storage);

   function Is_Null (Self : in Storage) return Boolean with
     Inline;

   function Get_Handle
     (Self : in Storage) return Storage_Handle with
     Inline;

   function Ready (Self : in Storage) return Boolean;

   function File_Size
     (Self : in Storage;
      Path : in String) return Sizes;

   procedure Read_File
     (Self        : in Storage;
      Path        : in String;
      Destination : in System.Address;
      Length      : in Sizes);

   procedure Write_File
     (Self   : in Storage;
      Path   : in String;
      Source : in System.Address;
      Length : in Sizes);

   procedure Create_Directory
     (Self : in Storage;
      Path : in String);

   function Enumerate_Directory
     (Self      : in Storage;
      Path      : in String;
      Callback  : in Directory_Enumeration_Callback;
      User_Data : in System.Address := System.Null_Address) return Boolean;

   function Enumerate_Root
     (Self      : in Storage;
      Callback  : in Directory_Enumeration_Callback;
      User_Data : in System.Address := System.Null_Address) return Boolean;

   procedure Remove_Path
     (Self : in Storage;
      Path : in String);

   procedure Rename_Path
     (Self     : in Storage;
      Old_Path : in String;
      New_Path : in String);

   procedure Copy_File
     (Self     : in Storage;
      Old_Path : in String;
      New_Path : in String);

   function Get_Path_Info
     (Self : in Storage;
      Path : in String;
      Info : out Path_Information) return Boolean;

   function Exists
     (Self : in Storage;
      Path : in String) return Boolean;

   function Space_Remaining
     (Self : in Storage) return Sizes;

   function Glob_Directory
     (Self    : in Storage;
      Path    : in String;
      Pattern : in String;
      Flags   : in Glob_Flags := No_Glob_Flags) return Path_Lists;

   function Glob_Directory
     (Self  : in Storage;
      Path  : in String;
      Flags : in Glob_Flags := No_Glob_Flags) return Path_Lists;

   function Glob_Root
     (Self    : in Storage;
      Pattern : in String;
      Flags   : in Glob_Flags := No_Glob_Flags) return Path_Lists;

   function Glob_Root
     (Self  : in Storage;
      Flags : in Glob_Flags := No_Glob_Flags) return Path_Lists;
private
   type Storage is new Ada.Finalization.Limited_Controlled with
      record
         Internal : Storage_Handle := null;
      end record;
end SDL.Storage;
