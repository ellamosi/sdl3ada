with Interfaces.C;

package body SDL.Power is
   package C renames Interfaces.C;
   package Raw renames SDL.Raw.Power;

   use type Raw.State;

   procedure Info (Data : in out Battery_Info) is
      Remaining_Seconds : aliased C.int := -1;
      Remaining_Percent : aliased C.int := -1;
      Power             : constant Raw.State :=
        Raw.Get_Power_Info (Remaining_Seconds'Access, Remaining_Percent'Access);
   begin
      Data.Power_State :=
        (if Power = Raw.State_Error then Error
         elsif Power = Raw.State_On_Battery then Battery
         elsif Power = Raw.State_No_Battery then No_Battery
         elsif Power = Raw.State_Charging then Charging
         elsif Power = Raw.State_Charged then Charged
         else Unknown);

      if Power = Raw.State_Error or else Remaining_Seconds = -1 then
         Data.Time_Valid := False;
      else
         Data.Time_Valid := True;
         Data.Time       := SDL.Power.Seconds (Remaining_Seconds);
      end if;

      if Power = Raw.State_Error or else Remaining_Percent = -1 then
         Data.Percentage_Valid := False;
      else
         Data.Percentage_Valid := True;
         Data.Percent          := Percentage (Remaining_Percent);
      end if;
   end Info;
end SDL.Power;
