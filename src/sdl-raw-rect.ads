with Interfaces.C;
with Interfaces.C.Extensions;

package SDL.Raw.Rect is
   pragma Preelaborate;

   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;

   subtype Coordinate is C.int;
   subtype Dimension is C.int;

   type Point is record
      X : Coordinate;
      Y : Coordinate;
   end record
   with Convention => C;

   type Point_Array is array (C.size_t range <>) of aliased Point with
     Convention => C;

   type Rectangle is record
      X      : Coordinate;
      Y      : Coordinate;
      Width  : Dimension;
      Height : Dimension;
   end record
   with Convention => C;

   Null_Rectangle : constant Rectangle := (others => 0);

   type Float_Point is record
      X : Float;
      Y : Float;
   end record
   with Convention => C;

   type Float_Point_Array is array (C.size_t range <>) of aliased Float_Point with
     Convention => C;

   type Float_Rectangle is record
      X      : Float;
      Y      : Float;
      Width  : Float;
      Height : Float;
   end record
   with Convention => C;

   Null_Float_Rectangle : constant Float_Rectangle := (others => 0.0);

   function Has_Rect_Intersection
     (A, B : access constant Rectangle) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_HasRectIntersection";

   function Get_Rect_Intersection
     (A, B   : access constant Rectangle;
      Result : access Rectangle) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetRectIntersection";

   function Get_Rect_Union
     (A, B   : access constant Rectangle;
      Result : access Rectangle) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetRectUnion";

   function Get_Rect_Enclosing_Points
     (Points : access constant Point;
      Count  : in C.int;
      Clip   : access constant Rectangle;
      Result : access Rectangle) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetRectEnclosingPoints";

   function Get_Rect_And_Line_Intersection
     (Rect : access constant Rectangle;
      X1   : access C.int;
      Y1   : access C.int;
      X2   : access C.int;
      Y2   : access C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetRectAndLineIntersection";

   function Has_Rect_Intersection_Float
     (A, B : access constant Float_Rectangle) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_HasRectIntersectionFloat";

   function Get_Rect_Intersection_Float
     (A, B   : access constant Float_Rectangle;
      Result : access Float_Rectangle) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetRectIntersectionFloat";

   function Get_Rect_Union_Float
     (A, B   : access constant Float_Rectangle;
      Result : access Float_Rectangle) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetRectUnionFloat";

   function Get_Rect_Enclosing_Points_Float
     (Points : access constant Float_Point;
      Count  : in C.int;
      Clip   : access constant Float_Rectangle;
      Result : access Float_Rectangle) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetRectEnclosingPointsFloat";

   function Get_Rect_And_Line_Intersection_Float
     (Rect : access constant Float_Rectangle;
      X1   : access Float;
      Y1   : access Float;
      X2   : access Float;
      Y2   : access Float) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetRectAndLineIntersectionFloat";
end SDL.Raw.Rect;
