# Generated Raw-Layer Target State

This document states the target package shape for `sdl3ada` if
`SDL.Raw.*` is deterministically generated from the tracked SDL headers and
the cost of maintaining the generator itself is treated as out of scope.

The current conventions in [raw-layer-conventions.md](raw-layer-conventions.md)
still apply. This document adds the stronger end-state rules and maps the
current tree onto that target.

## Layer Model

The current "thin vs thick" split should become a three-strata model:

1. Generated raw ABI mirror
   `SDL.Raw.*` packages are generated, header-shaped, and mechanically exact.
2. Public value layer
   Public `SDL.*` packages that mainly expose enums, records, pure helpers, and
   compatibility names stay handwritten but stop importing SDL directly.
3. Public thick wrapper layer
   Public `SDL.*` packages that own handles, marshal strings or arrays, manage
   callbacks, or translate errors stay handwritten and call only into raw.

There is also a small internal/support category for handwritten glue that
should not grow into a second raw layer.

## Hard Rules

- Only `SDL.Raw.*` may contain `Import => True`, `pragma Import`, or
  `External_Name` for SDL symbols.
- Generated raw packages are not edited by hand. Handwritten fixes belong in
  the generator or in handwritten wrapper code above raw.
- Every tracked SDL header family that feeds the public binding gets a raw home.
  If the family should not surface publicly, it still gets a generated raw
  support package rather than leaking imports into public code.
- Raw packages may depend only on other raw/support packages, never on public
  thick packages such as `SDL.Video.Rectangles` or `SDL.Video.Pixel_Formats`.
- Public value packages may subtype, rename, or wrap raw types, but they do not
  import SDL directly and they do not own resources.
- Public thick wrappers own all policy: string conversion, temporary buffers,
  exceptions, controlled finalization, borrowed-versus-owned tracking, and
  callback trampolines.
- `Makers` packages remain public wrappers only. They do not become raw and they
  do not import SDL directly.
- `SDL.C_Pointers` is frozen as a compatibility/support package. New code should
  prefer generated opaque types in the appropriate raw family.

## Subsystem Map

### Core And Runtime

| Current packages | Target role | Raw family status | Notes |
| --- | --- | --- | --- |
| `SDL` | public wrapper | keep `SDL.Raw.Init`; remove direct imports from `SDL` | Top-level init/quit and metadata helpers stay public, but all actual imports route through raw. |
| `SDL.Main`, `SDL.Main.Callback_Apps`, `SDL.Main.SDLMain_Callback_Apps` | public wrapper plus internal glue | keep `SDL.Raw.Main`; add support raw coverage for any remaining init/main callbacks | Public entry helpers stay handwritten because they own Ada entry conventions and callback policy. |
| `SDL.Main.Internal_Callback_Bindings` | internal handwritten glue | uses raw only | Internal trampoline package, not part of generated raw. |
| `SDL.Error` | public value facade | add `SDL.Raw.Error` | Thin public facade is fine, but the direct imports move down. |
| `SDL.Log` | public wrapper | add `SDL.Raw.Log` | Keep callback handling and convenience names handwritten. |
| `SDL.Assertions` | public wrapper | keep `SDL.Raw.Assert` | Good fit for handwritten wrapper over generated raw. |
| `SDL.Atomics` | public wrapper | keep `SDL.Raw.Atomic` | Keep the handwritten atomic object API and memory-barrier wrappers. |
| `SDL.Hints` | public wrapper | add `SDL.Raw.Hints` | Callback watch plumbing stays handwritten. |
| `SDL.Platform`, `SDL.CPUS`, `SDL.Power`, `SDL.Versions`, `SDL.Locale`, `SDL.Misc`, `SDL.Libraries` | public value or thin wrapper layer | keep or add `SDL.Raw.Platform`, `SDL.Raw.CPUInfo`, `SDL.Raw.Power`, `SDL.Raw.Version`, `SDL.Raw.Locale`, `SDL.Raw.Misc`, `SDL.Raw.LoadSO` | `SDL.Raw.Platform`, `SDL.Raw.CPUInfo`, `SDL.Raw.Power`, `SDL.Raw.Version`, and `SDL.Raw.LoadSO` now exist. |
| `SDL.Filesystems`, `SDL.Properties`, `SDL.Processes`, `SDL.Storage`, `SDL.Systems`, `SDL.Threads`, `SDL.Time`, `SDL.Timers` | public wrappers | keep or add raw families and normalize them | Existing raw families are the right shape conceptually, but handwritten public layers should own all buffer, string, and lifetime policy. `SDL.Timers` can remain a pure wrapper while routing timer and delay entry points through `SDL.Raw.Timer`. |
| `SDL.C_Pointers` | compatibility/support only | no new raw dependency on it | Existing public package can remain for compatibility, but generated raw families should declare their own opaque types or use a dedicated raw support package. |
| `SDL.UTF_8` | public support layer | add `SDL.Raw.UTF_8` only for ABI-level helpers | Ada string encoding policy stays above raw. |

