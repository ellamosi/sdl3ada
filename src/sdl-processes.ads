with Ada.Finalization;
with Ada.Strings.Unbounded;
with Interfaces.C;

with SDL.Properties;
with SDL.Raw.Process;

package SDL.Processes is
   pragma Elaborate_Body;

   package C renames Interfaces.C;
   package US renames Ada.Strings.Unbounded;

   Process_Error : exception;

   subtype IO_Modes is SDL.Raw.Process.Process_IO;
   subtype Process_Handle is SDL.Raw.Process.Process_Access;

   Inherited_IO   : constant IO_Modes := SDL.Raw.Process.Inherited;
   Null_IO        : constant IO_Modes := SDL.Raw.Process.Null_Device;
   Application_IO : constant IO_Modes := SDL.Raw.Process.Application;
   Redirected_IO  : constant IO_Modes := SDL.Raw.Process.Redirect;

   Process_Create_Args_Property : constant String :=
     SDL.Raw.Process.Process_Create_Args_Property;
   Process_Create_Environment_Property : constant String :=
     SDL.Raw.Process.Process_Create_Environment_Property;
   Process_Create_Working_Directory_Property : constant String :=
     SDL.Raw.Process.Process_Create_Working_Directory_Property;
   Process_Create_Stdin_Property : constant String :=
     SDL.Raw.Process.Process_Create_Stdin_Property;
   Process_Create_Stdin_Source_Property : constant String :=
     SDL.Raw.Process.Process_Create_Stdin_Source_Property;
   Process_Create_Stdout_Property : constant String :=
     SDL.Raw.Process.Process_Create_Stdout_Property;
   Process_Create_Stdout_Source_Property : constant String :=
     SDL.Raw.Process.Process_Create_Stdout_Source_Property;
   Process_Create_Stderr_Property : constant String :=
     SDL.Raw.Process.Process_Create_Stderr_Property;
   Process_Create_Stderr_Source_Property : constant String :=
     SDL.Raw.Process.Process_Create_Stderr_Source_Property;
   Process_Create_Stderr_To_Stdout_Property : constant String :=
     SDL.Raw.Process.Process_Create_Stderr_To_Stdout_Property;
   Process_Create_Background_Property : constant String :=
     SDL.Raw.Process.Process_Create_Background_Property;
   Process_Create_Command_Line_Property : constant String :=
     SDL.Raw.Process.Process_Create_Command_Line_Property;

   Process_PID_Property : constant String :=
     SDL.Raw.Process.Process_PID_Property;
   Process_Stdin_Property : constant String :=
     SDL.Raw.Process.Process_Stdin_Property;
   Process_Stdout_Property : constant String :=
     SDL.Raw.Process.Process_Stdout_Property;
   Process_Stderr_Property : constant String :=
     SDL.Raw.Process.Process_Stderr_Property;
   Process_Background_Property : constant String :=
     SDL.Raw.Process.Process_Background_Property;

   type Argument_List is array (Positive range <>) of US.Unbounded_String;

   function To_Argument (Value : in String) return US.Unbounded_String
     renames US.To_Unbounded_String;

   type Process is new Ada.Finalization.Limited_Controlled with private;

   overriding
   procedure Finalize (Self : in out Process);

   function Create
     (Arguments   : in Argument_List;
      Pipe_Stdio  : in Boolean := False) return Process;

   procedure Create
     (Self        : in out Process;
      Arguments   : in Argument_List;
      Pipe_Stdio  : in Boolean := False);

   function Create
     (Arguments  : in Argument_List;
      Properties : in SDL.Properties.Property_Set) return Process;

   procedure Create
     (Self       : in out Process;
      Arguments  : in Argument_List;
      Properties : in SDL.Properties.Property_Set);

   procedure Destroy (Self : in out Process);

   function Is_Null (Self : in Process) return Boolean with
     Inline;

   function Get_Handle
     (Self : in Process) return Process_Handle with
     Inline;

   function Get_Properties
     (Self : in Process) return SDL.Properties.Property_Set;

   function PID
     (Self : in Process) return SDL.Properties.Property_Numbers;

   function Is_Background (Self : in Process) return Boolean;

   function Has_Input (Self : in Process) return Boolean;
   function Has_Output (Self : in Process) return Boolean;
   function Has_Error_Output (Self : in Process) return Boolean;

   procedure Write_Input
     (Self : in Process;
      Data : in String);

   procedure Close_Input (Self : in Process);
   procedure Close_Output (Self : in Process);
   procedure Close_Error_Output (Self : in Process);

   function Read_All_Output
     (Self      : in Process;
      Exit_Code : out C.int) return String;

   function Wait
     (Self      : in Process;
      Block     : in Boolean := True;
      Exit_Code : out C.int) return Boolean;

   function Kill
     (Self  : in Process;
      Force : in Boolean := False) return Boolean;
private
   type Process is new Ada.Finalization.Limited_Controlled with
      record
         Internal : SDL.Raw.Process.Process_Access := null;
      end record;
end SDL.Processes;
