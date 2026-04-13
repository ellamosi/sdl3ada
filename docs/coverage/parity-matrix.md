# SDL3Ada Public Unit Parity Matrix

This matrix lists the current public `sdlada` unit surface against
`sdl3ada`, excluding `SDL_Linker`.

## Summary

- `sdlada` public units tracked: 52
- implemented in `sdl3ada`: 52
- `sdl3ada`-only public units: `SDL.Assertions`, `SDL.AsyncIO`, `SDL.Atomics`, `SDL.Audio.Streams`, `SDL.Cameras`, `SDL.Dialogs`, `SDL.Events.Cameras`, `SDL.Events.Keyboards`, `SDL.Events.Pens`, `SDL.Events.Sensors`, `SDL.GPU`, `SDL.Haptics`, `SDL.HIDAPI`, `SDL.Locale`, `SDL.Main`, `SDL.Message_Boxes`, `SDL.Misc`, `SDL.Mutexes`, `SDL.Pens`, `SDL.Processes`, `SDL.Properties`, `SDL.Sensors`, `SDL.Storage`, `SDL.Systems`, `SDL.Threads`, `SDL.Time`, `SDL.Trays`

## Core And Utility

| Unit | Status | SDL3 notes | Primary validation |
| --- | --- | --- | --- |
| `SDL` | implemented | Core init/quit flags remain the entry point for subsystem setup, and now also expose SDL3 app metadata plus main-thread helper coverage; the full `SDL_init.h` family is completed jointly with `SDL.Main`. | `core_smoke`, `alr build` |
| `SDL.Error` | implemented | Direct SDL3 error-string facade, including null-safe empty-string behavior when SDL reports no active error and the explicit out-of-memory error helper. | `core_smoke` |
| `SDL.Log` | implemented | SDL3 log categories and priorities mapped into the `sdlada` package shape, now including priority-prefix and output-callback control. | `core_smoke`, `alr build` |
| `SDL.Timers` | implemented | Tick and delay helpers stay direct and thin, and the SDL3 timer callback add/remove APIs are now covered. | `core_smoke` |
| `SDL.Versions` | implemented | `Revision` stays available; linked-version queries now also expose SDL3 numeric version helpers, while numeric revision compatibility stays conservative. | `core_smoke` |
| `SDL.Platform` | implemented | Runtime platform detection is backed by `SDL_GetPlatform`, with the raw platform-name string exposed alongside the compatibility enum. | `core_smoke` |
| `SDL.Hints` | implemented | Mix of direct SDL3 names and compatibility aliases for retired SDL2 hint names, now including string-based access, boolean lookup, per-hint reset, and callback watches. | `core_smoke` |
| `SDL.Filesystems` | implemented | SDL3 filesystem coverage now includes base/preferences/current/user path getters, folder/path enums, path info, enumeration callbacks, directory globbing, and direct create/remove/rename/copy helpers, while keeping SDL-owned versus caller-owned string lifetimes explicit. | `storage_smoke`, `rwops_smoke` |
| `SDL.CPUS` | implemented | CPU feature coverage is widened for AVX, ARM SIMD, NEON, and LoongArch probes plus RAM/page-size/SIMD alignment queries; legacy `Has_3DNow` and `Has_RDTSC` compatibility results stay conservative on SDL3. | `core_smoke` |
| `SDL.Power` | implemented | Battery and power-state queries remain direct. | `core_smoke` |
| `SDL.Clipboard` | implemented | Clipboard text, primary-selection text, callback-based MIME offers, typed data retrieval, and explicit clear helpers are exposed under the same unit, while callback lifetime stays explicit. Exact MIME enumeration content remains backend-dependent. | `clipboard_smoke` |
| `SDL.Libraries` | implemented | Compatibility facade over `SDL_LoadObject`, `SDL_LoadFunction`, and `SDL_UnloadObject`, runtime-validated through the disposable library probe used by `core_smoke`. | `core_smoke` |
| `SDL.C_Pointers` | implemented | Shared helper layer for pointer-heavy wrappers. | compile coverage via library and smoke builds |

## Events And Input

