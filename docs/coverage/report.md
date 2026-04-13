# SDL3Ada Callable API Coverage

This report is generated from SDL public headers and the Ada source tree in this repository. It measures callable API coverage, not every macro, enum value, or typedef spelling.

Tracked SDL version: `3.4.4`
Tracked SDL ref: `release-3.4.4`
Tracked checkout dir: `.deps/SDL`
Source headers scanned: `.deps/SDL/include/SDL3`

## Summary

| Metric | Count |
| --- | ---: |
| SDL callable API symbols discovered | 1271 |
| Tracked symbols | 1090 |
| Covered symbols | 1090 |
| Missing symbols | 0 |
| Excluded symbols | 181 |
| Coverage | 100.00% |
| Direct coverage | 1084 |
| Alias coverage | 2 |
| Manual wrapper coverage | 4 |

## Scope Rules

- `SDL_stdinc.h` is excluded as an intentional policy choice: Ada code should use Ada/runtime facilities instead of binding SDL's C runtime replacement layer directly.
- Variadic and `va_list` entry points are excluded from automatic coverage because they do not map cleanly to a 1:1 Ada binding.
- Public SDL macro forwards such as `SDL_CreateThread` are credited automatically when their real exported target is imported by the binding.
- A small explicit wrapper map is used where SDL offers convenience entry points and the Ada API exposes the capability through a different surface.

## Header Coverage

| Header | Tracked | Covered | Missing | Excluded | Coverage |
| --- | ---: | ---: | ---: | ---: | ---: |
| `SDL_assert.h` | 6 | 6 | 0 | 0 | 100.00% |
| `SDL_asyncio.h` | 11 | 11 | 0 | 0 | 100.00% |
| `SDL_atomic.h` | 16 | 16 | 0 | 0 | 100.00% |
| `SDL_audio.h` | 58 | 58 | 0 | 0 | 100.00% |
| `SDL_blendmode.h` | 1 | 1 | 0 | 0 | 100.00% |
| `SDL_camera.h` | 15 | 15 | 0 | 0 | 100.00% |
| `SDL_clipboard.h` | 11 | 11 | 0 | 0 | 100.00% |
| `SDL_cpuinfo.h` | 19 | 19 | 0 | 0 | 100.00% |
| `SDL_dialog.h` | 4 | 4 | 0 | 0 | 100.00% |
| `SDL_error.h` | 3 | 3 | 0 | 2 | 100.00% |
| `SDL_events.h` | 20 | 20 | 0 | 0 | 100.00% |
| `SDL_filesystem.h` | 11 | 11 | 0 | 0 | 100.00% |
| `SDL_gamepad.h` | 73 | 73 | 0 | 0 | 100.00% |
| `SDL_gpu.h` | 97 | 97 | 0 | 0 | 100.00% |
| `SDL_guid.h` | 2 | 2 | 0 | 0 | 100.00% |
| `SDL_haptic.h` | 31 | 31 | 0 | 0 | 100.00% |
| `SDL_hidapi.h` | 23 | 23 | 0 | 0 | 100.00% |
| `SDL_hints.h` | 8 | 8 | 0 | 0 | 100.00% |
| `SDL_init.h` | 10 | 10 | 0 | 0 | 100.00% |
| `SDL_iostream.h` | 46 | 46 | 0 | 2 | 100.00% |
| `SDL_joystick.h` | 58 | 58 | 0 | 0 | 100.00% |
| `SDL_keyboard.h` | 24 | 24 | 0 | 0 | 100.00% |
| `SDL_loadso.h` | 3 | 3 | 0 | 0 | 100.00% |
| `SDL_locale.h` | 1 | 1 | 0 | 0 | 100.00% |
| `SDL_log.h` | 8 | 8 | 0 | 10 | 100.00% |
| `SDL_main.h` | 6 | 6 | 0 | 0 | 100.00% |
| `SDL_messagebox.h` | 2 | 2 | 0 | 0 | 100.00% |
| `SDL_metal.h` | 3 | 3 | 0 | 0 | 100.00% |
| `SDL_misc.h` | 1 | 1 | 0 | 0 | 100.00% |
| `SDL_mouse.h` | 24 | 24 | 0 | 0 | 100.00% |
| `SDL_mutex.h` | 28 | 28 | 0 | 0 | 100.00% |
| `SDL_pen.h` | 1 | 1 | 0 | 0 | 100.00% |
| `SDL_pixels.h` | 11 | 11 | 0 | 0 | 100.00% |
| `SDL_platform.h` | 1 | 1 | 0 | 0 | 100.00% |
| `SDL_power.h` | 1 | 1 | 0 | 0 | 100.00% |
| `SDL_process.h` | 9 | 9 | 0 | 0 | 100.00% |
| `SDL_properties.h` | 21 | 21 | 0 | 0 | 100.00% |
| `SDL_rect.h` | 10 | 10 | 0 | 0 | 100.00% |
| `SDL_render.h` | 101 | 101 | 0 | 1 | 100.00% |
| `SDL_sensor.h` | 14 | 14 | 0 | 0 | 100.00% |
| `SDL_stdinc.h` | 0 | 0 | 0 | 166 | n/a |
| `SDL_storage.h` | 17 | 17 | 0 | 0 | 100.00% |
| `SDL_surface.h` | 65 | 65 | 0 | 0 | 100.00% |
| `SDL_system.h` | 33 | 33 | 0 | 0 | 100.00% |
| `SDL_thread.h` | 14 | 14 | 0 | 0 | 100.00% |
| `SDL_time.h` | 9 | 9 | 0 | 0 | 100.00% |
| `SDL_timer.h` | 10 | 10 | 0 | 0 | 100.00% |
| `SDL_touch.h` | 4 | 4 | 0 | 0 | 100.00% |
| `SDL_tray.h` | 23 | 23 | 0 | 0 | 100.00% |
| `SDL_version.h` | 2 | 2 | 0 | 0 | 100.00% |
| `SDL_video.h` | 114 | 114 | 0 | 0 | 100.00% |
| `SDL_vulkan.h` | 7 | 7 | 0 | 0 | 100.00% |

