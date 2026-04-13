with Ada.Exceptions;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Unchecked_Conversion;
with System;

with Interfaces;

with SDL;
with SDL.Clipboard;
with SDL.Error;
with SDL.Events.Events;
with SDL.Properties;
with SDL.Timers;
with SDL.Video.Displays;
with SDL.Video.Pixel_Formats;
with SDL.Video.Pixels;
with SDL.Video.Rectangles;
with SDL.Video.Renderers;
with SDL.Video.Renderers.Makers;
with SDL.Video.Surfaces;
with SDL.Video.Textures;
with SDL.Video.Textures.Makers;
with SDL.Video.Windows;
with SDL.Video.Windows.Makers;

procedure Video_Smoke is
   use type SDL.Dimension;
   use type SDL.Init_Flags;
   use type SDL.Properties.Property_ID;
   use type SDL.Sizes;
   use type SDL.Timers.Milliseconds;
   use type SDL.Video.Displays.Display_Indices;
   use type SDL.Video.Pixel_Formats.Pixel_Format_Names;
   use type SDL.Video.Rectangles.Rectangle;
   use type SDL.Video.Windows.ID;
   use type SDL.Video.Windows.Progress_States;
   use type SDL.Video.Windows.Window_Surface_V_Sync_Intervals;

   Width          : constant SDL.Positive_Dimension := 160;
   Height         : constant SDL.Positive_Dimension := 144;
   Width_Natural  : constant Natural := Natural (Width);
   Height_Natural : constant Natural := Natural (Height);

   Window         : SDL.Video.Windows.Window;
   Surface_Window : SDL.Video.Windows.Window;
   Popup_Window   : SDL.Video.Windows.Window;
   Renderer       : SDL.Video.Renderers.Renderer;
   Texture        : SDL.Video.Textures.Texture;

   Window_Created         : Boolean := False;
   Surface_Window_Created : Boolean := False;
   Popup_Window_Created   : Boolean := False;
   Renderer_Created       : Boolean := False;
   Texture_Created        : Boolean := False;
   Texture_Locked         : Boolean := False;

   procedure Lock_Texture is new SDL.Video.Textures.Lock
     (Pixel_Pointer_Type => SDL.Video.Pixels.ARGB_8888_Access.Pointer);

   type Pixel_Buffer is
     array (Natural range 0 .. (Width_Natural * Height_Natural) - 1) of
       aliased SDL.Video.Pixels.ARGB_8888
     with Convention => C;

   type Pixel_Buffer_Access is access all Pixel_Buffer;
   pragma No_Strict_Aliasing (Pixel_Buffer_Access);

   function To_Pixel_Buffer_Access is new Ada.Unchecked_Conversion
     (Source => SDL.Video.Pixels.ARGB_8888_Access.Pointer,
      Target => Pixel_Buffer_Access);

   procedure Require (Condition : in Boolean; Message : in String) is
   begin
      if not Condition then
         raise Program_Error with Message;
      end if;
   end Require;

   function Contains
     (Items  : in SDL.Video.Windows.ID_Lists;
      Value  : in SDL.Video.Windows.ID) return Boolean is
   begin
      for Item of Items loop
         if Item = Value then
            return True;
         end if;
      end loop;

      return False;
   end Contains;

   function Normal_Hit_Test
     (Win       : in System.Address;
      Area      : access constant SDL.Video.Rectangles.Point;
      User_Data : in System.Address) return SDL.Video.Windows.Hit_Test_Results
   with Convention => C;

   function Normal_Hit_Test
     (Win       : in System.Address;
      Area      : access constant SDL.Video.Rectangles.Point;
      User_Data : in System.Address) return SDL.Video.Windows.Hit_Test_Results is
   begin
      pragma Unreferenced (Win, Area, User_Data);
      return SDL.Video.Windows.Normal_Hit;
   end Normal_Hit_Test;
