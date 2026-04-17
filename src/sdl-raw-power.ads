with Interfaces.C;

package SDL.Raw.Power is
   pragma Pure;

   package C renames Interfaces.C;

   type State is
     (State_Error,
      State_Unknown,
      State_On_Battery,
      State_No_Battery,
      State_Charging,
      State_Charged)
   with
     Convention => C,
     Size       => C.int'Size;

   for State use
     (State_Error      => -1,
      State_Unknown    => 0,
      State_On_Battery => 1,
      State_No_Battery => 2,
      State_Charging   => 3,
      State_Charged    => 4);

   function Get_Power_Info
     (Seconds : access C.int;
      Percent : access C.int) return State
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetPowerInfo";
end SDL.Raw.Power;
