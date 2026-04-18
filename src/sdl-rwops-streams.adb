with Interfaces.C;

with SDL.Error;
with SDL.Raw.IOStream;

package body SDL.RWops.Streams is
   package C renames Interfaces.C;
   package Raw renames SDL.Raw.IOStream;

   use type Ada.Streams.Stream_Element_Offset;
   use type C.size_t;
   use type Raw.IO_Status;

   function Open (Op : in RWops) return RWops_Stream is
   begin
      return (Ada.Streams.Root_Stream_Type with Context => Op);
   end Open;

   procedure Open (Op : in RWops; Stream : out RWops_Stream) is
   begin
      Stream.Context := Op;
   end Open;

   procedure Close (Stream : in RWops_Stream) is
   begin
      Close (Stream.Context);
   end Close;

   overriding
   procedure Read
     (Stream : in out RWops_Stream;
      Item   : out Ada.Streams.Stream_Element_Array;
      Last   : out Ada.Streams.Stream_Element_Offset)
   is
      Bytes_Read : C.size_t := 0;
   begin
      if Item'Length = 0 then
         Last := Item'First - 1;
         return;
      end if;

      if Is_Null (Stream.Context) then
         raise RWops_Error with "Invalid RWops handle";
      end if;

      Bytes_Read :=
        Raw.Read_IO
          (Context => Get_Handle (Stream.Context),
           Ptr     => Item'Address,
           Size    => C.size_t (Item'Length));

      if Bytes_Read = 0 then
         if Raw.Get_IO_Status (Get_Handle (Stream.Context)) = Raw.IO_Status_Eof then
            Last := Item'First - 1;
            return;
         end if;

         raise RWops_Error with SDL.Error.Get;
      end if;

      Last := Item'First + Ada.Streams.Stream_Element_Offset (Bytes_Read) - 1;
   end Read;

   overriding
   procedure Write
     (Stream : in out RWops_Stream;
      Item   : in Ada.Streams.Stream_Element_Array)
   is
      Bytes_Written : C.size_t := 0;
   begin
      if Item'Length = 0 then
         return;
      end if;

      if Is_Null (Stream.Context) then
         raise RWops_Error with "Invalid RWops handle";
      end if;

      Bytes_Written :=
        Raw.Write_IO
          (Context => Get_Handle (Stream.Context),
           Ptr     => Item'Address,
           Size    => C.size_t (Item'Length));

      if Bytes_Written /= C.size_t (Item'Length) then
         raise RWops_Error with SDL.Error.Get;
      end if;
   end Write;
end SDL.RWops.Streams;
