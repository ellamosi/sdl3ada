# SDL3Ada Development

This document is for maintainers and contributors. For the project overview,
build quick start, and links to validation material, start with the
[root README](../README.md).

## Tracked SDL Inputs

`tracked-sdl.json` is the single source of truth for the tracked SDL release,
repo-local source checkout, and repo-local runtime cache metadata used by this
repository.

- `.deps/SDL/` holds the tracked SDL source checkout used for audit and header
  inventory work.
- `tracked_sdl_paths.gpr` is generated from `tracked-sdl.json` and carries the
  shared project-file path defaults.
- `.deps/SDL-runtime/macos/` holds the normalized macOS runtime cache used by
  the current local validation flow.

## Build And Runtime Layout

The project files are wired to the repo-local tracked SDL paths.

On macOS, the current baseline uses the normalized runtime cache under `.deps/SDL-runtime/macos/`, while local Alire resolution still handles the Ada-side dependency setup.

## Updating Tracked SDL

From the repository root:

```sh
python3 tools/update_tracked_sdl_gpr.py
python3 tools/ensure_tracked_sdl_runtime.py --download
python3 tools/update_tracked_sdl_asset_sha256.py
```

Use these when the tracked SDL version, local source layout, or cached macOS
runtime asset changes. The exact tracked version and asset metadata belong in
`tracked-sdl.json`.

## Coverage And Validation Workflow

From the repository root:

```sh
docs/coverage/update.sh --ensure-source
docs/coverage/update.sh --ensure-source --fail-on-missing
tools/run_release_baseline.sh
```

- `docs/coverage/update.sh --ensure-source` refreshes the repo-local SDL
  source checkout if needed and regenerates the callable API coverage report.
- `--fail-on-missing` turns remaining uncovered tracked symbols into a failing
  exit status.
- `tools/run_release_baseline.sh` is the repository-wide build and smoke
  baseline.

The checked-in generated audit lives in
[`docs/coverage/report.md`](coverage/report.md) and
[`docs/coverage/report.json`](coverage/report.json). The maintained reference
docs are the parity matrix and validation matrix under `docs/coverage/`.

## Specialist References

- [docs/main-entry-patterns.md](main-entry-patterns.md)
- [docs/raw-layer-conventions.md](raw-layer-conventions.md)
- [docs/coverage/README.md](coverage/README.md)
