with Ada.Finalization;
with Interfaces.C;
with System;

with SDL.Properties;
with SDL.Raw.Thread;

package SDL.Threads is
   pragma Elaborate_Body;

   package C renames Interfaces.C;

   Thread_Error : exception;

   subtype Thread_ID is SDL.Raw.Thread.Thread_ID;
   subtype Priorities is SDL.Raw.Thread.Thread_Priority;
   subtype States is SDL.Raw.Thread.Thread_State;
   subtype Thread_Function is SDL.Raw.Thread.Thread_Function;
   subtype TLS_Destructor_Callback is SDL.Raw.Thread.TLS_Destructor_Callback;

   Low_Priority           : constant Priorities := SDL.Raw.Thread.Low_Priority;
   Normal_Priority        : constant Priorities :=
     SDL.Raw.Thread.Normal_Priority;
   High_Priority          : constant Priorities := SDL.Raw.Thread.High_Priority;
   Time_Critical_Priority : constant Priorities :=
     SDL.Raw.Thread.Time_Critical_Priority;

   Unknown_State  : constant States := SDL.Raw.Thread.Unknown;
   Alive_State    : constant States := SDL.Raw.Thread.Alive;
   Detached_State : constant States := SDL.Raw.Thread.Detached;
   Complete_State : constant States := SDL.Raw.Thread.Complete;

   Thread_Create_Entry_Function_Property : constant String :=
     SDL.Raw.Thread.Thread_Create_Entry_Function_Property;
   Thread_Create_Name_Property : constant String :=
     SDL.Raw.Thread.Thread_Create_Name_Property;
   Thread_Create_User_Data_Property : constant String :=
     SDL.Raw.Thread.Thread_Create_User_Data_Property;
   Thread_Create_Stack_Size_Property : constant String :=
     SDL.Raw.Thread.Thread_Create_Stack_Size_Property;

   type TLS_ID is private;
   type Thread is new Ada.Finalization.Limited_Controlled with private;

   overriding
   procedure Finalize (Self : in out Thread);

   function Create
     (Callback  : in Thread_Function;
      Name      : in String;
      User_Data : in System.Address := System.Null_Address) return Thread;

   procedure Create
     (Self      : in out Thread;
      Callback  : in Thread_Function;
      Name      : in String;
      User_Data : in System.Address := System.Null_Address);

   function Create (Properties : in SDL.Properties.Property_Set) return Thread;
   procedure Create
     (Self       : in out Thread;
      Properties : in SDL.Properties.Property_Set);

   procedure Set_Create_Entry_Function
     (Properties : in SDL.Properties.Property_Set;
      Callback   : in Thread_Function);

   function Is_Null (Self : in Thread) return Boolean;

   function Get_Name (Self : in Thread) return String;
   function Current_ID return Thread_ID;
   function Get_ID (Self : in Thread) return Thread_ID;
   function State (Self : in Thread) return States;

   function Set_Current_Priority (Priority : in Priorities) return Boolean;

   procedure Wait
     (Self        : in out Thread;
      Exit_Status : out C.int);

   procedure Wait (Self : in out Thread);
   procedure Detach (Self : in out Thread);

   function Get_TLS (ID : in out TLS_ID) return System.Address;
   function Set_TLS
     (ID         : in out TLS_ID;
      Value      : in System.Address;
      Destructor : in TLS_Destructor_Callback := null) return Boolean;
   procedure Cleanup_TLS;
private
   type TLS_ID is record
      Internal : aliased SDL.Raw.Thread.TLS_ID := (Value => 0);
   end record;

   type Thread is new Ada.Finalization.Limited_Controlled with
      record
         Internal : SDL.Raw.Thread.Thread_Access := null;
      end record;
end SDL.Threads;
