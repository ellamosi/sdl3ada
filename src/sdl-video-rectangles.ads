with Interfaces.C;

package SDL.Video.Rectangles is
   pragma Preelaborate;
   pragma Elaborate_Body;

   package C renames Interfaces.C;

   Rectangle_Error : exception;

   type Size_Arrays is array (C.size_t range <>) of aliased SDL.Sizes with
     Convention => C;

   subtype Point is SDL.Coordinates;

   type Point_Arrays is array (C.size_t range <>) of aliased Point with
     Convention => C;

   type Float_Point is
      record
         X : Float;
         Y : Float;
      end record with
     Convention => C;

   type Float_Point_Arrays is array (C.size_t range <>) of aliased Float_Point with
     Convention => C;

   type Line_Segment is
      record
         Start  : SDL.Coordinates;
         Finish : SDL.Coordinates;
      end record with
     Convention => C;

   type Line_Arrays is array (C.size_t range <>) of aliased Line_Segment with
     Convention => C;

   type Float_Line_Segment is
      record
         Start  : Float_Point;
         Finish : Float_Point;
      end record with
     Convention => C;

   type Float_Line_Arrays is array (C.size_t range <>) of aliased Float_Line_Segment with
     Convention => C;

   type Rectangle is
      record
         X      : SDL.Coordinate;
         Y      : SDL.Coordinate;
         Width  : SDL.Natural_Dimension;
         Height : SDL.Natural_Dimension;
      end record with
     Convention => C;

   Null_Rectangle : constant Rectangle := (others => 0);

   type Rectangle_Arrays is array (C.size_t range <>) of aliased Rectangle with
     Convention => C;

   type Rectangle_Access is access all Rectangle with
     Convention => C;

   type Float_Rectangle is
      record
         X      : Float;
         Y      : Float;
         Width  : Float;
         Height : Float;
      end record with
     Convention => C;

   type Float_Rectangle_Arrays is array (C.size_t range <>) of aliased Float_Rectangle with
     Convention => C;

   type Float_Rectangle_Access is access all Float_Rectangle with
     Convention => C;

   function Inside (P : Point; R : Rectangle) return Boolean is
     (P.X >= R.X and P.X < R.X + R.Width and
      P.Y >= R.Y and P.Y < R.Y + R.Height);

   function Is_Empty (R : Rectangle) return Boolean is
     (R.Width = SDL.Natural_Dimension'First or
      R.Height = SDL.Natural_Dimension'First);

   function Has_Intersected (A, B : in Rectangle) return Boolean;

   function Intersects
     (A, B : in Rectangle;
      Intersection : out Rectangle) return Boolean;

   function Union (A, B : in Rectangle) return Rectangle;

   function Enclose
     (Points   : in Point_Arrays;
      Clip     : in Rectangle;
      Enclosed : out Rectangle) return Boolean;

   procedure Enclose
     (Points   : in Point_Arrays;
      Enclosed : out Rectangle);

   function Clip_To
     (Clip_Area : in Rectangle;
      Line      : in out Line_Segment) return Boolean;

   function Intersects
     (Clip_Area : in Rectangle;
      Line      : in out Line_Segment) return Boolean renames Clip_To;

   function Inside (P : Float_Point; R : Float_Rectangle) return Boolean is
     (P.X >= R.X and P.X < R.X + R.Width and
      P.Y >= R.Y and P.Y < R.Y + R.Height);

   function Is_Empty (R : Float_Rectangle) return Boolean is
     (R.Width <= 0.0 or R.Height <= 0.0);

   function Absolute (Value : Float) return Float is
     (if Value < 0.0 then -Value else Value);

   function Equals
     (Left, Right : Float_Rectangle;
      Epsilon     : Float := Float'Model_Epsilon) return Boolean is
       ((Left = Right) or
        ((Absolute (Left.X - Right.X) <= Epsilon) and
         (Absolute (Left.Y - Right.Y) <= Epsilon) and
         (Absolute (Left.Width - Right.Width) <= Epsilon) and
         (Absolute (Left.Height - Right.Height) <= Epsilon)));

   overriding
   function "=" (Left, Right : Float_Rectangle) return Boolean is
     (Equals (Left, Right, Float'Model_Epsilon));

   function Has_Intersected (A, B : in Float_Rectangle) return Boolean;

   function Intersects
     (A, B : in Float_Rectangle;
      Intersection : out Float_Rectangle) return Boolean;

   function Union (A, B : in Float_Rectangle) return Float_Rectangle;

   function Enclose
     (Points   : in Point_Arrays;
      Clip     : in Float_Rectangle;
      Enclosed : out Float_Rectangle) return Boolean;

   procedure Enclose
     (Points   : in Point_Arrays;
      Enclosed : out Float_Rectangle);

   function Clip_To
     (Clip_Area : in Float_Rectangle;
      Line      : in out Line_Segment) return Boolean;

   function Intersects
     (Clip_Area : in Float_Rectangle;
      Line      : in out Line_Segment) return Boolean renames Clip_To;
end SDL.Video.Rectangles;
