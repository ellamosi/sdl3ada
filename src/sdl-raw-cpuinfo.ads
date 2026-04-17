with Interfaces.C;
with Interfaces.C.Extensions;

package SDL.Raw.CPUInfo is
   pragma Pure;

   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;

   function Get_Num_Logical_CPU_Cores return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetNumLogicalCPUCores";

   function Get_CPU_Cache_Line_Size return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetCPUCacheLineSize";

   function Has_AltiVec return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_HasAltiVec";

   function Has_AVX return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_HasAVX";

   function Has_AVX2 return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_HasAVX2";

   function Has_AVX512F return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_HasAVX512F";

   function Has_ARM_SIMD return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_HasARMSIMD";

   function Has_LASX return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_HasLASX";

   function Has_LSX return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_HasLSX";

   function Has_MMX return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_HasMMX";

   function Has_NEON return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_HasNEON";

   function Has_SSE return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_HasSSE";

   function Has_SSE2 return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_HasSSE2";

   function Has_SSE3 return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_HasSSE3";

   function Has_SSE41 return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_HasSSE41";

   function Has_SSE42 return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_HasSSE42";

   function Get_SIMD_Alignment return C.size_t
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetSIMDAlignment";

   function Get_System_Page_Size return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetSystemPageSize";

   function Get_System_RAM return C.int
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetSystemRAM";
end SDL.Raw.CPUInfo;
