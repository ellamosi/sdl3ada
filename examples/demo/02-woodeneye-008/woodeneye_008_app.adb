with Ada.Command_Line;
with Ada.Numerics;
with Ada.Numerics.Discrete_Random;
with Ada.Numerics.Long_Elementary_Functions;
with Ada.Strings.Fixed;
with Ada.Strings.Unbounded;
with Ada.Unchecked_Conversion;
with Ada.Unchecked_Deallocation;

with Interfaces;
with Interfaces.C;
with Interfaces.C.Strings;
with System;

with SDL;
with SDL.Error;
with SDL.Events;
with SDL.Events.Events;
with SDL.Events.Keyboards;
with SDL.Events.Mice;
with SDL.Hints;
with SDL.Inputs.Mice;
with SDL.Main;
with SDL.Timers;
with SDL.Video.Palettes;
with SDL.Video.Rectangles;
with SDL.Video.Renderers;
with SDL.Video.Renderers.Makers;
with SDL.Video.Windows;

package body Woodeneye_008_App is
   package C renames Interfaces.C;
   package CS renames Interfaces.C.Strings;
   package US renames Ada.Strings.Unbounded;
   package Long_Math renames Ada.Numerics.Long_Elementary_Functions;

   use type C.int;
   use type CS.chars_ptr;
   use type Interfaces.Unsigned_32;
   use type Interfaces.Unsigned_64;
   use type SDL.Events.Event_Types;
   use type SDL.Events.Keyboards.Key_Codes;
   use type SDL.Events.Keyboard_IDs;
   use type SDL.Events.Mice.IDs;
   use type SDL.Main.App_Results;
   use type SDL.Timers.Nanoseconds;

   Window_Width        : constant SDL.Positive_Dimension := 640;
   Window_Height       : constant SDL.Positive_Dimension := 480;
   Map_Box_Scale       : constant Positive := 16;
   Map_Box_Edges_Len   : constant Positive := 12 + Map_Box_Scale * 2;
   Max_Player_Count    : constant Positive := 4;
   Circle_Draw_Sides   : constant Positive := 32;
   Frame_Delay_NS      : constant SDL.Timers.Nanoseconds := 999_999;
   One_Second_NS       : constant SDL.Timers.Nanoseconds := 999_999_999;
   Binary_Angle_Unit   : constant Long_Float := 2_147_483_648.0;
   Mouse_Look_Step     : constant Long_Float :=
     Long_Float (Ada.Numerics.Pi) / 4_096.0;
   Maximum_Pitch       : constant Long_Float :=
     Long_Float (Ada.Numerics.Pi) / 2.0;

   Escape_Key_Code : constant SDL.Events.Keyboards.Key_Codes :=
     SDL.Events.Keyboards.Value ("Escape");
   W_Key_Code      : constant SDL.Events.Keyboards.Key_Codes :=
     SDL.Events.Keyboards.Value ("W");
   A_Key_Code      : constant SDL.Events.Keyboards.Key_Codes :=
     SDL.Events.Keyboards.Value ("A");
   S_Key_Code      : constant SDL.Events.Keyboards.Key_Codes :=
     SDL.Events.Keyboards.Value ("S");
   D_Key_Code      : constant SDL.Events.Keyboards.Key_Codes :=
     SDL.Events.Keyboards.Value ("D");
   Space_Key_Code  : constant SDL.Events.Keyboards.Key_Codes :=
     SDL.Events.Keyboards.Value ("Space");

   subtype Player_Index is Positive range 1 .. Max_Player_Count;
   subtype Optional_Player_Index is Natural range 0 .. Max_Player_Count;
   subtype Edge_Index is Positive range 1 .. Map_Box_Edges_Len;
   subtype Circle_Point_Index is C.size_t range 0 .. C.size_t (Circle_Draw_Sides);
   subtype Random_Byte is Integer range 0 .. 255;

   package Random_Bytes is new Ada.Numerics.Discrete_Random (Random_Byte);

   type Vector_3D is record
      X : Long_Float := 0.0;
      Y : Long_Float := 0.0;
      Z : Long_Float := 0.0;
   end record;

   type Matrix_3x3 is array (Positive range 1 .. 3, Positive range 1 .. 3) of Long_Float;

   type Edge_3D is record
      A : Vector_3D := (others => 0.0);
      B : Vector_3D := (others => 0.0);
   end record;

   type Player_Record is record
      Mouse         : SDL.Events.Mice.IDs := 0;
      Keyboard      : SDL.Events.Keyboard_IDs := 0;
      Position      : Vector_3D := (others => 0.0);
      Velocity      : Vector_3D := (others => 0.0);
      Yaw           : Long_Float := 0.0;
      Pitch         : Long_Float := 0.0;
      Radius        : Long_Float := 0.5;
      Height        : Long_Float := 1.5;
      Colour        : SDL.Video.Palettes.Colour := SDL.Video.Palettes.Null_Colour;
      Move_Forward  : Boolean := False;
      Move_Left     : Boolean := False;
      Move_Backward : Boolean := False;
      Move_Right    : Boolean := False;
      Jump          : Boolean := False;
   end record;

   type Player_List is array (Player_Index) of Player_Record;
   type Edge_List is array (Edge_Index) of Edge_3D;

   type State is record
      Window          : SDL.Video.Windows.Window;
      Renderer        : SDL.Video.Renderers.Renderer;
      Player_Count    : Positive := 1;
      Players         : Player_List;
      Edges           : Edge_List;
      Debug_Text      : US.Unbounded_String := US.Null_Unbounded_String;
      FPS_Accumulator : Interfaces.Unsigned_64 := 0;
      Past_Tick       : SDL.Timers.Nanoseconds := 0;
      FPS_Last_Tick   : SDL.Timers.Nanoseconds := 0;
      SDL_Initialized : Boolean := False;
   end record;

   type State_Access is access all State;
   type Argument_Vector_Access is access CS.chars_ptr_array;

   procedure Free_State is new Ada.Unchecked_Deallocation (State, State_Access);
   procedure Free_Argument_Vector is new Ada.Unchecked_Deallocation
     (CS.chars_ptr_array, Argument_Vector_Access);

   function To_State is new Ada.Unchecked_Conversion (System.Address, State_Access);
   function To_Address is new Ada.Unchecked_Conversion (State_Access, System.Address);

   Random_Generator : Random_Bytes.Generator;

   procedure Require_SDL (Condition : in Boolean; Message : in String);
   procedure Cleanup (App : in out State);
   function Trim (Item : in String) return String;
   function Binary_Angle_To_Radians
     (Value : in Interfaces.Unsigned_32) return Long_Float;
   function Binary_Angle_To_Radians (Value : in Integer) return Long_Float;
   function Clamp
     (Value    : in Long_Float;
      Minimum  : in Long_Float;
      Maximum  : in Long_Float) return Long_Float;
   function Respawn_Coordinate return Long_Float;
   function Whose_Mouse
     (Mouse   : in SDL.Events.Mice.IDs;
      Players : in Player_List;
      Count   : in Positive) return Optional_Player_Index;
   function Whose_Keyboard
     (Keyboard : in SDL.Events.Keyboard_IDs;
      Players  : in Player_List;
      Count    : in Positive) return Optional_Player_Index;
   function First_Free_Mouse_Slot (Players : in Player_List) return Optional_Player_Index;
   function First_Free_Keyboard_Slot (Players : in Player_List) return Optional_Player_Index;
   procedure Shoot
     (Shooter : in Player_Index;
      Players : in out Player_List;
      Count   : in Positive);
   procedure Update
     (Players : in out Player_List;
      Count   : in Positive;
      DT_NS   : in SDL.Timers.Nanoseconds);
   procedure Draw_Circle
     (Renderer : in out SDL.Video.Renderers.Renderer;
      Radius   : in Float;
      X        : in Float;
      Y        : in Float);
   procedure Draw_Clipped_Segment
     (Renderer : in out SDL.Video.Renderers.Renderer;
      AX       : in Float;
      AY       : in Float;
      AZ       : in Float;
      BX       : in Float;
      BY       : in Float;
      BZ       : in Float;
      X        : in Float;
      Y        : in Float;
      Z        : in Float;
      W        : in Float);
   procedure Draw
     (Renderer   : in out SDL.Video.Renderers.Renderer;
      Edges      : in Edge_List;
      Players    : in Player_List;
      Count      : in Positive;
      Debug_Text : in String);
   procedure Init_Players (Players : in out Player_List);
   procedure Init_Edges (Edges : in out Edge_List);

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
      SDL.Video.Renderers.Finalize (App.Renderer);
      SDL.Video.Windows.Finalize (App.Window);

      if App.SDL_Initialized then
         SDL.Quit;
         App.SDL_Initialized := False;
      end if;
   end Cleanup;

   function Trim (Item : in String) return String is
     (Ada.Strings.Fixed.Trim (Item, Ada.Strings.Both));

   function Binary_Angle_To_Radians
     (Value : in Interfaces.Unsigned_32) return Long_Float is
   begin
      return Long_Float (Value) * Long_Float (Ada.Numerics.Pi) / Binary_Angle_Unit;
   end Binary_Angle_To_Radians;

   function Binary_Angle_To_Radians (Value : in Integer) return Long_Float is
   begin
      return Long_Float (Value) * Long_Float (Ada.Numerics.Pi) / Binary_Angle_Unit;
   end Binary_Angle_To_Radians;

   function Clamp
     (Value    : in Long_Float;
      Minimum  : in Long_Float;
      Maximum  : in Long_Float) return Long_Float is
   begin
      if Value < Minimum then
         return Minimum;
      elsif Value > Maximum then
         return Maximum;
      end if;

      return Value;
   end Clamp;

   function Respawn_Coordinate return Long_Float is
   begin
      return
        Long_Float (Map_Box_Scale * (Random_Bytes.Random (Random_Generator) - 128))
          / 256.0;
   end Respawn_Coordinate;

   function Whose_Mouse
     (Mouse   : in SDL.Events.Mice.IDs;
      Players : in Player_List;
      Count   : in Positive) return Optional_Player_Index
   is
   begin
      for Index in 1 .. Count loop
         if Players (Player_Index (Index)).Mouse = Mouse then
            return Index;
         end if;
      end loop;

      return 0;
   end Whose_Mouse;

   function Whose_Keyboard
     (Keyboard : in SDL.Events.Keyboard_IDs;
      Players  : in Player_List;
      Count    : in Positive) return Optional_Player_Index
   is
   begin
      for Index in 1 .. Count loop
         if Players (Player_Index (Index)).Keyboard = Keyboard then
            return Index;
         end if;
      end loop;

      return 0;
   end Whose_Keyboard;

   function First_Free_Mouse_Slot (Players : in Player_List) return Optional_Player_Index is
   begin
      for Index in Player_Index loop
         if Players (Index).Mouse = 0 then
            return Optional_Player_Index (Index);
         end if;
      end loop;

      return 0;
   end First_Free_Mouse_Slot;

   function First_Free_Keyboard_Slot (Players : in Player_List) return Optional_Player_Index is
   begin
      for Index in Player_Index loop
         if Players (Index).Keyboard = 0 then
            return Optional_Player_Index (Index);
         end if;
      end loop;

      return 0;
   end First_Free_Keyboard_Slot;

   procedure Shoot
     (Shooter : in Player_Index;
      Players : in out Player_List;
      Count   : in Positive)
   is
      X_0       : constant Long_Float := Players (Shooter).Position.X;
      Y_0       : constant Long_Float := Players (Shooter).Position.Y;
      Z_0       : constant Long_Float := Players (Shooter).Position.Z;
      Yaw_Rad   : constant Long_Float := Players (Shooter).Yaw;
      Pitch_Rad : constant Long_Float := Players (Shooter).Pitch;
      Cos_Yaw   : constant Long_Float := Long_Math.Cos (Yaw_Rad);
      Sin_Yaw   : constant Long_Float := Long_Math.Sin (Yaw_Rad);
      Cos_Pitch : constant Long_Float := Long_Math.Cos (Pitch_Rad);
      Sin_Pitch : constant Long_Float := Long_Math.Sin (Pitch_Rad);
      VX        : constant Long_Float := -Sin_Yaw * Cos_Pitch;
      VY        : constant Long_Float := Sin_Pitch;
      VZ        : constant Long_Float := -Cos_Yaw * Cos_Pitch;
   begin
      for Index in 1 .. Count loop
         if Index /= Shooter then
            declare
               Target : Player_Record renames Players (Player_Index (Index));
               Hit    : Natural := 0;
            begin
               for Segment in 0 .. 1 loop
                  declare
                     Radius : constant Long_Float := Target.Radius;
                     Height : constant Long_Float := Target.Height;
                     DX     : constant Long_Float := Target.Position.X - X_0;
                     DY     : constant Long_Float :=
                       Target.Position.Y - Y_0
                       + (if Segment = 0 then 0.0 else Radius - Height);
                     DZ     : constant Long_Float := Target.Position.Z - Z_0;
                     VD     : constant Long_Float := VX * DX + VY * DY + VZ * DZ;
                     DD     : constant Long_Float := DX * DX + DY * DY + DZ * DZ;
                     VV     : constant Long_Float := VX * VX + VY * VY + VZ * VZ;
                     RR     : constant Long_Float := Radius * Radius;
                  begin
                     if VD >= 0.0 and then VD * VD >= VV * (DD - RR) then
                        Hit := Hit + 1;
                     end if;
                  end;
               end loop;

               if Hit > 0 then
                  Target.Position :=
                    (X => Respawn_Coordinate,
                     Y => Respawn_Coordinate,
                     Z => Respawn_Coordinate);
               end if;
            end;
         end if;
      end loop;
   end Shoot;

   procedure Update
     (Players : in out Player_List;
      Count   : in Positive;
      DT_NS   : in SDL.Timers.Nanoseconds)
   is
      Rate              : constant Long_Float := 6.0;
      Multiplier        : constant Long_Float := 60.0;
      Gravity           : constant Long_Float := 25.0;
      Jump_Velocity     : constant Long_Float := 8.4375;
      Scale             : constant Long_Float := Long_Float (Map_Box_Scale);
      Time              : constant Long_Float := Long_Float (DT_NS) * 1.0E-9;
      Drag              : constant Long_Float := Long_Math.Exp (-Time * Rate);
      Diff              : constant Long_Float := 1.0 - Drag;
   begin
      for Index in 1 .. Count loop
         declare
            Player : Player_Record renames Players (Player_Index (Index));
            Cosine : constant Long_Float := Long_Math.Cos (Player.Yaw);
            Sine   : constant Long_Float := Long_Math.Sin (Player.Yaw);
            Dir_X  : constant Long_Float :=
              (if Player.Move_Right then 1.0 else 0.0)
              - (if Player.Move_Left then 1.0 else 0.0);
            Dir_Z  : constant Long_Float :=
              (if Player.Move_Backward then 1.0 else 0.0)
              - (if Player.Move_Forward then 1.0 else 0.0);
            Norm   : constant Long_Float := Dir_X * Dir_X + Dir_Z * Dir_Z;
            Acc_X  : constant Long_Float :=
              Multiplier
                * (if Norm = 0.0
                   then 0.0
                   else (Cosine * Dir_X + Sine * Dir_Z) / Long_Math.Sqrt (Norm));
            Acc_Z  : constant Long_Float :=
              Multiplier
                * (if Norm = 0.0
                   then 0.0
                   else (-Sine * Dir_X + Cosine * Dir_Z) / Long_Math.Sqrt (Norm));
            Vel_X  : constant Long_Float := Player.Velocity.X;
            Vel_Y  : constant Long_Float := Player.Velocity.Y;
            Vel_Z  : constant Long_Float := Player.Velocity.Z;
            Bound  : constant Long_Float := Scale - Player.Radius;
            Pos_X  : Long_Float;
            Pos_Y  : Long_Float;
            Pos_Z  : Long_Float;
         begin
            Player.Velocity.X := Player.Velocity.X - Vel_X * Diff;
            Player.Velocity.Y := Player.Velocity.Y - Gravity * Time;
            Player.Velocity.Z := Player.Velocity.Z - Vel_Z * Diff;
            Player.Velocity.X := Player.Velocity.X + Diff * Acc_X / Rate;
            Player.Velocity.Z := Player.Velocity.Z + Diff * Acc_Z / Rate;

            Player.Position.X :=
              Player.Position.X
              + (Time - Diff / Rate) * Acc_X / Rate
              + Diff * Vel_X / Rate;
            Player.Position.Y :=
              Player.Position.Y - 0.5 * Gravity * Time * Time + Vel_Y * Time;
            Player.Position.Z :=
              Player.Position.Z
              + (Time - Diff / Rate) * Acc_Z / Rate
              + Diff * Vel_Z / Rate;

            Pos_X := Clamp (Player.Position.X, -Bound, Bound);
            Pos_Y := Clamp (Player.Position.Y, Player.Height - Scale, Bound);
            Pos_Z := Clamp (Player.Position.Z, -Bound, Bound);

            if Player.Position.X /= Pos_X then
               Player.Velocity.X := 0.0;
            end if;

            if Player.Position.Y /= Pos_Y then
               Player.Velocity.Y := (if Player.Jump then Jump_Velocity else 0.0);
            end if;

            if Player.Position.Z /= Pos_Z then
               Player.Velocity.Z := 0.0;
            end if;

            Player.Position := (X => Pos_X, Y => Pos_Y, Z => Pos_Z);
         end;
      end loop;
   end Update;

   procedure Draw_Circle
     (Renderer : in out SDL.Video.Renderers.Renderer;
      Radius   : in Float;
      X        : in Float;
      Y        : in Float)
   is
      Points : SDL.Video.Rectangles.Float_Point_Arrays (Circle_Point_Index);
   begin
      for Index in Points'Range loop
         declare
            Angle : constant Long_Float :=
              2.0 * Long_Float (Ada.Numerics.Pi) * Long_Float (Index)
                / Long_Float (Circle_Draw_Sides);
         begin
            Points (Index) :=
              (X => X + Radius * Float (Long_Math.Cos (Angle)),
               Y => Y + Radius * Float (Long_Math.Sin (Angle)));
         end;
      end loop;

      SDL.Video.Renderers.Draw_Connected (Renderer, Points);
   end Draw_Circle;

   procedure Draw_Clipped_Segment
     (Renderer : in out SDL.Video.Renderers.Renderer;
      AX       : in Float;
      AY       : in Float;
      AZ       : in Float;
      BX       : in Float;
      BY       : in Float;
      BZ       : in Float;
      X        : in Float;
      Y        : in Float;
      Z        : in Float;
      W        : in Float)
   is
      Local_AX : Float := AX;
      Local_AY : Float := AY;
      Local_AZ : Float := AZ;
      Local_BX : Float := BX;
      Local_BY : Float := BY;
      Local_BZ : Float := BZ;
      DX       : Float;
      DY       : Float;
      T        : Float;
   begin
      if Local_AZ >= -W and then Local_BZ >= -W then
         return;
      end if;

      DX := Local_AX - Local_BX;
      DY := Local_AY - Local_BY;

      if Local_AZ > -W then
         T := (-W - Local_BZ) / (Local_AZ - Local_BZ);
         Local_AX := Local_BX + DX * T;
         Local_AY := Local_BY + DY * T;
         Local_AZ := -W;
      elsif Local_BZ > -W then
         T := (-W - Local_AZ) / (Local_BZ - Local_AZ);
         Local_BX := Local_AX - DX * T;
         Local_BY := Local_AY - DY * T;
         Local_BZ := -W;
      end if;

      Local_AX := -Z * Local_AX / Local_AZ;
      Local_AY := -Z * Local_AY / Local_AZ;
      Local_BX := -Z * Local_BX / Local_BZ;
      Local_BY := -Z * Local_BY / Local_BZ;

      SDL.Video.Renderers.Draw
        (Renderer,
         X + Local_AX,
         Y - Local_AY,
         X + Local_BX,
         Y - Local_BY);
   end Draw_Clipped_Segment;

   procedure Draw
     (Renderer   : in out SDL.Video.Renderers.Renderer;
      Edges      : in Edge_List;
      Players    : in Player_List;
      Count      : in Positive;
      Debug_Text : in String)
   is
      Output_Size : constant SDL.Sizes := SDL.Video.Renderers.Get_Output_Size (Renderer);
      Width_F     : constant Float := Float (Output_Size.Width);
      Height_F    : constant Float := Float (Output_Size.Height);
      Part_Hor    : constant Positive := (if Count > 2 then 2 else 1);
      Part_Ver    : constant Positive := (if Count > 1 then 2 else 1);
      Size_Hor    : constant Float := Width_F / Float (Part_Hor);
      Size_Ver    : constant Float := Height_F / Float (Part_Ver);
   begin
      SDL.Video.Renderers.Set_Draw_Colour (Renderer, 0.0, 0.0, 0.0, 1.0);
      SDL.Video.Renderers.Clear (Renderer);

      for Viewer_Number in 1 .. Count loop
         declare
            Viewer      : Player_Record renames Players (Player_Index (Viewer_Number));
            Mod_X       : constant Float := Float ((Viewer_Number - 1) mod Part_Hor);
            Mod_Y       : constant Float := Float ((Viewer_Number - 1) / Part_Hor);
            Hor_Origin  : constant Float := (Mod_X + 0.5) * Size_Hor;
            Ver_Origin  : constant Float := (Mod_Y + 0.5) * Size_Ver;
            Cam_Origin  : constant Float :=
              Float
                (0.5
                 * Long_Math.Sqrt
                     (Long_Float (Size_Hor * Size_Hor + Size_Ver * Size_Ver)));
            Hor_Offset  : constant Float := Mod_X * Size_Hor;
            Ver_Offset  : constant Float := Mod_Y * Size_Ver;
            Clip_Rect   : constant SDL.Video.Rectangles.Rectangle :=
              (X      => SDL.Coordinate (Integer (Hor_Offset)),
               Y      => SDL.Coordinate (Integer (Ver_Offset)),
               Width  => SDL.Natural_Dimension (Integer (Size_Hor)),
               Height => SDL.Natural_Dimension (Integer (Size_Ver)));
            X_0         : constant Long_Float := Viewer.Position.X;
            Y_0         : constant Long_Float := Viewer.Position.Y;
            Z_0         : constant Long_Float := Viewer.Position.Z;
            Cos_Yaw     : constant Long_Float := Long_Math.Cos (Viewer.Yaw);
            Sin_Yaw     : constant Long_Float := Long_Math.Sin (Viewer.Yaw);
            Cos_Pitch   : constant Long_Float := Long_Math.Cos (Viewer.Pitch);
            Sin_Pitch   : constant Long_Float := Long_Math.Sin (Viewer.Pitch);
            Mat         : constant Matrix_3x3 :=
              ((1 => Cos_Yaw,             2 => 0.0,       3 => -Sin_Yaw),
               (1 => Sin_Yaw * Sin_Pitch, 2 => Cos_Pitch, 3 => Cos_Yaw * Sin_Pitch),
               (1 => Sin_Yaw * Cos_Pitch, 2 => -Sin_Pitch, 3 => Cos_Yaw * Cos_Pitch));
         begin
            SDL.Video.Renderers.Set_Clip (Renderer, Clip_Rect);
            SDL.Video.Renderers.Set_Draw_Colour (Renderer, 64.0 / 255.0, 64.0 / 255.0, 64.0 / 255.0, 1.0);

            for Edge of Edges loop
               declare
                  AX : constant Float :=
                    Float
                      (Mat (1, 1) * (Edge.A.X - X_0)
                       + Mat (1, 2) * (Edge.A.Y - Y_0)
                       + Mat (1, 3) * (Edge.A.Z - Z_0));
                  AY : constant Float :=
                    Float
                      (Mat (2, 1) * (Edge.A.X - X_0)
                       + Mat (2, 2) * (Edge.A.Y - Y_0)
                       + Mat (2, 3) * (Edge.A.Z - Z_0));
                  AZ : constant Float :=
                    Float
                      (Mat (3, 1) * (Edge.A.X - X_0)
                       + Mat (3, 2) * (Edge.A.Y - Y_0)
                       + Mat (3, 3) * (Edge.A.Z - Z_0));
                  BX : constant Float :=
                    Float
                      (Mat (1, 1) * (Edge.B.X - X_0)
                       + Mat (1, 2) * (Edge.B.Y - Y_0)
                       + Mat (1, 3) * (Edge.B.Z - Z_0));
                  BY : constant Float :=
                    Float
                      (Mat (2, 1) * (Edge.B.X - X_0)
                       + Mat (2, 2) * (Edge.B.Y - Y_0)
                       + Mat (2, 3) * (Edge.B.Z - Z_0));
                  BZ : constant Float :=
                    Float
                      (Mat (3, 1) * (Edge.B.X - X_0)
                       + Mat (3, 2) * (Edge.B.Y - Y_0)
                       + Mat (3, 3) * (Edge.B.Z - Z_0));
               begin
                  Draw_Clipped_Segment
                    (Renderer,
                     AX,
                     AY,
                     AZ,
                     BX,
                     BY,
                     BZ,
                     Hor_Origin,
                     Ver_Origin,
                     Cam_Origin,
                     1.0);
               end;
            end loop;

            for Target_Number in 1 .. Count loop
               if Target_Number /= Viewer_Number then
                  declare
                     Target : Player_Record renames Players (Player_Index (Target_Number));
                  begin
                     SDL.Video.Renderers.Set_Draw_Colour (Renderer, Target.Colour);

                     for Circle in 0 .. 1 loop
                        declare
                           RX : constant Long_Float := Target.Position.X - Viewer.Position.X;
                           RY : constant Long_Float :=
                             Target.Position.Y - Viewer.Position.Y
                             + (Target.Radius - Target.Height) * Long_Float (Circle);
                           RZ : constant Long_Float := Target.Position.Z - Viewer.Position.Z;
                           DX : constant Long_Float :=
                             Mat (1, 1) * RX + Mat (1, 2) * RY + Mat (1, 3) * RZ;
                           DY : constant Long_Float :=
                             Mat (2, 1) * RX + Mat (2, 2) * RY + Mat (2, 3) * RZ;
                           DZ : constant Long_Float :=
                             Mat (3, 1) * RX + Mat (3, 2) * RY + Mat (3, 3) * RZ;
                           Effective_Radius : constant Long_Float :=
                             Target.Radius * Long_Float (Cam_Origin) / DZ;
                        begin
                           if DZ < 0.0 then
                              Draw_Circle
                                (Renderer,
                                 Float (Effective_Radius),
                                 Float (Long_Float (Hor_Origin) - Long_Float (Cam_Origin) * DX / DZ),
                                 Float (Long_Float (Ver_Origin) + Long_Float (Cam_Origin) * DY / DZ));
                           end if;
                        end;
                     end loop;
                  end;
               end if;
            end loop;

            SDL.Video.Renderers.Set_Draw_Colour (Renderer, 1.0, 1.0, 1.0, 1.0);
            SDL.Video.Renderers.Draw
              (Renderer, Hor_Origin, Ver_Origin - 10.0, Hor_Origin, Ver_Origin + 10.0);
            SDL.Video.Renderers.Draw
              (Renderer, Hor_Origin - 10.0, Ver_Origin, Hor_Origin + 10.0, Ver_Origin);
         end;
      end loop;

      SDL.Video.Renderers.Disable_Clip (Renderer);
      SDL.Video.Renderers.Set_Draw_Colour (Renderer, 1.0, 1.0, 1.0, 1.0);
      SDL.Video.Renderers.Debug_Text (Renderer, 0.0, 0.0, Debug_Text);
      SDL.Video.Renderers.Present (Renderer);
   end Draw;

   procedure Init_Players (Players : in out Player_List) is
      Green   : constant SDL.Video.Palettes.Colour :=
        (Red => 0, Green => 255, Blue => 0, Alpha => 255);
      Magenta : constant SDL.Video.Palettes.Colour :=
        (Red => 255, Green => 0, Blue => 255, Alpha => 255);
      Red     : constant SDL.Video.Palettes.Colour :=
        (Red => 255, Green => 0, Blue => 0, Alpha => 255);
      Cyan    : constant SDL.Video.Palettes.Colour :=
        (Red => 0, Green => 255, Blue => 255, Alpha => 255);
      Colours : constant array (Player_Index) of SDL.Video.Palettes.Colour :=
        (1 => Green, 2 => Magenta, 3 => Red, 4 => Cyan);
   begin
      for Index in Player_Index loop
         declare
            Sign_X : constant Long_Float := (if (Index mod 2) = 0 then -1.0 else 1.0);
            Sign_Z : constant Long_Float := (if Index > 2 then -1.0 else 1.0);
            Base   : constant Long_Float := 8.0 * Sign_X;
         begin
            Players (Index) :=
              (Mouse         => 0,
               Keyboard      => 0,
               Position      => (X => Base, Y => 0.0, Z => Base * Sign_Z),
               Velocity      => (others => 0.0),
               Yaw           =>
                 Binary_Angle_To_Radians
                   (Interfaces.Unsigned_32
                      (16#2000_0000#
                       + (if (Index mod 2) = 0 then 16#8000_0000# else 0)
                       + (if Index > 2 then 16#4000_0000# else 0))),
               Pitch         => Binary_Angle_To_Radians (Integer'(-16#0800_0000#)),
               Radius        => 0.5,
               Height        => 1.5,
               Colour        => Colours (Index),
               Move_Forward  => False,
               Move_Left     => False,
               Move_Backward => False,
               Move_Right    => False,
               Jump          => False);
         end;
      end loop;
   end Init_Players;

   procedure Init_Edges (Edges : in out Edge_List) is
      Radius : constant Long_Float := Long_Float (Map_Box_Scale);
      Map    : constant array (Positive range 1 .. 24) of Interfaces.Unsigned_32 :=
        (0, 1, 1, 3, 3, 2, 2, 0,
         7, 6, 6, 4, 4, 5, 5, 7,
         6, 2, 3, 7, 0, 4, 5, 1);
   begin
      for Index in 1 .. 12 loop
         for Axis in 0 .. 2 loop
            declare
               Mask : constant Interfaces.Unsigned_32 :=
                 Interfaces.Unsigned_32 (2 ** Axis);
               A    : constant Interfaces.Unsigned_32 := Map (Index * 2 - 1);
               B    : constant Interfaces.Unsigned_32 := Map (Index * 2);
            begin
               case Axis is
                  when 0 =>
                     Edges (Index).A.X := (if (A and Mask) /= 0 then Radius else -Radius);
                     Edges (Index).B.X := (if (B and Mask) /= 0 then Radius else -Radius);
                  when 1 =>
                     Edges (Index).A.Y := (if (A and Mask) /= 0 then Radius else -Radius);
                     Edges (Index).B.Y := (if (B and Mask) /= 0 then Radius else -Radius);
                  when 2 =>
                     Edges (Index).A.Z := (if (A and Mask) /= 0 then Radius else -Radius);
                     Edges (Index).B.Z := (if (B and Mask) /= 0 then Radius else -Radius);
                  when others =>
                     null;
               end case;
            end;
         end loop;
      end loop;

      for Index in 0 .. Map_Box_Scale - 1 loop
         declare
            D : constant Long_Float := Long_Float (Index * 2) - Radius;
         begin
            Edges (13 + Index).A := (X => -Radius, Y => -Radius, Z => D);
            Edges (13 + Index).B := (X => Radius, Y => -Radius, Z => D);
            Edges (13 + Map_Box_Scale + Index).A := (X => D, Y => -Radius, Z => -Radius);
            Edges (13 + Map_Box_Scale + Index).B := (X => D, Y => -Radius, Z => Radius);
         end;
      end loop;
   end Init_Edges;

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
           ("Example splitscreen shooter game",
            "1.0",
            "com.example.woodeneye-008"),
         "Unable to set application metadata");

      Require_SDL
        (SDL.Set_App_Metadata_Property
           (SDL.App_Metadata_URL_Property,
            "https://examples.libsdl.org/SDL3/demo/02-woodeneye-008/"),
         "Unable to set application URL metadata");
      Require_SDL
        (SDL.Set_App_Metadata_Property
           (SDL.App_Metadata_Creator_Property,
            "SDL team"),
         "Unable to set application creator metadata");
      Require_SDL
        (SDL.Set_App_Metadata_Property
           (SDL.App_Metadata_Copyright_Property,
            "Placed in the public domain"),
         "Unable to set application copyright metadata");
      Require_SDL
        (SDL.Set_App_Metadata_Property
           (SDL.App_Metadata_Type_Property,
            "game"),
         "Unable to set application type metadata");

      Require_SDL
        (SDL.Initialise (SDL.Enable_Video),
         "Couldn't initialize SDL");
      App.SDL_Initialized := True;

      SDL.Video.Renderers.Makers.Create
        (Window   => App.Window,
         Rend     => App.Renderer,
         Title    => "examples/demo/woodeneye-008",
         Position => SDL.Video.Windows.Centered_Window_Position,
         Size     => (Width => Window_Width, Height => Window_Height),
         Flags    => SDL.Video.Windows.Resizable);

      Init_Players (App.Players);
      Init_Edges (App.Edges);

      SDL.Video.Renderers.Set_V_Sync (App.Renderer, 0);
      SDL.Inputs.Mice.Set_Relative_Mode (App.Window, True);
      SDL.Hints.Set (SDL.Hints.Windows_Raw_Keyboard, "1", SDL.Hints.Override);

      Random_Bytes.Reset (Random_Generator);
      App.Debug_Text := US.Null_Unbounded_String;
      App.Past_Tick := SDL.Timers.Ticks_NS;
      App.FPS_Last_Tick := App.Past_Tick;

      App_State.all := To_Address (App);
      return SDL.Main.App_Continue;
   exception
      when others =>
         Cleanup (App.all);
         Free_State (App);
         raise;
   end App_Init;

   function App_Event
     (App_State : in System.Address;
      Event     : access SDL.Events.Events.Events) return SDL.Main.App_Results
   is
      App : constant State_Access := To_State (App_State);
   begin
      case Event.Common.Event_Type is
         when SDL.Events.Quit =>
            return SDL.Main.App_Success;

         when SDL.Events.Mice.Mouse_Removed =>
            for Index in 1 .. App.Player_Count loop
               if App.Players (Player_Index (Index)).Mouse =
                    Event.Mouse_Device.Which
               then
                  App.Players (Player_Index (Index)).Mouse := 0;
               end if;
            end loop;

         when SDL.Events.Keyboards.Keyboard_Removed =>
            for Index in 1 .. App.Player_Count loop
               if App.Players (Player_Index (Index)).Keyboard =
                    Event.Keyboard_Device.Which
               then
                  App.Players (Player_Index (Index)).Keyboard := 0;
               end if;
            end loop;

         when SDL.Events.Mice.Motion =>
            declare
               ID    : constant SDL.Events.Mice.IDs := Event.Mouse_Motion.Which;
               Index : constant Optional_Player_Index :=
                 Whose_Mouse (ID, App.Players, App.Player_Count);
            begin
               if Index /= 0 then
                  App.Players (Player_Index (Index)).Yaw :=
                    App.Players (Player_Index (Index)).Yaw
                    - Long_Float (Event.Mouse_Motion.X_Relative) * Mouse_Look_Step;
                  App.Players (Player_Index (Index)).Pitch :=
                    Clamp
                      (App.Players (Player_Index (Index)).Pitch
                       - Long_Float (Event.Mouse_Motion.Y_Relative) * Mouse_Look_Step,
                       -Maximum_Pitch,
                       Maximum_Pitch);
               elsif ID /= 0 then
                  declare
                     Slot : constant Optional_Player_Index :=
                       First_Free_Mouse_Slot (App.Players);
                  begin
                     if Slot /= 0 then
                        App.Players (Player_Index (Slot)).Mouse := ID;
                        App.Player_Count := Positive'Max (App.Player_Count, Positive (Slot));
                     end if;
                  end;
               end if;
            end;

         when SDL.Events.Mice.Button_Down =>
            declare
               ID    : constant SDL.Events.Mice.IDs := Event.Mouse_Button.Which;
               Index : constant Optional_Player_Index :=
                 Whose_Mouse (ID, App.Players, App.Player_Count);
            begin
               if Index /= 0 then
                  Shoot (Player_Index (Index), App.Players, App.Player_Count);
               end if;
            end;

         when SDL.Events.Keyboards.Key_Down =>
            declare
               Key   : constant SDL.Events.Keyboards.Key_Codes :=
                 Event.Keyboard.Key_Sym.Key_Code;
               ID    : constant SDL.Events.Keyboard_IDs := Event.Keyboard.Which;
               Index : constant Optional_Player_Index :=
                 Whose_Keyboard (ID, App.Players, App.Player_Count);
            begin
               if Index /= 0 then
                  if Key = W_Key_Code then
                     App.Players (Player_Index (Index)).Move_Forward := True;
                  end if;

                  if Key = A_Key_Code then
                     App.Players (Player_Index (Index)).Move_Left := True;
                  end if;

                  if Key = S_Key_Code then
                     App.Players (Player_Index (Index)).Move_Backward := True;
                  end if;

                  if Key = D_Key_Code then
                     App.Players (Player_Index (Index)).Move_Right := True;
                  end if;

                  if Key = Space_Key_Code then
                     App.Players (Player_Index (Index)).Jump := True;
                  end if;
               elsif ID /= 0 then
                  declare
                     Slot : constant Optional_Player_Index :=
                       First_Free_Keyboard_Slot (App.Players);
                  begin
                     if Slot /= 0 then
                        App.Players (Player_Index (Slot)).Keyboard := ID;
                        App.Player_Count := Positive'Max (App.Player_Count, Positive (Slot));
                     end if;
                  end;
               end if;
            end;

         when SDL.Events.Keyboards.Key_Up =>
            declare
               Key   : constant SDL.Events.Keyboards.Key_Codes :=
                 Event.Keyboard.Key_Sym.Key_Code;
               ID    : constant SDL.Events.Keyboard_IDs := Event.Keyboard.Which;
               Index : constant Optional_Player_Index :=
                 Whose_Keyboard (ID, App.Players, App.Player_Count);
            begin
               if Key = Escape_Key_Code then
                  return SDL.Main.App_Success;
               end if;

               if Index /= 0 then
                  if Key = W_Key_Code then
                     App.Players (Player_Index (Index)).Move_Forward := False;
                  end if;

                  if Key = A_Key_Code then
                     App.Players (Player_Index (Index)).Move_Left := False;
                  end if;

                  if Key = S_Key_Code then
                     App.Players (Player_Index (Index)).Move_Backward := False;
                  end if;

                  if Key = D_Key_Code then
                     App.Players (Player_Index (Index)).Move_Right := False;
                  end if;

                  if Key = Space_Key_Code then
                     App.Players (Player_Index (Index)).Jump := False;
                  end if;
               end if;
            end;

         when others =>
            null;
      end case;

      return SDL.Main.App_Continue;
   end App_Event;

   function App_Iterate
     (App_State : in System.Address) return SDL.Main.App_Results
   is
      App     : constant State_Access := To_State (App_State);
      Now     : constant SDL.Timers.Nanoseconds := SDL.Timers.Ticks_NS;
      Delta_NS : constant SDL.Timers.Nanoseconds := Now - App.Past_Tick;
   begin
      Update (App.Players, App.Player_Count, Delta_NS);
      Draw
        (App.Renderer,
         App.Edges,
         App.Players,
         App.Player_Count,
         US.To_String (App.Debug_Text));

      if Now - App.FPS_Last_Tick > One_Second_NS then
         App.FPS_Last_Tick := Now;
         App.Debug_Text :=
           US.To_Unbounded_String
             (Trim (Interfaces.Unsigned_64'Image (App.FPS_Accumulator)) & " fps");
         App.FPS_Accumulator := 0;
      end if;

      App.Past_Tick := Now;
      App.FPS_Accumulator := App.FPS_Accumulator + 1;

      declare
         Elapsed : constant SDL.Timers.Nanoseconds := SDL.Timers.Ticks_NS - Now;
      begin
         if Elapsed < Frame_Delay_NS then
            SDL.Timers.Wait_Delay_NS (Frame_Delay_NS - Elapsed);
         end if;
      end;

      return SDL.Main.App_Continue;
   end App_Iterate;

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

      Free_Arguments (Args);

      if Exit_Code /= 0 then
         raise Program_Error with
           "woodeneye_008 exited with status" & Integer'Image (Integer (Exit_Code));
      end if;
   exception
      when others =>
         Free_Arguments (Args);
         raise;
   end Run;
end Woodeneye_008_App;
