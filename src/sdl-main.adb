with Interfaces.C.Strings;

with SDL.Error;

package body SDL.Main is
   package CS renames Interfaces.C.Strings;

   procedure Set_Ready is
   begin
      SDL.Raw.Main.Set_Main_Ready;
   end Set_Ready;

   function Run_App
     (ArgC     : in C.int;
      ArgV     : in System.Address := System.Null_Address;
      Main     : in Main_Function;
      Reserved : in System.Address := System.Null_Address) return C.int
   is
   begin
      return SDL.Raw.Main.Run_App (ArgC, ArgV, Main, Reserved);
   end Run_App;

   function Enter_App_Main_Callbacks
     (ArgC      : in C.int;
      ArgV      : in System.Address := System.Null_Address;
      App_Init  : in App_Init_Callback;
      App_Iter  : in App_Iterate_Callback;
      App_Event : in App_Event_Callback;
      App_Quit  : in App_Quit_Callback) return C.int
   is
   begin
      return SDL.Raw.Main.Enter_App_Main_Callbacks
        (ArgC, ArgV, App_Init, App_Iter, App_Event, App_Quit);
   end Enter_App_Main_Callbacks;

   procedure Register_App
     (Style    : in Window_Class_Styles := Default_Window_Class_Style;
      Instance : in System.Address := System.Null_Address) is
   begin
      if not Boolean
          (SDL.Raw.Main.Register_App (CS.Null_Ptr, Style, Instance))
      then
         raise Main_Error with SDL.Error.Get;
      end if;
   end Register_App;

   procedure Register_App
     (Name     : in String;
      Style    : in Window_Class_Styles := Default_Window_Class_Style;
      Instance : in System.Address := System.Null_Address)
   is
      C_Name : CS.chars_ptr := CS.New_String (Name);
   begin
      begin
         if not Boolean
             (SDL.Raw.Main.Register_App (C_Name, Style, Instance))
         then
            raise Main_Error with SDL.Error.Get;
         end if;
      exception
         when others =>
            CS.Free (C_Name);
            raise;
      end;

      CS.Free (C_Name);
   end Register_App;

   procedure Unregister_App is
   begin
      SDL.Raw.Main.Unregister_App;
   end Unregister_App;

   procedure GDK_Suspend_Complete is
   begin
      SDL.Raw.Main.GDK_Suspend_Complete;
   end GDK_Suspend_Complete;
end SDL.Main;
