with Interfaces.C;
with Interfaces.C.Extensions;
with Interfaces.C.Strings;

with SDL.Error;

package body SDL.Properties is
   package C renames Interfaces.C;
   package CE renames Interfaces.C.Extensions;
   package CS renames Interfaces.C.Strings;
   package Raw renames SDL.Raw.Properties;

   use type Raw.ID;
   use type CS.chars_ptr;

   function To_C_Bool (Value : in Boolean) return CE.bool is
     (CE.bool'Val (Boolean'Pos (Value)));

   procedure Raise_Last_Error;
   procedure Raise_Last_Error is
   begin
      raise Property_Error with SDL.Error.Get;
   end Raise_Last_Error;

   procedure Require_Valid (Self : in Property_Set);
   procedure Require_Valid (Self : in Property_Set) is
   begin
      if Self.Handle = Null_Property_ID then
         raise Property_Error with "Invalid property set";
      end if;
   end Require_Valid;

   function Create return Property_Set is
      Handle : constant Property_ID := Raw.Create_Properties;
   begin
      if Handle = Null_Property_ID then
         Raise_Last_Error;
      end if;

      return Result : Property_Set do
         Result.Handle := Handle;
         Result.Owns := True;
      end return;
   end Create;

   procedure Create (Self : in out Property_Set) is
      Handle : Property_ID;
   begin
      Destroy (Self);

      Handle := Raw.Create_Properties;
      if Handle = Null_Property_ID then
         Raise_Last_Error;
      end if;

      Self.Handle := Handle;
      Self.Owns := True;
   end Create;

   function Global return Property_Set is
   begin
      return Reference (Raw.Get_Global_Properties);
   end Global;

   function Reference (ID : in Property_ID) return Property_Set is
   begin
      return Result : Property_Set do
         Result.Handle := ID;
         Result.Owns := False;
      end return;
   end Reference;

   overriding
   procedure Finalize (Self : in out Property_Set) is
   begin
      Destroy (Self);
   end Finalize;

   procedure Destroy (Self : in out Property_Set) is
   begin
      if Self.Owns and then Self.Handle /= Null_Property_ID then
         Raw.Destroy_Properties (Self.Handle);
      end if;

      Self.Handle := Null_Property_ID;
      Self.Owns := False;
   end Destroy;

   function Get_ID (Self : in Property_Set) return Property_ID is
     (Self.Handle);

   function Is_Null (Self : in Property_Set) return Boolean is
     (Self.Handle = Null_Property_ID);

   function Has
     (Self : in Property_Set;
      Name : in String) return Boolean
   is
   begin
      Require_Valid (Self);
      return Boolean (Raw.Has_Property (Self.Handle, C.To_C (Name)));
   end Has;

   function Get_Type
     (Self : in Property_Set;
      Name : in String) return Property_Types
   is
   begin
      Require_Valid (Self);
      return Raw.Get_Property_Type (Self.Handle, C.To_C (Name));
   end Get_Type;

   procedure Copy
     (Source      : in Property_Set;
      Destination : in out Property_Set)
   is
   begin
      Require_Valid (Source);
      Require_Valid (Destination);

      if not Boolean (Raw.Copy_Properties (Source.Handle, Destination.Handle)) then
         Raise_Last_Error;
      end if;
   end Copy;

   procedure Lock (Self : in Property_Set) is
   begin
      Require_Valid (Self);

      if not Boolean (Raw.Lock_Properties (Self.Handle)) then
         Raise_Last_Error;
      end if;
   end Lock;

   procedure Unlock (Self : in Property_Set) is
   begin
      Require_Valid (Self);
      Raw.Unlock_Properties (Self.Handle);
   end Unlock;

   procedure Set_Pointer_With_Cleanup
     (Self      : in Property_Set;
      Name      : in String;
      Value     : in System.Address;
      Cleanup   : in Cleanup_Callback;
      User_Data : in System.Address := System.Null_Address)
   is
   begin
      Require_Valid (Self);

      if not Boolean
          (Raw.Set_Pointer_Property_With_Cleanup
             (Props     => Self.Handle,
              Name      => C.To_C (Name),
              Value     => Value,
              Cleanup   => Cleanup,
              User_Data => User_Data))
      then
         Raise_Last_Error;
      end if;
   end Set_Pointer_With_Cleanup;

   procedure Set_Pointer
     (Self  : in Property_Set;
      Name  : in String;
      Value : in System.Address)
   is
   begin
      Require_Valid (Self);

      if not Boolean
          (Raw.Set_Pointer_Property
             (Props => Self.Handle,
              Name  => C.To_C (Name),
              Value => Value))
      then
         Raise_Last_Error;
      end if;
   end Set_Pointer;

   procedure Set_String
     (Self  : in Property_Set;
      Name  : in String;
      Value : in String)
   is
      C_Value : CS.chars_ptr := CS.New_String (Value);
   begin
      Require_Valid (Self);

      begin
         if not Boolean
             (Raw.Set_String_Property
                (Props => Self.Handle,
                 Name  => C.To_C (Name),
                 Value => C_Value))
         then
            Raise_Last_Error;
         end if;
      exception
         when others =>
            CS.Free (C_Value);
            raise;
      end;

      CS.Free (C_Value);
   end Set_String;

   procedure Set_Number
     (Self  : in Property_Set;
      Name  : in String;
      Value : in Property_Numbers)
   is
   begin
      Require_Valid (Self);

      if not Boolean
          (Raw.Set_Number_Property
             (Props => Self.Handle,
              Name  => C.To_C (Name),
              Value => Value))
      then
         Raise_Last_Error;
      end if;
   end Set_Number;

   procedure Set_Float
     (Self  : in Property_Set;
      Name  : in String;
      Value : in Property_Floats)
   is
   begin
      Require_Valid (Self);

      if not Boolean
          (Raw.Set_Float_Property
             (Props => Self.Handle,
              Name  => C.To_C (Name),
              Value => Value))
      then
         Raise_Last_Error;
      end if;
   end Set_Float;

   procedure Set_Boolean
     (Self  : in Property_Set;
      Name  : in String;
      Value : in Boolean)
   is
   begin
      Require_Valid (Self);

      if not Boolean
          (Raw.Set_Boolean_Property
             (Props => Self.Handle,
              Name  => C.To_C (Name),
              Value => To_C_Bool (Value)))
      then
         Raise_Last_Error;
      end if;
   end Set_Boolean;

   function Get_Pointer
     (Self    : in Property_Set;
      Name    : in String;
      Default : in System.Address := System.Null_Address) return System.Address
   is
   begin
      Require_Valid (Self);
      return Raw.Get_Pointer_Property (Self.Handle, C.To_C (Name), Default);
   end Get_Pointer;

   function Get_String
     (Self    : in Property_Set;
      Name    : in String;
      Default : in String := "") return String
   is
      C_Default : CS.chars_ptr := CS.New_String (Default);
      Result    : CS.chars_ptr;
   begin
      Require_Valid (Self);

      begin
         Result :=
           Raw.Get_String_Property
             (Props   => Self.Handle,
              Name    => C.To_C (Name),
              Default => C_Default);

         if Result = CS.Null_Ptr then
            CS.Free (C_Default);
            return "";
         end if;

         declare
            Value : constant String := CS.Value (Result);
         begin
            CS.Free (C_Default);
            return Value;
         end;
      exception
         when others =>
            CS.Free (C_Default);
            raise;
      end;
   end Get_String;

   function Get_Number
     (Self    : in Property_Set;
      Name    : in String;
      Default : in Property_Numbers := 0) return Property_Numbers
   is
   begin
      Require_Valid (Self);
      return Raw.Get_Number_Property (Self.Handle, C.To_C (Name), Default);
   end Get_Number;

   function Get_Float
     (Self    : in Property_Set;
      Name    : in String;
      Default : in Property_Floats := 0.0) return Property_Floats
   is
   begin
      Require_Valid (Self);
      return Raw.Get_Float_Property (Self.Handle, C.To_C (Name), Default);
   end Get_Float;

   function Get_Boolean
     (Self    : in Property_Set;
      Name    : in String;
      Default : in Boolean := False) return Boolean
   is
   begin
      Require_Valid (Self);
      return Boolean
        (Raw.Get_Boolean_Property (Self.Handle, C.To_C (Name), To_C_Bool (Default)));
   end Get_Boolean;

   procedure Clear
     (Self : in Property_Set;
      Name : in String)
   is
   begin
      Require_Valid (Self);

      if not Boolean (Raw.Clear_Property (Self.Handle, C.To_C (Name))) then
         Raise_Last_Error;
      end if;
   end Clear;

   procedure Enumerate
     (Self      : in Property_Set;
      Callback  : in Enumerate_Callback;
      User_Data : in System.Address := System.Null_Address)
   is
   begin
      Require_Valid (Self);

      if not Boolean
          (Raw.Enumerate_Properties
             (Props     => Self.Handle,
              Callback  => Callback,
              User_Data => User_Data))
      then
         Raise_Last_Error;
      end if;
   end Enumerate;
end SDL.Properties;
