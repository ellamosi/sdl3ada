# SDL3Ada

SDL3Ada is a proof of concept Ada 2022 binding for SDL3.

It attempts to follow similar conventions to
[SDLAda](https://github.com/ada-game-framework/sdlada). The goal is to keep the API
familiar for existing Ada SDL users while exposing SDL3 functionality.

Initial development of this project has been heavily AI-assisted, so the codebase should be read and validated with that in mind.

## Building

The project is set up for [Alire](https://alire.ada.dev/).

So far this repository has only been tested on macOS. It is not intended to be macOS-only, and adapting it to other supported SDL platforms should not be difficult, but that work has not yet been validated.

### Building the library

```sh
alr exec -- gprbuild -P sdl3ada.gpr
```

### Building and running an example
```sh
alr exec -- gprbuild -P examples/renderer/01-clear/clear.gpr
bin/clear
```

## Compatibility

SDL3Ada preserves familiar `SDL.*` unit names where that helps existing
`sdlada` users, but it follows SDL3 semantics rather than trying to emulate
SDL2 behavior. In particular, `SDL.RWops` remains the compatibility package
name while being implemented on top of SDL3's `SDL_IOStream` APIs.

Public-unit parity for the intended `sdlada` target surface is complete,
although much of that surface has not yet been exercised equally in runtime
validation. Some SDL targets are also intentionally excluded from scope where
they do not fit this binding well or would add maintenance cost without clear
benefit. For the detailed package-by-package view, see
[docs/coverage/parity-matrix.md](docs/coverage/parity-matrix.md).

## Examples And Validation

Examples are grouped by category under `examples/`, while smoke targets used
for baseline validation live under `examples/smoke/`. The repository-wide
validation entry point is `tools/run_release_baseline.sh`.

For a guide to the example tree, see [examples/README.md](examples/README.md).
For the full validation breakdown, including subsystem coverage and manual
follow-up areas, see
[docs/coverage/validation-matrix.md](docs/coverage/validation-matrix.md).

For repository maintenance details, tracked SDL inputs, and coverage workflow,
see [docs/development.md](docs/development.md).