## Alias-Covered API

| SDL API | Covered Through | Ada References |
| --- | --- | --- |
| `SDL_CreateThread` | `SDL_CreateThreadRuntime` | `src/sdl-raw-thread.ads:79` |
| `SDL_CreateThreadWithProperties` | `SDL_CreateThreadWithPropertiesRuntime` | `src/sdl-raw-thread.ads:88` |

## Manual Wrapper Coverage

| SDL API | Ada References | Reason |
| --- | --- | --- |
| `SDL_CreateRenderer` | `src/sdl-video-renderers-makers.ads:26`, `src/sdl-video-renderers-makers.adb:11` | Ada exposes renderer creation through SDL.Video.Renderers.Makers.Create and implements it via SDL_CreateRendererWithProperties. |
| `SDL_CreateWindow` | `src/sdl-video-windows-makers.ads:4`, `src/sdl-video-windows-makers.adb:16` | Ada exposes window creation through SDL.Video.Windows.Makers.Create and implements it via SDL_CreateWindowWithProperties. |
| `SDL_CreateWindowAndRenderer` | `src/sdl-video-renderers-makers.ads:47`, `src/sdl-video-renderers-makers.adb:177` | Ada exposes the combined window-plus-renderer convenience path through SDL.Video.Renderers.Makers.Create. |
| `SDL_Delay` | `src/sdl-timers.ads:38`, `src/sdl-timers.adb:33` | Ada exposes millisecond delay through SDL.Timers.Wait_Delay, which delegates to SDL_DelayNS. |

## Missing Tracked Symbols

No tracked callable SDL API symbols are currently missing.

## Excluded Scope Summary

| Reason | Count |
| --- | ---: |
| SDL's C runtime replacement layer is intentionally out of scope for the Ada binding coverage audit. | 166 |
| Variadic and va_list entry points are excluded from the automatic audit. | 15 |

The full per-symbol classification, signatures, and source references are available in `docs/coverage/report.json`.
