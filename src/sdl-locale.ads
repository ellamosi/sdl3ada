with Ada.Strings.Unbounded;

package SDL.Locale is
   pragma Elaborate_Body;

   Locale_Error : exception;

   type Locale is record
      Language : Ada.Strings.Unbounded.Unbounded_String :=
        Ada.Strings.Unbounded.Null_Unbounded_String;
      Country  : Ada.Strings.Unbounded.Unbounded_String :=
        Ada.Strings.Unbounded.Null_Unbounded_String;
   end record;

   type Locale_List is array (Natural range <>) of Locale;

   function Preferred return Locale_List;
end SDL.Locale;
