with Interfaces.C;
with Interfaces.C.Extensions;
with Interfaces.C.Strings;

package body SDL.Error is
   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;

   procedure Clear is
      function SDL_Clear_Error return CE.bool with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_ClearError";

      Ignored : constant CE.bool := SDL_Clear_Error;
      pragma Unreferenced (Ignored);
   begin
      null;
   end Clear;

   procedure Set (S : in String) is
      function SDL_Set_Error (Fmt_Str, C_Str : in C.char_array) return CE.bool with
        Import        => True,
        Convention    => C_Variadic_1,
        External_Name => "SDL_SetError";

      Ignored : constant CE.bool := SDL_Set_Error (C.To_C ("%s"), C.To_C (S));
      pragma Unreferenced (Ignored);
   begin
      null;
   end Set;

   function Out_Of_Memory return Boolean is
      function SDL_Out_Of_Memory return CE.bool with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_OutOfMemory";
   begin
      return Boolean (SDL_Out_Of_Memory);
   end Out_Of_Memory;

   function Get return String is
      function SDL_Get_Error return C.Strings.chars_ptr with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetError";
      Message : constant C.Strings.chars_ptr := SDL_Get_Error;

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
