with Ada.Characters.Handling;
with Interfaces.C.Strings;

package body SDL.Platform is
   package CS renames Interfaces.C.Strings;

   use type CS.chars_ptr;

   function SDL_Get_Platform return CS.chars_ptr with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetPlatform";

   function Name return String is
      Value : constant CS.chars_ptr := SDL_Get_Platform;
   begin
      if Value = CS.Null_Ptr then
         return "";
      end if;

      return CS.Value (Value);
   end Name;

   function Get return Platforms is
      Platform_Name : constant String :=
        Ada.Characters.Handling.To_Lower (Name);
   begin
      if Platform_Name = "windows" then
         return Windows;
      elsif Platform_Name = "macos" then
         return Mac_OS_X;
      elsif Platform_Name = "linux" then
         return Linux;
      elsif Platform_Name = "ios" then
         return iOS;
      elsif Platform_Name = "android" then
         return Android;
      elsif
        Platform_Name'Length >= 3
        and then Platform_Name (Platform_Name'Last - 2 .. Platform_Name'Last) = "bsd"
      then
         return BSD;
      else
         return Unknown;
      end if;
   end Get;
end SDL.Platform;
