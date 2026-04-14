# SDL3Ada Examples

The `examples/` tree contains both usage examples and validation-oriented
programs. Most directories are grouped by topic so the tree stays navigable,
while `smoke/` collects the smaller baseline targets used to keep major
subsystems buildable and runnable.

## Categories

- `examples/smoke/` contains the baseline validation targets.
- `examples/renderer/`, `audio/`, `input/`, `camera/`, `misc/`, `asyncio/`,
  `pen/`, and `demo/` contain topic-based examples and SDL ports.
- `examples/test/` holds ports that originate from SDL's upstream `test/`
  tree rather than its `examples/` tree.

## Start Here

If you just want a few representative entry points, start with:

- `examples/renderer/01-clear/` demonstrates direct callback startup via `SDL.Main.Enter_App_Main_Callbacks`.
- `examples/renderer/01-clear-run-callback-app/` demonstrates the helper-based pure-Ada callback startup via `SDL.Main.Run_Callback_App`.
- `examples/renderer/01-clear-generic/` demonstrates the same pure-Ada callback flow through `SDL.Main.Callback_Apps`.
- `examples/renderer/01-clear-sdlmain/` demonstrates the SDL-owned callback startup path via `sdl3ada_sdlmain.gpr`.
- `examples/renderer/01-clear-sdlmain-generic/` demonstrates the SDL-owned callback path through `SDL.Main.SDLMain_Callback_Apps`, packaged as a single `Clear` unit.
- `examples/audio/01-simple-playback/`
- `examples/input/01-joystick-polling/`
- `examples/smoke/core_smoke.gpr`
- `examples/smoke/render_smoke.gpr`

## Building And Running

Build an example from the repository root with:

```sh
alr exec -- gprbuild -P examples/renderer/01-clear/clear.gpr
```

Built binaries are emitted in `bin/`. For exhaustive build and run coverage,
including subsystem-specific smoke targets and manual follow-up areas, see
[docs/coverage/validation-matrix.md](../docs/coverage/validation-matrix.md).
