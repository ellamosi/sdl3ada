with Interfaces.C.Strings;

with SDL.Error;
with SDL.Raw.Misc;

package body SDL.Misc is
   package CS renames Interfaces.C.Strings;
   package Raw renames SDL.Raw.Misc;

   procedure Open_URL (URL : in String) is
      C_URL : CS.chars_ptr := CS.New_String (URL);
   begin
      begin
         if not Boolean (Raw.Open_URL (C_URL)) then
            raise Misc_Error with SDL.Error.Get;
         end if;
      exception
         when others =>
            CS.Free (C_URL);
            raise;
      end;

      CS.Free (C_URL);
   end Open_URL;
end SDL.Misc;
