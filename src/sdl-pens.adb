with Ada.Unchecked_Conversion;

with SDL.Raw.Pen;

package body SDL.Pens is
   package Raw renames SDL.Raw.Pen;

   function To_Public is new Ada.Unchecked_Conversion
     (Source => Raw.Device_Types,
      Target => Device_Types);

   function Get_Device_Type (Instance : in ID) return Device_Types is
   begin
      return To_Public (Raw.Get_Pen_Device_Type (Raw.ID (Instance)));
   end Get_Device_Type;
end SDL.Pens;
