with Ada.Command_Line;
with Ada.Streams;
with Ada.Strings.Fixed;
with Ada.Strings.Unbounded;
with Ada.Unchecked_Conversion;
with Ada.Unchecked_Deallocation;
with Ada.Numerics.Discrete_Random;

with Interfaces;
with Interfaces.C;
with Interfaces.C.Strings;
with System;

with SDL;
with SDL.Error;
with SDL.Events;
with SDL.Events.Queue;
with SDL.Events.Keyboards;
with SDL.Events.Windows;
with SDL.Main;
with SDL.RWops;
with SDL.Time;
with SDL.UTF_8;
with SDL.Video.Rectangles;
with SDL.Video.Renderers;
with SDL.Video.Renderers.Makers;
with SDL.Video.Windows;

package body Infinite_Monkeys_App is
   package C renames Interfaces.C;
   package CS renames Interfaces.C.Strings;
   package US renames Ada.Strings.Unbounded;

   use type C.int;
   use type CS.chars_ptr;
   use type Interfaces.Integer_64;
   use type Interfaces.Unsigned_16;
   use type SDL.Events.Event_Types;
   use type SDL.Events.Keyboards.Key_Modifiers;
   use type SDL.Events.Keyboards.Scan_Codes;
   use type SDL.Main.App_Results;
   use type SDL.Time.Times;
   use type SDL.UTF_8.Code_Points;

   Window_Width  : constant SDL.Positive_Dimension := 640;
   Window_Height : constant SDL.Positive_Dimension := 480;
   Character_Size : constant SDL.Positive_Dimension :=
     SDL.Video.Renderers.Debug_Text_Character_Size;
   Footer_Row_Count : constant Positive := 4;
   Nanoseconds_Per_Second : constant SDL.Time.Times := 1_000_000_000;
   Default_Monkey_Count   : constant Natural := 100;

   Min_Monkey_Scan_Code : constant SDL.Events.Keyboards.Scan_Codes :=
     SDL.Events.Keyboards.Value ("A");
   Max_Monkey_Scan_Code : constant SDL.Events.Keyboards.Scan_Codes :=
     SDL.Events.Keyboards.Value ("Slash");
   Pixel_Size_Changed_Event : constant SDL.Events.Event_Types :=
     SDL.Events.Windows.To_Event_Type (SDL.Events.Windows.Size_Changed);
   Newline_Code : constant SDL.UTF_8.Code_Points :=
     SDL.UTF_8.Code_Points (Character'Pos (Character'Val (10)));
   Space_Code : constant SDL.UTF_8.Code_Points :=
     SDL.UTF_8.Code_Points (Character'Pos (' '));
   Shift_Modifier : constant SDL.Events.Keyboards.Key_Modifiers :=
     SDL.Events.Keyboards.Modifier_Shift;

   LF : constant Character := Character'Val (10);

   Default_Text : constant String :=
     "Jabberwocky, by Lewis Carroll" & LF &
     LF &
     "'Twas brillig, and the slithy toves" & LF &
     "      Did gyre and gimble in the wabe:" & LF &
     "All mimsy were the borogoves," & LF &
     "      And the mome raths outgrabe." & LF &
     LF &
     """Beware the Jabberwock, my son!" & LF &
     "      The jaws that bite, the claws that catch!" & LF &
     "Beware the Jubjub bird, and shun" & LF &
     "      The frumious Bandersnatch!""" & LF &
     LF &
     "He took his vorpal sword in hand;" & LF &
     "      Long time the manxome foe he sought-" & LF &
     "So rested he by the Tumtum tree" & LF &
     "      And stood awhile in thought." & LF &
     LF &
     "And, as in uffish thought he stood," & LF &
     "      The Jabberwock, with eyes of flame," & LF &
     "Came whiffling through the tulgey wood," & LF &
     "      And burbled as it came!" & LF &
     LF &
     "One, two! One, two! And through and through" & LF &
     "      The vorpal blade went snicker-snack!" & LF &
     "He left it dead, and with its head" & LF &
     "      He went galumphing back." & LF &
     LF &
     """And hast thou slain the Jabberwock?" & LF &
     "      Come to my arms, my beamish boy!" & LF &
     "O frabjous day! Callooh! Callay!""" & LF &
     "      He chortled in his joy." & LF &
     LF &
     "'Twas brillig, and the slithy toves" & LF &
     "      Did gyre and gimble in the wabe:" & LF &
     "All mimsy were the borogoves," & LF &
     "      And the mome raths outgrabe." & LF;

   subtype Scan_Code_Ranges is Integer range
     Integer (Min_Monkey_Scan_Code) .. Integer (Max_Monkey_Scan_Code);

   package Random_Scan_Codes is new Ada.Numerics.Discrete_Random (Scan_Code_Ranges);
   package Random_Booleans is new Ada.Numerics.Discrete_Random (Boolean);

   type String_Access is access all String;

   type Line_Record is record
      Text   : US.Unbounded_String := US.Null_Unbounded_String;
      Length : Natural := 0;
   end record;

   type Line_Array is array (Positive range <>) of Line_Record;
   type Line_Array_Access is access Line_Array;

   type Code_Point_Array is array (Positive range <>) of SDL.UTF_8.Code_Points;
   type Code_Point_Array_Access is access Code_Point_Array;

   type State is record
      Window          : SDL.Video.Windows.Window;
      Renderer        : SDL.Video.Renderers.Renderer;
      Source_Text     : String_Access := null;
      Start_Time      : SDL.Time.Times := 0;
      End_Time        : SDL.Time.Times := 0;
      Progress_Offset : Natural := 0;
      Current_Row     : Natural := 0;
      Row_Count       : Natural := 0;
      Column_Count    : Natural := 0;
      Lines           : Line_Array_Access := null;
      Monkey_Chars    : Code_Point_Array_Access := null;
      Monkey_Count    : Natural := Default_Monkey_Count;
      SDL_Initialized : Boolean := False;
   end record;

   type State_Access is access all State;
   type Argument_Vector_Access is access CS.chars_ptr_array;

   procedure Free_State is new Ada.Unchecked_Deallocation (State, State_Access);
   procedure Free_Argument_Vector is new Ada.Unchecked_Deallocation
     (CS.chars_ptr_array, Argument_Vector_Access);
   procedure Free_String is new Ada.Unchecked_Deallocation (String, String_Access);
   procedure Free_Lines is new Ada.Unchecked_Deallocation
     (Line_Array, Line_Array_Access);
   procedure Free_Code_Points is new Ada.Unchecked_Deallocation
     (Code_Point_Array, Code_Point_Array_Access);

   function To_State is new Ada.Unchecked_Conversion (System.Address, State_Access);
   function To_Address is new Ada.Unchecked_Conversion (State_Access, System.Address);

   Scan_Generator  : Random_Scan_Codes.Generator;
   Shift_Generator : Random_Booleans.Generator;

   procedure Require_SDL (Condition : in Boolean; Message : in String);
   function Trim (Item : in String) return String;
   function To_String
     (Data : in Ada.Streams.Stream_Element_Array) return String;
   function Load_Text_File (Path : in String) return String;
   procedure Release_Display_Buffers (App : in out State);
   procedure Cleanup (App : in out State);
   procedure Parse_Arguments (App : in out State);
   procedure On_Window_Size_Changed (App : in out State);
   function Current_Line_Index (App : in State) return Positive;
   procedure Advance_Row (App : in out State);
   procedure Consume_Character
     (App         : in out State;
      Monkey      : in Integer;
      Code_Point  : in SDL.UTF_8.Code_Points;
      Next_Offset : in Natural);
   function Build_Monkey_Line (App : in State) return String;
   function Can_Monkey_Type
     (Code_Point : in SDL.UTF_8.Code_Points) return Boolean;
   function Get_Next_Character
     (App         : in out State;
      Next_Offset : out Natural) return SDL.UTF_8.Code_Points;
   function Monkey_Play return SDL.UTF_8.Code_Points;
   function Caption_Text
     (Monkey_Count : in Natural;
      Elapsed      : in Interfaces.Integer_64) return String;

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

   function Trim (Item : in String) return String is
     (Ada.Strings.Fixed.Trim (Item, Ada.Strings.Both));

   function To_String
     (Data : in Ada.Streams.Stream_Element_Array) return String
   is
      Result : String (1 .. Integer (Data'Length));
      Offset : Natural := 0;
   begin
      for Value of Data loop
         Offset := Offset + 1;
         Result (Offset) := Character'Val (Value);
      end loop;

      return Result;
   end To_String;

   function Load_Text_File (Path : in String) return String is
   begin
      return To_String (SDL.RWops.Load_File (Path));
   exception
      when SDL.RWops.RWops_Error =>
         raise Program_Error with "Couldn't open " & Path & ": " & SDL.Error.Get;
   end Load_Text_File;

   procedure Release_Display_Buffers (App : in out State) is
   begin
      if App.Lines /= null then
         Free_Lines (App.Lines);
      end if;

      if App.Monkey_Chars /= null then
         Free_Code_Points (App.Monkey_Chars);
      end if;

      App.Current_Row := 0;
      App.Row_Count := 0;
      App.Column_Count := 0;
   end Release_Display_Buffers;

   procedure Cleanup (App : in out State) is
   begin
      Release_Display_Buffers (App);

      if App.Source_Text /= null then
         Free_String (App.Source_Text);
      end if;

      SDL.Video.Renderers.Finalize (App.Renderer);
      SDL.Video.Windows.Finalize (App.Window);

      if App.SDL_Initialized then
         SDL.Quit;
         App.SDL_Initialized := False;
      end if;
   end Cleanup;

   procedure Parse_Arguments (App : in out State) is
      Arg : Positive := 1;
   begin
      if Ada.Command_Line.Argument_Count >= Arg
        and then Ada.Command_Line.Argument (Arg) = "--monkeys"
      then
         Arg := Arg + 1;

         if Ada.Command_Line.Argument_Count < Arg then
            raise Program_Error with
              "Usage: "
              & Ada.Command_Line.Command_Name
              & " [--monkeys N] [file.txt]";
         end if;

         begin
            declare
               Value : constant Integer :=
                 Integer'Value (Ada.Command_Line.Argument (Arg));
            begin
               if Value < 0 then
                  raise Program_Error with "--monkeys expects a non-negative integer";
               end if;

               App.Monkey_Count := Natural (Value);
            end;
         exception
            when Constraint_Error =>
               raise Program_Error with "--monkeys expects an integer";
         end;

         Arg := Arg + 1;
      end if;

      if Ada.Command_Line.Argument_Count >= Arg then
         App.Source_Text := new String'(Load_Text_File (Ada.Command_Line.Argument (Arg)));
      else
         App.Source_Text := new String'(Default_Text);
      end if;
   end Parse_Arguments;

   procedure On_Window_Size_Changed (App : in out State) is
      Size : SDL.Sizes;
      Rows : Integer;
      Cols : Integer;
   begin
      Size := SDL.Video.Renderers.Get_Current_Output_Size (App.Renderer);

      Release_Display_Buffers (App);

      Rows :=
        Integer (Size.Height / Character_Size) - Footer_Row_Count;
      Cols := Integer (Size.Width / Character_Size);

      if Rows <= 0 or else Cols <= 0 then
         return;
      end if;

      App.Row_Count := Natural (Rows);
      App.Column_Count := Natural (Cols);
      App.Lines := new Line_Array (1 .. App.Row_Count);
      App.Monkey_Chars := new Code_Point_Array (1 .. App.Column_Count);

      for Index in App.Monkey_Chars'Range loop
         App.Monkey_Chars (Index) := Space_Code;
      end loop;
   exception
      when SDL.Video.Renderers.Renderer_Error =>
         null;
   end On_Window_Size_Changed;

   function Current_Line_Index (App : in State) return Positive is
   begin
      return Positive ((App.Current_Row mod App.Row_Count) + 1);
   end Current_Line_Index;

   procedure Advance_Row (App : in out State) is
      Index : Positive;
   begin
      if App.Row_Count = 0 or else App.Lines = null then
         return;
      end if;

      App.Current_Row := App.Current_Row + 1;
      Index := Current_Line_Index (App);
      App.Lines (Index).Text := US.Null_Unbounded_String;
      App.Lines (Index).Length := 0;
   end Advance_Row;

   procedure Consume_Character
     (App         : in out State;
      Monkey      : in Integer;
      Code_Point  : in SDL.UTF_8.Code_Points;
      Next_Offset : in Natural)
   is
   begin
      if Monkey >= 0 and then App.Monkey_Chars /= null and then App.Column_Count > 0 then
         declare
            Index : constant Positive :=
              Positive ((Monkey mod Integer (App.Column_Count)) + 1);
         begin
            App.Monkey_Chars (Index) := Code_Point;
         end;
      end if;

      if App.Lines /= null and then App.Row_Count > 0 then
         if Code_Point = Newline_Code then
            Advance_Row (App);
         else
            declare
               Line_Index : constant Positive := Current_Line_Index (App);
            begin
               US.Append (App.Lines (Line_Index).Text, SDL.UTF_8.Encode (Code_Point));
               App.Lines (Line_Index).Length := App.Lines (Line_Index).Length + 1;

               if App.Lines (Line_Index).Length = App.Column_Count then
                  Advance_Row (App);
               end if;
            end;
         end if;
      end if;

      App.Progress_Offset := Next_Offset;
   end Consume_Character;

   function Build_Monkey_Line (App : in State) return String is
      Result : US.Unbounded_String := US.Null_Unbounded_String;
   begin
      if App.Monkey_Chars = null then
         return "";
      end if;

      for Code_Point of App.Monkey_Chars.all loop
         US.Append (Result, SDL.UTF_8.Encode (Code_Point));
      end loop;

      return US.To_String (Result);
   end Build_Monkey_Line;

   function Can_Monkey_Type
     (Code_Point : in SDL.UTF_8.Code_Points) return Boolean
   is
      Modifiers : SDL.Events.Keyboards.Key_Modifiers :=
        SDL.Events.Keyboards.Modifier_None;
      Scan_Code : constant SDL.Events.Keyboards.Scan_Codes :=
        SDL.Events.Keyboards.To_Scan_Code
          (SDL.Events.Keyboards.Key_Codes (Code_Point), Modifiers);
   begin
      if Scan_Code < Min_Monkey_Scan_Code or else Scan_Code > Max_Monkey_Scan_Code then
         return False;
      end if;

      if (Modifiers and not Shift_Modifier) /= 0 then
         return False;
      end if;

      return True;
   end Can_Monkey_Type;

   function Get_Next_Character
     (App         : in out State;
      Next_Offset : out Natural) return SDL.UTF_8.Code_Points
   is
      Candidate_Offset : Natural := App.Progress_Offset;
      Code_Point       : SDL.UTF_8.Code_Points := 0;
   begin
      if App.Source_Text = null then
         Next_Offset := 0;
         return 0;
      end if;

      while App.Progress_Offset < App.Source_Text.all'Length loop
         Candidate_Offset := App.Progress_Offset;
         Code_Point := SDL.UTF_8.Step (App.Source_Text.all, Candidate_Offset);

         if Code_Point = 0 then
            exit;
         elsif Can_Monkey_Type (Code_Point) then
            Next_Offset := Candidate_Offset;
            return Code_Point;
         else
            Consume_Character
              (App         => App,
               Monkey      => -1,
               Code_Point  => Code_Point,
               Next_Offset => Candidate_Offset);
         end if;
      end loop;

      Next_Offset := App.Progress_Offset;
      return 0;
   end Get_Next_Character;

   function Monkey_Play return SDL.UTF_8.Code_Points is
      Scan_Code : constant SDL.Events.Keyboards.Scan_Codes :=
        SDL.Events.Keyboards.Scan_Codes
          (Random_Scan_Codes.Random (Scan_Generator));
      Modifiers : constant SDL.Events.Keyboards.Key_Modifiers :=
        (if Random_Booleans.Random (Shift_Generator) then
            Shift_Modifier
         else
            SDL.Events.Keyboards.Modifier_None);
   begin
      return SDL.UTF_8.Code_Points
        (SDL.Events.Keyboards.To_Key_Code
           (Scan_Code => Scan_Code,
            Modifiers => Modifiers,
            Key_Event => False));
   end Monkey_Play;

   function Caption_Text
     (Monkey_Count : in Natural;
      Elapsed      : in Interfaces.Integer_64) return String
   is
      Total_Seconds : Interfaces.Integer_64 := Elapsed;
      Hours         : Interfaces.Integer_64 := 0;
      Minutes       : Interfaces.Integer_64 := 0;
      Seconds       : Interfaces.Integer_64 := 0;
   begin
      Seconds := Total_Seconds mod 60;
      Total_Seconds := Total_Seconds / 60;
      Minutes := Total_Seconds mod 60;
      Total_Seconds := Total_Seconds / 60;
      Hours := Total_Seconds;

      return
        "Monkeys: "
        & Trim (Natural'Image (Monkey_Count))
        & " - "
        & Trim (Interfaces.Integer_64'Image (Hours))
        & "H:"
        & Trim (Interfaces.Integer_64'Image (Minutes))
        & "M:"
        & Trim (Interfaces.Integer_64'Image (Seconds))
        & "S";
   end Caption_Text;

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
           ("Infinite Monkeys",
            "1.0",
            "com.example.infinite-monkeys"),
         "Unable to set application metadata");

      Require_SDL
        (SDL.Initialise (SDL.Enable_Video),
         "Couldn't initialize SDL");
      App.SDL_Initialized := True;

      SDL.Video.Renderers.Makers.Create
        (Window => App.Window,
         Rend   => App.Renderer,
         Title  => "examples/demo/infinite-monkeys",
         X      => SDL.Video.Windows.Centered_Window_Position,
         Y      => SDL.Video.Windows.Centered_Window_Position,
         Width  => Window_Width,
         Height => Window_Height);

      SDL.Video.Renderers.Set_V_Sync (App.Renderer, 1);

      Parse_Arguments (App.all);
      App.Start_Time := SDL.Time.Current;

      Random_Scan_Codes.Reset (Scan_Generator);
      Random_Booleans.Reset (Shift_Generator);

      On_Window_Size_Changed (App.all);

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
      App          : constant State_Access := To_State (App_State);
      Next_Character : SDL.UTF_8.Code_Points := 0;
      Next_Offset  : Natural := 0;
      Played       : SDL.UTF_8.Code_Points := 0;
      X            : Float := 0.0;
      Y            : Float := 0.0;
      Now          : SDL.Time.Times := 0;
      Elapsed      : Interfaces.Integer_64 := 0;
      Progress_Bar : SDL.Video.Rectangles.Float_Rectangle :=
        (X => 0.0, Y => 0.0, Width => 0.0, Height => Float (Character_Size));
   begin
      if App.Monkey_Count > 0 then
         for Monkey in 0 .. Integer (App.Monkey_Count) - 1 loop
            if Next_Character = 0 then
               Next_Character := Get_Next_Character (App.all, Next_Offset);

               if Next_Character = 0 then
                  exit;
               end if;
            end if;

            Played := Monkey_Play;
            if Played = Next_Character then
               Consume_Character
                 (App         => App.all,
                  Monkey      => Monkey,
                  Code_Point  => Played,
                  Next_Offset => Next_Offset);
               Next_Character := 0;
            end if;
         end loop;
      end if;

      SDL.Video.Renderers.Set_Draw_Colour (App.Renderer, 0.0, 0.0, 0.0, 1.0);
      SDL.Video.Renderers.Clear (App.Renderer);

      SDL.Video.Renderers.Set_Draw_Colour (App.Renderer, 1.0, 1.0, 1.0, 1.0);

      if App.Lines /= null then
         declare
            Row_Offset : Integer :=
              Integer (App.Current_Row) - Integer (App.Row_Count) + 1;
         begin
            if Row_Offset < 0 then
               Row_Offset := 0;
            end if;

            for Offset in 0 .. Integer (App.Row_Count) - 1 loop
               declare
                  Line_Index : constant Positive :=
                    Positive (((Row_Offset + Offset) mod Integer (App.Row_Count)) + 1);
               begin
                  SDL.Video.Renderers.Debug_Text
                    (App.Renderer,
                     X,
                     Y,
                     US.To_String (App.Lines (Line_Index).Text));
                  Y := Y + Float (Character_Size);
               end;
            end loop;
         end;

         Y := Float ((App.Row_Count + 1) * Natural (Character_Size));

         if App.Source_Text /= null and then App.Progress_Offset = App.Source_Text.all'Length then
            if App.End_Time = 0 then
               App.End_Time := SDL.Time.Current;
            end if;

            Now := App.End_Time;
         else
            Now := SDL.Time.Current;
         end if;

         Elapsed := (Now - App.Start_Time) / Nanoseconds_Per_Second;

         SDL.Video.Renderers.Debug_Text
           (App.Renderer,
            X,
            Y,
            Caption_Text (App.Monkey_Count, Elapsed));
         Y := Y + Float (Character_Size);

         SDL.Video.Renderers.Debug_Text
           (App.Renderer,
            X,
            Y,
            Build_Monkey_Line (App.all));
         Y := Y + Float (Character_Size);
      end if;

      SDL.Video.Renderers.Set_Draw_Colour (App.Renderer, 0.0, 1.0, 0.0, 1.0);

      Progress_Bar.X := X;
      Progress_Bar.Y := Y;

      if App.Source_Text /= null
        and then App.Source_Text.all'Length > 0
        and then App.Column_Count > 0
      then
         Progress_Bar.Width :=
           (Float (App.Progress_Offset) / Float (App.Source_Text.all'Length)) *
           Float (App.Column_Count * Natural (Character_Size));
      else
         Progress_Bar.Width := 0.0;
      end if;

      SDL.Video.Renderers.Fill (App.Renderer, Progress_Bar);
      SDL.Video.Renderers.Present (App.Renderer);

      return SDL.Main.App_Continue;
   end App_Iterate;

   function App_Event
     (App_State : in System.Address;
      Event     : access SDL.Events.Queue.Event) return SDL.Main.App_Results
   is
      App : constant State_Access := To_State (App_State);
   begin
      if Event = null then
         return SDL.Main.App_Continue;
      end if;

      if Event.Common.Event_Type = Pixel_Size_Changed_Event then
         On_Window_Size_Changed (App.all);
      elsif Event.Common.Event_Type = SDL.Events.Quit then
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
              "infinite_monkeys exited with status"
              & Integer'Image (Integer (Exit_Code));
         end;
      end if;

      Free_Arguments (Args);
   exception
      when others =>
         Free_Arguments (Args);
         raise;
   end Run;
end Infinite_Monkeys_App;
