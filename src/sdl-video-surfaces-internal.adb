package body SDL.Video.Surfaces.Internal is
   function Get_Internal
     (Self : in Surface) return Internal_Surface_Pointer is
     (Self.Internal);

   function Make_From_Pointer
     (Value : in Internal_Surface_Pointer;
      Owns  : in Boolean := False) return Surface
   is
   begin
      return Result : Surface do
         Result.Internal := Value;
         Result.Owns := Owns;
      end return;
   end Make_From_Pointer;
end SDL.Video.Surfaces.Internal;
