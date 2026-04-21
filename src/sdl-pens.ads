with Interfaces.C;

with SDL.Raw.Pen;

package SDL.Pens is
   package C renames Interfaces.C;

   use type SDL.Raw.Pen.Input_Flags;

   subtype ID is SDL.Raw.Pen.ID;

   subtype Input_Flags is SDL.Raw.Pen.Input_Flags;

   Input_Down         : constant Input_Flags := SDL.Raw.Pen.Input_Down;
   Input_Button_1     : constant Input_Flags := SDL.Raw.Pen.Input_Button_1;
   Input_Button_2     : constant Input_Flags := SDL.Raw.Pen.Input_Button_2;
   Input_Button_3     : constant Input_Flags := SDL.Raw.Pen.Input_Button_3;
   Input_Button_4     : constant Input_Flags := SDL.Raw.Pen.Input_Button_4;
   Input_Button_5     : constant Input_Flags := SDL.Raw.Pen.Input_Button_5;
   Input_Eraser_Tip   : constant Input_Flags := SDL.Raw.Pen.Input_Eraser_Tip;
   Input_In_Proximity : constant Input_Flags := SDL.Raw.Pen.Input_In_Proximity;

   subtype Axes is SDL.Raw.Pen.Axes;

   Pressure            : constant Axes := SDL.Raw.Pen.Pressure;
   X_Tilt              : constant Axes := SDL.Raw.Pen.X_Tilt;
   Y_Tilt              : constant Axes := SDL.Raw.Pen.Y_Tilt;
   Distance            : constant Axes := SDL.Raw.Pen.Distance;
   Rotation            : constant Axes := SDL.Raw.Pen.Rotation;
   Slider              : constant Axes := SDL.Raw.Pen.Slider;
   Tangential_Pressure : constant Axes := SDL.Raw.Pen.Tangential_Pressure;
   Count               : constant Axes := SDL.Raw.Pen.Count;

   subtype Device_Types is SDL.Raw.Pen.Device_Types;

   Invalid  : constant Device_Types := SDL.Raw.Pen.Invalid;
   Unknown  : constant Device_Types := SDL.Raw.Pen.Unknown;
   Direct   : constant Device_Types := SDL.Raw.Pen.Direct;
   Indirect : constant Device_Types := SDL.Raw.Pen.Indirect;

   function Has_Flag
     (State : in Input_Flags;
      Flag  : in Input_Flags) return Boolean is
       ((State and Flag) = Flag)
   with
     Inline;

   function Get_Device_Type (Instance : in ID) return Device_Types
   with Inline;
end SDL.Pens;
