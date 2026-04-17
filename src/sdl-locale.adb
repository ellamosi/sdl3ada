with Ada.Strings.Unbounded;
with Interfaces.C;
with Interfaces.C.Strings;

with SDL.Error;
with SDL.Raw.Locale;

package body SDL.Locale is
   package C renames Interfaces.C;
   package CS renames Interfaces.C.Strings;
   package Raw renames SDL.Raw.Locale;
   package US renames Ada.Strings.Unbounded;

   use type CS.chars_ptr;
   use type Raw.Locale_Access;
   use type Raw.Locale_Access_Pointers.Pointer;

   function Preferred return Locale_List is
      Count   : aliased C.int := 0;
      Locales : Raw.Locale_Access_Pointers.Pointer :=
        Raw.Get_Preferred_Locales (Count'Access);
   begin
      if Locales = null then
         raise Locale_Error with SDL.Error.Get;
      end if;

      if Count < 1 then
         Raw.Free (Locales);
         return (1 .. 0 => <>);
      end if;

      declare
         Result : Locale_List (1 .. Natural (Count));
      begin
         for Index in Result'Range loop
            declare
               Position : constant Raw.Locale_Access_Pointers.Pointer :=
                 Locales + C.ptrdiff_t (Index - 1);
               Item : constant Raw.Locale_Access := Position.all;
            begin
               if Item /= null and then Item.Language /= CS.Null_Ptr then
                  Result (Index).Language :=
                    US.To_Unbounded_String (CS.Value (Item.Language));
               end if;

               if Item /= null and then Item.Country /= CS.Null_Ptr then
                  Result (Index).Country :=
                    US.To_Unbounded_String (CS.Value (Item.Country));
               end if;
            end;
         end loop;

         Raw.Free (Locales);
         return Result;
      exception
         when others =>
            Raw.Free (Locales);
            raise;
      end;
   end Preferred;
end SDL.Locale;
