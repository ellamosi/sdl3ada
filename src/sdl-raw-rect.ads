with Interfaces.C;
with Interfaces.C.Extensions;
with System;

package SDL.Raw.Rect is
   pragma Preelaborate;

   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;

   function Has_Rect_Intersection
     (A, B : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_HasRectIntersection";

   function Get_Rect_Intersection
     (A, B   : in System.Address;
      Result : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetRectIntersection";

   function Get_Rect_Union
     (A, B   : in System.Address;
      Result : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetRectUnion";

   function Get_Rect_Enclosing_Points
     (Points : in System.Address;
      Count  : in C.int;
      Clip   : in System.Address;
      Result : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetRectEnclosingPoints";

   function Get_Rect_And_Line_Intersection
     (Rect : in System.Address;
      X1   : access C.int;
      Y1   : access C.int;
      X2   : access C.int;
      Y2   : access C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetRectAndLineIntersection";

   function Has_Rect_Intersection_Float
     (A, B : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_HasRectIntersectionFloat";

   function Get_Rect_Intersection_Float
     (A, B   : in System.Address;
      Result : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetRectIntersectionFloat";

   function Get_Rect_Union_Float
     (A, B   : in System.Address;
      Result : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetRectUnionFloat";

   function Get_Rect_Enclosing_Points_Float
     (Points : in System.Address;
      Count  : in C.int;
      Clip   : in System.Address;
      Result : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetRectEnclosingPointsFloat";

   function Get_Rect_And_Line_Intersection_Float
     (Rect : in System.Address;
      X1   : access Float;
      Y1   : access Float;
      X2   : access Float;
      Y2   : access Float) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetRectAndLineIntersectionFloat";
end SDL.Raw.Rect;
