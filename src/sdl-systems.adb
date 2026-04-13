with Interfaces.C.Extensions;

with SDL.Error;
with SDL.Raw.Thread;

package body SDL.Systems is
   package CE renames Interfaces.C.Extensions;
   package Raw renames SDL.Raw.System;

   use type CS.chars_ptr;

   function To_C_Bool (Value : in Boolean) return CE.bool is
     (CE.bool'Val (Boolean'Pos (Value)));

   procedure Raise_Last_Error
     (Default_Message : in String := "SDL system call failed");

   function Copy_Required_String
     (Value           : in CS.chars_ptr;
      Default_Message : in String) return String;

   procedure Raise_Last_Error
     (Default_Message : in String := "SDL system call failed")
   is
      Message : constant String := SDL.Error.Get;
   begin
      if Message = "" then
         raise Systems_Error with Default_Message;
      end if;

      raise Systems_Error with Message;
   end Raise_Last_Error;

   function Copy_Required_String
     (Value           : in CS.chars_ptr;
      Default_Message : in String) return String
   is
   begin
      if Value = CS.Null_Ptr then
         Raise_Last_Error (Default_Message);
      end if;

      return CS.Value (Value);
   end Copy_Required_String;

   procedure Set_Windows_Message_Hook
     (Callback  : in Windows_Message_Hook;
      User_Data : in System.Address := System.Null_Address) is
   begin
      Raw.Set_Windows_Message_Hook (Callback, User_Data);
   end Set_Windows_Message_Hook;

   function Direct3D9_Adapter_Index
     (Display : in Display_ID) return C.int is
     (Raw.Get_Direct3D9_Adapter_Index (Display));

   function Get_DXGI_Output_Info
     (Display       : in Display_ID;
      Adapter_Index : out C.int;
      Output_Index  : out C.int) return Boolean
   is
      Local_Adapter : aliased C.int := -1;
      Local_Output  : aliased C.int := -1;
   begin
      Adapter_Index := -1;
      Output_Index := -1;

      if Boolean
          (Raw.Get_DXGI_Output_Info
             (Display,
              Local_Adapter'Access,
              Local_Output'Access))
      then
         Adapter_Index := Local_Adapter;
         Output_Index := Local_Output;
         return True;
      end if;

      return False;
   end Get_DXGI_Output_Info;

   procedure Set_X11_Event_Hook
     (Callback  : in X11_Event_Hook;
      User_Data : in System.Address := System.Null_Address) is
   begin
      Raw.Set_X11_Event_Hook (Callback, User_Data);
   end Set_X11_Event_Hook;

   function Set_Linux_Thread_Priority
     (Thread_ID : in Linux_Thread_ID;
      Priority  : in C.int) return Boolean is
   begin
      return Boolean (Raw.Set_Linux_Thread_Priority (Thread_ID, Priority));
   end Set_Linux_Thread_Priority;

   function Set_Linux_Thread_Priority_And_Policy
     (Thread_ID    : in Linux_Thread_ID;
      Priority     : in SDL.Threads.Priorities;
      Sched_Policy : in C.int) return Boolean is
   begin
      return Boolean
        (Raw.Set_Linux_Thread_Priority_And_Policy
           (Thread_ID,
            SDL.Raw.Thread.Thread_Priority (Priority),
            Sched_Policy));
   end Set_Linux_Thread_Priority_And_Policy;

   function Set_iOS_Animation_Callback
     (Window       : in SDL.Video.Windows.Window;
      Interval     : in C.int;
      Callback     : in IOS_Animation_Callback;
      Callback_Arg : in System.Address := System.Null_Address) return Boolean
   is
   begin
      return Boolean
        (Raw.Set_iOS_Animation_Callback
           (Window       => SDL.Video.Windows.Get_Internal (Window),
            Interval     => Interval,
            Callback     => Callback,
            Callback_Arg => Callback_Arg));
   end Set_iOS_Animation_Callback;

   procedure Set_iOS_Event_Pump (Enabled : in Boolean) is
   begin
      Raw.Set_iOS_Event_Pump (To_C_Bool (Enabled));
   end Set_iOS_Event_Pump;

   function Android_JNI_Environment return Android_JNI_Environment_Handle is
     (Raw.Get_Android_JNI_Environment);

   function Android_Activity return Android_Activity_Handle is
     (Raw.Get_Android_Activity);

   function Android_SDK_Version return C.int is
     (Raw.Get_Android_SDK_Version);

   function Is_Chromebook return Boolean is
     (Boolean (Raw.Is_Chromebook));

   function Is_DeX_Mode return Boolean is
     (Boolean (Raw.Is_DeX_Mode));

   procedure Send_Android_Back_Button is
   begin
      Raw.Send_Android_Back_Button;
   end Send_Android_Back_Button;

   function Android_Internal_Storage_Path return String is
     (Copy_Required_String
        (Raw.Get_Android_Internal_Storage_Path,
         "Android internal storage path is unavailable"));

   function Android_External_Storage_State return External_Storage_Flags is
     (Raw.Get_Android_External_Storage_State);

   function Android_External_Storage_Path return String is
     (Copy_Required_String
        (Raw.Get_Android_External_Storage_Path,
         "Android external storage path is unavailable"));

   function Android_Cache_Path return String is
     (Copy_Required_String
        (Raw.Get_Android_Cache_Path,
         "Android cache path is unavailable"));

   function Request_Android_Permission
     (Permission : in String;
      Callback   : in Request_Android_Permission_Callback;
      User_Data  : in System.Address := System.Null_Address) return Boolean
   is
      C_Permission : CS.chars_ptr := CS.New_String (Permission);
      Success      : Boolean;
   begin
      begin
         Success :=
           Boolean
             (Raw.Request_Android_Permission
                (Permission => C_Permission,
                 Callback   => Callback,
                 User_Data  => User_Data));
      exception
         when others =>
            CS.Free (C_Permission);
            raise;
      end;

      CS.Free (C_Permission);
      return Success;
   end Request_Android_Permission;

   function Show_Android_Toast
     (Message  : in String;
      Duration : in Toast_Durations := Short_Toast;
      Gravity  : in C.int := No_Toast_Gravity;
      X_Offset : in C.int := 0;
      Y_Offset : in C.int := 0) return Boolean
   is
      C_Message : CS.chars_ptr := CS.New_String (Message);
      Success   : Boolean;
   begin
      begin
         Success :=
           Boolean
             (Raw.Show_Android_Toast
                (Message  => C_Message,
                 Duration => Raw.Toast_Durations (Duration),
                 Gravity  => Gravity,
                 X_Offset => X_Offset,
                 Y_Offset => Y_Offset));
      exception
         when others =>
            CS.Free (C_Message);
            raise;
      end;

      CS.Free (C_Message);
      return Success;
   end Show_Android_Toast;

   function Send_Android_Message
     (Command : in Android_Message_Command;
      Param   : in C.int) return Boolean is
   begin
      return Boolean (Raw.Send_Android_Message (Command, Param));
   end Send_Android_Message;

   function Is_Tablet return Boolean is
     (Boolean (Raw.Is_Tablet));

   function Is_TV return Boolean is
     (Boolean (Raw.Is_TV));

   function Get_Sandbox return Sandboxes is
     (Raw.Get_Sandbox);

   procedure On_Application_Will_Terminate is
   begin
      Raw.On_Application_Will_Terminate;
   end On_Application_Will_Terminate;

   procedure On_Application_Did_Receive_Memory_Warning is
   begin
      Raw.On_Application_Did_Receive_Memory_Warning;
   end On_Application_Did_Receive_Memory_Warning;

   procedure On_Application_Will_Enter_Background is
   begin
      Raw.On_Application_Will_Enter_Background;
   end On_Application_Will_Enter_Background;

   procedure On_Application_Did_Enter_Background is
   begin
      Raw.On_Application_Did_Enter_Background;
   end On_Application_Did_Enter_Background;

   procedure On_Application_Will_Enter_Foreground is
   begin
      Raw.On_Application_Will_Enter_Foreground;
   end On_Application_Will_Enter_Foreground;

   procedure On_Application_Did_Enter_Foreground is
   begin
      Raw.On_Application_Did_Enter_Foreground;
   end On_Application_Did_Enter_Foreground;

   procedure On_Application_Did_Change_Status_Bar_Orientation is
   begin
      Raw.On_Application_Did_Change_Status_Bar_Orientation;
   end On_Application_Did_Change_Status_Bar_Orientation;

   function Get_GDK_Task_Queue
     (Task_Queue : out GDK_Task_Queue_Handle) return Boolean
   is
      Local_Handle : aliased GDK_Task_Queue_Handle := null;
   begin
      Task_Queue := null;

      if Boolean (Raw.Get_GDK_Task_Queue (Local_Handle'Access)) then
         Task_Queue := Local_Handle;
         return True;
      end if;

      return False;
   end Get_GDK_Task_Queue;

   function Get_GDK_Default_User
     (User_Handle : out GDK_User_Handle) return Boolean
   is
      Local_Handle : aliased GDK_User_Handle := null;
   begin
      User_Handle := null;

      if Boolean (Raw.Get_GDK_Default_User (Local_Handle'Access)) then
         User_Handle := Local_Handle;
         return True;
      end if;

      return False;
   end Get_GDK_Default_User;
end SDL.Systems;
