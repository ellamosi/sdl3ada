with Interfaces;
with Interfaces.C;
with Interfaces.C.Extensions;
with Interfaces.C.Strings;
with System;

with SDL.Raw.Pixels;
with SDL.Raw.Properties;
with SDL.Raw.Rect;
with SDL.Raw.Video;

package SDL.Raw.GPU is
   pragma Preelaborate;

   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;
   package CS renames Interfaces.C.Strings;

   subtype Unsigned_8 is Interfaces.Unsigned_8;
   subtype Unsigned_32 is Interfaces.Unsigned_32;

   subtype Shader_Formats is Unsigned_32;
   subtype Texture_Formats is C.int;
   subtype Texture_Usage_Flags is Unsigned_32;
   subtype Buffer_Usage_Flags is Unsigned_32;
   subtype Window_Pointer is SDL.Raw.Video.Window_Pointer;
   subtype Load_Ops is C.int;
   subtype Store_Ops is C.int;
   subtype Present_Modes is C.int;
   subtype Swapchain_Compositions is C.int;
   subtype Texture_Types is C.int;
   subtype Sample_Counts is C.int;
   subtype Transfer_Buffer_Usages is C.int;
   subtype Primitive_Types is C.int;
   subtype Index_Element_Sizes is C.int;
   subtype Shader_Stages is C.int;
   subtype Vertex_Element_Formats is C.int;
   subtype Vertex_Input_Rates is C.int;
   subtype Fill_Modes is C.int;
   subtype Cull_Modes is C.int;
   subtype Front_Faces is C.int;
   subtype Compare_Ops is C.int;
   subtype Stencil_Ops is C.int;
   subtype Blend_Ops is C.int;
   subtype Blend_Factors is C.int;
   subtype Color_Component_Flags is Unsigned_8;
   subtype Filters is C.int;
   subtype Sampler_Mipmap_Modes is C.int;
   subtype Sampler_Address_Modes is C.int;
   subtype Flip_Modes is C.int;

   Invalid_Shader_Format   : constant Shader_Formats := 0;
   Private_Shader_Format   : constant Shader_Formats := 16#0000_0001#;
   SPIRV_Shader_Format     : constant Shader_Formats := 16#0000_0002#;
   DXBC_Shader_Format      : constant Shader_Formats := 16#0000_0004#;
   DXIL_Shader_Format      : constant Shader_Formats := 16#0000_0008#;
   MSL_Shader_Format       : constant Shader_Formats := 16#0000_0010#;
   Metallib_Shader_Format  : constant Shader_Formats := 16#0000_0020#;

   Invalid_Texture_Format : constant Texture_Formats := 0;

   Texture_Usage_Sampler                                 : constant Texture_Usage_Flags := 16#0000_0001#;
   Texture_Usage_Color_Target                            : constant Texture_Usage_Flags := 16#0000_0002#;
   Texture_Usage_Depth_Stencil_Target                    : constant Texture_Usage_Flags := 16#0000_0004#;
   Texture_Usage_Graphics_Storage_Read                   : constant Texture_Usage_Flags := 16#0000_0008#;
   Texture_Usage_Compute_Storage_Read                    : constant Texture_Usage_Flags := 16#0000_0010#;
   Texture_Usage_Compute_Storage_Write                   : constant Texture_Usage_Flags := 16#0000_0020#;
   Texture_Usage_Compute_Storage_Simultaneous_Read_Write : constant Texture_Usage_Flags := 16#0000_0040#;

   Buffer_Usage_Vertex                : constant Buffer_Usage_Flags := 16#0000_0001#;
   Buffer_Usage_Index                 : constant Buffer_Usage_Flags := 16#0000_0002#;
   Buffer_Usage_Indirect              : constant Buffer_Usage_Flags := 16#0000_0004#;
   Buffer_Usage_Graphics_Storage_Read : constant Buffer_Usage_Flags := 16#0000_0008#;
   Buffer_Usage_Compute_Storage_Read  : constant Buffer_Usage_Flags := 16#0000_0010#;
   Buffer_Usage_Compute_Storage_Write : constant Buffer_Usage_Flags := 16#0000_0020#;

   Load_Load      : constant Load_Ops := 0;
   Load_Clear     : constant Load_Ops := 1;
   Load_Dont_Care : constant Load_Ops := 2;

   Store_Store             : constant Store_Ops := 0;
   Store_Dont_Care         : constant Store_Ops := 1;
   Store_Resolve           : constant Store_Ops := 2;
   Store_Resolve_And_Store : constant Store_Ops := 3;

   Present_V_Sync    : constant Present_Modes := 0;
   Present_Immediate : constant Present_Modes := 1;
   Present_Mailbox   : constant Present_Modes := 2;

   Swapchain_SDR                 : constant Swapchain_Compositions := 0;
   Swapchain_SDR_Linear          : constant Swapchain_Compositions := 1;
   Swapchain_HDR_Extended_Linear : constant Swapchain_Compositions := 2;
   Swapchain_HDR10_ST2084        : constant Swapchain_Compositions := 3;

   Texture_2D         : constant Texture_Types := 0;
   Texture_2D_Array   : constant Texture_Types := 1;
   Texture_3D         : constant Texture_Types := 2;
   Texture_Cube       : constant Texture_Types := 3;
   Texture_Cube_Array : constant Texture_Types := 4;

   Sample_Count_1 : constant Sample_Counts := 0;
   Sample_Count_2 : constant Sample_Counts := 1;
   Sample_Count_4 : constant Sample_Counts := 2;
   Sample_Count_8 : constant Sample_Counts := 3;

   Transfer_Buffer_Upload   : constant Transfer_Buffer_Usages := 0;
   Transfer_Buffer_Download : constant Transfer_Buffer_Usages := 1;

   Primitive_Triangle_List  : constant Primitive_Types := 0;
   Primitive_Triangle_Strip : constant Primitive_Types := 1;
   Primitive_Line_List      : constant Primitive_Types := 2;
   Primitive_Line_Strip     : constant Primitive_Types := 3;
   Primitive_Point_List     : constant Primitive_Types := 4;

   Index_Element_Size_16_Bit : constant Index_Element_Sizes := 0;
   Index_Element_Size_32_Bit : constant Index_Element_Sizes := 1;

   Shader_Stage_Vertex   : constant Shader_Stages := 0;
   Shader_Stage_Fragment : constant Shader_Stages := 1;

   Vertex_Element_Invalid      : constant Vertex_Element_Formats := 0;
   Vertex_Element_Int          : constant Vertex_Element_Formats := 1;
   Vertex_Element_Int2         : constant Vertex_Element_Formats := 2;
   Vertex_Element_Int3         : constant Vertex_Element_Formats := 3;
   Vertex_Element_Int4         : constant Vertex_Element_Formats := 4;
   Vertex_Element_UInt         : constant Vertex_Element_Formats := 5;
   Vertex_Element_UInt2        : constant Vertex_Element_Formats := 6;
   Vertex_Element_UInt3        : constant Vertex_Element_Formats := 7;
   Vertex_Element_UInt4        : constant Vertex_Element_Formats := 8;
   Vertex_Element_Float        : constant Vertex_Element_Formats := 9;
   Vertex_Element_Float2       : constant Vertex_Element_Formats := 10;
   Vertex_Element_Float3       : constant Vertex_Element_Formats := 11;
   Vertex_Element_Float4       : constant Vertex_Element_Formats := 12;
   Vertex_Element_Byte2        : constant Vertex_Element_Formats := 13;
   Vertex_Element_Byte4        : constant Vertex_Element_Formats := 14;
   Vertex_Element_UByte2       : constant Vertex_Element_Formats := 15;
   Vertex_Element_UByte4       : constant Vertex_Element_Formats := 16;
   Vertex_Element_Byte2_Norm   : constant Vertex_Element_Formats := 17;
   Vertex_Element_Byte4_Norm   : constant Vertex_Element_Formats := 18;
   Vertex_Element_UByte2_Norm  : constant Vertex_Element_Formats := 19;
   Vertex_Element_UByte4_Norm  : constant Vertex_Element_Formats := 20;
   Vertex_Element_Short2       : constant Vertex_Element_Formats := 21;
   Vertex_Element_Short4       : constant Vertex_Element_Formats := 22;
   Vertex_Element_UShort2      : constant Vertex_Element_Formats := 23;
   Vertex_Element_UShort4      : constant Vertex_Element_Formats := 24;
   Vertex_Element_Short2_Norm  : constant Vertex_Element_Formats := 25;
   Vertex_Element_Short4_Norm  : constant Vertex_Element_Formats := 26;
   Vertex_Element_UShort2_Norm : constant Vertex_Element_Formats := 27;
   Vertex_Element_UShort4_Norm : constant Vertex_Element_Formats := 28;
   Vertex_Element_Half2        : constant Vertex_Element_Formats := 29;
   Vertex_Element_Half4        : constant Vertex_Element_Formats := 30;

   Vertex_Input_Rate_Vertex   : constant Vertex_Input_Rates := 0;
   Vertex_Input_Rate_Instance : constant Vertex_Input_Rates := 1;

   Fill_Mode_Fill : constant Fill_Modes := 0;
   Fill_Mode_Line : constant Fill_Modes := 1;

   Cull_Mode_None  : constant Cull_Modes := 0;
   Cull_Mode_Front : constant Cull_Modes := 1;
   Cull_Mode_Back  : constant Cull_Modes := 2;

   Front_Face_Counter_Clockwise : constant Front_Faces := 0;
   Front_Face_Clockwise         : constant Front_Faces := 1;

   Compare_Op_Invalid          : constant Compare_Ops := 0;
   Compare_Op_Never            : constant Compare_Ops := 1;
   Compare_Op_Less             : constant Compare_Ops := 2;
   Compare_Op_Equal            : constant Compare_Ops := 3;
   Compare_Op_Less_Or_Equal    : constant Compare_Ops := 4;
   Compare_Op_Greater          : constant Compare_Ops := 5;
   Compare_Op_Not_Equal        : constant Compare_Ops := 6;
   Compare_Op_Greater_Or_Equal : constant Compare_Ops := 7;
   Compare_Op_Always           : constant Compare_Ops := 8;

   Stencil_Op_Invalid             : constant Stencil_Ops := 0;
   Stencil_Op_Keep                : constant Stencil_Ops := 1;
   Stencil_Op_Zero                : constant Stencil_Ops := 2;
   Stencil_Op_Replace             : constant Stencil_Ops := 3;
   Stencil_Op_Increment_And_Clamp : constant Stencil_Ops := 4;
   Stencil_Op_Decrement_And_Clamp : constant Stencil_Ops := 5;
   Stencil_Op_Invert              : constant Stencil_Ops := 6;
   Stencil_Op_Increment_And_Wrap  : constant Stencil_Ops := 7;
   Stencil_Op_Decrement_And_Wrap  : constant Stencil_Ops := 8;

   Blend_Op_Invalid          : constant Blend_Ops := 0;
   Blend_Op_Add              : constant Blend_Ops := 1;
   Blend_Op_Subtract         : constant Blend_Ops := 2;
   Blend_Op_Reverse_Subtract : constant Blend_Ops := 3;
   Blend_Op_Min              : constant Blend_Ops := 4;
   Blend_Op_Max              : constant Blend_Ops := 5;

   Blend_Factor_Invalid                  : constant Blend_Factors := 0;
   Blend_Factor_Zero                     : constant Blend_Factors := 1;
   Blend_Factor_One                      : constant Blend_Factors := 2;
   Blend_Factor_Source_Colour            : constant Blend_Factors := 3;
   Blend_Factor_One_Minus_Source_Colour  : constant Blend_Factors := 4;
   Blend_Factor_Destination_Colour       : constant Blend_Factors := 5;
   Blend_Factor_One_Minus_Destination_Colour : constant Blend_Factors := 6;
   Blend_Factor_Source_Alpha             : constant Blend_Factors := 7;
   Blend_Factor_One_Minus_Source_Alpha   : constant Blend_Factors := 8;
   Blend_Factor_Destination_Alpha        : constant Blend_Factors := 9;
   Blend_Factor_One_Minus_Destination_Alpha : constant Blend_Factors := 10;
   Blend_Factor_Constant_Colour          : constant Blend_Factors := 11;
   Blend_Factor_One_Minus_Constant_Colour : constant Blend_Factors := 12;
   Blend_Factor_Source_Alpha_Saturate    : constant Blend_Factors := 13;

   Color_Component_R : constant Color_Component_Flags := 16#01#;
   Color_Component_G : constant Color_Component_Flags := 16#02#;
   Color_Component_B : constant Color_Component_Flags := 16#04#;
   Color_Component_A : constant Color_Component_Flags := 16#08#;

   Filter_Nearest : constant Filters := 0;
   Filter_Linear  : constant Filters := 1;

   Sampler_Mipmap_Mode_Nearest : constant Sampler_Mipmap_Modes := 0;
   Sampler_Mipmap_Mode_Linear  : constant Sampler_Mipmap_Modes := 1;

   Sampler_Address_Mode_Repeat          : constant Sampler_Address_Modes := 0;
   Sampler_Address_Mode_Mirrored_Repeat : constant Sampler_Address_Modes := 1;
   Sampler_Address_Mode_Clamp_To_Edge   : constant Sampler_Address_Modes := 2;

   Flip_None                       : constant Flip_Modes := 0;
   Flip_Horizontal                 : constant Flip_Modes := 1;
   Flip_Vertical                   : constant Flip_Modes := 2;
   Flip_Horizontal_And_Vertical    : constant Flip_Modes := 3;

   type Device_Object is null record;
   type Device_Access is access all Device_Object with
     Convention => C;

   type Buffer_Object is null record;
   type Buffer_Access is access all Buffer_Object with
     Convention => C;

   type Buffer_Access_Array is
     array (C.size_t range <>) of aliased Buffer_Access
   with Convention => C;

   type Transfer_Buffer_Object is null record;
   type Transfer_Buffer_Access is access all Transfer_Buffer_Object with
     Convention => C;

   type Texture_Object is null record;
   type Texture_Access is access all Texture_Object with
     Convention => C;

   type Texture_Access_Array is
     array (C.size_t range <>) of aliased Texture_Access
   with Convention => C;

   type Sampler_Object is null record;
   type Sampler_Access is access all Sampler_Object with
     Convention => C;

   type Shader_Object is null record;
   type Shader_Access is access all Shader_Object with
     Convention => C;

   type Compute_Pipeline_Object is null record;
   type Compute_Pipeline_Access is access all Compute_Pipeline_Object with
     Convention => C;

   type Graphics_Pipeline_Object is null record;
   type Graphics_Pipeline_Access is access all Graphics_Pipeline_Object with
     Convention => C;

   type Command_Buffer_Object is null record;
   type Command_Buffer_Access is access all Command_Buffer_Object with
     Convention => C;

   type Render_Pass_Object is null record;
   type Render_Pass_Access is access all Render_Pass_Object with
     Convention => C;

   type Compute_Pass_Object is null record;
   type Compute_Pass_Access is access all Compute_Pass_Object with
     Convention => C;

   type Copy_Pass_Object is null record;
   type Copy_Pass_Access is access all Copy_Pass_Object with
     Convention => C;

   type Fence_Object is null record;
   type Fence_Access is access all Fence_Object with
     Convention => C;

   type Fence_Access_Array is
     array (C.size_t range <>) of aliased Fence_Access
   with Convention => C;

   type Float_Colour is
      record
         Red   : Float := 0.0;
         Green : Float := 0.0;
         Blue  : Float := 0.0;
         Alpha : Float := 0.0;
      end record
   with Convention => C;

   type Viewport is
      record
         X         : Float := 0.0;
         Y         : Float := 0.0;
         Width     : Float := 0.0;
         Height    : Float := 0.0;
         Min_Depth : Float := 0.0;
         Max_Depth : Float := 1.0;
      end record
   with Convention => C;

   type Color_Target_Info is
      record
         Texture              : Texture_Access := null;
         Mip_Level            : Unsigned_32 := 0;
         Layer_Or_Depth_Plane : Unsigned_32 := 0;
         Clear_Color          : Float_Colour :=
           (Red => 0.0, Green => 0.0, Blue => 0.0, Alpha => 1.0);
         Load_Op              : Load_Ops := Load_Clear;
         Store_Op             : Store_Ops := Store_Store;
         Resolve_Texture      : Texture_Access := null;
         Resolve_Mip_Level    : Unsigned_32 := 0;
         Resolve_Layer        : Unsigned_32 := 0;
         Cycle                : CE.bool := CE.bool'Val (0);
         Cycle_Resolve        : CE.bool := CE.bool'Val (0);
         Padding_1            : Unsigned_8 := 0;
         Padding_2            : Unsigned_8 := 0;
      end record
   with Convention => C;

   type Color_Target_Info_Array is
     array (C.size_t range <>) of aliased Color_Target_Info
   with Convention => C;

   type Depth_Stencil_Target_Info is
      record
         Texture           : Texture_Access := null;
         Clear_Depth       : Float := 1.0;
         Load_Op           : Load_Ops := Load_Clear;
         Store_Op          : Store_Ops := Store_Store;
         Stencil_Load_Op   : Load_Ops := Load_Dont_Care;
         Stencil_Store_Op  : Store_Ops := Store_Dont_Care;
         Cycle             : CE.bool := CE.bool'Val (0);
         Clear_Stencil     : Unsigned_8 := 0;
         Mip_Level         : Unsigned_8 := 0;
         Layer             : Unsigned_8 := 0;
      end record
   with Convention => C;

   type Texture_Transfer_Info is
      record
         Transfer_Buffer : Transfer_Buffer_Access := null;
         Offset          : Unsigned_32 := 0;
         Pixels_Per_Row  : Unsigned_32 := 0;
         Rows_Per_Layer  : Unsigned_32 := 0;
      end record
   with Convention => C;

   type Transfer_Buffer_Location is
      record
         Transfer_Buffer : Transfer_Buffer_Access := null;
         Offset          : Unsigned_32 := 0;
      end record
   with Convention => C;

   type Texture_Location is
      record
         Texture   : Texture_Access := null;
         Mip_Level : Unsigned_32 := 0;
         Layer     : Unsigned_32 := 0;
         X         : Unsigned_32 := 0;
         Y         : Unsigned_32 := 0;
         Z         : Unsigned_32 := 0;
      end record
   with Convention => C;

   type Texture_Region is
      record
         Texture   : Texture_Access := null;
         Mip_Level : Unsigned_32 := 0;
         Layer     : Unsigned_32 := 0;
         X         : Unsigned_32 := 0;
         Y         : Unsigned_32 := 0;
         Z         : Unsigned_32 := 0;
         Width     : Unsigned_32 := 0;
         Height    : Unsigned_32 := 0;
         Depth     : Unsigned_32 := 1;
      end record
   with Convention => C;

   type Buffer_Location is
      record
         Buffer : Buffer_Access := null;
         Offset : Unsigned_32 := 0;
      end record
   with Convention => C;

   type Buffer_Region is
      record
         Buffer : Buffer_Access := null;
         Offset : Unsigned_32 := 0;
         Size   : Unsigned_32 := 0;
      end record
   with Convention => C;

   type Texture_Create_Info is
      record
         Kind                 : Texture_Types := Texture_2D;
         Format               : Texture_Formats := Invalid_Texture_Format;
         Usage                : Texture_Usage_Flags := 0;
         Width                : Unsigned_32 := 0;
         Height               : Unsigned_32 := 0;
         Layer_Count_Or_Depth : Unsigned_32 := 1;
         Num_Levels           : Unsigned_32 := 1;
         Sample_Count         : Sample_Counts := Sample_Count_1;
         Props                : SDL.Raw.Properties.ID :=
           SDL.Raw.Properties.No_Properties;
      end record
   with Convention => C;

   type Buffer_Create_Info is
      record
         Usage : Buffer_Usage_Flags := 0;
         Size  : Unsigned_32 := 0;
         Props : SDL.Raw.Properties.ID := SDL.Raw.Properties.No_Properties;
      end record
   with Convention => C;

   type Transfer_Buffer_Create_Info is
      record
         Usage : Transfer_Buffer_Usages := Transfer_Buffer_Upload;
         Size  : Unsigned_32 := 0;
         Props : SDL.Raw.Properties.ID := SDL.Raw.Properties.No_Properties;
      end record
   with Convention => C;

   type Sampler_Create_Info is
      record
         Min_Filter        : Filters := Filter_Linear;
         Mag_Filter        : Filters := Filter_Linear;
         Mipmap_Mode       : Sampler_Mipmap_Modes := Sampler_Mipmap_Mode_Linear;
         Address_Mode_U    : Sampler_Address_Modes := Sampler_Address_Mode_Repeat;
         Address_Mode_V    : Sampler_Address_Modes := Sampler_Address_Mode_Repeat;
         Address_Mode_W    : Sampler_Address_Modes := Sampler_Address_Mode_Repeat;
         Mip_LOD_Bias      : Float := 0.0;
         Max_Anisotropy    : Float := 1.0;
         Compare_Op        : Compare_Ops := Compare_Op_Invalid;
         Min_LOD           : Float := 0.0;
         Max_LOD           : Float := 0.0;
         Enable_Anisotropy : CE.bool := CE.bool'Val (0);
         Enable_Compare    : CE.bool := CE.bool'Val (0);
         Padding_1         : Unsigned_8 := 0;
         Padding_2         : Unsigned_8 := 0;
         Props             : SDL.Raw.Properties.ID :=
           SDL.Raw.Properties.No_Properties;
      end record
   with Convention => C;

   type Vertex_Buffer_Description is
      record
         Slot               : Unsigned_32 := 0;
         Pitch              : Unsigned_32 := 0;
         Input_Rate         : Vertex_Input_Rates := Vertex_Input_Rate_Vertex;
         Instance_Step_Rate : Unsigned_32 := 0;
      end record
   with Convention => C;

   type Vertex_Attribute is
      record
         Location    : Unsigned_32 := 0;
         Buffer_Slot : Unsigned_32 := 0;
         Format      : Vertex_Element_Formats := Vertex_Element_Invalid;
         Offset      : Unsigned_32 := 0;
      end record
   with Convention => C;

   type Vertex_Input_State is
      record
         Vertex_Buffer_Descriptions : System.Address := System.Null_Address;
         Num_Vertex_Buffers         : Unsigned_32 := 0;
         Vertex_Attributes          : System.Address := System.Null_Address;
         Num_Vertex_Attributes      : Unsigned_32 := 0;
      end record
   with Convention => C;

   type Stencil_Op_State is
      record
         Fail_Op       : Stencil_Ops := Stencil_Op_Keep;
         Pass_Op       : Stencil_Ops := Stencil_Op_Keep;
         Depth_Fail_Op : Stencil_Ops := Stencil_Op_Keep;
         Compare_Op    : Compare_Ops := Compare_Op_Always;
      end record
   with Convention => C;

   type Color_Target_Blend_State is
      record
         Source_Colour_Blend_Factor      : Blend_Factors := Blend_Factor_One;
         Destination_Colour_Blend_Factor : Blend_Factors := Blend_Factor_Zero;
         Colour_Blend_Op                 : Blend_Ops := Blend_Op_Add;
         Source_Alpha_Blend_Factor       : Blend_Factors := Blend_Factor_One;
         Destination_Alpha_Blend_Factor  : Blend_Factors := Blend_Factor_Zero;
         Alpha_Blend_Op                  : Blend_Ops := Blend_Op_Add;
         Colour_Write_Mask               : Color_Component_Flags := 16#0F#;
         Enable_Blend            : CE.bool := CE.bool'Val (0);
         Enable_Colour_Write_Mask : CE.bool := CE.bool'Val (0);
         Padding_1               : Unsigned_8 := 0;
         Padding_2               : Unsigned_8 := 0;
      end record
   with Convention => C;

   type Shader_Create_Info is
      record
         Code_Size            : C.size_t := 0;
         Code                 : System.Address := System.Null_Address;
         Entry_Point          : CS.chars_ptr := CS.Null_Ptr;
         Format               : Shader_Formats := Invalid_Shader_Format;
         Stage                : Shader_Stages := Shader_Stage_Vertex;
         Num_Samplers         : Unsigned_32 := 0;
         Num_Storage_Textures : Unsigned_32 := 0;
         Num_Storage_Buffers  : Unsigned_32 := 0;
         Num_Uniform_Buffers  : Unsigned_32 := 0;
         Props                : SDL.Raw.Properties.ID :=
           SDL.Raw.Properties.No_Properties;
      end record
   with Convention => C;

   type Rasterizer_State is
      record
         Fill_Mode                  : Fill_Modes := Fill_Mode_Fill;
         Cull_Mode                  : Cull_Modes := Cull_Mode_None;
         Front_Face                 : Front_Faces :=
           Front_Face_Counter_Clockwise;
         Depth_Bias_Constant_Factor : Float := 0.0;
         Depth_Bias_Clamp           : Float := 0.0;
         Depth_Bias_Slope_Factor    : Float := 0.0;
         Enable_Depth_Bias          : CE.bool := CE.bool'Val (0);
         Enable_Depth_Clip          : CE.bool := CE.bool'Val (1);
         Padding_1                  : Unsigned_8 := 0;
         Padding_2                  : Unsigned_8 := 0;
      end record
   with Convention => C;

   type Multisample_State is
      record
         Sample_Count             : Sample_Counts := Sample_Count_1;
         Sample_Mask              : Unsigned_32 := 0;
         Enable_Mask              : CE.bool := CE.bool'Val (0);
         Enable_Alpha_To_Coverage : CE.bool := CE.bool'Val (0);
         Padding_2                : Unsigned_8 := 0;
         Padding_3                : Unsigned_8 := 0;
      end record
   with Convention => C;

   type Depth_Stencil_State is
      record
         Compare_Op          : Compare_Ops := Compare_Op_Always;
         Back_Stencil_State  : Stencil_Op_State :=
           (Fail_Op       => Stencil_Op_Keep,
            Pass_Op       => Stencil_Op_Keep,
            Depth_Fail_Op => Stencil_Op_Keep,
            Compare_Op    => Compare_Op_Always);
         Front_Stencil_State : Stencil_Op_State :=
           (Fail_Op       => Stencil_Op_Keep,
            Pass_Op       => Stencil_Op_Keep,
            Depth_Fail_Op => Stencil_Op_Keep,
            Compare_Op    => Compare_Op_Always);
         Compare_Mask       : Unsigned_8 := 0;
         Write_Mask         : Unsigned_8 := 0;
         Enable_Depth_Test  : CE.bool := CE.bool'Val (0);
         Enable_Depth_Write : CE.bool := CE.bool'Val (0);
         Enable_Stencil_Test : CE.bool := CE.bool'Val (0);
         Padding_1          : Unsigned_8 := 0;
         Padding_2          : Unsigned_8 := 0;
         Padding_3          : Unsigned_8 := 0;
      end record
   with Convention => C;

   type Color_Target_Description is
      record
         Format      : Texture_Formats := Invalid_Texture_Format;
         Blend_State : Color_Target_Blend_State :=
           (Source_Colour_Blend_Factor      => Blend_Factor_One,
            Destination_Colour_Blend_Factor => Blend_Factor_Zero,
            Colour_Blend_Op                 => Blend_Op_Add,
            Source_Alpha_Blend_Factor       => Blend_Factor_One,
            Destination_Alpha_Blend_Factor  => Blend_Factor_Zero,
            Alpha_Blend_Op                  => Blend_Op_Add,
            Colour_Write_Mask               => 16#0F#,
            Enable_Blend             => CE.bool'Val (0),
            Enable_Colour_Write_Mask => CE.bool'Val (0),
            Padding_1                => 0,
            Padding_2                => 0);
      end record
   with Convention => C;

   type Graphics_Pipeline_Target_Info is
      record
         Color_Target_Descriptions : System.Address := System.Null_Address;
         Num_Color_Targets         : Unsigned_32 := 0;
         Depth_Stencil_Format      : Texture_Formats := Invalid_Texture_Format;
         Has_Depth_Stencil_Target  : CE.bool := CE.bool'Val (0);
         Padding_1                 : Unsigned_8 := 0;
         Padding_2                 : Unsigned_8 := 0;
         Padding_3                 : Unsigned_8 := 0;
      end record
   with Convention => C;

   type Graphics_Pipeline_Create_Info is
      record
         Vertex_Shader       : Shader_Access := null;
         Fragment_Shader     : Shader_Access := null;
         Vertex_Input_State  : SDL.Raw.GPU.Vertex_Input_State :=
           (Vertex_Buffer_Descriptions => System.Null_Address,
            Num_Vertex_Buffers         => 0,
            Vertex_Attributes          => System.Null_Address,
            Num_Vertex_Attributes      => 0);
         Primitive_Type      : Primitive_Types := Primitive_Triangle_List;
         Rasterizer_State    : SDL.Raw.GPU.Rasterizer_State :=
           (Fill_Mode                  => Fill_Mode_Fill,
            Cull_Mode                  => Cull_Mode_None,
            Front_Face                 => Front_Face_Counter_Clockwise,
            Depth_Bias_Constant_Factor => 0.0,
            Depth_Bias_Clamp           => 0.0,
            Depth_Bias_Slope_Factor    => 0.0,
            Enable_Depth_Bias          => CE.bool'Val (0),
            Enable_Depth_Clip          => CE.bool'Val (1),
            Padding_1                  => 0,
            Padding_2                  => 0);
         Multisample_State   : SDL.Raw.GPU.Multisample_State :=
           (Sample_Count             => Sample_Count_1,
            Sample_Mask              => 0,
            Enable_Mask              => CE.bool'Val (0),
            Enable_Alpha_To_Coverage => CE.bool'Val (0),
            Padding_2                => 0,
            Padding_3                => 0);
         Depth_Stencil_State : SDL.Raw.GPU.Depth_Stencil_State :=
           (Compare_Op           => Compare_Op_Always,
            Back_Stencil_State   =>
              (Fail_Op       => Stencil_Op_Keep,
               Pass_Op       => Stencil_Op_Keep,
               Depth_Fail_Op => Stencil_Op_Keep,
               Compare_Op    => Compare_Op_Always),
            Front_Stencil_State  =>
              (Fail_Op       => Stencil_Op_Keep,
               Pass_Op       => Stencil_Op_Keep,
               Depth_Fail_Op => Stencil_Op_Keep,
               Compare_Op    => Compare_Op_Always),
            Compare_Mask        => 0,
            Write_Mask          => 0,
            Enable_Depth_Test   => CE.bool'Val (0),
            Enable_Depth_Write  => CE.bool'Val (0),
            Enable_Stencil_Test => CE.bool'Val (0),
            Padding_1           => 0,
            Padding_2           => 0,
            Padding_3           => 0);
         Target_Info         : SDL.Raw.GPU.Graphics_Pipeline_Target_Info :=
           (Color_Target_Descriptions => System.Null_Address,
            Num_Color_Targets         => 0,
            Depth_Stencil_Format      => Invalid_Texture_Format,
            Has_Depth_Stencil_Target  => CE.bool'Val (0),
            Padding_1                 => 0,
            Padding_2                 => 0,
            Padding_3                 => 0);
         Props               : SDL.Raw.Properties.ID :=
           SDL.Raw.Properties.No_Properties;
      end record
   with Convention => C;

   type Compute_Pipeline_Create_Info is
      record
         Code_Size                     : C.size_t := 0;
         Code                          : System.Address := System.Null_Address;
         Entry_Point                   : CS.chars_ptr := CS.Null_Ptr;
         Format                        : Shader_Formats := Invalid_Shader_Format;
         Num_Samplers                  : Unsigned_32 := 0;
         Num_Readonly_Storage_Textures : Unsigned_32 := 0;
         Num_Readonly_Storage_Buffers  : Unsigned_32 := 0;
         Num_Readwrite_Storage_Textures : Unsigned_32 := 0;
         Num_Readwrite_Storage_Buffers : Unsigned_32 := 0;
         Num_Uniform_Buffers           : Unsigned_32 := 0;
         Threadcount_X                 : Unsigned_32 := 1;
         Threadcount_Y                 : Unsigned_32 := 1;
         Threadcount_Z                 : Unsigned_32 := 1;
         Props                         : SDL.Raw.Properties.ID :=
           SDL.Raw.Properties.No_Properties;
      end record
   with Convention => C;

   type Blit_Region is
      record
         Texture              : Texture_Access := null;
         Mip_Level            : Unsigned_32 := 0;
         Layer_Or_Depth_Plane : Unsigned_32 := 0;
         X                    : Unsigned_32 := 0;
         Y                    : Unsigned_32 := 0;
         Width                : Unsigned_32 := 0;
         Height               : Unsigned_32 := 0;
      end record
   with Convention => C;

   type Blit_Info is
      record
         Source      : Blit_Region :=
           (Texture              => null,
            Mip_Level            => 0,
            Layer_Or_Depth_Plane => 0,
            X                    => 0,
            Y                    => 0,
            Width                => 0,
            Height               => 0);
         Destination : Blit_Region :=
           (Texture              => null,
            Mip_Level            => 0,
            Layer_Or_Depth_Plane => 0,
            X                    => 0,
            Y                    => 0,
            Width                => 0,
            Height               => 0);
         Load_Op     : Load_Ops := Load_Load;
         Clear_Colour : Float_Colour :=
           (Red => 0.0, Green => 0.0, Blue => 0.0, Alpha => 1.0);
         Flip_Mode   : Flip_Modes := Flip_None;
         Filter      : Filters := Filter_Linear;
         Cycle       : CE.bool := CE.bool'Val (0);
         Padding_1   : Unsigned_8 := 0;
         Padding_2   : Unsigned_8 := 0;
         Padding_3   : Unsigned_8 := 0;
      end record
   with Convention => C;

   type Buffer_Binding is
      record
         Buffer : Buffer_Access := null;
         Offset : Unsigned_32 := 0;
      end record
   with Convention => C;

   type Buffer_Binding_Array is
     array (C.size_t range <>) of aliased Buffer_Binding
   with Convention => C;

   type Texture_Sampler_Binding is
      record
         Texture : Texture_Access := null;
         Sampler : Sampler_Access := null;
      end record
   with Convention => C;

   type Texture_Sampler_Binding_Array is
     array (C.size_t range <>) of aliased Texture_Sampler_Binding
   with Convention => C;

   type Storage_Buffer_Read_Write_Binding is
      record
         Buffer    : Buffer_Access := null;
         Cycle     : CE.bool := CE.bool'Val (0);
         Padding_1 : Unsigned_8 := 0;
         Padding_2 : Unsigned_8 := 0;
         Padding_3 : Unsigned_8 := 0;
      end record
   with Convention => C;

   type Storage_Buffer_Read_Write_Binding_Array is
     array (C.size_t range <>) of aliased Storage_Buffer_Read_Write_Binding
   with Convention => C;

   type Storage_Texture_Read_Write_Binding is
      record
         Texture   : Texture_Access := null;
         Mip_Level : Unsigned_32 := 0;
         Layer     : Unsigned_32 := 0;
         Cycle     : CE.bool := CE.bool'Val (0);
         Padding_1 : Unsigned_8 := 0;
         Padding_2 : Unsigned_8 := 0;
         Padding_3 : Unsigned_8 := 0;
      end record
   with Convention => C;

   type Storage_Texture_Read_Write_Binding_Array is
     array (C.size_t range <>) of aliased Storage_Texture_Read_Write_Binding
   with Convention => C;

   function Supports_Shader_Formats
     (Format_Flags : in Shader_Formats;
      Name         : in CS.chars_ptr) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GPUSupportsShaderFormats";

   function Supports_Properties
     (Props : in SDL.Raw.Properties.ID) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GPUSupportsProperties";

   function Create_Device
     (Format_Flags : in Shader_Formats;
      Debug_Mode   : in CE.bool;
      Name         : in CS.chars_ptr) return Device_Access
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CreateGPUDevice";

   function Create_Device_With_Properties
     (Props : in SDL.Raw.Properties.ID) return Device_Access
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CreateGPUDeviceWithProperties";

   procedure Destroy_Device (Device : in Device_Access) with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_DestroyGPUDevice";

   function Get_Num_Drivers return C.int with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetNumGPUDrivers";

   function Get_Driver (Index : in C.int) return CS.chars_ptr with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGPUDriver";

   function Get_Device_Driver
     (Device : in Device_Access) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGPUDeviceDriver";

   function Get_Shader_Formats
     (Device : in Device_Access) return Shader_Formats
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGPUShaderFormats";

   function Get_Device_Properties
     (Device : in Device_Access) return SDL.Raw.Properties.ID
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGPUDeviceProperties";

   function Create_Compute_Pipeline
     (Device      : in Device_Access;
      Create_Info : access constant Compute_Pipeline_Create_Info)
      return Compute_Pipeline_Access
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CreateGPUComputePipeline";

   function Create_Graphics_Pipeline
     (Device      : in Device_Access;
      Create_Info : access constant Graphics_Pipeline_Create_Info)
      return Graphics_Pipeline_Access
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CreateGPUGraphicsPipeline";

   function Create_Sampler
     (Device      : in Device_Access;
      Create_Info : access constant Sampler_Create_Info) return Sampler_Access
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CreateGPUSampler";

   function Create_Shader
     (Device      : in Device_Access;
      Create_Info : access constant Shader_Create_Info) return Shader_Access
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CreateGPUShader";

   function Create_Texture
     (Device      : in Device_Access;
      Create_Info : access constant Texture_Create_Info) return Texture_Access
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CreateGPUTexture";

   function Create_Buffer
     (Device      : in Device_Access;
      Create_Info : access constant Buffer_Create_Info) return Buffer_Access
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CreateGPUBuffer";

   function Create_Transfer_Buffer
     (Device      : in Device_Access;
      Create_Info : access constant Transfer_Buffer_Create_Info)
      return Transfer_Buffer_Access
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CreateGPUTransferBuffer";

   procedure Release_Texture
     (Device  : in Device_Access;
      Texture : in Texture_Access)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ReleaseGPUTexture";

   procedure Release_Sampler
     (Device  : in Device_Access;
      Sampler : in Sampler_Access)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ReleaseGPUSampler";

   procedure Release_Buffer
     (Device : in Device_Access;
      Buffer : in Buffer_Access)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ReleaseGPUBuffer";

   procedure Release_Transfer_Buffer
     (Device          : in Device_Access;
      Transfer_Buffer : in Transfer_Buffer_Access)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ReleaseGPUTransferBuffer";

   procedure Release_Compute_Pipeline
     (Device           : in Device_Access;
      Compute_Pipeline : in Compute_Pipeline_Access)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ReleaseGPUComputePipeline";

   procedure Release_Shader
     (Device : in Device_Access;
      Shader : in Shader_Access)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ReleaseGPUShader";

   procedure Release_Graphics_Pipeline
     (Device            : in Device_Access;
      Graphics_Pipeline : in Graphics_Pipeline_Access)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ReleaseGPUGraphicsPipeline";

   procedure Set_Buffer_Name
     (Device : in Device_Access;
      Buffer : in Buffer_Access;
      Text   : in CS.chars_ptr)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetGPUBufferName";

   procedure Set_Texture_Name
     (Device  : in Device_Access;
      Texture : in Texture_Access;
      Text    : in CS.chars_ptr)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetGPUTextureName";

   procedure GDK_Suspend_GPU
     (Device : in Device_Access)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GDKSuspendGPU";

   procedure GDK_Resume_GPU
     (Device : in Device_Access)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GDKResumeGPU";

   function Acquire_Command_Buffer
     (Device : in Device_Access) return Command_Buffer_Access
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_AcquireGPUCommandBuffer";

   procedure Push_Vertex_Uniform_Data
     (Command_Buffer : in Command_Buffer_Access;
      Slot_Index     : in Unsigned_32;
      Data           : in System.Address;
      Length         : in Unsigned_32)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_PushGPUVertexUniformData";

   procedure Push_Fragment_Uniform_Data
     (Command_Buffer : in Command_Buffer_Access;
      Slot_Index     : in Unsigned_32;
      Data           : in System.Address;
      Length         : in Unsigned_32)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_PushGPUFragmentUniformData";

   procedure Push_Compute_Uniform_Data
     (Command_Buffer : in Command_Buffer_Access;
      Slot_Index     : in Unsigned_32;
      Data           : in System.Address;
      Length         : in Unsigned_32)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_PushGPUComputeUniformData";

   procedure Insert_Debug_Label
     (Command_Buffer : in Command_Buffer_Access;
      Text           : in CS.chars_ptr)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_InsertGPUDebugLabel";

   procedure Push_Debug_Group
     (Command_Buffer : in Command_Buffer_Access;
      Name           : in CS.chars_ptr)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_PushGPUDebugGroup";

   procedure Pop_Debug_Group
     (Command_Buffer : in Command_Buffer_Access)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_PopGPUDebugGroup";

   function Begin_Render_Pass
     (Command_Buffer            : in Command_Buffer_Access;
      Color_Target_Infos        : access constant Color_Target_Info;
      Num_Color_Targets         : in Unsigned_32;
      Depth_Stencil_Target      : access constant Depth_Stencil_Target_Info)
      return Render_Pass_Access
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_BeginGPURenderPass";

   procedure Set_Viewport
     (Render_Pass : in Render_Pass_Access;
      Area        : access constant Viewport)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetGPUViewport";

   procedure Bind_Graphics_Pipeline
     (Render_Pass        : in Render_Pass_Access;
      Graphics_Pipeline  : in Graphics_Pipeline_Access)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_BindGPUGraphicsPipeline";

   procedure Set_Scissor
     (Render_Pass : in Render_Pass_Access;
      Scissor     : access constant SDL.Raw.Rect.Rectangle)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetGPUScissor";

   procedure Set_Blend_Constants
     (Render_Pass      : in Render_Pass_Access;
      Blend_Constants  : in Float_Colour)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetGPUBlendConstants";

   procedure Set_Stencil_Reference
     (Render_Pass : in Render_Pass_Access;
      Reference   : in Unsigned_8)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetGPUStencilReference";

   procedure Bind_Vertex_Buffers
     (Render_Pass   : in Render_Pass_Access;
      First_Slot    : in Unsigned_32;
      Bindings      : access constant Buffer_Binding;
      Num_Bindings  : in Unsigned_32)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_BindGPUVertexBuffers";

   procedure Bind_Index_Buffer
     (Render_Pass         : in Render_Pass_Access;
      Binding             : access constant Buffer_Binding;
      Index_Element_Size  : in Index_Element_Sizes)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_BindGPUIndexBuffer";

   procedure Bind_Vertex_Samplers
     (Render_Pass      : in Render_Pass_Access;
      First_Slot       : in Unsigned_32;
      Bindings         : access constant Texture_Sampler_Binding;
      Num_Bindings     : in Unsigned_32)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_BindGPUVertexSamplers";

   procedure Bind_Vertex_Storage_Textures
     (Render_Pass      : in Render_Pass_Access;
      First_Slot       : in Unsigned_32;
      Storage_Textures : access constant Texture_Access;
      Num_Bindings     : in Unsigned_32)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_BindGPUVertexStorageTextures";

   procedure Bind_Vertex_Storage_Buffers
     (Render_Pass     : in Render_Pass_Access;
      First_Slot      : in Unsigned_32;
      Storage_Buffers : access constant Buffer_Access;
      Num_Bindings    : in Unsigned_32)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_BindGPUVertexStorageBuffers";

   procedure Bind_Fragment_Samplers
     (Render_Pass      : in Render_Pass_Access;
      First_Slot       : in Unsigned_32;
      Bindings         : access constant Texture_Sampler_Binding;
      Num_Bindings     : in Unsigned_32)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_BindGPUFragmentSamplers";

   procedure Bind_Fragment_Storage_Textures
     (Render_Pass      : in Render_Pass_Access;
      First_Slot       : in Unsigned_32;
      Storage_Textures : access constant Texture_Access;
      Num_Bindings     : in Unsigned_32)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_BindGPUFragmentStorageTextures";

   procedure Bind_Fragment_Storage_Buffers
     (Render_Pass     : in Render_Pass_Access;
      First_Slot      : in Unsigned_32;
      Storage_Buffers : access constant Buffer_Access;
      Num_Bindings    : in Unsigned_32)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_BindGPUFragmentStorageBuffers";

   procedure Draw_Indexed_Primitives
     (Render_Pass    : in Render_Pass_Access;
      Num_Indices    : in Unsigned_32;
      Num_Instances  : in Unsigned_32;
      First_Index    : in Unsigned_32;
      Vertex_Offset  : in C.int;
      First_Instance : in Unsigned_32)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_DrawGPUIndexedPrimitives";

   procedure Draw_Primitives
     (Render_Pass    : in Render_Pass_Access;
      Num_Vertices   : in Unsigned_32;
      Num_Instances  : in Unsigned_32;
      First_Vertex   : in Unsigned_32;
      First_Instance : in Unsigned_32)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_DrawGPUPrimitives";

   procedure Draw_Primitives_Indirect
     (Render_Pass : in Render_Pass_Access;
      Buffer      : in Buffer_Access;
      Offset      : in Unsigned_32;
      Draw_Count  : in Unsigned_32)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_DrawGPUPrimitivesIndirect";

   procedure Draw_Indexed_Primitives_Indirect
     (Render_Pass : in Render_Pass_Access;
      Buffer      : in Buffer_Access;
      Offset      : in Unsigned_32;
      Draw_Count  : in Unsigned_32)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_DrawGPUIndexedPrimitivesIndirect";

   procedure End_Render_Pass
     (Render_Pass : in Render_Pass_Access)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_EndGPURenderPass";

   function Begin_Compute_Pass
     (Command_Buffer                 : in Command_Buffer_Access;
      Storage_Texture_Bindings       : access constant Storage_Texture_Read_Write_Binding;
      Num_Storage_Texture_Bindings   : in Unsigned_32;
      Storage_Buffer_Bindings        : access constant Storage_Buffer_Read_Write_Binding;
      Num_Storage_Buffer_Bindings    : in Unsigned_32)
      return Compute_Pass_Access
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_BeginGPUComputePass";

   procedure Bind_Compute_Pipeline
     (Compute_Pass     : in Compute_Pass_Access;
      Compute_Pipeline : in Compute_Pipeline_Access)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_BindGPUComputePipeline";

   procedure Bind_Compute_Samplers
     (Compute_Pass   : in Compute_Pass_Access;
      First_Slot     : in Unsigned_32;
      Bindings       : access constant Texture_Sampler_Binding;
      Num_Bindings   : in Unsigned_32)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_BindGPUComputeSamplers";

   procedure Bind_Compute_Storage_Textures
     (Compute_Pass     : in Compute_Pass_Access;
      First_Slot       : in Unsigned_32;
      Storage_Textures : access constant Texture_Access;
      Num_Bindings     : in Unsigned_32)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_BindGPUComputeStorageTextures";

   procedure Bind_Compute_Storage_Buffers
     (Compute_Pass    : in Compute_Pass_Access;
      First_Slot      : in Unsigned_32;
      Storage_Buffers : access constant Buffer_Access;
      Num_Bindings    : in Unsigned_32)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_BindGPUComputeStorageBuffers";

   procedure Dispatch_Compute
     (Compute_Pass : in Compute_Pass_Access;
      Groupcount_X : in Unsigned_32;
      Groupcount_Y : in Unsigned_32;
      Groupcount_Z : in Unsigned_32)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_DispatchGPUCompute";

   procedure Dispatch_Compute_Indirect
     (Compute_Pass : in Compute_Pass_Access;
      Buffer       : in Buffer_Access;
      Offset       : in Unsigned_32)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_DispatchGPUComputeIndirect";

   procedure End_Compute_Pass
     (Compute_Pass : in Compute_Pass_Access)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_EndGPUComputePass";

   function Map_Transfer_Buffer
     (Device          : in Device_Access;
      Transfer_Buffer : in Transfer_Buffer_Access;
      Cycle           : in CE.bool) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_MapGPUTransferBuffer";

   procedure Unmap_Transfer_Buffer
     (Device          : in Device_Access;
      Transfer_Buffer : in Transfer_Buffer_Access)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_UnmapGPUTransferBuffer";

   function Begin_Copy_Pass
     (Command_Buffer : in Command_Buffer_Access) return Copy_Pass_Access
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_BeginGPUCopyPass";

   procedure Upload_To_Texture
     (Copy_Pass   : in Copy_Pass_Access;
      Source      : access constant Texture_Transfer_Info;
      Destination : access constant Texture_Region;
      Cycle       : in CE.bool)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_UploadToGPUTexture";

   procedure Upload_To_Buffer
     (Copy_Pass   : in Copy_Pass_Access;
      Source      : access constant Transfer_Buffer_Location;
      Destination : access constant Buffer_Region;
      Cycle       : in CE.bool)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_UploadToGPUBuffer";

   procedure Copy_Texture_To_Texture
     (Copy_Pass   : in Copy_Pass_Access;
      Source      : access constant Texture_Location;
      Destination : access constant Texture_Location;
      Width       : in Unsigned_32;
      Height      : in Unsigned_32;
      Depth       : in Unsigned_32;
      Cycle       : in CE.bool)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CopyGPUTextureToTexture";

   procedure Copy_Buffer_To_Buffer
     (Copy_Pass   : in Copy_Pass_Access;
      Source      : access constant Buffer_Location;
      Destination : access constant Buffer_Location;
      Size        : in Unsigned_32;
      Cycle       : in CE.bool)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CopyGPUBufferToBuffer";

   procedure Download_From_Texture
     (Copy_Pass   : in Copy_Pass_Access;
      Source      : access constant Texture_Region;
      Destination : access constant Texture_Transfer_Info)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_DownloadFromGPUTexture";

   procedure Download_From_Buffer
     (Copy_Pass   : in Copy_Pass_Access;
      Source      : access constant Buffer_Region;
      Destination : access constant Transfer_Buffer_Location)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_DownloadFromGPUBuffer";

   procedure End_Copy_Pass
     (Copy_Pass : in Copy_Pass_Access)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_EndGPUCopyPass";

   procedure Generate_Mipmaps_For_Texture
     (Command_Buffer : in Command_Buffer_Access;
      Texture        : in Texture_Access)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GenerateMipmapsForGPUTexture";

   procedure Blit_Texture
     (Command_Buffer : in Command_Buffer_Access;
      Info           : access constant Blit_Info)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_BlitGPUTexture";

   function Window_Supports_Swapchain_Composition
     (Device                : in Device_Access;
      Window                : in Window_Pointer;
      Swapchain_Composition : in Swapchain_Compositions) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_WindowSupportsGPUSwapchainComposition";

   function Window_Supports_Present_Mode
     (Device       : in Device_Access;
      Window       : in Window_Pointer;
      Present_Mode : in Present_Modes) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_WindowSupportsGPUPresentMode";

   function Claim_Window
     (Device : in Device_Access;
      Window : in Window_Pointer) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ClaimWindowForGPUDevice";

   procedure Release_Window
     (Device : in Device_Access;
      Window : in Window_Pointer)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ReleaseWindowFromGPUDevice";

   function Set_Swapchain_Parameters
     (Device                : in Device_Access;
      Window                : in Window_Pointer;
      Swapchain_Composition : in Swapchain_Compositions;
      Present_Mode          : in Present_Modes) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetGPUSwapchainParameters";

   function Set_Allowed_Frames_In_Flight
     (Device                   : in Device_Access;
      Allowed_Frames_In_Flight : in Unsigned_32) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetGPUAllowedFramesInFlight";

   function Get_Swapchain_Texture_Format
     (Device : in Device_Access;
      Window : in Window_Pointer) return Texture_Formats
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGPUSwapchainTextureFormat";

   function Acquire_Swapchain_Texture
     (Command_Buffer : in Command_Buffer_Access;
      Window         : in Window_Pointer;
      Texture        : access Texture_Access;
      Texture_Width  : access Unsigned_32;
      Texture_Height : access Unsigned_32) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_AcquireGPUSwapchainTexture";

   function Wait_For_Swapchain
     (Device : in Device_Access;
      Window : in Window_Pointer) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_WaitForGPUSwapchain";

   function Wait_And_Acquire_Swapchain_Texture
     (Command_Buffer : in Command_Buffer_Access;
      Window         : in Window_Pointer;
      Texture        : access Texture_Access;
      Texture_Width  : access Unsigned_32;
      Texture_Height : access Unsigned_32) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_WaitAndAcquireGPUSwapchainTexture";

   function Submit_Command_Buffer
     (Command_Buffer : in Command_Buffer_Access) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SubmitGPUCommandBuffer";

   function Submit_Command_Buffer_And_Acquire_Fence
     (Command_Buffer : in Command_Buffer_Access) return Fence_Access
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SubmitGPUCommandBufferAndAcquireFence";

   function Cancel_Command_Buffer
     (Command_Buffer : in Command_Buffer_Access) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CancelGPUCommandBuffer";

   function Wait_For_Idle
     (Device : in Device_Access) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_WaitForGPUIdle";

   function Wait_For_Fences
     (Device     : in Device_Access;
      Wait_All   : in CE.bool;
      Fences     : access constant Fence_Access;
      Num_Fences : in Unsigned_32) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_WaitForGPUFences";

   function Query_Fence
     (Device : in Device_Access;
      Fence  : in Fence_Access) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_QueryGPUFence";

   procedure Release_Fence
     (Device : in Device_Access;
      Fence  : in Fence_Access)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ReleaseGPUFence";

   function Texture_Format_Texel_Block_Size
     (Format : in Texture_Formats) return Unsigned_32
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GPUTextureFormatTexelBlockSize";

   function Texture_Supports_Format
     (Device : in Device_Access;
      Format : in Texture_Formats;
      Kind   : in Texture_Types;
      Usage  : in Texture_Usage_Flags) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GPUTextureSupportsFormat";

   function Texture_Supports_Sample_Count
     (Device       : in Device_Access;
      Format       : in Texture_Formats;
      Sample_Count : in Sample_Counts) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GPUTextureSupportsSampleCount";

   function Calculate_Texture_Format_Size
     (Format               : in Texture_Formats;
      Width                : in Unsigned_32;
      Height               : in Unsigned_32;
      Depth_Or_Layer_Count : in Unsigned_32) return Unsigned_32
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CalculateGPUTextureFormatSize";

   function Get_Pixel_Format_From_Texture_Format
     (Format : in Texture_Formats)
      return SDL.Raw.Pixels.Pixel_Format_Name
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetPixelFormatFromGPUTextureFormat";

   function Get_Texture_Format_From_Pixel_Format
     (Format : in SDL.Raw.Pixels.Pixel_Format_Name)
      return Texture_Formats
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGPUTextureFormatFromPixelFormat";
end SDL.Raw.GPU;
