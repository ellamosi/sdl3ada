with SDL.Error;
with SDL.Raw.Rect;

package body SDL.Video.Rectangles is
   package Raw renames SDL.Raw.Rect;

   function To_Raw (Value : in Point) return Raw.Point is
     ((X => Value.X, Y => Value.Y));

   function To_Raw (Value : in Rectangle) return Raw.Rectangle is
     ((X      => Value.X,
       Y      => Value.Y,
       Width  => Raw.Dimension (Value.Width),
       Height => Raw.Dimension (Value.Height)));

   function To_Public (Value : in Raw.Rectangle) return Rectangle is
     ((X      => Value.X,
       Y      => Value.Y,
       Width  => SDL.Natural_Dimension (Value.Width),
       Height => SDL.Natural_Dimension (Value.Height)));

   function To_Raw (Value : in Float_Rectangle) return Raw.Float_Rectangle is
     ((X      => Value.X,
       Y      => Value.Y,
       Width  => Value.Width,
       Height => Value.Height));

   function To_Public
     (Value : in Raw.Float_Rectangle) return Float_Rectangle is
     ((X      => Value.X,
       Y      => Value.Y,
       Width  => Value.Width,
       Height => Value.Height));

   function Has_Intersected (A, B : in Rectangle) return Boolean is
      Left  : aliased constant Raw.Rectangle := To_Raw (A);
      Right : aliased constant Raw.Rectangle := To_Raw (B);
   begin
      return Boolean (Raw.Has_Rect_Intersection (Left'Access, Right'Access));
   end Has_Intersected;

   function Intersects
     (A, B : in Rectangle;
      Intersection : out Rectangle) return Boolean
   is
      Left   : aliased constant Raw.Rectangle := To_Raw (A);
      Right  : aliased constant Raw.Rectangle := To_Raw (B);
      Result : aliased Raw.Rectangle := Raw.Null_Rectangle;
      Found  : constant Boolean :=
        Boolean (Raw.Get_Rect_Intersection (Left'Access, Right'Access, Result'Access));
   begin
      if Found then
         Intersection := To_Public (Result);
      else
         Intersection := Null_Rectangle;
      end if;

      return Found;
   end Intersects;

   function Union (A, B : in Rectangle) return Rectangle is
      Left    : aliased constant Raw.Rectangle := To_Raw (A);
      Right   : aliased constant Raw.Rectangle := To_Raw (B);
      Result  : aliased Raw.Rectangle := Raw.Null_Rectangle;
      Ignored : constant Boolean :=
        Boolean (Raw.Get_Rect_Union (Left'Access, Right'Access, Result'Access));
      pragma Unreferenced (Ignored);
   begin
      return To_Public (Result);
   end Union;

   function Enclose
     (Points   : in Point_Arrays;
      Clip     : in Rectangle;
      Enclosed : out Rectangle) return Boolean
   is
      Converted : Raw.Point_Array (Points'Range);
      Clipped   : aliased constant Raw.Rectangle := To_Raw (Clip);
      Result    : aliased Raw.Rectangle := Raw.Null_Rectangle;
      Found     : Boolean;
   begin
      for Index in Points'Range loop
         Converted (Index) := To_Raw (Points (Index));
      end loop;

      Found :=
        Boolean
          (Raw.Get_Rect_Enclosing_Points
             ((if Converted'Length = 0 then null else Converted (Converted'First)'Access),
              C.int (Points'Length),
              Clipped'Access,
              Result'Access));
      if Found then
         Enclosed := To_Public (Result);
      else
         Enclosed := Null_Rectangle;
      end if;

      return Found;
   end Enclose;

   procedure Enclose
     (Points   : in Point_Arrays;
      Enclosed : out Rectangle)
   is
      Converted : Raw.Point_Array (Points'Range);
      Result    : aliased Raw.Rectangle := Raw.Null_Rectangle;
   begin
      for Index in Points'Range loop
         Converted (Index) := To_Raw (Points (Index));
      end loop;

      if not Boolean
          (Raw.Get_Rect_Enclosing_Points
             ((if Converted'Length = 0 then null else Converted (Converted'First)'Access),
              C.int (Points'Length),
              null,
              Result'Access))
      then
         raise Rectangle_Error with SDL.Error.Get;
      end if;

      Enclosed := To_Public (Result);
   end Enclose;

   function Clip_To
     (Clip_Area : in Rectangle;
      Line      : in out Line_Segment) return Boolean
   is
      Area : aliased constant Raw.Rectangle := To_Raw (Clip_Area);
      X1   : aliased C.int := Line.Start.X;
      Y1   : aliased C.int := Line.Start.Y;
      X2   : aliased C.int := Line.Finish.X;
      Y2   : aliased C.int := Line.Finish.Y;
      Hit  : constant Boolean :=
        Boolean
          (Raw.Get_Rect_And_Line_Intersection
             (Area'Access, X1'Access, Y1'Access, X2'Access, Y2'Access));
   begin
      if Hit then
         Line := (Start => (X => X1, Y => Y1), Finish => (X => X2, Y => Y2));
      end if;

      return Hit;
   end Clip_To;

   function Has_Intersected (A, B : in Float_Rectangle) return Boolean is
      Left  : aliased constant Raw.Float_Rectangle := To_Raw (A);
      Right : aliased constant Raw.Float_Rectangle := To_Raw (B);
   begin
      return Boolean
        (Raw.Has_Rect_Intersection_Float (Left'Access, Right'Access));
   end Has_Intersected;

   function Intersects
     (A, B : in Float_Rectangle;
      Intersection : out Float_Rectangle) return Boolean
   is
      Left   : aliased constant Raw.Float_Rectangle := To_Raw (A);
      Right  : aliased constant Raw.Float_Rectangle := To_Raw (B);
      Result : aliased Raw.Float_Rectangle := Raw.Null_Float_Rectangle;
      Found  : constant Boolean :=
        Boolean
          (Raw.Get_Rect_Intersection_Float
             (Left'Access, Right'Access, Result'Access));
   begin
      if Found then
         Intersection := To_Public (Result);
      else
         Intersection := (others => 0.0);
      end if;

      return Found;
   end Intersects;

   function Union (A, B : in Float_Rectangle) return Float_Rectangle is
      Left    : aliased constant Raw.Float_Rectangle := To_Raw (A);
      Right   : aliased constant Raw.Float_Rectangle := To_Raw (B);
      Result  : aliased Raw.Float_Rectangle := Raw.Null_Float_Rectangle;
      Ignored : constant Boolean :=
        Boolean
          (Raw.Get_Rect_Union_Float
             (Left'Access, Right'Access, Result'Access));
      pragma Unreferenced (Ignored);
   begin
      return To_Public (Result);
   end Union;

   function Enclose
     (Points   : in Point_Arrays;
      Clip     : in Float_Rectangle;
      Enclosed : out Float_Rectangle) return Boolean
   is
      Converted : Raw.Float_Point_Array (Points'Range);
      Clipped   : aliased constant Raw.Float_Rectangle := To_Raw (Clip);
      Result    : aliased Raw.Float_Rectangle := Raw.Null_Float_Rectangle;
   begin
      for Index in Points'Range loop
         Converted (Index) :=
           (X => Float (Points (Index).X), Y => Float (Points (Index).Y));
      end loop;

      if Boolean
          (Raw.Get_Rect_Enclosing_Points_Float
             ((if Converted'Length = 0 then null else Converted (Converted'First)'Access),
              C.int (Converted'Length),
              Clipped'Access,
              Result'Access))
      then
         Enclosed := To_Public (Result);
         return True;
      end if;

      Enclosed := (others => 0.0);
      return False;
   end Enclose;

   procedure Enclose
     (Points   : in Point_Arrays;
      Enclosed : out Float_Rectangle)
   is
      Converted : Raw.Float_Point_Array (Points'Range);
      Result    : aliased Raw.Float_Rectangle := Raw.Null_Float_Rectangle;
   begin
      for Index in Points'Range loop
         Converted (Index) :=
           (X => Float (Points (Index).X), Y => Float (Points (Index).Y));
      end loop;

      if not Boolean
          (Raw.Get_Rect_Enclosing_Points_Float
             ((if Converted'Length = 0 then null else Converted (Converted'First)'Access),
              C.int (Converted'Length),
              null,
              Result'Access))
      then
         raise Rectangle_Error with SDL.Error.Get;
      end if;

      Enclosed := To_Public (Result);
   end Enclose;

   function Clip_To
     (Clip_Area : in Float_Rectangle;
      Line      : in out Line_Segment) return Boolean
   is
      Area : aliased constant Raw.Float_Rectangle := To_Raw (Clip_Area);
      X1   : aliased Float := Float (Line.Start.X);
      Y1   : aliased Float := Float (Line.Start.Y);
      X2   : aliased Float := Float (Line.Finish.X);
      Y2   : aliased Float := Float (Line.Finish.Y);
      Hit  : constant Boolean :=
        Boolean
          (Raw.Get_Rect_And_Line_Intersection_Float
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
