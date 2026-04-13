with Interfaces;
with Interfaces.C;
with Interfaces.C.Extensions;
with Interfaces.C.Strings;
with System;

package SDL.Raw.Assert is
   pragma Preelaborate;

   package C renames Interfaces.C;
   package CS renames Interfaces.C.Strings;

   type Assert_States is
     (Retry_Assertion,
      Break_Assertion,
      Abort_Assertion,
      Ignore_Assertion,
      Always_Ignore_Assertion)
   with
     Convention => C,
     Size       => C.int'Size;

   for Assert_States use
     (Retry_Assertion         => 0,
      Break_Assertion         => 1,
      Abort_Assertion         => 2,
      Ignore_Assertion        => 3,
      Always_Ignore_Assertion => 4);

   type Assert_Data;
   type Assert_Data_Access is access constant Assert_Data with
     Convention => C;

   type Mutable_Assert_Data_Access is access all Assert_Data with
     Convention => C;

   type Assert_Data is record
      Always_Ignore : Interfaces.C.Extensions.bool;
      Trigger_Count : Interfaces.Unsigned_32;
      Condition     : CS.chars_ptr;
      Filename      : CS.chars_ptr;
      Line_Number   : C.int;
      Function_Name : CS.chars_ptr;
      Next          : Assert_Data_Access;
   end record with
     Convention => C;

   type Assertion_Handler is access function
     (Data      : Assert_Data_Access;
      User_Data : System.Address) return Assert_States
   with Convention => C;

   function Report_Assertion
     (Data          : Mutable_Assert_Data_Access;
      Function_Name : CS.chars_ptr;
      File_Name     : CS.chars_ptr;
      Line          : C.int) return Assert_States
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ReportAssertion";

   procedure Set_Assertion_Handler
     (Handler   : in Assertion_Handler;
      User_Data : in System.Address)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetAssertionHandler";

   function Get_Default_Assertion_Handler return Assertion_Handler
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetDefaultAssertionHandler";

   function Get_Assertion_Handler
     (User_Data : access System.Address) return Assertion_Handler
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetAssertionHandler";

   function Get_Assertion_Report return Assert_Data_Access
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetAssertionReport";

   procedure Reset_Assertion_Report
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ResetAssertionReport";
end SDL.Raw.Assert;