| Unit | Status | SDL3 notes | Primary validation |
| --- | --- | --- | --- |
| `SDL.Events` | implemented | Common-event and user-event records now cover SDL3 queue control and custom-event construction without fabricating SDL2-era payload shapes. | `events_smoke` |
| `SDL.Events.Events` | implemented | Queue pump/flush, timed wait, peep add/peek/get, push, filter/watch, enable-state, description, and window-ID helpers sit beside the widened SDL3-native union branches. | `events_smoke`, `input_smoke` |
| `SDL.Events.Files` | implemented | Drop-file payloads remain under the legacy package name. | `events_smoke` |
| `SDL.Events.Windows` | implemented | SDL3 window-event truthfulness is preserved via helper conversions instead of fake SDL2 fields. | `events_smoke` |
| `SDL.Events.Mice` | implemented | Float coordinates and SDL3 wheel data are preserved. | `events_smoke` |
| `SDL.Events.Touches` | implemented | SDL3 finger payloads are exposed directly; removed gesture streams are only compatibility placeholders, and touch-device plus active-finger queries are now bound for runtime inspection. | `events_smoke` |
| `SDL.Events.Joysticks` | implemented | Axis, button, device, and battery payloads are covered. | `input_smoke`, manual hardware check |
| `SDL.Events.Joysticks.Game_Controllers` | implemented | SDL3 gamepad events sit behind the familiar unit name. | `input_smoke`, manual hardware check |
| `SDL.Events.Controllers` | implemented | Legacy controller-facing constants and aliases are preserved for migration. | `input_smoke`, manual hardware check |
| `SDL.Inputs` | implemented | Shared input scaffolding stays compatible with the broader input tree. | `input_smoke` |
| `SDL.Inputs.Keyboards` | implemented | Keyboard enumeration, focused-window conveniences, and explicit SDL3 text-input property and area helpers now sit beside the legacy state APIs. | `input_smoke` |
| `SDL.Inputs.Mice` | implemented | Mouse enumeration, focus queries, explicit window-relative mode, and relative-transform installation are mapped honestly onto SDL3 while preserving focused-window conveniences. | `input_smoke` |
| `SDL.Inputs.Mice.Cursors` | implemented | System, default, bitmap, color, and animated cursor helpers are wrapped thickly; dummy backends still skip unsupported cursor creation. | `input_smoke`, manual GUI check |
| `SDL.Inputs.Joysticks` | implemented | Public 1-based device indices still map internally to SDL3 instance IDs, now alongside SDL3-native GUID, property, power, rumble, LED, effect, and virtual-device helpers. | `input_smoke`, manual hardware check |
| `SDL.Inputs.Joysticks.Makers` | implemented | Open/close wrappers preserve the `sdlada` lifetime pattern. | `input_smoke`, manual hardware check |
| `SDL.Inputs.Joysticks.Game_Controllers` | implemented | SDL3 gamepads remain under the legacy controller naming while covering mappings, ID metadata, bindings, type and label helpers, touchpads, sensors, rumble, LED, effects, and SF Symbols queries. | `input_smoke`, manual hardware check |
| `SDL.Inputs.Joysticks.Game_Controllers.Makers` | implemented | Maker helpers remain thin lifetime wrappers around SDL3 gamepad opens. | `input_smoke`, manual hardware check |

## Audio

| Unit | Status | SDL3 notes | Primary validation |
| --- | --- | --- | --- |
| `SDL.Audio` | implemented | Driver enumeration, direct logical-device open/close/pause/resume, format/channel-map/gain queries, WAV load helpers, sample conversion and mixing, and postmix callbacks are widened for parity. | `audio_smoke` |
| `SDL.Audio.Devices` | implemented | Generic device wrapper is backed by an SDL3 logical device plus a bound `SDL_AudioStream`. Recording parity uses explicit dequeue, not a fake callback. | `audio_smoke`, manual real-device check |
| `SDL.Audio.Sample_Formats` | implemented | SDL3-supported formats plus endianness and predicate helpers; removed SDL2-only unsigned formats stay absent. | `audio_smoke`, `video_foundation_smoke` |

## Video

