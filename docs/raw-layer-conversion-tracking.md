# Raw-Layer Conversion Tracking

This file tracks execution of
[raw-layer-conversion-plan.md](raw-layer-conversion-plan.md).

Status values:

- `not started`
- `in progress`
- `partial`
- `complete`
- `blocked`

## Global Completion Checklist

- [x] `SDL.Raw.*` is the only layer that imports C or SDL symbols.
- [x] Every SDL header family used by the public binding has a raw home.
- [x] Public value packages no longer import C or SDL directly.
- [x] Public thick wrappers call only into raw and internal handwritten glue.
- [x] Raw packages depend only on raw or support packages.
- [x] Compatibility packages are frozen and do not gain new low-level behavior.
- [x] A repository check exists for non-raw imports.
- [x] Development docs describe generated raw ownership and review policy.

## Workstream Board

| Workstream | Scope | Status | Notes |
| --- | --- | --- | --- |
| W0 Guardrails | Plan, tracking, target-state docs, reviewer policy | `complete` | Target-state and planning docs now exist, and `tools/check_non_raw_imports.py` provides a checked-in regression check for non-raw imports. |
| W1 Core raw support | Core utility raw families and value-package support types | `in progress` | `SDL.Raw.Assert`, `SDL.Raw.Atomic`, `SDL.Raw.C_Pointers`, `SDL.Raw.CPUInfo`, `SDL.Raw.Error`, `SDL.Raw.Hints`, `SDL.Raw.Init`, `SDL.Raw.LoadSO`, `SDL.Raw.Log`, `SDL.Raw.Misc`, `SDL.Raw.Mutex`, `SDL.Raw.Platform`, `SDL.Raw.Power`, `SDL.Raw.Properties`, `SDL.Raw.System`, `SDL.Raw.Thread`, `SDL.Raw.Time`, `SDL.Raw.Timer`, and `SDL.Raw.Version` now exist. Public cleanup is complete for `SDL`, `SDL.Assertions`, `SDL.AsyncIO`, `SDL.Atomics`, `SDL.CPUS`, `SDL.Clipboard`, `SDL.Error`, `SDL.Filesystems`, `SDL.Hints`, `SDL.Libraries`, `SDL.Locale`, `SDL.Log`, `SDL.Misc`, `SDL.Mutexes`, `SDL.Platform`, `SDL.Power`, `SDL.Processes`, `SDL.Properties`, `SDL.Storage`, `SDL.Systems`, `SDL.Threads`, `SDL.Time`, `SDL.Timers`, and `SDL.Versions`; remaining W1 work is now normalization and review rather than a `Pure`-layer blocker. |
| W2 Value package migration | Public value-heavy packages stop importing directly | `in progress` | Started with `SDL.Pens`, `SDL.Audio.Sample_Formats`, the root `SDL.Events` constants plus common/user event layouts, and `SDL.Events.Events` plus the keyboard, camera, sensor, touch, file-drop, window, mouse, pen, and joystick helper/layout packages now route through raw support families; `SDL.Raw.Events` now owns opaque 128-byte event storage plus typed raw event-pointer callback ABI for queue/filter/window/description entry points, while broader public event union and payload layout cleanup still remains. |
| W3 Wrapper raw backfills | Missing raw families for audio, input, desktop, and device wrappers | `complete` | `SDL.Raw.Audio`, `SDL.Raw.Camera`, `SDL.Raw.Dialog`, `SDL.Raw.Gamepad`, `SDL.Raw.Haptic`, `SDL.Raw.HIDAPI`, `SDL.Raw.Joystick`, `SDL.Raw.Keyboard`, `SDL.Raw.MessageBox`, `SDL.Raw.Mouse`, `SDL.Raw.Pen`, `SDL.Raw.Sensor`, and `SDL.Raw.Tray` now exist. Pure support splits `SDL.Raw.Gamepad_Events` and `SDL.Raw.Joystick_Events` avoid the old pure-layer blocker, and the planned audio, device, desktop, and input wrappers plus joystick/gamepad maker helpers now route through raw. Remaining conversion work has shifted to event/value cleanup and the broader video/render/GPU normalization streams. |
| W4 Video/render/GPU | Video/render raw families, GPU normalization, public-type leak removal | `complete` | `SDL.Raw.Metal`, `SDL.Raw.Pixels`, `SDL.Raw.Rect`, `SDL.Raw.Render`, `SDL.Raw.Surface`, `SDL.Raw.Video`, and `SDL.Raw.Vulkan` now exist as starter families for Metal view lifecycle, palette and pixel-format ownership/mutation/query helpers, rectangle intersection/enclosing/clipping helpers, full texture and renderer creation/query/state/draw/copy/geometry/readback/present plus texture property/lock/update/palette/blend/colour/alpha/size/destruction entry points, full surface creation/load/save/property/blit/clip/palette/key/modulation/blend/lock/RLE/alternate-image/transform/convert/pixel helpers, and broad video/window driver, theme, screensaver, display, GL/EGL, window, and Vulkan support. Public video/render wrappers are now routed through raw, `SDL.Raw.GPU` is normalized as a strict raw mirror aside from intentional byte/opaque-address ABI fields, and `SDL.Raw.Video` is normalized as a strict raw mirror aside from intentional driver-internal, platform-handle, proc-address, blob, and callback-user-data address surfaces. |
| W5 Closure and enforcement | Lint/checking, compatibility freeze, final doc cleanup | `complete` | The non-raw import baseline check now exists under `tools/`, the generated-raw ownership plus compatibility-freeze policy are documented, the compatibility queue is explicitly closed for `SDL.C_Pointers`, `SDL.Events.Controllers`, `SDL.Inputs`, and `SDL.RWops*`, `SDL.Raw.C_Pointers` owns the shared opaque SDL handle types used below raw, handwritten video bridge glue uses child support packages instead of linker-visible Ada hooks, and raw packages now depend only on raw or support packages. Remaining repository work is normalization inside W1/W2/W4 rather than another closure/enforcement blocker. |

