with Interfaces.C.Strings;

package body SDL.Versions is
   package C renames Interfaces.C;

   function SDL_Get_Revision return C.Strings.chars_ptr with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetRevision";

   function SDL_Get_Version return C.int with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetVersion";

   function To_Number (Value : in Version) return Version_Number is
     (Version_Number (Value.Major) * 1_000_000
      + Version_Number (Value.Minor) * 1_000
      + Version_Number (Value.Patch));

   function Major (Value : in Version_Number) return Version_Level is
     (Version_Level (Value / 1_000_000));

   function Minor (Value : in Version_Number) return Version_Level is
     (Version_Level ((Value / 1_000) mod 1_000));

   function Patch (Value : in Version_Number) return Version_Level is
     (Version_Level (Value mod 1_000));

   function Revision return String is
   begin
      return C.Strings.Value (SDL_Get_Revision);
   end Revision;

   function Revision return Revision_Level is
   begin
      --  SDL3 removed the old numeric revision query, so keep the deprecated
      --  compatibility entry point but report no numeric revision.
      return 0;
   end Revision;

   function Linked_Number return Version_Number is
     (Version_Number (SDL_Get_Version));

   function Linked return Version is
     (Major => Major (Linked_Number),
      Minor => Minor (Linked_Number),
      Patch => Patch (Linked_Number));

   procedure Linked_With (Info : in out Version) is
   begin
      Info := Linked;
   end Linked_With;
end SDL.Versions;
