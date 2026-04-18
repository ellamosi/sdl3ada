package SDL.Video.Surfaces.Internal is
   pragma Preelaborate;

   function Get_Internal
     (Self : in Surface) return Internal_Surface_Pointer
   with Inline;

   function Make_From_Pointer
     (Value : in Internal_Surface_Pointer;
      Owns  : in Boolean := False) return Surface;
end SDL.Video.Surfaces.Internal;