### Audio

| Current packages | Target role | Raw family status | Notes |
| --- | --- | --- | --- |
| `SDL.Audio.Sample_Formats` | public value layer | generated `SDL.Raw.Audio` provides ABI enums and predicates | Keep public naming and compatibility aliases handwritten. |
| `SDL.Audio` | public wrapper | add `SDL.Raw.Audio` | This is a high-value wrapper and should stay handwritten. |
| `SDL.Audio.Devices` | thick wrapper | add `SDL.Raw.Audio` | Ownership, stream binding, and error policy remain handwritten. |
| `SDL.Audio.Streams` | thick wrapper | add `SDL.Raw.Audio` | Queueing and callback-lifetime policy stay above raw. |

### Events, Input, And Devices

| Current packages | Target role | Raw family status | Notes |
| --- | --- | --- | --- |
| `SDL.Events`, `SDL.Events.Events` | public value layer plus queue wrapper | add `SDL.Raw.Events` | Event union layout and queue APIs belong in generated raw; public packages keep compatibility helpers and higher-level queue operations. |
| `SDL.Events.Windows`, `SDL.Events.Mice`, `SDL.Events.Touches`, `SDL.Events.Joysticks`, `SDL.Events.Joysticks.Game_Controllers`, `SDL.Events.Cameras`, `SDL.Events.Keyboards`, `SDL.Events.Pens`, `SDL.Events.Sensors`, `SDL.Events.Files` | public value layer | use `SDL.Raw.Events` plus support raw families for cross-header value types | These packages should expose event payload types and constants, but imports move to raw. |
| `SDL.Events.Controllers` | compatibility shim | no direct imports | This remains a handwritten migration package over public gamepad/event units. |
| `SDL.Inputs` | compatibility/value layer | no direct imports | Shared input namespace only. |
| `SDL.Inputs.Keyboards`, `SDL.Inputs.Mice`, `SDL.Inputs.Joysticks`, `SDL.Inputs.Joysticks.Game_Controllers` | public wrappers | add `SDL.Raw.Keyboard`, `SDL.Raw.Mouse`, `SDL.Raw.Joystick`, `SDL.Raw.Gamepad` | Device queries, string conversion, arrays, and borrowed handles stay handwritten. |
| `SDL.Inputs.Mice.Cursors` | thick wrapper | add or reuse `SDL.Raw.Mouse` and `SDL.Raw.Surface` | Cursor construction and ownership stay handwritten. |
| `SDL.Inputs.Joysticks.Makers`, `SDL.Inputs.Joysticks.Game_Controllers.Makers` | public makers | no direct imports | Open/close helpers remain wrappers only. |
| `SDL.Pens` | public value or thin wrapper layer | add `SDL.Raw.Pen` | Pen IDs, flags, and enums should come from generated raw support. |
| `SDL.Sensors`, `SDL.Haptics`, `SDL.Cameras`, `SDL.HIDAPI` | thick wrappers | add `SDL.Raw.Sensor`, `SDL.Raw.Haptic`, `SDL.Raw.Camera`, `SDL.Raw.HIDAPI` | Ownership, copying, and runtime checks stay handwritten. |

