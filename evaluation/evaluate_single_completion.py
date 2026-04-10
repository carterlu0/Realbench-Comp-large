#!/usr/bin/env python3
"""
Evaluate a black-box completion result on a single RealBench masked sample.

Evaluation flow:

1. Read completion-only output from a black-box response artifact.
2. Stitch the completion back into the masked target file.
3. Fast-path check:
   - exact match against the reference answer, or
   - token-equivalent match against the reference answer
   If this passes, mark success immediately and skip simulation.
4. Otherwise run syntax + function verification.
5. If syntax fails, mark failure immediately.
6. If function fails, mark failure immediately.
7. If function passes, mark success.

This script is intended to consume outputs produced by a black-box adapter that
already passed the output-shape checks in `rb_blackbox_completion_platform.py`.
"""

from __future__ import annotations

import argparse
import json
import os
import sys
from copy import deepcopy
from pathlib import Path
from typing import Any

from pyverilog.vparser.lexer import VerilogLexer

RTLC2_SRC = Path(__file__).resolve().parents[2] / "RTLC^2" / "src"
if RTLC2_SRC.is_dir() and str(RTLC2_SRC) not in sys.path:
    sys.path.insert(0, str(RTLC2_SRC))

from utils import edit_similarity_score, functional_equivalence, functional_equivalence_detail

import run_verify_reference as verify_ref
from rb_blackbox_completion_platform import (
    infer_target_identity,
    load_target_metadata,
    split_target_by_placeholder,
)


DEFAULT_REPO_ROOT = Path(__file__).resolve().parents[1]


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="ignore")


