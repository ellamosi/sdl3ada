with Ada.Strings.Fixed;
with Ada.Text_IO;

with SDL;
with SDL.Error;
with SDL.Video;
with SDL.Video.Displays;
with SDL.Video.Rectangles;

procedure TestBounds is
   use type SDL.Video.Displays.Display_Indices;

   Initialised : Boolean := False;

   function Trim (Item : in String) return String is
     (Ada.Strings.Fixed.Trim (Item, Ada.Strings.Both));

   procedure Require_SDL
     (Condition : in Boolean;
      Message   : in String) is
   begin
      if not Condition then
         raise Program_Error with Message & ": " & SDL.Error.Get;
      end if;
   end Require_SDL;

   function Rectangle_Image
     (Value : in SDL.Video.Rectangles.Rectangle) return String is
   begin
      return
        "{("
        & Trim (Integer'Image (Integer (Value.X)))
        & ","
        & Trim (Integer'Image (Integer (Value.Y)))
        & "),"
        & Trim (Integer'Image (Integer (Value.Width)))
        & "x"
        & Trim (Integer'Image (Integer (Value.Height)))
        & "}";
   end Rectangle_Image;
begin
   Require_SDL
     (SDL.Set_App_Metadata
        ("SDL Test Bounds",
         "1.0",
         "com.example.testbounds"),
      "Unable to set application metadata");

   Require_SDL
     (SDL.Initialise (SDL.Enable_Video),
      "Couldn't initialize SDL");
   Initialised := True;

   Ada.Text_IO.Put_Line
     ("Using video target '" & SDL.Video.Current_Driver_Name & "'.");

   declare
      Total : constant Positive :=
        Positive (SDL.Video.Displays.Total);
   begin
      Ada.Text_IO.Put_Line
        ("See " & Trim (Positive'Image (Total)) & " displays.");

      for Index in 1 .. Total loop
         declare
            Display : constant SDL.Video.Displays.Display_Indices :=
              SDL.Video.Displays.Display_Indices (Index);
            Bounds  : SDL.Video.Rectangles.Rectangle;
            Usable  : SDL.Video.Rectangles.Rectangle;
            Name    : constant String :=
              SDL.Video.Displays.Get_Display_Name (Display);
         begin
            Ada.Text_IO.Put_Line
              ("Display #"
               & Trim (Positive'Image (Index))
               & " ("""
               & Name
               & """):");

            if SDL.Video.Displays.Get_Bounds (Display, Bounds) then
               Ada.Text_IO.Put_Line
                 ("  bounds=" & Rectangle_Image (Bounds));
            else
               Ada.Text_IO.Put_Line
                 ("  bounds query failed: " & SDL.Error.Get);
            end if;

            if SDL.Video.Displays.Get_Usable_Bounds (Display, Usable) then
               Ada.Text_IO.Put_Line
                 ("  usable=" & Rectangle_Image (Usable));
            else
               Ada.Text_IO.Put_Line
                 ("  usable bounds query failed: " & SDL.Error.Get);
            end if;
         end;
      end loop;
   end;

   SDL.Quit;
exception
   when others =>
      if Initialised then
         SDL.Quit;
      end if;
      raise;
end TestBounds;
