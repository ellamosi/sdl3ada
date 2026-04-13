with Interfaces.C;
with Interfaces.C.Strings;

with SDL.Error;

package body SDL.Clipboard is
   package C renames Interfaces.C;
   package CS renames Interfaces.C.Strings;
   package Raw renames SDL.Raw.Clipboard;

   use type CS.chars_ptr;
   use type Raw.Sizes;
   use type System.Address;

   Empty_Bytes : constant Ada.Streams.Stream_Element_Array (1 .. 0) :=
     [others => 0];

   procedure SDL_Free (Memory : in CS.chars_ptr) with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_free";

   procedure SDL_Free (Memory : in System.Address) with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_free";

   procedure Raise_Last_Error
     (Default_Message : in String := "SDL clipboard call failed");

   function Copy_Text
     (Value           : in CS.chars_ptr;
      Default_Message : in String) return UTF_Strings.UTF_8_String;

   function Copy_Buffer
     (Buffer      : in System.Address;
      Byte_Length : in Raw.Sizes) return Ada.Streams.Stream_Element_Array;

   function Copy_Mime_Type_List
     (Items : in System.Address;
      Count : in Raw.Sizes) return Mime_Type_Lists;

   procedure Raise_Last_Error
     (Default_Message : in String := "SDL clipboard call failed")
   is
      Message : constant String := SDL.Error.Get;
   begin
      if Message = "" then
         raise Clipboard_Error with Default_Message;
      end if;

      raise Clipboard_Error with Message;
   end Raise_Last_Error;

   function Copy_Text
     (Value           : in CS.chars_ptr;
      Default_Message : in String) return UTF_Strings.UTF_8_String
   is
   begin
      if Value = CS.Null_Ptr then
         Raise_Last_Error (Default_Message);
      end if;

      declare
         Result : constant UTF_Strings.UTF_8_String := CS.Value (Value);
      begin
         SDL_Free (Value);
         return Result;
      exception
         when others =>
            SDL_Free (Value);
            raise;
      end;
   end Copy_Text;

   function Copy_Buffer
     (Buffer      : in System.Address;
      Byte_Length : in Raw.Sizes) return Ada.Streams.Stream_Element_Array
   is
   begin
      if Byte_Length = 0 then
         if Buffer /= System.Null_Address then
            SDL_Free (Buffer);
         end if;

         return Empty_Bytes;
      end if;

      if Buffer = System.Null_Address then
         Raise_Last_Error ("SDL clipboard data retrieval failed");
      end if;

      declare
         Bytes : Ada.Streams.Stream_Element_Array
           (1 .. Ada.Streams.Stream_Element_Offset (Byte_Length));
         for Bytes'Address use Buffer;
         pragma Import (Ada, Bytes);

         Result : constant Ada.Streams.Stream_Element_Array := Bytes;
      begin
         SDL_Free (Buffer);
         return Result;
      exception
         when others =>
            SDL_Free (Buffer);
            raise;
      end;
   end Copy_Buffer;

   function Copy_Mime_Type_List
     (Items : in System.Address;
      Count : in Raw.Sizes) return Mime_Type_Lists
   is
   begin
      if Items = System.Null_Address then
         Raise_Last_Error ("SDL clipboard MIME-type query failed");
      end if;

      if Count = 0 then
         SDL_Free (Items);
         return [];
      end if;

      declare
         Raw_Items : CS.chars_ptr_array (0 .. Count - 1);
         for Raw_Items'Address use Items;
         pragma Import (Ada, Raw_Items);

         Result : Mime_Type_Lists (1 .. Natural (Count));
      begin
         for Index in Result'Range loop
            Result (Index) :=
              US.To_Unbounded_String
                (CS.Value (Raw_Items (C.size_t (Index - 1))));
         end loop;

         SDL_Free (Items);
         return Result;
      exception
         when others =>
            SDL_Free (Items);
            raise;
      end;
   end Copy_Mime_Type_List;

   function Get return UTF_Strings.UTF_8_String is
   begin
      return Copy_Text
        (Raw.Get_Text, "Clipboard text is unavailable");
   end Get;

   function Has_Text return Boolean is
   begin
      return Boolean (Raw.Has_Text);
   end Has_Text;

   function Is_Empty return Boolean is
   begin
      return not Has_Text;
   end Is_Empty;

   procedure Set (Text : in UTF_Strings.UTF_8_String) is
   begin
      if not Boolean (Raw.Set_Text (C.To_C (Text))) then
         Raise_Last_Error ("Clipboard text update failed");
      end if;
   end Set;

   function Get_Primary_Selection return UTF_Strings.UTF_8_String is
   begin
      return Copy_Text
        (Raw.Get_Primary_Selection_Text,
         "Primary-selection text is unavailable");
   end Get_Primary_Selection;

   function Has_Primary_Selection_Text return Boolean is
   begin
      return Boolean (Raw.Has_Primary_Selection_Text);
   end Has_Primary_Selection_Text;

   procedure Set_Primary_Selection (Text : in UTF_Strings.UTF_8_String) is
   begin
      if not Boolean (Raw.Set_Primary_Selection_Text (C.To_C (Text))) then
         Raise_Last_Error ("Primary-selection text update failed");
      end if;
   end Set_Primary_Selection;

   procedure Set_Data
     (Callback   : in Clipboard_Data_Callback;
      Mime_Types : in Mime_Type_Lists;
      Cleanup    : in Clipboard_Cleanup_Callback := null;
      User_Data  : in System.Address := System.Null_Address)
   is
      Raw_Mime_Types : CS.chars_ptr_array
        (0 .. C.size_t (Mime_Types'Length - 1));

      procedure Free_Mime_Types;
      procedure Free_Mime_Types is
      begin
         for Index in Raw_Mime_Types'Range loop
            if Raw_Mime_Types (Index) /= CS.Null_Ptr then
               CS.Free (Raw_Mime_Types (Index));
            end if;
         end loop;
      end Free_Mime_Types;
   begin
      for Index in Raw_Mime_Types'Range loop
         Raw_Mime_Types (Index) :=
           CS.New_String
             (US.To_String
                (Mime_Types
                   (Mime_Types'First + Integer (Index - Raw_Mime_Types'First))));
      end loop;

      begin
         if not Boolean
             (Raw.Set_Data
                 (Callback       => Callback,
                  Cleanup        => Cleanup,
                  User_Data      => User_Data,
                 Mime_Types     => Raw_Mime_Types'Address,
                  Num_Mime_Types => C.size_t (Mime_Types'Length)))
         then
            Raise_Last_Error ("Clipboard data offer failed");
         end if;
      exception
         when others =>
            Free_Mime_Types;
            raise;
      end;

      Free_Mime_Types;
   end Set_Data;

   procedure Clear_Data is
   begin
      if not Boolean (Raw.Clear_Data) then
         Raise_Last_Error ("Clipboard data clear failed");
      end if;
   end Clear_Data;

   function Get_Data
     (Mime_Type : in String) return Ada.Streams.Stream_Element_Array
   is
      Byte_Length : aliased Raw.Sizes := 0;
      Buffer      : constant System.Address :=
        Raw.Get_Data (C.To_C (Mime_Type), Byte_Length'Access);
   begin
      return Copy_Buffer (Buffer, Byte_Length);
   end Get_Data;

   function Has_Data (Mime_Type : in String) return Boolean is
   begin
      return Boolean (Raw.Has_Data (C.To_C (Mime_Type)));
   end Has_Data;

   function Get_Mime_Types return Mime_Type_Lists is
      Count : aliased Raw.Sizes := 0;
      Items : constant System.Address := Raw.Get_Mime_Types (Count'Access);
   begin
      return Copy_Mime_Type_List (Items => Items, Count => Count);
   end Get_Mime_Types;
end SDL.Clipboard;
