with Ada.Command_Line;
with Ada.Text_IO;

with SDL;
with SDL.Error;
with SDL.Misc;

procedure TestURL is
   Initialised : Boolean := False;
   Any_Failure : Boolean := False;

   procedure Require_SDL
     (Condition : in Boolean;
      Message   : in String) is
   begin
      if not Condition then
         raise Program_Error with Message & ": " & SDL.Error.Get;
      end if;
   end Require_SDL;
begin
   Require_SDL
     (SDL.Set_App_Metadata
        ("SDL Test URL",
         "1.0",
         "com.example.testurl"),
      "Unable to set application metadata");

   Require_SDL
     (SDL.Initialise (SDL.Enable_Video),
      "Couldn't initialize SDL");
   Initialised := True;

   if Ada.Command_Line.Argument_Count = 0 then
      Ada.Text_IO.Put_Line
        ("Usage: " & Ada.Command_Line.Command_Name & " <url> [url ...]");
      Ada.Text_IO.Put_Line
        ("Example: " & Ada.Command_Line.Command_Name & " https://libsdl.org/");
      Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
   else
      for Index in 1 .. Ada.Command_Line.Argument_Count loop
         declare
            URL : constant String := Ada.Command_Line.Argument (Index);
         begin
            Ada.Text_IO.Put_Line ("Opening '" & URL & "' ...");

            begin
               SDL.Misc.Open_URL (URL);
               Ada.Text_IO.Put_Line ("  success!");
            exception
               when SDL.Misc.Misc_Error =>
                  Any_Failure := True;
                  Ada.Text_IO.Put_Line ("  failed! " & SDL.Error.Get);
            end;
         end;
      end loop;

      if Any_Failure then
         Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
      end if;
   end if;

   if Initialised then
      SDL.Quit;
   end if;
exception
   when others =>
      if Initialised then
         SDL.Quit;
      end if;
      raise;
end TestURL;
