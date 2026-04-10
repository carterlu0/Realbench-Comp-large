#!/usr/bin/env python3
"""
RealBench black-box completion platform.

This script standardizes how a completion model or completion system is called
by the RealBench evaluation stack.

The system under test is treated as a black box. It only needs to implement a
single Python-callable function with the following contract:

    def generate_completion(request: dict) -> str | dict:
        ...

Accepted return values:
  1. A raw string containing only the completion code.
  2. A dict containing at least:
       {"completion": "<code-only-output>"}

The platform is responsible for:
  - building a normalized request object
  - collecting target file / prefix / suffix
  - collecting same-repository Verilog context according to a chosen policy
  - collecting related markdown docs and optional images
  - validating that the adapter output is code-only

Typical usage:

  python run_completion_adapter.py \
      --adapter my_adapter:generate_completion \
      --target-file /home/carter/Realbench-Comp/Realbench-Comp_weighted_001/e203_hbirdv2/e203_exu_alu/e203_exu_alu__mask0001.v \
      --repo-root /home/carter/Realbench-Comp \
      --context-policy recursive_upstream \
      --include-docs auto \
      --response-out /tmp/response.json

The generated request object is JSON-serializable and can also be saved for
debugging or for adapter-side replay.
"""

from __future__ import annotations

import argparse
import base64
import importlib
import importlib.util
import json
import mimetypes
import os
import random
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Callable, Iterable, Mapping, Sequence

from benchmark_info import benchmark_info


DEFAULT_REPO_ROOT = Path(__file__).resolve().parents[1]
SCHEMA_VERSION = "rb_completion_request_v1"
PLACEHOLDER_LINE = "// <masked:to be completed>"
DEFAULT_TARGET_LANGUAGE = "verilog"
DEFAULT_MAX_CONTEXT_FILES = 32
DEFAULT_RANDOM_SEED = 1

SOURCE_SYSTEM_DIRS = ("sdc", "aes", "e203_hbirdv2")
MASK_FILE_RE = re.compile(r"^(?P<task>[A-Za-z0-9_]+)__mask(?P<mask_id>\d+)\.v$")


@dataclass(frozen=True)
class TargetIdentity:
    system: str | None
    task: str | None
    variant: str | None
    source_kind: str


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="ignore")


