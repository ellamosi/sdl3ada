with Interfaces.C;

package SDL.Video is
   pragma Preelaborate;
   pragma Elaborate_Body;

   package C renames Interfaces.C;

   Video_Error : exception;

   type Blend_Modes is mod 2 ** 32 with
     Convention => C,
     Size       => 32;

   None                      : constant Blend_Modes := 16#0000_0000#;
   Alpha_Blend               : constant Blend_Modes := 16#0000_0001#;
   Additive                  : constant Blend_Modes := 16#0000_0002#;
   Colour_Modulate           : constant Blend_Modes := 16#0000_0004#;
   Multiply                  : constant Blend_Modes := 16#0000_0008#;
   Alpha_Blend_Pre_Multiplied : constant Blend_Modes := 16#0000_0010#;
   Additive_Pre_Multiplied   : constant Blend_Modes := 16#0000_0020#;
   Invalid_Blend_Mode        : constant Blend_Modes := 16#7FFF_FFFF#;

   type Blend_Operations is
     (Add_Operation,
      Subtract_Operation,
      Reverse_Subtract_Operation,
      Minimum_Operation,
      Maximum_Operation)
   with
     Convention => C,
     Size       => C.int'Size;

   for Blend_Operations use
     (Add_Operation              => 16#1#,
      Subtract_Operation         => 16#2#,
      Reverse_Subtract_Operation => 16#3#,
      Minimum_Operation          => 16#4#,
      Maximum_Operation          => 16#5#);

   type Blend_Factors is
     (Zero_Factor,
      One_Factor,
      Source_Colour_Factor,
      One_Minus_Source_Colour_Factor,
      Source_Alpha_Factor,
      One_Minus_Source_Alpha_Factor,
      Destination_Colour_Factor,
      One_Minus_Destination_Colour_Factor,
      Destination_Alpha_Factor,
      One_Minus_Destination_Alpha_Factor)
   with
     Convention => C,
     Size       => C.int'Size;

   for Blend_Factors use
     (Zero_Factor                      => 16#1#,
      One_Factor                       => 16#2#,
      Source_Colour_Factor             => 16#3#,
      One_Minus_Source_Colour_Factor   => 16#4#,
      Source_Alpha_Factor              => 16#5#,
      One_Minus_Source_Alpha_Factor    => 16#6#,
      Destination_Colour_Factor        => 16#7#,
      One_Minus_Destination_Colour_Factor => 16#8#,
      Destination_Alpha_Factor         => 16#9#,
      One_Minus_Destination_Alpha_Factor => 16#A#);

   function Compose_Custom_Blend_Mode
     (Source_Colour_Factor      : in Blend_Factors;
      Destination_Colour_Factor : in Blend_Factors;
      Colour_Operation          : in Blend_Operations;
      Source_Alpha_Factor       : in Blend_Factors;
      Destination_Alpha_Factor  : in Blend_Factors;
      Alpha_Operation           : in Blend_Operations) return Blend_Modes;

   type System_Themes is
     (Unknown_Theme,
      Light_Theme,
      Dark_Theme)
   with
     Convention => C,
     Size       => C.int'Size;

   function Initialise (Name : in String := "") return Boolean;

   procedure Finalise;

   function Total_Drivers return Positive;

   function Driver_Name (Index : in Positive) return String;

   function Current_Driver_Name return String;

   function Current_System_Theme return System_Themes;

   procedure Enable_Screen_Saver;

   procedure Disable_Screen_Saver;

   function Is_Screen_Saver_Enabled return Boolean;
end SDL.Video;
