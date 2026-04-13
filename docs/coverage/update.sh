#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
PROJECT_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/../.." && pwd)

find_python() {
  if [ "${PYTHON:-}" != "" ]; then
    if [ -x "$PYTHON" ] && "$PYTHON" -c 'import sys' >/dev/null 2>&1; then
      printf '%s\n' "$PYTHON"
      return 0
    fi

    if command -v "$PYTHON" >/dev/null 2>&1; then
      CANDIDATE=$(command -v "$PYTHON")
      if "$CANDIDATE" -c 'import sys' >/dev/null 2>&1; then
        printf '%s\n' "$CANDIDATE"
        return 0
      fi
    fi
  fi

  for CANDIDATE in python3 python /usr/bin/python3; do
    if [ -x "$CANDIDATE" ] && "$CANDIDATE" -c 'import sys' >/dev/null 2>&1; then
      printf '%s\n' "$CANDIDATE"
      return 0
    fi

    if command -v "$CANDIDATE" >/dev/null 2>&1; then
      RESOLVED=$(command -v "$CANDIDATE")
      if "$RESOLVED" -c 'import sys' >/dev/null 2>&1; then
        printf '%s\n' "$RESOLVED"
        return 0
      fi
    fi
  done

  return 1
}

PYTHON_BIN=$(find_python) || {
  echo "Unable to find a working Python interpreter for tools/api_coverage.py" >&2
  exit 127
}

exec "$PYTHON_BIN" "$PROJECT_ROOT/tools/api_coverage.py" "$@"
