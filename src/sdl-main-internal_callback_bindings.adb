with Ada.Exceptions;
with Ada.Strings.Unbounded;
with Ada.Unchecked_Conversion;
with Ada.Unchecked_Deallocation;

with SDL.Error;

package body SDL.Main.Internal_Callback_Bindings is
   package ASU renames Ada.Strings.Unbounded;

   use type CS.chars_ptr;

   type State_Access is access all Application_State;

   procedure Free_State is new Ada.Unchecked_Deallocation
     (Application_State, State_Access);

   function To_State is new Ada.Unchecked_Conversion (System.Address, State_Access);
   function To_Address is new Ada.Unchecked_Conversion (State_Access, System.Address);

   function To_Arguments
     (ArgC : in C.int;
      ArgV : access CS.chars_ptr_array) return SDL.Main.Argument_Lists;
   procedure Set_Exception_Error
     (Occurrence : in Ada.Exceptions.Exception_Occurrence);
   procedure Cleanup_State
     (App             : in out State_Access;
      Result          : in SDL.Main.App_Results;
      Preserve_Error  : in Boolean := True);

   function To_Arguments
     (ArgC : in C.int;
      ArgV : access CS.chars_ptr_array) return SDL.Main.Argument_Lists
   is
      Count : constant Natural := Natural'Max (0, Integer (ArgC));
   begin
      if Count = 0 then
         return SDL.Main.Empty_Argument_List;
      end if;

      return Result : SDL.Main.Argument_Lists (1 .. Count) do
         for Index in Result'Range loop
            declare
               Raw_Index : constant C.size_t := C.size_t (Index - Result'First);
            begin
               if ArgV = null or else ArgV (Raw_Index) = CS.Null_Ptr then
                  Result (Index) := ASU.Null_Unbounded_String;
               else
                  Result (Index) := ASU.To_Unbounded_String (CS.Value (ArgV (Raw_Index)));
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

   procedure Cleanup_State
     (App             : in out State_Access;
      Result          : in SDL.Main.App_Results;
      Preserve_Error  : in Boolean := True)
   is
      Existing_Error : constant String := SDL.Error.Get;
   begin
      if App = null then
         return;
      end if;

      begin
         Finalize (App.all, Result);
      exception
         when Occurrence : others =>
            if not Preserve_Error or else Existing_Error = "" then
               Set_Exception_Error (Occurrence);
            end if;
      end;

      Free_State (App);
   end Cleanup_State;

   function App_Init
     (App_State : access System.Address;
      ArgC      : in C.int;
      ArgV      : access CS.chars_ptr_array) return SDL.Main.App_Results
   is
      App  : State_Access := new Application_State;
      Args : constant SDL.Main.Argument_Lists := To_Arguments (ArgC, ArgV);
   begin
      App_State.all := System.Null_Address;

      declare
         Result : constant SDL.Main.App_Results := Initialize (App.all, Args);
      begin
         App_State.all := To_Address (App);
         return Result;
      end;
   exception
      when Occurrence : others =>
         Set_Exception_Error (Occurrence);
         Cleanup_State (App, SDL.Main.App_Failure);
         App_State.all := System.Null_Address;
         return SDL.Main.App_Failure;
   end App_Init;

   function App_Iterate
     (App_State : in System.Address) return SDL.Main.App_Results
   is
      App : constant State_Access := To_State (App_State);
   begin
      if App = null then
         SDL.Error.Set ("SDL callback iterate received a null application state");
         return SDL.Main.App_Failure;
      end if;

      return Iterate (App.all);
   exception
      when Occurrence : others =>
         Set_Exception_Error (Occurrence);
         return SDL.Main.App_Failure;
   end App_Iterate;

   function App_Event
     (App_State : in System.Address;
      Event     : access SDL.Events.Events.Events) return SDL.Main.App_Results
   is
      App : constant State_Access := To_State (App_State);
   begin
      if App = null then
         SDL.Error.Set ("SDL callback event received a null application state");
         return SDL.Main.App_Failure;
      end if;

      if Event = null then
         return SDL.Main.App_Continue;
      end if;

      return Handle_Event (App.all, Event.all);
   exception
      when Occurrence : others =>
         Set_Exception_Error (Occurrence);
         return SDL.Main.App_Failure;
   end App_Event;

   procedure App_Quit
     (App_State : in System.Address;
      Result    : in SDL.Main.App_Results)
   is
      App : State_Access := To_State (App_State);
   begin
      Cleanup_State (App, Result, Preserve_Error => False);
   end App_Quit;

   procedure Run is
   begin
      SDL.Main.Run_Callback_App
        (App_Init  => App_Init_Access,
         App_Iter  => App_Iter_Access,
         App_Event => App_Event_Access,
         App_Quit  => App_Quit_Access);
   end Run;
end SDL.Main.Internal_Callback_Bindings;
