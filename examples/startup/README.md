# SDL3Ada Startup Examples

The `startup/` category keeps the SDL side intentionally small so the example
structure focuses on entry ownership and callback wiring rather than rendering
logic. Each example initializes SDL video, opens a window titled
`"Hello, SDL3Ada"`, waits until the window is closed, and then shuts SDL down.

- `01-hello-ada-owned-direct/` uses `SDL.Main.Enter_App_Main_Callbacks` directly.
- `01-hello-ada-owned-helper/` uses `SDL.Main.Run_Ada_Callback_App`.
- `01-hello-ada-owned-generic/` uses `SDL.Main.Callback_Apps`.
- `01-hello-sdl-owned-direct/` composes with `sdl3ada_sdlmain.gpr` and uses manual exported `SDL_App*` callbacks.
- `01-hello-sdl-owned-generic/` uses `SDL.Main.SDLMain_Callback_Apps`.
