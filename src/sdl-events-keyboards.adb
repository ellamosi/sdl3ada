package body SDL.Events.Keyboards is
   package CS renames Interfaces.C.Strings;

   use type CS.chars_ptr;

   function Value (Name : in String) return Scan_Codes is
      function SDL_Get_Scancode_From_Name (Value : in C.char_array) return Scan_Codes with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetScancodeFromName";
   begin
      return SDL_Get_Scancode_From_Name (C.To_C (Name));
   end Value;

   function Image (Scan_Code : in Scan_Codes) return String is
      function SDL_Get_Scancode_Name (Value : in Scan_Codes) return CS.chars_ptr with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetScancodeName";

      Result : constant CS.chars_ptr := SDL_Get_Scancode_Name (Scan_Code);
   begin
      if Result = CS.Null_Ptr then
         return "";
      end if;

      return CS.Value (Result);
   end Image;

   function Value (Name : in String) return Key_Codes is
      function SDL_Get_Key_From_Name (Value : in C.char_array) return Key_Codes with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetKeyFromName";
   begin
      return SDL_Get_Key_From_Name (C.To_C (Name));
   end Value;

   function Image (Key_Code : in Key_Codes) return String is
      function SDL_Get_Key_Name (Value : in Key_Codes) return CS.chars_ptr with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetKeyName";

      Result : constant CS.chars_ptr := SDL_Get_Key_Name (Key_Code);
   begin
      if Result = CS.Null_Ptr then
         return "";
      end if;

      return CS.Value (Result);
   end Image;

   function Set_Name
     (Scan_Code : in Scan_Codes;
      Name      : in CS.chars_ptr) return Boolean
   is
      function SDL_Set_Scancode_Name
        (Value : in Scan_Codes;
         Text  : in CS.chars_ptr) return CE.bool with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_SetScancodeName";
   begin
      return Boolean (SDL_Set_Scancode_Name (Scan_Code, Name));
   end Set_Name;

   function To_Key_Code
     (Scan_Code : in Scan_Codes;
      Modifiers : in Key_Modifiers;
      Key_Event : in Boolean) return Key_Codes
   is
      function SDL_Get_Key_From_Scan_Code
        (Value     : in Scan_Codes;
         Modifiers : in Key_Modifiers;
         Key_Event : in CE.bool) return Key_Codes with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetKeyFromScancode";
   begin
      return SDL_Get_Key_From_Scan_Code
        (Scan_Code,
         Modifiers,
         (if Key_Event then CE.bool'Val (1) else CE.bool'Val (0)));
   end To_Key_Code;

   function To_Key_Code (Scan_Code : in Scan_Codes) return Key_Codes is
   begin
      return To_Key_Code
        (Scan_Code => Scan_Code,
         Modifiers => Modifier_None,
         Key_Event => False);
   end To_Key_Code;

   function To_Scan_Code
     (Key_Code  : in Key_Codes;
      Modifiers : out Key_Modifiers) return Scan_Codes
   is
      function SDL_Get_Scan_Code_From_Key
        (Value     : in Key_Codes;
         Modifiers : access Key_Modifiers) return Scan_Codes with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetScancodeFromKey";

      Local_Modifiers : aliased Key_Modifiers := Modifier_None;
   begin
      return Result : constant Scan_Codes :=
        SDL_Get_Scan_Code_From_Key (Key_Code, Local_Modifiers'Access)
      do
         Modifiers := Local_Modifiers;
      end return;
   end To_Scan_Code;

   function To_Scan_Code (Key_Code : in Key_Codes) return Scan_Codes is
      Modifiers : Key_Modifiers;
   begin
      return To_Scan_Code (Key_Code, Modifiers);
   end To_Scan_Code;
end SDL.Events.Keyboards;
