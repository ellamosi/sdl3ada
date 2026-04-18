with Ada.Unchecked_Conversion;
with Interfaces.C.Strings;
with System;

with SDL.Error;
with SDL.Raw.Haptic;

package body SDL.Haptics is
   package Raw renames SDL.Raw.Haptic;
   package CS renames Interfaces.C.Strings;

   use type C.ptrdiff_t;
   use type CS.chars_ptr;
   use type Raw.ID_Pointers.Pointer;
   use type SDL.C_Pointers.Haptic_Pointer;
   use type System.Address;

   function To_Address is new Ada.Unchecked_Conversion
     (Source => Raw.ID_Pointers.Pointer,
      Target => System.Address);

   function To_Address is new Ada.Unchecked_Conversion
     (Source => SDL.C_Pointers.Haptic_Pointer,
      Target => System.Address);

   function To_Address is new Ada.Unchecked_Conversion
     (Source => SDL.C_Pointers.Joystick_Pointer,
      Target => System.Address);

   function To_Pointer is new Ada.Unchecked_Conversion
     (Source => System.Address,
      Target => SDL.C_Pointers.Haptic_Pointer);

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

   procedure Free (Items : in out Raw.ID_Pointers.Pointer);

   procedure Free (Items : in out Raw.ID_Pointers.Pointer) is
   begin
      if Items /= null then
         Raw.Free (To_Address (Items));
         Items := null;
      end if;
   end Free;

   function Copy_IDs
     (Items : in Raw.ID_Pointers.Pointer;
      Count : in C.int) return ID_Lists;

   function Copy_IDs
     (Items : in Raw.ID_Pointers.Pointer;
      Count : in C.int) return ID_Lists
   is
      Source_Items : Raw.ID_Pointers.Pointer := Items;
   begin
      if Count <= 0 then
         Free (Source_Items);
         return [];
      end if;

      if Source_Items = null then
         Raise_Last_Error ("Haptic enumeration failed");
      end if;

      declare
         Source : constant Raw.ID_Array :=
           Raw.ID_Pointers.Value (Source_Items, C.ptrdiff_t (Count));
         Result : ID_Lists (0 .. Natural (Count) - 1);
      begin
         for Index in Result'Range loop
            Result (Index) :=
              ID (Source (Source'First + C.ptrdiff_t (Index - Result'First)));
         end loop;

         Free (Source_Items);
         return Result;
      exception
         when others =>
            Free (Source_Items);
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
      Items : constant Raw.ID_Pointers.Pointer := Raw.Get_Haptics (Count'Access);
   begin
      return Copy_IDs (Items, Count);
   end Get_Haptics;

   function Name (Instance : in ID) return String is
      Value : constant CS.chars_ptr := Raw.Get_Haptic_Name_For_ID (Raw.ID (Instance));
   begin
      if Value = CS.Null_Ptr then
         return "";
      end if;

      return CS.Value (Value);
   end Name;

   function Has_Mouse return Boolean is
   begin
      return Boolean (Raw.Is_Mouse_Haptic);
   end Has_Mouse;

   function Open_Mouse return Haptic is
   begin
      return Result : Haptic do
         Open_Mouse (Result);
      end return;
   end Open_Mouse;

   procedure Open_Mouse (Self : in out Haptic) is
   begin
      Open_Internal
        (Self,
         To_Pointer (Raw.Open_Haptic_From_Mouse),
         "SDL_OpenHapticFromMouse failed");
   end Open_Mouse;

   function Is_Joystick_Haptic
     (Joystick : in SDL.Inputs.Joysticks.Joystick) return Boolean
   is
   begin
      return Boolean
        (Raw.Is_Joystick_Haptic
           (To_Address (SDL.Inputs.Joysticks.Get_Internal (Joystick))));
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
      Open_Internal
        (Self,
         To_Pointer (Raw.Open_Haptic (Raw.ID (Instance))),
         "SDL_OpenHaptic failed");
   end Open;

   function Get (Instance : in ID) return Haptic is
   begin
      return (Ada.Finalization.Limited_Controlled with
              Internal => To_Pointer (Raw.Get_Haptic_From_ID (Raw.ID (Instance))),
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
         To_Pointer
           (Raw.Open_Haptic_From_Joystick
              (To_Address (SDL.Inputs.Joysticks.Get_Internal (Joystick)))),
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
         Raw.Close_Haptic (To_Address (Self.Internal));
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

      Result := ID (Raw.Get_Haptic_ID (To_Address (Self.Internal)));
      if Result = 0 then
         Raise_Last_Error ("SDL_GetHapticID failed");
      end if;

      return Result;
   end Get_ID;

   function Name (Self : in Haptic) return String is
      Value : CS.chars_ptr;
   begin
      Require_Valid (Self);

      Value := Raw.Get_Haptic_Name (To_Address (Self.Internal));
      if Value = CS.Null_Ptr then
         return "";
      end if;

      return CS.Value (Value);
   end Name;

   function Get_Max_Effects (Self : in Haptic) return Natural is
   begin
      Require_Valid (Self);
      return Checked_Count
        (Raw.Get_Max_Haptic_Effects (To_Address (Self.Internal)),
         "SDL_GetMaxHapticEffects failed");
   end Get_Max_Effects;

   function Get_Max_Playing_Effects (Self : in Haptic) return Natural is
   begin
      Require_Valid (Self);
      return Checked_Count
        (Raw.Get_Max_Haptic_Effects_Playing (To_Address (Self.Internal)),
         "SDL_GetMaxHapticEffectsPlaying failed");
   end Get_Max_Playing_Effects;

   function Get_Features (Self : in Haptic) return Features is
   begin
      Require_Valid (Self);
      return Features (Raw.Get_Haptic_Features (To_Address (Self.Internal)));
   end Get_Features;

   function Get_Num_Axes (Self : in Haptic) return Natural is
   begin
      Require_Valid (Self);
      return Checked_Count
        (Raw.Get_Num_Haptic_Axes (To_Address (Self.Internal)),
         "SDL_GetNumHapticAxes failed");
   end Get_Num_Axes;

   function Effect_Supported
     (Self  : in Haptic;
      Value : in Effect) return Boolean
   is
      Copy : aliased constant Effect := Value;
   begin
      Require_Valid (Self);
      return Boolean
        (Raw.Haptic_Effect_Supported
           (To_Address (Self.Internal), Copy'Address));
   end Effect_Supported;

   function Create_Effect
     (Self  : in Haptic;
      Value : in Effect) return Effect_ID
   is
      Copy   : aliased constant Effect := Value;
      Result : Effect_ID;
   begin
      Require_Valid (Self);

      Result :=
        Raw.Create_Haptic_Effect
          (To_Address (Self.Internal), Copy'Address);
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

      if not Boolean
          (Raw.Update_Haptic_Effect
             (To_Address (Self.Internal), Item, Copy'Address))
      then
         Raise_Last_Error ("SDL_UpdateHapticEffect failed");
      end if;
   end Update_Effect;

   procedure Run_Effect
     (Self       : in Haptic;
      Item       : in Effect_ID;
      Iterations : in Replay_Counts := 1) is
   begin
      Require_Valid (Self);

      if not Boolean
          (Raw.Run_Haptic_Effect
             (To_Address (Self.Internal), Raw.Effect_ID (Item), Iterations))
      then
         Raise_Last_Error ("SDL_RunHapticEffect failed");
      end if;
   end Run_Effect;

   procedure Stop_Effect
     (Self   : in Haptic;
      Item   : in Effect_ID) is
   begin
      Require_Valid (Self);

      if not Boolean
          (Raw.Stop_Haptic_Effect
             (To_Address (Self.Internal), Raw.Effect_ID (Item)))
      then
         Raise_Last_Error ("SDL_StopHapticEffect failed");
      end if;
   end Stop_Effect;

   procedure Destroy_Effect
     (Self   : in Haptic;
      Item   : in Effect_ID) is
   begin
      Require_Valid (Self);
      Raw.Destroy_Haptic_Effect
        (To_Address (Self.Internal), Raw.Effect_ID (Item));
   end Destroy_Effect;

   function Effect_Status
     (Self   : in Haptic;
      Item   : in Effect_ID) return Boolean is
   begin
      Require_Valid (Self);
      return Boolean
        (Raw.Get_Haptic_Effect_Status
           (To_Address (Self.Internal), Raw.Effect_ID (Item)));
   end Effect_Status;

   procedure Set_Gain
     (Self  : in Haptic;
      Gain  : in C.int) is
   begin
      Require_Valid (Self);

      if not Boolean
          (Raw.Set_Haptic_Gain (To_Address (Self.Internal), Gain))
      then
         Raise_Last_Error ("SDL_SetHapticGain failed");
      end if;
   end Set_Gain;

   procedure Set_Autocenter
     (Self       : in Haptic;
      Autocenter : in C.int) is
   begin
      Require_Valid (Self);

      if not Boolean
          (Raw.Set_Haptic_Autocenter (To_Address (Self.Internal), Autocenter))
      then
         Raise_Last_Error ("SDL_SetHapticAutocenter failed");
      end if;
   end Set_Autocenter;

   procedure Pause (Self : in Haptic) is
   begin
      Require_Valid (Self);

      if not Boolean (Raw.Pause_Haptic (To_Address (Self.Internal))) then
         Raise_Last_Error ("SDL_PauseHaptic failed");
      end if;
   end Pause;

   procedure Resume (Self : in Haptic) is
   begin
      Require_Valid (Self);

      if not Boolean (Raw.Resume_Haptic (To_Address (Self.Internal))) then
         Raise_Last_Error ("SDL_ResumeHaptic failed");
      end if;
   end Resume;

   procedure Stop_All_Effects (Self : in Haptic) is
   begin
      Require_Valid (Self);

      if not Boolean (Raw.Stop_Haptic_Effects (To_Address (Self.Internal))) then
         Raise_Last_Error ("SDL_StopHapticEffects failed");
      end if;
   end Stop_All_Effects;

   function Supports_Rumble (Self : in Haptic) return Boolean is
   begin
      Require_Valid (Self);
      return Boolean (Raw.Haptic_Rumble_Supported (To_Address (Self.Internal)));
   end Supports_Rumble;

   procedure Initialise_Rumble (Self : in Haptic) is
   begin
      Require_Valid (Self);

      if not Boolean (Raw.Init_Haptic_Rumble (To_Address (Self.Internal))) then
         Raise_Last_Error ("SDL_InitHapticRumble failed");
      end if;
   end Initialise_Rumble;

   procedure Play_Rumble
     (Self      : in Haptic;
      Strength  : in C.C_float;
      Length_MS : in Replay_Counts) is
   begin
      Require_Valid (Self);

      if not Boolean
          (Raw.Play_Haptic_Rumble
             (To_Address (Self.Internal), Strength, Length_MS))
      then
         Raise_Last_Error ("SDL_PlayHapticRumble failed");
      end if;
   end Play_Rumble;

   procedure Stop_Rumble (Self : in Haptic) is
   begin
      Require_Valid (Self);

      if not Boolean (Raw.Stop_Haptic_Rumble (To_Address (Self.Internal))) then
         Raise_Last_Error ("SDL_StopHapticRumble failed");
      end if;
   end Stop_Rumble;

   function Get_Internal
     (Self : in Haptic) return SDL.C_Pointers.Haptic_Pointer is
   begin
      return Self.Internal;
   end Get_Internal;
end SDL.Haptics;
