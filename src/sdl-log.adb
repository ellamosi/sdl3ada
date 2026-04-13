with Interfaces.C.Extensions;

package body SDL.Log is
   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;

   function SDL_Set_Log_Priority_Prefix
     (Priority : in Priorities;
      Prefix   : in CS.chars_ptr) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetLogPriorityPrefix";

   procedure SDL_Log_Message_V
     (Category  : in Categories;
      Priority  : in Priorities;
      Format    : in CS.chars_ptr;
      Arguments : in Sys.Address)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_LogMessageV";

   function SDL_Get_Default_Log_Output_Function return Output_Function with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetDefaultLogOutputFunction";

   procedure SDL_Get_Log_Output_Function
     (Callback  : access Output_Function;
      User_Data : access Sys.Address)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetLogOutputFunction";

   procedure SDL_Set_Log_Output_Function
     (Callback  : in Output_Function;
      User_Data : in Sys.Address)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetLogOutputFunction";

   procedure Put (Message : in String) is
      procedure SDL_Log (C_Fmt, C_Message : in C.char_array) with
        Import        => True,
        Convention    => C_Variadic_1,
        External_Name => "SDL_Log";
   begin
      SDL_Log (C.To_C ("%s"), C.To_C (Message));
   end Put;

   procedure Put (Message : in String; Category : in Categories; Priority : in Priorities) is
      procedure SDL_Log_Message
        (Category : in Categories;
         Priority : in Priorities;
         C_Fmt,
         C_Message : in C.char_array) with
        Import        => True,
        Convention    => C_Variadic_1,
        External_Name => "SDL_LogMessage";
   begin
      SDL_Log_Message (Category, Priority, C.To_C ("%s"), C.To_C (Message));
   end Put;

   procedure Put_Critical (Message : in String; Category : in Categories := Application) is
      procedure SDL_Log_Critical (Category : in Categories; C_Fmt, C_Message : in C.char_array) with
        Import        => True,
        Convention    => C_Variadic_1,
        External_Name => "SDL_LogCritical";
   begin
      SDL_Log_Critical (Category, C.To_C ("%s"), C.To_C (Message));
   end Put_Critical;

   procedure Put_Debug (Message : in String; Category : in Categories := Application) is
      procedure SDL_Log_Debug (Category : in Categories; C_Fmt, C_Message : in C.char_array) with
        Import        => True,
        Convention    => C_Variadic_1,
        External_Name => "SDL_LogDebug";
   begin
      SDL_Log_Debug (Category, C.To_C ("%s"), C.To_C (Message));
   end Put_Debug;

   procedure Put_Error (Message : in String; Category : in Categories := Application) is
      procedure SDL_Log_Error (Category : in Categories; C_Fmt, C_Message : in C.char_array) with
        Import        => True,
        Convention    => C_Variadic_1,
        External_Name => "SDL_LogError";
   begin
      SDL_Log_Error (Category, C.To_C ("%s"), C.To_C (Message));
   end Put_Error;

   procedure Put_Info (Message : in String; Category : in Categories := Application) is
      procedure SDL_Log_Info (Category : in Categories; C_Fmt, C_Message : in C.char_array) with
        Import        => True,
        Convention    => C_Variadic_1,
        External_Name => "SDL_LogInfo";
   begin
      SDL_Log_Info (Category, C.To_C ("%s"), C.To_C (Message));
   end Put_Info;

   procedure Put_Trace (Message : in String; Category : in Categories := Application) is
      procedure SDL_Log_Trace (Category : in Categories; C_Fmt, C_Message : in C.char_array) with
        Import        => True,
        Convention    => C_Variadic_1,
        External_Name => "SDL_LogTrace";
   begin
      SDL_Log_Trace (Category, C.To_C ("%s"), C.To_C (Message));
   end Put_Trace;

   procedure Put_Verbose (Message : in String; Category : in Categories := Application) is
      procedure SDL_Log_Verbose (Category : in Categories; C_Fmt, C_Message : in C.char_array) with
        Import        => True,
        Convention    => C_Variadic_1,
        External_Name => "SDL_LogVerbose";
   begin
      SDL_Log_Verbose (Category, C.To_C ("%s"), C.To_C (Message));
   end Put_Verbose;

   procedure Put_Warn (Message : in String; Category : in Categories := Application) is
      procedure SDL_Log_Warn (Category : in Categories; C_Fmt, C_Message : in C.char_array) with
        Import        => True,
        Convention    => C_Variadic_1,
        External_Name => "SDL_LogWarn";
   begin
      SDL_Log_Warn (Category, C.To_C ("%s"), C.To_C (Message));
   end Put_Warn;

   function Set_Priority_Prefix
     (Priority : in Priorities;
      Prefix   : in String) return Boolean
   is
      C_Prefix : CS.chars_ptr := CS.New_String (Prefix);
   begin
      begin
         return Result : constant Boolean :=
           Boolean (SDL_Set_Log_Priority_Prefix (Priority, C_Prefix))
         do
            CS.Free (C_Prefix);
         end return;
      exception
         when others =>
            CS.Free (C_Prefix);
            raise;
      end;
   end Set_Priority_Prefix;

   function Clear_Priority_Prefix (Priority : in Priorities) return Boolean is
     (Boolean (SDL_Set_Log_Priority_Prefix (Priority, CS.Null_Ptr)));

   procedure Put_Message_V
     (Category  : in Categories;
      Priority  : in Priorities;
      Format    : in CS.chars_ptr;
      Arguments : in Sys.Address) is
   begin
      SDL_Log_Message_V (Category, Priority, Format, Arguments);
   end Put_Message_V;

   function Default_Output_Function return Output_Function is
     (SDL_Get_Default_Log_Output_Function);

   procedure Get_Output_Function
     (Callback  : out Output_Function;
      User_Data : out Sys.Address)
   is
      Local_Callback  : aliased Output_Function := null;
      Local_User_Data : aliased Sys.Address := Sys.Null_Address;
   begin
      SDL_Get_Log_Output_Function
        (Local_Callback'Access, Local_User_Data'Access);
      Callback := Local_Callback;
      User_Data := Local_User_Data;
   end Get_Output_Function;

   procedure Set_Output_Function
     (Callback  : in Output_Function;
      User_Data : in Sys.Address := Sys.Null_Address) is
   begin
      SDL_Set_Log_Output_Function (Callback, User_Data);
   end Set_Output_Function;

   procedure Reset_Output_Function is
   begin
      SDL_Set_Log_Output_Function
        (Default_Output_Function, Sys.Null_Address);
   end Reset_Output_Function;
end SDL.Log;
