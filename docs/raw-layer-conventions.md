# SDL3Ada Raw-Layer Conventions

This document captures the conventions for the auditable low-level binding
layer that supports the tracked SDL callable API audit described in
`tracked-sdl.json`.

## Namespace

- Low-level imports live under `SDL.Raw.*`.
- High-level and migration-oriented public wrappers stay under `SDL.*`.
- `SDL.Raw.*` packages are intentionally thin and keep close 1:1 naming with
  the underlying SDL family so the coverage matrix can be audited against the
  C headers.

Current raw packages include:

- `SDL.Raw.Assert`
- `SDL.Raw.Audio`
- `SDL.Raw.AsyncIO`
- `SDL.Raw.Atomic`
- `SDL.Raw.Camera`
- `SDL.Raw.C_Pointers`
- `SDL.Raw.CPUInfo`
- `SDL.Raw.Dialog`
- `SDL.Raw.Error`
- `SDL.Raw.Filesystem`
- `SDL.Raw.Gamepad`
- `SDL.Raw.Gamepad_Events`
- `SDL.Raw.Haptic`
- `SDL.Raw.HIDAPI`
- `SDL.Raw.Hints`
- `SDL.Raw.Init`
- `SDL.Raw.IOStream`
- `SDL.Raw.Joystick`
- `SDL.Raw.Joystick_Events`
- `SDL.Raw.Locale`
- `SDL.Raw.LoadSO`
- `SDL.Raw.Log`
- `SDL.Raw.Main`
- `SDL.Raw.MessageBox`
- `SDL.Raw.Misc`
- `SDL.Raw.Mutex`
- `SDL.Raw.Pen`
- `SDL.Raw.Platform`
- `SDL.Raw.Power`
- `SDL.Raw.Process`
- `SDL.Raw.Properties`
- `SDL.Raw.Render`
- `SDL.Raw.Sensor`
- `SDL.Raw.Storage`
- `SDL.Raw.System`
- `SDL.Raw.Timer`
- `SDL.Raw.Thread`
- `SDL.Raw.Time`
- `SDL.Raw.Tray`
- `SDL.Raw.Video`
- `SDL.Raw.Version`

## Naming

- Package names follow the source header family, for example
  `SDL_properties.h` maps to `SDL.Raw.Properties`.
- Imported subprograms use Ada `Camel_Case` names while keeping the SDL family
  shape obvious, for example `Create_Properties` for `SDL_CreateProperties`.
- Public thick wrappers may keep established `sdlada` naming when that avoids
  churn, but new raw imports should not fabricate SDL2-only semantics.

## C Strings And UTF-8

- Raw imports accept C-compatible string parameters and return SDL-owned string
  pointers where SDL defines them.
- Wrapper packages convert Ada `String` values to UTF-8 C strings at the call
  boundary and copy SDL-owned returned strings into Ada `String` values before
  control returns to the caller.
- The raw layer does not promise Ada-managed ownership for SDL-owned string
  pointers. Higher-level wrappers should copy them unless lifetime is
  explicitly documented and intentionally exposed.

## Arrays And Buffers

- Raw packages expose SDL-sized integers, addresses, and pointer types rather
  than synthesizing Ada containers.
- Higher-level wrappers are responsible for range checks, length validation,
  and copying between Ada arrays and SDL buffers.
- When SDL requires a contiguous temporary array, the wrapper should allocate a
  short-lived Ada object whose address is passed through the raw layer.

## Callbacks

- Raw callback signatures use C-convention access-to-subprogram types and a
  `System.Address` user-data slot when SDL provides one.
- Ada closures or nested-callback convenience APIs belong in the thick wrapper
  layer, not in `SDL.Raw.*`.
- When cleanup or enumeration callbacks may outlive the immediate call, the
  wrapper layer owns the lifetime contract and any trampoline storage.

## Ownership

- Raw handles remain plain SDL IDs, pointers, or addresses. They do not add
  ownership semantics.
- High-level wrappers own destruction policy. If SDL returns borrowed handles
  or property sets tied to another object, the wrapper must mark them as
  borrowed and avoid destroying them.
- Packages that create owned SDL resources should prefer Ada controlled types
  when that keeps destruction reliable without hiding SDL behavior.

## Generated Raw Ownership

- Generated `SDL.Raw.*` units own the auditable ABI surface: direct C imports,
  SDL symbol names, C-layout enums and records, callback signatures, and
  low-level pointer helpers required to mirror SDL arrays and buffers.
- Handwritten public wrappers own Ada-facing policy: exceptions, ownership,
  callbacks that need registries or trampolines, string and array conversion,
  and compatibility naming carried forward for `sdlada` callers.
- Review new low-level work against the generated-raw target first. If a
  public or compatibility unit needs a new SDL symbol, add it to the relevant
  raw family before touching the wrapper above it.

## Error Handling

- Raw imports return SDL success/failure results directly.
- Wrapper packages translate failure into existing package-specific exceptions
  with `SDL.Error.Get` so diagnostics remain consistent with the current code
  base.

## Compatibility Freeze

- `SDL.C_Pointers`, `SDL.Events.Controllers`, `SDL.Inputs`, `SDL.RWops`, and
  `SDL.RWops.Streams` are compatibility or support namespaces, not raw homes.
- `SDL.C_Pointers` remains public only as a compatibility facade over raw
  support types; new low-level handle definitions belong in `SDL.Raw.*`,
  currently via `SDL.Raw.C_Pointers`.
- These packages may wrap, rename, or bridge raw-backed behavior for caller
  compatibility, but they should not accumulate new `Import`, `External_Name`,
  or ABI-layout responsibilities during conversion.
- When conversion work touches one of these packages, treat new low-level
  requirements as a signal to extend the raw family below it instead.

## Coverage Inventory

- Callable SDL API coverage is audited from the tracked SDL include tree with
  `docs/coverage/update.sh`, which regenerates `docs/coverage/report.md` and
  `docs/coverage/report.json`.
- `python3 tools/check_non_raw_imports.py` enforces the checked-in baseline of
  remaining non-raw direct imports so conversion work can reduce the footprint
  without allowing it to silently expand again.
- `docs/coverage/policy.json` carries the checked-in exclusion rules for
  callable SDL
  APIs that are intentionally out of scope for the Ada binding audit.
- New raw packages should be added before or alongside broad subsystem work so
  widening remains auditable instead of hiding imports in unrelated bodies.

## Special-Review Header Classification

- `SDL_stdinc` remains a support-header classification, not a broad public
  `SDL.Stdinc` package.
- Scalar compatibility aliases such as `SDL_Time` and helper calls such as
  `SDL_free` may be consumed internally where the public SDL families require
  them, but they should not become a grab-bag public surface without a
  concrete caller need.
- `SDL_bits` and `SDL_endian` remain support headers; selective use for future
  public APIs is acceptable, but they are not promoted into first-class Ada
  package families.
- Macro-only compiler intrinsics from `SDL_atomic.h`, such as compiler
  barriers and CPU pause instructions, remain support-layer details. The
  callable atomic, barrier, and spinlock entry points are represented through
  `SDL.Raw.Atomic` and `SDL.Atomics`.
