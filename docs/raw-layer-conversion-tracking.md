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

- [ ] `SDL.Raw.*` is the only layer that imports C or SDL symbols.
- [ ] Every SDL header family used by the public binding has a raw home.
- [ ] Public value packages no longer import C or SDL directly.
- [ ] Public thick wrappers call only into raw and internal handwritten glue.
- [ ] Raw packages depend only on raw or support packages.
- [ ] Compatibility packages are frozen and do not gain new low-level behavior.
- [ ] A repository check exists for non-raw imports.
- [ ] Development docs describe generated raw ownership and review policy.

## Workstream Board

| Workstream | Scope | Status | Notes |
| --- | --- | --- | --- |
| W0 Guardrails | Plan, tracking, target-state docs, reviewer policy | `in progress` | Target-state and planning docs now exist. Enforcement tooling is still open. |
| W1 Core raw support | Core utility raw families and value-package support types | `in progress` | `SDL.Raw.CPUInfo`, `SDL.Raw.Error`, `SDL.Raw.Hints`, `SDL.Raw.Init`, `SDL.Raw.LoadSO`, `SDL.Raw.Log`, `SDL.Raw.Platform`, `SDL.Raw.Power`, `SDL.Raw.Timer`, and `SDL.Raw.Version` now exist. Public cleanup is complete for `SDL`, `SDL.AsyncIO`, `SDL.CPUS`, `SDL.Clipboard`, `SDL.Error`, `SDL.Filesystems`, `SDL.Hints`, `SDL.Libraries`, `SDL.Locale`, `SDL.Log`, `SDL.Platform`, `SDL.Power`, `SDL.Processes`, `SDL.Storage`, `SDL.Timers`, and `SDL.Versions`; remaining W1 work is now normalization and review rather than a `Pure`-layer blocker. |
| W2 Value package migration | Public value-heavy packages stop importing directly | `not started` | Includes event payload families and pure helper/value units. |
| W3 Wrapper raw backfills | Missing raw families for audio, input, desktop, and device wrappers | `not started` | Add raw first, then migrate wrappers. |
| W4 Video/render/GPU | Video/render raw families, GPU normalization, public-type leak removal | `not started` | Largest mixed layer in the current tree. |
| W5 Closure and enforcement | Lint/checking, compatibility freeze, final doc cleanup | `not started` | Should land only after most conversion work is done. |

## Existing Raw Families

These families already exist but still need review against the generated target
state.

