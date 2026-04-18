with Interfaces;

package body SDL.Timers is
   package Raw renames SDL.Raw.Timer;

   use type Interfaces.Unsigned_64;

   NS_Per_Millisecond : constant Nanoseconds := 1_000_000;

   function Ticks return Milliseconds is
     (Raw.Get_Ticks);

   function Ticks_NS return Nanoseconds is
     (Raw.Get_Ticks_NS);

   procedure Wait_Delay (MS : in Milliseconds) is
   begin
      Wait_Delay_NS (Nanoseconds (MS) * NS_Per_Millisecond);
   end Wait_Delay;

   procedure Wait_Delay_NS (NS : in Nanoseconds) is
   begin
      Raw.Delay_NS (NS);
   end Wait_Delay_NS;

   procedure Wait_Delay_Precise (NS : in Nanoseconds) is
   begin
      Raw.Delay_Precise (NS);
   end Wait_Delay_Precise;

   function Add_Timer
     (Interval  : in Timer_Intervals;
      Callback  : in Timer_Callback;
      User_Data : in System.Address := System.Null_Address) return Timer_ID
   is
   begin
      return Raw.Add_Timer
        (Interval  => Interval,
         Callback  => Raw.Timer_Callback (Callback),
         User_Data => User_Data);
   end Add_Timer;

   function Add_Timer_NS
     (Interval  : in Nanoseconds;
      Callback  : in NS_Timer_Callback;
      User_Data : in System.Address := System.Null_Address) return Timer_ID
   is
   begin
      return Raw.Add_Timer_NS
        (Interval  => Interval,
         Callback  => Raw.NS_Timer_Callback (Callback),
         User_Data => User_Data);
   end Add_Timer_NS;

   function Remove_Timer (Timer : in Timer_ID) return Boolean is
     (Boolean (Raw.Remove_Timer (Timer)));

   package body Performance is
      function Get_Counter return Counts is
        (Raw.Get_Performance_Counter);

      function Get_Frequency return Frequencies is
        (Raw.Get_Performance_Frequency);
   end Performance;
end SDL.Timers;
