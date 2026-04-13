#!/usr/bin/env python3

from __future__ import annotations

import argparse
import json
from pathlib import Path
import sys


ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from tracked_sdl import (  # noqa: E402
    compute_sha256,
    default_macos_asset_cache_path,
    default_manifest_path,
    load_tracked_sdl_manifest,
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Compute the tracked macOS SDL release asset SHA-256 from the local "
            "cached file and write it into tracked-sdl.json."
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
        help="Override the local asset path. Defaults to the cached tracked macOS asset.",
    )
    parser.add_argument(
        "--verify",
        action="store_true",
        help="Fail unless tracked-sdl.json already contains the computed SHA-256.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    project_root = Path(args.project_root).resolve()
    manifest_path = (
        default_manifest_path(project_root)
        if args.manifest is None
        else Path(args.manifest).resolve()
    )
    tracked = load_tracked_sdl_manifest(project_root=project_root, manifest_path=manifest_path)

    asset_path = (
        default_macos_asset_cache_path(tracked)
        if args.asset is None
        else Path(args.asset).resolve()
    )
    if not asset_path.is_file():
        print(f"Asset file does not exist: {asset_path}", file=sys.stderr)
        return 1

    actual_sha256 = compute_sha256(asset_path)
    data = json.loads(manifest_path.read_text(encoding="utf-8"))
    artifacts = data.setdefault("artifacts", {})
    macos = artifacts.setdefault("macos", {})
    recorded_sha256 = macos.get("sha256")

    if args.verify:
        if recorded_sha256 != actual_sha256:
            print(
                f"{manifest_path}: artifacts.macos.sha256 is {recorded_sha256!r}, "
                f"expected {actual_sha256}",
                file=sys.stderr,
            )
            return 1

        return 0

    macos["sha256"] = actual_sha256
    manifest_path.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
    print(f"{manifest_path}: artifacts.macos.sha256={actual_sha256}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