| Raw family | Current state | Status | Notes |
| --- | --- | --- | --- |
| `SDL.Raw.Assert` | present | `partial` | Existing raw family; review for generated ownership once conversion reaches assertions. |
| `SDL.Raw.AsyncIO` | present | `complete` | Existing raw family now also owns async-result buffer cleanup, and `SDL.AsyncIO` no longer imports SDL symbols directly. |
| `SDL.Raw.Atomic` | present | `partial` | Existing raw family; mostly support-oriented. |
| `SDL.Raw.Clipboard` | present | `complete` | Existing raw family now owns clipboard-result cleanup and typed pointer helpers, and `SDL.Clipboard` no longer imports SDL symbols directly. |
| `SDL.Raw.CPUInfo` | present | `complete` | Added as a pure-support raw family and now owns all CPU feature and capacity imports used by `SDL.CPUS`. |
| `SDL.Raw.Error` | present | `complete` | Added as the first phase-1 raw support family and now owns all `SDL_Error` imports. |
| `SDL.Raw.Filesystem` | present | `complete` | Existing raw family now also owns filesystem-result cleanup helpers, and `SDL.Filesystems` no longer imports SDL symbols directly. |
| `SDL.Raw.GPU` | present | `partial` | Must stop depending on public value packages and become a strict raw mirror. |
| `SDL.Raw.Hints` | present | `complete` | Added and now owns all hint query, mutation, and callback registration imports used by `SDL.Hints`. |
| `SDL.Raw.Init` | present | `complete` | Now pure-safe, covers init/quit/metadata imports, and is consumed from the `SDL` body so the public top-level package no longer imports SDL symbols directly. |
| `SDL.Raw.IOStream` | present | `partial` | Closest current example of the target style. |
| `SDL.Raw.LoadSO` | present | `complete` | Added and now owns all shared-object loading imports used by `SDL.Libraries`. |
| `SDL.Raw.Locale` | present | `complete` | Existing raw family now also owns locale-list cleanup via `SDL_free`, and `SDL.Locale` no longer imports SDL symbols directly. |
| `SDL.Raw.Log` | present | `complete` | Added and now owns all SDL log entry points, including callback and variadic logging APIs, used by `SDL.Log`. |
| `SDL.Raw.Main` | present | `partial` | Now owns the app-entry callback ABI types split out of `SDL.Raw.Init`; public main-entry packages still own higher-level callback policy, and event-layout coupling remains until `SDL.Raw.Events` exists. |
| `SDL.Raw.Misc` | present | `partial` | Normalize once `SDL.Misc` imports move down. |
| `SDL.Raw.Mutex` | present | `partial` | Existing raw family; public mutex wrappers still need final classification cleanup. |
| `SDL.Raw.Platform` | present | `complete` | Added and now owns all `SDL_GetPlatform` imports. |
| `SDL.Raw.Power` | present | `complete` | Added as a pure-support raw family and now owns all `SDL_GetPowerInfo` imports. |
| `SDL.Raw.Process` | present | `complete` | Existing raw family now also owns process-output cleanup, and `SDL.Processes` routes stream helpers through raw instead of importing them directly. |
| `SDL.Raw.Properties` | present | `partial` | Existing raw family; property-string and string-ABI policy should remain raw-only below wrappers. |
| `SDL.Raw.Storage` | present | `complete` | Existing raw family now also uses raw filesystem pointer helpers for glob results, and `SDL.Storage` no longer imports SDL symbols directly. |
| `SDL.Raw.System` | present | `partial` | Existing raw family; public systems facade still needs broader cleanup. |
| `SDL.Raw.Timer` | present | `complete` | Now pure-safe and owns all timer, delay, and performance-counter imports used by `SDL.Timers`. |
| `SDL.Raw.Thread` | present | `partial` | Existing raw family; thread wrapper remains handwritten. |
| `SDL.Raw.Time` | present | `partial` | Existing raw family; pair with timer/value cleanup. |
| `SDL.Raw.UTF_8` | present | `partial` | Treat as narrow support raw, not a second public string layer. |
| `SDL.Raw.Version` | present | `complete` | Added and now owns all version-query imports used by `SDL.Versions`. |

## Missing Raw Families To Add

These families are part of the target-state inventory and do not yet exist as
checked-in raw packages.

