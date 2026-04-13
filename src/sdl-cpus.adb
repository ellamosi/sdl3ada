with Interfaces.C.Extensions;

package body SDL.CPUS is
   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;

   function SDL_Get_CPU_Count return C.int with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetNumLogicalCPUCores";

   function SDL_Cache_Line_Size return C.int with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetCPUCacheLineSize";

   function SDL_Has_AltiVec return CE.bool with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_HasAltiVec";

   function SDL_Has_AVX return CE.bool with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_HasAVX";

   function SDL_Has_AVX_2 return CE.bool with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_HasAVX2";

   function SDL_Has_AVX_512F return CE.bool with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_HasAVX512F";

   function SDL_Has_ARM_SIMD return CE.bool with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_HasARMSIMD";

   function SDL_Has_LASX return CE.bool with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_HasLASX";

   function SDL_Has_LSX return CE.bool with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_HasLSX";

   function SDL_Has_MMX return CE.bool with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_HasMMX";

   function SDL_Has_NEON return CE.bool with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_HasNEON";

   function SDL_Has_SSE return CE.bool with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_HasSSE";

   function SDL_Has_SSE_2 return CE.bool with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_HasSSE2";

   function SDL_Has_SSE_3 return CE.bool with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_HasSSE3";

   function SDL_Has_SSE_4_1 return CE.bool with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_HasSSE41";

   function SDL_Has_SSE_4_2 return CE.bool with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_HasSSE42";

   function SDL_Get_SIMD_Alignment return C.size_t with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetSIMDAlignment";

   function SDL_Get_System_Page_Size return C.int with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetSystemPageSize";

   function SDL_Get_System_RAM return C.int with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetSystemRAM";

   function Count return Positive is
   begin
      return Positive (SDL_Get_CPU_Count);
   end Count;

   function Cache_Line_Size return Positive is
   begin
      return Positive (SDL_Cache_Line_Size);
   end Cache_Line_Size;

   function Has_3DNow return Boolean is
   begin
      --  SDL3 dropped this legacy probe.
      return False;
   end Has_3DNow;

   function Has_AltiVec return Boolean is (Boolean (SDL_Has_AltiVec));

   function Has_AVX return Boolean is (Boolean (SDL_Has_AVX));

   function Has_AVX_2 return Boolean is (Boolean (SDL_Has_AVX_2));

   function Has_AVX_512F return Boolean is (Boolean (SDL_Has_AVX_512F));

   function Has_ARM_SIMD return Boolean is (Boolean (SDL_Has_ARM_SIMD));

   function Has_LASX return Boolean is (Boolean (SDL_Has_LASX));

   function Has_LSX return Boolean is (Boolean (SDL_Has_LSX));

   function Has_MMX return Boolean is (Boolean (SDL_Has_MMX));

   function Has_NEON return Boolean is (Boolean (SDL_Has_NEON));

   function Has_RDTSC return Boolean is
   begin
      --  SDL3 dropped this legacy probe.
      return False;
   end Has_RDTSC;

   function Has_SSE return Boolean is (Boolean (SDL_Has_SSE));

   function Has_SSE_2 return Boolean is (Boolean (SDL_Has_SSE_2));

   function Has_SSE_3 return Boolean is (Boolean (SDL_Has_SSE_3));

   function Has_SSE_4_1 return Boolean is (Boolean (SDL_Has_SSE_4_1));

   function Has_SSE_4_2 return Boolean is (Boolean (SDL_Has_SSE_4_2));

   function SIMD_Alignment return C.size_t is (SDL_Get_SIMD_Alignment);

   function System_Page_Size return Natural is
     (Natural (SDL_Get_System_Page_Size));

   function System_RAM return Natural is
     (Natural (SDL_Get_System_RAM));
end SDL.CPUS;
