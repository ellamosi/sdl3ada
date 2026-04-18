with SDL.Raw.Keyboard;

package body SDL.Events.Keyboards is
   package CS renames Interfaces.C.Strings;
   package Raw renames SDL.Raw.Keyboard;

   use type CS.chars_ptr;

   function Value (Name : in String) return Scan_Codes is
   begin
      return Scan_Codes (Raw.Get_Scancode_From_Name (C.To_C (Name)));
   end Value;

   function Image (Scan_Code : in Scan_Codes) return String is
      Result : constant CS.chars_ptr :=
        Raw.Get_Scancode_Name (Raw.Scan_Code (Scan_Code));
   begin
      if Result = CS.Null_Ptr then
         return "";
      end if;

      return CS.Value (Result);
   end Image;

   function Value (Name : in String) return Key_Codes is
   begin
      return Key_Codes (Raw.Get_Key_From_Name (C.To_C (Name)));
   end Value;

   function Image (Key_Code : in Key_Codes) return String is
      Result : constant CS.chars_ptr :=
        Raw.Get_Key_Name (Raw.Key_Code (Key_Code));
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
   begin
      return Boolean (Raw.Set_Scancode_Name (Raw.Scan_Code (Scan_Code), Name));
   end Set_Name;

   function To_Key_Code
     (Scan_Code : in Scan_Codes;
      Modifiers : in Key_Modifiers;
      Key_Event : in Boolean) return Key_Codes
   is
   begin
      return Key_Codes
        (Raw.Get_Key_From_Scan_Code
           (Value     => Raw.Scan_Code (Scan_Code),
            Modifiers => Raw.Key_Modifier (Modifiers),
            Key_Event => (if Key_Event then CE.bool'Val (1) else CE.bool'Val (0))));
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
      Local_Modifiers : aliased Raw.Key_Modifier :=
        Raw.Key_Modifier (Modifier_None);
   begin
      return Result : constant Scan_Codes :=
        Scan_Codes
          (Raw.Get_Scan_Code_From_Key
             (Raw.Key_Code (Key_Code), Local_Modifiers'Access))
      do
         Modifiers := Key_Modifiers (Local_Modifiers);
      end return;
   end To_Scan_Code;

   function To_Scan_Code (Key_Code : in Key_Codes) return Scan_Codes is
      Modifiers : Key_Modifiers;
   begin
      return To_Scan_Code (Key_Code, Modifiers);
   end To_Scan_Code;
end SDL.Events.Keyboards;
