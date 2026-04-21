package body SDL.Pens is
   package Raw renames SDL.Raw.Pen;

   function Get_Device_Type (Instance : in ID) return Device_Types is
   begin
      return Raw.Get_Pen_Device_Type (Instance);
   end Get_Device_Type;
end SDL.Pens;