### Video, Render, And GPU

| Current packages | Target role | Raw family status | Notes |
| --- | --- | --- | --- |
| `SDL.Video` | public wrapper | add `SDL.Raw.Video` | Subsystem control and convenience helpers stay public. |
| `SDL.Video.Displays` | public wrapper | add `SDL.Raw.Video` | Display IDs and mode enumeration stay public, with string and array policy above raw. |
| `SDL.Video.Rectangles`, `SDL.Video.Pixels`, `SDL.Video.Pixel_Formats` | public value layer | add `SDL.Raw.Rect`, `SDL.Raw.Pixels`; pixel-format ABI types should come from generated raw support | These are prime examples of public value packages that should stop importing SDL directly. |
| `SDL.Video.Palettes` | thin wrapper | add `SDL.Raw.Pixels` or `SDL.Raw.Surface` support as needed | Ownership and palette mutation stay handwritten. |
| `SDL.Video.Windows`, `SDL.Video.Windows.Manager`, `SDL.Video.Windows.Makers` | thick wrapper plus maker/manager support | add `SDL.Raw.Video`, generated support for system window manager structs if needed | All window ownership and platform-handle policy stay handwritten. |
| `SDL.Video.Surfaces`, `SDL.Video.Surfaces.Makers` | thick wrapper plus makers | add `SDL.Raw.Surface` | Surface ownership, pixel access policy, and conversion helpers stay handwritten. |
| `SDL.Video.Textures`, `SDL.Video.Textures.Makers` | thick wrapper plus makers | add `SDL.Raw.Render` | Texture ownership and update helpers stay handwritten. |
| `SDL.Video.Renderers`, `SDL.Video.Renderers.Makers` | thick wrapper plus makers | add `SDL.Raw.Render` | Renderer state, readback, and bridge logic stay handwritten. |
| `SDL.Video.GL` | public wrapper | primarily `SDL.Raw.Video`; support raw packages for any SDL-defined GL-facing value types | All direct imports in the wrapper move to raw, but OpenGL ecosystem headers remain support data, not public wrapper families. |
| `SDL.Video.Metal` | thick wrapper | add `SDL.Raw.Metal` | Metal view lifetime remains public wrapper policy. |
| `SDL.Video.Vulkan` | wrapper | add `SDL.Raw.Vulkan` | Loader and surface lifecycle policy stay handwritten. |
| `SDL.GPU` | thick wrapper over a large generated family | normalize `SDL.Raw.GPU`; add `SDL.Raw.Rect` and `SDL.Raw.Pixels` support to remove public-type leakage | `SDL.GPU` should remain a public foundation package, but `SDL.Raw.GPU` must become a strict generated mirror. |

### IO, Desktop, And Miscellaneous SDL3-Native Packages

| Current packages | Target role | Raw family status | Notes |
| --- | --- | --- | --- |
| `SDL.RWops`, `SDL.RWops.Streams` | compatibility wrapper | keep `SDL.Raw.IOStream` | Public RWops compatibility stays handwritten; raw stays `SDL_IOStream`-shaped. |
| `SDL.Dialogs` | public wrapper | add `SDL.Raw.Dialog` | Callback lifetime and file-filter ergonomics stay handwritten. |
| `SDL.Message_Boxes` | public wrapper | add `SDL.Raw.MessageBox` | UI struct assembly stays handwritten. |
| `SDL.Trays` | thick wrapper | add `SDL.Raw.Tray` | Menu-tree ownership and callbacks stay handwritten. |

## Raw Families To Add Or Normalize

The current raw namespace is only a partial header mirror. Under the generated
target state, the following families should exist or be normalized before more
public wrapper work is added:

