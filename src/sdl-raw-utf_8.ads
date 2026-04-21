with Interfaces;
with Interfaces.C;

package SDL.Raw.UTF_8 is
   pragma Preelaborate;

   package C renames Interfaces.C;

   subtype Code_Points is Interfaces.Unsigned_32;

   Invalid_Unicode_Code_Point : constant Code_Points := 16#0000_FFFD#;

   type Char_Pointers is access all C.char
   with Convention => C;

   function Step
     (Text   : access Char_Pointers;
      Length : access C.size_t) return Code_Points
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_StepUTF8";

   function Step_Back
     (Start  : in Char_Pointers;
      Text   : access Char_Pointers) return Code_Points
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_StepBackUTF8";

   function Encode
     (Code_Point  : in Code_Points;
      Destination : in Char_Pointers) return Char_Pointers
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_UCS4ToUTF8";
end SDL.Raw.UTF_8;
