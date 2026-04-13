with Ada.Unchecked_Conversion;
with Interfaces.C;
with Interfaces.C.Pointers;
with Interfaces.C.Extensions;
with Interfaces.C.Strings;

with SDL.Error;

package body SDL.Inputs.Mice is
   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;
   package CS renames Interfaces.C.Strings;

   use type C.ptrdiff_t;
   use type CS.chars_ptr;
   use type System.Address;

   type ID_Arrays is array (C.ptrdiff_t range <>) of aliased ID with
     Convention => C;

   package ID_Pointers is new Interfaces.C.Pointers
     (Index              => C.ptrdiff_t,
      Element            => ID,
      Element_Array      => ID_Arrays,
      Default_Terminator => 0);

   use type ID_Pointers.Pointer;

   function To_Address is new Ada.Unchecked_Conversion
     (Source => ID_Pointers.Pointer,
      Target => System.Address);

   function To_C_Bool (Value : in Boolean) return CE.bool is
   begin
      if Value then
         return CE.bool'Succ (CE.bool'First);
      end if;

      return CE.bool'First;
   end To_C_Bool;

   procedure SDL_Free (Memory : in System.Address) with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_free";

   procedure Raise_Last_Error
     (Default_Message : in String := "SDL mouse call failed");
   procedure Raise_Last_Error
     (Default_Message : in String := "SDL mouse call failed")
   is
      Message : constant String := SDL.Error.Get;
   begin
      if Message = "" then
         raise Mice_Error with Default_Message;
      end if;

      raise Mice_Error with Message;
   end Raise_Last_Error;

   procedure Free (Items : in out ID_Pointers.Pointer);
   procedure Free (Items : in out ID_Pointers.Pointer) is
   begin
      if Items /= null then
         SDL_Free (To_Address (Items));
         Items := null;
      end if;
   end Free;

   function Copy_IDs
     (Items : in ID_Pointers.Pointer;
      Count : in C.int) return ID_Lists;
   function Copy_IDs
     (Items : in ID_Pointers.Pointer;
      Count : in C.int) return ID_Lists
   is
      Raw : ID_Pointers.Pointer := Items;
   begin
      if Count <= 0 then
         Free (Raw);
         return [];
      end if;

      if Raw = null then
         Raise_Last_Error ("Mouse enumeration failed");
      end if;

      declare
         Source : constant ID_Arrays :=
           ID_Pointers.Value (Raw, C.ptrdiff_t (Count));
         Result : ID_Lists (0 .. Natural (Count) - 1);
      begin
         for Index in Result'Range loop
            Result (Index) :=
              Source (Source'First + C.ptrdiff_t (Index - Result'First));
         end loop;

         Free (Raw);
         return Result;
      exception
         when others =>
            Free (Raw);
            raise;
      end;
   end Copy_IDs;

   function Mouse_Focus return System.Address;
   function Mouse_Focus return System.Address is
      function SDL_Get_Mouse_Focus return System.Address with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetMouseFocus";
   begin
      return SDL_Get_Mouse_Focus;
   end Mouse_Focus;

   function Focused_Window return System.Address;
   function Focused_Window return System.Address is
      function SDL_Get_Keyboard_Focus return System.Address with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetKeyboardFocus";

      Window : constant System.Address := Mouse_Focus;
   begin
      if Window /= System.Null_Address then
         return Window;
      end if;

      return SDL_Get_Keyboard_Focus;
   end Focused_Window;

   function Window_ID (Window : in System.Address) return SDL.Video.Windows.ID;
   function Window_ID (Window : in System.Address) return SDL.Video.Windows.ID is
      function SDL_Get_Window_ID
        (Value : in System.Address) return SDL.Video.Windows.ID with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetWindowID";
   begin
      if Window = System.Null_Address then
         return 0;
      end if;

      return SDL_Get_Window_ID (Window);
   end Window_ID;

   function Relative_Mode_Enabled (Window : in System.Address) return Boolean;
   function Relative_Mode_Enabled (Window : in System.Address) return Boolean is
      function SDL_Get_Window_Relative_Mouse_Mode
        (Value : in System.Address) return CE.bool with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetWindowRelativeMouseMode";
   begin
      if Window = System.Null_Address then
         return False;
      end if;

      return Boolean (SDL_Get_Window_Relative_Mouse_Mode (Window));
   end Relative_Mode_Enabled;

   procedure Set_Relative_Mode_Internal
     (Window : in System.Address;
      Enable : in Boolean);
   procedure Set_Relative_Mode_Internal
     (Window : in System.Address;
      Enable : in Boolean)
   is
      function SDL_Set_Window_Relative_Mouse_Mode
        (Value   : in System.Address;
         Enabled : in CE.bool) return CE.bool with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_SetWindowRelativeMouseMode";
   begin
      if Window = System.Null_Address then
         raise Mice_Error with "Mouse or keyboard focus is required";
      end if;

      if not Boolean
          (SDL_Set_Window_Relative_Mouse_Mode (Window, To_C_Bool (Enable)))
      then
         Raise_Last_Error ("SDL_SetWindowRelativeMouseMode failed");
      end if;
   end Set_Relative_Mode_Internal;

   function Has_Mouse return Boolean is
      function SDL_Has_Mouse return CE.bool with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_HasMouse";
   begin
      return Boolean (SDL_Has_Mouse);
   end Has_Mouse;

   function Get_Mice return ID_Lists is
      function SDL_Get_Mice
        (Count : access C.int) return ID_Pointers.Pointer with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetMice";

      Count : aliased C.int := 0;
      Items : constant ID_Pointers.Pointer := SDL_Get_Mice (Count'Access);
   begin
      return Copy_IDs (Items, Count);
   end Get_Mice;

   function Name (Instance : in ID) return String is
      function SDL_Get_Mouse_Name_For_ID
        (Value : in ID) return CS.chars_ptr with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetMouseNameForID";

      Result : constant CS.chars_ptr := SDL_Get_Mouse_Name_For_ID (Instance);
   begin
      if Result = CS.Null_Ptr then
         return "";
      end if;

      return CS.Value (Result);
   end Name;

   function Get_Focus return SDL.Video.Windows.ID is
   begin
      return Window_ID (Mouse_Focus);
   end Get_Focus;

   function Capture (Enabled : in Boolean) return Supported is
      function SDL_Capture_Mouse (Enabled : in CE.bool) return CE.bool with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_CaptureMouse";
   begin
      if Boolean (SDL_Capture_Mouse (To_C_Bool (Enabled))) then
         return Yes;
      end if;

      return No;
   end Capture;

   function Get_Global_State
     (X_Relative, Y_Relative : out SDL.Events.Mice.Movement_Values)
      return SDL.Events.Mice.Button_Masks
   is
      function SDL_Get_Global_Mouse_State
        (X, Y : out C.C_float) return SDL.Events.Mice.Button_Masks with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetGlobalMouseState";
   begin
      return SDL_Get_Global_Mouse_State (X_Relative, Y_Relative);
   end Get_Global_State;

   function Get_State
     (X_Relative, Y_Relative : out SDL.Events.Mice.Movement_Values)
      return SDL.Events.Mice.Button_Masks
   is
      function SDL_Get_Mouse_State
        (X, Y : out C.C_float) return SDL.Events.Mice.Button_Masks with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetMouseState";
   begin
      return SDL_Get_Mouse_State (X_Relative, Y_Relative);
   end Get_State;

   function In_Relative_Mode return Boolean is
      Window : constant System.Address := Focused_Window;
   begin
      return Relative_Mode_Enabled (Window);
   end In_Relative_Mode;

   function In_Relative_Mode
     (Window : in SDL.Video.Windows.Window) return Boolean
   is (Relative_Mode_Enabled (Window.Get_Internal));

   function Get_Relative_State
     (X_Relative, Y_Relative : out SDL.Events.Mice.Movement_Values)
      return SDL.Events.Mice.Button_Masks
   is
      function SDL_Get_Relative_Mouse_State
        (X, Y : out C.C_float) return SDL.Events.Mice.Button_Masks with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetRelativeMouseState";
   begin
      return SDL_Get_Relative_Mouse_State (X_Relative, Y_Relative);
   end Get_Relative_State;

   procedure Set_Relative_Mode (Enable : in Boolean := True) is
      Window : constant System.Address := Focused_Window;
   begin
      Set_Relative_Mode_Internal (Window, Enable);
   end Set_Relative_Mode;

   procedure Set_Relative_Mode
     (Window : in SDL.Video.Windows.Window;
      Enable : in Boolean := True)
   is
   begin
      Set_Relative_Mode_Internal (Window.Get_Internal, Enable);
   end Set_Relative_Mode;

   procedure Set_Relative_Transform
     (Callback  : in Motion_Transform_Callback;
      User_Data : in System.Address := System.Null_Address)
   is
      function SDL_Set_Relative_Mouse_Transform
        (Transform : in Motion_Transform_Callback;
         Data      : in System.Address) return CE.bool with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_SetRelativeMouseTransform";
   begin
      if not Boolean
          (SDL_Set_Relative_Mouse_Transform (Callback, User_Data))
      then
         Raise_Last_Error ("SDL_SetRelativeMouseTransform failed");
      end if;
   end Set_Relative_Transform;

   procedure Clear_Relative_Transform is
   begin
      Set_Relative_Transform (Callback => null);
   end Clear_Relative_Transform;

   procedure Show_Cursor (Enable : in Boolean := True) is
      function SDL_Show_Cursor return CE.bool with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_ShowCursor";

      function SDL_Hide_Cursor return CE.bool with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_HideCursor";

      Success : constant Boolean :=
        (if Enable then Boolean (SDL_Show_Cursor)
         else Boolean (SDL_Hide_Cursor));
   begin
      if not Success then
         raise Mice_Error with SDL.Error.Get;
      end if;
   end Show_Cursor;

   function Is_Cursor_Shown return Boolean is
      function SDL_Cursor_Visible return CE.bool with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_CursorVisible";
   begin
      return Boolean (SDL_Cursor_Visible);
   end Is_Cursor_Shown;

   procedure Warp (To : in SDL.Coordinates) is
      function SDL_Warp_Mouse_Global
        (X, Y : in C.C_float) return CE.bool with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_WarpMouseGlobal";
   begin
      if not Boolean
          (SDL_Warp_Mouse_Global
             (C.C_float (To.X), C.C_float (To.Y)))
      then
         raise Mice_Error with SDL.Error.Get;
      end if;
   end Warp;

   procedure Warp
     (Window : in SDL.Video.Windows.Window;
      To     : in SDL.Coordinates)
   is
      procedure SDL_Warp_Mouse_In_Window
        (Window : in System.Address;
         X, Y   : in C.C_float) with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_WarpMouseInWindow";
   begin
      SDL_Warp_Mouse_In_Window
        (Window.Get_Internal, C.C_float (To.X), C.C_float (To.Y));
   end Warp;
end SDL.Inputs.Mice;
