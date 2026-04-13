with Interfaces;

package SDL.UTF_8 is
   pragma Preelaborate;

   subtype Code_Points is Interfaces.Unsigned_32;

   Invalid_Code_Point : constant Code_Points := 16#0000_FFFD#;

   function Step
     (Item     : in String;
      Position : in out Natural) return Code_Points;

   function Encode (Code_Point : in Code_Points) return String;
end SDL.UTF_8;
