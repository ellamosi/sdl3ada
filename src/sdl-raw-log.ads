with Interfaces.C;
with Interfaces.C.Extensions;
with Interfaces.C.Strings;
with System;

package SDL.Raw.Log is
   pragma Preelaborate;

   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;
   package CS renames Interfaces.C.Strings;

   subtype Categories is C.int;

   type Priorities is
     (Invalid,
      Trace,
      Verbose,
      Debug,
      Info,
      Warn,
      Error,
      Critical,
      Count)
   with
     Convention => C,
     Size       => C.int'Size;

   for Priorities use
     (Invalid  => 0,
      Trace    => 1,
      Verbose  => 2,
      Debug    => 3,
      Info     => 4,
      Warn     => 5,
      Error    => 6,
      Critical => 7,
      Count    => 8);

   type Output_Function is access procedure
     (User_Data : in System.Address;
      Category  : in Categories;
      Priority  : in Priorities;
      Message   : in CS.chars_ptr)
   with Convention => C;

   procedure Reset_Log_Priorities
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ResetLogPriorities";

   function Set_Log_Priority_Prefix
     (Priority : in Priorities;
      Prefix   : in CS.chars_ptr) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetLogPriorityPrefix";

   procedure Set_Log_Priorities (Priority : in Priorities)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetLogPriorities";

   procedure Set_Log_Priority
     (Category : in Categories;
      Priority : in Priorities)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetLogPriority";

   function Get_Log_Priority (Category : in Categories) return Priorities
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetLogPriority";

   procedure Log (Fmt, Message : in C.char_array)
   with
     Import        => True,
     Convention    => C_Variadic_1,
     External_Name => "SDL_Log";

   procedure Log_Message
     (Category : in Categories;
      Priority : in Priorities;
      Fmt      : in C.char_array;
      Message  : in C.char_array)
   with
     Import        => True,
     Convention    => C_Variadic_1,
     External_Name => "SDL_LogMessage";

   procedure Log_Critical
     (Category : in Categories;
      Fmt      : in C.char_array;
      Message  : in C.char_array)
   with
     Import        => True,
     Convention    => C_Variadic_1,
     External_Name => "SDL_LogCritical";

   procedure Log_Debug
     (Category : in Categories;
      Fmt      : in C.char_array;
      Message  : in C.char_array)
   with
     Import        => True,
     Convention    => C_Variadic_1,
     External_Name => "SDL_LogDebug";

   procedure Log_Error
     (Category : in Categories;
      Fmt      : in C.char_array;
      Message  : in C.char_array)
   with
     Import        => True,
     Convention    => C_Variadic_1,
     External_Name => "SDL_LogError";

   procedure Log_Info
     (Category : in Categories;
      Fmt      : in C.char_array;
      Message  : in C.char_array)
   with
     Import        => True,
     Convention    => C_Variadic_1,
     External_Name => "SDL_LogInfo";

   procedure Log_Trace
     (Category : in Categories;
      Fmt      : in C.char_array;
      Message  : in C.char_array)
   with
     Import        => True,
     Convention    => C_Variadic_1,
     External_Name => "SDL_LogTrace";

   procedure Log_Verbose
     (Category : in Categories;
      Fmt      : in C.char_array;
      Message  : in C.char_array)
   with
     Import        => True,
     Convention    => C_Variadic_1,
     External_Name => "SDL_LogVerbose";

   procedure Log_Warn
     (Category : in Categories;
      Fmt      : in C.char_array;
      Message  : in C.char_array)
   with
     Import        => True,
     Convention    => C_Variadic_1,
     External_Name => "SDL_LogWarn";

   procedure Log_Message_V
     (Category  : in Categories;
      Priority  : in Priorities;
      Format    : in CS.chars_ptr;
      Arguments : in System.Address)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_LogMessageV";

   function Get_Default_Log_Output_Function return Output_Function
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetDefaultLogOutputFunction";

   procedure Get_Log_Output_Function
     (Callback  : access Output_Function;
      User_Data : access System.Address)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetLogOutputFunction";

   procedure Set_Log_Output_Function
     (Callback  : in Output_Function;
      User_Data : in System.Address)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetLogOutputFunction";
end SDL.Raw.Log;
