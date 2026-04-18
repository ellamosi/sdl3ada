with Ada.Unchecked_Conversion;

package body SDL.Video.Palettes.Internal is
   use type System.Address;
   use type Colour_Array_Pointer.Pointer;

   function To_Internal_Palette_Access is new Ada.Unchecked_Conversion
     (Source => System.Address,
      Target => Internal_Palette_Access);

   procedure Copy_From_Pointer
     (Value  : in System.Address;
      Result : out Palette)
   is
      Source : constant Internal_Palette_Access :=
        To_Internal_Palette_Access (Value);
   begin
      Result.Data := null;

      if Value = System.Null_Address
        or else Source = null
        or else Source.Total <= 0
        or else Source.Colours = null
      then
         return;
      end if;

      declare
         Source_Colours : constant Colour_Arrays :=
           Colour_Array_Pointer.Value
             (Source.Colours, C.ptrdiff_t (Source.Total));
         Copied : constant Palette := Create (Positive (Source.Total));
      begin
         Result.Data := Copied.Data;

         begin
            Set_Colours (Result, Source_Colours);
         exception
            when others =>
               Free (Result);
               raise;
         end;
      end;
   end Copy_From_Pointer;
end SDL.Video.Palettes.Internal;
