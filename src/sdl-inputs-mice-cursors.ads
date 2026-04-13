with Ada.Finalization;
with Interfaces;

private with SDL.C_Pointers;
with SDL.Video.Surfaces;

package SDL.Inputs.Mice.Cursors is
   type Cursor is new Ada.Finalization.Limited_Controlled with private;

   overriding
   procedure Finalize (Self : in out Cursor);

   function Is_Null (Self : in Cursor) return Boolean with
     Inline;

   type Bitmap_Data is array (Positive range <>) of aliased Interfaces.Unsigned_8 with
     Convention => C;

   subtype Duration_Milliseconds is Interfaces.Unsigned_32;

   type Frame_Info is record
      Image    : SDL.Video.Surfaces.Surface;
      Duration : Duration_Milliseconds;
   end record;

   type Frame_Lists is array (Positive range <>) of Frame_Info;

   type System_Cursors is
     (Arrow,
      I_Beam,
      Wait,
      Cross_Hair,
      Wait_Arrow,
      Size_NWSE,
      Size_NESW,
      Size_WE,
      Size_NS,
      Size_All,
      No,
      Hand,
      Size_NW,
      Size_N,
      Size_NE,
      Size_E,
      Size_SE,
      Size_S,
      Size_SW,
      Size_W);

   procedure Create_Bitmap_Cursor
     (Self     : in out Cursor;
      Data     : in Bitmap_Data;
      Mask     : in Bitmap_Data;
      Size     : in SDL.Sizes;
      Hot_Spot : in SDL.Coordinates);

   procedure Create_Colour_Cursor
     (Self     : in out Cursor;
      Image    : in SDL.Video.Surfaces.Surface;
      Hot_Spot : in SDL.Coordinates);

   procedure Create_Animated_Cursor
     (Self     : in out Cursor;
      Frames   : in Frame_Lists;
      Hot_Spot : in SDL.Coordinates);

   procedure Create_System_Cursor
     (Self        : in out Cursor;
      Cursor_Name : in System_Cursors);

   procedure Get_Cursor (Self : in out Cursor);
   procedure Get_Default_Cursor (Self : in out Cursor);

   procedure Set_Cursor (Self : in Cursor);
private
   type Cursor is new Ada.Finalization.Limited_Controlled with record
      Internal : SDL.C_Pointers.Cursor_Pointer := null;
      Owns     : Boolean := True;
   end record;
end SDL.Inputs.Mice.Cursors;