| Unit | Status | SDL3 notes | Primary validation |
| --- | --- | --- | --- |
| `SDL.Video` | implemented | Video-driver enumeration, screensaver control, subsystem init/finalize helpers, system-theme queries, and custom blend-mode composition helpers are covered. | `video_foundation_smoke`, `video_smoke`, `render_smoke` |
| `SDL.Video.Displays` | implemented | Public 1-based display indices map internally to SDL3 `SDL_DisplayID`; display properties, content scale, natural orientation, and fullscreen display-mode enumeration are covered, while DPI compatibility is derived from content scale. | `video_foundation_smoke`, manual real-display check |
| `SDL.Video.Rectangles` | implemented | Broad rectangle and point helper surface, including float variants and line clipping. | `video_foundation_smoke` |
| `SDL.Video.Palettes` | implemented | Thick palette wrapper with iteration and SDL3-native bulk colour updates. | `video_foundation_smoke` |
| `SDL.Video.Pixels` | implemented | Pixel record types and channel helpers remain available for surface and texture callers. | `video_foundation_smoke`, `video_smoke` |
| `SDL.Video.Pixel_Formats` | implemented | SDL3 detail lookups plus `sdlada`-facing aliases and mask/component helpers. | `video_foundation_smoke` |
| `SDL.Video.Surfaces` | implemented | Thick SDL3 surface wrapper now covers palette and colorspace control, alternate-image management, duplicate or rotate or scale or colorspace-convert helpers, raw pixel conversion and premultiply paths, direct pixel read or write helpers, clear/fill/blit/stretch/tiled/9-grid operations, modulation, locking, and property-backed metadata. SDL2-style in-place rect mutation is intentionally not fabricated. | `video_foundation_smoke` |
| `SDL.Video.Surfaces.Makers` | implemented | Surface constructors cover the parity creation paths, while the broader duplicate or rotate or scale and colorspace-convert helpers now live on `SDL.Video.Surfaces` itself. | `video_foundation_smoke` |
| `SDL.Video.Windows` | implemented | Window properties, title and size/state control, display and fullscreen-mode queries, safe-area and pixel-format helpers, live window-ID enumeration, grabs, parenting, progress, hit-test, and window-surface integration are covered under the familiar namespace, with backend-sensitive probes kept explicit. | `video_smoke`, `advanced_video_smoke`, manual GUI check |
| `SDL.Video.Windows.Makers` | implemented | Maker wrappers preserve the existing window lifetime model while now covering property-based and popup window creation paths. | `video_smoke`, `advanced_video_smoke` |
| `SDL.Video.Windows.Manager` | implemented | `WM_Info` is sourced from SDL3 window properties instead of SDL2's legacy query struct. | `advanced_video_smoke`, manual GUI check |
| `SDL.Video.Renderers` | implemented | Thick renderer wrapper now covers properties, draw state, viewport or clip control, logical presentation, window-to-render event-coordinate conversion, both direct and raw geometry submission, readback, debug text, the render-owned Metal layer, Metal command-encoder, Vulkan semaphore companion helpers, the GPU-device lookup bridge used by `SDL.GPU`, and the renderer-owned custom GPU render-state object helpers for create, fragment-uniform upload, set, reset, and destroy. | `render_smoke`, `video_smoke`, `gpu_smoke` |
| `SDL.Video.Renderers.Makers` | implemented | Renderer constructors now cover window, software-surface, property-based, combined window-plus-renderer creation paths, the direct GPU-renderer constructor that adopts an existing `SDL.GPU` device, and public property-name constants for GPU shader-format declarations on property-based renderer creation. | `render_smoke`, `video_smoke`, `gpu_smoke` |
| `SDL.Video.Textures` | implemented | Texture wrapper remains thick and ownership-safe while now covering modulation, alpha and blend state, indexed-texture palette set or query helpers, update helpers, lock-to-surface, and property-backed metadata. | `render_smoke`, `video_smoke` |
| `SDL.Video.Textures.Makers` | implemented | Texture constructors now cover direct pixel-format creation, surface import, property-based creation, and non-owning internal adoption for renderer lookups. | `render_smoke`, `video_smoke` |
| `SDL.Video.GL` | implemented | Attribute/context helpers now include EGL proc/display/config/window-surface lookup plus attribute callback and reset control, alongside current-window lookup, swap interval, and drawable-size compatibility. `Bind_Texture` and `Unbind_Texture` stay explicit runtime stubs because SDL3 removed them. | `advanced_video_smoke`, manual GUI check |
| `SDL.Video.Metal` | implemented | Controlled `SDL_MetalView` ownership now covers Metal view creation or destruction plus CAMetalLayer lookup without exposing raw lifetime hazards. | `advanced_video_smoke`, manual Apple GUI check |
| `SDL.Video.Vulkan` | implemented | Library load, proc lookup, parameterless and compatibility extension enumeration, allocator-aware surface create or destroy flows, presentation-support queries, and drawable-size compatibility are covered. Runtime validation still depends on a local Vulkan loader and real device or surface access. | `advanced_video_smoke`, manual Vulkan loader check |

