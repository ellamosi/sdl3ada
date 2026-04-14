with Ada.Command_Line;
with Ada.Exceptions;
with Ada.Strings.Unbounded;
with Ada.Unchecked_Conversion;
with Ada.Unchecked_Deallocation;

with Interfaces;
with Interfaces.C;
with Interfaces.C.Strings;
with System;

with SDL;
with SDL.Audio;
with SDL.Audio.Sample_Formats;
with SDL.Audio.Streams;
with SDL.Error;
with SDL.Events;
with SDL.Events.Queue;
with SDL.Events.Files;
with SDL.Events.Keyboards;
with SDL.Log;
with SDL.Main;
with SDL.RWops;
with SDL.Timers;
with SDL.Video.Displays;
with SDL.Video.Palettes;
with SDL.Video.Pixel_Formats;
with SDL.Video.Pixels;
with SDL.Video.Rectangles;
with SDL.Video.Renderers;
with SDL.Video.Renderers.Makers;
with SDL.Video.Textures;
with SDL.Video.Textures.Makers;
with SDL.Video.Windows;

package body Bytepusher_App is
   package ASU renames Ada.Strings.Unbounded;
   package C renames Interfaces.C;
   package CS renames Interfaces.C.Strings;

   use type CS.chars_ptr;
   use type Interfaces.Unsigned_8;
   use type Interfaces.Unsigned_16;
   use type C.int;
   use type SDL.Audio.Spec;
   use type SDL.Events.Event_Types;
   use type SDL.Events.Keyboards.Key_Codes;
   use type SDL.Events.Keyboards.Scan_Codes;
   use type SDL.Init_Flags;
   use type SDL.Main.App_Results;
   use type SDL.RWops.IO_Status;
   use type SDL.Timers.Nanoseconds;
   use type SDL.Video.Palettes.Palette_Access;
   use type System.Address;

   Screen_Width  : constant Natural := 256;
   Screen_Height : constant Natural := 256;
   Screen_Pixels : constant Natural := Screen_Width * Screen_Height;
   RAM_Size      : constant Natural := 16#1000000#;

   Frames_Per_Second        : constant Positive := 60;
   Samples_Per_Frame        : constant Positive := 256;
   Max_Audio_Latency_Frames : constant Positive := 5;
   NS_Per_Second            : constant SDL.Timers.Nanoseconds := 1_000_000_000;
   Status_Ticks_Max         : constant Natural := Frames_Per_Second * 3;

   IO_Keyboard    : constant Natural := 0;
   IO_PC          : constant Natural := 2;
   IO_Screen_Page : constant Natural := 5;
   IO_Audio_Bank  : constant Natural := 6;

   type Byte is new Interfaces.Unsigned_8;
   subtype Keyboard_Mask is Interfaces.Unsigned_16;

   type RAM_Image is array (Natural range 0 .. RAM_Size + 7) of aliased Byte with
     Convention => C;

   type Symbolic_Mapping is record
      Key  : SDL.Events.Keyboards.Key_Codes := 0;
      Mask : Keyboard_Mask := 0;
   end record;

   type Symbolic_Mappings is array (Positive range <>) of Symbolic_Mapping;

   type Positional_Mapping is record
      Scan : SDL.Events.Keyboards.Scan_Codes := SDL.Events.Keyboards.Scan_Code_Unknown;
      Mask : Keyboard_Mask := 0;
   end record;

   type Positional_Mappings is array (Positive range <>) of Positional_Mapping;

   type State is record
      RAM              : RAM_Image := (others => 0);
      Last_Tick        : SDL.Timers.Nanoseconds := 0;
      Tick_Accumulator : SDL.Timers.Nanoseconds := 0;
      Window           : SDL.Video.Windows.Window;
      Renderer         : SDL.Video.Renderers.Renderer;
      Palette          : SDL.Video.Palettes.Palette_Access := null;
      Texture          : SDL.Video.Textures.Texture;
      Render_Target    : SDL.Video.Textures.Texture;
      Audio_Stream     : SDL.Audio.Streams.Stream;
      Status_Text      : ASU.Unbounded_String := ASU.Null_Unbounded_String;
      Status_Ticks     : Natural := 0;
      Key_State        : Keyboard_Mask := 0;
      Display_Help     : Boolean := True;
      Positional_Input : Boolean := False;
      Escape_Key       : SDL.Events.Keyboards.Key_Codes := 0;
      Return_Key       : SDL.Events.Keyboards.Key_Codes := 0;
      Symbolic_Keys    : Symbolic_Mappings (1 .. 16);
      Positional_Keys  : Positional_Mappings (1 .. 16);
      SDL_Initialized  : Boolean := False;
   end record;

   type State_Access is access all State;
   type Argument_Vector_Access is access CS.chars_ptr_array;

   procedure Free_State is new Ada.Unchecked_Deallocation (State, State_Access);
   procedure Free_Palette is new Ada.Unchecked_Deallocation
     (SDL.Video.Palettes.Palette, SDL.Video.Palettes.Palette_Access);
   procedure Free_Argument_Vector is new Ada.Unchecked_Deallocation
     (CS.chars_ptr_array, Argument_Vector_Access);

   function To_State is new Ada.Unchecked_Conversion (System.Address, State_Access);
   function To_Address is new Ada.Unchecked_Conversion (State_Access, System.Address);

   Requested_Spec : constant SDL.Audio.Spec :=
     (Format    => SDL.Audio.Sample_Formats.Sample_Format_S8,
      Channels  => 1,
      Frequency =>
        SDL.Audio.Sample_Rate (Samples_Per_Frame * Frames_Per_Second));

   function Bit (Index : in Natural) return Keyboard_Mask is
     (Interfaces.Shift_Left (Keyboard_Mask (1), Index));

   procedure Require_SDL (Condition : in Boolean; Message : in String);
   procedure Set_Status (VM : in out State; Message : in String);
   procedure Initialise_Key_Mappings (VM : in out State);
   function Build_Palette return SDL.Video.Palettes.Palette_Access;
   function Load_File (VM : in out State; Path : in String) return Boolean;
   procedure Load_Path (VM : in out State; Path : in String);
   procedure Execute_VM_Frame (VM : in out State; Updated : out Boolean);
   procedure Update_Render_Target (VM : in out State);
   procedure Render_Frame (VM : in out State; Updated : in Boolean);
   procedure Cleanup (VM : in out State);

   function App_Init
     (App_State : access System.Address;
      ArgC      : in C.int;
      ArgV      : access CS.chars_ptr_array) return SDL.Main.App_Results
   with Convention => C;

   function App_Iterate
     (App_State : in System.Address) return SDL.Main.App_Results
   with Convention => C;

   function App_Event
     (App_State : in System.Address;
      Event     : access SDL.Events.Queue.Event) return SDL.Main.App_Results
   with Convention => C;

   procedure App_Quit
     (App_State : in System.Address;
      Result    : in SDL.Main.App_Results)
   with Convention => C;

   procedure Require_SDL (Condition : in Boolean; Message : in String) is
   begin
      if not Condition then
         raise Program_Error with Message & ": " & SDL.Error.Get;
      end if;
   end Require_SDL;

   function Filename (Path : in String) return String is
   begin
      for Index in reverse Path'Range loop
         if Path (Index) = '/' or else Path (Index) = '\' then
            return Path (Index + 1 .. Path'Last);
         end if;
      end loop;

      return Path;
   end Filename;

   function Read_U16
     (RAM     : in RAM_Image;
      Address : in Natural) return Natural is
     (Natural (RAM (Address)) * 16#100#
      + Natural (RAM (Address + 1)));

   function Read_U24
     (RAM     : in RAM_Image;
      Address : in Natural) return Natural is
     (Natural (RAM (Address)) * 16#1_0000#
      + Natural (RAM (Address + 1)) * 16#100#
      + Natural (RAM (Address + 2)));

   procedure Print
     (Renderer : in out SDL.Video.Renderers.Renderer;
      X        : in Float;
      Y        : in Float;
      Text     : in String);
   procedure Print
     (Renderer : in out SDL.Video.Renderers.Renderer;
      X        : in Float;
      Y        : in Float;
      Text     : in String)
   is
   begin
      SDL.Video.Renderers.Set_Draw_Colour (Renderer, 0.0, 0.0, 0.0, 1.0);
      SDL.Video.Renderers.Debug_Text (Renderer, (X => X + 1.0, Y => Y + 1.0), Text);
      SDL.Video.Renderers.Set_Draw_Colour (Renderer, 1.0, 1.0, 1.0, 1.0);
      SDL.Video.Renderers.Debug_Text (Renderer, (X => X, Y => Y), Text);
      SDL.Video.Renderers.Set_Draw_Colour (Renderer, 0.0, 0.0, 0.0, 1.0);
   end Print;

   function Calculate_Initial_Zoom return Positive is
      Bounds : SDL.Video.Rectangles.Rectangle;
      Zoom   : Positive := 2;
   begin
      if SDL.Video.Displays.Get_Usable_Bounds (SDL.Video.Displays.Primary, Bounds) then
         declare
            Width_Zoom  : constant Integer :=
              Integer (Bounds.Width) * 2 / 3 / Integer (Screen_Width);
            Height_Zoom : constant Integer :=
              Integer (Bounds.Height) * 2 / 3 / Integer (Screen_Height);
            Candidate   : constant Integer := Integer'Min (Width_Zoom, Height_Zoom);
         begin
            if Candidate > 0 then
               Zoom := Positive (Candidate);
            else
               Zoom := 1;
            end if;
         end;
      end if;

      return Zoom;
   end Calculate_Initial_Zoom;

   procedure Set_Status (VM : in out State; Message : in String) is
   begin
      VM.Status_Text := ASU.To_Unbounded_String (Message);
      VM.Status_Ticks := Status_Ticks_Max;
   end Set_Status;

   procedure Initialise_Key_Mappings (VM : in out State) is
   begin
      VM.Escape_Key := SDL.Events.Keyboards.Value ("Escape");
      VM.Return_Key := SDL.Events.Keyboards.Value ("Return");

      VM.Symbolic_Keys :=
        ((Key => SDL.Events.Keyboards.Value ("0"), Mask => Bit (0)),
         (Key => SDL.Events.Keyboards.Value ("1"), Mask => Bit (1)),
         (Key => SDL.Events.Keyboards.Value ("2"), Mask => Bit (2)),
         (Key => SDL.Events.Keyboards.Value ("3"), Mask => Bit (3)),
         (Key => SDL.Events.Keyboards.Value ("4"), Mask => Bit (4)),
         (Key => SDL.Events.Keyboards.Value ("5"), Mask => Bit (5)),
         (Key => SDL.Events.Keyboards.Value ("6"), Mask => Bit (6)),
         (Key => SDL.Events.Keyboards.Value ("7"), Mask => Bit (7)),
         (Key => SDL.Events.Keyboards.Value ("8"), Mask => Bit (8)),
         (Key => SDL.Events.Keyboards.Value ("9"), Mask => Bit (9)),
         (Key => SDL.Events.Keyboards.Value ("A"), Mask => Bit (10)),
         (Key => SDL.Events.Keyboards.Value ("B"), Mask => Bit (11)),
         (Key => SDL.Events.Keyboards.Value ("C"), Mask => Bit (12)),
         (Key => SDL.Events.Keyboards.Value ("D"), Mask => Bit (13)),
         (Key => SDL.Events.Keyboards.Value ("E"), Mask => Bit (14)),
         (Key => SDL.Events.Keyboards.Value ("F"), Mask => Bit (15)));

      VM.Positional_Keys :=
        ((Scan => SDL.Events.Keyboards.Value ("1"), Mask => Bit (1)),
         (Scan => SDL.Events.Keyboards.Value ("2"), Mask => Bit (2)),
         (Scan => SDL.Events.Keyboards.Value ("3"), Mask => Bit (3)),
         (Scan => SDL.Events.Keyboards.Value ("4"), Mask => Bit (12)),
         (Scan => SDL.Events.Keyboards.Value ("Q"), Mask => Bit (4)),
         (Scan => SDL.Events.Keyboards.Value ("W"), Mask => Bit (5)),
         (Scan => SDL.Events.Keyboards.Value ("E"), Mask => Bit (6)),
         (Scan => SDL.Events.Keyboards.Value ("R"), Mask => Bit (13)),
         (Scan => SDL.Events.Keyboards.Value ("A"), Mask => Bit (7)),
         (Scan => SDL.Events.Keyboards.Value ("S"), Mask => Bit (8)),
         (Scan => SDL.Events.Keyboards.Value ("D"), Mask => Bit (9)),
         (Scan => SDL.Events.Keyboards.Value ("F"), Mask => Bit (14)),
         (Scan => SDL.Events.Keyboards.Value ("Z"), Mask => Bit (10)),
         (Scan => SDL.Events.Keyboards.Value ("X"), Mask => Bit (0)),
         (Scan => SDL.Events.Keyboards.Value ("C"), Mask => Bit (11)),
         (Scan => SDL.Events.Keyboards.Value ("V"), Mask => Bit (15)));
   end Initialise_Key_Mappings;

   function Keycode_Mask
     (VM  : in State;
      Key : in SDL.Events.Keyboards.Key_Codes) return Keyboard_Mask
   is
   begin
      for Mapping of VM.Symbolic_Keys loop
         if Key = Mapping.Key then
            return Mapping.Mask;
         end if;
      end loop;

      return 0;
   end Keycode_Mask;

   function Scancode_Mask
     (VM   : in State;
      Scan : in SDL.Events.Keyboards.Scan_Codes) return Keyboard_Mask
   is
   begin
      for Mapping of VM.Positional_Keys loop
         if Scan = Mapping.Scan then
            return Mapping.Mask;
         end if;
      end loop;

      return 0;
   end Scancode_Mask;

   function Build_Palette return SDL.Video.Palettes.Palette_Access is
      Colours : SDL.Video.Palettes.Colour_Arrays (0 .. 255);
      Result  : SDL.Video.Palettes.Palette_Access :=
        new SDL.Video.Palettes.Palette'(SDL.Video.Palettes.Create (256));
      Index   : Natural := 0;
   begin
      for Red in 0 .. 5 loop
         for Green in 0 .. 5 loop
            for Blue in 0 .. 5 loop
               Colours (C.size_t (Index)) :=
                 (Red   => Interfaces.Unsigned_8 (Red * 16#33#),
                  Green => Interfaces.Unsigned_8 (Green * 16#33#),
                  Blue  => Interfaces.Unsigned_8 (Blue * 16#33#),
                  Alpha => 16#FF#);
               Index := Index + 1;
            end loop;
         end loop;
      end loop;

      for Remaining in Index .. 255 loop
         Colours (C.size_t (Remaining)) :=
           (Red => 0, Green => 0, Blue => 0, Alpha => 16#FF#);
      end loop;

      SDL.Video.Palettes.Set_Colours (Result.all, Colours);
      return Result;
   exception
      when others =>
         if Result /= null then
            SDL.Video.Palettes.Free (Result.all);
            Free_Palette (Result);
         end if;

         raise;
   end Build_Palette;

   function Load_File (VM : in out State; Path : in String) return Boolean is
      Source     : SDL.RWops.RWops;
      Bytes_Read : Natural := 0;
      OK         : Boolean := True;
   begin
      VM.RAM := (others => 0);

      SDL.RWops.From_File (Path, SDL.RWops.Read_Binary, Source);
      if SDL.RWops.Is_Null (Source) then
         return False;
      end if;

      while Bytes_Read < RAM_Size loop
         declare
            Count : constant Natural :=
              SDL.RWops.Read (Source, VM.RAM (Bytes_Read)'Address, RAM_Size - Bytes_Read);
         begin
            Bytes_Read := Bytes_Read + Count;

            if Count = 0 then
               OK := SDL.RWops.Status (Source) = SDL.RWops.End_Of_File;
               exit;
            end if;
         end;
      end loop;

      SDL.RWops.Close (Source);
      SDL.Audio.Streams.Clear (VM.Audio_Stream);
      VM.Display_Help := not OK;
      return OK;
   exception
      when others =>
         if not SDL.RWops.Is_Null (Source) then
            SDL.RWops.Close (Source);
         end if;

         SDL.Audio.Streams.Clear (VM.Audio_Stream);
         VM.Display_Help := True;
         return False;
   end Load_File;

   procedure Load_Path (VM : in out State; Path : in String) is
   begin
      if Load_File (VM, Path) then
         Set_Status (VM, "loaded " & Filename (Path));
      else
         Set_Status (VM, "load failed: " & Filename (Path));
      end if;
   end Load_Path;

   procedure Update_Framebuffer (VM : in out State) is
      Screen_Page : constant Natural := Natural (VM.RAM (IO_Screen_Page)) * 16#1_0000#;
   begin
      SDL.Video.Textures.Update
        (Self   => VM.Texture,
         Pixels => VM.RAM (Screen_Page)'Address,
         Pitch  => SDL.Video.Pixels.Pitches (Screen_Width));
   end Update_Framebuffer;

   procedure Execute_VM_Frame (VM : in out State; Updated : out Boolean) is
      Tick       : constant SDL.Timers.Nanoseconds := SDL.Timers.Ticks_NS;
      Elapsed    : constant SDL.Timers.Nanoseconds := Tick - VM.Last_Tick;
      Skip_Audio : Boolean := False;
   begin
      VM.Last_Tick := Tick;
      VM.Tick_Accumulator :=
        VM.Tick_Accumulator + Elapsed * SDL.Timers.Nanoseconds (Frames_Per_Second);

      Updated :=
        VM.Tick_Accumulator >= NS_Per_Second;
      Skip_Audio :=
        VM.Tick_Accumulator >=
          SDL.Timers.Nanoseconds (Max_Audio_Latency_Frames) * NS_Per_Second;

      if Skip_Audio then
         SDL.Audio.Streams.Clear (VM.Audio_Stream);
      end if;

      while VM.Tick_Accumulator >= NS_Per_Second loop
         declare
            Program_Counter : Natural;
         begin
            VM.Tick_Accumulator := VM.Tick_Accumulator - NS_Per_Second;

            VM.RAM (IO_Keyboard) := Byte (Interfaces.Shift_Right (VM.Key_State, 8));
            VM.RAM (IO_Keyboard + 1) := Byte (VM.Key_State and 16#00FF#);

            Program_Counter := Read_U24 (VM.RAM, IO_PC);

            for Index in 1 .. Screen_Pixels loop
               declare
                  Source_Address : constant Natural :=
                    Read_U24 (VM.RAM, Program_Counter);
                  Target_Address : constant Natural :=
                    Read_U24 (VM.RAM, Program_Counter + 3);
               begin
                  VM.RAM (Target_Address) := VM.RAM (Source_Address);
                  Program_Counter := Read_U24 (VM.RAM, Program_Counter + 6);
               end;
            end loop;

            if (not Skip_Audio) or else VM.Tick_Accumulator < NS_Per_Second then
               declare
                  Bank_Offset : constant Natural :=
                    Read_U16 (VM.RAM, IO_Audio_Bank) * 16#100#;
               begin
                  SDL.Audio.Streams.Put
                    (Self        => VM.Audio_Stream,
                     Data        => VM.RAM (Bank_Offset)'Address,
                     Byte_Length => Samples_Per_Frame);
               end;
            end if;
         end;
      end loop;
   end Execute_VM_Frame;

   procedure Update_Render_Target (VM : in out State) is
   begin
      Update_Framebuffer (VM);

      SDL.Video.Renderers.Set_Target (VM.Renderer, VM.Render_Target);
      SDL.Video.Renderers.Copy (VM.Renderer, VM.Texture);

      if VM.Display_Help then
         Print (VM.Renderer, 4.0, 4.0, "Drop a BytePusher file in this");
         Print (VM.Renderer, 8.0, 12.0, "window to load and run it!");
         Print (VM.Renderer, 4.0, 28.0, "Press ENTER to switch between");
         Print (VM.Renderer, 8.0, 36.0, "positional and symbolic input.");
      end if;

      if VM.Status_Ticks > 0 then
         VM.Status_Ticks := VM.Status_Ticks - 1;
         Print
           (VM.Renderer,
            4.0,
            Float (Screen_Height - 12),
            ASU.To_String (VM.Status_Text));
      end if;

      SDL.Video.Renderers.Reset_Target (VM.Renderer);
   end Update_Render_Target;

   procedure Render_Frame (VM : in out State; Updated : in Boolean) is
   begin
      if Updated then
         Update_Render_Target (VM);
      end if;

      SDL.Video.Renderers.Reset_Target (VM.Renderer);
      SDL.Video.Renderers.Set_Draw_Colour (VM.Renderer, 0.0, 0.0, 0.0, 1.0);
      SDL.Video.Renderers.Clear (VM.Renderer);
      SDL.Video.Renderers.Copy (VM.Renderer, VM.Render_Target);
      SDL.Video.Renderers.Present (VM.Renderer);
   end Render_Frame;

   procedure Cleanup (VM : in out State) is
   begin
      if SDL.Audio.Streams.Is_Open (VM.Audio_Stream) then
         SDL.Audio.Streams.Close (VM.Audio_Stream);
      end if;

      SDL.Video.Textures.Finalize (VM.Render_Target);
      SDL.Video.Textures.Finalize (VM.Texture);

      if VM.Palette /= null then
         SDL.Video.Palettes.Free (VM.Palette.all);
         Free_Palette (VM.Palette);
      end if;

      SDL.Video.Renderers.Finalize (VM.Renderer);
      SDL.Video.Windows.Finalize (VM.Window);

      if VM.SDL_Initialized then
         SDL.Quit;
         VM.SDL_Initialized := False;
      end if;
   end Cleanup;

   function App_Init
     (App_State : access System.Address;
      ArgC      : in C.int;
      ArgV      : access CS.chars_ptr_array) return SDL.Main.App_Results
   is
      pragma Unreferenced (ArgC, ArgV);

      VM           : State_Access := null;
      Actual_Spec  : SDL.Audio.Spec;
      Audio_Frames : Natural := 0;
      Initial_Zoom : Positive := 2;
      Window_Size  : SDL.Positive_Sizes :=
        (Width  => SDL.Positive_Dimension (Screen_Width * 2),
         Height => SDL.Positive_Dimension (Screen_Height * 2));
   begin
      if App_State = null then
         SDL.Error.Set ("Missing application state pointer");
         return SDL.Main.App_Failure;
      end if;

      App_State.all := System.Null_Address;
      VM := new State;
      App_State.all := To_Address (VM);

      Require_SDL
        (SDL.Set_App_Metadata
           ("SDL 3 BytePusher",
            "1.0",
            "com.example.SDL3BytePusher"),
         "App metadata setup failed");
      Require_SDL
        (SDL.Set_App_Metadata_Property
           (SDL.App_Metadata_URL_Property,
            "https://examples.libsdl.org/SDL3/demo/04-bytepusher/"),
         "App URL metadata setup failed");
      Require_SDL
        (SDL.Set_App_Metadata_Property
           (SDL.App_Metadata_Creator_Property,
            "SDL team"),
         "App creator metadata setup failed");
      Require_SDL
        (SDL.Set_App_Metadata_Property
           (SDL.App_Metadata_Copyright_Property,
            "Placed in the public domain"),
         "App copyright metadata setup failed");
      Require_SDL
        (SDL.Set_App_Metadata_Property
           (SDL.App_Metadata_Type_Property,
            "game"),
         "App type metadata setup failed");

      Require_SDL
        (SDL.Initialise (SDL.Enable_Audio or SDL.Enable_Video),
         "SDL initialization failed");
      VM.SDL_Initialized := True;

      Initialise_Key_Mappings (VM.all);
      Initial_Zoom := Calculate_Initial_Zoom;
      Window_Size :=
        (Width  => SDL.Positive_Dimension (Screen_Width * Initial_Zoom),
         Height => SDL.Positive_Dimension (Screen_Height * Initial_Zoom));

      SDL.Video.Renderers.Makers.Create
        (Window   => VM.Window,
         Rend     => VM.Renderer,
         Title    => "SDL 3 BytePusher",
         Position => SDL.Video.Windows.Centered_Window_Position,
         Size     => Window_Size,
         Flags    => SDL.Video.Windows.Resizable);

      SDL.Video.Renderers.Set_Logical_Presentation
        (Self => VM.Renderer,
         Size =>
           (Width  => SDL.Dimension (Screen_Width),
            Height => SDL.Dimension (Screen_Height)),
         Mode => SDL.Video.Renderers.Integer_Scale_Presentation);

      VM.Palette := Build_Palette;

      SDL.Video.Textures.Makers.Create
        (Tex      => VM.Texture,
         Renderer => VM.Renderer,
         Format   => SDL.Video.Pixel_Formats.Pixel_Format_Index_8,
         Kind     => SDL.Video.Textures.Streaming,
         Size     =>
           (Width  => SDL.Positive_Dimension (Screen_Width),
            Height => SDL.Positive_Dimension (Screen_Height)));
      SDL.Video.Textures.Makers.Create
        (Tex      => VM.Render_Target,
         Renderer => VM.Renderer,
         Format   => SDL.Video.Pixel_Formats.Pixel_Format_Unknown,
         Kind     => SDL.Video.Textures.Target,
         Size     =>
           (Width  => SDL.Positive_Dimension (Screen_Width),
            Height => SDL.Positive_Dimension (Screen_Height)));

      SDL.Video.Textures.Set_Palette (VM.Texture, VM.Palette.all);
      SDL.Video.Textures.Set_Scale_Mode (VM.Texture, SDL.Video.Textures.Nearest);
      SDL.Video.Textures.Set_Scale_Mode (VM.Render_Target, SDL.Video.Textures.Nearest);

      SDL.Audio.Streams.Open
        (Self          => VM.Audio_Stream,
         Device        => SDL.Audio.Default_Playback_Device,
         Application   => Requested_Spec,
         Output        => Actual_Spec,
         Sample_Frames => Audio_Frames);
      SDL.Audio.Streams.Set_Gain (VM.Audio_Stream, 0.1);
      SDL.Audio.Streams.Resume (VM.Audio_Stream);

      Set_Status (VM.all, "renderer: " & SDL.Video.Renderers.Name (VM.Renderer));

      VM.Last_Tick := SDL.Timers.Ticks_NS;
      VM.Tick_Accumulator := NS_Per_Second;

      if Ada.Command_Line.Argument_Count >= 1 then
         Load_Path (VM.all, Ada.Command_Line.Argument (1));
      end if;

      return SDL.Main.App_Continue;
   exception
      when Error : others =>
         SDL.Error.Set
           ("bytepusher init failed: "
            & Ada.Exceptions.Exception_Message (Error));
         return SDL.Main.App_Failure;
   end App_Init;

   function App_Iterate
     (App_State : in System.Address) return SDL.Main.App_Results
   is
      VM      : constant State_Access := To_State (App_State);
      Updated : Boolean := False;
   begin
      if VM = null then
         SDL.Error.Set ("Invalid application state");
         return SDL.Main.App_Failure;
      end if;

      Execute_VM_Frame (VM.all, Updated);
      Render_Frame (VM.all, Updated);
      return SDL.Main.App_Continue;
   exception
      when Error : others =>
         SDL.Error.Set
           ("bytepusher iterate failed: "
            & Ada.Exceptions.Exception_Message (Error));
         return SDL.Main.App_Failure;
   end App_Iterate;

   function App_Event
     (App_State : in System.Address;
      Event     : access SDL.Events.Queue.Event) return SDL.Main.App_Results
   is
      VM : constant State_Access := To_State (App_State);
   begin
      if VM = null then
         SDL.Error.Set ("Invalid application state");
         return SDL.Main.App_Failure;
      end if;

      if Event = null then
         return SDL.Main.App_Continue;
      end if;

      case Event.Common.Event_Type is
         when SDL.Events.Quit =>
            return SDL.Main.App_Success;

         when SDL.Events.Files.Drop_File =>
            if Event.Drop.File_Name /= CS.Null_Ptr then
               Load_Path (VM.all, CS.Value (Event.Drop.File_Name));
            end if;

         when SDL.Events.Keyboards.Key_Down =>
            declare
               Key  : constant SDL.Events.Keyboards.Key_Codes :=
                 Event.Keyboard.Key_Sym.Key_Code;
               Scan : constant SDL.Events.Keyboards.Scan_Codes :=
                 Event.Keyboard.Key_Sym.Scan_Code;
            begin
               if Key = VM.Escape_Key then
                  return SDL.Main.App_Success;
               end if;

               if Key = VM.Return_Key then
                  VM.Positional_Input := not VM.Positional_Input;
                  VM.Key_State := 0;

                  if VM.Positional_Input then
                     Set_Status (VM.all, "switched to positional input");
                  else
                     Set_Status (VM.all, "switched to symbolic input");
                  end if;
               end if;

               if VM.Positional_Input then
                  VM.Key_State := VM.Key_State or Scancode_Mask (VM.all, Scan);
               else
                  VM.Key_State := VM.Key_State or Keycode_Mask (VM.all, Key);
               end if;
            end;

         when SDL.Events.Keyboards.Key_Up =>
            declare
               Key  : constant SDL.Events.Keyboards.Key_Codes :=
                 Event.Keyboard.Key_Sym.Key_Code;
               Scan : constant SDL.Events.Keyboards.Scan_Codes :=
                 Event.Keyboard.Key_Sym.Scan_Code;
            begin
               if VM.Positional_Input then
                  VM.Key_State := VM.Key_State and not Scancode_Mask (VM.all, Scan);
               else
                  VM.Key_State := VM.Key_State and not Keycode_Mask (VM.all, Key);
               end if;
            end;

         when others =>
            null;
      end case;

      return SDL.Main.App_Continue;
   exception
      when Error : others =>
         SDL.Error.Set
           ("bytepusher event failed: "
            & Ada.Exceptions.Exception_Message (Error));
         return SDL.Main.App_Failure;
   end App_Event;

   procedure App_Quit
     (App_State : in System.Address;
      Result    : in SDL.Main.App_Results)
   is
      VM : State_Access := To_State (App_State);
   begin
      if Result = SDL.Main.App_Failure then
         declare
            Message : constant String := SDL.Error.Get;
         begin
            if Message /= "" then
               SDL.Log.Put_Error ("Error: " & Message);
            end if;
         end;
      end if;

      if VM /= null then
         Cleanup (VM.all);
         Free_State (VM);
      end if;
   end App_Quit;

   procedure Free_Arguments (Items : in out Argument_Vector_Access) is
   begin
      if Items = null then
         return;
      end if;

      for Index in Items'Range loop
         if Items (Index) /= CS.Null_Ptr then
            CS.Free (Items (Index));
            Items (Index) := CS.Null_Ptr;
         end if;
      end loop;

      Free_Argument_Vector (Items);
   end Free_Arguments;

   procedure Run is
      Arg_Count : constant Natural := Ada.Command_Line.Argument_Count + 1;
      Args      : Argument_Vector_Access := null;
      Exit_Code : C.int := 0;
   begin
      Args := new CS.chars_ptr_array (0 .. C.size_t (Arg_Count));

      for Index in Args'Range loop
         Args (Index) := CS.Null_Ptr;
      end loop;

      Args (0) := CS.New_String (Ada.Command_Line.Command_Name);
      for Index in 1 .. Ada.Command_Line.Argument_Count loop
         Args (C.size_t (Index)) := CS.New_String (Ada.Command_Line.Argument (Index));
      end loop;

      Exit_Code :=
        SDL.Main.Enter_App_Main_Callbacks
          (ArgC      => C.int (Arg_Count),
           ArgV      => Args (Args'First)'Address,
           App_Init  => App_Init'Access,
           App_Iter  => App_Iterate'Access,
           App_Event => App_Event'Access,
           App_Quit  => App_Quit'Access);

      if Exit_Code /= 0 then
         declare
            Message : constant String := SDL.Error.Get;
         begin
            if Message /= "" then
               raise Program_Error with Message;
            end if;

            raise Program_Error with
              "bytepusher exited with status" & Integer'Image (Integer (Exit_Code));
         end;
      end if;

      Free_Arguments (Args);
   exception
      when others =>
         Free_Arguments (Args);
         raise;
   end Run;
end Bytepusher_App;
