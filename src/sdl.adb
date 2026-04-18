with Interfaces.C.Extensions;
with SDL.Raw.Init;

package body SDL is
   package CE renames Interfaces.C.Extensions;
   package Init_Raw renames SDL.Raw.Init;

   use type Init_Raw.Init_Flags;
   use type System.Address;

   function To_C_Bool (Value : in Boolean) return CE.bool is
     (CE.bool'Val (Boolean'Pos (Value)));

   function To_Raw (Flags : in Init_Flags) return Init_Raw.Init_Flags is
     (Init_Raw.Init_Flags (Flags));

   function To_Public (Flags : in Init_Raw.Init_Flags) return Init_Flags is
     (Init_Flags (Flags));

   function Initialise (Flags : in Init_Flags := Enable_Everything) return Boolean is
   begin
      return Boolean (Init_Raw.Init (To_Raw (Flags)));
   end Initialise;

   procedure Quit is
   begin
      Init_Raw.Quit;
   end Quit;

   function Initialise_Sub_System (Flags : in Init_Flags) return Boolean is
   begin
      return Boolean (Init_Raw.Init_Sub_System (To_Raw (Flags)));
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
        (Init_Raw.Set_App_Metadata
           (App_Name       => C_Name'Address,
            App_Version    => C_Version'Address,
            App_Identifier => C_Identifier'Address));
   end Set_App_Metadata;

   function Clear_App_Metadata return Boolean is
   begin
      return Boolean
        (Init_Raw.Set_App_Metadata
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
        (Init_Raw.Set_App_Metadata_Property (C_Name'Address, C_Value'Address));
   end Set_App_Metadata_Property;

   function Clear_App_Metadata_Property (Name : in String) return Boolean is
      C_Name : aliased C.char_array := C.To_C (Name);
   begin
      return Boolean
        (Init_Raw.Set_App_Metadata_Property
           (C_Name'Address, System.Null_Address));
   end Clear_App_Metadata_Property;

   function Get_App_Metadata_Property (Name : in String) return String is
      C_Name  : aliased C.char_array := C.To_C (Name);
      Raw     : constant System.Address :=
        Init_Raw.Get_App_Metadata_Property (C_Name'Address);
   begin
      if Raw = System.Null_Address then
         return "";
      end if;

      declare
         Length : constant C.size_t := Init_Raw.Strlen (Raw);
         Value  : C.char_array (0 .. Length);
         for Value'Address use Raw;
         pragma Import (Ada, Value);
      begin
         return C.To_Ada (Value);
      end;
   end Get_App_Metadata_Property;

   function What_Was_Initialised return Init_Flags is
   begin
      return To_Public (Init_Raw.Was_Init (To_Raw (Null_Init_Flags)));
   end What_Was_Initialised;

   procedure Quit_Sub_System (Flags : in Init_Flags) is
   begin
      Init_Raw.Quit_Sub_System (To_Raw (Flags));
   end Quit_Sub_System;

   function Is_Main_Thread return Boolean is
   begin
      return Boolean (Init_Raw.Is_Main_Thread);
   end Is_Main_Thread;

   function Run_On_Main_Thread
     (Callback      : in Main_Thread_Callback;
      User_Data     : in System.Address := System.Null_Address;
      Wait_Complete : in Boolean := False) return Boolean
   is
   begin
      return Boolean
        (Init_Raw.Run_On_Main_Thread
           (Callback      => Init_Raw.Main_Thread_Callback (Callback),
            User_Data     => User_Data,
            Wait_Complete => To_C_Bool (Wait_Complete)));
   end Run_On_Main_Thread;

   function Was_Initialised (Flags : in Init_Flags) return Boolean is
   begin
      return Init_Raw.Was_Init (To_Raw (Flags)) = To_Raw (Flags);
   end Was_Initialised;
end SDL;
