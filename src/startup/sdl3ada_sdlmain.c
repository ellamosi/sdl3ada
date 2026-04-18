#if defined(__has_include)
#if __has_include(<SDL3/SDL.h>)
#include <SDL3/SDL.h>
#include <SDL3/SDL_main.h>
#else
#include <SDL.h>
#include <SDL_main.h>
#endif
#else
#include <SDL3/SDL.h>
#include <SDL3/SDL_main.h>
#endif

extern void adainit(void);
extern void adafinal(void);

extern SDL_AppResult SDLCALL SDL_AppInit(void **appstate, int argc, char *argv[]);
extern SDL_AppResult SDLCALL SDL_AppIterate(void *appstate);
extern SDL_AppResult SDLCALL SDL_AppEvent(void *appstate, SDL_Event *event);
extern void SDLCALL SDL_AppQuit(void *appstate, SDL_AppResult result);

int SDL_main(int argc, char *argv[])
{
    int exit_code = 0;

    adainit();
    exit_code =
        SDL_EnterAppMainCallbacks(argc, argv, SDL_AppInit, SDL_AppIterate, SDL_AppEvent, SDL_AppQuit);
    adafinal();

    return exit_code;
}

#if !defined(SDL_MAIN_AVAILABLE) && !defined(SDL_MAIN_NEEDED)
int main(int argc, char *argv[])
{
    return SDL_RunApp(argc, argv, SDL_main, NULL);
}
#endif
