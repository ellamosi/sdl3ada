with Ada.Command_Line;
with Ada.Unchecked_Conversion;
with Ada.Unchecked_Deallocation;

with Interfaces.C;
with Interfaces.C.Strings;
with System;

with SDL;
with SDL.AsyncIO;
with SDL.Error;
with SDL.Events;
with SDL.Events.Events;
with SDL.Filesystems;
with SDL.Main;
with SDL.RWops;
with SDL.Video.Rectangles;
with SDL.Video.Renderers;
with SDL.Video.Renderers.Makers;
with SDL.Video.Surfaces;
with SDL.Video.Surfaces.Makers;
with SDL.Video.Textures;
with SDL.Video.Textures.Makers;
with SDL.Video.Windows;

package body Load_Bitmaps_App is
   package C renames Interfaces.C;
   package CS renames Interfaces.C.Strings;

   use type C.int;
   use type CS.chars_ptr;
   use type SDL.AsyncIO.Results;
   use type SDL.AsyncIO.Sizes;
   use type SDL.Events.Event_Types;
   use type SDL.Main.App_Results;
   use type System.Address;

   Window_Width  : constant SDL.Positive_Dimension := 640;
   Window_Height : constant SDL.Positive_Dimension := 480;

   type Texture_Index is range 1 .. 4;
   type Texture_List is array (Texture_Index) of SDL.Video.Textures.Texture;
   type Rectangle_List is array (Texture_Index) of SDL.Video.Rectangles.Float_Rectangle;
   type Tag_List is array (Texture_Index) of aliased Character;

   Texture_Rectangles : constant Rectangle_List :=
     (1 => (X => 116.0, Y => 156.0, Width => 408.0, Height => 167.0),
      2 => (X => 20.0, Y => 200.0, Width => 96.0, Height => 60.0),
      3 => (X => 525.0, Y => 180.0, Width => 96.0, Height => 96.0),
      4 => (X => 288.0, Y => 375.0, Width => 64.0, Height => 64.0));

   type State is record
      Window          : SDL.Video.Windows.Window;
      Renderer        : SDL.Video.Renderers.Renderer;
      Queue           : SDL.AsyncIO.Queue;
      Textures        : Texture_List;
      Load_Tags       : Tag_List := ('1', '2', '3', '4');
      SDL_Initialized : Boolean := False;
   end record;

   type State_Access is access all State;
   type Argument_Vector_Access is access CS.chars_ptr_array;

   procedure Free_State is new Ada.Unchecked_Deallocation (State, State_Access);
   procedure Free_Argument_Vector is new Ada.Unchecked_Deallocation
     (CS.chars_ptr_array, Argument_Vector_Access);

   function To_State is new Ada.Unchecked_Conversion (System.Address, State_Access);
   function To_Address is new Ada.Unchecked_Conversion (State_Access, System.Address);

   procedure Require_SDL (Condition : in Boolean; Message : in String);
   function Texture_File_Name (Index : in Texture_Index) return String;
   function Texture_Path (Index : in Texture_Index) return String;
   procedure Cleanup (App : in out State);
   function Find_Texture_Index
     (App       : in State;
      User_Data : in System.Address;
      Index     : out Texture_Index) return Boolean;
   procedure Handle_Load_Result
     (App  : in out State;
      Item : in out SDL.AsyncIO.Outcome);

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

   function Texture_File_Name (Index : in Texture_Index) return String is
   begin
      case Index is
         when 1 =>
            return "sample.png";
         when 2 =>
            return "gamepad_front.png";
         when 3 =>
            return "speaker.png";
         when 4 =>
            return "icon2x.png";
      end case;
   end Texture_File_Name;

   function Texture_Path (Index : in Texture_Index) return String is
   begin
      return SDL.Filesystems.Base_Path & "../examples/assets/" & Texture_File_Name (Index);
   end Texture_Path;

   procedure Cleanup (App : in out State) is
   begin
      SDL.AsyncIO.Destroy (App.Queue);

      for Index in App.Textures'Range loop
         SDL.Video.Textures.Finalize (App.Textures (Index));
      end loop;

      SDL.Video.Renderers.Finalize (App.Renderer);
      SDL.Video.Windows.Finalize (App.Window);

      if App.SDL_Initialized then
         SDL.Quit;
         App.SDL_Initialized := False;
      end if;
   end Cleanup;

   function Find_Texture_Index
     (App       : in State;
      User_Data : in System.Address;
      Index     : out Texture_Index) return Boolean
   is
   begin
      for Candidate in Texture_Index loop
         if User_Data = App.Load_Tags (Candidate)'Address then
            Index := Candidate;
            return True;
         end if;
      end loop;

      Index := Texture_Index'First;
      return False;
   end Find_Texture_Index;

   procedure Handle_Load_Result
     (App  : in out State;
      Item : in out SDL.AsyncIO.Outcome)
   is
      Index        : Texture_Index;
      Bytes_Loaded : Natural;
   begin
      if not Find_Texture_Index (App, Item.User_Data, Index) then
         SDL.AsyncIO.Free_Buffer (Item);
         return;
      end if;

      if Item.Result /= SDL.AsyncIO.Complete then
         declare
            Message : constant String := SDL.Error.Get;
         begin
            SDL.AsyncIO.Free_Buffer (Item);

            if Message /= "" then
               raise Program_Error with
                 "Async load failed for " & Texture_File_Name (Index) & ": " & Message;
            end if;

            raise Program_Error with
              "Async load did not complete for " & Texture_File_Name (Index);
         end;
      end if;

      if Item.Buffer = System.Null_Address then
         SDL.AsyncIO.Free_Buffer (Item);
         raise Program_Error with
           "Async load returned a null buffer for " & Texture_File_Name (Index);
      end if;

      if Item.Bytes_Transferred > SDL.AsyncIO.Sizes (Natural'Last) then
         SDL.AsyncIO.Free_Buffer (Item);
         raise Program_Error with
           "Async load was too large to decode in Ada for " & Texture_File_Name (Index);
      end if;

      Bytes_Loaded := Natural (Item.Bytes_Transferred);

      declare
         Source : constant SDL.RWops.RWops :=
           SDL.RWops.From_Const_Memory (Item.Buffer, Bytes_Loaded);
         Image  : SDL.Video.Surfaces.Surface;
      begin
         SDL.Video.Surfaces.Makers.Load_PNG
           (Self        => Image,
            Source      => Source,
            Close_After => True);

         SDL.Video.Textures.Makers.Create
           (Tex      => App.Textures (Index),
            Renderer => App.Renderer,
            Surface  => Image);
      end;

      SDL.AsyncIO.Free_Buffer (Item);
   exception
      when others =>
         SDL.AsyncIO.Free_Buffer (Item);
         raise;
   end Handle_Load_Result;

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
           ("Example AsyncIO Load Bitmaps",
            "1.0",
            "com.example.asyncio-load-bitmaps"),
         "Unable to set application metadata");

      Require_SDL
        (SDL.Initialise (SDL.Enable_Video),
         "Couldn't initialize SDL");
      App.SDL_Initialized := True;

      SDL.Video.Renderers.Makers.Create
        (Window   => App.Window,
         Rend     => App.Renderer,
         Title    => "examples/asyncio/load-bitmaps",
         Position => SDL.Video.Windows.Centered_Window_Position,
         Size     => (Width => Window_Width, Height => Window_Height),
         Flags    => SDL.Video.Windows.Resizable);

      SDL.Video.Renderers.Set_Logical_Presentation
        (Self => App.Renderer,
         Size => (Width => Window_Width, Height => Window_Height),
         Mode => SDL.Video.Renderers.Letterbox_Presentation);

      SDL.AsyncIO.Create (App.Queue);

      for Index in Texture_Index loop
         SDL.AsyncIO.Load_File
           (File             => Texture_Path (Index),
            Completion_Queue => App.Queue,
            User_Data        => App.Load_Tags (Index)'Address);
      end loop;

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
      App  : constant State_Access := To_State (App_State);
      Item : SDL.AsyncIO.Outcome;
   begin
      if SDL.AsyncIO.Get_Result (App.Queue, Item) then
         Handle_Load_Result (App.all, Item);
      end if;

      SDL.Video.Renderers.Set_Draw_Colour (App.Renderer, 0.0, 0.0, 0.0, 1.0);
      SDL.Video.Renderers.Clear (App.Renderer);

      for Index in Texture_Index loop
         if not SDL.Video.Textures.Is_Null (App.Textures (Index)) then
            SDL.Video.Renderers.Copy_To
              (App.Renderer, App.Textures (Index), Texture_Rectangles (Index));
         end if;
      end loop;

      SDL.Video.Renderers.Present (App.Renderer);
      return SDL.Main.App_Continue;
   end App_Iterate;

   function App_Event
     (App_State : in System.Address;
      Event     : access SDL.Events.Events.Events) return SDL.Main.App_Results
   is
      pragma Unreferenced (App_State);
   begin
      if Event /= null and then Event.Common.Event_Type = SDL.Events.Quit then
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
              "load_bitmaps exited with status" & Integer'Image (Integer (Exit_Code));
         end;
      end if;

      Free_Arguments (Args);
   exception
      when others =>
         Free_Arguments (Args);
         raise;
   end Run;
end Load_Bitmaps_App;
