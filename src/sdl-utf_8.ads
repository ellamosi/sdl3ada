with SDL.Raw.UTF_8;

package SDL.UTF_8 is
   pragma Preelaborate;

   subtype Code_Points is SDL.Raw.UTF_8.Code_Points;

   Invalid_Code_Point : constant Code_Points :=
     SDL.Raw.UTF_8.Invalid_Unicode_Code_Point;

   function Step
     (Item     : in String;
      Position : in out Natural) return Code_Points;

   function Encode (Code_Point : in Code_Points) return String;
end SDL.UTF_8;
