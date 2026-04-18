with SDL.Raw.Power;

package SDL.Power is
   pragma Pure;

   subtype State is SDL.Raw.Power.State;

   Error      : constant State := SDL.Raw.Power.State_Error;
   Unknown    : constant State := SDL.Raw.Power.State_Unknown;
   Battery    : constant State := SDL.Raw.Power.State_On_Battery;
   No_Battery : constant State := SDL.Raw.Power.State_No_Battery;
   Charging   : constant State := SDL.Raw.Power.State_Charging;
   Charged    : constant State := SDL.Raw.Power.State_Charged;

   type Seconds is range 0 .. Integer'Last;
   type Percentage is range 0 .. 100;

   type Battery_Info is record
      Power_State      : State;
      Time_Valid       : Boolean;
      Time             : Seconds;
      Percentage_Valid : Boolean;
      Percent          : Percentage;
   end record;

   procedure Info (Data : in out Battery_Info);
end SDL.Power;
