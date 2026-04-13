with Interfaces;
with Interfaces.C;

package SDL.Pens is
   package C renames Interfaces.C;

   type ID is mod 2 ** 32 with
     Convention => C,
     Size       => 32;

   type Input_Flags is mod 2 ** 32 with
     Convention => C,
     Size       => 32;

   Input_Down              : constant Input_Flags := 16#0000_0001#;
   Input_Button_1          : constant Input_Flags := 16#0000_0002#;
   Input_Button_2          : constant Input_Flags := 16#0000_0004#;
   Input_Button_3          : constant Input_Flags := 16#0000_0008#;
   Input_Button_4          : constant Input_Flags := 16#0000_0010#;
   Input_Button_5          : constant Input_Flags := 16#0000_0020#;
   Input_Eraser_Tip        : constant Input_Flags := 16#4000_0000#;
   Input_In_Proximity      : constant Input_Flags := 16#8000_0000#;

   type Axes is
     (Pressure,
      X_Tilt,
      Y_Tilt,
      Distance,
      Rotation,
      Slider,
      Tangential_Pressure,
      Count)
   with
     Convention => C,
     Size       => C.int'Size;

   for Axes use
     (Pressure            => 0,
      X_Tilt              => 1,
      Y_Tilt              => 2,
      Distance            => 3,
      Rotation            => 4,
      Slider              => 5,
      Tangential_Pressure => 6,
      Count               => 7);

   type Device_Types is
     (Invalid,
      Unknown,
      Direct,
      Indirect)
   with
     Convention => C,
     Size       => C.int'Size;

   for Device_Types use
     (Invalid  => -1,
      Unknown  => 0,
      Direct   => 1,
      Indirect => 2);

   function Has_Flag
     (State : in Input_Flags;
      Flag  : in Input_Flags) return Boolean is
       ((State and Flag) = Flag)
   with
     Inline;

   function Get_Device_Type (Instance : in ID) return Device_Types
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetPenDeviceType";
end SDL.Pens;
