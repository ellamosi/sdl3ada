with Interfaces;
with Interfaces.C;
with Interfaces.C.Strings;
with System;

with SDL.Raw.System;
with SDL.Threads;
with SDL.Video.Windows;

package SDL.Systems is
   pragma Elaborate_Body;

   package C renames Interfaces.C;
   package CS renames Interfaces.C.Strings;

   Systems_Error : exception;

   subtype Display_ID is SDL.Raw.System.Display_ID;
   subtype Linux_Thread_ID is SDL.Raw.System.Linux_Thread_ID;
   subtype Android_Message_Command is SDL.Raw.System.Android_Message_Command;
   subtype Windows_Message_Pointer is SDL.Raw.System.Windows_Message_Pointer;
   subtype X11_Event_Pointer is SDL.Raw.System.X11_Event_Pointer;
   subtype GDK_Task_Queue_Handle is SDL.Raw.System.GDK_Task_Queue_Handle;
   subtype GDK_User_Handle is SDL.Raw.System.GDK_User_Handle;
   subtype Sandboxes is SDL.Raw.System.Sandboxes;
   subtype Toast_Durations is SDL.Raw.System.Toast_Durations;
   subtype External_Storage_Flags is SDL.Raw.System.External_Storage_Flags;
   subtype Windows_Message_Hook is SDL.Raw.System.Windows_Message_Hook;
   subtype X11_Event_Hook is SDL.Raw.System.X11_Event_Hook;
   subtype IOS_Animation_Callback is SDL.Raw.System.IOS_Animation_Callback;
   subtype Request_Android_Permission_Callback is
     SDL.Raw.System.Request_Android_Permission_Callback;

   subtype Android_JNI_Environment_Handle is System.Address;
   subtype Android_Activity_Handle is System.Address;

   Sandbox_None              : constant Sandboxes := SDL.Raw.System.No_Sandbox;
   Sandbox_Unknown_Container : constant Sandboxes :=
     SDL.Raw.System.Unknown_Container;
   Sandbox_Flatpak           : constant Sandboxes := SDL.Raw.System.Flatpak;
   Sandbox_Snap              : constant Sandboxes := SDL.Raw.System.Snap;
   Sandbox_MacOS             : constant Sandboxes := SDL.Raw.System.MacOS;

   Short_Toast : constant Toast_Durations := SDL.Raw.System.Short_Duration;
   Long_Toast  : constant Toast_Durations := SDL.Raw.System.Long_Duration;

   External_Storage_Read : constant External_Storage_Flags :=
     SDL.Raw.System.Android_External_Storage_Read;
   External_Storage_Write : constant External_Storage_Flags :=
     SDL.Raw.System.Android_External_Storage_Write;

   No_Toast_Gravity : constant C.int := -1;

   procedure Set_Windows_Message_Hook
     (Callback  : in Windows_Message_Hook;
      User_Data : in System.Address := System.Null_Address);

   function Direct3D9_Adapter_Index
     (Display : in Display_ID) return C.int;

   function Get_DXGI_Output_Info
     (Display       : in Display_ID;
      Adapter_Index : out C.int;
      Output_Index  : out C.int) return Boolean;

   procedure Set_X11_Event_Hook
     (Callback  : in X11_Event_Hook;
      User_Data : in System.Address := System.Null_Address);

   function Set_Linux_Thread_Priority
     (Thread_ID : in Linux_Thread_ID;
      Priority  : in C.int) return Boolean;

   function Set_Linux_Thread_Priority_And_Policy
     (Thread_ID    : in Linux_Thread_ID;
      Priority     : in SDL.Threads.Priorities;
      Sched_Policy : in C.int) return Boolean;

   function Set_iOS_Animation_Callback
     (Window       : in SDL.Video.Windows.Window;
      Interval     : in C.int;
      Callback     : in IOS_Animation_Callback;
      Callback_Arg : in System.Address := System.Null_Address) return Boolean;

   procedure Set_iOS_Event_Pump (Enabled : in Boolean);

   function Android_JNI_Environment return Android_JNI_Environment_Handle;
   function Android_Activity return Android_Activity_Handle;
   function Android_SDK_Version return C.int;
   function Is_Chromebook return Boolean;
   function Is_DeX_Mode return Boolean;

   procedure Send_Android_Back_Button;

   function Android_Internal_Storage_Path return String;
   function Android_External_Storage_State return External_Storage_Flags;
   function Android_External_Storage_Path return String;
   function Android_Cache_Path return String;

   function Request_Android_Permission
     (Permission : in String;
      Callback   : in Request_Android_Permission_Callback;
      User_Data  : in System.Address := System.Null_Address) return Boolean;

   function Show_Android_Toast
     (Message  : in String;
      Duration : in Toast_Durations := Short_Toast;
      Gravity  : in C.int := No_Toast_Gravity;
      X_Offset : in C.int := 0;
      Y_Offset : in C.int := 0) return Boolean;

   function Send_Android_Message
     (Command : in Android_Message_Command;
      Param   : in C.int) return Boolean;

   function Is_Tablet return Boolean;
   function Is_TV return Boolean;
   function Get_Sandbox return Sandboxes;

   procedure On_Application_Will_Terminate;
   procedure On_Application_Did_Receive_Memory_Warning;
   procedure On_Application_Will_Enter_Background;
   procedure On_Application_Did_Enter_Background;
   procedure On_Application_Will_Enter_Foreground;
   procedure On_Application_Did_Enter_Foreground;
   procedure On_Application_Did_Change_Status_Bar_Orientation;

   function Get_GDK_Task_Queue
     (Task_Queue : out GDK_Task_Queue_Handle) return Boolean;

   function Get_GDK_Default_User
     (User_Handle : out GDK_User_Handle) return Boolean;
end SDL.Systems;