- Normalize existing raw families: `SDL.Raw.AsyncIO`, `SDL.Raw.CPUInfo`,
  `SDL.Raw.Error`, `SDL.Raw.Filesystem`, `SDL.Raw.GPU`, `SDL.Raw.Hints`,
  `SDL.Raw.Init`, `SDL.Raw.IOStream`, `SDL.Raw.LoadSO`, `SDL.Raw.Log`,
  `SDL.Raw.Main`, `SDL.Raw.Mutex`, `SDL.Raw.Platform`, `SDL.Raw.Power`,
  `SDL.Raw.Process`, `SDL.Raw.Properties`, `SDL.Raw.Storage`,
  `SDL.Raw.System`, `SDL.Raw.Thread`, `SDL.Raw.Time`, `SDL.Raw.Timer`,
  `SDL.Raw.Version`.
- Add missing raw families that already have public wrappers above them:
  `SDL.Raw.Audio`, `SDL.Raw.Camera`, `SDL.Raw.Clipboard`, `SDL.Raw.Dialog`,
  `SDL.Raw.Events`, `SDL.Raw.Gamepad`,
  `SDL.Raw.Haptic`, `SDL.Raw.HIDAPI`, `SDL.Raw.Joystick`, `SDL.Raw.Keyboard`,
  `SDL.Raw.MessageBox`, `SDL.Raw.Mouse`, `SDL.Raw.Pen`, `SDL.Raw.Pixels`,
  `SDL.Raw.Rect`, `SDL.Raw.Render`, `SDL.Raw.Sensor`, `SDL.Raw.Surface`,
  `SDL.Raw.Tray`, `SDL.Raw.Video`, `SDL.Raw.Vulkan`.
- Keep support-header policy from `raw-layer-conventions.md` for
  `SDL_stdinc.h`, `SDL_bits.h`, `SDL_endian.h`, and `SDL_intrin.h`.

## Current Migration Queue

The current tree still has direct SDL imports outside `SDL.Raw.*`. That is the
main structural difference between the current codebase and the generated target
state.

Priority order:

1. Move all core and utility imports down into raw.
   Affected families: `SDL`, `SDL.Error`, `SDL.Log`, `SDL.Hints`,
   `SDL.Platform`, `SDL.CPUS`, `SDL.Power`, `SDL.Versions`,
   `SDL.Libraries`, `SDL.Timers`.
2. Move all value-type and event-layout imports down into raw.
   Affected families: `SDL.Events.Events`, `SDL.Events.Keyboards`,
   `SDL.Events.Touches`, `SDL.Events.Joysticks`,
   `SDL.Events.Joysticks.Game_Controllers`, `SDL.Pens`,
   `SDL.Video.Rectangles`, `SDL.Video.Pixel_Formats`,
   `SDL.Audio.Sample_Formats`, and similar pure-value packages.
3. Fill in missing raw families for wrapper-heavy subsystems before changing
   the wrappers themselves.
   Affected families: audio, video/render, GPU, input, haptics, cameras,
   HIDAPI, dialogs, message boxes, trays.
4. Normalize the public wrappers so they no longer act as ad hoc thin bindings.
   Affected families: `SDL.Audio`, `SDL.Video.*`, `SDL.GPU`,
   `SDL.Inputs.*`, `SDL.RWops`, `SDL.Systems`, `SDL.Threads`,
   `SDL.Storage`, `SDL.Processes`.
5. Freeze compatibility-only packages and stop adding new low-level behavior to
   them.
   Affected packages: `SDL.C_Pointers`, `SDL.Events.Controllers`,
   `SDL.Inputs`, `SDL.RWops`.

## Practical Review Standard

For any new subsystem work, the review questions should be:

- Does a generated raw family already exist for every SDL header used here?
- If not, why is this code importing SDL directly instead of extending raw?
- Is this package exposing value types, or is it actually owning resources?
- If it owns resources or marshals data, why is it not a handwritten wrapper?
- If it only mirrors SDL layout and names, why is it not generated?

If those questions are answered consistently, the repository will stop drifting
between raw, public-value, and wrapper concerns.
