with Ada.Finalization;
with System;

with SDL.Video.Windows;

package SDL.Video.Metal is
   pragma Elaborate_Body;

   SDL_Metal_Error : exception;

   type View is new Ada.Finalization.Limited_Controlled with private;

   function Create
     (Window : in SDL.Video.Windows.Window) return View;

   procedure Create
     (Self   : in out View;
      Window : in SDL.Video.Windows.Window);

   overriding
   procedure Finalize (Self : in out View);

   procedure Destroy (Self : in out View);

   function Is_Null (Self : in View) return Boolean with
     Inline;

   function Get_Layer (Self : in View) return System.Address;

   function Get_Internal (Self : in View) return System.Address with
     Inline;
private
   type View is new Ada.Finalization.Limited_Controlled with
      record
         Internal : System.Address := System.Null_Address;
         Owns     : Boolean := False;
      end record;
end SDL.Video.Metal;
