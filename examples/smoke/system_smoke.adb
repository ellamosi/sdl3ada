with Ada.Exceptions;
with Ada.Text_IO;

with SDL;
with SDL.Error;
with SDL.Platform;
with SDL.Systems;

procedure System_Smoke is
   Initialised : Boolean := False;

   use type SDL.Systems.Sandboxes;

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
   Require
     (SDL.Initialise (SDL.Null_Init_Flags),
      "SDL failed to initialise for system smoke");
   Initialised := True;

   declare
      Sandbox : constant SDL.Systems.Sandboxes := SDL.Systems.Get_Sandbox;
   begin
      case SDL.Platform.Get is
         when SDL.Platform.Mac_OS_X =>
            Require
              (Sandbox = SDL.Systems.Sandbox_None
                 or else Sandbox = SDL.Systems.Sandbox_MacOS,
               "Unexpected sandbox classification on macOS");
            Require
              (not SDL.Systems.Is_Tablet,
               "macOS baseline should not report a tablet form factor");
            Require
              (not SDL.Systems.Is_TV,
               "macOS baseline should not report a TV form factor");

         when others =>
            null;
      end case;
   end;

   SDL.Systems.On_Application_Will_Terminate;
   SDL.Systems.On_Application_Did_Receive_Memory_Warning;
   SDL.Systems.On_Application_Will_Enter_Background;
   SDL.Systems.On_Application_Did_Enter_Background;
   SDL.Systems.On_Application_Will_Enter_Foreground;
   SDL.Systems.On_Application_Did_Enter_Foreground;

   SDL.Quit;
   Initialised := False;

   Ada.Text_IO.Put_Line ("System smoke completed successfully.");
exception
   when Error : others =>
      if Initialised then
         SDL.Quit;
      end if;

      Ada.Text_IO.Put_Line
        ("System smoke failed: " & Ada.Exceptions.Exception_Message (Error));

      if SDL.Error.Get /= "" then
         Ada.Text_IO.Put_Line ("SDL error: " & SDL.Error.Get);
      end if;

      raise;
end System_Smoke;
