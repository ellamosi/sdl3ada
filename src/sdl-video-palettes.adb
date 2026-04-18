with Ada.Finalization;
with Ada.Unchecked_Conversion;

with SDL.Error;
with SDL.Video.Palettes.Internal;

package body SDL.Video.Palettes is
   package Raw renames SDL.Raw.Pixels;
   package Palette_Internal renames SDL.Video.Palettes.Internal;

   use type Raw.Palette_Access;
   use type Colour_Array_Pointer.Pointer;
   use type System.Address;

   type Iterator (Container : access constant Palette'Class) is
     new Ada.Finalization.Limited_Controlled and
       Palette_Iterator_Interfaces.Forward_Iterator with null record;

   overriding
   function First (Object : Iterator) return Cursor;

   overriding
   function Next (Object : Iterator; Position : Cursor) return Cursor;

   function To_Colour_Pointer is new Ada.Unchecked_Conversion
     (Source => System.Address,
      Target => Colour_Array_Pointer.Pointer);

   function Colour_Array_Address
     (Items : in Colour_Arrays) return System.Address is
     (if Items'Length = 0 then System.Null_Address else Items (Items'First)'Address);

   function Element (Position : in Cursor) return Colour is
   begin
      return Colour_Array_Pointer.Value (Position.Current) (0);
   end Element;

   function Has_Element (Position : in Cursor) return Boolean is
   begin
      return Position.Container /= null
        and then Position.Container.Data /= null
        and then Position.Current /= null
        and then Position.Index <= Natural (Position.Container.Data.Total);
   end Has_Element;

   function Constant_Reference
     (Container : aliased Palette;
      Position  : Cursor) return Colour is
      pragma Unreferenced (Container);
   begin
      return Element (Position);
   end Constant_Reference;

   function Iterate
     (Container : Palette)
      return Palette_Iterator_Interfaces.Forward_Iterator'Class
   is
   begin
      return Result : constant Iterator :=
        (Ada.Finalization.Limited_Controlled with
         Container => Container'Access)
      do
         null;
      end return;
   end Iterate;

   function Create (Total_Colours : in Positive) return Palette is
      Data : constant Internal_Palette_Access :=
        Raw.Create_Palette (C.int (Total_Colours));
   begin
      if Data = null then
         raise SDL.Video.Video_Error with SDL.Error.Get;
      end if;

      return (Data => Data);
   end Create;

   function Duplicate (Container : in Palette) return Palette is
   begin
      return Result : Palette do
         if Container.Data = null then
            Result.Data := null;
         else
            Palette_Internal.Copy_From_Pointer (Container.Data.all'Address, Result);
         end if;
      end return;
   end Duplicate;

   procedure Set_Colours
     (Container : in out Palette;
      Colours   : in Colour_Arrays;
      First     : in Natural := 0)
   is
   begin
      if Container.Data = null then
         raise SDL.Video.Video_Error with "Invalid palette";
      end if;

      if not Boolean
          (Raw.Set_Palette_Colors
             (Container.Data,
              Colour_Array_Address (Colours),
              C.int (First),
              C.int (Colours'Length)))
      then
         raise SDL.Video.Video_Error with SDL.Error.Get;
      end if;
   end Set_Colours;

   procedure Free (Container : in out Palette) is
   begin
      if Container.Data /= null then
         Raw.Destroy_Palette (Container.Data);
         Container.Data := null;
      end if;
   end Free;

   function Get_Internal (Container : in Palette) return System.Address is
     (if Container.Data = null
      then System.Null_Address
      else Container.Data.all'Address);

   overriding
   function First (Object : Iterator) return Cursor is
   begin
      if Object.Container = null
        or else Object.Container.Data = null
        or else Object.Container.Data.Colours = System.Null_Address
      then
         return No_Element;
      end if;

      return
        (Container => Object.Container,
         Index     => Natural'First + 1,
         Current   => To_Colour_Pointer (Object.Container.Data.Colours));
   end First;

   overriding
   function Next (Object : Iterator; Position : Cursor) return Cursor is
      Current : Colour_Array_Pointer.Pointer := Position.Current;
   begin
      if not Has_Element (Position) then
         return No_Element;
      end if;

      Colour_Array_Pointer.Increment (Current);

      return
        (Container => Object.Container,
         Index     => Position.Index + 1,
         Current   => Current);
   end Next;
end SDL.Video.Palettes;
