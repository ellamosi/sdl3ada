with Ada.Unchecked_Conversion;
with System;

with SDL.Error;
with SDL.Raw.Render;
with SDL.Video.Surfaces.Internal;
with SDL.Video.Windows.Makers;

package body SDL.Video.Renderers.Makers is
   package Raw renames SDL.Raw.Render;
   package Surface_Internal renames SDL.Video.Surfaces.Internal;

   use type System.Address;

   function To_Address is new Ada.Unchecked_Conversion
     (Source => SDL.Video.Surfaces.Internal_Surface_Pointer,
      Target => System.Address);

   function To_Address is new Ada.Unchecked_Conversion
     (Source => SDL.GPU.Device_Handle,
      Target => System.Address);

   function Resolve_Name
     (Driver : in SDL.Video.Renderers.Driver_Indices;
      Flags  : in SDL.Video.Renderers.Renderer_Flags) return String;

   function Resolve_Name
     (Driver : in SDL.Video.Renderers.Driver_Indices;
      Flags  : in SDL.Video.Renderers.Renderer_Flags) return String
   is
   begin
      if Driver >= 0 then
         declare
            Name : constant String := SDL.Video.Renderers.Driver_Name (Driver);
         begin
            if Name = "" then
               raise Renderer_Error with "Invalid renderer driver index";
            end if;

            return Name;
         end;
      end if;

      if (Flags and SDL.Video.Renderers.Software) /= 0 then
         return "software";
      end if;

      return "";
   end Resolve_Name;

   procedure Adopt
     (Rend     : in out SDL.Video.Renderers.Renderer;
      Internal : in System.Address);

   procedure Adopt
     (Rend     : in out SDL.Video.Renderers.Renderer;
      Internal : in System.Address)
   is
   begin
      if Internal = System.Null_Address then
         raise Renderer_Error with SDL.Error.Get;
      end if;

      SDL.Video.Renderers.Finalize (Rend);
      Rend.Internal := Internal;
      Rend.Owns := True;
   end Adopt;

   procedure Create
     (Rend   : in out SDL.Video.Renderers.Renderer;
      Device : in SDL.GPU.Device;
      Window : in out SDL.Video.Windows.Window)
   is
      Internal_Window : constant System.Address :=
        SDL.Video.Windows.Get_Internal (Window);
      Internal : System.Address := System.Null_Address;
   begin
      if SDL.GPU.Is_Null (Device) then
         raise Renderer_Error with "Invalid GPU device";
      end if;

      if Internal_Window = System.Null_Address then
         raise Renderer_Error with "Invalid window";
      end if;

      Internal :=
        Raw.Create_GPU_Renderer
          (To_Address (SDL.GPU.Get_Handle (Device)), Internal_Window);
      Adopt (Rend, Internal);
   end Create;

   procedure Create
     (Rend   : in out SDL.Video.Renderers.Renderer;
      Window : in out SDL.Video.Windows.Window;
      Driver : in SDL.Video.Renderers.Driver_Indices;
      Flags  : in SDL.Video.Renderers.Renderer_Flags :=
        SDL.Video.Renderers.Default_Renderer_Flags)
   is
      Props    : constant SDL.Properties.Property_Set := SDL.Properties.Create;
      Name     : constant String := Resolve_Name (Driver, Flags);
      Internal : System.Address := System.Null_Address;
   begin
      if SDL.Video.Windows.Get_Internal (Window) = System.Null_Address then
         raise Renderer_Error with "Invalid window";
      end if;

      SDL.Properties.Set_Pointer
        (Props,
         Create_Window_Property,
         SDL.Video.Windows.Get_Internal (Window));

      if Name /= "" then
         SDL.Properties.Set_String
           (Props, Create_Name_Property, Name);
      end if;

      if (Flags and SDL.Video.Renderers.Present_V_Sync) /= 0 then
         SDL.Properties.Set_Number
           (Props, Create_Present_V_Sync_Property, 1);
      end if;

      Internal :=
        Raw.Create_Renderer_With_Properties (SDL.Properties.Get_ID (Props));

      Adopt (Rend, Internal);
   end Create;

   procedure Create
     (Rend   : in out SDL.Video.Renderers.Renderer;
      Window : in out SDL.Video.Windows.Window;
      Flags  : in SDL.Video.Renderers.Renderer_Flags :=
        SDL.Video.Renderers.Default_Renderer_Flags)
   is
   begin
      Create
        (Rend   => Rend,
         Window => Window,
         Driver => -1,
         Flags  => Flags);
   end Create;

   procedure Create
     (Rend    : in out SDL.Video.Renderers.Renderer;
      Surface : in SDL.Video.Surfaces.Surface)
   is
      Internal : constant System.Address :=
        Raw.Create_Software_Renderer
          (To_Address (Surface_Internal.Get_Internal (Surface)));
   begin
      Adopt (Rend, Internal);
   end Create;

   procedure Create
     (Rend       : in out SDL.Video.Renderers.Renderer;
      Properties : in SDL.Properties.Property_Set)
   is
      Internal : constant System.Address :=
        Raw.Create_Renderer_With_Properties (SDL.Properties.Get_ID (Properties));
   begin
      Adopt (Rend, Internal);
   end Create;

   procedure Create
     (Window   : in out SDL.Video.Windows.Window;
      Rend     : in out SDL.Video.Renderers.Renderer;
      Title    : in String;
      Position : in SDL.Natural_Coordinates;
      Size     : in SDL.Positive_Sizes;
      Flags    : in SDL.Video.Windows.Window_Flags :=
        SDL.Video.Windows.Windowed;
      Driver   : in SDL.Video.Renderers.Driver_Indices := -1;
      Render_Flags : in SDL.Video.Renderers.Renderer_Flags :=
        SDL.Video.Renderers.Default_Renderer_Flags)
   is
   begin
      SDL.Video.Windows.Makers.Create
        (Win      => Window,
         Title    => Title,
         Position => Position,
         Size     => Size,
         Flags    => Flags);

      begin
         Create
           (Rend   => Rend,
            Window => Window,
            Driver => Driver,
            Flags  => Render_Flags);
      exception
         when others =>
            SDL.Video.Windows.Finalize (Window);
            raise;
      end;
   end Create;

   procedure Create
     (Window   : in out SDL.Video.Windows.Window;
      Rend     : in out SDL.Video.Renderers.Renderer;
      Title    : in String;
      X        : in SDL.Natural_Coordinate;
      Y        : in SDL.Natural_Coordinate;
      Width    : in SDL.Positive_Dimension;
      Height   : in SDL.Positive_Dimension;
      Flags    : in SDL.Video.Windows.Window_Flags :=
        SDL.Video.Windows.Windowed;
      Driver   : in SDL.Video.Renderers.Driver_Indices := -1;
      Render_Flags : in SDL.Video.Renderers.Renderer_Flags :=
        SDL.Video.Renderers.Default_Renderer_Flags)
   is
   begin
      Create
        (Window       => Window,
         Rend         => Rend,
         Title        => Title,
         Position     => (X => X, Y => Y),
         Size         => (Width => Width, Height => Height),
         Flags        => Flags,
         Driver       => Driver,
         Render_Flags => Render_Flags);
   end Create;
end SDL.Video.Renderers.Makers;
