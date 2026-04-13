with Ada.Exceptions;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Interfaces.C;

with SDL.Error;
with SDL.Processes;
with SDL.Properties;

procedure Process_Smoke is
   package C renames Interfaces.C;
   package US renames Ada.Strings.Unbounded;

   use type C.int;
   use type SDL.Properties.Property_Numbers;

   procedure Require
     (Condition : in Boolean;
      Message   : in String);

   procedure Require
     (Condition : in Boolean;
      Message   : in String) is
   begin
      if not Condition then
         raise Program_Error with Message;
      end if;
   end Require;
begin
   declare
      Arguments : constant SDL.Processes.Argument_List :=
        (1 => SDL.Processes.To_Argument ("/bin/cat"));
      Child     : SDL.Processes.Process :=
        SDL.Processes.Create (Arguments, Pipe_Stdio => True);
      Exit_Code : C.int := -1;
      Output    : US.Unbounded_String;
   begin
      Require (not SDL.Processes.Is_Null (Child), "Process handle should be valid");
      Require (SDL.Processes.PID (Child) /= 0, "PID should be available");
      Require (not SDL.Processes.Is_Background (Child), "Foreground process reported background mode");
      Require (SDL.Processes.Has_Input (Child), "stdin pipe should be available");
      Require (SDL.Processes.Has_Output (Child), "stdout pipe should be available");
      Require
        (not SDL.Processes.Has_Error_Output (Child),
         "stderr pipe should not be enabled by default");

      SDL.Processes.Write_Input (Child, "phase3-process-payload");
      SDL.Processes.Close_Input (Child);
      Require
        (not SDL.Processes.Has_Input (Child),
         "stdin pipe should be cleared after Close_Input");

      Output := US.To_Unbounded_String (SDL.Processes.Read_All_Output (Child, Exit_Code));

      Require (Exit_Code = 0, "cat exit code should be zero");
      Require
        (US.To_String (Output) = "phase3-process-payload",
         "stdin/stdout process round-trip failed");
      Require
        (SDL.Processes.Wait (Child, Block => False, Exit_Code => Exit_Code),
         "Completed process should report a cached exit status");
      Require (Exit_Code = 0, "Cached exit status should remain zero");
   end;

   declare
      Properties : SDL.Properties.Property_Set := SDL.Properties.Create;
      Arguments  : constant SDL.Processes.Argument_List :=
        (1 => SDL.Processes.To_Argument ("/bin/sh"),
         2 => SDL.Processes.To_Argument ("-c"),
         3 =>
           SDL.Processes.To_Argument
             ("printf 'process-out'; printf ' process-err' 1>&2; exit 7"));
      Exit_Code  : C.int := -1;
      Output     : US.Unbounded_String;
   begin
      Properties.Set_Number
        (SDL.Processes.Process_Create_Stdout_Property,
         SDL.Properties.Property_Numbers (SDL.Processes.Application_IO'Enum_Rep));
      Properties.Set_Boolean
        (SDL.Processes.Process_Create_Stderr_To_Stdout_Property, True);

      declare
         Child : SDL.Processes.Process := SDL.Processes.Create (Arguments, Properties);
      begin
         Require (SDL.Processes.Has_Output (Child), "stdout pipe should be available");
         Require
           (not SDL.Processes.Has_Error_Output (Child),
            "stderr should be redirected into stdout, not exposed separately");

         Output := US.To_Unbounded_String (SDL.Processes.Read_All_Output (Child, Exit_Code));

         Require (Exit_Code = 7, "Property-based process exit code mismatch");
         Require
           (US.To_String (Output) = "process-out process-err",
            "Combined stdout/stderr output mismatch");
         Require
           (SDL.Processes.Wait (Child, Block => False, Exit_Code => Exit_Code),
            "Completed property-based process should report a cached exit status");
         Require (Exit_Code = 7, "Cached property-based exit status mismatch");
      end;
   end;

   Ada.Text_IO.Put_Line ("Process smoke completed successfully.");
exception
   when Error : others =>
      Ada.Text_IO.Put_Line
        ("Process smoke failed: " & Ada.Exceptions.Exception_Message (Error));

      if SDL.Error.Get /= "" then
         Ada.Text_IO.Put_Line ("SDL error: " & SDL.Error.Get);
      end if;

      raise;
end Process_Smoke;
