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
- `SDL.Raw.AsyncIO`
- `SDL.Raw.Atomic`
- `SDL.Raw.CPUInfo`
- `SDL.Raw.Error`
- `SDL.Raw.Filesystem`
- `SDL.Raw.Init`
- `SDL.Raw.IOStream`
- `SDL.Raw.Locale`
- `SDL.Raw.LoadSO`
- `SDL.Raw.Log`
- `SDL.Raw.Main`
- `SDL.Raw.Misc`
- `SDL.Raw.Mutex`
- `SDL.Raw.Platform`
- `SDL.Raw.Power`
- `SDL.Raw.Process`
- `SDL.Raw.Properties`
- `SDL.Raw.Storage`
- `SDL.Raw.System`
- `SDL.Raw.Timer`
- `SDL.Raw.Thread`
- `SDL.Raw.Time`
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

## Error Handling

- Raw imports return SDL success/failure results directly.
- Wrapper packages translate failure into existing package-specific exceptions
  with `SDL.Error.Get` so diagnostics remain consistent with the current code
  base.

## Coverage Inventory

- Callable SDL API coverage is audited from the tracked SDL include tree with
  `docs/coverage/update.sh`, which regenerates `docs/coverage/report.md` and
  `docs/coverage/report.json`.
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
