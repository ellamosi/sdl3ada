with Interfaces.C;
with Interfaces.C.Extensions;

with SDL.Error;

package body SDL.Inputs.Mice.Cursors is
   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;

   use type SDL.C_Pointers.Cursor_Pointer;

   type Internal_Frame_Info is record
      Surface  : SDL.Video.Surfaces.Internal_Surface_Pointer;
      Duration : Duration_Milliseconds;
   end record with
     Convention => C;

   type Internal_Frame_Arrays is array (Positive range <>) of aliased Internal_Frame_Info with
     Convention => C;

   subtype SDL_System_Cursor is C.int;

   SDL_SYSTEM_CURSOR_DEFAULT      : constant SDL_System_Cursor := 0;
   SDL_SYSTEM_CURSOR_TEXT         : constant SDL_System_Cursor := 1;
   SDL_SYSTEM_CURSOR_WAIT         : constant SDL_System_Cursor := 2;
   SDL_SYSTEM_CURSOR_CROSSHAIR    : constant SDL_System_Cursor := 3;
   SDL_SYSTEM_CURSOR_PROGRESS     : constant SDL_System_Cursor := 4;
   SDL_SYSTEM_CURSOR_NWSE_RESIZE  : constant SDL_System_Cursor := 5;
   SDL_SYSTEM_CURSOR_NESW_RESIZE  : constant SDL_System_Cursor := 6;
   SDL_SYSTEM_CURSOR_EW_RESIZE    : constant SDL_System_Cursor := 7;
   SDL_SYSTEM_CURSOR_NS_RESIZE    : constant SDL_System_Cursor := 8;
   SDL_SYSTEM_CURSOR_MOVE         : constant SDL_System_Cursor := 9;
   SDL_SYSTEM_CURSOR_NOT_ALLOWED  : constant SDL_System_Cursor := 10;
   SDL_SYSTEM_CURSOR_POINTER      : constant SDL_System_Cursor := 11;
   SDL_SYSTEM_CURSOR_NW_RESIZE    : constant SDL_System_Cursor := 12;
   SDL_SYSTEM_CURSOR_N_RESIZE     : constant SDL_System_Cursor := 13;
   SDL_SYSTEM_CURSOR_NE_RESIZE    : constant SDL_System_Cursor := 14;
   SDL_SYSTEM_CURSOR_E_RESIZE     : constant SDL_System_Cursor := 15;
   SDL_SYSTEM_CURSOR_SE_RESIZE    : constant SDL_System_Cursor := 16;
   SDL_SYSTEM_CURSOR_S_RESIZE     : constant SDL_System_Cursor := 17;
   SDL_SYSTEM_CURSOR_SW_RESIZE    : constant SDL_System_Cursor := 18;
   SDL_SYSTEM_CURSOR_W_RESIZE     : constant SDL_System_Cursor := 19;

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

   function To_SDL_System_Cursor
     (Cursor_Name : in System_Cursors) return SDL_System_Cursor is
     (case Cursor_Name is
         when Arrow      => SDL_SYSTEM_CURSOR_DEFAULT,
         when I_Beam     => SDL_SYSTEM_CURSOR_TEXT,
         when Wait       => SDL_SYSTEM_CURSOR_WAIT,
         when Cross_Hair => SDL_SYSTEM_CURSOR_CROSSHAIR,
         when Wait_Arrow => SDL_SYSTEM_CURSOR_PROGRESS,
         when Size_NWSE  => SDL_SYSTEM_CURSOR_NWSE_RESIZE,
         when Size_NESW  => SDL_SYSTEM_CURSOR_NESW_RESIZE,
         when Size_WE    => SDL_SYSTEM_CURSOR_EW_RESIZE,
         when Size_NS    => SDL_SYSTEM_CURSOR_NS_RESIZE,
         when Size_All   => SDL_SYSTEM_CURSOR_MOVE,
         when No         => SDL_SYSTEM_CURSOR_NOT_ALLOWED,
         when Hand       => SDL_SYSTEM_CURSOR_POINTER,
         when Size_NW    => SDL_SYSTEM_CURSOR_NW_RESIZE,
         when Size_N     => SDL_SYSTEM_CURSOR_N_RESIZE,
         when Size_NE    => SDL_SYSTEM_CURSOR_NE_RESIZE,
         when Size_E     => SDL_SYSTEM_CURSOR_E_RESIZE,
         when Size_SE    => SDL_SYSTEM_CURSOR_SE_RESIZE,
         when Size_S     => SDL_SYSTEM_CURSOR_S_RESIZE,
         when Size_SW    => SDL_SYSTEM_CURSOR_SW_RESIZE,
         when Size_W     => SDL_SYSTEM_CURSOR_W_RESIZE);

   procedure Create_Bitmap_Cursor
     (Self     : in out Cursor;
      Data     : in Bitmap_Data;
      Mask     : in Bitmap_Data;
      Size     : in SDL.Sizes;
      Hot_Spot : in SDL.Coordinates)
   is
      function SDL_Create_Cursor
        (Bits   : access constant Interfaces.Unsigned_8;
         Mask   : access constant Interfaces.Unsigned_8;
         Width  : in C.int;
         Height : in C.int;
         Hot_X  : in C.int;
         Hot_Y  : in C.int) return SDL.C_Pointers.Cursor_Pointer with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_CreateCursor";

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
        SDL_Create_Cursor
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
      function SDL_Create_Color_Cursor
        (Surface : in SDL.Video.Surfaces.Internal_Surface_Pointer;
         Hot_X   : in C.int;
         Hot_Y   : in C.int) return SDL.C_Pointers.Cursor_Pointer with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_CreateColorCursor";

      Internal : constant SDL.C_Pointers.Cursor_Pointer :=
        SDL_Create_Color_Cursor
          (Get_Internal_Surface (Image),
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
      function SDL_Create_Animated_Cursor
        (Value       : access Internal_Frame_Info;
         Frame_Count : in C.int;
         Hot_X       : in C.int;
         Hot_Y       : in C.int) return SDL.C_Pointers.Cursor_Pointer with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_CreateAnimatedCursor";

      Raw_Frames : Internal_Frame_Arrays (Frames'Range);
      Internal   : SDL.C_Pointers.Cursor_Pointer;
   begin
      if Frames'Length = 0 then
         raise SDL.Inputs.Mice.Mice_Error with
           "Animated cursor creation requires at least one frame";
      end if;

      for Index in Frames'Range loop
         Raw_Frames (Index) :=
           (Surface  => Get_Internal_Surface (Frames (Index).Image),
            Duration => Frames (Index).Duration);
      end loop;

      Internal :=
        SDL_Create_Animated_Cursor
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
      function SDL_Create_System_Cursor
        (Cursor_Name : in SDL_System_Cursor)
         return SDL.C_Pointers.Cursor_Pointer with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_CreateSystemCursor";

      Internal : constant SDL.C_Pointers.Cursor_Pointer :=
        SDL_Create_System_Cursor (To_SDL_System_Cursor (Cursor_Name));
   begin
      if Internal = null then
         Raise_Last_Error ("SDL_CreateSystemCursor failed");
      end if;

      Adopt (Self, Internal, Owns => True);
   end Create_System_Cursor;

   procedure Get_Cursor (Self : in out Cursor) is
      function SDL_Get_Cursor return SDL.C_Pointers.Cursor_Pointer with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetCursor";
   begin
      Adopt (Self, SDL_Get_Cursor, Owns => False);
   end Get_Cursor;

   procedure Get_Default_Cursor (Self : in out Cursor) is
      function SDL_Get_Default_Cursor return SDL.C_Pointers.Cursor_Pointer with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetDefaultCursor";
   begin
      Adopt (Self, SDL_Get_Default_Cursor, Owns => False);
   end Get_Default_Cursor;

   procedure Set_Cursor (Self : in Cursor) is
      function SDL_Set_Cursor
        (Value : in SDL.C_Pointers.Cursor_Pointer) return CE.bool with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_SetCursor";
   begin
      if not Boolean (SDL_Set_Cursor (Self.Internal)) then
         Raise_Last_Error ("SDL_SetCursor failed");
      end if;
   end Set_Cursor;

   overriding
   procedure Finalize (Self : in out Cursor) is
      procedure SDL_Destroy_Cursor
        (Value : in SDL.C_Pointers.Cursor_Pointer) with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_DestroyCursor";
   begin
      if Self.Owns and then Self.Internal /= null then
         SDL_Destroy_Cursor (Self.Internal);
      end if;

      Self.Internal := null;
      Self.Owns := True;
   end Finalize;
end SDL.Inputs.Mice.Cursors;
