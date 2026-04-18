with Interfaces.C;
with Interfaces.C.Strings;
with System;

package SDL.Log is
   pragma Preelaborate;

   Max_Length : constant Integer := 4096;

   type Categories is new Interfaces.C.int with
     Convention => C;

   package CS renames Interfaces.C.Strings;
   package Sys renames System;

   Application : constant Categories := 0;
   Errors      : constant Categories := 1;
   Assert      : constant Categories := 2;
   System      : constant Categories := 3;
   Audio       : constant Categories := 4;
   Video       : constant Categories := 5;
   Render      : constant Categories := 6;
   Input       : constant Categories := 7;
   Test        : constant Categories := 8;
   GPU         : constant Categories := 9;

   Reserved_First : constant Categories := 10;
   Reserved_Last  : constant Categories := 18;

   Custom_Category : constant Categories := 19;

   subtype Custom_Categories is Categories range Custom_Category .. Categories'Last;

   type Priorities is (Invalid, Trace, Verbose, Debug, Info, Warn, Error, Critical, Count) with
     Convention => C;

   for Priorities use
     (Invalid  => 0,
      Trace    => 1,
      Verbose  => 2,
      Debug    => 3,
      Info     => 4,
      Warn     => 5,
      Error    => 6,
      Critical => 7,
      Count    => 8);

   type Output_Function is access procedure
     (User_Data : in Sys.Address;
      Category  : in Categories;
      Priority  : in Priorities;
      Message   : in CS.chars_ptr)
   with Convention => C;

   procedure Put (Message : in String) with
     Inline => True;

   procedure Put (Message : in String; Category : in Categories; Priority : in Priorities) with
     Inline => True;

   procedure Put_Critical (Message : in String; Category : in Categories := Application) with
     Inline => True;

   procedure Put_Debug (Message : in String; Category : in Categories := Application) with
     Inline => True;

   procedure Put_Error (Message : in String; Category : in Categories := Application) with
     Inline => True;

   procedure Put_Info (Message : in String; Category : in Categories := Application) with
     Inline => True;

   procedure Put_Trace (Message : in String; Category : in Categories := Application) with
     Inline => True;

   procedure Put_Verbose (Message : in String; Category : in Categories := Application) with
     Inline => True;

   procedure Put_Warn (Message : in String; Category : in Categories := Application) with
     Inline => True;

   procedure Reset_Priorities;

   function Set_Priority_Prefix
     (Priority : in Priorities;
      Prefix   : in String) return Boolean;

   function Clear_Priority_Prefix (Priority : in Priorities) return Boolean;

   procedure Set_All_Priorities (Priority : in Priorities);

   procedure Set (Priority : in Priorities) renames Set_All_Priorities;

   procedure Set_Priority (Category : in Categories; Priority : in Priorities);

   procedure Set (Category : in Categories; Priority : in Priorities) renames Set_Priority;

   function Get_Priority (Category : in Categories) return Priorities;

   procedure Put_Message_V
     (Category  : in Categories;
      Priority  : in Priorities;
      Format    : in CS.chars_ptr;
      Arguments : in Sys.Address);

   function Default_Output_Function return Output_Function;

   procedure Get_Output_Function
     (Callback  : out Output_Function;
      User_Data : out Sys.Address);

   procedure Set_Output_Function
     (Callback  : in Output_Function;
      User_Data : in Sys.Address := Sys.Null_Address);

   procedure Reset_Output_Function;
end SDL.Log;
