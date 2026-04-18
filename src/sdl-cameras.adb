with Ada.Unchecked_Conversion;
with Interfaces.C.Pointers;
with Interfaces.C.Strings;
with System;

with SDL.Error;
with SDL.Raw.Camera;

package body SDL.Cameras is
   package Raw renames SDL.Raw.Camera;
   package CS renames Interfaces.C.Strings;

   use type C.ptrdiff_t;
   use type CS.chars_ptr;
   use type Raw.ID_Pointers.Pointer;
   use type SDL.C_Pointers.Camera_Pointer;
   use type SDL.Properties.Property_ID;
   use type SDL.Video.Surfaces.Internal_Surface_Pointer;
   use type System.Address;

   type Spec_Access is access all Spec with
     Convention => C;

   type Spec_Access_Arrays is array (C.ptrdiff_t range <>) of aliased Spec_Access with
     Convention => C;

   package Spec_Pointers is new Interfaces.C.Pointers
     (Index              => C.ptrdiff_t,
      Element            => Spec_Access,
      Element_Array      => Spec_Access_Arrays,
      Default_Terminator => null);

   use type Spec_Pointers.Pointer;

   function To_Address is new Ada.Unchecked_Conversion
     (Source => Raw.ID_Pointers.Pointer,
      Target => System.Address);

   function To_Address is new Ada.Unchecked_Conversion
     (Source => Spec_Pointers.Pointer,
      Target => System.Address);

   function To_Address is new Ada.Unchecked_Conversion
     (Source => SDL.C_Pointers.Camera_Pointer,
      Target => System.Address);

   function To_Address is new Ada.Unchecked_Conversion
     (Source => SDL.Video.Surfaces.Internal_Surface_Pointer,
      Target => System.Address);

   function To_Pointer is new Ada.Unchecked_Conversion
     (Source => System.Address,
      Target => SDL.C_Pointers.Camera_Pointer);

   function To_Surface_Pointer is new Ada.Unchecked_Conversion
     (Source => System.Address,
      Target => SDL.Video.Surfaces.Internal_Surface_Pointer);

   function To_Spec_Pointers is new Ada.Unchecked_Conversion
     (Source => System.Address,
      Target => Spec_Pointers.Pointer);

   function To_Public (Value : in Raw.Positions) return Positions is
     (Positions'Val (Raw.Positions'Pos (Value)));

   function To_Public
     (Value : in Raw.Permission_States) return Permission_States is
     (Permission_States'Val (Raw.Permission_States'Pos (Value)));

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

   procedure Free (Items : in out Raw.ID_Pointers.Pointer);

   procedure Free (Items : in out Raw.ID_Pointers.Pointer) is
   begin
      if Items /= null then
         Raw.Free (To_Address (Items));
         Items := null;
      end if;
   end Free;

   procedure Free (Items : in out Spec_Pointers.Pointer);

   procedure Free (Items : in out Spec_Pointers.Pointer) is
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
         Raise_Last_Error ("Camera enumeration failed");
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

      Internal :=
        To_Pointer
          (Raw.Open_Camera
             (Raw.ID (Instance),
              (if Desired = null then System.Null_Address else Desired.all'Address)));
      if Internal = null then
         Raise_Last_Error ("SDL_OpenCamera failed");
      end if;

      Self.Internal := Internal;
      Self.Owns := True;
   end Open_Internal;

   function Total_Drivers return Natural is
      Count : constant C.int := Raw.Get_Num_Camera_Drivers;
   begin
      if Count < 0 then
         return 0;
      end if;

      return Natural (Count);
   end Total_Drivers;

   function Driver_Name (Index : in Positive) return String is
      Value : constant CS.chars_ptr := Raw.Get_Camera_Driver (C.int (Index - 1));
   begin
      if Value = CS.Null_Ptr then
         return "";
      end if;

      return CS.Value (Value);
   end Driver_Name;

   function Current_Driver_Name return String is
      Value : constant CS.chars_ptr := Raw.Get_Current_Camera_Driver;
   begin
      if Value = CS.Null_Ptr then
         return "";
      end if;

      return CS.Value (Value);
   end Current_Driver_Name;

   function Get_Cameras return ID_Lists is
      Count : aliased C.int := 0;
      Items : constant Raw.ID_Pointers.Pointer := Raw.Get_Cameras (Count'Access);
   begin
      return Copy_IDs (Items, Count);
   end Get_Cameras;

   function Supported_Formats (Instance : in ID) return Spec_Lists is
      Count : aliased C.int := 0;
      Items : constant Spec_Pointers.Pointer :=
        To_Spec_Pointers
          (Raw.Get_Camera_Supported_Formats (Raw.ID (Instance), Count'Access));
   begin
      return Copy_Specs (Items, Count);
   end Supported_Formats;

   function Name (Instance : in ID) return String is
      Value : constant CS.chars_ptr := Raw.Get_Camera_Name (Raw.ID (Instance));
   begin
      if Value = CS.Null_Ptr then
         return "";
      end if;

      return CS.Value (Value);
   end Name;

   function Position (Instance : in ID) return Positions is
   begin
      return To_Public (Raw.Get_Camera_Position (Raw.ID (Instance)));
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
         Raw.Close_Camera (To_Address (Self.Internal));
      end if;

      Self.Internal := null;
      Self.Owns := True;
   end Close;

   function Is_Null (Self : in Camera) return Boolean is
     (Self.Internal = null);

   function Permission_State (Self : in Camera) return Permission_States is
   begin
      Require_Valid (Self);
      return To_Public (Raw.Get_Camera_Permission_State (To_Address (Self.Internal)));
   end Permission_State;

   function Get_ID (Self : in Camera) return ID is
      Result : ID;
   begin
      if Self.Internal = null then
         return 0;
      end if;

      Result := ID (Raw.Get_Camera_ID (To_Address (Self.Internal)));
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

      Props := Raw.Get_Camera_Properties (To_Address (Self.Internal));
      if Props = SDL.Properties.Null_Property_ID then
         Raise_Last_Error ("SDL_GetCameraProperties failed");
      end if;

      return SDL.Properties.Reference (Props);
   end Get_Properties;

   function Get_Format
     (Self  : in Camera;
      Value : out Spec) return Boolean
   is
      Raw_Value : aliased Spec;
   begin
      Require_Valid (Self);

      if not Boolean
          (Raw.Get_Camera_Format
             (To_Address (Self.Internal), Raw_Value'Address))
      then
         return False;
      end if;

      Value := Raw_Value;
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

      Frame :=
        To_Surface_Pointer
          (Raw.Acquire_Camera_Frame (To_Address (Self.Internal), Stamp'Access));
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

      Raw.Release_Camera_Frame
        (To_Address (Self.Internal), To_Address (Internal));
      Frame := SDL.Video.Surfaces.Null_Surface;
   end Release_Frame;

   function Get_Internal
     (Self : in Camera) return SDL.C_Pointers.Camera_Pointer is
   begin
      return Self.Internal;
   end Get_Internal;
end SDL.Cameras;
