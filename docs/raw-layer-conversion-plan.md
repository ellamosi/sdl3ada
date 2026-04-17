# Raw-Layer Conversion Plan

This document is the execution plan for adopting the target rules in
[raw-layer-target-state.md](raw-layer-target-state.md).

It assumes that deterministic generation of `SDL.Raw.*` is available and that
generator implementation effort is outside the scope of this plan. The work
tracked here is repository conversion work: package reshaping, import
relocation, wrapper cleanup, and review-policy enforcement.

## Objective

Adopt the generated-raw rule set without destabilizing the current public
`sdl3ada` surface.

Success means:

- `SDL.Raw.*` is the only layer that imports C or SDL symbols.
- Every SDL header family used by the public binding has a raw home.
- Public `SDL.*` packages are either handwritten value layers or handwritten
  thick wrappers.
- Raw packages do not depend on public wrapper packages.
- Compatibility packages stop accumulating new low-level behavior.

## Conversion Constraints

- Preserve current public package names unless a separate compatibility decision
  explicitly changes them.
- Prefer staged family-by-family changes over cross-repository rewrites.
- Do not combine raw normalization with unrelated behavior changes in the same
  change set unless that is necessary to keep the build working.
- Keep the tracked SDL release and callable coverage workflow unchanged while
  conversion is in progress.
- Update the tracking file in the same change as each conversion step.

## Working Rules During Conversion

- New low-level imports go into raw first, even if the surrounding family has
  not been fully converted yet.
- When a public package still imports C or SDL directly, treat it as temporary
  technical debt and record it in the tracking file.
- If a package mainly exposes enums, records, IDs, or helper predicates, move
  it toward the public value layer instead of turning it into a wrapper.
- If a package owns handles, marshals strings or arrays, translates errors, or
  manages callbacks, keep it handwritten and route it through raw.
- Use one of two acceptable change shapes:
  - Add a raw family, then migrate its immediate public dependents.
  - Normalize an existing raw family, then remove direct imports from the
    public family above it.

## Phase Plan

### Phase 0: Guardrails And Baseline

Goal:

- Freeze the target architecture and establish the conversion tracker.

Deliverables:

- Target-state document accepted as the architectural rule set.
- Plan and tracking files checked in.
- Reviewer policy established: no new direct imports outside `SDL.Raw.*`.

Exit criteria:

- The repo has explicit plan and tracking documents.
- Future work can reference the same phase and workstream language.

### Phase 1: Core Raw Support Families

Goal:

- Add or normalize the low-risk raw support families that unblock large parts of
  the public surface.

Primary scope:

- Normalize existing raw families used by core runtime packages.
- Add raw families for `Error`, `Log`, `Hints`, `Platform`, `CPUInfo`,
  `Power`, `Version`, `Timer`, `Rect`, and `Pixels`.

Expected public packages affected:

- `SDL`
- `SDL.Error`
- `SDL.Log`
- `SDL.Hints`
- `SDL.Platform`
- `SDL.CPUS`
- `SDL.Power`
- `SDL.Versions`
- `SDL.Timers`
- `SDL.Video.Rectangles`
- `SDL.Video.Pixels`
- `SDL.Video.Pixel_Formats`

Exit criteria:

- These public families no longer import C or SDL directly.
- The raw support types they need are available without depending on public
  wrapper packages.

### Phase 2: Public Value Package Migration

Goal:

- Convert public value-heavy packages to pure handwritten facades over raw.

Primary scope:

- Event payload and constant packages.
- Value packages that currently sit halfway between raw and wrapper.
- Compatibility-value packages that should keep their public names but stop
  acting as ad hoc thin bindings.

Expected public packages affected:

- `SDL.Events`
- `SDL.Events.Events`
- `SDL.Events.Windows`
- `SDL.Events.Mice`
- `SDL.Events.Touches`
- `SDL.Events.Joysticks`
- `SDL.Events.Joysticks.Game_Controllers`
- `SDL.Events.Cameras`
- `SDL.Events.Keyboards`
- `SDL.Events.Pens`
- `SDL.Events.Sensors`
- `SDL.Events.Files`
- `SDL.Pens`
- `SDL.Audio.Sample_Formats`

Exit criteria:

- Public value packages use raw layouts and constants but contain no direct
  imports.
- Value packages are clearly distinguishable from thick wrappers in review.

### Phase 3: Wrapper-Family Raw Backfills

Goal:

- Add the missing raw families needed by wrapper-heavy subsystems before trying
  to normalize the wrappers themselves.

Primary scope:

- Audio
- Input and device families
- Desktop UI families
- Remaining core utility families that still lack a raw home

