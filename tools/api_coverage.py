from __future__ import annotations

import os
import argparse
import json
import sys
from collections import Counter, defaultdict, deque
from pathlib import Path
from typing import Any
import re

PROJECT_ROOT = Path(__file__).resolve().parents[1]
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))

from tracked_sdl import ensure_sdl_checkout, load_tracked_sdl_manifest


INCLUDE_RE = re.compile(r'#include <SDL3/(SDL_[A-Za-z0-9_]+\.h)>')
DECL_START_RE = re.compile(r'extern\s+SDL_DECLSPEC\b')
CALL_RE = re.compile(r'\bSDLCALL\s+(SDL_[A-Za-z0-9_]+)\s*\(')
MACRO_ALIAS_RE = re.compile(
    r'^\s*#define\s+(SDL_[A-Za-z0-9_]+)\s*\((.*?)\)\s*(SDL_[A-Za-z0-9_]+)\s*\(',
    re.M,
)
EXTERNAL_NAME_RE = re.compile(r'External_Name\s*=>\s*"((?:SDL|SDLMAIN)_[A-Za-z0-9_]+)"')


def parse_args() -> argparse.Namespace:
    tools_dir = Path(__file__).resolve().parent
    project_root = tools_dir.parent
    coverage_dir = project_root / "docs" / "coverage"

    parser = argparse.ArgumentParser(
        description=(
            "Measure SDL callable API coverage by comparing SDL public headers "
            "to imported SDL symbols in the Ada binding."
        )
    )
    parser.add_argument(
        "--project-root",
        type=Path,
        default=project_root,
        help="Path to the sdl3ada repository root.",
    )
    parser.add_argument(
        "--config",
        type=Path,
        default=coverage_dir / "policy.json",
        help="Path to the coverage policy JSON file.",
    )
    parser.add_argument(
        "--manifest",
        type=Path,
        default=project_root / "tracked-sdl.json",
        help="Path to the tracked SDL manifest JSON file.",
    )
    parser.add_argument(
        "--sdl-include",
        type=Path,
        default=None,
        help="Path to the SDL include/SDL3 directory. Overrides tracked-sdl.json.",
    )
    parser.add_argument(
        "--ensure-source",
        action="store_true",
        help="Ensure the tracked SDL checkout exists inside the repository before scanning.",
    )
    parser.add_argument(
        "--upstream-url",
        default=None,
        help="Override the manifest upstream git URL when ensuring the local SDL checkout.",
    )
    parser.add_argument(
        "--checkout-ref",
        default=None,
        help="Override the manifest git ref when ensuring the local SDL checkout.",
    )
    parser.add_argument(
        "--json-out",
        type=Path,
        default=coverage_dir / "report.json",
        help="Where to write the machine-readable report.",
    )
    parser.add_argument(
        "--markdown-out",
        type=Path,
        default=coverage_dir / "report.md",
        help="Where to write the Markdown report.",
    )
    parser.add_argument(
        "--fail-on-missing",
        action="store_true",
        help="Exit with status 1 if any tracked SDL API remains uncovered.",
    )
    return parser.parse_args()


def normalize_space(value: str) -> str:
    return " ".join(value.split())


def line_number(text: str, offset: int) -> int:
    return text.count("\n", 0, offset) + 1


def relative_to(path: Path, base: Path) -> str:
    return Path(os.path.relpath(path.resolve(), base.resolve())).as_posix()


def find_matching_paren(text: str, open_index: int) -> int:
    depth = 0

    for index in range(open_index, len(text)):
        char = text[index]

        if char == "(":
            depth += 1
        elif char == ")":
            depth -= 1
            if depth == 0:
                return index

    raise ValueError(f"Unbalanced parentheses starting at offset {open_index}")


def load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as handle:
        data = json.load(handle)

    if not isinstance(data, dict):
        raise ValueError(f"{path} must contain a JSON object")

    return data


