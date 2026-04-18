#!/usr/bin/env python3

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
SRC_DIR = ROOT / "src"
DEFAULT_BASELINE = Path(__file__).with_name("non_raw_import_baseline.txt")

EXTERNAL_NAME_RE = re.compile(r"\b(?:External_Name|Link_Name)\s*=>")
PRAGMA_IMPORT_RE = re.compile(r"^\s*pragma\s+Import\s*\(\s*(?!Ada\b)", re.IGNORECASE)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Fail when non-raw source units gain new direct external imports. "
            "The checked-in baseline allows the current in-progress conversion "
            "state while still catching regressions."
        )
    )
    parser.add_argument(
        "--baseline",
        type=Path,
        default=DEFAULT_BASELINE,
        help="Baseline file with `<relative-path> <expected-count>` entries.",
    )
    parser.add_argument(
        "--write-baseline",
        action="store_true",
        help="Overwrite the baseline file with the current scan and exit.",
    )
    return parser.parse_args()


def is_raw_file(path: Path) -> bool:
    return path.name.startswith("sdl-raw-")


def scan_file(path: Path) -> list[str]:
    findings: list[str] = []

    for lineno, line in enumerate(path.read_text(encoding="utf-8").splitlines(), start=1):
        if EXTERNAL_NAME_RE.search(line) or PRAGMA_IMPORT_RE.search(line):
            findings.append(f"{path.relative_to(ROOT).as_posix()}:{lineno}: {line.strip()}")

    return findings


def scan_tree() -> dict[str, list[str]]:
    results: dict[str, list[str]] = {}

    for path in sorted(SRC_DIR.rglob("*.ad[bs]")):
        if is_raw_file(path):
            continue

        findings = scan_file(path)
        if findings:
            results[path.relative_to(ROOT).as_posix()] = findings

    return results


def load_baseline(path: Path) -> dict[str, int]:
    baseline: dict[str, int] = {}

    if not path.exists():
        raise FileNotFoundError(f"Baseline file not found: {path}")

    for lineno, line in enumerate(path.read_text(encoding="utf-8").splitlines(), start=1):
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            continue

        try:
            relative_path, count_text = stripped.rsplit(maxsplit=1)
            baseline[relative_path] = int(count_text)
        except ValueError as exc:
            raise ValueError(f"{path}:{lineno}: invalid baseline entry: {line!r}") from exc

    return baseline


def write_baseline(path: Path, findings: dict[str, list[str]]) -> None:
    lines = [
        "# Non-raw import baseline",
        "#",
        "# Format: <relative-path> <expected-finding-count>",
        "#",
        "# Findings are lines outside `SDL.Raw.*` that contain either",
        "# `External_Name`/`Link_Name` aspects or non-Ada `pragma Import` calls.",
        "# Update this file only when intentional conversion work changes the",
        "# remaining non-raw import footprint.",
        "",
    ]

    for relative_path in sorted(findings):
        lines.append(f"{relative_path} {len(findings[relative_path])}")

    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def report_drift(
    findings: dict[str, list[str]], baseline: dict[str, int]
) -> tuple[list[str], int]:
    messages: list[str] = []
    total_findings = sum(len(items) for items in findings.values())
    current_counts = {path: len(items) for path, items in findings.items()}

    for relative_path in sorted(current_counts):
        actual = current_counts[relative_path]
        expected = baseline.get(relative_path)

        if expected is None:
            messages.append(
                f"New non-raw import file: {relative_path} ({actual} findings, baseline had none)"
            )
            messages.extend(f"  {line}" for line in findings[relative_path])
            continue

        if actual != expected:
            delta = actual - expected
            direction = "more" if delta > 0 else "fewer"
            messages.append(
                f"Baseline drift in {relative_path}: expected {expected}, found {actual} ({abs(delta)} {direction})"
            )
            messages.extend(f"  {line}" for line in findings[relative_path])

    for relative_path in sorted(set(baseline) - set(current_counts)):
        messages.append(
            f"Baseline drift in {relative_path}: expected {baseline[relative_path]}, found 0"
        )

    return messages, total_findings


def main() -> int:
    args = parse_args()
    findings = scan_tree()

    if args.write_baseline:
        write_baseline(args.baseline, findings)
        print(f"Wrote non-raw import baseline to {args.baseline.relative_to(ROOT)}")
        return 0

    try:
        baseline = load_baseline(args.baseline)
    except (FileNotFoundError, ValueError) as exc:
        print(str(exc), file=sys.stderr)
        return 1

    messages, total_findings = report_drift(findings, baseline)
    if messages:
        print("Non-raw import baseline check failed:", file=sys.stderr)
        for message in messages:
            print(message, file=sys.stderr)
        print(
            "\nIf the drift is intentional conversion work, update the baseline with:",
            file=sys.stderr,
        )
        print(
            f"  python3 {Path(__file__).relative_to(ROOT)} --write-baseline",
            file=sys.stderr,
        )
        return 1

    print(
        f"Non-raw import baseline check passed: {len(findings)} files, {total_findings} findings."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