## Existing Raw Families

These families already exist but still need review against the generated target
state.

| Raw family | Current state | Status | Notes |
| --- | --- | --- | --- |
| `SDL.Raw.Assert` | present | `complete` | Existing raw family owns the assertion ABI types, handler callback, and report/reset entry points used by `SDL.Assertions`, while the public wrapper keeps Ada string conversion and convenience accessors above raw. |
| `SDL.Raw.Audio` | present | `complete` | Added as a starter family and now owns the audio driver, device, WAV, mixing, conversion, postmix callback ABI, and audio-stream entry points used by `SDL.Audio`, `SDL.Audio.Devices`, and `SDL.Audio.Streams`. |
| `SDL.Raw.AsyncIO` | present | `complete` | Existing raw family now also owns async-result buffer cleanup, and `SDL.AsyncIO` no longer imports SDL symbols directly. |
| `SDL.Raw.Atomic` | present | `complete` | Existing raw family owns the atomic integer, unsigned, pointer, spinlock, and memory-barrier entry points used by `SDL.Atomics`, while the public package keeps the Ada object wrappers above raw. |
| `SDL.Raw.Camera` | present | `complete` | Raw camera now owns the `SDL_CameraSpec` ABI record, typed spec-list helpers, and typed camera-handle entry points used by `SDL.Cameras`, leaving only surface ownership policy above raw. |
| `SDL.Raw.Clipboard` | present | `complete` | Existing raw family now owns clipboard-result cleanup and typed pointer helpers, and `SDL.Clipboard` no longer imports SDL symbols directly. |
| `SDL.Raw.C_Pointers` | present | `complete` | Added as a raw support family for shared opaque SDL handle pointer types; raw device, IO, and process families now depend on it instead of the public `SDL.C_Pointers` compatibility package. |
| `SDL.Raw.CPUInfo` | present | `complete` | Added as a pure-support raw family and now owns all CPU feature and capacity imports used by `SDL.CPUS`. |
| `SDL.Raw.Dialog` | present | `complete` | Added and now owns the dialog ABI enum, filter struct, callback signature, and entry points used by `SDL.Dialogs`. |
| `SDL.Raw.Error` | present | `complete` | Added as the first phase-1 raw support family and now owns all `SDL_Error` imports. |
| `SDL.Raw.Event_Layouts` | present | `complete` | Added as a pure raw support package for the root common/user SDL event record layouts so `SDL.Events` can route those ABI-shaped value types through raw without depending on imported `SDL.Raw.Events`. |
| `SDL.Raw.Event_Layouts.Cameras` | present | `complete` | Added as a pure raw support package for camera event constants and the camera device-event layout so `SDL.Events.Cameras` can route those ABI-shaped value types through raw support. |
| `SDL.Raw.Event_Layouts.Files` | present | `complete` | Added as a raw support package for file-drop event constants and the drop-event layout so `SDL.Events.Files` can route those ABI-shaped value types through raw support; it is `Preelaborate` rather than `Pure` because the SDL drop-event ABI exposes C string pointers. |
| `SDL.Raw.Event_Layouts.Joysticks` | present | `complete` | Added as a pure raw support package for joystick event constants, index and value scalar types, hat-position flags, and axis/ball/hat/button/device/battery event layouts so `SDL.Events.Joysticks` can route those ABI-shaped value types through raw support while leaving polling and button-state helpers public. |
| `SDL.Raw.Event_Layouts.Keyboards` | present | `complete` | Added as a preelaborable raw support package for keyboard event constants plus keyboard/device/text-edit/text-input event layouts so `SDL.Events.Keyboards` can route those ABI-shaped value types through raw support while leaving naming and conversion helpers public. |
| `SDL.Raw.Event_Layouts.Mice` | present | `complete` | Added as a pure raw support package for mouse event constants, button and wheel scalar types, and motion/device/button/wheel event layouts so `SDL.Events.Mice` can route those ABI-shaped value types through raw support while leaving convenience helpers public. |
| `SDL.Raw.Event_Layouts.Pens` | present | `complete` | Added as a pure raw support package for pen event constants, coordinate and button scalar types, and proximity/motion/touch/button/axis event layouts so `SDL.Events.Pens` can route those ABI-shaped value types through raw support while leaving state helpers public. |
| `SDL.Raw.Event_Layouts.Touches` | present | `complete` | Added as a preelaborable raw support package for the SDL3 finger-event constants and finger-event layout so `SDL.Events.Touches` can route the native touch-event payload through raw support while leaving SDL2-compatibility gesture carriers handwritten. |
| `SDL.Raw.Event_Layouts.Windows` | present | `complete` | Added as a pure raw support package for window event constants and the window-event layout so `SDL.Events.Windows` can route the ABI-shaped value type and event IDs through raw support while keeping compatibility helpers public. |
| `SDL.Raw.Event_Layouts.Sensors` | present | `complete` | Added as a pure raw support package for sensor event constants, fixed data array layout, and sensor update-event layout so `SDL.Events.Sensors` can route those ABI-shaped value types through raw support. |
| `SDL.Raw.Event_Types` | present | `complete` | Added as a pure raw support package for root SDL event-type constants so pure public event value packages can route constants through raw without depending on imported `SDL.Raw.Events`. |
| `SDL.Raw.Events` | present | `complete` | Raw events now own the event queue, pump, filter/watch, enablement, registration, window lookup, and description entry points used by `SDL.Events.Events`, using opaque 128-byte event storage plus typed event-pointer/window-handle callback ABI below the handwritten public event union layout. |
| `SDL.Raw.Filesystem` | present | `complete` | Existing raw family now also owns filesystem-result cleanup helpers, and `SDL.Filesystems` no longer imports SDL symbols directly. |
| `SDL.Raw.Gamepad` | present | `complete` | Now owns the broader gamepad mapping, metadata, binding ABI, touchpad, sensor, rumble, and symbol entry points used by `SDL.Inputs.Joysticks.Game_Controllers`; pure event polling remains split into `SDL.Raw.Gamepad_Events`, and both the public wrapper and maker now route through raw. |
| `SDL.Raw.Gamepad_Events` | present | `complete` | Pure support split that owns the gamepad event-polling entry points used by `SDL.Events.Joysticks.Game_Controllers`. |
| `SDL.Raw.GPU` | present | `complete` | It no longer depends on public rectangle or pixel-format value packages; swapchain/window entry points use raw video window handles; scissor, fence, render/compute pass, binding-list, and graphics-pipeline list ABI now route through raw-owned rectangle, handle, record, access, and array types; and the remaining `System.Address` sites are intentional byte-buffer or opaque mapped-pointer ABI surfaces rather than normalization debt. |
| `SDL.Raw.Haptic` | present | `complete` | Raw haptic now owns the haptic effect ABI records and union plus typed haptic/joystick handle entry points and ID-list helpers used by `SDL.Haptics`, leaving only public ownership and policy wrappers above raw. |
| `SDL.Raw.HIDAPI` | present | `complete` | Added and now owns the HIDAPI ABI enums, wide-string helpers, device-info struct, and entry points used by `SDL.HIDAPI`. |
| `SDL.Raw.Hints` | present | `complete` | Added and now owns all hint query, mutation, and callback registration imports used by `SDL.Hints`. |
| `SDL.Raw.Init` | present | `complete` | Now pure-safe, covers init/quit/metadata imports, and is consumed from the `SDL` body so the public top-level package no longer imports SDL symbols directly. |
| `SDL.Raw.IOStream` | present | `complete` | Now uses shared raw opaque-handle support from `SDL.Raw.C_Pointers` and serves as the generator-shaped owner of the `SDL_IOStream` ABI surface used by the public RWops compatibility layer and other wrapper code. |
| `SDL.Raw.Joystick` | present | `complete` | Now owns joystick enumeration, metadata, virtual-joystick ABI, property, power, state, rumble, and virtual-input entry points used by `SDL.Inputs.Joysticks`, while pure event polling remains split into `SDL.Raw.Joystick_Events`. |
| `SDL.Raw.Joystick_Events` | present | `complete` | Pure support split that owns the joystick event-polling entry points used by `SDL.Events.Joysticks`. |
| `SDL.Raw.Keyboard` | present | `complete` | Raw keyboard now owns the typed keyboard focus, enumeration, modifier, state, naming/conversion, screen-keyboard, and text-input imports, including raw window and rectangle parameters for text-input area control; broader keyboard event payload layout remains correctly scoped under `SDL.Raw.Events` instead of this family. |
| `SDL.Raw.Keyboard_Types` | present | `complete` | Added as a pure raw support package for shared keyboard identifiers, modifier/key/scancode scalar types, and the public subset of modifier and scan-code constants so pure/public keyboard-facing packages can share ABI-owned scalars without depending on imported `SDL.Raw.Keyboard`. |
| `SDL.Raw.LoadSO` | present | `complete` | Added and now owns all shared-object loading imports used by `SDL.Libraries`. |
| `SDL.Raw.Locale` | present | `complete` | Existing raw family now also owns locale-list cleanup via `SDL_free`, and `SDL.Locale` no longer imports SDL symbols directly. |
| `SDL.Raw.Log` | present | `complete` | Added and now owns all SDL log entry points, including callback and variadic logging APIs, used by `SDL.Log`. |
| `SDL.Raw.Main` | present | `complete` | Now owns the app-entry callback ABI types split out of `SDL.Raw.Init`, using raw address-based event callback parameters so it no longer depends on public event-layout packages, while higher-level callback policy remains in handwritten `SDL.Main` wrapper code above raw. |
| `SDL.Raw.Main_Callbacks` | present | `complete` | Raw support package for the exported `SDL_App*` callback entry points, now bridged through raw callback ABI types without depending on `SDL.Main` or public event-layout packages. |
| `SDL.Raw.Metal` | present | `complete` | Added as a narrow support family and now owns the Metal view create/destroy/get-layer entry points used by `SDL.Video.Metal`. |
| `SDL.Raw.MessageBox` | present | `complete` | Added and now owns the message-box entry points used by `SDL.Message_Boxes`, while the public wrapper keeps struct assembly and string policy. |
| `SDL.Raw.Misc` | present | `complete` | Narrow raw family now owns `SDL_OpenURL`, and the public `SDL.Misc` wrapper routes string conversion and error policy through it without direct imports. |
| `SDL.Raw.Mutex` | present | `complete` | Existing raw family now owns the mutex, RW-lock, semaphore, condition, and one-time-init entry points used by `SDL.Mutexes`, while the public wrapper keeps controlled ownership and exception policy above raw. |
| `SDL.Raw.Mouse` | present | `complete` | Now owns mouse focus, enumeration, capture, state, relative-mode, transform, cursor-visibility, warp, and cursor-creation/get/set/destroy entry points used by `SDL.Inputs.Mice` and `SDL.Inputs.Mice.Cursors`. |
| `SDL.Raw.Pen` | present | `complete` | Added as a pure-support raw family and now owns the pen device-type import used by `SDL.Pens`. |
| `SDL.Raw.Pixels` | present | `complete` | Raw pixels now own the `SDL_Color`, `SDL_Palette`, and pixel-format-detail ABI records plus typed palette, naming, mask-conversion, and RGB/RGBA helper imports used by `SDL.Video.Palettes` and `SDL.Video.Pixel_Formats`, while public colour and format helpers remain handwritten above raw. |
| `SDL.Raw.Platform` | present | `complete` | Added and now owns all `SDL_GetPlatform` imports. |
| `SDL.Raw.Power` | present | `complete` | Added as a pure-support raw family and now owns all `SDL_GetPowerInfo` imports. |
| `SDL.Raw.Process` | present | `complete` | Existing raw family now also owns process-output cleanup, and `SDL.Processes` routes stream helpers through raw instead of importing them directly. |
| `SDL.Raw.Properties` | present | `complete` | Existing raw family owns the SDL property-set ABI surface used by `SDL.Properties`, while the public wrapper keeps string conversion, ownership, and exception policy above raw. |
| `SDL.Raw.Rect` | present | `complete` | Raw rectangle support now owns the integer and floating rectangle/point ABI records plus the typed access and array helpers, intersection, union, enclosing-points, and line-clipping imports used by `SDL.Video.Rectangles` and raw video window geometry; higher-level geometry helpers remain handwritten above raw. |
| `SDL.Raw.Render` | present | `complete` | Now owns renderer discovery, properties, GPU render-state, output/target/logical-presentation/viewport/clip/scale state, draw colour/blend/clear primitives, texture copy/rotation/affine/tiled/9-grid, geometry, readback, present/flush, Metal/Vulkan hooks, default texture scale mode, renderer destruction, and the texture property/lock/update/palette/blend/colour/alpha/size/destroy entry points used by `SDL.Video.Renderers`, `SDL.Video.Renderers.Makers`, `SDL.Video.Textures`, and their maker helpers. |
| `SDL.Raw.Sensor` | present | `complete` | Added as a device-support raw family and now owns sensor enumeration, lookup, property, data, lifecycle, and update imports used by `SDL.Sensors`. |
| `SDL.Raw.Surface` | present | `complete` | Now owns the surface creation/load/save/property/blit/clip/palette/key/modulation/blend/lock/RLE/alternate-image/transform/convert/colour-space/per-pixel entry points used by `SDL.Video.Surfaces` and `SDL.Video.Surfaces.Makers`, while generic RGBA mapping/detail helpers remain in `SDL.Raw.Pixels`. |
| `SDL.Raw.Storage` | present | `complete` | Existing raw family now also uses raw filesystem pointer helpers for glob results, and `SDL.Storage` no longer imports SDL symbols directly. |
| `SDL.Raw.System` | present | `complete` | Existing raw family now owns the system, platform-hook, Android, iOS, and sandbox entry points used by `SDL.Systems`, while the public wrapper keeps string conversion, handle shaping, and thread/window bridge policy above raw. |
| `SDL.Raw.Timer` | present | `complete` | Now pure-safe and owns all timer, delay, and performance-counter imports used by `SDL.Timers`. |
| `SDL.Raw.Thread` | present | `complete` | Existing raw family now owns the thread creation, state, priority, and TLS imports used by `SDL.Threads`, while the public wrapper keeps name conversion, ownership, and detach/wait policy above raw. |
| `SDL.Raw.Time` | present | `complete` | Existing raw family now owns the locale-preference, current-time, date-time conversion, Windows-file-time, and calendar helper imports used by `SDL.Time`. |
| `SDL.Raw.Touch` | present | `complete` | Added as a touch-support raw family and now owns touch device enumeration, name/type queries, finger-list ABI, and cleanup helpers used by `SDL.Events.Touches`. |
| `SDL.Raw.Tray` | present | `complete` | Added and now owns the tray callback ABI type, address-array helper, and all tray/menu/entry entry points used by `SDL.Trays`. |
| `SDL.Raw.UTF_8` | present | `complete` | Narrow raw UTF-8 support now owns the invalid-codepoint constant plus forward-step, reverse-step, and encode ABI helpers used below the public `SDL.UTF_8` support layer. |
| `SDL.Raw.Video_Types` | present | `complete` | Added as a pure raw support package for shared video/window identifier scalars so raw event-layout support packages and public window-ID aliases can share the same ABI-owned `Window_ID` type without depending on imported `SDL.Raw.Video`. |
| `SDL.Raw.Video` | present | `complete` | Added as a starter family for video-driver enumeration, current-driver lookup, system-theme query, screensaver control, display enumeration/mode/bounds/orientation queries, GL/EGL attribute/context/proc/swap/library helpers, custom blend-mode composition, and broad window creation/query/mutation/surface/grab/progress/hit-test support used by `SDL.Video`, `SDL.Video.Displays`, `SDL.Video.GL`, maker helpers, window management, and `SDL.Video.Windows`; display point/rect and bounds queries use raw-owned rectangle ABI types, window/GL/surface handle plus fullscreen-mode imports use raw-owned pointer and mode types, window safe-area/update-rect/mouse-rect imports route through `SDL.Raw.Rect`, hit-test callbacks reuse raw window and point ABI types, and the remaining `System.Address` sites are intentional driver-internal, platform-handle, proc-address, ICC/blob, or callback-user-data ABI surfaces rather than normalization debt. |
| `SDL.Raw.Vulkan` | present | `complete` | Added as a generic raw support family for Vulkan surface create/destroy, instance-extension enumeration, proc-address lookup, presentation support, and loader entry points used by `SDL.Video.Vulkan`. |
| `SDL.Raw.Version` | present | `complete` | Added and now owns all version-query imports used by `SDL.Versions`. |