def discover_headers(include_dir: Path, entry_headers: list[str]) -> list[str]:
    seen: set[str] = set()
    queue: deque[str] = deque(entry_headers)
    ordered: list[str] = []

    while queue:
        header = queue.popleft()
        if header in seen:
            continue

        header_path = include_dir / header
        if not header_path.is_file():
            raise FileNotFoundError(f"SDL header not found: {header_path}")

        seen.add(header)
        ordered.append(header)

        text = header_path.read_text(encoding="utf-8")
        for include in INCLUDE_RE.findall(text):
            if include not in seen:
                queue.append(include)

    return sorted(ordered)


def extract_api_symbols(include_dir: Path, headers: list[str]) -> tuple[list[dict[str, Any]], dict[str, str]]:
    symbols: list[dict[str, Any]] = []
    aliases: dict[str, str] = {}

    for header in headers:
        header_path = include_dir / header
        text = header_path.read_text(encoding="utf-8")

        for macro_name, _macro_params, target_name in MACRO_ALIAS_RE.findall(text):
            aliases[macro_name] = target_name

        for decl_match in DECL_START_RE.finditer(text):
            start = decl_match.start()
            call_match = CALL_RE.search(text, start)
            if call_match is None:
                continue

            next_semicolon = text.find(";", start)
            if next_semicolon == -1:
                raise ValueError(f"Missing ';' while parsing {header_path}")

            if call_match.start() > next_semicolon:
                continue

            symbol_name = call_match.group(1)
            open_paren_index = text.find("(", call_match.start())
            if open_paren_index == -1:
                raise ValueError(f"Missing parameter list for {symbol_name} in {header_path}")

            close_paren_index = find_matching_paren(text, open_paren_index)
            semicolon_index = text.find(";", close_paren_index)
            if semicolon_index == -1:
                raise ValueError(f"Missing ';' after {symbol_name} in {header_path}")

            snippet = text[start:semicolon_index + 1]
            parameters = text[open_paren_index + 1:close_paren_index]

            symbols.append(
                {
                    "name": symbol_name,
                    "header": header,
                    "header_line": line_number(text, start),
                    "signature": normalize_space(snippet),
                    "parameters": normalize_space(parameters),
                    "variadic_or_va_list": ("..." in parameters or "va_list" in parameters),
                }
            )

    return symbols, aliases


def collect_ada_imports(src_root: Path, project_root: Path) -> dict[str, list[dict[str, Any]]]:
    imports: dict[str, list[dict[str, Any]]] = defaultdict(list)
    source_paths = sorted(src_root.rglob("*.ads")) + sorted(src_root.rglob("*.adb"))

    for source_path in source_paths:
        text = source_path.read_text(encoding="utf-8")
        relative_path = relative_to(source_path, project_root)

        for match in EXTERNAL_NAME_RE.finditer(text):
            symbol_name = match.group(1)
            imports[symbol_name].append(
                {
                    "path": relative_path,
                    "line": line_number(text, match.start()),
                }
            )

    for locations in imports.values():
        locations.sort(key=lambda item: (item["path"], item["line"]))

    return dict(sorted(imports.items()))


def resolve_reference(project_root: Path, reference: dict[str, Any]) -> dict[str, Any]:
    path_value = reference.get("path")
    pattern = reference.get("pattern")

    if not isinstance(path_value, str) or not path_value:
        raise ValueError("Manual coverage references require a non-empty 'path'")

    if not isinstance(pattern, str) or not pattern:
        raise ValueError("Manual coverage references require a non-empty 'pattern'")

    reference_path = (project_root / path_value).resolve()
    if not reference_path.is_file():
        raise FileNotFoundError(f"Manual coverage reference file not found: {reference_path}")

    text = reference_path.read_text(encoding="utf-8")
    offset = text.find(pattern)
    if offset == -1:
        raise ValueError(f"Pattern not found in {reference_path}: {pattern!r}")

    return {
        "path": relative_to(reference_path, project_root),
        "line": line_number(text, offset),
    }


