with Ada.Finalization;
with Interfaces;
with System;

with SDL.Raw.Mutex;

package SDL.Mutexes is
   pragma Preelaborate;
   pragma Elaborate_Body;

   Mutex_Error : exception;

   subtype Timeout_Milliseconds is Interfaces.Integer_32;

   Infinite_Timeout : constant Timeout_Milliseconds :=
     Timeout_Milliseconds (-1);

   subtype Init_Status is SDL.Raw.Mutex.Init_Status;

   Init_Status_Uninitialized  : constant Init_Status :=
     SDL.Raw.Mutex.Init_Status_Uninitialized;
   Init_Status_Initializing   : constant Init_Status :=
     SDL.Raw.Mutex.Init_Status_Initializing;
   Init_Status_Initialized    : constant Init_Status :=
     SDL.Raw.Mutex.Init_Status_Initialized;
   Init_Status_Uninitializing : constant Init_Status :=
     SDL.Raw.Mutex.Init_Status_Uninitializing;

   type Init_State is private;

   function Status (State : in Init_State) return Init_Status;
   function Should_Init (State : in out Init_State) return Boolean;
   function Should_Quit (State : in out Init_State) return Boolean;
   procedure Set_Initialized
     (State       : in out Init_State;
      Initialized : in Boolean);

   type Mutex is new Ada.Finalization.Limited_Controlled with private;
   type Mutex_Reference is access all Mutex;

   overriding
   procedure Finalize (Self : in out Mutex);

   function Create return Mutex;
   procedure Create (Self : in out Mutex);
   procedure Destroy (Self : in out Mutex);

   function Is_Null (Self : in Mutex) return Boolean;

   procedure Lock (Self : in Mutex);
   function Try_Lock (Self : in Mutex) return Boolean;
   procedure Unlock (Self : in Mutex);

   type RW_Lock is new Ada.Finalization.Limited_Controlled with private;

   overriding
   procedure Finalize (Self : in out RW_Lock);

   function Create return RW_Lock;
   procedure Create (Self : in out RW_Lock);
   procedure Destroy (Self : in out RW_Lock);

   function Is_Null (Self : in RW_Lock) return Boolean;

   procedure Lock_For_Reading (Self : in RW_Lock);
   procedure Lock_For_Writing (Self : in RW_Lock);
   function Try_Lock_For_Reading (Self : in RW_Lock) return Boolean;
   function Try_Lock_For_Writing (Self : in RW_Lock) return Boolean;
   procedure Unlock (Self : in RW_Lock);

   type Semaphore is new Ada.Finalization.Limited_Controlled with private;

   overriding
   procedure Finalize (Self : in out Semaphore);

   function Create
     (Initial_Value : in Interfaces.Unsigned_32 := 0) return Semaphore;
   procedure Create
     (Self          : in out Semaphore;
      Initial_Value : in Interfaces.Unsigned_32 := 0);
   procedure Destroy (Self : in out Semaphore);

   function Is_Null (Self : in Semaphore) return Boolean;

   procedure Wait (Self : in Semaphore);
   function Try_Wait (Self : in Semaphore) return Boolean;
   function Wait_Timeout
     (Self       : in Semaphore;
      Timeout_MS : in Timeout_Milliseconds) return Boolean;
   procedure Signal (Self : in Semaphore);
   function Value (Self : in Semaphore) return Interfaces.Unsigned_32;

   type Condition is new Ada.Finalization.Limited_Controlled with private;

   overriding
   procedure Finalize (Self : in out Condition);

   function Create return Condition;
   procedure Create (Self : in out Condition);
   procedure Destroy (Self : in out Condition);

   function Is_Null (Self : in Condition) return Boolean;

   procedure Signal (Self : in Condition);
   procedure Broadcast (Self : in Condition);
   procedure Wait
     (Self  : in Condition;
      Guard : in Mutex_Reference);
   function Wait_Timeout
     (Self       : in Condition;
      Guard      : in Mutex_Reference;
      Timeout_MS : in Timeout_Milliseconds) return Boolean;
private
   type Init_State is record
      Internal : aliased SDL.Raw.Mutex.Init_State :=
        (Status   => (Value => 0),
         Thread   => 0,
         Reserved => System.Null_Address);
   end record;

   type Mutex is new Ada.Finalization.Limited_Controlled with
      record
         Internal : SDL.Raw.Mutex.Mutex_Access := null;
      end record;

   type RW_Lock is new Ada.Finalization.Limited_Controlled with
      record
         Internal : SDL.Raw.Mutex.RW_Lock_Access := null;
      end record;

   type Semaphore is new Ada.Finalization.Limited_Controlled with
      record
         Internal : SDL.Raw.Mutex.Semaphore_Access := null;
      end record;

   type Condition is new Ada.Finalization.Limited_Controlled with
      record
         Internal : SDL.Raw.Mutex.Condition_Access := null;
      end record;
end SDL.Mutexes;
