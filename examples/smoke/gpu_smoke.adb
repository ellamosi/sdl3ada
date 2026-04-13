with Ada.Characters.Latin_1; use Ada.Characters.Latin_1;
with Ada.Exceptions;
with Ada.Numerics;
with Ada.Numerics.Elementary_Functions;
with Ada.Streams;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Unchecked_Conversion;

with Interfaces;
with System;
with System.Address_To_Access_Conversions;

with GPU_Smoke_Shaders;
with SDL;
with SDL.Error;
with SDL.GPU;
with SDL.Properties;
with SDL.Video;
with SDL.Video.Pixel_Formats;
with SDL.Video.Renderers;
with SDL.Video.Renderers.Makers;
with SDL.Video.Windows;
with SDL.Video.Windows.Makers;

procedure GPU_Smoke is
   use type Interfaces.Unsigned_32;
   use type SDL.GPU.Shader_Formats;
   use type SDL.GPU.Texture_Formats;
   use type SDL.Init_Flags;
   use type SDL.Video.Pixel_Formats.Pixel_Format_Names;
   use type SDL.Video.Windows.Window_Flags;
   use type Ada.Streams.Stream_Element_Offset;
   use type System.Address;

   type Byte_Array is array (Interfaces.Unsigned_32 range 0 .. 3) of aliased
     Interfaces.Unsigned_8;

   Cube_Target_Dimension     : constant Natural := 32;
   Cube_Target_Dimension_U32 : constant Interfaces.Unsigned_32 :=
     Interfaces.Unsigned_32 (Cube_Target_Dimension);
   Cube_Target_Byte_Count    : constant Natural :=
     Cube_Target_Dimension * Cube_Target_Dimension * 4;

   type Cube_Vertex is record
      X, Y, Z          : Float;
      Red, Green, Blue : Float;
   end record
   with Convention => C;

   type Cube_Vertex_Array is array (Natural range 0 .. 35) of aliased Cube_Vertex
   with Convention => C;

   Cube_Vertices : constant Cube_Vertex_Array :=
     (0  => (X => -0.5, Y =>  0.5, Z => -0.5, Red => 1.0, Green => 0.0, Blue => 0.0),
      1  => (X =>  0.5, Y => -0.5, Z => -0.5, Red => 0.0, Green => 0.0, Blue => 1.0),
      2  => (X => -0.5, Y => -0.5, Z => -0.5, Red => 0.0, Green => 1.0, Blue => 0.0),
      3  => (X => -0.5, Y =>  0.5, Z => -0.5, Red => 1.0, Green => 0.0, Blue => 0.0),
      4  => (X =>  0.5, Y =>  0.5, Z => -0.5, Red => 1.0, Green => 1.0, Blue => 0.0),
      5  => (X =>  0.5, Y => -0.5, Z => -0.5, Red => 0.0, Green => 0.0, Blue => 1.0),
      6  => (X => -0.5, Y =>  0.5, Z =>  0.5, Red => 1.0, Green => 1.0, Blue => 1.0),
      7  => (X => -0.5, Y => -0.5, Z => -0.5, Red => 0.0, Green => 1.0, Blue => 0.0),
      8  => (X => -0.5, Y => -0.5, Z =>  0.5, Red => 0.0, Green => 1.0, Blue => 1.0),
      9  => (X => -0.5, Y =>  0.5, Z =>  0.5, Red => 1.0, Green => 1.0, Blue => 1.0),
      10 => (X => -0.5, Y =>  0.5, Z => -0.5, Red => 1.0, Green => 0.0, Blue => 0.0),
      11 => (X => -0.5, Y => -0.5, Z => -0.5, Red => 0.0, Green => 1.0, Blue => 0.0),
      12 => (X => -0.5, Y =>  0.5, Z =>  0.5, Red => 1.0, Green => 1.0, Blue => 1.0),
      13 => (X =>  0.5, Y =>  0.5, Z => -0.5, Red => 1.0, Green => 1.0, Blue => 0.0),
      14 => (X => -0.5, Y =>  0.5, Z => -0.5, Red => 1.0, Green => 0.0, Blue => 0.0),
      15 => (X => -0.5, Y =>  0.5, Z =>  0.5, Red => 1.0, Green => 1.0, Blue => 1.0),
      16 => (X =>  0.5, Y =>  0.5, Z =>  0.5, Red => 0.0, Green => 0.0, Blue => 0.0),
      17 => (X =>  0.5, Y =>  0.5, Z => -0.5, Red => 1.0, Green => 1.0, Blue => 0.0),
      18 => (X =>  0.5, Y =>  0.5, Z => -0.5, Red => 1.0, Green => 1.0, Blue => 0.0),
      19 => (X =>  0.5, Y => -0.5, Z =>  0.5, Red => 1.0, Green => 0.0, Blue => 1.0),
      20 => (X =>  0.5, Y => -0.5, Z => -0.5, Red => 0.0, Green => 0.0, Blue => 1.0),
      21 => (X =>  0.5, Y =>  0.5, Z => -0.5, Red => 1.0, Green => 1.0, Blue => 0.0),
      22 => (X =>  0.5, Y =>  0.5, Z =>  0.5, Red => 0.0, Green => 0.0, Blue => 0.0),
      23 => (X =>  0.5, Y => -0.5, Z =>  0.5, Red => 1.0, Green => 0.0, Blue => 1.0),
      24 => (X =>  0.5, Y =>  0.5, Z =>  0.5, Red => 0.0, Green => 0.0, Blue => 0.0),
      25 => (X => -0.5, Y => -0.5, Z =>  0.5, Red => 0.0, Green => 1.0, Blue => 1.0),
      26 => (X =>  0.5, Y => -0.5, Z =>  0.5, Red => 1.0, Green => 0.0, Blue => 1.0),
      27 => (X =>  0.5, Y =>  0.5, Z =>  0.5, Red => 0.0, Green => 0.0, Blue => 0.0),
      28 => (X => -0.5, Y =>  0.5, Z =>  0.5, Red => 1.0, Green => 1.0, Blue => 1.0),
      29 => (X => -0.5, Y => -0.5, Z =>  0.5, Red => 0.0, Green => 1.0, Blue => 1.0),
      30 => (X => -0.5, Y => -0.5, Z => -0.5, Red => 0.0, Green => 1.0, Blue => 0.0),
      31 => (X =>  0.5, Y => -0.5, Z =>  0.5, Red => 1.0, Green => 0.0, Blue => 1.0),
      32 => (X => -0.5, Y => -0.5, Z =>  0.5, Red => 0.0, Green => 1.0, Blue => 1.0),
      33 => (X => -0.5, Y => -0.5, Z => -0.5, Red => 0.0, Green => 1.0, Blue => 0.0),
      34 => (X =>  0.5, Y => -0.5, Z => -0.5, Red => 0.0, Green => 0.0, Blue => 1.0),
      35 => (X =>  0.5, Y => -0.5, Z =>  0.5, Red => 1.0, Green => 0.0, Blue => 1.0));

   Cube_Vertex_Size : constant Interfaces.Unsigned_32 :=
     Interfaces.Unsigned_32 (Cube_Vertex'Size / System.Storage_Unit);
   Cube_Vertex_Bytes : constant Interfaces.Unsigned_32 :=
     Interfaces.Unsigned_32 (Cube_Vertices'Size / System.Storage_Unit);

   type Cube_Pixel_Buffer is
     array (Natural range 0 .. Cube_Target_Byte_Count - 1) of aliased
       Interfaces.Unsigned_8;

   type Matrix_Values is array (Natural range 0 .. 15) of Float
   with Convention => C;

   subtype Matrix_Uniform_Bytes is Ada.Streams.Stream_Element_Array (1 .. 64);

   Identity_Tint : constant Ada.Streams.Stream_Element_Array (1 .. 16) :=
     (1  => 16#00#, 2  => 16#00#, 3  => 16#80#, 4  => 16#3F#,
      5  => 16#00#, 6  => 16#00#, 7  => 16#80#, 8  => 16#3F#,
      9  => 16#00#, 10 => 16#00#, 11 => 16#80#, 12 => 16#3F#,
      13 => 16#00#, 14 => 16#00#, 15 => 16#80#, 16 => 16#3F#);

   MSL_Vertex_Shader_Source : constant String :=
     "#include <metal_stdlib>" & LF &
     "using namespace metal;" & LF &
     LF &
     "struct Vertex_Output {" & LF &
     "    float4 position [[position]];" & LF &
     "    float2 uv;" & LF &
     "};" & LF &
     LF &
     "vertex Vertex_Output main0(uint vertex_id [[vertex_id]]) {" & LF &
     "    const float2 positions[3] = {" & LF &
     "        float2(-1.0, -1.0)," & LF &
     "        float2( 3.0, -1.0)," & LF &
     "        float2(-1.0,  3.0)" & LF &
     "    };" & LF &
     "    const float2 uvs[3] = {" & LF &
     "        float2(0.0, 0.0)," & LF &
     "        float2(2.0, 0.0)," & LF &
     "        float2(0.0, 2.0)" & LF &
     "    };" & LF &
     LF &
     "    Vertex_Output result;" & LF &
     "    result.position = float4(positions[vertex_id], 0.0, 1.0);" & LF &
     "    result.uv = uvs[vertex_id];" & LF &
     "    return result;" & LF &
     "}" & LF;

   MSL_Fragment_Shader_Source : constant String :=
     "#include <metal_stdlib>" & LF &
     "using namespace metal;" & LF &
     LF &
     "struct Vertex_Output {" & LF &
     "    float4 position [[position]];" & LF &
     "    float2 uv;" & LF &
     "};" & LF &
     LF &
     "struct Fragment_Uniforms {" & LF &
     "    float4 tint;" & LF &
     "};" & LF &
     LF &
     "fragment float4 main1(Vertex_Output input [[stage_in]]," & LF &
     "                      texture2d<float> source_texture [[texture(0)]]," & LF &
     "                      sampler source_sampler [[sampler(0)]]," & LF &
     "                      constant Fragment_Uniforms &uniforms [[buffer(0)]]) {" & LF &
     "    return source_texture.sample(source_sampler, input.uv) * uniforms.tint;" & LF &
     "}" & LF;

   package Byte_Array_Conversions is new System.Address_To_Access_Conversions
     (Byte_Array);
   package Cube_Vertex_Array_Conversions is new
     System.Address_To_Access_Conversions (Cube_Vertex_Array);
   package Cube_Pixel_Buffer_Conversions is new
     System.Address_To_Access_Conversions (Cube_Pixel_Buffer);

   use type Byte_Array_Conversions.Object_Pointer;
   use type Cube_Pixel_Buffer_Conversions.Object_Pointer;
   use type Cube_Vertex_Array_Conversions.Object_Pointer;
   use type Interfaces.Unsigned_8;

   function To_Uniform_Data is new Ada.Unchecked_Conversion
     (Matrix_Values, Matrix_Uniform_Bytes);

   function Is_Headless_Driver (Driver : in String) return Boolean is
     (Driver = "" or else Driver = "dummy" or else Driver = "offscreen");

   procedure Require (Condition : in Boolean; Message : in String) is
   begin
      if not Condition then
         raise Program_Error with Message;
      end if;
   end Require;

   procedure Require_Bytes
     (Label    : in String;
      Actual   : in System.Address;
      Expected : in Byte_Array)
   is
      Bytes : constant Byte_Array_Conversions.Object_Pointer :=
        Byte_Array_Conversions.To_Pointer (Actual);
   begin
      Require (Actual /= System.Null_Address, Label & " returned a null mapping");
      Require (Bytes /= null, Label & " produced a null typed view");

      for Index in Expected'Range loop
         Require
           (Bytes.all (Index) = Expected (Index),
            Label & " byte mismatch at index" & Interfaces.Unsigned_32'Image (Index));
      end loop;
   end Require_Bytes;

   procedure Write_Bytes
     (Target : in System.Address;
      Value  : in Byte_Array)
   is
      Bytes : constant Byte_Array_Conversions.Object_Pointer :=
        Byte_Array_Conversions.To_Pointer (Target);
   begin
      Require (Target /= System.Null_Address, "Expected a valid GPU transfer mapping");
      Require (Bytes /= null, "Expected a typed view for mapped GPU transfer data");
      Bytes.all := Value;
   end Write_Bytes;

   procedure Write_Cube_Vertices (Target : in System.Address) is
      Vertices : constant Cube_Vertex_Array_Conversions.Object_Pointer :=
        Cube_Vertex_Array_Conversions.To_Pointer (Target);
   begin
      Require
        (Target /= System.Null_Address,
         "Expected a valid GPU transfer mapping for cube vertices");
      Require (Vertices /= null, "Expected a typed view for cube vertex data");
      Vertices.all := Cube_Vertices;
   end Write_Cube_Vertices;

   procedure Require_Cube_Render (Actual : in System.Address) is
      Pixels : constant Cube_Pixel_Buffer_Conversions.Object_Pointer :=
        Cube_Pixel_Buffer_Conversions.To_Pointer (Actual);
      Center : constant Natural := Cube_Target_Dimension / 2;
      Drawn  : Natural := 0;

      function Alpha_At (X, Y : in Natural) return Interfaces.Unsigned_8 is
        (Pixels.all (((Y * Cube_Target_Dimension) + X) * 4 + 3));
   begin
      Require
        (Actual /= System.Null_Address,
         "GPU spinning cube returned a null download mapping");
      Require (Pixels /= null, "GPU spinning cube produced a null typed view");

      for Y in 0 .. Cube_Target_Dimension - 1 loop
         for X in 0 .. Cube_Target_Dimension - 1 loop
            if Alpha_At (X, Y) /= 0 then
               Drawn := Drawn + 1;
            end if;
         end loop;
      end loop;

      Require (Drawn > 0, "Expected spinning cube smoke to draw at least one pixel");
      Require
        (Drawn < Cube_Target_Dimension * Cube_Target_Dimension,
         "Expected spinning cube smoke not to cover the whole target");
      Require
        (Alpha_At (Center, Center) /= 0,
         "Expected spinning cube smoke to affect the center pixel");
      Require
        (Alpha_At (0, 0) = 0,
         "Expected spinning cube smoke to preserve the cleared corner pixel");
   end Require_Cube_Render;

   function Supports_Format
     (Supported : in SDL.GPU.Shader_Formats;
     Desired   : in SDL.GPU.Shader_Formats) return Boolean
   is
     ((Supported and Desired) = Desired);

   function To_Stream_Elements
     (Text : in String) return Ada.Streams.Stream_Element_Array
   is
      Result : Ada.Streams.Stream_Element_Array
        (1 .. Ada.Streams.Stream_Element_Offset (Text'Length));
      Offset : Ada.Streams.Stream_Element_Offset := Result'First;
   begin
      for Character_Of of Text loop
         Result (Offset) := Ada.Streams.Stream_Element (Character'Pos (Character_Of));
         Offset := Offset + Ada.Streams.Stream_Element_Offset (1);
      end loop;

      return Result;
   end To_Stream_Elements;

   function Rotate_Matrix
     (Angle, X, Y, Z : in Float) return Matrix_Values
   is
      use Ada.Numerics.Elementary_Functions;

      Result  : Matrix_Values := (others => 0.0);
      Radians : constant Float := Angle * Ada.Numerics.Pi / 180.0;
      Cosine  : constant Float := Cos (Radians);
      Sine    : constant Float := Sin (Radians);
      One_Minus_Cosine : constant Float := 1.0 - Cosine;
      Length  : constant Float := Sqrt ((X * X) + (Y * Y) + (Z * Z));
      Unit_X  : constant Float := X / Length;
      Unit_Y  : constant Float := Y / Length;
      Unit_Z  : constant Float := Z / Length;
   begin
      Result (15) := 1.0;

      Result (1)  := Unit_Z * Sine;
      Result (2)  := -Unit_Y * Sine;
      Result (6)  := Unit_X * Sine;
      Result (4)  := -Unit_Z * Sine;
      Result (8)  := Unit_Y * Sine;
      Result (9)  := -Unit_X * Sine;

      for I in 0 .. 2 loop
         for J in 0 .. 2 loop
            declare
               Left  : constant Float :=
                 (case I is
                     when 0 => Unit_X,
                     when 1 => Unit_Y,
                     when others => Unit_Z);
               Right : constant Float :=
                 (case J is
                     when 0 => Unit_X,
                     when 1 => Unit_Y,
                     when others => Unit_Z);
            begin
               Result ((I * 4) + J) :=
                 Result ((I * 4) + J)
                 + (One_Minus_Cosine * Left * Right)
                 + (if I = J then Cosine else 0.0);
            end;
         end loop;
      end loop;

      return Result;
   end Rotate_Matrix;

   function Perspective_Matrix
     (Field_Of_View, Aspect, Near_Plane, Far_Plane : in Float)
      return Matrix_Values
   is
      use Ada.Numerics.Elementary_Functions;

      Result : Matrix_Values := (others => 0.0);
      Focal  : constant Float :=
        1.0 / Tan ((Field_Of_View / 180.0) * Ada.Numerics.Pi * 0.5);
   begin
      Result (0)  := Focal / Aspect;
      Result (5)  := Focal;
      Result (10) := (Near_Plane + Far_Plane) / (Near_Plane - Far_Plane);
      Result (11) := -1.0;
      Result (14) :=
        (2.0 * Near_Plane * Far_Plane) / (Near_Plane - Far_Plane);
      return Result;
   end Perspective_Matrix;

   function Multiply_Matrices
     (Left, Right : in Matrix_Values) return Matrix_Values
   is
      Result : Matrix_Values := (others => 0.0);
   begin
      for I in 0 .. 3 loop
         for J in 0 .. 3 loop
            for K in 0 .. 3 loop
               Result ((J * 4) + I) :=
                 Result ((J * 4) + I)
                 + (Left ((K * 4) + I) * Right ((J * 4) + K));
            end loop;
         end loop;
      end loop;

      return Result;
   end Multiply_Matrices;

   function Cube_Transform return Matrix_Values is
      Model_View : Matrix_Values := Rotate_Matrix (30.0, 1.0, 0.0, 0.0);
      Perspective : constant Matrix_Values :=
        Perspective_Matrix (45.0, 1.0, 0.01, 100.0);
   begin
      Model_View := Multiply_Matrices
        (Rotate_Matrix (45.0, 0.0, 1.0, 0.0), Model_View);
      Model_View := Multiply_Matrices
        (Rotate_Matrix (20.0, 0.0, 0.0, 1.0), Model_View);
      Model_View (14) := Model_View (14) - 2.5;
      return Multiply_Matrices (Perspective, Model_View);
   end Cube_Transform;

   function Window_Flags_For
     (Driver : in String) return SDL.Video.Windows.Window_Flags
   is
      Flags : SDL.Video.Windows.Window_Flags := SDL.Video.Windows.Hidden;
   begin
      if Driver = "metal" then
         Flags := Flags or SDL.Video.Windows.Metal;
      elsif Driver = "vulkan" then
         Flags := Flags or SDL.Video.Windows.Vulkan;
      end if;

      return Flags;
   end Window_Flags_For;

   procedure Run_Resource_Roundtrip
     (Device : in SDL.GPU.Device)
   is
      Expected : constant Byte_Array :=
        (0 => 16#12#, 1 => 16#34#, 2 => 16#56#, 3 => 16#78#);
      Upload_Buffer          : SDL.GPU.Transfer_Buffer;
      Buffer_Download_Buffer : SDL.GPU.Transfer_Buffer;
      Texture_Download_Buffer : SDL.GPU.Transfer_Buffer;
      Source_Buffer          : SDL.GPU.Buffer;
      Copied_Buffer          : SDL.GPU.Buffer;
      Source_Texture         : SDL.GPU.Texture;
      Copied_Texture         : SDL.GPU.Texture;
      Linear_Sampler         : SDL.GPU.Sampler;
      Command                : SDL.GPU.Command_Buffer;
      Copy                   : SDL.GPU.Copy_Pass;
      Fence                  : SDL.GPU.Fence;
      Upload_Mapping         : System.Address := System.Null_Address;
      Download_Mapping       : System.Address := System.Null_Address;
      Texture_Mapping        : System.Address := System.Null_Address;
      Texture_Format         : SDL.GPU.Texture_Formats :=
        SDL.GPU.Texture_Format_From_Pixel_Format
          (SDL.Video.Pixel_Formats.Pixel_Format_RGBA_8888);
      Texture_Size           : Interfaces.Unsigned_32 := 0;
      Texture_Supported      : Boolean := False;
   begin
      SDL.GPU.Create_Transfer_Buffer
        (Upload_Buffer,
         Device,
         SDL.GPU.Upload,
         Interfaces.Unsigned_32 (Expected'Length));
      SDL.GPU.Create_Transfer_Buffer
        (Buffer_Download_Buffer,
         Device,
         SDL.GPU.Download,
         Interfaces.Unsigned_32 (Expected'Length));
      SDL.GPU.Create_Buffer
        (Source_Buffer,
         Device,
         SDL.GPU.Buffer_Usage_Vertex,
         Interfaces.Unsigned_32 (Expected'Length));
      SDL.GPU.Create_Buffer
        (Copied_Buffer,
         Device,
         SDL.GPU.Buffer_Usage_Vertex,
         Interfaces.Unsigned_32 (Expected'Length));
      SDL.GPU.Set_Name (Source_Buffer, "resource_roundtrip_source_buffer");
      SDL.GPU.Set_Name (Copied_Buffer, "resource_roundtrip_copied_buffer");

      Upload_Mapping := SDL.GPU.Map (Upload_Buffer);
      Write_Bytes (Upload_Mapping, Expected);
      SDL.GPU.Unmap (Upload_Buffer);
      Upload_Mapping := System.Null_Address;

      Texture_Supported :=
        Texture_Format /= SDL.GPU.Invalid_Texture_Format and then
        SDL.GPU.Texture_Format_Texel_Block_Size (Texture_Format) = 4 and then
        SDL.GPU.Texture_Supports_Format
          (Device,
           Texture_Format,
           SDL.GPU.Texture_2D,
           SDL.GPU.Texture_Usage_Sampler);

      if Texture_Supported then
         Texture_Size :=
           SDL.GPU.Calculate_Texture_Format_Size
             (Texture_Format, 1, 1, 1);
         Require (Texture_Size = 4, "Expected RGBA8 GPU texture size to be 4 bytes");

         SDL.GPU.Create_Transfer_Buffer
           (Texture_Download_Buffer, Device, SDL.GPU.Download, Texture_Size);
         SDL.GPU.Create_Texture
           (Source_Texture,
            Device,
            Texture_Format,
            SDL.GPU.Texture_Usage_Sampler,
            1,
            1);
         SDL.GPU.Create_Texture
           (Copied_Texture,
            Device,
            Texture_Format,
            SDL.GPU.Texture_Usage_Sampler,
            1,
            1);
         SDL.GPU.Set_Name (Source_Texture, "resource_roundtrip_source_texture");
         SDL.GPU.Set_Name (Copied_Texture, "resource_roundtrip_copied_texture");
         SDL.GPU.Create_Sampler (Linear_Sampler, Device);
      else
         Put_Line
           ("GPU texture round-trip skipped: no RGBA8 sampler texture support on this backend");
      end if;

      Command := SDL.GPU.Acquire_Command_Buffer (Device);
      SDL.GPU.Push_Debug_Group (Command, "resource_roundtrip");
      Copy := SDL.GPU.Begin_Copy_Pass (Command);

      SDL.GPU.Upload_To_Buffer
        (Copy,
         SDL.GPU.Make_Transfer_Buffer_Location (Upload_Buffer),
         SDL.GPU.Make_Buffer_Region
           (Source_Buffer, Interfaces.Unsigned_32 (Expected'Length)));
      SDL.GPU.Copy_Buffer_To_Buffer
        (Copy,
         SDL.GPU.Make_Buffer_Location (Source_Buffer),
         SDL.GPU.Make_Buffer_Location (Copied_Buffer),
         Interfaces.Unsigned_32 (Expected'Length));
      SDL.GPU.Download_From_Buffer
        (Copy,
         SDL.GPU.Make_Buffer_Region
           (Copied_Buffer, Interfaces.Unsigned_32 (Expected'Length)),
         SDL.GPU.Make_Transfer_Buffer_Location (Buffer_Download_Buffer));

      if Texture_Supported then
         SDL.GPU.Upload_To_Texture
           (Copy,
            SDL.GPU.Make_Texture_Transfer_Info (Upload_Buffer),
            SDL.GPU.Make_Texture_Region (Source_Texture, 1, 1));
         SDL.GPU.Copy_Texture_To_Texture
           (Copy,
            SDL.GPU.Make_Texture_Location (Source_Texture),
            SDL.GPU.Make_Texture_Location (Copied_Texture),
            1,
            1);
      end if;

      SDL.GPU.End_Pass (Copy);

      if Texture_Supported then
         SDL.GPU.Blit
           (Command,
            SDL.GPU.Make_Blit_Info
              (Source      => SDL.GPU.Make_Blit_Region (Copied_Texture, 1, 1),
               Destination => SDL.GPU.Make_Blit_Region (Source_Texture, 1, 1),
               Load_Op     => SDL.GPU.Clear,
               Filter      => SDL.GPU.Linear));

         Copy := SDL.GPU.Begin_Copy_Pass (Command);
         SDL.GPU.Download_From_Texture
           (Copy,
            SDL.GPU.Make_Texture_Region (Source_Texture, 1, 1),
            SDL.GPU.Make_Texture_Transfer_Info (Texture_Download_Buffer));
      end if;

      SDL.GPU.End_Pass (Copy);
      SDL.GPU.Pop_Debug_Group (Command);
      Fence := SDL.GPU.Submit_And_Acquire_Fence (Command);
      Require (SDL.GPU.Wait (Device, Fence), "Expected resource round-trip fence wait to succeed");
      SDL.GPU.Release (Device, Fence);

      Download_Mapping := SDL.GPU.Map (Buffer_Download_Buffer);
      Require_Bytes ("GPU buffer download", Download_Mapping, Expected);
      SDL.GPU.Unmap (Buffer_Download_Buffer);
      Download_Mapping := System.Null_Address;

      if Texture_Supported then
         Texture_Mapping := SDL.GPU.Map (Texture_Download_Buffer);
         Require_Bytes ("GPU texture download", Texture_Mapping, Expected);
         SDL.GPU.Unmap (Texture_Download_Buffer);
         Texture_Mapping := System.Null_Address;
      end if;

      SDL.GPU.Destroy (Linear_Sampler);
      SDL.GPU.Destroy (Copied_Texture);
      SDL.GPU.Destroy (Source_Texture);
      SDL.GPU.Destroy (Copied_Buffer);
      SDL.GPU.Destroy (Source_Buffer);
      SDL.GPU.Destroy (Texture_Download_Buffer);
      SDL.GPU.Destroy (Buffer_Download_Buffer);
      SDL.GPU.Destroy (Upload_Buffer);
   exception
      when others =>
         if Upload_Mapping /= System.Null_Address then
            SDL.GPU.Unmap (Upload_Buffer);
         end if;

         if Download_Mapping /= System.Null_Address then
            SDL.GPU.Unmap (Buffer_Download_Buffer);
         end if;

         if Texture_Mapping /= System.Null_Address then
            SDL.GPU.Unmap (Texture_Download_Buffer);
         end if;

         if not SDL.GPU.Is_Null (Copy) then
            SDL.GPU.End_Pass (Copy);
         end if;

         if not SDL.GPU.Is_Null (Command) then
            begin
               SDL.GPU.Cancel (Command);
            exception
               when others =>
                  null;
            end;
         end if;

         if not SDL.GPU.Is_Null (Fence) then
            begin
               SDL.GPU.Release (Device, Fence);
            exception
               when others =>
                  null;
            end;
         end if;

         SDL.GPU.Destroy (Linear_Sampler);
         SDL.GPU.Destroy (Copied_Texture);
         SDL.GPU.Destroy (Source_Texture);
         SDL.GPU.Destroy (Copied_Buffer);
         SDL.GPU.Destroy (Source_Buffer);
         SDL.GPU.Destroy (Texture_Download_Buffer);
         SDL.GPU.Destroy (Buffer_Download_Buffer);
         SDL.GPU.Destroy (Upload_Buffer);

         raise;
   end Run_Resource_Roundtrip;

   procedure Run_Multi_Target_Clear
     (Device : in SDL.GPU.Device)
   is
      First_Expected : constant Byte_Array :=
        (0 => 16#FF#, 1 => 16#00#, 2 => 16#00#, 3 => 16#FF#);
      Second_Expected : constant Byte_Array :=
        (0 => 16#00#, 1 => 16#FF#, 2 => 16#00#, 3 => 16#FF#);
      First_Target     : SDL.GPU.Texture;
      Second_Target    : SDL.GPU.Texture;
      First_Download   : SDL.GPU.Transfer_Buffer;
      Second_Download  : SDL.GPU.Transfer_Buffer;
      Command          : SDL.GPU.Command_Buffer;
      Pass             : SDL.GPU.Render_Pass;
      Copy             : SDL.GPU.Copy_Pass;
      Fence            : SDL.GPU.Fence;
      First_Mapping    : System.Address := System.Null_Address;
      Second_Mapping   : System.Address := System.Null_Address;
      Texture_Format   : SDL.GPU.Texture_Formats :=
        SDL.GPU.Texture_Format_From_Pixel_Format
          (SDL.Video.Pixel_Formats.Pixel_Format_RGBA_8888);
      Texture_Size     : Interfaces.Unsigned_32 := 0;
      Texture_Support  : Boolean := False;
   begin
      Texture_Support :=
        Texture_Format /= SDL.GPU.Invalid_Texture_Format and then
        SDL.GPU.Texture_Format_Texel_Block_Size (Texture_Format) = 4 and then
        SDL.GPU.Texture_Supports_Format
          (Device,
           Texture_Format,
           SDL.GPU.Texture_2D,
           SDL.GPU.Texture_Usage_Color_Target);

      if not Texture_Support then
         Put_Line
           ("GPU multi-target clear skipped: no RGBA8 color target support on this backend");
         return;
      end if;

      Texture_Size :=
        SDL.GPU.Calculate_Texture_Format_Size (Texture_Format, 1, 1, 1);
      Require (Texture_Size = 4, "Expected RGBA8 render-target size to be 4 bytes");

      SDL.GPU.Create_Transfer_Buffer
        (First_Download, Device, SDL.GPU.Download, Texture_Size);
      SDL.GPU.Create_Transfer_Buffer
        (Second_Download, Device, SDL.GPU.Download, Texture_Size);
      SDL.GPU.Create_Texture
        (First_Target,
         Device,
         Texture_Format,
         SDL.GPU.Texture_Usage_Color_Target,
         1,
         1);
      SDL.GPU.Create_Texture
        (Second_Target,
         Device,
         Texture_Format,
         SDL.GPU.Texture_Usage_Color_Target,
         1,
         1);

      Command := SDL.GPU.Acquire_Command_Buffer (Device);
      SDL.GPU.Push_Debug_Group (Command, "multi_target_clear");
      Pass :=
        SDL.GPU.Begin_Render_Pass
          (Command,
           (0 =>
              SDL.GPU.Make_Color_Target_Info
                (First_Target,
                 Clear_To        =>
                   (Red => 1.0, Green => 0.0, Blue => 0.0, Alpha => 1.0),
                 Load_Operation  => SDL.GPU.Clear,
                 Store_Operation => SDL.GPU.Store),
            1 =>
              SDL.GPU.Make_Color_Target_Info
                (Second_Target,
                 Clear_To        =>
                   (Red => 0.0, Green => 1.0, Blue => 0.0, Alpha => 1.0),
                 Load_Operation  => SDL.GPU.Clear,
                 Store_Operation => SDL.GPU.Store)));
      SDL.GPU.End_Pass (Pass);

      Copy := SDL.GPU.Begin_Copy_Pass (Command);
      SDL.GPU.Download_From_Texture
        (Copy,
         SDL.GPU.Make_Texture_Region (First_Target, 1, 1),
         SDL.GPU.Make_Texture_Transfer_Info (First_Download));
      SDL.GPU.Download_From_Texture
        (Copy,
         SDL.GPU.Make_Texture_Region (Second_Target, 1, 1),
         SDL.GPU.Make_Texture_Transfer_Info (Second_Download));
      SDL.GPU.End_Pass (Copy);
      SDL.GPU.Pop_Debug_Group (Command);

      Fence := SDL.GPU.Submit_And_Acquire_Fence (Command);
      Require
        (SDL.GPU.Wait (Device, Fence),
         "Expected multi-target clear fence wait to succeed");
      SDL.GPU.Release (Device, Fence);

      First_Mapping := SDL.GPU.Map (First_Download);
      Require_Bytes ("GPU first color target clear", First_Mapping, First_Expected);
      SDL.GPU.Unmap (First_Download);
      First_Mapping := System.Null_Address;

      Second_Mapping := SDL.GPU.Map (Second_Download);
      Require_Bytes
        ("GPU second color target clear", Second_Mapping, Second_Expected);
      SDL.GPU.Unmap (Second_Download);
      Second_Mapping := System.Null_Address;

      SDL.GPU.Destroy (Second_Target);
      SDL.GPU.Destroy (First_Target);
      SDL.GPU.Destroy (Second_Download);
      SDL.GPU.Destroy (First_Download);
   exception
      when others =>
         if First_Mapping /= System.Null_Address then
            SDL.GPU.Unmap (First_Download);
         end if;

         if Second_Mapping /= System.Null_Address then
            SDL.GPU.Unmap (Second_Download);
         end if;

         if not SDL.GPU.Is_Null (Pass) then
            SDL.GPU.End_Pass (Pass);
         end if;

         if not SDL.GPU.Is_Null (Copy) then
            SDL.GPU.End_Pass (Copy);
         end if;

         if not SDL.GPU.Is_Null (Command) then
            begin
               SDL.GPU.Cancel (Command);
            exception
               when others =>
                  null;
            end;
         end if;

         if not SDL.GPU.Is_Null (Fence) then
            begin
               SDL.GPU.Release (Device, Fence);
            exception
               when others =>
                  null;
            end;
         end if;

         SDL.GPU.Destroy (Second_Target);
         SDL.GPU.Destroy (First_Target);
         SDL.GPU.Destroy (Second_Download);
         SDL.GPU.Destroy (First_Download);

         raise;
   end Run_Multi_Target_Clear;

   procedure Run_Portable_Spinning_Cube
     (Device : in SDL.GPU.Device)
   is
      Vertex_Format : SDL.GPU.Shader_Formats := SDL.GPU.Invalid_Shader_Format;
      Fragment_Format : SDL.GPU.Shader_Formats := SDL.GPU.Invalid_Shader_Format;
      Vertex_Entrypoint : constant String := "main";
      Fragment_Entrypoint : constant String := "main";
      Vertex_Buffer : SDL.GPU.Buffer;
      Upload_Buffer : SDL.GPU.Transfer_Buffer;
      Download_Buffer : SDL.GPU.Transfer_Buffer;
      Target_Texture : SDL.GPU.Texture;
      Vertex_Module : SDL.GPU.Shader;
      Fragment_Module : SDL.GPU.Shader;
      Pipeline : SDL.GPU.Graphics_Pipeline;
      Command : SDL.GPU.Command_Buffer;
      Copy : SDL.GPU.Copy_Pass;
      Pass : SDL.GPU.Render_Pass;
      Fence : SDL.GPU.Fence;
      Upload_Mapping : System.Address := System.Null_Address;
      Download_Mapping : System.Address := System.Null_Address;
      Texture_Format : SDL.GPU.Texture_Formats :=
        SDL.GPU.Texture_Format_From_Pixel_Format
          (SDL.Video.Pixel_Formats.Pixel_Format_RGBA_8888);
      Texture_Size : Interfaces.Unsigned_32 := 0;
      Supported : constant SDL.GPU.Shader_Formats :=
        SDL.GPU.Supported_Shader_Formats (Device);
      Transform : constant Matrix_Uniform_Bytes :=
        To_Uniform_Data (Cube_Transform);
      Vertex_Buffers : constant SDL.GPU.Vertex_Buffer_Description_Arrays :=
        (0 =>
           (Slot               => 0,
            Pitch              => Cube_Vertex_Size,
            Input_Rate         => SDL.GPU.Per_Vertex,
            Instance_Step_Rate => 0));
      Vertex_Attributes : constant SDL.GPU.Vertex_Attribute_Arrays :=
        (0 =>
           (Location    => 0,
            Buffer_Slot => 0,
            Format      => SDL.GPU.Float3_Element,
            Offset      => 0),
         1 =>
           (Location    => 1,
            Buffer_Slot => 0,
            Format      => SDL.GPU.Float3_Element,
            Offset      => 3 * Interfaces.Unsigned_32 (Float'Size / System.Storage_Unit)));
   begin
      if Supports_Format (Supported, SDL.GPU.DXIL_Shader_Format) then
         Vertex_Format := SDL.GPU.DXIL_Shader_Format;
         Fragment_Format := SDL.GPU.DXIL_Shader_Format;
      elsif Supports_Format (Supported, SDL.GPU.MSL_Shader_Format) then
         Vertex_Format := SDL.GPU.MSL_Shader_Format;
         Fragment_Format := SDL.GPU.MSL_Shader_Format;
      elsif Supports_Format (Supported, SDL.GPU.SPIRV_Shader_Format) then
         Vertex_Format := SDL.GPU.SPIRV_Shader_Format;
         Fragment_Format := SDL.GPU.SPIRV_Shader_Format;
      else
         Put_Line
           ("GPU spinning cube skipped: no DXIL, MSL, or SPIR-V shader asset format on this backend");
         return;
      end if;

      if Texture_Format = SDL.GPU.Invalid_Texture_Format
        or else SDL.GPU.Texture_Format_Texel_Block_Size (Texture_Format) /= 4
        or else not SDL.GPU.Texture_Supports_Format
          (Device,
           Texture_Format,
           SDL.GPU.Texture_2D,
           SDL.GPU.Texture_Usage_Color_Target)
      then
         Put_Line
           ("GPU spinning cube skipped: no RGBA8 color target support on this backend");
         return;
      end if;

      Texture_Size :=
        SDL.GPU.Calculate_Texture_Format_Size
          (Texture_Format, Cube_Target_Dimension_U32, Cube_Target_Dimension_U32, 1);
      Require
        (Texture_Size = Interfaces.Unsigned_32 (Cube_Target_Byte_Count),
         "Expected spinning cube render-target size to match the offscreen texture");

      SDL.GPU.Create_Buffer
        (Vertex_Buffer, Device, SDL.GPU.Buffer_Usage_Vertex, Cube_Vertex_Bytes);
      SDL.GPU.Create_Transfer_Buffer
        (Upload_Buffer, Device, SDL.GPU.Upload, Cube_Vertex_Bytes);
      SDL.GPU.Create_Transfer_Buffer
        (Download_Buffer, Device, SDL.GPU.Download, Texture_Size);
      SDL.GPU.Create_Texture
        (Target_Texture,
         Device,
         Texture_Format,
         SDL.GPU.Texture_Usage_Color_Target,
         Cube_Target_Dimension_U32,
         Cube_Target_Dimension_U32);

      case Vertex_Format is
         when SDL.GPU.DXIL_Shader_Format =>
            SDL.GPU.Create_Shader
              (Vertex_Module,
               Device,
               GPU_Smoke_Shaders.Cube_Vertex_DXIL,
               GPU_Smoke_Shaders.DXIL_Entrypoint,
               SDL.GPU.DXIL_Shader_Format,
               SDL.GPU.Vertex_Shader,
               Num_Uniform_Buffers => 1);
            SDL.GPU.Create_Shader
              (Fragment_Module,
               Device,
               GPU_Smoke_Shaders.Cube_Fragment_DXIL,
               GPU_Smoke_Shaders.DXIL_Entrypoint,
               SDL.GPU.DXIL_Shader_Format,
               SDL.GPU.Fragment_Shader);
         when SDL.GPU.MSL_Shader_Format =>
            SDL.GPU.Create_Shader
              (Vertex_Module,
               Device,
               GPU_Smoke_Shaders.Cube_Vertex_MSL,
               GPU_Smoke_Shaders.MSL_Entrypoint,
               SDL.GPU.MSL_Shader_Format,
               SDL.GPU.Vertex_Shader,
               Num_Uniform_Buffers => 1);
            SDL.GPU.Create_Shader
              (Fragment_Module,
               Device,
               GPU_Smoke_Shaders.Cube_Fragment_MSL,
               GPU_Smoke_Shaders.MSL_Entrypoint,
               SDL.GPU.MSL_Shader_Format,
               SDL.GPU.Fragment_Shader);
         when SDL.GPU.SPIRV_Shader_Format =>
            SDL.GPU.Create_Shader
              (Vertex_Module,
               Device,
               GPU_Smoke_Shaders.Cube_Vertex_SPIRV,
               GPU_Smoke_Shaders.SPIRV_Entrypoint,
               SDL.GPU.SPIRV_Shader_Format,
               SDL.GPU.Vertex_Shader,
               Num_Uniform_Buffers => 1);
            SDL.GPU.Create_Shader
              (Fragment_Module,
               Device,
               GPU_Smoke_Shaders.Cube_Fragment_SPIRV,
               GPU_Smoke_Shaders.SPIRV_Entrypoint,
               SDL.GPU.SPIRV_Shader_Format,
               SDL.GPU.Fragment_Shader);
         when others =>
            raise Program_Error with "Unexpected cube shader format selection";
      end case;

      SDL.GPU.Create_Graphics_Pipeline
        (Pipeline,
         Device,
         Vertex_Module,
         Fragment_Module,
         Vertex_Buffers,
         Vertex_Attributes,
         SDL.GPU.Triangle_List,
         (0 => (Format => Texture_Format, others => <>)));

      Upload_Mapping := SDL.GPU.Map (Upload_Buffer);
      Write_Cube_Vertices (Upload_Mapping);
      SDL.GPU.Unmap (Upload_Buffer);
      Upload_Mapping := System.Null_Address;

      Command := SDL.GPU.Acquire_Command_Buffer (Device);
      SDL.GPU.Push_Debug_Group (Command, "portable_spinning_cube");

      Copy := SDL.GPU.Begin_Copy_Pass (Command);
      SDL.GPU.Upload_To_Buffer
        (Copy,
         SDL.GPU.Make_Transfer_Buffer_Location (Upload_Buffer),
         SDL.GPU.Make_Buffer_Region (Vertex_Buffer, Cube_Vertex_Bytes));
      SDL.GPU.End_Pass (Copy);

      SDL.GPU.Push_Vertex_Uniform_Data (Command, 0, Transform);
      Pass :=
        SDL.GPU.Begin_Render_Pass
          (Command,
           SDL.GPU.Make_Color_Target_Info
             (Target          => Target_Texture,
              Clear_To        =>
                (Red => 0.0, Green => 0.0, Blue => 0.0, Alpha => 0.0),
              Load_Operation  => SDL.GPU.Clear,
              Store_Operation => SDL.GPU.Store));
      SDL.GPU.Set_Viewport
        (Pass,
         (X         => 0.0,
          Y         => 0.0,
          Width     => Float (Cube_Target_Dimension),
          Height    => Float (Cube_Target_Dimension),
          Min_Depth => 0.0,
          Max_Depth => 1.0));
      SDL.GPU.Bind_Pipeline (Pass, Pipeline);
      SDL.GPU.Bind_Vertex_Buffers
        (Pass,
         0,
         (0 => SDL.GPU.Make_Buffer_Binding (Vertex_Buffer)));
      SDL.GPU.Draw_Primitives (Pass, 36);
      SDL.GPU.End_Pass (Pass);

      Copy := SDL.GPU.Begin_Copy_Pass (Command);
      SDL.GPU.Download_From_Texture
        (Copy,
         SDL.GPU.Make_Texture_Region
           (Target_Texture, Cube_Target_Dimension_U32, Cube_Target_Dimension_U32),
         SDL.GPU.Make_Texture_Transfer_Info
           (Download_Buffer,
            Pixels_Per_Row => Cube_Target_Dimension_U32,
            Rows_Per_Layer => Cube_Target_Dimension_U32));
      SDL.GPU.End_Pass (Copy);
      SDL.GPU.Pop_Debug_Group (Command);

      Fence := SDL.GPU.Submit_And_Acquire_Fence (Command);
      Require
        (SDL.GPU.Wait (Device, Fence),
         "Expected spinning cube fence wait to succeed");
      SDL.GPU.Release (Device, Fence);

      Download_Mapping := SDL.GPU.Map (Download_Buffer);
      Require_Cube_Render (Download_Mapping);
      SDL.GPU.Unmap (Download_Buffer);
      Download_Mapping := System.Null_Address;

      SDL.GPU.Destroy (Pipeline);
      SDL.GPU.Destroy (Fragment_Module);
      SDL.GPU.Destroy (Vertex_Module);
      SDL.GPU.Destroy (Target_Texture);
      SDL.GPU.Destroy (Download_Buffer);
      SDL.GPU.Destroy (Upload_Buffer);
      SDL.GPU.Destroy (Vertex_Buffer);
   exception
      when others =>
         if Upload_Mapping /= System.Null_Address then
            SDL.GPU.Unmap (Upload_Buffer);
         end if;

         if Download_Mapping /= System.Null_Address then
            SDL.GPU.Unmap (Download_Buffer);
         end if;

         if not SDL.GPU.Is_Null (Pass) then
            SDL.GPU.End_Pass (Pass);
         end if;

         if not SDL.GPU.Is_Null (Copy) then
            SDL.GPU.End_Pass (Copy);
         end if;

         if not SDL.GPU.Is_Null (Command) then
            begin
               SDL.GPU.Cancel (Command);
            exception
               when others =>
                  null;
            end;
         end if;

         if not SDL.GPU.Is_Null (Fence) then
            begin
               SDL.GPU.Release (Device, Fence);
            exception
               when others =>
                  null;
            end;
         end if;

         SDL.GPU.Destroy (Pipeline);
         SDL.GPU.Destroy (Fragment_Module);
         SDL.GPU.Destroy (Vertex_Module);
         SDL.GPU.Destroy (Target_Texture);
         SDL.GPU.Destroy (Download_Buffer);
         SDL.GPU.Destroy (Upload_Buffer);
         SDL.GPU.Destroy (Vertex_Buffer);

         raise;
   end Run_Portable_Spinning_Cube;

   procedure Run_Shader_Backed_Draw
     (Device : in SDL.GPU.Device)
   is
      Expected : constant Byte_Array :=
        (0 => 16#20#, 1 => 16#40#, 2 => 16#80#, 3 => 16#FF#);
      Empty_Vertex_Buffers :
        constant SDL.GPU.Vertex_Buffer_Description_Arrays (1 .. 0) :=
          (others => <>);
      Empty_Vertex_Attributes :
        constant SDL.GPU.Vertex_Attribute_Arrays (1 .. 0) :=
          (others => <>);
      Source_Code : constant Ada.Streams.Stream_Element_Array :=
        To_Stream_Elements (MSL_Vertex_Shader_Source);
      Fragment_Code : constant Ada.Streams.Stream_Element_Array :=
        To_Stream_Elements (MSL_Fragment_Shader_Source);
      Upload_Buffer   : SDL.GPU.Transfer_Buffer;
      Download_Buffer : SDL.GPU.Transfer_Buffer;
      Source_Texture  : SDL.GPU.Texture;
      Target_Texture  : SDL.GPU.Texture;
      Linear_Sampler  : SDL.GPU.Sampler;
      Vertex_Module   : SDL.GPU.Shader;
      Fragment_Module : SDL.GPU.Shader;
      Pipeline        : SDL.GPU.Graphics_Pipeline;
      Command         : SDL.GPU.Command_Buffer;
      Copy            : SDL.GPU.Copy_Pass;
      Pass            : SDL.GPU.Render_Pass;
      Fence           : SDL.GPU.Fence;
      Upload_Mapping  : System.Address := System.Null_Address;
      Download_Mapping : System.Address := System.Null_Address;
      Texture_Format  : SDL.GPU.Texture_Formats :=
        SDL.GPU.Texture_Format_From_Pixel_Format
          (SDL.Video.Pixel_Formats.Pixel_Format_RGBA_8888);
      Texture_Size    : Interfaces.Unsigned_32 := 0;
      Supported       : constant SDL.GPU.Shader_Formats :=
        SDL.GPU.Supported_Shader_Formats (Device);
   begin
      if not Supports_Format (Supported, SDL.GPU.MSL_Shader_Format) then
         Put_Line
           ("GPU shader-backed draw skipped: no inline MSL shader support on this backend");
         return;
      end if;

      if Texture_Format = SDL.GPU.Invalid_Texture_Format
        or else SDL.GPU.Texture_Format_Texel_Block_Size (Texture_Format) /= 4
        or else not SDL.GPU.Texture_Supports_Format
          (Device,
           Texture_Format,
           SDL.GPU.Texture_2D,
           SDL.GPU.Texture_Usage_Sampler)
        or else not SDL.GPU.Texture_Supports_Format
          (Device,
           Texture_Format,
           SDL.GPU.Texture_2D,
           SDL.GPU.Texture_Usage_Color_Target)
      then
         Put_Line
           ("GPU shader-backed draw skipped: no RGBA8 sampler and color-target support on this backend");
         return;
      end if;

      Texture_Size :=
        SDL.GPU.Calculate_Texture_Format_Size (Texture_Format, 1, 1, 1);
      Require (Texture_Size = 4, "Expected RGBA8 shader path texture size to be 4 bytes");

      SDL.GPU.Create_Transfer_Buffer
        (Upload_Buffer, Device, SDL.GPU.Upload, Texture_Size);
      SDL.GPU.Create_Transfer_Buffer
        (Download_Buffer, Device, SDL.GPU.Download, Texture_Size);
      SDL.GPU.Create_Texture
        (Source_Texture,
         Device,
         Texture_Format,
         SDL.GPU.Texture_Usage_Sampler,
         1,
         1);
      SDL.GPU.Create_Texture
        (Target_Texture,
         Device,
         Texture_Format,
         SDL.GPU.Texture_Usage_Color_Target,
         1,
         1);
      SDL.GPU.Create_Sampler
        (Linear_Sampler,
         Device,
         Min_Filter => SDL.GPU.Nearest,
         Mag_Filter => SDL.GPU.Nearest);
      SDL.GPU.Create_Shader
        (Vertex_Module,
         Device,
         Source_Code,
         "main0",
         SDL.GPU.MSL_Shader_Format,
         SDL.GPU.Vertex_Shader);
      SDL.GPU.Create_Shader
        (Fragment_Module,
         Device,
         Fragment_Code,
         "main1",
         SDL.GPU.MSL_Shader_Format,
         SDL.GPU.Fragment_Shader,
         Num_Samplers        => 1,
         Num_Uniform_Buffers => 1);
      SDL.GPU.Create_Graphics_Pipeline
        (Pipeline,
         Device,
         Vertex_Module,
         Fragment_Module,
         Empty_Vertex_Buffers,
         Empty_Vertex_Attributes,
         SDL.GPU.Triangle_List,
         (0 => (Format => Texture_Format, others => <>)));

      Upload_Mapping := SDL.GPU.Map (Upload_Buffer);
      Write_Bytes (Upload_Mapping, Expected);
      SDL.GPU.Unmap (Upload_Buffer);
      Upload_Mapping := System.Null_Address;

      Command := SDL.GPU.Acquire_Command_Buffer (Device);
      SDL.GPU.Push_Debug_Group (Command, "shader_backed_draw");

      Copy := SDL.GPU.Begin_Copy_Pass (Command);
      SDL.GPU.Upload_To_Texture
        (Copy,
         SDL.GPU.Make_Texture_Transfer_Info (Upload_Buffer),
         SDL.GPU.Make_Texture_Region (Source_Texture, 1, 1));
      SDL.GPU.End_Pass (Copy);

      SDL.GPU.Push_Fragment_Uniform_Data (Command, 0, Identity_Tint);
      Pass :=
        SDL.GPU.Begin_Render_Pass
          (Command,
           SDL.GPU.Make_Color_Target_Info
             (Target          => Target_Texture,
              Clear_To        =>
                (Red => 0.0, Green => 0.0, Blue => 0.0, Alpha => 1.0),
              Load_Operation  => SDL.GPU.Clear,
              Store_Operation => SDL.GPU.Store));
      SDL.GPU.Set_Viewport
        (Pass,
         (X         => 0.0,
          Y         => 0.0,
          Width     => 1.0,
          Height    => 1.0,
          Min_Depth => 0.0,
          Max_Depth => 1.0));
      SDL.GPU.Bind_Pipeline (Pass, Pipeline);
      SDL.GPU.Bind_Fragment_Samplers
        (Pass,
         0,
         (0 => SDL.GPU.Make_Texture_Sampler_Binding
            (Source_Texture, Linear_Sampler)));
      SDL.GPU.Draw_Primitives (Pass, 3);
      SDL.GPU.End_Pass (Pass);

      Copy := SDL.GPU.Begin_Copy_Pass (Command);
      SDL.GPU.Download_From_Texture
        (Copy,
         SDL.GPU.Make_Texture_Region (Target_Texture, 1, 1),
         SDL.GPU.Make_Texture_Transfer_Info (Download_Buffer));
      SDL.GPU.End_Pass (Copy);
      SDL.GPU.Pop_Debug_Group (Command);

      Fence := SDL.GPU.Submit_And_Acquire_Fence (Command);
      Require
        (SDL.GPU.Wait (Device, Fence),
         "Expected shader-backed draw fence wait to succeed");
      SDL.GPU.Release (Device, Fence);

      Download_Mapping := SDL.GPU.Map (Download_Buffer);
      Require_Bytes ("GPU shader-backed draw", Download_Mapping, Expected);
      SDL.GPU.Unmap (Download_Buffer);
      Download_Mapping := System.Null_Address;

      SDL.GPU.Destroy (Pipeline);
      SDL.GPU.Destroy (Fragment_Module);
      SDL.GPU.Destroy (Vertex_Module);
      SDL.GPU.Destroy (Linear_Sampler);
      SDL.GPU.Destroy (Target_Texture);
      SDL.GPU.Destroy (Source_Texture);
      SDL.GPU.Destroy (Download_Buffer);
      SDL.GPU.Destroy (Upload_Buffer);
   exception
      when others =>
         if Upload_Mapping /= System.Null_Address then
            SDL.GPU.Unmap (Upload_Buffer);
         end if;

         if Download_Mapping /= System.Null_Address then
            SDL.GPU.Unmap (Download_Buffer);
         end if;

         if not SDL.GPU.Is_Null (Pass) then
            SDL.GPU.End_Pass (Pass);
         end if;

         if not SDL.GPU.Is_Null (Copy) then
            SDL.GPU.End_Pass (Copy);
         end if;

         if not SDL.GPU.Is_Null (Command) then
            begin
               SDL.GPU.Cancel (Command);
            exception
               when others =>
                  null;
            end;
         end if;

         if not SDL.GPU.Is_Null (Fence) then
            begin
               SDL.GPU.Release (Device, Fence);
            exception
               when others =>
                  null;
            end;
         end if;

         SDL.GPU.Destroy (Pipeline);
         SDL.GPU.Destroy (Fragment_Module);
         SDL.GPU.Destroy (Vertex_Module);
         SDL.GPU.Destroy (Linear_Sampler);
         SDL.GPU.Destroy (Target_Texture);
         SDL.GPU.Destroy (Source_Texture);
         SDL.GPU.Destroy (Download_Buffer);
         SDL.GPU.Destroy (Upload_Buffer);

         raise;
   end Run_Shader_Backed_Draw;

   Formats          : SDL.GPU.Shader_Formats := SDL.GPU.Invalid_Shader_Format;
   Device           : SDL.GPU.Device;
   Window           : SDL.Video.Windows.Window;
   Renderer         : SDL.Video.Renderers.Renderer;
   Command          : SDL.GPU.Command_Buffer;
   Swapchain        : SDL.GPU.Texture;
   Pass             : SDL.GPU.Render_Pass;
   Fence            : SDL.GPU.Fence;
   Width            : SDL.Natural_Dimension := 0;
   Height           : SDL.Natural_Dimension := 0;
   Window_Created   : Boolean := False;
   Window_Claimed   : Boolean := False;
   Renderer_Created : Boolean := False;
   Headless_Video   : Boolean := False;
begin
   if not SDL.Initialise (SDL.Enable_Video) then
      Put_Line
        ("Skipping GPU runtime validation: SDL video initialization failed: "
         & SDL.Error.Get);
      return;
   end if;

   declare
      Video_Driver : constant String := SDL.Video.Current_Driver_Name;
   begin
      Headless_Video := Is_Headless_Driver (Video_Driver);
   end;

   Formats := SDL.GPU.Default_Shader_Formats;
   Require
     (Formats /= SDL.GPU.Invalid_Shader_Format,
      "Expected a non-empty default GPU shader format mask");

   if SDL.GPU.Total_Drivers = 0 then
      Put_Line ("Skipping GPU runtime validation: SDL reports no GPU drivers");
      SDL.Finalise;
      return;
   end if;

   begin
      SDL.GPU.Create (Device, Formats => Formats);
   exception
      when E : SDL.GPU.GPU_Error =>
         Put_Line
           ("Skipping GPU runtime validation: "
            & Ada.Exceptions.Exception_Message (E));
         SDL.Finalise;
         return;
   end;

   Put_Line ("GPU driver: " & SDL.GPU.Driver_Name (Device));
   Require
     (SDL.GPU.Supported_Shader_Formats (Device) /= SDL.GPU.Invalid_Shader_Format,
      "Expected non-empty device shader formats");
   Require
     (SDL.GPU.Get_Properties (Device) /= SDL.Properties.Null_Property_ID,
      "Expected GPU device properties");

   SDL.GPU.GDK_Suspend (Device);
   SDL.GPU.GDK_Resume (Device);

   Run_Resource_Roundtrip (Device);
   Run_Shader_Backed_Draw (Device);
   Run_Portable_Spinning_Cube (Device);
   Run_Multi_Target_Clear (Device);

   if Headless_Video then
      Put_Line
        ("GPU window-backed validation skipped on headless video driver """
         & SDL.Video.Current_Driver_Name & """");
      SDL.GPU.Destroy (Device);
      SDL.Finalise;
      Put_Line ("GPU smoke completed successfully.");
      return;
   end if;

   SDL.Video.Windows.Makers.Create
     (Win    => Window,
      Title  => "gpu-smoke",
      X      => SDL.Video.Windows.Centered_Window_Position,
      Y      => SDL.Video.Windows.Centered_Window_Position,
      Width  => 160,
      Height => 120,
      Flags  => Window_Flags_For (SDL.GPU.Driver_Name (Device)));
   Window_Created := True;

   SDL.GPU.Claim_Window (Device, Window);
   Window_Claimed := True;

   Require
     (SDL.GPU.Supports_Composition
        (Device, Window, SDL.GPU.Swapchain_SDR),
      "Expected SDR swapchain composition support");
   Require
     (SDL.GPU.Supports_Present_Mode
        (Device, Window, SDL.GPU.V_Sync),
      "Expected VSync present mode support");

   SDL.GPU.Set_Swapchain_Parameters
     (Device,
      Window,
      Composition  => SDL.GPU.Swapchain_SDR,
      Present_Mode => SDL.GPU.V_Sync);
   SDL.GPU.Set_Allowed_Frames_In_Flight (Device, 1);

   Require
     (SDL.GPU.Get_Swapchain_Texture_Format (Device, Window)
        /= SDL.GPU.Invalid_Texture_Format,
      "Expected a valid swapchain texture format");

   Command := SDL.GPU.Acquire_Command_Buffer (Device);
   SDL.GPU.Push_Debug_Group (Command, "gpu_smoke");
   SDL.GPU.Insert_Debug_Label (Command, "clear swapchain");

   if SDL.GPU.Wait_And_Acquire_Swapchain_Texture
       (Command, Window, Swapchain, Width, Height)
   then
      Require (Width > 0 and then Height > 0, "Expected non-zero swapchain size");

      Pass :=
        SDL.GPU.Begin_Render_Pass
          (Command,
           SDL.GPU.Make_Color_Target_Info
             (Target          => Swapchain,
              Clear_To        => (Red => 0.10,
                                  Green => 0.20,
                                  Blue => 0.30,
                                  Alpha => 1.0),
              Load_Operation  => SDL.GPU.Clear,
              Store_Operation => SDL.GPU.Store));

      SDL.GPU.Set_Viewport
        (Pass,
         (X         => 0.0,
          Y         => 0.0,
          Width     => Float (Width),
          Height    => Float (Height),
          Min_Depth => 0.0,
          Max_Depth => 1.0));
      SDL.GPU.End_Pass (Pass);

      SDL.GPU.Pop_Debug_Group (Command);
      Fence := SDL.GPU.Submit_And_Acquire_Fence (Command);
      Require (SDL.GPU.Wait (Device, Fence), "Expected GPU fence wait to succeed");
      SDL.GPU.Release (Device, Fence);
      SDL.GPU.Wait_For_Idle (Device);
   else
      Put_Line
        ("GPU swapchain acquisition returned no texture; skipping clear submission");
      SDL.GPU.Pop_Debug_Group (Command);
      SDL.GPU.Cancel (Command);
   end if;

   SDL.GPU.Release_Window (Device, Window);
   Window_Claimed := False;

   begin
      SDL.Video.Renderers.Makers.Create
        (Rend   => Renderer,
         Device => Device,
         Window => Window);
      Renderer_Created := True;

      declare
         Renderer_Device : constant SDL.GPU.Device :=
           SDL.Video.Renderers.Get_GPU_Device (Renderer);
      begin
         Require
           (not SDL.GPU.Is_Null (Renderer_Device),
            "Expected GPU device from renderer bridge");
         Require
           (SDL.GPU.Driver_Name (Renderer_Device) = SDL.GPU.Driver_Name (Device),
            "Renderer GPU bridge should round-trip the device driver");
      end;
   exception
      when E : SDL.Video.Renderers.Renderer_Error =>
         Put_Line
           ("GPU renderer bridge skipped: "
            & Ada.Exceptions.Exception_Message (E));
   end;

   if Renderer_Created then
      SDL.Video.Renderers.Finalize (Renderer);
      Renderer_Created := False;
   end if;

   if Window_Created then
      SDL.Video.Windows.Finalize (Window);
      Window_Created := False;
   end if;

   SDL.GPU.Destroy (Device);
   SDL.Finalise;
   Put_Line ("GPU smoke completed successfully.");
exception
   when Error : others =>
      if not SDL.GPU.Is_Null (Pass) then
         SDL.GPU.End_Pass (Pass);
      end if;

      if not SDL.GPU.Is_Null (Command) then
         begin
            SDL.GPU.Cancel (Command);
         exception
            when others =>
               null;
         end;
      end if;

      if not SDL.GPU.Is_Null (Fence) then
         begin
            SDL.GPU.Release (Device, Fence);
         exception
            when others =>
               null;
         end;
      end if;

      if Renderer_Created then
         SDL.Video.Renderers.Finalize (Renderer);
      end if;

      if Window_Claimed then
         begin
            SDL.GPU.Release_Window (Device, Window);
         exception
            when others =>
               null;
         end;
      end if;

      if Window_Created then
         SDL.Video.Windows.Finalize (Window);
      end if;

      SDL.GPU.Destroy (Device);
      SDL.Finalise;

      Put_Line ("GPU smoke failed: " & Ada.Exceptions.Exception_Message (Error));
      raise;
end GPU_Smoke;
