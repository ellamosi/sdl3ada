with System;
with SDL.Raw.Timer;

package SDL.Timers is
   pragma Pure;

   subtype Timer_ID is SDL.Raw.Timer.Timer_ID;

   No_Timer : constant Timer_ID := 0;

   subtype Timer_Intervals is SDL.Raw.Timer.Timer_Intervals;

   subtype Milliseconds is SDL.Raw.Timer.Tick_Values;
   subtype Nanoseconds is SDL.Raw.Timer.Nanoseconds;

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
     Inline;

   function Ticks_NS return Nanoseconds with
     Inline;

   procedure Wait_Delay (MS : in Milliseconds) with
     Inline;

   procedure Wait_Delay_NS (NS : in Nanoseconds) with
     Inline;

   procedure Wait_Delay_Precise (NS : in Nanoseconds) with
     Inline;

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
      subtype Counts is SDL.Raw.Timer.Tick_Values;
      subtype Frequencies is SDL.Raw.Timer.Tick_Values;

      function Get_Counter return Counts with
        Inline;

      function Get_Frequency return Frequencies with
        Inline;
   end Performance;
end SDL.Timers;
