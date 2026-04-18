with Interfaces;
with Interfaces.C;
with Interfaces.C.Extensions;
with Interfaces.C.Pointers;
with Interfaces.C.Strings;
with System;

package SDL.Raw.Tray is
   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;
   package CS renames Interfaces.C.Strings;

   subtype Entry_Flags is Interfaces.Unsigned_32;
   subtype Entry_Positions is C.int;

   type Address_Arrays is array (C.ptrdiff_t range <>) of aliased System.Address
   with Convention => C;

   package Address_Pointers is new Interfaces.C.Pointers
     (Index              => C.ptrdiff_t,
      Element            => System.Address,
      Element_Array      => Address_Arrays,
      Default_Terminator => System.Null_Address);

   type Tray_Callback is access procedure
     (User_Data : in System.Address;
      Selected  : in System.Address)
   with Convention => C;

   function Create_Tray
     (Icon    : in System.Address;
      Tooltip : in CS.chars_ptr) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CreateTray";

   procedure Set_Tray_Icon
     (Self : in System.Address;
      Icon : in System.Address)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetTrayIcon";

   procedure Set_Tray_Tooltip
     (Self    : in System.Address;
      Tooltip : in CS.chars_ptr)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetTrayTooltip";

   function Create_Tray_Menu
     (Self : in System.Address) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CreateTrayMenu";

   function Create_Tray_Submenu
     (Self : in System.Address) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CreateTraySubmenu";

   function Get_Tray_Menu
     (Self : in System.Address) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetTrayMenu";

   function Get_Tray_Submenu
     (Self : in System.Address) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetTraySubmenu";

   function Get_Tray_Entries
     (Self  : in System.Address;
      Count : access C.int) return Address_Pointers.Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetTrayEntries";

   procedure Remove_Tray_Entry
     (Self : in System.Address)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_RemoveTrayEntry";

   function Insert_Tray_Entry_At
     (Self     : in System.Address;
      Position : in Entry_Positions;
      Label    : in CS.chars_ptr;
      Flags    : in Entry_Flags) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_InsertTrayEntryAt";

   procedure Set_Tray_Entry_Label
     (Self  : in System.Address;
      Label : in CS.chars_ptr)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetTrayEntryLabel";

   function Get_Tray_Entry_Label
     (Self : in System.Address) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetTrayEntryLabel";

   procedure Set_Tray_Entry_Checked
     (Self    : in System.Address;
      Checked : in CE.bool)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetTrayEntryChecked";

   function Get_Tray_Entry_Checked
     (Self : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetTrayEntryChecked";

   procedure Set_Tray_Entry_Enabled
     (Self    : in System.Address;
      Enabled : in CE.bool)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetTrayEntryEnabled";

   function Get_Tray_Entry_Enabled
     (Self : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetTrayEntryEnabled";

   procedure Set_Tray_Entry_Callback
     (Self      : in System.Address;
      Callback  : in Tray_Callback;
      User_Data : in System.Address)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetTrayEntryCallback";

   procedure Click_Tray_Entry
     (Self : in System.Address)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ClickTrayEntry";

   procedure Destroy_Tray
     (Self : in System.Address)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_DestroyTray";

   function Get_Tray_Entry_Parent
     (Self : in System.Address) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetTrayEntryParent";

   function Get_Tray_Menu_Parent_Entry
     (Self : in System.Address) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetTrayMenuParentEntry";

   function Get_Tray_Menu_Parent_Tray
     (Self : in System.Address) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetTrayMenuParentTray";

   procedure Update_Trays
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_UpdateTrays";
end SDL.Raw.Tray;
