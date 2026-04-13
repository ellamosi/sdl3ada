with Ada.Finalization;
with Interfaces;
with Interfaces.C;

with SDL.C_Pointers;
with SDL.Properties;
with SDL.Video.Pixel_Formats;
with SDL.Video.Surfaces;

package SDL.Cameras is
   pragma Elaborate_Body;

   package C renames Interfaces.C;

   Camera_Error : exception;

   type ID is mod 2 ** 32 with
     Convention => C,
     Size       => 32;

   type ID_Lists is array (Natural range <>) of ID;

   subtype Colour_Spaces is Interfaces.Unsigned_32;

   Unknown_Colour_Space : constant Colour_Spaces := 0;

   type Spec is record
      Format               : SDL.Video.Pixel_Formats.Pixel_Format_Names;
      Colour_Space         : Colour_Spaces;
      Width                : C.int;
      Height               : C.int;
      Framerate_Numerator  : C.int;
      Framerate_Denominator : C.int;
   end record with
     Convention => C;

   type Spec_Lists is array (Natural range <>) of Spec;

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

   subtype Timestamp_Nanoseconds is Interfaces.Unsigned_64;

   type Camera is new Ada.Finalization.Limited_Controlled with private;

   function Total_Drivers return Natural;

   function Driver_Name (Index : in Positive) return String;

   function Current_Driver_Name return String;

   function Get_Cameras return ID_Lists;

   function Supported_Formats (Instance : in ID) return Spec_Lists;

   function Name (Instance : in ID) return String;

   function Position (Instance : in ID) return Positions;

   function Open (Instance : in ID) return Camera;

   function Open
     (Instance : in ID;
      Desired  : in Spec) return Camera;

   procedure Open
     (Self     : in out Camera;
      Instance : in ID);

   procedure Open
     (Self     : in out Camera;
      Instance : in ID;
      Desired  : in Spec);

   overriding
   procedure Finalize (Self : in out Camera);

   procedure Close (Self : in out Camera);

   function Is_Null (Self : in Camera) return Boolean with
     Inline;

   function Permission_State (Self : in Camera) return Permission_States;

   function Get_ID (Self : in Camera) return ID;

   function Get_Properties
     (Self : in Camera) return SDL.Properties.Property_Set;

   function Get_Format
     (Self  : in Camera;
      Value : out Spec) return Boolean;

   function Acquire_Frame
     (Self         : in Camera;
      Timestamp_NS : out Timestamp_Nanoseconds)
      return SDL.Video.Surfaces.Surface;

   procedure Release_Frame
     (Self  : in Camera;
      Frame : in out SDL.Video.Surfaces.Surface);

   function Get_Internal
     (Self : in Camera) return SDL.C_Pointers.Camera_Pointer
   with
     Inline;
private
   type Camera is new Ada.Finalization.Limited_Controlled with
      record
         Internal : SDL.C_Pointers.Camera_Pointer := null;
         Owns     : Boolean := True;
      end record;
end SDL.Cameras;
