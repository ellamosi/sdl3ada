with SDL.GPU;
with SDL.Properties;
with SDL.Video.Surfaces;
with SDL.Video.Windows;

package SDL.Video.Renderers.Makers is
   Create_Name_Property : constant String := "SDL.renderer.create.name";
   Create_Present_V_Sync_Property : constant String :=
     "SDL.renderer.create.present_vsync";
   Create_Surface_Property : constant String := "SDL.renderer.create.surface";
   Create_Window_Property : constant String := "SDL.renderer.create.window";
   Create_GPU_Device_Property : constant String :=
     "SDL.renderer.create.gpu.device";
   Create_GPU_Shader_SPIRV_Property : constant String :=
     "SDL.renderer.create.gpu.shaders_spirv";
   Create_GPU_Shader_DXIL_Property : constant String :=
     "SDL.renderer.create.gpu.shaders_dxil";
   Create_GPU_Shader_MSL_Property : constant String :=
     "SDL.renderer.create.gpu.shaders_msl";

   procedure Create
     (Rend   : in out SDL.Video.Renderers.Renderer;
      Device : in SDL.GPU.Device;
      Window : in out SDL.Video.Windows.Window);

   procedure Create
     (Rend   : in out SDL.Video.Renderers.Renderer;
      Window : in out SDL.Video.Windows.Window;
      Driver : in SDL.Video.Renderers.Driver_Indices;
      Flags  : in SDL.Video.Renderers.Renderer_Flags :=
        SDL.Video.Renderers.Default_Renderer_Flags);

   procedure Create
     (Rend   : in out SDL.Video.Renderers.Renderer;
      Window : in out SDL.Video.Windows.Window;
      Flags  : in SDL.Video.Renderers.Renderer_Flags :=
        SDL.Video.Renderers.Default_Renderer_Flags);

   procedure Create
     (Rend    : in out SDL.Video.Renderers.Renderer;
      Surface : in SDL.Video.Surfaces.Surface);

   procedure Create
     (Rend       : in out SDL.Video.Renderers.Renderer;
      Properties : in SDL.Properties.Property_Set);

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
        SDL.Video.Renderers.Default_Renderer_Flags);

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
        SDL.Video.Renderers.Default_Renderer_Flags) with
     Inline;
end SDL.Video.Renderers.Makers;
