with Interfaces.C;

with SDL.Error;

package body SDL.Events.Events is
   package C renames Interfaces.C;

   use type System.Address;

   function SDL_Peep_Events
     (Items     : in System.Address;
      Num_Events : in C.int;
      Action    : in Event_Actions;
      Min_Type  : in SDL.Events.Event_Types;
      Max_Type  : in SDL.Events.Event_Types) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_PeepEvents";

   function SDL_Poll_Event (Value : out Events) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_PollEvent";

   function SDL_Wait_Event (Value : out Events) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_WaitEvent";

   function SDL_Wait_Event_Timeout
     (Value      : out Events;
      Timeout_MS : in Interfaces.Integer_32) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_WaitEventTimeout";

   procedure SDL_Pump_Events
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_PumpEvents";

   function SDL_Has_Event
     (Event_Type : in SDL.Events.Event_Types) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_HasEvent";

   function SDL_Has_Events
     (Min_Type : in SDL.Events.Event_Types;
      Max_Type : in SDL.Events.Event_Types) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_HasEvents";

   procedure SDL_Flush_Event
     (Event_Type : in SDL.Events.Event_Types)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_FlushEvent";

   procedure SDL_Flush_Events
     (Min_Type : in SDL.Events.Event_Types;
      Max_Type : in SDL.Events.Event_Types)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_FlushEvents";

   function SDL_Push_Event (Value : access Events) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_PushEvent";

   procedure SDL_Set_Event_Filter
     (Filter    : in Event_Filter;
      User_Data : in System.Address)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetEventFilter";

   function SDL_Get_Event_Filter
     (Filter    : access Event_Filter;
      User_Data : access System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetEventFilter";

   function SDL_Add_Event_Watch
     (Filter    : in Event_Filter;
      User_Data : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_AddEventWatch";

   procedure SDL_Remove_Event_Watch
     (Filter    : in Event_Filter;
      User_Data : in System.Address)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_RemoveEventWatch";

   procedure SDL_Filter_Events
     (Filter    : in Event_Filter;
      User_Data : in System.Address)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_FilterEvents";

   procedure SDL_Set_Event_Enabled
     (Event_Type : in SDL.Events.Event_Types;
      Enabled    : in CE.bool)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetEventEnabled";

   function SDL_Event_Enabled
     (Event_Type : in SDL.Events.Event_Types) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_EventEnabled";

   function SDL_Register_Events
     (Count : in C.int) return SDL.Events.Event_Types
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_RegisterEvents";

   function SDL_Get_Window_From_Event
     (Event : access constant Events) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetWindowFromEvent";

   function SDL_Get_Window_ID
     (Window : in System.Address) return SDL.Video.Windows.ID
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetWindowID";

   function SDL_Get_Event_Description
     (Event         : access constant Events;
      Buffer        : in System.Address;
      Buffer_Length : in C.int) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetEventDescription";

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
      return Boolean (SDL_Poll_Event (Event));
   end Poll;

   procedure Wait (Event : out Events) is
   begin
      if not Boolean (SDL_Wait_Event (Event)) then
         Raise_With_Last_Error ("SDL_WaitEvent failed");
      end if;
   end Wait;

   function Wait
     (Event      : out Events;
      Timeout_MS : in Interfaces.Integer_32) return Boolean
   is
   begin
      return Boolean (SDL_Wait_Event_Timeout (Event, Timeout_MS));
   end Wait;

   procedure Pump is
   begin
      SDL_Pump_Events;
   end Pump;

   function Peep
     (Items    : in out Event_Arrays;
      Action   : in Event_Actions;
      Min_Type : in SDL.Events.Event_Types := SDL.Events.First_Event;
      Max_Type : in SDL.Events.Event_Types := SDL.Events.Last_Event)
      return Natural
   is
      Items_Address : System.Address := System.Null_Address;
      Retrieved     : C.int;
   begin
      if Items'Length > 0 then
         Items_Address := Items (Items'First)'Address;
      end if;

      Retrieved :=
        SDL_Peep_Events
          (Items      => Items_Address,
           Num_Events => C.int (Items'Length),
           Action     => Action,
           Min_Type   => Min_Type,
           Max_Type   => Max_Type);

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
        SDL_Peep_Events
          (Items      => System.Null_Address,
           Num_Events => 0,
           Action     => Peek,
           Min_Type   => Min_Type,
           Max_Type   => Max_Type);
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
      return Boolean (SDL_Has_Event (Event_Type));
   end Has;

   function Has
     (Min_Type : in SDL.Events.Event_Types;
      Max_Type : in SDL.Events.Event_Types) return Boolean
   is
   begin
      return Boolean (SDL_Has_Events (Min_Type, Max_Type));
   end Has;

   procedure Flush (Event_Type : in SDL.Events.Event_Types) is
   begin
      SDL_Flush_Event (Event_Type);
   end Flush;

   procedure Flush
     (Min_Type : in SDL.Events.Event_Types;
      Max_Type : in SDL.Events.Event_Types)
   is
   begin
      SDL_Flush_Events (Min_Type, Max_Type);
   end Flush;

   function Push (Event : in Events) return Boolean is
      Local_Event : aliased Events := Event;
   begin
      return Boolean (SDL_Push_Event (Local_Event'Access));
   end Push;

   procedure Set_Filter
     (Filter    : in Event_Filter;
      User_Data : in System.Address := System.Null_Address)
   is
   begin
      SDL_Set_Event_Filter (Filter, User_Data);
   end Set_Filter;

   function Get_Filter
     (Filter    : out Event_Filter;
      User_Data : out System.Address) return Boolean
   is
      Local_Filter    : aliased Event_Filter := null;
      Local_User_Data : aliased System.Address := System.Null_Address;
   begin
      if Boolean
          (SDL_Get_Event_Filter
             (Local_Filter'Access, Local_User_Data'Access))
      then
         Filter := Local_Filter;
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
      return Boolean (SDL_Add_Event_Watch (Filter, User_Data));
   end Add_Watch;

   procedure Remove_Watch
     (Filter    : in Event_Filter;
      User_Data : in System.Address := System.Null_Address)
   is
   begin
      SDL_Remove_Event_Watch (Filter, User_Data);
   end Remove_Watch;

   procedure Filter
     (Filter    : in Event_Filter;
      User_Data : in System.Address := System.Null_Address)
   is
   begin
      SDL_Filter_Events (Filter, User_Data);
   end Filter;

   procedure Set_Enabled
     (Event_Type : in SDL.Events.Event_Types;
      Enabled    : in Boolean)
   is
   begin
      SDL_Set_Event_Enabled (Event_Type, To_C_Bool (Enabled));
   end Set_Enabled;

   function Is_Enabled
     (Event_Type : in SDL.Events.Event_Types) return Boolean
   is
   begin
      return Boolean (SDL_Event_Enabled (Event_Type));
   end Is_Enabled;

   function Register
     (Count : in Natural) return SDL.Events.Event_Types
   is
   begin
      return SDL_Register_Events (C.int (Count));
   end Register;

   function Get_Window_ID
     (Event : in Events) return SDL.Video.Windows.ID
   is
      Local_Event : aliased constant Events := Event;
      Window      : constant System.Address :=
        SDL_Get_Window_From_Event (Local_Event'Access);
   begin
      if Window = System.Null_Address then
         return 0;
      end if;

      return SDL_Get_Window_ID (Window);
   end Get_Window_ID;

   function Get_Description (Event : in Events) return String is
      Local_Event : aliased constant Events := Event;
      Needed      : constant C.int :=
        SDL_Get_Event_Description
          (Event         => Local_Event'Access,
           Buffer        => System.Null_Address,
           Buffer_Length => 0);
   begin
      if Needed <= 0 then
         return "";
      end if;

      declare
         Buffer : aliased C.char_array (0 .. C.size_t (Needed));
         Written : constant C.int :=
           SDL_Get_Event_Description
             (Event         => Local_Event'Access,
              Buffer        => Buffer'Address,
              Buffer_Length => Needed + 1);
      begin
         pragma Unreferenced (Written);
         return C.To_Ada (Buffer);
      end;
   end Get_Description;
end SDL.Events.Events;
