with SDL.Properties;

package SDL.Video.Windows.Makers is
   procedure Create
     (Win      : in out SDL.Video.Windows.Window;
      Title    : in String;
      Position : in SDL.Natural_Coordinates;
      Size     : in SDL.Positive_Sizes;
      Flags    : in SDL.Video.Windows.Window_Flags := SDL.Video.Windows.Windowed);

   procedure Create
     (Win    : in out SDL.Video.Windows.Window;
      Title  : in String;
      X      : in SDL.Natural_Coordinate;
      Y      : in SDL.Natural_Coordinate;
      Width  : in SDL.Positive_Dimension;
      Height : in SDL.Positive_Dimension;
      Flags  : in SDL.Video.Windows.Window_Flags := SDL.Video.Windows.Windowed) with
     Inline;

   procedure Create
     (Win        : in out SDL.Video.Windows.Window;
      Properties : in SDL.Properties.Property_Set);

   procedure Create_Popup
     (Win      : in out SDL.Video.Windows.Window;
      Parent   : in SDL.Video.Windows.Window;
      Position : in SDL.Coordinates;
      Size     : in SDL.Positive_Sizes;
      Flags    : in SDL.Video.Windows.Window_Flags);

   procedure Create_Popup
     (Win    : in out SDL.Video.Windows.Window;
      Parent : in SDL.Video.Windows.Window;
      X      : in SDL.Coordinate;
      Y      : in SDL.Coordinate;
      Width  : in SDL.Positive_Dimension;
      Height : in SDL.Positive_Dimension;
      Flags  : in SDL.Video.Windows.Window_Flags) with
     Inline;
end SDL.Video.Windows.Makers;
