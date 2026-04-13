with Ada.Unchecked_Conversion;
with Interfaces.C.Pointers;
with Interfaces.C.Strings;
with System;

with SDL.Error;

package body SDL.Events.Touches is
   package C renames Interfaces.C;
   package CS renames Interfaces.C.Strings;

   type ID_Arrays is array (C.ptrdiff_t range <>) of aliased Touch_IDs with
     Convention => C;

   package ID_Pointers is new Interfaces.C.Pointers
     (Index              => C.ptrdiff_t,
      Element            => Touch_IDs,
      Element_Array      => ID_Arrays,
      Default_Terminator => 0);

   type Finger_Pointer is access all Finger with
     Convention => C;

   type Internal_Finger_Pointer_Arrays is
     array (C.ptrdiff_t range <>) of aliased Finger_Pointer
   with Convention => C;

   package Finger_Pointers is new Interfaces.C.Pointers
     (Index              => C.ptrdiff_t,
      Element            => Finger_Pointer,
      Element_Array      => Internal_Finger_Pointer_Arrays,
      Default_Terminator => null);

   use type C.ptrdiff_t;
   use type CS.chars_ptr;
   use type Finger_Pointers.Pointer;
   use type ID_Pointers.Pointer;
   use type System.Address;

   function To_Address is new Ada.Unchecked_Conversion
     (Source => ID_Pointers.Pointer,
      Target => System.Address);

   function To_Address is new Ada.Unchecked_Conversion
     (Source => Finger_Pointers.Pointer,
      Target => System.Address);

   procedure SDL_Free (Memory : in System.Address)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_free";

   function SDL_Get_Touch_Devices
     (Count : access C.int) return ID_Pointers.Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetTouchDevices";

   function SDL_Get_Touch_Device_Name
     (Instance : in Touch_IDs) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetTouchDeviceName";

   function SDL_Get_Touch_Device_Type
     (Instance : in Touch_IDs) return Touch_Device_Types
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetTouchDeviceType";

   function SDL_Get_Touch_Fingers
     (Instance : in Touch_IDs;
      Count    : access C.int) return Finger_Pointers.Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetTouchFingers";

   procedure Raise_Last_Error
     (Default_Message : in String := "SDL touch call failed");

   procedure Raise_Last_Error
     (Default_Message : in String := "SDL touch call failed")
   is
      Message : constant String := SDL.Error.Get;
   begin
      if Message = "" then
         raise Touch_Error with Default_Message;
      end if;

      raise Touch_Error with Message;
   end Raise_Last_Error;

   procedure Free (Items : in out ID_Pointers.Pointer);

   procedure Free (Items : in out ID_Pointers.Pointer) is
   begin
      if Items /= null then
         SDL_Free (To_Address (Items));
         Items := null;
      end if;
   end Free;

   procedure Free (Items : in out Finger_Pointers.Pointer);

   procedure Free (Items : in out Finger_Pointers.Pointer) is
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
         Raise_Last_Error ("Touch enumeration failed");
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

   function Copy_Fingers
     (Items : in Finger_Pointers.Pointer;
      Count : in C.int) return Finger_Lists;

   function Copy_Fingers
     (Items : in Finger_Pointers.Pointer;
      Count : in C.int) return Finger_Lists
   is
      Raw : Finger_Pointers.Pointer := Items;
   begin
      if Count <= 0 then
         Free (Raw);
         return [];
      end if;

      if Raw = null then
         Raise_Last_Error ("Touch finger enumeration failed");
      end if;

      declare
         Source : constant Internal_Finger_Pointer_Arrays :=
           Finger_Pointers.Value (Raw, C.ptrdiff_t (Count));
         Result : Finger_Lists (0 .. Natural (Count) - 1);
      begin
         for Index in Result'Range loop
            declare
               Current : constant Finger_Pointer :=
                 Source (Source'First + C.ptrdiff_t (Index - Result'First));
            begin
               if Current = null then
                  Result (Index) := (others => <>);
               else
                  Result (Index) := Current.all;
               end if;
            end;
         end loop;

         Free (Raw);
         return Result;
      exception
         when others =>
            Free (Raw);
            raise;
      end;
   end Copy_Fingers;

   function Get_Touches return ID_Lists is
      Count : aliased C.int := 0;
      Items : constant ID_Pointers.Pointer := SDL_Get_Touch_Devices (Count'Access);
   begin
      return Copy_IDs (Items, Count);
   end Get_Touches;

   function Name (Instance : in Touch_IDs) return String is
      Value : constant CS.chars_ptr := SDL_Get_Touch_Device_Name (Instance);
   begin
      if Value = CS.Null_Ptr then
         return "";
      end if;

      return CS.Value (Value);
   end Name;

   function Device_Type
     (Instance : in Touch_IDs) return Touch_Device_Types is
   begin
      return SDL_Get_Touch_Device_Type (Instance);
   end Device_Type;

   function Get_Fingers
     (Instance : in Touch_IDs) return Finger_Lists
   is
      Count : aliased C.int := 0;
      Items : constant Finger_Pointers.Pointer :=
        SDL_Get_Touch_Fingers (Instance, Count'Access);
   begin
      return Copy_Fingers (Items, Count);
   end Get_Fingers;
end SDL.Events.Touches;
