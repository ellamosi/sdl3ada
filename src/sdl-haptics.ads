with Ada.Finalization;
with Interfaces.C;

with SDL.C_Pointers;
with SDL.Inputs.Joysticks;
with SDL.Raw.Haptic;

package SDL.Haptics is
   pragma Elaborate_Body;

   package C renames Interfaces.C;

   Haptic_Error : exception;

   type ID is mod 2 ** 32 with
     Convention => C,
     Size       => 32;

   type ID_Lists is array (Natural range <>) of ID;

   subtype Features is SDL.Raw.Haptic.Features;
   subtype Effect_Types is SDL.Raw.Haptic.Effect_Types;
   subtype Direction_Types is SDL.Raw.Haptic.Direction_Types;
   subtype Effect_ID is SDL.Raw.Haptic.Effect_ID;
   subtype Replay_Counts is SDL.Raw.Haptic.Replay_Counts;
   subtype Unsigned_16 is SDL.Raw.Haptic.Unsigned_16;
   subtype Signed_16 is SDL.Raw.Haptic.Signed_16;
   subtype Signed_32 is SDL.Raw.Haptic.Signed_32;
   subtype Channel_Counts is SDL.Raw.Haptic.Channel_Counts;

   Infinity : constant Replay_Counts := SDL.Raw.Haptic.Infinity;

   Constant_Effect      : constant Effect_Types := SDL.Raw.Haptic.Constant_Effect;
   Sine_Effect          : constant Effect_Types := SDL.Raw.Haptic.Sine_Effect;
   Square_Effect        : constant Effect_Types := SDL.Raw.Haptic.Square_Effect;
   Triangle_Effect      : constant Effect_Types := SDL.Raw.Haptic.Triangle_Effect;
   Sawtooth_Up_Effect   : constant Effect_Types := SDL.Raw.Haptic.Sawtooth_Up_Effect;
   Sawtooth_Down_Effect : constant Effect_Types := SDL.Raw.Haptic.Sawtooth_Down_Effect;
   Ramp_Effect          : constant Effect_Types := SDL.Raw.Haptic.Ramp_Effect;
   Spring_Effect        : constant Effect_Types := SDL.Raw.Haptic.Spring_Effect;
   Damper_Effect        : constant Effect_Types := SDL.Raw.Haptic.Damper_Effect;
   Inertia_Effect       : constant Effect_Types := SDL.Raw.Haptic.Inertia_Effect;
   Friction_Effect      : constant Effect_Types := SDL.Raw.Haptic.Friction_Effect;
   Left_Right_Effect    : constant Effect_Types := SDL.Raw.Haptic.Left_Right_Effect;
   Custom_Effect        : constant Effect_Types := SDL.Raw.Haptic.Custom_Effect;

   Gain_Feature       : constant Features := SDL.Raw.Haptic.Gain_Feature;
   Autocenter_Feature : constant Features := SDL.Raw.Haptic.Autocenter_Feature;
   Status_Feature     : constant Features := SDL.Raw.Haptic.Status_Feature;
   Pause_Feature      : constant Features := SDL.Raw.Haptic.Pause_Feature;

   Polar         : constant Direction_Types := SDL.Raw.Haptic.Polar;
   Cartesian     : constant Direction_Types := SDL.Raw.Haptic.Cartesian;
   Spherical     : constant Direction_Types := SDL.Raw.Haptic.Spherical;
   Steering_Axis : constant Direction_Types := SDL.Raw.Haptic.Steering_Axis;

   subtype Direction_Values is SDL.Raw.Haptic.Direction_Values;
   subtype Unsigned_Axis_Values is SDL.Raw.Haptic.Unsigned_Axis_Values;
   subtype Signed_Axis_Values is SDL.Raw.Haptic.Signed_Axis_Values;
   subtype Direction is SDL.Raw.Haptic.Direction;
   subtype Constant_Effect_Data is SDL.Raw.Haptic.Constant_Effect_Data;
   subtype Periodic_Effect_Data is SDL.Raw.Haptic.Periodic_Effect_Data;
   subtype Condition_Effect_Data is SDL.Raw.Haptic.Condition_Effect_Data;
   subtype Ramp_Effect_Data is SDL.Raw.Haptic.Ramp_Effect_Data;
   subtype Left_Right_Effect_Data is SDL.Raw.Haptic.Left_Right_Effect_Data;
   subtype Sample_Pointer is SDL.Raw.Haptic.Sample_Pointer;
   subtype Custom_Effect_Data is SDL.Raw.Haptic.Custom_Effect_Data;
   subtype Effect_Kinds is SDL.Raw.Haptic.Effect_Kinds;
   subtype Effect is SDL.Raw.Haptic.Effect;

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
