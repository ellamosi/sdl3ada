# Callable API Audit

This note covers the green-field callable SDL API audit for `sdl3ada`. The
checked-in policy and generated reports now live under
[`docs/coverage/`](./), while the scanner itself lives under
[`tools/`](../../tools/) with the rest of the repository utilities.

The tracked SDL release is defined once in
[`tracked-sdl.json`](../../tracked-sdl.json). The coverage tooling reads that
manifest instead of assuming a sibling checkout exists outside the repository.

## What It Measures

The audit measures **callable SDL API coverage**:

- SDL exported/public callable entry points are discovered from the SDL public
  headers.
- Ada coverage is discovered from imported `SDL_*` external names in `src/`.
- Each SDL API symbol is classified as one of:
  - direct: the Ada binding imports the exact SDL symbol.
  - alias: the public SDL API name is a macro front for another exported
    symbol, and the binding imports that real target.
  - manual: the binding exposes the capability through a deliberate wrapper
    rather than the exact SDL symbol name.
  - excluded: the policy explicitly removes the symbol from the tracked scope.
  - missing: the symbol is still uncovered.

This does **not** attempt to auto-score every macro, enum member, typedef, or
property string. Those are much harder to compare accurately across C and Ada
without a large hand-maintained map. Callable API coverage is the deterministic
subset that makes new SDL function additions visible immediately.

## Files

- `../../tools/api_coverage.py`: coverage scanner and report generator.
- `policy.json`: scope decisions and the small set of manual wrapper mappings.
- `update.sh`: stable entrypoint that picks a working Python interpreter.
- `report.json`: generated machine-readable report.
- `report.md`: generated human-readable report.
- `../../tracked-sdl.json`: single source of truth for the tracked SDL version,
  upstream git ref, and repo-local checkout path.
- `../../tracked_sdl.py`: shared manifest loader and repo-local SDL checkout
  helper used by the coverage and tracked-SDL tooling.

## Usage

From the repository root:

```sh
docs/coverage/update.sh
```

If the tracked SDL checkout does not exist inside the repository yet:

```sh
docs/coverage/update.sh --ensure-source
```

To point the audit at a different SDL checkout:

```sh
docs/coverage/update.sh --sdl-include ../SDL-3.5.0/include/SDL3
```

For local development, `--ensure-source` also accepts temporary checkout
overrides such as:

```sh
docs/coverage/update.sh --ensure-source --upstream-url /path/to/local/SDL
```

To make CI fail when tracked coverage gaps remain:

```sh
docs/coverage/update.sh --fail-on-missing
```

## Policy

The policy file is where the audit becomes explicit and reviewable.

- Header-level exclusions document intentional scope boundaries.
- Variadic or `va_list` signatures are excluded automatically.
- Convenience wrappers that are intentionally exposed under a different Ada
  surface are declared in `manual_coverage`.
- The tracked SDL version, git ref, and repo-local checkout location come from
  `tracked-sdl.json`, not from `policy.json`.

If SDL adds new callable APIs in a future version, they will appear as
`missing` until they are either bound directly, covered by a documented
wrapper, or explicitly excluded by policy.
