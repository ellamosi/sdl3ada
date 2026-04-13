with Ada.Unchecked_Conversion;
with Interfaces.C.Extensions;
with Interfaces.C.Pointers;
with Interfaces.C.Strings;
with System;

with SDL.Error;
with SDL.Video.Surfaces.Makers;

package body SDL.Cameras is
   package CE renames Interfaces.C.Extensions;
   package CS renames Interfaces.C.Strings;

   use type C.ptrdiff_t;
   use type CS.chars_ptr;
   use type SDL.C_Pointers.Camera_Pointer;
   use type SDL.Properties.Property_ID;
   use type SDL.Video.Surfaces.Internal_Surface_Pointer;
   use type System.Address;

   type ID_Arrays is array (C.ptrdiff_t range <>) of aliased ID with
     Convention => C;

   package ID_Pointers is new Interfaces.C.Pointers
     (Index              => C.ptrdiff_t,
      Element            => ID,
      Element_Array      => ID_Arrays,
      Default_Terminator => 0);

   type Spec_Access is access all Spec with
     Convention => C;

   type Spec_Access_Arrays is array (C.ptrdiff_t range <>) of aliased Spec_Access with
     Convention => C;

   package Spec_Pointers is new Interfaces.C.Pointers
     (Index              => C.ptrdiff_t,
      Element            => Spec_Access,
      Element_Array      => Spec_Access_Arrays,
      Default_Terminator => null);

   use type ID_Pointers.Pointer;
   use type Spec_Pointers.Pointer;

   function To_Address is new Ada.Unchecked_Conversion
     (Source => ID_Pointers.Pointer,
      Target => System.Address);

   function To_Address is new Ada.Unchecked_Conversion
     (Source => Spec_Pointers.Pointer,
      Target => System.Address);

   function Make_Surface_From_Pointer
     (S    : in SDL.Video.Surfaces.Internal_Surface_Pointer;
      Owns : in Boolean := False) return SDL.Video.Surfaces.Surface
   with
     Import     => True,
     Convention => Ada;

   function Get_Internal_Surface
     (Self : in SDL.Video.Surfaces.Surface)
      return SDL.Video.Surfaces.Internal_Surface_Pointer
   with
     Import     => True,
     Convention => Ada;

   procedure SDL_Free (Memory : in System.Address) with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_free";

   function SDL_Get_Num_Camera_Drivers return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetNumCameraDrivers";

   function SDL_Get_Camera_Driver
     (Index : in C.int) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetCameraDriver";

   function SDL_Get_Current_Camera_Driver return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetCurrentCameraDriver";

   function SDL_Get_Cameras
     (Count : access C.int) return ID_Pointers.Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetCameras";

   function SDL_Get_Camera_Supported_Formats
     (Instance : in ID;
      Count    : access C.int) return Spec_Pointers.Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetCameraSupportedFormats";

   function SDL_Get_Camera_Name
     (Instance : in ID) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetCameraName";

   function SDL_Get_Camera_Position
     (Instance : in ID) return Positions
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetCameraPosition";

   function SDL_Open_Camera
     (Instance : in ID;
      Desired  : access constant Spec) return SDL.C_Pointers.Camera_Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_OpenCamera";

   function SDL_Get_Camera_Permission_State
     (Self : in SDL.C_Pointers.Camera_Pointer) return Permission_States
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetCameraPermissionState";

   function SDL_Get_Camera_ID
     (Self : in SDL.C_Pointers.Camera_Pointer) return ID
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetCameraID";

   function SDL_Get_Camera_Properties
     (Self : in SDL.C_Pointers.Camera_Pointer) return SDL.Properties.Property_ID
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetCameraProperties";

   function SDL_Get_Camera_Format
     (Self  : in SDL.C_Pointers.Camera_Pointer;
      Value : access Spec) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetCameraFormat";

   function SDL_Acquire_Camera_Frame
     (Self         : in SDL.C_Pointers.Camera_Pointer;
      Timestamp_NS : access Timestamp_Nanoseconds)
      return SDL.Video.Surfaces.Internal_Surface_Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_AcquireCameraFrame";

   procedure SDL_Release_Camera_Frame
     (Self  : in SDL.C_Pointers.Camera_Pointer;
      Frame : in SDL.Video.Surfaces.Internal_Surface_Pointer)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ReleaseCameraFrame";

   procedure SDL_Close_Camera
     (Self : in SDL.C_Pointers.Camera_Pointer)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CloseCamera";

   procedure Raise_Last_Error
     (Default_Message : in String := "SDL camera call failed");

   procedure Raise_Last_Error
     (Default_Message : in String := "SDL camera call failed")
   is
      Message : constant String := SDL.Error.Get;
   begin
      if Message = "" then
         raise Camera_Error with Default_Message;
      end if;

      raise Camera_Error with Message;
   end Raise_Last_Error;

   procedure Require_Valid (Self : in Camera);

   procedure Require_Valid (Self : in Camera) is
   begin
      if Self.Internal = null then
         raise Camera_Error with "Invalid camera";
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

   procedure Free (Items : in out Spec_Pointers.Pointer);

   procedure Free (Items : in out Spec_Pointers.Pointer) is
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
         Raise_Last_Error ("Camera enumeration failed");
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

   function Copy_Specs
     (Items : in Spec_Pointers.Pointer;
      Count : in C.int) return Spec_Lists;

   function Copy_Specs
     (Items : in Spec_Pointers.Pointer;
      Count : in C.int) return Spec_Lists
   is
      Raw : Spec_Pointers.Pointer := Items;
   begin
      if Count <= 0 then
         Free (Raw);
         return [];
      end if;

      if Raw = null then
         Raise_Last_Error ("SDL_GetCameraSupportedFormats failed");
      end if;

      declare
         Source : constant Spec_Access_Arrays :=
           Spec_Pointers.Value (Raw, C.ptrdiff_t (Count));
         Result : Spec_Lists (0 .. Natural (Count) - 1);
      begin
         for Index in Result'Range loop
            declare
               Source_Index : constant C.ptrdiff_t :=
                 Source'First + C.ptrdiff_t (Index - Result'First);
            begin
               if Source (Source_Index) = null then
                  Free (Raw);
                  raise Camera_Error with "Camera format list contains a null spec";
               end if;

               Result (Index) := Source (Source_Index).all;
            end;
         end loop;

         Free (Raw);
         return Result;
      exception
         when others =>
            Free (Raw);
            raise;
      end;
   end Copy_Specs;

   procedure Open_Internal
     (Self     : in out Camera;
      Instance : in ID;
      Desired  : access constant Spec);

   procedure Open_Internal
     (Self     : in out Camera;
      Instance : in ID;
      Desired  : access constant Spec)
   is
      Internal : SDL.C_Pointers.Camera_Pointer := null;
   begin
      Close (Self);

      Internal := SDL_Open_Camera (Instance, Desired);
      if Internal = null then
         Raise_Last_Error ("SDL_OpenCamera failed");
      end if;

      Self.Internal := Internal;
      Self.Owns := True;
   end Open_Internal;

   function Total_Drivers return Natural is
      Count : constant C.int := SDL_Get_Num_Camera_Drivers;
   begin
      if Count < 0 then
         return 0;
      end if;

      return Natural (Count);
   end Total_Drivers;

   function Driver_Name (Index : in Positive) return String is
      Value : constant CS.chars_ptr := SDL_Get_Camera_Driver (C.int (Index - 1));
   begin
      if Value = CS.Null_Ptr then
         return "";
      end if;

      return CS.Value (Value);
   end Driver_Name;

   function Current_Driver_Name return String is
      Value : constant CS.chars_ptr := SDL_Get_Current_Camera_Driver;
   begin
      if Value = CS.Null_Ptr then
         return "";
      end if;

      return CS.Value (Value);
   end Current_Driver_Name;

   function Get_Cameras return ID_Lists is
      Count : aliased C.int := 0;
      Items : constant ID_Pointers.Pointer := SDL_Get_Cameras (Count'Access);
   begin
      return Copy_IDs (Items, Count);
   end Get_Cameras;

   function Supported_Formats (Instance : in ID) return Spec_Lists is
      Count : aliased C.int := 0;
      Items : constant Spec_Pointers.Pointer :=
        SDL_Get_Camera_Supported_Formats (Instance, Count'Access);
   begin
      return Copy_Specs (Items, Count);
   end Supported_Formats;

   function Name (Instance : in ID) return String is
      Value : constant CS.chars_ptr := SDL_Get_Camera_Name (Instance);
   begin
      if Value = CS.Null_Ptr then
         return "";
      end if;

      return CS.Value (Value);
   end Name;

   function Position (Instance : in ID) return Positions is
   begin
      return SDL_Get_Camera_Position (Instance);
   end Position;

   function Open (Instance : in ID) return Camera is
   begin
      return Result : Camera do
         Open_Internal (Result, Instance, null);
      end return;
   end Open;

   function Open
     (Instance : in ID;
      Desired  : in Spec) return Camera
   is
   begin
      return Result : Camera do
         Open_Internal (Result, Instance, Desired'Unrestricted_Access);
      end return;
   end Open;

   procedure Open
     (Self     : in out Camera;
      Instance : in ID) is
   begin
      Open_Internal (Self, Instance, null);
   end Open;

   procedure Open
     (Self     : in out Camera;
      Instance : in ID;
      Desired  : in Spec) is
   begin
      Open_Internal (Self, Instance, Desired'Unrestricted_Access);
   end Open;

   overriding
   procedure Finalize (Self : in out Camera) is
   begin
      Close (Self);
   end Finalize;

   procedure Close (Self : in out Camera) is
   begin
      if Self.Owns and then Self.Internal /= null then
         SDL_Close_Camera (Self.Internal);
      end if;

      Self.Internal := null;
      Self.Owns := True;
   end Close;

   function Is_Null (Self : in Camera) return Boolean is
     (Self.Internal = null);

   function Permission_State (Self : in Camera) return Permission_States is
   begin
      Require_Valid (Self);
      return SDL_Get_Camera_Permission_State (Self.Internal);
   end Permission_State;

   function Get_ID (Self : in Camera) return ID is
      Result : ID;
   begin
      if Self.Internal = null then
         return 0;
      end if;

      Result := SDL_Get_Camera_ID (Self.Internal);
      if Result = 0 then
         Raise_Last_Error ("SDL_GetCameraID failed");
      end if;

      return Result;
   end Get_ID;

   function Get_Properties
     (Self : in Camera) return SDL.Properties.Property_Set
   is
      Props : SDL.Properties.Property_ID;
   begin
      Require_Valid (Self);

      Props := SDL_Get_Camera_Properties (Self.Internal);
      if Props = SDL.Properties.Null_Property_ID then
         Raise_Last_Error ("SDL_GetCameraProperties failed");
      end if;

      return SDL.Properties.Reference (Props);
   end Get_Properties;

   function Get_Format
     (Self  : in Camera;
      Value : out Spec) return Boolean
   is
      Raw : aliased Spec;
   begin
      Require_Valid (Self);

      if not Boolean (SDL_Get_Camera_Format (Self.Internal, Raw'Access)) then
         return False;
      end if;

      Value := Raw;
      return True;
   end Get_Format;

   function Acquire_Frame
     (Self         : in Camera;
      Timestamp_NS : out Timestamp_Nanoseconds)
      return SDL.Video.Surfaces.Surface
   is
      Stamp : aliased Timestamp_Nanoseconds := 0;
      Frame : SDL.Video.Surfaces.Internal_Surface_Pointer;
   begin
      Require_Valid (Self);

      Frame := SDL_Acquire_Camera_Frame (Self.Internal, Stamp'Access);
      Timestamp_NS := Stamp;

      if Frame = null then
         return SDL.Video.Surfaces.Null_Surface;
      end if;

      return Make_Surface_From_Pointer (Frame, Owns => False);
   end Acquire_Frame;

   procedure Release_Frame
     (Self  : in Camera;
      Frame : in out SDL.Video.Surfaces.Surface)
   is
      Internal : constant SDL.Video.Surfaces.Internal_Surface_Pointer :=
        Get_Internal_Surface (Frame);
   begin
      Require_Valid (Self);

      if Internal = null then
         return;
      end if;

      SDL_Release_Camera_Frame (Self.Internal, Internal);
      Frame := SDL.Video.Surfaces.Null_Surface;
   end Release_Frame;

   function Get_Internal
     (Self : in Camera) return SDL.C_Pointers.Camera_Pointer is
   begin
      return Self.Internal;
   end Get_Internal;
end SDL.Cameras;
