with Ada.Command_Line;
with Ada.Streams;
with Ada.Unchecked_Conversion;
with Ada.Unchecked_Deallocation;

with Interfaces.C;
with Interfaces.C.Strings;
with System;

with SDL;
with SDL.Audio;
with SDL.Audio.Streams;
with SDL.Error;
with SDL.Events;
with SDL.Events.Events;
with SDL.Filesystems;
with SDL.Main;
with SDL.Video.Renderers;
with SDL.Video.Renderers.Makers;
with SDL.Video.Windows;

package body Multiple_Streams_App is
   package C renames Interfaces.C;
   package CS renames Interfaces.C.Strings;

   use type C.int;
   use type CS.chars_ptr;
   use type SDL.Audio.Device_ID;
   use type SDL.Init_Flags;
   use type SDL.Events.Event_Types;
   use type SDL.Main.App_Results;

   Window_Width  : constant SDL.Positive_Dimension := 640;
   Window_Height : constant SDL.Positive_Dimension := 480;

   type Byte_Array_Access is access all Ada.Streams.Stream_Element_Array;
   type Sound_Index is range 1 .. 2;

   type Sound_State is record
      WAV_Data   : Byte_Array_Access := null;
      WAV_Length : Natural := 0;
      Stream     : SDL.Audio.Streams.Stream;
   end record;

   type Sound_List is array (Sound_Index) of Sound_State;

   type State is record
      Window          : SDL.Video.Windows.Window;
      Renderer        : SDL.Video.Renderers.Renderer;
      Audio_Device    : SDL.Audio.Device_ID := 0;
      Sounds          : Sound_List;
      SDL_Initialized : Boolean := False;
   end record;

   type State_Access is access all State;
   type Argument_Vector_Access is access CS.chars_ptr_array;

   procedure Free_State is new Ada.Unchecked_Deallocation (State, State_Access);
   procedure Free_Bytes is new Ada.Unchecked_Deallocation
     (Ada.Streams.Stream_Element_Array, Byte_Array_Access);
   procedure Free_Argument_Vector is new Ada.Unchecked_Deallocation
     (CS.chars_ptr_array, Argument_Vector_Access);

   function To_State is new Ada.Unchecked_Conversion (System.Address, State_Access);
   function To_Address is new Ada.Unchecked_Conversion (State_Access, System.Address);

   procedure Require_SDL (Condition : in Boolean; Message : in String);
   procedure Cleanup (App : in out State);
   function Sound_File_Name (Index : in Sound_Index) return String;
   function Sound_Path (Index : in Sound_Index) return String;
   procedure Load_Sound (App : in out State; Index : in Sound_Index);

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
      Event     : access SDL.Events.Events.Events) return SDL.Main.App_Results
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

   procedure Cleanup (App : in out State) is
   begin
      if App.Audio_Device /= 0 then
         SDL.Audio.Close_Device (App.Audio_Device);
         App.Audio_Device := 0;
      end if;

      for Index in App.Sounds'Range loop
         SDL.Audio.Streams.Close (App.Sounds (Index).Stream);

         if App.Sounds (Index).WAV_Data /= null then
            Free_Bytes (App.Sounds (Index).WAV_Data);
         end if;
      end loop;

      SDL.Video.Renderers.Finalize (App.Renderer);
      SDL.Video.Windows.Finalize (App.Window);

      if App.SDL_Initialized then
         SDL.Quit;
         App.SDL_Initialized := False;
      end if;
   end Cleanup;

   function Sound_File_Name (Index : in Sound_Index) return String is
   begin
      case Index is
         when 1 =>
            return "sample.wav";
         when 2 =>
            return "sword.wav";
      end case;
   end Sound_File_Name;

   function Sound_Path (Index : in Sound_Index) return String is
     (SDL.Filesystems.Base_Path & "../examples/assets/" & Sound_File_Name (Index));

   procedure Load_Sound (App : in out State; Index : in Sound_Index) is
      Loaded_Spec : SDL.Audio.Spec;
      Data        : constant Ada.Streams.Stream_Element_Array :=
        SDL.Audio.Load_WAV (Sound_Path (Index), Loaded_Spec);
   begin
      if Data'Length = 0 then
         raise Program_Error with Sound_File_Name (Index) & " was empty";
      end if;

      App.Sounds (Index).WAV_Data := new Ada.Streams.Stream_Element_Array'(Data);
      App.Sounds (Index).WAV_Length := Natural (Data'Length);
      SDL.Audio.Streams.Create (App.Sounds (Index).Stream, Loaded_Spec);
      SDL.Audio.Streams.Bind (App.Sounds (Index).Stream, App.Audio_Device);
   end Load_Sound;

   function App_Init
     (App_State : access System.Address;
      ArgC      : in C.int;
      ArgV      : access CS.chars_ptr_array) return SDL.Main.App_Results
   is
      pragma Unreferenced (ArgC, ArgV);

      App : State_Access := new State;
   begin
      App_State.all := System.Null_Address;

      Require_SDL
        (SDL.Set_App_Metadata
           ("Example Audio Multiple Streams",
            "1.0",
            "com.example.audio-multiple-streams"),
         "Unable to set application metadata");

      Require_SDL
        (SDL.Initialise (SDL.Enable_Video or SDL.Enable_Audio),
         "Couldn't initialize SDL");
      App.SDL_Initialized := True;

      SDL.Video.Renderers.Makers.Create
        (Window   => App.Window,
         Rend     => App.Renderer,
         Title    => "examples/audio/multiple-streams",
         Position => SDL.Video.Windows.Centered_Window_Position,
         Size     => (Width => Window_Width, Height => Window_Height),
         Flags    => SDL.Video.Windows.Resizable);

      SDL.Video.Renderers.Set_Logical_Presentation
        (Self => App.Renderer,
         Size => (Width => Window_Width, Height => Window_Height),
         Mode => SDL.Video.Renderers.Letterbox_Presentation);

      App.Audio_Device := SDL.Audio.Open_Device;
      Load_Sound (App.all, 1);
      Load_Sound (App.all, 2);

      App_State.all := To_Address (App);
      return SDL.Main.App_Continue;
   exception
      when others =>
         Cleanup (App.all);
         Free_State (App);
         raise;
   end App_Init;

   function App_Iterate
     (App_State : in System.Address) return SDL.Main.App_Results
   is
      App : constant State_Access := To_State (App_State);
   begin
      for Index in App.Sounds'Range loop
         if SDL.Audio.Streams.Queued_Bytes (App.Sounds (Index).Stream)
              < App.Sounds (Index).WAV_Length
         then
            SDL.Audio.Streams.Put
              (Self        => App.Sounds (Index).Stream,
               Data        => App.Sounds (Index).WAV_Data.all'Address,
               Byte_Length => Positive (App.Sounds (Index).WAV_Length));
         end if;
      end loop;

      SDL.Video.Renderers.Set_Draw_Colour (App.Renderer, 0.0, 0.0, 0.0, 1.0);
      SDL.Video.Renderers.Clear (App.Renderer);
      SDL.Video.Renderers.Present (App.Renderer);
      return SDL.Main.App_Continue;
   end App_Iterate;

   function App_Event
     (App_State : in System.Address;
      Event     : access SDL.Events.Events.Events) return SDL.Main.App_Results
   is
      pragma Unreferenced (App_State);
   begin
      if Event = null then
         return SDL.Main.App_Continue;
      end if;

      if Event.Common.Event_Type = SDL.Events.Quit then
         return SDL.Main.App_Success;
      end if;

      return SDL.Main.App_Continue;
   end App_Event;

   procedure App_Quit
     (App_State : in System.Address;
      Result    : in SDL.Main.App_Results)
   is
      pragma Unreferenced (Result);

      App : State_Access := To_State (App_State);
   begin
      if App = null then
         return;
      end if;

      Cleanup (App.all);
      Free_State (App);
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
         Args (C.size_t (Index)) :=
           CS.New_String (Ada.Command_Line.Argument (Index));
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
              "multiple_streams exited with status"
              & Integer'Image (Integer (Exit_Code));
         end;
      end if;

      Free_Arguments (Args);
   exception
      when others =>
         Free_Arguments (Args);
         raise;
   end Run;
end Multiple_Streams_App;
