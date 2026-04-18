with Ada.Unchecked_Conversion;
with Interfaces.C;

with SDL.Error;
with SDL.Raw.Events;
with SDL.Raw.Video;

package body SDL.Events.Events is
   package C renames Interfaces.C;
   package Raw_Events renames SDL.Raw.Events;
   package Raw_Video renames SDL.Raw.Video;

   use type System.Address;
   use type Raw_Video.Window_Pointer;

   function To_Raw (Value : in Event_Actions) return Raw_Events.Event_Action is
     (Raw_Events.Event_Action'Val (Event_Actions'Pos (Value)));

   function To_Raw is new Ada.Unchecked_Conversion
     (Source => Event_Filter,
      Target => Raw_Events.Event_Filter);

   function To_Public is new Ada.Unchecked_Conversion
     (Source => Raw_Events.Event_Filter,
      Target => Event_Filter);

   function To_Event_Pointer is new Ada.Unchecked_Conversion
     (Source => System.Address,
      Target => Raw_Events.Event_Access);

   function To_C_Bool (Value : in Boolean) return CE.bool is
     (CE.bool'Val (Boolean'Pos (Value)));

   procedure Raise_With_Last_Error (Default_Message : in String);
   procedure Raise_With_Last_Error (Default_Message : in String) is
      Message : constant String := SDL.Error.Get;
   begin
      if Message = "" then
         raise Event_Error with Default_Message;
      end if;

      raise Event_Error with Message;
   end Raise_With_Last_Error;

   function Poll (Event : out Events) return Boolean is
   begin
      return Boolean (Raw_Events.Poll_Event (To_Event_Pointer (Event'Address)));
   end Poll;

   procedure Wait (Event : out Events) is
   begin
      if not Boolean
          (Raw_Events.Wait_Event (To_Event_Pointer (Event'Address)))
      then
         Raise_With_Last_Error ("SDL_WaitEvent failed");
      end if;
   end Wait;

   function Wait
     (Event      : out Events;
      Timeout_MS : in Interfaces.Integer_32) return Boolean
   is
   begin
      return Boolean
        (Raw_Events.Wait_Event_Timeout
           (To_Event_Pointer (Event'Address), Timeout_MS));
   end Wait;

   procedure Pump is
   begin
      Raw_Events.Pump_Events;
   end Pump;

   function Peep
     (Items    : in out Event_Arrays;
      Action   : in Event_Actions;
      Min_Type : in SDL.Events.Event_Types := SDL.Events.First_Event;
      Max_Type : in SDL.Events.Event_Types := SDL.Events.Last_Event)
      return Natural
   is
      Items_Buffer : Raw_Events.Event_Access := null;
      Retrieved    : C.int;
   begin
      if Items'Length > 0 then
         Items_Buffer := To_Event_Pointer (Items (Items'First)'Address);
      end if;

      Retrieved :=
        Raw_Events.Peep_Events
          (Items      => Items_Buffer,
           Num_Events => C.int (Items'Length),
           Action     => To_Raw (Action),
           Min_Type   => Raw_Events.Event_Type (Min_Type),
           Max_Type   => Raw_Events.Event_Type (Max_Type));

      if Retrieved < 0 then
         Raise_With_Last_Error ("SDL_PeepEvents failed");
      end if;

      return Natural (Retrieved);
   end Peep;

   function Count
     (Min_Type : in SDL.Events.Event_Types := SDL.Events.First_Event;
      Max_Type : in SDL.Events.Event_Types := SDL.Events.Last_Event)
      return Natural
   is
      Retrieved : constant C.int :=
        Raw_Events.Peep_Events
          (Items      => null,
           Num_Events => 0,
           Action     => Raw_Events.Peek_Action,
           Min_Type   => Raw_Events.Event_Type (Min_Type),
           Max_Type   => Raw_Events.Event_Type (Max_Type));
   begin
      if Retrieved < 0 then
         Raise_With_Last_Error ("SDL_PeepEvents count failed");
      end if;

      return Natural (Retrieved);
   end Count;

   function Has
     (Event_Type : in SDL.Events.Event_Types) return Boolean
   is
   begin
      return Boolean (Raw_Events.Has_Event (Raw_Events.Event_Type (Event_Type)));
   end Has;

   function Has
     (Min_Type : in SDL.Events.Event_Types;
      Max_Type : in SDL.Events.Event_Types) return Boolean
   is
   begin
      return Boolean
        (Raw_Events.Has_Events
           (Raw_Events.Event_Type (Min_Type),
            Raw_Events.Event_Type (Max_Type)));
   end Has;

   procedure Flush (Event_Type : in SDL.Events.Event_Types) is
   begin
      Raw_Events.Flush_Event (Raw_Events.Event_Type (Event_Type));
   end Flush;

   procedure Flush
     (Min_Type : in SDL.Events.Event_Types;
      Max_Type : in SDL.Events.Event_Types)
   is
   begin
      Raw_Events.Flush_Events
        (Raw_Events.Event_Type (Min_Type),
         Raw_Events.Event_Type (Max_Type));
   end Flush;

   function Push (Event : in Events) return Boolean is
      Local_Event : aliased Events := Event;
   begin
      return Boolean
        (Raw_Events.Push_Event (To_Event_Pointer (Local_Event'Address)));
   end Push;

   procedure Set_Filter
     (Filter    : in Event_Filter;
      User_Data : in System.Address := System.Null_Address)
   is
   begin
      Raw_Events.Set_Event_Filter (To_Raw (Filter), User_Data);
   end Set_Filter;

   function Get_Filter
     (Filter    : out Event_Filter;
      User_Data : out System.Address) return Boolean
   is
      Local_Filter    : aliased Raw_Events.Event_Filter := null;
      Local_User_Data : aliased System.Address := System.Null_Address;
   begin
      if Boolean
          (Raw_Events.Get_Event_Filter
             (Local_Filter'Access, Local_User_Data'Access))
      then
         Filter := To_Public (Local_Filter);
         User_Data := Local_User_Data;
         return True;
      end if;

      Filter := null;
      User_Data := System.Null_Address;
      return False;
   end Get_Filter;

   function Add_Watch
     (Filter    : in Event_Filter;
      User_Data : in System.Address := System.Null_Address) return Boolean
   is
   begin
      return Boolean (Raw_Events.Add_Event_Watch (To_Raw (Filter), User_Data));
   end Add_Watch;

   procedure Remove_Watch
     (Filter    : in Event_Filter;
      User_Data : in System.Address := System.Null_Address)
   is
   begin
      Raw_Events.Remove_Event_Watch (To_Raw (Filter), User_Data);
   end Remove_Watch;

   procedure Filter
     (Filter    : in Event_Filter;
      User_Data : in System.Address := System.Null_Address)
   is
   begin
      Raw_Events.Filter_Events (To_Raw (Filter), User_Data);
   end Filter;

   procedure Set_Enabled
     (Event_Type : in SDL.Events.Event_Types;
      Enabled    : in Boolean)
   is
   begin
      Raw_Events.Set_Event_Enabled
        (Raw_Events.Event_Type (Event_Type), To_C_Bool (Enabled));
   end Set_Enabled;

   function Is_Enabled
     (Event_Type : in SDL.Events.Event_Types) return Boolean
   is
   begin
      return Boolean
        (Raw_Events.Event_Enabled (Raw_Events.Event_Type (Event_Type)));
   end Is_Enabled;

   function Register
     (Count : in Natural) return SDL.Events.Event_Types
   is
   begin
      return SDL.Events.Event_Types (Raw_Events.Register_Events (C.int (Count)));
   end Register;

   function Get_Window_ID
     (Event : in Events) return SDL.Video.Windows.ID
   is
      Local_Event : aliased constant Events := Event;
      Window      : constant Raw_Video.Window_Pointer :=
        Raw_Events.Get_Window_From_Event
          (To_Event_Pointer (Local_Event'Address));
   begin
      if Window = null then
         return 0;
      end if;

      return SDL.Video.Windows.ID (Raw_Video.Get_Window_ID (Window));
   end Get_Window_ID;

   function Get_Description (Event : in Events) return String is
      Local_Event : aliased constant Events := Event;
      Needed      : constant C.int :=
        Raw_Events.Get_Event_Description
          (Event         => To_Event_Pointer (Local_Event'Address),
           Buffer        => System.Null_Address,
           Buffer_Length => 0);
   begin
      if Needed <= 0 then
         return "";
      end if;

      declare
         Buffer : aliased C.char_array (0 .. C.size_t (Needed));
         Written : constant C.int :=
           Raw_Events.Get_Event_Description
             (Event         => To_Event_Pointer (Local_Event'Address),
              Buffer        => Buffer'Address,
              Buffer_Length => Needed + 1);
      begin
         pragma Unreferenced (Written);
         return C.To_Ada (Buffer);
      end;
   end Get_Description;
end SDL.Events.Events;
