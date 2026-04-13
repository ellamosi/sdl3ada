with Interfaces.C;
with Interfaces.C.Extensions;

with SDL.Error;

package body SDL.Video.Rectangles is
   package CE renames Interfaces.C.Extensions;

   function SDL_Has_Rect_Intersection
     (A, B : access constant Rectangle) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_HasRectIntersection";

   function SDL_Get_Rect_Intersection
     (A, B   : access constant Rectangle;
      Result : access Rectangle) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetRectIntersection";

   function SDL_Get_Rect_Union
     (A, B   : access constant Rectangle;
      Result : access Rectangle) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetRectUnion";

   function SDL_Get_Rect_Enclosing_Points
     (Points  : in Point_Arrays;
      Count   : in C.int;
      Clip    : access constant Rectangle;
      Result  : access Rectangle) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetRectEnclosingPoints";

   function SDL_Get_Rect_And_Line_Intersection
     (Rect : access constant Rectangle;
      X1   : access C.int;
      Y1   : access C.int;
      X2   : access C.int;
      Y2   : access C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetRectAndLineIntersection";

   function SDL_Has_Rect_Intersection_Float
     (A, B : access constant Float_Rectangle) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_HasRectIntersectionFloat";

   function SDL_Get_Rect_Intersection_Float
     (A, B   : access constant Float_Rectangle;
      Result : access Float_Rectangle) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetRectIntersectionFloat";

   function SDL_Get_Rect_Union_Float
     (A, B   : access constant Float_Rectangle;
      Result : access Float_Rectangle) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetRectUnionFloat";

   function SDL_Get_Rect_Enclosing_Points_Float
     (Points  : in Float_Point_Arrays;
      Count   : in C.int;
      Clip    : access constant Float_Rectangle;
      Result  : access Float_Rectangle) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetRectEnclosingPointsFloat";

   function SDL_Get_Rect_And_Line_Intersection_Float
     (Rect : access constant Float_Rectangle;
      X1   : access Float;
      Y1   : access Float;
      X2   : access Float;
      Y2   : access Float) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetRectAndLineIntersectionFloat";

   function Has_Intersected (A, B : in Rectangle) return Boolean is
      Left  : aliased Rectangle := A;
      Right : aliased Rectangle := B;
   begin
      return Boolean (SDL_Has_Rect_Intersection (Left'Access, Right'Access));
   end Has_Intersected;

   function Intersects
     (A, B : in Rectangle;
      Intersection : out Rectangle) return Boolean
   is
      Left   : aliased Rectangle := A;
      Right  : aliased Rectangle := B;
      Result : aliased Rectangle := Null_Rectangle;
      Found  : constant Boolean :=
        Boolean
          (SDL_Get_Rect_Intersection
             (Left'Access, Right'Access, Result'Access));
   begin
      if Found then
         Intersection := Result;
      else
         Intersection := Null_Rectangle;
      end if;

      return Found;
   end Intersects;

   function Union (A, B : in Rectangle) return Rectangle is
      Left   : aliased Rectangle := A;
      Right  : aliased Rectangle := B;
      Result : aliased Rectangle := Null_Rectangle;
      Ignored : constant Boolean :=
        Boolean
          (SDL_Get_Rect_Union (Left'Access, Right'Access, Result'Access));
      pragma Unreferenced (Ignored);
   begin
      return Result;
   end Union;

   function Enclose
     (Points   : in Point_Arrays;
      Clip     : in Rectangle;
      Enclosed : out Rectangle) return Boolean
   is
      Clipped : aliased Rectangle := Clip;
      Result  : aliased Rectangle := Null_Rectangle;
      Found   : constant Boolean :=
        Boolean
          (SDL_Get_Rect_Enclosing_Points
             (Points,
              C.int (Points'Length),
              Clipped'Access,
              Result'Access));
   begin
      if Found then
         Enclosed := Result;
      else
         Enclosed := Null_Rectangle;
      end if;

      return Found;
   end Enclose;

   procedure Enclose
     (Points   : in Point_Arrays;
      Enclosed : out Rectangle)
   is
      Result : aliased Rectangle := Null_Rectangle;
   begin
      if not Boolean
          (SDL_Get_Rect_Enclosing_Points
             (Points,
              C.int (Points'Length),
              null,
              Result'Access))
      then
         raise Rectangle_Error with SDL.Error.Get;
      end if;

      Enclosed := Result;
   end Enclose;

   function Clip_To
     (Clip_Area : in Rectangle;
      Line      : in out Line_Segment) return Boolean
   is
      Area : aliased Rectangle := Clip_Area;
      X1   : aliased C.int := Line.Start.X;
      Y1   : aliased C.int := Line.Start.Y;
      X2   : aliased C.int := Line.Finish.X;
      Y2   : aliased C.int := Line.Finish.Y;
      Hit  : constant Boolean :=
        Boolean
          (SDL_Get_Rect_And_Line_Intersection
             (Area'Access, X1'Access, Y1'Access, X2'Access, Y2'Access));
   begin
      if Hit then
         Line := (Start => (X => X1, Y => Y1), Finish => (X => X2, Y => Y2));
      end if;

      return Hit;
   end Clip_To;

   function Has_Intersected (A, B : in Float_Rectangle) return Boolean is
      Left  : aliased Float_Rectangle := A;
      Right : aliased Float_Rectangle := B;
   begin
      return Boolean
        (SDL_Has_Rect_Intersection_Float (Left'Access, Right'Access));
   end Has_Intersected;

   function Intersects
     (A, B : in Float_Rectangle;
      Intersection : out Float_Rectangle) return Boolean
   is
      Left   : aliased Float_Rectangle := A;
      Right  : aliased Float_Rectangle := B;
      Result : aliased Float_Rectangle := (others => 0.0);
      Found  : constant Boolean :=
        Boolean
          (SDL_Get_Rect_Intersection_Float
             (Left'Access, Right'Access, Result'Access));
   begin
      if Found then
         Intersection := Result;
      else
         Intersection := (others => 0.0);
      end if;

      return Found;
   end Intersects;

   function Union (A, B : in Float_Rectangle) return Float_Rectangle is
      Left   : aliased Float_Rectangle := A;
      Right  : aliased Float_Rectangle := B;
      Result : aliased Float_Rectangle := (others => 0.0);
      Ignored : constant Boolean :=
        Boolean
          (SDL_Get_Rect_Union_Float
             (Left'Access, Right'Access, Result'Access));
      pragma Unreferenced (Ignored);
   begin
      return Result;
   end Union;

   function Enclose
     (Points   : in Point_Arrays;
      Clip     : in Float_Rectangle;
      Enclosed : out Float_Rectangle) return Boolean
   is
      Converted : Float_Point_Arrays (Points'Range);
      Clipped   : aliased Float_Rectangle := Clip;
      Result    : aliased Float_Rectangle := (others => 0.0);
   begin
      for Index in Points'Range loop
         Converted (Index) :=
           (X => Float (Points (Index).X),
            Y => Float (Points (Index).Y));
      end loop;

      if Boolean
          (SDL_Get_Rect_Enclosing_Points_Float
             (Converted,
              C.int (Converted'Length),
              Clipped'Access,
              Result'Access))
      then
         Enclosed := Result;
         return True;
      end if;

      Enclosed := (others => 0.0);
      return False;
   end Enclose;

   procedure Enclose
     (Points   : in Point_Arrays;
      Enclosed : out Float_Rectangle)
   is
      Converted : Float_Point_Arrays (Points'Range);
      Result    : aliased Float_Rectangle := (others => 0.0);
   begin
      for Index in Points'Range loop
         Converted (Index) :=
           (X => Float (Points (Index).X),
            Y => Float (Points (Index).Y));
      end loop;

      if not Boolean
          (SDL_Get_Rect_Enclosing_Points_Float
             (Converted,
              C.int (Converted'Length),
              null,
              Result'Access))
      then
         raise Rectangle_Error with SDL.Error.Get;
      end if;

      Enclosed := Result;
   end Enclose;

   function Clip_To
     (Clip_Area : in Float_Rectangle;
      Line      : in out Line_Segment) return Boolean
   is
      Area : aliased Float_Rectangle := Clip_Area;
      X1   : aliased Float := Float (Line.Start.X);
      Y1   : aliased Float := Float (Line.Start.Y);
      X2   : aliased Float := Float (Line.Finish.X);
      Y2   : aliased Float := Float (Line.Finish.Y);
      Hit  : constant Boolean :=
        Boolean
          (SDL_Get_Rect_And_Line_Intersection_Float
             (Area'Access, X1'Access, Y1'Access, X2'Access, Y2'Access));
   begin
      if Hit then
         Line :=
           (Start  => (X => SDL.Coordinate (Integer (X1)),
                       Y => SDL.Coordinate (Integer (Y1))),
            Finish => (X => SDL.Coordinate (Integer (X2)),
                       Y => SDL.Coordinate (Integer (Y2))));
      end if;

      return Hit;
   end Clip_To;
end SDL.Video.Rectangles;