begin
   if not SDL.Initialise (SDL.Enable_Video or SDL.Enable_Events) then
      raise Program_Error with "SDL initialization failed: " & SDL.Error.Get;
   end if;

   SDL.Video.Windows.Makers.Create
     (Win    => Window,
      Title  => "sdl3ada video smoke",
      X      => SDL.Video.Windows.Centered_Window_Position,
      Y      => SDL.Video.Windows.Centered_Window_Position,
      Width  => SDL.Positive_Dimension (Width_Natural * 2),
      Height => SDL.Positive_Dimension (Height_Natural * 2));
   Window_Created := True;

   declare
      Props : constant SDL.Properties.Property_Set := SDL.Properties.Create;
   begin
      SDL.Properties.Set_String (Props, "SDL.window.create.title", "sdl3ada surface smoke");
      SDL.Properties.Set_Number
        (Props,
         "SDL.window.create.width",
         SDL.Properties.Property_Numbers (96));
      SDL.Properties.Set_Number
        (Props,
         "SDL.window.create.height",
         SDL.Properties.Property_Numbers (72));
      SDL.Properties.Set_Number
        (Props,
         "SDL.window.create.x",
         SDL.Properties.Property_Numbers (0));
      SDL.Properties.Set_Number
        (Props,
         "SDL.window.create.y",
         SDL.Properties.Property_Numbers (0));
      SDL.Properties.Set_Boolean (Props, "SDL.window.create.hidden", True);

      SDL.Video.Windows.Makers.Create
        (Win        => Surface_Window,
         Properties => Props);
   end;
   Surface_Window_Created := True;

   SDL.Video.Renderers.Makers.Create
     (Rend   => Renderer,
      Window => Window,
      Flags  => SDL.Video.Renderers.Accelerated);
   Renderer_Created := True;

   SDL.Video.Textures.Makers.Create
     (Tex      => Texture,
      Renderer => Renderer,
      Format   => SDL.Video.Pixel_Formats.Pixel_Format_RGB_888,
      Kind     => SDL.Video.Textures.Streaming,
      Size     => (Width => Width, Height => Height));
   Texture_Created := True;

   declare
      Pixels : SDL.Video.Pixels.ARGB_8888_Access.Pointer;
      Buffer : Pixel_Buffer_Access;
      Index  : Natural := 0;
   begin
      Lock_Texture (Texture, Pixels);
      Texture_Locked := True;

      Buffer := To_Pixel_Buffer_Access (Pixels);

      --  SDL_LockTexture exposes write-only memory, so initialize every pixel.
      for Y in 0 .. Height_Natural - 1 loop
         for X in 0 .. Width_Natural - 1 loop
            Buffer (Index) :=
              (Alpha => 16#FF#,
               Red   => Interfaces.Unsigned_8 ((X * 255) / (Width_Natural - 1)),
               Green => Interfaces.Unsigned_8 ((Y * 255) / (Height_Natural - 1)),
               Blue  => Interfaces.Unsigned_8 (((X + Y) * 255) / (Width_Natural + Height_Natural - 2)));
            Index := Index + 1;
         end loop;
      end loop;
   end;

   SDL.Video.Textures.Unlock (Texture);
   Texture_Locked := False;

   SDL.Video.Renderers.Clear (Renderer);
   SDL.Video.Renderers.Copy (Renderer, Texture);
   SDL.Video.Renderers.Present (Renderer);
   Window.Set_Title ("sdl3ada video smoke (presented frame)");

   declare
      Props      : constant SDL.Properties.Property_Set :=
        SDL.Properties.Reference (Window.Get_Properties);
      Position   : constant SDL.Coordinates := Window.Get_Position;
      Size       : constant SDL.Sizes := Window.Get_Size;
      Pixel_Size : constant SDL.Sizes := Window.Get_Size_In_Pixels;
      Safe_Area  : constant SDL.Video.Rectangles.Rectangle :=
        Window.Get_Safe_Area;
      Display    : constant SDL.Video.Displays.Display_Indices :=
        Window.Get_Display;
      Format     : constant SDL.Video.Pixel_Formats.Pixel_Format_Names :=
        Window.Get_Pixel_Format;
      Ratios     : SDL.Video.Windows.Aspect_Ratios;
      Mode       : SDL.Video.Displays.Mode;
      Readback   : SDL.Video.Displays.Mode;
      Mouse_Rect : SDL.Video.Rectangles.Rectangle;
   begin
      Require (Window.Get_ID /= 0, "Expected valid window ID");
      Require
        (Window.Get_Title = "sdl3ada video smoke (presented frame)",
         "Window title round-trip mismatch");
      Require
        (SDL.Properties.Get_ID (Props) /= SDL.Properties.Null_Property_ID,
         "Expected window properties");
      Require (Display >= 1, "Expected a valid display index");
      Require (Size.Width > 0 and then Size.Height > 0, "Expected non-zero window size");
      Require
        (Pixel_Size.Width > 0 and then Pixel_Size.Height > 0,
         "Expected non-zero window pixel size");
      Require (Window.Get_Pixel_Density > 0.0, "Expected positive pixel density");
      Require (Window.Get_Display_Scale > 0.0, "Expected positive display scale");
      Require
        (Safe_Area.Width > 0 and then Safe_Area.Height > 0,
         "Expected non-zero safe area");
      Require
        (Format /= SDL.Video.Pixel_Formats.Pixel_Format_Unknown,
         "Expected known window pixel format");
      Require (SDL.Video.Windows.Get_Grabbed.Is_Null, "Expected no grabbed window");

      Window.Set_Position (Position);
      Window.Set_Size
        (Width  => SDL.Positive_Dimension (Size.Width),
         Height => SDL.Positive_Dimension (Size.Height));

      Window.Set_Minimum_Size ((Width => 64, Height => 48));
      Require
        (Window.Get_Minimum_Size = (Width => 64, Height => 48),
         "Window minimum-size round-trip mismatch");

      Window.Set_Maximum_Size ((Width => 640, Height => 480));
      Require
        (Window.Get_Maximum_Size = (Width => 640, Height => 480),
         "Window maximum-size round-trip mismatch");

      Window.Set_Aspect_Ratio (Minimum => 1.0, Maximum => 2.0);
      Ratios := Window.Get_Aspect_Ratio;
      Require
        (abs (Ratios.Minimum - 1.0) < 0.01
           and then abs (Ratios.Maximum - 2.0) < 0.01,
         "Window aspect-ratio round-trip mismatch");
      Window.Set_Aspect_Ratio (Minimum => 0.0, Maximum => 0.0);

      if SDL.Video.Displays.Display_Mode (Display, 0, Mode) then
         begin
            Window.Set_Fullscreen_Mode (Mode);
            Require
              (Window.Get_Fullscreen_Mode (Readback),
               "Expected fullscreen mode after set");
            Require
              (Readback.Width = Mode.Width and then Readback.Height = Mode.Height,
               "Fullscreen mode readback mismatch");
            Window.Reset_Fullscreen_Mode;
            Require
              (not Window.Get_Fullscreen_Mode (Readback),
               "Expected reset fullscreen mode to clear explicit mode");
         exception
            when SDL.Video.Windows.Window_Error =>
               Put_Line ("Window fullscreen-mode probe skipped: " & SDL.Error.Get);
               SDL.Error.Clear;
         end;
      end if;

      begin
         Window.Set_Bordered (True);
         Window.Set_Resizable (True);
         Window.Set_Always_On_Top (False);
         Window.Set_Fill_Document (False);
         Window.Set_Fullscreen (False);
         Window.Sync;
      exception
         when SDL.Video.Windows.Window_Error =>
            Put_Line ("Window state probe skipped: " & SDL.Error.Get);
            SDL.Error.Clear;
      end;

      begin
         Window.Set_Mouse_Rect ((X => 0, Y => 0, Width => 32, Height => 24));
         Require
           (Window.Get_Mouse_Rect (Mouse_Rect),
            "Expected mouse confinement rectangle");
         Require
           (Mouse_Rect = (X => 0, Y => 0, Width => 32, Height => 24),
            "Mouse confinement rectangle mismatch");
         Window.Clear_Mouse_Rect;
         Require
           (not Window.Get_Mouse_Rect (Mouse_Rect),
            "Expected cleared mouse confinement rectangle");
      exception
         when SDL.Video.Windows.Window_Error =>
            Put_Line ("Window mouse-rect probe skipped: " & SDL.Error.Get);
            SDL.Error.Clear;
      end;

      begin
         Window.Set_Opacity (0.85);
         Require (Window.Get_Opacity > 0.0, "Expected positive window opacity");
         Window.Set_Opacity (1.0);
      exception
         when SDL.Video.Windows.Window_Error =>
            Put_Line ("Window opacity probe skipped: " & SDL.Error.Get);
            SDL.Error.Clear;
      end;
   end;

   begin
      Window.Set_Hit_Test (Normal_Hit_Test'Unrestricted_Access);
      Window.Disable_Hit_Test;
   exception
      when SDL.Video.Windows.Window_Error =>
         Put_Line ("Window hit-test probe skipped: " & SDL.Error.Get);
         SDL.Error.Clear;
   end;

   begin
      Window.Set_Progress_State (SDL.Video.Windows.Normal_Progress);
      Window.Set_Progress_Value (0.5);
      Require
        (Window.Get_Progress_State = SDL.Video.Windows.Normal_Progress,
         "Unexpected window progress state");
      Require (Window.Get_Progress_Value >= 0.0, "Unexpected window progress value");
      Window.Set_Progress_State (SDL.Video.Windows.No_Progress);
   exception
      when SDL.Video.Windows.Window_Error =>
         Put_Line ("Window progress probe skipped: " & SDL.Error.Get);
         SDL.Error.Clear;
   end;

   begin
      Window.Flash (SDL.Video.Windows.Flash_Cancel);
   exception
      when SDL.Video.Windows.Window_Error =>
         Put_Line ("Window flash probe skipped: " & SDL.Error.Get);
         SDL.Error.Clear;
   end;

   begin
      Window.Show_System_Menu (0, 0);
   exception
      when SDL.Video.Windows.Window_Error =>
         Put_Line ("Window system-menu probe skipped: " & SDL.Error.Get);
         SDL.Error.Clear;
   end;

   begin
      SDL.Video.Windows.Makers.Create_Popup
        (Win    => Popup_Window,
         Parent => Window,
         X      => 4,
         Y      => 4,
         Width  => 32,
         Height => 24,
         Flags  => SDL.Video.Windows.Tool_Tip);
      Popup_Window_Created := True;

      Require (not Popup_Window.Is_Null, "Expected popup window");
      Require (not Popup_Window.Get_Parent.Is_Null, "Expected popup parent");
      Popup_Window.Set_Focusable (False);
   exception
      when SDL.Video.Windows.Window_Error =>
         Put_Line ("Popup-window probe skipped: " & SDL.Error.Get);
         SDL.Error.Clear;
   end;

   declare
      Window_IDs : constant SDL.Video.Windows.ID_Lists :=
        SDL.Video.Windows.Get_Window_IDs;
   begin
      Require
        (Window_IDs'Length >= 2,
         "Expected at least two live SDL windows");
      Require
        (Contains (Window_IDs, Window.Get_ID),
         "Expected primary window ID in SDL window enumeration");
      Require
        (Contains (Window_IDs, Surface_Window.Get_ID),
         "Expected surface window ID in SDL window enumeration");

      if Popup_Window_Created then
         Require
           (Contains (Window_IDs, Popup_Window.Get_ID),
            "Expected popup window ID in SDL window enumeration");
      end if;
   end;

   begin
      Surface_Window.Show;
      Surface_Window.Hide;
      Surface_Window.Show;
      Surface_Window.Sync;
      Surface_Window.Set_Focusable (False);
      Surface_Window.Set_Modal (False);
      Surface_Window.Set_Parent (Window);
   exception
      when SDL.Video.Windows.Window_Error =>
         Put_Line ("Window parenting/state probe skipped: " & SDL.Error.Get);
         SDL.Error.Clear;
   end;

   begin
      declare
         Surface_Props : constant SDL.Properties.Property_Set :=
           SDL.Properties.Reference (Surface_Window.Get_Properties);
         Surface      : SDL.Video.Surfaces.Surface := Surface_Window.Get_Surface;
         Rectangles   : SDL.Video.Rectangles.Rectangle_Arrays (0 .. 0) :=
           (0 => SDL.Video.Rectangles.Rectangle'
              (X => 0, Y => 0, Width => 1, Height => 1));
      begin
         Require
           (SDL.Properties.Get_ID (Surface_Props) /= SDL.Properties.Null_Property_ID,
            "Expected surface-window properties");
         Require (Surface_Window.Has_Surface, "Expected surface-backed window");
         pragma Unreferenced (Surface);

         begin
            Surface_Window.Set_Surface_V_Sync
              (SDL.Video.Windows.Window_Surface_V_Sync_Disabled);
            Require
              (Surface_Window.Get_Surface_V_Sync =
                 SDL.Video.Windows.Window_Surface_V_Sync_Disabled,
               "Unexpected surface vsync value");
         exception
            when SDL.Video.Windows.Window_Error =>
               Put_Line ("Window surface-vsync probe skipped: " & SDL.Error.Get);
               SDL.Error.Clear;
         end;

         Surface_Window.Update_Surface;
         Surface_Window.Update_Surface_Rectangle
           ((X => 0, Y => 0, Width => 1, Height => 1));
         Surface_Window.Update_Surface_Rectangles (Rectangles);
         Surface_Window.Destroy_Surface;
      end;
   exception
      when SDL.Video.Windows.Window_Error =>
         Put_Line ("Window surface probe skipped: " & SDL.Error.Get);
         SDL.Error.Clear;
   end;

   begin
      SDL.Clipboard.Set ("sdl3ada video smoke");

      if SDL.Clipboard.Is_Empty then
         raise Program_Error with "Clipboard reported empty after set";
      end if;

      if SDL.Clipboard.Get /= "sdl3ada video smoke" then
         raise Program_Error with "Clipboard round-trip mismatch";
      end if;
   exception
      when SDL.Clipboard.Clipboard_Error =>
         Put_Line ("Clipboard probe skipped: " & SDL.Error.Get);
         SDL.Error.Clear;
   end;

   declare
      Event      : SDL.Events.Events.Events;
      Start_Time : constant SDL.Timers.Milliseconds := SDL.Timers.Ticks;
   begin
      while SDL.Timers.Ticks - Start_Time < SDL.Timers.Milliseconds (250) loop
         while SDL.Events.Events.Poll (Event) loop
            null;
         end loop;

         SDL.Timers.Wait_Delay (10);
      end loop;
   end;

   if Popup_Window_Created then
      SDL.Video.Windows.Finalize (Popup_Window);
   end if;

   if Texture_Created then
      SDL.Video.Textures.Finalize (Texture);
   end if;

   if Renderer_Created then
      SDL.Video.Renderers.Finalize (Renderer);
   end if;

   if Surface_Window_Created then
      SDL.Video.Windows.Finalize (Surface_Window);
   end if;

   if Window_Created then
      SDL.Video.Windows.Finalize (Window);
   end if;

   SDL.Quit;

   Put_Line ("Video smoke completed successfully.");
exception
   when Error : others =>
      if Texture_Locked then
         SDL.Video.Textures.Unlock (Texture);
      end if;

      if Popup_Window_Created then
         SDL.Video.Windows.Finalize (Popup_Window);
      end if;

      if Texture_Created then
         SDL.Video.Textures.Finalize (Texture);
      end if;

      if Renderer_Created then
         SDL.Video.Renderers.Finalize (Renderer);
      end if;

      if Surface_Window_Created then
         SDL.Video.Windows.Finalize (Surface_Window);
      end if;

      if Window_Created then
         SDL.Video.Windows.Finalize (Window);
      end if;

      SDL.Quit;

      Put_Line ("Video smoke failed: " & Ada.Exceptions.Exception_Message (Error));

      declare
         Message : constant String := SDL.Error.Get;
      begin
         if Message /= "" then
            Put_Line ("SDL error: " & Message);
         end if;
      end;

      raise;
end Video_Smoke;