## Missing Raw Families To Add

No additional raw families are currently missing from the tracked target-state
inventory.

## Public Non-Raw Import Cleanup Queue

This queue records public packages that currently contain `Import => True` or
`pragma Import` and therefore need review under the new rule set.

### Core And Utility

| Package | Target classification | Status | Notes |
| --- | --- | --- | --- |
| `SDL` | public wrapper | `complete` | Public package no longer imports SDL symbols directly; init/quit and metadata helpers route through pure `SDL.Raw.Init` from the body, which avoids the parent-to-child spec dependency cycle. |
| `SDL.AsyncIO` | public wrapper | `complete` | Public package now routes entirely through `SDL.Raw.AsyncIO`. |
| `SDL.CPUS` | public value layer | `complete` | Public package now routes entirely through pure `SDL.Raw.CPUInfo`. |
| `SDL.Clipboard` | public wrapper | `complete` | Public package now routes entirely through `SDL.Raw.Clipboard`. |
| `SDL.Error` | public value layer | `complete` | Public package now routes entirely through `SDL.Raw.Error`. |
| `SDL.Filesystems` | public wrapper | `complete` | Public package now routes entirely through `SDL.Raw.Filesystem`. |
| `SDL.Hints` | public wrapper | `complete` | Public package now routes entirely through `SDL.Raw.Hints`. |
| `SDL.Libraries` | public wrapper | `complete` | Public package now routes entirely through `SDL.Raw.LoadSO`. |
| `SDL.Locale` | public wrapper | `complete` | Public package now routes entirely through `SDL.Raw.Locale`. |
| `SDL.Log` | public wrapper | `complete` | Public package now routes entirely through `SDL.Raw.Log`. |
| `SDL.Platform` | public value layer | `complete` | Public package now routes entirely through `SDL.Raw.Platform`. |
| `SDL.Power` | public value layer | `complete` | Public package now re-exports the raw-owned power-state enum from pure `SDL.Raw.Power`, while `Battery_Info` shaping and the `Info` helper stay handwritten above raw. |
| `SDL.Processes` | public wrapper | `complete` | Public package now routes entirely through `SDL.Raw.Process` and `SDL.Raw.IOStream`. |
| `SDL.Storage` | public wrapper | `complete` | Public package now routes entirely through `SDL.Raw.Storage` and raw filesystem support helpers. |
| `SDL.Timers` | public value or thin wrapper layer | `complete` | Public package now routes entirely through pure `SDL.Raw.Timer`, keeping local callback types while backing public scalars with raw-compatible subtypes. |
| `SDL.Versions` | public value layer | `complete` | Public package now routes entirely through `SDL.Raw.Version`. |

