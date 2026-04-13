with Interfaces;
with Interfaces.C;
with System;

with SDL.Raw.Assert;

package SDL.Assertions is
   pragma Preelaborate;

   subtype Assert_States is SDL.Raw.Assert.Assert_States;
   subtype Assert_Data is SDL.Raw.Assert.Assert_Data;
   subtype Assert_Data_Access is SDL.Raw.Assert.Assert_Data_Access;
   subtype Mutable_Assert_Data_Access is SDL.Raw.Assert.Mutable_Assert_Data_Access;
   subtype Assertion_Handler is SDL.Raw.Assert.Assertion_Handler;

   Retry_Assertion         : constant Assert_States := SDL.Raw.Assert.Retry_Assertion;
   Break_Assertion         : constant Assert_States := SDL.Raw.Assert.Break_Assertion;
   Abort_Assertion         : constant Assert_States := SDL.Raw.Assert.Abort_Assertion;
   Ignore_Assertion        : constant Assert_States := SDL.Raw.Assert.Ignore_Assertion;
   Always_Ignore_Assertion : constant Assert_States := SDL.Raw.Assert.Always_Ignore_Assertion;

   function Report
     (Data          : in Mutable_Assert_Data_Access;
      Function_Name : in String;
      File_Name     : in String;
      Line          : in Interfaces.C.int) return Assert_States;

   procedure Set_Handler
     (Handler   : in Assertion_Handler;
      User_Data : in System.Address := System.Null_Address);

   function Default_Handler return Assertion_Handler;
   function Get_Handler
     (User_Data : access System.Address := null) return Assertion_Handler;
   function Get_Report return Assert_Data_Access;
   procedure Reset_Report;

   function Always_Ignored (Item : in Assert_Data) return Boolean;
   function Trigger_Count (Item : in Assert_Data) return Interfaces.Unsigned_32;
   function Condition (Item : in Assert_Data) return String;
   function File_Name (Item : in Assert_Data) return String;
   function Function_Name (Item : in Assert_Data) return String;
   function Line_Number (Item : in Assert_Data) return Interfaces.C.int;
   function Next (Item : in Assert_Data) return Assert_Data_Access;
end SDL.Assertions;
