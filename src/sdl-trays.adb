with Ada.Unchecked_Conversion;
with Ada.Unchecked_Deallocation;
with Interfaces.C.Extensions;
with Interfaces.C.Pointers;
with Interfaces.C.Strings;

with SDL.Error;
package body SDL.Trays is
   package CE renames Interfaces.C.Extensions;
   package CS renames Interfaces.C.Strings;

   type Address_Arrays is array (C.ptrdiff_t range <>) of aliased System.Address
   with Convention => C;

   package Address_Pointers is new Interfaces.C.Pointers
     (Index              => C.ptrdiff_t,
      Element            => System.Address,
      Element_Array      => Address_Arrays,
      Default_Terminator => System.Null_Address);

   type Callback_Context;
   type Callback_Context_Access is access Callback_Context;

   type Callback_Context is record
      Tray      : System.Address := System.Null_Address;
      Selected  : System.Address := System.Null_Address;
      Callback  : Tray_Callback := null;
      User_Data : System.Address := System.Null_Address;
      Next      : Callback_Context_Access := null;
   end record;

   procedure Free is new Ada.Unchecked_Deallocation
     (Object => Callback_Context, Name => Callback_Context_Access);

   use type Address_Pointers.Pointer;
   use type C.ptrdiff_t;
   use type CS.chars_ptr;
   use type System.Address;

   function To_Address is new Ada.Unchecked_Conversion
     (Source => Callback_Context_Access,
      Target => System.Address);

   function To_Context is new Ada.Unchecked_Conversion
     (Source => System.Address,
      Target => Callback_Context_Access);

   function To_C_Bool (Value : in Boolean) return CE.bool is
     (if Value then CE.bool'Val (1) else CE.bool'Val (0));

   function Get_Internal_Surface
     (Self : in SDL.Video.Surfaces.Surface)
      return SDL.Video.Surfaces.Internal_Surface_Pointer
   with
     Import     => True,
     Convention => Ada;

   protected Callback_Registry is
      procedure Replace
        (Tray      : in System.Address;
         Selected  : in System.Address;
         Callback  : in Tray_Callback;
         User_Data : in System.Address;
         Context   : out Callback_Context_Access);

      procedure Remove_Entry (Selected : in System.Address);
      procedure Remove_Tray (Tray : in System.Address);
   private
      Head : Callback_Context_Access := null;
   end Callback_Registry;

   protected body Callback_Registry is
      procedure Replace
        (Tray      : in System.Address;
         Selected  : in System.Address;
         Callback  : in Tray_Callback;
         User_Data : in System.Address;
         Context   : out Callback_Context_Access)
      is
         Previous : Callback_Context_Access := null;
         Current  : Callback_Context_Access := Head;
      begin
         while Current /= null loop
            exit when Current.Selected = Selected;
            Previous := Current;
            Current := Current.Next;
         end loop;

         if Current /= null then
            if Previous = null then
               Head := Current.Next;
            else
               Previous.Next := Current.Next;
            end if;

            Free (Current);
         end if;

         if Callback = null then
            Context := null;
            return;
         end if;

         Context :=
           new Callback_Context'
             (Tray      => Tray,
              Selected  => Selected,
              Callback  => Callback,
              User_Data => User_Data,
              Next      => Head);
         Head := Context;
      end Replace;

      procedure Remove_Entry (Selected : in System.Address) is
         Previous : Callback_Context_Access := null;
         Current  : Callback_Context_Access := Head;
      begin
         while Current /= null loop
            if Current.Selected = Selected then
               declare
                  Next : constant Callback_Context_Access := Current.Next;
               begin
                  if Previous = null then
                     Head := Next;
                  else
                     Previous.Next := Next;
                  end if;

                  Free (Current);
                  Current := Next;
               end;
            else
               Previous := Current;
               Current := Current.Next;
            end if;
         end loop;
      end Remove_Entry;

      procedure Remove_Tray (Tray : in System.Address) is
         Previous : Callback_Context_Access := null;
         Current  : Callback_Context_Access := Head;
      begin
         while Current /= null loop
            if Current.Tray = Tray then
               declare
                  Next : constant Callback_Context_Access := Current.Next;
               begin
                  if Previous = null then
                     Head := Next;
                  else
                     Previous.Next := Next;
                  end if;

                  Free (Current);
                  Current := Next;
               end;
            else
               Previous := Current;
               Current := Current.Next;
            end if;
         end loop;
      end Remove_Tray;
   end Callback_Registry;

   function SDL_Create_Tray
     (Icon    : in SDL.Video.Surfaces.Internal_Surface_Pointer;
      Tooltip : in CS.chars_ptr) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CreateTray";

   procedure SDL_Set_Tray_Icon
     (Self : in System.Address;
      Icon : in SDL.Video.Surfaces.Internal_Surface_Pointer)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetTrayIcon";

   procedure SDL_Set_Tray_Tooltip
     (Self    : in System.Address;
      Tooltip : in CS.chars_ptr)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetTrayTooltip";

   function SDL_Create_Tray_Menu (Self : in System.Address) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CreateTrayMenu";

   function SDL_Create_Tray_Submenu (Self : in System.Address) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CreateTraySubmenu";

   function SDL_Get_Tray_Menu (Self : in System.Address) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetTrayMenu";

   function SDL_Get_Tray_Submenu (Self : in System.Address) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetTraySubmenu";

   function SDL_Get_Tray_Entries
     (Self  : in System.Address;
      Count : access C.int) return Address_Pointers.Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetTrayEntries";

   procedure SDL_Remove_Tray_Entry (Self : in System.Address)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_RemoveTrayEntry";

   function SDL_Insert_Tray_Entry_At
     (Self     : in System.Address;
      Position : in Entry_Positions;
      Label    : in CS.chars_ptr;
      Flags    : in Entry_Flags) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_InsertTrayEntryAt";

   procedure SDL_Set_Tray_Entry_Label
     (Self  : in System.Address;
      Label : in CS.chars_ptr)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetTrayEntryLabel";

   function SDL_Get_Tray_Entry_Label (Self : in System.Address) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetTrayEntryLabel";

   procedure SDL_Set_Tray_Entry_Checked
     (Self    : in System.Address;
      Checked : in CE.bool)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetTrayEntryChecked";

   function SDL_Get_Tray_Entry_Checked (Self : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetTrayEntryChecked";

   procedure SDL_Set_Tray_Entry_Enabled
     (Self    : in System.Address;
      Enabled : in CE.bool)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetTrayEntryEnabled";

   function SDL_Get_Tray_Entry_Enabled (Self : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetTrayEntryEnabled";

   procedure Tray_Entry_Trampoline
     (User_Data : in System.Address;
      Selected  : in System.Address)
   with Convention => C;

   type Internal_Tray_Callback is access procedure
     (User_Data : in System.Address;
      Selected  : in System.Address)
   with Convention => C;

   procedure SDL_Set_Tray_Entry_Callback
     (Self      : in System.Address;
      Callback  : in Internal_Tray_Callback;
      User_Data : in System.Address)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetTrayEntryCallback";

   procedure SDL_Click_Tray_Entry (Self : in System.Address)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ClickTrayEntry";

   procedure SDL_Destroy_Tray (Self : in System.Address)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_DestroyTray";

   function SDL_Get_Tray_Entry_Parent (Self : in System.Address) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetTrayEntryParent";

   function SDL_Get_Tray_Menu_Parent_Entry
     (Self : in System.Address) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetTrayMenuParentEntry";

   function SDL_Get_Tray_Menu_Parent_Tray
     (Self : in System.Address) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetTrayMenuParentTray";

   procedure SDL_Update_Trays
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_UpdateTrays";

   procedure Raise_Last_Error
     (Default_Message : in String := "SDL tray call failed");

   procedure Raise_Last_Error
     (Default_Message : in String := "SDL tray call failed")
   is
      Message : constant String := SDL.Error.Get;
   begin
      if Message = "" then
         raise Tray_Error with Default_Message;
      end if;

      raise Tray_Error with Message;
   end Raise_Last_Error;

   function Make_Tray
     (Internal : in System.Address;
      Owns     : in Boolean := False) return Tray is
   begin
      return Result : Tray do
         Result.Internal := Internal;
         Result.Owns := Owns;
      end return;
   end Make_Tray;

   function Make_Menu (Internal : in System.Address) return Menu is
     ((Internal => Internal));

   function Make_Entry (Internal : in System.Address) return Tray_Entry is
     ((Internal => Internal));

   procedure Require_Tray (Self : in Tray);

   procedure Require_Tray (Self : in Tray) is
   begin
      if Self.Internal = System.Null_Address then
         raise Tray_Error with "Invalid tray";
      end if;
   end Require_Tray;

   procedure Require_Menu (Self : in Menu);

   procedure Require_Menu (Self : in Menu) is
   begin
      if Self.Internal = System.Null_Address then
         raise Tray_Error with "Invalid tray menu";
      end if;
   end Require_Menu;

   procedure Require_Entry (Self : in Tray_Entry);

   procedure Require_Entry (Self : in Tray_Entry) is
   begin
      if Self.Internal = System.Null_Address then
         raise Tray_Error with "Invalid tray entry";
      end if;
   end Require_Entry;

   function Owning_Tray (Self : in Tray_Entry) return System.Address is
      Parent_Menu : constant System.Address := SDL_Get_Tray_Entry_Parent (Self.Internal);
   begin
      if Parent_Menu = System.Null_Address then
         return System.Null_Address;
      end if;

      declare
         Parent_Tray : constant System.Address :=
           SDL_Get_Tray_Menu_Parent_Tray (Parent_Menu);
      begin
         if Parent_Tray /= System.Null_Address then
            return Parent_Tray;
         end if;
      end;

      declare
         Parent_Entry : constant System.Address :=
           SDL_Get_Tray_Menu_Parent_Entry (Parent_Menu);
      begin
         if Parent_Entry = System.Null_Address then
            return System.Null_Address;
         end if;

         return Owning_Tray (Make_Entry (Parent_Entry));
      end;
   end Owning_Tray;

   procedure Tray_Entry_Trampoline
     (User_Data : in System.Address;
      Selected  : in System.Address)
   is
      Context : constant Callback_Context_Access := To_Context (User_Data);
   begin
      if Context = null or else Context.Callback = null then
         return;
      end if;

      Context.Callback
        (User_Data => Context.User_Data,
         Selected  => Make_Entry (Selected));
   end Tray_Entry_Trampoline;

   function Create
     (Icon    : in SDL.Video.Surfaces.Surface := SDL.Video.Surfaces.Null_Surface;
      Tooltip : in String := "") return Tray is
   begin
      return Result : Tray do
         Create (Self => Result, Icon => Icon, Tooltip => Tooltip);
      end return;
   end Create;

   procedure Create
     (Self    : out Tray;
      Icon    : in SDL.Video.Surfaces.Surface := SDL.Video.Surfaces.Null_Surface;
      Tooltip : in String := "")
   is
      C_Tooltip : CS.chars_ptr := CS.Null_Ptr;
      Internal  : System.Address;
   begin
      if Tooltip /= "" then
         C_Tooltip := CS.New_String (Tooltip);
      end if;

      begin
         Internal :=
           SDL_Create_Tray
             (Icon    => Get_Internal_Surface (Icon),
              Tooltip => C_Tooltip);
      exception
         when others =>
            if C_Tooltip /= CS.Null_Ptr then
               CS.Free (C_Tooltip);
            end if;
            raise;
      end;

      if C_Tooltip /= CS.Null_Ptr then
         CS.Free (C_Tooltip);
      end if;

      if Internal = System.Null_Address then
         Raise_Last_Error ("SDL_CreateTray failed");
      end if;

      Self.Internal := Internal;
      Self.Owns := True;
   end Create;

   overriding
   procedure Finalize (Self : in out Tray) is
   begin
      if Self.Owns and then Self.Internal /= System.Null_Address then
         Destroy (Self);
      end if;
   end Finalize;

   procedure Destroy (Self : in out Tray) is
   begin
      if Self.Internal = System.Null_Address then
         return;
      end if;

      Callback_Registry.Remove_Tray (Self.Internal);

      if Self.Owns then
         SDL_Destroy_Tray (Self.Internal);
      end if;

      Self.Internal := System.Null_Address;
      Self.Owns := False;
   end Destroy;

   function Is_Null (Self : in Tray) return Boolean is
     (Self.Internal = System.Null_Address);

   function Is_Null (Self : in Menu) return Boolean is
     (Self.Internal = System.Null_Address);

   function Is_Null (Self : in Tray_Entry) return Boolean is
     (Self.Internal = System.Null_Address);

   procedure Set_Icon
     (Self : in Tray;
      Icon : in SDL.Video.Surfaces.Surface := SDL.Video.Surfaces.Null_Surface) is
   begin
      Require_Tray (Self);
      SDL_Set_Tray_Icon (Self.Internal, Get_Internal_Surface (Icon));
   end Set_Icon;

   procedure Set_Tooltip
     (Self    : in Tray;
      Tooltip : in String := "")
   is
      C_Tooltip : CS.chars_ptr := CS.Null_Ptr;
   begin
      Require_Tray (Self);

      if Tooltip /= "" then
         C_Tooltip := CS.New_String (Tooltip);
      end if;

      begin
         SDL_Set_Tray_Tooltip (Self.Internal, C_Tooltip);
      exception
         when others =>
            if C_Tooltip /= CS.Null_Ptr then
               CS.Free (C_Tooltip);
            end if;
            raise;
      end;

      if C_Tooltip /= CS.Null_Ptr then
         CS.Free (C_Tooltip);
      end if;
   end Set_Tooltip;

   function Create_Menu (Self : in Tray) return Menu is
      Internal : System.Address;
   begin
      Require_Tray (Self);
      Internal := SDL_Create_Tray_Menu (Self.Internal);

      if Internal = System.Null_Address then
         Raise_Last_Error ("SDL_CreateTrayMenu failed");
      end if;

      return Make_Menu (Internal);
   end Create_Menu;

   function Get_Menu (Self : in Tray) return Menu is
   begin
      Require_Tray (Self);
      return Make_Menu (SDL_Get_Tray_Menu (Self.Internal));
   end Get_Menu;

   function Create_Submenu (Self : in Tray_Entry) return Menu is
      Internal : System.Address;
   begin
      Require_Entry (Self);
      Internal := SDL_Create_Tray_Submenu (Self.Internal);

      if Internal = System.Null_Address then
         Raise_Last_Error ("SDL_CreateTraySubmenu failed");
      end if;

      return Make_Menu (Internal);
   end Create_Submenu;

   function Get_Submenu (Self : in Tray_Entry) return Menu is
   begin
      Require_Entry (Self);
      return Make_Menu (SDL_Get_Tray_Submenu (Self.Internal));
   end Get_Submenu;

   function Get_Entries (Self : in Menu) return Entry_Lists is
      Count  : aliased C.int := 0;
      Values : constant Address_Pointers.Pointer :=
        SDL_Get_Tray_Entries (Self.Internal, Count'Access);
   begin
      Require_Menu (Self);

      if Values = null or else Count <= 0 then
         return (1 .. 0 => <>);
      end if;

      return Result : Entry_Lists (1 .. Natural (Count)) do
         for Index in Result'Range loop
            declare
               Position : constant Address_Pointers.Pointer :=
                 Values + C.ptrdiff_t (Index - Result'First);
            begin
               Result (Index) := Make_Entry (Position.all);
            end;
         end loop;
      end return;
   end Get_Entries;

   procedure Remove (Self : in out Tray_Entry) is
   begin
      Require_Entry (Self);
      Callback_Registry.Remove_Entry (Self.Internal);
      SDL_Remove_Tray_Entry (Self.Internal);
      Self.Internal := System.Null_Address;
   end Remove;

   function Insert_Internal
     (Self      : in Menu;
      Position  : in Entry_Positions;
      Label     : in String;
      Use_Label : in Boolean;
      Flags     : in Entry_Flags) return Tray_Entry
   is
      C_Label  : CS.chars_ptr := CS.Null_Ptr;
      Internal : System.Address;
   begin
      Require_Menu (Self);

      if Use_Label then
         C_Label := CS.New_String (Label);
      end if;

      begin
         Internal :=
           SDL_Insert_Tray_Entry_At
             (Self     => Self.Internal,
              Position => Position,
              Label    => C_Label,
              Flags    => Flags);
      exception
         when others =>
            if C_Label /= CS.Null_Ptr then
               CS.Free (C_Label);
            end if;
            raise;
      end;

      if C_Label /= CS.Null_Ptr then
         CS.Free (C_Label);
      end if;

      if Internal = System.Null_Address then
         Raise_Last_Error ("SDL_InsertTrayEntryAt failed");
      end if;

      return Make_Entry (Internal);
   end Insert_Internal;

   function Insert_At
     (Self     : in Menu;
      Position : in Entry_Positions;
      Label    : in String;
      Flags    : in Entry_Flags) return Tray_Entry is
   begin
      return Insert_Internal
        (Self      => Self,
         Position  => Position,
         Label     => Label,
         Use_Label => True,
         Flags     => Flags);
   end Insert_At;

   function Append
     (Self  : in Menu;
      Label : in String;
      Flags : in Entry_Flags) return Tray_Entry is
   begin
      return Insert_At
        (Self     => Self,
         Position => Append_Position,
         Label    => Label,
         Flags    => Flags);
   end Append;

   function Insert_Separator_At
     (Self     : in Menu;
      Position : in Entry_Positions := Append_Position) return Tray_Entry is
   begin
      return Insert_Internal
        (Self      => Self,
         Position  => Position,
         Label     => "",
         Use_Label => False,
         Flags     => Button);
   end Insert_Separator_At;

   procedure Set_Label
     (Self  : in Tray_Entry;
      Label : in String)
   is
      C_Label : CS.chars_ptr := CS.New_String (Label);
   begin
      Require_Entry (Self);

      begin
         SDL_Set_Tray_Entry_Label (Self.Internal, C_Label);
      exception
         when others =>
            CS.Free (C_Label);
            raise;
      end;

      CS.Free (C_Label);
   end Set_Label;

   function Get_Label (Self : in Tray_Entry) return String is
      Value : CS.chars_ptr;
   begin
      Require_Entry (Self);
      Value := SDL_Get_Tray_Entry_Label (Self.Internal);

      if Value = CS.Null_Ptr then
         return "";
      end if;

      return CS.Value (Value);
   end Get_Label;

   function Is_Separator (Self : in Tray_Entry) return Boolean is
   begin
      Require_Entry (Self);
      return SDL_Get_Tray_Entry_Label (Self.Internal) = CS.Null_Ptr;
   end Is_Separator;

   procedure Set_Checked
     (Self    : in Tray_Entry;
      Enabled : in Boolean) is
   begin
      Require_Entry (Self);
      SDL_Set_Tray_Entry_Checked (Self.Internal, To_C_Bool (Enabled));
   end Set_Checked;

   function Get_Checked (Self : in Tray_Entry) return Boolean is
   begin
      Require_Entry (Self);
      return Boolean (SDL_Get_Tray_Entry_Checked (Self.Internal));
   end Get_Checked;

   procedure Set_Enabled
     (Self    : in Tray_Entry;
      Enabled : in Boolean) is
   begin
      Require_Entry (Self);
      SDL_Set_Tray_Entry_Enabled (Self.Internal, To_C_Bool (Enabled));
   end Set_Enabled;

   function Get_Enabled (Self : in Tray_Entry) return Boolean is
   begin
      Require_Entry (Self);
      return Boolean (SDL_Get_Tray_Entry_Enabled (Self.Internal));
   end Get_Enabled;

   procedure Set_Callback
     (Self      : in Tray_Entry;
      Callback  : in Tray_Callback;
      User_Data : in System.Address := System.Null_Address)
   is
      Context : Callback_Context_Access;
   begin
      Require_Entry (Self);

      Callback_Registry.Replace
        (Tray      => Owning_Tray (Self),
         Selected  => Self.Internal,
         Callback  => Callback,
         User_Data => User_Data,
         Context   => Context);

      SDL_Set_Tray_Entry_Callback
        (Self      => Self.Internal,
         Callback  =>
           (if Callback = null
            then null
            else Tray_Entry_Trampoline'Access),
         User_Data =>
           (if Context = null
            then System.Null_Address
            else To_Address (Context)));
   end Set_Callback;

   procedure Clear_Callback (Self : in Tray_Entry) is
   begin
      Set_Callback (Self => Self, Callback => null);
   end Clear_Callback;

   procedure Click (Self : in Tray_Entry) is
   begin
      Require_Entry (Self);
      SDL_Click_Tray_Entry (Self.Internal);
   end Click;

   function Get_Parent (Self : in Tray_Entry) return Menu is
   begin
      Require_Entry (Self);
      return Make_Menu (SDL_Get_Tray_Entry_Parent (Self.Internal));
   end Get_Parent;

   function Get_Parent_Entry (Self : in Menu) return Tray_Entry is
   begin
      Require_Menu (Self);
      return Make_Entry (SDL_Get_Tray_Menu_Parent_Entry (Self.Internal));
   end Get_Parent_Entry;

   function Get_Parent_Tray (Self : in Menu) return Tray is
   begin
      Require_Menu (Self);
      return Make_Tray
        (Internal => SDL_Get_Tray_Menu_Parent_Tray (Self.Internal),
         Owns     => False);
   end Get_Parent_Tray;

   procedure Update is
   begin
      SDL_Update_Trays;
   end Update;
end SDL.Trays;
