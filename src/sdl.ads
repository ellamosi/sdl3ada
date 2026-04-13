with Interfaces.C;
with System;
with SDL_Linker;

package SDL is
   pragma Pure;
   pragma Linker_Options (SDL_Linker.Options);

   package C renames Interfaces.C;

   use type C.int;

   type Init_Flags is mod 2 ** 32 with
     Convention => C;

   type Main_Thread_Callback is access procedure
     (User_Data : in System.Address)
   with Convention => C;

   Null_Init_Flags : constant Init_Flags := 16#0000_0000#;
   Enable_Audio    : constant Init_Flags := 16#0000_0010#;
   Enable_Video    : constant Init_Flags := 16#0000_0020#;
   Enable_Joystick : constant Init_Flags := 16#0000_0200#;
   Enable_Haptic   : constant Init_Flags := 16#0000_1000#;
   Enable_Gamepad  : constant Init_Flags := 16#0000_2000#;
   Enable_Events   : constant Init_Flags := 16#0000_4000#;
   Enable_Sensor   : constant Init_Flags := 16#0000_8000#;
   Enable_Camera   : constant Init_Flags := 16#0001_0000#;

   --  SDL3 removed SDL_INIT_EVERYTHING, but keeping a local aggregate flag
   --  preserves the familiar binding shape without depending on old-name APIs.
   Enable_Everything : constant Init_Flags :=
     Enable_Audio or Enable_Video or Enable_Joystick or Enable_Haptic or
     Enable_Gamepad or Enable_Events or Enable_Sensor or Enable_Camera;

   App_Metadata_Name_Property       : constant String := "SDL.app.metadata.name";
   App_Metadata_Version_Property    : constant String := "SDL.app.metadata.version";
   App_Metadata_Identifier_Property : constant String := "SDL.app.metadata.identifier";
   App_Metadata_Creator_Property    : constant String := "SDL.app.metadata.creator";
   App_Metadata_Copyright_Property  : constant String := "SDL.app.metadata.copyright";
   App_Metadata_URL_Property        : constant String := "SDL.app.metadata.url";
   App_Metadata_Type_Property       : constant String := "SDL.app.metadata.type";

   --  Coordinates are for positioning things.
   subtype Coordinate is C.int;
   subtype Natural_Coordinate is Coordinate range 0 .. Coordinate'Last;
   subtype Positive_Coordinate is Coordinate range 1 .. Coordinate'Last;

   Centre_Coordinate : constant Coordinate := 0;

   type Coordinates is record
      X : SDL.Coordinate;
      Y : SDL.Coordinate;
   end record with
     Convention => C;

   Zero_Coordinate : constant Coordinates := (others => 0);

   subtype Natural_Coordinates is Coordinates with
     Dynamic_Predicate =>
       Natural_Coordinates.X >= Natural_Coordinate'First and Natural_Coordinates.Y >= Natural_Coordinate'First;

   subtype Positive_Coordinates is Coordinates with
     Dynamic_Predicate =>
       Positive_Coordinates.X >= Positive_Coordinate'First and Positive_Coordinates.Y >= Positive_Coordinate'First;

   --  Dimensions are for sizing things.
   subtype Dimension is C.int;
   subtype Natural_Dimension is Dimension range 0 .. Dimension'Last;
   subtype Positive_Dimension is Dimension range 1 .. Dimension'Last;

   type Sizes is record
      Width  : Dimension;
      Height : Dimension;
   end record with
     Convention => C;

   Zero_Size : constant Sizes := (others => Natural_Dimension'First);

   subtype Natural_Sizes is Sizes with
     Dynamic_Predicate => Natural_Sizes.Width >= 0 and Natural_Sizes.Height >= 0;

   subtype Positive_Sizes is Sizes with
     Dynamic_Predicate => Positive_Sizes.Width >= 1 and Positive_Sizes.Height >= 1;

   function "*" (Left : in Sizes; Scale : in Positive_Dimension) return Sizes is
     (Sizes'(Width => Left.Width * Scale, Height => Left.Height * Scale));

   function "/" (Left : in Sizes; Scale : in Positive_Dimension) return Sizes is
     (Sizes'(Width => Left.Width / Scale, Height => Left.Height / Scale));

   function Initialise (Flags : in Init_Flags := Enable_Everything) return Boolean with
     Inline;

   procedure Quit with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_Quit";

   procedure Finalise renames Quit;

   function Initialise_Sub_System (Flags : in Init_Flags) return Boolean with
     Inline;

   function Set_App_Metadata
     (App_Name       : in String;
      App_Version    : in String;
      App_Identifier : in String) return Boolean;

   function Clear_App_Metadata return Boolean;

   function Set_App_Metadata_Property
     (Name  : in String;
      Value : in String) return Boolean;

   function Clear_App_Metadata_Property (Name : in String) return Boolean;

   function Get_App_Metadata_Property (Name : in String) return String;

   procedure Quit_Sub_System (Flags : in Init_Flags) with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_QuitSubSystem";

   procedure Finalise_Sub_System (Flags : in Init_Flags) renames Quit_Sub_System;

   function What_Was_Initialised return Init_Flags with
     Inline;

   function Is_Main_Thread return Boolean with
     Inline;

   function Run_On_Main_Thread
     (Callback      : in Main_Thread_Callback;
      User_Data     : in System.Address := System.Null_Address;
      Wait_Complete : in Boolean := False) return Boolean;

   function Was_Initialised return Init_Flags renames What_Was_Initialised;

   function Was_Initialised (Flags : in Init_Flags) return Boolean with
     Inline;
end SDL;