def resolve_manual_coverage(
    project_root: Path,
    raw_entries: list[dict[str, Any]],
) -> dict[str, dict[str, Any]]:
    manual: dict[str, dict[str, Any]] = {}

    for entry in raw_entries:
        symbol = entry.get("symbol")
        reason = entry.get("reason")
        references = entry.get("references", [])

        if not isinstance(symbol, str) or not symbol.startswith("SDL_"):
            raise ValueError("Manual coverage entries require an SDL symbol name")

        if symbol in manual:
            raise ValueError(f"Duplicate manual coverage entry for {symbol}")

        if not isinstance(reason, str) or not reason:
            raise ValueError(f"Manual coverage entry for {symbol} is missing a reason")

        if not isinstance(references, list) or not references:
            raise ValueError(f"Manual coverage entry for {symbol} requires references")

        manual[symbol] = {
            "reason": reason,
            "references": [resolve_reference(project_root, reference) for reference in references],
        }

    return dict(sorted(manual.items()))


def build_report(
    project_root: Path,
    tracked_sdl: Any,
    include_dir: Path,
    policy_path: Path,
    symbols: list[dict[str, Any]],
    aliases: dict[str, str],
    ada_imports: dict[str, list[dict[str, Any]]],
    policy: dict[str, Any],
    manual_coverage: dict[str, dict[str, Any]],
) -> dict[str, Any]:
    exclude_headers = policy.get("exclude_headers", {})
    exclude_symbols = policy.get("exclude_symbols", {})
    exclude_signatures = policy.get("exclude_signatures", {})

    if not isinstance(exclude_headers, dict):
        raise ValueError("'exclude_headers' must be an object")
    if not isinstance(exclude_symbols, dict):
        raise ValueError("'exclude_symbols' must be an object")
    if not isinstance(exclude_signatures, dict):
        raise ValueError("'exclude_signatures' must be an object")

    signature_exclusion_reason = exclude_signatures.get("variadic_or_va_list")
    if signature_exclusion_reason is not None and not isinstance(signature_exclusion_reason, str):
        raise ValueError("'exclude_signatures.variadic_or_va_list' must be a string")

    excluded_by_reason: dict[str, list[str]] = defaultdict(list)
    alias_entries: list[dict[str, Any]] = []
    manual_entries: list[dict[str, Any]] = []
    symbol_entries: list[dict[str, Any]] = []

    header_stats: dict[str, Counter[str]] = defaultdict(Counter)

    for symbol in sorted(symbols, key=lambda item: (item["header"], item["name"])):
        name = symbol["name"]
        header = symbol["header"]
        entry = dict(symbol)
        entry["classification"] = "missing"
        entry["coverage_reason"] = None
        entry["coverage_references"] = []
        entry["covered_by_symbol"] = None

        if header in exclude_headers:
            reason = exclude_headers[header]
            if not isinstance(reason, str) or not reason:
                raise ValueError(f"Header exclusion for {header} must be a non-empty string")
            entry["classification"] = "excluded"
            entry["coverage_reason"] = reason
            excluded_by_reason[reason].append(name)
        elif name in exclude_symbols:
            reason = exclude_symbols[name]
            if not isinstance(reason, str) or not reason:
                raise ValueError(f"Symbol exclusion for {name} must be a non-empty string")
            entry["classification"] = "excluded"
            entry["coverage_reason"] = reason
            excluded_by_reason[reason].append(name)
        elif entry["variadic_or_va_list"]:
            if not signature_exclusion_reason:
                raise ValueError(
                    f"{name} uses variadic or va_list parameters, but the policy does not define "
                    "'exclude_signatures.variadic_or_va_list'"
                )
            entry["classification"] = "excluded"
            entry["coverage_reason"] = signature_exclusion_reason
            excluded_by_reason[signature_exclusion_reason].append(name)
        elif name in ada_imports:
            entry["classification"] = "direct"
            entry["coverage_reason"] = "Imported directly by the Ada binding."
            entry["coverage_references"] = ada_imports[name]
        elif name in aliases and aliases[name] in ada_imports:
            target = aliases[name]
            entry["classification"] = "alias"
            entry["covered_by_symbol"] = target
            entry["coverage_reason"] = f"Covered via public SDL macro forwarding to {target}."
            entry["coverage_references"] = ada_imports[target]
            alias_entries.append(
                {
                    "api_symbol": name,
                    "target_symbol": target,
                    "references": ada_imports[target],
                }
            )
        elif name in manual_coverage:
            manual_entry = manual_coverage[name]
            entry["classification"] = "manual"
            entry["coverage_reason"] = manual_entry["reason"]
            entry["coverage_references"] = manual_entry["references"]
            manual_entries.append(
                {
                    "api_symbol": name,
                    "reason": manual_entry["reason"],
                    "references": manual_entry["references"],
                }
            )

        header_stats[header][entry["classification"]] += 1
        symbol_entries.append(entry)

    headers: list[dict[str, Any]] = []
    for header in sorted(header_stats):
        stats = header_stats[header]
        tracked = stats["direct"] + stats["alias"] + stats["manual"] + stats["missing"]
        covered = stats["direct"] + stats["alias"] + stats["manual"]
        percent = None if tracked == 0 else round((covered / tracked) * 100.0, 2)

        headers.append(
            {
                "header": header,
                "tracked": tracked,
                "covered": covered,
                "missing": stats["missing"],
                "excluded": stats["excluded"],
                "direct": stats["direct"],
                "alias": stats["alias"],
                "manual": stats["manual"],
                "coverage_percent": percent,
            }
        )

    summary_counter = Counter(entry["classification"] for entry in symbol_entries)
    tracked_total = summary_counter["direct"] + summary_counter["alias"] + summary_counter["manual"] + summary_counter["missing"]
    covered_total = summary_counter["direct"] + summary_counter["alias"] + summary_counter["manual"]
    coverage_percent = 100.0 if tracked_total == 0 else round((covered_total / tracked_total) * 100.0, 2)

    excluded_summary = [
        {
            "reason": reason,
            "count": len(sorted_symbols),
            "symbols": sorted(sorted_symbols),
        }
        for reason, sorted_symbols in sorted(
            ((reason, sorted(names)) for reason, names in excluded_by_reason.items()),
            key=lambda item: item[0],
        )
    ]

    missing_by_header: list[dict[str, Any]] = []
    for header in sorted({entry["header"] for entry in symbol_entries if entry["classification"] == "missing"}):
        missing_symbols = [entry["name"] for entry in symbol_entries if entry["header"] == header and entry["classification"] == "missing"]
        missing_by_header.append(
            {
                "header": header,
                "symbols": missing_symbols,
            }
        )

    report = {
        "tool": "tools/api_coverage.py",
        "scope": "Callable SDL public API coverage",
        "project_root": ".",
        "policy_file": relative_to(policy_path, project_root),
        "tracked_sdl": {
            "manifest_file": relative_to(tracked_sdl.manifest_path, project_root),
            "library": tracked_sdl.library,
            "version": tracked_sdl.version,
            "git_url": tracked_sdl.git_url,
            "git_ref": tracked_sdl.git_ref,
            "checkout_dir": tracked_sdl.checkout_dir_rel,
            "include_dir": tracked_sdl.include_dir_rel,
        },
        "scan": {
            "include_dir": relative_to(include_dir, project_root),
        },
        "summary": {
            "total_symbols": len(symbol_entries),
            "tracked_symbols": tracked_total,
            "covered_symbols": covered_total,
            "missing_symbols": summary_counter["missing"],
            "excluded_symbols": summary_counter["excluded"],
            "coverage_percent": coverage_percent,
            "direct_symbols": summary_counter["direct"],
            "alias_symbols": summary_counter["alias"],
            "manual_symbols": summary_counter["manual"],
        },
        "headers": headers,
        "aliases": sorted(alias_entries, key=lambda item: item["api_symbol"]),
        "manual_coverage": sorted(manual_entries, key=lambda item: item["api_symbol"]),
        "excluded_scope": excluded_summary,
        "missing_by_header": missing_by_header,
        "symbols": symbol_entries,
    }

    return report


