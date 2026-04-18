with Interfaces;
with Interfaces.C;
with Interfaces.C.Extensions;
with Interfaces.C.Strings;
with System;

with SDL.Events.Events;

package SDL.Raw.Main is
   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;
   package CS renames Interfaces.C.Strings;

   subtype Window_Class_Styles is Interfaces.Unsigned_32;

   type App_Results is
     (App_Continue,
      App_Success,
      App_Failure)
   with
     Convention => C,
     Size       => C.int'Size;

   for App_Results use
     (App_Continue => 0,
      App_Success  => 1,
      App_Failure  => 2);

   type Main_Function is access function
     (ArgC : in C.int;
      ArgV : access CS.chars_ptr_array) return C.int
   with Convention => C;

   type App_Init_Callback is access function
     (App_State : access System.Address;
      ArgC      : in C.int;
      ArgV      : access CS.chars_ptr_array) return App_Results
   with Convention => C;

   type App_Iterate_Callback is access function
     (App_State : in System.Address) return App_Results
   with Convention => C;

   type App_Event_Callback is access function
     (App_State : in System.Address;
      Event     : access SDL.Events.Events.Events) return App_Results
   with Convention => C;

   type App_Quit_Callback is access procedure
     (App_State : in System.Address;
      Result    : in App_Results)
   with Convention => C;

   procedure Set_Main_Ready
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetMainReady";

   function Run_App
     (ArgC      : in C.int;
      ArgV      : in System.Address;
      Main      : in Main_Function;
      Reserved  : in System.Address) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_RunApp";

   function Enter_App_Main_Callbacks
     (ArgC      : in C.int;
      ArgV      : in System.Address;
      App_Init  : in App_Init_Callback;
      App_Iter  : in App_Iterate_Callback;
      App_Event : in App_Event_Callback;
      App_Quit  : in App_Quit_Callback) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_EnterAppMainCallbacks";

   function Register_App
     (Name     : in CS.chars_ptr;
      Style    : in Window_Class_Styles;
      Instance : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_RegisterApp";

   procedure Unregister_App
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_UnregisterApp";

   procedure GDK_Suspend_Complete
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GDKSuspendComplete";
end SDL.Raw.Main;