## IO And Streams

| Unit | Status | SDL3 notes | Primary validation |
| --- | --- | --- | --- |
| `SDL.RWops` | implemented | Public API is preserved, but each handle is backed by SDL3 `SDL_IOStream`. File, memory, dynamic-memory, and custom-interface opens, properties/status access, block read/write, load/save helpers, and signed plus unsigned endian helpers are now covered. | `rwops_smoke` |
| `SDL.RWops.Streams` | implemented | Ada `Root_Stream_Type` bridge now rides on the same `SDL_IOStream` implementation. EOF and short-read behavior is documented explicitly. | `rwops_smoke` |

## SDL3-Native Additions

These units are intentionally outside the `sdlada` parity count, but they are
part of the supported `sdl3ada` surface:

| Unit | Purpose | Primary validation |
| --- | --- | --- |
| `SDL.Assertions` | Runtime assertion-handler hooks and report access over `SDL_assert.h`, without trying to fake C assertion macros as Ada syntax. | `core_smoke`, `alr build` |
| `SDL.Atomics` | Spinlocks, memory-barrier functions, and atomic integer/u32/pointer helpers over `SDL_atomic.h`, while keeping compiler-intrinsic-only macros out of the public Ada surface. | `concurrency_smoke`, `alr build` |
| `SDL.AsyncIO` | Public queue-based wrapper over `SDL_asyncio.h`, covering async file open/size/read/write/close, queue polling and waits, and `SDL_LoadFileAsync` buffer ownership via explicit `Free_Buffer`. | `asyncio_smoke`, `alr build` |
| `SDL.Audio.Streams` | Direct SDL3 bound and unbound stream APIs cover format changes, frequency-ratio and gain control, channel-map reset helpers, callbacks, planar/no-copy queueing, and device binding beside `SDL.Audio.Devices`. | `audio_smoke` |
| `SDL.Cameras` | Controlled camera wrapper over `SDL_camera.h`, covering driver and device enumeration, properties, permission state, supported formats, frame acquire/release, and borrowed surface wrapping without hiding SDL's permission-sensitive streaming semantics. | `device_smoke`, manual real-camera check |
| `SDL.Dialogs` | Public wrapper over `SDL_dialog.h`, covering file-filter records, async dialog callbacks, open/save/folder helpers, and the property-driven dialog launch path while keeping callback lifetimes explicit. | `desktop_smoke`, manual real-desktop dialog check |
| `SDL.Events.Cameras` | SDL3-native camera device event records and constants for added/removed/approved/denied notifications, wired into the widened `SDL.Events.Events` union. | `device_smoke`, manual real-camera check |
| `SDL.Events.Keyboards` | SDL3-native keyboard and text-event detail helpers now include explicit scancode-name, keycode-translation, and modifier round-trip APIs used by the widened event and input layers. | `events_smoke`, `input_smoke` |
| `SDL.Events.Pens` | SDL3-native pen proximity, touch, motion, button, and axis event records and constants, wired into the widened `SDL.Events.Events` union without fabricating SDL2-era tablet abstractions. | `device_smoke`, manual real-pen check |
| `SDL.Events.Sensors` | SDL3-native sensor update event records and constants, wired into the widened `SDL.Events.Events` union for sensor data notifications. | `device_smoke`, manual real-sensor check |
| `SDL.GPU` | Public foundation over `SDL_gpu.h`, now covering device creation, driver and property queries, claimed-window swapchains, command buffers, single-target or multi-target render passes with optional depth-stencil descriptors, explicit GPU buffers or transfer buffers and created textures, buffer and texture debug naming, copy passes, upload or download plus buffer or texture copy helpers, texture-format capability queries, samplers, shaders, graphics and compute pipelines, render or compute bindings, draw or dispatch helpers, uniform uploads, texture blits, fences, idle waits, the renderer-device bridge, the GDK suspend/resume entry points, the first Metal-backed inline shader runtime smoke path, and a portable DXIL/MSL/SPIR-V offscreen spinning-cube smoke path. Broader live backend validation still requires a real GPU/display environment. | `gpu_smoke`, manual real-GPU backend check |
| `SDL.Haptics` | Controlled haptic-device wrapper over `SDL_haptic.h`, covering device enumeration, feature queries, effect creation and control, gain or autocenter settings, and rumble support with explicit live-device error handling. | `device_smoke`, manual real-haptics check |
| `SDL.HIDAPI` | Public wrapper over `SDL_hidapi.h`, covering init/shutdown, device-change counts, enumeration, open-by-path or VID/PID flows, property and device-info lookup, nonblocking mode, raw read/write and report helpers, report-descriptor reads, string queries, and BLE scan control. Empty enumerations are treated as zero devices instead of exceptional failure. | `device_smoke`, manual real-HID check |
| `SDL.Locale` | Preferred-locale enumeration copied into Ada-managed strings from SDL's caller-owned locale array. | `core_smoke`, `alr build` |
| `SDL.Main` | Low-level SDL main-entry helpers and callback types for `SDL_SetMainReady`, `SDL_RunApp`, `SDL_EnterAppMainCallbacks`, and the platform-specific `SDL_RegisterApp`/`SDL_UnregisterApp` helpers; see `docs/main-entry-patterns.md` for Ada entry guidance. | `core_smoke`, `alr build` |
| `SDL.Message_Boxes` | Public wrapper over `SDL_messagebox.h`, covering simple and custom modal message boxes, button records, flags, and color schemes while keeping blocking desktop UI out of automated smoke runs. | `desktop_smoke`, manual real-desktop message-box check |
| `SDL.Misc` | SDL3 misc helpers, currently starting with `SDL_OpenURL`. Runtime validation stays compile-oriented because it launches external applications. | `alr build` |
| `SDL.Mutexes` | Public wrappers for mutexes, RW-locks, semaphores, conditions, and `SDL_InitState` over `SDL_mutex.h`, with explicit ownership and exception-based create failures. | `concurrency_smoke`, `alr build` |
| `SDL.Pens` | SDL3-native pen ID, input-flag, axis, and device-type helpers over `SDL_pen.h`, paired with `SDL.Events.Pens` for event payload coverage and live device-type queries. | `device_smoke`, manual real-pen check |
| `SDL.Properties` | Public wrapper over SDL3 property sets, with the raw import foundation in `SDL.Raw.Properties` for later subsystem work. | `core_smoke`, `alr build` |
| `SDL.Sensors` | Controlled sensor wrapper over `SDL_sensor.h`, covering device enumeration, type queries, properties, live data reads, and explicit update polling without fabricating data when hardware is absent. | `device_smoke`, manual real-sensor check |
| `SDL.Storage` | High-level storage backend wrapper over `SDL_storage.h`, covering title/user/file/custom storage opens, caller-owned read/write buffers, directory/path helpers, and the raw storage-interface callback record without hiding SDL's batch/close lifecycle. | `storage_smoke`, `alr build` |
| `SDL.Systems` | Public facade over `SDL_system.h`, keeping platform-native callbacks and opaque handles explicit while covering sandbox/form-factor queries, application-lifecycle notifications, and platform-specific integration entry points. | `system_smoke`, `alr build` |
| `SDL.Threads` | Thread creation, property-based creation, naming, IDs, wait/detach, priority, TLS, and TLS destructor callbacks over `SDL_thread.h`, with automatic detach on wrapper finalization when the caller has not already consumed the handle. | `concurrency_smoke`, `alr build` |
| `SDL.Processes` | Child-process launch, property-based launch, stdin/stdout pipe helpers, whole-output reads, PID/property inspection, and wait/kill/destroy coverage over `SDL_process.h`, with explicit close helpers that clear SDL's borrowed pipe properties after early closure. | `process_smoke`, `alr build` |
| `SDL.Time` | Realtime clock, calendar conversion, locale time-format preference, and FILETIME helper coverage over `SDL_time.h`. | `core_smoke`, `alr build` |
| `SDL.Trays` | Controlled tray wrapper over `SDL_tray.h`, covering tray creation and destruction, menu and submenu construction, entry enumeration and mutation, callback registration, synthetic click dispatch, and parent lookups while keeping headless runtime limits explicit. | `desktop_smoke`, manual real-desktop tray check |

## Deferred Inventory

None.

## Won't-Bind Inventory

None.
