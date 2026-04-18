with Ada.Streams;
with Ada.Unchecked_Deallocation;

with Interfaces.C.Extensions;
with Interfaces.C.Strings;

with SDL.Error;
with SDL.Video.Surfaces.Internal;
with SDL.Video.Textures.Internal;

package body SDL.Video.Renderers is
   package CE renames Interfaces.C.Extensions;
   package CS renames Interfaces.C.Strings;
   package Surface_Internal renames SDL.Video.Surfaces.Internal;
   package Texture_Internal renames SDL.Video.Textures.Internal;

   use type CS.chars_ptr;
   use type C.size_t;
   use type System.Address;
   use type SDL.Video.Surfaces.Internal_Surface_Pointer;

   type Raw_Buffer_Handle_Arrays is
     array (C.size_t range <>) of aliased SDL.GPU.Buffer_Handle
   with Convention => C;

   type Raw_Texture_Handle_Arrays is
     array (C.size_t range <>) of aliased SDL.GPU.Texture_Handle
   with Convention => C;

   type Raw_Buffer_Handle_Array_Access is access Raw_Buffer_Handle_Arrays;
   type Raw_Texture_Handle_Array_Access is access Raw_Texture_Handle_Arrays;

   procedure Free_Raw_Buffer_Handle_Arrays is new Ada.Unchecked_Deallocation
     (Raw_Buffer_Handle_Arrays, Raw_Buffer_Handle_Array_Access);

   procedure Free_Raw_Texture_Handle_Arrays is new Ada.Unchecked_Deallocation
     (Raw_Texture_Handle_Arrays, Raw_Texture_Handle_Array_Access);

   function Bytes_Address
     (Data : in Ada.Streams.Stream_Element_Array) return System.Address is
     (if Data'Length = 0 then System.Null_Address else Data (Data'First)'Address);

   function Binding_Count
     (Bindings : in Texture_Sampler_Binding_Array_Access) return C.int is
     (if Bindings = null then 0 else C.int (Bindings'Length));

   function Texture_Count
     (Textures : in Texture_Array_Access) return C.int is
     (if Textures = null then 0 else C.int (Textures'Length));

   function Buffer_Count
     (Buffers : in Buffer_Array_Access) return C.int is
     (if Buffers = null then 0 else C.int (Buffers'Length));

   function Binding_Address
     (Bindings : in Texture_Sampler_Binding_Array_Access) return System.Address
   is
   begin
      if Bindings = null or else Bindings'Length = 0 then
         return System.Null_Address;
      end if;

      return Bindings (Bindings'First)'Address;
   end Binding_Address;

   function Texture_Handle_Address
     (Textures : in Raw_Texture_Handle_Array_Access) return System.Address
   is
   begin
      if Textures = null or else Textures'Length = 0 then
         return System.Null_Address;
      end if;

      return Textures (Textures'First)'Address;
   end Texture_Handle_Address;

   function Buffer_Handle_Address
     (Buffers : in Raw_Buffer_Handle_Array_Access) return System.Address
   is
   begin
      if Buffers = null or else Buffers'Length = 0 then
         return System.Null_Address;
      end if;

      return Buffers (Buffers'First)'Address;
   end Buffer_Handle_Address;

   function Copy_Texture_Handles
     (Textures : in Texture_Array_Access) return Raw_Texture_Handle_Array_Access;

   function Copy_Texture_Handles
     (Textures : in Texture_Array_Access) return Raw_Texture_Handle_Array_Access
   is
      Result : Raw_Texture_Handle_Array_Access := null;
   begin
      if Textures = null or else Textures'Length = 0 then
         return null;
      end if;

      Result := new Raw_Texture_Handle_Arrays (0 .. C.size_t (Textures'Length - 1));

      for Index in Textures'Range loop
         if SDL.GPU.Is_Null (Textures (Index)) then
            raise Renderer_Error with "Invalid GPU texture";
         end if;

         Result (C.size_t (Index - Textures'First)) :=
           SDL.GPU.Get_Handle (Textures (Index));
      end loop;

      return Result;
   end Copy_Texture_Handles;

   function Copy_Buffer_Handles
     (Buffers : in Buffer_Array_Access) return Raw_Buffer_Handle_Array_Access;

   function Copy_Buffer_Handles
     (Buffers : in Buffer_Array_Access) return Raw_Buffer_Handle_Array_Access
   is
      Result : Raw_Buffer_Handle_Array_Access := null;
   begin
      if Buffers = null or else Buffers'Length = 0 then
         return null;
      end if;

      Result := new Raw_Buffer_Handle_Arrays (0 .. C.size_t (Buffers'Length - 1));

      for Index in Buffers'Range loop
         if SDL.GPU.Is_Null (Buffers (Index)) then
            raise Renderer_Error with "Invalid GPU buffer";
         end if;

         Result (C.size_t (Index - Buffers'First)) :=
           SDL.GPU.Get_Handle (Buffers (Index));
      end loop;

      return Result;
   end Copy_Buffer_Handles;

   procedure Raise_Renderer_Error
     (Default_Message : in String := "SDL renderer call failed");

   procedure Raise_Renderer_Error
     (Default_Message : in String := "SDL renderer call failed")
   is
      Message : constant String := SDL.Error.Get;
   begin
      if Message = "" then
         raise Renderer_Error with Default_Message;
      end if;

      raise Renderer_Error with Message;
   end Raise_Renderer_Error;

   procedure Require_Renderer (Self : in Renderer);

   procedure Require_Renderer (Self : in Renderer) is
   begin
      if Self.Internal = System.Null_Address then
         raise Renderer_Error with "Invalid renderer";
      end if;
   end Require_Renderer;

   procedure Require_Texture (Texture : in SDL.Video.Textures.Texture);

   procedure Require_Texture (Texture : in SDL.Video.Textures.Texture) is
   begin
      if SDL.Video.Textures.Get_Internal (Texture) = System.Null_Address then
         raise Renderer_Error with "Invalid texture";
      end if;
   end Require_Texture;

   function To_Float_Point
     (Point : in SDL.Video.Rectangles.Point)
      return SDL.Video.Rectangles.Float_Point is
     (X => Float (Point.X),
      Y => Float (Point.Y));

   function To_Float_Rectangle
     (Rectangle : in SDL.Video.Rectangles.Rectangle)
      return SDL.Video.Rectangles.Float_Rectangle is
     (X      => Float (Rectangle.X),
      Y      => Float (Rectangle.Y),
      Width  => Float (Rectangle.Width),
      Height => Float (Rectangle.Height));

   procedure Render_Geometry_Raw
     (Self          : in out Renderer;
      Texture       : in SDL.Video.Textures.Texture;
      Vertices      : in Vertex_Arrays;
      Index_Address : in System.Address := System.Null_Address;
      Index_Count   : in C.int := 0;
      Index_Size    : in C.int := 0);

   procedure Render_Geometry_Raw
     (Self          : in out Renderer;
      Texture       : in SDL.Video.Textures.Texture;
      Vertices      : in Vertex_Arrays;
      Index_Address : in System.Address := System.Null_Address;
      Index_Count   : in C.int := 0;
      Index_Size    : in C.int := 0)
   is
      function SDL_Render_Geometry_Raw
        (Renderer     : in System.Address;
         Texture      : in System.Address;
         XY           : in System.Address;
         XY_Stride    : in C.int;
         Colour       : in System.Address;
         Colour_Stride : in C.int;
         UV           : in System.Address;
         UV_Stride    : in C.int;
         Vertex_Count : in C.int;
         Indices      : in System.Address;
         I_Count      : in C.int;
         Size_Indices : in C.int) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_RenderGeometryRaw";

      Texture_Address : constant System.Address :=
        SDL.Video.Textures.Get_Internal (Texture);
      Vertex_Stride : constant C.int :=
        C.int (Vertices (Vertices'First)'Size / System.Storage_Unit);
   begin
      Require_Renderer (Self);

      if Vertices'Length = 0 then
         return;
      end if;

      if not Boolean
          (SDL_Render_Geometry_Raw
             (Self.Internal,
              Texture_Address,
              Vertices (Vertices'First).Position.X'Address,
              Vertex_Stride,
              Vertices (Vertices'First).Colour'Address,
              Vertex_Stride,
              Vertices (Vertices'First).Texture_Coordinate.X'Address,
              Vertex_Stride,
              C.int (Vertices'Length),
              Index_Address,
              Index_Count,
              Index_Size))
      then
         Raise_Renderer_Error;
      end if;
   end Render_Geometry_Raw;

   function Is_Null (Self : in Renderer) return Boolean is
     (Self.Internal = System.Null_Address);

   function Get_Internal (Self : in Renderer) return System.Address is
     (Self.Internal);

   function Total_Drivers return Natural is
      function SDL_Get_Num_Render_Drivers return C.int with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetNumRenderDrivers";

      Count : constant C.int := SDL_Get_Num_Render_Drivers;
   begin
      if Count <= 0 then
         return 0;
      end if;

      return Natural (Count);
   end Total_Drivers;

   function Driver_Name (Driver : in Driver_Indices) return String is
      function SDL_Get_Render_Driver (Index : in C.int) return CS.chars_ptr with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetRenderDriver";

      Result : CS.chars_ptr;
   begin
      if Driver < 0 then
         return "";
      end if;

      Result := SDL_Get_Render_Driver (C.int (Driver));

      if Result = CS.Null_Ptr then
         return "";
      end if;

      return CS.Value (Result);
   end Driver_Name;

   function Name (Self : in Renderer) return String is
      function SDL_Get_Renderer_Name
        (Value : in System.Address) return CS.chars_ptr
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetRendererName";

      Result : CS.chars_ptr;
   begin
      if Self.Internal = System.Null_Address then
         return "";
      end if;

      Result := SDL_Get_Renderer_Name (Self.Internal);

      if Result = CS.Null_Ptr then
         return "";
      end if;

      return CS.Value (Result);
   end Name;

   function Get
     (Window : in SDL.Video.Windows.Window) return Renderer
   is
      function SDL_Get_Renderer
        (Value : in System.Address) return System.Address
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetRenderer";

      Internal : constant System.Address :=
        SDL_Get_Renderer (SDL.Video.Windows.Get_Internal (Window));
   begin
      return
        (Ada.Finalization.Limited_Controlled with
         Internal => Internal,
         Owns     => False);
   end Get;

   function Get
     (Texture : in SDL.Video.Textures.Texture) return Renderer
   is
      function SDL_Get_Renderer_From_Texture
        (Value : in System.Address) return System.Address
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetRendererFromTexture";

      Internal : constant System.Address :=
        SDL_Get_Renderer_From_Texture (SDL.Video.Textures.Get_Internal (Texture));
   begin
      return
        (Ada.Finalization.Limited_Controlled with
         Internal => Internal,
         Owns     => False);
   end Get;

   function Get_Window_ID
     (Self : in Renderer) return SDL.Video.Windows.ID
   is
      function SDL_Get_Render_Window
        (Value : in System.Address) return System.Address
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetRenderWindow";

      function SDL_Get_Window_ID
        (Value : in System.Address) return SDL.Video.Windows.ID
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetWindowID";

      Window : constant System.Address := SDL_Get_Render_Window (Self.Internal);
   begin
      if Window = System.Null_Address then
         return 0;
      end if;

      return SDL_Get_Window_ID (Window);
   end Get_Window_ID;

   function Get_Properties
     (Self : in Renderer) return SDL.Properties.Property_ID
   is
      function SDL_Get_Renderer_Properties
        (Value : in System.Address) return SDL.Properties.Property_ID
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetRendererProperties";
   begin
      Require_Renderer (Self);
      return SDL_Get_Renderer_Properties (Self.Internal);
   end Get_Properties;

   function Get_GPU_Device
     (Self : in Renderer) return SDL.GPU.Device
   is
      function SDL_Get_GPU_Renderer_Device
        (Value : in System.Address) return SDL.GPU.Device_Handle
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetGPURendererDevice";
   begin
      Require_Renderer (Self);
      return SDL.GPU.Make_Device_From_Pointer
        (SDL_Get_GPU_Renderer_Device (Self.Internal));
   end Get_GPU_Device;

   procedure Require_GPU_Render_State (Self : in GPU_Render_State);

   procedure Require_GPU_Render_State (Self : in GPU_Render_State) is
   begin
      if Self.Internal = System.Null_Address then
         raise Renderer_Error with "Invalid GPU render state";
      end if;
   end Require_GPU_Render_State;

   function Create_GPU_Render_State
     (Self        : in Renderer;
      Create_Info : in GPU_Render_State_Create_Info) return GPU_Render_State
   is
   begin
      return Result : GPU_Render_State do
         Create_GPU_Render_State (Result, Self, Create_Info);
      end return;
   end Create_GPU_Render_State;

   procedure Create_GPU_Render_State
     (Self        : in out GPU_Render_State;
      Renderer    : in SDL.Video.Renderers.Renderer;
      Create_Info : in GPU_Render_State_Create_Info)
   is
      type Raw_GPU_Render_State_Create_Info is
         record
            Fragment_Shader     : SDL.GPU.Shader_Handle;
            Num_Sampler_Bindings : C.int;
            Sampler_Bindings    : System.Address;
            Num_Storage_Textures : C.int;
            Storage_Textures    : System.Address;
            Num_Storage_Buffers : C.int;
            Storage_Buffers     : System.Address;
            Props               : SDL.Properties.Property_ID;
         end record
      with Convention => C;

      function SDL_Create_GPU_Render_State
        (Target      : in System.Address;
         Create_Info : access constant Raw_GPU_Render_State_Create_Info)
         return System.Address
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_CreateGPURenderState";

      Raw_Storage_Textures : Raw_Texture_Handle_Array_Access := null;
      Raw_Storage_Buffers  : Raw_Buffer_Handle_Array_Access := null;
      Raw_Create_Info      : aliased Raw_GPU_Render_State_Create_Info :=
        (Fragment_Shader      => null,
         Num_Sampler_Bindings => 0,
         Sampler_Bindings     => System.Null_Address,
         Num_Storage_Textures => 0,
         Storage_Textures     => System.Null_Address,
         Num_Storage_Buffers  => 0,
         Storage_Buffers      => System.Null_Address,
         Props                => Create_Info.Properties);
      Internal             : System.Address := System.Null_Address;
   begin
      Require_Renderer (Renderer);

      if SDL.GPU.Is_Null (Create_Info.Fragment_Shader) then
         raise Renderer_Error with "Invalid GPU fragment shader";
      end if;

      Raw_Storage_Textures := Copy_Texture_Handles (Create_Info.Storage_Textures);
      Raw_Storage_Buffers := Copy_Buffer_Handles (Create_Info.Storage_Buffers);

      Raw_Create_Info.Fragment_Shader :=
        SDL.GPU.Get_Handle (Create_Info.Fragment_Shader);
      Raw_Create_Info.Num_Sampler_Bindings :=
        Binding_Count (Create_Info.Sampler_Bindings);
      Raw_Create_Info.Sampler_Bindings :=
        Binding_Address (Create_Info.Sampler_Bindings);
      Raw_Create_Info.Num_Storage_Textures :=
        Texture_Count (Create_Info.Storage_Textures);
      Raw_Create_Info.Storage_Textures :=
        Texture_Handle_Address (Raw_Storage_Textures);
      Raw_Create_Info.Num_Storage_Buffers :=
        Buffer_Count (Create_Info.Storage_Buffers);
      Raw_Create_Info.Storage_Buffers :=
        Buffer_Handle_Address (Raw_Storage_Buffers);

      Internal :=
        SDL_Create_GPU_Render_State (Renderer.Internal, Raw_Create_Info'Access);

      if Internal = System.Null_Address then
         Raise_Renderer_Error ("SDL_CreateGPURenderState failed");
      end if;

      Destroy (Self);
      Self.Internal := Internal;
      Self.Owns := True;

      Free_Raw_Texture_Handle_Arrays (Raw_Storage_Textures);
      Free_Raw_Buffer_Handle_Arrays (Raw_Storage_Buffers);
   exception
      when others =>
         Free_Raw_Texture_Handle_Arrays (Raw_Storage_Textures);
         Free_Raw_Buffer_Handle_Arrays (Raw_Storage_Buffers);
         raise;
   end Create_GPU_Render_State;

   procedure Destroy (Self : in out GPU_Render_State) is
      procedure SDL_Destroy_GPU_Render_State (State : in System.Address) with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_DestroyGPURenderState";
   begin
      if Self.Owns and then Self.Internal /= System.Null_Address then
         SDL_Destroy_GPU_Render_State (Self.Internal);
         Self.Internal := System.Null_Address;
      end if;
   end Destroy;

   function Is_Null (Self : in GPU_Render_State) return Boolean is
     (Self.Internal = System.Null_Address);

   procedure Set_Fragment_Uniform_Data
     (Self       : in out GPU_Render_State;
      Slot_Index : in Interfaces.Unsigned_32;
      Data       : in Ada.Streams.Stream_Element_Array)
   is
      function SDL_Set_GPU_Render_State_Fragment_Uniforms
        (State      : in System.Address;
         Slot_Index : in Interfaces.Unsigned_32;
         Data       : in System.Address;
         Length     : in Interfaces.Unsigned_32) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_SetGPURenderStateFragmentUniforms";
   begin
      Require_GPU_Render_State (Self);

      if not Boolean
          (SDL_Set_GPU_Render_State_Fragment_Uniforms
             (Self.Internal,
              Slot_Index,
              Bytes_Address (Data),
              Interfaces.Unsigned_32 (Data'Length)))
      then
         Raise_Renderer_Error ("SDL_SetGPURenderStateFragmentUniforms failed");
      end if;
   end Set_Fragment_Uniform_Data;

   procedure Set_GPU_Render_State
     (Self  : in out Renderer;
      State : in GPU_Render_State)
   is
      function SDL_Set_GPU_Render_State
        (Target : in System.Address;
         State  : in System.Address) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_SetGPURenderState";
   begin
      Require_Renderer (Self);
      Require_GPU_Render_State (State);

      if not Boolean (SDL_Set_GPU_Render_State (Self.Internal, State.Internal)) then
         Raise_Renderer_Error ("SDL_SetGPURenderState failed");
      end if;
   end Set_GPU_Render_State;

   procedure Reset_GPU_Render_State (Self : in out Renderer) is
      function SDL_Set_GPU_Render_State
        (Target : in System.Address;
         State  : in System.Address) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_SetGPURenderState";
   begin
      Require_Renderer (Self);

      if not Boolean
          (SDL_Set_GPU_Render_State (Self.Internal, System.Null_Address))
      then
         Raise_Renderer_Error ("SDL_SetGPURenderState failed");
      end if;
   end Reset_GPU_Render_State;

   procedure Get_Output_Size
     (Self          : in Renderer;
      Width, Height : out SDL.Natural_Dimension)
   is
      function SDL_Get_Render_Output_Size
        (Value  : in System.Address;
         Width  : access C.int;
         Height : access C.int) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetRenderOutputSize";

      Raw_Width  : aliased C.int := 0;
      Raw_Height : aliased C.int := 0;
   begin
      Require_Renderer (Self);

      if not Boolean
          (SDL_Get_Render_Output_Size
             (Self.Internal, Raw_Width'Access, Raw_Height'Access))
      then
         Raise_Renderer_Error;
      end if;

      Width := SDL.Natural_Dimension (Raw_Width);
      Height := SDL.Natural_Dimension (Raw_Height);
   end Get_Output_Size;

   function Get_Output_Size (Self : in Renderer) return SDL.Sizes is
      Width  : SDL.Natural_Dimension := 0;
      Height : SDL.Natural_Dimension := 0;
   begin
      Get_Output_Size (Self, Width, Height);
      return (Width => Width, Height => Height);
   end Get_Output_Size;

   procedure Get_Current_Output_Size
     (Self          : in Renderer;
      Width, Height : out SDL.Natural_Dimension)
   is
      function SDL_Get_Current_Render_Output_Size
        (Value  : in System.Address;
         Width  : access C.int;
         Height : access C.int) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetCurrentRenderOutputSize";

      Raw_Width  : aliased C.int := 0;
      Raw_Height : aliased C.int := 0;
   begin
      Require_Renderer (Self);

      if not Boolean
          (SDL_Get_Current_Render_Output_Size
             (Self.Internal, Raw_Width'Access, Raw_Height'Access))
      then
         Raise_Renderer_Error;
      end if;

      Width := SDL.Natural_Dimension (Raw_Width);
      Height := SDL.Natural_Dimension (Raw_Height);
   end Get_Current_Output_Size;

   function Get_Current_Output_Size (Self : in Renderer) return SDL.Sizes is
      Width  : SDL.Natural_Dimension := 0;
      Height : SDL.Natural_Dimension := 0;
   begin
      Get_Current_Output_Size (Self, Width, Height);
      return (Width => Width, Height => Height);
   end Get_Current_Output_Size;

   procedure Set_Target
     (Self    : in out Renderer;
      Texture : in SDL.Video.Textures.Texture)
   is
      function SDL_Set_Render_Target
        (Renderer : in System.Address;
         Target   : in System.Address) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_SetRenderTarget";
   begin
      Require_Renderer (Self);
      Require_Texture (Texture);

      if not Boolean
          (SDL_Set_Render_Target
             (Self.Internal, SDL.Video.Textures.Get_Internal (Texture)))
      then
         Raise_Renderer_Error;
      end if;
   end Set_Target;

   procedure Reset_Target (Self : in out Renderer) is
      function SDL_Set_Render_Target
        (Renderer : in System.Address;
         Target   : in System.Address) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_SetRenderTarget";
   begin
      Require_Renderer (Self);

      if not Boolean
          (SDL_Set_Render_Target (Self.Internal, System.Null_Address))
      then
         Raise_Renderer_Error;
      end if;
   end Reset_Target;

   function Get_Target
     (Self : in Renderer) return SDL.Video.Textures.Texture
   is
      function SDL_Get_Render_Target
        (Renderer : in System.Address) return System.Address
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetRenderTarget";
   begin
      Require_Renderer (Self);
      return Texture_Internal.Make_From_Pointer
        (SDL_Get_Render_Target (Self.Internal));
   end Get_Target;

   procedure Set_Logical_Presentation
     (Self : in out Renderer;
      Size : in SDL.Sizes;
      Mode : in Logical_Presentations)
   is
      function SDL_Set_Render_Logical_Presentation
        (Renderer : in System.Address;
         Width    : in C.int;
         Height   : in C.int;
         Mode     : in Logical_Presentations) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_SetRenderLogicalPresentation";
   begin
      Require_Renderer (Self);

      if not Boolean
          (SDL_Set_Render_Logical_Presentation
             (Self.Internal,
              C.int (Size.Width),
              C.int (Size.Height),
              Mode))
      then
         Raise_Renderer_Error;
      end if;
   end Set_Logical_Presentation;

   procedure Get_Logical_Presentation
     (Self          : in Renderer;
      Width, Height : out SDL.Natural_Dimension;
      Mode          : out Logical_Presentations)
   is
      function SDL_Get_Render_Logical_Presentation
        (Renderer : in System.Address;
         Width    : access C.int;
         Height   : access C.int;
         Mode     : access Logical_Presentations) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetRenderLogicalPresentation";

      Raw_Width  : aliased C.int := 0;
      Raw_Height : aliased C.int := 0;
      Raw_Mode   : aliased Logical_Presentations :=
        Logical_Presentation_Disabled;
   begin
      Require_Renderer (Self);

      if not Boolean
          (SDL_Get_Render_Logical_Presentation
             (Self.Internal,
              Raw_Width'Access,
              Raw_Height'Access,
              Raw_Mode'Access))
      then
         Raise_Renderer_Error;
      end if;

      Width := SDL.Natural_Dimension (Raw_Width);
      Height := SDL.Natural_Dimension (Raw_Height);
      Mode := Raw_Mode;
   end Get_Logical_Presentation;

   function Get_Logical_Presentation_Rectangle
     (Self : in Renderer) return SDL.Video.Rectangles.Float_Rectangle
   is
      function SDL_Get_Render_Logical_Presentation_Rect
        (Renderer : in System.Address;
         Rectangle : access SDL.Video.Rectangles.Float_Rectangle)
         return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetRenderLogicalPresentationRect";

      Result : aliased SDL.Video.Rectangles.Float_Rectangle :=
        (others => 0.0);
   begin
      Require_Renderer (Self);

      if not Boolean
          (SDL_Get_Render_Logical_Presentation_Rect
             (Self.Internal, Result'Access))
      then
         Raise_Renderer_Error;
      end if;

      return Result;
   end Get_Logical_Presentation_Rectangle;

   procedure Window_Coordinates_To_Render
     (Self               : in Renderer;
      Window_X, Window_Y : in Float;
      X, Y               : out Float)
   is
      function SDL_Render_Coordinates_From_Window
        (Renderer : in System.Address;
         Window_X : in Float;
         Window_Y : in Float;
         X        : access Float;
         Y        : access Float) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_RenderCoordinatesFromWindow";

      Raw_X : aliased Float := 0.0;
      Raw_Y : aliased Float := 0.0;
   begin
      Require_Renderer (Self);

      if not Boolean
          (SDL_Render_Coordinates_From_Window
             (Self.Internal,
              Window_X,
              Window_Y,
              Raw_X'Access,
              Raw_Y'Access))
      then
         Raise_Renderer_Error;
      end if;

      X := Raw_X;
      Y := Raw_Y;
   end Window_Coordinates_To_Render;

   function Window_Coordinates_To_Render
     (Self  : in Renderer;
      Point : in SDL.Video.Rectangles.Float_Point)
      return SDL.Video.Rectangles.Float_Point
   is
      Result : SDL.Video.Rectangles.Float_Point := (others => 0.0);
   begin
      Window_Coordinates_To_Render (Self, Point.X, Point.Y, Result.X, Result.Y);
      return Result;
   end Window_Coordinates_To_Render;

   procedure Render_Coordinates_To_Window
     (Self               : in Renderer;
      X, Y               : in Float;
      Window_X, Window_Y : out Float)
   is
      function SDL_Render_Coordinates_To_Window
        (Renderer : in System.Address;
         X        : in Float;
         Y        : in Float;
         Window_X : access Float;
         Window_Y : access Float) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_RenderCoordinatesToWindow";

      Raw_X : aliased Float := 0.0;
      Raw_Y : aliased Float := 0.0;
   begin
      Require_Renderer (Self);

      if not Boolean
          (SDL_Render_Coordinates_To_Window
             (Self.Internal,
              X,
              Y,
              Raw_X'Access,
              Raw_Y'Access))
      then
         Raise_Renderer_Error;
      end if;

      Window_X := Raw_X;
      Window_Y := Raw_Y;
   end Render_Coordinates_To_Window;

   function Render_Coordinates_To_Window
     (Self  : in Renderer;
     Point : in SDL.Video.Rectangles.Float_Point)
      return SDL.Video.Rectangles.Float_Point
   is
      Result : SDL.Video.Rectangles.Float_Point := (others => 0.0);
   begin
      Render_Coordinates_To_Window (Self, Point.X, Point.Y, Result.X, Result.Y);
      return Result;
   end Render_Coordinates_To_Window;

   procedure Convert_Event_Coordinates
     (Self  : in Renderer;
      Event : in out SDL.Events.Events.Events)
   is
      function SDL_Convert_Event_To_Render_Coordinates
        (Renderer : in System.Address;
         Event    : access SDL.Events.Events.Events) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_ConvertEventToRenderCoordinates";

      Raw_Event : aliased SDL.Events.Events.Events := Event;
   begin
      Require_Renderer (Self);

      if not Boolean
          (SDL_Convert_Event_To_Render_Coordinates
             (Self.Internal, Raw_Event'Access))
      then
         Raise_Renderer_Error;
      end if;

      Event := Raw_Event;
   end Convert_Event_Coordinates;

   procedure Set_Viewport
     (Self      : in out Renderer;
      Rectangle : in SDL.Video.Rectangles.Rectangle)
   is
      function SDL_Set_Render_Viewport
        (Renderer : in System.Address;
         Rect     : in System.Address) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_SetRenderViewport";

      Raw_Rectangle : aliased constant SDL.Video.Rectangles.Rectangle := Rectangle;
   begin
      Require_Renderer (Self);

      if not Boolean
          (SDL_Set_Render_Viewport
             (Self.Internal, Raw_Rectangle'Address))
      then
         Raise_Renderer_Error;
      end if;
   end Set_Viewport;

   procedure Reset_Viewport (Self : in out Renderer) is
      function SDL_Set_Render_Viewport
        (Renderer : in System.Address;
         Rect     : in System.Address) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_SetRenderViewport";
   begin
      Require_Renderer (Self);

      if not Boolean
          (SDL_Set_Render_Viewport (Self.Internal, System.Null_Address))
      then
         Raise_Renderer_Error;
      end if;
   end Reset_Viewport;

   function Get_Viewport
     (Self : in Renderer) return SDL.Video.Rectangles.Rectangle
   is
      function SDL_Get_Render_Viewport
        (Renderer : in System.Address;
         Rect     : access SDL.Video.Rectangles.Rectangle) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetRenderViewport";

      Result : aliased SDL.Video.Rectangles.Rectangle := (others => 0);
   begin
      Require_Renderer (Self);

      if not Boolean
          (SDL_Get_Render_Viewport (Self.Internal, Result'Access))
      then
         Raise_Renderer_Error;
      end if;

      return Result;
   end Get_Viewport;

   function Is_Viewport_Set (Self : in Renderer) return Boolean is
      function SDL_Render_Viewport_Set
        (Renderer : in System.Address) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_RenderViewportSet";
   begin
      Require_Renderer (Self);
      return Boolean (SDL_Render_Viewport_Set (Self.Internal));
   end Is_Viewport_Set;

   function Get_Safe_Area
     (Self : in Renderer) return SDL.Video.Rectangles.Rectangle
   is
      function SDL_Get_Render_Safe_Area
        (Renderer : in System.Address;
         Rect     : access SDL.Video.Rectangles.Rectangle) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetRenderSafeArea";

      Result : aliased SDL.Video.Rectangles.Rectangle := (others => 0);
   begin
      Require_Renderer (Self);

      if not Boolean
          (SDL_Get_Render_Safe_Area (Self.Internal, Result'Access))
      then
         Raise_Renderer_Error;
      end if;

      return Result;
   end Get_Safe_Area;

   procedure Set_Clip
     (Self      : in out Renderer;
      Rectangle : in SDL.Video.Rectangles.Rectangle)
   is
      function SDL_Set_Render_Clip_Rect
        (Renderer : in System.Address;
         Rect     : in System.Address) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_SetRenderClipRect";

      Raw_Rectangle : aliased constant SDL.Video.Rectangles.Rectangle := Rectangle;
   begin
      Require_Renderer (Self);

      if not Boolean
          (SDL_Set_Render_Clip_Rect
             (Self.Internal, Raw_Rectangle'Address))
      then
         Raise_Renderer_Error;
      end if;
   end Set_Clip;

   procedure Disable_Clip (Self : in out Renderer) is
      function SDL_Set_Render_Clip_Rect
        (Renderer : in System.Address;
         Rect     : in System.Address) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_SetRenderClipRect";
   begin
      Require_Renderer (Self);

      if not Boolean
          (SDL_Set_Render_Clip_Rect (Self.Internal, System.Null_Address))
      then
         Raise_Renderer_Error;
      end if;
   end Disable_Clip;

   function Get_Clip
     (Self : in Renderer) return SDL.Video.Rectangles.Rectangle
   is
      function SDL_Get_Render_Clip_Rect
        (Renderer : in System.Address;
         Rect     : access SDL.Video.Rectangles.Rectangle) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetRenderClipRect";

      Result : aliased SDL.Video.Rectangles.Rectangle := (others => 0);
   begin
      Require_Renderer (Self);

      if not Boolean
          (SDL_Get_Render_Clip_Rect (Self.Internal, Result'Access))
      then
         Raise_Renderer_Error;
      end if;

      return Result;
   end Get_Clip;

   function Is_Clip_Enabled (Self : in Renderer) return Boolean is
      function SDL_Render_Clip_Enabled
        (Renderer : in System.Address) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_RenderClipEnabled";
   begin
      Require_Renderer (Self);
      return Boolean (SDL_Render_Clip_Enabled (Self.Internal));
   end Is_Clip_Enabled;

   procedure Set_Scale
     (Self    : in out Renderer;
      Scale_X : in Float;
      Scale_Y : in Float)
   is
      function SDL_Set_Render_Scale
        (Renderer : in System.Address;
         Scale_X  : in Float;
         Scale_Y  : in Float) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_SetRenderScale";
   begin
      Require_Renderer (Self);

      if not Boolean
          (SDL_Set_Render_Scale (Self.Internal, Scale_X, Scale_Y))
      then
         Raise_Renderer_Error;
      end if;
   end Set_Scale;

   procedure Get_Scale
     (Self    : in Renderer;
      Scale_X : out Float;
      Scale_Y : out Float)
   is
      function SDL_Get_Render_Scale
        (Renderer : in System.Address;
         Scale_X  : access Float;
         Scale_Y  : access Float) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetRenderScale";

      Raw_X : aliased Float := 0.0;
      Raw_Y : aliased Float := 0.0;
   begin
      Require_Renderer (Self);

      if not Boolean
          (SDL_Get_Render_Scale (Self.Internal, Raw_X'Access, Raw_Y'Access))
      then
         Raise_Renderer_Error;
      end if;

      Scale_X := Raw_X;
      Scale_Y := Raw_Y;
   end Get_Scale;

   function Get_Scale
     (Self : in Renderer) return SDL.Video.Rectangles.Float_Point
   is
      Result : SDL.Video.Rectangles.Float_Point := (others => 0.0);
   begin
      Get_Scale (Self, Result.X, Result.Y);
      return Result;
   end Get_Scale;

   function Get_Blend_Mode
     (Self : in Renderer) return SDL.Video.Blend_Modes
   is
      function SDL_Get_Render_Draw_Blend_Mode
        (Renderer : in System.Address;
         Mode     : access SDL.Video.Blend_Modes) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetRenderDrawBlendMode";

      Result : aliased SDL.Video.Blend_Modes := SDL.Video.None;
   begin
      Require_Renderer (Self);

      if not Boolean
          (SDL_Get_Render_Draw_Blend_Mode (Self.Internal, Result'Access))
      then
         Raise_Renderer_Error;
      end if;

      return Result;
   end Get_Blend_Mode;

   procedure Set_Blend_Mode
     (Self : in out Renderer;
      Mode : in SDL.Video.Blend_Modes)
   is
      function SDL_Set_Render_Draw_Blend_Mode
        (Renderer : in System.Address;
         Mode     : in SDL.Video.Blend_Modes) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_SetRenderDrawBlendMode";
   begin
      Require_Renderer (Self);

      if not Boolean
          (SDL_Set_Render_Draw_Blend_Mode (Self.Internal, Mode))
      then
         Raise_Renderer_Error;
      end if;
   end Set_Blend_Mode;

   function Get_Draw_Colour
     (Self : in Renderer) return SDL.Video.Palettes.Colour
   is
      function SDL_Get_Render_Draw_Color
        (Renderer : in System.Address;
         Red      : access SDL.Video.Palettes.Colour_Component;
         Green    : access SDL.Video.Palettes.Colour_Component;
         Blue     : access SDL.Video.Palettes.Colour_Component;
         Alpha    : access SDL.Video.Palettes.Colour_Component) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetRenderDrawColor";

      Red   : aliased SDL.Video.Palettes.Colour_Component := 0;
      Green : aliased SDL.Video.Palettes.Colour_Component := 0;
      Blue  : aliased SDL.Video.Palettes.Colour_Component := 0;
      Alpha : aliased SDL.Video.Palettes.Colour_Component := 0;
   begin
      Require_Renderer (Self);

      if not Boolean
          (SDL_Get_Render_Draw_Color
             (Self.Internal,
              Red'Access,
              Green'Access,
              Blue'Access,
              Alpha'Access))
      then
         Raise_Renderer_Error;
      end if;

      return
        (Red   => Red,
         Green => Green,
         Blue  => Blue,
         Alpha => Alpha);
   end Get_Draw_Colour;

   procedure Get_Draw_Colour
     (Self        : in Renderer;
      Red, Green  : out Float;
      Blue, Alpha : out Float)
   is
      function SDL_Get_Render_Draw_Color_Float
        (Renderer : in System.Address;
         Red      : access Float;
         Green    : access Float;
         Blue     : access Float;
         Alpha    : access Float) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetRenderDrawColorFloat";

      Raw_Red   : aliased Float := 0.0;
      Raw_Green : aliased Float := 0.0;
      Raw_Blue  : aliased Float := 0.0;
      Raw_Alpha : aliased Float := 0.0;
   begin
      Require_Renderer (Self);

      if not Boolean
          (SDL_Get_Render_Draw_Color_Float
             (Self.Internal,
              Raw_Red'Access,
              Raw_Green'Access,
              Raw_Blue'Access,
              Raw_Alpha'Access))
      then
         Raise_Renderer_Error;
      end if;

      Red := Raw_Red;
      Green := Raw_Green;
      Blue := Raw_Blue;
      Alpha := Raw_Alpha;
   end Get_Draw_Colour;

   procedure Set_Draw_Colour
     (Self   : in out Renderer;
      Colour : in SDL.Video.Palettes.Colour)
   is
      function SDL_Set_Render_Draw_Color
        (Renderer : in System.Address;
         Red      : in SDL.Video.Palettes.Colour_Component;
         Green    : in SDL.Video.Palettes.Colour_Component;
         Blue     : in SDL.Video.Palettes.Colour_Component;
         Alpha    : in SDL.Video.Palettes.Colour_Component) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_SetRenderDrawColor";
   begin
      Require_Renderer (Self);

      if not Boolean
          (SDL_Set_Render_Draw_Color
             (Self.Internal,
              Colour.Red,
              Colour.Green,
              Colour.Blue,
              Colour.Alpha))
      then
         Raise_Renderer_Error;
      end if;
   end Set_Draw_Colour;

   procedure Set_Draw_Colour
     (Self        : in out Renderer;
      Red, Green  : in Float;
      Blue, Alpha : in Float)
   is
      function SDL_Set_Render_Draw_Color_Float
        (Renderer : in System.Address;
         Red      : in Float;
         Green    : in Float;
         Blue     : in Float;
         Alpha    : in Float) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_SetRenderDrawColorFloat";
   begin
      Require_Renderer (Self);

      if not Boolean
          (SDL_Set_Render_Draw_Color_Float
             (Self.Internal, Red, Green, Blue, Alpha))
      then
         Raise_Renderer_Error;
      end if;
   end Set_Draw_Colour;

   function Get_Colour_Scale (Self : in Renderer) return Float is
      function SDL_Get_Render_Color_Scale
        (Renderer : in System.Address;
         Scale    : access Float) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetRenderColorScale";

      Result : aliased Float := 0.0;
   begin
      Require_Renderer (Self);

      if not Boolean
          (SDL_Get_Render_Color_Scale (Self.Internal, Result'Access))
      then
         Raise_Renderer_Error;
      end if;

      return Result;
   end Get_Colour_Scale;

   procedure Set_Colour_Scale
     (Self  : in out Renderer;
      Scale : in Float)
   is
      function SDL_Set_Render_Color_Scale
        (Renderer : in System.Address;
         Scale    : in Float) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_SetRenderColorScale";
   begin
      Require_Renderer (Self);

      if not Boolean
          (SDL_Set_Render_Color_Scale (Self.Internal, Scale))
      then
         Raise_Renderer_Error;
      end if;
   end Set_Colour_Scale;

   procedure Clear (Self : in out Renderer) is
      function SDL_Render_Clear (Value : in System.Address) return CE.bool with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_RenderClear";
   begin
      Require_Renderer (Self);

      if not Boolean (SDL_Render_Clear (Self.Internal)) then
         Raise_Renderer_Error;
      end if;
   end Clear;

   procedure Draw
     (Self  : in out Renderer;
      Point : in SDL.Video.Rectangles.Float_Point)
   is
      function SDL_Render_Point
        (Renderer : in System.Address;
         X        : in Float;
         Y        : in Float) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_RenderPoint";
   begin
      Require_Renderer (Self);

      if not Boolean (SDL_Render_Point (Self.Internal, Point.X, Point.Y)) then
         Raise_Renderer_Error;
      end if;
   end Draw;

   procedure Draw
     (Self  : in out Renderer;
      Point : in SDL.Video.Rectangles.Point) is
   begin
      Draw (Self, To_Float_Point (Point));
   end Draw;

   procedure Draw
     (Self   : in out Renderer;
      Points : in SDL.Video.Rectangles.Float_Point_Arrays)
   is
      function SDL_Render_Points
        (Renderer : in System.Address;
         Points   : access constant SDL.Video.Rectangles.Float_Point;
         Count    : in C.int) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_RenderPoints";
   begin
      Require_Renderer (Self);

      if Points'Length = 0 then
         return;
      end if;

      if not Boolean
          (SDL_Render_Points
             (Self.Internal, Points (Points'First)'Access, C.int (Points'Length)))
      then
         Raise_Renderer_Error;
      end if;
   end Draw;

   procedure Draw
     (Self   : in out Renderer;
      Points : in SDL.Video.Rectangles.Point_Arrays)
   is
      Float_Points : SDL.Video.Rectangles.Float_Point_Arrays (Points'Range);
   begin
      for Index in Points'Range loop
         Float_Points (Index) := To_Float_Point (Points (Index));
      end loop;

      Draw (Self, Float_Points);
   end Draw;

   procedure Draw_Connected
     (Self   : in out Renderer;
      Points : in SDL.Video.Rectangles.Float_Point_Arrays)
   is
      function SDL_Render_Lines
        (Renderer : in System.Address;
         Points   : access constant SDL.Video.Rectangles.Float_Point;
         Count    : in C.int) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_RenderLines";
   begin
      Require_Renderer (Self);

      if Points'Length = 0 then
         return;
      end if;

      if not Boolean
          (SDL_Render_Lines
             (Self.Internal, Points (Points'First)'Access, C.int (Points'Length)))
      then
         Raise_Renderer_Error;
      end if;
   end Draw_Connected;

   procedure Draw_Connected
     (Self   : in out Renderer;
      Points : in SDL.Video.Rectangles.Point_Arrays)
   is
      Float_Points : SDL.Video.Rectangles.Float_Point_Arrays (Points'Range);
   begin
      for Index in Points'Range loop
         Float_Points (Index) := To_Float_Point (Points (Index));
      end loop;

      Draw_Connected (Self, Float_Points);
   end Draw_Connected;

   procedure Draw
     (Self : in out Renderer;
      Line : in SDL.Video.Rectangles.Float_Line_Segment)
   is
      function SDL_Render_Line
        (Renderer : in System.Address;
         X1       : in Float;
         Y1       : in Float;
         X2       : in Float;
         Y2       : in Float) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_RenderLine";
   begin
      Require_Renderer (Self);

      if not Boolean
          (SDL_Render_Line
             (Self.Internal,
              Line.Start.X,
              Line.Start.Y,
              Line.Finish.X,
              Line.Finish.Y))
      then
         Raise_Renderer_Error;
      end if;
   end Draw;

   procedure Draw
     (Self : in out Renderer;
      Line : in SDL.Video.Rectangles.Line_Segment)
   is
      Float_Line : constant SDL.Video.Rectangles.Float_Line_Segment :=
        (Start  => To_Float_Point (Line.Start),
         Finish => To_Float_Point (Line.Finish));
   begin
      Draw (Self, Float_Line);
   end Draw;

   procedure Draw
     (Self           : in out Renderer;
      X1, Y1, X2, Y2 : in Float)
   is
      Line : constant SDL.Video.Rectangles.Float_Line_Segment :=
        (Start  => (X => X1, Y => Y1),
         Finish => (X => X2, Y => Y2));
   begin
      Draw (Self, Line);
   end Draw;

   procedure Draw
     (Self          : in out Renderer;
      X1, Y1, X2, Y2 : in SDL.Coordinate) is
   begin
      Draw (Self, Float (X1), Float (Y1), Float (X2), Float (Y2));
   end Draw;

   procedure Draw
     (Self  : in out Renderer;
      Lines : in SDL.Video.Rectangles.Float_Line_Arrays)
   is
   begin
      for Line of Lines loop
         Draw (Self, Line);
      end loop;
   end Draw;

   procedure Draw
     (Self  : in out Renderer;
      Lines : in SDL.Video.Rectangles.Line_Arrays)
   is
   begin
      for Line of Lines loop
         Draw (Self, Line);
      end loop;
   end Draw;

   procedure Draw
     (Self      : in out Renderer;
      Rectangle : in SDL.Video.Rectangles.Float_Rectangle)
   is
      function SDL_Render_Rect
        (Renderer : in System.Address;
         Rect     : access constant SDL.Video.Rectangles.Float_Rectangle)
         return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_RenderRect";

      Raw_Rectangle : aliased constant SDL.Video.Rectangles.Float_Rectangle :=
        Rectangle;
   begin
      Require_Renderer (Self);

      if not Boolean
          (SDL_Render_Rect (Self.Internal, Raw_Rectangle'Access))
      then
         Raise_Renderer_Error;
      end if;
   end Draw;

   procedure Draw
     (Self      : in out Renderer;
      Rectangle : in SDL.Video.Rectangles.Rectangle) is
   begin
      Draw (Self, To_Float_Rectangle (Rectangle));
   end Draw;

   procedure Draw
     (Self       : in out Renderer;
      Rectangles : in SDL.Video.Rectangles.Float_Rectangle_Arrays)
   is
      function SDL_Render_Rects
        (Renderer : in System.Address;
         Rects    : access constant SDL.Video.Rectangles.Float_Rectangle;
         Count    : in C.int) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_RenderRects";
   begin
      Require_Renderer (Self);

      if Rectangles'Length = 0 then
         return;
      end if;

      if not Boolean
          (SDL_Render_Rects
             (Self.Internal,
              Rectangles (Rectangles'First)'Access,
              C.int (Rectangles'Length)))
      then
         Raise_Renderer_Error;
      end if;
   end Draw;

   procedure Draw
     (Self       : in out Renderer;
      Rectangles : in SDL.Video.Rectangles.Rectangle_Arrays)
   is
      Float_Rectangles :
        SDL.Video.Rectangles.Float_Rectangle_Arrays (Rectangles'Range);
   begin
      for Index in Rectangles'Range loop
         Float_Rectangles (Index) := To_Float_Rectangle (Rectangles (Index));
      end loop;

      Draw (Self, Float_Rectangles);
   end Draw;

   procedure Fill
     (Self      : in out Renderer;
      Rectangle : in SDL.Video.Rectangles.Float_Rectangle)
   is
      function SDL_Render_Fill_Rect
        (Renderer : in System.Address;
         Rect     : access constant SDL.Video.Rectangles.Float_Rectangle)
         return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_RenderFillRect";

      Raw_Rectangle : aliased constant SDL.Video.Rectangles.Float_Rectangle :=
        Rectangle;
   begin
      Require_Renderer (Self);

      if not Boolean
          (SDL_Render_Fill_Rect (Self.Internal, Raw_Rectangle'Access))
      then
         Raise_Renderer_Error;
      end if;
   end Fill;

   procedure Fill
     (Self      : in out Renderer;
      Rectangle : in SDL.Video.Rectangles.Rectangle) is
   begin
      Fill (Self, To_Float_Rectangle (Rectangle));
   end Fill;

   procedure Fill
     (Self       : in out Renderer;
      Rectangles : in SDL.Video.Rectangles.Float_Rectangle_Arrays)
   is
      function SDL_Render_Fill_Rects
        (Renderer : in System.Address;
         Rects    : access constant SDL.Video.Rectangles.Float_Rectangle;
         Count    : in C.int) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_RenderFillRects";
   begin
      Require_Renderer (Self);

      if Rectangles'Length = 0 then
         return;
      end if;

      if not Boolean
          (SDL_Render_Fill_Rects
             (Self.Internal,
              Rectangles (Rectangles'First)'Access,
              C.int (Rectangles'Length)))
      then
         Raise_Renderer_Error;
      end if;
   end Fill;

   procedure Fill
     (Self       : in out Renderer;
      Rectangles : in SDL.Video.Rectangles.Rectangle_Arrays)
   is
      Float_Rectangles :
        SDL.Video.Rectangles.Float_Rectangle_Arrays (Rectangles'Range);
   begin
      for Index in Rectangles'Range loop
         Float_Rectangles (Index) := To_Float_Rectangle (Rectangles (Index));
      end loop;

      Fill (Self, Float_Rectangles);
   end Fill;

   procedure Copy
     (Self    : in out Renderer;
      Texture : in SDL.Video.Textures.Texture)
   is
      function SDL_Render_Texture
        (Renderer : in System.Address;
         Texture  : in System.Address;
         Source   : in System.Address;
         Target   : in System.Address) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_RenderTexture";
   begin
      Require_Renderer (Self);
      Require_Texture (Texture);

      if not Boolean
          (SDL_Render_Texture
             (Self.Internal,
              SDL.Video.Textures.Get_Internal (Texture),
              System.Null_Address,
              System.Null_Address))
      then
         Raise_Renderer_Error;
      end if;
   end Copy;

   procedure Copy
     (Self    : in out Renderer;
      Texture : in SDL.Video.Textures.Texture;
      Source  : in SDL.Video.Rectangles.Float_Rectangle;
      Target  : in SDL.Video.Rectangles.Float_Rectangle)
   is
      function SDL_Render_Texture
        (Renderer : in System.Address;
         Texture  : in System.Address;
         Source   : in System.Address;
         Target   : in System.Address) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_RenderTexture";

      Source_Rect : aliased constant SDL.Video.Rectangles.Float_Rectangle := Source;
      Target_Rect : aliased constant SDL.Video.Rectangles.Float_Rectangle := Target;
   begin
      Require_Renderer (Self);
      Require_Texture (Texture);

      if not Boolean
          (SDL_Render_Texture
             (Self.Internal,
              SDL.Video.Textures.Get_Internal (Texture),
              Source_Rect'Address,
              Target_Rect'Address))
      then
         Raise_Renderer_Error;
      end if;
   end Copy;

   procedure Copy
     (Self    : in out Renderer;
      Texture : in SDL.Video.Textures.Texture;
      Source  : in SDL.Video.Rectangles.Rectangle;
      Target  : in SDL.Video.Rectangles.Rectangle) is
   begin
      Copy (Self, Texture, To_Float_Rectangle (Source), To_Float_Rectangle (Target));
   end Copy;

   procedure Copy
     (Self    : in out Renderer;
      Texture : in SDL.Video.Textures.Texture;
      Source  : in SDL.Video.Rectangles.Rectangle;
      Target  : in SDL.Video.Rectangles.Float_Rectangle) is
   begin
      Copy (Self, Texture, To_Float_Rectangle (Source), Target);
   end Copy;

   procedure Copy_From
     (Self    : in out Renderer;
      Texture : in SDL.Video.Textures.Texture;
      Source  : in SDL.Video.Rectangles.Float_Rectangle)
   is
      function SDL_Render_Texture
        (Renderer : in System.Address;
         Texture  : in System.Address;
         Source   : in System.Address;
         Target   : in System.Address) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_RenderTexture";

      Source_Rect : aliased constant SDL.Video.Rectangles.Float_Rectangle := Source;
   begin
      Require_Renderer (Self);
      Require_Texture (Texture);

      if not Boolean
          (SDL_Render_Texture
             (Self.Internal,
              SDL.Video.Textures.Get_Internal (Texture),
              Source_Rect'Address,
              System.Null_Address))
      then
         Raise_Renderer_Error;
      end if;
   end Copy_From;

   procedure Copy_From
     (Self    : in out Renderer;
      Texture : in SDL.Video.Textures.Texture;
      Source  : in SDL.Video.Rectangles.Rectangle) is
   begin
      Copy_From (Self, Texture, To_Float_Rectangle (Source));
   end Copy_From;

   procedure Copy_To
     (Self    : in out Renderer;
      Texture : in SDL.Video.Textures.Texture;
      Target  : in SDL.Video.Rectangles.Rectangle) is
   begin
      Copy_To (Self, Texture, To_Float_Rectangle (Target));
   end Copy_To;

   procedure Copy_To
     (Self    : in out Renderer;
      Texture : in SDL.Video.Textures.Texture;
      Target  : in SDL.Video.Rectangles.Float_Rectangle)
   is
      function SDL_Render_Texture
        (Renderer : in System.Address;
         Texture  : in System.Address;
         Source   : in System.Address;
         Target   : in System.Address) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_RenderTexture";

      Target_Rect : aliased constant SDL.Video.Rectangles.Float_Rectangle := Target;
   begin
      Require_Renderer (Self);
      Require_Texture (Texture);

      if not Boolean
          (SDL_Render_Texture
             (Self.Internal,
              SDL.Video.Textures.Get_Internal (Texture),
              System.Null_Address,
              Target_Rect'Address))
      then
         Raise_Renderer_Error;
      end if;
   end Copy_To;

   procedure Copy_Rotated
     (Self    : in out Renderer;
      Texture : in SDL.Video.Textures.Texture;
      Angle   : in Long_Float;
      Centre  : in SDL.Video.Rectangles.Float_Point;
      Flip    : in Flip_Modes := No_Flip)
   is
      function SDL_Render_Texture_Rotated
        (Renderer : in System.Address;
         Texture  : in System.Address;
         Source   : in System.Address;
         Target   : in System.Address;
         Angle    : in C.double;
         Centre   : in System.Address;
         Flip     : in Flip_Modes) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_RenderTextureRotated";

      Raw_Centre : aliased constant SDL.Video.Rectangles.Float_Point := Centre;
   begin
      Require_Renderer (Self);
      Require_Texture (Texture);

      if not Boolean
          (SDL_Render_Texture_Rotated
             (Self.Internal,
              SDL.Video.Textures.Get_Internal (Texture),
              System.Null_Address,
              System.Null_Address,
              C.double (Angle),
              Raw_Centre'Address,
              Flip))
      then
         Raise_Renderer_Error;
      end if;
   end Copy_Rotated;

   procedure Copy_Rotated
     (Self    : in out Renderer;
      Texture : in SDL.Video.Textures.Texture;
      Target  : in SDL.Video.Rectangles.Rectangle;
      Angle   : in Long_Float;
      Centre  : in SDL.Video.Rectangles.Point;
      Flip    : in Flip_Modes := No_Flip) is
   begin
      Copy_Rotated
        (Self    => Self,
         Texture => Texture,
         Target  => To_Float_Rectangle (Target),
         Angle   => Angle,
         Centre  => To_Float_Point (Centre),
         Flip    => Flip);
   end Copy_Rotated;

   procedure Copy_Rotated
     (Self    : in out Renderer;
      Texture : in SDL.Video.Textures.Texture;
      Target  : in SDL.Video.Rectangles.Float_Rectangle;
      Angle   : in Long_Float;
      Centre  : in SDL.Video.Rectangles.Float_Point;
      Flip    : in Flip_Modes := No_Flip)
   is
      function SDL_Render_Texture_Rotated
        (Renderer : in System.Address;
         Texture  : in System.Address;
         Source   : in System.Address;
         Target   : in System.Address;
         Angle    : in C.double;
         Centre   : in System.Address;
         Flip     : in Flip_Modes) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_RenderTextureRotated";

      Target_Rect : aliased constant SDL.Video.Rectangles.Float_Rectangle := Target;
      Raw_Centre  : aliased constant SDL.Video.Rectangles.Float_Point := Centre;
   begin
      Require_Renderer (Self);
      Require_Texture (Texture);

      if not Boolean
          (SDL_Render_Texture_Rotated
             (Self.Internal,
              SDL.Video.Textures.Get_Internal (Texture),
              System.Null_Address,
              Target_Rect'Address,
              C.double (Angle),
              Raw_Centre'Address,
              Flip))
      then
         Raise_Renderer_Error;
      end if;
   end Copy_Rotated;

   procedure Copy_Rotated
     (Self    : in out Renderer;
      Texture : in SDL.Video.Textures.Texture;
      Source  : in SDL.Video.Rectangles.Rectangle;
      Target  : in SDL.Video.Rectangles.Rectangle;
      Angle   : in Long_Float;
      Centre  : in SDL.Video.Rectangles.Point;
      Flip    : in Flip_Modes := No_Flip) is
   begin
      Copy_Rotated
        (Self    => Self,
         Texture => Texture,
         Source  => To_Float_Rectangle (Source),
         Target  => To_Float_Rectangle (Target),
         Angle   => Angle,
         Centre  => To_Float_Point (Centre),
         Flip    => Flip);
   end Copy_Rotated;

   procedure Copy_Rotated
     (Self    : in out Renderer;
      Texture : in SDL.Video.Textures.Texture;
      Source  : in SDL.Video.Rectangles.Float_Rectangle;
      Target  : in SDL.Video.Rectangles.Float_Rectangle;
      Angle   : in Long_Float;
      Centre  : in SDL.Video.Rectangles.Float_Point;
      Flip    : in Flip_Modes := No_Flip)
   is
      function SDL_Render_Texture_Rotated
        (Renderer : in System.Address;
         Texture  : in System.Address;
         Source   : in System.Address;
         Target   : in System.Address;
         Angle    : in C.double;
         Centre   : in System.Address;
         Flip     : in Flip_Modes) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_RenderTextureRotated";

      Source_Rect : aliased constant SDL.Video.Rectangles.Float_Rectangle := Source;
      Target_Rect : aliased constant SDL.Video.Rectangles.Float_Rectangle := Target;
      Raw_Centre  : aliased constant SDL.Video.Rectangles.Float_Point := Centre;
   begin
      Require_Renderer (Self);
      Require_Texture (Texture);

      if not Boolean
          (SDL_Render_Texture_Rotated
             (Self.Internal,
              SDL.Video.Textures.Get_Internal (Texture),
              Source_Rect'Address,
              Target_Rect'Address,
              C.double (Angle),
              Raw_Centre'Address,
              Flip))
      then
         Raise_Renderer_Error;
      end if;
   end Copy_Rotated;

   procedure Copy_Affine
     (Self    : in out Renderer;
      Texture : in SDL.Video.Textures.Texture;
      Origin  : in SDL.Video.Rectangles.Float_Point;
      Right   : in SDL.Video.Rectangles.Float_Point;
      Down    : in SDL.Video.Rectangles.Float_Point)
   is
      function SDL_Render_Texture_Affine
        (Renderer : in System.Address;
         Texture  : in System.Address;
         Source   : in System.Address;
         Origin   : in System.Address;
         Right    : in System.Address;
         Down     : in System.Address) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_RenderTextureAffine";

      Raw_Origin : aliased constant SDL.Video.Rectangles.Float_Point := Origin;
      Raw_Right  : aliased constant SDL.Video.Rectangles.Float_Point := Right;
      Raw_Down   : aliased constant SDL.Video.Rectangles.Float_Point := Down;
   begin
      Require_Renderer (Self);
      Require_Texture (Texture);

      if not Boolean
          (SDL_Render_Texture_Affine
             (Self.Internal,
              SDL.Video.Textures.Get_Internal (Texture),
              System.Null_Address,
              Raw_Origin'Address,
              Raw_Right'Address,
              Raw_Down'Address))
      then
         Raise_Renderer_Error;
      end if;
   end Copy_Affine;

   procedure Copy_Affine
     (Self    : in out Renderer;
      Texture : in SDL.Video.Textures.Texture;
      Source  : in SDL.Video.Rectangles.Float_Rectangle;
      Origin  : in SDL.Video.Rectangles.Float_Point;
      Right   : in SDL.Video.Rectangles.Float_Point;
      Down    : in SDL.Video.Rectangles.Float_Point)
   is
      function SDL_Render_Texture_Affine
        (Renderer : in System.Address;
         Texture  : in System.Address;
         Source   : in System.Address;
         Origin   : in System.Address;
         Right    : in System.Address;
         Down     : in System.Address) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_RenderTextureAffine";

      Source_Rect : aliased constant SDL.Video.Rectangles.Float_Rectangle := Source;
      Raw_Origin  : aliased constant SDL.Video.Rectangles.Float_Point := Origin;
      Raw_Right   : aliased constant SDL.Video.Rectangles.Float_Point := Right;
      Raw_Down    : aliased constant SDL.Video.Rectangles.Float_Point := Down;
   begin
      Require_Renderer (Self);
      Require_Texture (Texture);

      if not Boolean
          (SDL_Render_Texture_Affine
             (Self.Internal,
              SDL.Video.Textures.Get_Internal (Texture),
              Source_Rect'Address,
              Raw_Origin'Address,
              Raw_Right'Address,
              Raw_Down'Address))
      then
         Raise_Renderer_Error;
      end if;
   end Copy_Affine;

   procedure Copy_Tiled
     (Self    : in out Renderer;
      Texture : in SDL.Video.Textures.Texture;
      Scale   : in Float;
      Target  : in SDL.Video.Rectangles.Float_Rectangle)
   is
      function SDL_Render_Texture_Tiled
        (Renderer : in System.Address;
         Texture  : in System.Address;
         Source   : in System.Address;
         Scale    : in Float;
         Target   : in System.Address) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_RenderTextureTiled";

      Target_Rect : aliased constant SDL.Video.Rectangles.Float_Rectangle := Target;
   begin
      Require_Renderer (Self);
      Require_Texture (Texture);

      if not Boolean
          (SDL_Render_Texture_Tiled
             (Self.Internal,
              SDL.Video.Textures.Get_Internal (Texture),
              System.Null_Address,
              Scale,
              Target_Rect'Address))
      then
         Raise_Renderer_Error;
      end if;
   end Copy_Tiled;

   procedure Copy_Tiled
     (Self    : in out Renderer;
      Texture : in SDL.Video.Textures.Texture;
      Source  : in SDL.Video.Rectangles.Float_Rectangle;
      Scale   : in Float;
      Target  : in SDL.Video.Rectangles.Float_Rectangle)
   is
      function SDL_Render_Texture_Tiled
        (Renderer : in System.Address;
         Texture  : in System.Address;
         Source   : in System.Address;
         Scale    : in Float;
         Target   : in System.Address) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_RenderTextureTiled";

      Source_Rect : aliased constant SDL.Video.Rectangles.Float_Rectangle := Source;
      Target_Rect : aliased constant SDL.Video.Rectangles.Float_Rectangle := Target;
   begin
      Require_Renderer (Self);
      Require_Texture (Texture);

      if not Boolean
          (SDL_Render_Texture_Tiled
             (Self.Internal,
              SDL.Video.Textures.Get_Internal (Texture),
              Source_Rect'Address,
              Scale,
              Target_Rect'Address))
      then
         Raise_Renderer_Error;
      end if;
   end Copy_Tiled;

   procedure Copy_9_Grid
     (Self          : in out Renderer;
      Texture       : in SDL.Video.Textures.Texture;
      Source        : in SDL.Video.Rectangles.Float_Rectangle;
      Left_Width    : in Float;
      Right_Width   : in Float;
      Top_Height    : in Float;
      Bottom_Height : in Float;
      Scale         : in Float;
      Target        : in SDL.Video.Rectangles.Float_Rectangle)
   is
      function SDL_Render_Texture_9_Grid
        (Renderer      : in System.Address;
         Texture       : in System.Address;
         Source        : in System.Address;
         Left_Width    : in Float;
         Right_Width   : in Float;
         Top_Height    : in Float;
         Bottom_Height : in Float;
         Scale         : in Float;
         Target        : in System.Address) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_RenderTexture9Grid";

      Source_Rect : aliased constant SDL.Video.Rectangles.Float_Rectangle := Source;
      Target_Rect : aliased constant SDL.Video.Rectangles.Float_Rectangle := Target;
   begin
      Require_Renderer (Self);
      Require_Texture (Texture);

      if not Boolean
          (SDL_Render_Texture_9_Grid
             (Self.Internal,
              SDL.Video.Textures.Get_Internal (Texture),
              Source_Rect'Address,
              Left_Width,
              Right_Width,
              Top_Height,
              Bottom_Height,
              Scale,
              Target_Rect'Address))
      then
         Raise_Renderer_Error;
      end if;
   end Copy_9_Grid;

   procedure Copy_9_Grid_Tiled
     (Self          : in out Renderer;
      Texture       : in SDL.Video.Textures.Texture;
      Source        : in SDL.Video.Rectangles.Float_Rectangle;
      Left_Width    : in Float;
      Right_Width   : in Float;
      Top_Height    : in Float;
      Bottom_Height : in Float;
      Scale         : in Float;
      Target        : in SDL.Video.Rectangles.Float_Rectangle;
      Tile_Scale    : in Float)
   is
      function SDL_Render_Texture_9_Grid_Tiled
        (Renderer      : in System.Address;
         Texture       : in System.Address;
         Source        : in System.Address;
         Left_Width    : in Float;
         Right_Width   : in Float;
         Top_Height    : in Float;
         Bottom_Height : in Float;
         Scale         : in Float;
         Target        : in System.Address;
         Tile_Scale    : in Float) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_RenderTexture9GridTiled";

      Source_Rect : aliased constant SDL.Video.Rectangles.Float_Rectangle := Source;
      Target_Rect : aliased constant SDL.Video.Rectangles.Float_Rectangle := Target;
   begin
      Require_Renderer (Self);
      Require_Texture (Texture);

      if not Boolean
          (SDL_Render_Texture_9_Grid_Tiled
             (Self.Internal,
              SDL.Video.Textures.Get_Internal (Texture),
              Source_Rect'Address,
              Left_Width,
              Right_Width,
              Top_Height,
              Bottom_Height,
              Scale,
              Target_Rect'Address,
              Tile_Scale))
      then
         Raise_Renderer_Error;
      end if;
   end Copy_9_Grid_Tiled;

   procedure Render_Geometry
     (Self     : in out Renderer;
      Vertices : in Vertex_Arrays)
   is
   begin
      Render_Geometry
        (Self     => Self,
         Texture  => Texture_Internal.Make_From_Pointer (System.Null_Address),
         Vertices => Vertices);
   end Render_Geometry;

   procedure Render_Geometry
     (Self     : in out Renderer;
      Vertices : in Vertex_Arrays;
      Indices  : in Index_Arrays)
   is
   begin
      Render_Geometry
        (Self     => Self,
         Texture  => Texture_Internal.Make_From_Pointer (System.Null_Address),
         Vertices => Vertices,
         Indices  => Indices);
   end Render_Geometry;

   procedure Render_Geometry
     (Self     : in out Renderer;
     Texture  : in SDL.Video.Textures.Texture;
     Vertices : in Vertex_Arrays)
   is
      function SDL_Render_Geometry
        (Renderer    : in System.Address;
         Texture     : in System.Address;
         Vertex_Data : access constant SDL.Video.Renderers.Vertices;
         Count       : in C.int;
         Indices     : in System.Address;
         I_Count     : in C.int) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_RenderGeometry";

      Texture_Address : constant System.Address :=
        SDL.Video.Textures.Get_Internal (Texture);
   begin
      Require_Renderer (Self);

      if Vertices'Length = 0 then
         return;
      end if;

      if not Boolean
          (SDL_Render_Geometry
             (Self.Internal,
              Texture_Address,
              Vertices (Vertices'First)'Access,
              C.int (Vertices'Length),
              System.Null_Address,
              0))
      then
         Raise_Renderer_Error;
      end if;
   end Render_Geometry;

   procedure Render_Geometry
     (Self     : in out Renderer;
     Texture  : in SDL.Video.Textures.Texture;
     Vertices : in Vertex_Arrays;
     Indices  : in Index_Arrays)
   is
   begin
      if Vertices'Length = 0 or else Indices'Length = 0 then
         return;
      end if;

      Render_Geometry_Raw
        (Self          => Self,
         Texture       => Texture,
         Vertices      => Vertices,
         Index_Address => Indices (Indices'First)'Address,
         Index_Count   => C.int (Indices'Length),
         Index_Size    => C.int (Vertex_Indices'Size / System.Storage_Unit));
   end Render_Geometry;

   procedure Set_Texture_Address_Modes
     (Self   : in out Renderer;
      U_Mode : in Texture_Address_Modes;
      V_Mode : in Texture_Address_Modes)
   is
      function SDL_Set_Render_Texture_Address_Mode
        (Renderer : in System.Address;
         U_Mode   : in Texture_Address_Modes;
         V_Mode   : in Texture_Address_Modes) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_SetRenderTextureAddressMode";
   begin
      Require_Renderer (Self);

      if not Boolean
          (SDL_Set_Render_Texture_Address_Mode
             (Self.Internal, U_Mode, V_Mode))
      then
         Raise_Renderer_Error;
      end if;
   end Set_Texture_Address_Modes;

   procedure Get_Texture_Address_Modes
     (Self   : in Renderer;
      U_Mode : out Texture_Address_Modes;
      V_Mode : out Texture_Address_Modes)
   is
      function SDL_Get_Render_Texture_Address_Mode
        (Renderer : in System.Address;
         U_Mode   : access Texture_Address_Modes;
         V_Mode   : access Texture_Address_Modes) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetRenderTextureAddressMode";

      Raw_U : aliased Texture_Address_Modes := Automatic_Addressing;
      Raw_V : aliased Texture_Address_Modes := Automatic_Addressing;
   begin
      Require_Renderer (Self);

      if not Boolean
          (SDL_Get_Render_Texture_Address_Mode
             (Self.Internal, Raw_U'Access, Raw_V'Access))
      then
         Raise_Renderer_Error;
      end if;

      U_Mode := Raw_U;
      V_Mode := Raw_V;
   end Get_Texture_Address_Modes;

   function Read_Pixels
     (Self : in Renderer) return SDL.Video.Surfaces.Surface
   is
      function SDL_Render_Read_Pixels
        (Renderer : in System.Address;
         Area     : in System.Address)
         return SDL.Video.Surfaces.Internal_Surface_Pointer
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_RenderReadPixels";

      Internal : SDL.Video.Surfaces.Internal_Surface_Pointer;
   begin
      Require_Renderer (Self);

      Internal := SDL_Render_Read_Pixels (Self.Internal, System.Null_Address);

      if Internal = null then
         Raise_Renderer_Error;
      end if;

      return Surface_Internal.Make_From_Pointer (Internal, Owns => True);
   end Read_Pixels;

   function Read_Pixels
     (Self : in Renderer;
      Area : in SDL.Video.Rectangles.Rectangle)
      return SDL.Video.Surfaces.Surface
   is
      function SDL_Render_Read_Pixels
        (Renderer : in System.Address;
         Area     : in System.Address)
         return SDL.Video.Surfaces.Internal_Surface_Pointer
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_RenderReadPixels";

      Raw_Area : aliased constant SDL.Video.Rectangles.Rectangle := Area;
      Internal : SDL.Video.Surfaces.Internal_Surface_Pointer;
   begin
      Require_Renderer (Self);

      Internal := SDL_Render_Read_Pixels (Self.Internal, Raw_Area'Address);

      if Internal = null then
         Raise_Renderer_Error;
      end if;

      return Surface_Internal.Make_From_Pointer (Internal, Owns => True);
   end Read_Pixels;

   procedure Present (Self : in out Renderer) is
      function SDL_Render_Present (Value : in System.Address) return CE.bool with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_RenderPresent";
   begin
      Require_Renderer (Self);

      if not Boolean (SDL_Render_Present (Self.Internal)) then
         Raise_Renderer_Error;
      end if;
   end Present;

   procedure Flush (Self : in out Renderer) is
      function SDL_Flush_Renderer
        (Renderer : in System.Address) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_FlushRenderer";
   begin
      Require_Renderer (Self);

      if not Boolean (SDL_Flush_Renderer (Self.Internal)) then
         Raise_Renderer_Error;
      end if;
   end Flush;

   function Get_Metal_Layer
     (Self : in Renderer) return System.Address
   is
      function SDL_Get_Render_Metal_Layer
        (Renderer : in System.Address) return System.Address
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetRenderMetalLayer";
   begin
      Require_Renderer (Self);
      return SDL_Get_Render_Metal_Layer (Self.Internal);
   end Get_Metal_Layer;

   function Get_Metal_Command_Encoder
     (Self : in Renderer) return System.Address
   is
      function SDL_Get_Render_Metal_Command_Encoder
        (Renderer : in System.Address) return System.Address
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetRenderMetalCommandEncoder";
   begin
      Require_Renderer (Self);
      return SDL_Get_Render_Metal_Command_Encoder (Self.Internal);
   end Get_Metal_Command_Encoder;

   procedure Add_Vulkan_Render_Semaphores
     (Self             : in out Renderer;
      Wait_Stage_Mask  : in Vulkan_Wait_Stage_Masks;
      Wait_Semaphore   : in Vulkan_Semaphores := No_Vulkan_Semaphore;
      Signal_Semaphore : in Vulkan_Semaphores := No_Vulkan_Semaphore)
   is
      function SDL_Add_Vulkan_Render_Semaphores
        (Renderer         : in System.Address;
         Wait_Stage_Mask  : in Vulkan_Wait_Stage_Masks;
         Wait_Semaphore   : in Vulkan_Semaphores;
         Signal_Semaphore : in Vulkan_Semaphores) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_AddVulkanRenderSemaphores";
   begin
      Require_Renderer (Self);

      if not Boolean
          (SDL_Add_Vulkan_Render_Semaphores
             (Self.Internal,
              Wait_Stage_Mask,
              Wait_Semaphore,
              Signal_Semaphore))
      then
         Raise_Renderer_Error;
      end if;
   end Add_Vulkan_Render_Semaphores;

   procedure Set_V_Sync
     (Self  : in out Renderer;
      Value : in Integer)
   is
      function SDL_Set_Render_VSync
        (Renderer : in System.Address;
         Value    : in C.int) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_SetRenderVSync";
   begin
      Require_Renderer (Self);

      if not Boolean
          (SDL_Set_Render_VSync (Self.Internal, C.int (Value)))
      then
         Raise_Renderer_Error;
      end if;
   end Set_V_Sync;

   function Get_V_Sync (Self : in Renderer) return Integer is
      function SDL_Get_Render_VSync
        (Renderer : in System.Address;
         Value    : access C.int) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetRenderVSync";

      Result : aliased C.int := 0;
   begin
      Require_Renderer (Self);

      if not Boolean
          (SDL_Get_Render_VSync (Self.Internal, Result'Access))
      then
         Raise_Renderer_Error;
      end if;

      return Integer (Result);
   end Get_V_Sync;

   procedure Debug_Text
     (Self : in out Renderer;
      X    : in Float;
      Y    : in Float;
      Text : in String)
   is
      function SDL_Render_Debug_Text
        (Renderer : in System.Address;
         X        : in Float;
         Y        : in Float;
         Text     : in C.char_array) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_RenderDebugText";
   begin
      Require_Renderer (Self);

      if not Boolean
          (SDL_Render_Debug_Text
             (Self.Internal, X, Y, C.To_C (Text)))
      then
         Raise_Renderer_Error;
      end if;
   end Debug_Text;

   procedure Debug_Text
     (Self     : in out Renderer;
      Position : in SDL.Video.Rectangles.Float_Point;
      Text     : in String)
   is
   begin
      Debug_Text (Self, Position.X, Position.Y, Text);
   end Debug_Text;

   procedure Set_Default_Texture_Scale_Mode
     (Self : in out Renderer;
      Mode : in SDL.Video.Textures.Scale_Modes)
   is
      function SDL_Set_Default_Texture_Scale_Mode
        (Renderer : in System.Address;
         Mode     : in SDL.Video.Textures.Scale_Modes) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_SetDefaultTextureScaleMode";
   begin
      Require_Renderer (Self);

      if not Boolean
          (SDL_Set_Default_Texture_Scale_Mode (Self.Internal, Mode))
      then
         Raise_Renderer_Error;
      end if;
   end Set_Default_Texture_Scale_Mode;

   function Get_Default_Texture_Scale_Mode
     (Self : in Renderer) return SDL.Video.Textures.Scale_Modes
   is
      function SDL_Get_Default_Texture_Scale_Mode
        (Renderer : in System.Address;
         Mode     : access SDL.Video.Textures.Scale_Modes) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetDefaultTextureScaleMode";

      Result : aliased SDL.Video.Textures.Scale_Modes :=
        SDL.Video.Textures.Invalid;
   begin
      Require_Renderer (Self);

      if not Boolean
          (SDL_Get_Default_Texture_Scale_Mode
             (Self.Internal, Result'Access))
      then
         Raise_Renderer_Error;
      end if;

      return Result;
   end Get_Default_Texture_Scale_Mode;

   overriding
   procedure Finalize (Self : in out Renderer) is
      procedure SDL_Destroy_Renderer (Value : in System.Address) with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_DestroyRenderer";
   begin
      if Self.Owns and then Self.Internal /= System.Null_Address then
         SDL_Destroy_Renderer (Self.Internal);
         Self.Internal := System.Null_Address;
      end if;
   end Finalize;
end SDL.Video.Renderers;