Expected raw families to add:

- `SDL.Raw.Audio`
- `SDL.Raw.Camera`
- `SDL.Raw.Dialog`
- `SDL.Raw.Events`
- `SDL.Raw.Gamepad`
- `SDL.Raw.Haptic`
- `SDL.Raw.HIDAPI`
- `SDL.Raw.Keyboard`
- `SDL.Raw.LoadSO`
- `SDL.Raw.MessageBox`
- `SDL.Raw.Mouse`
- `SDL.Raw.Sensor`
- `SDL.Raw.Tray`

Expected public packages affected:

- `SDL.Audio`
- `SDL.Audio.Devices`
- `SDL.Audio.Streams`
- `SDL.Cameras`
- `SDL.Dialogs`
- `SDL.HIDAPI`
- `SDL.Haptics`
- `SDL.Inputs.Keyboards`
- `SDL.Inputs.Mice`
- `SDL.Inputs.Mice.Cursors`
- `SDL.Inputs.Joysticks`
- `SDL.Inputs.Joysticks.Makers`
- `SDL.Inputs.Joysticks.Game_Controllers`
- `SDL.Inputs.Joysticks.Game_Controllers.Makers`
- `SDL.Message_Boxes`
- `SDL.Sensors`
- `SDL.Trays`
- `SDL.Libraries`

Exit criteria:

- Wrapper-heavy subsystems have raw homes for all ABI-level types and imports
  they need.
- Public wrappers above them can be converted without inventing new low-level
  imports.

### Phase 4: Video, Render, And GPU Normalization

Goal:

- Convert the largest mixed layer in the repository into a clean raw-plus-wrapper
  structure.

Primary scope:

- Add raw homes for video, render, surface, Vulkan, and Metal-facing SDL
  families.
- Remove public-type leakage from `SDL.Raw.GPU`.
- Push all video/render imports down into raw.

Expected raw families to add or normalize:

- `SDL.Raw.Video`
- `SDL.Raw.Render`
- `SDL.Raw.Surface`
- `SDL.Raw.Vulkan`
- `SDL.Raw.Metal`
- normalized `SDL.Raw.GPU`

Expected public packages affected:

- `SDL.Video`
- `SDL.Video.Displays`
- `SDL.Video.Windows`
- `SDL.Video.Windows.Manager`
- `SDL.Video.Windows.Makers`
- `SDL.Video.Surfaces`
- `SDL.Video.Surfaces.Makers`
- `SDL.Video.Textures`
- `SDL.Video.Textures.Makers`
- `SDL.Video.Renderers`
- `SDL.Video.Renderers.Makers`
- `SDL.Video.GL`
- `SDL.Video.Metal`
- `SDL.Video.Vulkan`
- `SDL.GPU`

Exit criteria:

- Video, render, and GPU public packages contain no direct imports.
- `SDL.Raw.GPU` depends only on raw or support packages.
- Rectangle and pixel-format ABI types used by GPU come from raw support
  families, not public wrappers.

### Phase 5: Closure And Enforcement

Goal:

- Turn the architecture into a maintained rule instead of a one-time cleanup.

Primary scope:

- Add or strengthen a repository check for non-raw imports.
- Update maintainer docs to describe generated raw ownership clearly.
- Freeze compatibility-only packages and stop routing new low-level behavior
  through them.

Expected packages and docs affected:

- `docs/development.md`
- `docs/raw-layer-conventions.md`
- `docs/raw-layer-target-state.md`
- coverage or lint tooling under `tools/`
- compatibility packages such as `SDL.C_Pointers`, `SDL.Events.Controllers`,
  `SDL.Inputs`, and `SDL.RWops`

Exit criteria:

- The repository can detect regressions toward new non-raw imports.
- The tracking file has no remaining open workstreams for the target state.

## Recommended Unit Of Work

Each change should usually do one of the following:

- Add one raw family and migrate the nearest public value packages.
- Add one raw family and migrate one wrapper family.
- Normalize one existing raw family and remove all direct imports above it.
- Add one enforcement or documentation improvement without touching runtime
  behavior.

Avoid changes that span multiple unrelated subsystems unless the shared goal is
specifically to add common raw support such as `SDL.Raw.Rect` or
`SDL.Raw.Pixels`.

## Review Checklist

Use this checklist on every conversion change:

- Does this change reduce the count of non-raw imports?
- If a new raw family was needed, was it added before wrapper work?
- Did any raw package start depending on a public package?
- Did a public value package stay value-only, or did it accidentally become a
  wrapper?
- Did a wrapper keep ownership and callback policy above raw?
- Was the tracking file updated in the same change?
