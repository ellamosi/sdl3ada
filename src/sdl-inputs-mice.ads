with System;

with SDL.Events;
with SDL.Events.Mice;
with SDL.Video.Windows;

package SDL.Inputs.Mice is
   Mice_Error : exception;

   subtype ID is SDL.Events.Mice.IDs;
   type ID_Lists is array (Natural range <>) of ID;

   type Motion_Value_Access is access all SDL.Events.Mice.Movement_Values with
     Convention => C;

   type Motion_Transform_Callback is access procedure
     (User_Data  : in System.Address;
      Time_Stamp : in SDL.Events.Time_Stamps;
      Window     : in System.Address;
      Mouse      : in ID;
      X          : in Motion_Value_Access;
      Y          : in Motion_Value_Access)
   with Convention => C;

   type Cursor_Toggles is (Off, On);

   for Cursor_Toggles use (Off => 0, On => 1);

   type Supported is (Yes, No);

   function Has_Mouse return Boolean;

   function Get_Mice return ID_Lists;

   function Name (Instance : in ID) return String;

   function Get_Focus return SDL.Video.Windows.ID;

   function Capture (Enabled : in Boolean) return Supported;

   function Get_Global_State
     (X_Relative, Y_Relative : out SDL.Events.Mice.Movement_Values)
      return SDL.Events.Mice.Button_Masks;

   function Get_State
     (X_Relative, Y_Relative : out SDL.Events.Mice.Movement_Values)
      return SDL.Events.Mice.Button_Masks;

   function In_Relative_Mode return Boolean;
   function In_Relative_Mode
     (Window : in SDL.Video.Windows.Window) return Boolean;

   function Get_Relative_State
     (X_Relative, Y_Relative : out SDL.Events.Mice.Movement_Values)
      return SDL.Events.Mice.Button_Masks;

   procedure Set_Relative_Mode (Enable : in Boolean := True);
   procedure Set_Relative_Mode
     (Window : in SDL.Video.Windows.Window;
      Enable : in Boolean := True);

   procedure Set_Relative_Transform
     (Callback  : in Motion_Transform_Callback;
      User_Data : in System.Address := System.Null_Address);

   procedure Clear_Relative_Transform;

   procedure Show_Cursor (Enable : in Boolean := True);

   function Is_Cursor_Shown return Boolean;

   procedure Warp (To : in SDL.Coordinates);

   procedure Warp
     (Window : in SDL.Video.Windows.Window;
      To     : in SDL.Coordinates);
end SDL.Inputs.Mice;
