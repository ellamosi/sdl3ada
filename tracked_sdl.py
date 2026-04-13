from __future__ import annotations

from contextlib import contextmanager
from dataclasses import dataclass
import hashlib
import json
import os
from pathlib import Path
import platform
import plistlib
import shutil
import subprocess
import tempfile
from urllib import request


@dataclass(frozen=True)
class TrackedSDLMacOSArtifact:
    asset_name: str
    asset_url: str
    sha256: str | None


@dataclass(frozen=True)
class TrackedSDL:
    project_root: Path
    manifest_path: Path
    library: str
    version: str
    git_url: str
    git_ref: str
    checkout_dir_rel: str
    include_dir_rel: str
    build_dir_rel: str
    macos_framework_dir_rel: str
    checkout_dir: Path
    include_dir: Path
    build_dir: Path
    macos_framework_dir: Path
    macos_artifact: TrackedSDLMacOSArtifact | None


def default_manifest_path(project_root: Path) -> Path:
    return project_root / "tracked-sdl.json"


def default_gpr_config_path(project_root: Path) -> Path:
    return project_root / "tracked_sdl_paths.gpr"


def default_download_cache_dir(project_root: Path) -> Path:
    return project_root / ".deps" / "distfiles"


def _load_json(path: Path) -> dict:
    with path.open("r", encoding="utf-8") as handle:
        data = json.load(handle)

    if not isinstance(data, dict):
        raise ValueError(f"{path} must contain a JSON object")

    return data


def _require_object(container: dict, key: str, path: Path) -> dict:
    value = container.get(key)
    if not isinstance(value, dict):
        raise ValueError(f"{path}: '{key}' must be an object")
    return value


def _require_string(container: dict, key: str, path: Path) -> str:
    value = container.get(key)
    if not isinstance(value, str) or not value:
        raise ValueError(f"{path}: '{key}' must be a non-empty string")
    return value


def _optional_object(container: dict, key: str) -> dict | None:
    value = container.get(key)
    if value is None:
        return None
    if not isinstance(value, dict):
        raise ValueError(f"{key!r} must be an object when present")
    return value


def _optional_string(container: dict, key: str, path: Path) -> str | None:
    value = container.get(key)
    if value is None:
        return None
    if not isinstance(value, str) or not value:
        raise ValueError(f"{path}: '{key}' must be a non-empty string when present")
    return value


def _optional_sha256(container: dict, key: str, path: Path) -> str | None:
    value = _optional_string(container, key, path)
    if value is None:
        return None

    normalized = value.lower()
    if len(normalized) != 64 or any(char not in "0123456789abcdef" for char in normalized):
        raise ValueError(f"{path}: '{key}' must be a 64-character lowercase SHA-256 hex string")

    return normalized


def load_tracked_sdl_manifest(project_root: Path, manifest_path: Path | None = None) -> TrackedSDL:
    root = project_root.resolve()
    manifest = (manifest_path or default_manifest_path(root)).resolve()
    data = _load_json(manifest)

    library = _require_string(data, "library", manifest)
    version = _require_string(data, "version", manifest)
    upstream = _require_object(data, "upstream", manifest)
    paths = _require_object(data, "paths", manifest)
    artifacts = _optional_object(data, "artifacts")

    git_url = _require_string(upstream, "git_url", manifest)
    git_ref = _require_string(upstream, "git_ref", manifest)
    checkout_dir_rel = _require_string(paths, "checkout_dir", manifest)
    include_dir_rel = _require_string(paths, "include_dir", manifest)
    build_dir_rel = _require_string(paths, "build_dir", manifest)
    macos_framework_dir_rel = _require_string(paths, "macos_framework_dir", manifest)

    checkout_dir = (root / checkout_dir_rel).resolve()
    include_dir = (root / include_dir_rel).resolve()
    build_dir = (root / build_dir_rel).resolve()
    macos_framework_dir = (root / macos_framework_dir_rel).resolve()

    try:
        include_dir.relative_to(checkout_dir)
    except ValueError as exc:
        raise ValueError(f"{manifest}: include_dir must live inside checkout_dir") from exc

    macos_artifact = None
    if artifacts is not None:
        macos = _optional_object(artifacts, "macos")
        if macos is not None:
            macos_artifact = TrackedSDLMacOSArtifact(
                asset_name=_require_string(macos, "asset_name", manifest),
                asset_url=_require_string(macos, "asset_url", manifest),
                sha256=_optional_sha256(macos, "sha256", manifest),
            )

    return TrackedSDL(
        project_root=root,
        manifest_path=manifest,
        library=library,
        version=version,
        git_url=git_url,
        git_ref=git_ref,
        checkout_dir_rel=checkout_dir_rel,
        include_dir_rel=include_dir_rel,
        build_dir_rel=build_dir_rel,
        macos_framework_dir_rel=macos_framework_dir_rel,
        checkout_dir=checkout_dir,
        include_dir=include_dir,
        build_dir=build_dir,
        macos_framework_dir=macos_framework_dir,
        macos_artifact=macos_artifact,
    )


