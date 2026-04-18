with Ada.Command_Line;
with Ada.Exceptions;
with Ada.Unchecked_Conversion;
with Ada.Unchecked_Deallocation;

with Interfaces.C.Strings;

with SDL.Error;

package body SDL.Main is
   package CS renames Interfaces.C.Strings;

   use type App_Init_Callback;
   use type App_Iterate_Callback;
   use type App_Event_Callback;
   use type App_Quit_Callback;
   use type CS.chars_ptr;

   type Callback_Set is record
      App_Init  : App_Init_Callback := null;
      App_Iter  : App_Iterate_Callback := null;
      App_Event : App_Event_Callback := null;
      App_Quit  : App_Quit_Callback := null;
   end record;

   type Ada_Callback_Set is record
      App_Init  : Ada_App_Init_Callback := null;
      App_Iter  : Ada_App_Iterate_Callback := null;
      App_Event : Ada_App_Event_Callback := null;
      App_Quit  : Ada_App_Quit_Callback := null;
   end record;

   type Argument_Vector_Access is access CS.chars_ptr_array;

   procedure Free_Argument_Vector is new Ada.Unchecked_Deallocation
     (CS.chars_ptr_array, Argument_Vector_Access);

   --  SDL_RunApp only accepts a single main callback, so the callback-app
   --  entry points are staged here for the bridge that enters SDL callbacks.
   Current_Callbacks : Callback_Set :=
     (App_Init  => null,
      App_Iter  => null,
      App_Event => null,
      App_Quit  => null);
   Current_Ada_Callbacks : Ada_Callback_Set :=
     (App_Init  => null,
      App_Iter  => null,
      App_Event => null,
      App_Quit  => null);
   Callback_Running  : Boolean := False;

   procedure Clear_Callbacks;
   procedure Clear_Ada_Callbacks;
   procedure Free_Arguments (Items : in out Argument_Vector_Access);
   function To_Arguments
     (ArgC : in C.int;
      ArgV : access CS.chars_ptr_array) return Argument_Lists;
   procedure Set_Exception_Error
     (Occurrence : in Ada.Exceptions.Exception_Occurrence);
   procedure Raise_Exit_Error
     (Exit_Code    : in C.int;
      Program_Name : in String);
   function Callback_Main
     (ArgC : in C.int;
      ArgV : access CS.chars_ptr_array) return C.int
   with Convention => C;
   function Ada_Callback_Init
     (App_State : access System.Address;
      ArgC      : in C.int;
      ArgV      : access CS.chars_ptr_array) return App_Results
   with Convention => C;
   function Ada_Callback_Iterate
     (App_State : in System.Address) return App_Results
   with Convention => C;
   function Ada_Callback_Event
     (App_State : in System.Address;
      Event     : access SDL.Events.Events.Events) return App_Results
   with Convention => C;
   function To_Raw_Event_Callback is new Ada.Unchecked_Conversion
     (Source => App_Event_Callback,
      Target => SDL.Raw.Main.App_Event_Callback);
   procedure Ada_Callback_Quit
     (App_State : in System.Address;
      Result    : in App_Results)
   with Convention => C;

   procedure Clear_Callbacks is
   begin
      Current_Callbacks :=
        (App_Init  => null,
         App_Iter  => null,
         App_Event => null,
         App_Quit  => null);
   end Clear_Callbacks;

   procedure Clear_Ada_Callbacks is
   begin
      Current_Ada_Callbacks :=
        (App_Init  => null,
         App_Iter  => null,
         App_Event => null,
         App_Quit  => null);
   end Clear_Ada_Callbacks;

   procedure Free_Arguments (Items : in out Argument_Vector_Access) is
   begin
      if Items = null then
         return;
      end if;

      for Index in Items'Range loop
         if Items (Index) /= CS.Null_Ptr then
            CS.Free (Items (Index));
            Items (Index) := CS.Null_Ptr;
         end if;
      end loop;

      Free_Argument_Vector (Items);
   end Free_Arguments;

   function To_Arguments
     (ArgC : in C.int;
      ArgV : access CS.chars_ptr_array) return Argument_Lists
   is
      Count : constant Natural := Natural'Max (0, Integer (ArgC));
   begin
      if Count = 0 then
         return Empty_Argument_List;
      end if;

      return Result : Argument_Lists (1 .. Count) do
         for Index in Result'Range loop
            declare
               Raw_Index : constant C.size_t := C.size_t (Index - Result'First);
            begin
               if ArgV = null or else ArgV (Raw_Index) = CS.Null_Ptr then
                  Result (Index) := ASU.Null_Unbounded_String;
               else
                  Result (Index) :=
                    ASU.To_Unbounded_String (CS.Value (ArgV (Raw_Index)));
               end if;
            end;
         end loop;
      end return;
   end To_Arguments;

   procedure Set_Exception_Error
     (Occurrence : in Ada.Exceptions.Exception_Occurrence)
   is
      Name    : constant String := Ada.Exceptions.Exception_Name (Occurrence);
      Message : constant String := Ada.Exceptions.Exception_Message (Occurrence);
   begin
      if Message /= "" then
         SDL.Error.Set (Name & ": " & Message);
      else
         SDL.Error.Set (Name);
      end if;
   end Set_Exception_Error;

   procedure Raise_Exit_Error
     (Exit_Code    : in C.int;
      Program_Name : in String)
   is
      Message : constant String := SDL.Error.Get;
   begin
      if Exit_Code = C.int (0) then
         return;
      end if;

      if Message /= "" then
         raise Main_Error with Message;
      end if;

      raise Main_Error with
        Program_Name & " exited with status" & Integer'Image (Integer (Exit_Code));
   end Raise_Exit_Error;

   function Callback_Main
     (ArgC : in C.int;
      ArgV : access CS.chars_ptr_array) return C.int
   is
      Arg_Vector : constant System.Address :=
        (if ArgV = null then System.Null_Address else ArgV.all'Address);
   begin
      return Enter_App_Main_Callbacks
        (ArgC      => ArgC,
         ArgV      => Arg_Vector,
         App_Init  => Current_Callbacks.App_Init,
         App_Iter  => Current_Callbacks.App_Iter,
         App_Event => Current_Callbacks.App_Event,
         App_Quit  => Current_Callbacks.App_Quit);
   end Callback_Main;

   function Ada_Callback_Init
     (App_State : access System.Address;
      ArgC      : in C.int;
      ArgV      : access CS.chars_ptr_array) return App_Results
   is
   begin
      if Current_Ada_Callbacks.App_Init = null then
         SDL.Error.Set ("SDL.Main.Run_Ada_Callback_App callback bridge is inactive");
         if App_State /= null then
            App_State.all := System.Null_Address;
         end if;
         return App_Failure;
      end if;

      if App_State /= null then
         App_State.all := System.Null_Address;
      end if;

      return Current_Ada_Callbacks.App_Init (To_Arguments (ArgC, ArgV));
   exception
      when Occurrence : others =>
         if App_State /= null then
            App_State.all := System.Null_Address;
         end if;
         Set_Exception_Error (Occurrence);
         return App_Failure;
   end Ada_Callback_Init;

   function Ada_Callback_Iterate
     (App_State : in System.Address) return App_Results
   is
      pragma Unreferenced (App_State);
   begin
      if Current_Ada_Callbacks.App_Iter = null then
         SDL.Error.Set ("SDL.Main.Run_Ada_Callback_App callback bridge is inactive");
         return App_Failure;
      end if;

      return Current_Ada_Callbacks.App_Iter.all;
   exception
      when Occurrence : others =>
         Set_Exception_Error (Occurrence);
         return App_Failure;
   end Ada_Callback_Iterate;

   function Ada_Callback_Event
     (App_State : in System.Address;
      Event     : access SDL.Events.Events.Events) return App_Results
   is
      pragma Unreferenced (App_State);
   begin
      if Current_Ada_Callbacks.App_Event = null then
         SDL.Error.Set ("SDL.Main.Run_Ada_Callback_App callback bridge is inactive");
         return App_Failure;
      end if;

      if Event = null then
         return App_Continue;
      end if;

      return Current_Ada_Callbacks.App_Event (Event.all);
   exception
      when Occurrence : others =>
         Set_Exception_Error (Occurrence);
         return App_Failure;
   end Ada_Callback_Event;

   procedure Ada_Callback_Quit
     (App_State : in System.Address;
      Result    : in App_Results)
   is
      pragma Unreferenced (App_State);
      Existing_Error : constant String := SDL.Error.Get;
   begin
      if Current_Ada_Callbacks.App_Quit = null then
         SDL.Error.Set ("SDL.Main.Run_Ada_Callback_App callback bridge is inactive");
         return;
      end if;

      Current_Ada_Callbacks.App_Quit (Result);
   exception
      when Occurrence : others =>
         if Existing_Error = "" then
            Set_Exception_Error (Occurrence);
         end if;
   end Ada_Callback_Quit;

   procedure Set_Ready is
   begin
      SDL.Raw.Main.Set_Main_Ready;
   end Set_Ready;

   function Command_Name (Args : in Argument_Lists) return String is
   begin
      if Args'Length = 0 then
         return "";
      end if;

      return ASU.To_String (Args (Args'First));
   end Command_Name;

   function Argument_Count (Args : in Argument_Lists) return Natural is
   begin
      if Args'Length = 0 then
         return 0;
      end if;

      return Args'Length - 1;
   end Argument_Count;

   function Argument
     (Args  : in Argument_Lists;
      Index : in Positive) return String
   is
      Actual_Index : constant Positive := Args'First + Index;
   begin
      if Index > Argument_Count (Args) then
         raise Constraint_Error with "argument index out of range";
      end if;

      return ASU.To_String (Args (Actual_Index));
   end Argument;

   function Run_App
     (ArgC     : in C.int;
      ArgV     : in System.Address := System.Null_Address;
      Main     : in Main_Function;
      Reserved : in System.Address := System.Null_Address) return C.int
   is
   begin
      return SDL.Raw.Main.Run_App (ArgC, ArgV, Main, Reserved);
   end Run_App;

   procedure Run_Ada_Callback_App
     (App_Init  : in Ada_App_Init_Callback;
      App_Iter  : in Ada_App_Iterate_Callback;
      App_Event : in Ada_App_Event_Callback;
      App_Quit  : in Ada_App_Quit_Callback)
   is
   begin
      if Callback_Running then
         raise Main_Error with
           "SDL.Main.Run_Ada_Callback_App does not support nesting";
      end if;

      if App_Init = null
        or else App_Iter = null
        or else App_Event = null
        or else App_Quit = null
      then
         raise Main_Error with
           "SDL.Main.Run_Ada_Callback_App requires non-null callback pointers";
      end if;

      Current_Ada_Callbacks :=
        (App_Init  => App_Init,
         App_Iter  => App_Iter,
         App_Event => App_Event,
         App_Quit  => App_Quit);

      Run_Callback_App
        (App_Init  => Ada_Callback_Init'Access,
         App_Iter  => Ada_Callback_Iterate'Access,
         App_Event => Ada_Callback_Event'Access,
         App_Quit  => Ada_Callback_Quit'Access);

      Clear_Ada_Callbacks;
   exception
      when others =>
         Clear_Ada_Callbacks;
         raise;
   end Run_Ada_Callback_App;

   procedure Run_Callback_App
     (App_Init  : in App_Init_Callback;
      App_Iter  : in App_Iterate_Callback;
      App_Event : in App_Event_Callback;
      App_Quit  : in App_Quit_Callback)
   is
      Arg_Count : constant Natural := Ada.Command_Line.Argument_Count + 1;
      Args      : Argument_Vector_Access := null;
   begin
      if Callback_Running then
         raise Main_Error with "SDL.Main.Run_Callback_App does not support nesting";
      end if;

      if App_Init = null
        or else App_Iter = null
        or else App_Event = null
        or else App_Quit = null
      then
         raise Main_Error with
           "SDL.Main.Run_Callback_App requires non-null callback pointers";
      end if;

      Args := new CS.chars_ptr_array (0 .. C.size_t (Arg_Count));

      for Index in Args'Range loop
         Args (Index) := CS.Null_Ptr;
      end loop;

      Args (0) := CS.New_String (Ada.Command_Line.Command_Name);
      for Index in 1 .. Ada.Command_Line.Argument_Count loop
         Args (C.size_t (Index)) := CS.New_String (Ada.Command_Line.Argument (Index));
      end loop;

      Current_Callbacks :=
        (App_Init  => App_Init,
         App_Iter  => App_Iter,
         App_Event => App_Event,
         App_Quit  => App_Quit);
      Callback_Running := True;

      declare
         Exit_Code : constant C.int :=
           Run_App
             (ArgC     => C.int (Arg_Count),
              ArgV     => Args (Args'First)'Address,
              Main     => Callback_Main'Access,
              Reserved => System.Null_Address);
      begin
         Raise_Exit_Error (Exit_Code, Ada.Command_Line.Command_Name);
      end;

      Callback_Running := False;
      Clear_Callbacks;
      Free_Arguments (Args);
   exception
      when others =>
         Callback_Running := False;
         Clear_Callbacks;
         Free_Arguments (Args);
         raise;
   end Run_Callback_App;

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
        (ArgC, ArgV, App_Init, App_Iter, To_Raw_Event_Callback (App_Event), App_Quit);
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
