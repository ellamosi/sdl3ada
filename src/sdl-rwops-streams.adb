with Interfaces.C;

with SDL.Error;

package body SDL.RWops.Streams is
   package C renames Interfaces.C;

   type IO_Status is
     (Ready,
      Error,
      End_Of_File,
      Not_Ready,
      Read_Only,
      Write_Only)
   with
     Convention => C,
     Size       => C.int'Size;

   for IO_Status use
     (Ready       => 0,
      Error       => 1,
      End_Of_File => 2,
      Not_Ready   => 3,
      Read_Only   => 4,
      Write_Only  => 5);

   use type Ada.Streams.Stream_Element_Offset;
   use type C.size_t;

   function SDL_Read_IO
     (Context : in RWops;
      Ptr     : in System.Address;
      Size    : in C.size_t) return C.size_t
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ReadIO";

   function SDL_Write_IO
     (Context : in RWops;
      Ptr     : in System.Address;
      Size    : in C.size_t) return C.size_t
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_WriteIO";

   function SDL_Get_IO_Status (Context : in RWops) return IO_Status with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetIOStatus";

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
        SDL_Read_IO
          (Context => Stream.Context,
           Ptr     => Item'Address,
           Size    => C.size_t (Item'Length));

      if Bytes_Read = 0 then
         if SDL_Get_IO_Status (Stream.Context) = End_Of_File then
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
        SDL_Write_IO
          (Context => Stream.Context,
           Ptr     => Item'Address,
           Size    => C.size_t (Item'Length));

      if Bytes_Written /= C.size_t (Item'Length) then
         raise RWops_Error with SDL.Error.Get;
      end if;
   end Write;
end SDL.RWops.Streams;