def _quote_gpr_string(value: str) -> str:
    return '"' + value.replace('"', '""') + '"'


def _render_gpr_path_expression(
    project_name: str,
    anchor_dir: Path,
    target_path: Path,
) -> str:
    try:
        relative = Path(os.path.relpath(target_path, anchor_dir)).as_posix()
    except ValueError:
        return _quote_gpr_string(target_path.as_posix())

    return f"{project_name}'Project_Dir & {_quote_gpr_string(relative)}"


def render_tracked_sdl_gpr(
    tracked: TrackedSDL,
    output_path: Path | None = None,
    project_name: str = "Tracked_SDL_Paths",
) -> str:
    target_path = (output_path or default_gpr_config_path(tracked.project_root)).resolve()
    anchor_dir = target_path.parent.resolve()

    build_expr = _render_gpr_path_expression(
        project_name=project_name,
        anchor_dir=anchor_dir,
        target_path=tracked.build_dir,
    )
    framework_expr = _render_gpr_path_expression(
        project_name=project_name,
        anchor_dir=anchor_dir,
        target_path=tracked.macos_framework_dir,
    )

    return (
        "--  Generated from tracked-sdl.json. Do not edit manually.\n"
        f"abstract project {project_name} is\n"
        f"   SDL3_Build_Dir := external (\"SDL3_BUILD_DIR\", {build_expr});\n"
        f"   SDL3_Framework_Dir := external (\"SDL3_FRAMEWORK_DIR\", {framework_expr});\n"
        f"end {project_name};\n"
    )


def write_tracked_sdl_gpr(
    tracked: TrackedSDL,
    output_path: Path | None = None,
    project_name: str = "Tracked_SDL_Paths",
) -> Path:
    target_path = (output_path or default_gpr_config_path(tracked.project_root)).resolve()
    contents = render_tracked_sdl_gpr(
        tracked=tracked,
        output_path=target_path,
        project_name=project_name,
    )
    target_path.parent.mkdir(parents=True, exist_ok=True)
    target_path.write_text(contents, encoding="utf-8")
    return target_path


def compute_sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def default_macos_asset_cache_path(tracked: TrackedSDL) -> Path:
    if tracked.macos_artifact is None:
        raise ValueError("tracked-sdl.json does not define artifacts.macos")
    return default_download_cache_dir(tracked.project_root) / tracked.macos_artifact.asset_name


def verify_file_sha256(path: Path, expected_sha256: str | None) -> None:
    if expected_sha256 is None:
        return

    actual = compute_sha256(path)
    if actual != expected_sha256:
        raise ValueError(
            f"{path} has SHA-256 {actual}, expected {expected_sha256}. "
            "Delete the file and retry, or override the asset path."
        )


