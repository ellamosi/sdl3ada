package SDL.C_Pointers is
   pragma Preelaborate;

   type Windows is null record;
   type Windows_Pointer is access all Windows with
     Convention => C;

   type Renderers is null record;
   type Renderer_Pointer is access all Renderers with
     Convention => C;

   type Textures is null record;
   type Texture_Pointer is access all Textures with
     Convention => C;

   type Surfaces is null record;
   type Surface_Pointer is access all Surfaces with
     Convention => C;

   type Palettes is null record;
   type Palette_Pointer is access all Palettes with
     Convention => C;

   type GL_Contexts is null record;
   type GL_Context_Pointer is access all GL_Contexts with
     Convention => C;

   type Audio_Streams is null record;
   type Audio_Stream_Pointer is access all Audio_Streams with
     Convention => C;

   type IO_Streams is null record;
   type IO_Stream_Pointer is access all IO_Streams with
     Convention => C;

   type Joysticks is null record;
   type Joystick_Pointer is access all Joysticks with
     Convention => C;

   type Game_Controllers is null record;
   type Game_Controller_Pointer is access all Game_Controllers with
     Convention => C;

   type Haptics is null record;
   type Haptic_Pointer is access all Haptics with
     Convention => C;

   type Sensors is null record;
   type Sensor_Pointer is access all Sensors with
     Convention => C;

   type Cameras is null record;
   type Camera_Pointer is access all Cameras with
     Convention => C;

   type HID_Devices is null record;
   type HID_Device_Pointer is access all HID_Devices with
     Convention => C;

   type Cursors is null record;
   type Cursor_Pointer is access all Cursors with
     Convention => C;

   type Shared_Objects is null record;
   type Shared_Object_Pointer is access all Shared_Objects with
     Convention => C;
end SDL.C_Pointers;
