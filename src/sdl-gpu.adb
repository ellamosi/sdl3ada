with Ada.Streams;
with Interfaces.C.Extensions;
with Interfaces.C.Strings;

with SDL.Error;
with SDL.Platform;
with SDL.Raw.Pixels;

package body SDL.GPU is
   package CE renames Interfaces.C.Extensions;
   package CS renames Interfaces.C.Strings;
   package Raw renames SDL.Raw.GPU;

   use type CE.bool;
   use type CS.chars_ptr;
   use type Device_Handle;
   use type Buffer_Handle;
   use type Transfer_Buffer_Handle;
   use type Texture_Handle;
   use type Sampler_Handle;
   use type Shader_Handle;
   use type Graphics_Pipeline_Handle;
   use type Compute_Pipeline_Handle;
   use type Command_Buffer_Handle;
   use type Render_Pass_Handle;
   use type Compute_Pass_Handle;
   use type Copy_Pass_Handle;
   use type Fence_Handle;
   use type Shader_Formats;
   use type System.Address;

   function To_C_Bool (Value : in Boolean) return CE.bool is
     (if Value then CE.bool'Val (1) else CE.bool'Val (0));

   function To_Bool (Value : in CE.bool) return Boolean is
     (Value /= CE.bool'Val (0));

   function To_Raw (Value : in Present_Modes) return Raw.Present_Modes is
     (Raw.Present_Modes (Present_Modes'Enum_Rep (Value)));

   function To_Raw
     (Value : in Swapchain_Compositions) return Raw.Swapchain_Compositions is
     (Raw.Swapchain_Compositions (Swapchain_Compositions'Enum_Rep (Value)));

   function To_Raw (Value : in Load_Operations) return Raw.Load_Ops is
     (Raw.Load_Ops (Load_Operations'Enum_Rep (Value)));

   function To_Raw (Value : in Store_Operations) return Raw.Store_Ops is
     (Raw.Store_Ops (Store_Operations'Enum_Rep (Value)));

   function To_Raw (Value : in Texture_Types) return Raw.Texture_Types is
     (Raw.Texture_Types (Texture_Types'Enum_Rep (Value)));

   function To_Raw (Value : in Sample_Counts) return Raw.Sample_Counts is
     (Raw.Sample_Counts (Sample_Counts'Enum_Rep (Value)));

   function To_Raw
     (Value : in Transfer_Buffer_Usages) return Raw.Transfer_Buffer_Usages is
     (Raw.Transfer_Buffer_Usages (Transfer_Buffer_Usages'Enum_Rep (Value)));

   function To_Raw (Value : in Primitive_Types) return Raw.Primitive_Types is
     (Raw.Primitive_Types (Primitive_Types'Enum_Rep (Value)));

   function To_Raw
     (Value : in Index_Element_Sizes) return Raw.Index_Element_Sizes is
     (Raw.Index_Element_Sizes (Index_Element_Sizes'Enum_Rep (Value)));

   function To_Raw (Value : in Shader_Stages) return Raw.Shader_Stages is
     (Raw.Shader_Stages (Shader_Stages'Enum_Rep (Value)));

   function To_Raw
     (Value : in Vertex_Element_Formats) return Raw.Vertex_Element_Formats is
     (Raw.Vertex_Element_Formats (Vertex_Element_Formats'Enum_Rep (Value)));

   function To_Raw
     (Value : in Vertex_Input_Rates) return Raw.Vertex_Input_Rates is
     (Raw.Vertex_Input_Rates (Vertex_Input_Rates'Enum_Rep (Value)));

   function To_Raw (Value : in Fill_Modes) return Raw.Fill_Modes is
     (Raw.Fill_Modes (Fill_Modes'Enum_Rep (Value)));

   function To_Raw (Value : in Cull_Modes) return Raw.Cull_Modes is
     (Raw.Cull_Modes (Cull_Modes'Enum_Rep (Value)));

   function To_Raw (Value : in Front_Faces) return Raw.Front_Faces is
     (Raw.Front_Faces (Front_Faces'Enum_Rep (Value)));

   function To_Raw
     (Value : in Compare_Operations) return Raw.Compare_Ops is
     (Raw.Compare_Ops (Compare_Operations'Enum_Rep (Value)));

   function To_Raw
     (Value : in Stencil_Operations) return Raw.Stencil_Ops is
     (Raw.Stencil_Ops (Stencil_Operations'Enum_Rep (Value)));

   function To_Raw (Value : in Blend_Operations) return Raw.Blend_Ops is
     (Raw.Blend_Ops (Blend_Operations'Enum_Rep (Value)));

   function To_Raw (Value : in Blend_Factors) return Raw.Blend_Factors is
     (Raw.Blend_Factors (Blend_Factors'Enum_Rep (Value)));

   function To_Raw (Value : in Filters) return Raw.Filters is
     (Raw.Filters (Filters'Enum_Rep (Value)));

   function To_Raw
     (Value : in Sampler_Mipmap_Modes) return Raw.Sampler_Mipmap_Modes is
     (Raw.Sampler_Mipmap_Modes (Sampler_Mipmap_Modes'Enum_Rep (Value)));

   function To_Raw
     (Value : in Sampler_Address_Modes) return Raw.Sampler_Address_Modes is
     (Raw.Sampler_Address_Modes (Sampler_Address_Modes'Enum_Rep (Value)));

   function To_Raw (Value : in Flip_Modes) return Raw.Flip_Modes is
     (Raw.Flip_Modes (Flip_Modes'Enum_Rep (Value)));

   function To_Raw
     (Value : in Vertex_Buffer_Description) return Raw.Vertex_Buffer_Description
   is
     ((Slot               => Value.Slot,
       Pitch              => Value.Pitch,
       Input_Rate         => To_Raw (Value.Input_Rate),
       Instance_Step_Rate => Value.Instance_Step_Rate));

   function To_Raw
     (Value : in Vertex_Attribute) return Raw.Vertex_Attribute
   is
     ((Location    => Value.Location,
       Buffer_Slot => Value.Buffer_Slot,
       Format      => To_Raw (Value.Format),
       Offset      => Value.Offset));

   function To_Raw
     (Value : in Stencil_Op_State) return Raw.Stencil_Op_State
   is
     ((Fail_Op       => To_Raw (Value.Fail_Operation),
       Pass_Op       => To_Raw (Value.Pass_Operation),
       Depth_Fail_Op => To_Raw (Value.Depth_Fail_Operation),
       Compare_Op    => To_Raw (Value.Compare_Operation)));

   function To_Raw
     (Value : in Color_Target_Blend_State)
      return Raw.Color_Target_Blend_State
   is
     ((Source_Colour_Blend_Factor      =>
         To_Raw (Value.Source_Colour_Blend_Factor),
       Destination_Colour_Blend_Factor =>
         To_Raw (Value.Destination_Colour_Blend_Factor),
       Colour_Blend_Op                 =>
         To_Raw (Value.Colour_Blend_Operation),
       Source_Alpha_Blend_Factor       =>
         To_Raw (Value.Source_Alpha_Blend_Factor),
       Destination_Alpha_Blend_Factor  =>
         To_Raw (Value.Destination_Alpha_Blend_Factor),
       Alpha_Blend_Op                  =>
         To_Raw (Value.Alpha_Blend_Operation),
       Colour_Write_Mask               => Value.Colour_Write_Mask,
       Enable_Blend                    => To_C_Bool (Value.Enable_Blend),
       Enable_Colour_Write_Mask        =>
         To_C_Bool (Value.Enable_Colour_Write_Mask),
       Padding_1                       => 0,
       Padding_2                       => 0));

   function To_Raw
     (Value : in Rasterizer_State) return Raw.Rasterizer_State
   is
     ((Fill_Mode                  => To_Raw (Value.Fill_Mode),
       Cull_Mode                  => To_Raw (Value.Cull_Mode),
       Front_Face                 => To_Raw (Value.Front_Face),
       Depth_Bias_Constant_Factor => Value.Depth_Bias_Constant_Factor,
       Depth_Bias_Clamp           => Value.Depth_Bias_Clamp,
       Depth_Bias_Slope_Factor    => Value.Depth_Bias_Slope_Factor,
       Enable_Depth_Bias          => To_C_Bool (Value.Enable_Depth_Bias),
       Enable_Depth_Clip          => To_C_Bool (Value.Enable_Depth_Clip),
       Padding_1                  => 0,
       Padding_2                  => 0));

   function To_Raw
     (Value : in Multisample_State) return Raw.Multisample_State
   is
     ((Sample_Count             => To_Raw (Value.Sample_Count),
       Sample_Mask              => Value.Sample_Mask,
       Enable_Mask              => To_C_Bool (Value.Enable_Mask),
       Enable_Alpha_To_Coverage =>
         To_C_Bool (Value.Enable_Alpha_To_Coverage),
       Padding_2                => 0,
       Padding_3                => 0));

   function To_Raw
     (Value : in Depth_Stencil_State) return Raw.Depth_Stencil_State
   is
     ((Compare_Op           => To_Raw (Value.Compare_Operation),
       Back_Stencil_State   => To_Raw (Value.Back_Stencil_State),
       Front_Stencil_State  => To_Raw (Value.Front_Stencil_State),
       Compare_Mask         => Value.Compare_Mask,
       Write_Mask           => Value.Write_Mask,
       Enable_Depth_Test    => To_C_Bool (Value.Enable_Depth_Test),
       Enable_Depth_Write   => To_C_Bool (Value.Enable_Depth_Write),
       Enable_Stencil_Test  => To_C_Bool (Value.Enable_Stencil_Test),
       Padding_1            => 0,
       Padding_2            => 0,
       Padding_3            => 0));

   function To_Raw
     (Value : in Color_Target_Description)
      return Raw.Color_Target_Description
   is
     ((Format      => Value.Format,
       Blend_State => To_Raw (Value.Blend_State)));

   type Raw_Vertex_Buffer_Description_Arrays is
     array (C.size_t range <>) of aliased Raw.Vertex_Buffer_Description
   with Convention => C;

   type Raw_Vertex_Attribute_Arrays is
     array (C.size_t range <>) of aliased Raw.Vertex_Attribute
   with Convention => C;

   type Raw_Colour_Target_Description_Arrays is
     array (C.size_t range <>) of aliased Raw.Color_Target_Description
   with Convention => C;

   type Raw_Color_Target_Info_Arrays is
     array (C.size_t range <>) of aliased Raw.Color_Target_Info
   with Convention => C;

   type Raw_Buffer_Binding_Arrays is
     array (C.size_t range <>) of aliased Raw.Buffer_Binding
   with Convention => C;

   type Raw_Texture_Sampler_Binding_Arrays is
     array (C.size_t range <>) of aliased Raw.Texture_Sampler_Binding
   with Convention => C;

   type Raw_Storage_Buffer_Read_Write_Binding_Arrays is
     array (C.size_t range <>) of aliased Raw.Storage_Buffer_Read_Write_Binding
   with Convention => C;

   type Raw_Storage_Texture_Read_Write_Binding_Arrays is
     array (C.size_t range <>) of aliased Raw.Storage_Texture_Read_Write_Binding
   with Convention => C;

   type Raw_Buffer_Handle_Arrays is
     array (C.size_t range <>) of aliased Buffer_Handle
   with Convention => C;

   type Raw_Texture_Handle_Arrays is
     array (C.size_t range <>) of aliased Texture_Handle
   with Convention => C;

   function Array_Last (Length : in Natural) return C.size_t is
     (if Length = 0 then 0 else C.size_t (Length - 1));

   function Bytes_Address
     (Data : in Ada.Streams.Stream_Element_Array) return System.Address is
     (if Data'Length = 0 then System.Null_Address else Data (Data'First)'Address);

   procedure Raise_GPU_Error
     (Default_Message : in String := "SDL GPU call failed");

   procedure Raise_GPU_Error
     (Default_Message : in String := "SDL GPU call failed")
   is
      Message : constant String := SDL.Error.Get;
   begin
      if Message = "" then
         raise GPU_Error with Default_Message;
      end if;

      raise GPU_Error with Message;
   end Raise_GPU_Error;

   procedure Require_Device (Self : in Device);
   procedure Require_Buffer (Self : in Buffer);
   procedure Require_Transfer_Buffer (Self : in Transfer_Buffer);
   procedure Require_Sampler (Self : in Sampler);
   procedure Require_Shader (Self : in Shader);
   procedure Require_Graphics_Pipeline (Self : in Graphics_Pipeline);
   procedure Require_Compute_Pipeline (Self : in Compute_Pipeline);
   procedure Require_Command_Buffer (Self : in Command_Buffer);
   procedure Require_Render_Pass (Self : in Render_Pass);
   procedure Require_Compute_Pass (Self : in Compute_Pass);
   procedure Require_Copy_Pass (Self : in Copy_Pass);
   procedure Require_Texture (Self : in Texture);

   function Window_Address
     (Window : in SDL.Video.Windows.Window) return System.Address;

   procedure Require_Device (Self : in Device) is
   begin
      if Self.Internal = null then
         raise GPU_Error with "Invalid GPU device";
      end if;
   end Require_Device;

   procedure Require_Buffer (Self : in Buffer) is
   begin
      if Self.Internal = null then
         raise GPU_Error with "Invalid GPU buffer";
      end if;
   end Require_Buffer;

   procedure Require_Transfer_Buffer (Self : in Transfer_Buffer) is
   begin
      if Self.Internal = null then
         raise GPU_Error with "Invalid GPU transfer buffer";
      end if;
   end Require_Transfer_Buffer;

   procedure Require_Sampler (Self : in Sampler) is
   begin
      if Self.Internal = null then
         raise GPU_Error with "Invalid GPU sampler";
      end if;
   end Require_Sampler;

   procedure Require_Shader (Self : in Shader) is
   begin
      if Self.Internal = null then
         raise GPU_Error with "Invalid GPU shader";
      end if;
   end Require_Shader;

   procedure Require_Graphics_Pipeline (Self : in Graphics_Pipeline) is
   begin
      if Self.Internal = null then
         raise GPU_Error with "Invalid GPU graphics pipeline";
      end if;
   end Require_Graphics_Pipeline;

   procedure Require_Compute_Pipeline (Self : in Compute_Pipeline) is
   begin
      if Self.Internal = null then
         raise GPU_Error with "Invalid GPU compute pipeline";
      end if;
   end Require_Compute_Pipeline;

   procedure Require_Command_Buffer (Self : in Command_Buffer) is
   begin
      if Self.Internal = null then
         raise GPU_Error with "Invalid GPU command buffer";
      end if;
   end Require_Command_Buffer;

   procedure Require_Render_Pass (Self : in Render_Pass) is
   begin
      if Self.Internal = null then
         raise GPU_Error with "Invalid GPU render pass";
      end if;
   end Require_Render_Pass;

   procedure Require_Compute_Pass (Self : in Compute_Pass) is
   begin
      if Self.Internal = null then
         raise GPU_Error with "Invalid GPU compute pass";
      end if;
   end Require_Compute_Pass;

   procedure Require_Copy_Pass (Self : in Copy_Pass) is
   begin
      if Self.Internal = null then
         raise GPU_Error with "Invalid GPU copy pass";
      end if;
   end Require_Copy_Pass;

   procedure Require_Texture (Self : in Texture) is
   begin
      if Self.Internal = null then
         raise GPU_Error with "Invalid GPU texture";
      end if;
   end Require_Texture;

   function Window_Address
     (Window : in SDL.Video.Windows.Window) return System.Address
   is
      Internal : constant System.Address := SDL.Video.Windows.Get_Internal (Window);
   begin
      if Internal = System.Null_Address then
         raise GPU_Error with "Invalid window";
      end if;

      return Internal;
   end Window_Address;

   procedure Reset
     (Self     : in out Buffer;
      Internal : in Buffer_Handle := null;
      Device   : in Device_Handle := null;
      Owns     : in Boolean := True);

   procedure Reset
     (Self     : in out Transfer_Buffer;
      Internal : in Transfer_Buffer_Handle := null;
      Device   : in Device_Handle := null;
      Owns     : in Boolean := True;
      Mapped   : in Boolean := False);

   procedure Reset
     (Self     : in out Texture;
      Internal : in Texture_Handle := null;
      Device   : in Device_Handle := null;
      Owns     : in Boolean := False);

   procedure Reset
     (Self     : in out Sampler;
      Internal : in Sampler_Handle := null;
      Device   : in Device_Handle := null;
      Owns     : in Boolean := True);

   procedure Reset
     (Self     : in out Shader;
      Internal : in Shader_Handle := null;
      Device   : in Device_Handle := null;
      Owns     : in Boolean := True);

   procedure Reset
     (Self     : in out Graphics_Pipeline;
      Internal : in Graphics_Pipeline_Handle := null;
      Device   : in Device_Handle := null;
      Owns     : in Boolean := True);

   procedure Reset
     (Self     : in out Compute_Pipeline;
      Internal : in Compute_Pipeline_Handle := null;
      Device   : in Device_Handle := null;
      Owns     : in Boolean := True);

   procedure Reset
     (Self     : in out Buffer;
      Internal : in Buffer_Handle := null;
      Device   : in Device_Handle := null;
      Owns     : in Boolean := True)
   is
   begin
      Self.Internal := Internal;
      Self.Device := Device;
      Self.Owns := Owns;
   end Reset;

   procedure Reset
     (Self     : in out Transfer_Buffer;
      Internal : in Transfer_Buffer_Handle := null;
      Device   : in Device_Handle := null;
      Owns     : in Boolean := True;
      Mapped   : in Boolean := False)
   is
   begin
      Self.Internal := Internal;
      Self.Device := Device;
      Self.Owns := Owns;
      Self.Mapped := Mapped;
   end Reset;

   procedure Reset
     (Self     : in out Texture;
      Internal : in Texture_Handle := null;
      Device   : in Device_Handle := null;
      Owns     : in Boolean := False)
   is
   begin
      Self.Internal := Internal;
      Self.Device := Device;
      Self.Owns := Owns;
   end Reset;

   procedure Reset
     (Self     : in out Sampler;
      Internal : in Sampler_Handle := null;
      Device   : in Device_Handle := null;
      Owns     : in Boolean := True)
   is
   begin
      Self.Internal := Internal;
      Self.Device := Device;
      Self.Owns := Owns;
   end Reset;

   procedure Reset
     (Self     : in out Shader;
      Internal : in Shader_Handle := null;
      Device   : in Device_Handle := null;
      Owns     : in Boolean := True)
   is
   begin
      Self.Internal := Internal;
      Self.Device := Device;
      Self.Owns := Owns;
   end Reset;

   procedure Reset
     (Self     : in out Graphics_Pipeline;
      Internal : in Graphics_Pipeline_Handle := null;
      Device   : in Device_Handle := null;
      Owns     : in Boolean := True)
   is
   begin
      Self.Internal := Internal;
      Self.Device := Device;
      Self.Owns := Owns;
   end Reset;

   procedure Reset
     (Self     : in out Compute_Pipeline;
      Internal : in Compute_Pipeline_Handle := null;
      Device   : in Device_Handle := null;
      Owns     : in Boolean := True)
   is
   begin
      Self.Internal := Internal;
      Self.Device := Device;
      Self.Owns := Owns;
   end Reset;

   function Default_Shader_Formats return Shader_Formats is
   begin
      case SDL.Platform.Get is
         when SDL.Platform.Windows =>
            return DXIL_Shader_Format or DXBC_Shader_Format;
         when SDL.Platform.Mac_OS_X | SDL.Platform.iOS =>
            return MSL_Shader_Format or Metallib_Shader_Format;
         when SDL.Platform.Linux | SDL.Platform.BSD | SDL.Platform.Android =>
            return SPIRV_Shader_Format;
         when others =>
            return Invalid_Shader_Format;
      end case;
   end Default_Shader_Formats;

   function Supports_Shader_Formats
     (Formats : in Shader_Formats;
      Name    : in String := "") return Boolean
   is
      C_Name  : CS.chars_ptr := CS.Null_Ptr;
      Success : Boolean;
   begin
      if Name /= "" then
         C_Name := CS.New_String (Name);
      end if;

      begin
         Success := To_Bool (Raw.Supports_Shader_Formats (Formats, C_Name));
      exception
         when others =>
            if C_Name /= CS.Null_Ptr then
               CS.Free (C_Name);
            end if;

            raise;
      end;

      if C_Name /= CS.Null_Ptr then
         CS.Free (C_Name);
      end if;

      return Success;
   end Supports_Shader_Formats;

   function Supports_Properties
     (Properties : in SDL.Properties.Property_Set) return Boolean is
     (To_Bool (Raw.Supports_Properties (Properties.Get_ID)));

   function Total_Drivers return Natural is
      Count : constant C.int := Raw.Get_Num_Drivers;
   begin
      if Count <= 0 then
         return 0;
      end if;

      return Natural (Count);
   end Total_Drivers;

   function Driver_Name (Index : in Driver_Indices) return String is
      Result : CS.chars_ptr;
   begin
      if Index < 0 then
         return "";
      end if;

      Result := Raw.Get_Driver (C.int (Index));

      if Result = CS.Null_Ptr then
         return "";
      end if;

      return CS.Value (Result);
   end Driver_Name;

   function Create
     (Formats    : in Shader_Formats;
      Debug_Mode : in Boolean := False;
      Name       : in String := "") return Device
   is
   begin
      return Result : Device do
         Create (Result, Formats, Debug_Mode, Name);
      end return;
   end Create;

   procedure Create
     (Self       : in out Device;
      Formats    : in Shader_Formats;
      Debug_Mode : in Boolean := False;
      Name       : in String := "")
   is
      C_Name  : CS.chars_ptr := CS.Null_Ptr;
      Created : Device_Handle;
   begin
      Destroy (Self);

      if Name /= "" then
         C_Name := CS.New_String (Name);
      end if;

      begin
         Created :=
           Raw.Create_Device
             (Format_Flags => Formats,
              Debug_Mode   => To_C_Bool (Debug_Mode),
              Name         => C_Name);
      exception
         when others =>
            if C_Name /= CS.Null_Ptr then
               CS.Free (C_Name);
            end if;

            raise;
      end;

      if C_Name /= CS.Null_Ptr then
         CS.Free (C_Name);
      end if;

      if Created = null then
         Raise_GPU_Error ("SDL_CreateGPUDevice failed");
      end if;

      Self.Internal := Created;
      Self.Owns := True;
   end Create;

   function Create_With_Properties
     (Properties : in SDL.Properties.Property_Set) return Device
   is
   begin
      return Result : Device do
         Create_With_Properties (Result, Properties);
      end return;
   end Create_With_Properties;

   procedure Create_With_Properties
     (Self       : in out Device;
      Properties : in SDL.Properties.Property_Set)
   is
      Created : constant Device_Handle :=
        Raw.Create_Device_With_Properties (Properties.Get_ID);
   begin
      Destroy (Self);

      if Created = null then
         Raise_GPU_Error ("SDL_CreateGPUDeviceWithProperties failed");
      end if;

      Self.Internal := Created;
      Self.Owns := True;
   end Create_With_Properties;

   procedure Destroy (Self : in out Device) is
   begin
      if Self.Owns and then Self.Internal /= null then
         Raw.Destroy_Device (Self.Internal);
      end if;

      Self.Internal := null;
      Self.Owns := True;
   end Destroy;

   overriding
   procedure Finalize (Self : in out Device) is
   begin
      Destroy (Self);
   end Finalize;

   function Is_Null (Self : in Device) return Boolean is
     (Self.Internal = null);

   function Get_Handle (Self : in Device) return Device_Handle is
     (Self.Internal);

   function Driver_Name (Self : in Device) return String is
      Result : CS.chars_ptr;
   begin
      Require_Device (Self);
      Result := Raw.Get_Device_Driver (Self.Internal);

      if Result = CS.Null_Ptr then
         return "";
      end if;

      return CS.Value (Result);
   end Driver_Name;

   function Supported_Shader_Formats
     (Self : in Device) return Shader_Formats
   is
   begin
      Require_Device (Self);
      return Raw.Get_Shader_Formats (Self.Internal);
   end Supported_Shader_Formats;

   function Get_Properties
     (Self : in Device) return SDL.Properties.Property_ID
   is
   begin
      Require_Device (Self);
      return Raw.Get_Device_Properties (Self.Internal);
   end Get_Properties;

   function Texture_Format_Texel_Block_Size
     (Format : in Texture_Formats) return Interfaces.Unsigned_32 is
     (Raw.Texture_Format_Texel_Block_Size (Format));

   function Texture_Supports_Format
     (Self   : in Device;
      Format : in Texture_Formats;
      Kind   : in Texture_Types;
      Usage  : in Texture_Usage_Flags) return Boolean
   is
   begin
      Require_Device (Self);

      return
        To_Bool
          (Raw.Texture_Supports_Format
             (Self.Internal, Format, To_Raw (Kind), Usage));
   end Texture_Supports_Format;

   function Texture_Supports_Sample_Count
     (Self         : in Device;
      Format       : in Texture_Formats;
      Sample_Count : in Sample_Counts) return Boolean
   is
   begin
      Require_Device (Self);

      return
        To_Bool
          (Raw.Texture_Supports_Sample_Count
             (Self.Internal, Format, To_Raw (Sample_Count)));
   end Texture_Supports_Sample_Count;

   function Calculate_Texture_Format_Size
     (Format               : in Texture_Formats;
      Width                : in Interfaces.Unsigned_32;
      Height               : in Interfaces.Unsigned_32;
      Depth_Or_Layer_Count : in Interfaces.Unsigned_32)
      return Interfaces.Unsigned_32 is
     (Raw.Calculate_Texture_Format_Size
        (Format, Width, Height, Depth_Or_Layer_Count));

   function Pixel_Format_From_Texture_Format
     (Format : in Texture_Formats)
      return SDL.Video.Pixel_Formats.Pixel_Format_Names is
     (SDL.Video.Pixel_Formats.Pixel_Format_Names
        (Raw.Get_Pixel_Format_From_Texture_Format (Format)));

   function Texture_Format_From_Pixel_Format
     (Format : in SDL.Video.Pixel_Formats.Pixel_Format_Names)
      return Texture_Formats is
     (Raw.Get_Texture_Format_From_Pixel_Format
        (SDL.Raw.Pixels.Pixel_Format_Name (Format)));

   function Create_Buffer
     (Device     : in SDL.GPU.Device;
      Usage      : in Buffer_Usage_Flags;
      Size       : in Interfaces.Unsigned_32;
      Properties : in SDL.Properties.Property_ID :=
        SDL.Properties.Null_Property_ID) return Buffer
   is
   begin
      return Result : Buffer do
         Create_Buffer (Result, Device, Usage, Size, Properties);
      end return;
   end Create_Buffer;

   procedure Create_Buffer
     (Self       : in out Buffer;
      Device     : in SDL.GPU.Device;
      Usage      : in Buffer_Usage_Flags;
      Size       : in Interfaces.Unsigned_32;
      Properties : in SDL.Properties.Property_ID :=
        SDL.Properties.Null_Property_ID)
   is
      Info : aliased constant Raw.Buffer_Create_Info :=
        (Usage => Usage,
         Size  => Size,
         Props => Properties);
      Created : Buffer_Handle;
   begin
      Require_Device (Device);
      Destroy (Self);

      Created := Raw.Create_Buffer (Device.Internal, Info'Access);

      if Created = null then
         Raise_GPU_Error ("SDL_CreateGPUBuffer failed");
      end if;

      Reset (Self, Internal => Created, Device => Device.Internal, Owns => True);
   end Create_Buffer;

   procedure Destroy (Self : in out Buffer) is
   begin
      if Self.Owns and then Self.Device /= null and then Self.Internal /= null then
         Raw.Release_Buffer (Self.Device, Self.Internal);
      end if;

      Reset (Self);
   end Destroy;

   function Is_Null (Self : in Buffer) return Boolean is
     (Self.Internal = null);

   function Get_Handle (Self : in Buffer) return Buffer_Handle is
     (Self.Internal);

   procedure Set_Name
     (Self : in Buffer;
      Name : in String)
   is
      C_Name : CS.chars_ptr := CS.New_String (Name);
   begin
      Require_Buffer (Self);

      if Self.Device = null then
         CS.Free (C_Name);
         raise GPU_Error with "GPU buffer is not associated with a GPU device";
      end if;

      begin
         Raw.Set_Buffer_Name (Self.Device, Self.Internal, C_Name);
      exception
         when others =>
            CS.Free (C_Name);
            raise;
      end;

      CS.Free (C_Name);
   end Set_Name;

   function Create_Transfer_Buffer
     (Device     : in SDL.GPU.Device;
      Usage      : in Transfer_Buffer_Usages;
      Size       : in Interfaces.Unsigned_32;
      Properties : in SDL.Properties.Property_ID :=
        SDL.Properties.Null_Property_ID) return Transfer_Buffer
   is
   begin
      return Result : Transfer_Buffer do
         Create_Transfer_Buffer (Result, Device, Usage, Size, Properties);
      end return;
   end Create_Transfer_Buffer;

   procedure Create_Transfer_Buffer
     (Self       : in out Transfer_Buffer;
      Device     : in SDL.GPU.Device;
      Usage      : in Transfer_Buffer_Usages;
      Size       : in Interfaces.Unsigned_32;
      Properties : in SDL.Properties.Property_ID :=
        SDL.Properties.Null_Property_ID)
   is
      Info : aliased constant Raw.Transfer_Buffer_Create_Info :=
        (Usage => To_Raw (Usage),
         Size  => Size,
         Props => Properties);
      Created : Transfer_Buffer_Handle;
   begin
      Require_Device (Device);
      Destroy (Self);

      Created := Raw.Create_Transfer_Buffer (Device.Internal, Info'Access);

      if Created = null then
         Raise_GPU_Error ("SDL_CreateGPUTransferBuffer failed");
      end if;

      Reset
        (Self,
         Internal => Created,
         Device   => Device.Internal,
         Owns     => True,
         Mapped   => False);
   end Create_Transfer_Buffer;

   procedure Destroy (Self : in out Transfer_Buffer) is
   begin
      if Self.Device /= null and then Self.Internal /= null and then Self.Mapped then
         Raw.Unmap_Transfer_Buffer (Self.Device, Self.Internal);
      end if;

      if Self.Owns and then Self.Device /= null and then Self.Internal /= null then
         Raw.Release_Transfer_Buffer (Self.Device, Self.Internal);
      end if;

      Reset (Self);
   end Destroy;

   function Is_Null (Self : in Transfer_Buffer) return Boolean is
     (Self.Internal = null);

   function Map
     (Self  : in out Transfer_Buffer;
      Cycle : in Boolean := False) return System.Address
   is
      Result : System.Address;
   begin
      Require_Transfer_Buffer (Self);

      if Self.Device = null then
         raise GPU_Error with "Transfer buffer is not associated with a GPU device";
      end if;

      if Self.Mapped then
         raise GPU_Error with "GPU transfer buffer already mapped";
      end if;

      Result :=
        Raw.Map_Transfer_Buffer (Self.Device, Self.Internal, To_C_Bool (Cycle));

      if Result = System.Null_Address then
         Raise_GPU_Error ("SDL_MapGPUTransferBuffer failed");
      end if;

      Self.Mapped := True;
      return Result;
   end Map;

   procedure Unmap (Self : in out Transfer_Buffer) is
   begin
      if Self.Device = null or else Self.Internal = null or else not Self.Mapped then
         return;
      end if;

      Raw.Unmap_Transfer_Buffer (Self.Device, Self.Internal);
      Self.Mapped := False;
   end Unmap;

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
        SDL.Properties.Null_Property_ID) return Texture
   is
   begin
      return Result : Texture do
         Create_Texture
           (Result,
            Device,
            Format,
            Usage,
            Width,
            Height,
            Kind,
            Layer_Count_Or_Depth,
            Num_Levels,
            Sample_Count,
            Properties);
      end return;
   end Create_Texture;

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
        SDL.Properties.Null_Property_ID)
   is
      Info : aliased constant Raw.Texture_Create_Info :=
        (Kind                 => To_Raw (Kind),
         Format               => Format,
         Usage                => Usage,
         Width                => Width,
         Height               => Height,
         Layer_Count_Or_Depth => Layer_Count_Or_Depth,
         Num_Levels           => Num_Levels,
         Sample_Count         => To_Raw (Sample_Count),
         Props                => Properties);
      Created : Texture_Handle;
   begin
      Require_Device (Device);
      Destroy (Self);

      Created := Raw.Create_Texture (Device.Internal, Info'Access);

      if Created = null then
         Raise_GPU_Error ("SDL_CreateGPUTexture failed");
      end if;

      Reset (Self, Internal => Created, Device => Device.Internal, Owns => True);
   end Create_Texture;

   procedure Destroy (Self : in out Texture) is
   begin
      if Self.Owns and then Self.Device /= null and then Self.Internal /= null then
         Raw.Release_Texture (Self.Device, Self.Internal);
      end if;

      Reset (Self);
   end Destroy;

   function Is_Null (Self : in Texture) return Boolean is
     (Self.Internal = null);

   function Get_Handle (Self : in Texture) return Texture_Handle is
     (Self.Internal);

   procedure Set_Name
     (Self : in Texture;
      Name : in String)
   is
      C_Name : CS.chars_ptr := CS.New_String (Name);
   begin
      Require_Texture (Self);

      if Self.Device = null then
         CS.Free (C_Name);
         raise GPU_Error with "GPU texture is not associated with a GPU device";
      end if;

      begin
         Raw.Set_Texture_Name (Self.Device, Self.Internal, C_Name);
      exception
         when others =>
            CS.Free (C_Name);
            raise;
      end;

      CS.Free (C_Name);
   end Set_Name;

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
        SDL.Properties.Null_Property_ID) return Sampler
   is
   begin
      return Result : Sampler do
         Create_Sampler
           (Result,
            Device,
            Min_Filter,
            Mag_Filter,
            Mipmap_Mode,
            Address_Mode_U,
            Address_Mode_V,
            Address_Mode_W,
            Mip_LOD_Bias,
            Max_Anisotropy,
            Compare_Operation,
            Min_LOD,
            Max_LOD,
            Enable_Anisotropy,
            Enable_Compare,
            Properties);
      end return;
   end Create_Sampler;

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
        SDL.Properties.Null_Property_ID)
   is
      Info : aliased constant Raw.Sampler_Create_Info :=
        (Min_Filter        => To_Raw (Min_Filter),
         Mag_Filter        => To_Raw (Mag_Filter),
         Mipmap_Mode       => To_Raw (Mipmap_Mode),
         Address_Mode_U    => To_Raw (Address_Mode_U),
         Address_Mode_V    => To_Raw (Address_Mode_V),
         Address_Mode_W    => To_Raw (Address_Mode_W),
         Mip_LOD_Bias      => Mip_LOD_Bias,
         Max_Anisotropy    => Max_Anisotropy,
         Compare_Op        => To_Raw (Compare_Operation),
         Min_LOD           => Min_LOD,
         Max_LOD           => Max_LOD,
         Enable_Anisotropy => To_C_Bool (Enable_Anisotropy),
         Enable_Compare    => To_C_Bool (Enable_Compare),
         Padding_1         => 0,
         Padding_2         => 0,
         Props             => Properties);
      Created : Sampler_Handle;
   begin
      Require_Device (Device);
      Destroy (Self);

      Created := Raw.Create_Sampler (Device.Internal, Info'Access);

      if Created = null then
         Raise_GPU_Error ("SDL_CreateGPUSampler failed");
      end if;

      Reset (Self, Internal => Created, Device => Device.Internal, Owns => True);
   end Create_Sampler;

   procedure Destroy (Self : in out Sampler) is
   begin
      if Self.Owns and then Self.Device /= null and then Self.Internal /= null then
         Raw.Release_Sampler (Self.Device, Self.Internal);
      end if;

      Reset (Self);
   end Destroy;

   function Is_Null (Self : in Sampler) return Boolean is
     (Self.Internal = null);

   function Get_Handle (Self : in Sampler) return Sampler_Handle is
     (Self.Internal);

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
        SDL.Properties.Null_Property_ID) return Shader
   is
   begin
      return Result : Shader do
         Create_Shader
           (Result,
            Device,
            Code,
            Entrypoint,
            Format,
            Stage,
            Num_Samplers,
            Num_Storage_Textures,
            Num_Storage_Buffers,
            Num_Uniform_Buffers,
            Properties);
      end return;
   end Create_Shader;

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
        SDL.Properties.Null_Property_ID)
   is
      C_Entrypoint : CS.chars_ptr := CS.New_String (Entrypoint);
      Info         : aliased Raw.Shader_Create_Info :=
        (Code_Size            => C.size_t (Code'Length),
         Code                 => Bytes_Address (Code),
         Entry_Point          => C_Entrypoint,
         Format               => Format,
         Stage                => To_Raw (Stage),
         Num_Samplers         => Num_Samplers,
         Num_Storage_Textures => Num_Storage_Textures,
         Num_Storage_Buffers  => Num_Storage_Buffers,
         Num_Uniform_Buffers  => Num_Uniform_Buffers,
         Props                => Properties);
      Created      : Shader_Handle;
   begin
      Require_Device (Device);
      Destroy (Self);

      begin
         Created := Raw.Create_Shader (Device.Internal, Info'Access);
      exception
         when others =>
            CS.Free (C_Entrypoint);
            raise;
      end;

      CS.Free (C_Entrypoint);

      if Created = null then
         Raise_GPU_Error ("SDL_CreateGPUShader failed");
      end if;

      Reset (Self, Internal => Created, Device => Device.Internal, Owns => True);
   end Create_Shader;

   procedure Destroy (Self : in out Shader) is
   begin
      if Self.Owns and then Self.Device /= null and then Self.Internal /= null then
         Raw.Release_Shader (Self.Device, Self.Internal);
      end if;

      Reset (Self);
   end Destroy;

   function Is_Null (Self : in Shader) return Boolean is
     (Self.Internal = null);

   function Get_Handle (Self : in Shader) return Shader_Handle is
     (Self.Internal);

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
        SDL.Properties.Null_Property_ID) return Graphics_Pipeline
   is
   begin
      return Result : Graphics_Pipeline do
         Create_Graphics_Pipeline
           (Result,
            Device,
            Vertex,
            Fragment,
            Vertex_Buffers,
            Vertex_Attributes,
            Primitive,
            Color_Targets,
            Rasterizer,
            Multisample,
            Depth_Stencil,
            Depth_Stencil_Format,
            Has_Depth_Stencil_Target,
            Properties);
      end return;
   end Create_Graphics_Pipeline;

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
        SDL.Properties.Null_Property_ID)
   is
      Raw_Vertex_Buffers    :
        aliased Raw_Vertex_Buffer_Description_Arrays
          (0 .. Array_Last (Vertex_Buffers'Length));
      Raw_Vertex_Attributes :
        aliased Raw_Vertex_Attribute_Arrays
          (0 .. Array_Last (Vertex_Attributes'Length));
      Raw_Colour_Targets    :
        aliased Raw_Colour_Target_Description_Arrays
          (0 .. Array_Last (Color_Targets'Length));
      Info                  : aliased Raw.Graphics_Pipeline_Create_Info;
      Created               : Graphics_Pipeline_Handle;
   begin
      Require_Device (Device);
      Require_Shader (Vertex);
      Require_Shader (Fragment);
      Destroy (Self);

      for Index in Vertex_Buffers'Range loop
         Raw_Vertex_Buffers (C.size_t (Index - Vertex_Buffers'First)) :=
           To_Raw (Vertex_Buffers (Index));
      end loop;

      for Index in Vertex_Attributes'Range loop
         Raw_Vertex_Attributes (C.size_t (Index - Vertex_Attributes'First)) :=
           To_Raw (Vertex_Attributes (Index));
      end loop;

      for Index in Color_Targets'Range loop
         Raw_Colour_Targets (C.size_t (Index - Color_Targets'First)) :=
           To_Raw (Color_Targets (Index));
      end loop;

      Info :=
        (Vertex_Shader      => Vertex.Internal,
         Fragment_Shader    => Fragment.Internal,
         Vertex_Input_State =>
           (Vertex_Buffer_Descriptions =>
              (if Vertex_Buffers'Length = 0 then System.Null_Address
               else Raw_Vertex_Buffers'Address),
            Num_Vertex_Buffers         =>
              Interfaces.Unsigned_32 (Vertex_Buffers'Length),
            Vertex_Attributes          =>
              (if Vertex_Attributes'Length = 0 then System.Null_Address
               else Raw_Vertex_Attributes'Address),
            Num_Vertex_Attributes      =>
              Interfaces.Unsigned_32 (Vertex_Attributes'Length)),
         Primitive_Type     => To_Raw (Primitive),
         Rasterizer_State   => To_Raw (Rasterizer),
         Multisample_State  => To_Raw (Multisample),
         Depth_Stencil_State => To_Raw (Depth_Stencil),
         Target_Info        =>
           (Color_Target_Descriptions =>
              (if Color_Targets'Length = 0 then System.Null_Address
               else Raw_Colour_Targets'Address),
            Num_Color_Targets         => Interfaces.Unsigned_32 (Color_Targets'Length),
            Depth_Stencil_Format      => Depth_Stencil_Format,
            Has_Depth_Stencil_Target  => To_C_Bool (Has_Depth_Stencil_Target),
            Padding_1                 => 0,
            Padding_2                 => 0,
            Padding_3                 => 0),
         Props              => Properties);

      Created := Raw.Create_Graphics_Pipeline (Device.Internal, Info'Access);

      if Created = null then
         Raise_GPU_Error ("SDL_CreateGPUGraphicsPipeline failed");
      end if;

      Reset (Self, Internal => Created, Device => Device.Internal, Owns => True);
   end Create_Graphics_Pipeline;

   procedure Destroy (Self : in out Graphics_Pipeline) is
   begin
      if Self.Owns and then Self.Device /= null and then Self.Internal /= null then
         Raw.Release_Graphics_Pipeline (Self.Device, Self.Internal);
      end if;

      Reset (Self);
   end Destroy;

   function Is_Null (Self : in Graphics_Pipeline) return Boolean is
     (Self.Internal = null);

   function Get_Handle
     (Self : in Graphics_Pipeline) return Graphics_Pipeline_Handle is
     (Self.Internal);

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
        SDL.Properties.Null_Property_ID) return Compute_Pipeline
   is
   begin
      return Result : Compute_Pipeline do
         Create_Compute_Pipeline
           (Result,
            Device,
            Code,
            Entrypoint,
            Format,
            Num_Samplers,
            Num_Readonly_Storage_Textures,
            Num_Readonly_Storage_Buffers,
            Num_Readwrite_Storage_Textures,
            Num_Readwrite_Storage_Buffers,
            Num_Uniform_Buffers,
            Threadcount_X,
            Threadcount_Y,
            Threadcount_Z,
            Properties);
      end return;
   end Create_Compute_Pipeline;

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
        SDL.Properties.Null_Property_ID)
   is
      C_Entrypoint : CS.chars_ptr := CS.New_String (Entrypoint);
      Info         : aliased Raw.Compute_Pipeline_Create_Info :=
        (Code_Size                      => C.size_t (Code'Length),
         Code                           => Bytes_Address (Code),
         Entry_Point                    => C_Entrypoint,
         Format                         => Format,
         Num_Samplers                   => Num_Samplers,
         Num_Readonly_Storage_Textures  => Num_Readonly_Storage_Textures,
         Num_Readonly_Storage_Buffers   => Num_Readonly_Storage_Buffers,
         Num_Readwrite_Storage_Textures => Num_Readwrite_Storage_Textures,
         Num_Readwrite_Storage_Buffers  => Num_Readwrite_Storage_Buffers,
         Num_Uniform_Buffers            => Num_Uniform_Buffers,
         Threadcount_X                  => Threadcount_X,
         Threadcount_Y                  => Threadcount_Y,
         Threadcount_Z                  => Threadcount_Z,
         Props                          => Properties);
      Created      : Compute_Pipeline_Handle;
   begin
      Require_Device (Device);
      Destroy (Self);

      begin
         Created := Raw.Create_Compute_Pipeline (Device.Internal, Info'Access);
      exception
         when others =>
            CS.Free (C_Entrypoint);
            raise;
      end;

      CS.Free (C_Entrypoint);

      if Created = null then
         Raise_GPU_Error ("SDL_CreateGPUComputePipeline failed");
      end if;

      Reset (Self, Internal => Created, Device => Device.Internal, Owns => True);
   end Create_Compute_Pipeline;

   procedure Destroy (Self : in out Compute_Pipeline) is
   begin
      if Self.Owns and then Self.Device /= null and then Self.Internal /= null then
         Raw.Release_Compute_Pipeline (Self.Device, Self.Internal);
      end if;

      Reset (Self);
   end Destroy;

   function Is_Null (Self : in Compute_Pipeline) return Boolean is
     (Self.Internal = null);

   function Get_Handle
     (Self : in Compute_Pipeline) return Compute_Pipeline_Handle is
     (Self.Internal);

   function Make_Texture_Transfer_Info
     (Buffer         : in Transfer_Buffer;
      Offset         : in Interfaces.Unsigned_32 := 0;
      Pixels_Per_Row : in Interfaces.Unsigned_32 := 0;
      Rows_Per_Layer : in Interfaces.Unsigned_32 := 0)
      return Texture_Transfer_Info
   is
   begin
      Require_Transfer_Buffer (Buffer);

      return
        (Internal =>
           (Transfer_Buffer => Buffer.Internal,
            Offset          => Offset,
            Pixels_Per_Row  => Pixels_Per_Row,
            Rows_Per_Layer  => Rows_Per_Layer));
   end Make_Texture_Transfer_Info;

   function Make_Transfer_Buffer_Location
     (Buffer : in Transfer_Buffer;
      Offset : in Interfaces.Unsigned_32 := 0)
      return Transfer_Buffer_Location
   is
   begin
      Require_Transfer_Buffer (Buffer);
      return (Internal => (Transfer_Buffer => Buffer.Internal, Offset => Offset));
   end Make_Transfer_Buffer_Location;

   function Make_Texture_Location
     (Target    : in Texture;
      Mip_Level : in Interfaces.Unsigned_32 := 0;
      Layer     : in Interfaces.Unsigned_32 := 0;
      X         : in Interfaces.Unsigned_32 := 0;
      Y         : in Interfaces.Unsigned_32 := 0;
      Z         : in Interfaces.Unsigned_32 := 0)
      return Texture_Location
   is
   begin
      Require_Texture (Target);

      return
        (Internal =>
           (Texture   => Target.Internal,
            Mip_Level => Mip_Level,
            Layer     => Layer,
            X         => X,
            Y         => Y,
            Z         => Z));
   end Make_Texture_Location;

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
      return Texture_Region
   is
   begin
      Require_Texture (Target);

      return
        (Internal =>
           (Texture   => Target.Internal,
            Mip_Level => Mip_Level,
            Layer     => Layer,
            X         => X,
            Y         => Y,
            Z         => Z,
            Width     => Width,
            Height    => Height,
            Depth     => Depth));
   end Make_Texture_Region;

   function Make_Buffer_Location
     (Target : in Buffer;
      Offset : in Interfaces.Unsigned_32 := 0) return Buffer_Location
   is
   begin
      Require_Buffer (Target);
      return (Internal => (Buffer => Target.Internal, Offset => Offset));
   end Make_Buffer_Location;

   function Make_Buffer_Region
     (Target : in Buffer;
      Size   : in Interfaces.Unsigned_32;
      Offset : in Interfaces.Unsigned_32 := 0) return Buffer_Region
   is
   begin
      Require_Buffer (Target);
      return (Internal => (Buffer => Target.Internal, Offset => Offset, Size => Size));
   end Make_Buffer_Region;

   function Make_Buffer_Binding
     (Target : in Buffer;
      Offset : in Interfaces.Unsigned_32 := 0) return Buffer_Binding
   is
   begin
      Require_Buffer (Target);
      return (Internal => (Buffer => Target.Internal, Offset => Offset));
   end Make_Buffer_Binding;

   function Make_Texture_Sampler_Binding
     (Target  : in Texture;
      Sampler : in SDL.GPU.Sampler) return Texture_Sampler_Binding
   is
   begin
      Require_Texture (Target);
      Require_Sampler (Sampler);

      return
        (Internal =>
           (Texture => Target.Internal, Sampler => Sampler.Internal));
   end Make_Texture_Sampler_Binding;

   function Make_Storage_Buffer_Read_Write_Binding
     (Target : in Buffer;
      Cycle  : in Boolean := False)
      return Storage_Buffer_Read_Write_Binding
   is
   begin
      Require_Buffer (Target);

      return
        (Internal =>
           (Buffer    => Target.Internal,
            Cycle     => To_C_Bool (Cycle),
            Padding_1 => 0,
            Padding_2 => 0,
            Padding_3 => 0));
   end Make_Storage_Buffer_Read_Write_Binding;

   function Make_Storage_Texture_Read_Write_Binding
     (Target    : in Texture;
      Mip_Level : in Interfaces.Unsigned_32 := 0;
      Layer     : in Interfaces.Unsigned_32 := 0;
      Cycle     : in Boolean := False)
      return Storage_Texture_Read_Write_Binding
   is
   begin
      Require_Texture (Target);

      return
        (Internal =>
           (Texture   => Target.Internal,
            Mip_Level => Mip_Level,
            Layer     => Layer,
            Cycle     => To_C_Bool (Cycle),
            Padding_1 => 0,
            Padding_2 => 0,
            Padding_3 => 0));
   end Make_Storage_Texture_Read_Write_Binding;

   function Make_Blit_Region
     (Target               : in Texture;
      Width                : in Interfaces.Unsigned_32;
      Height               : in Interfaces.Unsigned_32;
      Mip_Level            : in Interfaces.Unsigned_32 := 0;
      Layer_Or_Depth_Plane : in Interfaces.Unsigned_32 := 0;
      X                    : in Interfaces.Unsigned_32 := 0;
      Y                    : in Interfaces.Unsigned_32 := 0) return Blit_Region
   is
   begin
      Require_Texture (Target);

      return
        (Internal =>
           (Texture              => Target.Internal,
            Mip_Level            => Mip_Level,
            Layer_Or_Depth_Plane => Layer_Or_Depth_Plane,
            X                    => X,
            Y                    => Y,
            Width                => Width,
            Height               => Height));
   end Make_Blit_Region;

   function Make_Blit_Info
     (Source       : in Blit_Region;
      Destination  : in Blit_Region;
      Load_Op      : in Load_Operations := Load;
      Clear_To     : in Float_Colour :=
        (Red => 0.0, Green => 0.0, Blue => 0.0, Alpha => 1.0);
      Flip         : in Flip_Modes := No_Flip;
      Filter       : in Filters := Linear;
      Cycle        : in Boolean := False) return Blit_Info
   is
   begin
      return
        (Internal =>
           (Source       => Source.Internal,
            Destination  => Destination.Internal,
            Load_Op      => To_Raw (Load_Op),
            Clear_Colour => Clear_To,
            Flip_Mode    => To_Raw (Flip),
            Filter       => To_Raw (Filter),
            Cycle        => To_C_Bool (Cycle),
            Padding_1    => 0,
            Padding_2    => 0,
            Padding_3    => 0));
   end Make_Blit_Info;

   procedure Claim_Window
     (Self   : in Device;
      Window : in SDL.Video.Windows.Window)
   is
   begin
      Require_Device (Self);

      if not To_Bool (Raw.Claim_Window (Self.Internal, Window_Address (Window))) then
         Raise_GPU_Error ("SDL_ClaimWindowForGPUDevice failed");
      end if;
   end Claim_Window;

   procedure Release_Window
     (Self   : in Device;
      Window : in SDL.Video.Windows.Window)
   is
      Internal_Window : constant System.Address := SDL.Video.Windows.Get_Internal (Window);
   begin
      if Self.Internal = null or else Internal_Window = System.Null_Address then
         return;
      end if;

      Raw.Release_Window (Self.Internal, Internal_Window);
   end Release_Window;

   function Supports_Composition
     (Self        : in Device;
      Window      : in SDL.Video.Windows.Window;
      Composition : in Swapchain_Compositions) return Boolean
   is
   begin
      Require_Device (Self);

      return
        To_Bool
          (Raw.Window_Supports_Swapchain_Composition
             (Self.Internal, Window_Address (Window), To_Raw (Composition)));
   end Supports_Composition;

   function Supports_Present_Mode
     (Self         : in Device;
      Window       : in SDL.Video.Windows.Window;
      Present_Mode : in Present_Modes) return Boolean
   is
   begin
      Require_Device (Self);

      return
        To_Bool
          (Raw.Window_Supports_Present_Mode
             (Self.Internal, Window_Address (Window), To_Raw (Present_Mode)));
   end Supports_Present_Mode;

   procedure Set_Swapchain_Parameters
     (Self         : in Device;
      Window       : in SDL.Video.Windows.Window;
      Composition  : in Swapchain_Compositions := Swapchain_SDR;
      Present_Mode : in Present_Modes := V_Sync)
   is
   begin
      Require_Device (Self);

      if not To_Bool
          (Raw.Set_Swapchain_Parameters
             (Self.Internal,
              Window_Address (Window),
              To_Raw (Composition),
              To_Raw (Present_Mode)))
      then
         Raise_GPU_Error ("SDL_SetGPUSwapchainParameters failed");
      end if;
   end Set_Swapchain_Parameters;

   procedure Set_Allowed_Frames_In_Flight
     (Self                     : in Device;
      Allowed_Frames_In_Flight : in Interfaces.Unsigned_32)
   is
   begin
      Require_Device (Self);

      if not To_Bool
          (Raw.Set_Allowed_Frames_In_Flight
             (Self.Internal, Allowed_Frames_In_Flight))
      then
         Raise_GPU_Error ("SDL_SetGPUAllowedFramesInFlight failed");
      end if;
   end Set_Allowed_Frames_In_Flight;

   function Get_Swapchain_Texture_Format
     (Self   : in Device;
      Window : in SDL.Video.Windows.Window) return Texture_Formats
   is
   begin
      Require_Device (Self);
      return Raw.Get_Swapchain_Texture_Format (Self.Internal, Window_Address (Window));
   end Get_Swapchain_Texture_Format;

   procedure GDK_Suspend (Self : in Device) is
   begin
      Require_Device (Self);
      Raw.GDK_Suspend_GPU (Self.Internal);
   end GDK_Suspend;

   procedure GDK_Resume (Self : in Device) is
   begin
      Require_Device (Self);
      Raw.GDK_Resume_GPU (Self.Internal);
   end GDK_Resume;

   function Acquire_Command_Buffer
     (Self : in Device) return Command_Buffer
   is
      Internal : Command_Buffer_Handle;
   begin
      Require_Device (Self);
      Internal := Raw.Acquire_Command_Buffer (Self.Internal);

      if Internal = null then
         Raise_GPU_Error ("SDL_AcquireGPUCommandBuffer failed");
      end if;

      return (Internal => Internal);
   end Acquire_Command_Buffer;

   function Is_Null (Self : in Command_Buffer) return Boolean is
     (Self.Internal = null);

   procedure Push_Vertex_Uniform_Data
     (Self       : in Command_Buffer;
      Slot_Index : in Interfaces.Unsigned_32;
      Data       : in Ada.Streams.Stream_Element_Array)
   is
   begin
      Require_Command_Buffer (Self);
      Raw.Push_Vertex_Uniform_Data
        (Self.Internal,
         Slot_Index,
         Bytes_Address (Data),
         Interfaces.Unsigned_32 (Data'Length));
   end Push_Vertex_Uniform_Data;

   procedure Push_Fragment_Uniform_Data
     (Self       : in Command_Buffer;
      Slot_Index : in Interfaces.Unsigned_32;
      Data       : in Ada.Streams.Stream_Element_Array)
   is
   begin
      Require_Command_Buffer (Self);
      Raw.Push_Fragment_Uniform_Data
        (Self.Internal,
         Slot_Index,
         Bytes_Address (Data),
         Interfaces.Unsigned_32 (Data'Length));
   end Push_Fragment_Uniform_Data;

   procedure Push_Compute_Uniform_Data
     (Self       : in Command_Buffer;
      Slot_Index : in Interfaces.Unsigned_32;
      Data       : in Ada.Streams.Stream_Element_Array)
   is
   begin
      Require_Command_Buffer (Self);
      Raw.Push_Compute_Uniform_Data
        (Self.Internal,
         Slot_Index,
         Bytes_Address (Data),
         Interfaces.Unsigned_32 (Data'Length));
   end Push_Compute_Uniform_Data;

   procedure Insert_Debug_Label
     (Self : in Command_Buffer;
      Text : in String)
   is
      C_Text : CS.chars_ptr := CS.New_String (Text);
   begin
      Require_Command_Buffer (Self);

      begin
         Raw.Insert_Debug_Label (Self.Internal, C_Text);
      exception
         when others =>
            CS.Free (C_Text);
            raise;
      end;

      CS.Free (C_Text);
   end Insert_Debug_Label;

   procedure Push_Debug_Group
     (Self : in Command_Buffer;
      Name : in String)
   is
      C_Name : CS.chars_ptr := CS.New_String (Name);
   begin
      Require_Command_Buffer (Self);

      begin
         Raw.Push_Debug_Group (Self.Internal, C_Name);
      exception
         when others =>
            CS.Free (C_Name);
            raise;
      end;

      CS.Free (C_Name);
   end Push_Debug_Group;

   procedure Pop_Debug_Group (Self : in Command_Buffer) is
   begin
      Require_Command_Buffer (Self);
      Raw.Pop_Debug_Group (Self.Internal);
   end Pop_Debug_Group;

   function Begin_Copy_Pass
     (Self : in out Command_Buffer) return Copy_Pass
   is
      Internal : Copy_Pass_Handle;
   begin
      Require_Command_Buffer (Self);
      Internal := Raw.Begin_Copy_Pass (Self.Internal);

      if Internal = null then
         Raise_GPU_Error ("SDL_BeginGPUCopyPass failed");
      end if;

      return (Internal => Internal);
   end Begin_Copy_Pass;

   function Begin_Compute_Pass
     (Self : in out Command_Buffer) return Compute_Pass
   is
      Empty_Textures : Storage_Texture_Read_Write_Binding_Arrays (1 .. 0);
      Empty_Buffers  : Storage_Buffer_Read_Write_Binding_Arrays (1 .. 0);
   begin
      return Begin_Compute_Pass (Self, Empty_Textures, Empty_Buffers);
   end Begin_Compute_Pass;

   function Begin_Compute_Pass
     (Self             : in out Command_Buffer;
      Storage_Textures : in Storage_Texture_Read_Write_Binding_Arrays;
      Storage_Buffers  : in Storage_Buffer_Read_Write_Binding_Arrays)
      return Compute_Pass
   is
      Raw_Textures : aliased Raw_Storage_Texture_Read_Write_Binding_Arrays
        (0 .. Array_Last (Storage_Textures'Length));
      Raw_Buffers : aliased Raw_Storage_Buffer_Read_Write_Binding_Arrays
        (0 .. Array_Last (Storage_Buffers'Length));
      Internal    : Compute_Pass_Handle;
   begin
      Require_Command_Buffer (Self);

      for Index in Storage_Textures'Range loop
         Raw_Textures (C.size_t (Index - Storage_Textures'First)) :=
           Storage_Textures (Index).Internal;
      end loop;

      for Index in Storage_Buffers'Range loop
         Raw_Buffers (C.size_t (Index - Storage_Buffers'First)) :=
           Storage_Buffers (Index).Internal;
      end loop;

      Internal :=
        Raw.Begin_Compute_Pass
          (Self.Internal,
           (if Storage_Textures'Length = 0 then System.Null_Address
            else Raw_Textures'Address),
           Interfaces.Unsigned_32 (Storage_Textures'Length),
           (if Storage_Buffers'Length = 0 then System.Null_Address
            else Raw_Buffers'Address),
           Interfaces.Unsigned_32 (Storage_Buffers'Length));

      if Internal = null then
         Raise_GPU_Error ("SDL_BeginGPUComputePass failed");
      end if;

      return (Internal => Internal);
   end Begin_Compute_Pass;

   procedure End_Pass (Self : in out Copy_Pass) is
   begin
      if Self.Internal = null then
         return;
      end if;

      Raw.End_Copy_Pass (Self.Internal);
      Self.Internal := null;
   end End_Pass;

   procedure End_Pass (Self : in out Compute_Pass) is
   begin
      if Self.Internal = null then
         return;
      end if;

      Raw.End_Compute_Pass (Self.Internal);
      Self.Internal := null;
   end End_Pass;

   function Is_Null (Self : in Copy_Pass) return Boolean is
     (Self.Internal = null);

   function Is_Null (Self : in Compute_Pass) return Boolean is
     (Self.Internal = null);

   procedure Upload_To_Texture
     (Self        : in Copy_Pass;
      Source      : in Texture_Transfer_Info;
      Destination : in Texture_Region;
      Cycle       : in Boolean := False)
   is
      Raw_Source      : aliased constant Raw.Texture_Transfer_Info :=
        Source.Internal;
      Raw_Destination : aliased constant Raw.Texture_Region := Destination.Internal;
   begin
      Require_Copy_Pass (Self);
      Raw.Upload_To_Texture
        (Self.Internal,
         Raw_Source'Access,
         Raw_Destination'Access,
         To_C_Bool (Cycle));
   end Upload_To_Texture;

   procedure Upload_To_Buffer
     (Self        : in Copy_Pass;
      Source      : in Transfer_Buffer_Location;
      Destination : in Buffer_Region;
      Cycle       : in Boolean := False)
   is
      Raw_Source      : aliased constant Raw.Transfer_Buffer_Location :=
        Source.Internal;
      Raw_Destination : aliased constant Raw.Buffer_Region := Destination.Internal;
   begin
      Require_Copy_Pass (Self);
      Raw.Upload_To_Buffer
        (Self.Internal,
         Raw_Source'Access,
         Raw_Destination'Access,
         To_C_Bool (Cycle));
   end Upload_To_Buffer;

   procedure Copy_Texture_To_Texture
     (Self        : in Copy_Pass;
      Source      : in Texture_Location;
      Destination : in Texture_Location;
      Width       : in Interfaces.Unsigned_32;
      Height      : in Interfaces.Unsigned_32;
      Depth       : in Interfaces.Unsigned_32 := 1;
      Cycle       : in Boolean := False)
   is
      Raw_Source      : aliased constant Raw.Texture_Location := Source.Internal;
      Raw_Destination : aliased constant Raw.Texture_Location :=
        Destination.Internal;
   begin
      Require_Copy_Pass (Self);
      Raw.Copy_Texture_To_Texture
        (Self.Internal,
         Raw_Source'Access,
         Raw_Destination'Access,
         Width,
         Height,
         Depth,
         To_C_Bool (Cycle));
   end Copy_Texture_To_Texture;

   procedure Copy_Buffer_To_Buffer
     (Self        : in Copy_Pass;
      Source      : in Buffer_Location;
      Destination : in Buffer_Location;
      Size        : in Interfaces.Unsigned_32;
      Cycle       : in Boolean := False)
   is
      Raw_Source      : aliased constant Raw.Buffer_Location := Source.Internal;
      Raw_Destination : aliased constant Raw.Buffer_Location :=
        Destination.Internal;
   begin
      Require_Copy_Pass (Self);
      Raw.Copy_Buffer_To_Buffer
        (Self.Internal,
         Raw_Source'Access,
         Raw_Destination'Access,
         Size,
         To_C_Bool (Cycle));
   end Copy_Buffer_To_Buffer;

   procedure Download_From_Texture
     (Self        : in Copy_Pass;
      Source      : in Texture_Region;
      Destination : in Texture_Transfer_Info)
   is
      Raw_Source      : aliased constant Raw.Texture_Region := Source.Internal;
      Raw_Destination : aliased constant Raw.Texture_Transfer_Info :=
        Destination.Internal;
   begin
      Require_Copy_Pass (Self);
      Raw.Download_From_Texture
        (Self.Internal, Raw_Source'Access, Raw_Destination'Access);
   end Download_From_Texture;

   procedure Download_From_Buffer
     (Self        : in Copy_Pass;
      Source      : in Buffer_Region;
      Destination : in Transfer_Buffer_Location)
   is
      Raw_Source      : aliased constant Raw.Buffer_Region := Source.Internal;
      Raw_Destination : aliased constant Raw.Transfer_Buffer_Location :=
        Destination.Internal;
   begin
      Require_Copy_Pass (Self);
      Raw.Download_From_Buffer
        (Self.Internal, Raw_Source'Access, Raw_Destination'Access);
   end Download_From_Buffer;

   procedure Generate_Mipmaps
     (Self   : in Command_Buffer;
      Target : in Texture)
   is
   begin
      Require_Command_Buffer (Self);
      Require_Texture (Target);
      Raw.Generate_Mipmaps_For_Texture (Self.Internal, Target.Internal);
   end Generate_Mipmaps;

   procedure Blit
     (Self : in Command_Buffer;
      Info : in Blit_Info)
   is
      Raw_Info : aliased constant Raw.Blit_Info := Info.Internal;
   begin
      Require_Command_Buffer (Self);
      Raw.Blit_Texture (Self.Internal, Raw_Info'Access);
   end Blit;

   function Wait_For_Swapchain
     (Self   : in Device;
      Window : in SDL.Video.Windows.Window) return Boolean
   is
   begin
      Require_Device (Self);
      return To_Bool (Raw.Wait_For_Swapchain (Self.Internal, Window_Address (Window)));
   end Wait_For_Swapchain;

   function Acquire_Swapchain_Texture
     (Self          : in out Command_Buffer;
      Window        : in SDL.Video.Windows.Window;
      Acquired      : in out Texture;
      Width, Height : out SDL.Natural_Dimension) return Boolean
   is
      Raw_Texture : aliased Texture_Handle := null;
      Raw_Width   : aliased Interfaces.Unsigned_32 := 0;
      Raw_Height  : aliased Interfaces.Unsigned_32 := 0;
   begin
      Require_Command_Buffer (Self);

      if not To_Bool
          (Raw.Acquire_Swapchain_Texture
             (Self.Internal,
              Window_Address (Window),
              Raw_Texture'Access,
              Raw_Width'Access,
              Raw_Height'Access))
      then
         Raise_GPU_Error ("SDL_AcquireGPUSwapchainTexture failed");
      end if;

      Destroy (Acquired);
      Reset (Acquired, Internal => Raw_Texture, Owns => False);
      Width := SDL.Natural_Dimension (Raw_Width);
      Height := SDL.Natural_Dimension (Raw_Height);
      return Raw_Texture /= null;
   end Acquire_Swapchain_Texture;

   function Wait_And_Acquire_Swapchain_Texture
     (Self          : in out Command_Buffer;
      Window        : in SDL.Video.Windows.Window;
      Acquired      : in out Texture;
      Width, Height : out SDL.Natural_Dimension) return Boolean
   is
      Raw_Texture : aliased Texture_Handle := null;
      Raw_Width   : aliased Interfaces.Unsigned_32 := 0;
      Raw_Height  : aliased Interfaces.Unsigned_32 := 0;
   begin
      Require_Command_Buffer (Self);

      if not To_Bool
          (Raw.Wait_And_Acquire_Swapchain_Texture
             (Self.Internal,
              Window_Address (Window),
              Raw_Texture'Access,
              Raw_Width'Access,
              Raw_Height'Access))
      then
         Raise_GPU_Error ("SDL_WaitAndAcquireGPUSwapchainTexture failed");
      end if;

      Destroy (Acquired);
      Reset (Acquired, Internal => Raw_Texture, Owns => False);
      Width := SDL.Natural_Dimension (Raw_Width);
      Height := SDL.Natural_Dimension (Raw_Height);
      return Raw_Texture /= null;
   end Wait_And_Acquire_Swapchain_Texture;

   procedure Submit (Self : in out Command_Buffer) is
   begin
      Require_Command_Buffer (Self);

      if not To_Bool (Raw.Submit_Command_Buffer (Self.Internal)) then
         Raise_GPU_Error ("SDL_SubmitGPUCommandBuffer failed");
      end if;

      Self.Internal := null;
   end Submit;

   procedure Cancel (Self : in out Command_Buffer) is
   begin
      if Self.Internal = null then
         return;
      end if;

      if not To_Bool (Raw.Cancel_Command_Buffer (Self.Internal)) then
         Raise_GPU_Error ("SDL_CancelGPUCommandBuffer failed");
      end if;

      Self.Internal := null;
   end Cancel;

   function Submit_And_Acquire_Fence
     (Self : in out Command_Buffer) return Fence
   is
      Internal : Fence_Handle;
   begin
      Require_Command_Buffer (Self);
      Internal := Raw.Submit_Command_Buffer_And_Acquire_Fence (Self.Internal);

      if Internal = null then
         Raise_GPU_Error
           ("SDL_SubmitGPUCommandBufferAndAcquireFence failed");
      end if;

      Self.Internal := null;
      return (Internal => Internal);
   end Submit_And_Acquire_Fence;

   function Make_Color_Target_Info
     (Target          : in Texture;
      Clear_To        : in Float_Colour :=
        (Red => 0.0, Green => 0.0, Blue => 0.0, Alpha => 1.0);
      Load_Operation  : in Load_Operations := Clear;
      Store_Operation : in Store_Operations := Store;
      Cycle           : in Boolean := False) return Color_Target_Info
   is
   begin
      Require_Texture (Target);

      return
        (Internal =>
           (Texture              => Target.Internal,
            Mip_Level            => 0,
            Layer_Or_Depth_Plane => 0,
            Clear_Color          => Clear_To,
            Load_Op              => To_Raw (Load_Operation),
            Store_Op             => To_Raw (Store_Operation),
            Resolve_Texture      => null,
            Resolve_Mip_Level    => 0,
            Resolve_Layer        => 0,
            Cycle                => To_C_Bool (Cycle),
            Cycle_Resolve        => CE.bool'Val (0),
            Padding_1            => 0,
            Padding_2            => 0));
   end Make_Color_Target_Info;

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
      return Depth_Stencil_Target_Info
   is
   begin
      Require_Texture (Target);

      return
        (Internal =>
           (Texture          => Target.Internal,
            Clear_Depth      => Clear_Depth,
            Load_Op          => To_Raw (Load_Operation),
            Store_Op         => To_Raw (Store_Operation),
            Stencil_Load_Op  => To_Raw (Stencil_Load_Op),
            Stencil_Store_Op => To_Raw (Stencil_Store_Op),
            Cycle            => To_C_Bool (Cycle),
            Clear_Stencil    => Clear_Stencil,
            Mip_Level        => Mip_Level,
            Layer            => Layer));
   end Make_Depth_Stencil_Target_Info;

   function Begin_Render_Pass_Internal
     (Self                  : in out Command_Buffer;
      Color_Targets         : access constant Raw.Color_Target_Info;
      Num_Color_Targets     : in Interfaces.Unsigned_32;
      Depth_Stencil_Target  : in System.Address := System.Null_Address)
      return Render_Pass
   is
      Pass_Handle : Render_Pass_Handle;
   begin
      Require_Command_Buffer (Self);
      Pass_Handle :=
        Raw.Begin_Render_Pass
          (Self.Internal,
           Color_Targets,
           Num_Color_Targets,
           Depth_Stencil_Target);

      if Pass_Handle = null then
         Raise_GPU_Error ("SDL_BeginGPURenderPass failed");
      end if;

      return (Internal => Pass_Handle);
   end Begin_Render_Pass_Internal;

   function Begin_Render_Pass
     (Self         : in out Command_Buffer;
      Color_Target : in Color_Target_Info) return Render_Pass
   is
      Raw_Target  : aliased constant Raw.Color_Target_Info := Color_Target.Internal;
   begin
      return Begin_Render_Pass_Internal (Self, Raw_Target'Access, 1);
   end Begin_Render_Pass;

   function Begin_Render_Pass
     (Self          : in out Command_Buffer;
      Color_Targets : in Color_Target_Info_Arrays) return Render_Pass
   is
      Raw_Targets : aliased Raw_Color_Target_Info_Arrays
        (0 .. Array_Last (Color_Targets'Length));
      First_Target : access constant Raw.Color_Target_Info := null;
   begin
      for Index in Color_Targets'Range loop
         Raw_Targets (C.size_t (Index - Color_Targets'First)) :=
           Color_Targets (Index).Internal;
      end loop;

      if Color_Targets'Length > 0 then
         First_Target := Raw_Targets (0)'Access;
      end if;

      return
        Begin_Render_Pass_Internal
          (Self,
           First_Target,
           Interfaces.Unsigned_32 (Color_Targets'Length));
   end Begin_Render_Pass;

   function Begin_Render_Pass
     (Self                 : in out Command_Buffer;
      Color_Target         : in Color_Target_Info;
      Depth_Stencil_Target : in Depth_Stencil_Target_Info) return Render_Pass
   is
      Raw_Target : aliased constant Raw.Color_Target_Info := Color_Target.Internal;
      Raw_Depth  : aliased constant Raw.Depth_Stencil_Target_Info :=
        Depth_Stencil_Target.Internal;
   begin
      return
        Begin_Render_Pass_Internal
          (Self, Raw_Target'Access, 1, Raw_Depth'Address);
   end Begin_Render_Pass;

   function Begin_Render_Pass
     (Self                 : in out Command_Buffer;
      Color_Targets        : in Color_Target_Info_Arrays;
      Depth_Stencil_Target : in Depth_Stencil_Target_Info) return Render_Pass
   is
      Raw_Targets : aliased Raw_Color_Target_Info_Arrays
        (0 .. Array_Last (Color_Targets'Length));
      First_Target : access constant Raw.Color_Target_Info := null;
      Raw_Depth    : aliased constant Raw.Depth_Stencil_Target_Info :=
        Depth_Stencil_Target.Internal;
   begin
      for Index in Color_Targets'Range loop
         Raw_Targets (C.size_t (Index - Color_Targets'First)) :=
           Color_Targets (Index).Internal;
      end loop;

      if Color_Targets'Length > 0 then
         First_Target := Raw_Targets (0)'Access;
      end if;

      return
        Begin_Render_Pass_Internal
          (Self,
           First_Target,
           Interfaces.Unsigned_32 (Color_Targets'Length),
           Raw_Depth'Address);
   end Begin_Render_Pass;

   function Begin_Render_Pass
     (Self                 : in out Command_Buffer;
      Depth_Stencil_Target : in Depth_Stencil_Target_Info) return Render_Pass
   is
      Raw_Depth : aliased constant Raw.Depth_Stencil_Target_Info :=
        Depth_Stencil_Target.Internal;
   begin
      return
        Begin_Render_Pass_Internal
          (Self, null, 0, Raw_Depth'Address);
   end Begin_Render_Pass;

   procedure End_Pass (Self : in out Render_Pass) is
   begin
      if Self.Internal = null then
         return;
      end if;

      Raw.End_Render_Pass (Self.Internal);
      Self.Internal := null;
   end End_Pass;

   function Is_Null (Self : in Render_Pass) return Boolean is
     (Self.Internal = null);

   procedure Bind_Pipeline
     (Self     : in Render_Pass;
      Pipeline : in Graphics_Pipeline)
   is
   begin
      Require_Render_Pass (Self);
      Require_Graphics_Pipeline (Pipeline);
      Raw.Bind_Graphics_Pipeline (Self.Internal, Pipeline.Internal);
   end Bind_Pipeline;

   procedure Set_Viewport
     (Self : in Render_Pass;
      Area : in Viewport)
   is
      Raw_Area : aliased constant Raw.Viewport := Area;
   begin
      Require_Render_Pass (Self);
      Raw.Set_Viewport (Self.Internal, Raw_Area'Access);
   end Set_Viewport;

   procedure Set_Scissor
     (Self    : in Render_Pass;
      Scissor : in SDL.Video.Rectangles.Rectangle)
   is
      Raw_Scissor : aliased constant SDL.Video.Rectangles.Rectangle := Scissor;
   begin
      Require_Render_Pass (Self);
      Raw.Set_Scissor (Self.Internal, Raw_Scissor'Address);
   end Set_Scissor;

   procedure Set_Blend_Constants
     (Self      : in Render_Pass;
      Constants : in Float_Colour)
   is
   begin
      Require_Render_Pass (Self);
      Raw.Set_Blend_Constants (Self.Internal, Constants);
   end Set_Blend_Constants;

   procedure Set_Stencil_Reference
     (Self      : in Render_Pass;
      Reference : in Interfaces.Unsigned_8)
   is
   begin
      Require_Render_Pass (Self);
      Raw.Set_Stencil_Reference (Self.Internal, Reference);
   end Set_Stencil_Reference;

   procedure Bind_Vertex_Buffers
     (Self       : in Render_Pass;
      First_Slot : in Interfaces.Unsigned_32;
      Bindings   : in Buffer_Binding_Arrays)
   is
      Raw_Bindings : aliased Raw_Buffer_Binding_Arrays
        (0 .. Array_Last (Bindings'Length));
   begin
      Require_Render_Pass (Self);

      for Index in Bindings'Range loop
         Raw_Bindings (C.size_t (Index - Bindings'First)) :=
           Bindings (Index).Internal;
      end loop;

      Raw.Bind_Vertex_Buffers
        (Self.Internal,
         First_Slot,
         (if Bindings'Length = 0 then System.Null_Address
          else Raw_Bindings'Address),
         Interfaces.Unsigned_32 (Bindings'Length));
   end Bind_Vertex_Buffers;

   procedure Bind_Index_Buffer
     (Self               : in Render_Pass;
      Binding            : in Buffer_Binding;
      Index_Element_Size : in Index_Element_Sizes)
   is
      Raw_Binding : aliased constant Raw.Buffer_Binding := Binding.Internal;
   begin
      Require_Render_Pass (Self);
      Raw.Bind_Index_Buffer
        (Self.Internal, Raw_Binding'Access, To_Raw (Index_Element_Size));
   end Bind_Index_Buffer;

   procedure Bind_Vertex_Samplers
     (Self       : in Render_Pass;
      First_Slot : in Interfaces.Unsigned_32;
      Bindings   : in Texture_Sampler_Binding_Arrays)
   is
      Raw_Bindings : aliased Raw_Texture_Sampler_Binding_Arrays
        (0 .. Array_Last (Bindings'Length));
   begin
      Require_Render_Pass (Self);

      for Index in Bindings'Range loop
         Raw_Bindings (C.size_t (Index - Bindings'First)) :=
           Bindings (Index).Internal;
      end loop;

      Raw.Bind_Vertex_Samplers
        (Self.Internal,
         First_Slot,
         (if Bindings'Length = 0 then System.Null_Address
          else Raw_Bindings'Address),
         Interfaces.Unsigned_32 (Bindings'Length));
   end Bind_Vertex_Samplers;

   procedure Bind_Vertex_Storage_Textures
     (Self       : in Render_Pass;
      First_Slot : in Interfaces.Unsigned_32;
      Bindings   : in Texture_Arrays)
   is
      Raw_Bindings : aliased Raw_Texture_Handle_Arrays
        (0 .. Array_Last (Bindings'Length));
   begin
      Require_Render_Pass (Self);

      for Index in Bindings'Range loop
         Require_Texture (Bindings (Index));
         Raw_Bindings (C.size_t (Index - Bindings'First)) :=
           Bindings (Index).Internal;
      end loop;

      Raw.Bind_Vertex_Storage_Textures
        (Self.Internal,
         First_Slot,
         (if Bindings'Length = 0 then System.Null_Address
          else Raw_Bindings'Address),
         Interfaces.Unsigned_32 (Bindings'Length));
   end Bind_Vertex_Storage_Textures;

   procedure Bind_Vertex_Storage_Buffers
     (Self       : in Render_Pass;
      First_Slot : in Interfaces.Unsigned_32;
      Bindings   : in Buffer_Arrays)
   is
      Raw_Bindings : aliased Raw_Buffer_Handle_Arrays
        (0 .. Array_Last (Bindings'Length));
   begin
      Require_Render_Pass (Self);

      for Index in Bindings'Range loop
         Require_Buffer (Bindings (Index));
         Raw_Bindings (C.size_t (Index - Bindings'First)) :=
           Bindings (Index).Internal;
      end loop;

      Raw.Bind_Vertex_Storage_Buffers
        (Self.Internal,
         First_Slot,
         (if Bindings'Length = 0 then System.Null_Address
          else Raw_Bindings'Address),
         Interfaces.Unsigned_32 (Bindings'Length));
   end Bind_Vertex_Storage_Buffers;

   procedure Bind_Fragment_Samplers
     (Self       : in Render_Pass;
      First_Slot : in Interfaces.Unsigned_32;
      Bindings   : in Texture_Sampler_Binding_Arrays)
   is
      Raw_Bindings : aliased Raw_Texture_Sampler_Binding_Arrays
        (0 .. Array_Last (Bindings'Length));
   begin
      Require_Render_Pass (Self);

      for Index in Bindings'Range loop
         Raw_Bindings (C.size_t (Index - Bindings'First)) :=
           Bindings (Index).Internal;
      end loop;

      Raw.Bind_Fragment_Samplers
        (Self.Internal,
         First_Slot,
         (if Bindings'Length = 0 then System.Null_Address
          else Raw_Bindings'Address),
         Interfaces.Unsigned_32 (Bindings'Length));
   end Bind_Fragment_Samplers;

   procedure Bind_Fragment_Storage_Textures
     (Self       : in Render_Pass;
      First_Slot : in Interfaces.Unsigned_32;
      Bindings   : in Texture_Arrays)
   is
      Raw_Bindings : aliased Raw_Texture_Handle_Arrays
        (0 .. Array_Last (Bindings'Length));
   begin
      Require_Render_Pass (Self);

      for Index in Bindings'Range loop
         Require_Texture (Bindings (Index));
         Raw_Bindings (C.size_t (Index - Bindings'First)) :=
           Bindings (Index).Internal;
      end loop;

      Raw.Bind_Fragment_Storage_Textures
        (Self.Internal,
         First_Slot,
         (if Bindings'Length = 0 then System.Null_Address
          else Raw_Bindings'Address),
         Interfaces.Unsigned_32 (Bindings'Length));
   end Bind_Fragment_Storage_Textures;

   procedure Bind_Fragment_Storage_Buffers
     (Self       : in Render_Pass;
      First_Slot : in Interfaces.Unsigned_32;
      Bindings   : in Buffer_Arrays)
   is
      Raw_Bindings : aliased Raw_Buffer_Handle_Arrays
        (0 .. Array_Last (Bindings'Length));
   begin
      Require_Render_Pass (Self);

      for Index in Bindings'Range loop
         Require_Buffer (Bindings (Index));
         Raw_Bindings (C.size_t (Index - Bindings'First)) :=
           Bindings (Index).Internal;
      end loop;

      Raw.Bind_Fragment_Storage_Buffers
        (Self.Internal,
         First_Slot,
         (if Bindings'Length = 0 then System.Null_Address
          else Raw_Bindings'Address),
         Interfaces.Unsigned_32 (Bindings'Length));
   end Bind_Fragment_Storage_Buffers;

   procedure Draw_Indexed_Primitives
     (Self           : in Render_Pass;
      Num_Indices    : in Interfaces.Unsigned_32;
      Num_Instances  : in Interfaces.Unsigned_32 := 1;
      First_Index    : in Interfaces.Unsigned_32 := 0;
      Vertex_Offset  : in Integer := 0;
      First_Instance : in Interfaces.Unsigned_32 := 0)
   is
   begin
      Require_Render_Pass (Self);
      Raw.Draw_Indexed_Primitives
        (Self.Internal,
         Num_Indices,
         Num_Instances,
         First_Index,
         C.int (Vertex_Offset),
         First_Instance);
   end Draw_Indexed_Primitives;

   procedure Draw_Primitives
     (Self           : in Render_Pass;
      Num_Vertices   : in Interfaces.Unsigned_32;
      Num_Instances  : in Interfaces.Unsigned_32 := 1;
      First_Vertex   : in Interfaces.Unsigned_32 := 0;
      First_Instance : in Interfaces.Unsigned_32 := 0)
   is
   begin
      Require_Render_Pass (Self);
      Raw.Draw_Primitives
        (Self.Internal,
         Num_Vertices,
         Num_Instances,
         First_Vertex,
         First_Instance);
   end Draw_Primitives;

   procedure Draw_Primitives_Indirect
     (Self       : in Render_Pass;
      Parameters : in Buffer;
      Offset     : in Interfaces.Unsigned_32 := 0;
      Draw_Count : in Interfaces.Unsigned_32 := 1)
   is
   begin
      Require_Render_Pass (Self);
      Require_Buffer (Parameters);
      Raw.Draw_Primitives_Indirect
        (Self.Internal, Parameters.Internal, Offset, Draw_Count);
   end Draw_Primitives_Indirect;

   procedure Draw_Indexed_Primitives_Indirect
     (Self       : in Render_Pass;
      Parameters : in Buffer;
      Offset     : in Interfaces.Unsigned_32 := 0;
      Draw_Count : in Interfaces.Unsigned_32 := 1)
   is
   begin
      Require_Render_Pass (Self);
      Require_Buffer (Parameters);
      Raw.Draw_Indexed_Primitives_Indirect
        (Self.Internal, Parameters.Internal, Offset, Draw_Count);
   end Draw_Indexed_Primitives_Indirect;

   procedure Bind_Pipeline
     (Self     : in Compute_Pass;
      Pipeline : in Compute_Pipeline)
   is
   begin
      Require_Compute_Pass (Self);
      Require_Compute_Pipeline (Pipeline);
      Raw.Bind_Compute_Pipeline (Self.Internal, Pipeline.Internal);
   end Bind_Pipeline;

   procedure Bind_Compute_Samplers
     (Self       : in Compute_Pass;
      First_Slot : in Interfaces.Unsigned_32;
      Bindings   : in Texture_Sampler_Binding_Arrays)
   is
      Raw_Bindings : aliased Raw_Texture_Sampler_Binding_Arrays
        (0 .. Array_Last (Bindings'Length));
   begin
      Require_Compute_Pass (Self);

      for Index in Bindings'Range loop
         Raw_Bindings (C.size_t (Index - Bindings'First)) :=
           Bindings (Index).Internal;
      end loop;

      Raw.Bind_Compute_Samplers
        (Self.Internal,
         First_Slot,
         (if Bindings'Length = 0 then System.Null_Address
          else Raw_Bindings'Address),
         Interfaces.Unsigned_32 (Bindings'Length));
   end Bind_Compute_Samplers;

   procedure Bind_Compute_Storage_Textures
     (Self       : in Compute_Pass;
      First_Slot : in Interfaces.Unsigned_32;
      Bindings   : in Texture_Arrays)
   is
      Raw_Bindings : aliased Raw_Texture_Handle_Arrays
        (0 .. Array_Last (Bindings'Length));
   begin
      Require_Compute_Pass (Self);

      for Index in Bindings'Range loop
         Require_Texture (Bindings (Index));
         Raw_Bindings (C.size_t (Index - Bindings'First)) :=
           Bindings (Index).Internal;
      end loop;

      Raw.Bind_Compute_Storage_Textures
        (Self.Internal,
         First_Slot,
         (if Bindings'Length = 0 then System.Null_Address
          else Raw_Bindings'Address),
         Interfaces.Unsigned_32 (Bindings'Length));
   end Bind_Compute_Storage_Textures;

   procedure Bind_Compute_Storage_Buffers
     (Self       : in Compute_Pass;
      First_Slot : in Interfaces.Unsigned_32;
      Bindings   : in Buffer_Arrays)
   is
      Raw_Bindings : aliased Raw_Buffer_Handle_Arrays
        (0 .. Array_Last (Bindings'Length));
   begin
      Require_Compute_Pass (Self);

      for Index in Bindings'Range loop
         Require_Buffer (Bindings (Index));
         Raw_Bindings (C.size_t (Index - Bindings'First)) :=
           Bindings (Index).Internal;
      end loop;

      Raw.Bind_Compute_Storage_Buffers
        (Self.Internal,
         First_Slot,
         (if Bindings'Length = 0 then System.Null_Address
          else Raw_Bindings'Address),
         Interfaces.Unsigned_32 (Bindings'Length));
   end Bind_Compute_Storage_Buffers;

   procedure Dispatch
     (Self         : in Compute_Pass;
      Groupcount_X : in Interfaces.Unsigned_32;
      Groupcount_Y : in Interfaces.Unsigned_32;
      Groupcount_Z : in Interfaces.Unsigned_32)
   is
   begin
      Require_Compute_Pass (Self);
      Raw.Dispatch_Compute (Self.Internal, Groupcount_X, Groupcount_Y, Groupcount_Z);
   end Dispatch;

   procedure Dispatch_Indirect
     (Self       : in Compute_Pass;
      Parameters : in Buffer;
      Offset     : in Interfaces.Unsigned_32 := 0)
   is
   begin
      Require_Compute_Pass (Self);
      Require_Buffer (Parameters);
      Raw.Dispatch_Compute_Indirect (Self.Internal, Parameters.Internal, Offset);
   end Dispatch_Indirect;

   function Is_Null (Self : in Fence) return Boolean is
     (Self.Internal = null);

   function Query
     (Device : in SDL.GPU.Device;
      Self   : in Fence) return Boolean
   is
   begin
      Require_Device (Device);

      if Self.Internal = null then
         return False;
      end if;

      return To_Bool (Raw.Query_Fence (Device.Internal, Self.Internal));
   end Query;

   function Wait
     (Device : in SDL.GPU.Device;
      Self   : in Fence) return Boolean
   is
      type Fence_List is array (C.size_t range 0 .. 0) of aliased Fence_Handle with
        Convention => C;

      Fences : aliased Fence_List := [0 => Self.Internal];
   begin
      Require_Device (Device);

      if Self.Internal = null then
         return False;
      end if;

      return
        To_Bool
          (Raw.Wait_For_Fences
             (Device.Internal,
              To_C_Bool (True),
              Fences'Address,
              1));
   end Wait;

   procedure Release
     (Device : in SDL.GPU.Device;
      Self   : in out Fence)
   is
   begin
      if Device.Internal = null or else Self.Internal = null then
         return;
      end if;

      Raw.Release_Fence (Device.Internal, Self.Internal);
      Self.Internal := null;
   end Release;

   procedure Wait_For_Idle (Self : in Device) is
   begin
      Require_Device (Self);

      if not To_Bool (Raw.Wait_For_Idle (Self.Internal)) then
         Raise_GPU_Error ("SDL_WaitForGPUIdle failed");
      end if;
   end Wait_For_Idle;

   function Make_Device_From_Pointer
     (Internal : in Device_Handle;
      Owns     : in Boolean := False) return Device
   is
   begin
      return Result : Device do
         Result.Internal := Internal;
         Result.Owns := Owns;
      end return;
   end Make_Device_From_Pointer;

   function Make_Texture_From_Pointer
     (Internal : in Texture_Handle) return Texture is
   begin
      return Result : Texture do
         Reset (Result, Internal => Internal, Owns => False);
      end return;
   end Make_Texture_From_Pointer;
end SDL.GPU;
