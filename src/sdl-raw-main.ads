with Interfaces;
with Interfaces.C;
with Interfaces.C.Extensions;
with Interfaces.C.Strings;
with System;

with SDL.Raw.Init;

package SDL.Raw.Main is
   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;
   package CS renames Interfaces.C.Strings;

   subtype Window_Class_Styles is Interfaces.Unsigned_32;

   type Main_Function is access function
     (ArgC : in C.int;
      ArgV : access CS.chars_ptr_array) return C.int
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
      App_Init  : in SDL.Raw.Init.App_Init_Callback;
      App_Iter  : in SDL.Raw.Init.App_Iterate_Callback;
      App_Event : in SDL.Raw.Init.App_Event_Callback;
      App_Quit  : in SDL.Raw.Init.App_Quit_Callback) return C.int
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
