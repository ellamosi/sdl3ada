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

## Pure Ada Callback Startup

`SDL.Main.Run_Ada_Callback_App` is the simplest way for an Ada executable to
use SDL's callback-driven app model without adding a per-application C shim or
writing C-shaped callback definitions. It collects the current process
arguments from `Ada.Command_Line`, calls `SDL_RunApp`, and then enters
`SDL_EnterAppMainCallbacks` through a bridge owned by `sdl3ada`.

```ada
with My_Callbacks;
with SDL.Main;

procedure My_App is
begin
   SDL.Main.Run_Ada_Callback_App
     (App_Init  => My_Callbacks.Initialize'Access,
      App_Iter  => My_Callbacks.Iterate'Access,
      App_Event => My_Callbacks.Handle_Event'Access,
      App_Quit  => My_Callbacks.Finalize'Access);
end My_App;
```

Use this path when you want SDL's callback app shape with ordinary Ada callback
signatures and package-level state is sufficient. See
`examples/startup/01-hello-ada-owned-helper/` for a complete example.

If you want the callbacks themselves to stay Ada-shaped and also want typed
application state instead of package globals, instantiate
`SDL.Main.Callback_Apps`. The generic owns the C trampolines, typed state
allocation, argument conversion, and exception barriers.

```ada
with SDL.Main.Callback_Apps;
with My_Logic;

package My_App is new SDL.Main.Callback_Apps
  (Application_State => My_Logic.State,
   Initialize        => My_Logic.Initialize,
   Iterate           => My_Logic.Iterate,
   Handle_Event      => My_Logic.Handle_Event,
   Finalize          => My_Logic.Finalize);
```

Then call `My_App.Run` from a normal Ada `main`. See
`examples/startup/01-hello-ada-owned-generic/` for a complete example.

## Low-Level Callback Startup

`SDL.Main.Enter_App_Main_Callbacks` is the low-level Ada equivalent of
`SDL_MAIN_USE_CALLBACKS`. Use it from a thin entry stub and provide
C-convention callbacks matching `SDL.Main.App_Init_Callback`,
`SDL.Main.App_Iterate_Callback`, `SDL.Main.App_Event_Callback`, and
`SDL.Main.App_Quit_Callback`.

If you already have those C-shaped callbacks but want `sdl3ada` to gather
arguments and drive `SDL_RunApp` for you, `SDL.Main.Run_Callback_App` provides
that bridge. Most Ada code should prefer `SDL.Main.Run_Ada_Callback_App` or
`SDL.Main.Callback_Apps`.

This mode hands the outer loop to SDL. Do not combine it with a separate Ada
polling loop that also calls `SDL_PollEvent` or `SDL_WaitEvent`.

See `examples/startup/01-hello-ada-owned-direct/` for a direct minimal example of this shape.

## SDL-Owned Callback Entry

If you want the closest Ada equivalent to SDL's native `SDL_main.h` callback
startup, use a foreign `SDL_main` shim and bind the Ada partition with
`gnatbind -n`.

- `with` both `sdl3ada.gpr` and `sdl3ada_sdlmain.gpr`.
- Add `SDL3Ada_SDLMain.Support_Source_Dir` to the executable project's
  `Source_Dirs`, and use `SDL3Ada_SDLMain.Support_Main` as the C main.
- Either export Ada callbacks with the C names `SDL_AppInit`,
  `SDL_AppIterate`, `SDL_AppEvent`, and `SDL_AppQuit`, or instantiate
  `SDL.Main.SDLMain_Callback_Apps` to have `sdl3ada` provide those exported
  hooks for you.
- Add the binder `-n` switch, the support project's C include path, and the
  usual platform-specific SDL linker settings from your executable project.

```gpr
with "sdl3ada.gpr";
with "sdl3ada_sdlmain.gpr";

project My_App is
   for Languages use ("Ada", "C");
   for Source_Dirs use (".", SDL3Ada_SDLMain.Support_Source_Dir);
   for Main use ("sdl3ada_sdlmain.c");

   package Binder is
      for Default_Switches ("Ada") use ("-n");
   end Binder;

   package Compiler is
      for Default_Switches ("C") use ("-I" & SDL3Ada_SDLMain.SDL_Include_Dir);
   end Compiler;

   package Linker is
      case SDL3Ada.Platform is
         when "macosx" =>
            for Default_Switches ("C") use
              ("-F" & SDL3Ada.SDL3_Framework_Dir,
               "-Wl,-rpath," & SDL3Ada.SDL3_Framework_Dir);

         when others =>
            null;
      end case;
   end Linker;
end My_App;
```

This keeps SDL in charge of the outer process entry shim while leaving the
callback bodies in Ada. It is a specialized interop path rather than the
recommended default for normal Ada applications. See
`examples/startup/01-hello-sdl-owned-direct/` for a complete example.

To keep the app-facing code idiomatic Ada, instantiate
`SDL.Main.SDLMain_Callback_Apps` instead of exporting `SDL_App*` manually. See
`examples/startup/01-hello-sdl-owned-generic/` for that version.

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
