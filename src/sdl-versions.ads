with Interfaces.C;

package SDL.Versions is
   pragma Preelaborate;

   type Version_Number is new Interfaces.C.int with
     Convention => C;

   type Version_Level is mod 2 ** 8 with
     Size       => 8,
     Convention => C;

   type Revision_Level is mod 2 ** 32;

   type Version is record
      Major : Version_Level;
      Minor : Version_Level;
      Patch : Version_Level;
   end record with
     Convention => C;

   Compiled_Major : constant Version_Level := 3;
   Compiled_Minor : constant Version_Level := 4;
   Compiled_Patch : constant Version_Level := 4;
   Compiled_Number : constant Version_Number := 3_004_004;

   function Compiled return Version is
     (Major => Compiled_Major,
      Minor => Compiled_Minor,
      Patch => Compiled_Patch)
   with Inline => True;

   function To_Number (Value : in Version) return Version_Number with
     Inline => True;

   function Major (Value : in Version_Number) return Version_Level with
     Inline => True;

   function Minor (Value : in Version_Number) return Version_Level with
     Inline => True;

   function Patch (Value : in Version_Number) return Version_Level with
     Inline => True;

   function Revision return String with
     Inline => True;

   function Revision return Revision_Level with
     Inline => True;

   function Linked return Version with
     Inline => True;

   function Linked_Number return Version_Number with
     Inline => True;

   procedure Linked_With (Info : in out Version) with
     Inline => True;
end SDL.Versions;
