package SDL.Error is
   pragma Preelaborate;

   procedure Clear with
     Inline;

   procedure Set (S : in String) with
     Inline;

   function Out_Of_Memory return Boolean with
     Inline;

   function Get return String with
     Inline;

   procedure Get (Buffer : in out String) with
     Inline;
end SDL.Error;