def render_percent(value: float | None) -> str:
    return "n/a" if value is None else f"{value:.2f}%"


def render_references(references: list[dict[str, Any]]) -> str:
    return ", ".join(f"`{item['path']}:{item['line']}`" for item in references)


def render_markdown(report: dict[str, Any], project_root: Path) -> str:
    summary = report["summary"]
    tracked_sdl = report["tracked_sdl"]
    include_display = report["scan"]["include_dir"]

    lines: list[str] = []
    lines.append("# SDL3Ada Callable API Coverage")
    lines.append("")
    lines.append(
        "This report is generated from SDL public headers and the Ada source tree in this repository. "
        "It measures callable API coverage, not every macro, enum value, or typedef spelling."
    )
    lines.append("")
    lines.append(f"Tracked SDL version: `{tracked_sdl['version']}`")
    lines.append(f"Tracked SDL ref: `{tracked_sdl['git_ref']}`")
    lines.append(f"Tracked checkout dir: `{tracked_sdl['checkout_dir']}`")
    lines.append(f"Source headers scanned: `{include_display}`")
    lines.append("")
    lines.append("## Summary")
    lines.append("")
    lines.append("| Metric | Count |")
    lines.append("| --- | ---: |")
    lines.append(f"| SDL callable API symbols discovered | {summary['total_symbols']} |")
    lines.append(f"| Tracked symbols | {summary['tracked_symbols']} |")
    lines.append(f"| Covered symbols | {summary['covered_symbols']} |")
    lines.append(f"| Missing symbols | {summary['missing_symbols']} |")
    lines.append(f"| Excluded symbols | {summary['excluded_symbols']} |")
    lines.append(f"| Coverage | {summary['coverage_percent']:.2f}% |")
    lines.append(f"| Direct coverage | {summary['direct_symbols']} |")
    lines.append(f"| Alias coverage | {summary['alias_symbols']} |")
    lines.append(f"| Manual wrapper coverage | {summary['manual_symbols']} |")
    lines.append("")
    lines.append("## Scope Rules")
    lines.append("")
    lines.append("- `SDL_stdinc.h` is excluded as an intentional policy choice: Ada code should use Ada/runtime facilities instead of binding SDL's C runtime replacement layer directly.")
    lines.append("- Variadic and `va_list` entry points are excluded from automatic coverage because they do not map cleanly to a 1:1 Ada binding.")
    lines.append("- Public SDL macro forwards such as `SDL_CreateThread` are credited automatically when their real exported target is imported by the binding.")
    lines.append("- A small explicit wrapper map is used where SDL offers convenience entry points and the Ada API exposes the capability through a different surface.")
    lines.append("")
    lines.append("## Header Coverage")
    lines.append("")
    lines.append("| Header | Tracked | Covered | Missing | Excluded | Coverage |")
    lines.append("| --- | ---: | ---: | ---: | ---: | ---: |")

    for header in report["headers"]:
        lines.append(
            f"| `{header['header']}` | {header['tracked']} | {header['covered']} | "
            f"{header['missing']} | {header['excluded']} | {render_percent(header['coverage_percent'])} |"
        )

    lines.append("")

    if report["aliases"]:
        lines.append("## Alias-Covered API")
        lines.append("")
        lines.append("| SDL API | Covered Through | Ada References |")
        lines.append("| --- | --- | --- |")
        for entry in report["aliases"]:
            lines.append(
                f"| `{entry['api_symbol']}` | `{entry['target_symbol']}` | "
                f"{render_references(entry['references'])} |"
            )
        lines.append("")

    if report["manual_coverage"]:
        lines.append("## Manual Wrapper Coverage")
        lines.append("")
        lines.append("| SDL API | Ada References | Reason |")
        lines.append("| --- | --- | --- |")
        for entry in report["manual_coverage"]:
            lines.append(
                f"| `{entry['api_symbol']}` | {render_references(entry['references'])} | {entry['reason']} |"
            )
        lines.append("")

    lines.append("## Missing Tracked Symbols")
    lines.append("")

    if summary["missing_symbols"] == 0:
        lines.append("No tracked callable SDL API symbols are currently missing.")
        lines.append("")
    else:
        for bucket in report["missing_by_header"]:
            lines.append(f"### `{bucket['header']}` ({len(bucket['symbols'])})")
            lines.append("")
            for symbol_name in bucket["symbols"]:
                lines.append(f"- `{symbol_name}`")
            lines.append("")

    lines.append("## Excluded Scope Summary")
    lines.append("")
    lines.append("| Reason | Count |")
    lines.append("| --- | ---: |")
    for entry in report["excluded_scope"]:
        lines.append(f"| {entry['reason']} | {entry['count']} |")
    lines.append("")
    lines.append(
        "The full per-symbol classification, signatures, and source references are available in "
        "`docs/coverage/report.json`."
    )
    lines.append("")

    return "\n".join(lines)


