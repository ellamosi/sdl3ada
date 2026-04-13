with Ada.Exceptions;
with Ada.Text_IO; use Ada.Text_IO;
with System;

with SDL;
with SDL.Error;
with SDL.Video;
with SDL.Video.GL;
with SDL.Video.Metal;
with SDL.Video.Vulkan;
with SDL.Video.Windows;
with SDL.Video.Windows.Makers;
with SDL.Video.Windows.Manager;

procedure Advanced_Video_Smoke is
   use type System.Address;
   use type SDL.Dimension;
   use type SDL.Video.GL.Swap_Intervals;
   use type SDL.Video.Windows.Window_Flags;
   use type SDL.Video.Windows.Manager.WM_Types;

   package Vulkan is new SDL.Video.Vulkan
     (Instance_Address_Type => System.Address,
      Instance_Null         => System.Null_Address,
      Surface_Type          => System.Address);

   type GL_Function is access procedure with Convention => C;

   function Get_GL_Clear is new SDL.Video.GL.Get_Subprogram
     (Subprogram_Name       => "glClear",
      Access_To_Sub_Program => GL_Function);

   procedure Require (Condition : in Boolean; Message : in String) is
   begin
      if not Condition then
         raise Program_Error with Message;
      end if;
   end Require;

   function Has_Native_WM_Info (Driver : in String) return Boolean is
   begin
      return Driver = "windows"
        or else Driver = "x11"
        or else Driver = "cocoa"
        or else Driver = "uikit"
        or else Driver = "wayland"
        or else Driver = "android";
   end Has_Native_WM_Info;

   Manager_Window : SDL.Video.Windows.Window;
   Metal_Window   : SDL.Video.Windows.Window;
   Metal_View     : SDL.Video.Metal.View;
   GL_Window      : SDL.Video.Windows.Window;
   GL_Context     : SDL.Video.GL.Contexts;
begin
   if not SDL.Initialise (SDL.Enable_Video) then
      raise Program_Error with "SDL initialization failed: " & SDL.Error.Get;
   end if;

   SDL.Video.GL.Reset_Attributes;
   SDL.Video.GL.Set_Attribute_Callbacks;

   SDL.Video.Windows.Makers.Create
     (Win    => Manager_Window,
      Title  => "advanced-video-smoke",
      X      => 0,
      Y      => 0,
      Width  => 64,
      Height => 64,
      Flags  => SDL.Video.Windows.Hidden);

   declare
      Driver : constant String := SDL.Video.Current_Driver_Name;
      Info   : SDL.Video.Windows.Manager.WM_Info;
      EGL_Proc : constant System.Address :=
        SDL.Video.GL.Get_Proc_Address ("eglGetDisplay");
      EGL_Display : constant System.Address :=
        SDL.Video.GL.Get_Current_Display;
      EGL_Config : constant System.Address :=
        SDL.Video.GL.Get_Current_Config;
      EGL_Surface : constant System.Address :=
        SDL.Video.GL.Get_Window_Surface (Manager_Window);
   begin
      if Has_Native_WM_Info (Driver) then
         Require
           (SDL.Video.Windows.Manager.Get_WM_Info (Manager_Window, Info),
            "Expected window-manager info on driver " & Driver);
         Require
           (Info.Sub_System /= SDL.Video.Windows.Manager.WM_Unknown,
            "Expected concrete window-manager subsystem");
      else
         Put_Line
           ("Skipping strict window-manager assertions on video driver """
            & Driver & """");
      end if;

      if Driver = "" or else Driver = "dummy" or else Driver = "offscreen" then
         Require
           (EGL_Display = System.Null_Address,
            "Expected no current EGL display on headless video driver");
         Require
           (EGL_Config = System.Null_Address,
            "Expected no current EGL config on headless video driver");
         Require
           (EGL_Surface = System.Null_Address,
            "Expected no window EGL surface on headless video driver");
      end if;

      pragma Unreferenced (EGL_Proc);
   end;

   declare
      Driver : constant String := SDL.Video.Current_Driver_Name;
   begin
      if Driver = "cocoa" or else Driver = "uikit" then
         SDL.Video.Windows.Makers.Create
           (Win    => Metal_Window,
            Title  => "advanced-video-metal-smoke",
            X      => 0,
            Y      => 0,
            Width  => 64,
            Height => 64,
            Flags  => SDL.Video.Windows.Hidden or SDL.Video.Windows.Metal);

         SDL.Video.Metal.Create (Metal_View, Metal_Window);

         Require
           (SDL.Video.Metal.Get_Layer (Metal_View) /= System.Null_Address,
            "Expected Metal layer");

         SDL.Video.Metal.Destroy (Metal_View);
      else
         Put_Line
           ("Skipping Metal runtime validation on video driver """ & Driver
            & """");
      end if;
   end;

   declare
      Driver : constant String := SDL.Video.Current_Driver_Name;
   begin
      if Driver = "" or else Driver = "dummy" or else Driver = "offscreen" then
         Put_Line
           ("Skipping OpenGL runtime validation on video driver """ & Driver
            & """");
      else
         SDL.Video.GL.Set_Core_Context_Profile (3, 2);
         SDL.Video.GL.Set_Double_Buffer (True);

         SDL.Video.Windows.Makers.Create
           (Win    => GL_Window,
            Title  => "advanced-video-gl-smoke",
            X      => 0,
            Y      => 0,
            Width  => 64,
            Height => 64,
            Flags  => SDL.Video.Windows.Hidden or SDL.Video.Windows.OpenGL);

         SDL.Video.GL.Create (GL_Context, GL_Window);
         SDL.Video.GL.Set_Current (GL_Context, GL_Window);

         declare
            Current : constant SDL.Video.GL.Contexts := SDL.Video.GL.Get_Current;
            Width   : SDL.Natural_Dimension := 0;
            Height  : SDL.Natural_Dimension := 0;
            Proc    : constant GL_Function := Get_GL_Clear;
         begin
            pragma Unreferenced (Current);

            SDL.Video.GL.Get_Drawable_Size (GL_Window, Width, Height);

            Require (Width > 0 and then Height > 0, "Expected non-zero drawable size");

            SDL.Video.GL.Set_Swap_Interval (SDL.Video.GL.Not_Synchronised);

            Require
              (SDL.Video.GL.Get_Swap_Interval = SDL.Video.GL.Not_Synchronised,
               "Unexpected OpenGL swap interval");

            Require (Proc /= null, "Expected OpenGL procedure lookup to succeed");
         end;
      end if;
   end;

   declare
      Loaded : Boolean := False;
   begin
      begin
         Vulkan.Load_Library;
         Loaded := True;

         declare
            Extensions        : constant Vulkan.Extension_Name_Arrays :=
              Vulkan.Get_Instance_Extensions;
            Window_Extensions : constant Vulkan.Extension_Name_Arrays :=
              Vulkan.Get_Instance_Extensions (Manager_Window);
         begin
            Require
              (Vulkan.Get_Instance_Procedure_Address /= System.Null_Address,
               "Expected Vulkan instance procedure address");
            Require (Extensions'Length >= 1, "Expected at least one Vulkan instance extension");
            Require
              (Window_Extensions'Length = Extensions'Length,
               "Expected windowed Vulkan extension helper to match parameterless SDL3 path");
         end;
      exception
         when E : Vulkan.SDL_Vulkan_Error =>
            Put_Line
              ("Skipping Vulkan runtime validation: "
               & Ada.Exceptions.Exception_Message (E));
      end;

      if Loaded then
         Vulkan.Unload_Library;
      end if;
   end;
end Advanced_Video_Smoke;