def download_file(url: str, destination: Path) -> Path:
    destination.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile(
        dir=destination.parent,
        prefix=destination.name + ".",
        suffix=".tmp",
        delete=False,
    ) as handle:
        temp_path = Path(handle.name)

    try:
        download_request = request.Request(
            url,
            headers={"User-Agent": "sdl3ada-tracked-sdl-runtime/1"},
        )
        with request.urlopen(download_request) as response, temp_path.open("wb") as handle:
            shutil.copyfileobj(response, handle)
        temp_path.replace(destination)
    except Exception:
        temp_path.unlink(missing_ok=True)
        raise

    return destination


def _install_tree(source: Path, destination: Path) -> Path:
    temporary = destination.parent / (destination.name + ".tmp")
    if temporary.exists():
        shutil.rmtree(temporary)

    destination.parent.mkdir(parents=True, exist_ok=True)
    shutil.copytree(source, temporary, symlinks=True)

    if destination.exists():
        shutil.rmtree(destination)

    shutil.move(temporary.as_posix(), destination.as_posix())
    return destination


def _resolve_macos_framework_from_xcframework(xcframework_root: Path) -> Path:
    info_path = xcframework_root / "Info.plist"
    if not info_path.is_file():
        raise FileNotFoundError(f"{xcframework_root} does not contain Info.plist")

    info = plistlib.loads(info_path.read_bytes())
    libraries = info.get("AvailableLibraries")
    if not isinstance(libraries, list):
        raise ValueError(f"{info_path} does not define AvailableLibraries")

    for library in libraries:
        if not isinstance(library, dict):
            continue
        if library.get("SupportedPlatform") != "macos":
            continue

        identifier = library.get("LibraryIdentifier")
        library_path = library.get("LibraryPath")
        if not isinstance(identifier, str) or not isinstance(library_path, str):
            continue

        framework_path = (xcframework_root / identifier / library_path).resolve()
        if framework_path.is_dir() and framework_path.name == "SDL3.framework":
            return framework_path

    raise FileNotFoundError(f"{xcframework_root} does not contain a macOS SDL3.framework slice")


def _find_macos_framework(root: Path) -> Path:
    if root.is_dir() and root.name == "SDL3.framework":
        return root.resolve()

    direct_framework = root / "SDL3.framework"
    if direct_framework.is_dir():
        return direct_framework.resolve()

    if root.is_dir() and root.name.endswith(".xcframework"):
        return _resolve_macos_framework_from_xcframework(root)

    xcframeworks = sorted(path for path in root.glob("*.xcframework") if path.is_dir())
    if len(xcframeworks) == 1:
        return _resolve_macos_framework_from_xcframework(xcframeworks[0])

    if len(xcframeworks) > 1:
        raise FileNotFoundError(f"{root} contains multiple xcframeworks; choose one explicitly")

    raise FileNotFoundError(
        f"Could not find SDL3.framework or SDL3.xcframework in {root}"
    )


@contextmanager
def mounted_dmg(dmg_path: Path):
    if platform.system() != "Darwin":
        raise RuntimeError("Mounting a .dmg requires macOS (hdiutil)")

    attached = subprocess.run(
        ["hdiutil", "attach", "-plist", "-readonly", "-nobrowse", dmg_path.as_posix()],
        check=True,
        capture_output=True,
    )
    mount_data = plistlib.loads(attached.stdout)
    mount_point = None
    for entity in mount_data.get("system-entities", []):
        if not isinstance(entity, dict):
            continue
        candidate = entity.get("mount-point")
        if isinstance(candidate, str) and candidate:
            mount_point = Path(candidate)
            break

    if mount_point is None:
        raise RuntimeError(f"Could not determine mount point for {dmg_path}")

    try:
        yield mount_point
    finally:
        subprocess.run(
            ["hdiutil", "detach", mount_point.as_posix()],
            check=False,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )


def verify_macos_framework(tracked: TrackedSDL) -> Path:
    framework_path = tracked.macos_framework_dir / "SDL3.framework"
    if not framework_path.is_dir():
        raise FileNotFoundError(
            f"Tracked macOS runtime is missing: {framework_path}\n"
            "Run tools/ensure_tracked_sdl_runtime.py --download or pass --asset."
        )

    return framework_path


