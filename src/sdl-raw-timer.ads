with Interfaces;
with Interfaces.C.Extensions;
with System;

package SDL.Raw.Timer is
   pragma Preelaborate;

   package CE renames Interfaces.C.Extensions;

   subtype Tick_Values is Interfaces.Unsigned_64;
   subtype Nanoseconds is Interfaces.Unsigned_64;
   subtype Timer_ID is Interfaces.Unsigned_32;
   subtype Timer_Intervals is Interfaces.Unsigned_32;

   type Timer_Callback is access function
     (User_Data : in System.Address;
      Timer     : in Timer_ID;
      Interval  : in Timer_Intervals) return Timer_Intervals
   with Convention => C;

   type NS_Timer_Callback is access function
     (User_Data : in System.Address;
      Timer     : in Timer_ID;
      Interval  : in Nanoseconds) return Nanoseconds
   with Convention => C;

   function Get_Ticks return Tick_Values
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetTicks";

   function Get_Ticks_NS return Nanoseconds
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetTicksNS";

   function Get_Performance_Counter return Tick_Values
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetPerformanceCounter";

   function Get_Performance_Frequency return Tick_Values
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetPerformanceFrequency";

   procedure Delay_NS (NS : in Nanoseconds)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_DelayNS";

   procedure Delay_Precise (NS : in Nanoseconds)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_DelayPrecise";

   function Add_Timer
     (Interval  : in Timer_Intervals;
      Callback  : in Timer_Callback;
      User_Data : in System.Address) return Timer_ID
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_AddTimer";

   function Add_Timer_NS
     (Interval  : in Nanoseconds;
      Callback  : in NS_Timer_Callback;
      User_Data : in System.Address) return Timer_ID
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_AddTimerNS";

   function Remove_Timer (Timer : in Timer_ID) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_RemoveTimer";
end SDL.Raw.Timer;
