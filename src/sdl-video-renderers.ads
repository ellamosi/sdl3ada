with Ada.Streams;
with Ada.Finalization;
with Interfaces;
with Interfaces.C;
with System;

with SDL.Events.Events;
with SDL.GPU;
with SDL.Properties;
with SDL.Video.Palettes;
with SDL.Video.Rectangles;
with SDL.Video.Surfaces;
with SDL.Video.Textures;
with SDL.Video.Windows;

package SDL.Video.Renderers is
   package C renames Interfaces.C;

   type Driver_Indices is range -1 .. C.int'Last with
     Convention => C;

   Renderer_Error : exception;

   type Renderer_Flags is mod 2 ** 32 with
     Convention => C;

   Default_Renderer_Flags : constant Renderer_Flags := 16#0000_0000#;
   Software               : constant Renderer_Flags := 16#0000_0001#;
   Accelerated            : constant Renderer_Flags := 16#0000_0002#;
   Present_V_Sync         : constant Renderer_Flags := 16#0000_0004#;
   Target_Texture         : constant Renderer_Flags := 16#0000_0008#;

   type Flip_Modes is
     (No_Flip,
      Horizontal_Flip,
      Vertical_Flip,
      Horizontal_And_Vertical_Flip)
   with
     Convention => C,
     Size       => C.int'Size;

   for Flip_Modes use
     (No_Flip                     => 0,
      Horizontal_Flip             => 1,
      Vertical_Flip               => 2,
      Horizontal_And_Vertical_Flip => 3);

   type Texture_Address_Modes is
     (Invalid_Address_Mode,
      Automatic_Addressing,
      Clamp_Addressing,
      Wrap_Addressing)
   with
     Convention => C,
     Size       => C.int'Size;

   for Texture_Address_Modes use
     (Invalid_Address_Mode => -1,
      Automatic_Addressing => 0,
      Clamp_Addressing     => 1,
      Wrap_Addressing      => 2);

   type Logical_Presentations is
     (Logical_Presentation_Disabled,
      Stretch_Presentation,
      Letterbox_Presentation,
      Overscan_Presentation,
      Integer_Scale_Presentation)
   with
     Convention => C,
     Size       => C.int'Size;

   for Logical_Presentations use
     (Logical_Presentation_Disabled => 0,
      Stretch_Presentation          => 1,
      Letterbox_Presentation        => 2,
      Overscan_Presentation         => 3,
      Integer_Scale_Presentation    => 4);

   subtype Vulkan_Wait_Stage_Masks is Interfaces.Unsigned_32;
   subtype Vulkan_Semaphores is Interfaces.Integer_64;

   No_Vulkan_Semaphore : constant Vulkan_Semaphores := 0;

   type Vertex_Colours is
      record
         Red   : Float := 0.0;
         Green : Float := 0.0;
         Blue  : Float := 0.0;
         Alpha : Float := 0.0;
      end record
   with Convention => C;

   type Vertices is
      record
         Position           : SDL.Video.Rectangles.Float_Point;
         Colour             : Vertex_Colours;
         Texture_Coordinate : SDL.Video.Rectangles.Float_Point;
      end record
   with Convention => C;

   type Vertex_Arrays is array (C.size_t range <>) of aliased Vertices with
     Convention => C;

   subtype Vertex_Indices is C.int;

   type Index_Arrays is array (C.size_t range <>) of aliased Vertex_Indices with
     Convention => C;

   type Renderer is new Ada.Finalization.Limited_Controlled with private;

   overriding
   procedure Finalize (Self : in out Renderer);

   type Texture_Sampler_Binding_Array_Access is access constant
     SDL.GPU.Texture_Sampler_Binding_Arrays;
   type Texture_Array_Access is access constant SDL.GPU.Texture_Arrays;
   type Buffer_Array_Access is access constant SDL.GPU.Buffer_Arrays;

   type GPU_Render_State_Create_Info is
      record
         Fragment_Shader  : SDL.GPU.Shader;
         Sampler_Bindings : Texture_Sampler_Binding_Array_Access := null;
         Storage_Textures : Texture_Array_Access := null;
         Storage_Buffers  : Buffer_Array_Access := null;
         Properties       : SDL.Properties.Property_ID :=
           SDL.Properties.Null_Property_ID;
      end record;

   type GPU_Render_State is private;

   function Is_Null (Self : in Renderer) return Boolean with
     Inline;

   function Total_Drivers return Natural;

   function Driver_Name (Driver : in Driver_Indices) return String;

   function Name (Self : in Renderer) return String;

   function Get
     (Window : in SDL.Video.Windows.Window) return Renderer;

   function Get
     (Texture : in SDL.Video.Textures.Texture) return Renderer;

   function Get_Window_ID
     (Self : in Renderer) return SDL.Video.Windows.ID;

   function Get_Properties
     (Self : in Renderer) return SDL.Properties.Property_ID;

   function Get_GPU_Device
     (Self : in Renderer) return SDL.GPU.Device;

   function Create_GPU_Render_State
     (Self        : in Renderer;
      Create_Info : in GPU_Render_State_Create_Info) return GPU_Render_State;

   procedure Create_GPU_Render_State
     (Self        : in out GPU_Render_State;
      Renderer    : in SDL.Video.Renderers.Renderer;
      Create_Info : in GPU_Render_State_Create_Info);

   procedure Destroy (Self : in out GPU_Render_State);

   function Is_Null (Self : in GPU_Render_State) return Boolean with
     Inline;

   procedure Set_Fragment_Uniform_Data
     (Self       : in out GPU_Render_State;
      Slot_Index : in Interfaces.Unsigned_32;
      Data       : in Ada.Streams.Stream_Element_Array);

   procedure Set_GPU_Render_State
     (Self  : in out Renderer;
      State : in GPU_Render_State);

   procedure Reset_GPU_Render_State (Self : in out Renderer);

   procedure Get_Output_Size
     (Self          : in Renderer;
      Width, Height : out SDL.Natural_Dimension);

   function Get_Output_Size (Self : in Renderer) return SDL.Sizes;

   procedure Get_Current_Output_Size
     (Self          : in Renderer;
      Width, Height : out SDL.Natural_Dimension);

   function Get_Current_Output_Size (Self : in Renderer) return SDL.Sizes;

   procedure Set_Target
     (Self    : in out Renderer;
      Texture : in SDL.Video.Textures.Texture);

   procedure Reset_Target (Self : in out Renderer);

   function Get_Target
     (Self : in Renderer) return SDL.Video.Textures.Texture;

   procedure Set_Logical_Presentation
     (Self : in out Renderer;
      Size : in SDL.Sizes;
      Mode : in Logical_Presentations);

   procedure Get_Logical_Presentation
     (Self          : in Renderer;
      Width, Height : out SDL.Natural_Dimension;
      Mode          : out Logical_Presentations);

   function Get_Logical_Presentation_Rectangle
     (Self : in Renderer) return SDL.Video.Rectangles.Float_Rectangle;

   procedure Window_Coordinates_To_Render
     (Self               : in Renderer;
      Window_X, Window_Y : in Float;
      X, Y               : out Float);

   function Window_Coordinates_To_Render
     (Self  : in Renderer;
      Point : in SDL.Video.Rectangles.Float_Point)
      return SDL.Video.Rectangles.Float_Point;

   procedure Render_Coordinates_To_Window
     (Self               : in Renderer;
      X, Y               : in Float;
      Window_X, Window_Y : out Float);

   function Render_Coordinates_To_Window
     (Self  : in Renderer;
      Point : in SDL.Video.Rectangles.Float_Point)
      return SDL.Video.Rectangles.Float_Point;

   procedure Convert_Event_Coordinates
     (Self  : in Renderer;
      Event : in out SDL.Events.Events.Events);

   procedure Set_Viewport
     (Self      : in out Renderer;
      Rectangle : in SDL.Video.Rectangles.Rectangle);

   procedure Reset_Viewport (Self : in out Renderer);

   function Get_Viewport
     (Self : in Renderer) return SDL.Video.Rectangles.Rectangle;

   function Is_Viewport_Set (Self : in Renderer) return Boolean;

   function Get_Safe_Area
     (Self : in Renderer) return SDL.Video.Rectangles.Rectangle;

   procedure Set_Clip
     (Self      : in out Renderer;
      Rectangle : in SDL.Video.Rectangles.Rectangle);

   procedure Disable_Clip (Self : in out Renderer);

   function Get_Clip
     (Self : in Renderer) return SDL.Video.Rectangles.Rectangle;

   function Is_Clip_Enabled (Self : in Renderer) return Boolean;

   procedure Set_Scale
     (Self    : in out Renderer;
      Scale_X : in Float;
      Scale_Y : in Float);

   procedure Get_Scale
     (Self    : in Renderer;
      Scale_X : out Float;
      Scale_Y : out Float);

   function Get_Scale
     (Self : in Renderer) return SDL.Video.Rectangles.Float_Point;

   function Get_Blend_Mode
     (Self : in Renderer) return SDL.Video.Blend_Modes;

   procedure Set_Blend_Mode
     (Self : in out Renderer;
      Mode : in SDL.Video.Blend_Modes);

   function Get_Draw_Colour
     (Self : in Renderer) return SDL.Video.Palettes.Colour;

   procedure Get_Draw_Colour
     (Self        : in Renderer;
      Red, Green  : out Float;
      Blue, Alpha : out Float);

   procedure Set_Draw_Colour
     (Self   : in out Renderer;
      Colour : in SDL.Video.Palettes.Colour);

   procedure Set_Draw_Colour
     (Self        : in out Renderer;
      Red, Green  : in Float;
      Blue, Alpha : in Float);

   function Get_Colour_Scale (Self : in Renderer) return Float;

   procedure Set_Colour_Scale
     (Self  : in out Renderer;
      Scale : in Float);

   procedure Clear (Self : in out Renderer);

   procedure Draw
     (Self  : in out Renderer;
      Point : in SDL.Video.Rectangles.Point);

   procedure Draw
     (Self   : in out Renderer;
      Points : in SDL.Video.Rectangles.Point_Arrays);

   procedure Draw_Connected
     (Self   : in out Renderer;
      Points : in SDL.Video.Rectangles.Point_Arrays);

   procedure Draw
     (Self : in out Renderer;
      Line : in SDL.Video.Rectangles.Line_Segment);

   procedure Draw
     (Self          : in out Renderer;
      X1, Y1, X2, Y2 : in SDL.Coordinate);

   procedure Draw
     (Self  : in out Renderer;
      Lines : in SDL.Video.Rectangles.Line_Arrays);

   procedure Draw
     (Self      : in out Renderer;
      Rectangle : in SDL.Video.Rectangles.Rectangle);

   procedure Draw
     (Self       : in out Renderer;
      Rectangles : in SDL.Video.Rectangles.Rectangle_Arrays);

   procedure Fill
     (Self      : in out Renderer;
      Rectangle : in SDL.Video.Rectangles.Rectangle);

   procedure Fill
     (Self       : in out Renderer;
      Rectangles : in SDL.Video.Rectangles.Rectangle_Arrays);

   procedure Draw
     (Self  : in out Renderer;
      Point : in SDL.Video.Rectangles.Float_Point);

   procedure Draw
     (Self   : in out Renderer;
      Points : in SDL.Video.Rectangles.Float_Point_Arrays);

   procedure Draw_Connected
     (Self   : in out Renderer;
      Points : in SDL.Video.Rectangles.Float_Point_Arrays);

   procedure Draw
     (Self : in out Renderer;
      Line : in SDL.Video.Rectangles.Float_Line_Segment);

   procedure Draw
     (Self           : in out Renderer;
      X1, Y1, X2, Y2 : in Float);

   procedure Draw
     (Self  : in out Renderer;
      Lines : in SDL.Video.Rectangles.Float_Line_Arrays);

   procedure Draw
     (Self      : in out Renderer;
      Rectangle : in SDL.Video.Rectangles.Float_Rectangle);

   procedure Draw
     (Self       : in out Renderer;
      Rectangles : in SDL.Video.Rectangles.Float_Rectangle_Arrays);

   procedure Fill
     (Self      : in out Renderer;
      Rectangle : in SDL.Video.Rectangles.Float_Rectangle);

   procedure Fill
     (Self       : in out Renderer;
      Rectangles : in SDL.Video.Rectangles.Float_Rectangle_Arrays);

   procedure Copy
     (Self    : in out Renderer;
      Texture : in SDL.Video.Textures.Texture);

   procedure Copy
     (Self    : in out Renderer;
      Texture : in SDL.Video.Textures.Texture;
      Source  : in SDL.Video.Rectangles.Rectangle;
      Target  : in SDL.Video.Rectangles.Rectangle);

   procedure Copy
     (Self    : in out Renderer;
      Texture : in SDL.Video.Textures.Texture;
      Source  : in SDL.Video.Rectangles.Float_Rectangle;
      Target  : in SDL.Video.Rectangles.Float_Rectangle);

   procedure Copy
     (Self    : in out Renderer;
      Texture : in SDL.Video.Textures.Texture;
      Source  : in SDL.Video.Rectangles.Rectangle;
      Target  : in SDL.Video.Rectangles.Float_Rectangle);

   procedure Copy_From
     (Self    : in out Renderer;
      Texture : in SDL.Video.Textures.Texture;
      Source  : in SDL.Video.Rectangles.Float_Rectangle);

   procedure Copy_From
     (Self    : in out Renderer;
      Texture : in SDL.Video.Textures.Texture;
      Source  : in SDL.Video.Rectangles.Rectangle);

   procedure Copy_To
     (Self    : in out Renderer;
      Texture : in SDL.Video.Textures.Texture;
      Target  : in SDL.Video.Rectangles.Rectangle);

   procedure Copy_To
     (Self    : in out Renderer;
      Texture : in SDL.Video.Textures.Texture;
      Target  : in SDL.Video.Rectangles.Float_Rectangle);

   procedure Copy_Rotated
     (Self    : in out Renderer;
      Texture : in SDL.Video.Textures.Texture;
      Angle   : in Long_Float;
      Centre  : in SDL.Video.Rectangles.Float_Point;
      Flip    : in Flip_Modes := No_Flip);

   procedure Copy_Rotated
     (Self    : in out Renderer;
      Texture : in SDL.Video.Textures.Texture;
      Target  : in SDL.Video.Rectangles.Rectangle;
      Angle   : in Long_Float;
      Centre  : in SDL.Video.Rectangles.Point;
      Flip    : in Flip_Modes := No_Flip);

   procedure Copy_Rotated
     (Self    : in out Renderer;
      Texture : in SDL.Video.Textures.Texture;
      Target  : in SDL.Video.Rectangles.Float_Rectangle;
      Angle   : in Long_Float;
      Centre  : in SDL.Video.Rectangles.Float_Point;
      Flip    : in Flip_Modes := No_Flip);

   procedure Copy_Rotated
     (Self    : in out Renderer;
      Texture : in SDL.Video.Textures.Texture;
      Source  : in SDL.Video.Rectangles.Rectangle;
      Target  : in SDL.Video.Rectangles.Rectangle;
      Angle   : in Long_Float;
      Centre  : in SDL.Video.Rectangles.Point;
      Flip    : in Flip_Modes := No_Flip);

   procedure Copy_Rotated
     (Self    : in out Renderer;
      Texture : in SDL.Video.Textures.Texture;
      Source  : in SDL.Video.Rectangles.Float_Rectangle;
      Target  : in SDL.Video.Rectangles.Float_Rectangle;
      Angle   : in Long_Float;
      Centre  : in SDL.Video.Rectangles.Float_Point;
      Flip    : in Flip_Modes := No_Flip);

   procedure Copy_Affine
     (Self    : in out Renderer;
      Texture : in SDL.Video.Textures.Texture;
      Origin  : in SDL.Video.Rectangles.Float_Point;
      Right   : in SDL.Video.Rectangles.Float_Point;
      Down    : in SDL.Video.Rectangles.Float_Point);

   procedure Copy_Affine
     (Self    : in out Renderer;
      Texture : in SDL.Video.Textures.Texture;
      Source  : in SDL.Video.Rectangles.Float_Rectangle;
      Origin  : in SDL.Video.Rectangles.Float_Point;
      Right   : in SDL.Video.Rectangles.Float_Point;
      Down    : in SDL.Video.Rectangles.Float_Point);

   procedure Copy_Tiled
     (Self    : in out Renderer;
      Texture : in SDL.Video.Textures.Texture;
      Scale   : in Float;
      Target  : in SDL.Video.Rectangles.Float_Rectangle);

   procedure Copy_Tiled
     (Self    : in out Renderer;
      Texture : in SDL.Video.Textures.Texture;
      Source  : in SDL.Video.Rectangles.Float_Rectangle;
      Scale   : in Float;
      Target  : in SDL.Video.Rectangles.Float_Rectangle);

   procedure Copy_9_Grid
     (Self          : in out Renderer;
      Texture       : in SDL.Video.Textures.Texture;
      Source        : in SDL.Video.Rectangles.Float_Rectangle;
      Left_Width    : in Float;
      Right_Width   : in Float;
      Top_Height    : in Float;
      Bottom_Height : in Float;
      Scale         : in Float;
      Target        : in SDL.Video.Rectangles.Float_Rectangle);

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
      Tile_Scale    : in Float);

   procedure Render_Geometry
     (Self     : in out Renderer;
      Vertices : in Vertex_Arrays);

   procedure Render_Geometry
     (Self     : in out Renderer;
      Vertices : in Vertex_Arrays;
      Indices  : in Index_Arrays);

   procedure Render_Geometry
     (Self     : in out Renderer;
      Texture  : in SDL.Video.Textures.Texture;
      Vertices : in Vertex_Arrays);

   procedure Render_Geometry
     (Self     : in out Renderer;
      Texture  : in SDL.Video.Textures.Texture;
      Vertices : in Vertex_Arrays;
      Indices  : in Index_Arrays);

   procedure Set_Texture_Address_Modes
     (Self   : in out Renderer;
      U_Mode : in Texture_Address_Modes;
      V_Mode : in Texture_Address_Modes);

   procedure Get_Texture_Address_Modes
     (Self   : in Renderer;
      U_Mode : out Texture_Address_Modes;
      V_Mode : out Texture_Address_Modes);

   function Read_Pixels
     (Self : in Renderer) return SDL.Video.Surfaces.Surface;

   function Read_Pixels
     (Self : in Renderer;
      Area : in SDL.Video.Rectangles.Rectangle)
      return SDL.Video.Surfaces.Surface;

   procedure Present (Self : in out Renderer);

   procedure Flush (Self : in out Renderer);

   function Get_Metal_Layer
     (Self : in Renderer) return System.Address;

   function Get_Metal_Command_Encoder
     (Self : in Renderer) return System.Address;

   procedure Add_Vulkan_Render_Semaphores
     (Self             : in out Renderer;
      Wait_Stage_Mask  : in Vulkan_Wait_Stage_Masks;
      Wait_Semaphore   : in Vulkan_Semaphores := No_Vulkan_Semaphore;
      Signal_Semaphore : in Vulkan_Semaphores := No_Vulkan_Semaphore);

   procedure Set_V_Sync
     (Self  : in out Renderer;
      Value : in Integer);

   function Get_V_Sync (Self : in Renderer) return Integer;

   Debug_Text_Character_Size : constant SDL.Positive_Dimension := 8;

   procedure Debug_Text
     (Self : in out Renderer;
      X    : in Float;
      Y    : in Float;
      Text : in String);

   procedure Debug_Text
     (Self     : in out Renderer;
      Position : in SDL.Video.Rectangles.Float_Point;
      Text     : in String);

   procedure Set_Default_Texture_Scale_Mode
     (Self : in out Renderer;
      Mode : in SDL.Video.Textures.Scale_Modes);

   function Get_Default_Texture_Scale_Mode
     (Self : in Renderer) return SDL.Video.Textures.Scale_Modes;

   function Get_Internal (Self : in Renderer) return System.Address with
     Inline;
private
   type GPU_Render_State is
      record
         Internal : System.Address := System.Null_Address;
         Owns     : Boolean        := True;
      end record;

   type Renderer is new Ada.Finalization.Limited_Controlled with
      record
         Internal : System.Address := System.Null_Address;
         Owns     : Boolean        := True;
      end record;
end SDL.Video.Renderers;
