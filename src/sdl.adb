with Interfaces.C.Extensions;

package body SDL is
   package CE renames Interfaces.C.Extensions;

   use type System.Address;

   function SDL_Init (Flags : in Init_Flags := Enable_Everything) return CE.bool with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_Init";

   function SDL_Init_Sub_System (Flags : in Init_Flags) return CE.bool with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_InitSubSystem";

   function SDL_Was_Init (Flags : in Init_Flags := Null_Init_Flags) return Init_Flags with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_WasInit";

   function SDL_Is_Main_Thread return CE.bool with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_IsMainThread";

   function SDL_Run_On_Main_Thread
     (Callback      : in Main_Thread_Callback;
      User_Data     : in System.Address;
      Wait_Complete : in CE.bool) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_RunOnMainThread";

   function SDL_Set_App_Metadata
     (App_Name       : in System.Address;
      App_Version    : in System.Address;
      App_Identifier : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetAppMetadata";

   function SDL_Set_App_Metadata_Property
     (Name  : in System.Address;
      Value : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetAppMetadataProperty";

   function SDL_Get_App_Metadata_Property
     (Name : in System.Address) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetAppMetadataProperty";

   function C_Strlen (Item : in System.Address) return C.size_t with
     Import        => True,
     Convention    => C,
     External_Name => "strlen";

   function To_C_Bool (Value : in Boolean) return CE.bool is
     (CE.bool'Val (Boolean'Pos (Value)));

   function Initialise (Flags : in Init_Flags := Enable_Everything) return Boolean is
   begin
      return Boolean (SDL_Init (Flags));
   end Initialise;

   function Initialise_Sub_System (Flags : in Init_Flags) return Boolean is
   begin
      return Boolean (SDL_Init_Sub_System (Flags));
   end Initialise_Sub_System;

   function Set_App_Metadata
     (App_Name       : in String;
      App_Version    : in String;
      App_Identifier : in String) return Boolean
   is
      C_Name       : aliased C.char_array := C.To_C (App_Name);
      C_Version    : aliased C.char_array := C.To_C (App_Version);
      C_Identifier : aliased C.char_array := C.To_C (App_Identifier);
   begin
      return Boolean
        (SDL_Set_App_Metadata
           (App_Name       => C_Name'Address,
            App_Version    => C_Version'Address,
            App_Identifier => C_Identifier'Address));
   end Set_App_Metadata;

   function Clear_App_Metadata return Boolean is
   begin
      return Boolean
        (SDL_Set_App_Metadata
           (App_Name       => System.Null_Address,
            App_Version    => System.Null_Address,
            App_Identifier => System.Null_Address));
   end Clear_App_Metadata;

   function Set_App_Metadata_Property
     (Name  : in String;
      Value : in String) return Boolean
   is
      C_Name  : aliased C.char_array := C.To_C (Name);
      C_Value : aliased C.char_array := C.To_C (Value);
   begin
      return Boolean
        (SDL_Set_App_Metadata_Property (C_Name'Address, C_Value'Address));
   end Set_App_Metadata_Property;

   function Clear_App_Metadata_Property (Name : in String) return Boolean is
      C_Name : aliased C.char_array := C.To_C (Name);
   begin
      return Boolean
        (SDL_Set_App_Metadata_Property (C_Name'Address, System.Null_Address));
   end Clear_App_Metadata_Property;

   function Get_App_Metadata_Property (Name : in String) return String is
      C_Name  : aliased C.char_array := C.To_C (Name);
      Raw     : constant System.Address :=
        SDL_Get_App_Metadata_Property (C_Name'Address);
   begin
      if Raw = System.Null_Address then
         return "";
      end if;

      declare
         Length : constant C.size_t := C_Strlen (Raw);
         Value  : C.char_array (0 .. Length);
         for Value'Address use Raw;
         pragma Import (Ada, Value);
      begin
         return C.To_Ada (Value);
      end;
   end Get_App_Metadata_Property;

   function What_Was_Initialised return Init_Flags is
   begin
      return SDL_Was_Init;
   end What_Was_Initialised;

   function Is_Main_Thread return Boolean is
   begin
      return Boolean (SDL_Is_Main_Thread);
   end Is_Main_Thread;

   function Run_On_Main_Thread
     (Callback      : in Main_Thread_Callback;
      User_Data     : in System.Address := System.Null_Address;
      Wait_Complete : in Boolean := False) return Boolean
   is
   begin
      return Boolean
        (SDL_Run_On_Main_Thread
           (Callback      => Callback,
            User_Data     => User_Data,
            Wait_Complete => To_C_Bool (Wait_Complete)));
   end Run_On_Main_Thread;

   function Was_Initialised (Flags : in Init_Flags) return Boolean is
   begin
      return SDL_Was_Init (Flags) = Flags;
   end Was_Initialised;
end SDL;
