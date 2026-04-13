with Ada.Unchecked_Conversion;
with Interfaces.C.Extensions;
with Interfaces.C.Pointers;
with Interfaces.C.Strings;
with System;

with SDL.Error;

package body SDL.Haptics is
   package CE renames Interfaces.C.Extensions;
   package CS renames Interfaces.C.Strings;

   use type C.ptrdiff_t;
   use type CS.chars_ptr;
   use type SDL.C_Pointers.Haptic_Pointer;
   use type System.Address;

   type ID_Arrays is array (C.ptrdiff_t range <>) of aliased ID with
     Convention => C;

   package ID_Pointers is new Interfaces.C.Pointers
     (Index              => C.ptrdiff_t,
      Element            => ID,
      Element_Array      => ID_Arrays,
      Default_Terminator => 0);

   use type ID_Pointers.Pointer;

   function To_Address is new Ada.Unchecked_Conversion
     (Source => ID_Pointers.Pointer,
      Target => System.Address);

   procedure SDL_Free (Memory : in System.Address) with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_free";

   function SDL_Get_Haptics
     (Count : access C.int) return ID_Pointers.Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetHaptics";

   function SDL_Get_Haptic_Name_For_ID
     (Instance : in ID) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetHapticNameForID";

   function SDL_Open_Haptic
     (Instance : in ID) return SDL.C_Pointers.Haptic_Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_OpenHaptic";

   function SDL_Get_Haptic_From_ID
     (Instance : in ID) return SDL.C_Pointers.Haptic_Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetHapticFromID";

   function SDL_Get_Haptic_ID
     (Self : in SDL.C_Pointers.Haptic_Pointer) return ID
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetHapticID";

   function SDL_Get_Haptic_Name
     (Self : in SDL.C_Pointers.Haptic_Pointer) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetHapticName";

   function SDL_Is_Mouse_Haptic return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_IsMouseHaptic";

   function SDL_Open_Haptic_From_Mouse return SDL.C_Pointers.Haptic_Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_OpenHapticFromMouse";

   function SDL_Is_Joystick_Haptic
     (Joystick : in SDL.C_Pointers.Joystick_Pointer) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_IsJoystickHaptic";

   function SDL_Open_Haptic_From_Joystick
     (Joystick : in SDL.C_Pointers.Joystick_Pointer) return SDL.C_Pointers.Haptic_Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_OpenHapticFromJoystick";

   procedure SDL_Close_Haptic
     (Self : in SDL.C_Pointers.Haptic_Pointer)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CloseHaptic";

   function SDL_Get_Max_Haptic_Effects
     (Self : in SDL.C_Pointers.Haptic_Pointer) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetMaxHapticEffects";

   function SDL_Get_Max_Haptic_Effects_Playing
     (Self : in SDL.C_Pointers.Haptic_Pointer) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetMaxHapticEffectsPlaying";

   function SDL_Get_Haptic_Features
     (Self : in SDL.C_Pointers.Haptic_Pointer) return Features
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetHapticFeatures";

   function SDL_Get_Num_Haptic_Axes
     (Self : in SDL.C_Pointers.Haptic_Pointer) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetNumHapticAxes";

   function SDL_Haptic_Effect_Supported
     (Self  : in SDL.C_Pointers.Haptic_Pointer;
      Value : access constant Effect) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_HapticEffectSupported";

   function SDL_Create_Haptic_Effect
     (Self  : in SDL.C_Pointers.Haptic_Pointer;
      Value : access constant Effect) return Effect_ID
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CreateHapticEffect";

   function SDL_Update_Haptic_Effect
     (Self   : in SDL.C_Pointers.Haptic_Pointer;
      Item   : in Effect_ID;
      Value  : access constant Effect) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_UpdateHapticEffect";

   function SDL_Run_Haptic_Effect
     (Self       : in SDL.C_Pointers.Haptic_Pointer;
      Item       : in Effect_ID;
      Iterations : in Replay_Counts) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_RunHapticEffect";

   function SDL_Stop_Haptic_Effect
     (Self : in SDL.C_Pointers.Haptic_Pointer;
      Item : in Effect_ID) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_StopHapticEffect";

   procedure SDL_Destroy_Haptic_Effect
     (Self : in SDL.C_Pointers.Haptic_Pointer;
      Item : in Effect_ID)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_DestroyHapticEffect";

   function SDL_Get_Haptic_Effect_Status
     (Self : in SDL.C_Pointers.Haptic_Pointer;
      Item : in Effect_ID) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetHapticEffectStatus";

   function SDL_Set_Haptic_Gain
     (Self : in SDL.C_Pointers.Haptic_Pointer;
      Gain : in C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetHapticGain";

   function SDL_Set_Haptic_Autocenter
     (Self       : in SDL.C_Pointers.Haptic_Pointer;
      Autocenter : in C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetHapticAutocenter";

   function SDL_Pause_Haptic
     (Self : in SDL.C_Pointers.Haptic_Pointer) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_PauseHaptic";

   function SDL_Resume_Haptic
     (Self : in SDL.C_Pointers.Haptic_Pointer) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ResumeHaptic";

   function SDL_Stop_Haptic_Effects
     (Self : in SDL.C_Pointers.Haptic_Pointer) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_StopHapticEffects";

   function SDL_Haptic_Rumble_Supported
     (Self : in SDL.C_Pointers.Haptic_Pointer) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_HapticRumbleSupported";

   function SDL_Init_Haptic_Rumble
     (Self : in SDL.C_Pointers.Haptic_Pointer) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_InitHapticRumble";

   function SDL_Play_Haptic_Rumble
     (Self      : in SDL.C_Pointers.Haptic_Pointer;
      Strength  : in C.C_float;
      Length_MS : in Replay_Counts) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_PlayHapticRumble";

   function SDL_Stop_Haptic_Rumble
     (Self : in SDL.C_Pointers.Haptic_Pointer) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_StopHapticRumble";

   procedure Raise_Last_Error
     (Default_Message : in String := "SDL haptic call failed");

   procedure Raise_Last_Error
     (Default_Message : in String := "SDL haptic call failed")
   is
      Message : constant String := SDL.Error.Get;
   begin
      if Message = "" then
         raise Haptic_Error with Default_Message;
      end if;

      raise Haptic_Error with Message;
   end Raise_Last_Error;

   procedure Require_Valid (Self : in Haptic);

   procedure Require_Valid (Self : in Haptic) is
   begin
      if Self.Internal = null then
         raise Haptic_Error with "Invalid haptic device";
      end if;
   end Require_Valid;

   procedure Free (Items : in out ID_Pointers.Pointer);

   procedure Free (Items : in out ID_Pointers.Pointer) is
   begin
      if Items /= null then
         SDL_Free (To_Address (Items));
         Items := null;
      end if;
   end Free;

   function Copy_IDs
     (Items : in ID_Pointers.Pointer;
      Count : in C.int) return ID_Lists;

   function Copy_IDs
     (Items : in ID_Pointers.Pointer;
      Count : in C.int) return ID_Lists
   is
      Raw : ID_Pointers.Pointer := Items;
   begin
      if Count <= 0 then
         Free (Raw);
         return [];
      end if;

      if Raw = null then
         Raise_Last_Error ("Haptic enumeration failed");
      end if;

      declare
         Source : constant ID_Arrays :=
           ID_Pointers.Value (Raw, C.ptrdiff_t (Count));
         Result : ID_Lists (0 .. Natural (Count) - 1);
      begin
         for Index in Result'Range loop
            Result (Index) :=
              Source (Source'First + C.ptrdiff_t (Index - Result'First));
         end loop;

         Free (Raw);
         return Result;
      exception
         when others =>
            Free (Raw);
            raise;
      end;
   end Copy_IDs;

   function Checked_Count
     (Value           : in C.int;
      Default_Message : in String) return Natural;

   function Checked_Count
     (Value           : in C.int;
      Default_Message : in String) return Natural
   is
   begin
      if Value < 0 then
         Raise_Last_Error (Default_Message);
      end if;

      return Natural (Value);
   end Checked_Count;

   procedure Open_Internal
     (Self     : in out Haptic;
      Internal : in SDL.C_Pointers.Haptic_Pointer;
      Default_Message : in String);

   procedure Open_Internal
     (Self     : in out Haptic;
      Internal : in SDL.C_Pointers.Haptic_Pointer;
      Default_Message : in String)
   is
   begin
      Close (Self);

      if Internal = null then
         Raise_Last_Error (Default_Message);
      end if;

      Self.Internal := Internal;
      Self.Owns := True;
   end Open_Internal;

   function Get_Haptics return ID_Lists is
      Count : aliased C.int := 0;
      Items : constant ID_Pointers.Pointer := SDL_Get_Haptics (Count'Access);
   begin
      return Copy_IDs (Items, Count);
   end Get_Haptics;

   function Name (Instance : in ID) return String is
      Value : constant CS.chars_ptr := SDL_Get_Haptic_Name_For_ID (Instance);
   begin
      if Value = CS.Null_Ptr then
         return "";
      end if;

      return CS.Value (Value);
   end Name;

   function Has_Mouse return Boolean is
   begin
      return Boolean (SDL_Is_Mouse_Haptic);
   end Has_Mouse;

   function Open_Mouse return Haptic is
   begin
      return Result : Haptic do
         Open_Mouse (Result);
      end return;
   end Open_Mouse;

   procedure Open_Mouse (Self : in out Haptic) is
   begin
      Open_Internal (Self, SDL_Open_Haptic_From_Mouse, "SDL_OpenHapticFromMouse failed");
   end Open_Mouse;

   function Is_Joystick_Haptic
     (Joystick : in SDL.Inputs.Joysticks.Joystick) return Boolean
   is
   begin
      return Boolean
        (SDL_Is_Joystick_Haptic (SDL.Inputs.Joysticks.Get_Internal (Joystick)));
   end Is_Joystick_Haptic;

   function Open (Instance : in ID) return Haptic is
   begin
      return Result : Haptic do
         Open (Result, Instance);
      end return;
   end Open;

   procedure Open
     (Self     : in out Haptic;
      Instance : in ID) is
   begin
      Open_Internal (Self, SDL_Open_Haptic (Instance), "SDL_OpenHaptic failed");
   end Open;

   function Get (Instance : in ID) return Haptic is
   begin
      return (Ada.Finalization.Limited_Controlled with
              Internal => SDL_Get_Haptic_From_ID (Instance),
              Owns     => False);
   end Get;

   function Open_From_Joystick
     (Joystick : in SDL.Inputs.Joysticks.Joystick) return Haptic is
   begin
      return Result : Haptic do
         Open_From_Joystick (Result, Joystick);
      end return;
   end Open_From_Joystick;

   procedure Open_From_Joystick
     (Self     : in out Haptic;
      Joystick : in SDL.Inputs.Joysticks.Joystick) is
   begin
      Open_Internal
        (Self,
         SDL_Open_Haptic_From_Joystick (SDL.Inputs.Joysticks.Get_Internal (Joystick)),
         "SDL_OpenHapticFromJoystick failed");
   end Open_From_Joystick;

   overriding
   procedure Finalize (Self : in out Haptic) is
   begin
      Close (Self);
   end Finalize;

   procedure Close (Self : in out Haptic) is
   begin
      if Self.Owns and then Self.Internal /= null then
         SDL_Close_Haptic (Self.Internal);
      end if;

      Self.Internal := null;
      Self.Owns := True;
   end Close;

   function Is_Null (Self : in Haptic) return Boolean is
     (Self.Internal = null);

   function Get_ID (Self : in Haptic) return ID is
      Result : ID;
   begin
      if Self.Internal = null then
         return 0;
      end if;

      Result := SDL_Get_Haptic_ID (Self.Internal);
      if Result = 0 then
         Raise_Last_Error ("SDL_GetHapticID failed");
      end if;

      return Result;
   end Get_ID;

   function Name (Self : in Haptic) return String is
      Value : CS.chars_ptr;
   begin
      Require_Valid (Self);

      Value := SDL_Get_Haptic_Name (Self.Internal);
      if Value = CS.Null_Ptr then
         return "";
      end if;

      return CS.Value (Value);
   end Name;

   function Get_Max_Effects (Self : in Haptic) return Natural is
   begin
      Require_Valid (Self);
      return Checked_Count
        (SDL_Get_Max_Haptic_Effects (Self.Internal),
         "SDL_GetMaxHapticEffects failed");
   end Get_Max_Effects;

   function Get_Max_Playing_Effects (Self : in Haptic) return Natural is
   begin
      Require_Valid (Self);
      return Checked_Count
        (SDL_Get_Max_Haptic_Effects_Playing (Self.Internal),
         "SDL_GetMaxHapticEffectsPlaying failed");
   end Get_Max_Playing_Effects;

   function Get_Features (Self : in Haptic) return Features is
   begin
      Require_Valid (Self);
      return SDL_Get_Haptic_Features (Self.Internal);
   end Get_Features;

   function Get_Num_Axes (Self : in Haptic) return Natural is
   begin
      Require_Valid (Self);
      return Checked_Count
        (SDL_Get_Num_Haptic_Axes (Self.Internal),
         "SDL_GetNumHapticAxes failed");
   end Get_Num_Axes;

   function Effect_Supported
     (Self  : in Haptic;
      Value : in Effect) return Boolean
   is
      Copy : aliased constant Effect := Value;
   begin
      Require_Valid (Self);
      return Boolean (SDL_Haptic_Effect_Supported (Self.Internal, Copy'Access));
   end Effect_Supported;

   function Create_Effect
     (Self  : in Haptic;
      Value : in Effect) return Effect_ID
   is
      Copy   : aliased constant Effect := Value;
      Result : Effect_ID;
   begin
      Require_Valid (Self);

      Result := SDL_Create_Haptic_Effect (Self.Internal, Copy'Access);
      if Result < 0 then
         Raise_Last_Error ("SDL_CreateHapticEffect failed");
      end if;

      return Result;
   end Create_Effect;

   procedure Update_Effect
     (Self    : in Haptic;
      Item    : in Effect_ID;
      Value   : in Effect)
   is
      Copy : aliased constant Effect := Value;
   begin
      Require_Valid (Self);

      if not Boolean (SDL_Update_Haptic_Effect (Self.Internal, Item, Copy'Access)) then
         Raise_Last_Error ("SDL_UpdateHapticEffect failed");
      end if;
   end Update_Effect;

   procedure Run_Effect
     (Self       : in Haptic;
      Item       : in Effect_ID;
      Iterations : in Replay_Counts := 1) is
   begin
      Require_Valid (Self);

      if not Boolean (SDL_Run_Haptic_Effect (Self.Internal, Item, Iterations)) then
         Raise_Last_Error ("SDL_RunHapticEffect failed");
      end if;
   end Run_Effect;

   procedure Stop_Effect
     (Self   : in Haptic;
      Item   : in Effect_ID) is
   begin
      Require_Valid (Self);

      if not Boolean (SDL_Stop_Haptic_Effect (Self.Internal, Item)) then
         Raise_Last_Error ("SDL_StopHapticEffect failed");
      end if;
   end Stop_Effect;

   procedure Destroy_Effect
     (Self   : in Haptic;
      Item   : in Effect_ID) is
   begin
      Require_Valid (Self);
      SDL_Destroy_Haptic_Effect (Self.Internal, Item);
   end Destroy_Effect;

   function Effect_Status
     (Self   : in Haptic;
      Item   : in Effect_ID) return Boolean is
   begin
      Require_Valid (Self);
      return Boolean (SDL_Get_Haptic_Effect_Status (Self.Internal, Item));
   end Effect_Status;

   procedure Set_Gain
     (Self  : in Haptic;
      Gain  : in C.int) is
   begin
      Require_Valid (Self);

      if not Boolean (SDL_Set_Haptic_Gain (Self.Internal, Gain)) then
         Raise_Last_Error ("SDL_SetHapticGain failed");
      end if;
   end Set_Gain;

   procedure Set_Autocenter
     (Self       : in Haptic;
      Autocenter : in C.int) is
   begin
      Require_Valid (Self);

      if not Boolean (SDL_Set_Haptic_Autocenter (Self.Internal, Autocenter)) then
         Raise_Last_Error ("SDL_SetHapticAutocenter failed");
      end if;
   end Set_Autocenter;

   procedure Pause (Self : in Haptic) is
   begin
      Require_Valid (Self);

      if not Boolean (SDL_Pause_Haptic (Self.Internal)) then
         Raise_Last_Error ("SDL_PauseHaptic failed");
      end if;
   end Pause;

   procedure Resume (Self : in Haptic) is
   begin
      Require_Valid (Self);

      if not Boolean (SDL_Resume_Haptic (Self.Internal)) then
         Raise_Last_Error ("SDL_ResumeHaptic failed");
      end if;
   end Resume;

   procedure Stop_All_Effects (Self : in Haptic) is
   begin
      Require_Valid (Self);

      if not Boolean (SDL_Stop_Haptic_Effects (Self.Internal)) then
         Raise_Last_Error ("SDL_StopHapticEffects failed");
      end if;
   end Stop_All_Effects;

   function Supports_Rumble (Self : in Haptic) return Boolean is
   begin
      Require_Valid (Self);
      return Boolean (SDL_Haptic_Rumble_Supported (Self.Internal));
   end Supports_Rumble;

   procedure Initialise_Rumble (Self : in Haptic) is
   begin
      Require_Valid (Self);

      if not Boolean (SDL_Init_Haptic_Rumble (Self.Internal)) then
         Raise_Last_Error ("SDL_InitHapticRumble failed");
      end if;
   end Initialise_Rumble;

   procedure Play_Rumble
     (Self      : in Haptic;
      Strength  : in C.C_float;
      Length_MS : in Replay_Counts) is
   begin
      Require_Valid (Self);

      if not Boolean (SDL_Play_Haptic_Rumble (Self.Internal, Strength, Length_MS)) then
         Raise_Last_Error ("SDL_PlayHapticRumble failed");
      end if;
   end Play_Rumble;

   procedure Stop_Rumble (Self : in Haptic) is
   begin
      Require_Valid (Self);

      if not Boolean (SDL_Stop_Haptic_Rumble (Self.Internal)) then
         Raise_Last_Error ("SDL_StopHapticRumble failed");
      end if;
   end Stop_Rumble;

   function Get_Internal
     (Self : in Haptic) return SDL.C_Pointers.Haptic_Pointer is
   begin
      return Self.Internal;
   end Get_Internal;
end SDL.Haptics;
