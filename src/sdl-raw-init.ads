with Interfaces;
with Interfaces.C;
with Interfaces.C.Extensions;
with Interfaces.C.Strings;
with System;

with SDL.Events.Events;

package SDL.Raw.Init is
   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;
   package CS renames Interfaces.C.Strings;

   subtype Init_Flags is Interfaces.Unsigned_32;

   type App_Results is
     (App_Continue,
      App_Success,
      App_Failure)
   with
     Convention => C,
     Size       => C.int'Size;

   for App_Results use
     (App_Continue => 0,
      App_Success  => 1,
      App_Failure  => 2);

   type Main_Thread_Callback is access procedure
     (User_Data : in System.Address)
   with Convention => C;

   type App_Init_Callback is access function
     (App_State : access System.Address;
      ArgC      : in C.int;
      ArgV      : access CS.chars_ptr_array) return App_Results
   with Convention => C;

   type App_Iterate_Callback is access function
     (App_State : in System.Address) return App_Results
   with Convention => C;

   type App_Event_Callback is access function
     (App_State : in System.Address;
      Event     : access SDL.Events.Events.Events) return App_Results
   with Convention => C;

   type App_Quit_Callback is access procedure
     (App_State : in System.Address;
      Result    : in App_Results)
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
     (App_Name       : in CS.chars_ptr;
      App_Version    : in CS.chars_ptr;
      App_Identifier : in CS.chars_ptr) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetAppMetadata";

   function Set_App_Metadata_Property
     (Name  : in CS.chars_ptr;
      Value : in CS.chars_ptr) return CE.bool
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_SetAppMetadataProperty";

   function Get_App_Metadata_Property
     (Name : in CS.chars_ptr) return CS.chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_GetAppMetadataProperty";
end SDL.Raw.Init;
