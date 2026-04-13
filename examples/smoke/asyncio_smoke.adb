with Ada.Directories;
with Ada.Exceptions;
with Ada.Text_IO;
with System;
with System.Address_To_Access_Conversions;

with SDL.AsyncIO;
with SDL.Error;
with SDL.Timers;

procedure AsyncIO_Smoke is
   Temp_File : constant String := "asyncio_smoke.tmp";

   Payload : constant String := "phase3-asyncio-payload";
   subtype Payload_String is String (1 .. Payload'Length);
   package Payload_Addresses is new System.Address_To_Access_Conversions
     (Payload_String);

   use type Payload_Addresses.Object_Pointer;
   use type SDL.AsyncIO.Async_IO_Handle;
   use type SDL.AsyncIO.Results;
   use type SDL.AsyncIO.Sizes;
   use type SDL.AsyncIO.Task_Types;
   use type System.Address;

   Write_Tag       : aliased Character := 'W';
   Close_Tag       : aliased Character := 'C';
   Read_Tag        : aliased Character := 'R';
   Read_Close_Tag  : aliased Character := 'D';
   Load_File_Tag   : aliased Character := 'L';

   procedure Require
     (Condition : in Boolean;
      Message   : in String);

   procedure Cleanup_File;

   function Poll_For_Result
     (Completion_Queue : in SDL.AsyncIO.Queue;
      Item             : out SDL.AsyncIO.Outcome) return Boolean;

   function Wait_For_Result
     (Completion_Queue : in SDL.AsyncIO.Queue;
      Item             : out SDL.AsyncIO.Outcome) return Boolean;

   procedure Require
     (Condition : in Boolean;
      Message   : in String) is
   begin
      if not Condition then
         raise Program_Error with Message;
      end if;
   end Require;

   procedure Cleanup_File is
   begin
      if Ada.Directories.Exists (Temp_File) then
         Ada.Directories.Delete_File (Temp_File);
      end if;
   exception
      when others =>
         null;
   end Cleanup_File;

   function Poll_For_Result
     (Completion_Queue : in SDL.AsyncIO.Queue;
      Item             : out SDL.AsyncIO.Outcome) return Boolean
   is
   begin
      for Attempt in 1 .. 200 loop
         if SDL.AsyncIO.Get_Result (Completion_Queue, Item) then
            return True;
         end if;

         SDL.Timers.Wait_Delay (5);
      end loop;

      return False;
   end Poll_For_Result;

   function Wait_For_Result
     (Completion_Queue : in SDL.AsyncIO.Queue;
      Item             : out SDL.AsyncIO.Outcome) return Boolean
   is
   begin
      for Attempt in 1 .. 20 loop
         if SDL.AsyncIO.Wait_Result
             (Self       => Completion_Queue,
              Item       => Item,
              Timeout_MS => 100)
         then
            return True;
         end if;
      end loop;

      return False;
   end Wait_For_Result;
begin
   Cleanup_File;

   declare
      Completion_Queue : SDL.AsyncIO.Queue := SDL.AsyncIO.Create;
      Written_Buffer   : aliased constant Payload_String := Payload;
      Read_Buffer      : aliased Payload_String := (others => Character'Val (0));
      Item             : SDL.AsyncIO.Outcome;
   begin
      declare
         Writer : SDL.AsyncIO.Async_IO := SDL.AsyncIO.Open (Temp_File, "w+");
         Handle : constant SDL.AsyncIO.Async_IO_Handle :=
           SDL.AsyncIO.Get_Handle (Writer);
      begin
         Require (not SDL.AsyncIO.Is_Null (Writer), "Writer handle should be valid");
         Require (SDL.AsyncIO.Size (Writer) = 0, "Fresh async file should be empty");

         SDL.AsyncIO.Write
           (Self             => Writer,
            Buffer           => Written_Buffer'Address,
            Offset           => 0,
            Byte_Count       => SDL.AsyncIO.Sizes (Written_Buffer'Length),
            Completion_Queue => Completion_Queue,
            User_Data        => Write_Tag'Address);

         SDL.AsyncIO.Close
           (Self             => Writer,
            Flush            => True,
            Completion_Queue => Completion_Queue,
            User_Data        => Close_Tag'Address);

         Require
           (SDL.AsyncIO.Is_Null (Writer),
            "Close should invalidate the async I/O handle");

         Require
           (Poll_For_Result (Completion_Queue, Item),
            "Timed out waiting for async write completion");
         Require (Item.Async_IO_Handle = Handle, "Write outcome handle mismatch");
         Require (Item.Task_Type = SDL.AsyncIO.Write_Task, "Expected write task outcome");
         Require (Item.Result = SDL.AsyncIO.Complete, "Async write did not complete");
         Require
           (Item.Bytes_Transferred = SDL.AsyncIO.Sizes (Written_Buffer'Length),
            "Async write transferred an unexpected number of bytes");
         Require (Item.User_Data = Write_Tag'Address, "Async write user data mismatch");

         Require
           (Wait_For_Result (Completion_Queue, Item),
            "Timed out waiting for async close completion");
         Require (Item.Async_IO_Handle = Handle, "Close outcome handle mismatch");
         Require (Item.Task_Type = SDL.AsyncIO.Close_Task, "Expected close task outcome");
         Require (Item.Result = SDL.AsyncIO.Complete, "Async close did not complete");
         Require (Item.User_Data = Close_Tag'Address, "Async close user data mismatch");
      end;

      declare
         Reader : SDL.AsyncIO.Async_IO := SDL.AsyncIO.Open (Temp_File, "r");
         Handle : constant SDL.AsyncIO.Async_IO_Handle :=
           SDL.AsyncIO.Get_Handle (Reader);
      begin
         Require
           (SDL.AsyncIO.Size (Reader) = SDL.AsyncIO.Sizes (Payload'Length),
            "Async reader reported an unexpected file size");

         SDL.AsyncIO.Read
           (Self             => Reader,
            Buffer           => Read_Buffer'Address,
            Offset           => 0,
            Byte_Count       => SDL.AsyncIO.Sizes (Read_Buffer'Length),
            Completion_Queue => Completion_Queue,
            User_Data        => Read_Tag'Address);

         SDL.AsyncIO.Close
           (Self             => Reader,
            Flush            => False,
            Completion_Queue => Completion_Queue,
            User_Data        => Read_Close_Tag'Address);

         Require
           (Wait_For_Result (Completion_Queue, Item),
            "Timed out waiting for async read completion");
         Require (Item.Async_IO_Handle = Handle, "Read outcome handle mismatch");
         Require (Item.Task_Type = SDL.AsyncIO.Read_Task, "Expected read task outcome");
         Require (Item.Result = SDL.AsyncIO.Complete, "Async read did not complete");
         Require
           (Item.Bytes_Transferred = SDL.AsyncIO.Sizes (Read_Buffer'Length),
            "Async read transferred an unexpected number of bytes");
         Require (Item.User_Data = Read_Tag'Address, "Async read user data mismatch");
         Require (Read_Buffer = Payload, "Async read contents did not round-trip");

         Require
           (Poll_For_Result (Completion_Queue, Item),
            "Timed out waiting for async read-close completion");
         Require (Item.Async_IO_Handle = Handle, "Read close outcome handle mismatch");
         Require (Item.Task_Type = SDL.AsyncIO.Close_Task, "Expected read close outcome");
         Require (Item.Result = SDL.AsyncIO.Complete, "Async reader close did not complete");
         Require
           (Item.User_Data = Read_Close_Tag'Address,
            "Async read-close user data mismatch");
      end;

      SDL.AsyncIO.Load_File
        (File             => Temp_File,
         Completion_Queue => Completion_Queue,
         User_Data        => Load_File_Tag'Address);

      Require
        (Wait_For_Result (Completion_Queue, Item),
         "Timed out waiting for async load-file completion");
      Require (Item.Task_Type = SDL.AsyncIO.Read_Task, "Load-file should report a read task");
      Require (Item.Result = SDL.AsyncIO.Complete, "Async load-file did not complete");
      Require
        (Item.Bytes_Transferred = SDL.AsyncIO.Sizes (Payload'Length),
         "Async load-file transferred an unexpected number of bytes");
      Require (Item.User_Data = Load_File_Tag'Address, "Async load-file user data mismatch");
      Require (Item.Buffer /= System.Null_Address, "Async load-file returned a null buffer");

      declare
         Loaded : constant Payload_Addresses.Object_Pointer :=
           Payload_Addresses.To_Pointer (Item.Buffer);
      begin
         Require (Loaded /= null, "Loaded payload pointer conversion failed");
         Require (Loaded.all = Payload, "Async load-file contents did not match");
      end;

      SDL.AsyncIO.Free_Buffer (Item);
      Require (Item.Buffer = System.Null_Address, "Async load-file buffer was not freed");

      SDL.AsyncIO.Signal (Completion_Queue);
      Require
        (not SDL.AsyncIO.Wait_Result (Completion_Queue, Item, Timeout_MS => 1),
         "Empty async I/O queue unexpectedly produced a result");
   end;

   Cleanup_File;
   Ada.Text_IO.Put_Line ("AsyncIO smoke completed successfully.");
exception
   when Error : others =>
      Cleanup_File;
      Ada.Text_IO.Put_Line
        ("AsyncIO smoke failed: " & Ada.Exceptions.Exception_Message (Error));

      if SDL.Error.Get /= "" then
         Ada.Text_IO.Put_Line ("SDL error: " & SDL.Error.Get);
      end if;

      raise;
end AsyncIO_Smoke;
