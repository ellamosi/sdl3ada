#!/usr/bin/env python3

from __future__ import annotations

import argparse
from pathlib import Path
import sys


ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from tracked_sdl import (  # noqa: E402
    ensure_macos_framework,
    load_tracked_sdl_manifest,
    verify_macos_framework,
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Ensure the tracked macOS SDL runtime is present in the normalized "
            "repo-local framework directory."
        ),
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
        "--asset",
        default=None,
        help=(
            "Local runtime asset to normalize. Supported inputs: a .dmg, an "
            "SDL3.xcframework directory, an SDL3.framework directory, or a "
            "directory containing one of those."
        ),
    )
    parser.add_argument(
        "--download",
        action="store_true",
        help="Download the official macOS asset declared in tracked-sdl.json if needed.",
    )
    parser.add_argument(
        "--asset-url",
        default=None,
        help="Override the download URL for --download.",
    )
    parser.add_argument(
        "--sha256",
        default=None,
        help="Override the expected SHA-256 for the downloaded or local .dmg asset.",
    )
    parser.add_argument(
        "--force",
        action="store_true",
        help="Reinstall the normalized runtime even if SDL3.framework already exists.",
    )
    parser.add_argument(
        "--verify",
        action="store_true",
        help="Fail unless the normalized repo-local SDL3.framework already exists.",
    )
    return parser.parse_args()


def main() -> int:
    try:
        args = parse_args()
        project_root = Path(args.project_root).resolve()
        manifest = None if args.manifest is None else Path(args.manifest).resolve()
        tracked = load_tracked_sdl_manifest(project_root=project_root, manifest_path=manifest)

        if args.verify:
            framework_path = verify_macos_framework(tracked)
        else:
            asset_path = None if args.asset is None else Path(args.asset).resolve()
            framework_dir = ensure_macos_framework(
                tracked,
                asset_path=asset_path,
                download=args.download,
                force=args.force,
                asset_url=args.asset_url,
                expected_sha256=args.sha256,
            )
            framework_path = framework_dir / "SDL3.framework"
    except (FileNotFoundError, OSError, RuntimeError, ValueError) as exc:
        print(exc, file=sys.stderr)
        return 1

    print(framework_path)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
