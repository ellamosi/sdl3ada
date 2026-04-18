with Interfaces;
with Interfaces.C;
with Interfaces.C.Extensions;
with Interfaces.C.Pointers;
with Interfaces.C.Strings;
with System;

with SDL.Raw.Properties;

package SDL.Raw.Camera is
   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;
   package CS renames Interfaces.C.Strings;

   subtype ID is Interfaces.Unsigned_32;
   subtype Timestamp_Nanoseconds is Interfaces.Unsigned_64;

   type Positions is
     (Unknown_Position,
      Front_Facing,
      Back_Facing)
   with
     Convention => C,
     Size       => C.int'Size;

   for Positions use
     (Unknown_Position => 0,
      Front_Facing     => 1,
      Back_Facing      => 2);

   type Permission_States is
     (Denied,
      Pending,
      Approved)
   with
     Convention => C,
     Size       => C.int'Size;

   for Permission_States use
     (Denied   => -1,
      Pending  => 0,
      Approved => 1);

   type ID_Array is array (C.ptrdiff_t range <>) of aliased ID with
     Convention => C;

   package ID_Pointers is new Interfaces.C.Pointers
     (Index              => C.ptrdiff_t,
      Element            => ID,
      Element_Array      => ID_Array,
      Default_Terminator => 0);

   procedure Free (Memory : in System.Address)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_free";

   function Get_Num_Camera_Drivers return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetNumCameraDrivers";

   function Get_Camera_Driver
     (Index : in C.int) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetCameraDriver";

   function Get_Current_Camera_Driver return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetCurrentCameraDriver";

   function Get_Cameras
     (Count : access C.int) return ID_Pointers.Pointer
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetCameras";

   function Get_Camera_Supported_Formats
     (Instance : in ID;
      Count    : access C.int) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetCameraSupportedFormats";

   function Get_Camera_Name
     (Instance : in ID) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetCameraName";

   function Get_Camera_Position
     (Instance : in ID) return Positions
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetCameraPosition";

   function Open_Camera
     (Instance : in ID;
      Desired  : in System.Address) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_OpenCamera";

   function Get_Camera_Permission_State
     (Self : in System.Address) return Permission_States
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetCameraPermissionState";

   function Get_Camera_ID
     (Self : in System.Address) return ID
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetCameraID";

   function Get_Camera_Properties
     (Self : in System.Address) return SDL.Raw.Properties.ID
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetCameraProperties";

   function Get_Camera_Format
     (Self  : in System.Address;
      Value : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetCameraFormat";

   function Acquire_Camera_Frame
     (Self         : in System.Address;
      Timestamp_NS : access Timestamp_Nanoseconds)
      return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_AcquireCameraFrame";

   procedure Release_Camera_Frame
     (Self  : in System.Address;
      Frame : in System.Address)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_ReleaseCameraFrame";

   procedure Close_Camera
     (Self : in System.Address)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_CloseCamera";
end SDL.Raw.Camera;
