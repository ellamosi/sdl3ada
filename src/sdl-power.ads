with Interfaces.C;

package SDL.Power is
   pragma Pure;

   type State is
     (Error,
      Unknown,
      Battery,
      No_Battery,
      Charging,
      Charged) with
     Convention => C,
     Size       => Interfaces.C.int'Size;

   for State use
     (Error      => -1,
      Unknown    => 0,
      Battery    => 1,
      No_Battery => 2,
      Charging   => 3,
      Charged    => 4);

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
