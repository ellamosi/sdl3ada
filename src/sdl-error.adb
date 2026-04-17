with Interfaces.C;
with Interfaces.C.Strings;

with SDL.Raw.Error;

package body SDL.Error is
   package C renames Interfaces.C;
   package Raw renames SDL.Raw.Error;

   procedure Clear is
      Ignored : constant Raw.CE.bool := Raw.Clear_Error;
      pragma Unreferenced (Ignored);
   begin
      null;
   end Clear;

   procedure Set (S : in String) is
      Ignored : constant Raw.CE.bool := Raw.Set_Error (C.To_C ("%s"), C.To_C (S));
      pragma Unreferenced (Ignored);
   begin
      null;
   end Set;

   function Out_Of_Memory return Boolean is
   begin
      return Boolean (Raw.Out_Of_Memory);
   end Out_Of_Memory;

   function Get return String is
      Message : constant C.Strings.chars_ptr := Raw.Get_Error;

      use type C.Strings.chars_ptr;
   begin
      if Message = C.Strings.Null_Ptr then
         return "";
      end if;

      return C.Strings.Value (Message);
   end Get;

   procedure Get (Buffer : in out String) is
      Message : constant String := Get;
      Last    : constant Natural := Natural'Min (Buffer'Length, Message'Length);
   begin
      if Last > 0 then
         Buffer (Buffer'First .. Buffer'First + Last - 1) :=
           Message (Message'First .. Message'First + Last - 1);
      end if;

      if Last < Buffer'Length then
         Buffer (Buffer'First + Last .. Buffer'Last) := [others => ' '];
      end if;
   end Get;
end SDL.Error;
