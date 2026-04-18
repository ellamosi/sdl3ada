with Interfaces.C;
with Interfaces.C.Extensions;
with System;

with SDL.Raw.C_Pointers;
with SDL.Raw.Properties;

package SDL.Raw.Process is
   pragma Preelaborate;

   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;

   type Process_Object is null record;
   type Process_Access is access all Process_Object with
     Convention => C;

   type Process_IO is
     (Inherited,
      Null_Device,
      Application,
      Redirect)
   with
     Convention => C,
     Size       => C.int'Size;

   for Process_IO use
     (Inherited   => 0,
      Null_Device => 1,
      Application => 2,
      Redirect    => 3);

   Process_Create_Args_Property : constant String :=
     "SDL.process.create.args";
   Process_Create_Environment_Property : constant String :=
     "SDL.process.create.environment";
   Process_Create_Working_Directory_Property : constant String :=
     "SDL.process.create.working_directory";
   Process_Create_Stdin_Property : constant String :=
     "SDL.process.create.stdin_option";
   Process_Create_Stdin_Source_Property : constant String :=
     "SDL.process.create.stdin_source";
   Process_Create_Stdout_Property : constant String :=
     "SDL.process.create.stdout_option";
   Process_Create_Stdout_Source_Property : constant String :=
     "SDL.process.create.stdout_source";
   Process_Create_Stderr_Property : constant String :=
     "SDL.process.create.stderr_option";
   Process_Create_Stderr_Source_Property : constant String :=
     "SDL.process.create.stderr_source";
   Process_Create_Stderr_To_Stdout_Property : constant String :=
     "SDL.process.create.stderr_to_stdout";
   Process_Create_Background_Property : constant String :=
     "SDL.process.create.background";
   Process_Create_Command_Line_Property : constant String :=
     "SDL.process.create.cmdline";

   Process_PID_Property : constant String := "SDL.process.pid";
   Process_Stdin_Property : constant String := "SDL.process.stdin";
   Process_Stdout_Property : constant String := "SDL.process.stdout";
   Process_Stderr_Property : constant String := "SDL.process.stderr";
   Process_Background_Property : constant String := "SDL.process.background";

   procedure Free (Memory : in System.Address)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_free";

   function Create_Process
     (Args        : in System.Address;
      Pipe_Stdio  : in CE.bool) return Process_Access
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CreateProcess";

   function Create_Process_With_Properties
     (Props : in SDL.Raw.Properties.ID) return Process_Access
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CreateProcessWithProperties";

   function Get_Process_Properties
     (Self : in Process_Access) return SDL.Raw.Properties.ID
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetProcessProperties";

   function Read_Process
     (Self      : in Process_Access;
      Data_Size : access C.size_t;
      Exit_Code : access C.int) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ReadProcess";

   function Get_Process_Input
     (Self : in Process_Access) return SDL.Raw.C_Pointers.IO_Stream_Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetProcessInput";

   function Get_Process_Output
     (Self : in Process_Access) return SDL.Raw.C_Pointers.IO_Stream_Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetProcessOutput";

   function Kill_Process
     (Self  : in Process_Access;
      Force : in CE.bool) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_KillProcess";

   function Wait_Process
     (Self      : in Process_Access;
      Block     : in CE.bool;
      Exit_Code : access C.int) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_WaitProcess";

   procedure Destroy_Process (Self : in Process_Access) with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_DestroyProcess";
end SDL.Raw.Process;
