with Interfaces;

with SDL.Raw.Time;

package SDL.Time is
   pragma Preelaborate;

   Time_Error : exception;

   subtype Times is SDL.Raw.Time.Times;
   subtype Date_Time is SDL.Raw.Time.Date_Time;
   subtype Date_Formats is SDL.Raw.Time.Date_Formats;
   subtype Time_Formats is SDL.Raw.Time.Time_Formats;

   Year_Month_Day : constant Date_Formats := SDL.Raw.Time.Year_Month_Day;
   Day_Month_Year : constant Date_Formats := SDL.Raw.Time.Day_Month_Year;
   Month_Day_Year : constant Date_Formats := SDL.Raw.Time.Month_Day_Year;

   Twenty_Four_Hour : constant Time_Formats := SDL.Raw.Time.Twenty_Four_Hour;
   Twelve_Hour      : constant Time_Formats := SDL.Raw.Time.Twelve_Hour;

   type Windows_File_Time is record
      Low_Date_Time  : Interfaces.Unsigned_32;
      High_Date_Time : Interfaces.Unsigned_32;
   end record with
     Convention => C;

   type Date_Time_Locale_Preferences is record
      Date_Format : Date_Formats;
      Time_Format : Time_Formats;
   end record with
     Convention => C;

   function Get_Locale_Preferences return Date_Time_Locale_Preferences;
   function Current return Times;
   function To_Date_Time
     (Ticks      : in Times;
      Local_Time : in Boolean := True) return Date_Time;
   function To_Time (Value : in Date_Time) return Times;
   function To_Windows_File_Time (Ticks : in Times) return Windows_File_Time;
   function From_Windows_File_Time (Value : in Windows_File_Time) return Times;
   function Days_In_Month (Year, Month : in Integer) return Positive;
   function Day_Of_Year (Year, Month, Day : in Integer) return Natural;
   function Day_Of_Week (Year, Month, Day : in Integer) return Natural;
end SDL.Time;