def ensure_macos_framework(
    tracked: TrackedSDL,
    asset_path: Path | None = None,
    *,
    download: bool = False,
    force: bool = False,
    asset_url: str | None = None,
    expected_sha256: str | None = None,
) -> Path:
    framework_path = tracked.macos_framework_dir / "SDL3.framework"
    if framework_path.is_dir() and not force:
        return tracked.macos_framework_dir

    local_asset = asset_path
    manifest_asset = tracked.macos_artifact

    if local_asset is None:
        if not download:
            raise FileNotFoundError(
                f"{framework_path} does not exist.\n"
                "Run tools/ensure_tracked_sdl_runtime.py --download or provide --asset."
            )
        if manifest_asset is None and asset_url is None:
            raise ValueError(
                "tracked-sdl.json does not define artifacts.macos and no asset URL was provided"
            )

        local_asset = default_macos_asset_cache_path(tracked)
        url = asset_url or (manifest_asset.asset_url if manifest_asset is not None else None)
        if url is None:
            raise ValueError("No macOS asset URL is available")

        if not local_asset.exists() or force:
            download_file(url, local_asset)

        verify_file_sha256(
            local_asset,
            expected_sha256 or (manifest_asset.sha256 if manifest_asset is not None else None),
        )
    else:
        local_asset = local_asset.resolve()
        if not local_asset.exists():
            raise FileNotFoundError(f"Asset path does not exist: {local_asset}")

        if local_asset.is_file() and local_asset.suffix.lower() == ".dmg":
            verify_file_sha256(
                local_asset,
                expected_sha256 or (manifest_asset.sha256 if manifest_asset is not None else None),
            )

    if local_asset.is_file():
        if local_asset.suffix.lower() != ".dmg":
            raise ValueError(f"Unsupported macOS runtime asset file: {local_asset}")

        with mounted_dmg(local_asset) as mount_root:
            source_framework = _find_macos_framework(mount_root)
            _install_tree(source_framework, framework_path)
    else:
        source_framework = _find_macos_framework(local_asset)
        _install_tree(source_framework, framework_path)

    return tracked.macos_framework_dir


def run_git(args: list[str], workdir: Path | None = None) -> None:
    subprocess.run(
        ["git", *args],
        cwd=None if workdir is None else workdir,
        check=True,
    )


def has_git_ref(workdir: Path, git_ref: str) -> bool:
    result = subprocess.run(
        ["git", "rev-parse", "--verify", "--quiet", f"{git_ref}^{{commit}}"],
        cwd=workdir,
        check=False,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    return result.returncode == 0


def ensure_sdl_checkout(
    tracked: TrackedSDL,
    upstream_url: str | None = None,
    checkout_ref: str | None = None,
) -> Path:
    git_url = upstream_url or tracked.git_url
    git_ref = checkout_ref or tracked.git_ref
    checkout_dir = tracked.checkout_dir

    checkout_dir.parent.mkdir(parents=True, exist_ok=True)

    if checkout_dir.exists():
        if not (checkout_dir / ".git").exists():
            raise ValueError(
                f"{checkout_dir} exists, but it is not a git checkout. "
                "Remove it or update tracked-sdl.json to use a different location."
            )
    else:
        run_git(["clone", "--origin", "origin", "--no-checkout", git_url, checkout_dir.as_posix()])

    current_url = subprocess.run(
        ["git", "remote", "get-url", "origin"],
        cwd=checkout_dir,
        check=False,
        capture_output=True,
        text=True,
    )

    if current_url.returncode != 0 or current_url.stdout.strip() != git_url:
        run_git(["remote", "set-url", "origin", git_url], workdir=checkout_dir)

    if not has_git_ref(checkout_dir, git_ref):
        run_git(["fetch", "--tags", "origin"], workdir=checkout_dir)

    run_git(["checkout", "--detach", git_ref], workdir=checkout_dir)

    if not tracked.include_dir.is_dir():
        raise FileNotFoundError(
            f"SDL checkout is present at {checkout_dir}, but {tracked.include_dir} does not exist."
        )

    return tracked.include_dir
