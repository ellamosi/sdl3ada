with Ada.Strings.UTF_Encoding;
with System.Storage_Elements;

with SDL.RWops;

package SDL.Video.Surfaces.Makers is
   pragma Preelaborate;
   pragma Elaborate_Body;

   package UTF_Strings renames Ada.Strings.UTF_Encoding;

   procedure Create
     (Self       : in out Surface;
      Size       : in SDL.Sizes;
      BPP        : in Pixel_Depths;
      Red_Mask   : in Colour_Masks;
      Blue_Mask  : in Colour_Masks;
      Green_Mask : in Colour_Masks;
      Alpha_Mask : in Colour_Masks);

   generic
      type Element is private;
      type Element_Pointer is access all Element;
   procedure Create_From
     (Self       : in out Surface;
      Pixels     : in Element_Pointer;
      Size       : in SDL.Sizes;
      BPP        : in Pixel_Depths := Element'Size;
      Pitch      : in System.Storage_Elements.Storage_Offset;
      Red_Mask   : in Colour_Masks;
      Green_Mask : in Colour_Masks;
      Blue_Mask  : in Colour_Masks;
      Alpha_Mask : in Colour_Masks);

   generic
      type Element is private;
      type Index is (<>);
      type Element_Array is array (Index range <>, Index range <>) of Element;
   procedure Create_From_Array
     (Self       : in out Surface;
      Pixels     : access Element_Array;
      Red_Mask   : in Colour_Masks;
      Green_Mask : in Colour_Masks;
      Blue_Mask  : in Colour_Masks;
      Alpha_Mask : in Colour_Masks);

   procedure Create
     (Self      : in out Surface;
      File_Name : in UTF_Strings.UTF_String);

   procedure Create
     (Self        : in out Surface;
      Source      : in SDL.RWops.RWops;
      Close_After : in Boolean := False);

   procedure Load
     (Self      : in out Surface;
      File_Name : in UTF_Strings.UTF_String) renames Create;

   procedure Load
     (Self        : in out Surface;
      Source      : in SDL.RWops.RWops;
      Close_After : in Boolean := False) renames Create;

   procedure Load_BMP
     (Self      : in out Surface;
      File_Name : in UTF_Strings.UTF_String);

   procedure Load_BMP
     (Self        : in out Surface;
      Source      : in SDL.RWops.RWops;
      Close_After : in Boolean := False);

   procedure Load_PNG
     (Self      : in out Surface;
      File_Name : in UTF_Strings.UTF_String);

   procedure Load_PNG
     (Self        : in out Surface;
      Source      : in SDL.RWops.RWops;
      Close_After : in Boolean := False);

   procedure Convert
     (Self         : in out Surface;
      Src          : SDL.Video.Surfaces.Surface;
      Pixel_Format : SDL.Video.Pixel_Formats.Pixel_Format_Access);
private
   function Get_Internal_Surface
     (Self : in Surface) return Internal_Surface_Pointer
   with
     Export     => True,
     Convention => Ada;

   function Make_Surface_From_Pointer
     (S    : in Internal_Surface_Pointer;
      Owns : in Boolean := False) return Surface
   with
     Export     => True,
     Convention => Ada;
end SDL.Video.Surfaces.Makers;
