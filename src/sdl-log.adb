with Ada.Unchecked_Conversion;

with SDL.Raw.Log;

package body SDL.Log is
   package C renames Interfaces.C;
   package Raw renames SDL.Raw.Log;

   function To_Raw_Priority (Value : in Priorities) return Raw.Priorities is
     (Raw.Priorities'Val (Priorities'Pos (Value)));

   function To_Public_Priority (Value : in Raw.Priorities) return Priorities is
     (Priorities'Val (Raw.Priorities'Pos (Value)));

   function To_Raw_Category (Value : in Categories) return Raw.Categories is
     (Raw.Categories (Value));

   function To_Raw_Output_Function is new Ada.Unchecked_Conversion
     (Source => Output_Function,
      Target => Raw.Output_Function);

   function To_Public_Output_Function is new Ada.Unchecked_Conversion
     (Source => Raw.Output_Function,
      Target => Output_Function);

   procedure Put (Message : in String) is
   begin
      Raw.Log (C.To_C ("%s"), C.To_C (Message));
   end Put;

   procedure Put (Message : in String; Category : in Categories; Priority : in Priorities) is
   begin
      Raw.Log_Message
        (To_Raw_Category (Category),
         To_Raw_Priority (Priority),
         C.To_C ("%s"),
         C.To_C (Message));
   end Put;

   procedure Put_Critical (Message : in String; Category : in Categories := Application) is
   begin
      Raw.Log_Critical (To_Raw_Category (Category), C.To_C ("%s"), C.To_C (Message));
   end Put_Critical;

   procedure Put_Debug (Message : in String; Category : in Categories := Application) is
   begin
      Raw.Log_Debug (To_Raw_Category (Category), C.To_C ("%s"), C.To_C (Message));
   end Put_Debug;

   procedure Put_Error (Message : in String; Category : in Categories := Application) is
   begin
      Raw.Log_Error (To_Raw_Category (Category), C.To_C ("%s"), C.To_C (Message));
   end Put_Error;

   procedure Put_Info (Message : in String; Category : in Categories := Application) is
   begin
      Raw.Log_Info (To_Raw_Category (Category), C.To_C ("%s"), C.To_C (Message));
   end Put_Info;

   procedure Put_Trace (Message : in String; Category : in Categories := Application) is
   begin
      Raw.Log_Trace (To_Raw_Category (Category), C.To_C ("%s"), C.To_C (Message));
   end Put_Trace;

   procedure Put_Verbose (Message : in String; Category : in Categories := Application) is
   begin
      Raw.Log_Verbose (To_Raw_Category (Category), C.To_C ("%s"), C.To_C (Message));
   end Put_Verbose;

   procedure Put_Warn (Message : in String; Category : in Categories := Application) is
   begin
      Raw.Log_Warn (To_Raw_Category (Category), C.To_C ("%s"), C.To_C (Message));
   end Put_Warn;

   procedure Reset_Priorities is
   begin
      Raw.Reset_Log_Priorities;
   end Reset_Priorities;

   function Set_Priority_Prefix
     (Priority : in Priorities;
     Prefix   : in String) return Boolean
   is
      C_Prefix : CS.chars_ptr := CS.New_String (Prefix);
   begin
      begin
         return Result : constant Boolean :=
           Boolean (Raw.Set_Log_Priority_Prefix (To_Raw_Priority (Priority), C_Prefix))
         do
            CS.Free (C_Prefix);
         end return;
      exception
         when others =>
            CS.Free (C_Prefix);
            raise;
      end;
   end Set_Priority_Prefix;

   function Clear_Priority_Prefix (Priority : in Priorities) return Boolean is
     (Boolean (Raw.Set_Log_Priority_Prefix (To_Raw_Priority (Priority), CS.Null_Ptr)));

   procedure Set_All_Priorities (Priority : in Priorities) is
   begin
      Raw.Set_Log_Priorities (To_Raw_Priority (Priority));
   end Set_All_Priorities;

   procedure Set_Priority (Category : in Categories; Priority : in Priorities) is
   begin
      Raw.Set_Log_Priority (To_Raw_Category (Category), To_Raw_Priority (Priority));
   end Set_Priority;

   function Get_Priority (Category : in Categories) return Priorities is
     (To_Public_Priority (Raw.Get_Log_Priority (To_Raw_Category (Category))));

   procedure Put_Message_V
     (Category  : in Categories;
      Priority  : in Priorities;
      Format    : in CS.chars_ptr;
      Arguments : in Sys.Address) is
   begin
      Raw.Log_Message_V
        (To_Raw_Category (Category),
         To_Raw_Priority (Priority),
         Format,
         Arguments);
   end Put_Message_V;

   function Default_Output_Function return Output_Function is
     (To_Public_Output_Function (Raw.Get_Default_Log_Output_Function));

   procedure Get_Output_Function
     (Callback  : out Output_Function;
      User_Data : out Sys.Address)
   is
      Local_Callback  : aliased Raw.Output_Function := null;
      Local_User_Data : aliased Sys.Address := Sys.Null_Address;
   begin
      Raw.Get_Log_Output_Function
        (Local_Callback'Access, Local_User_Data'Access);
      Callback := To_Public_Output_Function (Local_Callback);
      User_Data := Local_User_Data;
   end Get_Output_Function;

   procedure Set_Output_Function
     (Callback  : in Output_Function;
      User_Data : in Sys.Address := Sys.Null_Address) is
   begin
      Raw.Set_Log_Output_Function (To_Raw_Output_Function (Callback), User_Data);
   end Set_Output_Function;

   procedure Reset_Output_Function is
   begin
      Raw.Set_Log_Output_Function (Raw.Get_Default_Log_Output_Function, Sys.Null_Address);
   end Reset_Output_Function;
end SDL.Log;
