with Ada.Unchecked_Conversion;
with Interfaces.C;
with System;

with SDL.Error;
with SDL.Raw.Mouse;

package body SDL.Inputs.Mice.Cursors is
   package C renames Interfaces.C;
   package Raw renames SDL.Raw.Mouse;

   use type SDL.C_Pointers.Cursor_Pointer;

   function To_Address is new Ada.Unchecked_Conversion
     (Source => SDL.Video.Surfaces.Internal_Surface_Pointer,
      Target => System.Address);

   procedure Raise_Last_Error
     (Default_Message : in String := "SDL cursor call failed");
   procedure Raise_Last_Error
     (Default_Message : in String := "SDL cursor call failed")
   is
      Message : constant String := SDL.Error.Get;
   begin
      if Message = "" then
         raise SDL.Inputs.Mice.Mice_Error with Default_Message;
      end if;

      raise SDL.Inputs.Mice.Mice_Error with Message;
   end Raise_Last_Error;

   function Get_Internal_Surface
     (Value : in SDL.Video.Surfaces.Surface)
      return SDL.Video.Surfaces.Internal_Surface_Pointer
   with
     Import     => True,
     Convention => Ada;

   procedure Adopt
     (Self     : in out Cursor;
      Internal : in SDL.C_Pointers.Cursor_Pointer;
      Owns     : in Boolean);
   procedure Adopt
     (Self     : in out Cursor;
      Internal : in SDL.C_Pointers.Cursor_Pointer;
      Owns     : in Boolean)
   is
   begin
      Finalize (Self);
      Self.Internal := Internal;
      Self.Owns := Owns;
   end Adopt;

   function Is_Null (Self : in Cursor) return Boolean is
     (Self.Internal = null);

   function To_Raw_System_Cursor
     (Cursor_Name : in System_Cursors) return Raw.System_Cursor is
     (case Cursor_Name is
         when Arrow      => Raw.Default,
         when I_Beam     => Raw.Text,
         when Wait       => Raw.Wait,
         when Cross_Hair => Raw.Crosshair,
         when Wait_Arrow => Raw.Progress,
         when Size_NWSE  => Raw.NWSE_Resize,
         when Size_NESW  => Raw.NESW_Resize,
         when Size_WE    => Raw.EW_Resize,
         when Size_NS    => Raw.NS_Resize,
         when Size_All   => Raw.Move,
         when No         => Raw.Not_Allowed,
         when Hand       => Raw.Pointer,
         when Size_NW    => Raw.NW_Resize,
         when Size_N     => Raw.N_Resize,
         when Size_NE    => Raw.NE_Resize,
         when Size_E     => Raw.E_Resize,
         when Size_SE    => Raw.SE_Resize,
         when Size_S     => Raw.S_Resize,
         when Size_SW    => Raw.SW_Resize,
         when Size_W     => Raw.W_Resize);

   procedure Create_Bitmap_Cursor
     (Self     : in out Cursor;
      Data     : in Bitmap_Data;
      Mask     : in Bitmap_Data;
      Size     : in SDL.Sizes;
      Hot_Spot : in SDL.Coordinates)
   is
      Bytes_Per_Row : constant Natural :=
        (if Size.Width <= 0 then 0 else Natural (Size.Width) / 8);
      Expected_Size : constant Natural := Bytes_Per_Row * Natural (Size.Height);
      Internal      : SDL.C_Pointers.Cursor_Pointer;
   begin
      if Size.Width <= 0 or else Size.Height <= 0 then
         raise SDL.Inputs.Mice.Mice_Error with "Cursor size must be positive";
      end if;

      if Size.Width mod 8 /= 0 then
         raise SDL.Inputs.Mice.Mice_Error with
           "Bitmap cursor width must be a multiple of 8";
      end if;

      if Data'Length < Expected_Size or else Mask'Length < Expected_Size then
         raise SDL.Inputs.Mice.Mice_Error with
           "Bitmap cursor data and mask must cover the full image";
      end if;

      Internal :=
        Raw.Create_Cursor
          (Bits   => Data (Data'First)'Access,
           Mask   => Mask (Mask'First)'Access,
           Width  => C.int (Size.Width),
           Height => C.int (Size.Height),
           Hot_X  => C.int (Hot_Spot.X),
           Hot_Y  => C.int (Hot_Spot.Y));

      if Internal = null then
         Raise_Last_Error ("SDL_CreateCursor failed");
      end if;

      Adopt (Self, Internal, Owns => True);
   end Create_Bitmap_Cursor;

   procedure Create_Colour_Cursor
     (Self     : in out Cursor;
      Image    : in SDL.Video.Surfaces.Surface;
      Hot_Spot : in SDL.Coordinates)
   is
      Internal : constant SDL.C_Pointers.Cursor_Pointer :=
        Raw.Create_Color_Cursor
          (To_Address (Get_Internal_Surface (Image)),
           C.int (Hot_Spot.X),
           C.int (Hot_Spot.Y));
   begin
      if Internal = null then
         Raise_Last_Error ("SDL_CreateColorCursor failed");
      end if;

      Adopt (Self, Internal, Owns => True);
   end Create_Colour_Cursor;

   procedure Create_Animated_Cursor
     (Self     : in out Cursor;
      Frames   : in Frame_Lists;
      Hot_Spot : in SDL.Coordinates)
   is
      Raw_Frames : Raw.Cursor_Frame_Array (Frames'Range);
      Internal   : SDL.C_Pointers.Cursor_Pointer;
   begin
      if Frames'Length = 0 then
         raise SDL.Inputs.Mice.Mice_Error with
           "Animated cursor creation requires at least one frame";
      end if;

      for Index in Frames'Range loop
         Raw_Frames (Index) :=
           (Surface  => To_Address (Get_Internal_Surface (Frames (Index).Image)),
            Duration => Frames (Index).Duration);
      end loop;

      Internal :=
        Raw.Create_Animated_Cursor
          (Raw_Frames (Raw_Frames'First)'Access,
           C.int (Frames'Length),
           C.int (Hot_Spot.X),
           C.int (Hot_Spot.Y));

      if Internal = null then
         Raise_Last_Error ("SDL_CreateAnimatedCursor failed");
      end if;

      Adopt (Self, Internal, Owns => True);
   end Create_Animated_Cursor;

   procedure Create_System_Cursor
     (Self        : in out Cursor;
      Cursor_Name : in System_Cursors)
   is
      Internal : constant SDL.C_Pointers.Cursor_Pointer :=
        Raw.Create_System_Cursor (To_Raw_System_Cursor (Cursor_Name));
   begin
      if Internal = null then
         Raise_Last_Error ("SDL_CreateSystemCursor failed");
      end if;

      Adopt (Self, Internal, Owns => True);
   end Create_System_Cursor;

   procedure Get_Cursor (Self : in out Cursor) is
   begin
      Adopt (Self, Raw.Get_Cursor, Owns => False);
   end Get_Cursor;

   procedure Get_Default_Cursor (Self : in out Cursor) is
   begin
      Adopt (Self, Raw.Get_Default_Cursor, Owns => False);
   end Get_Default_Cursor;

   procedure Set_Cursor (Self : in Cursor) is
   begin
      if not Boolean (Raw.Set_Cursor (Self.Internal)) then
         Raise_Last_Error ("SDL_SetCursor failed");
      end if;
   end Set_Cursor;

   overriding
   procedure Finalize (Self : in out Cursor) is
   begin
      if Self.Owns and then Self.Internal /= null then
         Raw.Destroy_Cursor (Self.Internal);
      end if;

      Self.Internal := null;
      Self.Owns := True;
   end Finalize;
end SDL.Inputs.Mice.Cursors;
