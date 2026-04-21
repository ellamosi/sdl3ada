with Interfaces;
with Interfaces.C;
with Interfaces.C.Extensions;
with Interfaces.C.Pointers;
with Interfaces.C.Strings;
with System;

with SDL.Raw.C_Pointers;

package SDL.Raw.Haptic is
   pragma Preelaborate;

   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;
   package CS renames Interfaces.C.Strings;

   subtype ID is Interfaces.Unsigned_32;
   subtype Features is Interfaces.Unsigned_32;
   type Effect_Types is mod 2 ** 16 with
     Convention => C,
     Size       => 16;

   subtype Direction_Types is Interfaces.Unsigned_8;
   subtype Effect_ID is C.int;
   subtype Replay_Counts is Interfaces.Unsigned_32;
   subtype Unsigned_16 is Interfaces.Unsigned_16;
   subtype Signed_16 is Interfaces.Integer_16;
   subtype Signed_32 is Interfaces.Integer_32;
   subtype Channel_Counts is Interfaces.Unsigned_8;

   Infinity : constant Replay_Counts := 16#FFFF_FFFF#;

   Constant_Effect      : constant Effect_Types := 16#0001#;
   Sine_Effect          : constant Effect_Types := 16#0002#;
   Square_Effect        : constant Effect_Types := 16#0004#;
   Triangle_Effect      : constant Effect_Types := 16#0008#;
   Sawtooth_Up_Effect   : constant Effect_Types := 16#0010#;
   Sawtooth_Down_Effect : constant Effect_Types := 16#0020#;
   Ramp_Effect          : constant Effect_Types := 16#0040#;
   Spring_Effect        : constant Effect_Types := 16#0080#;
   Damper_Effect        : constant Effect_Types := 16#0100#;
   Inertia_Effect       : constant Effect_Types := 16#0200#;
   Friction_Effect      : constant Effect_Types := 16#0400#;
   Left_Right_Effect    : constant Effect_Types := 16#0800#;
   Custom_Effect        : constant Effect_Types := 16#8000#;

   Gain_Feature       : constant Features := 16#0001_0000#;
   Autocenter_Feature : constant Features := 16#0002_0000#;
   Status_Feature     : constant Features := 16#0004_0000#;
   Pause_Feature      : constant Features := 16#0008_0000#;

   Polar         : constant Direction_Types := 0;
   Cartesian     : constant Direction_Types := 1;
   Spherical     : constant Direction_Types := 2;
   Steering_Axis : constant Direction_Types := 3;

   type Direction_Values is array (0 .. 2) of aliased Signed_32 with
     Convention     => C,
     Component_Size => Signed_32'Size;

   type Unsigned_Axis_Values is array (0 .. 2) of aliased Unsigned_16 with
     Convention     => C,
     Component_Size => Unsigned_16'Size;

   type Signed_Axis_Values is array (0 .. 2) of aliased Signed_16 with
     Convention     => C,
     Component_Size => Signed_16'Size;

   type Direction is record
      Encoding : Direction_Types := Polar;
      Values   : Direction_Values := (others => 0);
   end record with
     Convention => C;

   type Constant_Effect_Data is record
      Kind          : Effect_Types := Constant_Effect;
      Heading       : Direction := (others => <>);
      Length        : Replay_Counts := 0;
      Start_Delay   : Unsigned_16 := 0;
      Button        : Unsigned_16 := 0;
      Interval      : Unsigned_16 := 0;
      Level         : Signed_16 := 0;
      Attack_Length : Unsigned_16 := 0;
      Attack_Level  : Unsigned_16 := 0;
      Fade_Length   : Unsigned_16 := 0;
      Fade_Level    : Unsigned_16 := 0;
   end record with
     Convention => C;

   type Periodic_Effect_Data is record
      Kind          : Effect_Types := Sine_Effect;
      Heading       : Direction := (others => <>);
      Length        : Replay_Counts := 0;
      Start_Delay   : Unsigned_16 := 0;
      Button        : Unsigned_16 := 0;
      Interval      : Unsigned_16 := 0;
      Period        : Unsigned_16 := 0;
      Magnitude     : Signed_16 := 0;
      Offset        : Signed_16 := 0;
      Phase         : Unsigned_16 := 0;
      Attack_Length : Unsigned_16 := 0;
      Attack_Level  : Unsigned_16 := 0;
      Fade_Length   : Unsigned_16 := 0;
      Fade_Level    : Unsigned_16 := 0;
   end record with
     Convention => C;

   type Condition_Effect_Data is record
      Kind        : Effect_Types := Spring_Effect;
      Heading     : Direction := (others => <>);
      Length      : Replay_Counts := 0;
      Start_Delay : Unsigned_16 := 0;
      Button      : Unsigned_16 := 0;
      Interval    : Unsigned_16 := 0;
      Right_Sat   : Unsigned_Axis_Values := (others => 0);
      Left_Sat    : Unsigned_Axis_Values := (others => 0);
      Right_Coeff : Signed_Axis_Values := (others => 0);
      Left_Coeff  : Signed_Axis_Values := (others => 0);
      Deadband    : Unsigned_Axis_Values := (others => 0);
      Center      : Signed_Axis_Values := (others => 0);
   end record with
     Convention => C;

   type Ramp_Effect_Data is record
      Kind          : Effect_Types := Ramp_Effect;
      Heading       : Direction := (others => <>);
      Length        : Replay_Counts := 0;
      Start_Delay   : Unsigned_16 := 0;
      Button        : Unsigned_16 := 0;
      Interval      : Unsigned_16 := 0;
      Start_Level   : Signed_16 := 0;
      End_Level     : Signed_16 := 0;
      Attack_Length : Unsigned_16 := 0;
      Attack_Level  : Unsigned_16 := 0;
      Fade_Length   : Unsigned_16 := 0;
      Fade_Level    : Unsigned_16 := 0;
   end record with
     Convention => C;

   type Left_Right_Effect_Data is record
      Kind            : Effect_Types := Left_Right_Effect;
      Length          : Replay_Counts := 0;
      Large_Magnitude : Unsigned_16 := 0;
      Small_Magnitude : Unsigned_16 := 0;
   end record with
     Convention => C;

   type Sample_Pointer is access all Unsigned_16 with
     Convention => C;

   type Custom_Effect_Data is record
      Kind          : Effect_Types := Custom_Effect;
      Heading       : Direction := (others => <>);
      Length        : Replay_Counts := 0;
      Start_Delay   : Unsigned_16 := 0;
      Button        : Unsigned_16 := 0;
      Interval      : Unsigned_16 := 0;
      Channels      : Channel_Counts := 0;
      Period        : Unsigned_16 := 0;
      Samples       : Unsigned_16 := 0;
      Data          : Sample_Pointer := null;
      Attack_Length : Unsigned_16 := 0;
      Attack_Level  : Unsigned_16 := 0;
      Fade_Length   : Unsigned_16 := 0;
      Fade_Level    : Unsigned_16 := 0;
   end record with
     Convention => C;

   type Effect_Kinds is
     (Type_Only,
      Constant_Data,
      Periodic_Data,
      Condition_Data,
      Ramp_Data,
      Left_Right_Data,
      Custom_Data);

   type Effect (Kind : Effect_Kinds := Type_Only) is record
      case Kind is
         when Type_Only =>
            Effect_Type : Effect_Types;

         when Constant_Data =>
            Constant_Info : Constant_Effect_Data;

         when Periodic_Data =>
            Periodic : Periodic_Effect_Data;

         when Condition_Data =>
            Condition : Condition_Effect_Data;

         when Ramp_Data =>
            Ramp : Ramp_Effect_Data;

         when Left_Right_Data =>
            Left_Right : Left_Right_Effect_Data;

         when Custom_Data =>
            Custom : Custom_Effect_Data;
      end case;
   end record with
     Unchecked_Union,
     Convention => C;

   type ID_Array is array (C.ptrdiff_t range <>) of aliased ID with
     Convention => C;

   package ID_Pointers is new Interfaces.C.Pointers
     (Index              => C.ptrdiff_t,
      Element            => ID,
      Element_Array      => ID_Array,
      Default_Terminator => 0);

   procedure Free (Memory : in System.Address)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_free";

   function Get_Haptics
     (Count : access C.int) return ID_Pointers.Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetHaptics";

   function Get_Haptic_Name_For_ID
     (Instance : in ID) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetHapticNameForID";

   function Open_Haptic
     (Instance : in ID) return SDL.Raw.C_Pointers.Haptic_Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_OpenHaptic";

   function Get_Haptic_From_ID
     (Instance : in ID) return SDL.Raw.C_Pointers.Haptic_Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetHapticFromID";

   function Get_Haptic_ID
     (Self : in SDL.Raw.C_Pointers.Haptic_Pointer) return ID
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetHapticID";

   function Get_Haptic_Name
     (Self : in SDL.Raw.C_Pointers.Haptic_Pointer) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetHapticName";

   function Is_Mouse_Haptic return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_IsMouseHaptic";

   function Open_Haptic_From_Mouse return SDL.Raw.C_Pointers.Haptic_Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_OpenHapticFromMouse";

   function Is_Joystick_Haptic
     (Joystick : in SDL.Raw.C_Pointers.Joystick_Pointer) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_IsJoystickHaptic";

   function Open_Haptic_From_Joystick
     (Joystick : in SDL.Raw.C_Pointers.Joystick_Pointer)
      return SDL.Raw.C_Pointers.Haptic_Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_OpenHapticFromJoystick";

   procedure Close_Haptic
     (Self : in SDL.Raw.C_Pointers.Haptic_Pointer)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CloseHaptic";

   function Get_Max_Haptic_Effects
     (Self : in SDL.Raw.C_Pointers.Haptic_Pointer) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetMaxHapticEffects";

   function Get_Max_Haptic_Effects_Playing
     (Self : in SDL.Raw.C_Pointers.Haptic_Pointer) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetMaxHapticEffectsPlaying";

   function Get_Haptic_Features
     (Self : in SDL.Raw.C_Pointers.Haptic_Pointer) return Features
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetHapticFeatures";

   function Get_Num_Haptic_Axes
     (Self : in SDL.Raw.C_Pointers.Haptic_Pointer) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetNumHapticAxes";

   function Haptic_Effect_Supported
     (Self  : in SDL.Raw.C_Pointers.Haptic_Pointer;
      Value : access constant Effect) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_HapticEffectSupported";

   function Create_Haptic_Effect
     (Self  : in SDL.Raw.C_Pointers.Haptic_Pointer;
      Value : access constant Effect) return Effect_ID
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CreateHapticEffect";

   function Update_Haptic_Effect
     (Self  : in SDL.Raw.C_Pointers.Haptic_Pointer;
      Item  : in Effect_ID;
      Value : access constant Effect) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_UpdateHapticEffect";

   function Run_Haptic_Effect
     (Self       : in SDL.Raw.C_Pointers.Haptic_Pointer;
      Item       : in Effect_ID;
      Iterations : in Replay_Counts) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_RunHapticEffect";

   function Stop_Haptic_Effect
     (Self : in SDL.Raw.C_Pointers.Haptic_Pointer;
     Item : in Effect_ID) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_StopHapticEffect";

   procedure Destroy_Haptic_Effect
     (Self : in SDL.Raw.C_Pointers.Haptic_Pointer;
      Item : in Effect_ID)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_DestroyHapticEffect";

   function Get_Haptic_Effect_Status
     (Self : in SDL.Raw.C_Pointers.Haptic_Pointer;
      Item : in Effect_ID) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetHapticEffectStatus";

   function Set_Haptic_Gain
     (Self : in SDL.Raw.C_Pointers.Haptic_Pointer;
      Gain : in C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetHapticGain";

   function Set_Haptic_Autocenter
     (Self       : in SDL.Raw.C_Pointers.Haptic_Pointer;
      Autocenter : in C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetHapticAutocenter";

   function Pause_Haptic
     (Self : in SDL.Raw.C_Pointers.Haptic_Pointer) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_PauseHaptic";

   function Resume_Haptic
     (Self : in SDL.Raw.C_Pointers.Haptic_Pointer) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ResumeHaptic";

   function Stop_Haptic_Effects
     (Self : in SDL.Raw.C_Pointers.Haptic_Pointer) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_StopHapticEffects";

   function Haptic_Rumble_Supported
     (Self : in SDL.Raw.C_Pointers.Haptic_Pointer) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_HapticRumbleSupported";

   function Init_Haptic_Rumble
     (Self : in SDL.Raw.C_Pointers.Haptic_Pointer) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_InitHapticRumble";

   function Play_Haptic_Rumble
     (Self      : in SDL.Raw.C_Pointers.Haptic_Pointer;
      Strength  : in C.C_float;
      Length_MS : in Replay_Counts) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_PlayHapticRumble";

   function Stop_Haptic_Rumble
     (Self : in SDL.Raw.C_Pointers.Haptic_Pointer) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_StopHapticRumble";
end SDL.Raw.Haptic;
