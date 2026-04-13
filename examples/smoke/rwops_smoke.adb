with Ada.Directories;
with Ada.Exceptions;
with Ada.Streams;
with Ada.Text_IO;
with Interfaces;
with Interfaces.C;
with Interfaces.C.Extensions;
with System;
with System.Address_To_Access_Conversions;
with System.Storage_Elements;

with SDL.Properties;
with SDL.Raw.IOStream;
with SDL.RWops;
with SDL.RWops.Streams;

procedure RWops_Smoke is
   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;
   package SSE renames System.Storage_Elements;

   use type Ada.Streams.Stream_Element;
   use type Ada.Streams.Stream_Element_Offset;
   use type Interfaces.Integer_8;
   use type Interfaces.Integer_16;
   use type Interfaces.Integer_32;
   use type Interfaces.Integer_64;
   use type Interfaces.Unsigned_8;
   use type Interfaces.Unsigned_16;
   use type Interfaces.Unsigned_32;
   use type Interfaces.Unsigned_64;
   use type SDL.Properties.Property_Numbers;
   use type SDL.Raw.IOStream.Offsets;
   use type SDL.Raw.IOStream.Status;
   use type SDL.Raw.IOStream.Whence;
   use type SDL.RWops.Handle;
   use type SDL.RWops.Offsets;
   use type SDL.RWops.Property_ID;
   use type SSE.Integer_Address;

   File_Path : constant String := "/tmp/sdl3ada-rwops-smoke.bin";

   Expected_File_Bytes : constant Ada.Streams.Stream_Element_Array (1 .. 15) :=
     (1  => 16#12#,
      2  => 16#56#,
      3  => 16#34#,
      4  => 16#78#,
      5  => 16#9A#,
      6  => 16#BC#,
      7  => 16#DE#,
      8  => 16#EF#,
      9  => 16#CD#,
      10 => 16#AB#,
      11 => 16#89#,
      12 => 16#67#,
      13 => 16#45#,
      14 => 16#23#,
      15 => 16#01#);

   Expected_Dynamic_Bytes : constant Ada.Streams.Stream_Element_Array (1 .. 19) :=
     (1  => 16#12#,
      2  => 16#56#,
      3  => 16#34#,
      4  => 16#78#,
      5  => 16#9A#,
      6  => 16#BC#,
      7  => 16#DE#,
      8  => 16#EF#,
      9  => 16#CD#,
      10 => 16#AB#,
      11 => 16#89#,
      12 => 16#67#,
      13 => 16#45#,
      14 => 16#23#,
      15 => 16#01#,
      16 => Ada.Streams.Stream_Element (Character'Pos ('X')),
      17 => Ada.Streams.Stream_Element (Character'Pos ('Y')),
      18 => Ada.Streams.Stream_Element (Character'Pos ('Z')),
      19 => Ada.Streams.Stream_Element (Character'Pos ('!')));

   Expected_Custom_Bytes : constant Ada.Streams.Stream_Element_Array (1 .. 4) :=
     (1 => Ada.Streams.Stream_Element (Character'Pos ('A')),
      2 => Ada.Streams.Stream_Element (Character'Pos ('d')),
      3 => Ada.Streams.Stream_Element (Character'Pos ('a')),
      4 => Ada.Streams.Stream_Element (Character'Pos ('!')));

   type Custom_State is record
      Buffer      : Ada.Streams.Stream_Element_Array (1 .. 32) := (others => 0);
      Length      : Natural := 0;
      Position    : Natural := 0;
      Flush_Count : Natural := 0;
      Closed      : Boolean := False;
   end record;

   package Custom_State_Pointers is new System.Address_To_Access_Conversions
     (Custom_State);
   package Byte_Pointers is new System.Address_To_Access_Conversions
     (Ada.Streams.Stream_Element);

   use type Byte_Pointers.Object_Pointer;
   use type Custom_State_Pointers.Object_Pointer;

   procedure Require (Condition : in Boolean; Message : in String);

   function Matches_Expected
     (Actual   : in Ada.Streams.Stream_Element_Array;
      Expected : in Ada.Streams.Stream_Element_Array) return Boolean;

   procedure Cleanup_File;

   function Custom_Size
     (User_Data : in System.Address) return SDL.Raw.IOStream.Offsets
   with Convention => C;

   function Custom_Seek
     (User_Data : in System.Address;
      Offset    : in SDL.Raw.IOStream.Offsets;
      Origin    : in SDL.Raw.IOStream.Whence) return SDL.Raw.IOStream.Offsets
   with Convention => C;

   function Custom_Read
     (User_Data : in System.Address;
      Pointer   : in System.Address;
      Size      : in C.size_t;
      Result    : access SDL.Raw.IOStream.Status) return C.size_t
   with Convention => C;

   function Custom_Write
     (User_Data : in System.Address;
      Pointer   : in System.Address;
      Size      : in C.size_t;
      Result    : access SDL.Raw.IOStream.Status) return C.size_t
   with Convention => C;

   function Custom_Flush
     (User_Data : in System.Address;
      Result    : access SDL.Raw.IOStream.Status) return CE.bool
   with Convention => C;

   function Custom_Close
     (User_Data : in System.Address) return CE.bool
   with Convention => C;

   procedure Require (Condition : in Boolean; Message : in String) is
   begin
      if not Condition then
         raise Program_Error with Message;
      end if;
   end Require;

   function Matches_Expected
     (Actual   : in Ada.Streams.Stream_Element_Array;
      Expected : in Ada.Streams.Stream_Element_Array) return Boolean
   is
   begin
      if Actual'Length /= Expected'Length then
         return False;
      end if;

      for Offset in Expected'Range loop
         if Actual (Actual'First + (Offset - Expected'First)) /= Expected (Offset) then
            return False;
         end if;
      end loop;

      return True;
   end Matches_Expected;

   procedure Cleanup_File is
   begin
      if Ada.Directories.Exists (File_Path) then
         Ada.Directories.Delete_File (File_Path);
      end if;
   exception
      when Ada.Directories.Name_Error | Ada.Directories.Use_Error =>
         null;
   end Cleanup_File;

   function Custom_Size
     (User_Data : in System.Address) return SDL.Raw.IOStream.Offsets
   is
      State : constant Custom_State_Pointers.Object_Pointer :=
        Custom_State_Pointers.To_Pointer (User_Data);
   begin
      if State = null then
         return -1;
      end if;

      return SDL.Raw.IOStream.Offsets (State.all.Length);
   end Custom_Size;

   function Custom_Seek
     (User_Data : in System.Address;
      Offset    : in SDL.Raw.IOStream.Offsets;
      Origin    : in SDL.Raw.IOStream.Whence) return SDL.Raw.IOStream.Offsets
   is
      State  : constant Custom_State_Pointers.Object_Pointer :=
        Custom_State_Pointers.To_Pointer (User_Data);
      Base   : Integer;
      Target : Integer;
   begin
      if State = null then
         return -1;
      end if;

      case Origin is
         when SDL.Raw.IOStream.Seek_Set =>
            Base := 0;
         when SDL.Raw.IOStream.Seek_Cur =>
            Base := State.all.Position;
         when SDL.Raw.IOStream.Seek_End =>
            Base := State.all.Length;
      end case;

      Target := Base + Integer (Offset);
      if Target < 0 or else Target > State.all.Length then
         return -1;
      end if;

      State.all.Position := Natural (Target);
      return SDL.Raw.IOStream.Offsets (Target);
   end Custom_Seek;

   function Custom_Read
     (User_Data : in System.Address;
      Pointer   : in System.Address;
      Size      : in C.size_t;
      Result    : access SDL.Raw.IOStream.Status) return C.size_t
   is
      State     : constant Custom_State_Pointers.Object_Pointer :=
        Custom_State_Pointers.To_Pointer (User_Data);
      Remaining : Natural;
      Count     : Natural;
      Address   : System.Address := Pointer;
   begin
      if State = null then
         if Result /= null then
            Result.all := SDL.Raw.IOStream.Error;
         end if;
         return 0;
      end if;

      if State.all.Position >= State.all.Length then
         if Result /= null then
            Result.all := SDL.Raw.IOStream.End_Of_File;
         end if;
         return 0;
      end if;

      Remaining := State.all.Length - State.all.Position;
      Count := Natural'Min (Natural (Size), Remaining);

      for Index in 0 .. Count - 1 loop
         Byte_Pointers.To_Pointer (Address).all :=
           State.all.Buffer
             (State.all.Buffer'First +
                Ada.Streams.Stream_Element_Offset (State.all.Position + Index));
         Address :=
           SSE.To_Address
             (SSE.To_Integer (Address) + SSE.Integer_Address (1));
      end loop;

      State.all.Position := State.all.Position + Count;

      if Result /= null then
         Result.all := SDL.Raw.IOStream.Ready;
      end if;

      return C.size_t (Count);
   end Custom_Read;

   function Custom_Write
     (User_Data : in System.Address;
      Pointer   : in System.Address;
      Size      : in C.size_t;
      Result    : access SDL.Raw.IOStream.Status) return C.size_t
   is
      State     : constant Custom_State_Pointers.Object_Pointer :=
        Custom_State_Pointers.To_Pointer (User_Data);
      Remaining : Natural;
      Count     : Natural;
      Address   : System.Address := Pointer;
   begin
      if State = null then
         if Result /= null then
            Result.all := SDL.Raw.IOStream.Error;
         end if;
         return 0;
      end if;

      Remaining := State.all.Buffer'Length - State.all.Position;
      Count := Natural'Min (Natural (Size), Remaining);

      for Index in 0 .. Count - 1 loop
         State.all.Buffer
           (State.all.Buffer'First +
              Ada.Streams.Stream_Element_Offset (State.all.Position + Index)) :=
           Byte_Pointers.To_Pointer (Address).all;
         Address :=
           SSE.To_Address
             (SSE.To_Integer (Address) + SSE.Integer_Address (1));
      end loop;

      State.all.Position := State.all.Position + Count;
      State.all.Length := Natural'Max (State.all.Length, State.all.Position);

      if Result /= null then
         Result.all :=
           (if Count = Natural (Size)
            then SDL.Raw.IOStream.Ready
            else SDL.Raw.IOStream.Error);
      end if;

      return C.size_t (Count);
   end Custom_Write;

   function Custom_Flush
     (User_Data : in System.Address;
      Result    : access SDL.Raw.IOStream.Status) return CE.bool
   is
      State : constant Custom_State_Pointers.Object_Pointer :=
        Custom_State_Pointers.To_Pointer (User_Data);
   begin
      if State = null then
         if Result /= null then
            Result.all := SDL.Raw.IOStream.Error;
         end if;
         return CE.bool'Val (0);
      end if;

      State.all.Flush_Count := State.all.Flush_Count + 1;
      if Result /= null then
         Result.all := SDL.Raw.IOStream.Ready;
      end if;
      return CE.bool'Val (1);
   end Custom_Flush;

   function Custom_Close
     (User_Data : in System.Address) return CE.bool
   is
      State : constant Custom_State_Pointers.Object_Pointer :=
        Custom_State_Pointers.To_Pointer (User_Data);
   begin
      if State = null then
         return CE.bool'Val (0);
      end if;

      State.all.Closed := True;
      return CE.bool'Val (1);
   end Custom_Close;
begin
   Cleanup_File;

   declare
      Buffer : aliased Ada.Streams.Stream_Element_Array (1 .. 16) :=
        (others => 0);
      Memory_Ops : constant SDL.RWops.RWops :=
        SDL.RWops.From_Memory (Buffer'Address, Natural (Buffer'Length));
      Memory_Stream : SDL.RWops.Streams.RWops_Stream :=
        SDL.RWops.Streams.Open (Memory_Ops);
      Memory_Props : constant SDL.Properties.Property_Set :=
        SDL.Properties.Reference (SDL.RWops.Get_Properties (Memory_Ops));
   begin
      Require
        (SDL.RWops.Get_Handle (Memory_Ops) /= null,
         "Memory RWops handle should be valid");
      Require
        (SDL.RWops.Get_Properties (Memory_Ops) /= SDL.RWops.Null_Property_ID,
         "Memory RWops properties should be available");
      Require
        (Memory_Props.Get_Number (SDL.RWops.Memory_Size_Property) =
           SDL.Properties.Property_Numbers (Buffer'Length),
         "Memory RWops reported the wrong property size");
      Require
        (SDL.RWops.Size (Memory_Ops) = SDL.RWops.Offsets (Buffer'Length),
         "Memory RWops reported the wrong size");
      Require
        (SDL.RWops.Tell (Memory_Ops) = SDL.RWops.Null_Offset,
         "Memory RWops did not start at offset zero");

      SDL.RWops.Streams.Write
        (Memory_Stream,
         (1 => 16#DE#, 2 => 16#AD#, 3 => 16#BE#, 4 => 16#EF#));

      Require
        (SDL.RWops.Tell (Memory_Ops) = 4,
         "Memory stream write did not advance the offset");

      Require
        (SDL.RWops.Seek (Memory_Ops, 0, SDL.RWops.RW_Seek_Set) = 0,
         "Memory seek-to-start failed");
      Require
        (SDL.RWops.Read_U_8 (Memory_Ops) = 16#DE#
           and then SDL.RWops.Read_U_8 (Memory_Ops) = 16#AD#
           and then SDL.RWops.Read_U_8 (Memory_Ops) = 16#BE#
           and then SDL.RWops.Read_U_8 (Memory_Ops) = 16#EF#,
         "Memory round-trip bytes did not match");

      SDL.RWops.Streams.Close (Memory_Stream);
   end;

   declare
      Buffer : aliased Ada.Streams.Stream_Element_Array (1 .. 15) :=
        (others => 0);
      Signed_Ops : constant SDL.RWops.RWops :=
        SDL.RWops.From_Memory (Buffer'Address, Natural (Buffer'Length));
   begin
      SDL.RWops.Write_S_8 (Signed_Ops, -1);
      SDL.RWops.Write_S_LE_16 (Signed_Ops, -16#1234#);
      SDL.RWops.Write_S_BE_32 (Signed_Ops, -16#0123_4567#);
      SDL.RWops.Write_S_LE_64 (Signed_Ops, -16#0123_4567_89AB_CDEF#);

      Require
        (SDL.RWops.Seek (Signed_Ops, 0, SDL.RWops.RW_Seek_Set) = 0,
         "Signed memory seek-to-start failed");
      Require
        (SDL.RWops.Read_S_8 (Signed_Ops) = -1,
         "Read_S_8 returned the wrong value");
      Require
        (SDL.RWops.Read_S_LE_16 (Signed_Ops) = -16#1234#,
         "Read_S_LE_16 returned the wrong value");
      Require
        (SDL.RWops.Read_S_BE_32 (Signed_Ops) = -16#0123_4567#,
         "Read_S_BE_32 returned the wrong value");
      Require
        (SDL.RWops.Read_S_LE_64 (Signed_Ops) = -16#0123_4567_89AB_CDEF#,
         "Read_S_LE_64 returned the wrong value");

      SDL.RWops.Close (Signed_Ops);
   end;

   declare
      Dynamic_Ops : constant SDL.RWops.RWops := SDL.RWops.From_Dynamic_Memory;
      Dynamic_Props : constant SDL.Properties.Property_Set :=
        SDL.Properties.Reference (SDL.RWops.Get_Properties (Dynamic_Ops));
      Extra_Byte : aliased Ada.Streams.Stream_Element_Array (1 .. 1) :=
        (1 => Ada.Streams.Stream_Element (Character'Pos ('!')));
   begin
      SDL.RWops.Save_File (Dynamic_Ops, Expected_File_Bytes);
      SDL.RWops.Put (Dynamic_Ops, "XYZ");
      Require
        (SDL.RWops.Write
           (Dynamic_Ops, Extra_Byte'Address, Natural (Extra_Byte'Length)) =
             Extra_Byte'Length,
         "Dynamic memory block write returned the wrong byte count");
      SDL.RWops.Flush (Dynamic_Ops);

      Require
        (SDL.RWops.Size (Dynamic_Ops) = 19,
         "Dynamic memory RWops reported the wrong size");
      Require
        (Dynamic_Props.Has (SDL.RWops.Dynamic_Memory_Property),
         "Dynamic memory pointer property missing");

      Require
        (SDL.RWops.Seek (Dynamic_Ops, 0, SDL.RWops.RW_Seek_Set) = 0,
         "Dynamic memory seek-to-start failed");

      declare
         Dynamic_Data : constant Ada.Streams.Stream_Element_Array :=
           SDL.RWops.Load_File (Dynamic_Ops);
      begin
         Require
           (Matches_Expected (Dynamic_Data, Expected_Dynamic_Bytes),
            "Dynamic memory helper round trip did not match");

         SDL.RWops.Save_File (File_Path, Dynamic_Data);
         Require
           (Matches_Expected (SDL.RWops.Load_File (File_Path), Expected_Dynamic_Bytes),
            "Path load/save helpers did not preserve the expected bytes");
      end;

      SDL.RWops.Close (Dynamic_Ops);
   end;

   declare
      File_Ops : constant SDL.RWops.RWops :=
        SDL.RWops.From_File
          (File_Path, SDL.RWops.Create_To_Read_Write_Binary);
   begin
      SDL.RWops.Write_U_8 (File_Ops, 16#12#);
      SDL.RWops.Write_LE_16 (File_Ops, 16#3456#);
      SDL.RWops.Write_BE_32 (File_Ops, 16#789A_BCDE#);
      SDL.RWops.Write_LE_64 (File_Ops, 16#0123_4567_89AB_CDEF#);
      SDL.RWops.Flush (File_Ops);

      Require
        (SDL.RWops.Tell (File_Ops) = 15,
         "File RWops did not advance by the expected byte count");
      Require
        (SDL.RWops.Size (File_Ops) = 15,
         "File RWops reported the wrong size after writing");

      SDL.RWops.Close (File_Ops);
   end;

   declare
      File_Ops : constant SDL.RWops.RWops :=
        SDL.RWops.From_File (File_Path, SDL.RWops.Read_Binary);
      File_Props : constant SDL.Properties.Property_Set :=
        SDL.Properties.Reference (SDL.RWops.Get_Properties (File_Ops));
      EOF_Buffer : aliased Ada.Streams.Stream_Element_Array (1 .. 1) := (others => 0);
   begin
      Require
        (SDL.RWops.Get_Handle (File_Ops) /= null,
         "File RWops handle should be valid");
      Require
        (SDL.RWops.Get_Properties (File_Ops) /= SDL.RWops.Null_Property_ID,
         "File RWops properties should be available");
      Require
        (not File_Props.Is_Null,
         "File properties wrapper should be valid");
      Require
        (SDL.RWops.Status (File_Ops) = SDL.RWops.Ready,
         "Freshly opened file RWops should start ready");
      Require
        (SDL.RWops.Size (File_Ops) = 15,
         "Reopened file RWops reported the wrong size");
      Require
        (SDL.RWops.Read_U_8 (File_Ops) = 16#12#,
         "Read_U_8 returned the wrong value");
      Require
        (SDL.RWops.Read_LE_16 (File_Ops) = 16#3456#,
         "Read_LE_16 returned the wrong value");
      Require
        (SDL.RWops.Read_BE_32 (File_Ops) = 16#789A_BCDE#,
         "Read_BE_32 returned the wrong value");
      Require
        (SDL.RWops.Read_LE_64 (File_Ops) = 16#0123_4567_89AB_CDEF#,
         "Read_LE_64 returned the wrong value");
      Require
        (SDL.RWops.Tell (File_Ops) = 15,
         "File RWops did not end at the expected offset");

      Require
        (SDL.RWops.Read (File_Ops, EOF_Buffer'Address, Natural (EOF_Buffer'Length)) = 0,
         "Block read at EOF should return zero");
      Require
        (SDL.RWops.Status (File_Ops) = SDL.RWops.End_Of_File,
         "EOF read should update the RWops status");

      SDL.RWops.Close (File_Ops);
   end;

   declare
      File_Ops : constant SDL.RWops.RWops :=
        SDL.RWops.From_File (File_Path, SDL.RWops.Read_Binary);
      File_Stream : SDL.RWops.Streams.RWops_Stream :=
        SDL.RWops.Streams.Open (File_Ops);
      Read_Buffer : Ada.Streams.Stream_Element_Array (1 .. 17) :=
        (others => 0);
      EOF_Buffer : Ada.Streams.Stream_Element_Array (1 .. 1) := (others => 0);
      Last : Ada.Streams.Stream_Element_Offset;
      EOF_Last : Ada.Streams.Stream_Element_Offset;
   begin
      SDL.RWops.Streams.Read (File_Stream, Read_Buffer, Last);

      Require
        (Last = 15,
         "Stream read did not report the expected partial-read boundary");
      Require
        (Matches_Expected (Read_Buffer (Expected_File_Bytes'Range), Expected_File_Bytes),
         "Stream read bytes did not match the low-level writes");

      SDL.RWops.Streams.Read (File_Stream, EOF_Buffer, EOF_Last);
      Require
        (EOF_Last = EOF_Buffer'First - 1,
         "Stream read at EOF should report no bytes read");

      SDL.RWops.Streams.Close (File_Stream);
   end;

   declare
      State : aliased Custom_State;
      Interface_Definition : SDL.RWops.IO_Stream_Interface :=
        SDL.RWops.Create_Interface;
      Custom_Ops : SDL.RWops.RWops;
      Read_Back : aliased Ada.Streams.Stream_Element_Array (1 .. 4) :=
        (others => 0);
      EOF_Byte : aliased Ada.Streams.Stream_Element_Array (1 .. 1) := (others => 0);
      Loaded_Custom : Ada.Streams.Stream_Element_Array (1 .. 4);
   begin
      Interface_Definition.Size := Custom_Size'Unrestricted_Access;
      Interface_Definition.Seek := Custom_Seek'Unrestricted_Access;
      Interface_Definition.Read := Custom_Read'Unrestricted_Access;
      Interface_Definition.Write := Custom_Write'Unrestricted_Access;
      Interface_Definition.Flush := Custom_Flush'Unrestricted_Access;
      Interface_Definition.Close := Custom_Close'Unrestricted_Access;

      SDL.RWops.Open (Interface_Definition, State'Address, Custom_Ops);

      Require
        (SDL.RWops.Write
           (Custom_Ops,
            Expected_Custom_Bytes'Address,
            Natural (Expected_Custom_Bytes'Length)) = Expected_Custom_Bytes'Length,
         "Custom IO block write returned the wrong byte count");
      SDL.RWops.Flush (Custom_Ops);
      Require (State.Flush_Count = 1, "Custom flush callback was not invoked");

      Require
        (SDL.RWops.Seek (Custom_Ops, 0, SDL.RWops.RW_Seek_Set) = 0,
         "Custom IO seek-to-start failed");
      Loaded_Custom := SDL.RWops.Load_File (Custom_Ops);
      Require
        (Matches_Expected (Loaded_Custom, Expected_Custom_Bytes),
         "Custom IO load helper did not return the expected bytes");

      Require
        (SDL.RWops.Seek (Custom_Ops, 0, SDL.RWops.RW_Seek_Set) = 0,
         "Custom IO second seek-to-start failed");
      Require
        (SDL.RWops.Read
           (Custom_Ops, Read_Back'Address, Natural (Read_Back'Length)) =
             Read_Back'Length,
         "Custom IO block read returned the wrong byte count");
      Require
        (Matches_Expected (Read_Back, Expected_Custom_Bytes),
         "Custom IO block read returned the wrong bytes");
      Require
        (SDL.RWops.Read (Custom_Ops, EOF_Byte'Address, Natural (EOF_Byte'Length)) = 0,
         "Custom IO EOF read should return zero");
      Require
        (SDL.RWops.Status (Custom_Ops) = SDL.RWops.End_Of_File,
         "Custom IO EOF read should update the status");

      SDL.RWops.Close (Custom_Ops);
      Require (State.Closed, "Custom close callback was not invoked");
   end;

   Cleanup_File;
   Ada.Text_IO.Put_Line ("RWops smoke completed successfully.");
exception
   when E : others =>
      Cleanup_File;
      Ada.Text_IO.Put_Line (Ada.Exceptions.Exception_Information (E));
      raise;
end RWops_Smoke;
