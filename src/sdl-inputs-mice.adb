with Ada.Unchecked_Conversion;
with Interfaces.C;
with Interfaces.C.Strings;

with SDL.Error;
with SDL.Raw.C_Pointers;
with SDL.Raw.Keyboard;
with SDL.Raw.Mouse;
with SDL.Raw.Video;

package body SDL.Inputs.Mice is
   package C renames Interfaces.C;
   package CS renames Interfaces.C.Strings;
   package Raw renames SDL.Raw.Mouse;
   package Raw_Video renames SDL.Raw.Video;

   use type C.ptrdiff_t;
   use type CS.chars_ptr;
   use type Raw.ID_Pointers.Pointer;
   use type System.Address;

   function To_Address is new Ada.Unchecked_Conversion
     (Source => Raw.ID_Pointers.Pointer,
      Target => System.Address);

   function To_Address is new Ada.Unchecked_Conversion
     (Source => SDL.Raw.C_Pointers.Windows_Pointer,
      Target => System.Address);

   function To_Window_Pointer is new Ada.Unchecked_Conversion
     (Source => System.Address,
      Target => Raw_Video.Window_Pointer);

   function To_Raw_Motion_Transform_Callback is new Ada.Unchecked_Conversion
     (Source => Motion_Transform_Callback,
      Target => Raw.Motion_Transform_Callback);

   function To_C_Bool (Value : in Boolean) return Raw.CE.bool is
     (Raw.CE.bool'Val (Boolean'Pos (Value)));

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

   procedure Free (Items : in out Raw.ID_Pointers.Pointer);
   procedure Free (Items : in out Raw.ID_Pointers.Pointer) is
   begin
      if Items /= null then
         Raw.Free (To_Address (Items));
         Items := null;
      end if;
   end Free;

   function Copy_IDs
     (Items : in Raw.ID_Pointers.Pointer;
      Count : in C.int) return ID_Lists;
   function Copy_IDs
     (Items : in Raw.ID_Pointers.Pointer;
      Count : in C.int) return ID_Lists
   is
      Raw_Items : Raw.ID_Pointers.Pointer := Items;
   begin
      if Count <= 0 then
         Free (Raw_Items);
         return [];
      end if;

      if Raw_Items = null then
         Raise_Last_Error ("Mouse enumeration failed");
      end if;

      declare
         Source : constant Raw.ID_Array :=
           Raw.ID_Pointers.Value (Raw_Items, C.ptrdiff_t (Count));
         Result : ID_Lists (0 .. Natural (Count) - 1);
      begin
         for Index in Result'Range loop
            Result (Index) :=
              ID (Source (Source'First + C.ptrdiff_t (Index - Result'First)));
         end loop;

         Free (Raw_Items);
         return Result;
      exception
         when others =>
            Free (Raw_Items);
            raise;
      end;
   end Copy_IDs;

   function Mouse_Focus return System.Address is
     (Raw.Get_Mouse_Focus);

   function Focused_Window return System.Address;
   function Focused_Window return System.Address is
      Window : constant System.Address := Mouse_Focus;
   begin
      if Window /= System.Null_Address then
         return Window;
      end if;

      return To_Address (SDL.Raw.Keyboard.Get_Keyboard_Focus);
   end Focused_Window;

   function Window_ID (Window : in System.Address) return SDL.Video.Windows.ID;
   function Window_ID (Window : in System.Address) return SDL.Video.Windows.ID is
   begin
      if Window = System.Null_Address then
         return 0;
      end if;

      return SDL.Video.Windows.ID
        (Raw_Video.Get_Window_ID (To_Window_Pointer (Window)));
   end Window_ID;

   function Relative_Mode_Enabled (Window : in System.Address) return Boolean;
   function Relative_Mode_Enabled (Window : in System.Address) return Boolean is
   begin
      if Window = System.Null_Address then
         return False;
      end if;

      return Boolean (Raw.Get_Window_Relative_Mouse_Mode (Window));
   end Relative_Mode_Enabled;

   procedure Set_Relative_Mode_Internal
     (Window : in System.Address;
      Enable : in Boolean);
   procedure Set_Relative_Mode_Internal
     (Window : in System.Address;
      Enable : in Boolean)
   is
   begin
      if Window = System.Null_Address then
         raise Mice_Error with "Mouse or keyboard focus is required";
      end if;

      if not Boolean
          (Raw.Set_Window_Relative_Mouse_Mode (Window, To_C_Bool (Enable)))
      then
         Raise_Last_Error ("SDL_SetWindowRelativeMouseMode failed");
      end if;
   end Set_Relative_Mode_Internal;

   function Has_Mouse return Boolean is
   begin
      return Boolean (Raw.Has_Mouse);
   end Has_Mouse;

   function Get_Mice return ID_Lists is
      Count : aliased C.int := 0;
      Items : constant Raw.ID_Pointers.Pointer := Raw.Get_Mice (Count'Access);
   begin
      return Copy_IDs (Items, Count);
   end Get_Mice;

   function Name (Instance : in ID) return String is
      Result : constant CS.chars_ptr :=
        Raw.Get_Mouse_Name_For_ID (Raw.ID (Instance));
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
   begin
      if Boolean (Raw.Capture_Mouse (To_C_Bool (Enabled))) then
         return Yes;
      end if;

      return No;
   end Capture;

   function Get_Global_State
     (X_Relative, Y_Relative : out SDL.Events.Mice.Movement_Values)
      return SDL.Events.Mice.Button_Masks
   is
   begin
      return SDL.Events.Mice.Button_Masks
        (Raw.Get_Global_Mouse_State (X_Relative, Y_Relative));
   end Get_Global_State;

   function Get_State
     (X_Relative, Y_Relative : out SDL.Events.Mice.Movement_Values)
      return SDL.Events.Mice.Button_Masks
   is
   begin
      return SDL.Events.Mice.Button_Masks
        (Raw.Get_Mouse_State (X_Relative, Y_Relative));
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
   begin
      return SDL.Events.Mice.Button_Masks
        (Raw.Get_Relative_Mouse_State (X_Relative, Y_Relative));
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
      Raw_Callback : constant Raw.Motion_Transform_Callback :=
        (if Callback = null then null
         else To_Raw_Motion_Transform_Callback (Callback));
   begin
      if not Boolean
          (Raw.Set_Relative_Mouse_Transform (Raw_Callback, User_Data))
      then
         Raise_Last_Error ("SDL_SetRelativeMouseTransform failed");
      end if;
   end Set_Relative_Transform;

   procedure Clear_Relative_Transform is
   begin
      Set_Relative_Transform (Callback => null);
   end Clear_Relative_Transform;

   procedure Show_Cursor (Enable : in Boolean := True) is
   begin
      if Enable then
         if not Boolean (Raw.Show_Cursor) then
            Raise_Last_Error ("SDL_ShowCursor failed");
         end if;
      else
         if not Boolean (Raw.Hide_Cursor) then
            Raise_Last_Error ("SDL_HideCursor failed");
         end if;
      end if;
   end Show_Cursor;

   function Is_Cursor_Shown return Boolean is
   begin
      return Boolean (Raw.Cursor_Visible);
   end Is_Cursor_Shown;

   procedure Warp (To : in SDL.Coordinates) is
   begin
      if not Boolean
          (Raw.Warp_Mouse_Global (C.C_float (To.X), C.C_float (To.Y)))
      then
         Raise_Last_Error ("SDL_WarpMouseGlobal failed");
      end if;
   end Warp;

   procedure Warp
     (Window : in SDL.Video.Windows.Window;
      To     : in SDL.Coordinates)
   is
   begin
      Raw.Warp_Mouse_In_Window
        (Window.Get_Internal, C.C_float (To.X), C.C_float (To.Y));
   end Warp;
end SDL.Inputs.Mice;
