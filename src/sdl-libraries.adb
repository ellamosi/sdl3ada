with Ada.Unchecked_Conversion;
with Interfaces.C;
with System;

with SDL.Error;

package body SDL.Libraries is
   package C renames Interfaces.C;
   package Raw renames SDL.Raw.LoadSO;

   use type Internal_Handle_Access;

   procedure Load (Self : out Handles; Name : in String) is
   begin
      Self.Internal := Raw.Load_Object (C.To_C (Name));

      if Self.Internal = null then
         raise Library_Error with SDL.Error.Get;
      end if;
   end Load;

   procedure Unload (Self : in out Handles) is
   begin
      Raw.Unload_Object (Self.Internal);
      Self.Internal := null;
   end Unload;

   function Load_Sub_Program
     (From_Library : in Handles) return Access_To_Sub_Program
   is
      function To_Sub_Program is new Ada.Unchecked_Conversion
        (Source => System.Address, Target => Access_To_Sub_Program);

      Func_Ptr : constant System.Address :=
        Raw.Load_Function (From_Library.Internal, C.To_C (Name));

      use type System.Address;
   begin
      if Func_Ptr = System.Null_Address then
         raise Library_Error with SDL.Error.Get;
      end if;

      return To_Sub_Program (Func_Ptr);
   end Load_Sub_Program;

   overriding
   procedure Finalize (Self : in out Handles) is
   begin
      if Self.Internal /= null then
         Unload (Self);
      end if;
   end Finalize;
end SDL.Libraries;