| Raw family | Primary public dependents | Status | Notes |
| --- | --- | --- | --- |
| `SDL.Raw.Audio` | `SDL.Audio`, `SDL.Audio.Devices`, `SDL.Audio.Streams`, `SDL.Audio.Sample_Formats` | `not started` | Large wrapper family; should land before more audio API expansion. |
| `SDL.Raw.Camera` | `SDL.Cameras`, `SDL.Events.Cameras` | `not started` | Needed for clean device and event layering. |
| `SDL.Raw.Dialog` | `SDL.Dialogs` | `not started` | Needed for callback and filter structs. |
| `SDL.Raw.Events` | `SDL.Events.*` | `not started` | Needed for event union and shared payload layout. |
| `SDL.Raw.Gamepad` | `SDL.Inputs.Joysticks.Game_Controllers`, `SDL.Events.Joysticks.Game_Controllers` | `not started` | Split cleanly from joystick wrapper policy. |
| `SDL.Raw.Haptic` | `SDL.Haptics` | `not started` | Device wrapper support. |
| `SDL.Raw.HIDAPI` | `SDL.HIDAPI` | `not started` | Device wrapper support. |
| `SDL.Raw.Joystick` | `SDL.Inputs.Joysticks`, `SDL.Events.Joysticks` | `not started` | Device and event support. |
| `SDL.Raw.Keyboard` | `SDL.Inputs.Keyboards`, `SDL.Events.Keyboards` | `not started` | Input/value support. |
| `SDL.Raw.MessageBox` | `SDL.Message_Boxes` | `not started` | Desktop UI support. |
| `SDL.Raw.Mouse` | `SDL.Inputs.Mice`, `SDL.Events.Mice`, `SDL.Inputs.Mice.Cursors` | `not started` | Needed for cursor and input support. |
| `SDL.Raw.Metal` | `SDL.Video.Metal` | `not started` | Can be narrow if Metal exposure remains small. |
| `SDL.Raw.Pen` | `SDL.Pens`, `SDL.Events.Pens` | `not started` | Value support family. |
| `SDL.Raw.Pixels` | `SDL.Video.Pixels`, `SDL.Video.Pixel_Formats`, `SDL.GPU` | `not started` | Shared value support family. |
| `SDL.Raw.Rect` | `SDL.Video.Rectangles`, `SDL.GPU`, render/video families | `not started` | Shared value support family. |
| `SDL.Raw.Render` | `SDL.Video.Renderers`, `SDL.Video.Textures`, `SDL.GPU` bridge points | `not started` | Large video/render family. |
| `SDL.Raw.Sensor` | `SDL.Sensors`, `SDL.Events.Sensors` | `not started` | Device wrapper support. |
| `SDL.Raw.Surface` | `SDL.Video.Surfaces`, palettes, cursor helpers | `not started` | Large video foundation family. |
| `SDL.Raw.Tray` | `SDL.Trays` | `not started` | Desktop UI support. |
| `SDL.Raw.Video` | `SDL.Video`, `SDL.Video.Displays`, `SDL.Video.Windows`, `SDL.Video.GL` | `not started` | Large video family. |
| `SDL.Raw.Vulkan` | `SDL.Video.Vulkan` | `not started` | Narrow family but required for full separation. |

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
| `SDL.Power` | public value layer | `complete` | Public package now routes entirely through pure `SDL.Raw.Power`. |
| `SDL.Processes` | public wrapper | `complete` | Public package now routes entirely through `SDL.Raw.Process` and `SDL.Raw.IOStream`. |
| `SDL.Storage` | public wrapper | `complete` | Public package now routes entirely through `SDL.Raw.Storage` and raw filesystem support helpers. |
| `SDL.Timers` | public value or thin wrapper layer | `complete` | Public package now routes entirely through pure `SDL.Raw.Timer`, keeping local callback types while backing public scalars with raw-compatible subtypes. |
| `SDL.Versions` | public value layer | `complete` | Public package now routes entirely through `SDL.Raw.Version`. |

### Events And Input

| Package | Target classification | Status | Notes |
| --- | --- | --- | --- |
| `SDL.Events.Events` | public value layer plus queue wrapper | `not started` | Needs `SDL.Raw.Events`. |
| `SDL.Events.Joysticks` | public value layer | `not started` | Needs `SDL.Raw.Events` and `SDL.Raw.Joystick`. |
| `SDL.Events.Joysticks.Game_Controllers` | public value layer | `not started` | Needs `SDL.Raw.Events` and `SDL.Raw.Gamepad`. |
| `SDL.Events.Keyboards` | public value layer | `not started` | Needs `SDL.Raw.Events` and `SDL.Raw.Keyboard`. |
| `SDL.Events.Touches` | public value layer | `not started` | Likely moves under `SDL.Raw.Events`. |
| `SDL.Inputs.Joysticks` | public wrapper | `not started` | Needs `SDL.Raw.Joystick`. |
| `SDL.Inputs.Joysticks.Game_Controllers` | public wrapper | `not started` | Needs `SDL.Raw.Gamepad`. |
| `SDL.Inputs.Joysticks.Game_Controllers.Makers` | public maker wrapper | `not started` | Should stop importing directly. |
| `SDL.Inputs.Joysticks.Makers` | public maker wrapper | `not started` | Should stop importing directly. |
| `SDL.Inputs.Keyboards` | public wrapper | `not started` | Needs `SDL.Raw.Keyboard`. |
| `SDL.Inputs.Mice` | public wrapper | `not started` | Needs `SDL.Raw.Mouse`. |
| `SDL.Inputs.Mice.Cursors` | public thick wrapper | `not started` | Needs `SDL.Raw.Mouse` and likely `SDL.Raw.Surface`. |
| `SDL.Pens` | public value layer | `not started` | Needs `SDL.Raw.Pen`. |
| `SDL.Sensors` | public wrapper | `not started` | Needs `SDL.Raw.Sensor`. |

