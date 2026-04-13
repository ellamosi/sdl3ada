with Ada.Finalization;
with System;

with SDL.Raw.Properties;

package SDL.Properties is
   pragma Elaborate_Body;

   Property_Error : exception;

   subtype Property_ID is SDL.Raw.Properties.ID;
   Null_Property_ID : constant Property_ID := SDL.Raw.Properties.No_Properties;

   subtype Property_Numbers is SDL.Raw.Properties.Numbers;
   subtype Property_Floats is SDL.Raw.Properties.Floats;
   subtype Property_Types is SDL.Raw.Properties.Property_Types;

   subtype Cleanup_Callback is SDL.Raw.Properties.Cleanup_Callback;
   subtype Enumerate_Callback is SDL.Raw.Properties.Enumerate_Callback;

   Invalid_Type : constant Property_Types := SDL.Raw.Properties.Invalid_Type;
   Pointer_Type : constant Property_Types := SDL.Raw.Properties.Pointer_Type;
   String_Type  : constant Property_Types := SDL.Raw.Properties.String_Type;
   Number_Type  : constant Property_Types := SDL.Raw.Properties.Number_Type;
   Float_Type   : constant Property_Types := SDL.Raw.Properties.Float_Type;
   Boolean_Type : constant Property_Types := SDL.Raw.Properties.Boolean_Type;

   Name_Property : constant String := SDL.Raw.Properties.Name_Property;

   type Property_Set is new Ada.Finalization.Limited_Controlled with private;

   function Create return Property_Set;
   procedure Create (Self : in out Property_Set);

   function Global return Property_Set;
   function Reference (ID : in Property_ID) return Property_Set;

   overriding
   procedure Finalize (Self : in out Property_Set);

   procedure Destroy (Self : in out Property_Set);

   function Get_ID (Self : in Property_Set) return Property_ID with
     Inline;

   function Is_Null (Self : in Property_Set) return Boolean with
     Inline;

   function Has
     (Self : in Property_Set;
      Name : in String) return Boolean;

   function Get_Type
     (Self : in Property_Set;
      Name : in String) return Property_Types;

   procedure Copy
     (Source      : in Property_Set;
      Destination : in out Property_Set);

   procedure Lock (Self : in Property_Set);
   procedure Unlock (Self : in Property_Set);

   procedure Set_Pointer_With_Cleanup
     (Self      : in Property_Set;
      Name      : in String;
      Value     : in System.Address;
      Cleanup   : in Cleanup_Callback;
      User_Data : in System.Address := System.Null_Address);

   procedure Set_Pointer
     (Self  : in Property_Set;
      Name  : in String;
      Value : in System.Address);

   procedure Set_String
     (Self  : in Property_Set;
      Name  : in String;
      Value : in String);

   procedure Set_Number
     (Self  : in Property_Set;
      Name  : in String;
      Value : in Property_Numbers);

   procedure Set_Float
     (Self  : in Property_Set;
      Name  : in String;
      Value : in Property_Floats);

   procedure Set_Boolean
     (Self  : in Property_Set;
      Name  : in String;
      Value : in Boolean);

   function Get_Pointer
     (Self    : in Property_Set;
      Name    : in String;
      Default : in System.Address := System.Null_Address) return System.Address;

   function Get_String
     (Self    : in Property_Set;
      Name    : in String;
      Default : in String := "") return String;

   function Get_Number
     (Self    : in Property_Set;
      Name    : in String;
      Default : in Property_Numbers := 0) return Property_Numbers;

   function Get_Float
     (Self    : in Property_Set;
      Name    : in String;
      Default : in Property_Floats := 0.0) return Property_Floats;

   function Get_Boolean
     (Self    : in Property_Set;
      Name    : in String;
      Default : in Boolean := False) return Boolean;

   procedure Clear
     (Self : in Property_Set;
      Name : in String);

   procedure Enumerate
     (Self      : in Property_Set;
      Callback  : in Enumerate_Callback;
      User_Data : in System.Address := System.Null_Address);
private
   type Property_Set is new Ada.Finalization.Limited_Controlled with
      record
         Handle : Property_ID := Null_Property_ID;
         Owns   : Boolean := False;
      end record;
end SDL.Properties;
