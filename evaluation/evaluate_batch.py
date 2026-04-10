#!/usr/bin/env python3
"""
Batch evaluator for black-box completion responses on a masked RealBench dataset.

This script reuses `rb_evaluate_blackbox_completion.py` as the per-sample
evaluation core and adds:

  - dataset-level response discovery
  - optional skipping of missing responses
  - stitched DUT output organization
  - aggregate metrics and summary report generation

Response discovery expects a directory that mirrors the dataset tree layout.
For a target such as:

  masked_units_xxx/e203_hbirdv2/e203_exu_alu/e203_exu_alu__mask0001.v

the batch evaluator searches under `response_dir` for, in order:

  e203_hbirdv2/e203_exu_alu/e203_exu_alu__mask0001.json
  e203_hbirdv2/e203_exu_alu/e203_exu_alu__mask0001.txt
  e203_hbirdv2/e203_exu_alu/e203_exu_alu__mask0001.response.json
  e203_hbirdv2/e203_exu_alu/e203_exu_alu__mask0001.response.txt

It can also consume an explicit response manifest:

  {
    "responses": {
      "e203_hbirdv2/e203_exu_alu/e203_exu_alu__mask0001.v": "/abs/or/rel/path/to/response.json"
    }
  }
"""

from __future__ import annotations

import argparse
import json
from collections import Counter
from copy import deepcopy
from pathlib import Path
from typing import Any

from rb_evaluate_blackbox_completion import (
    compute_text_metrics,
    evaluate_completion_text,
    evaluate_one_completion,
    read_completion_candidates_from_response,
)
from rb_blackbox_completion_platform import load_target_metadata


DEFAULT_REPO_ROOT = Path(__file__).resolve().parents[1]


def iter_masked_targets(dataset_dir: Path) -> list[Path]:
    out: list[Path] = []
    for path in sorted(dataset_dir.rglob("*.v")):
        if path.name.endswith(".response.v"):
            continue
        if "__mask" not in path.name:
            continue
        out.append(path)
    return out


