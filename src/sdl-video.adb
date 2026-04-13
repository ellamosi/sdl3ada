with Interfaces.C;
with Interfaces.C.Extensions;
with Interfaces.C.Strings;

with SDL.Error;
with SDL.Hints;

package body SDL.Video is
   package CE renames Interfaces.C.Extensions;
   package CS renames Interfaces.C.Strings;

   use type CS.chars_ptr;

   function SDL_Get_Num_Video_Drivers return C.int with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetNumVideoDrivers";

   function SDL_Get_Video_Driver
     (Index : in C.int) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetVideoDriver";

   function SDL_Get_Current_Video_Driver return CS.chars_ptr with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetCurrentVideoDriver";

   function SDL_Get_System_Theme return System_Themes with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetSystemTheme";

   function SDL_Compose_Custom_Blend_Mode
     (Source_Colour_Factor      : in Blend_Factors;
      Destination_Colour_Factor : in Blend_Factors;
      Colour_Operation          : in Blend_Operations;
      Source_Alpha_Factor       : in Blend_Factors;
      Destination_Alpha_Factor  : in Blend_Factors;
      Alpha_Operation           : in Blend_Operations) return Blend_Modes
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ComposeCustomBlendMode";

   function SDL_Screen_Saver_Enabled return CE.bool with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ScreenSaverEnabled";

   function SDL_Enable_Screen_Saver return CE.bool with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_EnableScreenSaver";

   function SDL_Disable_Screen_Saver return CE.bool with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_DisableScreenSaver";

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
      Count : constant C.int := SDL_Get_Num_Video_Drivers;
   begin
      if Count < 1 then
         raise Video_Error with SDL.Error.Get;
      end if;

      return Positive (Count);
   end Total_Drivers;

   function Driver_Name (Index : in Positive) return String is
      Name : constant CS.chars_ptr := SDL_Get_Video_Driver (C.int (Index - 1));
   begin
      if Name = CS.Null_Ptr then
         return "";
      end if;

      return CS.Value (Name);
   end Driver_Name;

   function Current_Driver_Name return String is
      Name : constant CS.chars_ptr := SDL_Get_Current_Video_Driver;
   begin
      if Name = CS.Null_Ptr then
         return "";
      end if;

      return CS.Value (Name);
   end Current_Driver_Name;

   function Current_System_Theme return System_Themes is
   begin
      return SDL_Get_System_Theme;
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
        SDL_Compose_Custom_Blend_Mode
          (Source_Colour_Factor      => Source_Colour_Factor,
           Destination_Colour_Factor => Destination_Colour_Factor,
           Colour_Operation          => Colour_Operation,
           Source_Alpha_Factor       => Source_Alpha_Factor,
           Destination_Alpha_Factor  => Destination_Alpha_Factor,
           Alpha_Operation           => Alpha_Operation);
   end Compose_Custom_Blend_Mode;

   procedure Enable_Screen_Saver is
   begin
      if not Boolean (SDL_Enable_Screen_Saver) then
         raise Video_Error with SDL.Error.Get;
      end if;
   end Enable_Screen_Saver;

   procedure Disable_Screen_Saver is
   begin
      if not Boolean (SDL_Disable_Screen_Saver) then
         raise Video_Error with SDL.Error.Get;
      end if;
   end Disable_Screen_Saver;

   function Is_Screen_Saver_Enabled return Boolean is
   begin
      return Boolean (SDL_Screen_Saver_Enabled);
   end Is_Screen_Saver_Enabled;
end SDL.Video;
