#!/bin/sh

set -eu

mkdir -p bin

case "$(uname -s)" in
    Darwin)
        cc -dynamiclib -o bin/liblibraryprobe.dylib examples/library_probe.c
        ;;
    Linux|FreeBSD|OpenBSD|NetBSD|DragonFly)
        cc -shared -fPIC -o bin/liblibraryprobe.so examples/library_probe.c
        ;;
    MINGW*|MSYS*|CYGWIN*)
        cc -shared -o bin/libraryprobe.dll examples/library_probe.c
        ;;
    *)
        echo "Unsupported platform for library probe build: $(uname -s)" >&2
        exit 1
        ;;
esac
