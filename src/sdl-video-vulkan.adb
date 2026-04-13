with Interfaces.C.Extensions;
with Interfaces.C.Strings;

with SDL.Error;

package body SDL.Video.Vulkan is
   package CE renames Interfaces.C.Extensions;
   package CS renames Interfaces.C.Strings;

   use type Interfaces.Unsigned_32;
   use type System.Address;
   use type CS.chars_ptr;

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
      function SDL_Vulkan_Create_Surface
        (Window    : in System.Address;
         Instance  : in Instance_Address_Type;
         Allocator : in System.Address;
         Surface   : out Surface_Type) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_Vulkan_CreateSurface";
   begin
      if not Boolean
          (SDL_Vulkan_Create_Surface
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
      procedure SDL_Vulkan_Destroy_Surface
        (Instance  : in Instance_Address_Type;
         Surface   : in Surface_Type;
         Allocator : in System.Address)
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_Vulkan_DestroySurface";
   begin
      SDL_Vulkan_Destroy_Surface (Instance, Surface, Allocator);
   end Destroy_Surface;

   procedure Get_Drawable_Size
     (Window        : in SDL.Video.Windows.Window;
      Width, Height : out SDL.Natural_Dimension)
   is
      function SDL_Get_Window_Size_In_Pixels
        (Value  : in System.Address;
         Width  : access C.int;
         Height : access C.int) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetWindowSizeInPixels";

      Raw_Width  : aliased C.int := 0;
      Raw_Height : aliased C.int := 0;
   begin
      if not Boolean
          (SDL_Get_Window_Size_In_Pixels
             (SDL.Video.Windows.Get_Internal (Window),
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
      function SDL_Vulkan_Get_Instance_Extensions
        (Count : access Interfaces.Unsigned_32) return System.Address
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_Vulkan_GetInstanceExtensions";

      Count : aliased Interfaces.Unsigned_32 := 0;
      Names : System.Address;
   begin
      Names := SDL_Vulkan_Get_Instance_Extensions (Count'Access);

      if Names = System.Null_Address or else Count = 0 then
         return Null_Extension_Name_Array;
      end if;

      declare
         Raw : CS.chars_ptr_array
           (0 .. C.size_t (Count - 1));
         for Raw'Address use Names;
         pragma Import (Ada, Raw);

         Result : Extension_Name_Arrays (1 .. Positive (Count));
         use Ada.Strings.Unbounded;
      begin
         for Index in Result'Range loop
            declare
               Raw_Name : constant CS.chars_ptr :=
                 Raw (C.size_t (Index - 1));
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
      function SDL_Vulkan_Get_Vk_Get_Instance_Proc_Addr
        return Instance_Address_Type
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_Vulkan_GetVkGetInstanceProcAddr";

      Result : constant Instance_Address_Type :=
        SDL_Vulkan_Get_Vk_Get_Instance_Proc_Addr;
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
      function SDL_Vulkan_Get_Presentation_Support
        (Instance           : in Instance_Address_Type;
         Physical_Device    : in System.Address;
         Queue_Family_Index : in Interfaces.Unsigned_32) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_Vulkan_GetPresentationSupport";
   begin
      return Boolean
        (SDL_Vulkan_Get_Presentation_Support
           (Instance, Physical_Device, Queue_Family_Index));
   end Get_Presentation_Support;

   procedure Load_Library is
      function SDL_Vulkan_Load_Library
        (Path : in CS.chars_ptr) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_Vulkan_LoadLibrary";
   begin
      if not Boolean (SDL_Vulkan_Load_Library (CS.Null_Ptr)) then
         raise SDL_Vulkan_Error with SDL.Error.Get;
      end if;
   end Load_Library;

   procedure Load_Library (Path : in String) is
      function SDL_Vulkan_Load_Library
        (Value : in C.char_array) return CE.bool
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_Vulkan_LoadLibrary";
   begin
      if not Boolean (SDL_Vulkan_Load_Library (C.To_C (Path))) then
         raise SDL_Vulkan_Error with SDL.Error.Get;
      end if;
   end Load_Library;

   procedure Unload_Library is
      procedure SDL_Vulkan_Unload_Library
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_Vulkan_UnloadLibrary";
   begin
      SDL_Vulkan_Unload_Library;
   end Unload_Library;
end SDL.Video.Vulkan;