### Events And Input

| Package | Target classification | Status | Notes |
| --- | --- | --- | --- |
| `SDL.Events` | public value layer | `complete` | Public root event package now routes root event-type constants through pure `SDL.Raw.Event_Types`, shared keyboard and window IDs through pure `SDL.Raw.Keyboard_Types` and `SDL.Raw.Video_Types`, and common/user event record layouts through pure `SDL.Raw.Event_Layouts`, while higher-level event union shaping stays handwritten. |
| `SDL.Events.Cameras` | public value layer | `complete` | Public camera event package now routes camera event constants and device-event layout through pure `SDL.Raw.Event_Layouts.Cameras`. |
| `SDL.Events.Events` | public value layer plus queue wrapper | `complete` | Public queue/filter/watch wrapper now routes event pump, polling, peep/count, enablement, registration, window lookup, and description entry points through `SDL.Raw.Events` and `SDL.Raw.Video`, using raw-owned opaque event storage and raw callback ABI for queue/filter-facing calls while the public event union layout and filter callback type stay handwritten. |
| `SDL.Events.Files` | public value layer | `complete` | Public file-drop event package now routes drop-event constants and the drop-event layout through `SDL.Raw.Event_Layouts.Files`, while pointer ownership policy stays documented at the public layer. |
| `SDL.Events.Joysticks` | public value layer | `complete` | Public joystick event package now routes joystick event constants, index and value scalar types, hat-position flags, and axis/ball/hat/button/device/battery event layouts through pure `SDL.Raw.Event_Layouts.Joysticks`, while event polling controls stay on pure `SDL.Raw.Joystick_Events` and the button-state helper stays handwritten. |
| `SDL.Events.Joysticks.Game_Controllers` | public value layer | `complete` | Event polling controls now route through pure `SDL.Raw.Gamepad_Events`; broader event layout migration still depends on `SDL.Raw.Events`. |
| `SDL.Events.Keyboards` | public value layer | `complete` | Public keyboard event package now routes shared key/scancode/modifier types through pure `SDL.Raw.Keyboard_Types`, keyboard/device/text-edit/text-input event constants and layouts through `SDL.Raw.Event_Layouts.Keyboards`, and the naming/conversion helpers through `SDL.Raw.Keyboard`. |
| `SDL.Events.Mice` | public value layer | `complete` | Public mouse event package now routes mouse event constants, scalar types, and motion/device/button/wheel event layouts through pure `SDL.Raw.Event_Layouts.Mice`, while button-mask, wheel, and state convenience helpers stay handwritten. |
| `SDL.Events.Pens` | public value layer | `complete` | Public pen event package now routes pen event constants, coordinate and button scalar types, and proximity/motion/touch/button/axis event layouts through pure `SDL.Raw.Event_Layouts.Pens`, while the touch/button state helpers stay handwritten. |
| `SDL.Events.Sensors` | public value layer | `complete` | Public sensor event package now routes sensor update constants, fixed data-array layout, and update-event layout through pure `SDL.Raw.Event_Layouts.Sensors`. |
| `SDL.Events.Touches` | public value layer | `complete` | Public touch package now routes touch identifiers, device-type metadata, finger structs, and finger-event constants/layout through `SDL.Raw.Touch` plus `SDL.Raw.Event_Layouts.Touches`, while the SDL2-compatibility dollar/multigesture carriers stay handwritten. |
| `SDL.Events.Windows` | public value layer | `complete` | Public window event package now routes window event constants and the window-event layout through pure `SDL.Raw.Event_Layouts.Windows`, while the SDL2-compatibility event-ID mapping helpers stay handwritten. |
| `SDL.Inputs.Joysticks` | public wrapper | `complete` | Public wrapper now routes joystick enumeration, metadata, virtual-joystick setup, property, power, state, rumble, and virtual-input calls through `SDL.Raw.Joystick`, while joystick haptic checks continue to use `SDL.Raw.Haptic`. |
| `SDL.Inputs.Joysticks.Game_Controllers` | public wrapper | `complete` | Public wrapper now routes gamepad enumeration, mappings, binding queries, metadata, joystick bridge, properties, touchpad, sensor, rumble, LED, and Apple symbol helpers through `SDL.Raw.Gamepad`, while wrapper ownership and compatibility shaping stay handwritten. |
| `SDL.Inputs.Joysticks.Game_Controllers.Makers` | public maker wrapper | `complete` | Open helpers now route through `SDL.Raw.Gamepad`. |
| `SDL.Inputs.Joysticks.Makers` | public maker wrapper | `complete` | Open helpers now route through `SDL.Raw.Joystick`. |
| `SDL.Inputs.Keyboards` | public wrapper | `complete` | Public wrapper now routes keyboard focus, enumeration, modifiers, state, screen-keyboard queries, and text-input control through `SDL.Raw.Keyboard`, using `SDL.Raw.Video` only for focused-window ID lookup. |
| `SDL.Inputs.Mice` | public wrapper | `complete` | Public wrapper now routes mouse focus, enumeration, capture, state, relative-mode control, relative transform, cursor visibility, and warp calls through `SDL.Raw.Mouse`, using `SDL.Raw.Keyboard` and `SDL.Raw.Video` only for focused-window fallback and ID lookup. |
| `SDL.Inputs.Mice.Cursors` | public thick wrapper | `complete` | Public thick wrapper now routes cursor creation, lookup, set, and destroy calls through `SDL.Raw.Mouse`, while the surface-handle bridge used to feed SDL surface pointers remains handwritten glue above raw. |
| `SDL.Pens` | public value layer | `complete` | Public package now re-exports raw-owned pen IDs, flags, axes, and device-type enums from pure `SDL.Raw.Pen`, while the public flag helper and device-type query stay handwritten above raw. |
| `SDL.Sensors` | public wrapper | `complete` | Public package now routes sensor enumeration, metadata, data access, lifecycle, and update calls through `SDL.Raw.Sensor`. |

