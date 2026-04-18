with System;

with SDL.Raw.Audio;

package SDL.Audio.Sample_Formats is
   pragma Preelaborate;

   type Sample_Bit_Size is mod 2 ** 8 with
     Convention => C;

   type Sample_Endianness is (Little_Endian, Big_Endian) with
     Convention => C;

   use type System.Bit_Order;

   System_Endianness : constant Sample_Endianness :=
     (if System.Default_Bit_Order = System.High_Order_First
      then Big_Endian
      else Little_Endian);

   Unknown : constant SDL.Audio.Sample_Format :=
     SDL.Audio.Sample_Format (SDL.Raw.Audio.Unknown);

   Sample_Format_U8 : constant SDL.Audio.Sample_Format :=
     SDL.Audio.Sample_Format (SDL.Raw.Audio.Sample_Format_U8);
   Sample_Format_S8 : constant SDL.Audio.Sample_Format :=
     SDL.Audio.Sample_Format (SDL.Raw.Audio.Sample_Format_S8);

   Sample_Format_S16LSB : constant SDL.Audio.Sample_Format :=
     SDL.Audio.Sample_Format (SDL.Raw.Audio.Sample_Format_S16LSB);
   Sample_Format_S16MSB : constant SDL.Audio.Sample_Format :=
     SDL.Audio.Sample_Format (SDL.Raw.Audio.Sample_Format_S16MSB);

   Sample_Format_S32LSB : constant SDL.Audio.Sample_Format :=
     SDL.Audio.Sample_Format (SDL.Raw.Audio.Sample_Format_S32LSB);
   Sample_Format_S32MSB : constant SDL.Audio.Sample_Format :=
     SDL.Audio.Sample_Format (SDL.Raw.Audio.Sample_Format_S32MSB);

   Sample_Format_F32LSB : constant SDL.Audio.Sample_Format :=
     SDL.Audio.Sample_Format (SDL.Raw.Audio.Sample_Format_F32LSB);
   Sample_Format_F32MSB : constant SDL.Audio.Sample_Format :=
     SDL.Audio.Sample_Format (SDL.Raw.Audio.Sample_Format_F32MSB);

   Sample_Format_S16 : constant SDL.Audio.Sample_Format :=
     (if System.Default_Bit_Order = System.High_Order_First
      then Sample_Format_S16MSB
      else Sample_Format_S16LSB);

   Sample_Format_S32 : constant SDL.Audio.Sample_Format :=
     (if System.Default_Bit_Order = System.High_Order_First
      then Sample_Format_S32MSB
      else Sample_Format_S32LSB);

   Sample_Format_F32 : constant SDL.Audio.Sample_Format :=
     (if System.Default_Bit_Order = System.High_Order_First
      then Sample_Format_F32MSB
      else Sample_Format_F32LSB);

   Sample_Format_S16SYS : constant SDL.Audio.Sample_Format := Sample_Format_S16;
   Sample_Format_S32SYS : constant SDL.Audio.Sample_Format := Sample_Format_S32;
   Sample_Format_F32SYS : constant SDL.Audio.Sample_Format := Sample_Format_F32;

   function Bit_Size (Format : SDL.Audio.Sample_Format) return Sample_Bit_Size is
     (Sample_Bit_Size (Format and 16#00FF#));

   function Byte_Size (Format : SDL.Audio.Sample_Format) return Natural is
     (Natural (Bit_Size (Format)) / 8);

   function Is_Float (Format : SDL.Audio.Sample_Format) return Boolean is
     ((Format and 16#0100#) /= 0);

   function Is_Integer (Format : SDL.Audio.Sample_Format) return Boolean is
     (not Is_Float (Format));

   function Is_Big_Endian (Format : SDL.Audio.Sample_Format) return Boolean is
     ((Format and 16#1000#) /= 0);

   function Is_Little_Endian (Format : SDL.Audio.Sample_Format) return Boolean is
     (not Is_Big_Endian (Format));

   function Is_Signed (Format : SDL.Audio.Sample_Format) return Boolean is
     ((Format and 16#8000#) /= 0);

   function Is_Unsigned (Format : SDL.Audio.Sample_Format) return Boolean is
     (not Is_Signed (Format));
end SDL.Audio.Sample_Formats;
