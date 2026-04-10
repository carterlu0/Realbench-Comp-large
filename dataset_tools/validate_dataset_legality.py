#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
from typing import Any

from rb_blackbox_completion_platform import load_target_metadata
from rb_evaluate_blackbox_completion import evaluate_completion_text


DEFAULT_REPO_ROOT = Path(__file__).resolve().parents[1]
def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Validate RealBench dataset legality via blank/oracle black-box experiments."
    )
    parser.add_argument("--dataset-dir", type=Path, required=True)
    parser.add_argument("--repo-root", type=Path, default=DEFAULT_REPO_ROOT)
    parser.add_argument("--stage", type=str, default="stage2", choices=["stage1", "stage2"])
    parser.add_argument("--timeout-sec", type=int, default=300)
    parser.add_argument("--max-tasks", type=int, default=None)
    parser.add_argument("--oracle-disable-fast-path", action="store_true")
    parser.add_argument("--output-json", type=Path, default=None)
    parser.add_argument("--print-summary", action="store_true")
    return parser.parse_args()


def iter_masked_targets(dataset_dir: Path) -> list[Path]:
    out: list[Path] = []
    for path in sorted(dataset_dir.rglob("*.v")):
        if path.name.endswith(".response.v"):
            continue
        if "__mask" not in path.name:
            continue
        out.append(path)
    return out


def evaluate_group(
    *,
    name: str,
    dataset_dir: Path,
    targets: list[Path],
    repo_root: Path,
    stage: str,
    timeout_sec: int,
    completion_provider: Any,
    disable_fast_path: bool,
) -> dict[str, Any]:
    results: list[dict[str, Any]] = []
    old_fast_path = os.environ.get("REALBENCH_DISABLE_FAST_PATH_SUCCESS")
    try:
        if disable_fast_path:
            os.environ["REALBENCH_DISABLE_FAST_PATH_SUCCESS"] = "1"
        else:
            os.environ.pop("REALBENCH_DISABLE_FAST_PATH_SUCCESS", None)

        for target_file in targets:
            target_meta = load_target_metadata(target_file, explicit_meta_path=None)
            masked_items = list(target_meta.get("masked", []))
            answer = str(masked_items[0].get("answer", "")) if masked_items else ""
            completion = completion_provider(answer)
            result = evaluate_completion_text(
                target_file=target_file,
                completion=completion,
                response_meta={"validation_group": name},
                response_path=None,
                repo_root=repo_root,
                stage=stage,
                timeout_sec=timeout_sec,
                output_json=None,
                stitched_out=None,
            )
            result["target_relpath"] = str(target_file.resolve().relative_to(dataset_dir.resolve()).as_posix())
            results.append(result)
    finally:
        if old_fast_path is None:
            os.environ.pop("REALBENCH_DISABLE_FAST_PATH_SUCCESS", None)
        else:
            os.environ["REALBENCH_DISABLE_FAST_PATH_SUCCESS"] = old_fast_path

    total = len(results)
    em_pass = sum(int(r.get("text_metrics", {}).get("em", 0)) for r in results)
    es_avg = sum(float(r.get("text_metrics", {}).get("es", 0.0) or 0.0) for r in results) / total if total else 0.0
    func_correct = sum(int(r.get("func_correct", 0) or 0) for r in results)
    syntax_pass = sum(int(r.get("syntax", 0) or 0) for r in results)
    final_success = sum(1 for r in results if str(r.get("final_decision")) == "success")
    fast_match_pass = sum(1 for r in results if bool(r.get("fast_match", {}).get("matched", False)))

    return {
        "name": name,
        "total": total,
        "em_pass": em_pass,
        "em_percent": 100.0 * em_pass / total if total else 0.0,
        "es_percent": es_avg,
        "func_correct": func_correct,
        "func_percent": 100.0 * func_correct / total if total else 0.0,
        "syntax_pass": syntax_pass,
        "syntax_percent": 100.0 * syntax_pass / total if total else 0.0,
        "final_success": final_success,
        "final_success_percent": 100.0 * final_success / total if total else 0.0,
        "fast_match_pass": fast_match_pass,
        "results": results,
    }


def summarize_failures(results: list[dict[str, Any]], *, expect_success: bool, limit: int = 20) -> list[dict[str, Any]]:
    failures: list[dict[str, Any]] = []
    for result in results:
        succeeded = str(result.get("final_decision")) == "success"
        if succeeded == expect_success:
            continue
        failures.append(
            {
                "target_relpath": result.get("target_relpath"),
                "em": int(result.get("text_metrics", {}).get("em", 0) or 0),
                "es": float(result.get("text_metrics", {}).get("es", 0.0) or 0.0),
                "syntax": int(result.get("syntax", 0) or 0),
                "function": int(result.get("function", 0) or 0),
                "func_correct": int(result.get("func_correct", 0) or 0),
                "fast_match": bool(result.get("fast_match", {}).get("matched", False)),
                "decision_path": result.get("decision_path", []),
                "syntax_info": result.get("syntax_info"),
                "function_info": result.get("function_info"),
            }
        )
        if len(failures) >= limit:
            break
    return failures


def main() -> int:
    args = parse_args()
    dataset_dir = args.dataset_dir.resolve()
    repo_root = args.repo_root.resolve()
    if not dataset_dir.is_dir():
        raise FileNotFoundError(f"Missing dataset dir: {dataset_dir}")
    targets = iter_masked_targets(dataset_dir)
    if args.max_tasks is not None:
        targets = targets[: args.max_tasks]

    blank_summary = evaluate_group(
        name="blank",
        dataset_dir=dataset_dir,
        targets=targets,
        repo_root=repo_root,
        stage=args.stage,
        timeout_sec=args.timeout_sec,
        completion_provider=lambda answer: "",
        disable_fast_path=False,
    )
    oracle_summary = evaluate_group(
        name="oracle",
        dataset_dir=dataset_dir,
        targets=targets,
        repo_root=repo_root,
        stage=args.stage,
        timeout_sec=args.timeout_sec,
        completion_provider=lambda answer: answer,
        disable_fast_path=args.oracle_disable_fast_path,
    )

    blank_expect_zero = (
        blank_summary["em_pass"] == 0
        and blank_summary["func_correct"] == 0
        and blank_summary["final_success"] == 0
    )
    oracle_expect_full = (
        oracle_summary["em_pass"] == oracle_summary["total"]
        and oracle_summary["syntax_pass"] == oracle_summary["total"]
        and oracle_summary["func_correct"] == oracle_summary["total"]
        and oracle_summary["final_success"] == oracle_summary["total"]
    )

    summary = {
        "dataset_dir": str(dataset_dir),
        "repo_root": str(repo_root),
        "stage": args.stage,
        "timeout_sec": args.timeout_sec,
        "oracle_disable_fast_path": args.oracle_disable_fast_path,
        "verdict": {
            "blank_should_score_zero": blank_expect_zero,
            "oracle_should_score_full": oracle_expect_full,
            "dataset_legality_passed": blank_expect_zero and oracle_expect_full,
        },
        "failure_examples": {
            "blank_unexpected_successes": summarize_failures(blank_summary["results"], expect_success=False),
            "oracle_unexpected_failures": summarize_failures(oracle_summary["results"], expect_success=True),
        },
        "groups": [blank_summary, oracle_summary],
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
