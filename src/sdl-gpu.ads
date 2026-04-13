with Ada.Streams;
with Ada.Finalization;
with Interfaces;
with Interfaces.C;
with System;

with SDL.Properties;
with SDL.Raw.GPU;
with SDL.Video.Pixel_Formats;
with SDL.Video.Rectangles;
with SDL.Video.Windows;

package SDL.GPU is
   pragma Elaborate_Body;

   package C renames Interfaces.C;

   GPU_Error : exception;

   type Driver_Indices is range -1 .. C.int'Last with
     Convention => C;

   subtype Device_Handle is SDL.Raw.GPU.Device_Access;
   subtype Buffer_Handle is SDL.Raw.GPU.Buffer_Access;
   subtype Texture_Handle is SDL.Raw.GPU.Texture_Access;
   subtype Sampler_Handle is SDL.Raw.GPU.Sampler_Access;
   subtype Shader_Handle is SDL.Raw.GPU.Shader_Access;
   subtype Graphics_Pipeline_Handle is SDL.Raw.GPU.Graphics_Pipeline_Access;
   subtype Compute_Pipeline_Handle is SDL.Raw.GPU.Compute_Pipeline_Access;
   subtype Command_Buffer_Handle is SDL.Raw.GPU.Command_Buffer_Access;
   subtype Render_Pass_Handle is SDL.Raw.GPU.Render_Pass_Access;
   subtype Compute_Pass_Handle is SDL.Raw.GPU.Compute_Pass_Access;
   subtype Copy_Pass_Handle is SDL.Raw.GPU.Copy_Pass_Access;
   subtype Fence_Handle is SDL.Raw.GPU.Fence_Access;
   subtype Shader_Formats is SDL.Raw.GPU.Shader_Formats;
   subtype Texture_Formats is SDL.Raw.GPU.Texture_Formats;
   subtype Texture_Usage_Flags is SDL.Raw.GPU.Texture_Usage_Flags;
   subtype Buffer_Usage_Flags is SDL.Raw.GPU.Buffer_Usage_Flags;
   subtype Float_Colour is SDL.Raw.GPU.Float_Colour;
   subtype Viewport is SDL.Raw.GPU.Viewport;

   Invalid_Shader_Format  : constant Shader_Formats :=
     SDL.Raw.GPU.Invalid_Shader_Format;
   Private_Shader_Format  : constant Shader_Formats :=
     SDL.Raw.GPU.Private_Shader_Format;
   SPIRV_Shader_Format    : constant Shader_Formats :=
     SDL.Raw.GPU.SPIRV_Shader_Format;
   DXBC_Shader_Format     : constant Shader_Formats :=
     SDL.Raw.GPU.DXBC_Shader_Format;
   DXIL_Shader_Format     : constant Shader_Formats :=
     SDL.Raw.GPU.DXIL_Shader_Format;
   MSL_Shader_Format      : constant Shader_Formats :=
     SDL.Raw.GPU.MSL_Shader_Format;
   Metallib_Shader_Format : constant Shader_Formats :=
     SDL.Raw.GPU.Metallib_Shader_Format;

   Invalid_Texture_Format : constant Texture_Formats :=
     SDL.Raw.GPU.Invalid_Texture_Format;

   Texture_Usage_Sampler : constant Texture_Usage_Flags :=
     SDL.Raw.GPU.Texture_Usage_Sampler;
   Texture_Usage_Color_Target : constant Texture_Usage_Flags :=
     SDL.Raw.GPU.Texture_Usage_Color_Target;
   Texture_Usage_Depth_Stencil_Target : constant Texture_Usage_Flags :=
     SDL.Raw.GPU.Texture_Usage_Depth_Stencil_Target;
   Texture_Usage_Graphics_Storage_Read : constant Texture_Usage_Flags :=
     SDL.Raw.GPU.Texture_Usage_Graphics_Storage_Read;
   Texture_Usage_Compute_Storage_Read : constant Texture_Usage_Flags :=
     SDL.Raw.GPU.Texture_Usage_Compute_Storage_Read;
   Texture_Usage_Compute_Storage_Write : constant Texture_Usage_Flags :=
     SDL.Raw.GPU.Texture_Usage_Compute_Storage_Write;
   Texture_Usage_Compute_Storage_Simultaneous_Read_Write :
     constant Texture_Usage_Flags :=
       SDL.Raw.GPU.Texture_Usage_Compute_Storage_Simultaneous_Read_Write;

   Buffer_Usage_Vertex : constant Buffer_Usage_Flags :=
     SDL.Raw.GPU.Buffer_Usage_Vertex;
   Buffer_Usage_Index : constant Buffer_Usage_Flags :=
     SDL.Raw.GPU.Buffer_Usage_Index;
   Buffer_Usage_Indirect : constant Buffer_Usage_Flags :=
     SDL.Raw.GPU.Buffer_Usage_Indirect;
   Buffer_Usage_Graphics_Storage_Read : constant Buffer_Usage_Flags :=
     SDL.Raw.GPU.Buffer_Usage_Graphics_Storage_Read;
   Buffer_Usage_Compute_Storage_Read : constant Buffer_Usage_Flags :=
     SDL.Raw.GPU.Buffer_Usage_Compute_Storage_Read;
   Buffer_Usage_Compute_Storage_Write : constant Buffer_Usage_Flags :=
     SDL.Raw.GPU.Buffer_Usage_Compute_Storage_Write;

   type Load_Operations is
     (Load,
      Clear,
      Dont_Care)
   with
     Convention => C,
     Size       => C.int'Size;

   for Load_Operations use
     (Load      => SDL.Raw.GPU.Load_Load,
      Clear     => SDL.Raw.GPU.Load_Clear,
      Dont_Care => SDL.Raw.GPU.Load_Dont_Care);

   type Store_Operations is
     (Store,
      Store_Dont_Care,
      Resolve,
      Resolve_And_Store)
   with
     Convention => C,
     Size       => C.int'Size;

   for Store_Operations use
     (Store             => SDL.Raw.GPU.Store_Store,
      Store_Dont_Care   => SDL.Raw.GPU.Store_Dont_Care,
      Resolve           => SDL.Raw.GPU.Store_Resolve,
      Resolve_And_Store => SDL.Raw.GPU.Store_Resolve_And_Store);

   type Present_Modes is
     (V_Sync,
      Immediate,
      Mailbox)
   with
     Convention => C,
     Size       => C.int'Size;

   for Present_Modes use
     (V_Sync    => SDL.Raw.GPU.Present_V_Sync,
      Immediate => SDL.Raw.GPU.Present_Immediate,
      Mailbox   => SDL.Raw.GPU.Present_Mailbox);

   type Swapchain_Compositions is
     (Swapchain_SDR,
      Swapchain_SDR_Linear,
      Swapchain_HDR_Extended_Linear,
      Swapchain_HDR10_ST2084)
   with
     Convention => C,
     Size       => C.int'Size;

   for Swapchain_Compositions use
     (Swapchain_SDR                 => SDL.Raw.GPU.Swapchain_SDR,
      Swapchain_SDR_Linear          => SDL.Raw.GPU.Swapchain_SDR_Linear,
      Swapchain_HDR_Extended_Linear => SDL.Raw.GPU.Swapchain_HDR_Extended_Linear,
      Swapchain_HDR10_ST2084        => SDL.Raw.GPU.Swapchain_HDR10_ST2084);

   type Texture_Types is
     (Texture_2D,
      Texture_2D_Array,
      Texture_3D,
      Texture_Cube,
      Texture_Cube_Array)
   with
     Convention => C,
     Size       => C.int'Size;

   for Texture_Types use
     (Texture_2D         => SDL.Raw.GPU.Texture_2D,
      Texture_2D_Array   => SDL.Raw.GPU.Texture_2D_Array,
      Texture_3D         => SDL.Raw.GPU.Texture_3D,
      Texture_Cube       => SDL.Raw.GPU.Texture_Cube,
      Texture_Cube_Array => SDL.Raw.GPU.Texture_Cube_Array);

   type Sample_Counts is
     (Sample_Count_1,
      Sample_Count_2,
      Sample_Count_4,
      Sample_Count_8)
   with
     Convention => C,
     Size       => C.int'Size;

   for Sample_Counts use
     (Sample_Count_1 => SDL.Raw.GPU.Sample_Count_1,
      Sample_Count_2 => SDL.Raw.GPU.Sample_Count_2,
      Sample_Count_4 => SDL.Raw.GPU.Sample_Count_4,
      Sample_Count_8 => SDL.Raw.GPU.Sample_Count_8);

   type Transfer_Buffer_Usages is
     (Upload,
      Download)
   with
     Convention => C,
     Size       => C.int'Size;

   for Transfer_Buffer_Usages use
     (Upload   => SDL.Raw.GPU.Transfer_Buffer_Upload,
      Download => SDL.Raw.GPU.Transfer_Buffer_Download);

   type Primitive_Types is
     (Triangle_List,
      Triangle_Strip,
      Line_List,
      Line_Strip,
      Point_List)
   with
     Convention => C,
     Size       => C.int'Size;

   for Primitive_Types use
     (Triangle_List  => SDL.Raw.GPU.Primitive_Triangle_List,
      Triangle_Strip => SDL.Raw.GPU.Primitive_Triangle_Strip,
      Line_List      => SDL.Raw.GPU.Primitive_Line_List,
      Line_Strip     => SDL.Raw.GPU.Primitive_Line_Strip,
      Point_List     => SDL.Raw.GPU.Primitive_Point_List);

   type Index_Element_Sizes is
     (Index_Elements_16_Bit,
      Index_Elements_32_Bit)
   with
     Convention => C,
     Size       => C.int'Size;

   for Index_Element_Sizes use
     (Index_Elements_16_Bit => SDL.Raw.GPU.Index_Element_Size_16_Bit,
      Index_Elements_32_Bit => SDL.Raw.GPU.Index_Element_Size_32_Bit);

   type Shader_Stages is
     (Vertex_Shader,
      Fragment_Shader)
   with
     Convention => C,
     Size       => C.int'Size;

   for Shader_Stages use
     (Vertex_Shader   => SDL.Raw.GPU.Shader_Stage_Vertex,
      Fragment_Shader => SDL.Raw.GPU.Shader_Stage_Fragment);

   type Vertex_Element_Formats is
     (Invalid_Vertex_Element,
      Int_Element,
      Int2_Element,
      Int3_Element,
      Int4_Element,
      UInt_Element,
      UInt2_Element,
      UInt3_Element,
      UInt4_Element,
      Float_Element,
      Float2_Element,
      Float3_Element,
      Float4_Element,
      Byte2_Element,
      Byte4_Element,
      UByte2_Element,
      UByte4_Element,
      Byte2_Norm_Element,
      Byte4_Norm_Element,
      UByte2_Norm_Element,
      UByte4_Norm_Element,
      Short2_Element,
      Short4_Element,
      UShort2_Element,
      UShort4_Element,
      Short2_Norm_Element,
      Short4_Norm_Element,
      UShort2_Norm_Element,
      UShort4_Norm_Element,
      Half2_Element,
      Half4_Element)
   with
     Convention => C,
     Size       => C.int'Size;

   for Vertex_Element_Formats use
     (Invalid_Vertex_Element => SDL.Raw.GPU.Vertex_Element_Invalid,
      Int_Element            => SDL.Raw.GPU.Vertex_Element_Int,
      Int2_Element           => SDL.Raw.GPU.Vertex_Element_Int2,
      Int3_Element           => SDL.Raw.GPU.Vertex_Element_Int3,
      Int4_Element           => SDL.Raw.GPU.Vertex_Element_Int4,
      UInt_Element           => SDL.Raw.GPU.Vertex_Element_UInt,
      UInt2_Element          => SDL.Raw.GPU.Vertex_Element_UInt2,
      UInt3_Element          => SDL.Raw.GPU.Vertex_Element_UInt3,
      UInt4_Element          => SDL.Raw.GPU.Vertex_Element_UInt4,
      Float_Element          => SDL.Raw.GPU.Vertex_Element_Float,
      Float2_Element         => SDL.Raw.GPU.Vertex_Element_Float2,
      Float3_Element         => SDL.Raw.GPU.Vertex_Element_Float3,
      Float4_Element         => SDL.Raw.GPU.Vertex_Element_Float4,
      Byte2_Element          => SDL.Raw.GPU.Vertex_Element_Byte2,
      Byte4_Element          => SDL.Raw.GPU.Vertex_Element_Byte4,
      UByte2_Element         => SDL.Raw.GPU.Vertex_Element_UByte2,
      UByte4_Element         => SDL.Raw.GPU.Vertex_Element_UByte4,
      Byte2_Norm_Element     => SDL.Raw.GPU.Vertex_Element_Byte2_Norm,
      Byte4_Norm_Element     => SDL.Raw.GPU.Vertex_Element_Byte4_Norm,
      UByte2_Norm_Element    => SDL.Raw.GPU.Vertex_Element_UByte2_Norm,
      UByte4_Norm_Element    => SDL.Raw.GPU.Vertex_Element_UByte4_Norm,
      Short2_Element         => SDL.Raw.GPU.Vertex_Element_Short2,
      Short4_Element         => SDL.Raw.GPU.Vertex_Element_Short4,
      UShort2_Element        => SDL.Raw.GPU.Vertex_Element_UShort2,
      UShort4_Element        => SDL.Raw.GPU.Vertex_Element_UShort4,
      Short2_Norm_Element    => SDL.Raw.GPU.Vertex_Element_Short2_Norm,
      Short4_Norm_Element    => SDL.Raw.GPU.Vertex_Element_Short4_Norm,
      UShort2_Norm_Element   => SDL.Raw.GPU.Vertex_Element_UShort2_Norm,
      UShort4_Norm_Element   => SDL.Raw.GPU.Vertex_Element_UShort4_Norm,
      Half2_Element          => SDL.Raw.GPU.Vertex_Element_Half2,
      Half4_Element          => SDL.Raw.GPU.Vertex_Element_Half4);

   type Vertex_Input_Rates is
     (Per_Vertex,
      Per_Instance)
   with
     Convention => C,
     Size       => C.int'Size;

   for Vertex_Input_Rates use
     (Per_Vertex   => SDL.Raw.GPU.Vertex_Input_Rate_Vertex,
      Per_Instance => SDL.Raw.GPU.Vertex_Input_Rate_Instance);

   type Fill_Modes is
     (Fill,
      Line)
   with
     Convention => C,
     Size       => C.int'Size;

   for Fill_Modes use
     (Fill => SDL.Raw.GPU.Fill_Mode_Fill,
      Line => SDL.Raw.GPU.Fill_Mode_Line);

   type Cull_Modes is
     (Cull_None,
      Cull_Front,
      Cull_Back)
   with
     Convention => C,
     Size       => C.int'Size;

   for Cull_Modes use
     (Cull_None  => SDL.Raw.GPU.Cull_Mode_None,
      Cull_Front => SDL.Raw.GPU.Cull_Mode_Front,
      Cull_Back  => SDL.Raw.GPU.Cull_Mode_Back);

   type Front_Faces is
     (Counter_Clockwise,
      Clockwise)
   with
     Convention => C,
     Size       => C.int'Size;

   for Front_Faces use
     (Counter_Clockwise => SDL.Raw.GPU.Front_Face_Counter_Clockwise,
      Clockwise         => SDL.Raw.GPU.Front_Face_Clockwise);

   type Compare_Operations is
     (Invalid_Compare_Operation,
      Never,
      Less,
      Equal,
      Less_Or_Equal,
      Greater,
      Not_Equal,
      Greater_Or_Equal,
      Always)
   with
     Convention => C,
     Size       => C.int'Size;

   for Compare_Operations use
     (Invalid_Compare_Operation => SDL.Raw.GPU.Compare_Op_Invalid,
      Never                     => SDL.Raw.GPU.Compare_Op_Never,
      Less                      => SDL.Raw.GPU.Compare_Op_Less,
      Equal                     => SDL.Raw.GPU.Compare_Op_Equal,
      Less_Or_Equal             => SDL.Raw.GPU.Compare_Op_Less_Or_Equal,
      Greater                   => SDL.Raw.GPU.Compare_Op_Greater,
      Not_Equal                 => SDL.Raw.GPU.Compare_Op_Not_Equal,
      Greater_Or_Equal          => SDL.Raw.GPU.Compare_Op_Greater_Or_Equal,
      Always                    => SDL.Raw.GPU.Compare_Op_Always);

   type Stencil_Operations is
     (Invalid_Stencil_Operation,
      Keep,
      Zero,
      Replace,
      Increment_And_Clamp,
      Decrement_And_Clamp,
      Invert,
      Increment_And_Wrap,
      Decrement_And_Wrap)
   with
     Convention => C,
     Size       => C.int'Size;

   for Stencil_Operations use
     (Invalid_Stencil_Operation => SDL.Raw.GPU.Stencil_Op_Invalid,
      Keep                      => SDL.Raw.GPU.Stencil_Op_Keep,
      Zero                      => SDL.Raw.GPU.Stencil_Op_Zero,
      Replace                   => SDL.Raw.GPU.Stencil_Op_Replace,
      Increment_And_Clamp       => SDL.Raw.GPU.Stencil_Op_Increment_And_Clamp,
      Decrement_And_Clamp       => SDL.Raw.GPU.Stencil_Op_Decrement_And_Clamp,
      Invert                    => SDL.Raw.GPU.Stencil_Op_Invert,
      Increment_And_Wrap        => SDL.Raw.GPU.Stencil_Op_Increment_And_Wrap,
      Decrement_And_Wrap        => SDL.Raw.GPU.Stencil_Op_Decrement_And_Wrap);

   type Blend_Operations is
     (Invalid_Blend_Operation,
      Blend_Add,
      Blend_Subtract,
      Blend_Reverse_Subtract,
      Blend_Min,
      Blend_Max)
   with
     Convention => C,
     Size       => C.int'Size;

   for Blend_Operations use
     (Invalid_Blend_Operation => SDL.Raw.GPU.Blend_Op_Invalid,
      Blend_Add               => SDL.Raw.GPU.Blend_Op_Add,
      Blend_Subtract          => SDL.Raw.GPU.Blend_Op_Subtract,
      Blend_Reverse_Subtract  => SDL.Raw.GPU.Blend_Op_Reverse_Subtract,
      Blend_Min               => SDL.Raw.GPU.Blend_Op_Min,
      Blend_Max               => SDL.Raw.GPU.Blend_Op_Max);

   type Blend_Factors is
     (Invalid_Blend_Factor,
      Blend_Zero,
      Blend_One,
      Source_Colour,
      One_Minus_Source_Colour,
      Destination_Colour,
      One_Minus_Destination_Colour,
      Source_Alpha,
      One_Minus_Source_Alpha,
      Destination_Alpha,
      One_Minus_Destination_Alpha,
      Constant_Colour,
      One_Minus_Constant_Colour,
      Source_Alpha_Saturate)
   with
     Convention => C,
     Size       => C.int'Size;

   for Blend_Factors use
     (Invalid_Blend_Factor        => SDL.Raw.GPU.Blend_Factor_Invalid,
      Blend_Zero                  => SDL.Raw.GPU.Blend_Factor_Zero,
      Blend_One                   => SDL.Raw.GPU.Blend_Factor_One,
      Source_Colour               => SDL.Raw.GPU.Blend_Factor_Source_Colour,
      One_Minus_Source_Colour     => SDL.Raw.GPU.Blend_Factor_One_Minus_Source_Colour,
      Destination_Colour          => SDL.Raw.GPU.Blend_Factor_Destination_Colour,
      One_Minus_Destination_Colour => SDL.Raw.GPU.Blend_Factor_One_Minus_Destination_Colour,
      Source_Alpha                => SDL.Raw.GPU.Blend_Factor_Source_Alpha,
      One_Minus_Source_Alpha      => SDL.Raw.GPU.Blend_Factor_One_Minus_Source_Alpha,
      Destination_Alpha           => SDL.Raw.GPU.Blend_Factor_Destination_Alpha,
      One_Minus_Destination_Alpha => SDL.Raw.GPU.Blend_Factor_One_Minus_Destination_Alpha,
      Constant_Colour             => SDL.Raw.GPU.Blend_Factor_Constant_Colour,
      One_Minus_Constant_Colour   => SDL.Raw.GPU.Blend_Factor_One_Minus_Constant_Colour,
      Source_Alpha_Saturate       => SDL.Raw.GPU.Blend_Factor_Source_Alpha_Saturate);

   subtype Color_Component_Flags is SDL.Raw.GPU.Color_Component_Flags;

   Color_Component_R : constant Color_Component_Flags :=
     SDL.Raw.GPU.Color_Component_R;
   Color_Component_G : constant Color_Component_Flags :=
     SDL.Raw.GPU.Color_Component_G;
   Color_Component_B : constant Color_Component_Flags :=
     SDL.Raw.GPU.Color_Component_B;
   Color_Component_A : constant Color_Component_Flags :=
     SDL.Raw.GPU.Color_Component_A;

   type Filters is
     (Nearest,
      Linear)
   with
     Convention => C,
     Size       => C.int'Size;

   for Filters use
     (Nearest => SDL.Raw.GPU.Filter_Nearest,
      Linear  => SDL.Raw.GPU.Filter_Linear);

   type Sampler_Mipmap_Modes is
     (Mipmap_Nearest,
      Mipmap_Linear)
   with
     Convention => C,
     Size       => C.int'Size;

   for Sampler_Mipmap_Modes use
     (Mipmap_Nearest => SDL.Raw.GPU.Sampler_Mipmap_Mode_Nearest,
      Mipmap_Linear  => SDL.Raw.GPU.Sampler_Mipmap_Mode_Linear);

   type Sampler_Address_Modes is
     (Repeat,
      Mirrored_Repeat,
      Clamp_To_Edge)
   with
     Convention => C,
     Size       => C.int'Size;

   for Sampler_Address_Modes use
     (Repeat          => SDL.Raw.GPU.Sampler_Address_Mode_Repeat,
      Mirrored_Repeat => SDL.Raw.GPU.Sampler_Address_Mode_Mirrored_Repeat,
      Clamp_To_Edge   => SDL.Raw.GPU.Sampler_Address_Mode_Clamp_To_Edge);

   type Flip_Modes is
     (No_Flip,
      Horizontal_Flip,
      Vertical_Flip,
      Horizontal_And_Vertical_Flip)
   with
     Convention => C,
     Size       => C.int'Size;

   for Flip_Modes use
     (No_Flip                     => SDL.Raw.GPU.Flip_None,
      Horizontal_Flip             => SDL.Raw.GPU.Flip_Horizontal,
      Vertical_Flip               => SDL.Raw.GPU.Flip_Vertical,
      Horizontal_And_Vertical_Flip => SDL.Raw.GPU.Flip_Horizontal_And_Vertical);

   Device_Name_Property           : constant String := "SDL.gpu.device.name";
   Device_Driver_Name_Property    : constant String := "SDL.gpu.device.driver_name";
   Device_Driver_Version_Property : constant String :=
     "SDL.gpu.device.driver_version";
   Device_Driver_Info_Property    : constant String :=
     "SDL.gpu.device.driver_info";

   Create_Debug_Mode_Property      : constant String :=
     "SDL.gpu.device.create.debugmode";
   Create_Prefer_Low_Power_Property : constant String :=
     "SDL.gpu.device.create.preferlowpower";
   Create_Verbose_Property         : constant String :=
     "SDL.gpu.device.create.verbose";
   Create_Name_Property            : constant String :=
     "SDL.gpu.device.create.name";
   Create_Shader_SPIRV_Property    : constant String :=
     "SDL.gpu.device.create.shaders.spirv";
   Create_Shader_DXBC_Property     : constant String :=
     "SDL.gpu.device.create.shaders.dxbc";
   Create_Shader_DXIL_Property     : constant String :=
     "SDL.gpu.device.create.shaders.dxil";
   Create_Shader_MSL_Property      : constant String :=
     "SDL.gpu.device.create.shaders.msl";
   Create_Shader_Metallib_Property : constant String :=
     "SDL.gpu.device.create.shaders.metallib";
   Texture_Create_Name_Property    : constant String :=
     "SDL.gpu.texture.create.name";
   Buffer_Create_Name_Property     : constant String :=
     "SDL.gpu.buffer.create.name";
   Transfer_Buffer_Create_Name_Property : constant String :=
     "SDL.gpu.transferbuffer.create.name";
   Compute_Pipeline_Create_Name_Property : constant String :=
     "SDL.gpu.computepipeline.create.name";
   Graphics_Pipeline_Create_Name_Property : constant String :=
     "SDL.gpu.graphicspipeline.create.name";
   Sampler_Create_Name_Property : constant String :=
     "SDL.gpu.sampler.create.name";
   Shader_Create_Name_Property : constant String :=
     "SDL.gpu.shader.create.name";

   type Device is new Ada.Finalization.Limited_Controlled with private;

   overriding
   procedure Finalize (Self : in out Device);

   type Buffer is private;

   type Transfer_Buffer is private;

   type Texture is private;
   type Sampler is private;
   type Shader is private;
   type Graphics_Pipeline is private;
   type Compute_Pipeline is private;

   type Command_Buffer is private;
   type Render_Pass is private;
   type Compute_Pass is private;
   type Copy_Pass is private;
   type Fence is private;

   type Vertex_Buffer_Description is
      record
         Slot               : Interfaces.Unsigned_32 := 0;
         Pitch              : Interfaces.Unsigned_32 := 0;
         Input_Rate         : Vertex_Input_Rates := Per_Vertex;
         Instance_Step_Rate : Interfaces.Unsigned_32 := 0;
      end record;

   type Vertex_Buffer_Description_Arrays is
     array (Natural range <>) of Vertex_Buffer_Description;

   type Vertex_Attribute is
      record
         Location    : Interfaces.Unsigned_32 := 0;
         Buffer_Slot : Interfaces.Unsigned_32 := 0;
         Format      : Vertex_Element_Formats := Invalid_Vertex_Element;
         Offset      : Interfaces.Unsigned_32 := 0;
      end record;

   type Vertex_Attribute_Arrays is array (Natural range <>) of Vertex_Attribute;

   type Stencil_Op_State is
      record
         Fail_Operation       : Stencil_Operations := Keep;
         Pass_Operation       : Stencil_Operations := Keep;
         Depth_Fail_Operation : Stencil_Operations := Keep;
         Compare_Operation    : Compare_Operations := Always;
      end record;

   type Color_Target_Blend_State is
      record
         Source_Colour_Blend_Factor      : Blend_Factors := Blend_One;
         Destination_Colour_Blend_Factor : Blend_Factors := Blend_Zero;
         Colour_Blend_Operation          : Blend_Operations := Blend_Add;
         Source_Alpha_Blend_Factor       : Blend_Factors := Blend_One;
         Destination_Alpha_Blend_Factor  : Blend_Factors := Blend_Zero;
         Alpha_Blend_Operation           : Blend_Operations := Blend_Add;
         Colour_Write_Mask               : Color_Component_Flags := 16#0F#;
         Enable_Blend                    : Boolean := False;
         Enable_Colour_Write_Mask        : Boolean := False;
      end record;

   type Rasterizer_State is
      record
         Fill_Mode                  : Fill_Modes := Fill;
         Cull_Mode                  : Cull_Modes := Cull_None;
         Front_Face                 : Front_Faces := Counter_Clockwise;
         Depth_Bias_Constant_Factor : Float := 0.0;
         Depth_Bias_Clamp           : Float := 0.0;
         Depth_Bias_Slope_Factor    : Float := 0.0;
         Enable_Depth_Bias          : Boolean := False;
         Enable_Depth_Clip          : Boolean := True;
      end record;

   type Multisample_State is
      record
         Sample_Count             : Sample_Counts := Sample_Count_1;
         Sample_Mask              : Interfaces.Unsigned_32 := 0;
         Enable_Mask              : Boolean := False;
         Enable_Alpha_To_Coverage : Boolean := False;
      end record;

   type Depth_Stencil_State is
      record
         Compare_Operation   : Compare_Operations := Always;
         Back_Stencil_State  : Stencil_Op_State :=
           (Fail_Operation       => Keep,
            Pass_Operation       => Keep,
            Depth_Fail_Operation => Keep,
            Compare_Operation    => Always);
         Front_Stencil_State : Stencil_Op_State :=
           (Fail_Operation       => Keep,
            Pass_Operation       => Keep,
            Depth_Fail_Operation => Keep,
            Compare_Operation    => Always);
         Compare_Mask        : Interfaces.Unsigned_8 := 0;
         Write_Mask          : Interfaces.Unsigned_8 := 0;
         Enable_Depth_Test   : Boolean := False;
         Enable_Depth_Write  : Boolean := False;
         Enable_Stencil_Test : Boolean := False;
      end record;

   type Color_Target_Description is
      record
         Format      : Texture_Formats := Invalid_Texture_Format;
         Blend_State : Color_Target_Blend_State :=
           (Source_Colour_Blend_Factor      => Blend_One,
            Destination_Colour_Blend_Factor => Blend_Zero,
            Colour_Blend_Operation          => Blend_Add,
            Source_Alpha_Blend_Factor       => Blend_One,
            Destination_Alpha_Blend_Factor  => Blend_Zero,
            Alpha_Blend_Operation           => Blend_Add,
            Colour_Write_Mask               => 16#0F#,
            Enable_Blend             => False,
            Enable_Colour_Write_Mask => False);
      end record;

   type Color_Target_Description_Arrays is
     array (Natural range <>) of Color_Target_Description;

   type Buffer_Arrays is array (Natural range <>) of Buffer;
   type Texture_Arrays is array (Natural range <>) of Texture;

   type Color_Target_Info is private;
   type Color_Target_Info_Arrays is array (Natural range <>) of Color_Target_Info;
   type Depth_Stencil_Target_Info is private;
   type Texture_Transfer_Info is private;
   type Transfer_Buffer_Location is private;
   type Texture_Location is private;
   type Texture_Region is private;
   type Buffer_Location is private;
   type Buffer_Region is private;
   type Buffer_Binding is private;
   type Buffer_Binding_Arrays is array (Natural range <>) of Buffer_Binding;
   type Texture_Sampler_Binding is private;
   type Texture_Sampler_Binding_Arrays is
     array (Natural range <>) of Texture_Sampler_Binding;
   type Storage_Buffer_Read_Write_Binding is private;
   type Storage_Buffer_Read_Write_Binding_Arrays is
     array (Natural range <>) of Storage_Buffer_Read_Write_Binding;
   type Storage_Texture_Read_Write_Binding is private;
   type Storage_Texture_Read_Write_Binding_Arrays is
     array (Natural range <>) of Storage_Texture_Read_Write_Binding;
   type Blit_Region is private;
   type Blit_Info is private;

   function Default_Shader_Formats return Shader_Formats;

   function Supports_Shader_Formats
     (Formats : in Shader_Formats;
      Name    : in String := "") return Boolean;

   function Supports_Properties
     (Properties : in SDL.Properties.Property_Set) return Boolean;

   function Total_Drivers return Natural;
   function Driver_Name (Index : in Driver_Indices) return String;

   function Create
     (Formats    : in Shader_Formats;
      Debug_Mode : in Boolean := False;
      Name       : in String := "") return Device;

   procedure Create
     (Self       : in out Device;
      Formats    : in Shader_Formats;
      Debug_Mode : in Boolean := False;
      Name       : in String := "");

   function Create_With_Properties
     (Properties : in SDL.Properties.Property_Set) return Device;

   procedure Create_With_Properties
     (Self       : in out Device;
      Properties : in SDL.Properties.Property_Set);

   function Make_Device_From_Pointer
     (Internal : in Device_Handle;
      Owns     : in Boolean := False) return Device;

   procedure Destroy (Self : in out Device);

   function Is_Null (Self : in Device) return Boolean with
     Inline;

   function Get_Handle (Self : in Device) return Device_Handle with
     Inline;

   function Driver_Name (Self : in Device) return String;

   function Supported_Shader_Formats
     (Self : in Device) return Shader_Formats;

   function Get_Properties
     (Self : in Device) return SDL.Properties.Property_ID;

   function Texture_Format_Texel_Block_Size
     (Format : in Texture_Formats) return Interfaces.Unsigned_32;

   function Texture_Supports_Format
     (Self   : in Device;
      Format : in Texture_Formats;
      Kind   : in Texture_Types;
      Usage  : in Texture_Usage_Flags) return Boolean;

   function Texture_Supports_Sample_Count
     (Self         : in Device;
      Format       : in Texture_Formats;
      Sample_Count : in Sample_Counts) return Boolean;

   function Calculate_Texture_Format_Size
     (Format               : in Texture_Formats;
      Width                : in Interfaces.Unsigned_32;
      Height               : in Interfaces.Unsigned_32;
      Depth_Or_Layer_Count : in Interfaces.Unsigned_32)
      return Interfaces.Unsigned_32;

   function Pixel_Format_From_Texture_Format
     (Format : in Texture_Formats)
      return SDL.Video.Pixel_Formats.Pixel_Format_Names;

   function Texture_Format_From_Pixel_Format
     (Format : in SDL.Video.Pixel_Formats.Pixel_Format_Names)
      return Texture_Formats;

   function Create_Buffer
     (Device     : in SDL.GPU.Device;
      Usage      : in Buffer_Usage_Flags;
      Size       : in Interfaces.Unsigned_32;
      Properties : in SDL.Properties.Property_ID :=
        SDL.Properties.Null_Property_ID) return Buffer;

   procedure Create_Buffer
     (Self       : in out Buffer;
      Device     : in SDL.GPU.Device;
      Usage      : in Buffer_Usage_Flags;
      Size       : in Interfaces.Unsigned_32;
      Properties : in SDL.Properties.Property_ID :=
        SDL.Properties.Null_Property_ID);

   procedure Destroy (Self : in out Buffer);

   function Is_Null (Self : in Buffer) return Boolean with
     Inline;

   function Get_Handle (Self : in Buffer) return Buffer_Handle with
     Inline;

   procedure Set_Name
     (Self : in Buffer;
      Name : in String);

   function Create_Transfer_Buffer
     (Device     : in SDL.GPU.Device;
      Usage      : in Transfer_Buffer_Usages;
      Size       : in Interfaces.Unsigned_32;
      Properties : in SDL.Properties.Property_ID :=
        SDL.Properties.Null_Property_ID) return Transfer_Buffer;

   procedure Create_Transfer_Buffer
     (Self       : in out Transfer_Buffer;
      Device     : in SDL.GPU.Device;
      Usage      : in Transfer_Buffer_Usages;
      Size       : in Interfaces.Unsigned_32;
      Properties : in SDL.Properties.Property_ID :=
        SDL.Properties.Null_Property_ID);

   procedure Destroy (Self : in out Transfer_Buffer);

   function Is_Null (Self : in Transfer_Buffer) return Boolean with
     Inline;

   function Map
     (Self  : in out Transfer_Buffer;
      Cycle : in Boolean := False) return System.Address;

   procedure Unmap (Self : in out Transfer_Buffer);

   function Create_Texture
     (Device               : in SDL.GPU.Device;
      Format               : in Texture_Formats;
      Usage                : in Texture_Usage_Flags;
      Width                : in Interfaces.Unsigned_32;
      Height               : in Interfaces.Unsigned_32;
      Kind                 : in Texture_Types := Texture_2D;
      Layer_Count_Or_Depth : in Interfaces.Unsigned_32 := 1;
      Num_Levels           : in Interfaces.Unsigned_32 := 1;
      Sample_Count         : in Sample_Counts := Sample_Count_1;
      Properties           : in SDL.Properties.Property_ID :=
        SDL.Properties.Null_Property_ID) return Texture;

   procedure Create_Texture
     (Self                 : in out Texture;
      Device               : in SDL.GPU.Device;
      Format               : in Texture_Formats;
      Usage                : in Texture_Usage_Flags;
      Width                : in Interfaces.Unsigned_32;
      Height               : in Interfaces.Unsigned_32;
      Kind                 : in Texture_Types := Texture_2D;
      Layer_Count_Or_Depth : in Interfaces.Unsigned_32 := 1;
      Num_Levels           : in Interfaces.Unsigned_32 := 1;
      Sample_Count         : in Sample_Counts := Sample_Count_1;
      Properties           : in SDL.Properties.Property_ID :=
        SDL.Properties.Null_Property_ID);

   procedure Destroy (Self : in out Texture);

   function Is_Null (Self : in Texture) return Boolean with
     Inline;

   function Get_Handle (Self : in Texture) return Texture_Handle with
     Inline;

   procedure Set_Name
     (Self : in Texture;
      Name : in String);

   function Create_Sampler
     (Device            : in SDL.GPU.Device;
      Min_Filter        : in Filters := Linear;
      Mag_Filter        : in Filters := Linear;
      Mipmap_Mode       : in Sampler_Mipmap_Modes := Mipmap_Linear;
      Address_Mode_U    : in Sampler_Address_Modes := Repeat;
      Address_Mode_V    : in Sampler_Address_Modes := Repeat;
      Address_Mode_W    : in Sampler_Address_Modes := Repeat;
      Mip_LOD_Bias      : in Float := 0.0;
      Max_Anisotropy    : in Float := 1.0;
      Compare_Operation : in Compare_Operations := Invalid_Compare_Operation;
      Min_LOD           : in Float := 0.0;
      Max_LOD           : in Float := 0.0;
      Enable_Anisotropy : in Boolean := False;
      Enable_Compare    : in Boolean := False;
      Properties        : in SDL.Properties.Property_ID :=
        SDL.Properties.Null_Property_ID) return Sampler;

   procedure Create_Sampler
     (Self              : in out Sampler;
      Device            : in SDL.GPU.Device;
      Min_Filter        : in Filters := Linear;
      Mag_Filter        : in Filters := Linear;
      Mipmap_Mode       : in Sampler_Mipmap_Modes := Mipmap_Linear;
      Address_Mode_U    : in Sampler_Address_Modes := Repeat;
      Address_Mode_V    : in Sampler_Address_Modes := Repeat;
      Address_Mode_W    : in Sampler_Address_Modes := Repeat;
      Mip_LOD_Bias      : in Float := 0.0;
      Max_Anisotropy    : in Float := 1.0;
      Compare_Operation : in Compare_Operations := Invalid_Compare_Operation;
      Min_LOD           : in Float := 0.0;
      Max_LOD           : in Float := 0.0;
      Enable_Anisotropy : in Boolean := False;
      Enable_Compare    : in Boolean := False;
      Properties        : in SDL.Properties.Property_ID :=
        SDL.Properties.Null_Property_ID);

   procedure Destroy (Self : in out Sampler);

   function Is_Null (Self : in Sampler) return Boolean with
     Inline;

   function Get_Handle (Self : in Sampler) return Sampler_Handle with
     Inline;

   function Create_Shader
     (Device               : in SDL.GPU.Device;
      Code                 : in Ada.Streams.Stream_Element_Array;
      Entrypoint           : in String;
      Format               : in Shader_Formats;
      Stage                : in Shader_Stages;
      Num_Samplers         : in Interfaces.Unsigned_32 := 0;
      Num_Storage_Textures : in Interfaces.Unsigned_32 := 0;
      Num_Storage_Buffers  : in Interfaces.Unsigned_32 := 0;
      Num_Uniform_Buffers  : in Interfaces.Unsigned_32 := 0;
      Properties           : in SDL.Properties.Property_ID :=
        SDL.Properties.Null_Property_ID) return Shader;

   procedure Create_Shader
     (Self                 : in out Shader;
      Device               : in SDL.GPU.Device;
      Code                 : in Ada.Streams.Stream_Element_Array;
      Entrypoint           : in String;
      Format               : in Shader_Formats;
      Stage                : in Shader_Stages;
      Num_Samplers         : in Interfaces.Unsigned_32 := 0;
      Num_Storage_Textures : in Interfaces.Unsigned_32 := 0;
      Num_Storage_Buffers  : in Interfaces.Unsigned_32 := 0;
      Num_Uniform_Buffers  : in Interfaces.Unsigned_32 := 0;
      Properties           : in SDL.Properties.Property_ID :=
        SDL.Properties.Null_Property_ID);

   procedure Destroy (Self : in out Shader);

   function Is_Null (Self : in Shader) return Boolean with
     Inline;

   function Get_Handle (Self : in Shader) return Shader_Handle with
     Inline;

   function Create_Graphics_Pipeline
     (Device                   : in SDL.GPU.Device;
      Vertex                   : in Shader;
      Fragment                 : in Shader;
      Vertex_Buffers           : in Vertex_Buffer_Description_Arrays;
      Vertex_Attributes        : in Vertex_Attribute_Arrays;
      Primitive                : in Primitive_Types;
      Color_Targets            : in Color_Target_Description_Arrays;
      Rasterizer               : in Rasterizer_State :=
        (Fill_Mode                  => Fill,
         Cull_Mode                  => Cull_None,
         Front_Face                 => Counter_Clockwise,
         Depth_Bias_Constant_Factor => 0.0,
         Depth_Bias_Clamp           => 0.0,
         Depth_Bias_Slope_Factor    => 0.0,
         Enable_Depth_Bias          => False,
         Enable_Depth_Clip          => True);
      Multisample              : in Multisample_State :=
        (Sample_Count             => Sample_Count_1,
         Sample_Mask              => 0,
         Enable_Mask              => False,
         Enable_Alpha_To_Coverage => False);
      Depth_Stencil            : in Depth_Stencil_State :=
        (Compare_Operation   => Always,
         Back_Stencil_State  =>
           (Fail_Operation       => Keep,
            Pass_Operation       => Keep,
            Depth_Fail_Operation => Keep,
            Compare_Operation    => Always),
         Front_Stencil_State =>
           (Fail_Operation       => Keep,
            Pass_Operation       => Keep,
            Depth_Fail_Operation => Keep,
            Compare_Operation    => Always),
         Compare_Mask        => 0,
         Write_Mask          => 0,
         Enable_Depth_Test   => False,
         Enable_Depth_Write  => False,
         Enable_Stencil_Test => False);
      Depth_Stencil_Format     : in Texture_Formats := Invalid_Texture_Format;
      Has_Depth_Stencil_Target : in Boolean := False;
      Properties               : in SDL.Properties.Property_ID :=
        SDL.Properties.Null_Property_ID) return Graphics_Pipeline;

   procedure Create_Graphics_Pipeline
     (Self                     : in out Graphics_Pipeline;
      Device                   : in SDL.GPU.Device;
      Vertex                   : in Shader;
      Fragment                 : in Shader;
      Vertex_Buffers           : in Vertex_Buffer_Description_Arrays;
      Vertex_Attributes        : in Vertex_Attribute_Arrays;
      Primitive                : in Primitive_Types;
      Color_Targets            : in Color_Target_Description_Arrays;
      Rasterizer               : in Rasterizer_State :=
        (Fill_Mode                  => Fill,
         Cull_Mode                  => Cull_None,
         Front_Face                 => Counter_Clockwise,
         Depth_Bias_Constant_Factor => 0.0,
         Depth_Bias_Clamp           => 0.0,
         Depth_Bias_Slope_Factor    => 0.0,
         Enable_Depth_Bias          => False,
         Enable_Depth_Clip          => True);
      Multisample              : in Multisample_State :=
        (Sample_Count             => Sample_Count_1,
         Sample_Mask              => 0,
         Enable_Mask              => False,
         Enable_Alpha_To_Coverage => False);
      Depth_Stencil            : in Depth_Stencil_State :=
        (Compare_Operation   => Always,
         Back_Stencil_State  =>
           (Fail_Operation       => Keep,
            Pass_Operation       => Keep,
            Depth_Fail_Operation => Keep,
            Compare_Operation    => Always),
         Front_Stencil_State =>
           (Fail_Operation       => Keep,
            Pass_Operation       => Keep,
            Depth_Fail_Operation => Keep,
            Compare_Operation    => Always),
         Compare_Mask        => 0,
         Write_Mask          => 0,
         Enable_Depth_Test   => False,
         Enable_Depth_Write  => False,
         Enable_Stencil_Test => False);
      Depth_Stencil_Format     : in Texture_Formats := Invalid_Texture_Format;
      Has_Depth_Stencil_Target : in Boolean := False;
      Properties               : in SDL.Properties.Property_ID :=
        SDL.Properties.Null_Property_ID);

   procedure Destroy (Self : in out Graphics_Pipeline);

   function Is_Null (Self : in Graphics_Pipeline) return Boolean with
     Inline;

   function Get_Handle
     (Self : in Graphics_Pipeline) return Graphics_Pipeline_Handle with
     Inline;

   function Create_Compute_Pipeline
     (Device                         : in SDL.GPU.Device;
      Code                           : in Ada.Streams.Stream_Element_Array;
      Entrypoint                     : in String;
      Format                         : in Shader_Formats;
      Num_Samplers                   : in Interfaces.Unsigned_32 := 0;
      Num_Readonly_Storage_Textures  : in Interfaces.Unsigned_32 := 0;
      Num_Readonly_Storage_Buffers   : in Interfaces.Unsigned_32 := 0;
      Num_Readwrite_Storage_Textures : in Interfaces.Unsigned_32 := 0;
      Num_Readwrite_Storage_Buffers  : in Interfaces.Unsigned_32 := 0;
      Num_Uniform_Buffers            : in Interfaces.Unsigned_32 := 0;
      Threadcount_X                  : in Interfaces.Unsigned_32 := 1;
      Threadcount_Y                  : in Interfaces.Unsigned_32 := 1;
      Threadcount_Z                  : in Interfaces.Unsigned_32 := 1;
      Properties                     : in SDL.Properties.Property_ID :=
        SDL.Properties.Null_Property_ID) return Compute_Pipeline;

   procedure Create_Compute_Pipeline
     (Self                           : in out Compute_Pipeline;
      Device                         : in SDL.GPU.Device;
      Code                           : in Ada.Streams.Stream_Element_Array;
      Entrypoint                     : in String;
      Format                         : in Shader_Formats;
      Num_Samplers                   : in Interfaces.Unsigned_32 := 0;
      Num_Readonly_Storage_Textures  : in Interfaces.Unsigned_32 := 0;
      Num_Readonly_Storage_Buffers   : in Interfaces.Unsigned_32 := 0;
      Num_Readwrite_Storage_Textures : in Interfaces.Unsigned_32 := 0;
      Num_Readwrite_Storage_Buffers  : in Interfaces.Unsigned_32 := 0;
      Num_Uniform_Buffers            : in Interfaces.Unsigned_32 := 0;
      Threadcount_X                  : in Interfaces.Unsigned_32 := 1;
      Threadcount_Y                  : in Interfaces.Unsigned_32 := 1;
      Threadcount_Z                  : in Interfaces.Unsigned_32 := 1;
      Properties                     : in SDL.Properties.Property_ID :=
        SDL.Properties.Null_Property_ID);

   procedure Destroy (Self : in out Compute_Pipeline);

   function Is_Null (Self : in Compute_Pipeline) return Boolean with
     Inline;

   function Get_Handle
     (Self : in Compute_Pipeline) return Compute_Pipeline_Handle with
     Inline;

   function Make_Texture_Transfer_Info
     (Buffer         : in Transfer_Buffer;
      Offset         : in Interfaces.Unsigned_32 := 0;
      Pixels_Per_Row : in Interfaces.Unsigned_32 := 0;
      Rows_Per_Layer : in Interfaces.Unsigned_32 := 0)
      return Texture_Transfer_Info;

   function Make_Transfer_Buffer_Location
     (Buffer : in Transfer_Buffer;
      Offset : in Interfaces.Unsigned_32 := 0)
      return Transfer_Buffer_Location;

   function Make_Texture_Location
     (Target    : in Texture;
      Mip_Level : in Interfaces.Unsigned_32 := 0;
      Layer     : in Interfaces.Unsigned_32 := 0;
      X         : in Interfaces.Unsigned_32 := 0;
      Y         : in Interfaces.Unsigned_32 := 0;
      Z         : in Interfaces.Unsigned_32 := 0)
      return Texture_Location;

   function Make_Texture_Region
     (Target    : in Texture;
      Width     : in Interfaces.Unsigned_32;
      Height    : in Interfaces.Unsigned_32;
      Depth     : in Interfaces.Unsigned_32 := 1;
      Mip_Level : in Interfaces.Unsigned_32 := 0;
      Layer     : in Interfaces.Unsigned_32 := 0;
      X         : in Interfaces.Unsigned_32 := 0;
      Y         : in Interfaces.Unsigned_32 := 0;
      Z         : in Interfaces.Unsigned_32 := 0)
      return Texture_Region;

   function Make_Buffer_Location
     (Target : in Buffer;
      Offset : in Interfaces.Unsigned_32 := 0) return Buffer_Location;

   function Make_Buffer_Region
     (Target : in Buffer;
      Size   : in Interfaces.Unsigned_32;
      Offset : in Interfaces.Unsigned_32 := 0) return Buffer_Region;

   function Make_Buffer_Binding
     (Target : in Buffer;
      Offset : in Interfaces.Unsigned_32 := 0) return Buffer_Binding;

   function Make_Texture_Sampler_Binding
     (Target  : in Texture;
      Sampler : in SDL.GPU.Sampler) return Texture_Sampler_Binding;

   function Make_Storage_Buffer_Read_Write_Binding
     (Target : in Buffer;
      Cycle  : in Boolean := False)
      return Storage_Buffer_Read_Write_Binding;

   function Make_Storage_Texture_Read_Write_Binding
     (Target    : in Texture;
      Mip_Level : in Interfaces.Unsigned_32 := 0;
      Layer     : in Interfaces.Unsigned_32 := 0;
      Cycle     : in Boolean := False)
      return Storage_Texture_Read_Write_Binding;

   function Make_Blit_Region
     (Target               : in Texture;
      Width                : in Interfaces.Unsigned_32;
      Height               : in Interfaces.Unsigned_32;
      Mip_Level            : in Interfaces.Unsigned_32 := 0;
      Layer_Or_Depth_Plane : in Interfaces.Unsigned_32 := 0;
      X                    : in Interfaces.Unsigned_32 := 0;
      Y                    : in Interfaces.Unsigned_32 := 0) return Blit_Region;

   function Make_Blit_Info
     (Source       : in Blit_Region;
      Destination  : in Blit_Region;
      Load_Op      : in Load_Operations := Load;
      Clear_To     : in Float_Colour :=
        (Red => 0.0, Green => 0.0, Blue => 0.0, Alpha => 1.0);
      Flip         : in Flip_Modes := No_Flip;
      Filter       : in Filters := Linear;
      Cycle        : in Boolean := False) return Blit_Info;

   procedure Claim_Window
     (Self   : in Device;
      Window : in SDL.Video.Windows.Window);

   procedure Release_Window
     (Self   : in Device;
      Window : in SDL.Video.Windows.Window);

   function Supports_Composition
     (Self        : in Device;
      Window      : in SDL.Video.Windows.Window;
      Composition : in Swapchain_Compositions) return Boolean;

   function Supports_Present_Mode
     (Self         : in Device;
      Window       : in SDL.Video.Windows.Window;
      Present_Mode : in Present_Modes) return Boolean;

   procedure Set_Swapchain_Parameters
     (Self         : in Device;
      Window       : in SDL.Video.Windows.Window;
      Composition  : in Swapchain_Compositions := Swapchain_SDR;
      Present_Mode : in Present_Modes := V_Sync);

   procedure Set_Allowed_Frames_In_Flight
     (Self                     : in Device;
      Allowed_Frames_In_Flight : in Interfaces.Unsigned_32);

   function Get_Swapchain_Texture_Format
     (Self   : in Device;
      Window : in SDL.Video.Windows.Window) return Texture_Formats;

   procedure GDK_Suspend (Self : in Device);

   procedure GDK_Resume (Self : in Device);

   function Acquire_Command_Buffer
     (Self : in Device) return Command_Buffer;

   function Is_Null (Self : in Command_Buffer) return Boolean with
     Inline;

   procedure Push_Vertex_Uniform_Data
     (Self       : in Command_Buffer;
      Slot_Index : in Interfaces.Unsigned_32;
      Data       : in Ada.Streams.Stream_Element_Array);

   procedure Push_Fragment_Uniform_Data
     (Self       : in Command_Buffer;
      Slot_Index : in Interfaces.Unsigned_32;
      Data       : in Ada.Streams.Stream_Element_Array);

   procedure Push_Compute_Uniform_Data
     (Self       : in Command_Buffer;
      Slot_Index : in Interfaces.Unsigned_32;
      Data       : in Ada.Streams.Stream_Element_Array);

   procedure Insert_Debug_Label
     (Self : in Command_Buffer;
      Text : in String);

   procedure Push_Debug_Group
     (Self : in Command_Buffer;
      Name : in String);

   procedure Pop_Debug_Group (Self : in Command_Buffer);

   function Begin_Copy_Pass
     (Self : in out Command_Buffer) return Copy_Pass;

   function Begin_Compute_Pass
     (Self : in out Command_Buffer) return Compute_Pass;

   function Begin_Compute_Pass
     (Self                : in out Command_Buffer;
      Storage_Textures    : in Storage_Texture_Read_Write_Binding_Arrays;
      Storage_Buffers     : in Storage_Buffer_Read_Write_Binding_Arrays)
      return Compute_Pass;

   procedure End_Pass (Self : in out Copy_Pass);
   procedure End_Pass (Self : in out Compute_Pass);

   function Is_Null (Self : in Copy_Pass) return Boolean with
     Inline;
   function Is_Null (Self : in Compute_Pass) return Boolean with
     Inline;

   procedure Upload_To_Texture
     (Self        : in Copy_Pass;
      Source      : in Texture_Transfer_Info;
      Destination : in Texture_Region;
      Cycle       : in Boolean := False);

   procedure Upload_To_Buffer
     (Self        : in Copy_Pass;
      Source      : in Transfer_Buffer_Location;
      Destination : in Buffer_Region;
      Cycle       : in Boolean := False);

   procedure Copy_Texture_To_Texture
     (Self        : in Copy_Pass;
      Source      : in Texture_Location;
      Destination : in Texture_Location;
      Width       : in Interfaces.Unsigned_32;
      Height      : in Interfaces.Unsigned_32;
      Depth       : in Interfaces.Unsigned_32 := 1;
      Cycle       : in Boolean := False);

   procedure Copy_Buffer_To_Buffer
     (Self        : in Copy_Pass;
      Source      : in Buffer_Location;
      Destination : in Buffer_Location;
      Size        : in Interfaces.Unsigned_32;
      Cycle       : in Boolean := False);

   procedure Download_From_Texture
     (Self        : in Copy_Pass;
      Source      : in Texture_Region;
      Destination : in Texture_Transfer_Info);

   procedure Download_From_Buffer
     (Self        : in Copy_Pass;
      Source      : in Buffer_Region;
      Destination : in Transfer_Buffer_Location);

   procedure Generate_Mipmaps
     (Self   : in Command_Buffer;
      Target : in Texture);

   procedure Blit
     (Self : in Command_Buffer;
      Info : in Blit_Info);

   function Wait_For_Swapchain
     (Self   : in Device;
      Window : in SDL.Video.Windows.Window) return Boolean;

   function Acquire_Swapchain_Texture
     (Self          : in out Command_Buffer;
      Window        : in SDL.Video.Windows.Window;
      Acquired      : in out Texture;
      Width, Height : out SDL.Natural_Dimension) return Boolean;

   function Wait_And_Acquire_Swapchain_Texture
     (Self          : in out Command_Buffer;
      Window        : in SDL.Video.Windows.Window;
      Acquired      : in out Texture;
      Width, Height : out SDL.Natural_Dimension) return Boolean;

   procedure Submit (Self : in out Command_Buffer);
   procedure Cancel (Self : in out Command_Buffer);

   function Submit_And_Acquire_Fence
     (Self : in out Command_Buffer) return Fence;

   function Make_Color_Target_Info
     (Target          : in Texture;
      Clear_To        : in Float_Colour :=
        (Red => 0.0, Green => 0.0, Blue => 0.0, Alpha => 1.0);
      Load_Operation  : in Load_Operations := Clear;
      Store_Operation : in Store_Operations := Store;
      Cycle           : in Boolean := False) return Color_Target_Info;

   function Make_Depth_Stencil_Target_Info
     (Target               : in Texture;
      Clear_Depth          : in Float := 1.0;
      Load_Operation       : in Load_Operations := Clear;
      Store_Operation      : in Store_Operations := Store;
      Stencil_Load_Op      : in Load_Operations := Dont_Care;
      Stencil_Store_Op     : in Store_Operations := Store_Dont_Care;
      Cycle                : in Boolean := False;
      Clear_Stencil        : in Interfaces.Unsigned_8 := 0;
      Mip_Level            : in Interfaces.Unsigned_8 := 0;
      Layer                : in Interfaces.Unsigned_8 := 0)
      return Depth_Stencil_Target_Info;

   function Begin_Render_Pass
     (Self         : in out Command_Buffer;
      Color_Target : in Color_Target_Info) return Render_Pass;

   function Begin_Render_Pass
     (Self          : in out Command_Buffer;
      Color_Targets : in Color_Target_Info_Arrays) return Render_Pass;

   function Begin_Render_Pass
     (Self                 : in out Command_Buffer;
      Color_Target         : in Color_Target_Info;
      Depth_Stencil_Target : in Depth_Stencil_Target_Info) return Render_Pass;

   function Begin_Render_Pass
     (Self                 : in out Command_Buffer;
      Color_Targets        : in Color_Target_Info_Arrays;
      Depth_Stencil_Target : in Depth_Stencil_Target_Info) return Render_Pass;

   function Begin_Render_Pass
     (Self                 : in out Command_Buffer;
      Depth_Stencil_Target : in Depth_Stencil_Target_Info) return Render_Pass;

   procedure End_Pass (Self : in out Render_Pass);

   function Is_Null (Self : in Render_Pass) return Boolean with
     Inline;

   procedure Bind_Pipeline
     (Self     : in Render_Pass;
      Pipeline : in Graphics_Pipeline);

   procedure Set_Viewport
     (Self : in Render_Pass;
      Area : in Viewport);

   procedure Set_Scissor
     (Self    : in Render_Pass;
      Scissor : in SDL.Video.Rectangles.Rectangle);

   procedure Set_Blend_Constants
     (Self      : in Render_Pass;
      Constants : in Float_Colour);

   procedure Set_Stencil_Reference
     (Self      : in Render_Pass;
      Reference : in Interfaces.Unsigned_8);

   procedure Bind_Vertex_Buffers
     (Self       : in Render_Pass;
      First_Slot : in Interfaces.Unsigned_32;
      Bindings   : in Buffer_Binding_Arrays);

   procedure Bind_Index_Buffer
     (Self               : in Render_Pass;
      Binding            : in Buffer_Binding;
      Index_Element_Size : in Index_Element_Sizes);

   procedure Bind_Vertex_Samplers
     (Self       : in Render_Pass;
      First_Slot : in Interfaces.Unsigned_32;
      Bindings   : in Texture_Sampler_Binding_Arrays);

   procedure Bind_Vertex_Storage_Textures
     (Self       : in Render_Pass;
      First_Slot : in Interfaces.Unsigned_32;
      Bindings   : in Texture_Arrays);

   procedure Bind_Vertex_Storage_Buffers
     (Self       : in Render_Pass;
      First_Slot : in Interfaces.Unsigned_32;
      Bindings   : in Buffer_Arrays);

   procedure Bind_Fragment_Samplers
     (Self       : in Render_Pass;
      First_Slot : in Interfaces.Unsigned_32;
      Bindings   : in Texture_Sampler_Binding_Arrays);

   procedure Bind_Fragment_Storage_Textures
     (Self       : in Render_Pass;
      First_Slot : in Interfaces.Unsigned_32;
      Bindings   : in Texture_Arrays);

   procedure Bind_Fragment_Storage_Buffers
     (Self       : in Render_Pass;
      First_Slot : in Interfaces.Unsigned_32;
      Bindings   : in Buffer_Arrays);

   procedure Draw_Indexed_Primitives
     (Self           : in Render_Pass;
      Num_Indices    : in Interfaces.Unsigned_32;
      Num_Instances  : in Interfaces.Unsigned_32 := 1;
      First_Index    : in Interfaces.Unsigned_32 := 0;
      Vertex_Offset  : in Integer := 0;
      First_Instance : in Interfaces.Unsigned_32 := 0);

   procedure Draw_Primitives
     (Self           : in Render_Pass;
      Num_Vertices   : in Interfaces.Unsigned_32;
      Num_Instances  : in Interfaces.Unsigned_32 := 1;
      First_Vertex   : in Interfaces.Unsigned_32 := 0;
      First_Instance : in Interfaces.Unsigned_32 := 0);

   procedure Draw_Primitives_Indirect
     (Self       : in Render_Pass;
      Parameters : in Buffer;
      Offset     : in Interfaces.Unsigned_32 := 0;
      Draw_Count : in Interfaces.Unsigned_32 := 1);

   procedure Draw_Indexed_Primitives_Indirect
     (Self       : in Render_Pass;
      Parameters : in Buffer;
      Offset     : in Interfaces.Unsigned_32 := 0;
      Draw_Count : in Interfaces.Unsigned_32 := 1);

   procedure Bind_Pipeline
     (Self     : in Compute_Pass;
      Pipeline : in Compute_Pipeline);

   procedure Bind_Compute_Samplers
     (Self       : in Compute_Pass;
      First_Slot : in Interfaces.Unsigned_32;
      Bindings   : in Texture_Sampler_Binding_Arrays);

   procedure Bind_Compute_Storage_Textures
     (Self       : in Compute_Pass;
      First_Slot : in Interfaces.Unsigned_32;
      Bindings   : in Texture_Arrays);

   procedure Bind_Compute_Storage_Buffers
     (Self       : in Compute_Pass;
      First_Slot : in Interfaces.Unsigned_32;
      Bindings   : in Buffer_Arrays);

   procedure Dispatch
     (Self         : in Compute_Pass;
      Groupcount_X : in Interfaces.Unsigned_32;
      Groupcount_Y : in Interfaces.Unsigned_32;
      Groupcount_Z : in Interfaces.Unsigned_32);

   procedure Dispatch_Indirect
     (Self       : in Compute_Pass;
      Parameters : in Buffer;
      Offset     : in Interfaces.Unsigned_32 := 0);

   function Is_Null (Self : in Fence) return Boolean with
     Inline;

   function Query
     (Device : in SDL.GPU.Device;
      Self   : in Fence) return Boolean;

   function Wait
     (Device : in SDL.GPU.Device;
      Self   : in Fence) return Boolean;

   procedure Release
     (Device : in SDL.GPU.Device;
      Self   : in out Fence);

   procedure Wait_For_Idle (Self : in Device);
