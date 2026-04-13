with Ada.Exceptions;
with Ada.Text_IO;
with Interfaces;
with Interfaces.C;
with System;
with System.Address_To_Access_Conversions;

with SDL.Atomics;
with SDL.Error;
with SDL.Mutexes;
with SDL.Properties;
with SDL.Threads;

procedure Concurrency_Smoke is
   package C renames Interfaces.C;

   type Shared_State is limited record
      Guard            : aliased SDL.Mutexes.Mutex := SDL.Mutexes.Create;
      Ready_Condition  : SDL.Mutexes.Condition := SDL.Mutexes.Create;
      Ready_Semaphore  : SDL.Mutexes.Semaphore := SDL.Mutexes.Create (0);
      Ready_Flag       : Boolean := False;
      Counter          : SDL.Atomics.Atomic_Integer;
      TLS_Key          : SDL.Threads.TLS_ID;
      TLS_Destructions : aliased Interfaces.Unsigned_32 := 0;
   end record;

   package Shared_State_Addresses is new System.Address_To_Access_Conversions
     (Shared_State);
   package Unsigned_32_Addresses is new System.Address_To_Access_Conversions
     (Interfaces.Unsigned_32);

   use type C.int;
   use type Interfaces.Unsigned_32;
   use type SDL.Mutexes.Init_Status;
   use type SDL.Threads.States;
   use type SDL.Threads.Thread_ID;
   use type Shared_State_Addresses.Object_Pointer;
   use type System.Address;
   use type Unsigned_32_Addresses.Object_Pointer;

   procedure Require
     (Condition : in Boolean;
      Message   : in String);

   procedure TLS_Destroy (Value : in System.Address) with
     Convention => C;

   function Worker (User_Data : in System.Address) return C.int with
     Convention => C;

   procedure Verify_Thread_Round_Trip
     (Shared  : aliased in out Shared_State;
      Thread  : in out SDL.Threads.Thread;
      Name    : in String);

   procedure Require
     (Condition : in Boolean;
      Message   : in String) is
   begin
      if not Condition then
         raise Program_Error with Message;
      end if;
   end Require;

   procedure TLS_Destroy (Value : in System.Address) is
      Counter : constant Unsigned_32_Addresses.Object_Pointer :=
        Unsigned_32_Addresses.To_Pointer (Value);
   begin
      if Counter /= null then
         Counter.all := Counter.all + 1;
      end if;
   end TLS_Destroy;

   function Worker (User_Data : in System.Address) return C.int is
      Shared : constant Shared_State_Addresses.Object_Pointer :=
        Shared_State_Addresses.To_Pointer (User_Data);
   begin
      if Shared = null then
         return -1;
      end if;

      if not SDL.Threads.Set_TLS
          (ID         => Shared.all.TLS_Key,
           Value      => Shared.all.TLS_Destructions'Address,
           Destructor => TLS_Destroy'Unrestricted_Access)
      then
         return -2;
      end if;

      if SDL.Threads.Get_TLS (Shared.all.TLS_Key)
         /= Shared.all.TLS_Destructions'Address
      then
         return -3;
      end if;

      if SDL.Atomics.Add (Shared.all.Counter, 1) /= 0 then
         return -4;
      end if;

      SDL.Mutexes.Lock (Shared.all.Guard);
      Shared.all.Ready_Flag := True;
      SDL.Mutexes.Signal (Shared.all.Ready_Condition);
      SDL.Mutexes.Unlock (Shared.all.Guard);

      SDL.Mutexes.Signal (Shared.all.Ready_Semaphore);

      return 123;
   end Worker;

   procedure Verify_Thread_Round_Trip
     (Shared  : aliased in out Shared_State;
      Thread  : in out SDL.Threads.Thread;
      Name    : in String)
   is
      Exit_Status : C.int := -1;
   begin
      Require
        (SDL.Threads.Get_Name (Thread) = Name,
         "Thread name round-trip failed");
      Require
        (SDL.Threads.Get_ID (Thread) /= 0,
         "Thread ID should not be zero");
      Require
        (SDL.Threads.State (Thread) /= SDL.Threads.Unknown_State,
         "Thread state should not be unknown");

      SDL.Mutexes.Lock (Shared.Guard);

      while not Shared.Ready_Flag loop
         Require
           (SDL.Mutexes.Wait_Timeout
              (Self       => Shared.Ready_Condition,
               Guard      => Shared.Guard'Unchecked_Access,
               Timeout_MS => 1000),
            "Condition wait timed out");
      end loop;

      SDL.Mutexes.Unlock (Shared.Guard);

      Require
        (SDL.Mutexes.Wait_Timeout (Shared.Ready_Semaphore, 1000),
         "Semaphore wait timed out");
      Require
        (SDL.Atomics.Get (Shared.Counter) = 1,
         "Atomic counter did not update across the worker thread");

      SDL.Threads.Wait (Thread, Exit_Status);
      Require (Exit_Status = 123, "Unexpected worker exit status");
      Require
        (Shared.TLS_Destructions = 1,
         "TLS destructor did not run on thread shutdown");
   end Verify_Thread_Round_Trip;
begin
   declare
      Value : SDL.Atomics.Atomic_Integer;
      Refs  : SDL.Atomics.Atomic_Integer;
   begin
      Require (SDL.Atomics.Get (Value) = 0, "Atomic integer should start at zero");
      Require (SDL.Atomics.Set (Value, 10) = 0, "Atomic integer set returned wrong previous value");
      Require
        (SDL.Atomics.Compare_And_Swap (Value, 10, 12),
         "Atomic integer compare-and-swap failed");
      Require (SDL.Atomics.Add (Value, 5) = 12, "Atomic integer add returned wrong previous value");
      Require (SDL.Atomics.Get (Value) = 17, "Atomic integer add did not persist");
      Require
        (SDL.Atomics.Increment_Reference (Refs) = 0,
         "Atomic reference increment returned wrong previous value");
      Require
        (SDL.Atomics.Decrement_Reference (Refs),
         "Atomic reference decrement did not report reaching zero");
   end;

   declare
      Value : SDL.Atomics.Atomic_Unsigned_32;
   begin
      Require
        (SDL.Atomics.Set (Value, 16#CAFE_BABE#) = 0,
         "Atomic u32 set returned wrong previous value");
      Require
        (SDL.Atomics.Compare_And_Swap (Value, 16#CAFE_BABE#, 16#CAFE_BABF#),
         "Atomic u32 compare-and-swap failed");
      Require
        (SDL.Atomics.Add (Value, 1) = 16#CAFE_BABF#,
         "Atomic u32 add returned wrong previous value");
      Require
        (SDL.Atomics.Get (Value) = 16#CAFE_BAC0#,
         "Atomic u32 add did not persist");
   end;

   declare
      First_Target  : aliased Interfaces.Unsigned_32 := 17;
      Second_Target : aliased Interfaces.Unsigned_32 := 23;
      Value         : SDL.Atomics.Atomic_Pointer;
   begin
      Require
        (SDL.Atomics.Set (Value, First_Target'Address) = System.Null_Address,
         "Atomic pointer set returned wrong previous value");
      Require
        (SDL.Atomics.Get (Value) = First_Target'Address,
         "Atomic pointer get returned wrong address");
      Require
        (SDL.Atomics.Compare_And_Swap
           (Value, First_Target'Address, Second_Target'Address),
         "Atomic pointer compare-and-swap failed");
      Require
        (SDL.Atomics.Get (Value) = Second_Target'Address,
         "Atomic pointer compare-and-swap did not persist");
   end;

   declare
      Lock : SDL.Atomics.Spin_Lock := SDL.Atomics.Unlocked;
   begin
      Require (SDL.Atomics.Try_Lock (Lock), "Spinlock try-lock failed");
      SDL.Atomics.Unlock (Lock);
      SDL.Atomics.Lock (Lock);
      SDL.Atomics.Unlock (Lock);
      SDL.Atomics.Memory_Barrier_Release;
      SDL.Atomics.Memory_Barrier_Acquire;
   end;

   declare
      Guard : SDL.Mutexes.Mutex := SDL.Mutexes.Create;
   begin
      SDL.Mutexes.Lock (Guard);
      Require
        (SDL.Mutexes.Try_Lock (Guard),
         "Recursive mutex try-lock failed");
      SDL.Mutexes.Unlock (Guard);
      SDL.Mutexes.Unlock (Guard);
   end;

   declare
      Guard : SDL.Mutexes.RW_Lock := SDL.Mutexes.Create;
   begin
      SDL.Mutexes.Lock_For_Reading (Guard);
      Require
        (SDL.Mutexes.Try_Lock_For_Reading (Guard),
         "Recursive read lock failed");
      SDL.Mutexes.Unlock (Guard);
      SDL.Mutexes.Unlock (Guard);

      Require
        (SDL.Mutexes.Try_Lock_For_Writing (Guard),
         "Write lock try-lock failed");
      SDL.Mutexes.Unlock (Guard);
   end;

   declare
      Gate : SDL.Mutexes.Semaphore := SDL.Mutexes.Create (0);
   begin
      Require
        (not SDL.Mutexes.Try_Wait (Gate),
         "Fresh semaphore try-wait unexpectedly succeeded");
      Require
        (not SDL.Mutexes.Wait_Timeout (Gate, 1),
         "Fresh semaphore timeout unexpectedly succeeded");
      SDL.Mutexes.Signal (Gate);
      Require
        (SDL.Mutexes.Wait_Timeout (Gate, 1000),
         "Signaled semaphore did not unblock");
   end;

   declare
      State : SDL.Mutexes.Init_State;
   begin
      Require
        (SDL.Mutexes.Status (State) = SDL.Mutexes.Init_Status_Uninitialized,
         "Init state should start uninitialized");
      Require (SDL.Mutexes.Should_Init (State), "Init state should request initialization");
      Require
        (SDL.Mutexes.Status (State) = SDL.Mutexes.Init_Status_Initializing,
         "Init state should enter initializing");
      SDL.Mutexes.Set_Initialized (State, True);
      Require
        (SDL.Mutexes.Status (State) = SDL.Mutexes.Init_Status_Initialized,
         "Init state should become initialized");
      Require (SDL.Mutexes.Should_Quit (State), "Init state should request shutdown");
      Require
        (SDL.Mutexes.Status (State) = SDL.Mutexes.Init_Status_Uninitializing,
         "Init state should enter uninitializing");
      SDL.Mutexes.Set_Initialized (State, False);
      Require
        (SDL.Mutexes.Status (State) = SDL.Mutexes.Init_Status_Uninitialized,
         "Init state should return to uninitialized");
   end;

   declare
      Shared : aliased Shared_State;
      Worker_Thread : SDL.Threads.Thread :=
        SDL.Threads.Create
          (Callback  => Worker'Unrestricted_Access,
           Name      => "phase3-worker",
           User_Data => Shared'Address);
   begin
      Verify_Thread_Round_Trip (Shared, Worker_Thread, "phase3-worker");
   end;

   declare
      Shared      : aliased Shared_State;
      Properties  : SDL.Properties.Property_Set := SDL.Properties.Create;
   begin
      SDL.Threads.Set_Create_Entry_Function
        (Properties, Worker'Unrestricted_Access);
      Properties.Set_String
        (SDL.Threads.Thread_Create_Name_Property, "phase3-prop-worker");
      Properties.Set_Pointer
        (SDL.Threads.Thread_Create_User_Data_Property, Shared'Address);

      declare
         Worker_Thread : SDL.Threads.Thread := SDL.Threads.Create (Properties);
      begin
         Verify_Thread_Round_Trip
           (Shared, Worker_Thread, "phase3-prop-worker");
      end;
   end;

   Ada.Text_IO.Put_Line ("Concurrency smoke completed successfully.");
exception
   when Error : others =>
      Ada.Text_IO.Put_Line
        ("Concurrency smoke failed: " & Ada.Exceptions.Exception_Message (Error));

      if SDL.Error.Get /= "" then
         Ada.Text_IO.Put_Line ("SDL error: " & SDL.Error.Get);
      end if;

      raise;
end Concurrency_Smoke;
