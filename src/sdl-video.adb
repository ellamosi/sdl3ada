with Interfaces.C.Strings;

with SDL.Error;
with SDL.Hints;
with SDL.Raw.Video;

package body SDL.Video is
   package CS renames Interfaces.C.Strings;
   package Raw renames SDL.Raw.Video;

   use type CS.chars_ptr;

   function To_Raw_Blend_Factor
     (Value : in Blend_Factors) return Raw.Blend_Factor;

   function To_Raw_Blend_Factor
     (Value : in Blend_Factors) return Raw.Blend_Factor is
   begin
      case Value is
         when Zero_Factor =>
            return Raw.Zero_Factor;
         when One_Factor =>
            return Raw.One_Factor;
         when Source_Colour_Factor =>
            return Raw.Source_Colour_Factor;
         when One_Minus_Source_Colour_Factor =>
            return Raw.One_Minus_Source_Colour_Factor;
         when Source_Alpha_Factor =>
            return Raw.Source_Alpha_Factor;
         when One_Minus_Source_Alpha_Factor =>
            return Raw.One_Minus_Source_Alpha_Factor;
         when Destination_Colour_Factor =>
            return Raw.Destination_Colour_Factor;
         when One_Minus_Destination_Colour_Factor =>
            return Raw.One_Minus_Destination_Colour_Factor;
         when Destination_Alpha_Factor =>
            return Raw.Destination_Alpha_Factor;
         when One_Minus_Destination_Alpha_Factor =>
            return Raw.One_Minus_Destination_Alpha_Factor;
      end case;
   end To_Raw_Blend_Factor;

   function To_Raw_Blend_Operation
     (Value : in Blend_Operations) return Raw.Blend_Operation;

   function To_Raw_Blend_Operation
     (Value : in Blend_Operations) return Raw.Blend_Operation is
   begin
      case Value is
         when Add_Operation =>
            return Raw.Add_Operation;
         when Subtract_Operation =>
            return Raw.Subtract_Operation;
         when Reverse_Subtract_Operation =>
            return Raw.Reverse_Subtract_Operation;
         when Minimum_Operation =>
            return Raw.Minimum_Operation;
         when Maximum_Operation =>
            return Raw.Maximum_Operation;
      end case;
   end To_Raw_Blend_Operation;

   function To_Public_System_Theme
     (Value : in Raw.System_Theme) return System_Themes;

   function To_Public_System_Theme
     (Value : in Raw.System_Theme) return System_Themes is
   begin
      case Value is
         when Raw.Unknown_Theme =>
            return Unknown_Theme;
         when Raw.Light_Theme =>
            return Light_Theme;
         when Raw.Dark_Theme =>
            return Dark_Theme;
      end case;
   end To_Public_System_Theme;

   function Initialise (Name : in String := "") return Boolean is
   begin
      if Name'Length > 0 then
         SDL.Hints.Set (SDL.Hints.Video_Driver, Name);
      end if;

      return SDL.Initialise_Sub_System (SDL.Enable_Video);
   end Initialise;

   procedure Finalise is
   begin
      SDL.Quit_Sub_System (SDL.Enable_Video);
   end Finalise;

   function Total_Drivers return Positive is
      Count : constant C.int := Raw.Get_Num_Video_Drivers;
   begin
      if Count < 1 then
         raise Video_Error with SDL.Error.Get;
      end if;

      return Positive (Count);
   end Total_Drivers;

   function Driver_Name (Index : in Positive) return String is
      Name : constant CS.chars_ptr :=
        Raw.Get_Video_Driver (C.int (Index - 1));
   begin
      if Name = CS.Null_Ptr then
         return "";
      end if;

      return CS.Value (Name);
   end Driver_Name;

   function Current_Driver_Name return String is
      Name : constant CS.chars_ptr := Raw.Get_Current_Video_Driver;
   begin
      if Name = CS.Null_Ptr then
         return "";
      end if;

      return CS.Value (Name);
   end Current_Driver_Name;

   function Current_System_Theme return System_Themes is
   begin
      return To_Public_System_Theme (Raw.Get_System_Theme);
   end Current_System_Theme;

   function Compose_Custom_Blend_Mode
     (Source_Colour_Factor      : in Blend_Factors;
      Destination_Colour_Factor : in Blend_Factors;
      Colour_Operation          : in Blend_Operations;
      Source_Alpha_Factor       : in Blend_Factors;
      Destination_Alpha_Factor  : in Blend_Factors;
      Alpha_Operation           : in Blend_Operations) return Blend_Modes
   is
   begin
      return
        Blend_Modes
          (Raw.Compose_Custom_Blend_Mode
             (Source_Colour_Factor      => To_Raw_Blend_Factor (Source_Colour_Factor),
              Destination_Colour_Factor =>
                To_Raw_Blend_Factor (Destination_Colour_Factor),
              Colour_Operation          => To_Raw_Blend_Operation (Colour_Operation),
              Source_Alpha_Factor       => To_Raw_Blend_Factor (Source_Alpha_Factor),
              Destination_Alpha_Factor  =>
                To_Raw_Blend_Factor (Destination_Alpha_Factor),
              Alpha_Operation           => To_Raw_Blend_Operation (Alpha_Operation)));
   end Compose_Custom_Blend_Mode;

   procedure Enable_Screen_Saver is
   begin
      if not Boolean (Raw.Enable_Screen_Saver) then
         raise Video_Error with SDL.Error.Get;
      end if;
   end Enable_Screen_Saver;

   procedure Disable_Screen_Saver is
   begin
      if not Boolean (Raw.Disable_Screen_Saver) then
         raise Video_Error with SDL.Error.Get;
      end if;
   end Disable_Screen_Saver;

   function Is_Screen_Saver_Enabled return Boolean is
   begin
      return Boolean (Raw.Screen_Saver_Enabled);
   end Is_Screen_Saver_Enabled;
end SDL.Video;
