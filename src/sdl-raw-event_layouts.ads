with Interfaces;
with System;

with SDL.Raw.Event_Types;
with SDL.Raw.Video_Types;

package SDL.Raw.Event_Layouts is
   pragma Pure;

   subtype Event_Code is Interfaces.Integer_32;

   type Common_Event is record
      Event_Type : SDL.Raw.Event_Types.Event_Type;
      Reserved   : Interfaces.Unsigned_32;
      Time_Stamp : Interfaces.Unsigned_64;
   end record with
     Convention => C;

   type User_Event is record
      Event_Type : SDL.Raw.Event_Types.Event_Type;
      Reserved   : Interfaces.Unsigned_32;
      Time_Stamp : Interfaces.Unsigned_64;
      Window_ID  : SDL.Raw.Video_Types.Window_ID;
      Code       : Event_Code;
      Data_1     : System.Address;
      Data_2     : System.Address;
   end record with
     Convention => C;
end SDL.Raw.Event_Layouts;
