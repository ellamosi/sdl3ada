# SDL3Ada Coverage Tracking

Coverage tracking is now split into three maintained artifacts:

1. `docs/coverage/report.md` and `docs/coverage/report.json`: generated callable SDL API audit
2. `parity-matrix.md`: maintained public Ada unit surface
3. `validation-matrix.md`: maintained build, smoke, and manual validation map

That split keeps the generated SDL symbol audit separate from the two
repository-maintained documents that still need editorial judgment.

## Canonical Inputs

- `tracked-sdl.json` is the single source of truth for the tracked SDL release,
  repo-local source checkout, and repo-local macOS runtime cache.
- `docs/coverage/policy.json` carries the explicit exclusion rules for callable
  SDL APIs
  that are intentionally out of scope for the Ada binding audit.
- `src/**/*.ads` and `src/**/*.adb` are the Ada sources scanned by the
  callable API audit.

## Coverage Views

- `docs/coverage/report.md` is the human-readable callable API audit. It summarizes
  tracked, covered, missing, and excluded SDL callable symbols and breaks the
  results down by header.
- `docs/coverage/report.json` is the machine-readable form of that same audit.
- `parity-matrix.md` remains the public-unit compatibility view across the
  user-facing Ada package surface.
- `validation-matrix.md` remains the runtime validation view for build
  commands, smoke targets, and manual backend or hardware-sensitive checks.
- `callable-api-audit.md` keeps the focused workflow and scope notes for the
  generated callable API audit.

## Commands

From the repository root:

```sh
docs/coverage/update.sh --ensure-source
docs/coverage/update.sh --ensure-source --fail-on-missing
tools/run_release_baseline.sh
```

- `docs/coverage/update.sh --ensure-source` refreshes the repo-local SDL source
  checkout if needed and regenerates `docs/coverage/report.md` plus
  `docs/coverage/report.json`.
- `docs/coverage/update.sh --ensure-source --fail-on-missing` does the same work but
  exits non-zero if tracked callable SDL APIs are still uncovered.
- `tools/run_release_baseline.sh` runs the automated build/smoke baseline and
  refreshes the callable API audit as part of that pass.

## Typical Workflow

1. Update the tracked SDL ref in `tracked-sdl.json` or update Ada binding code.
2. Run `docs/coverage/update.sh --ensure-source`.
3. Review `docs/coverage/report.md` for newly missing symbols, coverage gains, or policy
   mismatches.
4. Update raw imports or wrappers as needed. If a callable SDL API should stay
   out of scope, update `docs/coverage/policy.json`.
5. Update `parity-matrix.md` if the public Ada package surface changed.
6. Update `validation-matrix.md` if build commands, smoke targets, or manual
   validation notes changed.
7. Run `tools/run_release_baseline.sh` before commit when the change affects
   build or runtime coverage.

## Scope And Limits

- The generated audit measures callable SDL API coverage. It does not attempt
  to model every macro, enum value, typedef spelling, or vendor passthrough
  header.
- Runtime truth still comes from the smoke coverage and manual follow-up
  documented in `validation-matrix.md`.
- `parity-matrix.md` and `validation-matrix.md` are maintained documents, not
  generated outputs, so they should be reviewed directly when behavior changes.