def load_manifest(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def rel_dataset_path(path: Path, dataset_dir: Path) -> str:
    return str(path.resolve().relative_to(dataset_dir.resolve()).as_posix())


def resolve_response_for_target(
    target_file: Path,
    dataset_dir: Path,
    response_dir: Path | None,
    response_manifest: dict[str, Any] | None,
) -> Path | None:
    rel = Path(rel_dataset_path(target_file, dataset_dir))

    if response_manifest is not None:
        responses = response_manifest.get("responses", {})
        raw = responses.get(str(rel.as_posix()))
        if raw is not None:
            candidate = Path(str(raw))
            if not candidate.is_absolute():
                candidate = (
                    response_dir / candidate
                    if response_dir is not None
                    else dataset_dir / candidate
                )
            return candidate.resolve()

    if response_dir is None:
        return None

    base = response_dir / rel
    candidates = [
        base.with_suffix(".json"),
        base.with_suffix(".txt"),
        base.with_name(base.stem + ".response.json"),
        base.with_name(base.stem + ".response.txt"),
    ]
    for candidate in candidates:
        if candidate.is_file():
            return candidate.resolve()
    return None


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Batch evaluate black-box completion responses on a masked RealBench dataset."
    )
    parser.add_argument(
        "--dataset-dir",
        type=Path,
        required=True,
        help="Masked dataset directory to evaluate against.",
    )
    parser.add_argument(
        "--response-dir",
        type=Path,
        default=None,
        help="Directory containing black-box responses, typically mirroring dataset layout.",
    )
    parser.add_argument(
        "--response-manifest",
        type=Path,
        default=None,
        help="Optional JSON mapping from dataset-relative target paths to response paths.",
    )
    parser.add_argument(
        "--repo-root",
        type=Path,
        default=DEFAULT_REPO_ROOT,
        help="RealBench repository root.",
    )
    parser.add_argument(
        "--stage",
        type=str,
        default="stage2",
        choices=["stage1", "stage2"],
        help="Verification stage.",
    )
    parser.add_argument(
        "--timeout-sec",
        type=int,
        default=300,
        help="Per-sample simulation timeout.",
    )
    parser.add_argument(
        "--max-tasks",
        type=int,
        default=None,
        help="Optional cap on the number of dataset samples to evaluate.",
    )
    parser.add_argument(
        "--allow-missing-responses",
        action="store_true",
        help="Skip samples that have no discovered response artifact.",
    )
    parser.add_argument(
        "--stitched-dir",
        type=Path,
        default=None,
        help="Optional root dir to save stitched DUT files.",
    )
    parser.add_argument(
        "--per-sample-json-dir",
        type=Path,
        default=None,
        help="Optional root dir to save per-sample evaluation JSON files.",
    )
    parser.add_argument(
        "--output-json",
        type=Path,
        default=None,
        help="Optional batch summary JSON output path.",
    )
    parser.add_argument(
        "--print-summary",
        action="store_true",
        help="Print summary JSON to stdout.",
    )
    parser.add_argument(
        "--k-values",
        type=int,
        nargs="+",
        default=[1],
        help="Compute EM@k and func@k for the provided k values.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()

    dataset_dir = args.dataset_dir.resolve()
    repo_root = args.repo_root.resolve()
    response_dir = None if args.response_dir is None else args.response_dir.resolve()
    response_manifest = (
        None
        if args.response_manifest is None
        else load_manifest(args.response_manifest.resolve())
    )

    if not dataset_dir.is_dir():
        raise FileNotFoundError(f"Missing dataset dir: {dataset_dir}")
    if response_dir is None and response_manifest is None:
        raise ValueError("At least one of --response-dir or --response-manifest must be provided")

    targets = iter_masked_targets(dataset_dir)
    if args.max_tasks is not None:
        targets = targets[: args.max_tasks]
    k_values = sorted({k for k in args.k_values if int(k) > 0})
    if not k_values:
        k_values = [1]

    results: list[dict[str, Any]] = []
    skipped_missing: list[dict[str, Any]] = []
    result_by_rel: dict[str, dict[str, Any]] = {}
    response_path_by_rel: dict[str, Path] = {}

    for idx, target_file in enumerate(targets, start=1):
        response_path = resolve_response_for_target(
            target_file=target_file,
            dataset_dir=dataset_dir,
            response_dir=response_dir,
            response_manifest=response_manifest,
        )
        rel = rel_dataset_path(target_file, dataset_dir)

        if response_path is None or not response_path.exists():
            if args.allow_missing_responses:
                skipped_missing.append(
                    {
                        "index": idx,
                        "target_file": str(target_file),
                        "target_relpath": rel,
                        "reason": "missing_response",
                    }
                )
                continue
            raise FileNotFoundError(
                f"No response artifact found for target {target_file} "
                f"(dataset relative path: {rel})"
            )

        stitched_out = None
        if args.stitched_dir is not None:
            stitched_out = (args.stitched_dir.resolve() / rel)

        per_sample_json = None
        if args.per_sample_json_dir is not None:
            per_sample_json = (
                args.per_sample_json_dir.resolve() / rel
            ).with_suffix(".eval.json")

        result = evaluate_one_completion(
            target_file=target_file,
            response_path=response_path,
            repo_root=repo_root,
            stage=args.stage,
            timeout_sec=args.timeout_sec,
            output_json=per_sample_json,
            stitched_out=stitched_out,
        )
        result["batch_index"] = idx
        result["target_relpath"] = rel
        results.append(result)
        result_by_rel[rel] = result
        response_path_by_rel[rel] = response_path

    total = len(results)
    syntax_pass = sum(1 for r in results if int(r.get("syntax", 0)) == 1)
    function_pass = sum(1 for r in results if int(r.get("function", 0)) == 1)
    effective_function_pass = sum(1 for r in results if int(r.get("effective_function", 0)) == 1)
    final_success = sum(1 for r in results if str(r.get("final_decision")) == "success")
    fast_match_pass = sum(1 for r in results if bool(r.get("fast_match", {}).get("matched", False)))
    em_pass = sum(1 for r in results if int(r.get("text_metrics", {}).get("em", 0)) == 1)
    es_avg = (
        sum(float(r.get("text_metrics", {}).get("es", 0.0)) for r in results) / total
        if total > 0 else 0.0
    )
    func_correct = sum(1 for r in results if int(r.get("func_correct", 0)) == 1)

    func_eval_cache: dict[tuple[str, int], bool] = {}
    em_at_k: dict[str, float] = {}
    func_at_k: dict[str, float] = {}
    for k in k_values:
        em_hits = 0
        func_hits = 0
        for target_file in targets:
            rel = rel_dataset_path(target_file, dataset_dir)
            response_path = response_path_by_rel.get(rel)
            if response_path is None:
                continue

            candidates, response_meta = read_completion_candidates_from_response(response_path)
            candidates = candidates[:k]
            target_meta = load_target_metadata(target_file, explicit_meta_path=None)
            masked_items = list(target_meta.get("masked", []))
            reference_answer = str(masked_items[0].get("answer", "")) if masked_items else ""

            if any(int(compute_text_metrics(candidate, reference_answer)["em"]) == 1 for candidate in candidates):
                em_hits += 1

            func_hit = False
            for candidate_index, candidate in enumerate(candidates):
                cache_key = (rel, candidate_index)
                if cache_key not in func_eval_cache:
                    if candidate_index == 0 and rel in result_by_rel:
                        func_eval_cache[cache_key] = str(result_by_rel[rel].get("final_decision")) == "success"
                    else:
                        candidate_meta = deepcopy(response_meta)
                        candidate_meta["candidate_index"] = candidate_index
                        candidate_result = evaluate_completion_text(
                            target_file=target_file,
                            completion=candidate,
                            response_meta=candidate_meta,
                            response_path=response_path,
                            repo_root=repo_root,
                            stage=args.stage,
                            timeout_sec=args.timeout_sec,
                            output_json=None,
                            stitched_out=None,
                        )
                        func_eval_cache[cache_key] = str(candidate_result.get("final_decision")) == "success"
                if func_eval_cache[cache_key]:
                    func_hit = True
                    break

            if func_hit:
                func_hits += 1

        em_at_k[str(k)] = 0.0 if total == 0 else (em_hits / total) * 100.0
        func_at_k[str(k)] = 0.0 if total == 0 else (func_hits / total) * 100.0

    summary = {
        "dataset_dir": str(dataset_dir),
        "response_dir": None if response_dir is None else str(response_dir),
        "response_manifest": None
        if args.response_manifest is None
        else str(args.response_manifest.resolve()),
        "repo_root": str(repo_root),
        "stage": args.stage,
        "timeout_sec": args.timeout_sec,
        "total_discovered_targets": len(targets),
        "evaluated_tasks": total,
        "skipped_missing_response_count": len(skipped_missing),
        "skipped_missing_responses": skipped_missing,
        "em_pass": em_pass,
        "em_percent": 0.0 if total == 0 else (em_pass / total) * 100.0,
        "es_percent": es_avg,
        "syntax_pass": syntax_pass,
        "function_pass_raw": function_pass,
        "function_pass_effective": effective_function_pass,
        "final_success": final_success,
        "func_correct": func_correct,
        "func_percent": 0.0 if total == 0 else (func_correct / total) * 100.0,
        "em_at_k": em_at_k,
        "func_at_k": func_at_k,
        "single_test_score": 0.0 if total == 0 else (final_success / total) * 100.0,
        "fast_match_pass": fast_match_pass,
        "fast_match_rate": 0.0 if total == 0 else (fast_match_pass / total) * 100.0,
        "final_decision_counts": dict(
            sorted(Counter(str(r.get("final_decision", "unknown")) for r in results).items())
        ),
        "decision_path_terminal_counts": dict(
            sorted(
                Counter(
                    (
                        r.get("decision_path", [])[-1]
                        if isinstance(r.get("decision_path"), list) and r.get("decision_path")
                        else "none"
                    )
                    for r in results
                ).items()
            )
        ),
        "results": results,
    }

    if args.output_json is not None:
        out = args.output_json.resolve()
        out.parent.mkdir(parents=True, exist_ok=True)
        out.write_text(json.dumps(summary, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    if args.print_summary:
        print(json.dumps(summary, ensure_ascii=False, indent=2))

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