def load_json(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def read_completion_from_response(response_path: Path) -> tuple[str, dict[str, Any]]:
    text = read_text(response_path)
    meta: dict[str, Any] = {"response_path": str(response_path.resolve())}
    try:
        obj = json.loads(text)
    except Exception:
        return text, meta

    if isinstance(obj, dict) and "completion" in obj:
        completion = obj["completion"]
        if not isinstance(completion, str):
            raise ValueError("response JSON field 'completion' must be a string")
        for key, value in obj.items():
            if key != "completion":
                meta[key] = value
        return completion, meta

    if isinstance(obj, str):
        return obj, meta

    raise ValueError(
        "Unsupported response artifact. Expected either raw text or JSON with a 'completion' field."
    )


def _normalize_candidate(candidate: Any) -> str:
    if isinstance(candidate, str):
        return candidate
    if isinstance(candidate, dict) and "completion" in candidate and isinstance(candidate["completion"], str):
        return candidate["completion"]
    raise ValueError("Unsupported candidate format; expected string or {'completion': str}")


def _extract_candidates_from_response_obj(obj: dict[str, Any]) -> list[str]:
    if "candidates" in obj and isinstance(obj["candidates"], list):
        return [_normalize_candidate(item) for item in obj["candidates"]]
    if "completions" in obj and isinstance(obj["completions"], list):
        return [_normalize_candidate(item) for item in obj["completions"]]
    meta_obj = obj.get("meta")
    if isinstance(meta_obj, dict):
        if "candidates" in meta_obj and isinstance(meta_obj["candidates"], list):
            return [_normalize_candidate(item) for item in meta_obj["candidates"]]
        if "completions" in meta_obj and isinstance(meta_obj["completions"], list):
            return [_normalize_candidate(item) for item in meta_obj["completions"]]
    if "completion" in obj:
        return [_normalize_candidate(obj["completion"])]
    return []


def read_completion_candidates_from_response(response_path: Path) -> tuple[list[str], dict[str, Any]]:
    text = read_text(response_path)
    meta: dict[str, Any] = {"response_path": str(response_path.resolve())}
    try:
        obj = json.loads(text)
    except Exception:
        return [text], meta

    if isinstance(obj, str):
        return [obj], meta

    if isinstance(obj, dict):
        candidates = _extract_candidates_from_response_obj(obj)
        if not candidates:
            raise ValueError(
                "Unsupported response artifact. Expected 'completion', 'completions', or 'candidates'."
            )

        for key, value in obj.items():
            if key not in {"completion", "completions", "candidates"}:
                meta[key] = value
        meta["candidate_count"] = len(candidates)
        return candidates, meta

    raise ValueError(
        "Unsupported response artifact. Expected raw text, JSON string, or JSON object with completion fields."
    )


def tokenize_verilog_snippet(text: str) -> list[tuple[str, str]]:
    def err(msg: str, line: int, column: int | None = None) -> None:
        location = f"<snippet>:{line}" if column is None else f"<snippet>:{line}:{column}"
        raise SyntaxError(f"{location}: {msg}")

    lexer = VerilogLexer(err)
    lexer.build()
    lexer.reset_lineno()
    lexer.input(text)
    tokens: list[tuple[str, str]] = []
    while True:
        tok = lexer.token()
        if tok is None:
            break
        tokens.append((str(tok.type), str(tok.value)))
    return tokens


def _strip_outer_begin_end_tokens(tokens: list[tuple[str, str]]) -> list[tuple[str, str]]:
    if len(tokens) >= 2 and tokens[0] == ("BEGIN", "begin") and tokens[-1] == ("END", "end"):
        depth = 0
        for index, token in enumerate(tokens):
            token_type, _ = token
            if token_type == "BEGIN":
                depth += 1
            elif token_type == "END":
                depth -= 1
                if depth == 0 and index != len(tokens) - 1:
                    return tokens
        if depth == 0:
            return tokens[1:-1]
    return tokens


def normalize_verilog_tokens_for_em(text: str) -> tuple[list[tuple[str, str]] | None, str | None]:
    try:
        tokens = tokenize_verilog_snippet(text)
    except Exception as exc:
        return None, str(exc)

    filtered = [token for token in tokens if token[0] not in {"COMMENT1", "COMMENT2", "DIRECTIVE"}]
    filtered = _strip_outer_begin_end_tokens(filtered)
    return filtered, None


def fast_answer_equivalence(completion: str, reference_answer: str) -> dict[str, Any]:
    if completion == reference_answer:
        return {
            "matched": True,
            "method": "exact_text",
            "exact_text": True,
            "token_equivalent": True,
        }

    token_equivalent = False
    token_error: str | None = None
    try:
        token_equivalent = tokenize_verilog_snippet(completion) == tokenize_verilog_snippet(
            reference_answer
        )
    except Exception as exc:
        token_error = str(exc)

    return {
        "matched": token_equivalent,
        "method": "token_equivalent" if token_equivalent else "none",
        "exact_text": False,
        "token_equivalent": token_equivalent,
        "token_error": token_error,
    }


def compute_text_metrics(completion: str, reference_answer: str) -> dict[str, Any]:
    detail = functional_equivalence_detail(completion, reference_answer)
    exact_text = completion.strip() == reference_answer.strip()
    normalized_completion_tokens, normalized_completion_error = normalize_verilog_tokens_for_em(completion)
    normalized_reference_tokens, normalized_reference_error = normalize_verilog_tokens_for_em(reference_answer)
    normalized_exact = (
        normalized_completion_tokens is not None
        and normalized_reference_tokens is not None
        and normalized_completion_tokens == normalized_reference_tokens
    )
    em_pass = exact_text or normalized_exact
    es_score = float(edit_similarity_score([completion], [reference_answer]))
    return {
        "em": 1 if em_pass else 0,
        "em_percent": 100.0 if em_pass else 0.0,
        "es": es_score,
        "equivalent": bool(detail.get("equivalent", False)),
        "reason": str(detail.get("reason", "unknown")),
        "exact_text": exact_text,
        "normalized_exact": normalized_exact,
        "normalized_completion_token_count": None if normalized_completion_tokens is None else len(normalized_completion_tokens),
        "normalized_reference_token_count": None if normalized_reference_tokens is None else len(normalized_reference_tokens),
        "normalized_completion_error": normalized_completion_error,
        "normalized_reference_error": normalized_reference_error,
        "completion_chars": len(completion),
        "reference_chars": len(reference_answer),
    }


def should_skip_fast_path() -> bool:
    return os.environ.get("REALBENCH_DISABLE_FAST_PATH_SUCCESS", "").strip().lower() in {
        "1",
        "true",
        "yes",
        "on",
    }


def stitch_completion_into_masked_file(masked_code: str, completion: str) -> tuple[str, dict[str, Any]]:
    prefix, suffix, has_hole = split_target_by_placeholder(masked_code)
    if not has_hole:
        raise ValueError("Target file does not contain the expected placeholder hole")
    stitched = prefix + completion + suffix
    return stitched, {
        "has_explicit_hole": has_hole,
        "prefix_length": len(prefix),
        "suffix_length": len(suffix),
        "stitched_length": len(stitched),
    }


def find_dataset_root(target_file: Path, repo_root: Path) -> Path | None:
    current = target_file.resolve().parent
    repo_root_resolved = repo_root.resolve()
    while True:
        if (current / "dataset_manifest.json").exists() or (
            current / "excluded_forever.json"
        ).exists():
            return current
        if current == repo_root_resolved or current.parent == current:
            return None
        current = current.parent


def build_task_info(target_file: Path, repo_root: Path) -> dict[str, Any]:
    identity = infer_target_identity(target_file, repo_root)
    if identity.system is None or identity.task is None:
        raise ValueError(
            "Cannot infer system/task from target path. Expected a path preserving <system>/<task>/..."
        )

    template_dir = repo_root / identity.system / identity.task / "verification"
    if not template_dir.is_dir():
        raise FileNotFoundError(f"Missing verification template dir: {template_dir}")

    return {
        "system": identity.system,
        "task": identity.task,
        "variant": identity.variant,
        "task_display": (
            identity.task if identity.variant is None else f"{identity.task}[{identity.variant}]"
        ),
        "full_task_display": verify_ref.full_task_display(
            identity.system,
            identity.task if identity.variant is None else f"{identity.task}[{identity.variant}]",
        ),
        "template_dir": str(template_dir),
        "top_filename": f"{identity.task}_top.sv",
    }


def evaluate_one_completion(
    target_file: Path,
    response_path: Path,
    repo_root: Path,
    stage: str,
    timeout_sec: int,
    output_json: Path | None,
    stitched_out: Path | None,
) -> dict[str, Any]:
    completions, response_meta = read_completion_candidates_from_response(response_path)
    completion = completions[0] if completions else ""
    return evaluate_completion_text(
        target_file=target_file,
        completion=completion,
        response_meta=response_meta,
        response_path=response_path,
        repo_root=repo_root,
        stage=stage,
        timeout_sec=timeout_sec,
        output_json=output_json,
        stitched_out=stitched_out,
    )


def evaluate_completion_text(
    target_file: Path,
    completion: str,
    response_meta: dict[str, Any],
    response_path: Path | None,
    repo_root: Path,
    stage: str,
    timeout_sec: int,
    output_json: Path | None,
    stitched_out: Path | None,
) -> dict[str, Any]:
    masked_code = read_text(target_file)
    target_meta = load_target_metadata(target_file, explicit_meta_path=None)

    masked_items = list(target_meta.get("masked", []))
    if len(masked_items) != 1:
        raise ValueError(
            "Current evaluator expects exactly one masked item in the target metadata"
        )
    reference_answer = str(masked_items[0].get("answer", ""))
    if not reference_answer:
        raise ValueError("Reference answer missing from target metadata")

    fast_match = fast_answer_equivalence(completion, reference_answer)
    text_metrics = compute_text_metrics(completion, reference_answer)
    stitched_code, stitched_meta = stitch_completion_into_masked_file(masked_code, completion)

    if stitched_out is not None:
        stitched_out.parent.mkdir(parents=True, exist_ok=True)
        stitched_out.write_text(stitched_code, encoding="utf-8")

    task_info = build_task_info(target_file, repo_root)
    dataset_root = find_dataset_root(target_file, repo_root)
    dataset_policy = verify_ref.load_dataset_policy(
        str(dataset_root) if dataset_root is not None else str(target_file.parent),
        enabled=dataset_root is not None,
    )
    result: dict[str, Any] = {
        "target_file": str(target_file.resolve()),
        "response_path": None if response_path is None else str(response_path.resolve()),
        "repo_root": str(repo_root.resolve()),
        "stage": stage,
        "task": task_info,
        "dataset_root": None if dataset_root is None else str(dataset_root.resolve()),
        "dataset_policy_enabled": bool(dataset_policy.get("enabled")),
        "response_meta": response_meta,
        "target_metadata_summary": {
            "masked_type": masked_items[0].get("type"),
            "masked_kind": masked_items[0].get("kind"),
            "masked_span_lines": masked_items[0].get("span_lines"),
            "variant_id": target_meta.get("variant_id"),
        },
        "text_metrics": text_metrics,
        "fast_match": fast_match,
        "stitched_meta": stitched_meta,
        "syntax": 0,
        "function": 0,
        "effective_function": 0,
        "func_correct": 0,
        "func_percent": 0.0,
        "final_decision": "failure",
        "decision_path": [],
        "single_test_score": 0.0,
    }

    if fast_match["matched"] and not should_skip_fast_path():
        result["syntax"] = 1
        result["function"] = 1
        result["effective_function"] = 1
        result["func_correct"] = 1
        result["func_percent"] = 100.0
        result["final_decision"] = "success"
        result["decision_path"] = ["fast_answer_equivalence_pass"]
        result["single_test_score"] = 100.0
        if output_json is not None:
            output_json.parent.mkdir(parents=True, exist_ok=True)
            output_json.write_text(
                json.dumps(result, ensure_ascii=False, indent=2) + "\n",
                encoding="utf-8",
            )
        return result
    elif fast_match["matched"]:
        decision_path = ["fast_answer_equivalence_pass_but_forced_full_evaluation"]
    else:
        decision_path = ["fast_answer_equivalence_fail"]
    stitched_for_verify, injected_macros = verify_ref.apply_stage_macros(
        stitched_code, str(task_info["task"]), stage
    )
    task_make_env = {k: str(v) for k, v in verify_ref.CONFIG_MAKE_ENV.items()}
    task_make_env.update(verify_ref.TASK_MAKE_ENV_OVERRIDES.get(str(task_info["task"]), {}))

    syntax, function, syntax_info, function_info = verify_ref.run_testbench_once(
        code=stitched_for_verify,
        template_dir=str(task_info["template_dir"]),
        top_filename=str(task_info["top_filename"]),
        make_env=task_make_env,
        segfault_retries=int(verify_ref.CONFIG_SEGFAULT_RETRIES),
        timeout_sec=timeout_sec,
    )
    result["syntax"] = syntax
    result["function"] = function
    result["syntax_info"] = syntax_info
    result["function_info"] = function_info
    result["injected_macros"] = injected_macros

    if syntax != 1:
        decision_path.append("syntax_fail")
        result["effective_function"] = 0
        result["func_correct"] = 0
        result["func_percent"] = 0.0
        result["final_decision"] = "failure"
        result["decision_path"] = decision_path
        result["single_test_score"] = 0.0
        if output_json is not None:
            output_json.parent.mkdir(parents=True, exist_ok=True)
            output_json.write_text(
                json.dumps(result, ensure_ascii=False, indent=2) + "\n",
                encoding="utf-8",
            )
        return result

    decision_path.append("syntax_pass")

    if function != 1:
        decision_path.append("function_fail")
        result["effective_function"] = 0
        result["func_correct"] = 0
        result["func_percent"] = 0.0
        result["final_decision"] = "failure"
        result["decision_path"] = decision_path
        result["single_test_score"] = 0.0
        if output_json is not None:
            output_json.parent.mkdir(parents=True, exist_ok=True)
            output_json.write_text(
                json.dumps(result, ensure_ascii=False, indent=2) + "\n",
                encoding="utf-8",
            )
        return result

    decision_path.append("function_pass")
    result["effective_function"] = 1
    result["func_correct"] = 1
    result["func_percent"] = 100.0
    result["final_decision"] = "success"
    result["single_test_score"] = 100.0

    result["decision_path"] = decision_path

    if output_json is not None:
        output_json.parent.mkdir(parents=True, exist_ok=True)
        output_json.write_text(
            json.dumps(result, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )

    return result


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Evaluate one black-box completion result on a masked RealBench sample."
    )
    parser.add_argument(
        "--target-file",
        type=Path,
        required=True,
        help="Masked target file containing the placeholder.",
    )
    parser.add_argument(
        "--response",
        type=Path,
        required=True,
        help="Black-box response artifact. Supports either raw text or JSON with a 'completion' field.",
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
        default=verify_ref.CONFIG_STAGE,
        choices=["stage1", "stage2"],
        help="Verification stage.",
    )
    parser.add_argument(
        "--timeout-sec",
        type=int,
        default=verify_ref.CONFIG_TIMEOUT_SEC,
        help="Simulation timeout for make all.",
    )
    parser.add_argument(
        "--output-json",
        type=Path,
        default=None,
        help="Optional detailed result JSON output path.",
    )
    parser.add_argument(
        "--stitched-out",
        type=Path,
        default=None,
        help="Optional path to save the stitched complete DUT file.",
    )
    parser.add_argument(
        "--print-result",
        action="store_true",
        help="Print the result JSON to stdout.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    result = evaluate_one_completion(
        target_file=args.target_file.resolve(),
        response_path=args.response.resolve(),
        repo_root=args.repo_root.resolve(),
        stage=args.stage,
        timeout_sec=args.timeout_sec,
        output_json=None if args.output_json is None else args.output_json.resolve(),
        stitched_out=None if args.stitched_out is None else args.stitched_out.resolve(),
    )
    if args.print_result:
        print(json.dumps(result, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
