with Interfaces.C.Strings;

with SDL.Raw.Assert;

package body SDL.Assertions is
   package CS renames Interfaces.C.Strings;
   package Raw renames SDL.Raw.Assert;

   use type CS.chars_ptr;

   function Value_Or_Empty (Item : in CS.chars_ptr) return String;
   function Value_Or_Empty (Item : in CS.chars_ptr) return String is
   begin
      if Item = CS.Null_Ptr then
         return "";
      end if;

      return CS.Value (Item);
   end Value_Or_Empty;

   function Report
     (Data          : in Mutable_Assert_Data_Access;
      Function_Name : in String;
      File_Name     : in String;
      Line          : in Interfaces.C.int) return Assert_States
   is
      C_Function : CS.chars_ptr := CS.New_String (Function_Name);
      C_File     : CS.chars_ptr := CS.New_String (File_Name);
   begin
      begin
         return Result : constant Assert_States :=
           Raw.Report_Assertion (Data, C_Function, C_File, Line)
         do
            CS.Free (C_Function);
            CS.Free (C_File);
         end return;
      exception
         when others =>
            CS.Free (C_Function);
            CS.Free (C_File);
            raise;
      end;
   end Report;

   procedure Set_Handler
     (Handler   : in Assertion_Handler;
      User_Data : in System.Address := System.Null_Address) is
   begin
      Raw.Set_Assertion_Handler (Handler, User_Data);
   end Set_Handler;

   function Default_Handler return Assertion_Handler is
     (Raw.Get_Default_Assertion_Handler);

   function Get_Handler
     (User_Data : access System.Address := null) return Assertion_Handler is
     (Raw.Get_Assertion_Handler (User_Data));

   function Get_Report return Assert_Data_Access is
     (Raw.Get_Assertion_Report);

   procedure Reset_Report is
   begin
      Raw.Reset_Assertion_Report;
   end Reset_Report;

   function Always_Ignored (Item : in Assert_Data) return Boolean is
     (Boolean (Item.Always_Ignore));

   function Trigger_Count (Item : in Assert_Data) return Interfaces.Unsigned_32 is
     (Item.Trigger_Count);

   function Condition (Item : in Assert_Data) return String is
     (Value_Or_Empty (Item.Condition));

   function File_Name (Item : in Assert_Data) return String is
     (Value_Or_Empty (Item.Filename));

   function Function_Name (Item : in Assert_Data) return String is
     (Value_Or_Empty (Item.Function_Name));

   function Line_Number (Item : in Assert_Data) return Interfaces.C.int is
     (Item.Line_Number);

   function Next (Item : in Assert_Data) return Assert_Data_Access is
     (Item.Next);
end SDL.Assertions;
