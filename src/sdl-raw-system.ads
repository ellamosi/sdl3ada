with Interfaces;
with Interfaces.C;
with Interfaces.C.Extensions;
with Interfaces.C.Strings;
with System;

with SDL.Raw.Thread;

package SDL.Raw.System is
   pragma Preelaborate;

   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;
   package CS renames Interfaces.C.Strings;

   subtype Display_ID is Interfaces.Unsigned_32;
   subtype Linux_Thread_ID is Interfaces.Integer_64;
   subtype Android_Message_Command is Interfaces.Unsigned_32;

   type Windows_Message is null record;
   type Windows_Message_Pointer is access all Windows_Message with
     Convention => C;

   type X11_Event is null record;
   type X11_Event_Pointer is access all X11_Event with
     Convention => C;

   type GDK_Task_Queue_Object is null record;
   type GDK_Task_Queue_Handle is access all GDK_Task_Queue_Object with
     Convention => C;

   type GDK_User_Object is null record;
   type GDK_User_Handle is access all GDK_User_Object with
     Convention => C;

   type Sandboxes is
     (No_Sandbox,
      Unknown_Container,
      Flatpak,
      Snap,
      MacOS)
   with
     Convention => C,
     Size       => C.int'Size;

   for Sandboxes use
     (No_Sandbox        => 0,
      Unknown_Container => 1,
      Flatpak           => 2,
      Snap              => 3,
      MacOS             => 4);

   type Toast_Durations is
     (Short_Duration,
      Long_Duration)
   with
     Convention => C,
     Size       => C.int'Size;

   for Toast_Durations use
     (Short_Duration => 0,
      Long_Duration  => 1);

   type External_Storage_Flags is mod 2 ** 32 with
     Convention => C;

   Android_External_Storage_Read  : constant External_Storage_Flags := 16#01#;
   Android_External_Storage_Write : constant External_Storage_Flags := 16#02#;

   type Windows_Message_Hook is access function
     (User_Data : in Standard.System.Address;
      Message   : in Windows_Message_Pointer) return CE.bool
   with Convention => C;

   type X11_Event_Hook is access function
     (User_Data : in Standard.System.Address;
      Event     : in X11_Event_Pointer) return CE.bool
   with Convention => C;

   type IOS_Animation_Callback is access procedure
     (User_Data : in Standard.System.Address)
   with Convention => C;

   type Request_Android_Permission_Callback is access procedure
     (User_Data  : in Standard.System.Address;
      Permission : in CS.chars_ptr;
      Granted    : in CE.bool)
   with Convention => C;

   procedure Set_Windows_Message_Hook
     (Callback  : in Windows_Message_Hook;
      User_Data : in Standard.System.Address)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetWindowsMessageHook";

   function Get_Direct3D9_Adapter_Index
     (Display : in Display_ID) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetDirect3D9AdapterIndex";

   function Get_DXGI_Output_Info
     (Display       : in Display_ID;
      Adapter_Index : access C.int;
      Output_Index  : access C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetDXGIOutputInfo";

   procedure Set_X11_Event_Hook
     (Callback  : in X11_Event_Hook;
      User_Data : in Standard.System.Address)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetX11EventHook";

   function Set_Linux_Thread_Priority
     (Thread_ID : in Linux_Thread_ID;
      Priority  : in C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetLinuxThreadPriority";

   function Set_Linux_Thread_Priority_And_Policy
     (Thread_ID   : in Linux_Thread_ID;
      SDL_Priority : in SDL.Raw.Thread.Thread_Priority;
      Sched_Policy : in C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetLinuxThreadPriorityAndPolicy";

   function Set_iOS_Animation_Callback
     (Window      : in Standard.System.Address;
      Interval    : in C.int;
      Callback    : in IOS_Animation_Callback;
      Callback_Arg : in Standard.System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetiOSAnimationCallback";

   procedure Set_iOS_Event_Pump
     (Enabled : in CE.bool)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetiOSEventPump";

   function Get_Android_JNI_Environment return Standard.System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetAndroidJNIEnv";

   function Get_Android_Activity return Standard.System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetAndroidActivity";

   function Get_Android_SDK_Version return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetAndroidSDKVersion";

   function Is_Chromebook return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_IsChromebook";

   function Is_DeX_Mode return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_IsDeXMode";

   procedure Send_Android_Back_Button
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SendAndroidBackButton";

   function Get_Android_Internal_Storage_Path return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetAndroidInternalStoragePath";

   function Get_Android_External_Storage_State return External_Storage_Flags
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetAndroidExternalStorageState";

   function Get_Android_External_Storage_Path return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetAndroidExternalStoragePath";

   function Get_Android_Cache_Path return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetAndroidCachePath";

   function Request_Android_Permission
     (Permission : in CS.chars_ptr;
      Callback   : in Request_Android_Permission_Callback;
      User_Data  : in Standard.System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_RequestAndroidPermission";

   function Show_Android_Toast
     (Message  : in CS.chars_ptr;
      Duration : in Toast_Durations;
      Gravity  : in C.int;
      X_Offset : in C.int;
      Y_Offset : in C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ShowAndroidToast";

   function Send_Android_Message
     (Command : in Android_Message_Command;
      Param   : in C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SendAndroidMessage";

   function Is_Tablet return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_IsTablet";

   function Is_TV return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_IsTV";

   function Get_Sandbox return Sandboxes
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetSandbox";

   procedure On_Application_Will_Terminate
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_OnApplicationWillTerminate";

   procedure On_Application_Did_Receive_Memory_Warning
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_OnApplicationDidReceiveMemoryWarning";

   procedure On_Application_Will_Enter_Background
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_OnApplicationWillEnterBackground";

   procedure On_Application_Did_Enter_Background
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_OnApplicationDidEnterBackground";

   procedure On_Application_Will_Enter_Foreground
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_OnApplicationWillEnterForeground";

   procedure On_Application_Did_Enter_Foreground
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_OnApplicationDidEnterForeground";

   procedure On_Application_Did_Change_Status_Bar_Orientation
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_OnApplicationDidChangeStatusBarOrientation";

   function Get_GDK_Task_Queue
     (Task_Queue : access GDK_Task_Queue_Handle) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGDKTaskQueue";

   function Get_GDK_Default_User
     (User_Handle : access GDK_User_Handle) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGDKDefaultUser";
end SDL.Raw.System;