def load_json(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def rel_or_abs(path: Path, root: Path) -> str:
    try:
        return str(path.resolve().relative_to(root.resolve()).as_posix())
    except Exception:
        return str(path.resolve())


def infer_target_identity(target_file: Path, repo_root: Path) -> TargetIdentity:
    parts = target_file.resolve().parts
    variant = None
    task = None
    system = None
    source_kind = "unknown"

    try:
        rel_parts = target_file.resolve().relative_to(repo_root.resolve()).parts
    except Exception:
        rel_parts = target_file.resolve().parts

    if len(rel_parts) >= 3:
        candidate_system = rel_parts[-3]
        candidate_task = rel_parts[-2]
        filename = rel_parts[-1]
        match = MASK_FILE_RE.match(filename)
        if match:
            source_kind = "masked"
            system = candidate_system
            task = candidate_task
            variant = f"mask{match.group('mask_id')}"
        elif filename == f"{candidate_task}.v":
            source_kind = "source"
            system = candidate_system
            task = candidate_task

    return TargetIdentity(system=system, task=task, variant=variant, source_kind=source_kind)


def split_target_by_placeholder(code: str) -> tuple[str, str, bool]:
    idx = code.find(PLACEHOLDER_LINE)
    if idx < 0:
        return code, "", False
    suffix_start = idx + len(PLACEHOLDER_LINE)
    if suffix_start < len(code) and code[suffix_start : suffix_start + 1] == "\n":
        suffix_start += 1
    prefix = code[:idx]
    suffix = code[suffix_start:]
    return prefix, suffix, True


def load_target_metadata(target_file: Path, explicit_meta_path: Path | None) -> dict[str, Any]:
    meta_path = explicit_meta_path or Path(str(target_file) + ".json")
    if not meta_path.exists():
        return {}
    try:
        return load_json(meta_path)
    except Exception as exc:
        return {"meta_load_error": str(exc), "meta_path": str(meta_path)}


def module_index(repo_root: Path, system_name: str) -> dict[str, Path]:
    search_root = repo_root / system_name
    out: dict[str, Path] = {}
    if not search_root.is_dir():
        return out
    for path in sorted(search_root.rglob("*.v")):
        out.setdefault(path.stem, path)
    return out


def resolve_module_file(repo_root: Path, system_name: str, module_name: str) -> Path | None:
    direct = repo_root / system_name / module_name / f"{module_name}.v"
    if direct.is_file():
        return direct
    indexed = module_index(repo_root, system_name).get(module_name)
    if indexed is not None:
        return indexed

    # Masked datasets contain only target variants, not the full source repo.
    # Fall back to the canonical RealBench source tree so context retrieval
    # can still resolve upstream/downstream modules without changing caller settings.
    if repo_root.resolve() != DEFAULT_REPO_ROOT.resolve():
        fallback_direct = DEFAULT_REPO_ROOT / system_name / module_name / f"{module_name}.v"
        if fallback_direct.is_file():
            return fallback_direct
        return module_index(DEFAULT_REPO_ROOT, system_name).get(module_name)

    return None


def benchmark_dependencies(system_name: str, task_name: str) -> list[str]:
    return list(benchmark_info.get(system_name, {}).get(task_name, []))


def canonical_source_file(repo_root: Path, identity: TargetIdentity) -> Path | None:
    if identity.system is None or identity.task is None:
        return None
    return resolve_module_file(repo_root, identity.system, identity.task)


def resolve_workspace_relative_path(
    repo_root: Path,
    relative_path: str,
    identity: TargetIdentity,
) -> Path | None:
    candidate_roots = [repo_root]
    for parent in repo_root.resolve().parents:
        candidate_roots.append(parent)

    seen_roots: set[Path] = set()
    for root in candidate_roots:
        resolved_root = root.resolve()
        if resolved_root in seen_roots:
            continue
        seen_roots.add(resolved_root)

        candidate = (resolved_root / relative_path).resolve()
        if candidate.exists():
            return candidate

        if identity.system and not (resolved_root / identity.system).exists():
            continue

    return None


def recursive_upstream_modules(system_name: str, task_name: str) -> list[str]:
    seen: set[str] = set()
    out: list[str] = []

    def dfs(name: str) -> None:
        for dep in benchmark_dependencies(system_name, name):
            if dep in seen:
                continue
            seen.add(dep)
            out.append(dep)
            dfs(dep)

    dfs(task_name)
    return out


def reverse_dependency_map(system_name: str) -> dict[str, list[str]]:
    out: dict[str, list[str]] = {}
    for module_name, deps in benchmark_info.get(system_name, {}).items():
        for dep in deps:
            out.setdefault(dep, []).append(module_name)
    for modules in out.values():
        modules.sort()
    return out


def recursive_downstream_modules(system_name: str, task_name: str) -> list[str]:
    reverse_map = reverse_dependency_map(system_name)
    seen: set[str] = set()
    out: list[str] = []

    def dfs(name: str) -> None:
        for child in reverse_map.get(name, []):
            if child in seen:
                continue
            seen.add(child)
            out.append(child)
            dfs(child)

    dfs(task_name)
    return out


def all_source_verilog_files(repo_root: Path) -> list[Path]:
    """Collect all source Verilog files from known systems, excluding verification/test directories."""
    out: list[Path] = []
    # Directories to exclude (test/verification related)
    EXCLUDE_DIRS = {"verification", "test", "tests", "tb", "testbench", "sim", "simulation"}
    
    for system_name in SOURCE_SYSTEM_DIRS:
        root = repo_root / system_name
        if root.is_dir():
            for p in root.rglob("*.v"):
                # Check if any parent directory name matches exclude list
                rel_parts = p.relative_to(root).parts
                if any(part.lower() in EXCLUDE_DIRS for part in rel_parts):
                    continue
                out.append(p)
    return sorted(out)


def parse_custom_context_list(path: Path) -> list[str]:
    items: list[str] = []
    for raw in path.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        items.append(line)
    return items


def collect_context_paths(
    repo_root: Path,
    target_file: Path,
    identity: TargetIdentity,
    context_policy: str,
    max_context_files: int,
    seed: int,
    custom_context_list: Path | None = None,
) -> list[dict[str, Any]]:
    rng = random.Random(seed)
    target_resolved = target_file.resolve()
    system_name = identity.system
    task_name = identity.task
    canonical_target_source = canonical_source_file(repo_root, identity)
    canonical_target_source_resolved = (
        None if canonical_target_source is None else canonical_target_source.resolve()
    )

    def path_entry(path: Path, role: str) -> dict[str, Any]:
        return {
            "path": rel_or_abs(path, repo_root),
            "role": role,
            "content": read_text(path),
        }

    if context_policy == "none":
        return []

    if system_name is None or task_name is None:
        if context_policy in {"same_system_random", "direct_upstream", "recursive_upstream", "direct_downstream", "recursive_downstream", "upstream_and_downstream"}:
            raise ValueError(
                "Cannot infer target system/task from target path; please use a target path "
                "that preserves <system>/<task>/..., or use a policy that does not require task identity."
            )

    entries: list[dict[str, Any]] = []
    seen_paths: set[Path] = set()

    def add_path(path: Path | None, role: str) -> None:
        if path is None:
            return
        resolved = path.resolve()
        if resolved == target_resolved:
            return
        if canonical_target_source_resolved is not None and resolved == canonical_target_source_resolved:
            return
        if resolved in seen_paths:
            return
        seen_paths.add(resolved)
        entries.append(path_entry(resolved, role))

    if context_policy == "direct_upstream":
        for dep in benchmark_dependencies(system_name, task_name):
            add_path(resolve_module_file(repo_root, system_name, dep), "direct_upstream")
    elif context_policy == "recursive_upstream":
        for dep in recursive_upstream_modules(system_name, task_name):
            add_path(resolve_module_file(repo_root, system_name, dep), "recursive_upstream")
    elif context_policy == "direct_downstream":
        for dep in reverse_dependency_map(system_name).get(task_name, []):
            add_path(resolve_module_file(repo_root, system_name, dep), "direct_downstream")
    elif context_policy == "recursive_downstream":
        for dep in recursive_downstream_modules(system_name, task_name):
            add_path(resolve_module_file(repo_root, system_name, dep), "recursive_downstream")
    elif context_policy == "upstream_and_downstream":
        for dep in recursive_upstream_modules(system_name, task_name):
            add_path(resolve_module_file(repo_root, system_name, dep), "recursive_upstream")
        for dep in recursive_downstream_modules(system_name, task_name):
            add_path(resolve_module_file(repo_root, system_name, dep), "recursive_downstream")
    elif context_policy == "same_system_random":
        candidates: list[Path] = []
        for p in all_source_verilog_files(repo_root):
            try:
                rel = p.resolve().relative_to(repo_root.resolve())
            except Exception:
                continue
            if not rel.parts or rel.parts[0] != system_name:
                continue
            if p.resolve() == target_resolved:
                continue
            if canonical_target_source_resolved is not None and p.resolve() == canonical_target_source_resolved:
                continue
            candidates.append(p)
        rng.shuffle(candidates)
        limit = len(candidates) if max_context_files <= 0 else max_context_files
        for path in candidates[:limit]:
            add_path(path, "same_system_random")
    elif context_policy == "repo_random":
        candidates: list[Path] = []
        for p in all_source_verilog_files(repo_root):
            if p.resolve() == target_resolved:
                continue
            if canonical_target_source_resolved is not None and p.resolve() == canonical_target_source_resolved:
                continue
            candidates.append(p)
        rng.shuffle(candidates)
        limit = len(candidates) if max_context_files <= 0 else max_context_files
        for path in candidates[:limit]:
            add_path(path, "repo_random")
    elif context_policy == "all_other_verilog":
        if system_name is None:
            raise ValueError(
                "all_other_verilog now means 'all other Verilog files in the same system', "
                "so the target system must be inferable from the target path."
            )
        for path in all_source_verilog_files(repo_root):
            try:
                rel = path.resolve().relative_to(repo_root.resolve())
            except Exception:
                continue
            if not rel.parts or rel.parts[0] != system_name:
                continue
            add_path(path, "same_system_all")
    elif context_policy == "custom":
        if custom_context_list is None:
            raise ValueError("custom context policy requires --custom-context-list")
        for raw in parse_custom_context_list(custom_context_list):
            candidate = Path(raw)
            if not candidate.is_absolute():
                candidate = repo_root / candidate
            add_path(candidate, "custom")
    else:
        raise ValueError(f"Unsupported context_policy={context_policy!r}")

    if max_context_files > 0 and context_policy in {
        "direct_upstream",
        "recursive_upstream",
        "direct_downstream",
        "recursive_downstream",
        "upstream_and_downstream",
        "custom",
        "all_other_verilog",
    }:
        entries = entries[:max_context_files]

    return entries


def collect_related_docs(
    repo_root: Path,
    target_file: Path,
    identity: TargetIdentity,
    include_docs: str,
    explicit_doc_paths: Sequence[Path],
    metadata: Mapping[str, Any] | None = None,
) -> list[dict[str, Any]]:
    """Collect design documentation for the target file.
    
    With include_docs='auto', collects the same-named .md file first, then a
    small number of nearby spec/overview markdown files that appear strongly
    related to the current task.
    """
    if include_docs == "none":
        return []

    docs: list[Path] = []
    if include_docs == "auto":
        stem = identity.task or target_file.stem
        system_prefix = (identity.system or "").split("_")[0].lower()

        def doc_score(path: Path) -> tuple[int, int, str]:
            name = path.stem.lower()
            parent = path.parent.name.lower()
            score = 0
            if stem.lower() in name:
                score += 10
            if identity.task and identity.task.lower() in name:
                score += 8
            if system_prefix and system_prefix in name:
                score += 4
            if any(token in name for token in ("designspec", "spec", "overview", "manual", "guide")):
                score += 3
            if any(token in parent for token in ("doc", "docs", "spec", "design")):
                score += 1
            return (score, -len(path.parts), path.name.lower())

        search_dirs: list[Path] = [target_file.parent]
        canonical = canonical_source_file(repo_root, identity)
        if canonical is not None:
            search_dirs.append(canonical.parent)
        seen_search_dirs: set[Path] = set()
        for here in search_dirs:
            resolved_here = here.resolve()
            if resolved_here in seen_search_dirs or not resolved_here.exists():
                continue
            seen_search_dirs.add(resolved_here)
            same_stem = resolved_here / f"{stem}.md"
            if same_stem.exists():
                docs.append(same_stem)

            candidate_dirs = [resolved_here]
            if resolved_here.parent.exists():
                candidate_dirs.append(resolved_here.parent)

            scored_candidates: list[tuple[tuple[int, int, str], Path]] = []
            seen_candidates: set[Path] = set()
            for candidate_dir in candidate_dirs:
                for candidate in candidate_dir.glob("*.md"):
                    resolved_candidate = candidate.resolve()
                    if resolved_candidate in seen_candidates or resolved_candidate == same_stem.resolve():
                        continue
                    seen_candidates.add(resolved_candidate)
                    score_key = doc_score(resolved_candidate)
                    if score_key[0] <= 0:
                        continue
                    scored_candidates.append((score_key, resolved_candidate))

            scored_candidates.sort(key=lambda item: item[0], reverse=True)
            for _, candidate in scored_candidates[:3]:
                docs.append(candidate)

        for rel_path in metadata.get("related_docs", []) if metadata else []:
            candidate = resolve_workspace_relative_path(repo_root, str(rel_path), identity)
            if candidate is None:
                continue
            if candidate.exists() and candidate.suffix.lower() == ".md":
                docs.append(candidate)
    elif include_docs == "explicit":
        docs.extend(explicit_doc_paths)
    else:
        raise ValueError(f"Unsupported include_docs={include_docs!r}")

    out: list[dict[str, Any]] = []
    seen: set[Path] = set()
    for path in docs:
        resolved = path.resolve()
        if not resolved.exists() or resolved in seen:
            continue
        seen.add(resolved)
        out.append(
            {
                "path": rel_or_abs(resolved, repo_root),
                "content": read_text(resolved),
            }
        )
    return out


def collect_images(
    repo_root: Path,
    target_file: Path,
    identity: TargetIdentity,
    include_images: str,
    explicit_image_paths: Sequence[Path],
) -> list[dict[str, Any]]:
    """Collect design images/figures for the target file.
    
    With include_images='auto', collects images from the 'figures' subdirectory
    of the canonical source file's directory.
    
    Supported image formats: png, jpg, jpeg, gif, svg, webp
    """
    if include_images == "none":
        return []

    image_paths: list[Path] = []
    if include_images == "auto":
        # Search for figures directory in the canonical source location
        canonical = canonical_source_file(repo_root, identity)
        search_dirs: list[Path] = []
        if canonical is not None:
            search_dirs.append(canonical.parent)
        
        # Also check target file's parent (for masked files)
        search_dirs.append(target_file.parent)
        
        seen_dirs: set[Path] = set()
        for here in search_dirs:
            resolved_here = here.resolve()
            if resolved_here in seen_dirs or not resolved_here.exists():
                continue
            seen_dirs.add(resolved_here)
            
            # Check for 'figures' subdirectory (common naming)
            figures_dir = resolved_here / "figures"
            if figures_dir.exists() and figures_dir.is_dir():
                for ext in ["*.png", "*.jpg", "*.jpeg", "*.gif", "*.svg", "*.webp"]:
                    image_paths.extend(figures_dir.glob(ext))
    elif include_images == "explicit":
        image_paths.extend(explicit_image_paths)
    else:
        raise ValueError(f"Unsupported include_images={include_images!r}")

    out: list[dict[str, Any]] = []
    seen: set[Path] = set()
    for path in image_paths:
        resolved = path.resolve()
        if not resolved.exists() or resolved in seen:
            continue
        seen.add(resolved)
        media_type, _ = mimetypes.guess_type(str(resolved))
        encoded = base64.b64encode(resolved.read_bytes()).decode("ascii")
        out.append(
            {
                "path": rel_or_abs(resolved, repo_root),
                "media_type": media_type or "application/octet-stream",
                "content_base64": encoded,
            }
        )
    return out


def build_request(
    target_file: Path,
    repo_root: Path,
    context_policy: str,
    max_context_files: int,
    seed: int,
    include_docs: str,
    explicit_doc_paths: Sequence[Path],
    include_images: str,
    explicit_image_paths: Sequence[Path],
    custom_context_list: Path | None,
    explicit_meta_path: Path | None,
) -> dict[str, Any]:
    target_code = read_text(target_file)
    prefix, suffix, has_explicit_hole = split_target_by_placeholder(target_code)
    identity = infer_target_identity(target_file, repo_root)
    meta = load_target_metadata(target_file, explicit_meta_path)

    context_verilog = collect_context_paths(
        repo_root=repo_root,
        target_file=target_file,
        identity=identity,
        context_policy=context_policy,
        max_context_files=max_context_files,
        seed=seed,
        custom_context_list=custom_context_list,
    )
    docs = collect_related_docs(
        repo_root=repo_root,
        target_file=target_file,
        identity=identity,
        include_docs=include_docs,
        explicit_doc_paths=explicit_doc_paths,
        metadata=meta,
    )
    images = collect_images(
        repo_root=repo_root,
        target_file=target_file,
        identity=identity,
        include_images=include_images,
        explicit_image_paths=explicit_image_paths,
    )
    canonical = canonical_source_file(repo_root, identity)

    request = {
        "schema_version": SCHEMA_VERSION,
        "task_type": "code_completion",
        "target_language": DEFAULT_TARGET_LANGUAGE,
        "target": {
            "path": rel_or_abs(target_file, repo_root),
            "system": identity.system,
            "task": identity.task,
            "variant": identity.variant,
            "source_kind": identity.source_kind,
            "canonical_source_path": None if canonical is None else rel_or_abs(canonical, repo_root),
            "placeholder_line": PLACEHOLDER_LINE,
            "has_explicit_hole": has_explicit_hole,
            "whole_file": target_code,
            "prefix": prefix,
            "suffix": suffix,
            "metadata": meta,
        },
        "context": {
            "verilog_files": context_verilog,
            "docs_md": docs,
            "images": images,
        },
        "input_contract": {
            "supported_channels": [
                "target.whole_file",
                "target.prefix",
                "target.suffix",
                "context.verilog_files",
                "context.docs_md",
                "context.images",
            ],
            "required_output": {
                "type": "string",
                "meaning": "completion_only",
                "forbidden": [
                    "full_file_output",
                    "markdown_code_fences",
                    "natural_language_explanation",
                ],
            },
        },
        "platform_options": {
            "context_policy": context_policy,
            "max_context_files": max_context_files,
            "seed": seed,
            "include_docs": include_docs,
        },
    }
    return request


def load_adapter(spec: str) -> Callable[[dict[str, Any]], Any]:
    if ":" not in spec:
        raise ValueError("Adapter spec must be in the form module:function")
    module_name, func_name = spec.split(":", 1)
    module: Any
    module_path = Path(module_name)
    if module_name.endswith(".py") or module_path.exists():
        resolved = module_path.resolve()
        if not resolved.is_file():
            raise ValueError(f"Adapter path is not a file: {resolved}")
        synthetic_name = f"rb_adapter_{resolved.stem}_{abs(hash(str(resolved)))}"
        spec_obj = importlib.util.spec_from_file_location(synthetic_name, resolved)
        if spec_obj is None or spec_obj.loader is None:
            raise ValueError(f"Failed to load adapter module from path: {resolved}")
        module = importlib.util.module_from_spec(spec_obj)
        spec_obj.loader.exec_module(module)
    else:
        module = importlib.import_module(module_name)
    func = getattr(module, func_name, None)
    if func is None or not callable(func):
        raise ValueError(f"Adapter function not found or not callable: {spec}")
    return func


def unwrap_markdown_fence(text: str) -> str:
    stripped = text.strip()
    match = re.fullmatch(r"```[A-Za-z0-9_+-]*\n(?P<body>[\s\S]*?)\n```", stripped)
    if match:
        return match.group("body")
    return text


def looks_like_full_file_output(completion: str, request: Mapping[str, Any]) -> bool:
    target = request.get("target", {})
    prefix = str(target.get("prefix", ""))
    suffix = str(target.get("suffix", ""))
    whole_file = str(target.get("whole_file", ""))
    if completion == whole_file:
        return True
    if prefix and completion.startswith(prefix[: min(120, len(prefix))]):
        return True
    if suffix and completion.endswith(suffix[max(0, len(suffix) - 120) :]):
        return True
    if PLACEHOLDER_LINE in completion:
        return True
    return False


def normalize_adapter_response(
    raw_response: Any,
    request: Mapping[str, Any],
    strict_output: bool,
) -> dict[str, Any]:
    meta: dict[str, Any] = {"raw_response_type": type(raw_response).__name__}

    if isinstance(raw_response, str):
        completion = raw_response
    elif isinstance(raw_response, Mapping):
        if "completion" not in raw_response:
            raise ValueError("Adapter dict response must contain a 'completion' field")
        completion = raw_response["completion"]
        for key, value in raw_response.items():
            if key != "completion":
                meta[key] = value
    else:
        raise ValueError(
            "Adapter must return either a string completion or a dict containing {'completion': ...}"
        )

    if not isinstance(completion, str):
        raise ValueError("The adapter output field 'completion' must be a string")

    normalized = unwrap_markdown_fence(completion)
    if strict_output and normalized != completion:
        raise ValueError("Adapter output must not use markdown code fences")
    if strict_output and looks_like_full_file_output(normalized, request):
        raise ValueError(
            "Adapter output appears to contain the full file or the placeholder; "
            "the adapter must return completion-only code."
        )

    return {
        "completion": normalized,
        "normalized_output": True,
        "meta": meta,
    }


def invoke_adapter(
    adapter: Callable[[dict[str, Any]], Any],
    request: dict[str, Any],
    strict_output: bool,
) -> dict[str, Any]:
    raw = adapter(request)
    return normalize_adapter_response(raw, request=request, strict_output=strict_output)


def parse_args(argv: Sequence[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Standardized black-box completion platform for RealBench."
    )
    parser.add_argument(
        "--adapter",
        type=str,
        default=None,
        help="Adapter function in the form module:function. Omit for request-build-only mode.",
    )
    parser.add_argument(
        "--target-file",
        type=Path,
        required=True,
        help="Target file to be completed. May be a masked .v file or an original source file.",
    )
    parser.add_argument(
        "--repo-root",
        type=Path,
        default=DEFAULT_REPO_ROOT,
        help="RealBench repository root.",
    )
    parser.add_argument(
        "--target-meta",
        type=Path,
        default=None,
        help="Optional explicit metadata path. Defaults to <target-file>.json when present.",
    )
    parser.add_argument(
        "--context-policy",
        type=str,
        default="recursive_upstream",
        choices=[
            "none",
            "direct_upstream",
            "recursive_upstream",
            "direct_downstream",
            "recursive_downstream",
            "upstream_and_downstream",
            "same_system_random",
            "repo_random",
            "all_other_verilog",
            "custom",
        ],
        help=(
            "Which Verilog repository context to provide to the black-box system. "
            "'all_other_verilog' means all other .v files in the same system as the target."
        ),
    )
    parser.add_argument(
        "--custom-context-list",
        type=Path,
        default=None,
        help="Text file used when --context-policy=custom. One path per line.",
    )
    parser.add_argument(
        "--max-context-files",
        type=int,
        default=DEFAULT_MAX_CONTEXT_FILES,
        help="Maximum number of context Verilog files to include. Use 0 to disable truncation.",
    )
    parser.add_argument(
        "--include-docs",
        type=str,
        default="auto",
        choices=["none", "auto", "explicit"],
        help="How to include markdown documentation.",
    )
    parser.add_argument(
        "--doc-path",
        type=Path,
        action="append",
        default=[],
        help="Explicit markdown doc path. Can be repeated.",
    )
    parser.add_argument(
        "--include-images",
        type=str,
        default="auto",
        choices=["none", "auto", "explicit"],
        help="How to include design images/figures.",
    )
    parser.add_argument(
        "--image-path",
        type=Path,
        action="append",
        default=[],
        help="Explicit image path. Can be repeated.",
    )
    parser.add_argument(
        "--seed",
        type=int,
        default=DEFAULT_RANDOM_SEED,
        help="Random seed used by random context policies.",
    )
    parser.add_argument(
        "--request-out",
        type=Path,
        default=None,
        help="Optional path to save the normalized request JSON.",
    )
    parser.add_argument(
        "--response-out",
        type=Path,
        default=None,
        help="Optional path to save the normalized adapter response JSON.",
    )
    parser.add_argument(
        "--print-request",
        action="store_true",
        help="Print request JSON to stdout.",
    )
    parser.add_argument(
        "--print-completion",
        action="store_true",
        help="Print normalized completion-only output to stdout.",
    )
    parser.add_argument(
        "--strict-output",
        action="store_true",
        default=True,
        help="Enforce completion-only output strictly. Enabled by default.",
    )
    parser.add_argument(
        "--no-strict-output",
        dest="strict_output",
        action="store_false",
        help="Relax strict output checks.",
    )
    return parser.parse_args(argv)


def main(argv: Sequence[str] | None = None) -> int:
    args = parse_args(sys.argv[1:] if argv is None else argv)

    repo_root = args.repo_root.resolve()
    target_file = args.target_file.resolve()
    if not target_file.is_file():
        raise FileNotFoundError(f"Missing target file: {target_file}")
    if not repo_root.is_dir():
        raise FileNotFoundError(f"Missing repo root: {repo_root}")

    request = build_request(
        target_file=target_file,
        repo_root=repo_root,
        context_policy=args.context_policy,
        max_context_files=args.max_context_files,
        seed=args.seed,
        include_docs=args.include_docs,
        explicit_doc_paths=[p.resolve() for p in args.doc_path],
        include_images=args.include_images,
        explicit_image_paths=[p.resolve() for p in args.image_path],
        custom_context_list=None if args.custom_context_list is None else args.custom_context_list.resolve(),
        explicit_meta_path=None if args.target_meta is None else args.target_meta.resolve(),
    )

    if args.request_out is not None:
        args.request_out.parent.mkdir(parents=True, exist_ok=True)
        args.request_out.write_text(
            json.dumps(request, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )

    if args.print_request:
        print(json.dumps(request, ensure_ascii=False, indent=2))

    if args.adapter is None:
        return 0

    adapter = load_adapter(args.adapter)
    response = invoke_adapter(adapter=adapter, request=request, strict_output=args.strict_output)

    if args.response_out is not None:
        args.response_out.parent.mkdir(parents=True, exist_ok=True)
        args.response_out.write_text(
            json.dumps(response, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )

    if args.print_completion:
        print(response["completion"], end="")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
