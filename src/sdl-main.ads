with Ada.Strings.Unbounded;
with Interfaces.C;
with System;

with SDL.Events.Events;
with SDL.Raw.Main;

package SDL.Main is
   package C renames Interfaces.C;
   package ASU renames Ada.Strings.Unbounded;

   Main_Error : exception;

   subtype App_Results is SDL.Raw.Main.App_Results;
   subtype Main_Function is SDL.Raw.Main.Main_Function;
   subtype App_Init_Callback is SDL.Raw.Main.App_Init_Callback;
   subtype App_Iterate_Callback is SDL.Raw.Main.App_Iterate_Callback;
   subtype App_Quit_Callback is SDL.Raw.Main.App_Quit_Callback;
   subtype Window_Class_Styles is SDL.Raw.Main.Window_Class_Styles;

   App_Continue : constant App_Results := SDL.Raw.Main.App_Continue;
   App_Success  : constant App_Results := SDL.Raw.Main.App_Success;
   App_Failure  : constant App_Results := SDL.Raw.Main.App_Failure;
   Default_Window_Class_Style : constant Window_Class_Styles := 0;

   type Argument_Lists is array (Positive range <>) of ASU.Unbounded_String;

   Empty_Argument_List : constant Argument_Lists (1 .. 0) :=
     (others => ASU.Null_Unbounded_String);

   procedure Set_Ready;

   function Command_Name (Args : in Argument_Lists) return String;

   function Argument_Count (Args : in Argument_Lists) return Natural;

   function Argument
     (Args  : in Argument_Lists;
      Index : in Positive) return String;

   type Ada_App_Init_Callback is access function
     (Args : in Argument_Lists) return App_Results;

   type Ada_App_Iterate_Callback is access function return App_Results;

   type Ada_App_Event_Callback is access function
     (Event : in SDL.Events.Events.Events) return App_Results;

   type Ada_App_Quit_Callback is access procedure
     (Result : in App_Results);

   type App_Event_Callback is access function
     (App_State : in System.Address;
      Event     : access SDL.Events.Events.Events) return App_Results
   with Convention => C;

   function Run_App
     (ArgC     : in C.int;
      ArgV     : in System.Address := System.Null_Address;
      Main     : in Main_Function;
      Reserved : in System.Address := System.Null_Address) return C.int;

   procedure Run_Ada_Callback_App
     (App_Init  : in Ada_App_Init_Callback;
      App_Iter  : in Ada_App_Iterate_Callback;
      App_Event : in Ada_App_Event_Callback;
      App_Quit  : in Ada_App_Quit_Callback);

   procedure Run_Callback_App
     (App_Init  : in App_Init_Callback;
      App_Iter  : in App_Iterate_Callback;
      App_Event : in App_Event_Callback;
      App_Quit  : in App_Quit_Callback);

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
