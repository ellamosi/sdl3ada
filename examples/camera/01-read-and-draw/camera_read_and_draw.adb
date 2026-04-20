with Ada.Characters.Handling;
with Ada.Command_Line;
with Ada.Exceptions;
with Ada.Strings;
with Ada.Strings.Fixed;
with Ada.Strings.Unbounded;
with Ada.Text_IO;

with SDL;
with SDL.Cameras;
with SDL.Error;
with SDL.Events;
with SDL.Events.Cameras;
with SDL.Events.Queue;
with SDL.Events.Keyboards;
with SDL.Events.Mice;
with SDL.Message_Boxes;
with SDL.Properties;
with SDL.Timers;
with SDL.Video.Pixel_Formats;
with SDL.Video.Pixels;
with SDL.Video.Rectangles;
with SDL.Video.Renderers;
with SDL.Video.Renderers.Makers;
with SDL.Video.Surfaces;
with SDL.Video.Textures;
with SDL.Video.Textures.Makers;
with SDL.Video.Windows;

procedure Camera_Read_And_Draw is
   package ASU renames Ada.Strings.Unbounded;

   use Ada.Text_IO;

   use type SDL.C.int;
   use type SDL.Cameras.ID;
   use type SDL.Cameras.Positions;
   use type SDL.Dimension;
   use type SDL.Events.Event_Types;
   use type SDL.Events.Keyboards.Key_Codes;
   use type SDL.Init_Flags;
   use type SDL.Properties.Property_Numbers;
   use type SDL.Sizes;
   use type SDL.Timers.Milliseconds;
   use type SDL.Video.Pixel_Formats.Pixel_Format_Access;
   use type SDL.Video.Pixel_Formats.Pixel_Format_Names;
   use type SDL.Video.Surfaces.Surface;

   package Float_Output is new Ada.Text_IO.Float_IO (Float);

   Renderer_Max_Texture_Size_Property : constant String :=
     "SDL.renderer.max_texture_size";
   Surface_Rotation_Property : constant String := "SDL.surface.rotation";
   Texture_Create_Access_Property : constant String :=
     "SDL.texture.create.access";
   Texture_Create_Colourspace_Property : constant String :=
     "SDL.texture.create.colorspace";
   Texture_Create_Format_Property : constant String :=
     "SDL.texture.create.format";
   Texture_Create_Height_Property : constant String :=
     "SDL.texture.create.height";
   Texture_Create_Width_Property : constant String :=
     "SDL.texture.create.width";

   Texture_Access_Streaming : constant SDL.Properties.Property_Numbers := 1;

   Escape_Key_Code  : constant SDL.Events.Keyboards.Key_Codes :=
     SDL.Events.Keyboards.Value ("Escape");
   Space_Key_Code   : constant SDL.Events.Keyboards.Key_Codes :=
     SDL.Events.Keyboards.Value ("Space");
   AC_Back_Key_Code : constant SDL.Events.Keyboards.Key_Codes :=
     SDL.Events.Keyboards.Value ("AC Back");

   Window   : SDL.Video.Windows.Window;
   Renderer : SDL.Video.Renderers.Renderer;
   Camera   : SDL.Cameras.Camera;
   Texture  : SDL.Video.Textures.Texture;

   Current_Frame : SDL.Video.Surfaces.Surface := SDL.Video.Surfaces.Null_Surface;

   Texture_Updated : Boolean := False;
   Running         : Boolean := True;

   Front_Camera : SDL.Cameras.ID := 0;
   Back_Camera  : SDL.Cameras.ID := 0;

   Last_Log_Time  : SDL.Timers.Milliseconds := 0;
   Last_Flip_Time : SDL.Timers.Milliseconds := 0;
   Iterate_Count  : Natural := 0;
   Frame_Count    : Natural := 0;

   function Trim (Item : in String) return String is
     (Ada.Strings.Fixed.Trim (Item, Ada.Strings.Both));

   function Format_Float (Value : in Float) return String is
      Buffer : String (1 .. 32);
   begin
      Float_Output.Put (To => Buffer, Item => Value, Aft => 2, Exp => 0);
      return Trim (Buffer);
   end Format_Float;

   function Format_FPS (Spec : in SDL.Cameras.Spec) return String is
      FPS : Float := 0.0;
   begin
      if Spec.Framerate_Denominator /= 0 then
         FPS :=
           Float (Spec.Framerate_Numerator) /
           Float (Spec.Framerate_Denominator);
      end if;

      return Format_Float (FPS);
   end Format_FPS;

   function Format_Spec (Spec : in SDL.Cameras.Spec) return String is
   begin
      return
        Trim (Integer'Image (Integer (Spec.Width)))
        & "x"
        & Trim (Integer'Image (Integer (Spec.Height)))
        & " "
        & Format_FPS (Spec)
        & " FPS "
        & SDL.Video.Pixel_Formats.Image (Spec.Format);
   end Format_Spec;

   function Equal_Case_Insensitive
     (Left  : in String;
      Right : in String) return Boolean is
   begin
      return Ada.Characters.Handling.To_Lower (Left) =
        Ada.Characters.Handling.To_Lower (Right);
   end Equal_Case_Insensitive;

   function Requested_Camera_Name return String is
      Name  : ASU.Unbounded_String := ASU.Null_Unbounded_String;
      Index : Positive := 1;
   begin
      while Index <= Ada.Command_Line.Argument_Count loop
         declare
            Argument : constant String := Ada.Command_Line.Argument (Index);
         begin
            if Argument = "--camera" then
               if Index = Ada.Command_Line.Argument_Count then
                  raise Program_Error with "Missing value after --camera";
               end if;

               Name := ASU.To_Unbounded_String (Ada.Command_Line.Argument (Index + 1));
               Index := Index + 2;
            else
               raise Program_Error with
                 "Unknown argument: "
                 & Argument
                 & ASCII.LF
                 & "Usage: "
                 & Ada.Command_Line.Command_Name
                 & " [--camera name]";
            end if;
         end;
      end loop;

      return ASU.To_String (Name);
   end Requested_Camera_Name;

   function Default_Spec return SDL.Cameras.Spec is
     ((Format                => SDL.Video.Pixel_Formats.Pixel_Format_Unknown,
       Colour_Space          => SDL.Cameras.Unknown_Colour_Space,
       Width                 => 0,
       Height                => 0,
       Framerate_Numerator   => 0,
       Framerate_Denominator => 0));

   function Has_Desired_Spec (Spec : in SDL.Cameras.Spec) return Boolean is
     (Spec.Width > 0 and then Spec.Height > 0);

   function Frame_Format
     (Frame : in SDL.Video.Surfaces.Surface)
      return SDL.Video.Pixel_Formats.Pixel_Format_Names
   is
      Format_Details : constant SDL.Video.Pixel_Formats.Pixel_Format_Access :=
        SDL.Video.Surfaces.Pixel_Format (Frame);
   begin
      if Format_Details = null then
         return SDL.Video.Pixel_Formats.Pixel_Format_Unknown;
      end if;

      return Format_Details.Format;
   end Frame_Format;

   function To_Positive_Size
     (Size : in SDL.Sizes) return SDL.Positive_Sizes is
   begin
      return
        (Width  => SDL.Positive_Dimension (Size.Width),
         Height => SDL.Positive_Dimension (Size.Height));
   end To_Positive_Size;

   function Renderer_Max_Texture_Size return Natural is
      Props : constant SDL.Properties.Property_Set :=
        SDL.Properties.Reference (SDL.Video.Renderers.Get_Properties (Renderer));
      Value : constant SDL.Properties.Property_Numbers :=
        SDL.Properties.Get_Number
          (Props, Renderer_Max_Texture_Size_Property, 0);
   begin
      if Value <= 0 then
         return 0;
      end if;

      return Natural (Value);
   end Renderer_Max_Texture_Size;

   procedure Print_Camera_Specs (Camera_ID : in SDL.Cameras.ID) is
      Formats : constant SDL.Cameras.Spec_Lists :=
        SDL.Cameras.Supported_Formats (Camera_ID);
   begin
      if Formats'Length = 0 then
         return;
      end if;

      Put_Line ("Available formats:");
      for Spec of Formats loop
         Put_Line ("    " & Format_Spec (Spec));
      end loop;
   end Print_Camera_Specs;

   function Pick_Camera_Spec
     (Camera_ID         : in SDL.Cameras.ID;
      Maximum_Texture_Size : in Natural) return SDL.Cameras.Spec
   is
      Formats : constant SDL.Cameras.Spec_Lists :=
        SDL.Cameras.Supported_Formats (Camera_ID);
   begin
      for Spec of Formats loop
         if Natural (Spec.Width) <= Maximum_Texture_Size
           and then Natural (Spec.Height) <= Maximum_Texture_Size
         then
            return Spec;
         end if;
      end loop;

      return Default_Spec;
   end Pick_Camera_Spec;

   procedure Release_Current_Frame is
   begin
      if Current_Frame = SDL.Video.Surfaces.Null_Surface or else Camera.Is_Null then
         return;
      end if;

      Camera.Release_Frame (Current_Frame);
   end Release_Current_Frame;

   procedure Destroy_Texture is
   begin
      SDL.Video.Textures.Finalize (Texture);
      Texture_Updated := False;
   end Destroy_Texture;

   procedure Update_Window_Title (Camera_ID : in SDL.Cameras.ID) is
   begin
      Window.Set_Title
        ("camera_read_and_draw: "
         & SDL.Cameras.Name (Camera_ID)
         & " ("
         & SDL.Cameras.Current_Driver_Name
         & ")");
   end Update_Window_Title;

   procedure Open_Camera (Camera_ID : in SDL.Cameras.ID) is
      Desired : constant SDL.Cameras.Spec :=
        Pick_Camera_Spec (Camera_ID, Renderer_Max_Texture_Size);
   begin
      if Has_Desired_Spec (Desired) then
         Camera.Open (Camera_ID, Desired);
      else
         Camera.Open (Camera_ID);
      end if;

      Update_Window_Title (Camera_ID);
   end Open_Camera;

   procedure Flip_Camera is
      Current_Time : constant SDL.Timers.Milliseconds := SDL.Timers.Ticks;
      Current_ID   : SDL.Cameras.ID := 0;
      Next_Camera  : SDL.Cameras.ID := 0;
   begin
      if Camera.Is_Null or else (Current_Time - Last_Flip_Time) < 3_000 then
         return;
      end if;

      Current_ID := Camera.Get_ID;

      if Current_ID = Front_Camera then
         Next_Camera := Back_Camera;
      elsif Current_ID = Back_Camera then
         Next_Camera := Front_Camera;
      end if;

      if Next_Camera = 0 then
         return;
      end if;

      Put_Line ("Flip camera!");

      Release_Current_Frame;
      Camera.Close;
      Destroy_Texture;
      Open_Camera (Next_Camera);
      Last_Flip_Time := Current_Time;
   end Flip_Camera;

   procedure Log_Current_Camera_Format is
      Active : SDL.Cameras.Spec;
   begin
      if Camera.Is_Null then
         return;
      end if;

      if Camera.Get_Format (Active) then
         Put_Line ("Camera approved!");
         Put_Line ("Camera spec: " & Format_Spec (Active));
      end if;
   end Log_Current_Camera_Format;

   procedure Handle_Events is
      Event : SDL.Events.Queue.Event;
   begin
      while SDL.Events.Queue.Poll (Event) loop
         if Event.Common.Event_Type = SDL.Events.Quit then
            Put_Line ("Quit!");
            Running := False;
         else
            case SDL.Events.Queue.Kind_Of (Event) is
               when SDL.Events.Queue.Is_Keyboard_Event =>
                  declare
                     Keyboard_Event :
                       constant SDL.Events.Keyboards.Keyboard_Events :=
                         SDL.Events.Queue.As_Keyboard (Event);
                     Key_Code : constant SDL.Events.Keyboards.Key_Codes :=
                       Keyboard_Event.Key_Sym.Key_Code;
                  begin
                     if Keyboard_Event.Event_Type = SDL.Events.Keyboards.Key_Down then
                        if Key_Code = Escape_Key_Code
                          or else Key_Code = AC_Back_Key_Code
                        then
                           Put_Line ("Key: Escape!");
                           Running := False;
                        elsif Key_Code = Space_Key_Code then
                           Flip_Camera;
                        end if;
                     end if;
                  end;

               when SDL.Events.Queue.Is_Mouse_Button_Event =>
                  declare
                     Button_Event : constant SDL.Events.Mice.Button_Events :=
                       SDL.Events.Queue.As_Mouse_Button (Event);
                  begin
                     if Button_Event.Event_Type = SDL.Events.Mice.Button_Down then
                        Flip_Camera;
                     end if;
                  end;

               when SDL.Events.Queue.Is_Camera_Device_Event =>
                  declare
                     Camera_Event : constant SDL.Events.Cameras.Device_Events :=
                       SDL.Events.Queue.As_Camera_Device (Event);
                  begin
                     if Camera_Event.Event_Type = SDL.Events.Cameras.Device_Approved then
                        Log_Current_Camera_Format;
                     elsif Camera_Event.Event_Type =
                       SDL.Events.Cameras.Device_Denied
                     then
                        Put_Line ("Camera denied!");

                        begin
                           SDL.Message_Boxes.Show_Simple
                             (Title   => "Camera permission denied!",
                              Message => "User denied access to the camera!",
                              Window  => Window,
                              Flags   => SDL.Message_Boxes.Error_Box);
                        exception
                           when SDL.Message_Boxes.Message_Box_Error =>
                              null;
                        end;

                        raise Program_Error with "User denied access to the camera";
                     end if;
                  end;

               when others =>
                  null;
            end case;
         end if;
      end loop;
   end Handle_Events;

   procedure Ensure_Texture_For_Frame is
      Frame_Size        : constant SDL.Sizes := Current_Frame.Size;
      Frame_Format_Name : constant SDL.Video.Pixel_Formats.Pixel_Format_Names :=
        Frame_Format (Current_Frame);
   begin
      if Texture.Is_Null
        or else Texture.Get_Size /= Frame_Size
        or else Texture.Get_Pixel_Format /= Frame_Format_Name
      then
         declare
            Props : constant SDL.Properties.Property_Set := SDL.Properties.Create;
         begin
            Window.Set_Size (To_Positive_Size (Frame_Size));
            Destroy_Texture;

            SDL.Properties.Set_Number
              (Props,
               Texture_Create_Format_Property,
               SDL.Properties.Property_Numbers (Frame_Format_Name));
            SDL.Properties.Set_Number
              (Props,
               Texture_Create_Colourspace_Property,
               SDL.Properties.Property_Numbers (Current_Frame.Get_Colour_Space));
            SDL.Properties.Set_Number
              (Props,
               Texture_Create_Access_Property,
               Texture_Access_Streaming);
            SDL.Properties.Set_Number
              (Props,
               Texture_Create_Width_Property,
               SDL.Properties.Property_Numbers (Frame_Size.Width));
            SDL.Properties.Set_Number
              (Props,
               Texture_Create_Height_Property,
               SDL.Properties.Property_Numbers (Frame_Size.Height));

            SDL.Video.Textures.Makers.Create (Texture, Renderer, Props);
         end;
      end if;
   end Ensure_Texture_For_Frame;

   procedure Render_Frame is
      Time_Now     : constant SDL.Timers.Milliseconds := SDL.Timers.Ticks;
      Timestamp_NS : SDL.Cameras.Timestamp_Nanoseconds := 0;
      Next_Frame   : SDL.Video.Surfaces.Surface := SDL.Video.Surfaces.Null_Surface;
   begin
      Iterate_Count := Iterate_Count + 1;

      if Time_Now - Last_Log_Time >= 60_000 then
         Put_Line
           ("Camera loop iterations in last minute: "
            & Trim (Natural'Image (Iterate_Count)));
         Put_Line
           ("Camera frame rate: " & Format_Float (Float (Frame_Count) / 60.0));

         Iterate_Count := 0;
         Frame_Count := 0;
         Last_Log_Time := Time_Now;
      end if;

      SDL.Video.Renderers.Set_Draw_Colour (Renderer, 0.60, 0.60, 0.60, 1.0);
      SDL.Video.Renderers.Clear (Renderer);

      if not Camera.Is_Null then
         Next_Frame := Camera.Acquire_Frame (Timestamp_NS);
      end if;

      if Next_Frame /= SDL.Video.Surfaces.Null_Surface then
         Frame_Count := Frame_Count + 1;

         if Current_Frame /= SDL.Video.Surfaces.Null_Surface then
            Camera.Release_Frame (Current_Frame);
         end if;

         Current_Frame := Next_Frame;
         Texture_Updated := False;
      end if;

      if Current_Frame /= SDL.Video.Surfaces.Null_Surface then
         Ensure_Texture_For_Frame;

         if not Texture_Updated then
            Texture.Update
              (Pixels => Current_Frame.Pixels,
               Pitch  => SDL.Video.Pixels.Pitches (Current_Frame.Pitch));
            Texture_Updated := True;
         end if;

         declare
            Frame_Size   : constant SDL.Sizes := Current_Frame.Size;
            Output_Size  : constant SDL.Sizes :=
              SDL.Video.Renderers.Get_Output_Size (Renderer);
            Rotation     : constant Long_Float :=
              Long_Float
                (SDL.Properties.Get_Float
                   (SDL.Properties.Reference
                      (SDL.Properties.Property_ID (Current_Frame.Get_Properties)),
                    Surface_Rotation_Property,
                    0.0));
            Source_Rect  : constant SDL.Video.Rectangles.Float_Rectangle :=
              (X      => 0.0,
               Y      => 0.0,
               Width  => Float (Frame_Size.Width),
               Height => Float (Frame_Size.Height));
            Target_Rect  : constant SDL.Video.Rectangles.Float_Rectangle :=
              (X      => Float (Output_Size.Width - Frame_Size.Width) / 2.0,
               Y      => Float (Output_Size.Height - Frame_Size.Height) / 2.0,
               Width  => Float (Frame_Size.Width),
               Height => Float (Frame_Size.Height));
            Rotation_Centre : constant SDL.Video.Rectangles.Float_Point :=
              (X => Float (Frame_Size.Width) / 2.0,
               Y => Float (Frame_Size.Height) / 2.0);
         begin
            SDL.Video.Renderers.Copy_Rotated
              (Self    => Renderer,
               Texture => Texture,
               Source  => Source_Rect,
               Target  => Target_Rect,
               Angle   => Rotation,
               Centre  => Rotation_Centre);
         end;
      end if;

      SDL.Video.Renderers.Present (Renderer);
   end Render_Frame;

   procedure Cleanup is
   begin
      Release_Current_Frame;
      Camera.Close;
      Destroy_Texture;
      SDL.Video.Renderers.Finalize (Renderer);
      SDL.Video.Windows.Finalize (Window);
      SDL.Quit;
   end Cleanup;

   Requested_Name : constant String := Requested_Camera_Name;
begin
   if not SDL.Initialise (SDL.Enable_Video or SDL.Enable_Events or SDL.Enable_Camera) then
      raise Program_Error with "SDL initialization failed: " & SDL.Error.Get;
   end if;

   SDL.Video.Renderers.Makers.Create
     (Window       => Window,
      Rend         => Renderer,
      Title        => "camera_read_and_draw",
      Position     => SDL.Video.Windows.Centered_Window_Position,
      Size         => (Width => 640, Height => 480),
      Flags        => SDL.Video.Windows.Resizable);

   Put_Line ("Using SDL camera driver: " & SDL.Cameras.Current_Driver_Name);

   declare
      Devices  : constant SDL.Cameras.ID_Lists := SDL.Cameras.Get_Cameras;
      Selected : SDL.Cameras.ID := 0;
      Index    : Natural := 0;
   begin
      Put_Line ("Saw" & Natural'Image (Devices'Length) & " camera devices.");

      for Device of Devices loop
         declare
            Name     : constant String := SDL.Cameras.Name (Device);
            Position : constant SDL.Cameras.Positions := SDL.Cameras.Position (Device);
            Prefix   : constant String :=
              (case Position is
                  when SDL.Cameras.Front_Facing =>
                     "[front-facing] ",
                  when SDL.Cameras.Back_Facing =>
                     "[back-facing] ",
                  when others =>
                     "");
         begin
            if Position = SDL.Cameras.Front_Facing and then Front_Camera = 0 then
               Front_Camera := Device;
            elsif Position = SDL.Cameras.Back_Facing and then Back_Camera = 0 then
               Back_Camera := Device;
            end if;

            if Requested_Name /= ""
              and then Equal_Case_Insensitive (Name, Requested_Name)
            then
               Selected := Device;
            end if;

            Put_Line
              ("  - Camera #"
               & Trim (Natural'Image (Index))
               & ": "
               & Prefix
               & Name);
            Print_Camera_Specs (Device);

            Index := Index + 1;
         end;
      end loop;

      if Selected = 0 then
         if Requested_Name /= "" then
            raise Program_Error with "Could not find camera """ & Requested_Name & """";
         elsif Front_Camera /= 0 then
            Selected := Front_Camera;
         elsif Devices'Length > 0 then
            Selected := Devices (Devices'First);
         end if;
      end if;

      if Selected = 0 then
         raise Program_Error with "No cameras available";
      end if;

      Open_Camera (Selected);
   end;

   Last_Log_Time := SDL.Timers.Ticks;

   while Running loop
      Handle_Events;
      exit when not Running;
      Render_Frame;
   end loop;

   Cleanup;
exception
   when Error : others =>
      Cleanup;

      Put_Line
        ("camera_read_and_draw failed: "
         & Ada.Exceptions.Exception_Message (Error));

      declare
         Message : constant String := SDL.Error.Get;
      begin
         if Message /= "" then
            Put_Line ("SDL error: " & Message);
         end if;
      end;

      raise;
end Camera_Read_And_Draw;
