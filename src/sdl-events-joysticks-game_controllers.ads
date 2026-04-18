package SDL.Events.Joysticks.Game_Controllers is
   pragma Pure;

   type Axes is
     (Invalid,
      Left_X,
      Left_Y,
      Right_X,
      Right_Y,
      Trigger_Left,
      Trigger_Right) with
     Convention => C;

   for Axes use
     (Invalid       => -1,
      Left_X        => 0,
      Left_Y        => 1,
      Right_X       => 2,
      Right_Y       => 3,
      Trigger_Left  => 4,
      Trigger_Right => 5);

   subtype LR_Axes is Axes range Left_X .. Right_Y;
   subtype Trigger_Axes is Axes range Trigger_Left .. Trigger_Right;

   type LR_Axes_Values is range -32_768 .. 32_767 with
     Convention => C,
     Size       => 16;

   type Trigger_Axes_Values is range 0 .. 32_767 with
     Convention => C,
     Size       => 16;

   type Buttons is
     (Invalid,
      A,
      B,
      X,
      Y,
      Back,
      Guide,
      Start,
      Left_Stick,
      Right_Stick,
      Left_Shoulder,
      Right_Shoulder,
      D_Pad_Up,
      D_Pad_Down,
      D_Pad_Left,
      D_Pad_Right,
      Misc_1,
      Right_Paddle_1,
      Left_Paddle_1,
      Right_Paddle_2,
      Left_Paddle_2,
      Touchpad,
      Misc_2,
      Misc_3,
      Misc_4,
      Misc_5,
      Misc_6) with
     Convention => C;

   for Buttons use
     (Invalid          => -1,
      A                => 0,
      B                => 1,
      X                => 2,
      Y                => 3,
      Back             => 4,
      Guide            => 5,
      Start            => 6,
      Left_Stick       => 7,
      Right_Stick      => 8,
      Left_Shoulder    => 9,
      Right_Shoulder   => 10,
      D_Pad_Up         => 11,
      D_Pad_Down       => 12,
      D_Pad_Left       => 13,
      D_Pad_Right      => 14,
      Misc_1           => 15,
      Right_Paddle_1   => 16,
      Left_Paddle_1    => 17,
      Right_Paddle_2   => 18,
      Left_Paddle_2    => 19,
      Touchpad         => 20,
      Misc_2           => 21,
      Misc_3           => 22,
      Misc_4           => 23,
      Misc_5           => 24,
      Misc_6           => 25);

   procedure Update;

   function Is_Polling_Enabled return Boolean;

   procedure Enable_Polling;

   procedure Disable_Polling;
end SDL.Events.Joysticks.Game_Controllers;
