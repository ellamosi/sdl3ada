with Ada.Finalization;
with Interfaces;
with Interfaces.C;

with SDL.C_Pointers;
with SDL.Inputs.Joysticks;

package SDL.Haptics is
   pragma Elaborate_Body;

   package C renames Interfaces.C;

   Haptic_Error : exception;

   type ID is mod 2 ** 32 with
     Convention => C,
     Size       => 32;

   type ID_Lists is array (Natural range <>) of ID;

   type Features is mod 2 ** 32 with
     Convention => C,
     Size       => 32;

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

   Polar        : constant Direction_Types := 0;
   Cartesian    : constant Direction_Types := 1;
   Spherical    : constant Direction_Types := 2;
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

   type Haptic is new Ada.Finalization.Limited_Controlled with private;

   function Get_Haptics return ID_Lists;

   function Name (Instance : in ID) return String;

   function Has_Mouse return Boolean;

   function Open_Mouse return Haptic;

   procedure Open_Mouse (Self : in out Haptic);

   function Is_Joystick_Haptic
     (Joystick : in SDL.Inputs.Joysticks.Joystick) return Boolean;

   function Open (Instance : in ID) return Haptic;

   procedure Open
     (Self     : in out Haptic;
      Instance : in ID);

   function Get (Instance : in ID) return Haptic;

   function Open_From_Joystick
     (Joystick : in SDL.Inputs.Joysticks.Joystick) return Haptic;

   procedure Open_From_Joystick
     (Self     : in out Haptic;
      Joystick : in SDL.Inputs.Joysticks.Joystick);

   overriding
   procedure Finalize (Self : in out Haptic);

   procedure Close (Self : in out Haptic);

   function Is_Null (Self : in Haptic) return Boolean with
     Inline;

   function Get_ID (Self : in Haptic) return ID;

   function Name (Self : in Haptic) return String;

   function Get_Max_Effects (Self : in Haptic) return Natural;

   function Get_Max_Playing_Effects (Self : in Haptic) return Natural;

   function Get_Features (Self : in Haptic) return Features;

   function Get_Num_Axes (Self : in Haptic) return Natural;

   function Effect_Supported
     (Self  : in Haptic;
      Value : in Effect) return Boolean;

   function Create_Effect
     (Self  : in Haptic;
      Value : in Effect) return Effect_ID;

   procedure Update_Effect
     (Self    : in Haptic;
      Item    : in Effect_ID;
      Value   : in Effect);

   procedure Run_Effect
     (Self       : in Haptic;
      Item       : in Effect_ID;
      Iterations : in Replay_Counts := 1);

   procedure Stop_Effect
     (Self   : in Haptic;
      Item   : in Effect_ID);

   procedure Destroy_Effect
     (Self   : in Haptic;
      Item   : in Effect_ID);

   function Effect_Status
     (Self   : in Haptic;
      Item   : in Effect_ID) return Boolean;

   procedure Set_Gain
     (Self  : in Haptic;
      Gain  : in C.int);

   procedure Set_Autocenter
     (Self       : in Haptic;
      Autocenter : in C.int);

   procedure Pause (Self : in Haptic);

   procedure Resume (Self : in Haptic);

   procedure Stop_All_Effects (Self : in Haptic);

   function Supports_Rumble (Self : in Haptic) return Boolean;

   procedure Initialise_Rumble (Self : in Haptic);

   procedure Play_Rumble
     (Self      : in Haptic;
      Strength  : in C.C_float;
      Length_MS : in Replay_Counts);

   procedure Stop_Rumble (Self : in Haptic);

   function Get_Internal
     (Self : in Haptic) return SDL.C_Pointers.Haptic_Pointer
   with
     Inline;
private
   type Haptic is new Ada.Finalization.Limited_Controlled with
      record
         Internal : SDL.C_Pointers.Haptic_Pointer := null;
         Owns     : Boolean := True;
      end record;
end SDL.Haptics;
