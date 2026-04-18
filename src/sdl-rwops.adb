with Ada.Unchecked_Conversion;

with Interfaces.C.Extensions;
with Interfaces.C.Strings;

with SDL.Error;

package body SDL.RWops is
   package CE renames Interfaces.C.Extensions;
   package CS renames Interfaces.C.Strings;
   package Raw renames SDL.Raw.IOStream;

   use type SDL.C_Pointers.IO_Stream_Pointer;
   use type Ada.Streams.Stream_Element_Offset;
   use type C.size_t;
   use type Raw.IO_Status;
   use type System.Address;

   Empty_Bytes : constant Ada.Streams.Stream_Element_Array (1 .. 0) :=
     (1 .. 0 => 0);

   procedure SDL_Free (Memory : in CS.chars_ptr) with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_free";

   procedure SDL_Free (Memory : in System.Address) with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_free";

   function SDL_IO_PrintF
     (Context : in Handle;
      Format  : in C.char_array;
      Value   : in C.char_array) return C.size_t
   with
     Import        => True,
     Convention    => C_Variadic_1,
     External_Name => "SDL_IOprintf";

   function SDL_Get_Base_Path return CS.chars_ptr with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetBasePath";

   function SDL_Get_Pref_Path
     (Organisation : in C.char_array;
      Application  : in C.char_array) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetPrefPath";

   procedure Ensure_Valid (Context : in RWops) is
   begin
      if Is_Null (Context) then
         raise RWops_Error with "Invalid RWops handle";
      end if;
   end Ensure_Valid;

   function Mode_String (Mode : in File_Mode) return String is
     (case Mode is
         when Read                       => "r",
         when Create_To_Write            => "w",
         when Append                     => "a",
         when Read_Write                 => "r+",
         when Create_To_Read_Write       => "w+",
         when Append_And_Read            => "a+",
         when Read_Binary                => "rb",
         when Create_To_Write_Binary     => "wb",
         when Append_Binary              => "ab",
         when Read_Write_Binary          => "r+b",
         when Create_To_Read_Write_Binary => "w+b",
         when Append_And_Read_Binary     => "a+b");

   function Opened
     (Context : in Handle) return RWops is
   begin
      if Context = null then
         raise RWops_Error with SDL.Error.Get;
      end if;

      return RWops (Context);
   end Opened;

   function To_C_Bool (Value : in Boolean) return CE.bool is
     (CE.bool'Val (Boolean'Pos (Value)));

   procedure Raise_Last_Error;
   procedure Raise_Last_Error is
   begin
      raise RWops_Error with SDL.Error.Get;
   end Raise_Last_Error;

   function To_Stream_Elements
     (Address : in System.Address;
      Length  : in C.size_t) return Ada.Streams.Stream_Element_Array
   is
      subtype Result_Array is Ada.Streams.Stream_Element_Array
        (1 .. Ada.Streams.Stream_Element_Offset (Length));
      type Result_Array_Access is access all Result_Array;
      function To_Result_Array is new Ada.Unchecked_Conversion
        (Source => System.Address,
         Target => Result_Array_Access);
   begin
      if Length = 0 then
         return Empty_Bytes;
      end if;

      if Length > C.size_t (Ada.Streams.Stream_Element_Offset'Last) then
         raise RWops_Error with "SDL_LoadFile result is too large for Ada stream indexing";
      end if;

      return To_Result_Array (Address).all;
   end To_Stream_Elements;

   function Base_Path return UTF_Strings.UTF_String is
      C_Path : constant CS.chars_ptr := SDL_Get_Base_Path;

      use type CS.chars_ptr;
   begin
      if C_Path = CS.Null_Ptr then
         raise RWops_Error with SDL.Error.Get;
      end if;

      declare
         Ada_Path : constant UTF_Strings.UTF_String := CS.Value (C_Path);
      begin
         SDL_Free (C_Path);
         return Ada_Path;
      end;
   end Base_Path;

   function Preferences_Path
     (Organisation : in UTF_Strings.UTF_String;
      Application  : in UTF_Strings.UTF_String) return UTF_Strings.UTF_String
   is
      C_Path : constant CS.chars_ptr :=
        SDL_Get_Pref_Path
          (Organisation => C.To_C (Organisation),
           Application  => C.To_C (Application));

      use type CS.chars_ptr;
   begin
      if C_Path = CS.Null_Ptr then
         raise RWops_Error with SDL.Error.Get;
      end if;

      declare
         Ada_Path : constant UTF_Strings.UTF_String := CS.Value (C_Path);
      begin
         SDL_Free (C_Path);
         return Ada_Path;
      end;
   end Preferences_Path;

   function Seek
     (Context : in RWops;
      Offset  : in Offsets;
      Whence  : in Whence_Type) return Offsets
   is
      Returned_Offset : Offsets;
   begin
      Ensure_Valid (Context);

      Returned_Offset :=
        Offsets
          (Raw.Seek_IO
             (Get_Handle (Context),
              Interfaces.Integer_64 (Offset),
              Raw.IO_Whence'Val (Whence_Type'Pos (Whence))));

      if Returned_Offset = Error_Offset then
         raise RWops_Error with SDL.Error.Get;
      end if;

      return Returned_Offset;
   end Seek;

   function Size (Context : in RWops) return Offsets is
      Returned_Size : Offsets;
   begin
      Ensure_Valid (Context);

      Returned_Size := Offsets (Raw.Get_IO_Size (Get_Handle (Context)));

      if Returned_Size < Null_Offset then
         raise RWops_Error with SDL.Error.Get;
      end if;

      return Returned_Size;
   end Size;

   function Tell (Context : in RWops) return Offsets is
      Returned_Offset : Offsets;
   begin
      Ensure_Valid (Context);

      Returned_Offset := Offsets (Raw.Tell_IO (Get_Handle (Context)));

      if Returned_Offset = Error_Offset then
         raise RWops_Error with SDL.Error.Get;
      end if;

      return Returned_Offset;
   end Tell;

   function Get_Handle (Source : in RWops) return Handle is
     (Handle (Source));

   function Get_Properties (Context : in RWops) return Property_ID is
   begin
      Ensure_Valid (Context);
      return Raw.Get_IO_Properties (Get_Handle (Context));
   end Get_Properties;

   function Status (Context : in RWops) return IO_Status is
   begin
      Ensure_Valid (Context);
      return Raw.Get_IO_Status (Get_Handle (Context));
   end Status;

   function Read
     (Context     : in RWops;
      Destination : in System.Address;
      Size        : in Natural) return Natural
   is
   begin
      Ensure_Valid (Context);

      if Size = 0 then
         return 0;
      end if;

      return Natural
        (Raw.Read_IO
           (Get_Handle (Context),
            Destination,
            C.size_t (Size)));
   end Read;

   function Write
     (Context : in RWops;
      Source  : in System.Address;
      Size    : in Natural) return Natural
   is
   begin
      Ensure_Valid (Context);

      if Size = 0 then
         return 0;
      end if;

      return Natural
        (Raw.Write_IO
           (Get_Handle (Context),
            Source,
            C.size_t (Size)));
   end Write;

   procedure Put
     (Destination : in RWops;
      Value       : in String)
   is
      Bytes_Written : C.size_t;
   begin
      Ensure_Valid (Destination);

      if Value'Length = 0 then
         return;
      end if;

      Bytes_Written :=
        SDL_IO_PrintF
          (Context => Get_Handle (Destination),
           Format  => C.To_C ("%s"),
           Value   => C.To_C (Value));

      if Bytes_Written /= C.size_t (Value'Length) and then Status (Destination) = Error then
         Raise_Last_Error;
      end if;
   end Put;

   procedure Flush (Context : in RWops) is
   begin
      Ensure_Valid (Context);

      if not Boolean (Raw.Flush_IO (Get_Handle (Context))) then
         Raise_Last_Error;
      end if;
   end Flush;

   function From_File
     (File_Name : in UTF_Strings.UTF_String;
      Mode      : in File_Mode) return RWops
   is
   begin
      return Opened
        (Raw.IO_From_File
           (File => C.To_C (File_Name),
            Mode => C.To_C (Mode_String (Mode))));
   end From_File;

   procedure From_File
     (File_Name : in UTF_Strings.UTF_String;
      Mode      : in File_Mode;
      Ops       : out RWops) is
   begin
      Ops := From_File (File_Name, Mode);
   end From_File;

   function From_Memory
     (Memory : in System.Address;
      Size   : in Natural) return RWops
   is
   begin
      return Opened
        (Raw.IO_From_Mem
           (Memory,
            C.size_t (Size)));
   end From_Memory;

   procedure From_Memory
     (Memory : in System.Address;
      Size   : in Natural;
      Ops    : out RWops) is
   begin
      Ops := From_Memory (Memory, Size);
   end From_Memory;

   function From_Const_Memory
     (Memory : in System.Address;
      Size   : in Natural) return RWops
   is
   begin
      return Opened
        (Raw.IO_From_Const_Mem
           (Memory,
            C.size_t (Size)));
   end From_Const_Memory;

   procedure From_Const_Memory
     (Memory : in System.Address;
      Size   : in Natural;
      Ops    : out RWops) is
   begin
      Ops := From_Const_Memory (Memory, Size);
   end From_Const_Memory;

   function From_Dynamic_Memory return RWops is
   begin
      return Opened (Raw.IO_From_Dynamic_Mem);
   end From_Dynamic_Memory;

   procedure From_Dynamic_Memory (Ops : out RWops) is
   begin
      Ops := From_Dynamic_Memory;
   end From_Dynamic_Memory;

   function Open
     (Interface_Definition : in IO_Stream_Interface;
      User_Data            : in System.Address := System.Null_Address)
      return RWops
   is
      Definition : aliased constant IO_Stream_Interface := Interface_Definition;
   begin
      return Opened
        (Raw.Open_IO
           (Definition'Access,
            User_Data));
   end Open;

   procedure Open
     (Interface_Definition : in IO_Stream_Interface;
      User_Data            : in System.Address;
      Ops                  : out RWops) is
   begin
      Ops := Open (Interface_Definition, User_Data);
   end Open;

   procedure Close (Ops : in RWops) is
   begin
      if Is_Null (Ops) then
         return;
      end if;

      if not Boolean (Raw.Close_IO (Get_Handle (Ops))) then
         Raise_Last_Error;
      end if;
   end Close;

   function Load_File
     (Source      : in RWops;
      Close_After : in Boolean := False)
      return Ada.Streams.Stream_Element_Array
   is
      Data_Size : aliased C.size_t := 0;
      Buffer    : System.Address;
   begin
      Ensure_Valid (Source);

      Buffer :=
        Raw.Load_File_IO
          (Get_Handle (Source),
           Data_Size'Access,
           To_C_Bool (Close_After));

      if Buffer = System.Null_Address then
         Raise_Last_Error;
      end if;

      declare
         Result : constant Ada.Streams.Stream_Element_Array :=
           To_Stream_Elements (Buffer, Data_Size);
      begin
         SDL_Free (Buffer);
         return Result;
      exception
         when others =>
            SDL_Free (Buffer);
            raise;
      end;
   end Load_File;

   function Load_File
     (File_Name : in UTF_Strings.UTF_String)
      return Ada.Streams.Stream_Element_Array
   is
      Data_Size : aliased C.size_t := 0;
      Buffer    : System.Address;
   begin
      Buffer := Raw.Load_File (C.To_C (File_Name), Data_Size'Access);
      if Buffer = System.Null_Address then
         Raise_Last_Error;
      end if;

      declare
         Result : constant Ada.Streams.Stream_Element_Array :=
           To_Stream_Elements (Buffer, Data_Size);
      begin
         SDL_Free (Buffer);
         return Result;
      exception
         when others =>
            SDL_Free (Buffer);
            raise;
      end;
   end Load_File;

   procedure Save_File
     (Destination : in RWops;
      Data        : in Ada.Streams.Stream_Element_Array;
      Close_After : in Boolean := False)
   is
      Address : constant System.Address :=
        (if Data'Length = 0 then System.Null_Address else Data'Address);
   begin
      Save_File (Destination, Address, Natural (Data'Length), Close_After);
   end Save_File;

   procedure Save_File
     (Destination : in RWops;
      Data        : in System.Address;
      Size        : in Natural;
      Close_After : in Boolean := False)
   is
   begin
      Ensure_Valid (Destination);

      if not Boolean
          (Raw.Save_File_IO
             (Get_Handle (Destination),
              Data,
              C.size_t (Size),
              To_C_Bool (Close_After)))
      then
         Raise_Last_Error;
      end if;
   end Save_File;

   procedure Save_File
     (File_Name : in UTF_Strings.UTF_String;
      Data      : in Ada.Streams.Stream_Element_Array)
   is
      Address : constant System.Address :=
        (if Data'Length = 0 then System.Null_Address else Data'Address);
   begin
      Save_File (File_Name, Address, Natural (Data'Length));
   end Save_File;

   procedure Save_File
     (File_Name : in UTF_Strings.UTF_String;
      Data      : in System.Address;
      Size      : in Natural)
   is
   begin
      if not Boolean
          (Raw.Save_File
             (C.To_C (File_Name),
              Data,
              C.size_t (Size)))
      then
         Raise_Last_Error;
      end if;
   end Save_File;

   function Read_U_8 (Src : in RWops) return Uint8 is
      Value : aliased Uint8 := 0;
   begin
      Ensure_Valid (Src);

      if not Boolean (Raw.Read_U_8 (Get_Handle (Src), Value'Access)) then
         Raise_Last_Error;
      end if;

      return Value;
   end Read_U_8;

   function Read_S_8 (Src : in RWops) return Sint8 is
      Value : aliased Sint8 := 0;
   begin
      Ensure_Valid (Src);

      if not Boolean (Raw.Read_S_8 (Get_Handle (Src), Value'Access)) then
         Raise_Last_Error;
      end if;

      return Value;
   end Read_S_8;

   function Read_LE_16 (Src : in RWops) return Uint16 is
      Value : aliased Uint16 := 0;
   begin
      Ensure_Valid (Src);

      if not Boolean (Raw.Read_U_16_Le (Get_Handle (Src), Value'Access)) then
         Raise_Last_Error;
      end if;

      return Value;
   end Read_LE_16;

   function Read_S_LE_16 (Src : in RWops) return Sint16 is
      Value : aliased Sint16 := 0;
   begin
      Ensure_Valid (Src);

      if not Boolean (Raw.Read_S_16_Le (Get_Handle (Src), Value'Access)) then
         Raise_Last_Error;
      end if;

      return Value;
   end Read_S_LE_16;

   function Read_BE_16 (Src : in RWops) return Uint16 is
      Value : aliased Uint16 := 0;
   begin
      Ensure_Valid (Src);

      if not Boolean (Raw.Read_U_16_Be (Get_Handle (Src), Value'Access)) then
         Raise_Last_Error;
      end if;

      return Value;
   end Read_BE_16;

   function Read_S_BE_16 (Src : in RWops) return Sint16 is
      Value : aliased Sint16 := 0;
   begin
      Ensure_Valid (Src);

      if not Boolean (Raw.Read_S_16_Be (Get_Handle (Src), Value'Access)) then
         Raise_Last_Error;
      end if;

      return Value;
   end Read_S_BE_16;

   function Read_LE_32 (Src : in RWops) return Uint32 is
      Value : aliased Uint32 := 0;
   begin
      Ensure_Valid (Src);

      if not Boolean (Raw.Read_U_32_Le (Get_Handle (Src), Value'Access)) then
         Raise_Last_Error;
      end if;

      return Value;
   end Read_LE_32;

   function Read_S_LE_32 (Src : in RWops) return Sint32 is
      Value : aliased Sint32 := 0;
   begin
      Ensure_Valid (Src);

      if not Boolean (Raw.Read_S_32_Le (Get_Handle (Src), Value'Access)) then
         Raise_Last_Error;
      end if;

      return Value;
   end Read_S_LE_32;

   function Read_BE_32 (Src : in RWops) return Uint32 is
      Value : aliased Uint32 := 0;
   begin
      Ensure_Valid (Src);

      if not Boolean (Raw.Read_U_32_Be (Get_Handle (Src), Value'Access)) then
         Raise_Last_Error;
      end if;

      return Value;
   end Read_BE_32;

   function Read_S_BE_32 (Src : in RWops) return Sint32 is
      Value : aliased Sint32 := 0;
   begin
      Ensure_Valid (Src);

      if not Boolean (Raw.Read_S_32_Be (Get_Handle (Src), Value'Access)) then
         Raise_Last_Error;
      end if;

      return Value;
   end Read_S_BE_32;

   function Read_LE_64 (Src : in RWops) return Uint64 is
      Value : aliased Uint64 := 0;
   begin
      Ensure_Valid (Src);

      if not Boolean (Raw.Read_U_64_Le (Get_Handle (Src), Value'Access)) then
         Raise_Last_Error;
      end if;

      return Value;
   end Read_LE_64;

   function Read_S_LE_64 (Src : in RWops) return Sint64 is
      Value : aliased Sint64 := 0;
   begin
      Ensure_Valid (Src);

      if not Boolean (Raw.Read_S_64_Le (Get_Handle (Src), Value'Access)) then
         Raise_Last_Error;
      end if;

      return Value;
   end Read_S_LE_64;

   function Read_BE_64 (Src : in RWops) return Uint64 is
      Value : aliased Uint64 := 0;
   begin
      Ensure_Valid (Src);

      if not Boolean (Raw.Read_U_64_Be (Get_Handle (Src), Value'Access)) then
         Raise_Last_Error;
      end if;

      return Value;
   end Read_BE_64;

   function Read_S_BE_64 (Src : in RWops) return Sint64 is
      Value : aliased Sint64 := 0;
   begin
      Ensure_Valid (Src);

      if not Boolean (Raw.Read_S_64_Be (Get_Handle (Src), Value'Access)) then
         Raise_Last_Error;
      end if;

      return Value;
   end Read_S_BE_64;

   procedure Write_U_8 (Destination : in RWops; Value : in Uint8) is
   begin
      Ensure_Valid (Destination);

      if not Boolean (Raw.Write_U_8 (Get_Handle (Destination), Value)) then
         Raise_Last_Error;
      end if;
   end Write_U_8;

   procedure Write_S_8 (Destination : in RWops; Value : in Sint8) is
   begin
      Ensure_Valid (Destination);

      if not Boolean (Raw.Write_S_8 (Get_Handle (Destination), Value)) then
         Raise_Last_Error;
      end if;
   end Write_S_8;

   procedure Write_LE_16 (Destination : in RWops; Value : in Uint16) is
   begin
      Ensure_Valid (Destination);

      if not Boolean (Raw.Write_U_16_Le (Get_Handle (Destination), Value)) then
         Raise_Last_Error;
      end if;
   end Write_LE_16;

   procedure Write_S_LE_16 (Destination : in RWops; Value : in Sint16) is
   begin
      Ensure_Valid (Destination);

      if not Boolean (Raw.Write_S_16_Le (Get_Handle (Destination), Value)) then
         Raise_Last_Error;
      end if;
   end Write_S_LE_16;

   procedure Write_BE_16 (Destination : in RWops; Value : in Uint16) is
   begin
      Ensure_Valid (Destination);

      if not Boolean (Raw.Write_U_16_Be (Get_Handle (Destination), Value)) then
         Raise_Last_Error;
      end if;
   end Write_BE_16;

   procedure Write_S_BE_16 (Destination : in RWops; Value : in Sint16) is
   begin
      Ensure_Valid (Destination);

      if not Boolean (Raw.Write_S_16_Be (Get_Handle (Destination), Value)) then
         Raise_Last_Error;
      end if;
   end Write_S_BE_16;

   procedure Write_LE_32 (Destination : in RWops; Value : in Uint32) is
   begin
      Ensure_Valid (Destination);

      if not Boolean (Raw.Write_U_32_Le (Get_Handle (Destination), Value)) then
         Raise_Last_Error;
      end if;
   end Write_LE_32;

   procedure Write_S_LE_32 (Destination : in RWops; Value : in Sint32) is
   begin
      Ensure_Valid (Destination);

      if not Boolean (Raw.Write_S_32_Le (Get_Handle (Destination), Value)) then
         Raise_Last_Error;
      end if;
   end Write_S_LE_32;

   procedure Write_BE_32 (Destination : in RWops; Value : in Uint32) is
   begin
      Ensure_Valid (Destination);

      if not Boolean (Raw.Write_U_32_Be (Get_Handle (Destination), Value)) then
         Raise_Last_Error;
      end if;
   end Write_BE_32;

   procedure Write_S_BE_32 (Destination : in RWops; Value : in Sint32) is
   begin
      Ensure_Valid (Destination);

      if not Boolean (Raw.Write_S_32_Be (Get_Handle (Destination), Value)) then
         Raise_Last_Error;
      end if;
   end Write_S_BE_32;

   procedure Write_LE_64 (Destination : in RWops; Value : in Uint64) is
   begin
      Ensure_Valid (Destination);

      if not Boolean (Raw.Write_U_64_Le (Get_Handle (Destination), Value)) then
         Raise_Last_Error;
      end if;
   end Write_LE_64;

   procedure Write_S_LE_64 (Destination : in RWops; Value : in Sint64) is
   begin
      Ensure_Valid (Destination);

      if not Boolean (Raw.Write_S_64_Le (Get_Handle (Destination), Value)) then
         Raise_Last_Error;
      end if;
   end Write_S_LE_64;

   procedure Write_BE_64 (Destination : in RWops; Value : in Uint64) is
   begin
      Ensure_Valid (Destination);

      if not Boolean (Raw.Write_U_64_Be (Get_Handle (Destination), Value)) then
         Raise_Last_Error;
      end if;
   end Write_BE_64;

   procedure Write_S_BE_64 (Destination : in RWops; Value : in Sint64) is
   begin
      Ensure_Valid (Destination);

      if not Boolean (Raw.Write_S_64_Be (Get_Handle (Destination), Value)) then
         Raise_Last_Error;
      end if;
   end Write_S_BE_64;

   function Is_Null (Source : in RWops) return Boolean is
   begin
      return Source = null;
   end Is_Null;
end SDL.RWops;