### Audio, Devices, And Desktop

| Package | Target classification | Status | Notes |
| --- | --- | --- | --- |
| `SDL.Audio` | public wrapper | `complete` | Public package now routes core audio drivers, device queries, WAV loading, mixing, conversion, and postmix callback ABI through `SDL.Raw.Audio`, while hint policy, array copying, and callback lifetime stay handwritten. |
| `SDL.Audio.Devices` | public thick wrapper | `complete` | Public generic package now routes device enumeration, open/close, format queries, audio-stream plumbing, and playback callback ABI through `SDL.Raw.Audio`, while generic buffer typing and callback policy stay handwritten. |
| `SDL.Audio.Sample_Formats` | public value layer | `complete` | Public sample-format constants now route through `SDL.Raw.Audio`, while endian selection and bit/byte/sign helper predicates stay handwritten. |
| `SDL.Audio.Streams` | public thick wrapper | `complete` | Public package now routes stream creation, device-stream open/bind/unbind, format/gain/frequency/channel-map queries, queue/dequeue operations, device pause/lock helpers, and stream callback ABI through `SDL.Raw.Audio`, while buffer copying and error policy stay handwritten. |
| `SDL.Cameras` | public thick wrapper | `complete` | Public package now routes camera discovery, open/close, permission, property, format, and frame entry points through `SDL.Raw.Camera`, while keeping public spec-value conversion and surface ownership policy handwritten above the raw ABI layer. |
| `SDL.Dialogs` | public wrapper | `complete` | Public package now routes dialog ABI types and entry points through `SDL.Raw.Dialog`, while keeping callback lifetime, filter assembly, and property policy handwritten. |
| `SDL.HIDAPI` | public thick wrapper | `complete` | Public package now routes HID device enumeration, I/O, wide-string queries, and device-info ABI through `SDL.Raw.HIDAPI`, while keeping UTF conversion, ownership, and error policy handwritten. |
| `SDL.Haptics` | public thick wrapper | `complete` | Public package now routes haptic device enumeration, ownership, effect control, and rumble entry points through `SDL.Raw.Haptic`, while re-exporting raw-owned effect ABI types and keeping ownership and error policy handwritten above raw. |
| `SDL.Message_Boxes` | public wrapper | `complete` | Public package now routes all SDL message-box entry points through `SDL.Raw.MessageBox`. |
| `SDL.Trays` | public thick wrapper | `complete` | Public package now routes tray, menu, and entry ABI calls through `SDL.Raw.Tray`, while callback registry policy, string lifetime, and menu-tree ownership remain handwritten. |

