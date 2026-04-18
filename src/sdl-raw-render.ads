with Interfaces;
with Interfaces.C;
with Interfaces.C.Extensions;
with Interfaces.C.Strings;
with System;

with SDL.Raw.Properties;

package SDL.Raw.Render is
   pragma Preelaborate;

   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;
   package CS renames Interfaces.C.Strings;

   subtype Pixel_Format_Names is Interfaces.Unsigned_32;
   subtype Texture_Kind is C.int;
   subtype Texture_Scale_Mode is C.int;
   subtype Logical_Presentation is C.int;
   subtype Flip_Mode is C.int;
   subtype Texture_Address_Mode is C.int;
   subtype Blend_Mode is Interfaces.Unsigned_32;
   subtype Colour_Component is Interfaces.Unsigned_8;
   subtype Texture_Pitch is C.int;
   subtype Vulkan_Wait_Stage_Mask is Interfaces.Unsigned_32;
   subtype Vulkan_Semaphore is Interfaces.Integer_64;

   function Create_Texture
     (Target     : in System.Address;
      Pixel      : in Pixel_Format_Names;
      Kind_Value : in Texture_Kind;
      Width      : in C.int;
      Height     : in C.int) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CreateTexture";

   function Create_Texture_From_Surface
     (Renderer : in System.Address;
      Surface  : in System.Address) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CreateTextureFromSurface";

   function Create_Texture_With_Properties
     (Renderer : in System.Address;
      Props    : in SDL.Raw.Properties.ID) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CreateTextureWithProperties";

   function Create_Renderer_With_Properties
     (Props : in SDL.Raw.Properties.ID) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CreateRendererWithProperties";

   function Create_Software_Renderer
     (Surface : in System.Address) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CreateSoftwareRenderer";

   function Create_GPU_Renderer
     (Device : in System.Address;
      Window : in System.Address) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CreateGPURenderer";

   function Get_Num_Render_Drivers return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetNumRenderDrivers";

   function Get_Render_Driver
     (Index : in C.int) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetRenderDriver";

   function Get_Renderer_Name
     (Value : in System.Address) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetRendererName";

   function Get_Renderer
     (Value : in System.Address) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetRenderer";

   function Get_Renderer_From_Texture
     (Value : in System.Address) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetRendererFromTexture";

   function Get_Render_Window
     (Value : in System.Address) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetRenderWindow";

   function Get_Renderer_Properties
     (Value : in System.Address) return SDL.Raw.Properties.ID
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetRendererProperties";

   function Get_GPU_Renderer_Device
     (Value : in System.Address) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetGPURendererDevice";

   function Create_GPU_Render_State
     (Target      : in System.Address;
      Create_Info : in System.Address) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CreateGPURenderState";

   procedure Destroy_GPU_Render_State
     (State : in System.Address)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_DestroyGPURenderState";

   function Set_GPU_Render_State_Fragment_Uniforms
     (State      : in System.Address;
      Slot_Index : in Interfaces.Unsigned_32;
      Data       : in System.Address;
      Length     : in Interfaces.Unsigned_32) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetGPURenderStateFragmentUniforms";

   function Set_GPU_Render_State
     (Target : in System.Address;
      State  : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetGPURenderState";

   function Get_Render_Output_Size
     (Value  : in System.Address;
      Width  : access C.int;
      Height : access C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetRenderOutputSize";

   function Get_Current_Render_Output_Size
     (Value  : in System.Address;
      Width  : access C.int;
      Height : access C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetCurrentRenderOutputSize";

   function Set_Render_Target
     (Renderer : in System.Address;
      Target   : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetRenderTarget";

   function Get_Render_Target
     (Renderer : in System.Address) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetRenderTarget";

   function Set_Render_Logical_Presentation
     (Renderer : in System.Address;
      Width    : in C.int;
      Height   : in C.int;
      Mode     : in Logical_Presentation) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetRenderLogicalPresentation";

   function Get_Render_Logical_Presentation
     (Renderer : in System.Address;
      Width    : access C.int;
      Height   : access C.int;
      Mode     : access Logical_Presentation) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetRenderLogicalPresentation";

   function Get_Render_Logical_Presentation_Rect
     (Renderer  : in System.Address;
      Rectangle : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetRenderLogicalPresentationRect";

   function Render_Coordinates_From_Window
     (Renderer : in System.Address;
      Window_X : in C.C_float;
      Window_Y : in C.C_float;
      X        : access C.C_float;
      Y        : access C.C_float) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_RenderCoordinatesFromWindow";

   function Render_Coordinates_To_Window
     (Renderer : in System.Address;
      X        : in C.C_float;
      Y        : in C.C_float;
      Window_X : access C.C_float;
      Window_Y : access C.C_float) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_RenderCoordinatesToWindow";

   function Convert_Event_To_Render_Coordinates
     (Renderer : in System.Address;
      Event    : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ConvertEventToRenderCoordinates";

   function Set_Render_Viewport
     (Renderer : in System.Address;
      Rect     : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetRenderViewport";

   function Get_Render_Viewport
     (Renderer : in System.Address;
      Rect     : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetRenderViewport";

   function Render_Viewport_Set
     (Renderer : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_RenderViewportSet";

   function Get_Render_Safe_Area
     (Renderer : in System.Address;
      Rect     : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetRenderSafeArea";

   function Set_Render_Clip_Rect
     (Renderer : in System.Address;
      Rect     : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetRenderClipRect";

   function Get_Render_Clip_Rect
     (Renderer : in System.Address;
      Rect     : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetRenderClipRect";

   function Render_Clip_Enabled
     (Renderer : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_RenderClipEnabled";

   function Set_Render_Scale
     (Renderer : in System.Address;
      Scale_X  : in C.C_float;
      Scale_Y  : in C.C_float) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetRenderScale";

   function Get_Render_Scale
     (Renderer : in System.Address;
      Scale_X  : access C.C_float;
      Scale_Y  : access C.C_float) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetRenderScale";

   function Get_Render_Draw_Blend_Mode
     (Renderer : in System.Address;
      Mode     : access Blend_Mode) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetRenderDrawBlendMode";

   function Set_Render_Draw_Blend_Mode
     (Renderer : in System.Address;
      Mode     : in Blend_Mode) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetRenderDrawBlendMode";

   function Get_Render_Draw_Color
     (Renderer : in System.Address;
      Red      : access Colour_Component;
      Green    : access Colour_Component;
      Blue     : access Colour_Component;
      Alpha    : access Colour_Component) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetRenderDrawColor";

   function Get_Render_Draw_Color_Float
     (Renderer : in System.Address;
      Red      : access C.C_float;
      Green    : access C.C_float;
      Blue     : access C.C_float;
      Alpha    : access C.C_float) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetRenderDrawColorFloat";

   function Set_Render_Draw_Color
     (Renderer : in System.Address;
      Red      : in Colour_Component;
      Green    : in Colour_Component;
      Blue     : in Colour_Component;
      Alpha    : in Colour_Component) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetRenderDrawColor";

   function Set_Render_Draw_Color_Float
     (Renderer : in System.Address;
      Red      : in C.C_float;
      Green    : in C.C_float;
      Blue     : in C.C_float;
      Alpha    : in C.C_float) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetRenderDrawColorFloat";

   function Get_Render_Color_Scale
     (Renderer : in System.Address;
      Scale    : access C.C_float) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetRenderColorScale";

   function Set_Render_Color_Scale
     (Renderer : in System.Address;
      Scale    : in C.C_float) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetRenderColorScale";

   function Render_Clear
     (Value : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_RenderClear";

   function Render_Point
     (Renderer : in System.Address;
      X        : in C.C_float;
      Y        : in C.C_float) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_RenderPoint";

   function Render_Points
     (Renderer : in System.Address;
      Points   : in System.Address;
      Count    : in C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_RenderPoints";

   function Render_Lines
     (Renderer : in System.Address;
      Points   : in System.Address;
      Count    : in C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_RenderLines";

   function Render_Line
     (Renderer : in System.Address;
      X1       : in C.C_float;
      Y1       : in C.C_float;
      X2       : in C.C_float;
      Y2       : in C.C_float) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_RenderLine";

   function Render_Rect
     (Renderer : in System.Address;
      Rect     : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_RenderRect";

   function Render_Rects
     (Renderer : in System.Address;
      Rects    : in System.Address;
      Count    : in C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_RenderRects";

   function Render_Fill_Rect
     (Renderer : in System.Address;
      Rect     : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_RenderFillRect";

   function Render_Fill_Rects
     (Renderer : in System.Address;
      Rects    : in System.Address;
      Count    : in C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_RenderFillRects";

   function Render_Texture
     (Renderer : in System.Address;
      Texture  : in System.Address;
      Source   : in System.Address;
      Target   : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_RenderTexture";

   function Render_Texture_Rotated
     (Renderer : in System.Address;
      Texture  : in System.Address;
      Source   : in System.Address;
      Target   : in System.Address;
      Angle    : in C.double;
      Centre   : in System.Address;
      Flip     : in Flip_Mode) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_RenderTextureRotated";

   function Render_Texture_Affine
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

   function Render_Texture_Tiled
     (Renderer : in System.Address;
      Texture  : in System.Address;
      Source   : in System.Address;
      Scale    : in C.C_float;
      Target   : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_RenderTextureTiled";

   function Render_Texture_9_Grid
     (Renderer      : in System.Address;
      Texture       : in System.Address;
      Source        : in System.Address;
      Left_Width    : in C.C_float;
      Right_Width   : in C.C_float;
      Top_Height    : in C.C_float;
      Bottom_Height : in C.C_float;
      Scale         : in C.C_float;
      Target        : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_RenderTexture9Grid";

   function Render_Texture_9_Grid_Tiled
     (Renderer      : in System.Address;
      Texture       : in System.Address;
      Source        : in System.Address;
      Left_Width    : in C.C_float;
      Right_Width   : in C.C_float;
      Top_Height    : in C.C_float;
      Bottom_Height : in C.C_float;
      Scale         : in C.C_float;
      Target        : in System.Address;
      Tile_Scale    : in C.C_float) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_RenderTexture9GridTiled";

   function Render_Geometry
     (Renderer    : in System.Address;
      Texture     : in System.Address;
      Vertex_Data : in System.Address;
      Count       : in C.int;
      Indices     : in System.Address;
      I_Count     : in C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_RenderGeometry";

   function Render_Geometry_Raw
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

   function Set_Render_Texture_Address_Mode
     (Renderer : in System.Address;
      U_Mode   : in Texture_Address_Mode;
      V_Mode   : in Texture_Address_Mode) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetRenderTextureAddressMode";

   function Get_Render_Texture_Address_Mode
     (Renderer : in System.Address;
      U_Mode   : access Texture_Address_Mode;
      V_Mode   : access Texture_Address_Mode) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetRenderTextureAddressMode";

   function Render_Read_Pixels
     (Renderer : in System.Address;
      Area     : in System.Address) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_RenderReadPixels";

   function Render_Present
     (Value : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_RenderPresent";

   function Flush_Renderer
     (Renderer : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_FlushRenderer";

   function Get_Render_Metal_Layer
     (Renderer : in System.Address) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetRenderMetalLayer";

   function Get_Render_Metal_Command_Encoder
     (Renderer : in System.Address) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetRenderMetalCommandEncoder";

   function Add_Vulkan_Render_Semaphores
     (Renderer         : in System.Address;
      Wait_Stage_Mask  : in Vulkan_Wait_Stage_Mask;
      Wait_Semaphore   : in Vulkan_Semaphore;
      Signal_Semaphore : in Vulkan_Semaphore) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_AddVulkanRenderSemaphores";

   function Set_Render_VSync
     (Renderer : in System.Address;
      Value    : in C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetRenderVSync";

   function Get_Render_VSync
     (Renderer : in System.Address;
      Value    : access C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetRenderVSync";

   function Render_Debug_Text
     (Renderer : in System.Address;
      X        : in C.C_float;
      Y        : in C.C_float;
      Text     : in C.char_array) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_RenderDebugText";

   function Set_Default_Texture_Scale_Mode
     (Renderer : in System.Address;
      Mode     : in Texture_Scale_Mode) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetDefaultTextureScaleMode";

   function Get_Default_Texture_Scale_Mode
     (Renderer : in System.Address;
      Mode     : access Texture_Scale_Mode) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetDefaultTextureScaleMode";

   procedure Destroy_Renderer
     (Value : in System.Address)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_DestroyRenderer";

   function Get_Texture_Properties
     (Value : in System.Address) return SDL.Raw.Properties.ID
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetTextureProperties";

   function Lock_Texture
     (Value  : in System.Address;
      Area   : in System.Address;
      Target : out System.Address;
      Pitch  : out Texture_Pitch) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_LockTexture";

   function Lock_Texture_To_Surface
     (Value   : in System.Address;
      Area    : in System.Address;
      Surface : access System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_LockTextureToSurface";

   procedure Unlock_Texture (Value : in System.Address)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_UnlockTexture";

   function Update_Texture
     (Value  : in System.Address;
      Area   : in System.Address;
      Pixels : in System.Address;
      Pitch  : in Texture_Pitch) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_UpdateTexture";

   function Update_YUV_Texture
     (Value    : in System.Address;
      Area     : in System.Address;
      Y_Pixels : in System.Address;
      Y_Pitch  : in Texture_Pitch;
      U_Pixels : in System.Address;
      U_Pitch  : in Texture_Pitch;
      V_Pixels : in System.Address;
      V_Pitch  : in Texture_Pitch) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_UpdateYUVTexture";

   function Update_NV_Texture
     (Value     : in System.Address;
      Area      : in System.Address;
      Y_Pixels  : in System.Address;
      Y_Pitch   : in Texture_Pitch;
      UV_Pixels : in System.Address;
      UV_Pitch  : in Texture_Pitch) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_UpdateNVTexture";

   function Set_Texture_Palette
     (Value   : in System.Address;
      Palette : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetTexturePalette";

   function Get_Texture_Palette
     (Value : in System.Address) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetTexturePalette";

   function Set_Texture_Scale_Mode
     (Value : in System.Address;
      Scale : in Texture_Scale_Mode) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetTextureScaleMode";

   function Get_Texture_Scale_Mode
     (Value : in System.Address;
      Scale : access Texture_Scale_Mode) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetTextureScaleMode";

   function Get_Texture_Blend_Mode
     (Value : in System.Address;
      Mode  : access Blend_Mode) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetTextureBlendMode";

   function Set_Texture_Blend_Mode
     (Value : in System.Address;
      Mode  : in Blend_Mode) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetTextureBlendMode";

   function Get_Texture_Color_Mod
     (Value : in System.Address;
      Red   : access Colour_Component;
      Green : access Colour_Component;
      Blue  : access Colour_Component) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetTextureColorMod";

   function Get_Texture_Color_Mod_Float
     (Value : in System.Address;
      Red   : access C.C_float;
      Green : access C.C_float;
      Blue  : access C.C_float) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetTextureColorModFloat";

   function Set_Texture_Color_Mod
     (Value : in System.Address;
      Red   : in Colour_Component;
      Green : in Colour_Component;
      Blue  : in Colour_Component) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetTextureColorMod";

   function Set_Texture_Color_Mod_Float
     (Value : in System.Address;
      Red   : in C.C_float;
      Green : in C.C_float;
      Blue  : in C.C_float) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetTextureColorModFloat";

   function Get_Texture_Alpha_Mod
     (Value : in System.Address;
      Alpha : access Colour_Component) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetTextureAlphaMod";

   function Get_Texture_Alpha_Mod_Float
     (Value : in System.Address;
      Alpha : access C.C_float) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetTextureAlphaModFloat";

   function Set_Texture_Alpha_Mod
     (Value : in System.Address;
      Alpha : in Colour_Component) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetTextureAlphaMod";

   function Set_Texture_Alpha_Mod_Float
     (Value : in System.Address;
      Alpha : in C.C_float) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetTextureAlphaModFloat";

   function Get_Texture_Size
     (Value  : in System.Address;
      Width  : access C.C_float;
      Height : access C.C_float) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetTextureSize";

   procedure Destroy_Texture (Value : in System.Address)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_DestroyTexture";
end SDL.Raw.Render;
