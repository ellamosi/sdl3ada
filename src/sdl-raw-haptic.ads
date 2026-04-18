with Interfaces;
with Interfaces.C;
with Interfaces.C.Extensions;
with Interfaces.C.Pointers;
with Interfaces.C.Strings;
with System;

package SDL.Raw.Haptic is
   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;
   package CS renames Interfaces.C.Strings;

   subtype ID is Interfaces.Unsigned_32;
   subtype Features is Interfaces.Unsigned_32;
   subtype Effect_ID is C.int;
   subtype Replay_Counts is Interfaces.Unsigned_32;

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
     (Instance : in ID) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_OpenHaptic";

   function Get_Haptic_From_ID
     (Instance : in ID) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetHapticFromID";

   function Get_Haptic_ID
     (Self : in System.Address) return ID
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetHapticID";

   function Get_Haptic_Name
     (Self : in System.Address) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetHapticName";

   function Is_Mouse_Haptic return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_IsMouseHaptic";

   function Open_Haptic_From_Mouse return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_OpenHapticFromMouse";

   function Is_Joystick_Haptic
     (Joystick : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_IsJoystickHaptic";

   function Open_Haptic_From_Joystick
     (Joystick : in System.Address) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_OpenHapticFromJoystick";

   procedure Close_Haptic
     (Self : in System.Address)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CloseHaptic";

   function Get_Max_Haptic_Effects
     (Self : in System.Address) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetMaxHapticEffects";

   function Get_Max_Haptic_Effects_Playing
     (Self : in System.Address) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetMaxHapticEffectsPlaying";

   function Get_Haptic_Features
     (Self : in System.Address) return Features
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetHapticFeatures";

   function Get_Num_Haptic_Axes
     (Self : in System.Address) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetNumHapticAxes";

   function Haptic_Effect_Supported
     (Self  : in System.Address;
      Value : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_HapticEffectSupported";

   function Create_Haptic_Effect
     (Self  : in System.Address;
      Value : in System.Address) return Effect_ID
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CreateHapticEffect";

   function Update_Haptic_Effect
     (Self  : in System.Address;
      Item  : in Effect_ID;
      Value : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_UpdateHapticEffect";

   function Run_Haptic_Effect
     (Self       : in System.Address;
      Item       : in Effect_ID;
      Iterations : in Replay_Counts) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_RunHapticEffect";

   function Stop_Haptic_Effect
     (Self : in System.Address;
      Item : in Effect_ID) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_StopHapticEffect";

   procedure Destroy_Haptic_Effect
     (Self : in System.Address;
      Item : in Effect_ID)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_DestroyHapticEffect";

   function Get_Haptic_Effect_Status
     (Self : in System.Address;
      Item : in Effect_ID) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetHapticEffectStatus";

   function Set_Haptic_Gain
     (Self : in System.Address;
      Gain : in C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetHapticGain";

   function Set_Haptic_Autocenter
     (Self       : in System.Address;
      Autocenter : in C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetHapticAutocenter";

   function Pause_Haptic
     (Self : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_PauseHaptic";

   function Resume_Haptic
     (Self : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ResumeHaptic";

   function Stop_Haptic_Effects
     (Self : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_StopHapticEffects";

   function Haptic_Rumble_Supported
     (Self : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_HapticRumbleSupported";

   function Init_Haptic_Rumble
     (Self : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_InitHapticRumble";

   function Play_Haptic_Rumble
     (Self      : in System.Address;
      Strength  : in C.C_float;
      Length_MS : in Replay_Counts) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_PlayHapticRumble";

   function Stop_Haptic_Rumble
     (Self : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_StopHapticRumble";
end SDL.Raw.Haptic;