### Audio, Devices, And Desktop

| Package | Target classification | Status | Notes |
| --- | --- | --- | --- |
| `SDL.Audio` | public wrapper | `not started` | Needs `SDL.Raw.Audio`. |
| `SDL.Audio.Devices` | public thick wrapper | `not started` | Needs `SDL.Raw.Audio`. |
| `SDL.Audio.Streams` | public thick wrapper | `not started` | Needs `SDL.Raw.Audio`. |
| `SDL.Cameras` | public thick wrapper | `not started` | Needs `SDL.Raw.Camera`. |
| `SDL.Dialogs` | public wrapper | `not started` | Needs `SDL.Raw.Dialog`. |
| `SDL.HIDAPI` | public thick wrapper | `not started` | Needs `SDL.Raw.HIDAPI`. |
| `SDL.Haptics` | public thick wrapper | `not started` | Needs `SDL.Raw.Haptic`. |
| `SDL.Message_Boxes` | public wrapper | `not started` | Needs `SDL.Raw.MessageBox`. |
| `SDL.Trays` | public thick wrapper | `not started` | Needs `SDL.Raw.Tray`. |

### Video And GPU

| Package | Target classification | Status | Notes |
| --- | --- | --- | --- |
| `SDL.Video` | public wrapper | `not started` | Needs `SDL.Raw.Video`. |
| `SDL.Video.Displays` | public wrapper | `not started` | Needs `SDL.Raw.Video`. |
| `SDL.Video.GL` | public wrapper | `not started` | Should route through `SDL.Raw.Video` plus support raw families. |
| `SDL.Video.Metal` | public thick wrapper | `not started` | Needs `SDL.Raw.Metal`. |
| `SDL.Video.Palettes` | public wrapper | `not started` | Needs raw surface or pixels support. |
| `SDL.Video.Pixel_Formats` | public value layer | `not started` | Needs `SDL.Raw.Pixels`. |
| `SDL.Video.Rectangles` | public value layer | `not started` | Needs `SDL.Raw.Rect`. |
| `SDL.Video.Renderers` | public thick wrapper | `not started` | Needs `SDL.Raw.Render`. |
| `SDL.Video.Renderers.Makers` | public maker wrapper | `not started` | Should stop importing directly. |
| `SDL.Video.Surfaces` | public thick wrapper | `not started` | Needs `SDL.Raw.Surface`. |
| `SDL.Video.Surfaces.Makers` | public maker wrapper | `not started` | Should stop importing directly. |
| `SDL.Video.Textures` | public thick wrapper | `not started` | Needs `SDL.Raw.Render`. |
| `SDL.Video.Textures.Makers` | public maker wrapper | `not started` | Should stop importing directly. |
| `SDL.Video.Vulkan` | public wrapper | `not started` | Needs `SDL.Raw.Vulkan`. |
| `SDL.Video.Windows` | public thick wrapper | `not started` | Needs `SDL.Raw.Video`. |
| `SDL.Video.Windows.Makers` | public maker wrapper | `not started` | Should stop importing directly. |
| `SDL.Video.Windows.Manager` | public wrapper/support layer | `not started` | Should depend on raw support, not direct imports. |

## Compatibility Freeze Queue

These packages should remain supported but should not gain new low-level import
or ABI responsibilities during conversion.

| Package | Status | Notes |
| --- | --- | --- |
| `SDL.C_Pointers` | `not started` | Freeze as compatibility/support only. |
| `SDL.Events.Controllers` | `not started` | Keep as migration alias layer over gamepad/event families. |
| `SDL.Inputs` | `not started` | Shared namespace only; do not grow new low-level behavior here. |
| `SDL.RWops` | `not started` | Keep as compatibility wrapper over `SDL.Raw.IOStream`. |
| `SDL.RWops.Streams` | `not started` | Compatibility bridge; avoid new raw responsibility here. |

## Tracking Discipline

When a conversion change lands:

- Update the relevant workstream status.
- Update the raw-family row if a new raw package was added or normalized.
- Update the package row for every public family touched.
- Record blockers explicitly instead of leaving ambiguous partial progress.
