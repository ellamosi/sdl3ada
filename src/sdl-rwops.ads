with Ada.Streams;
with Ada.Strings.UTF_Encoding;
with Interfaces;
with Interfaces.C;
with System;

with SDL.C_Pointers;
with SDL.Raw.IOStream;
with SDL.Raw.Properties;

package SDL.RWops is
   pragma Preelaborate;
   pragma Elaborate_Body;

   package C renames Interfaces.C;
   package UTF_Strings renames Ada.Strings.UTF_Encoding;

   RWops_Error : exception;

   subtype Uint8 is Interfaces.Unsigned_8;
   subtype Sint8 is Interfaces.Integer_8;
   subtype Uint16 is Interfaces.Unsigned_16;
   subtype Sint16 is Interfaces.Integer_16;
   subtype Uint32 is Interfaces.Unsigned_32;
   subtype Sint32 is Interfaces.Integer_32;
   subtype Uint64 is Interfaces.Unsigned_64;
   subtype Sint64 is Interfaces.Integer_64;

   subtype IO_Status is SDL.Raw.IOStream.IO_Status;
   Ready      : constant IO_Status := SDL.Raw.IOStream.IO_Status_Ready;
   Error      : constant IO_Status := SDL.Raw.IOStream.IO_Status_Error;
   End_Of_File : constant IO_Status := SDL.Raw.IOStream.IO_Status_Eof;
   Not_Ready  : constant IO_Status := SDL.Raw.IOStream.IO_Status_Not_Ready;
   Read_Only  : constant IO_Status := SDL.Raw.IOStream.IO_Status_Readonly;
   Write_Only : constant IO_Status := SDL.Raw.IOStream.IO_Status_Writeonly;

   subtype Property_ID is SDL.Raw.Properties.ID;
   Null_Property_ID : constant Property_ID := SDL.Raw.Properties.No_Properties;

   subtype Handle is SDL.C_Pointers.IO_Stream_Pointer;
   subtype IO_Stream_Interface is SDL.Raw.IOStream.IO_Stream_Interface;
   subtype Size_Callback is SDL.Raw.IOStream.Size_Callback;
   subtype Seek_Callback is SDL.Raw.IOStream.Seek_Callback;
   subtype Read_Callback is SDL.Raw.IOStream.Read_Callback;
   subtype Write_Callback is SDL.Raw.IOStream.Write_Callback;
   subtype Flush_Callback is SDL.Raw.IOStream.Flush_Callback;
   subtype Close_Callback is SDL.Raw.IOStream.Close_Callback;

   IO_Stream_Interface_Size : constant Interfaces.Unsigned_32 :=
     Interfaces.Unsigned_32
       (SDL.Raw.IOStream.IO_Stream_Interface'Size / System.Storage_Unit);

   function Create_Interface return IO_Stream_Interface is
     (Version => IO_Stream_Interface_Size,
      Size    => null,
      Seek    => null,
      Read    => null,
      Write   => null,
      Flush   => null,
      Close   => null);

   type RWops is limited private;

   type File_Mode is
     (Read,
      Create_To_Write,
      Append,
      Read_Write,
      Create_To_Read_Write,
      Append_And_Read,
      Read_Binary,
      Create_To_Write_Binary,
      Append_Binary,
      Read_Write_Binary,
      Create_To_Read_Write_Binary,
      Append_And_Read_Binary);

   type Whence_Type is private;

   RW_Seek_Set : constant Whence_Type;
   RW_Seek_Cur : constant Whence_Type;
   RW_Seek_End : constant Whence_Type;

   type Offsets is new Interfaces.Integer_64;

   Null_Offset  : constant Offsets := 0;
   Error_Offset : constant Offsets := -1;

   subtype Sizes is Offsets;

   Error_Or_EOF : constant Sizes := 0;

   Windows_Handle_Property : constant String :=
     SDL.Raw.IOStream.Iostream_Windows_Handle_Pointer_Property;
   Stdio_File_Property : constant String :=
     SDL.Raw.IOStream.Iostream_Stdio_File_Pointer_Property;
   File_Descriptor_Property : constant String :=
     SDL.Raw.IOStream.Iostream_File_Descriptor_Number_Property;
   Android_AAsset_Property : constant String :=
     SDL.Raw.IOStream.Iostream_Android_Aasset_Pointer_Property;
   Memory_Pointer_Property : constant String :=
     SDL.Raw.IOStream.Iostream_Memory_Pointer_Property;
   Memory_Size_Property : constant String :=
     SDL.Raw.IOStream.Iostream_Memory_Size_Number_Property;
   Memory_Free_Function_Property : constant String :=
     SDL.Raw.IOStream.Iostream_Memory_Free_Func_Pointer_Property;
   Dynamic_Memory_Property : constant String :=
     SDL.Raw.IOStream.Iostream_Dynamic_Memory_Pointer_Property;
   Dynamic_Chunk_Size_Property : constant String :=
     SDL.Raw.IOStream.Iostream_Dynamic_Chunksize_Number_Property;

   function Base_Path return UTF_Strings.UTF_String;
   pragma Obsolescent
     (Entity  => Base_Path,
      Message => "Moved to SDL.Filesystems, this one will be removed in the next release.");

   function Preferences_Path
     (Organisation : in UTF_Strings.UTF_String;
      Application  : in UTF_Strings.UTF_String) return UTF_Strings.UTF_String;
   pragma Obsolescent
     (Entity  => Preferences_Path,
      Message => "Moved to SDL.Filesystems, this one will be removed in the next release.");

   function Seek
     (Context : in RWops;
      Offset  : in Offsets;
      Whence  : in Whence_Type) return Offsets;

   function Size (Context : in RWops) return Offsets;
   function Tell (Context : in RWops) return Offsets;

   function Get_Handle (Source : in RWops) return Handle with
     Inline;

   function Get_Properties (Context : in RWops) return Property_ID;

   function Status (Context : in RWops) return IO_Status;

   function Read
     (Context     : in RWops;
      Destination : in System.Address;
      Size        : in Natural) return Natural;

   function Write
     (Context : in RWops;
      Source  : in System.Address;
      Size    : in Natural) return Natural;

   procedure Put
     (Destination : in RWops;
      Value       : in String);

   procedure Flush (Context : in RWops);

   function From_File
     (File_Name : in UTF_Strings.UTF_String;
      Mode      : in File_Mode) return RWops;

   procedure From_File
     (File_Name : in UTF_Strings.UTF_String;
      Mode      : in File_Mode;
      Ops       : out RWops);

   function From_Memory
     (Memory : in System.Address;
      Size   : in Natural) return RWops;

   procedure From_Memory
     (Memory : in System.Address;
      Size   : in Natural;
      Ops    : out RWops);

   function From_Const_Memory
     (Memory : in System.Address;
      Size   : in Natural) return RWops;

   procedure From_Const_Memory
     (Memory : in System.Address;
      Size   : in Natural;
      Ops    : out RWops);

   function From_Dynamic_Memory return RWops;

   procedure From_Dynamic_Memory (Ops : out RWops);

   function Open
     (Interface_Definition : in IO_Stream_Interface;
      User_Data            : in System.Address := System.Null_Address)
      return RWops;

   procedure Open
     (Interface_Definition : in IO_Stream_Interface;
      User_Data            : in System.Address;
      Ops                  : out RWops);

   procedure Close (Ops : in RWops);

   function Load_File
     (Source      : in RWops;
      Close_After : in Boolean := False)
      return Ada.Streams.Stream_Element_Array;

   function Load_File
     (File_Name : in UTF_Strings.UTF_String)
      return Ada.Streams.Stream_Element_Array;

   procedure Save_File
     (Destination : in RWops;
      Data        : in Ada.Streams.Stream_Element_Array;
      Close_After : in Boolean := False);

   procedure Save_File
     (Destination : in RWops;
      Data        : in System.Address;
      Size        : in Natural;
      Close_After : in Boolean := False);

   procedure Save_File
     (File_Name : in UTF_Strings.UTF_String;
      Data      : in Ada.Streams.Stream_Element_Array);

   procedure Save_File
     (File_Name : in UTF_Strings.UTF_String;
      Data      : in System.Address;
      Size      : in Natural);

   function Read_U_8 (Src : in RWops) return Uint8;
   function Read_S_8 (Src : in RWops) return Sint8;
   function Read_LE_16 (Src : in RWops) return Uint16;
   function Read_S_LE_16 (Src : in RWops) return Sint16;
   function Read_BE_16 (Src : in RWops) return Uint16;
   function Read_S_BE_16 (Src : in RWops) return Sint16;
   function Read_LE_32 (Src : in RWops) return Uint32;
   function Read_S_LE_32 (Src : in RWops) return Sint32;
   function Read_BE_32 (Src : in RWops) return Uint32;
   function Read_S_BE_32 (Src : in RWops) return Sint32;
   function Read_LE_64 (Src : in RWops) return Uint64;
   function Read_S_LE_64 (Src : in RWops) return Sint64;
   function Read_BE_64 (Src : in RWops) return Uint64;
   function Read_S_BE_64 (Src : in RWops) return Sint64;

   procedure Write_U_8 (Destination : in RWops; Value : in Uint8);
   procedure Write_S_8 (Destination : in RWops; Value : in Sint8);
   procedure Write_LE_16 (Destination : in RWops; Value : in Uint16);
   procedure Write_S_LE_16 (Destination : in RWops; Value : in Sint16);
   procedure Write_BE_16 (Destination : in RWops; Value : in Uint16);
   procedure Write_S_BE_16 (Destination : in RWops; Value : in Sint16);
   procedure Write_LE_32 (Destination : in RWops; Value : in Uint32);
   procedure Write_S_LE_32 (Destination : in RWops; Value : in Sint32);
   procedure Write_BE_32 (Destination : in RWops; Value : in Uint32);
   procedure Write_S_BE_32 (Destination : in RWops; Value : in Sint32);
   procedure Write_LE_64 (Destination : in RWops; Value : in Uint64);
   procedure Write_S_LE_64 (Destination : in RWops; Value : in Sint64);
   procedure Write_BE_64 (Destination : in RWops; Value : in Uint64);
   procedure Write_S_BE_64 (Destination : in RWops; Value : in Sint64);

   function Is_Null (Source : in RWops) return Boolean with
     Inline_Always => True;
private
   type Whence_Type is new C.int;

   RW_Seek_Set : constant Whence_Type := 0;
   RW_Seek_Cur : constant Whence_Type := 1;
   RW_Seek_End : constant Whence_Type := 2;

   type RWops is new SDL.C_Pointers.IO_Stream_Pointer;
end SDL.RWops;
