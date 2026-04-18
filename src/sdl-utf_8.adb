with Ada.Unchecked_Conversion;

with Interfaces.C;
with System;
with System.Storage_Elements;

package body SDL.UTF_8 is
   package C renames Interfaces.C;
   package Raw renames SDL.Raw.UTF_8;
   package SSE renames System.Storage_Elements;

   use type Raw.Char_Pointers;
   use type SSE.Integer_Address;
   use type SSE.Storage_Offset;

   function To_Char_Pointer is new Ada.Unchecked_Conversion
     (System.Address, Raw.Char_Pointers);
   function To_Address is new Ada.Unchecked_Conversion
     (Raw.Char_Pointers, System.Address);

   subtype Buffer_Index is C.size_t range 0 .. 4;
   type UTF_8_Buffers is array (Buffer_Index) of aliased C.char with
     Convention => C;

   function Step
     (Item     : in String;
      Position : in out Natural) return Code_Points
   is
      Remaining : aliased C.size_t := 0;
      Current   : aliased Raw.Char_Pointers := null;
      Start     : System.Address;
      Result    : Code_Points;
      Advanced  : SSE.Storage_Offset := 0;
   begin
      if Item'Length = 0 or else Position >= Item'Length then
         return 0;
      end if;

      Start := Item (Item'First + Position)'Address;
      Current := To_Char_Pointer (Start);
      Remaining := C.size_t (Item'Length - Position);

      Result := Raw.Step (Current'Access, Remaining'Access);
      Advanced :=
        SSE.Storage_Offset
          (SSE.To_Integer (To_Address (Current)) - SSE.To_Integer (Start));

      if Advanced > 0 then
         Position := Position + Natural (Advanced);
      end if;

      return Result;
   end Step;

   function Encode (Code_Point : in Code_Points) return String is
      Buffer : aliased UTF_8_Buffers := [others => C.char'Val (0)];
      Start  : constant Raw.Char_Pointers :=
        To_Char_Pointer (Buffer (Buffer'First)'Address);
      Last   : constant Raw.Char_Pointers := Raw.Encode (Code_Point, Start);
      Length : constant Natural :=
        (if Last = null then
            0
         else
            Natural
              (SSE.To_Integer (To_Address (Last)) -
               SSE.To_Integer (To_Address (Start))));
      Result : String (1 .. Length);
   begin
      for Offset in 0 .. Length - 1 loop
         Result (Result'First + Offset) :=
           Character'Val (C.char'Pos (Buffer (C.size_t (Offset))));
      end loop;

      return Result;
   end Encode;
end SDL.UTF_8;
