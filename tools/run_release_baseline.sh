#!/bin/sh

set -eu

ROOT=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
cd "$ROOT"

log() {
    printf '%s\n' "$*"
}

run() {
    log "==> $*"
    "$@"
}

run_runtime() {
    log "==> $*"
    if [ -n "$RUNTIME_DYLD_LIBRARY_PATH" ]; then
        env DYLD_LIBRARY_PATH="$RUNTIME_DYLD_LIBRARY_PATH" "$@"
    else
        "$@"
    fi
}

run_runtime_env() {
    log "==> env $*"
    if [ -n "$RUNTIME_DYLD_LIBRARY_PATH" ]; then
        env DYLD_LIBRARY_PATH="$RUNTIME_DYLD_LIBRARY_PATH" "$@"
    else
        env "$@"
    fi
}

RUNTIME_DYLD_LIBRARY_PATH=
if [ "$(uname -s)" = "Darwin" ] && [ -d /opt/local/lib ]; then
    RUNTIME_DYLD_LIBRARY_PATH="/opt/local/lib${DYLD_LIBRARY_PATH:+:$DYLD_LIBRARY_PATH}"
fi

if [ -x /usr/bin/python3 ]; then
    PYTHON=/usr/bin/python3
elif command -v python3 >/dev/null 2>&1; then
    PYTHON=$(command -v python3)
else
    PYTHON=
fi

if [ -n "$PYTHON" ]; then
    run "$PYTHON" tools/update_tracked_sdl_gpr.py --verify
    if [ "${SDL3ADA_PLATFORM:-}" = "macosx" ] && [ -z "${SDL3_FRAMEWORK_DIR:-}" ]; then
        run "$PYTHON" tools/ensure_tracked_sdl_runtime.py --verify
    fi
fi

run alr exec -- gprbuild -P "$ROOT/sdl3ada.gpr"
run sh examples/build_library_probe.sh

for project in \
    examples/smoke/core_smoke.gpr \
    examples/smoke/asyncio_smoke.gpr \
    examples/smoke/concurrency_smoke.gpr \
    examples/smoke/events_smoke.gpr \
    examples/smoke/input_smoke.gpr \
    examples/smoke/device_smoke.gpr \
    examples/smoke/process_smoke.gpr \
    examples/smoke/system_smoke.gpr \
    examples/smoke/storage_smoke.gpr \
    examples/smoke/clipboard_smoke.gpr \
    examples/smoke/audio_smoke.gpr \
    examples/smoke/render_smoke.gpr \
    examples/smoke/video_foundation_smoke.gpr \
    examples/smoke/video_smoke.gpr \
    examples/smoke/advanced_video_smoke.gpr \
    examples/smoke/desktop_smoke.gpr \
    examples/smoke/gpu_smoke.gpr \
    examples/smoke/rwops_smoke.gpr
do
    run alr exec -- gprbuild -P "$project"
done

run_runtime bin/core_smoke
run_runtime bin/asyncio_smoke
run_runtime bin/concurrency_smoke
run_runtime_env SDL_VIDEODRIVER=dummy bin/events_smoke
run_runtime_env SDL_VIDEODRIVER=dummy bin/input_smoke
run_runtime bin/device_smoke
run_runtime bin/process_smoke
run_runtime bin/system_smoke
run_runtime bin/storage_smoke
run_runtime_env SDL_VIDEODRIVER=dummy bin/clipboard_smoke
run_runtime_env SDL_AUDIODRIVER=dummy bin/audio_smoke
run_runtime_env SDL_VIDEODRIVER=dummy bin/render_smoke
run_runtime_env SDL_VIDEODRIVER=dummy bin/video_foundation_smoke
run_runtime_env SDL_VIDEODRIVER=dummy bin/video_smoke
run_runtime_env SDL_VIDEODRIVER=dummy bin/advanced_video_smoke
run_runtime_env SDL_VIDEODRIVER=dummy bin/desktop_smoke
run_runtime_env SDL_VIDEODRIVER=dummy bin/gpu_smoke
run_runtime bin/rwops_smoke

if [ -n "$PYTHON" ]; then
    run "$PYTHON" tools/api_coverage.py --ensure-source
else
    log "==> Skipping coverage verification because no python3 interpreter was found"
fi

log "Release baseline completed."
