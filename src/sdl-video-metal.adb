with SDL.Error;

package body SDL.Video.Metal is
   use type System.Address;

   procedure Raise_Metal_Error
     (Default_Message : in String := "SDL metal call failed");

   procedure Raise_Metal_Error
     (Default_Message : in String := "SDL metal call failed")
   is
      Message : constant String := SDL.Error.Get;
   begin
      if Message = "" then
         raise SDL_Metal_Error with Default_Message;
      end if;

      raise SDL_Metal_Error with Message;
   end Raise_Metal_Error;

   procedure Require_View (Self : in View);

   procedure Require_View (Self : in View) is
   begin
      if Self.Internal = System.Null_Address then
         raise SDL_Metal_Error with "Invalid Metal view";
      end if;
   end Require_View;

   function Create
     (Window : in SDL.Video.Windows.Window) return View
   is
   begin
      return Result : View do
         Create (Result, Window);
      end return;
   end Create;

   procedure Create
     (Self   : in out View;
      Window : in SDL.Video.Windows.Window)
   is
      function SDL_Metal_Create_View
        (Value : in System.Address) return System.Address
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_Metal_CreateView";

      Internal : System.Address := System.Null_Address;
   begin
      Destroy (Self);

      Internal := SDL_Metal_Create_View (SDL.Video.Windows.Get_Internal (Window));
      if Internal = System.Null_Address then
         Raise_Metal_Error ("SDL_Metal_CreateView failed");
      end if;

      Self.Internal := Internal;
      Self.Owns := True;
   end Create;

   overriding
   procedure Finalize (Self : in out View) is
   begin
      Destroy (Self);
   end Finalize;

   procedure Destroy (Self : in out View) is
      procedure SDL_Metal_Destroy_View
        (Value : in System.Address)
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_Metal_DestroyView";
   begin
      if Self.Owns and then Self.Internal /= System.Null_Address then
         SDL_Metal_Destroy_View (Self.Internal);
      end if;

      Self.Internal := System.Null_Address;
      Self.Owns := False;
   end Destroy;

   function Is_Null (Self : in View) return Boolean is
     (Self.Internal = System.Null_Address);

   function Get_Layer (Self : in View) return System.Address is
      function SDL_Metal_Get_Layer
        (Value : in System.Address) return System.Address
      with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_Metal_GetLayer";

      Result : System.Address;
   begin
      Require_View (Self);

      Result := SDL_Metal_Get_Layer (Self.Internal);
      if Result = System.Null_Address then
         Raise_Metal_Error ("SDL_Metal_GetLayer failed");
      end if;

      return Result;
   end Get_Layer;

   function Get_Internal (Self : in View) return System.Address is
     (Self.Internal);
end SDL.Video.Metal;
