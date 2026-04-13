with Interfaces.C;
with System;

with SDL.Raw.Init;
with SDL.Raw.Main;

package SDL.Main is
   package C renames Interfaces.C;

   Main_Error : exception;

   subtype App_Results is SDL.Raw.Init.App_Results;
   subtype Main_Function is SDL.Raw.Main.Main_Function;
   subtype App_Init_Callback is SDL.Raw.Init.App_Init_Callback;
   subtype App_Iterate_Callback is SDL.Raw.Init.App_Iterate_Callback;
   subtype App_Event_Callback is SDL.Raw.Init.App_Event_Callback;
   subtype App_Quit_Callback is SDL.Raw.Init.App_Quit_Callback;
   subtype Window_Class_Styles is SDL.Raw.Main.Window_Class_Styles;

   App_Continue : constant App_Results := SDL.Raw.Init.App_Continue;
   App_Success  : constant App_Results := SDL.Raw.Init.App_Success;
   App_Failure  : constant App_Results := SDL.Raw.Init.App_Failure;
   Default_Window_Class_Style : constant Window_Class_Styles := 0;

   procedure Set_Ready;

   function Run_App
     (ArgC     : in C.int;
      ArgV     : in System.Address := System.Null_Address;
      Main     : in Main_Function;
      Reserved : in System.Address := System.Null_Address) return C.int;

   function Enter_App_Main_Callbacks
     (ArgC      : in C.int;
      ArgV      : in System.Address := System.Null_Address;
      App_Init  : in App_Init_Callback;
      App_Iter  : in App_Iterate_Callback;
      App_Event : in App_Event_Callback;
      App_Quit  : in App_Quit_Callback) return C.int;

   procedure Register_App
     (Style    : in Window_Class_Styles := Default_Window_Class_Style;
      Instance : in System.Address := System.Null_Address);

   procedure Register_App
     (Name     : in String;
      Style    : in Window_Class_Styles := Default_Window_Class_Style;
      Instance : in System.Address := System.Null_Address);

   procedure Unregister_App;

   procedure GDK_Suspend_Complete;
end SDL.Main;
