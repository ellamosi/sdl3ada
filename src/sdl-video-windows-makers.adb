with System;

with SDL.Error;
with SDL.Properties;

package body SDL.Video.Windows.Makers is
   use type System.Address;

   SDL_PROP_WINDOW_CREATE_FLAGS_NUMBER  : constant String := "SDL.window.create.flags";
   SDL_PROP_WINDOW_CREATE_HEIGHT_NUMBER : constant String := "SDL.window.create.height";
   SDL_PROP_WINDOW_CREATE_TITLE_STRING  : constant String := "SDL.window.create.title";
   SDL_PROP_WINDOW_CREATE_WIDTH_NUMBER  : constant String := "SDL.window.create.width";
   SDL_PROP_WINDOW_CREATE_X_NUMBER      : constant String := "SDL.window.create.x";
   SDL_PROP_WINDOW_CREATE_Y_NUMBER      : constant String := "SDL.window.create.y";

   function SDL_Create_Window_With_Properties
     (Props : in SDL.Properties.Property_ID) return System.Address with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CreateWindowWithProperties";

   function SDL_Create_Popup_Window
     (Parent : in System.Address;
      X      : in SDL.Coordinate;
      Y      : in SDL.Coordinate;
      Width  : in SDL.Positive_Dimension;
      Height : in SDL.Positive_Dimension;
      Flags  : in SDL.Video.Windows.Window_Flags) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CreatePopupWindow";

   procedure Create
     (Win      : in out SDL.Video.Windows.Window;
      Title    : in String;
      Position : in SDL.Natural_Coordinates;
      Size     : in SDL.Positive_Sizes;
      Flags    : in SDL.Video.Windows.Window_Flags := SDL.Video.Windows.Windowed)
   is
      Props    : constant SDL.Properties.Property_Set := SDL.Properties.Create;
      Internal : System.Address := System.Null_Address;
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

      Internal := SDL_Create_Window_With_Properties (SDL.Properties.Get_ID (Props));

      if Internal = System.Null_Address then
         raise Window_Error with SDL.Error.Get;
      end if;

      SDL.Video.Windows.Finalize (Win);
      Win.Internal := Internal;
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
      Internal : constant System.Address :=
        SDL_Create_Window_With_Properties (SDL.Properties.Get_ID (Properties));
   begin
      if Internal = System.Null_Address then
         raise Window_Error with SDL.Error.Get;
      end if;

      SDL.Video.Windows.Finalize (Win);
      Win.Internal := Internal;
      Win.Owns := True;
   end Create;

   procedure Create_Popup
     (Win      : in out SDL.Video.Windows.Window;
      Parent   : in SDL.Video.Windows.Window;
      Position : in SDL.Coordinates;
      Size     : in SDL.Positive_Sizes;
      Flags    : in SDL.Video.Windows.Window_Flags)
   is
      Internal : constant System.Address :=
        SDL_Create_Popup_Window
          (Parent => Parent.Get_Internal,
           X      => Position.X,
           Y      => Position.Y,
           Width  => Size.Width,
           Height => Size.Height,
           Flags  => Flags);
   begin
      if Internal = System.Null_Address then
         raise Window_Error with SDL.Error.Get;
      end if;

      SDL.Video.Windows.Finalize (Win);
      Win.Internal := Internal;
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
