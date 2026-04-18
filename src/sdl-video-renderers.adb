with Ada.Unchecked_Conversion;
with Ada.Unchecked_Deallocation;

with Interfaces.C.Extensions;
with Interfaces.C.Strings;

with SDL.Error;
with SDL.Raw.Render;
with SDL.Raw.Video;
with SDL.Video.Surfaces.Internal;
with SDL.Video.Textures.Internal;

package body SDL.Video.Renderers is
   package CE renames Interfaces.C.Extensions;
   package CS renames Interfaces.C.Strings;
   package Raw_Render renames SDL.Raw.Render;
   package Raw_Video renames SDL.Raw.Video;
   package Surface_Internal renames SDL.Video.Surfaces.Internal;
   package Texture_Internal renames SDL.Video.Textures.Internal;

   use type CS.chars_ptr;
   use type C.size_t;
   use type System.Address;
   use type SDL.Video.Surfaces.Internal_Surface_Pointer;

   function To_Device_Handle is new Ada.Unchecked_Conversion
     (Source => System.Address,
      Target => SDL.GPU.Device_Handle);

   function To_Internal_Surface_Pointer is new Ada.Unchecked_Conversion
     (Source => System.Address,
      Target => SDL.Video.Surfaces.Internal_Surface_Pointer);

   function To_Window_Pointer is new Ada.Unchecked_Conversion
     (Source => System.Address,
      Target => Raw_Video.Window_Pointer);

   function To_Address
     (Value : access constant SDL.Events.Events.Events) return System.Address is
       (if Value = null then System.Null_Address else Value.all'Address);

   function To_Address
     (Value : access constant SDL.Video.Rectangles.Float_Point)
      return System.Address is
       (if Value = null then System.Null_Address else Value.all'Address);

   function To_Address
     (Value : access constant SDL.Video.Rectangles.Float_Rectangle)
      return System.Address is
       (if Value = null then System.Null_Address else Value.all'Address);

   function To_Address
     (Value : access constant SDL.Video.Rectangles.Rectangle)
      return System.Address is
       (if Value = null then System.Null_Address else Value.all'Address);

   function To_Address
     (Value : access constant SDL.Video.Renderers.Vertices) return System.Address
   is
     (if Value = null then System.Null_Address else Value.all'Address);

   function To_Raw (Value : in Flip_Modes) return Raw_Render.Flip_Mode is
   begin
      case Value is
         when No_Flip =>
            return 0;
         when Horizontal_Flip =>
            return 1;
         when Vertical_Flip =>
            return 2;
         when Horizontal_And_Vertical_Flip =>
            return 3;
      end case;
   end To_Raw;

   function To_Raw
     (Value : in Logical_Presentations) return Raw_Render.Logical_Presentation
   is
   begin
      case Value is
         when Logical_Presentation_Disabled =>
            return 0;
         when Stretch_Presentation =>
            return 1;
         when Letterbox_Presentation =>
            return 2;
         when Overscan_Presentation =>
            return 3;
         when Integer_Scale_Presentation =>
            return 4;
      end case;
   end To_Raw;

   function To_Raw
     (Value : in SDL.Video.Blend_Modes) return Raw_Render.Blend_Mode is
       (Raw_Render.Blend_Mode (Value));

   function To_Raw
     (Value : in Texture_Address_Modes) return Raw_Render.Texture_Address_Mode
   is
   begin
      case Value is
         when Invalid_Address_Mode =>
            return -1;
         when Automatic_Addressing =>
            return 0;
         when Clamp_Addressing =>
            return 1;
         when Wrap_Addressing =>
            return 2;
      end case;
   end To_Raw;

   function To_Raw
     (Value : in SDL.Video.Textures.Scale_Modes)
      return Raw_Render.Texture_Scale_Mode
   is
   begin
      case Value is
         when SDL.Video.Textures.Invalid =>
            return -1;
         when SDL.Video.Textures.Nearest =>
            return 0;
         when SDL.Video.Textures.Linear =>
            return 1;
         when SDL.Video.Textures.Pixel_Art =>
            return 2;
      end case;
   end To_Raw;

   function To_Public
     (Value : in Raw_Render.Logical_Presentation)
      return Logical_Presentations
   is
   begin
      case Value is
         when 0 =>
            return Logical_Presentation_Disabled;
         when 1 =>
            return Stretch_Presentation;
         when 2 =>
            return Letterbox_Presentation;
         when 3 =>
            return Overscan_Presentation;
         when 4 =>
            return Integer_Scale_Presentation;
         when others =>
            return Logical_Presentation_Disabled;
      end case;
   end To_Public;

   function To_Public
     (Value : in Raw_Render.Blend_Mode) return SDL.Video.Blend_Modes is
       (SDL.Video.Blend_Modes (Value));

   function To_Public
     (Value : in Raw_Render.Texture_Address_Mode)
      return Texture_Address_Modes
   is
   begin
      case Value is
         when -1 =>
            return Invalid_Address_Mode;
         when 0 =>
            return Automatic_Addressing;
         when 1 =>
            return Clamp_Addressing;
         when 2 =>
            return Wrap_Addressing;
         when others =>
            return Invalid_Address_Mode;
      end case;
   end To_Public;

   function To_Public
     (Value : in Raw_Render.Texture_Scale_Mode)
      return SDL.Video.Textures.Scale_Modes
   is
   begin
      case Value is
         when -1 =>
            return SDL.Video.Textures.Invalid;
         when 0 =>
            return SDL.Video.Textures.Nearest;
         when 1 =>
            return SDL.Video.Textures.Linear;
         when 2 =>
            return SDL.Video.Textures.Pixel_Art;
         when others =>
            return SDL.Video.Textures.Invalid;
      end case;
   end To_Public;

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
      Size_Indices : in C.int) return CE.bool is
       (Raw_Render.Render_Geometry_Raw
          (Renderer,
           Texture,
           XY,
           XY_Stride,
           Colour,
           Colour_Stride,
           UV,
           UV_Stride,
           Vertex_Count,
           Indices,
           I_Count,
           Size_Indices));

   function SDL_Get_Num_Render_Drivers return C.int is
     (Raw_Render.Get_Num_Render_Drivers);

   function SDL_Get_Render_Driver
     (Index : in C.int) return CS.chars_ptr is
       (Raw_Render.Get_Render_Driver (Index));

   function SDL_Get_Renderer_Name
     (Value : in System.Address) return CS.chars_ptr is
       (Raw_Render.Get_Renderer_Name (Value));

   function SDL_Get_Renderer
     (Value : in System.Address) return System.Address is
       (Raw_Render.Get_Renderer (Value));

   function SDL_Get_Renderer_From_Texture
     (Value : in System.Address) return System.Address is
       (Raw_Render.Get_Renderer_From_Texture (Value));

   function SDL_Get_Render_Window
     (Value : in System.Address) return System.Address is
       (Raw_Render.Get_Render_Window (Value));

   function SDL_Get_Window_ID
     (Value : in System.Address) return SDL.Video.Windows.ID is
       (SDL.Video.Windows.ID (Raw_Video.Get_Window_ID (To_Window_Pointer (Value))));

   function SDL_Get_Renderer_Properties
     (Value : in System.Address) return SDL.Properties.Property_ID is
       (SDL.Properties.Property_ID (Raw_Render.Get_Renderer_Properties (Value)));

   function SDL_Get_GPU_Renderer_Device
     (Value : in System.Address) return SDL.GPU.Device_Handle is
       (To_Device_Handle (Raw_Render.Get_GPU_Renderer_Device (Value)));

   function SDL_Create_GPU_Render_State
     (Target      : in System.Address;
      Create_Info : in System.Address) return System.Address is
       (Raw_Render.Create_GPU_Render_State (Target, Create_Info));

   procedure SDL_Destroy_GPU_Render_State
     (State : in System.Address) is
   begin
      Raw_Render.Destroy_GPU_Render_State (State);
   end SDL_Destroy_GPU_Render_State;

   function SDL_Set_GPU_Render_State_Fragment_Uniforms
     (State      : in System.Address;
      Slot_Index : in Interfaces.Unsigned_32;
      Data       : in System.Address;
      Length     : in Interfaces.Unsigned_32) return CE.bool is
       (Raw_Render.Set_GPU_Render_State_Fragment_Uniforms
          (State, Slot_Index, Data, Length));

   function SDL_Set_GPU_Render_State
     (Target : in System.Address;
      State  : in System.Address) return CE.bool is
       (Raw_Render.Set_GPU_Render_State (Target, State));

   function SDL_Get_Render_Output_Size
     (Value  : in System.Address;
      Width  : access C.int;
      Height : access C.int) return CE.bool is
       (Raw_Render.Get_Render_Output_Size (Value, Width, Height));

   function SDL_Get_Current_Render_Output_Size
     (Value  : in System.Address;
      Width  : access C.int;
      Height : access C.int) return CE.bool is
       (Raw_Render.Get_Current_Render_Output_Size (Value, Width, Height));

   function SDL_Set_Render_Target
     (Renderer : in System.Address;
      Target   : in System.Address) return CE.bool is
       (Raw_Render.Set_Render_Target (Renderer, Target));

   function SDL_Get_Render_Target
     (Renderer : in System.Address) return System.Address is
       (Raw_Render.Get_Render_Target (Renderer));

   function SDL_Set_Render_Logical_Presentation
     (Renderer : in System.Address;
      Width    : in C.int;
      Height   : in C.int;
      Mode     : in Logical_Presentations) return CE.bool is
       (Raw_Render.Set_Render_Logical_Presentation
          (Renderer, Width, Height, To_Raw (Mode)));

   function SDL_Get_Render_Logical_Presentation
     (Renderer : in System.Address;
      Width    : access C.int;
      Height   : access C.int;
      Mode     : access Logical_Presentations) return CE.bool
   is
      Raw_Mode : aliased Raw_Render.Logical_Presentation :=
        To_Raw (Logical_Presentation_Disabled);
      Success  : constant CE.bool :=
        Raw_Render.Get_Render_Logical_Presentation
          (Renderer, Width, Height, Raw_Mode'Access);
   begin
      if Boolean (Success) then
         Mode.all := To_Public (Raw_Mode);
      end if;

      return Success;
   end SDL_Get_Render_Logical_Presentation;

   function SDL_Get_Render_Logical_Presentation_Rect
     (Renderer  : in System.Address;
      Rectangle : access SDL.Video.Rectangles.Float_Rectangle) return CE.bool is
       (Raw_Render.Get_Render_Logical_Presentation_Rect
          (Renderer, To_Address (Rectangle)));

   function SDL_Render_Coordinates_From_Window
     (Renderer : in System.Address;
      Window_X : in Float;
      Window_Y : in Float;
      X        : access Float;
      Y        : access Float) return CE.bool
   is
      Raw_X : aliased C.C_float := 0.0;
      Raw_Y : aliased C.C_float := 0.0;
      Success : constant CE.bool :=
        Raw_Render.Render_Coordinates_From_Window
          (Renderer,
           C.C_float (Window_X),
           C.C_float (Window_Y),
           Raw_X'Access,
           Raw_Y'Access);
   begin
      if Boolean (Success) then
         X.all := Float (Raw_X);
         Y.all := Float (Raw_Y);
      end if;

      return Success;
   end SDL_Render_Coordinates_From_Window;

   function SDL_Render_Coordinates_To_Window
     (Renderer : in System.Address;
      X        : in Float;
      Y        : in Float;
      Window_X : access Float;
      Window_Y : access Float) return CE.bool
   is
      Raw_X : aliased C.C_float := 0.0;
      Raw_Y : aliased C.C_float := 0.0;
      Success : constant CE.bool :=
        Raw_Render.Render_Coordinates_To_Window
          (Renderer,
           C.C_float (X),
           C.C_float (Y),
           Raw_X'Access,
           Raw_Y'Access);
   begin
      if Boolean (Success) then
         Window_X.all := Float (Raw_X);
         Window_Y.all := Float (Raw_Y);
      end if;

      return Success;
   end SDL_Render_Coordinates_To_Window;

   function SDL_Convert_Event_To_Render_Coordinates
     (Renderer : in System.Address;
      Event    : access SDL.Events.Events.Events) return CE.bool is
       (Raw_Render.Convert_Event_To_Render_Coordinates
          (Renderer, To_Address (Event)));

   function SDL_Set_Render_Viewport
     (Renderer : in System.Address;
      Rect     : in System.Address) return CE.bool is
       (Raw_Render.Set_Render_Viewport (Renderer, Rect));

   function SDL_Get_Render_Viewport
     (Renderer : in System.Address;
      Rect     : access SDL.Video.Rectangles.Rectangle) return CE.bool is
       (Raw_Render.Get_Render_Viewport (Renderer, To_Address (Rect)));

   function SDL_Render_Viewport_Set
     (Renderer : in System.Address) return CE.bool is
       (Raw_Render.Render_Viewport_Set (Renderer));

   function SDL_Get_Render_Safe_Area
     (Renderer : in System.Address;
      Rect     : access SDL.Video.Rectangles.Rectangle) return CE.bool is
       (Raw_Render.Get_Render_Safe_Area (Renderer, To_Address (Rect)));

   function SDL_Set_Render_Clip_Rect
     (Renderer : in System.Address;
      Rect     : in System.Address) return CE.bool is
       (Raw_Render.Set_Render_Clip_Rect (Renderer, Rect));

   function SDL_Get_Render_Clip_Rect
     (Renderer : in System.Address;
      Rect     : access SDL.Video.Rectangles.Rectangle) return CE.bool is
       (Raw_Render.Get_Render_Clip_Rect (Renderer, To_Address (Rect)));

   function SDL_Render_Clip_Enabled
     (Renderer : in System.Address) return CE.bool is
       (Raw_Render.Render_Clip_Enabled (Renderer));

   function SDL_Set_Render_Scale
     (Renderer : in System.Address;
      Scale_X  : in Float;
      Scale_Y  : in Float) return CE.bool is
       (Raw_Render.Set_Render_Scale
          (Renderer, C.C_float (Scale_X), C.C_float (Scale_Y)));

   function SDL_Get_Render_Scale
     (Renderer : in System.Address;
      Scale_X  : access Float;
      Scale_Y  : access Float) return CE.bool
   is
      Raw_X : aliased C.C_float := 0.0;
      Raw_Y : aliased C.C_float := 0.0;
      Success : constant CE.bool :=
        Raw_Render.Get_Render_Scale (Renderer, Raw_X'Access, Raw_Y'Access);
   begin
      if Boolean (Success) then
         Scale_X.all := Float (Raw_X);
         Scale_Y.all := Float (Raw_Y);
      end if;

      return Success;
   end SDL_Get_Render_Scale;

   function SDL_Get_Render_Draw_Blend_Mode
     (Renderer : in System.Address;
      Mode     : access SDL.Video.Blend_Modes) return CE.bool
   is
      Raw_Mode : aliased Raw_Render.Blend_Mode := To_Raw (SDL.Video.None);
      Success  : constant CE.bool :=
        Raw_Render.Get_Render_Draw_Blend_Mode (Renderer, Raw_Mode'Access);
   begin
      if Boolean (Success) then
         Mode.all := To_Public (Raw_Mode);
      end if;

      return Success;
   end SDL_Get_Render_Draw_Blend_Mode;

   function SDL_Set_Render_Draw_Blend_Mode
     (Renderer : in System.Address;
      Mode     : in SDL.Video.Blend_Modes) return CE.bool is
       (Raw_Render.Set_Render_Draw_Blend_Mode (Renderer, To_Raw (Mode)));

   function SDL_Get_Render_Draw_Color
     (Renderer : in System.Address;
      Red      : access SDL.Video.Palettes.Colour_Component;
      Green    : access SDL.Video.Palettes.Colour_Component;
      Blue     : access SDL.Video.Palettes.Colour_Component;
      Alpha    : access SDL.Video.Palettes.Colour_Component) return CE.bool is
       (Raw_Render.Get_Render_Draw_Color (Renderer, Red, Green, Blue, Alpha));

   function SDL_Get_Render_Draw_Color_Float
     (Renderer : in System.Address;
      Red      : access Float;
      Green    : access Float;
      Blue     : access Float;
      Alpha    : access Float) return CE.bool
   is
      Raw_Red   : aliased C.C_float := 0.0;
      Raw_Green : aliased C.C_float := 0.0;
      Raw_Blue  : aliased C.C_float := 0.0;
      Raw_Alpha : aliased C.C_float := 0.0;
      Success   : constant CE.bool :=
        Raw_Render.Get_Render_Draw_Color_Float
          (Renderer,
           Raw_Red'Access,
           Raw_Green'Access,
           Raw_Blue'Access,
           Raw_Alpha'Access);
   begin
      if Boolean (Success) then
         Red.all := Float (Raw_Red);
         Green.all := Float (Raw_Green);
         Blue.all := Float (Raw_Blue);
         Alpha.all := Float (Raw_Alpha);
      end if;

      return Success;
   end SDL_Get_Render_Draw_Color_Float;

   function SDL_Set_Render_Draw_Color
     (Renderer : in System.Address;
      Red      : in SDL.Video.Palettes.Colour_Component;
      Green    : in SDL.Video.Palettes.Colour_Component;
      Blue     : in SDL.Video.Palettes.Colour_Component;
      Alpha    : in SDL.Video.Palettes.Colour_Component) return CE.bool is
       (Raw_Render.Set_Render_Draw_Color (Renderer, Red, Green, Blue, Alpha));

   function SDL_Set_Render_Draw_Color_Float
     (Renderer : in System.Address;
      Red      : in Float;
      Green    : in Float;
      Blue     : in Float;
      Alpha    : in Float) return CE.bool is
       (Raw_Render.Set_Render_Draw_Color_Float
          (Renderer,
           C.C_float (Red),
           C.C_float (Green),
           C.C_float (Blue),
           C.C_float (Alpha)));

   function SDL_Get_Render_Color_Scale
     (Renderer : in System.Address;
      Scale    : access Float) return CE.bool
   is
      Raw_Scale : aliased C.C_float := 0.0;
      Success   : constant CE.bool :=
        Raw_Render.Get_Render_Color_Scale (Renderer, Raw_Scale'Access);
   begin
      if Boolean (Success) then
         Scale.all := Float (Raw_Scale);
      end if;

      return Success;
   end SDL_Get_Render_Color_Scale;

   function SDL_Set_Render_Color_Scale
     (Renderer : in System.Address;
      Scale    : in Float) return CE.bool is
       (Raw_Render.Set_Render_Color_Scale (Renderer, C.C_float (Scale)));

   function SDL_Render_Clear
     (Value : in System.Address) return CE.bool is
       (Raw_Render.Render_Clear (Value));

   function SDL_Render_Point
     (Renderer : in System.Address;
      X        : in Float;
      Y        : in Float) return CE.bool is
       (Raw_Render.Render_Point
          (Renderer, C.C_float (X), C.C_float (Y)));

   function SDL_Render_Points
     (Renderer : in System.Address;
      Points   : access constant SDL.Video.Rectangles.Float_Point;
      Count    : in C.int) return CE.bool is
       (Raw_Render.Render_Points (Renderer, To_Address (Points), Count));

   function SDL_Render_Lines
     (Renderer : in System.Address;
      Points   : access constant SDL.Video.Rectangles.Float_Point;
      Count    : in C.int) return CE.bool is
       (Raw_Render.Render_Lines (Renderer, To_Address (Points), Count));

   function SDL_Render_Line
     (Renderer : in System.Address;
      X1       : in Float;
      Y1       : in Float;
      X2       : in Float;
      Y2       : in Float) return CE.bool is
       (Raw_Render.Render_Line
          (Renderer,
           C.C_float (X1),
           C.C_float (Y1),
           C.C_float (X2),
           C.C_float (Y2)));

   function SDL_Render_Rect
     (Renderer : in System.Address;
      Rect     : access constant SDL.Video.Rectangles.Float_Rectangle)
      return CE.bool is
       (Raw_Render.Render_Rect (Renderer, To_Address (Rect)));

   function SDL_Render_Rects
     (Renderer : in System.Address;
      Rects    : access constant SDL.Video.Rectangles.Float_Rectangle;
      Count    : in C.int) return CE.bool is
       (Raw_Render.Render_Rects (Renderer, To_Address (Rects), Count));

   function SDL_Render_Fill_Rect
     (Renderer : in System.Address;
      Rect     : access constant SDL.Video.Rectangles.Float_Rectangle)
      return CE.bool is
       (Raw_Render.Render_Fill_Rect (Renderer, To_Address (Rect)));

   function SDL_Render_Fill_Rects
     (Renderer : in System.Address;
      Rects    : access constant SDL.Video.Rectangles.Float_Rectangle;
      Count    : in C.int) return CE.bool is
       (Raw_Render.Render_Fill_Rects (Renderer, To_Address (Rects), Count));

   function SDL_Render_Texture
     (Renderer : in System.Address;
      Texture  : in System.Address;
      Source   : in System.Address;
      Target   : in System.Address) return CE.bool is
       (Raw_Render.Render_Texture (Renderer, Texture, Source, Target));

   function SDL_Render_Texture_Rotated
     (Renderer : in System.Address;
      Texture  : in System.Address;
      Source   : in System.Address;
      Target   : in System.Address;
      Angle    : in C.double;
      Centre   : in System.Address;
      Flip     : in Flip_Modes) return CE.bool is
       (Raw_Render.Render_Texture_Rotated
          (Renderer,
           Texture,
           Source,
           Target,
           Angle,
           Centre,
           To_Raw (Flip)));

   function SDL_Render_Texture_Affine
     (Renderer : in System.Address;
      Texture  : in System.Address;
      Source   : in System.Address;
      Origin   : in System.Address;
      Right    : in System.Address;
      Down     : in System.Address) return CE.bool is
       (Raw_Render.Render_Texture_Affine
          (Renderer, Texture, Source, Origin, Right, Down));

   function SDL_Render_Texture_Tiled
     (Renderer : in System.Address;
      Texture  : in System.Address;
      Source   : in System.Address;
      Scale    : in Float;
      Target   : in System.Address) return CE.bool is
       (Raw_Render.Render_Texture_Tiled
          (Renderer, Texture, Source, C.C_float (Scale), Target));

   function SDL_Render_Texture_9_Grid
     (Renderer      : in System.Address;
      Texture       : in System.Address;
      Source        : in System.Address;
      Left_Width    : in Float;
      Right_Width   : in Float;
      Top_Height    : in Float;
      Bottom_Height : in Float;
      Scale         : in Float;
      Target        : in System.Address) return CE.bool is
       (Raw_Render.Render_Texture_9_Grid
          (Renderer,
           Texture,
           Source,
           C.C_float (Left_Width),
           C.C_float (Right_Width),
           C.C_float (Top_Height),
           C.C_float (Bottom_Height),
           C.C_float (Scale),
           Target));

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
      Tile_Scale    : in Float) return CE.bool is
       (Raw_Render.Render_Texture_9_Grid_Tiled
          (Renderer,
           Texture,
           Source,
           C.C_float (Left_Width),
           C.C_float (Right_Width),
           C.C_float (Top_Height),
           C.C_float (Bottom_Height),
           C.C_float (Scale),
           Target,
           C.C_float (Tile_Scale)));

   function SDL_Render_Geometry
     (Renderer    : in System.Address;
      Texture     : in System.Address;
      Vertex_Data : access constant SDL.Video.Renderers.Vertices;
      Count       : in C.int;
      Indices     : in System.Address;
      I_Count     : in C.int) return CE.bool is
       (Raw_Render.Render_Geometry
          (Renderer,
           Texture,
           To_Address (Vertex_Data),
           Count,
           Indices,
           I_Count));

   function SDL_Set_Render_Texture_Address_Mode
     (Renderer : in System.Address;
      U_Mode   : in Texture_Address_Modes;
      V_Mode   : in Texture_Address_Modes) return CE.bool is
       (Raw_Render.Set_Render_Texture_Address_Mode
          (Renderer, To_Raw (U_Mode), To_Raw (V_Mode)));

   function SDL_Get_Render_Texture_Address_Mode
     (Renderer : in System.Address;
      U_Mode   : access Texture_Address_Modes;
      V_Mode   : access Texture_Address_Modes) return CE.bool
   is
      Raw_U   : aliased Raw_Render.Texture_Address_Mode :=
        To_Raw (Automatic_Addressing);
      Raw_V   : aliased Raw_Render.Texture_Address_Mode :=
        To_Raw (Automatic_Addressing);
      Success : constant CE.bool :=
        Raw_Render.Get_Render_Texture_Address_Mode
          (Renderer, Raw_U'Access, Raw_V'Access);
   begin
      if Boolean (Success) then
         U_Mode.all := To_Public (Raw_U);
         V_Mode.all := To_Public (Raw_V);
      end if;

      return Success;
   end SDL_Get_Render_Texture_Address_Mode;

   function SDL_Render_Read_Pixels
     (Renderer : in System.Address;
      Area     : in System.Address)
      return SDL.Video.Surfaces.Internal_Surface_Pointer is
       (To_Internal_Surface_Pointer
          (Raw_Render.Render_Read_Pixels (Renderer, Area)));

   function SDL_Render_Present
     (Value : in System.Address) return CE.bool is
       (Raw_Render.Render_Present (Value));

   function SDL_Flush_Renderer
     (Renderer : in System.Address) return CE.bool is
       (Raw_Render.Flush_Renderer (Renderer));

   function SDL_Get_Render_Metal_Layer
     (Renderer : in System.Address) return System.Address is
       (Raw_Render.Get_Render_Metal_Layer (Renderer));

   function SDL_Get_Render_Metal_Command_Encoder
     (Renderer : in System.Address) return System.Address is
       (Raw_Render.Get_Render_Metal_Command_Encoder (Renderer));

   function SDL_Add_Vulkan_Render_Semaphores
     (Renderer         : in System.Address;
      Wait_Stage_Mask  : in Vulkan_Wait_Stage_Masks;
      Wait_Semaphore   : in Vulkan_Semaphores;
      Signal_Semaphore : in Vulkan_Semaphores) return CE.bool is
       (Raw_Render.Add_Vulkan_Render_Semaphores
          (Renderer,
           Raw_Render.Vulkan_Wait_Stage_Mask (Wait_Stage_Mask),
           Raw_Render.Vulkan_Semaphore (Wait_Semaphore),
           Raw_Render.Vulkan_Semaphore (Signal_Semaphore)));

   function SDL_Set_Render_VSync
     (Renderer : in System.Address;
      Value    : in C.int) return CE.bool is
       (Raw_Render.Set_Render_VSync (Renderer, Value));

   function SDL_Get_Render_VSync
     (Renderer : in System.Address;
      Value    : access C.int) return CE.bool is
       (Raw_Render.Get_Render_VSync (Renderer, Value));

   function SDL_Render_Debug_Text
     (Renderer : in System.Address;
      X        : in Float;
      Y        : in Float;
      Text     : in C.char_array) return CE.bool is
       (Raw_Render.Render_Debug_Text
          (Renderer, C.C_float (X), C.C_float (Y), Text));

   function SDL_Set_Default_Texture_Scale_Mode
     (Renderer : in System.Address;
      Mode     : in SDL.Video.Textures.Scale_Modes) return CE.bool is
       (Raw_Render.Set_Default_Texture_Scale_Mode
          (Renderer, To_Raw (Mode)));

   function SDL_Get_Default_Texture_Scale_Mode
     (Renderer : in System.Address;
      Mode     : access SDL.Video.Textures.Scale_Modes) return CE.bool
   is
      Raw_Mode : aliased Raw_Render.Texture_Scale_Mode :=
        To_Raw (SDL.Video.Textures.Invalid);
      Success  : constant CE.bool :=
        Raw_Render.Get_Default_Texture_Scale_Mode
          (Renderer, Raw_Mode'Access);
   begin
      if Boolean (Success) then
         Mode.all := To_Public (Raw_Mode);
      end if;

      return Success;
   end SDL_Get_Default_Texture_Scale_Mode;

   procedure SDL_Destroy_Renderer
     (Value : in System.Address) is
   begin
      Raw_Render.Destroy_Renderer (Value);
   end SDL_Destroy_Renderer;

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
      Count : constant C.int := SDL_Get_Num_Render_Drivers;
   begin
      if Count <= 0 then
         return 0;
      end if;

      return Natural (Count);
   end Total_Drivers;

   function Driver_Name (Driver : in Driver_Indices) return String is
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
   begin
      Require_Renderer (Self);
      return SDL_Get_Renderer_Properties (Self.Internal);
   end Get_Properties;

   function Get_GPU_Device
     (Self : in Renderer) return SDL.GPU.Device
   is
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
        SDL_Create_GPU_Render_State (Renderer.Internal, Raw_Create_Info'Address);

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
   begin
      Require_Renderer (Self);
      Require_GPU_Render_State (State);

      if not Boolean (SDL_Set_GPU_Render_State (Self.Internal, State.Internal)) then
         Raise_Renderer_Error ("SDL_SetGPURenderState failed");
      end if;
   end Set_GPU_Render_State;

   procedure Reset_GPU_Render_State (Self : in out Renderer) is
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
   begin
      Require_Renderer (Self);
      return Boolean (SDL_Render_Viewport_Set (Self.Internal));
   end Is_Viewport_Set;

   function Get_Safe_Area
     (Self : in Renderer) return SDL.Video.Rectangles.Rectangle
   is
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
   begin
      Require_Renderer (Self);
      return Boolean (SDL_Render_Clip_Enabled (Self.Internal));
   end Is_Clip_Enabled;

   procedure Set_Scale
     (Self    : in out Renderer;
      Scale_X : in Float;
      Scale_Y : in Float)
   is
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
   begin
      Require_Renderer (Self);

      if not Boolean
          (SDL_Set_Render_Color_Scale (Self.Internal, Scale))
      then
         Raise_Renderer_Error;
      end if;
   end Set_Colour_Scale;

   procedure Clear (Self : in out Renderer) is
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
   begin
      Require_Renderer (Self);

      if not Boolean (SDL_Render_Present (Self.Internal)) then
         Raise_Renderer_Error;
      end if;
   end Present;

   procedure Flush (Self : in out Renderer) is
   begin
      Require_Renderer (Self);

      if not Boolean (SDL_Flush_Renderer (Self.Internal)) then
         Raise_Renderer_Error;
      end if;
   end Flush;

   function Get_Metal_Layer
     (Self : in Renderer) return System.Address
   is
   begin
      Require_Renderer (Self);
      return SDL_Get_Render_Metal_Layer (Self.Internal);
   end Get_Metal_Layer;

   function Get_Metal_Command_Encoder
     (Self : in Renderer) return System.Address
   is
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
   begin
      Require_Renderer (Self);

      if not Boolean
          (SDL_Set_Render_VSync (Self.Internal, C.int (Value)))
      then
         Raise_Renderer_Error;
      end if;
   end Set_V_Sync;

   function Get_V_Sync (Self : in Renderer) return Integer is
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
   begin
      if Self.Owns and then Self.Internal /= System.Null_Address then
         SDL_Destroy_Renderer (Self.Internal);
         Self.Internal := System.Null_Address;
      end if;
   end Finalize;
end SDL.Video.Renderers;
