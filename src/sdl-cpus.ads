with Interfaces.C;

package SDL.CPUS is
   pragma Pure;

   function Count return Positive;

   function Cache_Line_Size return Positive with
     Inline => True;

   function Has_3DNow return Boolean with
     Inline => True;

   function Has_AltiVec return Boolean with
     Inline => True;

   function Has_AVX return Boolean with
     Inline => True;

   function Has_AVX_2 return Boolean with
     Inline => True;

   function Has_AVX_512F return Boolean with
     Inline => True;

   function Has_ARM_SIMD return Boolean with
     Inline => True;

   function Has_LASX return Boolean with
     Inline => True;

   function Has_LSX return Boolean with
     Inline => True;

   function Has_MMX return Boolean with
     Inline => True;

   function Has_NEON return Boolean with
     Inline => True;

   function Has_RDTSC return Boolean with
     Inline => True;

   function Has_SSE return Boolean with
     Inline => True;

   function Has_SSE_2 return Boolean with
     Inline => True;

   function Has_SSE_3 return Boolean with
     Inline => True;

   function Has_SSE_4_1 return Boolean with
     Inline => True;

   function Has_SSE_4_2 return Boolean with
     Inline => True;

   function SIMD_Alignment return Interfaces.C.size_t with
     Inline => True;

   function System_Page_Size return Natural with
     Inline => True;

   function System_RAM return Natural with
     Inline => True;
end SDL.CPUS;
