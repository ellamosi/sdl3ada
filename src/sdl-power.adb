with Interfaces.C;

package body SDL.Power is
   package C renames Interfaces.C;

   type Internal_State is new C.int with
     Convention => C;

   Power_State_Error      : constant Internal_State := -1;
   Power_State_Battery    : constant Internal_State := 1;
   Power_State_No_Battery : constant Internal_State := 2;
   Power_State_Charging   : constant Internal_State := 3;
   Power_State_Charged    : constant Internal_State := 4;

   procedure Info (Data : in out Battery_Info) is
      function SDL_Get_Power_Info
        (Seconds, Percent : out C.int) return Internal_State with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetPowerInfo";

      Remaining_Seconds : C.int;
      Remaining_Percent : C.int;
      Power             : constant Internal_State :=
        SDL_Get_Power_Info (Remaining_Seconds, Remaining_Percent);
   begin
      Data.Power_State :=
        (if Power = Power_State_Error then Error
         elsif Power = Power_State_Battery then Battery
         elsif Power = Power_State_No_Battery then No_Battery
         elsif Power = Power_State_Charging then Charging
         elsif Power = Power_State_Charged then Charged
         else Unknown);

      if Power = Power_State_Error or else Remaining_Seconds = -1 then
         Data.Time_Valid := False;
      else
         Data.Time_Valid := True;
         Data.Time       := SDL.Power.Seconds (Remaining_Seconds);
      end if;

      if Power = Power_State_Error or else Remaining_Percent = -1 then
         Data.Percentage_Valid := False;
      else
         Data.Percentage_Valid := True;
         Data.Percent          := Percentage (Remaining_Percent);
      end if;
   end Info;
end SDL.Power;
