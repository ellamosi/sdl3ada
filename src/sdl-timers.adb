with Interfaces.C.Extensions;

package body SDL.Timers is
   package CE renames Interfaces.C.Extensions;

   NS_Per_Millisecond : constant Nanoseconds := 1_000_000;

   function SDL_Add_Timer
     (Interval  : in Timer_Intervals;
      Callback  : in Timer_Callback;
      User_Data : in System.Address) return Timer_ID
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_AddTimer";

   function SDL_Add_Timer_NS
     (Interval  : in Nanoseconds;
      Callback  : in NS_Timer_Callback;
      User_Data : in System.Address) return Timer_ID
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_AddTimerNS";

   function SDL_Remove_Timer (Timer : in Timer_ID) return CE.bool with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_RemoveTimer";

   procedure Wait_Delay (MS : in Milliseconds) is
   begin
      Wait_Delay_NS (Nanoseconds (MS) * NS_Per_Millisecond);
   end Wait_Delay;

   function Add_Timer
     (Interval  : in Timer_Intervals;
      Callback  : in Timer_Callback;
      User_Data : in System.Address := System.Null_Address) return Timer_ID
   is
   begin
      return SDL_Add_Timer (Interval, Callback, User_Data);
   end Add_Timer;

   function Add_Timer_NS
     (Interval  : in Nanoseconds;
      Callback  : in NS_Timer_Callback;
      User_Data : in System.Address := System.Null_Address) return Timer_ID
   is
   begin
      return SDL_Add_Timer_NS (Interval, Callback, User_Data);
   end Add_Timer_NS;

   function Remove_Timer (Timer : in Timer_ID) return Boolean is
     (Boolean (SDL_Remove_Timer (Timer)));
end SDL.Timers;
