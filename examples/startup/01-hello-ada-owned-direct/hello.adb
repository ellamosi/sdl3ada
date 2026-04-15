with Ada.Command_Line;
with Ada.Unchecked_Deallocation;

with Hello_Logic;

with Interfaces.C;
with Interfaces.C.Strings;

with SDL.Error;
with SDL.Main;

procedure Hello is
   package C renames Interfaces.C;
   package CS renames Interfaces.C.Strings;

   use type C.int;
   use type CS.chars_ptr;

   type Argument_Vector_Access is access CS.chars_ptr_array;

   procedure Free_Argument_Vector is new Ada.Unchecked_Deallocation
     (CS.chars_ptr_array, Argument_Vector_Access);

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

   Args      : Argument_Vector_Access := null;
   Arg_Count : constant Natural := Ada.Command_Line.Argument_Count + 1;
   Exit_Code : C.int := 0;
begin
   Args := new CS.chars_ptr_array (0 .. C.size_t (Arg_Count));

   for Index in Args'Range loop
      Args (Index) := CS.Null_Ptr;
   end loop;

   Args (0) := CS.New_String (Ada.Command_Line.Command_Name);
   for Index in 1 .. Ada.Command_Line.Argument_Count loop
      Args (C.size_t (Index)) := CS.New_String (Ada.Command_Line.Argument (Index));
   end loop;

   Exit_Code :=
     SDL.Main.Enter_App_Main_Callbacks
       (ArgC      => C.int (Arg_Count),
        ArgV      => Args (Args'First)'Address,
        App_Init  => Hello_Logic.App_Init'Access,
        App_Iter  => Hello_Logic.App_Iterate'Access,
        App_Event => Hello_Logic.App_Event'Access,
        App_Quit  => Hello_Logic.App_Quit'Access);

   if Exit_Code /= 0 then
      declare
         Message : constant String := SDL.Error.Get;
      begin
         if Message /= "" then
            raise SDL.Main.Main_Error with Message;
         end if;

         raise SDL.Main.Main_Error with
           "hello exited with status" & Integer'Image (Integer (Exit_Code));
      end;
   end if;

   Free_Arguments (Args);
exception
   when others =>
      Free_Arguments (Args);
      raise;
end Hello;
