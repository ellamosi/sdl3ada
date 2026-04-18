with Interfaces.C;
with Interfaces.C.Extensions;
with System;

package SDL.Raw.Init is
   pragma Pure;

   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;

   subtype Init_Flags is Interfaces.Unsigned_32;

   type Main_Thread_Callback is access procedure
     (User_Data : in System.Address)
   with Convention => C;

   Name_Property       : constant String := "SDL.app.metadata.name";
   Version_Property    : constant String := "SDL.app.metadata.version";
   Identifier_Property : constant String := "SDL.app.metadata.identifier";
   Creator_Property    : constant String := "SDL.app.metadata.creator";
   Copyright_Property  : constant String := "SDL.app.metadata.copyright";
   URL_Property        : constant String := "SDL.app.metadata.url";
   Type_Property       : constant String := "SDL.app.metadata.type";

   function Init (Flags : in Init_Flags) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_Init";

   function Init_Sub_System (Flags : in Init_Flags) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_InitSubSystem";

   function Was_Init (Flags : in Init_Flags) return Init_Flags
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_WasInit";

   procedure Quit
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_Quit";

   procedure Quit_Sub_System (Flags : in Init_Flags)
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_QuitSubSystem";

   function Is_Main_Thread return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_IsMainThread";

   function Run_On_Main_Thread
     (Callback      : in Main_Thread_Callback;
      User_Data     : in System.Address;
      Wait_Complete : in CE.bool) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_RunOnMainThread";

   function Set_App_Metadata
     (App_Name       : in System.Address;
      App_Version    : in System.Address;
      App_Identifier : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetAppMetadata";

   function Set_App_Metadata_Property
     (Name  : in System.Address;
      Value : in System.Address) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetAppMetadataProperty";

   function Get_App_Metadata_Property
     (Name : in System.Address) return System.Address
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetAppMetadataProperty";

   function Strlen (Item : in System.Address) return C.size_t
   with
     Import        => True,
     Convention    => C,
     External_Name => "strlen";
end SDL.Raw.Init;