### Video And GPU

| Package | Target classification | Status | Notes |
| --- | --- | --- | --- |
| `SDL.Video` | public wrapper | `complete` | Public wrapper now routes driver enumeration, current-driver lookup, system-theme query, custom blend-mode composition, and screensaver control through `SDL.Raw.Video`, while subsystem init/quit policy still stays handwritten. |
| `SDL.Video.Displays` | public wrapper | `complete` | Public wrapper now routes display enumeration, primary-display lookup, names, properties, closest/current/desktop/fullscreen modes, bounds, content scale, and orientation queries through `SDL.Raw.Video`, while index validation, string copying, and public mode/orientation shaping stay handwritten. |
| `SDL.Video.GL` | public wrapper | `complete` | Public wrapper now routes GL/EGL attribute, context, current-window, drawable-size, proc-address, extension, swap-interval, swap-window, and library entry points through `SDL.Raw.Video`, while legacy SDL2-removed bind/unbind policy, profile/flag shaping, and public callback types stay handwritten. |
| `SDL.Video.Metal` | public thick wrapper | `complete` | Public wrapper now routes Metal view create/destroy/get-layer calls through `SDL.Raw.Metal`, while view ownership and error policy stay handwritten. |
| `SDL.Video.Palettes` | public wrapper | `complete` | Public wrapper now routes palette allocation, mutation, destruction, and colour-pointer access through `SDL.Raw.Pixels`, while iterator and copy policy stay handwritten. |
| `SDL.Video.Pixel_Formats` | public value layer | `complete` | Public value helpers now route pixel-format detail lookup, naming, mask conversion, and RGB/RGBA mapping through `SDL.Raw.Pixels`, while the public constants and record layout stay handwritten. |
| `SDL.Video.Rectangles` | public value layer | `complete` | Public rectangle helpers now route intersection, union, enclosing-points, and line-clipping calls through `SDL.Raw.Rect`, converting between public geometry values and raw-owned point/rectangle ABI records while keeping the public geometry types handwritten. |
| `SDL.Video.Renderers` | public thick wrapper | `complete` | Public thick wrapper now routes renderer discovery, lookup, properties, GPU render-state control, output/target/logical-presentation/viewport/clip/scale state, draw colour/blend/clear primitives, texture copy/rotation/affine/tiled/9-grid, geometry, readback, presentation, Metal/Vulkan hooks, VSync, debug text, and default texture scale mode through `SDL.Raw.Render` and `SDL.Raw.Video`, while typed geometry, ownership, and GPU helper assembly stay handwritten. |
| `SDL.Video.Renderers.Makers` | public maker wrapper | `complete` | Renderer creation helpers now route through `SDL.Raw.Render`. |
| `SDL.Video.Surfaces` | public thick wrapper | `complete` | Public thick wrapper now routes surface properties, blit/fill/clip, palette/key/modulation/blend, lock/RLE, save helpers, alternate-image lists, flip/rotate/duplicate/scale/convert, colour-space, pixel conversion/premultiply/clear/stretch/tiled blits, and per-pixel map/read/write calls through `SDL.Raw.Surface` and `SDL.Raw.Pixels`, while ownership, error policy, and typed views stay handwritten. |
| `SDL.Video.Surfaces.Makers` | public maker wrapper | `complete` | Surface maker helpers now route surface creation and file/IO loading entry points through `SDL.Raw.Surface`, while format selection and ownership policy stay handwritten. |
| `SDL.Video.Textures` | public thick wrapper | `complete` | Public wrapper now routes texture properties, lock/unlock, surface-lock bridge, pixel updates, palette binding, scale/blend mode, colour/alpha modulation, size queries, and destruction through `SDL.Raw.Render`, while property decoding, state checks, and palette/surface bridging stay handwritten. |
| `SDL.Video.Textures.Makers` | public maker wrapper | `complete` | Texture creation helpers now route through `SDL.Raw.Render`. |
| `SDL.Video.Vulkan` | public wrapper | `complete` | Public generic wrapper now routes Vulkan surface lifecycle, instance-extension enumeration, proc-address lookup, presentation support, library loading, and drawable-size queries through `SDL.Raw.Vulkan` and `SDL.Raw.Video`. |
| `SDL.Video.Windows` | public thick wrapper | `complete` | Public thick wrapper now routes the shared window-ID scalar through pure `SDL.Raw.Video_Types` and the window lookup/listing, display and property queries, title/icon/surface access, position/size/fullscreen/aspect/border/min-max state, visibility/focus/fullscreen/sync/surface update paths, keyboard/mouse grab and mouse-rect state, opacity/parent/modal/focusable/system-menu/hit-test/shape control, flash/progress APIs, and destruction through `SDL.Raw.Video`, while ownership, ID-list shaping, fullscreen-mode resolution, ICC copy-out, and callback-facing policy stay handwritten. |
| `SDL.Video.Windows.Makers` | public maker wrapper | `complete` | Window creation helpers now route through `SDL.Raw.Video`. |
| `SDL.Video.Windows.Manager` | public wrapper/support layer | `complete` | Window manager property lookup now routes through `SDL.Raw.Video`. |

## Compatibility Freeze Queue

These packages should remain supported but should not gain new low-level import
or ABI responsibilities during conversion.

| Package | Status | Notes |
| --- | --- | --- |
| `SDL.C_Pointers` | `complete` | Compatibility/support-only opaque-pointer namespace; no direct imports or new raw-home responsibilities should be added here. |
| `SDL.Events.Controllers` | `complete` | Frozen migration/value alias layer over joystick and gamepad event families; it remains handwritten and does not own direct SDL imports. |
| `SDL.Inputs` | `complete` | Shared compatibility namespace only; the root package stays pure and does not grow low-level behavior. |
| `SDL.RWops` | `complete` | Compatibility wrapper now routes through `SDL.Raw.IOStream` and `SDL.Raw.Filesystem` support, without keeping its own direct C imports. |
| `SDL.RWops.Streams` | `complete` | Compatibility stream bridge now routes raw read/write/status access through `SDL.Raw.IOStream`. |

## Tracking Discipline

When a conversion change lands:

- Update the relevant workstream status.
- Update the raw-family row if a new raw package was added or normalized.
- Update the package row for every public family touched.
- Record blockers explicitly instead of leaving ambiguous partial progress.
