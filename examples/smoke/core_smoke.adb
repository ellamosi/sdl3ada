with Ada.Directories;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Interfaces.C;
with Interfaces.C.Strings;
with System;
with System.Address_To_Access_Conversions;

with SDL;
with SDL.Assertions;
with SDL.C_Pointers;
with SDL.CPUS;
with SDL.Error;
with SDL.Filesystems;
with SDL.Hints;
with SDL.Libraries;
with SDL.Locale;
with SDL.Log;
with SDL.Main;
with SDL.Platform;
with SDL.Power;
with SDL.Properties;
with SDL.Time;
with SDL.Timers;
with SDL.Versions;

procedure Core_Smoke is
   package C renames Interfaces.C;
   package CS renames Interfaces.C.Strings;
   package US renames Ada.Strings.Unbounded;
   package Int_Addresses is new System.Address_To_Access_Conversions (C.int);

   type Log_Capture is record
      Count          : C.int := 0;
      Category       : SDL.Log.Categories := SDL.Log.Application;
      Priority       : SDL.Log.Priorities := SDL.Log.Invalid;
      Message_Length : C.int := 0;
   end record with
     Convention => C;

   type Hint_Capture is record
      Count         : C.int := 0;
      Initial_Match : C.int := 0;
      Update_Match  : C.int := 0;
   end record with
     Convention => C;

   package Log_Capture_Addresses is new System.Address_To_Access_Conversions
     (Log_Capture);
   package Hint_Capture_Addresses is new System.Address_To_Access_Conversions
     (Hint_Capture);

   use type C.int;
   use type Hint_Capture_Addresses.Object_Pointer;
   use type Int_Addresses.Object_Pointer;
   use type Log_Capture_Addresses.Object_Pointer;
   use type CS.chars_ptr;
   use type SDL.Log.Categories;
   use type SDL.Log.Output_Function;
   use type SDL.Log.Priorities;
   use type System.Address;
   use type SDL.Assertions.Assert_Data_Access;
   use type SDL.Assertions.Assertion_Handler;
   use type SDL.Properties.Property_Numbers;
   use type SDL.Time.Times;
   use type SDL.Timers.Milliseconds;
   use type SDL.Timers.Timer_ID;
   use type SDL.Versions.Version;
   use type SDL.Versions.Version_Number;

   type Probe_Function_Access is access function (Value : CS.chars_ptr) return C.int with
     Convention => C;

   function Load_Probe_Function is new SDL.Libraries.Load_Sub_Program
     (Access_To_Sub_Program => Probe_Function_Access,
      Name                  => "library_probe_value");

   function Probe_Library_Filename return String is
   begin
      case SDL.Platform.Get is
         when SDL.Platform.Mac_OS_X =>
            return "liblibraryprobe.dylib";
         when SDL.Platform.Linux | SDL.Platform.BSD =>
            return "liblibraryprobe.so";
         when SDL.Platform.Windows =>
            return "libraryprobe.dll";
         when others =>
            return "";
      end case;
   end Probe_Library_Filename;

   function Probe_Library_Path return String is
      Filename : constant String := Probe_Library_Filename;
      Base     : constant String := String (SDL.Filesystems.Base_Path);
      Path     : constant String := Base & Filename;
   begin
      if Filename /= "" and then Ada.Directories.Exists (Path) then
         return Path;
      end if;

      return "";
   end Probe_Library_Path;

   SDL_Initialized : Boolean := False;
   Start_Ticks     : SDL.Timers.Milliseconds;
   End_Ticks       : SDL.Timers.Milliseconds;

   Linked_Version  : SDL.Versions.Version;
   Power_Info      : SDL.Power.Battery_Info;

   Null_Window_Ptr : constant SDL.C_Pointers.Windows_Pointer := null;

   pragma Unreferenced (Null_Window_Ptr);

   procedure Mark_Main_Thread (User_Data : in System.Address) with
     Convention => C;
   procedure Mark_Main_Thread (User_Data : in System.Address) is
      Value : constant Int_Addresses.Object_Pointer :=
        Int_Addresses.To_Pointer (User_Data);
   begin
      if Value /= null then
         Value.all := 1;
      end if;
   end Mark_Main_Thread;

   function Fire_Timer
     (User_Data : in System.Address;
      Timer     : in SDL.Timers.Timer_ID;
      Interval  : in SDL.Timers.Timer_Intervals) return SDL.Timers.Timer_Intervals
   with Convention => C;
   function Fire_Timer
     (User_Data : in System.Address;
      Timer     : in SDL.Timers.Timer_ID;
      Interval  : in SDL.Timers.Timer_Intervals) return SDL.Timers.Timer_Intervals
   is
      pragma Unreferenced (Timer, Interval);

      Value : constant Int_Addresses.Object_Pointer :=
        Int_Addresses.To_Pointer (User_Data);
   begin
      if Value /= null then
         Value.all := 1;
      end if;

      return 0;
   end Fire_Timer;

   function Cancel_NS_Timer
     (User_Data : in System.Address;
      Timer     : in SDL.Timers.Timer_ID;
      Interval  : in SDL.Timers.Nanoseconds) return SDL.Timers.Nanoseconds
   with Convention => C;
   function Cancel_NS_Timer
     (User_Data : in System.Address;
      Timer     : in SDL.Timers.Timer_ID;
      Interval  : in SDL.Timers.Nanoseconds) return SDL.Timers.Nanoseconds
   is
      pragma Unreferenced (User_Data, Timer, Interval);
   begin
      return 0;
   end Cancel_NS_Timer;

   procedure Capture_Log
     (User_Data : in System.Address;
      Category  : in SDL.Log.Categories;
      Priority  : in SDL.Log.Priorities;
      Message   : in CS.chars_ptr)
   with Convention => C;
   procedure Capture_Log
     (User_Data : in System.Address;
      Category  : in SDL.Log.Categories;
      Priority  : in SDL.Log.Priorities;
      Message   : in CS.chars_ptr)
   is
      Capture : constant Log_Capture_Addresses.Object_Pointer :=
        Log_Capture_Addresses.To_Pointer (User_Data);
   begin
      if Capture /= null then
         declare
            Text : constant String :=
              (if Message = CS.Null_Ptr then "" else CS.Value (Message));
         begin
            Capture.all.Message_Length := C.int (Text'Length);
         end;

         Capture.all.Count := Capture.all.Count + 1;
         Capture.all.Category := Category;
         Capture.all.Priority := Priority;
      end if;
   end Capture_Log;

   procedure Capture_Hint
     (User_Data : in System.Address;
      Name      : in String;
      Old_Value : in String;
      New_Value : in String);
   procedure Capture_Hint
     (User_Data : in System.Address;
      Name      : in String;
      Old_Value : in String;
      New_Value : in String)
   is
      Capture : constant Hint_Capture_Addresses.Object_Pointer :=
        Hint_Capture_Addresses.To_Pointer (User_Data);
   begin
      if Capture = null then
         return;
      end if;

      if Capture.all.Count = 0
        and then Name = "SDL3ADA_CORE_SMOKE_CALLBACK"
        and then Old_Value = "initial"
        and then New_Value = "initial"
      then
         Capture.all.Initial_Match := 1;
      elsif Capture.all.Count = 1
        and then Name = "SDL3ADA_CORE_SMOKE_CALLBACK"
        and then Old_Value = "initial"
        and then New_Value = "updated"
      then
         Capture.all.Update_Match := 1;
      end if;

      Capture.all.Count := Capture.all.Count + 1;
   end Capture_Hint;
begin
   SDL.Main.Set_Ready;

   if not SDL.Set_App_Metadata
       ("sdl3ada core smoke", "phase2", "io.ellamosi.sdl3ada.core_smoke")
   then
      Ada.Text_IO.Put_Line ("SDL app metadata setup failed: " & SDL.Error.Get);
      raise Program_Error with "SDL app metadata setup failed";
   end if;

   if SDL.Get_App_Metadata_Property (SDL.App_Metadata_Name_Property)
      /= "sdl3ada core smoke"
   then
      raise Program_Error with "SDL app metadata name round-trip failed";
   end if;

   if not SDL.Set_App_Metadata_Property
       (SDL.App_Metadata_Creator_Property, "EllaMosi")
   then
      Ada.Text_IO.Put_Line ("SDL app metadata property set failed: " & SDL.Error.Get);
      raise Program_Error with "SDL app metadata property set failed";
   end if;

   if SDL.Get_App_Metadata_Property (SDL.App_Metadata_Creator_Property)
      /= "EllaMosi"
   then
      raise Program_Error with "SDL app metadata property round-trip failed";
   end if;

   if not SDL.Clear_App_Metadata_Property (SDL.App_Metadata_Creator_Property) then
      Ada.Text_IO.Put_Line ("SDL app metadata property clear failed: " & SDL.Error.Get);
      raise Program_Error with "SDL app metadata property clear failed";
   end if;

   if SDL.Get_App_Metadata_Property (SDL.App_Metadata_Creator_Property) /= "" then
      raise Program_Error with "SDL app metadata property clear failed";
   end if;

   Ada.Text_IO.Put_Line ("SDL app metadata round-trip passed.");

   if not SDL.Initialise (SDL.Enable_Events) then
      Ada.Text_IO.Put_Line ("SDL initialization failed: " & SDL.Error.Get);
      raise Program_Error with "SDL initialization failed";
   end if;

   SDL_Initialized := True;

   if not SDL.Is_Main_Thread then
      raise Program_Error with "SDL did not report the Ada entry thread as the main thread";
   end if;

   declare
      Ran_On_Main_Thread : aliased C.int := 0;
   begin
      if not SDL.Run_On_Main_Thread
          (Callback      => Mark_Main_Thread'Unrestricted_Access,
           User_Data     => Ran_On_Main_Thread'Address,
           Wait_Complete => True)
      then
         Ada.Text_IO.Put_Line ("SDL main-thread callback failed: " & SDL.Error.Get);
         raise Program_Error with "SDL main-thread callback failed";
      end if;

      if Ran_On_Main_Thread /= 1 then
         raise Program_Error with "SDL main-thread callback was not executed";
      end if;

      Ada.Text_IO.Put_Line ("SDL main-thread callback passed.");
   end;

   Start_Ticks := SDL.Timers.Ticks;
   SDL.Timers.Wait_Delay (10);
   End_Ticks := SDL.Timers.Ticks;

   declare
      Timer_Fired : aliased C.int := 0;
      pragma Atomic (Timer_Fired);

      One_Shot_Timer : SDL.Timers.Timer_ID;
      Removed_Timer  : SDL.Timers.Timer_ID;
      Deadline       : SDL.Timers.Milliseconds;
   begin
      One_Shot_Timer :=
        SDL.Timers.Add_Timer
          (Interval  => SDL.Timers.Timer_Intervals (10),
           Callback  => Fire_Timer'Unrestricted_Access,
           User_Data => Timer_Fired'Address);

      if One_Shot_Timer = SDL.Timers.No_Timer then
         Ada.Text_IO.Put_Line ("SDL timer creation failed: " & SDL.Error.Get);
         raise Program_Error with "SDL timer creation failed";
      end if;

      Deadline := SDL.Timers.Ticks + SDL.Timers.Milliseconds (250);

      while Timer_Fired = 0 and then SDL.Timers.Ticks < Deadline loop
         SDL.Timers.Wait_Delay (1);
      end loop;

      if Timer_Fired /= 1 then
         raise Program_Error with "SDL timer callback did not fire";
      end if;

      Removed_Timer :=
        SDL.Timers.Add_Timer_NS
          (Interval => SDL.Timers.Nanoseconds (50_000_000),
           Callback => Cancel_NS_Timer'Unrestricted_Access);

      if Removed_Timer = SDL.Timers.No_Timer then
         Ada.Text_IO.Put_Line ("SDL nanosecond timer creation failed: " & SDL.Error.Get);
         raise Program_Error with "SDL nanosecond timer creation failed";
      end if;

      if not SDL.Timers.Remove_Timer (Removed_Timer) then
         Ada.Text_IO.Put_Line ("SDL timer removal failed: " & SDL.Error.Get);
         raise Program_Error with "SDL timer removal failed";
      end if;

      Ada.Text_IO.Put_Line ("SDL.Timers callback and removal passed.");
   end;

   SDL.Versions.Linked_With (Linked_Version);
   Ada.Text_IO.Put_Line
     ("Compiled SDL version:"
      & Integer'Image (Integer (SDL.Versions.Compiled_Major))
      & "."
      & Integer'Image (Integer (SDL.Versions.Compiled_Minor))
      & "."
      & Integer'Image (Integer (SDL.Versions.Compiled_Patch)));
   Ada.Text_IO.Put_Line
     ("Linked SDL version:"
      & Integer'Image (Integer (Linked_Version.Major))
      & "."
      & Integer'Image (Integer (Linked_Version.Minor))
      & "."
      & Integer'Image (Integer (Linked_Version.Patch)));
   Ada.Text_IO.Put_Line ("SDL revision: " & SDL.Versions.Revision);
   if SDL.Platform.Name = "" then
      raise Program_Error with "SDL platform name was empty";
   end if;

   declare
      Linked_Number : constant SDL.Versions.Version_Number :=
        SDL.Versions.Linked_Number;
      Linked_Direct : constant SDL.Versions.Version := SDL.Versions.Linked;
   begin
      if Linked_Direct /= Linked_Version then
         raise Program_Error with "SDL linked version helper mismatch";
      end if;

      if SDL.Versions.To_Number (Linked_Direct) /= Linked_Number then
         raise Program_Error with "SDL linked version number mismatch";
      end if;

      Ada.Text_IO.Put_Line
        ("Linked SDL version number:"
         & Integer'Image (Integer (Linked_Number)));
   end;

   Ada.Text_IO.Put_Line
     ("Platform: "
      & SDL.Platform.Name
      & " ("
      & SDL.Platform.Platforms'Image (SDL.Platform.Get)
      & ")");

   declare
      Boolean_Hint  : constant String := "SDL3ADA_CORE_SMOKE_BOOLEAN";
      Callback_Hint : constant String := "SDL3ADA_CORE_SMOKE_CALLBACK";
      Missing_Hint  : constant String := "SDL3ADA_CORE_SMOKE_MISSING";
      Callback      : constant SDL.Hints.Hint_Callback :=
        Capture_Hint'Unrestricted_Access;
      Capture       : aliased Hint_Capture;
   begin
      SDL.Hints.Set (SDL.Hints.App_Name, "sdl3ada core smoke", SDL.Hints.Override);
      if SDL.Hints.Get (SDL.Hints.App_Name) /= "sdl3ada core smoke" then
         raise Program_Error with "SDL.Hints round-trip failed";
      end if;

      SDL.Hints.Set (Boolean_Hint, "1");
      if not SDL.Hints.Get_Boolean (Boolean_Hint) then
         raise Program_Error with "SDL.Hints boolean get failed";
      end if;

      if not SDL.Hints.Get_Boolean (Missing_Hint, True) then
         raise Program_Error with "SDL.Hints boolean default failed";
      end if;

      if not SDL.Hints.Clear (Boolean_Hint) then
         raise Program_Error with "SDL.Hints single clear failed";
      end if;

      if SDL.Hints.Get (Boolean_Hint) /= "" then
         raise Program_Error with "SDL.Hints single clear round-trip failed";
      end if;

      SDL.Hints.Set (Callback_Hint, "initial");
      if not SDL.Hints.Add_Callback
          (Name      => Callback_Hint,
           Callback  => Callback,
           User_Data => Capture'Address)
      then
         raise Program_Error with "SDL.Hints callback registration failed";
      end if;

      SDL.Hints.Set (Callback_Hint, "updated");
      SDL.Hints.Remove_Callback
        (Name      => Callback_Hint,
         Callback  => Callback,
         User_Data => Capture'Address);
      SDL.Hints.Set (Callback_Hint, "removed");

      if Capture.Count /= 2 then
         raise Program_Error with "SDL.Hints callback invocation count mismatch";
      end if;

      if Capture.Initial_Match /= 1 then
         raise Program_Error with "SDL.Hints initial callback payload mismatch";
      end if;

      if Capture.Update_Match /= 1 then
         raise Program_Error with "SDL.Hints update callback payload mismatch";
      end if;

      if not SDL.Hints.Clear (Callback_Hint) then
         raise Program_Error with "SDL.Hints callback clear failed";
      end if;

      SDL.Hints.Clear;
   end;

   declare
      Props : SDL.Properties.Property_Set := SDL.Properties.Create;
      Copy  : SDL.Properties.Property_Set := SDL.Properties.Create;
   begin
      SDL.Properties.Set_String
        (Props, SDL.Properties.Name_Property, "core-smoke-properties");
      SDL.Properties.Set_Number (Props, "SDL3Ada.core.number", 42);
      SDL.Properties.Set_Boolean (Props, "SDL3Ada.core.enabled", True);
      SDL.Properties.Copy (Props, Copy);
      SDL.Properties.Lock (Copy);
      SDL.Properties.Unlock (Copy);

      if SDL.Properties.Get_String (Copy, SDL.Properties.Name_Property)
         /= "core-smoke-properties"
      then
         raise Program_Error with "SDL.Properties string round-trip failed";
      end if;

      if SDL.Properties.Get_Number (Copy, "SDL3Ada.core.number")
         /= SDL.Properties.Property_Numbers (42)
      then
         raise Program_Error with "SDL.Properties number round-trip failed";
      end if;

      if not SDL.Properties.Get_Boolean (Copy, "SDL3Ada.core.enabled") then
         raise Program_Error with "SDL.Properties boolean round-trip failed";
      end if;

      Ada.Text_IO.Put_Line ("SDL.Properties round-trip passed.");
   end;

   declare
      Default_Callback : constant SDL.Log.Output_Function :=
        SDL.Log.Default_Output_Function;
      Saved_Callback   : SDL.Log.Output_Function := null;
      Saved_User_Data  : System.Address := System.Null_Address;
      Capture          : aliased Log_Capture;
      Saved_Output     : Boolean := False;
   begin
      if Default_Callback = null then
         raise Program_Error with "SDL.Log default output callback was null";
      end if;

      SDL.Log.Get_Output_Function (Saved_Callback, Saved_User_Data);
      Saved_Output := True;

      if Saved_Callback = null then
         raise Program_Error with "SDL.Log output callback was null";
      end if;

      if not SDL.Log.Set_Priority_Prefix (SDL.Log.Warn, "phase2 warn: ") then
         Ada.Text_IO.Put_Line ("SDL log prefix set failed: " & SDL.Error.Get);
         raise Program_Error with "SDL log prefix set failed";
      end if;

      if not SDL.Log.Clear_Priority_Prefix (SDL.Log.Warn) then
         Ada.Text_IO.Put_Line ("SDL log prefix clear failed: " & SDL.Error.Get);
         raise Program_Error with "SDL log prefix clear failed";
      end if;

      SDL.Log.Set_Output_Function
        (Capture_Log'Unrestricted_Access, Capture'Address);
      SDL.Log.Put ("phase2 log callback", SDL.Log.Application, SDL.Log.Warn);
      SDL.Log.Set_Output_Function (Saved_Callback, Saved_User_Data);

      if Capture.Count /= 1 then
         raise Program_Error with "SDL.Log output callback was not invoked";
      end if;

      if Capture.Category /= SDL.Log.Application then
         raise Program_Error with "SDL.Log category capture mismatch";
      end if;

      if Capture.Priority /= SDL.Log.Warn then
         raise Program_Error with "SDL.Log priority capture mismatch";
      end if;

      if Capture.Message_Length <= 0 then
         raise Program_Error with "SDL.Log callback message was empty";
      end if;

      Ada.Text_IO.Put_Line ("SDL.Log callback round-trip passed.");
   exception
      when others =>
         if Saved_Output then
            SDL.Log.Set_Output_Function (Saved_Callback, Saved_User_Data);
         else
            SDL.Log.Reset_Output_Function;
         end if;

         raise;
   end;

   declare
      Handler_User_Data : aliased System.Address := System.Null_Address;
      Default_Handler   : constant SDL.Assertions.Assertion_Handler :=
        SDL.Assertions.Default_Handler;
      Current_Handler   : SDL.Assertions.Assertion_Handler;
   begin
      if Default_Handler = null then
         raise Program_Error with "SDL.Assertions default handler was null";
      end if;

      SDL.Assertions.Set_Handler (Default_Handler);
      Current_Handler := SDL.Assertions.Get_Handler (Handler_User_Data'Access);

      if Current_Handler /= Default_Handler then
         raise Program_Error with "SDL.Assertions handler round-trip failed";
      end if;

      if Handler_User_Data /= System.Null_Address then
         raise Program_Error with "SDL.Assertions handler user data was not reset";
      end if;

      SDL.Assertions.Reset_Report;

      if SDL.Assertions.Get_Report /= null then
         raise Program_Error with "SDL.Assertions report was not cleared";
      end if;

      Ada.Text_IO.Put_Line ("SDL.Assertions handler round-trip passed.");
   end;

   declare
      Locales : constant SDL.Locale.Locale_List := SDL.Locale.Preferred;
   begin
      Ada.Text_IO.Put_Line ("Preferred locale count:" & Integer'Image (Locales'Length));

      if Locales'Length > 0 then
         declare
            First    : constant SDL.Locale.Locale := Locales (Locales'First);
            Country  : constant String := US.To_String (First.Country);
         begin
            Ada.Text_IO.Put_Line
              ("First preferred locale: "
               & US.To_String (First.Language)
               & (if Country = "" then "" else "_" & Country));
         end;
      end if;
   end;

   declare
      Preferences : constant SDL.Time.Date_Time_Locale_Preferences :=
        SDL.Time.Get_Locale_Preferences;
      Current_Time : constant SDL.Time.Times := SDL.Time.Current;
      UTC_Time     : constant SDL.Time.Date_Time :=
        SDL.Time.To_Date_Time (Current_Time, Local_Time => False);
      Local_Time   : constant SDL.Time.Date_Time :=
        SDL.Time.To_Date_Time (Current_Time, Local_Time => True);
      Round_Trip   : constant SDL.Time.Times := SDL.Time.To_Time (UTC_Time);
      Windows_Time : constant SDL.Time.Windows_File_Time :=
        SDL.Time.To_Windows_File_Time (Current_Time);
   begin
      if Round_Trip /= Current_Time then
         raise Program_Error with "SDL.Time UTC round-trip failed";
      end if;

      if SDL.Time.Days_In_Month (Integer (Local_Time.Year), Integer (Local_Time.Month))
         < Positive (Local_Time.Day)
      then
         raise Program_Error with "SDL.Time days-in-month validation failed";
      end if;

      if SDL.Time.Day_Of_Week
          (Integer (Local_Time.Year),
           Integer (Local_Time.Month),
           Integer (Local_Time.Day))
         /= Natural (Local_Time.Day_Of_Week)
      then
         raise Program_Error with "SDL.Time day-of-week validation failed";
      end if;

      Ada.Text_IO.Put_Line
        ("SDL.Time locale preference:"
         & SDL.Time.Date_Formats'Image (Preferences.Date_Format)
         & " /"
         & SDL.Time.Time_Formats'Image (Preferences.Time_Format));
      Ada.Text_IO.Put_Line
        ("Current local date/time:"
         & Integer'Image (Integer (Local_Time.Year))
         & "-"
         & Integer'Image (Integer (Local_Time.Month))
         & "-"
         & Integer'Image (Integer (Local_Time.Day))
         & " UTC offset"
         & Integer'Image (Integer (Local_Time.UTC_Offset)));
      Ada.Text_IO.Put_Line
        ("Windows FILETIME parts:"
         & Interfaces.Unsigned_32'Image (Windows_Time.Low_Date_Time)
         & " /"
         & Interfaces.Unsigned_32'Image (Windows_Time.High_Date_Time));
      Ada.Text_IO.Put_Line ("SDL.Time round-trip passed.");
   end;

   Ada.Text_IO.Put_Line ("Base path: " & String (SDL.Filesystems.Base_Path));
   Ada.Text_IO.Put_Line
     ("Preferences path: "
      & String (SDL.Filesystems.Preferences_Path ("EllaMosi", "sdl3ada-core-smoke")));

   Ada.Text_IO.Put_Line ("Logical CPU count:" & Positive'Image (SDL.CPUS.Count));
   Ada.Text_IO.Put_Line
     ("CPU cache line size:" & Positive'Image (SDL.CPUS.Cache_Line_Size));
   Ada.Text_IO.Put_Line
     ("CPU system RAM MiB:" & Natural'Image (SDL.CPUS.System_RAM));
   Ada.Text_IO.Put_Line
     ("CPU SIMD alignment:" & Interfaces.C.size_t'Image (SDL.CPUS.SIMD_Alignment));
   Ada.Text_IO.Put_Line
     ("CPU page size:" & Natural'Image (SDL.CPUS.System_Page_Size));
   Ada.Text_IO.Put_Line
     ("CPU features: SSE="
      & Boolean'Image (SDL.CPUS.Has_SSE)
      & " SSE2="
      & Boolean'Image (SDL.CPUS.Has_SSE_2)
      & " SSE3="
      & Boolean'Image (SDL.CPUS.Has_SSE_3)
      & " SSE4.1="
      & Boolean'Image (SDL.CPUS.Has_SSE_4_1)
      & " SSE4.2="
      & Boolean'Image (SDL.CPUS.Has_SSE_4_2)
      & " MMX="
      & Boolean'Image (SDL.CPUS.Has_MMX)
      & " AVX="
      & Boolean'Image (SDL.CPUS.Has_AVX)
      & " AVX2="
      & Boolean'Image (SDL.CPUS.Has_AVX_2)
      & " AVX512F="
      & Boolean'Image (SDL.CPUS.Has_AVX_512F)
      & " NEON="
      & Boolean'Image (SDL.CPUS.Has_NEON)
      & " ARM_SIMD="
      & Boolean'Image (SDL.CPUS.Has_ARM_SIMD)
      & " LSX="
      & Boolean'Image (SDL.CPUS.Has_LSX)
      & " LASX="
      & Boolean'Image (SDL.CPUS.Has_LASX)
      & " AltiVec="
      & Boolean'Image (SDL.CPUS.Has_AltiVec));

   SDL.Power.Info (Power_Info);
   Ada.Text_IO.Put_Line ("Power state:" & SDL.Power.State'Image (Power_Info.Power_State));

   declare
      Library_Path : constant String := Probe_Library_Path;
   begin
      if Library_Path = "" then
         Ada.Text_IO.Put_Line
           ("SDL.Libraries runtime probe skipped; build examples/build_library_probe.sh to enable it.");
      else
         declare
            Library      : SDL.Libraries.Handles;
            Probe        : Probe_Function_Access;
            Probe_String : CS.chars_ptr := CS.New_String ("21");
         begin
            SDL.Libraries.Load (Library, Library_Path);
            Probe := Load_Probe_Function (Library);

            if Probe (Probe_String) /= 42 then
               raise Program_Error with "SDL.Libraries runtime probe returned wrong value";
            end if;

            CS.Free (Probe_String);
            SDL.Libraries.Unload (Library);
            Ada.Text_IO.Put_Line ("SDL.Libraries runtime probe passed.");
         exception
            when others =>
               CS.Free (Probe_String);
               raise;
         end;
      end if;
   end;

   SDL.Error.Clear;
   Ada.Text_IO.Put_Line ("SDL error after clear: " & SDL.Error.Get);
   if SDL.Error.Out_Of_Memory then
      raise Program_Error with "SDL.Out_Of_Memory unexpectedly returned true";
   end if;

   if SDL.Error.Get = "" then
      raise Program_Error with "SDL.Out_Of_Memory did not set an error";
   end if;

   SDL.Error.Clear;
   Ada.Text_IO.Put_Line ("Tick delta:" & SDL.Timers.Milliseconds'Image (End_Ticks - Start_Ticks));
   SDL.Quit;
   SDL_Initialized := False;
exception
   when others =>
      if SDL_Initialized then
         SDL.Quit;
      end if;

      raise;
end Core_Smoke;
