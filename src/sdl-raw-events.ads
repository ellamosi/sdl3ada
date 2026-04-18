with Interfaces;
with Interfaces.C;
with Interfaces.C.Extensions;
with System;

package SDL.Raw.Events is
   pragma Preelaborate;

   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;

   subtype Event_Type is Interfaces.Unsigned_32;

   type Event_Action is
     (Add_Action,
      Peek_Action,
      Get_Action)
   with
     Convention => C,
     Size       => C.int'Size;

   for Event_Action use
     (Add_Action  => 0,
      Peek_Action => 1,
      Get_Action  => 2);

   type Event_Filter is access function
     (User_Data : in System.Address;
      Event     : in System.Address) return CE.bool
   with Convention => C;

   function Peep_Events
     (Items      : in System.Address;
      Num_Events : in C.int;
      Action     : in Event_Action;
      Min_Type   : in Event_Type;
      Max_Type   : in Event_Type) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_PeepEvents";

   function Poll_Event
     (Value : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_PollEvent";

   function Wait_Event
     (Value : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_WaitEvent";

   function Wait_Event_Timeout
     (Value      : in System.Address;
      Timeout_MS : in Interfaces.Integer_32) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_WaitEventTimeout";

   procedure Pump_Events
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_PumpEvents";

   function Has_Event
     (Kind : in Event_Type) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_HasEvent";

   function Has_Events
     (Min_Type : in Event_Type;
      Max_Type : in Event_Type) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_HasEvents";

   procedure Flush_Event
     (Kind : in Event_Type)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_FlushEvent";

   procedure Flush_Events
     (Min_Type : in Event_Type;
      Max_Type : in Event_Type)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_FlushEvents";

   function Push_Event
     (Value : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_PushEvent";

   procedure Set_Event_Filter
     (Filter    : in Event_Filter;
      User_Data : in System.Address)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetEventFilter";

   function Get_Event_Filter
     (Filter    : access Event_Filter;
      User_Data : access System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetEventFilter";

   function Add_Event_Watch
     (Filter    : in Event_Filter;
      User_Data : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_AddEventWatch";

   procedure Remove_Event_Watch
     (Filter    : in Event_Filter;
      User_Data : in System.Address)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_RemoveEventWatch";

   procedure Filter_Events
     (Filter    : in Event_Filter;
      User_Data : in System.Address)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_FilterEvents";

   procedure Set_Event_Enabled
     (Kind    : in Event_Type;
      Enabled : in CE.bool)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetEventEnabled";

   function Event_Enabled
     (Kind : in Event_Type) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_EventEnabled";

   function Register_Events
     (Count : in C.int) return Event_Type
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_RegisterEvents";

   function Get_Window_From_Event
     (Event : in System.Address) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetWindowFromEvent";

   function Get_Event_Description
     (Event         : in System.Address;
      Buffer        : in System.Address;
      Buffer_Length : in C.int) return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetEventDescription";
end SDL.Raw.Events;
