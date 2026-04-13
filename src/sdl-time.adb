with Interfaces.C;
with Interfaces.C.Extensions;

with SDL.Error;

package body SDL.Time is
   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;
   package Raw renames SDL.Raw.Time;

   function To_C_Bool (Value : in Boolean) return CE.bool is
     (CE.bool'Val (Boolean'Pos (Value)));

   procedure Raise_Last_Error;
   procedure Raise_Last_Error is
   begin
      raise Time_Error with SDL.Error.Get;
   end Raise_Last_Error;

   function Get_Locale_Preferences return Date_Time_Locale_Preferences is
      Date_Format : aliased Date_Formats;
      Time_Format : aliased Time_Formats;
   begin
      if not Boolean
          (Raw.Get_Date_Time_Locale_Preferences
             (Date_Format'Access, Time_Format'Access))
      then
         Raise_Last_Error;
      end if;

      return (Date_Format => Date_Format, Time_Format => Time_Format);
   end Get_Locale_Preferences;

   function Current return Times is
      Result : aliased Times := 0;
   begin
      if not Boolean (Raw.Get_Current_Time (Result'Access)) then
         Raise_Last_Error;
      end if;

      return Result;
   end Current;

   function To_Date_Time
     (Ticks      : in Times;
      Local_Time : in Boolean := True) return Date_Time
   is
      Result : aliased Date_Time;
   begin
      if not Boolean
          (Raw.Time_To_Date_Time
             (Ticks      => Ticks,
              DT         => Result'Access,
              Local_Time => To_C_Bool (Local_Time)))
      then
         Raise_Last_Error;
      end if;

      return Result;
   end To_Date_Time;

   function To_Time (Value : in Date_Time) return Times is
      Raw_Value : aliased constant Date_Time := Value;
      Result    : aliased Times := 0;
   begin
      if not Boolean
          (Raw.Date_Time_To_Time (Raw_Value'Access, Result'Access))
      then
         Raise_Last_Error;
      end if;

      return Result;
   end To_Time;

   function To_Windows_File_Time (Ticks : in Times) return Windows_File_Time is
      Low  : aliased Interfaces.Unsigned_32 := 0;
      High : aliased Interfaces.Unsigned_32 := 0;
   begin
      Raw.Time_To_Windows (Ticks, Low'Access, High'Access);
      return (Low_Date_Time => Low, High_Date_Time => High);
   end To_Windows_File_Time;

   function From_Windows_File_Time (Value : in Windows_File_Time) return Times is
     (Raw.Time_From_Windows (Value.Low_Date_Time, Value.High_Date_Time));

   function Days_In_Month (Year, Month : in Integer) return Positive is
      Result : constant C.int :=
        Raw.Get_Days_In_Month (C.int (Year), C.int (Month));
   begin
      if Result < 0 then
         Raise_Last_Error;
      end if;

      return Positive (Result);
   end Days_In_Month;

   function Day_Of_Year (Year, Month, Day : in Integer) return Natural is
      Result : constant C.int :=
        Raw.Get_Day_Of_Year (C.int (Year), C.int (Month), C.int (Day));
   begin
      if Result < 0 then
         Raise_Last_Error;
      end if;

      return Natural (Result);
   end Day_Of_Year;

   function Day_Of_Week (Year, Month, Day : in Integer) return Natural is
      Result : constant C.int :=
        Raw.Get_Day_Of_Week (C.int (Year), C.int (Month), C.int (Day));
   begin
      if Result < 0 then
         Raise_Last_Error;
      end if;

      return Natural (Result);
   end Day_Of_Week;
end SDL.Time;