def ensure_parent(path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)


def main() -> int:
    args = parse_args()
    project_root = args.project_root.resolve()
    policy_path = (args.config if args.config.is_absolute() else project_root / args.config).resolve()
    manifest_path = (args.manifest if args.manifest.is_absolute() else project_root / args.manifest).resolve()

    policy = load_json(policy_path)
    tracked_sdl = load_tracked_sdl_manifest(project_root, manifest_path)

    if args.ensure_source:
        ensure_sdl_checkout(
            tracked_sdl,
            upstream_url=args.upstream_url,
            checkout_ref=args.checkout_ref,
        )

    sdl_include = args.sdl_include
    if sdl_include is None:
        sdl_include = tracked_sdl.include_dir

    include_dir = sdl_include.resolve()
    src_root = project_root / "src"

    if not include_dir.is_dir():
        if args.sdl_include is None:
            raise FileNotFoundError(
                "SDL include directory not found: "
                f"{include_dir}. Run `docs/coverage/update.sh --ensure-source` to create the "
                "repo-local SDL checkout described in tracked-sdl.json, or pass "
                "`--sdl-include` to point at an existing SDL include tree."
            )
        raise FileNotFoundError(f"SDL include directory not found: {include_dir}")
    if not src_root.is_dir():
        raise FileNotFoundError(f"Ada source directory not found: {src_root}")

    entry_headers = policy.get("entry_headers")
    if not isinstance(entry_headers, list) or not entry_headers or not all(isinstance(item, str) for item in entry_headers):
        raise ValueError("'entry_headers' must be a non-empty array of strings")

    manual_coverage = resolve_manual_coverage(
        project_root=project_root,
        raw_entries=policy.get("manual_coverage", []),
    )

    headers = discover_headers(include_dir, entry_headers)
    api_symbols, aliases = extract_api_symbols(include_dir, headers)
    ada_imports = collect_ada_imports(src_root, project_root)
    report = build_report(
        project_root=project_root,
        tracked_sdl=tracked_sdl,
        include_dir=include_dir,
        policy_path=policy_path,
        symbols=api_symbols,
        aliases=aliases,
        ada_imports=ada_imports,
        policy=policy,
        manual_coverage=manual_coverage,
    )

    ensure_parent(args.json_out)
    ensure_parent(args.markdown_out)

    with args.json_out.open("w", encoding="utf-8") as handle:
        json.dump(report, handle, indent=2, sort_keys=True)
        handle.write("\n")

    with args.markdown_out.open("w", encoding="utf-8") as handle:
        handle.write(render_markdown(report, project_root))

    summary = report["summary"]
    print(
        "Tracked: {tracked}  Covered: {covered}  Missing: {missing}  Coverage: {coverage:.2f}%".format(
            tracked=summary["tracked_symbols"],
            covered=summary["covered_symbols"],
            missing=summary["missing_symbols"],
            coverage=summary["coverage_percent"],
        )
    )
    print(f"Markdown report: {args.markdown_out}")
    print(f"JSON report: {args.json_out}")

    if args.fail_on_missing and summary["missing_symbols"] > 0:
        return 1

    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f"error: {exc}", file=sys.stderr)
        raise SystemExit(1)
