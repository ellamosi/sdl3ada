with Ada.Strings.Unbounded;
with Interfaces.C;
with System;

with SDL.Properties;
with SDL.Video.Windows;

package SDL.Dialogs is
   pragma Elaborate_Body;

   package C renames Interfaces.C;
   package US renames Ada.Strings.Unbounded;

   Dialog_Error : exception;

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

   type Statuses is
     (Accepted,
      Cancelled,
      Failed);

   type File_Filter is record
      Name    : US.Unbounded_String := US.Null_Unbounded_String;
      Pattern : US.Unbounded_String := US.Null_Unbounded_String;
   end record;

   type File_Filter_Lists is array (Natural range <>) of File_Filter;
   type File_Path_Lists is array (Natural range <>) of US.Unbounded_String;

   type File_Dialog_Callback is access procedure
     (User_Data        : in System.Address;
      Status           : in Statuses;
      Files            : in File_Path_Lists;
      Selected_Filter  : in C.int;
      Error_Message    : in String);

   Filters_Pointer_Property : constant String := "SDL.filedialog.filters";
   Filter_Count_Property    : constant String := "SDL.filedialog.nfilters";
   Window_Pointer_Property  : constant String := "SDL.filedialog.window";
   Location_Property        : constant String := "SDL.filedialog.location";
   Many_Property            : constant String := "SDL.filedialog.many";
   Title_Property           : constant String := "SDL.filedialog.title";
   Accept_Property          : constant String := "SDL.filedialog.accept";
   Cancel_Property          : constant String := "SDL.filedialog.cancel";

   procedure Show_Open_File_Dialog
     (Callback         : in File_Dialog_Callback;
      Default_Location : in String := "";
      Allow_Many       : in Boolean := False;
      User_Data        : in System.Address := System.Null_Address);

   procedure Show_Open_File_Dialog
     (Callback         : in File_Dialog_Callback;
      Window           : in SDL.Video.Windows.Window;
      Default_Location : in String := "";
      Allow_Many       : in Boolean := False;
      User_Data        : in System.Address := System.Null_Address);

   procedure Show_Open_File_Dialog
     (Callback         : in File_Dialog_Callback;
      Filters          : in File_Filter_Lists;
      Default_Location : in String := "";
      Allow_Many       : in Boolean := False;
      User_Data        : in System.Address := System.Null_Address);

   procedure Show_Open_File_Dialog
     (Callback         : in File_Dialog_Callback;
      Window           : in SDL.Video.Windows.Window;
      Filters          : in File_Filter_Lists;
      Default_Location : in String := "";
      Allow_Many       : in Boolean := False;
      User_Data        : in System.Address := System.Null_Address);

   procedure Show_Save_File_Dialog
     (Callback         : in File_Dialog_Callback;
      Default_Location : in String := "";
      User_Data        : in System.Address := System.Null_Address);

   procedure Show_Save_File_Dialog
     (Callback         : in File_Dialog_Callback;
      Window           : in SDL.Video.Windows.Window;
      Default_Location : in String := "";
      User_Data        : in System.Address := System.Null_Address);

   procedure Show_Save_File_Dialog
     (Callback         : in File_Dialog_Callback;
      Filters          : in File_Filter_Lists;
      Default_Location : in String := "";
      User_Data        : in System.Address := System.Null_Address);

   procedure Show_Save_File_Dialog
     (Callback         : in File_Dialog_Callback;
      Window           : in SDL.Video.Windows.Window;
      Filters          : in File_Filter_Lists;
      Default_Location : in String := "";
      User_Data        : in System.Address := System.Null_Address);

   procedure Show_Open_Folder_Dialog
     (Callback         : in File_Dialog_Callback;
      Default_Location : in String := "";
      Allow_Many       : in Boolean := False;
      User_Data        : in System.Address := System.Null_Address);

   procedure Show_Open_Folder_Dialog
     (Callback         : in File_Dialog_Callback;
      Window           : in SDL.Video.Windows.Window;
      Default_Location : in String := "";
      Allow_Many       : in Boolean := False;
      User_Data        : in System.Address := System.Null_Address);

   procedure Show_File_Dialog_With_Properties
     (Kind       : in File_Dialog_Type;
      Callback   : in File_Dialog_Callback;
      Properties : in SDL.Properties.Property_Set;
      User_Data  : in System.Address := System.Null_Address);

   procedure Show_File_Dialog_With_Properties
     (Kind       : in File_Dialog_Type;
      Callback   : in File_Dialog_Callback;
      Properties : in SDL.Properties.Property_Set;
      Filters    : in File_Filter_Lists;
      User_Data  : in System.Address := System.Null_Address);
end SDL.Dialogs;
