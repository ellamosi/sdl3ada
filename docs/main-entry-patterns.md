# SDL3Ada Main Entry Patterns

SDL's C `SDL_main.h` header injects platform-specific entry code with
preprocessor macros. Ada does not consume that header directly, so `sdl3ada`
exposes the runtime pieces explicitly through `SDL.Main`.

## Normal Ada Executable

Most Ada programs should keep their normal Ada `main` procedure and call
`SDL.Main.Set_Ready` before the first SDL initialization call. This is the
Ada equivalent of defining `SDL_MAIN_HANDLED` and calling
`SDL_SetMainReady()`.

```ada
with SDL;
with SDL.Error;
with SDL.Main;

procedure My_App is
begin
   SDL.Main.Set_Ready;

   if not SDL.Initialise (SDL.Enable_Video or SDL.Enable_Events) then
      raise Program_Error with SDL.Error.Get;
   end if;

   SDL.Quit;
end My_App;
```

Use this path when the executable already starts in Ada and you do not need
SDL to provide a custom process entry point.

## Delegating Startup To SDL

`SDL.Main.Run_App` is the explicit Ada binding for `SDL_RunApp`. Use it when
some other entry point must hand control to SDL for platform-specific startup.
When using `Run_App`, do not call `SDL.Main.Set_Ready` first; SDL documents
`SDL_RunApp` as the replacement for that manual step.

`ArgC` and `ArgV` may be zero and `System.Null_Address` if the platform does
not naturally provide them. SDL will synthesize arguments where it can.

## Callback-Driven Startup

`SDL.Main.Enter_App_Main_Callbacks` is the low-level Ada equivalent of
`SDL_MAIN_USE_CALLBACKS`. Use it from a thin entry stub and provide
C-convention callbacks matching `SDL.Main.App_Init_Callback`,
`SDL.Main.App_Iterate_Callback`, `SDL.Main.App_Event_Callback`, and
`SDL.Main.App_Quit_Callback`.

This mode hands the outer loop to SDL. Do not combine it with a separate Ada
polling loop that also calls `SDL_PollEvent` or `SDL_WaitEvent`.

## Platform-Specific Helpers

`SDL.Main.Register_App` and `SDL.Main.Unregister_App` expose
`SDL_RegisterApp` and `SDL_UnregisterApp` for the rare Win32 case where the
application must control the window-class registration before SDL video
initialization. Most callers should not use these helpers directly; SDL video
startup already handles registration when needed.

On non-Windows targets SDL reports these helpers as unsupported. The
`SDL.Main.Register_App` wrapper raises `SDL.Main.Main_Error` on that failure.
`SDL.Main.Unregister_App` is still exposed so Win32 code can pair cleanup with
explicit registration.

`SDL.Main.GDK_Suspend_Complete` remains the direct binding for the Xbox GDK
background-suspend handoff. It is only meaningful on GDK targets.
