with Ada.Unchecked_Conversion;
with Interfaces.C.Strings;
with System;

with SDL.Error;

package body SDL.Events.Touches is
   package C renames Interfaces.C;
   package CS renames Interfaces.C.Strings;
   package Raw renames SDL.Raw.Touch;

   use type C.ptrdiff_t;
   use type CS.chars_ptr;
   use type Raw.Finger_Access;
   use type Raw.Finger_Pointers.Pointer;
   use type Raw.ID_Pointers.Pointer;
   use type System.Address;

   function To_Address is new Ada.Unchecked_Conversion
     (Source => Raw.ID_Pointers.Pointer,
      Target => System.Address);

   function To_Address is new Ada.Unchecked_Conversion
     (Source => Raw.Finger_Pointers.Pointer,
      Target => System.Address);

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

   procedure Free (Items : in out Raw.ID_Pointers.Pointer);

   procedure Free (Items : in out Raw.ID_Pointers.Pointer) is
   begin
      if Items /= null then
         Raw.Free (To_Address (Items));
         Items := null;
      end if;
   end Free;

   procedure Free (Items : in out Raw.Finger_Pointers.Pointer);

   procedure Free (Items : in out Raw.Finger_Pointers.Pointer) is
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
      Raw_Items : Raw.ID_Pointers.Pointer := Items;
   begin
      if Count <= 0 then
         Free (Raw_Items);
         return [];
      end if;

      if Raw_Items = null then
         Raise_Last_Error ("Touch enumeration failed");
      end if;

      declare
         Source : constant Raw.ID_Array :=
           Raw.ID_Pointers.Value (Raw_Items, C.ptrdiff_t (Count));
         Result : ID_Lists (0 .. Natural (Count) - 1);
      begin
         for Index in Result'Range loop
            Result (Index) :=
              Touch_IDs
                (Source (Source'First + C.ptrdiff_t (Index - Result'First)));
         end loop;

         Free (Raw_Items);
         return Result;
      exception
         when others =>
            Free (Raw_Items);
            raise;
      end;
   end Copy_IDs;

   function Copy_Fingers
     (Items : in Raw.Finger_Pointers.Pointer;
      Count : in C.int) return Finger_Lists;

   function Copy_Fingers
     (Items : in Raw.Finger_Pointers.Pointer;
      Count : in C.int) return Finger_Lists
   is
      Raw_Items : Raw.Finger_Pointers.Pointer := Items;
   begin
      if Count <= 0 then
         Free (Raw_Items);
         return [];
      end if;

      if Raw_Items = null then
         Raise_Last_Error ("Touch finger enumeration failed");
      end if;

      declare
         Source : constant Raw.Finger_Access_Array :=
           Raw.Finger_Pointers.Value (Raw_Items, C.ptrdiff_t (Count));
         Result : Finger_Lists (0 .. Natural (Count) - 1);
      begin
         for Index in Result'Range loop
            declare
               Current : constant Raw.Finger_Access :=
                 Source (Source'First + C.ptrdiff_t (Index - Result'First));
            begin
               if Current = null then
                  Result (Index) := (others => <>);
               else
                  Result (Index) := Current.all;
               end if;
            end;
         end loop;

         Free (Raw_Items);
         return Result;
      exception
         when others =>
            Free (Raw_Items);
            raise;
      end;
   end Copy_Fingers;

   function Get_Touches return ID_Lists is
      Count : aliased C.int := 0;
      Items : constant Raw.ID_Pointers.Pointer :=
        Raw.Get_Touch_Devices (Count'Access);
   begin
      return Copy_IDs (Items, Count);
   end Get_Touches;

   function Name (Instance : in Touch_IDs) return String is
      Value : constant CS.chars_ptr :=
        Raw.Get_Touch_Device_Name (Raw.ID (Instance));
   begin
      if Value = CS.Null_Ptr then
         return "";
      end if;

      return CS.Value (Value);
   end Name;

   function Device_Type
     (Instance : in Touch_IDs) return Touch_Device_Types is
   begin
      return Raw.Get_Touch_Device_Type (Instance);
   end Device_Type;

   function Get_Fingers
     (Instance : in Touch_IDs) return Finger_Lists
   is
      Count : aliased C.int := 0;
      Items : constant Raw.Finger_Pointers.Pointer :=
        Raw.Get_Touch_Fingers (Raw.ID (Instance), Count'Access);
   begin
      return Copy_Fingers (Items, Count);
   end Get_Fingers;
end SDL.Events.Touches;
