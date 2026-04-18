with Ada.Unchecked_Conversion;
with System;
with System.Storage_Elements;

with SDL.Properties;
with SDL.Raw.Video;

package body SDL.Video.Windows.Manager is
   package Raw renames SDL.Raw.Video;
   package SSE renames System.Storage_Elements;

   use type System.Address;
   use type SDL.Properties.Property_Numbers;

   SDL_PROP_WINDOW_ANDROID_SURFACE_POINTER                 : constant String := "SDL.window.android.surface";
   SDL_PROP_WINDOW_ANDROID_WINDOW_POINTER                  : constant String := "SDL.window.android.window";
   SDL_PROP_WINDOW_COCOA_WINDOW_POINTER                    : constant String := "SDL.window.cocoa.window";
   SDL_PROP_WINDOW_UIKIT_OPENGL_FRAMEBUFFER_NUMBER         : constant String := "SDL.window.uikit.opengl.framebuffer";
   SDL_PROP_WINDOW_UIKIT_OPENGL_RENDERBUFFER_NUMBER        : constant String := "SDL.window.uikit.opengl.renderbuffer";
   SDL_PROP_WINDOW_UIKIT_OPENGL_RESOLVE_FRAMEBUFFER_NUMBER : constant String :=
     "SDL.window.uikit.opengl.resolve_framebuffer";
   SDL_PROP_WINDOW_UIKIT_WINDOW_POINTER                    : constant String := "SDL.window.uikit.window";
   SDL_PROP_WINDOW_WAYLAND_DISPLAY_POINTER                 : constant String := "SDL.window.wayland.display";
   SDL_PROP_WINDOW_WAYLAND_SURFACE_POINTER                 : constant String := "SDL.window.wayland.surface";
   SDL_PROP_WINDOW_WIN32_HDC_POINTER                       : constant String := "SDL.window.win32.hdc";
   SDL_PROP_WINDOW_WIN32_HWND_POINTER                      : constant String := "SDL.window.win32.hwnd";
   SDL_PROP_WINDOW_X11_DISPLAY_POINTER                     : constant String := "SDL.window.x11.display";
   SDL_PROP_WINDOW_X11_WINDOW_NUMBER                       : constant String := "SDL.window.x11.window";

   function To_C_Address is new Ada.Unchecked_Conversion
     (Source => System.Address,
      Target => C_Address);

   function Pointer_Property
     (Props : in SDL.Properties.Property_Set;
      Name  : in String) return C_Address;
   function Pointer_Property
     (Props : in SDL.Properties.Property_Set;
      Name  : in String) return C_Address
   is
   begin
      return To_C_Address (SDL.Properties.Get_Pointer (Props, Name));
   end Pointer_Property;

   function Number_Property
     (Props : in SDL.Properties.Property_Set;
      Name  : in String) return SDL.Properties.Property_Numbers;
   function Number_Property
     (Props : in SDL.Properties.Property_Set;
      Name  : in String) return SDL.Properties.Property_Numbers
   is
   begin
      return SDL.Properties.Get_Number (Props, Name);
   end Number_Property;

   function Number_As_Address
     (Value : in SDL.Properties.Property_Numbers) return C_Address is
   begin
      return To_C_Address
        (SSE.To_Address (SSE.Integer_Address (Value)));
   end Number_As_Address;

   function Linked_Version return SDL.Versions.Version is
      Result : SDL.Versions.Version := SDL.Versions.Compiled;
   begin
      SDL.Versions.Linked_With (Result);
      return Result;
   end Linked_Version;

   function Get_WM_Info
     (Win  : in Window;
      Info : out WM_Info) return Boolean
   is
      Props : constant SDL.Properties.Property_Set :=
        SDL.Properties.Reference
          (SDL.Properties.Property_ID
             (Raw.Get_Window_Properties (Get_Internal (Win))));
   begin
      Info :=
        (Version    => Linked_Version,
         Sub_System => WM_Unknown,
         Info       => (WM => WM_Unknown));

      if Get_Internal (Win) = System.Null_Address or else SDL.Properties.Is_Null (Props) then
         return False;
      end if;

      declare
         HWND            : constant C_Address :=
           Pointer_Property (Props, SDL_PROP_WINDOW_WIN32_HWND_POINTER);
         HDC             : constant C_Address :=
           Pointer_Property (Props, SDL_PROP_WINDOW_WIN32_HDC_POINTER);
         Cocoa_Window    : constant C_Address :=
           Pointer_Property (Props, SDL_PROP_WINDOW_COCOA_WINDOW_POINTER);
         UIK_Window      : constant C_Address :=
           Pointer_Property (Props, SDL_PROP_WINDOW_UIKIT_WINDOW_POINTER);
         X11_Display     : constant C_Address :=
           Pointer_Property (Props, SDL_PROP_WINDOW_X11_DISPLAY_POINTER);
         X11_Window      : constant SDL.Properties.Property_Numbers :=
           Number_Property (Props, SDL_PROP_WINDOW_X11_WINDOW_NUMBER);
         Wayland_Display : constant C_Address :=
           Pointer_Property (Props, SDL_PROP_WINDOW_WAYLAND_DISPLAY_POINTER);
         Wayland_Surface : constant C_Address :=
           Pointer_Property (Props, SDL_PROP_WINDOW_WAYLAND_SURFACE_POINTER);
         Android_Window  : constant C_Address :=
           Pointer_Property (Props, SDL_PROP_WINDOW_ANDROID_WINDOW_POINTER);
         Android_Surface : constant C_Address :=
           Pointer_Property (Props, SDL_PROP_WINDOW_ANDROID_SURFACE_POINTER);
      begin
         if HWND /= null or else HDC /= null then
            Info :=
              (Version    => Linked_Version,
               Sub_System => WM_Windows,
               Info       =>
                 (WM   => WM_Windows,
                  HWND => Windows.HWNDs (HWND),
                  HDC  => Windows.HDCs (HDC)));
            return True;
         end if;

         if Cocoa_Window /= null then
            Info :=
              (Version    => Linked_Version,
               Sub_System => WM_Cocoa,
               Info       =>
                 (WM           => WM_Cocoa,
                  Cocoa_Window => Cocoa.NS_Window (Cocoa_Window)));
            return True;
         end if;

         if UIK_Window /= null then
            Info :=
              (Version    => Linked_Version,
               Sub_System => WM_UI_Kit,
               Info       =>
                 (WM                        => WM_UI_Kit,
                  UIK_Window                => UI_Kit.Window (UIK_Window),
                  UIK_Frame_Buffer          =>
                    UI_Kit.Window
                      (Number_As_Address
                         (Number_Property
                            (Props,
                             SDL_PROP_WINDOW_UIKIT_OPENGL_FRAMEBUFFER_NUMBER))),
                  UIK_Colour_Buffer         =>
                    UI_Kit.Window
                      (Number_As_Address
                         (Number_Property
                            (Props,
                             SDL_PROP_WINDOW_UIKIT_OPENGL_RENDERBUFFER_NUMBER))),
                  UIK_Resolve_Frame_Buffer  =>
                    UI_Kit.Window
                      (Number_As_Address
                         (Number_Property
                            (Props,
                             SDL_PROP_WINDOW_UIKIT_OPENGL_RESOLVE_FRAMEBUFFER_NUMBER)))));
            return True;
         end if;

         if X11_Display /= null or else X11_Window /= 0 then
            Info :=
              (Version    => Linked_Version,
               Sub_System => WM_X11,
               Info       =>
                 (WM          => WM_X11,
                  X11_Display => X11.Display (X11_Display),
                  X11_Window  => X11.Window (Interfaces.Unsigned_32 (X11_Window))));
            return True;
         end if;

         if Wayland_Display /= null or else Wayland_Surface /= null then
            Info :=
              (Version    => Linked_Version,
               Sub_System => WM_Wayland,
               Info       =>
                 (WM                    => WM_Wayland,
                  Wayland_Display       => Wayland.Display (Wayland_Display),
                  Wayland_Surface       => Wayland.Surface (Wayland_Surface),
                  Wayland_Shell_Surface => Wayland.Shell_Surface'(null)));
            return True;
         end if;

         if Android_Window /= null or else Android_Surface /= null then
            Info :=
              (Version    => Linked_Version,
               Sub_System => WM_Android,
               Info       =>
                 (WM              => WM_Android,
                  Android_Window  => Android.Native_Window (Android_Window),
                  Android_Surface => Android.EGL_Surface (Android_Surface)));
            return True;
         end if;
      end;

      return False;
   end Get_WM_Info;
end SDL.Video.Windows.Manager;
