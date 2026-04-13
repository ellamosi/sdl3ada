#!/usr/bin/env python3

from __future__ import annotations

import argparse
from pathlib import Path
import sys


ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from tracked_sdl import (  # noqa: E402
    default_gpr_config_path,
    load_tracked_sdl_manifest,
    render_tracked_sdl_gpr,
    write_tracked_sdl_gpr,
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Generate the shared GPR SDL path defaults from tracked-sdl.json.",
    )
    parser.add_argument(
        "--project-root",
        default=str(ROOT),
        help="Repository root containing tracked-sdl.json.",
    )
    parser.add_argument(
        "--manifest",
        default=None,
        help="Override the tracked SDL manifest path.",
    )
    parser.add_argument(
        "--output",
        default=None,
        help="Override the output GPR file path.",
    )
    parser.add_argument(
        "--verify",
        action="store_true",
        help="Fail if the generated file would differ from the checked-in file.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    project_root = Path(args.project_root).resolve()
    manifest = None if args.manifest is None else Path(args.manifest).resolve()

    tracked = load_tracked_sdl_manifest(project_root=project_root, manifest_path=manifest)
    output_path = (
        default_gpr_config_path(project_root)
        if args.output is None
        else Path(args.output).resolve()
    )
    expected = render_tracked_sdl_gpr(tracked=tracked, output_path=output_path)

    if args.verify:
        try:
            actual = output_path.read_text(encoding="utf-8")
        except FileNotFoundError:
            print(f"missing generated file: {output_path}", file=sys.stderr)
            return 1

        if actual != expected:
            print(
                f"stale generated file: {output_path}\n"
                "run tools/update_tracked_sdl_gpr.py to regenerate it",
                file=sys.stderr,
            )
            return 1

        return 0

    write_tracked_sdl_gpr(tracked=tracked, output_path=output_path)
    print(output_path)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
