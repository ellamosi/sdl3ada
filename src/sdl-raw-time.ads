with Interfaces;
with Interfaces.C;
with Interfaces.C.Extensions;

package SDL.Raw.Time is
   pragma Preelaborate;

   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;

   subtype Times is Interfaces.Integer_64;

   type Date_Time is record
      Year         : C.int;
      Month        : C.int;
      Day          : C.int;
      Hour         : C.int;
      Minute       : C.int;
      Second       : C.int;
      Nanosecond   : C.int;
      Day_Of_Week  : C.int;
      UTC_Offset   : C.int;
   end record with
     Convention => C;

   type Date_Formats is
     (Year_Month_Day,
      Day_Month_Year,
      Month_Day_Year)
   with
     Convention => C,
     Size       => C.int'Size;

   for Date_Formats use
     (Year_Month_Day => 0,
      Day_Month_Year => 1,
      Month_Day_Year => 2);

   type Time_Formats is
     (Twenty_Four_Hour,
      Twelve_Hour)
   with
     Convention => C,
     Size       => C.int'Size;

   for Time_Formats use
     (Twenty_Four_Hour => 0,
      Twelve_Hour      => 1);

   function Get_Date_Time_Locale_Preferences
     (Date_Format : access Date_Formats;
      Time_Format : access Time_Formats) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetDateTimeLocalePreferences";

   function Get_Current_Time (Ticks : access Times) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetCurrentTime";

   function Time_To_Date_Time
     (Ticks      : in Times;
      DT         : access Date_Time;
      Local_Time : in CE.bool) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_TimeToDateTime";

   function Date_Time_To_Time
     (DT    : access constant Date_Time;
      Ticks : access Times) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_DateTimeToTime";

   procedure Time_To_Windows
     (Ticks            : in Times;
      Low_Date_Time    : access Interfaces.Unsigned_32;
      High_Date_Time   : access Interfaces.Unsigned_32)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_TimeToWindows";

   function Time_From_Windows
     (Low_Date_Time  : in Interfaces.Unsigned_32;
      High_Date_Time : in Interfaces.Unsigned_32) return Times
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_TimeFromWindows";

   function Get_Days_In_Month
     (Year  : in C.int;
      Month : in C.int) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetDaysInMonth";

   function Get_Day_Of_Year
     (Year  : in C.int;
      Month : in C.int;
      Day   : in C.int) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetDayOfYear";

   function Get_Day_Of_Week
     (Year  : in C.int;
      Month : in C.int;
      Day   : in C.int) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetDayOfWeek";
end SDL.Raw.Time;
