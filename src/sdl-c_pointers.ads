with SDL.Raw.C_Pointers;

package SDL.C_Pointers is
   pragma Preelaborate;

   subtype Windows is SDL.Raw.C_Pointers.Windows;
   subtype Windows_Pointer is SDL.Raw.C_Pointers.Windows_Pointer;

   subtype Renderers is SDL.Raw.C_Pointers.Renderers;
   subtype Renderer_Pointer is SDL.Raw.C_Pointers.Renderer_Pointer;

   subtype Textures is SDL.Raw.C_Pointers.Textures;
   subtype Texture_Pointer is SDL.Raw.C_Pointers.Texture_Pointer;

   subtype Surfaces is SDL.Raw.C_Pointers.Surfaces;
   subtype Surface_Pointer is SDL.Raw.C_Pointers.Surface_Pointer;

   subtype Palettes is SDL.Raw.C_Pointers.Palettes;
   subtype Palette_Pointer is SDL.Raw.C_Pointers.Palette_Pointer;

   subtype GL_Contexts is SDL.Raw.C_Pointers.GL_Contexts;
   subtype GL_Context_Pointer is SDL.Raw.C_Pointers.GL_Context_Pointer;

   subtype Audio_Streams is SDL.Raw.C_Pointers.Audio_Streams;
   subtype Audio_Stream_Pointer is SDL.Raw.C_Pointers.Audio_Stream_Pointer;

   subtype IO_Streams is SDL.Raw.C_Pointers.IO_Streams;
   subtype IO_Stream_Pointer is SDL.Raw.C_Pointers.IO_Stream_Pointer;

   subtype Joysticks is SDL.Raw.C_Pointers.Joysticks;
   subtype Joystick_Pointer is SDL.Raw.C_Pointers.Joystick_Pointer;

   subtype Game_Controllers is SDL.Raw.C_Pointers.Game_Controllers;
   subtype Game_Controller_Pointer is SDL.Raw.C_Pointers.Game_Controller_Pointer;

   subtype Haptics is SDL.Raw.C_Pointers.Haptics;
   subtype Haptic_Pointer is SDL.Raw.C_Pointers.Haptic_Pointer;

   subtype Sensors is SDL.Raw.C_Pointers.Sensors;
   subtype Sensor_Pointer is SDL.Raw.C_Pointers.Sensor_Pointer;

   subtype Cameras is SDL.Raw.C_Pointers.Cameras;
   subtype Camera_Pointer is SDL.Raw.C_Pointers.Camera_Pointer;

   subtype HID_Devices is SDL.Raw.C_Pointers.HID_Devices;
   subtype HID_Device_Pointer is SDL.Raw.C_Pointers.HID_Device_Pointer;

   subtype Cursors is SDL.Raw.C_Pointers.Cursors;
   subtype Cursor_Pointer is SDL.Raw.C_Pointers.Cursor_Pointer;

   subtype Shared_Objects is SDL.Raw.C_Pointers.Shared_Objects;
   subtype Shared_Object_Pointer is SDL.Raw.C_Pointers.Shared_Object_Pointer;
end SDL.C_Pointers;
