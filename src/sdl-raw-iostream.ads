with Interfaces;
with Interfaces.C;
with Interfaces.C.Extensions;
with Interfaces.C.Strings;
with System;

with SDL.C_Pointers;
with SDL.Raw.Properties;

package SDL.Raw.IOStream is
   pragma Preelaborate;

   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;
   package CS renames Interfaces.C.Strings;

   subtype Stream_Access is SDL.C_Pointers.IO_Stream_Pointer;
   subtype Offsets is Interfaces.Integer_64;
   subtype Sizes is C.size_t;

   type Status is
     (Ready,
      Error,
      End_Of_File,
      Not_Ready,
      Read_Only,
      Write_Only)
   with
     Convention => C,
     Size       => C.int'Size;

   for Status use
     (Ready      => 0,
      Error      => 1,
      End_Of_File => 2,
      Not_Ready  => 3,
      Read_Only  => 4,
      Write_Only => 5);

   type Whence is
     (Seek_Set,
      Seek_Cur,
      Seek_End)
   with
     Convention => C,
     Size       => C.int'Size;

   for Whence use
     (Seek_Set => 0,
      Seek_Cur => 1,
      Seek_End => 2);

   type Size_Callback is access function
     (User_Data : in System.Address) return Offsets
   with Convention => C;

   type Seek_Callback is access function
     (User_Data : in System.Address;
      Offset    : in Offsets;
      Origin    : in Whence) return Offsets
   with Convention => C;

   type Read_Callback is access function
     (User_Data : in System.Address;
      Pointer   : in System.Address;
      Size      : in Sizes;
      Result    : access Status) return Sizes
   with Convention => C;

   type Write_Callback is access function
     (User_Data : in System.Address;
      Pointer   : in System.Address;
      Size      : in Sizes;
      Result    : access Status) return Sizes
   with Convention => C;

   type Flush_Callback is access function
     (User_Data : in System.Address;
      Result    : access Status) return CE.bool
   with Convention => C;

   type Close_Callback is access function
     (User_Data : in System.Address) return CE.bool
   with Convention => C;

   type IO_Stream_Interface is record
      Version : Interfaces.Unsigned_32 := 0;
      Size    : Size_Callback := null;
      Seek    : Seek_Callback := null;
      Read    : Read_Callback := null;
      Write   : Write_Callback := null;
      Flush   : Flush_Callback := null;
      Close   : Close_Callback := null;
   end record with
     Convention => C;

   IO_Stream_Interface_Size : constant Interfaces.Unsigned_32 :=
     Interfaces.Unsigned_32
       (IO_Stream_Interface'Size / System.Storage_Unit);

   function Create_Interface return IO_Stream_Interface is
     (Version => IO_Stream_Interface_Size,
      Size    => null,
      Seek    => null,
      Read    => null,
      Write   => null,
      Flush   => null,
      Close   => null);

   Windows_Handle_Property    : constant String := "SDL.iostream.windows.handle";
   Stdio_File_Property        : constant String := "SDL.iostream.stdio.file";
   File_Descriptor_Property   : constant String := "SDL.iostream.file_descriptor";
   Android_AAsset_Property    : constant String := "SDL.iostream.android.aasset";
   Memory_Pointer_Property    : constant String := "SDL.iostream.memory.base";
   Memory_Size_Property       : constant String := "SDL.iostream.memory.size";
   Memory_Free_Function_Property : constant String := "SDL.iostream.memory.free";
   Dynamic_Memory_Property    : constant String := "SDL.iostream.dynamic.memory";
   Dynamic_Chunk_Size_Property : constant String := "SDL.iostream.dynamic.chunksize";

   function IO_From_File
     (File : in C.char_array;
      Mode : in C.char_array) return Stream_Access
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_IOFromFile";

   function IO_From_Mem
     (Memory : in System.Address;
      Size   : in Sizes) return Stream_Access
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_IOFromMem";

   function IO_From_Const_Mem
     (Memory : in System.Address;
      Size   : in Sizes) return Stream_Access
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_IOFromConstMem";

   function IO_From_Dynamic_Mem return Stream_Access
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_IOFromDynamicMem";

   function Open_IO
     (Interface_Definition : access constant IO_Stream_Interface;
      User_Data            : in System.Address) return Stream_Access
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_OpenIO";

   function Close_IO (Context : in Stream_Access) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CloseIO";

   function Get_IO_Properties
     (Context : in Stream_Access) return SDL.Raw.Properties.ID
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetIOProperties";

   function Get_IO_Status
     (Context : in Stream_Access) return Status
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetIOStatus";

   function Get_IO_Size (Context : in Stream_Access) return Offsets
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetIOSize";

   function Seek_IO
     (Context : in Stream_Access;
      Offset  : in Offsets;
      Origin  : in Whence) return Offsets
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SeekIO";

   function Tell_IO (Context : in Stream_Access) return Offsets
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_TellIO";

   function Read_IO
     (Context : in Stream_Access;
      Pointer : in System.Address;
      Size    : in Sizes) return Sizes
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ReadIO";

   function Write_IO
     (Context : in Stream_Access;
      Pointer : in System.Address;
      Size    : in Sizes) return Sizes
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_WriteIO";

   function IO_VPrintf
     (Context   : in Stream_Access;
      Format    : in C.char_array;
      Arguments : in System.Address) return Sizes
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_IOvprintf";

   function Flush_IO (Context : in Stream_Access) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_FlushIO";

   function Load_File_IO
     (Source    : in Stream_Access;
      Data_Size : access Sizes;
      Close_IO  : in CE.bool) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_LoadFile_IO";

   function Load_File
     (File      : in C.char_array;
      Data_Size : access Sizes) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_LoadFile";

   function Save_File_IO
     (Destination : in Stream_Access;
      Data        : in System.Address;
      Data_Size   : in Sizes;
      Close_IO    : in CE.bool) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SaveFile_IO";

   function Save_File
     (File      : in C.char_array;
      Data      : in System.Address;
      Data_Size : in Sizes) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SaveFile";

   function Read_U8
     (Source : in Stream_Access;
      Value  : access Interfaces.Unsigned_8) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ReadU8";

   function Read_S8
     (Source : in Stream_Access;
      Value  : access Interfaces.Integer_8) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ReadS8";

   function Read_U16LE
     (Source : in Stream_Access;
      Value  : access Interfaces.Unsigned_16) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ReadU16LE";

   function Read_S16LE
     (Source : in Stream_Access;
      Value  : access Interfaces.Integer_16) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ReadS16LE";

   function Read_U16BE
     (Source : in Stream_Access;
      Value  : access Interfaces.Unsigned_16) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ReadU16BE";

   function Read_S16BE
     (Source : in Stream_Access;
      Value  : access Interfaces.Integer_16) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ReadS16BE";

   function Read_U32LE
     (Source : in Stream_Access;
      Value  : access Interfaces.Unsigned_32) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ReadU32LE";

   function Read_S32LE
     (Source : in Stream_Access;
      Value  : access Interfaces.Integer_32) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ReadS32LE";

   function Read_U32BE
     (Source : in Stream_Access;
      Value  : access Interfaces.Unsigned_32) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ReadU32BE";

   function Read_S32BE
     (Source : in Stream_Access;
      Value  : access Interfaces.Integer_32) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ReadS32BE";

   function Read_U64LE
     (Source : in Stream_Access;
      Value  : access Interfaces.Unsigned_64) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ReadU64LE";

   function Read_S64LE
     (Source : in Stream_Access;
      Value  : access Interfaces.Integer_64) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ReadS64LE";

   function Read_U64BE
     (Source : in Stream_Access;
      Value  : access Interfaces.Unsigned_64) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ReadU64BE";

   function Read_S64BE
     (Source : in Stream_Access;
      Value  : access Interfaces.Integer_64) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ReadS64BE";

   function Write_U8
     (Destination : in Stream_Access;
      Value       : in Interfaces.Unsigned_8) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_WriteU8";

   function Write_S8
     (Destination : in Stream_Access;
      Value       : in Interfaces.Integer_8) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_WriteS8";

   function Write_U16LE
     (Destination : in Stream_Access;
      Value       : in Interfaces.Unsigned_16) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_WriteU16LE";

   function Write_S16LE
     (Destination : in Stream_Access;
      Value       : in Interfaces.Integer_16) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_WriteS16LE";

   function Write_U16BE
     (Destination : in Stream_Access;
      Value       : in Interfaces.Unsigned_16) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_WriteU16BE";

   function Write_S16BE
     (Destination : in Stream_Access;
      Value       : in Interfaces.Integer_16) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_WriteS16BE";

   function Write_U32LE
     (Destination : in Stream_Access;
      Value       : in Interfaces.Unsigned_32) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_WriteU32LE";

   function Write_S32LE
     (Destination : in Stream_Access;
      Value       : in Interfaces.Integer_32) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_WriteS32LE";

   function Write_U32BE
     (Destination : in Stream_Access;
      Value       : in Interfaces.Unsigned_32) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_WriteU32BE";

   function Write_S32BE
     (Destination : in Stream_Access;
      Value       : in Interfaces.Integer_32) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_WriteS32BE";

   function Write_U64LE
     (Destination : in Stream_Access;
      Value       : in Interfaces.Unsigned_64) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_WriteU64LE";

   function Write_S64LE
     (Destination : in Stream_Access;
      Value       : in Interfaces.Integer_64) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_WriteS64LE";

   function Write_U64BE
     (Destination : in Stream_Access;
      Value       : in Interfaces.Unsigned_64) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_WriteU64BE";

   function Write_S64BE
     (Destination : in Stream_Access;
      Value       : in Interfaces.Integer_64) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_WriteS64BE";
end SDL.Raw.IOStream;
