with Ada.Unchecked_Conversion;
with System;

with SDL.Error;
with SDL.Raw.Video;

package body SDL.Video.Windows.Makers is
   package Raw renames SDL.Raw.Video;

   use type System.Address;
   use type Raw.Window_Pointer;

   function To_Address is new Ada.Unchecked_Conversion
     (Source => Raw.Window_Pointer,
      Target => System.Address);

   function To_Window_Pointer is new Ada.Unchecked_Conversion
     (Source => System.Address,
      Target => Raw.Window_Pointer);

   SDL_PROP_WINDOW_CREATE_FLAGS_NUMBER  : constant String := "SDL.window.create.flags";
   SDL_PROP_WINDOW_CREATE_HEIGHT_NUMBER : constant String := "SDL.window.create.height";
   SDL_PROP_WINDOW_CREATE_TITLE_STRING  : constant String := "SDL.window.create.title";
   SDL_PROP_WINDOW_CREATE_WIDTH_NUMBER  : constant String := "SDL.window.create.width";
   SDL_PROP_WINDOW_CREATE_X_NUMBER      : constant String := "SDL.window.create.x";
   SDL_PROP_WINDOW_CREATE_Y_NUMBER      : constant String := "SDL.window.create.y";

   procedure Create
     (Win      : in out SDL.Video.Windows.Window;
      Title    : in String;
      Position : in SDL.Natural_Coordinates;
      Size     : in SDL.Positive_Sizes;
      Flags    : in SDL.Video.Windows.Window_Flags := SDL.Video.Windows.Windowed)
   is
      Props    : constant SDL.Properties.Property_Set := SDL.Properties.Create;
      Internal : Raw.Window_Pointer := null;
   begin
      SDL.Properties.Set_String
        (Props, SDL_PROP_WINDOW_CREATE_TITLE_STRING, Title);
      SDL.Properties.Set_Number
        (Props,
         SDL_PROP_WINDOW_CREATE_X_NUMBER,
         SDL.Properties.Property_Numbers (Position.X));
      SDL.Properties.Set_Number
        (Props,
         SDL_PROP_WINDOW_CREATE_Y_NUMBER,
         SDL.Properties.Property_Numbers (Position.Y));
      SDL.Properties.Set_Number
        (Props,
         SDL_PROP_WINDOW_CREATE_WIDTH_NUMBER,
         SDL.Properties.Property_Numbers (Size.Width));
      SDL.Properties.Set_Number
        (Props,
         SDL_PROP_WINDOW_CREATE_HEIGHT_NUMBER,
         SDL.Properties.Property_Numbers (Size.Height));
      SDL.Properties.Set_Number
        (Props,
         SDL_PROP_WINDOW_CREATE_FLAGS_NUMBER,
         SDL.Properties.Property_Numbers (Flags));

      Internal :=
        Raw.Create_Window_With_Properties (SDL.Properties.Get_ID (Props));

      if Internal = null then
         raise Window_Error with SDL.Error.Get;
      end if;

      SDL.Video.Windows.Finalize (Win);
      Win.Internal := To_Address (Internal);
      Win.Owns := True;
   end Create;

   procedure Create
     (Win    : in out SDL.Video.Windows.Window;
      Title  : in String;
      X      : in SDL.Natural_Coordinate;
      Y      : in SDL.Natural_Coordinate;
      Width  : in SDL.Positive_Dimension;
      Height : in SDL.Positive_Dimension;
      Flags  : in SDL.Video.Windows.Window_Flags := SDL.Video.Windows.Windowed)
   is
   begin
      Create
        (Win      => Win,
         Title    => Title,
         Position => (X => X, Y => Y),
         Size     => (Width => Width, Height => Height),
         Flags    => Flags);
   end Create;

   procedure Create
     (Win        : in out SDL.Video.Windows.Window;
      Properties : in SDL.Properties.Property_Set)
   is
      Internal : constant Raw.Window_Pointer :=
        Raw.Create_Window_With_Properties (SDL.Properties.Get_ID (Properties));
   begin
      if Internal = null then
         raise Window_Error with SDL.Error.Get;
      end if;

      SDL.Video.Windows.Finalize (Win);
      Win.Internal := To_Address (Internal);
      Win.Owns := True;
   end Create;

   procedure Create_Popup
     (Win      : in out SDL.Video.Windows.Window;
      Parent   : in SDL.Video.Windows.Window;
      Position : in SDL.Coordinates;
      Size     : in SDL.Positive_Sizes;
      Flags    : in SDL.Video.Windows.Window_Flags)
   is
      Internal : constant Raw.Window_Pointer :=
        Raw.Create_Popup_Window
          (Parent => To_Window_Pointer (Parent.Get_Internal),
           X      => Position.X,
           Y      => Position.Y,
           Width  => Size.Width,
           Height => Size.Height,
           Flags  => Raw.Window_Flags (Flags));
   begin
      if Internal = null then
         raise Window_Error with SDL.Error.Get;
      end if;

      SDL.Video.Windows.Finalize (Win);
      Win.Internal := To_Address (Internal);
      Win.Owns := True;
   end Create_Popup;

   procedure Create_Popup
     (Win    : in out SDL.Video.Windows.Window;
      Parent : in SDL.Video.Windows.Window;
      X      : in SDL.Coordinate;
      Y      : in SDL.Coordinate;
      Width  : in SDL.Positive_Dimension;
      Height : in SDL.Positive_Dimension;
      Flags  : in SDL.Video.Windows.Window_Flags)
   is
   begin
      Create_Popup
        (Win      => Win,
         Parent   => Parent,
         Position => (X => X, Y => Y),
         Size     => (Width => Width, Height => Height),
         Flags    => Flags);
   end Create_Popup;
end SDL.Video.Windows.Makers;
