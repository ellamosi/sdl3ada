with Interfaces;
with System;

package SDL.Timers is
   pragma Pure;

   subtype Timer_ID is Interfaces.Unsigned_32;

   No_Timer : constant Timer_ID := 0;

   subtype Timer_Intervals is Interfaces.Unsigned_32;

   type Milliseconds is new Interfaces.Unsigned_64;
   type Nanoseconds is new Interfaces.Unsigned_64;

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

   function Ticks return Milliseconds with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetTicks";

   function Ticks_NS return Nanoseconds with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetTicksNS";

   procedure Wait_Delay (MS : in Milliseconds) with
     Inline;

   procedure Wait_Delay_NS (NS : in Nanoseconds) with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_DelayNS";

   procedure Wait_Delay_Precise (NS : in Nanoseconds) with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_DelayPrecise";

   function Add_Timer
     (Interval  : in Timer_Intervals;
      Callback  : in Timer_Callback;
      User_Data : in System.Address := System.Null_Address) return Timer_ID
   with Inline;

   function Add_Timer_NS
     (Interval  : in Nanoseconds;
      Callback  : in NS_Timer_Callback;
      User_Data : in System.Address := System.Null_Address) return Timer_ID
   with Inline;

   function Remove_Timer (Timer : in Timer_ID) return Boolean with
     Inline;

   function Add
     (Interval  : in Timer_Intervals;
      Callback  : in Timer_Callback;
      User_Data : in System.Address := System.Null_Address) return Timer_ID
     renames Add_Timer;

   function Add_NS
     (Interval  : in Nanoseconds;
      Callback  : in NS_Timer_Callback;
      User_Data : in System.Address := System.Null_Address) return Timer_ID
     renames Add_Timer_NS;

   function Remove (Timer : in Timer_ID) return Boolean renames Remove_Timer;

   package Performance is
      type Counts is new Interfaces.Unsigned_64;
      type Frequencies is new Interfaces.Unsigned_64;

      function Get_Counter return Counts with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetPerformanceCounter";

      function Get_Frequency return Frequencies with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetPerformanceFrequency";
   end Performance;
end SDL.Timers;
