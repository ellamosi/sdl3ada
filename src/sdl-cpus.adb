with SDL.Raw.CPUInfo;

package body SDL.CPUS is
   package C renames Interfaces.C;
   package Raw renames SDL.Raw.CPUInfo;

   function Count return Positive is
   begin
      return Positive (Raw.Get_Num_Logical_CPU_Cores);
   end Count;

   function Cache_Line_Size return Positive is
   begin
      return Positive (Raw.Get_CPU_Cache_Line_Size);
   end Cache_Line_Size;

   function Has_3DNow return Boolean is
   begin
      --  SDL3 dropped this legacy probe.
      return False;
   end Has_3DNow;

   function Has_AltiVec return Boolean is (Boolean (Raw.Has_AltiVec));

   function Has_AVX return Boolean is (Boolean (Raw.Has_AVX));

   function Has_AVX_2 return Boolean is (Boolean (Raw.Has_AVX2));

   function Has_AVX_512F return Boolean is (Boolean (Raw.Has_AVX512F));

   function Has_ARM_SIMD return Boolean is (Boolean (Raw.Has_ARM_SIMD));

   function Has_LASX return Boolean is (Boolean (Raw.Has_LASX));

   function Has_LSX return Boolean is (Boolean (Raw.Has_LSX));

   function Has_MMX return Boolean is (Boolean (Raw.Has_MMX));

   function Has_NEON return Boolean is (Boolean (Raw.Has_NEON));

   function Has_RDTSC return Boolean is
   begin
      --  SDL3 dropped this legacy probe.
      return False;
   end Has_RDTSC;

   function Has_SSE return Boolean is (Boolean (Raw.Has_SSE));

   function Has_SSE_2 return Boolean is (Boolean (Raw.Has_SSE2));

   function Has_SSE_3 return Boolean is (Boolean (Raw.Has_SSE3));

   function Has_SSE_4_1 return Boolean is (Boolean (Raw.Has_SSE41));

   function Has_SSE_4_2 return Boolean is (Boolean (Raw.Has_SSE42));

   function SIMD_Alignment return C.size_t is (Raw.Get_SIMD_Alignment);

   function System_Page_Size return Natural is
     (Natural (Raw.Get_System_Page_Size));

   function System_RAM return Natural is
     (Natural (Raw.Get_System_RAM));
end SDL.CPUS;
