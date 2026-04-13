# SDL3Ada Validation Matrix

This note ties the runtime families reflected in `docs/coverage/report.md` and the
public Ada units tracked in `docs/coverage/parity-matrix.md` to the smoke
targets and manual checks that currently audit them.

Use the documents in this order when auditing release readiness:

- `docs/coverage/parity-matrix.md` for the public Ada unit surface
- `docs/coverage/report.md` for callable SDL API coverage and remaining missing symbols

The one-command automated baseline from the repository root is:

```sh
tools/run_release_baseline.sh
```

Treat this file as the maintained validation entry point. The table below is
where the checked-in build commands, smoke commands, and remaining manual
backend or hardware-sensitive checks should stay current.

## Runtime Families

| Header families | Public units | Build | Run | Validation notes |
| --- | --- | --- | --- | --- |
| `SDL_properties.h`, `SDL_assert.h`, `SDL_cpuinfo.h`, `SDL_init.h`, `SDL_locale.h`, `SDL_log.h`, `SDL_main.h`, `SDL_misc.h`, `SDL_platform.h`, `SDL_time.h`, `SDL_timer.h`, `SDL_version.h`, `SDL_error.h`, `SDL_hints.h`, `SDL_loadso.h`, `SDL_power.h` | `SDL`, `SDL.Assertions`, `SDL.Locale`, `SDL.Log`, `SDL.Main`, `SDL.Properties`, `SDL.Libraries`, `SDL.Power`, and related core units | `alr exec -- gprbuild -P examples/smoke/core_smoke.gpr` | `bin/core_smoke` | Covers app metadata, string and boolean hint access, per-hint reset, hint callbacks, explicit out-of-memory error reporting, timers, logs, assertions, locale/time, power queries, and the disposable library-probe shared-library round trip. |
| `SDL_asyncio.h` | `SDL.AsyncIO` | `alr exec -- gprbuild -P examples/smoke/asyncio_smoke.gpr` | `bin/asyncio_smoke` | Covers async write/read/flush/close flows, queue polling, blocking waits, and `SDL_LoadFileAsync` buffer ownership. |
| `SDL_atomic.h`, `SDL_mutex.h`, `SDL_thread.h` | `SDL.Atomics`, `SDL.Mutexes`, `SDL.Threads` | `alr exec -- gprbuild -P examples/smoke/concurrency_smoke.gpr` | `bin/concurrency_smoke` | Covers atomics, spinlocks, mutexes, RW-locks, semaphores, conditions, thread creation, naming, wait/detach, TLS, and TLS destructor callbacks. |
| `SDL_events.h`, `SDL_touch.h` | `SDL.Events.*` | `alr exec -- gprbuild -P examples/smoke/events_smoke.gpr` | `env SDL_VIDEODRIVER=dummy bin/events_smoke` | Covers event pump/flush, peep/push/custom events, filter/watch callbacks, event descriptions, touch-device and active-finger queries, and synthetic touch-event payload round trips. |
| `SDL_keyboard.h`, `SDL_mouse.h`, `SDL_keycode.h`, `SDL_gamepad.h`, `SDL_guid.h`, `SDL_joystick.h` | `SDL.Events.Keyboards`, `SDL.Inputs.*` | `alr exec -- gprbuild -P examples/smoke/input_smoke.gpr` | `env SDL_VIDEODRIVER=dummy bin/input_smoke` | Covers keyboard/mouse queries, text-input helpers, relative-mode control, cursor helpers, gamepad mappings, virtual joystick/gamepad helpers, rumble, LED, effect, touchpad, sensor, and power helpers. |
| `SDL_camera.h`, `SDL_haptic.h`, `SDL_hidapi.h`, `SDL_pen.h`, `SDL_sensor.h` | `SDL.Cameras`, `SDL.Haptics`, `SDL.HIDAPI`, `SDL.Pens`, `SDL.Sensors` | `alr exec -- gprbuild -P examples/smoke/device_smoke.gpr` | `bin/device_smoke` | Covers enumeration and wrapper behavior on all hosts, while live reads, frames, and raw I/O are logged as honest skips when no hardware is present. |
| `SDL_process.h` | `SDL.Processes` | `alr exec -- gprbuild -P examples/smoke/process_smoke.gpr` | `bin/process_smoke` | Covers stdin/stdout pipe round trips, stderr redirection, process properties, and exit-code reporting. |
| `SDL_system.h` | `SDL.Systems` | `alr exec -- gprbuild -P examples/smoke/system_smoke.gpr` | `bin/system_smoke` | Covers sandbox, form-factor, and cross-platform lifecycle helper surface. |
| `SDL_storage.h`, `SDL_filesystem.h` | `SDL.Storage`, `SDL.Filesystems` | `alr exec -- gprbuild -P examples/smoke/storage_smoke.gpr` | `bin/storage_smoke` | Covers file-backed storage create/write/read/rename/copy/remove flows plus widened filesystem path info, enumeration, globbing, and direct file operations. |
| `SDL_clipboard.h` | `SDL.Clipboard` | `alr exec -- gprbuild -P examples/smoke/clipboard_smoke.gpr` | `env SDL_VIDEODRIVER=dummy bin/clipboard_smoke` | Covers clipboard text, primary selection, MIME-data offers, typed retrieval, and cleanup callbacks on the dummy-video baseline. |
| `SDL_audio.h` | `SDL.Audio`, `SDL.Audio.Devices`, `SDL.Audio.Streams` | `alr exec -- gprbuild -P examples/smoke/audio_smoke.gpr` | `env SDL_AUDIODRIVER=dummy bin/audio_smoke` | Covers logical-device control, WAV load helpers, format conversion, mixing, postmix callbacks, and bound or standalone audio streams on the dummy driver. |
| `SDL_iostream.h` | `SDL.RWops`, `SDL.RWops.Streams` | `alr exec -- gprbuild -P examples/smoke/rwops_smoke.gpr` | `bin/rwops_smoke` | Covers file, memory, dynamic-memory, and custom `SDL_IOStream` flows plus load/save helpers, stream properties, and endian helpers. |
| `SDL_render.h`, selected `SDL_blendmode.h` helpers | `SDL.Video.Renderers`, `SDL.Video.Textures` | `alr exec -- gprbuild -P examples/smoke/render_smoke.gpr` | `env SDL_VIDEODRIVER=dummy bin/render_smoke` | Covers software-renderer creation, custom blend-mode composition, indexed-texture palette round trips, direct and indexed geometry submission, hidden-window event-coordinate conversion, draw state, debug text, readback, and the renderer-owned GPU bridge surface. |
| `SDL_video.h`, `SDL_pixels.h`, `SDL_rect.h`, `SDL_surface.h` | `SDL.Video`, `SDL.Video.Pixels`, `SDL.Video.Rectangles`, `SDL.Video.Surfaces`, `SDL.Video.Palettes` | `alr exec -- gprbuild -P examples/smoke/video_foundation_smoke.gpr` | `env SDL_VIDEODRIVER=dummy bin/video_foundation_smoke` | Covers palettes and indexed-surface palette control, colourspace round trips, alternate-image enumeration, direct pixel access plus explicit read/write helpers, raw pixel conversion and premultiply paths, clear/fill/blit/stretch/tiled/9-grid operations, duplicate/rotate/scale/convert helpers, and the window-surface foundation with honest dummy-backend skips where SDL reports unsupported behavior. |
| `SDL_video.h` | `SDL.Video.Windows`, `SDL.Video.Windows.Makers` | `alr exec -- gprbuild -P examples/smoke/video_smoke.gpr` | `env SDL_VIDEODRIVER=dummy bin/video_smoke` | Covers property-backed windows, title or position or size queries, fullscreen mode round trips, live window enumeration through `SDL_GetWindows`, and surface-window creation/update flows. Popup-window creation remains an honest skip on the dummy driver. |
| `SDL_video.h`, `SDL_metal.h`, `SDL_vulkan.h` | `SDL.Video.Metal`, `SDL.Video.Vulkan`, `SDL.Video.GL` companions | `alr exec -- gprbuild -P examples/smoke/advanced_video_smoke.gpr` | `env SDL_VIDEODRIVER=dummy bin/advanced_video_smoke` | Covers `SDL_GL_ResetAttributes`, null callback installation through `SDL_EGL_SetAttributeCallbacks`, EGL proc/display/config/window-surface probes on the dummy backend, and the Metal/Vulkan companion paths. Live GUI sessions are still required for full Metal, OpenGL, Vulkan, and real EGL validation. |
| `SDL_dialog.h`, `SDL_messagebox.h`, `SDL_tray.h` | `SDL.Dialogs`, `SDL.Message_Boxes`, `SDL.Trays` | `alr exec -- gprbuild -P examples/smoke/desktop_smoke.gpr` | `env SDL_VIDEODRIVER=dummy bin/desktop_smoke` | Covers wrapper construction and non-interactive skips on headless baselines; real tray, dialog, and message-box interaction remains manual desktop validation. |
| `SDL_gpu.h` | `SDL.Raw.GPU`, `SDL.GPU`, GPU bridge entry points in `SDL.Video.Renderers` | `alr exec -- gprbuild -P examples/smoke/gpu_smoke.gpr` | `env SDL_VIDEODRIVER=dummy bin/gpu_smoke` | Covers headless-safe skips, buffer and texture debug naming, GDK suspend/resume calls, offscreen resource paths, shader-backed Metal validation when available, and the portable DXIL/MSL/SPIR-V cube path. In this environment, the dummy driver reports no supported SDL_GPU backend and the native driver reports no displays, so live Metal, Vulkan, and D3D12 validation still requires a real GPU/display session. |

## Auxiliary Header Families

- `SDL_test*` stays outside the core runtime crate. If it is ever bound, it
  should ship as a sibling or optional test-support package.
- `SDL_begin_code.h`, `SDL_close_code.h`, `SDL_copying.h`,
  `SDL_dlopennote.h`, `SDL_intrin.h`, `SDL_main_impl.h`,
  `SDL_oldnames.h`, and `SDL_platform_defines.h` are inventoried as support
  headers rather than standalone runtime binding families.
- `SDL_opengl*` and `SDL_opengles*` headers are inventoried as vendor
  passthrough headers. SDL-owned companion entry points are validated through
  the video packages instead of by binding those vendor headers directly.