private
   subtype Transfer_Buffer_Handle is SDL.Raw.GPU.Transfer_Buffer_Access;

   type Device is new Ada.Finalization.Limited_Controlled with
      record
         Internal : Device_Handle := null;
         Owns     : Boolean       := True;
      end record;

   type Buffer is
      record
         Internal : Buffer_Handle := null;
         Device   : Device_Handle := null;
         Owns     : Boolean       := True;
      end record;

   type Transfer_Buffer is
      record
         Internal : Transfer_Buffer_Handle := null;
         Device   : Device_Handle := null;
         Owns     : Boolean       := True;
         Mapped   : Boolean       := False;
      end record;

   type Texture is
      record
         Internal : Texture_Handle := null;
         Device   : Device_Handle := null;
         Owns     : Boolean       := False;
      end record;

   type Sampler is
      record
         Internal : Sampler_Handle := null;
         Device   : Device_Handle := null;
         Owns     : Boolean       := True;
      end record;

   type Shader is
      record
         Internal : Shader_Handle := null;
         Device   : Device_Handle := null;
         Owns     : Boolean       := True;
      end record;

   type Graphics_Pipeline is
      record
         Internal : Graphics_Pipeline_Handle := null;
         Device   : Device_Handle := null;
         Owns     : Boolean                  := True;
      end record;

   type Compute_Pipeline is
      record
         Internal : Compute_Pipeline_Handle := null;
         Device   : Device_Handle := null;
         Owns     : Boolean                 := True;
      end record;

   type Command_Buffer is
      record
         Internal : Command_Buffer_Handle := null;
      end record;

   type Render_Pass is
      record
         Internal : Render_Pass_Handle := null;
      end record;

   type Compute_Pass is
      record
         Internal : Compute_Pass_Handle := null;
      end record;

   type Copy_Pass is
      record
         Internal : Copy_Pass_Handle := null;
      end record;

   type Fence is
      record
         Internal : Fence_Handle := null;
      end record;

   type Color_Target_Info is
      record
         Internal : SDL.Raw.GPU.Color_Target_Info;
      end record;

   type Depth_Stencil_Target_Info is
      record
         Internal : SDL.Raw.GPU.Depth_Stencil_Target_Info;
      end record;

   type Texture_Transfer_Info is
      record
         Internal : SDL.Raw.GPU.Texture_Transfer_Info;
      end record;

   type Transfer_Buffer_Location is
      record
         Internal : SDL.Raw.GPU.Transfer_Buffer_Location;
      end record;

   type Texture_Location is
      record
         Internal : SDL.Raw.GPU.Texture_Location;
      end record;

   type Texture_Region is
      record
         Internal : SDL.Raw.GPU.Texture_Region;
      end record;

   type Buffer_Location is
      record
         Internal : SDL.Raw.GPU.Buffer_Location;
      end record;

   type Buffer_Region is
      record
         Internal : SDL.Raw.GPU.Buffer_Region;
      end record;

   type Buffer_Binding is
      record
         Internal : SDL.Raw.GPU.Buffer_Binding;
      end record;

   type Texture_Sampler_Binding is
      record
         Internal : SDL.Raw.GPU.Texture_Sampler_Binding;
      end record;

   type Storage_Buffer_Read_Write_Binding is
      record
         Internal : SDL.Raw.GPU.Storage_Buffer_Read_Write_Binding;
      end record;

   type Storage_Texture_Read_Write_Binding is
      record
         Internal : SDL.Raw.GPU.Storage_Texture_Read_Write_Binding;
      end record;

   type Blit_Region is
      record
         Internal : SDL.Raw.GPU.Blit_Region;
      end record;

   type Blit_Info is
      record
         Internal : SDL.Raw.GPU.Blit_Info;
      end record;

   function Make_Texture_From_Pointer
     (Internal : in Texture_Handle) return Texture;
end SDL.GPU;
