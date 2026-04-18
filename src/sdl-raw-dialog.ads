with Interfaces.C;
with Interfaces.C.Extensions;
with Interfaces.C.Pointers;
with Interfaces.C.Strings;
with System;

with SDL.Raw.Properties;

package SDL.Raw.Dialog is

   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;
   package CS renames Interfaces.C.Strings;

   type File_Dialog_Type is
     (Open_File,
      Save_File,
      Open_Folder)
   with
     Convention => C,
     Size       => C.int'Size;

   for File_Dialog_Type use
     (Open_File   => 0,
      Save_File   => 1,
      Open_Folder => 2);

   type File_Filter is record
      Name    : CS.chars_ptr := CS.Null_Ptr;
      Pattern : CS.chars_ptr := CS.Null_Ptr;
   end record
   with Convention => C;

   type File_List_Array is array (C.ptrdiff_t range <>) of aliased CS.chars_ptr
   with Convention => C;

   package File_Lists is new Interfaces.C.Pointers
     (Index              => C.ptrdiff_t,
      Element            => CS.chars_ptr,
      Element_Array      => File_List_Array,
      Default_Terminator => CS.Null_Ptr);

   type File_Dialog_Callback is access procedure
     (User_Data : in System.Address;
      File_List : in File_Lists.Pointer;
      Filter    : in C.int)
   with Convention => C;

   procedure Show_Open_File_Dialog
     (Callback         : in File_Dialog_Callback;
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

   procedure Show_Save_File_Dialog
     (Callback         : in File_Dialog_Callback;
      User_Data        : in System.Address;
      Window           : in System.Address;
      Filters          : in System.Address;
      Filter_Count     : in C.int;
      Default_Location : in CS.chars_ptr)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ShowSaveFileDialog";

   procedure Show_Open_Folder_Dialog
     (Callback         : in File_Dialog_Callback;
      User_Data        : in System.Address;
      Window           : in System.Address;
      Default_Location : in CS.chars_ptr;
      Allow_Many       : in CE.bool)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ShowOpenFolderDialog";

   procedure Show_File_Dialog_With_Properties
     (Kind       : in File_Dialog_Type;
      Callback   : in File_Dialog_Callback;
      User_Data  : in System.Address;
      Properties : in SDL.Raw.Properties.ID)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ShowFileDialogWithProperties";
end SDL.Raw.Dialog;
