with Ada.Unchecked_Conversion;
with Interfaces.C.Strings;

with SDL.Error;
with SDL.Raw.Video;
with SDL.Raw.Vulkan;

package body SDL.Video.Vulkan is
   package CS renames Interfaces.C.Strings;
   package Raw_Video renames SDL.Raw.Video;
   package Raw is new SDL.Raw.Vulkan (Instance_Address_Type, Surface_Type);

   use type C.ptrdiff_t;
   use type Interfaces.Unsigned_32;
   use type CS.chars_ptr;
   use type Raw.Extension_Pointers.Pointer;

   function To_Window_Pointer is new Ada.Unchecked_Conversion
     (Source => System.Address,
      Target => Raw_Video.Window_Pointer);

   procedure Create_Surface
     (Window   : in SDL.Video.Windows.Window;
      Instance : in Instance_Address_Type;
      Surface  : out Surface_Type)
   is
   begin
      Create_Surface
        (Window    => Window,
         Instance  => Instance,
         Surface   => Surface,
         Allocator => System.Null_Address);
   end Create_Surface;

   procedure Create_Surface
     (Window    : in SDL.Video.Windows.Window;
      Instance  : in Instance_Address_Type;
      Surface   : out Surface_Type;
      Allocator : in System.Address)
   is
   begin
      if not Boolean
          (Raw.Create_Surface
             (SDL.Video.Windows.Get_Internal (Window),
              Instance,
              Allocator,
              Surface))
      then
         raise SDL_Vulkan_Error with SDL.Error.Get;
      end if;
   end Create_Surface;

   procedure Destroy_Surface
     (Instance  : in Instance_Address_Type;
      Surface   : in Surface_Type;
      Allocator : in System.Address := System.Null_Address)
   is
   begin
      Raw.Destroy_Surface (Instance, Surface, Allocator);
   end Destroy_Surface;

   procedure Get_Drawable_Size
     (Window        : in SDL.Video.Windows.Window;
      Width, Height : out SDL.Natural_Dimension)
   is
      Raw_Width  : aliased C.int := 0;
      Raw_Height : aliased C.int := 0;
   begin
      if not Boolean
          (Raw_Video.Get_Window_Size_In_Pixels
             (To_Window_Pointer (SDL.Video.Windows.Get_Internal (Window)),
              Raw_Width'Access,
              Raw_Height'Access))
      then
         raise SDL_Vulkan_Error with SDL.Error.Get;
      end if;

      Width := SDL.Natural_Dimension (Raw_Width);
      Height := SDL.Natural_Dimension (Raw_Height);
   end Get_Drawable_Size;

   function Get_Instance_Extensions return Extension_Name_Arrays
   is
      Count : aliased Interfaces.Unsigned_32 := 0;
      Names : constant Raw.Extension_Pointers.Pointer :=
        Raw.Get_Instance_Extensions (Count'Access);
   begin
      if Names = null or else Count = 0 then
         return Null_Extension_Name_Array;
      end if;

      declare
         Source : constant Raw.Extension_Name_Array :=
           Raw.Extension_Pointers.Value (Names, C.ptrdiff_t (Count));
         Result : Extension_Name_Arrays (1 .. Positive (Count));
         use Ada.Strings.Unbounded;
      begin
         for Index in Result'Range loop
            declare
               Raw_Name : constant CS.chars_ptr :=
                 Source (Source'First + C.ptrdiff_t (Index - Result'First));
            begin
               if Raw_Name = CS.Null_Ptr then
                  Result (Index) := Null_Unbounded_String;
               else
                  Result (Index) := To_Unbounded_String (CS.Value (Raw_Name));
               end if;
            end;
         end loop;

         return Result;
      end;
   end Get_Instance_Extensions;

   function Get_Instance_Extensions
     (Window : in SDL.Video.Windows.Window) return Extension_Name_Arrays
   is
      pragma Unreferenced (Window);
   begin
      return Get_Instance_Extensions;
   end Get_Instance_Extensions;

   function Get_Instance_Procedure_Address return Instance_Address_Type is
      Result : constant Instance_Address_Type :=
        Raw.Get_Vk_Get_Instance_Proc_Addr;
   begin
      if Result = Instance_Null then
         raise SDL_Vulkan_Error with SDL.Error.Get;
      end if;

      return Result;
   end Get_Instance_Procedure_Address;

   function Get_Presentation_Support
     (Instance           : in Instance_Address_Type;
      Physical_Device    : in System.Address;
      Queue_Family_Index : in Interfaces.Unsigned_32) return Boolean
   is
   begin
      return Boolean
        (Raw.Get_Presentation_Support
           (Instance, Physical_Device, Queue_Family_Index));
   end Get_Presentation_Support;

   procedure Load_Library is
   begin
      if not Boolean (Raw.Load_Library (CS.Null_Ptr)) then
         raise SDL_Vulkan_Error with SDL.Error.Get;
      end if;
   end Load_Library;

   procedure Load_Library (Path : in String) is
   begin
      if not Boolean (Raw.Load_Library (C.To_C (Path))) then
         raise SDL_Vulkan_Error with SDL.Error.Get;
      end if;
   end Load_Library;

   procedure Unload_Library is
   begin
      Raw.Unload_Library;
   end Unload_Library;
end SDL.Video.Vulkan;
