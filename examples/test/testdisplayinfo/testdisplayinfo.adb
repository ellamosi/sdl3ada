with Ada.Strings.Fixed;
with Ada.Text_IO;

with SDL;
with SDL.Error;
with SDL.Video;
with SDL.Video.Displays;
with SDL.Video.Pixel_Formats;
with SDL.Video.Rectangles;

procedure TestDisplayInfo is
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
        Trim (Integer'Image (Integer (Value.Width)))
        & "x"
        & Trim (Integer'Image (Integer (Value.Height)))
        & " at "
        & Trim (Integer'Image (Integer (Value.X)))
        & ","
        & Trim (Integer'Image (Integer (Value.Y)));
   end Rectangle_Image;

   function Float_Image (Value : in Float) return String is
     (Trim (Float'Image (Value)));

   function Orientation_Image
     (Value : in SDL.Video.Displays.Display_Orientations) return String is
   begin
      case Value is
         when SDL.Video.Displays.Orientation_Unknown =>
            return "unknown";
         when SDL.Video.Displays.Orientation_Landscape =>
            return "landscape";
         when SDL.Video.Displays.Orientation_Landscape_Flipped =>
            return "landscape-flipped";
         when SDL.Video.Displays.Orientation_Portrait =>
            return "portrait";
         when SDL.Video.Displays.Orientation_Portrait_Flipped =>
            return "portrait-flipped";
      end case;
   end Orientation_Image;

   function Mode_Image (Value : in SDL.Video.Displays.Mode) return String is
   begin
      return
        Trim (Integer'Image (Integer (Value.Width)))
        & "x"
        & Trim (Integer'Image (Integer (Value.Height)))
        & " @"
        & Trim (Integer'Image (Integer (Value.Refresh_Rate)))
        & "Hz, fmt="
        & SDL.Video.Pixel_Formats.Image (Value.Format);
   end Mode_Image;
begin
   Require_SDL
     (SDL.Set_App_Metadata
        ("SDL Test Display Info",
         "1.0",
         "com.example.testdisplayinfo"),
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
            Name    : constant String :=
              SDL.Video.Displays.Get_Display_Name (Display);
            Bounds  : SDL.Video.Rectangles.Rectangle;
            Usable  : SDL.Video.Rectangles.Rectangle;
            Mode    : SDL.Video.Displays.Mode;
            Count   : Positive;
         begin
            Ada.Text_IO.Put_Line
              (Trim (Positive'Image (Index))
               & ": """
               & Name
               & """");

            if SDL.Video.Displays.Get_Bounds (Display, Bounds) then
               Ada.Text_IO.Put_Line
                 ("  bounds: " & Rectangle_Image (Bounds));
            else
               Ada.Text_IO.Put_Line
                 ("  bounds query failed: " & SDL.Error.Get);
            end if;

            if SDL.Video.Displays.Get_Usable_Bounds (Display, Usable) then
               Ada.Text_IO.Put_Line
                 ("  usable: " & Rectangle_Image (Usable));
            else
               Ada.Text_IO.Put_Line
                 ("  usable bounds query failed: " & SDL.Error.Get);
            end if;

            Ada.Text_IO.Put_Line
              ("  content scale: "
               & Float_Image (SDL.Video.Displays.Get_Content_Scale (Display)));
            Ada.Text_IO.Put_Line
              ("  dpi: h="
               & Float_Image
                   (SDL.Video.Displays.Get_Display_Horizontal_DPI (Display))
               & " v="
               & Float_Image
                   (SDL.Video.Displays.Get_Display_Vertical_DPI (Display)));
            Ada.Text_IO.Put_Line
              ("  orientation: current="
               & Orientation_Image
                   (SDL.Video.Displays.Get_Orientation (Display))
               & " natural="
               & Orientation_Image
                   (SDL.Video.Displays.Get_Natural_Orientation (Display)));

            if SDL.Video.Displays.Current_Mode (Display, Mode) then
               Ada.Text_IO.Put_Line ("  CURRENT: " & Mode_Image (Mode));
            else
               Ada.Text_IO.Put_Line
                 ("  CURRENT: failed to query (" & SDL.Error.Get & ")");
            end if;

            if SDL.Video.Displays.Desktop_Mode (Display, Mode) then
               Ada.Text_IO.Put_Line ("  DESKTOP: " & Mode_Image (Mode));
            else
               Ada.Text_IO.Put_Line
                 ("  DESKTOP: failed to query (" & SDL.Error.Get & ")");
            end if;

            if SDL.Video.Displays.Total_Display_Modes (Display, Count) then
               Ada.Text_IO.Put_Line
                 ("  fullscreen modes: " & Trim (Positive'Image (Count)));

               for Mode_Index in Natural range 0 .. Natural (Count - 1) loop
                  if SDL.Video.Displays.Display_Mode (Display, Mode_Index, Mode) then
                     Ada.Text_IO.Put_Line
                       ("    ["
                        & Trim (Natural'Image (Mode_Index))
                        & "] "
                        & Mode_Image (Mode));
                  else
                     Ada.Text_IO.Put_Line
                       ("    ["
                        & Trim (Natural'Image (Mode_Index))
                        & "] failed to query ("
                        & SDL.Error.Get
                        & ")");
                  end if;
               end loop;
            else
               Ada.Text_IO.Put_Line
                 ("  fullscreen mode enumeration failed: " & SDL.Error.Get);
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
end TestDisplayInfo;
