#!/usr/bin/env python3
"""
RTLC^2 adapter for the Realbench-Comp black-box completion platform.

This adapter connects Realbench-Comp completion requests to the RTLC^2
retrieval-augmented completion pipeline.

Interface contract:
    generate_completion(request: dict) -> str | dict

The request object follows RealBench's rb_completion_request_v1 schema:
    - target.prefix: code before the placeholder
    - target.suffix: code after the placeholder
    - context.verilog_files: same-repository Verilog context files

The adapter:
    1. Extracts prefix/suffix and context from RealBench request
    2. Builds local repository blocks from context files (RealBench provided)
    3. Performs BM25 retrieval within the provided context (local)
    4. Optionally performs external retrieval from RTL-Repo's external corpus
    5. Uses gating mechanism to decide external retrieval necessity
    6. Constructs prompt with retrieved blocks
    7. Calls LLM backend for completion
    8. Returns completion-only code

External retrieval uses the same strategy as RTL-Repo main system:
    - External corpus: RTL-Repo/train
    - Gating: strong/weak/miss based on local retrieval quality
    - File-level coarse-to-fine ranking
    - Multi-channel RRF fusion
"""

from __future__ import annotations

import copy
import importlib
import json
import os
import random
import re
import sys
import time
from collections import Counter
from pathlib import Path
from typing import Any, Callable, Dict, List, Optional, Tuple

# Add RTLC^2 src directory to path
RTLC2_ROOT = Path(__file__).resolve().parents[2] / "RTLC^2"
RTLC2_SRC = RTLC2_ROOT / "src"
if RTLC2_SRC.is_dir():
    sys.path.insert(0, str(RTLC2_SRC))

try:
    from retrieval import bm25 as BM25search


    def convert_logprobs_to_serializable(logprobs_obj):
        if logprobs_obj is None:
            return None

        serializable_content = []
        if hasattr(logprobs_obj, "content") and logprobs_obj.content:
            for token_logprob in logprobs_obj.content:
                token_data = {
                    "token": getattr(token_logprob, "token", None),
                    "logprob": getattr(token_logprob, "logprob", None),
                    "bytes": getattr(token_logprob, "bytes", None),
                }
                top_logprobs_list = []
                if hasattr(token_logprob, "top_logprobs") and token_logprob.top_logprobs:
                    for top_item in token_logprob.top_logprobs:
                        top_data = {
                            "token": getattr(top_item, "token", None),
                            "logprob": getattr(top_item, "logprob", None),
                            "bytes": getattr(top_item, "bytes", None),
                        }
                        top_logprobs_list.append(top_data)
                token_data["top_logprobs"] = top_logprobs_list
                serializable_content.append(token_data)
        return serializable_content
    from common.token_counter import load_backend_token_counter
    from common.text_utils import format_verilog_text, post_process
except ImportError as e:
    print(f"Error: Failed to import RTLC^2 modules: {e}")
    print(f"Make sure RTLC^2/src is accessible at: {RTLC2_SRC}")
    sys.exit(1)

# Try to import LLM backend
try:
    from backends import openai_compatible as LLMload_1
    LLM_BACKEND_AVAILABLE = True
except ImportError:
    LLM_BACKEND_AVAILABLE = False
    print("Warning: LLMload_1 not available, will use mock completion mode.")

try:
    from doc_retrieval import (
        build_doc_chunks,
        build_query_text,
        get_codebert_runtime,
        render_retrieved_doc_lines,
        retrieve_with_bm25 as retrieve_docs_bm25,
        retrieve_with_bm25_then_codebert as retrieve_docs_bm25_then_codebert,
        retrieve_with_codebert as retrieve_docs_codebert,
    )
    DOC_RETRIEVAL_AVAILABLE = True
except ImportError:
    DOC_RETRIEVAL_AVAILABLE = False


# ---------------------------------------------------------------------------
# Configuration (aligned with RTL-Repo main system)
# ---------------------------------------------------------------------------

# Default backend configuration
DEFAULT_BACKEND_CONFIG = {
    "type": "openai_chat_api",
    "api_base": os.environ.get("RTLC2_API_BASE", "https://api.deepseek.com"),
    "api_key": os.environ.get("RTLC2_API_KEY", ""),
    "model_name": "deepseek-chat",
    "temperature": 0.1,
    "client_timeout_seconds": 120,
    "append_suffix_to_prompt": True,
    "chat_fallback": True,
    "max_tokens": 4096,
}

DEFAULT_LOCAL_MODEL_PATH = os.environ.get("RTLC2_LOCAL_MODEL_PATH", "")

OPENAI_OFFICIAL_SUPPORTED_MODELS = [
    "gpt-4.1",
    "gpt-4.1-mini",
    "gpt-4.1-nano",
    "gpt-4o",
    "gpt-4o-mini",
    "gpt-5",
    "gpt-5-mini",
    "gpt-5-nano",
]

# External corpus path (same as RTL-Repo main system)
DEFAULT_EXTERNAL_RETRIEVAL_PATH = str(RTLC2_ROOT / "RTL-Repo" / "train")

DEFAULT_COMPLETION_POSTPROCESS_CONFIG = {
    "enable_clipping": False,
    "enable_dynamic_length_guard": True,
    "dynamic_length_multiplier": 1.8,
}

DEFAULT_FIM_MODE = False


def build_backend_token_counter(backend_config: Dict[str, Any]) -> Any:
    try:
        return load_backend_token_counter(
            backend_name=str(backend_config.get("type", "unknown") or "unknown"),
            backend_config=backend_config,
            default_local_model_path=DEFAULT_LOCAL_MODEL_PATH,
        )
    except Exception:
        return None


def count_prompt_tokens(prompt_text: str, token_counter: Any) -> Tuple[Optional[int], Dict[str, Any]]:
    if token_counter is None:
        return None, {"available": False, "reason": "token_counter_missing"}

    count_fn = getattr(token_counter, "count_text", None)
    summary_fn = getattr(token_counter, "summary", None)
    summary = summary_fn() if callable(summary_fn) else {}
    if not callable(count_fn):
        return None, {"available": False, "reason": "count_text_unavailable", "counter": summary}

    try:
        token_count = count_fn(prompt_text)
    except Exception as exc:
        return None, {"available": False, "reason": f"count_failed: {exc}", "counter": summary}

    if token_count is None:
        return None, {"available": False, "reason": "counter_returned_none", "counter": summary}

    return int(token_count), {"available": True, "counter": summary}


def _first_non_empty_env(*names: str) -> str | None:
    for name in names:
        value = os.environ.get(name)
        if value is not None and str(value).strip():
            return str(value)
    return None


def _resolve_provider_defaults(provider_name: str) -> Dict[str, str]:
    provider = str(provider_name or "").strip().lower()
    if provider == "deepseek":
        return {
            "type": "openai_chat_api",
            "api_base": "https://api.deepseek.com",
            "model_name": "deepseek-chat",
            "chat_fallback": True,
        }
    if provider == "openai":
        return {
            "type": "openai_responses_api",
            "api_base": "https://api.openai.com/v1",
            "model_name": "gpt-4.1-mini",
            "chat_fallback": False,
        }
    return {}


def _coerce_backend_output_text(value: Any) -> Tuple[str, Dict[str, Any]]:
    """Best-effort text extraction for multiple backend return shapes."""
    diagnostics: Dict[str, Any] = {
        "raw_type": type(value).__name__,
        "used_path": "none",
        "raw_preview": "",
    }

    def _preview(text: Any) -> str:
        if text is None:
            return ""
        rendered = str(text)
        rendered = rendered.replace("\r", "\\r").replace("\n", "\\n")
        return rendered[:200]

    def _collect_text_from_sequence(items: List[Any]) -> str:
        parts: List[str] = []
        for item in items:
            if isinstance(item, str):
                if item:
                    parts.append(item)
                continue
            if isinstance(item, dict):
                text, _ = _from_mapping(item)
                if text:
                    parts.append(text)
                    continue
                nested_content = item.get("content")
                if isinstance(nested_content, list):
                    nested_text = _collect_text_from_sequence(nested_content)
                    if nested_text:
                        parts.append(nested_text)
                continue

            text, _ = _from_object(item)
            if text:
                parts.append(text)
        return "\n".join(part for part in parts if part)

    def _from_mapping(mapping: Dict[str, Any]) -> Tuple[str, str]:
        direct_keys = (
            "output_text",
            "text",
            "content",
            "response",
            "output",
            "completion",
            "generated_text",
        )
        for key in direct_keys:
            candidate = mapping.get(key)
            if isinstance(candidate, str) and candidate.strip():
                return candidate, f"dict.{key}"

        output_items = mapping.get("output")
        if isinstance(output_items, list):
            text = _collect_text_from_sequence(output_items)
            if text.strip():
                return text, "dict.output[]"

        choices = mapping.get("choices")
        if isinstance(choices, list):
            text = _collect_text_from_sequence(choices)
            if text.strip():
                return text, "dict.choices[]"

        return "", ""

    def _from_object(obj: Any) -> Tuple[str, str]:
        direct_attrs = (
            "output_text",
            "text",
            "content",
            "response",
            "output",
            "completion",
            "generated_text",
        )
        for attr in direct_attrs:
            if not hasattr(obj, attr):
                continue
            candidate = getattr(obj, attr)
            if isinstance(candidate, str) and candidate.strip():
                return candidate, f"attr.{attr}"
            if isinstance(candidate, list):
                text = _collect_text_from_sequence(candidate)
                if text.strip():
                    return text, f"attr.{attr}[]"

        model_dump = getattr(obj, "model_dump", None)
        if callable(model_dump):
            try:
                dumped = model_dump()
            except Exception:
                dumped = None
            if isinstance(dumped, dict):
                text, path = _from_mapping(dumped)
                if text.strip():
                    return text, f"model_dump.{path}"

        to_dict = getattr(obj, "to_dict", None)
        if callable(to_dict):
            try:
                dumped = to_dict()
            except Exception:
                dumped = None
            if isinstance(dumped, dict):
                text, path = _from_mapping(dumped)
                if text.strip():
                    return text, f"to_dict.{path}"

        return "", ""

    diagnostics["raw_preview"] = _preview(value)

    if value is None:
        return "", diagnostics
    if isinstance(value, str):
        diagnostics["used_path"] = "str"
        diagnostics["text_length"] = len(value)
        diagnostics["text_preview"] = _preview(value)
        return value, diagnostics
    if isinstance(value, dict):
        text, path = _from_mapping(value)
        diagnostics["used_path"] = path or "dict.unparsed"
        diagnostics["text_length"] = len(text)
        diagnostics["text_preview"] = _preview(text)
        return text, diagnostics

    text, path = _from_object(value)
    diagnostics["used_path"] = path or "object.unparsed"
    diagnostics["text_length"] = len(text)
    diagnostics["text_preview"] = _preview(text)
    return text, diagnostics

# Retrieval configuration (aligned with RTL-Repo generate_model_predictions_1.py)
DEFAULT_RETRIEVAL_CONFIG = {
    # Local retrieval switch
    "enable_local_retrieval": True,

    # Local retrieval settings
    "bm25_block_order": "ascending",
    "bm25_merge_overlapping_blocks": False,
    "bm25_top_k_blocks": 10,
    "retrieval_fusion_k": 60,
    
    # External retrieval settings (same as RTL-Repo)
    "enable_external_retrieval": True,
    "external_retrieval_path": DEFAULT_EXTERNAL_RETRIEVAL_PATH,
    "external_prepend_blocks": 3,
    "bm25_external_file_top_k": 24,
    "enable_external_file_coarse_to_fine": True,
    "enable_external_composite_file_ranking": True,
    "enable_external_filename_match_boost": False,
    "enable_external_generic_large_file_penalty": False,
    "enable_masked_type_retrieval_boost": True,
    
    # External retrieval gating (same as RTL-Repo)
    "enable_external_retrieval_gating": True,
    "external_gate_local_top_n": 3,
    "external_gate_strong_prepend_blocks": 0,
    "external_gate_weak_prepend_blocks": 3,
    "external_gate_miss_prepend_blocks": 5,
    "external_gate_max_unknown_blocks_for_strong": 1,
    "external_gate_min_strong_identifier_coverage": 0.45,
    "external_gate_min_weak_identifier_coverage": 0.18,
    
    # Generation settings
    "sample_window": 50,
    "response_lines": 20,
    "max_tokens": 256,
    "trim_prompt": True,
    "trim_max_tokens": 32767,

    # Markdown doc retrieval settings
    "enable_doc_retrieval": True,
    "doc_injection_mode": "retrieved_chunks",
    "doc_retrieval_backend": "hybrid",
    "doc_codebert_fallback_backend": "bm25",
    "doc_retrieval_top_k": 3,
    "doc_bm25_candidate_k": 12,
    "doc_chunk_max_chars": 1200,
    "doc_codebert_model_path": str(RTL_REPO_ROOT / "models" / "codebert-base"),
    "doc_codebert_batch_size": 8,
    "doc_codebert_max_length": 256,
    "doc_query_prefix_lines": 30,
    "doc_query_suffix_lines": 20,
}


def resolve_doc_retrieval_config() -> Dict[str, Any]:
    config = dict(DEFAULT_RETRIEVAL_CONFIG)

    local_env = os.environ.get("REALBENCH_ENABLE_LOCAL_RETRIEVAL")
    if local_env is not None:
        config["enable_local_retrieval"] = local_env.lower() in {"1", "true", "yes", "on"}

    external_env = os.environ.get("REALBENCH_ENABLE_EXTERNAL_RETRIEVAL")
    if external_env is not None:
        config["enable_external_retrieval"] = external_env.lower() in {"1", "true", "yes", "on"}

    external_prepend_env = os.environ.get("REALBENCH_EXTERNAL_PREPEND_BLOCKS")
    if external_prepend_env:
        config["external_prepend_blocks"] = max(0, int(external_prepend_env))

    infile_top_k_env = os.environ.get("REALBENCH_INFILE_TOP_K_BLOCKS")
    if infile_top_k_env:
        config["infile_top_k_blocks"] = max(0, int(infile_top_k_env))

    gating_env = os.environ.get("REALBENCH_ENABLE_EXTERNAL_RETRIEVAL_GATING")
    if gating_env is not None:
        config["enable_external_retrieval_gating"] = gating_env.lower() in {"1", "true", "yes", "on"}

    masked_type_boost_env = os.environ.get("REALBENCH_ENABLE_MASKED_TYPE_RETRIEVAL_BOOST")
    if masked_type_boost_env is not None:
        config["enable_masked_type_retrieval_boost"] = masked_type_boost_env.lower() in {"1", "true", "yes", "on"}

    enable_env = os.environ.get("REALBENCH_ENABLE_DOC_RETRIEVAL")
    if enable_env is not None:
        config["enable_doc_retrieval"] = enable_env.lower() in {"1", "true", "yes", "on"}

    doc_injection_mode_env = os.environ.get("REALBENCH_DOC_INJECTION_MODE")
    if doc_injection_mode_env:
        config["doc_injection_mode"] = doc_injection_mode_env.strip().lower()

    backend_env = os.environ.get("REALBENCH_DOC_RETRIEVAL_BACKEND")
    if backend_env:
        config["doc_retrieval_backend"] = backend_env.strip().lower()

    fallback_env = os.environ.get("REALBENCH_DOC_CODEBERT_FALLBACK_BACKEND")
    if fallback_env:
        config["doc_codebert_fallback_backend"] = fallback_env.strip().lower()

    top_k_env = os.environ.get("REALBENCH_DOC_RETRIEVAL_TOP_K")
    if top_k_env:
        config["doc_retrieval_top_k"] = max(0, int(top_k_env))

    bm25_candidate_env = os.environ.get("REALBENCH_DOC_BM25_CANDIDATE_K")
    if bm25_candidate_env:
        config["doc_bm25_candidate_k"] = max(1, int(bm25_candidate_env))

    chunk_chars_env = os.environ.get("REALBENCH_DOC_CHUNK_MAX_CHARS")
    if chunk_chars_env:
        config["doc_chunk_max_chars"] = max(200, int(chunk_chars_env))

    batch_size_env = os.environ.get("REALBENCH_DOC_CODEBERT_BATCH_SIZE")
    if batch_size_env:
        config["doc_codebert_batch_size"] = max(1, int(batch_size_env))

    max_length_env = os.environ.get("REALBENCH_DOC_CODEBERT_MAX_LENGTH")
    if max_length_env:
        config["doc_codebert_max_length"] = max(16, int(max_length_env))

    trim_prompt_env = os.environ.get("REALBENCH_TRIM_PROMPT")
    if trim_prompt_env is not None:
        config["trim_prompt"] = trim_prompt_env.lower() in {"1", "true", "yes", "on"}

    trim_max_tokens_env = os.environ.get("REALBENCH_TRIM_MAX_TOKENS")
    if trim_max_tokens_env:
        config["trim_max_tokens"] = max(256, int(trim_max_tokens_env))

    model_path_env = os.environ.get("REALBENCH_DOC_CODEBERT_MODEL_PATH")
    if model_path_env:
        config["doc_codebert_model_path"] = model_path_env

    return config


def _parse_env_flag(name: str, default: bool) -> bool:
    raw = os.environ.get(name)
    if raw is None:
        return default
    return raw.strip().lower() in {"1", "true", "yes", "on"}


def render_full_doc_lines(docs_md: List[Dict[str, Any]] | List[str]) -> List[str]:
    rendered: List[str] = []
    for index, doc in enumerate(docs_md or [], start=1):
        if isinstance(doc, dict):
            doc_path = str(doc.get("path") or doc.get("file_path") or f"doc_{index}.md")
            content = str(doc.get("content") or doc.get("text") or doc.get("body") or "")
        else:
            doc_path = f"doc_{index}.md"
            content = str(doc or "")
        content_lines = [line.rstrip("\n") for line in content.splitlines()]
        if not content_lines:
            continue
        rendered.extend(
            [
                "===== Retrieved document =====",
                f"// Doc source: {doc_path}",
                *content_lines,
                "",
            ]
        )
    if rendered and not rendered[-1]:
        rendered.pop()
    return rendered


def resolve_backend_config() -> Dict[str, Any]:
    config = dict(DEFAULT_BACKEND_CONFIG)

    provider_env = os.environ.get("REALBENCH_API_PROVIDER", "").strip().lower()
    if provider_env:
        config.update(_resolve_provider_defaults(provider_env))

    api_base_env = _first_non_empty_env("REALBENCH_API_BASE")
    if api_base_env:
        config["api_base"] = api_base_env

    api_key_env = _first_non_empty_env("REALBENCH_API_KEY", "OPENAI_API_KEY")
    if api_key_env:
        config["api_key"] = api_key_env

    model_name_env = _first_non_empty_env("REALBENCH_MODEL_NAME", "REALBENCH_API_MODEL")
    if model_name_env:
        config["model_name"] = model_name_env.strip()

    backend_type_env = os.environ.get("REALBENCH_BACKEND_TYPE")
    if backend_type_env:
        config["type"] = backend_type_env.strip().lower()

    local_model_path_env = os.environ.get("REALBENCH_LOCAL_MODEL_PATH")
    if local_model_path_env:
        config["model_path"] = local_model_path_env

    if config.get("type") == "local_hf_causal_lm":
        config.setdefault("model_path", DEFAULT_LOCAL_MODEL_PATH)
        config.setdefault("append_suffix_to_prompt", True)
        config.setdefault("local_plain_completion_prompt", True)
        if not model_name_env:
            config["model_name"] = Path(config["model_path"]).name

    if config.get("type") in {"openai_chat_api", "openai_responses_api", "fim_api"}:
        config["token_counter"] = {
            "family": "huggingface",
            "kind": "huggingface",
            "tokenizer_path": config.get("model_path") or DEFAULT_LOCAL_MODEL_PATH,
            "max_context_tokens": 65536,
        }
        token_counter_max_context_env = os.environ.get("REALBENCH_TOKEN_COUNTER_MAX_CONTEXT")
        if token_counter_max_context_env:
            config["token_counter"]["max_context_tokens"] = max(256, int(token_counter_max_context_env))

    temperature_env = os.environ.get("REALBENCH_TEMPERATURE")
    if temperature_env:
        config["temperature"] = float(temperature_env)

    client_timeout_env = os.environ.get("REALBENCH_CLIENT_TIMEOUT_SECONDS")
    if client_timeout_env:
        config["client_timeout_seconds"] = max(1, int(float(client_timeout_env)))

    max_tokens_env = os.environ.get("REALBENCH_MAX_TOKENS")
    if max_tokens_env:
        config["max_tokens"] = max(1, int(max_tokens_env))

    chat_fallback_env = os.environ.get("REALBENCH_CHAT_FALLBACK")
    if chat_fallback_env is not None:
        config["chat_fallback"] = _parse_env_flag(
            "REALBENCH_CHAT_FALLBACK",
            bool(config.get("chat_fallback", True)),
        )

    append_suffix_env = os.environ.get("REALBENCH_APPEND_SUFFIX_TO_PROMPT")
    if append_suffix_env is not None:
        config["append_suffix_to_prompt"] = _parse_env_flag(
            "REALBENCH_APPEND_SUFFIX_TO_PROMPT", bool(config.get("append_suffix_to_prompt", True))
        )

    local_plain_env = os.environ.get("REALBENCH_LOCAL_PLAIN_COMPLETION_PROMPT")
    if local_plain_env is not None:
        config["local_plain_completion_prompt"] = _parse_env_flag(
            "REALBENCH_LOCAL_PLAIN_COMPLETION_PROMPT",
            bool(config.get("local_plain_completion_prompt", True)),
        )

    return config


def allow_mock_fallback() -> bool:
    return _parse_env_flag("REALBENCH_ALLOW_MOCK_FALLBACK", True)


def resolve_retrieval_fallback_config() -> Dict[str, Any]:
    return {
        "enabled": _parse_env_flag("REALBENCH_ENABLE_RETRIEVAL_FALLBACK", True),
        "prefer_local": _parse_env_flag("REALBENCH_RETRIEVAL_FALLBACK_PREFER_LOCAL", True),
        "max_candidates": max(1, int(os.environ.get("REALBENCH_RETRIEVAL_FALLBACK_MAX_CANDIDATES", "8"))),
        "empty_line_threshold": max(0, int(os.environ.get("REALBENCH_RETRIEVAL_FALLBACK_EMPTY_LINE_THRESHOLD", "0"))),
    }


def resolve_completion_postprocess_config() -> Dict[str, Any]:
    config = dict(DEFAULT_COMPLETION_POSTPROCESS_CONFIG)
    config["enable_clipping"] = _parse_env_flag("REALBENCH_ENABLE_COMPLETION_CLIPPING", config["enable_clipping"])
    config["enable_dynamic_length_guard"] = _parse_env_flag(
        "REALBENCH_ENABLE_DYNAMIC_LENGTH_GUARD", config["enable_dynamic_length_guard"]
    )
    multiplier_env = os.environ.get("REALBENCH_DYNAMIC_LENGTH_MULTIPLIER")
    if multiplier_env:
        config["dynamic_length_multiplier"] = max(1.0, float(multiplier_env))
    return config


def estimate_expected_completion_lines(request: Dict[str, Any]) -> int:
    masked_item = get_primary_masked_item(request)
    if isinstance(masked_item, dict):
        for key in ("line_count", "response_lines", "expected_completion_lines"):
            value = masked_item.get(key)
            if isinstance(value, int) and value > 0:
                return value

        answer = str(masked_item.get("answer", ""))
        answer_lines = len(non_empty_lines(answer))
        if answer_lines > 0:
            return answer_lines

    target = request.get("target", {}) if isinstance(request, dict) else {}
    expected = target.get("expected_completion_lines") if isinstance(target, dict) else None
    if isinstance(expected, int) and expected > 0:
        return expected

    return 0


def _preserve_structural_closers_after_truncation(
    kept_lines: List[str],
    dropped_lines: List[str],
) -> Tuple[List[str], Dict[str, Any]]:
    meta: Dict[str, Any] = {
        "applied": False,
        "appended_lines": 0,
        "appended_closers": [],
    }
    if not kept_lines or not dropped_lines:
        return kept_lines, meta

    opener_tokens = {"begin", "case", "function", "task", "module"}
    closer_for = {
        "begin": "end",
        "case": "endcase",
        "function": "endfunction",
        "task": "endtask",
        "module": "endmodule",
    }
    closer_tokens = set(closer_for.values())
    token_pattern = re.compile(r"\b(begin|end|case|endcase|function|endfunction|task|endtask|module|endmodule)\b")

    def collect_unmatched(lines: List[str]) -> List[str]:
        stack: List[str] = []
        for line in lines:
            stripped = line.strip()
            if not stripped or stripped.startswith("//"):
                continue
            tokens = token_pattern.findall(stripped)
            for token in tokens:
                if token in opener_tokens:
                    stack.append(token)
                    continue
                if token == "end":
                    if stack and stack[-1] == "begin":
                        stack.pop()
                    continue
                if token in closer_tokens:
                    expected_open = None
                    for opener, closer in closer_for.items():
                        if closer == token:
                            expected_open = opener
                            break
                    if expected_open and stack and stack[-1] == expected_open:
                        stack.pop()
        return stack

    unmatched = collect_unmatched(kept_lines)
    if not unmatched:
        return kept_lines, meta

    needed_closers: List[str] = []
    for opener in reversed(unmatched):
        closer = closer_for.get(opener)
        if closer:
            needed_closers.append(closer)

    if not needed_closers:
        return kept_lines, meta

    appended: List[str] = []
    remaining_needed = needed_closers.copy()
    for line in dropped_lines:
        stripped = line.strip()
        if not stripped or stripped.startswith("//"):
            continue
        if stripped != remaining_needed[0]:
            continue
        appended.append(line)
        remaining_needed.pop(0)
        if not remaining_needed:
            break

    if not appended:
        return kept_lines, meta

    meta["applied"] = True
    meta["appended_lines"] = len(appended)
    meta["appended_closers"] = [line.strip() for line in appended]
    return kept_lines + appended, meta


def apply_dynamic_length_guard(
    request: Dict[str, Any],
    candidate_lines: List[str],
    postprocess_config: Dict[str, Any],
) -> Tuple[List[str], Dict[str, Any]]:
    meta: Dict[str, Any] = {
        "enabled": bool(postprocess_config.get("enable_dynamic_length_guard", True)),
        "triggered": False,
        "expected_lines": 0,
        "max_allowed_lines": None,
        "original_line_count": len(candidate_lines),
        "final_line_count": len(candidate_lines),
    }
    if not meta["enabled"] or not candidate_lines:
        return candidate_lines, meta

    expected_lines = estimate_expected_completion_lines(request)
    meta["expected_lines"] = expected_lines
    if expected_lines <= 0:
        return candidate_lines, meta

    multiplier = float(postprocess_config.get("dynamic_length_multiplier", 1.8))
    allowed_lines = max(1, int(expected_lines * multiplier + 0.999999))
    meta["max_allowed_lines"] = allowed_lines
    if len(candidate_lines) <= allowed_lines:
        return candidate_lines, meta

    meta["triggered"] = True
    meta["truncated_from_line"] = allowed_lines
    trimmed = candidate_lines[:allowed_lines]
    dropped = candidate_lines[allowed_lines:]
    trimmed, closure_meta = _preserve_structural_closers_after_truncation(trimmed, dropped)
    meta["closure_preservation"] = closure_meta
    meta["final_line_count"] = len(trimmed)
    return trimmed, meta


def resolve_prompt_construction_config() -> Dict[str, Any]:
    return {
        "prompt_prefix_mode": os.environ.get("REALBENCH_PROMPT_PREFIX_MODE", "retrieval").strip().lower(),
        "include_right_context": _parse_env_flag("REALBENCH_INCLUDE_RIGHT_CONTEXT", True),
        "include_shape_hint": _parse_env_flag("REALBENCH_INCLUDE_SHAPE_HINT", True),
        "use_strict_boundary_constraints": _parse_env_flag("REALBENCH_USE_STRICT_BOUNDARY_CONSTRAINTS", True),
        "place_short_right_context_at_end": _parse_env_flag(
            "REALBENCH_PLACE_SHORT_RIGHT_CONTEXT_AT_END",
            True,
        ),
        "short_right_context_max_lines": max(
            0,
            int(os.environ.get("REALBENCH_SHORT_RIGHT_CONTEXT_MAX_LINES", "20")),
        ),
    }


def resolve_fim_config(request: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
    request = request or {}
    target = request.get("target", {}) if isinstance(request, dict) else {}
    metadata = target.get("metadata", {}) if isinstance(target, dict) else {}

    request_fim = False
    if isinstance(metadata, dict):
        raw_request_fim = metadata.get("process_as_fim")
        if raw_request_fim is not None:
            request_fim = bool(raw_request_fim)

    env_fim = _parse_env_flag("REALBENCH_PROCESS_AS_FIM", DEFAULT_FIM_MODE)
    suffix_mode = os.environ.get("REALBENCH_FIM_SUFFIX_MODE", "right_context").strip().lower()
    if suffix_mode not in {"right_context", "full_suffix"}:
        suffix_mode = "right_context"

    return {
        "enabled": bool(request_fim or env_fim),
        "suffix_mode": suffix_mode,
    }


def resolve_generation_suffix(
    request: Dict[str, Any],
    suffix: str,
    fim_config: Dict[str, Any],
) -> str:
    if not fim_config.get("enabled", False):
        return suffix

    if fim_config.get("suffix_mode") == "full_suffix":
        return suffix

    suffix_lines = get_right_context_lines(request, suffix)
    return "\n".join(suffix_lines)


def count_rendered_retrieval_blocks(lines: List[str]) -> int:
    count = 0
    for line in lines:
        stripped = str(line).strip()
        if (
            stripped.startswith("===== block ")
            or stripped.startswith("===== doc chunk ")
            or stripped == "===== Retrieved context ====="
            or stripped == "===== Retrieved document ====="
        ):
            count += 1
    return count


def build_formatted_prompt_lines_from_request(request: Dict[str, Any]) -> List[str]:
    prompt_text = convert_realbench_to_rtlrepo_prompt(request)
    return [line.rstrip() for line in str(prompt_text).splitlines() if line.strip()]

# Verilog tokenization regex (from BM25search)
VERILOG_TOKEN_RE = re.compile(
    r"""
    \d+'[sS]?[bBoOdDhH][0-9a-fA-F_xXzZ?]+ |
    \d+ |
    `[\w$]+ |
    === | !== | ==\? | !=\? | <= | >= | && | \|\| | <<<? | >>>? | \*\* | ~\^ | \^~ |
    [A-Za-z_$][\w$]* |
    \S
    """,
    re.VERBOSE,
)

# Prompt template for RealBench completion
REALBENCH_PROMPT_TEMPLATE = (
    "\n===== Start predicting from here. Please predict the code that should fill "
    "the masked placeholder. Output only the completion code. "
    "Stop immediately after writing the completion. "
    "Do not continue with helper modules, endmodule, explanations, comments, or any extra text. "
    "Do not add any formatting marks (such as ```verilog) or comments ====="
)

STRICT_BOUNDARY_CONSTRAINTS = (
    "\n===== Strict output constraints =====\n"
    "You are continuing the current code block only, not starting a new file or a new module.\n"
    "Do not repeat earlier context lines from retrieval or from the existing prompt unless the missing lines themselves are exactly the same.\n"
    "Do not output file headers, path markers, retrieval markers, repo names, or fenced code blocks.\n"
    "Do not output `timescale, module, endmodule, initial begin, task, function, always, assign, input, output, inout, wire, reg, or logic as a new declaration unless the missing lines at the cursor literally begin with them.\n"
    "Do not start a helper module, do not restart the current module, and do not jump to another unrelated block.\n"
    "===== End strict output constraints ====="
)

DEFAULT_RIGHT_CONTEXT_SLICE = (10, 29)
DEFAULT_RIGHT_CONTEXT_FALLBACK_HEAD_LINES = 20


# ---------------------------------------------------------------------------
# Helper Functions
# ---------------------------------------------------------------------------

def non_empty_lines(text: str) -> List[str]:
    """Extract non-empty lines from text."""
    return [line.rstrip() for line in str(text).splitlines() if line.strip()]


def is_block_level_mask_request(request: Dict[str, Any]) -> bool:
    target = request.get("target", {})
    metadata = target.get("metadata", {})
    if not isinstance(metadata, dict):
        return False

    masked_items = metadata.get("masked", [])
    if not isinstance(masked_items, list) or not masked_items:
        return False

    for item in masked_items:
        if not isinstance(item, dict):
            continue
        if str(item.get("kind", "")).lower() == "block":
            return True
        answer = str(item.get("answer", ""))
        if len(non_empty_lines(answer)) > 1:
            return True
    return False


def get_primary_masked_item(request: Dict[str, Any]) -> Dict[str, Any]:
    target = request.get("target", {})
    metadata = target.get("metadata", {})
    if not isinstance(metadata, dict):
        return {}

    masked_items = metadata.get("masked", [])
    if not isinstance(masked_items, list) or not masked_items:
        return {}

    first = masked_items[0]
    return first if isinstance(first, dict) else {}


def build_block_shape_hint(request: Dict[str, Any]) -> List[str]:
    masked_item = get_primary_masked_item(request)
    masked_type = str(masked_item.get("type", "")).strip().lower()
    if not masked_type:
        return []

    hints = {
        "function": [
            "===== Missing block shape hint =====",
            "The missing block is a function block.",
            "It should start with `function` and end with `endfunction` before the right-context begins.",
        ],
        "task": [
            "===== Missing block shape hint =====",
            "The missing block is a task block.",
            "It should start with `task` and end with `endtask` before the right-context begins.",
        ],
        "assign": [
            "===== Missing block shape hint =====",
            "The missing block is an assign-style block.",
            "Prefer one or more `assign ...;` statements only.",
        ],
        "assign_cluster": [
            "===== Missing block shape hint =====",
            "The missing block is an assign cluster.",
            "Prefer consecutive `assign ...;` statements only.",
        ],
        "always": [
            "===== Missing block shape hint =====",
            "The missing block is an `always` procedural block.",
            "Keep a single coherent `always` block and stop before unrelated module content.",
        ],
    }
    return hints.get(masked_type, [])


def get_masked_type(request: Dict[str, Any]) -> str:
    masked_item = get_primary_masked_item(request)
    return str(masked_item.get("type", "")).strip().lower()


def get_right_context_lines(
    request: Dict[str, Any],
    suffix: str,
    line_slice: Tuple[int, int] = DEFAULT_RIGHT_CONTEXT_SLICE,
    fallback_head_lines: int = DEFAULT_RIGHT_CONTEXT_FALLBACK_HEAD_LINES,
) -> List[str]:
    formatted_suffix = format_verilog_text(suffix)
    suffix_lines = [line.strip() for line in str(formatted_suffix).splitlines() if line.strip()]
    if not suffix_lines:
        return []

    if is_block_level_mask_request(request):
        return suffix_lines

    start, end = line_slice
    sliced = suffix_lines[start:end]
    if sliced:
        return sliced
    return suffix_lines[:fallback_head_lines]


def tokenize_verilog(text: str) -> List[str]:
    """Tokenize Verilog code using RTL-Repo's tokenizer."""
    return [token.lower() for token in VERILOG_TOKEN_RE.findall(str(text))]


def convert_realbench_to_rtlrepo_prompt(
    request: Dict[str, Any],
) -> str:
    """
    Convert RealBench request to RTL-Repo prompt format.
    
    This synthesizes RealBench's separate .v files into a unified prompt text
    that matches RTL-Repo's format, enabling proper retrieval via BM25search.
    
    RTL-Repo prompt format:
        // Repo Name: <repo_name>
        // Path: <file_path1>
        <snippet1>
        
        // Path: <file_path2>
        <snippet2>
        ...
        // Path: <target_file_path>
        <cropped_code>
    
    Args:
        request: RealBench completion request dict
    
    Returns:
        Unified prompt text in RTL-Repo format
    """
    target = request.get("target", {})
    context = request.get("context", {})
    
    system_name = target.get("system", "realbench_system")
    target_path = target.get("path", "unknown")
    prefix = target.get("prefix", "")
    verilog_files = context.get("verilog_files", [])
    
    # Build cross-file context section
    prompt_lines = [f"// Repo Name: {system_name}"]
    
    # Add context files as snippets
    for ctx_file in verilog_files:
        file_path = ctx_file.get("path", "unknown")
        content = ctx_file.get("content", "")
        
        # Format the content
        formatted_content = format_verilog_text(content)
        
        # Add file header and content
        prompt_lines.append(f"// Path: {file_path}")
        prompt_lines.append(formatted_content)
        prompt_lines.append("")  # Empty line separator
    
    # Add target file (cropped code = prefix)
    formatted_prefix = format_verilog_text(prefix)
    prompt_lines.append(f"// Path: {target_path}")
    prompt_lines.append(formatted_prefix)
    
    # Join and normalize excessive newlines
    prompt_text = "\n".join(prompt_lines)
    prompt_text = re.sub(r'\n{4,}', '\n\n', prompt_text)
    
    return prompt_text


# ---------------------------------------------------------------------------
# Comment-heavy block filtering (aligned with RTL-Repo external filtering)
# ---------------------------------------------------------------------------

LOCAL_SKIP_COMMENT_HEAVY = True
LOCAL_MAX_COMMENT_RATIO = 0.65
LOCAL_MIN_CODE_LINES = 4


def _comment_ratio(lines):
    """Calculate the ratio of comment-like lines in a block."""
    non_empty = [str(line).strip() for line in lines if str(line).strip()]
    if not non_empty:
        return 1.0
    comment_like = 0
    for stripped in non_empty:
        if stripped.startswith("//") or stripped.startswith("/*") or stripped.startswith("*"):
            comment_like += 1
            continue
        if set(stripped) <= {"/"}:
            comment_like += 1
    return comment_like / len(non_empty)


def _count_code_like_lines(lines):
    """Count lines that look like actual code (not comments)."""
    count = 0
    for line in lines:
        stripped = str(line).strip()
        if not stripped:
            continue
        if stripped.startswith("//"):
            continue
        if stripped.startswith("/*") or stripped.startswith("*"):
            continue
        if set(stripped) <= {"/"}:
            continue
        count += 1
    return count


def _is_comment_heavy_local_block(block_lines):
    """Check if a block is too comment-heavy to be useful for retrieval."""
    if not LOCAL_SKIP_COMMENT_HEAVY:
        return False
    code_lines = _count_code_like_lines(block_lines)
    ratio = _comment_ratio(block_lines)
    return code_lines < LOCAL_MIN_CODE_LINES or ratio > LOCAL_MAX_COMMENT_RATIO


def build_local_blocks_from_context(
    context_files: List[Dict[str, Any]],
    exclude_file_paths: Optional[List[str]] = None,
    window_size: int = 30,
    step: int = 10,
) -> List[Dict[str, Any]]:
    """
    Build sliding window blocks from RealBench context files.
    
    This adapts RTL-Repo's local block building to work with RealBench's
    provided context files (which are complete files, not pre-chunked).
    
    Args:
        context_files: List of context file dicts from RealBench request
                       Each has: {"path": "...", "role": "...", "content": "..."}
        window_size: Sliding window size (default 30 lines)
        step: Sliding step (default 10 lines)
    
    Returns:
        List of block info dicts compatible with BM25search scoring
    """
    block_infos = []
    block_id_counter = 0
    excluded_paths = {
        str(path or "").replace("\\", "/").strip()
        for path in (exclude_file_paths or [])
        if str(path or "").strip()
    }
    
    for ctx_file in context_files:
        file_path = str(ctx_file.get("path", "unknown") or "unknown").replace("\\", "/").strip()
        if file_path in excluded_paths:
            continue
        role = ctx_file.get("role", "context")
        content = ctx_file.get("content", "")
        
        # Format and clean the content
        formatted_content = format_verilog_text(content)
        lines = non_empty_lines(formatted_content)
        
        if not lines:
            continue
        
        # Build sliding windows
        total = len(lines)
        if total <= window_size:
            # Single block for small files
            # Skip comment-heavy blocks
            if not _is_comment_heavy_local_block(lines):
                block_infos.append({
                    "block_id": f"realbench:{block_id_counter}:{file_path}",
                    "source": "local",
                    "block_kind": f"realbench_{role}",
                    "start_index": 0,
                    "block_lines": lines,
                    "text": "\n".join(lines),
                    "tokens": tokenize_verilog("\n".join(lines)),
                    "repo_name": "realbench_context",
                    "file_paths": [file_path],
                })
                block_id_counter += 1
        else:
            # Sliding windows for larger files
            for start_idx in range(0, total - window_size + 1, step):
                block_lines = lines[start_idx : start_idx + window_size]
                # Skip comment-heavy blocks
                if _is_comment_heavy_local_block(block_lines):
                    continue
                block_infos.append({
                    "block_id": f"realbench:{block_id_counter}:{file_path}:{start_idx}",
                    "source": "local",
                    "block_kind": f"realbench_{role}",
                    "start_index": start_idx,
                    "block_lines": block_lines,
                    "text": "\n".join(block_lines),
                    "tokens": tokenize_verilog("\n".join(block_lines)),
                    "repo_name": "realbench_context",
                    "file_paths": [file_path],
                })
                block_id_counter += 1
    
    return block_infos


def build_infile_remote_blocks(
    whole_file: str,
    prefix: str,
    suffix: str,
    target_path: str,
    window_size: int = 30,
    step: int = 10,
    left_keep_lines: int = 150,
    right_keep_lines: int = 150,
) -> List[Dict[str, Any]]:
    """Build retrievable blocks from the current file outside the kept visible window."""
    whole_lines = [line.rstrip() for line in str(whole_file).splitlines()]
    prefix_lines = [line.rstrip() for line in str(prefix).splitlines()]
    suffix_lines = [line.rstrip() for line in str(suffix).splitlines()]

    if not whole_lines:
        return []

    total_lines = len(whole_lines)
    mask_start = min(max(len(prefix_lines), 0), total_lines)
    mask_end = max(mask_start, total_lines - max(len(suffix_lines), 0))
    keep_start = max(0, mask_start - max(left_keep_lines, 0))
    keep_end = min(total_lines, mask_end + max(right_keep_lines, 0))

    block_infos: List[Dict[str, Any]] = []
    block_id_counter = 0
    for start_idx in range(0, total_lines, step):
        end_idx = min(total_lines, start_idx + window_size)
        if end_idx <= start_idx:
            continue
        if start_idx < keep_end and end_idx > keep_start:
            continue

        block_lines = whole_lines[start_idx:end_idx]
        normalized_lines = non_empty_lines("\n".join(block_lines))
        if not normalized_lines or _is_comment_heavy_local_block(normalized_lines):
            continue

        text = "\n".join(normalized_lines)
        block_infos.append({
            "block_id": f"infile:{block_id_counter}:{target_path}:{start_idx}",
            "source": "In_file",
            "block_kind": "in_file_remote",
            "start_index": start_idx,
            "block_lines": normalized_lines,
            "text": text,
            "tokens": tokenize_verilog(text),
            "repo_name": "current_in_file",
            "file_paths": [target_path],
        })
        block_id_counter += 1

    return block_infos


def build_visible_infile_context(
    whole_file: str,
    prefix: str,
    suffix: str,
    header_max_lines: int = 80,
    left_keep_lines: int = 150,
    right_keep_lines: int = 150,
    skip_marker: str = "===== Unrelated in-file code skipped =====",
) -> Tuple[str, str]:
    """Build visible in-file context with a structure header and local windows around the mask."""
    whole_lines = [line.rstrip() for line in str(whole_file).splitlines()]
    prefix_lines = [line.rstrip() for line in str(prefix).splitlines()]
    suffix_lines = [line.rstrip() for line in str(suffix).splitlines()]

    if not whole_lines:
        return prefix, suffix

    total_lines = len(whole_lines)
    prefix_count = min(max(len(prefix_lines), 0), total_lines)
    suffix_count = min(max(len(suffix_lines), 0), max(0, total_lines - prefix_count))
    mask_start = prefix_count
    mask_end = max(mask_start, total_lines - suffix_count)

    header_end = 0
    saw_module = False
    paren_depth = 0
    seen_header_paren = False
    for index, line in enumerate(whole_lines[:header_max_lines]):
        stripped = line.strip()
        if not saw_module:
            if stripped.startswith("module "):
                saw_module = True
            else:
                continue

        paren_depth += line.count("(") - line.count(")")
        if "(" in line:
            seen_header_paren = True

        if seen_header_paren and paren_depth <= 0 and ";" in line:
            header_end = index + 1
            break

        if not seen_header_paren and ";" in line:
            header_end = index + 1
            break

    if header_end == 0:
        header_end = min(header_max_lines, total_lines, prefix_count)

    left_start = max(0, mask_start - max(left_keep_lines, 0))
    right_end = min(total_lines, mask_end + max(right_keep_lines, 0))

    header_lines = whole_lines[:header_end]
    left_window_lines = whole_lines[left_start:mask_start]
    right_window_lines = whole_lines[mask_end:right_end]

    new_prefix_lines: List[str] = []
    if header_lines:
        new_prefix_lines.extend(header_lines)

    left_window_start = left_start
    if left_window_start < header_end:
        left_window_lines = whole_lines[header_end:mask_start]
        left_window_start = header_end

    if left_window_start > header_end and left_window_lines:
        if new_prefix_lines and new_prefix_lines[-1].strip() != skip_marker:
            new_prefix_lines.append(skip_marker)

    if left_window_lines:
        if new_prefix_lines and new_prefix_lines[-1] != "":
            new_prefix_lines.append("")
        new_prefix_lines.extend(left_window_lines)

    new_suffix_lines: List[str] = []
    if right_window_lines:
        new_suffix_lines.extend(right_window_lines)
        if right_end < total_lines:
            new_suffix_lines.append(skip_marker)

    return "\n".join(new_prefix_lines), "\n".join(new_suffix_lines)


def build_local_query_text(prefix: str, suffix: str, min_lines: int = 30) -> str:
    """Build a retrieval query text without relying on the target file as a retrievable document."""
    prefix_lines = non_empty_lines(prefix)
    if len(prefix_lines) >= min_lines:
        return "\n".join(prefix_lines[-min_lines:])

    suffix_lines = non_empty_lines(suffix)
    needed_suffix = max(0, min_lines - len(prefix_lines))
    suffix_window = suffix_lines[:needed_suffix]
    query_lines = list(prefix_lines)
    if suffix_window:
        query_lines.append("// Query suffix context")
        query_lines.extend(suffix_window)
    return "\n".join(query_lines)


def augment_query_text_with_masked_type(
    query_text: str,
    masked_type: str,
) -> Tuple[str, Dict[str, Any]]:
    normalized_type = str(masked_type or "").strip().lower()
    type_keywords = {
        "function": ["function", "endfunction", "function"],
        "task": ["task", "endtask", "task"],
        "always": ["always", "begin", "end", "always"],
        "assign": ["assign", "assign"],
        "assign_cluster": ["assign", "assign", "assign"],
    }.get(normalized_type, [])
    if not type_keywords:
        return query_text, {
            "enabled": False,
            "masked_type": normalized_type,
            "added_keywords": [],
        }

    augmented_lines = [query_text.rstrip()] if query_text.strip() else []
    if augmented_lines:
        augmented_lines.append("")
    augmented_lines.append("// Retrieval structure hints")
    augmented_lines.extend(type_keywords)
    return "\n".join(augmented_lines), {
        "enabled": True,
        "masked_type": normalized_type,
        "added_keywords": type_keywords,
    }


def resolve_iteration_rag_previous_output(request: Dict[str, Any]) -> str:
    meta = request.get("meta", {})
    if not isinstance(meta, dict):
        return ""

    iteration_rag = meta.get("iteration_rag", {})
    previous_output = meta.get("previous_output", "")
    mode = os.environ.get("REALBENCH_ITERATION_RAG_PREVIOUS_OUTPUT_MODE", "disabled").strip().lower()

    if mode not in {"enabled", "on", "1", "true", "yes"}:
        return ""
    if not isinstance(iteration_rag, dict) or not iteration_rag.get("enabled"):
        return ""
    if not isinstance(previous_output, str) or not previous_output.strip():
        return ""
    return format_verilog_text(previous_output)


def augment_query_text_with_previous_output(
    query_text: str,
    previous_output: str,
    max_lines: int = 40,
) -> Tuple[str, Dict[str, Any]]:
    if not previous_output.strip():
        return query_text, {
            "enabled": False,
            "previous_output_lines": 0,
            "query_augmented": False,
        }

    mode = os.environ.get("REALBENCH_ITERATION_RAG_QUERY_MODE", "append_tail").strip().lower()
    previous_lines = non_empty_lines(previous_output)
    query_lines = non_empty_lines(query_text)

    if mode in {"sliding_window_30", "sliding30", "window30"}:
        query_window_size = max(1, int(os.environ.get("REALBENCH_ITERATION_RAG_QUERY_WINDOW_LINES", "30")))
        anchor_lines = query_lines[-query_window_size:]
        if len(previous_lines) <= query_window_size:
            combined_lines = anchor_lines + previous_lines
            query_window = combined_lines[-query_window_size:]
        else:
            query_window = previous_lines[:query_window_size]
        return "\n".join(query_window), {
            "enabled": True,
            "mode": "sliding_window_30",
            "previous_output_lines": len(previous_lines),
            "previous_output_lines_used": min(len(previous_lines), query_window_size),
            "query_augmented": True,
            "query_window_size": query_window_size,
            "query_window_source": "previous_output_head" if len(previous_lines) > query_window_size else "anchor_plus_previous_output",
        }

    previous_tail = previous_lines[-max_lines:]
    augmented_parts = [query_text.rstrip()]
    if augmented_parts[0]:
        augmented_parts.append("")
    augmented_parts.append("// Iteration RAG previous output")
    augmented_parts.extend(previous_tail)
    return "\n".join(part for part in augmented_parts if part is not None), {
        "enabled": True,
        "mode": "append_tail",
        "previous_output_lines": len(previous_lines),
        "previous_output_lines_used": len(previous_tail),
        "query_augmented": True,
    }


def augment_rtlrepo_prompt_with_previous_output(
    rtlrepo_prompt: str,
    request: Dict[str, Any],
    previous_output: str,
) -> Tuple[str, Dict[str, Any]]:
    if not previous_output.strip():
        return rtlrepo_prompt, {
            "enabled": False,
            "prompt_augmented": False,
        }

    target = request.get("target", {})
    target_path = target.get("path", "unknown")
    augmented_prompt = "\n".join(
        [
            rtlrepo_prompt.rstrip(),
            "",
            f"// Path: {target_path}::__iteration_rag_previous_output__",
            previous_output,
        ]
    )
    return augmented_prompt, {
        "enabled": True,
        "prompt_augmented": True,
    }


def build_token_counter(blocks: List[Dict[str, Any]]) -> Dict[str, Any]:
    """Build token counter and norm for each block."""
    from collections import Counter
    import math
    
    for block in blocks:
        tokens = block.get("tokens", [])
        counter = Counter(tokens)
        norm = math.sqrt(sum(v * v for v in counter.values()))
        block["token_counter"] = counter
        block["token_norm"] = norm
    
    return blocks


def score_blocks_bm25(
    blocks: List[Dict[str, Any]],
    query_tokens: List[str],
) -> List[Tuple[Dict[str, Any], float]]:
    """
    Score blocks using BM25 algorithm.
    
    Args:
        blocks: List of block info dicts
        query_tokens: Tokenized query
    
    Returns:
        List of (block, score) tuples sorted by score descending
    """
    try:
        from rank_bm25 import BM25Okapi
        bm25_index = BM25Okapi([block["tokens"] for block in blocks])
        scores = bm25_index.get_scores(query_tokens)
        return [(block, float(score)) for block, score in zip(blocks, scores)]
    except ImportError:
        # Fallback to token cosine similarity
        return score_blocks_cosine(blocks, query_tokens)


def score_blocks_cosine(
    blocks: List[Dict[str, Any]],
    query_tokens: List[str],
) -> List[Tuple[Dict[str, Any], float]]:
    """
    Score blocks using token cosine similarity (fallback when BM25 unavailable).
    """
    from collections import Counter
    import math
    
    query_counter = Counter(query_tokens)
    query_norm = math.sqrt(sum(v * v for v in query_counter.values()))
    
    results = []
    for block in blocks:
        block_counter = block.get("token_counter", Counter(block.get("tokens", [])))
        block_norm = block.get("token_norm", 1.0)
        
        if query_norm <= 0 or block_norm <= 0:
            score = 0.0
        else:
            dot = sum(query_counter.get(t, 0) * block_counter.get(t, 0) for t in query_counter)
            score = dot / (query_norm * block_norm)
        
        results.append((block, score))
    
    return results


def compute_block_token_cosine(
    block: Dict[str, Any],
    query_tokens: List[str],
) -> float:
    """Compute token cosine similarity between a query and one block."""
    scored = score_blocks_cosine([block], query_tokens)
    if not scored:
        return 0.0
    return float(scored[0][1])


def retrieve_top_k_blocks(
    blocks: List[Dict[str, Any]],
    query_tokens: List[str],
    top_k: int = 10,
    block_order: str = "ascending",
    rich_render: bool = False,
    retriever_name: str = "local_bm25_fallback",
) -> List[Dict[str, Any]]:
    """
    Retrieve top-k blocks and render them as prompt lines.
    
    Args:
        blocks: List of block info dicts
        query_tokens: Tokenized query
        top_k: Number of blocks to retrieve
        block_order: "ascending" (lower scores first) or "descending"
    
    Returns:
        List of rendered prompt lines with block metadata
    """
    # Score blocks
    scored = score_blocks_bm25(blocks, query_tokens)
    
    # Sort by score
    reverse = block_order == "descending"
    scored.sort(key=lambda x: (x[1], x[0].get("start_index", 0)), reverse=reverse)
    
    # Take top-k
    top_blocks = scored[:top_k]
    
    if rich_render:
        ranked_items = [
            make_ranked_candidate_item(
                block=block,
                score=score,
                retriever_name=retriever_name,
                token_cosine=compute_block_token_cosine(block, query_tokens),
            )
            for block, score in top_blocks
        ]
        return BM25search._render_selected_items(ranked_items)

    # Render blocks
    output_lines = []
    for rank, (block, score) in enumerate(top_blocks, start=1):
        output_lines.append(f"===== block {rank} （score: {score:.4f}) =====")
        output_lines.append(f"// Retrieval source: {block['source']}")
        output_lines.append(f"// Retrieval file: {block.get('file_paths', ['unknown'])[0]}")
        output_lines.append(f"// Retrieval role: {block.get('block_kind', 'unknown')}")
        output_lines.extend(block["block_lines"])
        output_lines.append("")

    return output_lines


# ---------------------------------------------------------------------------
# External Retrieval Gating (aligned with RTL-Repo main system)
# ---------------------------------------------------------------------------

# Stopwords for identifier extraction (from RTL-Repo)
RETRIEVAL_GATE_STOPWORDS = {
    "module", "endmodule", "input", "output", "inout", "wire", "reg", "logic",
    "always", "begin", "end", "assign", "case", "posedge", "negedge",
    "parameter", "localparam", "clock", "reset", "clk", "rst",
}

IDENTIFIER_RE = re.compile(r"[A-Za-z_][A-Za-z0-9_$]*")
CAMEL_CASE_RE = re.compile(r"[A-Z]+(?=[A-Z][a-z]|\d|_|$)|[A-Z]?[a-z]+|\d+")


def split_identifier_fragments(text: str) -> List[str]:
    """Split identifiers into fragments (camelCase, snake_case aware)."""
    fragments = []
    for part in re.split(r"[^A-Za-z0-9_$]+", str(text or "")):
        if not part:
            continue
        camel_parts = CAMEL_CASE_RE.findall(part)
        if camel_parts:
            fragments.extend(camel_parts)
        else:
            fragments.append(part)
    return [fragment.lower() for fragment in fragments if fragment]


def extract_retrieval_gate_identifiers(
    target_file_path: str,
    search_seed: str,
    max_identifiers: int = 12,
) -> List[str]:
    """
    Extract key identifiers from target file path and search seed.
    
    This is used for external retrieval gating decision.
    """
    counts = {}
    basename = Path(str(target_file_path or "")).name
    stem = Path(basename).stem
    
    # Add identifiers from filename
    for token in split_identifier_fragments(basename) + split_identifier_fragments(stem):
        if token and len(token) >= 2:
            counts[token] = counts.get(token, 0) + 2
    
    # Add identifiers from tail of search seed
    tail_lines = [line.strip() for line in str(search_seed or "").splitlines() if line.strip()][-8:]
    for line in tail_lines:
        for match in IDENTIFIER_RE.finditer(line):
            token = match.group().lower()
            if token in RETRIEVAL_GATE_STOPWORDS or len(token) < 2:
                continue
            counts[token] = counts.get(token, 0) + 1
    
    # Sort by frequency
    ranked = sorted(counts.items(), key=lambda item: (-item[1], item[0]))
    return [token for token, _ in ranked[:max_identifiers]]


def is_testbench_like_name(text: str) -> bool:
    """Check if a name looks like a testbench."""
    lowered = str(text or "").lower()
    return "testbench" in lowered or bool(re.search(r"(^|[_\\/.\\-])tb([_\\/.\\-]|$)", lowered))


def is_testbench_like_block(block: Dict[str, Any]) -> bool:
    """Check if a block looks like testbench code."""
    file_label = str((block.get("file_paths") or [""])[0])
    if is_testbench_like_name(file_label):
        return True
    code_lines = block.get("block_lines", [])[:20]
    joined = "\n".join(code_lines).lower()
    return any(marker in joined for marker in ("initial begin", "$display", "$stop", "#", "wait("))


def build_retrieval_gate_diagnostics(
    local_blocks: List[Dict[str, Any]],
    target_file_path: str,
    search_seed: str,
    config: Dict[str, Any],
) -> Dict[str, Any]:
    """
    Build diagnostics for external retrieval gating decision.
    
    This implements the same gating logic as RTL-Repo's generate_model_predictions_1.py:
    - strong: Local retrieval is sufficient, no external needed
    - weak: Some local match, add moderate external blocks
    - miss: Poor local match, add more external blocks
    
    Returns:
        Dict with gating state and resolved external block count
    """
    top_n = config.get("external_gate_local_top_n", 3)
    
    if not local_blocks:
        return {
            "state": "miss",
            "reason": "no_local_blocks",
            "resolved_external_prepend_blocks": config.get("external_gate_miss_prepend_blocks", 5),
        }
    
    # Score local blocks
    query_tokens = tokenize_verilog(search_seed)
    scored = score_blocks_bm25(local_blocks, query_tokens)
    scored.sort(key=lambda x: x[1], reverse=True)
    
    top_items = scored[:top_n]
    key_identifiers = extract_retrieval_gate_identifiers(target_file_path, search_seed)
    
    target_basename = Path(str(target_file_path)).name.lower()
    target_stem = Path(str(target_file_path)).stem.lower()
    target_role_is_tb = is_testbench_like_name(target_file_path)
    
    unknown_count = 0
    same_file_hit = False
    same_stem_hit = False
    local_tb_like_hits = 0
    best_identifier_hits = 0
    coverage_matches = set()
    
    for block, score in top_items:
        file_paths = block.get("file_paths") or []
        file_label = str(file_paths[0]) if file_paths else "unknown"
        basename = Path(file_label).name.lower() if file_label and file_label != "unknown" else ""
        
        haystack = "\n".join([
            file_label,
            block.get("repo_name") or "",
            "\n".join(block.get("block_lines", [])[:20]),
        ]).lower()
        
        if not basename:
            unknown_count += 1
        if basename and basename == target_basename:
            same_file_hit = True
        if basename and target_stem and (basename.startswith(target_stem) or target_stem in basename):
            same_stem_hit = True
        if is_testbench_like_block(block):
            local_tb_like_hits += 1
        
        identifier_hits = 0
        for token in key_identifiers:
            if token in haystack:
                coverage_matches.add(token)
                identifier_hits += 1
        best_identifier_hits = max(best_identifier_hits, identifier_hits)
    
    identifier_coverage = len(coverage_matches) / len(key_identifiers) if key_identifiers else 0.0
    role_match = (not target_role_is_tb) or local_tb_like_hits > 0
    
    strong_coverage = config.get("external_gate_min_strong_identifier_coverage", 0.45)
    weak_coverage = config.get("external_gate_min_weak_identifier_coverage", 0.18)
    max_unknown_for_strong = config.get("external_gate_max_unknown_blocks_for_strong", 1)
    
    # Determine gating state (same logic as RTL-Repo)
    if same_file_hit or same_stem_hit:
        state = "strong"
        reason = "local_file_family_hit"
    elif role_match and identifier_coverage >= strong_coverage and unknown_count <= max_unknown_for_strong:
        state = "strong"
        reason = "local_identifier_coverage_strong"
    elif role_match and (identifier_coverage >= weak_coverage or best_identifier_hits >= 2 or unknown_count < top_n):
        state = "weak"
        reason = "local_partial_match"
    else:
        state = "miss"
        reason = "local_match_weak"
    
    # Adjust for testbench role mismatch
    if target_role_is_tb and local_tb_like_hits == 0 and state != "miss":
        state = "weak" if state == "strong" else "miss"
        reason = "target_testbench_but_local_blocks_not_testbench_like"
    
    # Resolve external block count based on state
    if state == "strong":
        resolved_prepend = config.get("external_gate_strong_prepend_blocks", 0)
    elif state == "weak":
        resolved_prepend = config.get("external_gate_weak_prepend_blocks", 3)
    else:
        resolved_prepend = config.get("external_gate_miss_prepend_blocks", 5)
    
    return {
        "state": state,
        "reason": reason,
        "resolved_external_prepend_blocks": max(0, resolved_prepend),
        "target_file_path": target_file_path,
        "identifier_coverage": identifier_coverage,
        "key_identifiers": key_identifiers,
        "same_file_hit": same_file_hit,
        "same_stem_hit": same_stem_hit,
        "unknown_count": unknown_count,
    }


# ---------------------------------------------------------------------------
# External Retrieval (using RTL-Repo's BM25search)
# ---------------------------------------------------------------------------

def retrieve_external_blocks(
    rtlrepo_prompt: str,
    target_file_path: str,
    external_corpus_path: str,
    external_prepend_blocks: int,
    config: Dict[str, Any],
    local_blocks: Optional[List[Dict[str, Any]]] = None,
    masked_type: str = "",
) -> Tuple[List[str], Dict[str, Any]]:
    """
    Retrieve external blocks using RTL-Repo's BM25search module.
    
    This uses the same external retrieval pipeline as RTL-Repo main system:
    - Uses RTL-Repo format prompt for proper local block building
    - File-level coarse-to-fine ranking
    - Multi-channel RRF fusion
    - Identifier and structure keyword matching
    
    Args:
        rtlrepo_prompt: Query text in RTL-Repo prompt format (with // Repo Name: and // Path: headers)
        target_file_path: Target file path for context
        external_corpus_path: Path to external corpus
        external_prepend_blocks: Number of external blocks to retrieve
        config: Retrieval configuration
    
    Returns:
        Tuple of (rendered external block lines, retrieval inspection dict)
    """
    if not external_corpus_path or external_prepend_blocks <= 0:
        return [], {}
    
    try:
        # Use RTL-Repo's inspect_retrieval for full retrieval pipeline
        # This properly handles both local and external retrieval
        inspection = BM25search.inspect_retrieval(
            prompt=rtlrepo_prompt,
            output_path="result.txt",
            block_order=config.get("bm25_block_order", "ascending"),
            merge_overlapping_blocks=config.get("bm25_merge_overlapping_blocks", False),
            top_k=config.get("bm25_top_k_blocks", 10),
            retriever_specs=[
                {"name": "local_bm25", "type": "bm25", "source": "local", "enabled": True, "weight": 1.0},
                {"name": "external_bm25", "type": "bm25", "source": "external", "enabled": True, "weight": 1.0},
            ],
            external_corpus_path=external_corpus_path,
            external_prepend_blocks=external_prepend_blocks,
            external_file_top_k=config.get("bm25_external_file_top_k", 24),
            fusion_k=config.get("retrieval_fusion_k", 60),
            query_file_path=target_file_path,
            local_blocks=local_blocks,
            masked_type=masked_type,
            enable_external_file_coarse_to_fine=config.get("enable_external_file_coarse_to_fine", True),
            enable_external_composite_file_ranking=config.get("enable_external_composite_file_ranking", True),
            enable_external_filename_match_boost=config.get("enable_external_filename_match_boost", False),
            enable_external_generic_large_file_penalty=config.get("enable_external_generic_large_file_penalty", False),
        )
        
        if isinstance(inspection, dict):
            ordered_external_items = inspection.get("ordered_external_items", [])
            inspection_dict = inspection
        elif isinstance(inspection, list):
            ordered_external_items = inspection
            inspection_dict = {"ordered_external_items": inspection}
        else:
            ordered_external_items = []
            inspection_dict = {}
        selected_external_items = ordered_external_items[:external_prepend_blocks]
        output_lines = BM25search._render_selected_items(selected_external_items)
        
        return output_lines, inspection_dict
        
    except Exception as e:
        print(f"Warning: External retrieval failed: {e}")
        import traceback
        traceback.print_exc()
        return [], {}


def build_completion_prompt(
    request: Dict[str, Any],
    prefix: str,
    suffix: str,
    retrieved_lines: List[str],
    doc_lines: List[str] | None = None,
    response_lines: int = 20,
    include_suffix: bool = True,
    include_shape_hint: bool = True,
    use_strict_boundary_constraints: bool = True,
    place_short_right_context_at_end: bool = True,
    short_right_context_max_lines: int = 20,
) -> List[str]:
    """
    Build the complete prompt for LLM generation.
    
    Args:
        prefix: Code before the placeholder
        suffix: Code after the placeholder
        retrieved_lines: Retrieved context blocks
        response_lines: Expected number of completion lines
        include_suffix: Whether to include suffix as right context
    
    Returns:
        List of prompt lines
    """
    prompt_lines = []
    deferred_suffix_lines: List[str] = []

    if doc_lines:
        prompt_lines.extend(doc_lines)
    
    # Add retrieved blocks first
    if retrieved_lines:
        prompt_lines.extend(retrieved_lines)
    
    # Add right context reference (suffix)
    if include_suffix and suffix:
        suffix_lines = get_right_context_lines(request, suffix)
        if suffix_lines:
            if place_short_right_context_at_end and len(suffix_lines) <= max(0, short_right_context_max_lines):
                deferred_suffix_lines = list(suffix_lines)
            else:
                prompt_lines.append("")
                prompt_lines.append("===== Right context reference (after placeholder) =====")
                prompt_lines.extend(suffix_lines)
                prompt_lines.append(
                    "===== The block above is additional right-context reference. "
                    "Still output only the missing completion code. ====="
                )

    shape_hint_lines = build_block_shape_hint(request) if include_shape_hint else []
    if shape_hint_lines:
        prompt_lines.append("")
        prompt_lines.extend(shape_hint_lines)

    if use_strict_boundary_constraints:
        prompt_lines.append("")
        prompt_lines.extend(STRICT_BOUNDARY_CONSTRAINTS.splitlines())
    
    # Add the prefix (code to be completed)
    prompt_lines.append("")
    prompt_lines.append("===== Code to be completed =====")
    prompt_lines.extend(non_empty_lines(prefix))

    # Add generation instruction
    prompt_lines.append("")
    prompt_lines.append(REALBENCH_PROMPT_TEMPLATE.format(response_lines=response_lines))

    if deferred_suffix_lines:
        prompt_lines.append("")
        prompt_lines.append("===== Right context reference (after placeholder) =====")
        prompt_lines.extend(deferred_suffix_lines)
        prompt_lines.append(
            "===== The block above is additional right-context reference. "
            "Use it only to locate the placeholder boundary; still output only the missing completion code. ====="
        )
    
    return prompt_lines


def render_prompt_text(prompt_lines: List[str]) -> str:
    prompt_lines = normalize_prompt_lines(prompt_lines)
    return "\n".join(prompt_lines) + "\n"


def normalize_prompt_lines(prompt_lines: List[Any]) -> List[str]:
    normalized: List[str] = []

    def _append_flattened(item: Any) -> None:
        if item is None:
            return
        if isinstance(item, (list, tuple)):
            for nested in item:
                _append_flattened(nested)
            return
        normalized.append(str(item))

    for item in prompt_lines:
        _append_flattened(item)
    return normalized


def trim_prompt_lines(
    prompt_lines: List[str],
    max_tokens: int = 8192,
    token_counter: Any = None,
    random_seed: Any = None,
) -> Tuple[List[str], Dict[str, Any]]:
    prompt_lines = normalize_prompt_lines(prompt_lines)
    rng = random.Random(str(random_seed) if random_seed is not None else "rtlrepo_trim")

    def _count_lines(lines: List[str]) -> Tuple[Optional[int], Dict[str, Any]]:
        prompt_text = "\n".join(lines) + "\n"
        return count_prompt_tokens(prompt_text, token_counter)

    def _trim_head_lines(lines: List[str], budget: int) -> List[str]:
        if token_counter is None or not lines:
            return lines
        candidate = list(lines)
        iterations = 0
        while candidate and iterations < 1000:
            current_tokens, _ = _count_lines(candidate)
            if current_tokens is None or current_tokens <= budget:
                return candidate
            if len(candidate) <= 1:
                break
            candidate = candidate[1:]
            iterations += 1
        return candidate[-1:] if candidate else []

    def _split_sections(lines: List[str]) -> Tuple[List[str], List[List[str]], List[str]]:
        retrieval_blocks: List[List[str]] = []
        preamble_lines: List[str] = []
        completion_lines: List[str] = []

        code_marker_index = None
        for index, line in enumerate(lines):
            if str(line).strip() == "===== Code to be completed =====":
                code_marker_index = index
                break

        prefix_lines = lines if code_marker_index is None else lines[:code_marker_index]
        completion_lines = [] if code_marker_index is None else lines[code_marker_index:]

        current_block = None
        for line in prefix_lines:
            if (
                str(line).startswith("===== block ")
                or str(line).startswith("===== doc chunk ")
                or str(line).startswith("===== Retrieved context =====")
                or str(line).startswith("===== Retrieved document =====")
            ):
                if current_block is not None:
                    retrieval_blocks.append(current_block)
                current_block = [line]
                continue

            if current_block is not None:
                current_block.append(line)
            else:
                preamble_lines.append(line)

        if current_block is not None:
            retrieval_blocks.append(current_block)

        return preamble_lines, retrieval_blocks, completion_lines

    def _parse_block_priority(block_lines: List[str]) -> float:
        for line in block_lines[:6]:
            match = re.search(r"token_overlap_cosine:\s*([0-9]*\.?[0-9]+)", str(line))
            if match:
                try:
                    return -float(match.group(1))
                except ValueError:
                    return float("inf")
            match = re.search(r"score[:：]\s*([0-9]*\.?[0-9]+)", str(line))
            if match:
                try:
                    return float(match.group(1))
                except ValueError:
                    return float("inf")
        return float("inf")

    def _classify_block_source(block_lines: List[str]) -> str:
        source = "unknown"
        retrievers_line = ""
        for line in block_lines[:8]:
            text = str(line)
            if text.startswith("===== Retrieved document =====") or text.startswith("===== doc chunk "):
                return "file"
            if text.startswith("// Retrieval source:"):
                source = text.split(":", 1)[1].strip().lower()
            elif text.startswith("// Retrieval retriever(s):"):
                retrievers_line = text.split(":", 1)[1].strip().lower()

        if "in_file_bm25" in retrievers_line or source == "in_file":
            return "infile"
        if source == "external":
            return "external"
        if source == "local":
            return "local"
        if source == "file":
            return "file"
        return "local"

    def _choose_block_to_remove(current_blocks: List[List[str]]) -> int:
        grouped_indices: Dict[str, List[int]] = {
            "external": [],
            "local": [],
            "file": [],
            "infile": [],
        }
        for index, block in enumerate(current_blocks):
            grouped_indices.setdefault(_classify_block_source(block), []).append(index)

        if grouped_indices["external"]:
            return grouped_indices["external"][0]

        competing_groups = [
            group_name
            for group_name in ("local", "file", "infile")
            if grouped_indices[group_name]
        ]
        if competing_groups:
            max_count = max(len(grouped_indices[group_name]) for group_name in competing_groups)
            candidates = [
                group_name
                for group_name in competing_groups
                if len(grouped_indices[group_name]) == max_count
            ]
            chosen_group = candidates[0] if len(candidates) == 1 else rng.choice(candidates)
            return grouped_indices[chosen_group][0]

        return 0

    def _count_block_groups(blocks: List[List[str]]) -> Dict[str, int]:
        counts = {
            "external": 0,
            "local": 0,
            "file": 0,
            "infile": 0,
        }
        for block in blocks:
            counts.setdefault(_classify_block_source(block), 0)
            counts[_classify_block_source(block)] += 1
        return counts

    def _flatten_sections(preamble_lines: List[str], retrieval_blocks: List[List[str]], completion_lines: List[str]) -> List[str]:
        flattened: List[str] = []
        flattened.extend(preamble_lines)
        for block in retrieval_blocks:
            flattened.extend(block)
        flattened.extend(completion_lines)
        return flattened

    def _trim_completion_preserving_structure(preamble_lines: List[str], completion_lines: List[str], budget: int) -> List[str]:
        candidate_lines = (preamble_lines or []) + (completion_lines or [])
        if token_counter is None or not candidate_lines:
            return candidate_lines

        candidate_tokens, _ = _count_lines(candidate_lines)
        if candidate_tokens is None or candidate_tokens <= budget:
            return list(candidate_lines)

        marker_index = None
        for index, line in enumerate(completion_lines):
            if str(line).strip() == "===== Code to be completed =====":
                marker_index = index
                break

        protected_completion = list(completion_lines)
        body_start = marker_index + 1 if marker_index is not None else 0
        body_lines = protected_completion[body_start:]

        while True:
            current_lines = (preamble_lines or []) + protected_completion
            current_tokens, _ = _count_lines(current_lines)
            if current_tokens is None or current_tokens <= budget:
                return current_lines
            if body_lines:
                body_lines = body_lines[1:]
                protected_completion = []
                if marker_index is not None:
                    protected_completion.append(completion_lines[marker_index])
                protected_completion.extend(body_lines)
                continue
            break

        minimal_completion: List[str] = []
        if marker_index is not None:
            minimal_completion.append(completion_lines[marker_index])

        minimal_lines = (preamble_lines or []) + minimal_completion
        minimal_tokens, _ = _count_lines(minimal_lines) if minimal_lines else (0, {})
        if minimal_tokens is None or minimal_tokens <= budget:
            return minimal_lines

        if marker_index is not None:
            marker_line = completion_lines[marker_index]
            marker_tokens, _ = _count_lines([marker_line])
            if marker_tokens is None or marker_tokens <= budget:
                return [marker_line]

        return _trim_head_lines(minimal_completion or candidate_lines, budget)

    full_text = "\n".join(prompt_lines) + "\n"
    prompt_tokens_before, token_meta = count_prompt_tokens(full_text, token_counter)

    if prompt_tokens_before is not None and prompt_tokens_before <= max_tokens:
        return prompt_lines, {
            "trimmed": False,
            "method": "tokenizer_block_priority",
            "prompt_tokens_before": prompt_tokens_before,
            "prompt_tokens_after": prompt_tokens_before,
            "max_tokens": max_tokens,
            "counter": token_meta,
        }

    if prompt_tokens_before is not None:
        preamble_lines, retrieval_blocks, completion_lines = _split_sections(prompt_lines)
        if retrieval_blocks:
            current_blocks = list(retrieval_blocks)
            removed_blocks = 0
            removed_block_counts = {
                "external": 0,
                "local": 0,
                "file": 0,
                "infile": 0,
            }
            removal_trace: List[str] = []

            while current_blocks:
                candidate_lines = _flatten_sections(preamble_lines, current_blocks, completion_lines)
                candidate_tokens, _ = _count_lines(candidate_lines)
                if candidate_tokens is None or candidate_tokens <= max_tokens:
                    return candidate_lines, {
                        "trimmed": True,
                        "method": "tokenizer_block_priority",
                        "prompt_tokens_before": prompt_tokens_before,
                        "prompt_tokens_after": candidate_tokens,
                        "max_tokens": max_tokens,
                        "iterations": removed_blocks,
                        "removed_retrieval_blocks": removed_blocks,
                        "removed_block_counts": removed_block_counts,
                        "remaining_block_counts": _count_block_groups(current_blocks),
                        "removal_trace": removal_trace,
                        "counter": token_meta,
                    }

                remove_index = _choose_block_to_remove(current_blocks)
                removed_source = _classify_block_source(current_blocks[remove_index])
                removal_trace.append(removed_source)
                removed_block_counts.setdefault(removed_source, 0)
                removed_block_counts[removed_source] += 1
                current_blocks.pop(remove_index)
                removed_blocks += 1

            completion_only = preamble_lines + completion_lines
            completion_only_tokens, _ = _count_lines(completion_only) if completion_only else (0, {})
            if completion_only_tokens is not None and completion_only_tokens <= max_tokens:
                return completion_only, {
                    "trimmed": True,
                    "method": "tokenizer_block_priority_completion_only",
                    "prompt_tokens_before": prompt_tokens_before,
                    "prompt_tokens_after": completion_only_tokens,
                    "max_tokens": max_tokens,
                    "iterations": removed_blocks,
                    "removed_retrieval_blocks": removed_blocks,
                    "removed_block_counts": removed_block_counts,
                    "remaining_block_counts": _count_block_groups([]),
                    "removal_trace": removal_trace,
                    "counter": token_meta,
                }

            trimmed_completion = _trim_completion_preserving_structure(preamble_lines, completion_lines, max_tokens)
            trimmed_completion_tokens, _ = _count_lines(trimmed_completion) if trimmed_completion else (0, {})
            return trimmed_completion, {
                "trimmed": True,
                "method": "tokenizer_block_priority_completion_trim",
                "prompt_tokens_before": prompt_tokens_before,
                "prompt_tokens_after": trimmed_completion_tokens,
                "max_tokens": max_tokens,
                "iterations": removed_blocks,
                "removed_retrieval_blocks": removed_blocks,
                "removed_block_counts": removed_block_counts,
                "remaining_block_counts": _count_block_groups([]),
                "removal_trace": removal_trace,
                "counter": token_meta,
            }

        trimmed_lines = _trim_head_lines(prompt_lines, max_tokens)
        trimmed_tokens, _ = _count_lines(trimmed_lines) if trimmed_lines else (0, {})
        return trimmed_lines, {
            "trimmed": True,
            "method": "tokenizer_head_trim",
            "prompt_tokens_before": prompt_tokens_before,
            "prompt_tokens_after": trimmed_tokens,
            "max_tokens": max_tokens,
            "counter": token_meta,
        }

    max_chars = max_tokens * 4
    total_chars = sum(len(line) + 1 for line in prompt_lines)
    if total_chars <= max_chars:
        return prompt_lines, {
            "trimmed": False,
            "method": "char_approx_block_priority",
            "prompt_chars_before": total_chars,
            "prompt_chars_after": total_chars,
            "max_tokens": max_tokens,
            "approx_chars_per_token": 4,
            "counter": token_meta,
        }

    preamble_lines, retrieval_blocks, completion_lines = _split_sections(prompt_lines)
    if retrieval_blocks:
        current_blocks = list(retrieval_blocks)
        removed_blocks = 0
        removed_block_counts = {
            "external": 0,
            "local": 0,
            "file": 0,
            "infile": 0,
        }
        removal_trace: List[str] = []
        while current_blocks:
            candidate_lines = _flatten_sections(preamble_lines, current_blocks, completion_lines)
            candidate_chars = sum(len(line) + 1 for line in candidate_lines)
            if candidate_chars <= max_chars:
                return candidate_lines, {
                    "trimmed": True,
                    "method": "char_approx_block_priority",
                    "prompt_chars_before": total_chars,
                    "prompt_chars_after": candidate_chars,
                    "max_tokens": max_tokens,
                    "approx_chars_per_token": 4,
                    "removed_retrieval_blocks": removed_blocks,
                    "removed_block_counts": removed_block_counts,
                    "remaining_block_counts": _count_block_groups(current_blocks),
                    "removal_trace": removal_trace,
                    "counter": token_meta,
                }
            remove_index = _choose_block_to_remove(current_blocks)
            removed_source = _classify_block_source(current_blocks[remove_index])
            removal_trace.append(removed_source)
            removed_block_counts.setdefault(removed_source, 0)
            removed_block_counts[removed_source] += 1
            current_blocks.pop(remove_index)
            removed_blocks += 1

        completion_only = preamble_lines + completion_lines
        completion_only_chars = sum(len(line) + 1 for line in completion_only)
        if completion_only_chars <= max_chars:
            return completion_only, {
                "trimmed": True,
                "method": "char_approx_block_priority_completion_only",
                "prompt_chars_before": total_chars,
                "prompt_chars_after": completion_only_chars,
                "max_tokens": max_tokens,
                "approx_chars_per_token": 4,
                "removed_retrieval_blocks": removed_blocks,
                "removed_block_counts": removed_block_counts,
                "remaining_block_counts": _count_block_groups([]),
                "removal_trace": removal_trace,
                "counter": token_meta,
            }

    trimmed_lines = list(prompt_lines)
    while trimmed_lines and sum(len(line) + 1 for line in trimmed_lines) > max_chars:
        if len(trimmed_lines) <= 1:
            break
        trimmed_lines = trimmed_lines[1:]
    trimmed_chars = sum(len(line) + 1 for line in trimmed_lines)
    return trimmed_lines, {
        "trimmed": True,
        "method": "char_approx_head_trim",
        "prompt_chars_before": total_chars,
        "prompt_chars_after": trimmed_chars,
        "max_tokens": max_tokens,
        "approx_chars_per_token": 4,
        "counter": token_meta,
    }


def build_stop_sequences(retrieval_config: Dict[str, Any]) -> List[str] | None:
    stop = retrieval_config.get("stop")
    if stop is None:
        return None
    if stop == "none":
        return None
    if isinstance(stop, str):
        stop = [stop]
    if not isinstance(stop, list):
        return None
    cleaned = [item for item in stop if isinstance(item, str) and item]
    return cleaned or None


def resolve_request_controls(
    backend_config: Dict[str, Any],
    retrieval_config: Dict[str, Any],
) -> Tuple[Any, Any]:
    model_name = str(backend_config.get("model_name", "")).lower()
    reasoning_effort = retrieval_config.get("reasoning_effort", backend_config.get("reasoning_effort"))
    text_verbosity = retrieval_config.get("text_verbosity", backend_config.get("text_verbosity"))

    if reasoning_effort is None and model_name.startswith("gpt-5"):
        reasoning_effort = "minimal"
    if text_verbosity is None and model_name.startswith("gpt-5"):
        text_verbosity = "low"

    return reasoning_effort, text_verbosity


def call_llm_backend(
    prompt_lines: List[str],
    suffix: str,
    backend_config: Dict[str, Any],
    retrieval_config: Dict[str, Any],
) -> Tuple[str, Dict[str, Any]]:
    """
    Call LLM backend for completion.
    
    Args:
        prompt_lines: Built prompt lines
        suffix: Right context (suffix)
        backend_config: Backend configuration
        retrieval_config: Retrieval/generation configuration
    
    Returns:
        Generated completion string
    """
    prompt_lines = normalize_prompt_lines(prompt_lines)
    prompt_text = "\n".join(prompt_lines)
    max_tokens = int(backend_config.get("max_tokens", retrieval_config.get("max_tokens", 256)))
    temperature = backend_config.get("temperature", 0.1)
    stop = build_stop_sequences(retrieval_config)
    if stop is None:
        stop = backend_config.get("stop")
    timeout_seconds = backend_config.get("client_timeout_seconds")
    system_prompt = backend_config.get("system_prompt")
    reasoning_effort, text_verbosity = resolve_request_controls(backend_config, retrieval_config)
    
    backend_type = backend_config.get("type", "openai_responses_api")
    if backend_type != "local_hf_causal_lm" and not LLM_BACKEND_AVAILABLE:
        if allow_mock_fallback():
            return _mock_completion(prompt_lines, retrieval_config)
        raise RuntimeError("LLMload_1 unavailable and REALBENCH_ALLOW_MOCK_FALLBACK is disabled")
    
    try:
        backend_diag: Dict[str, Any] = {
            "backend_type": backend_type,
            "model_name": backend_config.get("model_name") or backend_config.get("model_path"),
            "system_prompt_enabled": bool(system_prompt),
            "stop_count": len(stop) if isinstance(stop, list) else 0,
            "timeout_seconds": timeout_seconds,
            "reasoning_effort": reasoning_effort,
            "text_verbosity": text_verbosity,
        }
        if backend_type == "fim_api":
            output = LLMload_1.run_fim_inference(
                api_base=backend_config["api_base"],
                api_key=backend_config["api_key"],
                model_name=backend_config["model_name"],
                prompt=prompt_text,
                suffix=suffix,
                max_tokens=max_tokens,
                temperature=temperature,
                stop=stop,
                timeout_seconds=timeout_seconds,
            )
        elif backend_type == "openai_responses_api":
            # Compose prompt with suffix
            if backend_config.get("append_suffix_to_prompt", False) and suffix:
                full_prompt = prompt_text + "\n\n===== Additional right-context reference =====\n" + suffix
            else:
                full_prompt = prompt_text
            
            output, _ = LLMload_1.run_responses_inference(
                api_base=backend_config["api_base"],
                api_key=backend_config["api_key"],
                model_name=backend_config["model_name"],
                prompt=full_prompt,
                max_tokens=max_tokens,
                temperature=temperature,
                system_prompt=system_prompt,
                chat_fallback=backend_config.get("chat_fallback", True),
                stop=stop,
                reasoning_effort=reasoning_effort,
                text_verbosity=text_verbosity,
                timeout_seconds=timeout_seconds,
            )
        elif backend_type == "openai_chat_api":
            if backend_config.get("append_suffix_to_prompt", False) and suffix:
                full_prompt = prompt_text + "\n\n===== Additional right-context reference =====\n" + suffix
            else:
                full_prompt = prompt_text
            
            output, chat_logprobs = LLMload_1.run_chat_inference(
                api_base=backend_config["api_base"],
                api_key=backend_config["api_key"],
                model_name=backend_config["model_name"],
                prompt=full_prompt,
                max_tokens=max_tokens,
                temperature=temperature,
                system_prompt=system_prompt,
                stop=stop,
                reasoning_effort=reasoning_effort,
                text_verbosity=text_verbosity,
                timeout_seconds=timeout_seconds,
            )
            backend_diag["logprobs_content"] = convert_logprobs_to_serializable(chat_logprobs)
        elif backend_type == "local_hf_causal_lm":
            model_path = backend_config.get("model_path", DEFAULT_LOCAL_MODEL_PATH)
            local_prompt = prompt_text
            if not backend_config.get("local_plain_completion_prompt", True):
                local_prompt = prompt_text
                if suffix and backend_config.get("append_suffix_to_prompt", False):
                    local_prompt += (
                        "\n\n===== Additional right-context reference =====\n"
                        + suffix
                        + "\n===== The block above is additional right-context reference. "
                        + "Still output only the missing completion code. ====="
                    )

            local_loader = importlib.import_module("LLMload_Starcoder2_7b")
            output, local_logprobs = local_loader.run_llm_inference(
                model_path=model_path,
                input_text=local_prompt,
                temperature=temperature,
                max_tokens=max_tokens,
            )
            local_debug = getattr(local_logprobs, "debug", None)
            if isinstance(local_debug, dict):
                backend_diag["local_debug"] = local_debug
        else:
            raise ValueError(f"Unknown backend type: {backend_type}")

        text_output, output_diag = _coerce_backend_output_text(output)
        backend_diag["raw_output"] = output_diag
        return text_output or "", backend_diag
    
    except Exception as e:
        if allow_mock_fallback():
            print(f"Warning: LLM backend call failed: {e}")
            return _mock_completion(prompt_lines, retrieval_config), {
                "backend_type": backend_type,
                "model_name": backend_config.get("model_name") or backend_config.get("model_path"),
                "mock_fallback": True,
                "error": str(e),
            }
        raise


def _mock_completion(prompt_lines: List[str], config: Dict[str, Any]) -> str:
    """
    Generate mock completion for testing when LLM backend unavailable.
    
    Returns a placeholder completion that can be used for pipeline testing.
    """
    response_lines = config.get("response_lines", 20)
    
    # Simple mock: return a few generic Verilog lines
    mock_lines = [
        "// Mock completion (LLM backend not available)",
        "reg [31:0] mock_signal;",
        "always @(posedge clk) begin",
        "    if (reset) begin",
        "        mock_signal <= 32'h0;",
        "    end else begin",
        "        mock_signal <= mock_signal + 1;",
        "    end",
        "end",
    ]
    
    return "\n".join(mock_lines[:response_lines])


def normalize_compare_line(line: str) -> str:
    return re.sub(r"\s+", " ", str(line).strip())


def find_suffix_overlap_start(
    candidate_lines: List[str],
    suffix_lines: List[str],
) -> Tuple[Optional[int], Dict[str, Any]]:
    if not candidate_lines or not suffix_lines:
        return None, {"matched": False}

    candidate_norm = [normalize_compare_line(line) for line in candidate_lines]
    suffix_norm = [normalize_compare_line(line) for line in suffix_lines]

    best_match: Optional[Tuple[int, int, int]] = None
    for cand_index, cand_line in enumerate(candidate_norm):
        if not cand_line:
            continue
        for suffix_index, suffix_line in enumerate(suffix_norm):
            if cand_line != suffix_line:
                continue

            run_length = 1
            while (
                cand_index + run_length < len(candidate_norm)
                and suffix_index + run_length < len(suffix_norm)
                and candidate_norm[cand_index + run_length] == suffix_norm[suffix_index + run_length]
            ):
                run_length += 1

            is_good_anchor = run_length >= 2 or suffix_index == 0
            if not is_good_anchor:
                continue

            candidate = (cand_index, suffix_index, run_length)
            if best_match is None or candidate[0] < best_match[0] or (
                candidate[0] == best_match[0] and candidate[2] > best_match[2]
            ):
                best_match = candidate

    if best_match is None:
        return None, {"matched": False}

    cand_index, suffix_index, run_length = best_match
    return cand_index, {
        "matched": True,
        "candidate_index": cand_index,
        "suffix_index": suffix_index,
        "run_length": run_length,
    }


def find_prefix_overlap_run(
    candidate_lines: List[str],
    prefix_lines: List[str],
) -> Dict[str, Any]:
    if not candidate_lines or not prefix_lines:
        return {"matched": False}

    candidate_norm = [normalize_compare_line(line) for line in candidate_lines]
    prefix_norm = [normalize_compare_line(line) for line in prefix_lines]

    best_match: Optional[Tuple[int, int]] = None
    first_candidate = candidate_norm[0]
    if not first_candidate:
        return {"matched": False}

    for prefix_index, prefix_line in enumerate(prefix_norm):
        if prefix_line != first_candidate:
            continue
        run_length = 1
        while (
            run_length < len(candidate_norm)
            and prefix_index + run_length < len(prefix_norm)
            and candidate_norm[run_length] == prefix_norm[prefix_index + run_length]
        ):
            run_length += 1
        if run_length >= 2 and (best_match is None or run_length > best_match[1]):
            best_match = (prefix_index, run_length)

    if best_match is None:
        return {"matched": False}

    prefix_index, run_length = best_match
    return {
        "matched": True,
        "prefix_index": prefix_index,
        "run_length": run_length,
    }


def compress_repeated_lines(candidate_lines: List[str]) -> Tuple[List[str], Dict[str, Any]]:
    if not candidate_lines:
        return candidate_lines, {"changed": False}

    out: List[str] = []
    previous_norm = None
    repeat_count = 0
    removed = 0
    for line in candidate_lines:
        current_norm = normalize_compare_line(line)
        if current_norm == previous_norm:
            repeat_count += 1
        else:
            previous_norm = current_norm
            repeat_count = 1

        if repeat_count > 2:
            removed += 1
            continue
        out.append(line)

    return out, {
        "changed": removed > 0,
        "removed_lines": removed,
        "final_line_count": len(out),
    }


def make_ranked_candidate_item(
    block: Dict[str, Any],
    score: float,
    retriever_name: str,
    token_cosine: Optional[float] = None,
) -> Dict[str, Any]:
    item = {
        "block": block,
        "fused_score": float(score),
        "retrievers": [retriever_name],
        "raw_scores": {retriever_name: float(score)},
    }
    if token_cosine is not None:
        item["absolute_scores"] = {"token_cosine": float(token_cosine)}
    return item


def collect_retrieval_fallback_candidate_items(
    local_blocks: List[Dict[str, Any]],
    query_tokens: List[str],
    retrieval_inspection: Dict[str, Any],
    fallback_config: Dict[str, Any],
) -> List[Dict[str, Any]]:
    max_candidates = int(fallback_config.get("max_candidates", 8))
    prefer_local = bool(fallback_config.get("prefer_local", True))

    ordered_local_items = list(retrieval_inspection.get("ordered_local_items", []))
    ordered_external_items = list(retrieval_inspection.get("ordered_external_items", []))

    if not ordered_local_items and local_blocks:
        scored = score_blocks_bm25(local_blocks, query_tokens)
        scored.sort(key=lambda item: item[1], reverse=True)
        ordered_local_items = [
            make_ranked_candidate_item(block=block, score=score, retriever_name="local_bm25_fallback")
            for block, score in scored[:max_candidates]
        ]

    candidates: List[Dict[str, Any]] = []
    local_quota = max_candidates if not ordered_external_items else max(1, max_candidates // 2)
    external_quota = max_candidates if not ordered_local_items else max(1, max_candidates // 2)

    local_slice = ordered_local_items[:local_quota]
    external_slice = ordered_external_items[:external_quota]
    if prefer_local:
        candidates.extend(local_slice)
        candidates.extend(external_slice)
    else:
        candidates.extend(external_slice)
        candidates.extend(local_slice)
    return candidates


def score_retrieval_fallback_candidate(
    request: Dict[str, Any],
    candidate_item: Dict[str, Any],
    candidate_lines: List[str],
    clip_meta: Dict[str, Any],
    key_identifiers: List[str],
    prefer_local: bool,
) -> Dict[str, Any]:
    block = candidate_item.get("block", {})
    text = "\n".join(candidate_lines).lower()
    file_paths = [str(path) for path in (block.get("file_paths") or [])]
    file_label = file_paths[0] if file_paths else ""
    file_label_lower = file_label.lower()
    target_path = str(request.get("target", {}).get("path", "")).lower()
    target_stem = Path(target_path).stem.lower()
    same_file = bool(file_label_lower and file_label_lower == target_path)
    same_stem = bool(file_label_lower and target_stem and target_stem in Path(file_label_lower).stem.lower())
    identifier_hits = [token for token in key_identifiers if token in text]
    type_span_meta = clip_meta.get("type_span_extraction", {})
    type_matched = bool(type_span_meta.get("matched", False))
    source = str(block.get("source", "unknown"))
    source_pref = 1 if (prefer_local and source == "local") or ((not prefer_local) and source == "external") else 0
    fused_score = float(candidate_item.get("fused_score", 0.0) or 0.0)

    return {
        "same_file": same_file,
        "same_stem": same_stem,
        "identifier_hits": identifier_hits,
        "identifier_hit_count": len(identifier_hits),
        "type_matched": type_matched,
        "source": source,
        "source_pref": source_pref,
        "fused_score": fused_score,
        "sort_key": (
            1 if same_file else 0,
            1 if same_stem else 0,
            1 if type_matched else 0,
            len(identifier_hits),
            source_pref,
            fused_score,
        ),
    }


def build_retrieval_fallback_completion(
    request: Dict[str, Any],
    candidate_items: List[Dict[str, Any]],
    search_seed: str,
    fallback_config: Dict[str, Any],
    postprocess_config: Optional[Dict[str, Any]] = None,
) -> Tuple[str, Dict[str, Any]]:
    if not fallback_config.get("enabled", False):
        return "", {"enabled": False, "used": False}

    postprocess_config = postprocess_config or DEFAULT_COMPLETION_POSTPROCESS_CONFIG
    enable_clipping = bool(postprocess_config.get("enable_clipping", False))

    masked_type = get_masked_type(request)
    key_identifiers = extract_retrieval_gate_identifiers(
        str(request.get("target", {}).get("path", "")),
        search_seed,
    )
    prefer_local = bool(fallback_config.get("prefer_local", True))
    empty_line_threshold = int(fallback_config.get("empty_line_threshold", 0))

    evaluated: List[Dict[str, Any]] = []
    best: Optional[Tuple[Tuple[Any, ...], List[str], Dict[str, Any], Dict[str, Any]]] = None

    for index, candidate_item in enumerate(candidate_items, start=1):
        block = candidate_item.get("block", {})
        raw_lines = [str(line).rstrip() for line in block.get("block_lines", []) if str(line).strip()]
        if not raw_lines:
            continue

        if enable_clipping:
            clipped_lines, clip_meta = clip_completion_lines_for_request(request, raw_lines)
        else:
            clipped_lines = list(raw_lines)
            clip_meta = {
                "skipped": True,
                "reason": "completion_clipping_disabled",
                "original_line_count": len(raw_lines),
                "final_line_count": len(raw_lines),
            }
        if len(clipped_lines) <= empty_line_threshold:
            continue

        candidate_score = score_retrieval_fallback_candidate(
            request=request,
            candidate_item=candidate_item,
            candidate_lines=clipped_lines,
            clip_meta=clip_meta,
            key_identifiers=key_identifiers,
            prefer_local=prefer_local,
        )
        lowered_lines = [line.strip().lower() for line in clipped_lines if line.strip()]
        if masked_type == "function" and not candidate_score["type_matched"]:
            continue
        if masked_type == "task" and not candidate_score["type_matched"]:
            continue
        if masked_type == "always" and not any(line.startswith("always") for line in lowered_lines):
            continue
        if masked_type in {"assign", "assign_cluster"} and not any(line.startswith("assign") for line in lowered_lines):
            continue

        if not (
            candidate_score["same_file"]
            or candidate_score["same_stem"]
            or candidate_score["identifier_hit_count"] > 0
            or masked_type in {"assign", "assign_cluster"}
        ):
            continue

        evaluated.append(
            {
                "rank": index,
                "source": candidate_score["source"],
                "file_paths": block.get("file_paths", []),
                "identifier_hits": candidate_score["identifier_hits"],
                "type_matched": candidate_score["type_matched"],
                "line_count": len(clipped_lines),
                "fused_score": candidate_score["fused_score"],
                "preview": "\n".join(clipped_lines[:6]),
            }
        )

        current = (candidate_score["sort_key"], clipped_lines, clip_meta, candidate_score)
        if best is None or current[0] > best[0]:
            best = current

    if best is None:
        return "", {
            "enabled": True,
            "used": False,
            "masked_type": masked_type,
            "key_identifiers": key_identifiers,
            "evaluated_candidates": evaluated,
        }

    _, best_lines, best_clip_meta, best_score = best
    return "\n".join(best_lines), {
        "enabled": True,
        "used": True,
        "strategy": "retrieval_prefill",
        "masked_type": masked_type,
        "key_identifiers": key_identifiers,
        "selected_source": best_score["source"],
        "selected_identifier_hits": best_score["identifier_hits"],
        "selected_same_file": best_score["same_file"],
        "selected_same_stem": best_score["same_stem"],
        "selected_line_count": len(best_lines),
        "selected_clip_meta": best_clip_meta,
        "evaluated_candidates": evaluated,
    }


def detect_bad_completion_reason(
    request: Dict[str, Any],
    valid_lines: List[str],
    postprocess_meta: Dict[str, Any],
    fallback_config: Dict[str, Any],
) -> Optional[str]:
    empty_line_threshold = int(fallback_config.get("empty_line_threshold", 0))
    if len(valid_lines) <= empty_line_threshold:
        return "empty_or_too_short"

    lowered_lines = [line.strip().lower() for line in valid_lines if line.strip()]
    if any(line.startswith("=====") or "retrieval source:" in line for line in lowered_lines):
        return "leaked_retrieval_markup"
    if any(line.startswith("module ") or line == "endmodule" for line in lowered_lines):
        return "restarted_module_or_endmodule"

    clip_meta = postprocess_meta.get("clip", {})
    if clip_meta.get("cropped_by_suffix_overlap", False):
        return "overlapped_into_suffix"

    masked_type = get_masked_type(request)
    if masked_type == "always" and not any(line.startswith("always") for line in lowered_lines):
        return "missing_always_head"
    if masked_type in {"assign", "assign_cluster"} and not any(line.startswith("assign") for line in lowered_lines):
        return "missing_assign_head"
    if masked_type == "function" and not any(line.startswith("function") for line in lowered_lines):
        return "missing_function_head"
    if masked_type == "task" and not any(line.startswith("task") for line in lowered_lines):
        return "missing_task_head"

    return None


def extract_completion_span_by_mask_type(
    request: Dict[str, Any],
    candidate_lines: List[str],
) -> Tuple[List[str], Dict[str, Any]]:
    masked_item = get_primary_masked_item(request)
    masked_type = str(masked_item.get("type", "")).strip().lower()
    meta: Dict[str, Any] = {"masked_type": masked_type, "matched": False}
    if not masked_type or not candidate_lines:
        return candidate_lines, meta

    patterns = {
        "function": (
            re.compile(r"^\s*function\b", re.IGNORECASE),
            re.compile(r"^\s*endfunction\b", re.IGNORECASE),
        ),
        "task": (
            re.compile(r"^\s*task\b", re.IGNORECASE),
            re.compile(r"^\s*endtask\b", re.IGNORECASE),
        ),
    }
    if masked_type in patterns:
        start_re, end_re = patterns[masked_type]
        start_index = None
        end_index = None
        for idx, line in enumerate(candidate_lines):
            if start_index is None and start_re.search(line):
                start_index = idx
            if start_index is not None and end_re.search(line):
                end_index = idx
                break
        if start_index is not None and end_index is not None and end_index >= start_index:
            meta.update(
                {
                    "matched": True,
                    "strategy": "keyword_span",
                    "start_index": start_index,
                    "end_index": end_index,
                }
            )
            return candidate_lines[start_index : end_index + 1], meta
        return candidate_lines, meta

    if masked_type in {"assign", "assign_cluster"}:
        assign_lines = [line for line in candidate_lines if re.search(r"^\s*assign\b", line, re.IGNORECASE)]
        if assign_lines:
            meta.update({"matched": True, "strategy": "assign_only", "line_count": len(assign_lines)})
            return assign_lines, meta
        return candidate_lines, meta

    return candidate_lines, meta


def strip_leading_noise_for_masked_type(
    request: Dict[str, Any],
    candidate_lines: List[str],
) -> Tuple[List[str], Dict[str, Any]]:
    masked_type = get_masked_type(request)
    meta: Dict[str, Any] = {
        "masked_type": masked_type,
        "trimmed": False,
    }
    if not candidate_lines:
        return candidate_lines, meta

    start_patterns = {
        "function": re.compile(r"^\s*function\b", re.IGNORECASE),
        "task": re.compile(r"^\s*task\b", re.IGNORECASE),
        "always": re.compile(r"^\s*always(?:_(?:ff|comb|latch))?\b", re.IGNORECASE),
        "assign": re.compile(r"^\s*assign\b", re.IGNORECASE),
        "assign_cluster": re.compile(r"^\s*assign\b", re.IGNORECASE),
    }
    start_re = start_patterns.get(masked_type)
    if start_re is None:
        return candidate_lines, meta

    for idx, line in enumerate(candidate_lines):
        if start_re.search(line):
            if idx > 0:
                meta.update({"trimmed": True, "start_index": idx})
                return candidate_lines[idx:], meta
            return candidate_lines, meta
    return candidate_lines, meta


def truncate_at_invalid_block_boundary(
    request: Dict[str, Any],
    candidate_lines: List[str],
) -> Tuple[List[str], Dict[str, Any]]:
    masked_type = get_masked_type(request)
    meta: Dict[str, Any] = {
        "masked_type": masked_type,
        "truncated": False,
    }
    if not candidate_lines:
        return candidate_lines, meta

    boundary_patterns = [
        re.compile(r"^\s*=====", re.IGNORECASE),
        re.compile(r"^\s*//\s*path:\s*", re.IGNORECASE),
        re.compile(r"^\s*//\s*repo name:\s*", re.IGNORECASE),
        re.compile(r"^\s*module\b", re.IGNORECASE),
        re.compile(r"^\s*endmodule\b", re.IGNORECASE),
        re.compile(r"^\s*`timescale\b", re.IGNORECASE),
    ]

    allowed_at_head = []
    if masked_type == "function":
        allowed_at_head = [re.compile(r"^\s*function\b", re.IGNORECASE), re.compile(r"^\s*endfunction\b", re.IGNORECASE)]
    elif masked_type == "task":
        allowed_at_head = [re.compile(r"^\s*task\b", re.IGNORECASE), re.compile(r"^\s*endtask\b", re.IGNORECASE)]

    for idx, line in enumerate(candidate_lines):
        stripped = line.strip()
        if not stripped:
            continue
        if idx == 0 and any(pattern.search(line) for pattern in allowed_at_head):
            continue
        if any(pattern.search(line) for pattern in boundary_patterns):
            meta.update({"truncated": True, "boundary_index": idx, "boundary_line": stripped[:160]})
            return candidate_lines[:idx], meta
    return candidate_lines, meta


def drop_non_verilog_noise_lines(
    candidate_lines: List[str],
) -> Tuple[List[str], Dict[str, Any]]:
    meta: Dict[str, Any] = {
        "changed": False,
        "dropped_indices": [],
    }
    if not candidate_lines:
        return candidate_lines, meta

    filtered_lines: List[str] = []
    dropped_indices: List[int] = []
    for idx, line in enumerate(candidate_lines):
        stripped = line.strip()
        if not stripped:
            continue
        if re.fullmatch(r"[.=\-_*#/:\\]+", stripped):
            dropped_indices.append(idx)
            continue
        if re.fullmatch(r"(?:[.=\-_*#/:\\]\s*){4,}", stripped):
            dropped_indices.append(idx)
            continue
        if re.search(r"={4,}", stripped) and not re.search(r"<=|>=|==|!=|===|!==", stripped):
            dropped_indices.append(idx)
            continue
        filtered_lines.append(line)

    meta["changed"] = filtered_lines != candidate_lines
    meta["dropped_indices"] = dropped_indices
    meta["final_line_count"] = len(filtered_lines)
    return filtered_lines, meta


def clip_completion_lines_for_request(
    request: Dict[str, Any],
    candidate_lines: List[str],
) -> Tuple[List[str], Dict[str, Any]]:
    meta: Dict[str, Any] = {
        "is_block_level_mask": is_block_level_mask_request(request),
        "original_line_count": len(candidate_lines),
        "cropped_by_marker": False,
        "cropped_by_suffix_overlap": False,
    }
    if not candidate_lines:
        return candidate_lines, meta

    clipped_lines = list(candidate_lines)
    clipped_lines, dedup_meta = compress_repeated_lines(clipped_lines)
    meta["repeat_compression"] = dedup_meta

    marker_index = None
    for idx, line in enumerate(clipped_lines):
        if line.strip().startswith("====="):
            marker_index = idx
            break
    if marker_index is not None:
        clipped_lines = clipped_lines[:marker_index]
        meta["cropped_by_marker"] = True
        meta["marker_index"] = marker_index

    prefix = str(request.get("target", {}).get("prefix", ""))
    prefix_lines = [line.strip() for line in format_verilog_text(prefix).splitlines() if line.strip()]
    prefix_overlap = find_prefix_overlap_run(clipped_lines, prefix_lines)
    meta["prefix_overlap"] = prefix_overlap
    if prefix_overlap.get("matched", False):
        clipped_lines = clipped_lines[int(prefix_overlap["run_length"]) :]
        meta["cropped_repeated_prefix"] = True

    suffix = str(request.get("target", {}).get("suffix", ""))
    suffix_lines = [line.strip() for line in format_verilog_text(suffix).splitlines() if line.strip()]
    overlap_index, overlap_meta = find_suffix_overlap_start(clipped_lines, suffix_lines)
    meta["suffix_overlap"] = overlap_meta
    if overlap_index is not None:
        clipped_lines = clipped_lines[:overlap_index]
        meta["cropped_by_suffix_overlap"] = True

    clipped_lines, span_meta = extract_completion_span_by_mask_type(request, clipped_lines)
    meta["type_span_extraction"] = span_meta

    if is_block_level_mask_request(request):
        clipped_lines, leading_noise_meta = strip_leading_noise_for_masked_type(request, clipped_lines)
        meta["leading_noise_trim"] = leading_noise_meta

    clipped_lines, noise_meta = drop_non_verilog_noise_lines(clipped_lines)
    meta["non_verilog_noise_filter"] = noise_meta

    clipped_lines, boundary_meta = truncate_at_invalid_block_boundary(request, clipped_lines)
    meta["invalid_boundary_truncation"] = boundary_meta

    toxic_norms = {normalize_compare_line(line) for line in clipped_lines if normalize_compare_line(line)}
    if (
        toxic_norms
        and toxic_norms.issubset({"endmodule", "end"})
        and is_block_level_mask_request(request)
        and not span_meta.get("matched", False)
    ):
        meta["dropped_toxic_closers"] = True
        clipped_lines = []

    while clipped_lines and not clipped_lines[0].strip():
        clipped_lines.pop(0)
    while clipped_lines and not clipped_lines[-1].strip():
        clipped_lines.pop()

    meta["final_line_count"] = len(clipped_lines)
    return clipped_lines, meta


def process_completion_output(
    raw_output: str,
    request: Optional[Dict[str, Any]] = None,
    is_fim: bool = False,
    postprocess_config: Optional[Dict[str, Any]] = None,
) -> Tuple[List[str], Dict[str, Any]]:
    """
    Process raw LLM output to extract valid completion lines.
    
    Args:
        raw_output: Raw output from LLM
        is_fim: Whether output is from FIM mode
    
    Returns:
        List of valid code lines
    """
    postprocess_meta: Dict[str, Any] = {
        "is_fim": is_fim,
        "raw_line_count": 0,
    }
    postprocess_config = postprocess_config or DEFAULT_COMPLETION_POSTPROCESS_CONFIG
    enable_clipping = bool(postprocess_config.get("enable_clipping", False))

    if is_fim:
        # Handle FIM special tokens
        parts = raw_output.split("<｜fim_middle｜>")
        if len(parts) >= 2:
            middle = parts[1].split("<｜fim_suffix｜>")[0]
            lines = middle.split("\n")
        else:
            lines = raw_output.split("\n")
    else:
        lines = raw_output.split("\n")
    
    postprocess_meta["raw_line_count"] = len(lines)

    # Clean lines
    valid_lines = []
    for line in lines:
        stripped = line.rstrip()
        if not stripped:
            continue
        # Skip markdown fences
        if stripped.startswith("```") or stripped.endswith("```"):
            continue
        # Skip pure comment lines that look like explanations
        if stripped.startswith("//") and any(
            keyword in stripped.lower() 
            for keyword in ["here is", "this is", "the following", "explanation"]
        ):
            continue
        valid_lines.append(stripped)

    postprocess_meta["cleaned_line_count"] = len(valid_lines)
    postprocess_meta["cleaned_lines"] = list(valid_lines)

    if request is not None:
        valid_lines, dynamic_length_meta = apply_dynamic_length_guard(request, valid_lines, postprocess_config)
        postprocess_meta["dynamic_length_guard"] = dynamic_length_meta

    if request is not None and enable_clipping:
        valid_lines, clip_meta = clip_completion_lines_for_request(request, valid_lines)
        postprocess_meta["clip"] = clip_meta
    elif request is not None:
        postprocess_meta["clip"] = {
            "skipped": True,
            "reason": "completion_clipping_disabled",
            "original_line_count": len(valid_lines),
            "final_line_count": len(valid_lines),
        }

    return valid_lines, postprocess_meta


# ---------------------------------------------------------------------------
# Main Adapter Function
# ---------------------------------------------------------------------------

def generate_completion(request: Dict[str, Any]) -> str:
    """
    Main adapter function for RealBench black-box completion platform.
    
    This function implements the RealBench adapter contract:
        - Input: request dict following rb_completion_request_v1 schema
        - Output: completion-only code string
    
    The request contains:
        - target.prefix: Code before the placeholder
        - target.suffix: Code after the placeholder
        - context.verilog_files: Same-repository context files
    
    Processing flow:
        1. Extract prefix, suffix, and context from request
        2. Build local blocks from context files (sliding window)
        3. Tokenize prefix as query
        4. Perform BM25 retrieval on context blocks
        5. Build prompt with retrieved blocks + prefix + suffix
        6. Call LLM backend
        7. Process and return completion-only output
    
    Args:
        request: RealBench completion request dict
    
    Returns:
        Completion code string (only the code to fill the placeholder)
    """
    start_time = time.perf_counter()
    
    # -----------------------------------------------------------------------
    # 1. Extract request components
    # -----------------------------------------------------------------------
    target = request.get("target", {})
    context = request.get("context", {})
    
    prefix = target.get("prefix", "")
    suffix = target.get("suffix", "")
    whole_file = target.get("whole_file", "")
    target_path = target.get("path", "unknown")
    system_name = target.get("system", "unknown")
    task_name = target.get("task", "unknown")
    
    verilog_files = context.get("verilog_files", [])
    docs_md = context.get("docs_md", [])
    retrieval_config = resolve_doc_retrieval_config()
    backend_config = resolve_backend_config()
    retrieval_fallback_config = resolve_retrieval_fallback_config()
    completion_postprocess_config = resolve_completion_postprocess_config()
    prompt_config = resolve_prompt_construction_config()
    fim_config = resolve_fim_config(request)
    
    # Log request info
    print(f"[RTL-Repo Adapter] Processing target: {target_path}")
    print(f"[RTL-Repo Adapter] System: {system_name}, Task: {task_name}")
    print(f"[RTL-Repo Adapter] Context files: {len(verilog_files)}")
    print(f"[RTL-Repo Adapter] Prefix lines: {len(non_empty_lines(prefix))}")
    print(f"[RTL-Repo Adapter] Suffix lines: {len(non_empty_lines(suffix))}")
    print(f"[RTL-Repo Adapter] Markdown docs: {len(docs_md)}")
    
    # -----------------------------------------------------------------------
    # 2. Build local retrieval corpus and query text
    # -----------------------------------------------------------------------
    build_start = time.perf_counter()
    local_blocks = build_local_blocks_from_context(
        context_files=verilog_files,
        exclude_file_paths=[target_path],
        window_size=30,
        step=10,
    )
    local_blocks = build_token_counter(local_blocks)
    build_time = time.perf_counter() - build_start
    print(f"[RTL-Repo Adapter] Built {len(local_blocks)} local blocks in {build_time:.2f}s")

    # -----------------------------------------------------------------------
    # 3. Build query text without putting the target file into the retrievable corpus
    # -----------------------------------------------------------------------
    query_text = build_local_query_text(prefix, suffix, min_lines=30)
    previous_output = resolve_iteration_rag_previous_output(request)
    query_text, iteration_rag_meta = augment_query_text_with_previous_output(query_text, previous_output)
    masked_type = get_masked_type(request)
    query_text, masked_type_query_meta = augment_query_text_with_masked_type(
        query_text,
        masked_type,
    )
    query_tokens = tokenize_verilog(query_text)
    
    print(f"[RTL-Repo Adapter] Query tokens: {len(query_tokens)}")
    
    # -----------------------------------------------------------------------
    # 4. Convert to RTL-Repo prompt format for unified retrieval
    # -----------------------------------------------------------------------
    # Build RTL-Repo format prompt from RealBench request
    # This enables proper retrieval via BM25search.inspect_retrieval
    rtlrepo_prompt = convert_realbench_to_rtlrepo_prompt(request)
    rtlrepo_prompt, iteration_prompt_meta = augment_rtlrepo_prompt_with_previous_output(
        rtlrepo_prompt,
        request,
        previous_output,
    )
    print(f"[RTL-Repo Adapter] Built RTL-Repo format prompt ({len(rtlrepo_prompt)} chars)")
    if iteration_rag_meta.get("enabled"):
        print(
            "[RTL-Repo Adapter] Iteration RAG previous output enabled: "
            f"{iteration_rag_meta.get('previous_output_lines_used', 0)} lines appended to query"
        )
    
    # -----------------------------------------------------------------------
    # 5. Perform unified retrieval (local + external) via BM25search
    # -----------------------------------------------------------------------
    retrieval_start = time.perf_counter()
    
    enable_local = retrieval_config.get("enable_local_retrieval", True)
    enable_external = retrieval_config.get("enable_external_retrieval", False)
    enable_gating = retrieval_config.get("enable_external_retrieval_gating", True)
    enable_masked_type_retrieval_boost = retrieval_config.get("enable_masked_type_retrieval_boost", True)
    external_corpus_path = retrieval_config.get("external_retrieval_path", "")
    
    external_lines = []
    local_lines = []
    doc_lines = []
    gate_diagnostics = None
    retrieval_inspection = {}
    
    if enable_external and external_corpus_path:
        # Determine external prepend count via gating
        if enable_gating:
            gate_diagnostics = build_retrieval_gate_diagnostics(
                local_blocks=local_blocks,
                target_file_path=target_path,
                search_seed=query_text,
                config=DEFAULT_RETRIEVAL_CONFIG,
            )
            gate_state = gate_diagnostics.get("state", "miss")
            gate_reason = gate_diagnostics.get("reason", "unknown")
            external_prepend = gate_diagnostics.get("resolved_external_prepend_blocks", 0)
            
            print(f"[RTL-Repo Adapter] Gate state: {gate_state} ({gate_reason})")
            print(f"[RTL-Repo Adapter] Resolved external blocks: {external_prepend}")
        else:
            external_prepend = DEFAULT_RETRIEVAL_CONFIG.get("external_prepend_blocks", 3)
        
        if external_prepend > 0:
            external_start = time.perf_counter()
            
            external_lines, retrieval_inspection = retrieve_external_blocks(
                rtlrepo_prompt=rtlrepo_prompt,
                target_file_path=target_path,
                external_corpus_path=external_corpus_path,
                external_prepend_blocks=external_prepend,
                config=DEFAULT_RETRIEVAL_CONFIG,
                local_blocks=local_blocks,
                masked_type=masked_type if enable_masked_type_retrieval_boost else "",
            )
            
            external_time = time.perf_counter() - external_start
            print(f"[RTL-Repo Adapter] Retrieved {len(external_lines)} external lines in {external_time:.2f}s")
            
            # Also get local blocks from inspection for reference
            ordered_local_items = retrieval_inspection.get("ordered_local_items", [])
            if ordered_local_items:
                local_lines = BM25search._render_selected_items(ordered_local_items)
        elif local_blocks:
            top_k = retrieval_config.get("bm25_top_k_blocks", 10)
            block_order = retrieval_config.get("bm25_block_order", "ascending")
            local_lines = retrieve_top_k_blocks(
                blocks=local_blocks,
                query_tokens=query_tokens,
                top_k=top_k,
                block_order=block_order,
            )
    elif enable_local:
        # No external retrieval, just do local retrieval
        top_k = retrieval_config.get("bm25_top_k_blocks", 10)
        block_order = retrieval_config.get("bm25_block_order", "ascending")
        
        if local_blocks:
            local_lines = retrieve_top_k_blocks(
                blocks=local_blocks,
                query_tokens=query_tokens,
                top_k=top_k,
                block_order=block_order,
            )
    
    retrieval_time = time.perf_counter() - retrieval_start
    print(f"[RTL-Repo Adapter] Total retrieval time: {retrieval_time:.2f}s")
    print(f"[RTL-Repo Adapter] Local lines: {len(local_lines)}, External lines: {len(external_lines)}")

    if DOC_RETRIEVAL_AVAILABLE and retrieval_config.get("enable_doc_retrieval", False) and docs_md:
        doc_injection_mode = str(retrieval_config.get("doc_injection_mode", "retrieved_chunks") or "retrieved_chunks").strip().lower()
        doc_chunks = []
        requested_doc_backend = retrieval_config.get("doc_retrieval_backend", "hybrid")
        doc_backend = requested_doc_backend
        if doc_injection_mode == "full_file":
            doc_lines = render_full_doc_lines(docs_md)
            doc_results = list(docs_md)
            doc_backend = "full_file"
            print(
                f"[RTL-Repo Adapter] Doc injection mode: full_file, docs: {len(docs_md)}"
            )
        else:
            doc_chunks = build_doc_chunks(
                docs_md,
                int(retrieval_config.get("doc_chunk_max_chars", 1200)),
            )
            doc_results = []
            fallback_backend = retrieval_config.get("doc_codebert_fallback_backend", "bm25")
            doc_query = build_query_text(
                request,
                int(retrieval_config.get("doc_query_prefix_lines", 30)),
                int(retrieval_config.get("doc_query_suffix_lines", 20)),
            )

            if doc_chunks:
                if doc_backend == "bm25":
                    doc_results = retrieve_docs_bm25(
                        doc_query,
                        doc_chunks,
                        int(retrieval_config.get("doc_retrieval_top_k", 3)),
                    )
                elif doc_backend in {"hybrid", "codebert"}:
                    model_path = retrieval_config.get(
                        "doc_codebert_model_path",
                        str(RTL_REPO_ROOT / "models" / "codebert-base"),
                    )
                    runtime = get_codebert_runtime(model_path)
                    if runtime is None:
                        if fallback_backend == "bm25":
                            print(
                                "[RTL-Repo Adapter] CodeBERT runtime unavailable, "
                                "falling back to BM25 for markdown retrieval"
                            )
                            doc_backend = "bm25"
                            doc_results = retrieve_docs_bm25(
                                doc_query,
                                doc_chunks,
                                int(retrieval_config.get("doc_retrieval_top_k", 3)),
                            )
                    else:
                        try:
                            if doc_backend == "hybrid":
                                doc_results = retrieve_docs_bm25_then_codebert(
                                    request=request,
                                    chunks=doc_chunks,
                                    top_k=int(retrieval_config.get("doc_retrieval_top_k", 3)),
                                    bm25_candidate_k=int(retrieval_config.get("doc_bm25_candidate_k", 12)),
                                    model_path=model_path,
                                    batch_size=int(retrieval_config.get("doc_codebert_batch_size", 8)),
                                    max_length=int(retrieval_config.get("doc_codebert_max_length", 256)),
                                    prefix_lines=int(retrieval_config.get("doc_query_prefix_lines", 30)),
                                    suffix_lines=int(retrieval_config.get("doc_query_suffix_lines", 20)),
                                    request_path_for_cache=request.get("debug_request_path", "") or target_path,
                                    use_cache=True,
                                )
                            else:
                                doc_results = retrieve_docs_codebert(
                                    request=request,
                                    chunks=doc_chunks,
                                    top_k=int(retrieval_config.get("doc_retrieval_top_k", 3)),
                                    model_path=model_path,
                                    batch_size=int(retrieval_config.get("doc_codebert_batch_size", 8)),
                                    max_length=int(retrieval_config.get("doc_codebert_max_length", 256)),
                                    prefix_lines=int(retrieval_config.get("doc_query_prefix_lines", 30)),
                                    suffix_lines=int(retrieval_config.get("doc_query_suffix_lines", 20)),
                                    request_path_for_cache=request.get("debug_request_path", "") or target_path,
                                    use_cache=True,
                                )
                        except Exception as exc:
                            if fallback_backend == "bm25":
                                print(
                                    "[RTL-Repo Adapter] CodeBERT retrieval failed "
                                    f"({exc}), falling back to BM25"
                                )
                                doc_backend = "bm25"
                                doc_results = retrieve_docs_bm25(
                                    doc_query,
                                    doc_chunks,
                                    int(retrieval_config.get("doc_retrieval_top_k", 3)),
                                )
                            else:
                                raise
                elif doc_backend in {"none", "off", "disabled"}:
                    doc_results = []

            doc_lines = render_retrieved_doc_lines(doc_results)
            print(
                f"[RTL-Repo Adapter] Doc retrieval backend: {requested_doc_backend} -> {doc_backend}, "
                f"chunks: {len(doc_chunks)}, selected: {len(doc_results)}"
            )
    
    # -----------------------------------------------------------------------
    # 6. Build completion prompt
    # -----------------------------------------------------------------------
    prompt_start = time.perf_counter()
    
    response_lines = retrieval_config.get("response_lines", 20)
    include_suffix = prompt_config.get("include_right_context", True) and not fim_config.get("enabled", False)
    generation_suffix = resolve_generation_suffix(request, suffix, fim_config)
    token_counter = build_backend_token_counter(backend_config)
    
    # Combine local and external retrieved lines
    # External blocks go first (prepend), then local blocks
    combined_retrieved_lines = []
    if external_lines:
        combined_retrieved_lines.extend(external_lines)
        combined_retrieved_lines.append("")  # Separator
    if local_lines:
        combined_retrieved_lines.extend(local_lines)

    prompt_prefix_mode = prompt_config.get("prompt_prefix_mode", "retrieval")
    if prompt_prefix_mode == "formatted_prompt":
        doc_lines = []
        combined_retrieved_lines = build_formatted_prompt_lines_from_request(request)
    elif prompt_prefix_mode == "none":
        doc_lines = []
        combined_retrieved_lines = []
    
    prompt_lines = build_completion_prompt(
        request=request,
        prefix=prefix,
        suffix=suffix,
        retrieved_lines=combined_retrieved_lines,
        doc_lines=doc_lines,
        response_lines=response_lines,
        include_suffix=include_suffix,
        include_shape_hint=prompt_config.get("include_shape_hint", True),
        use_strict_boundary_constraints=prompt_config.get("use_strict_boundary_constraints", True),
        place_short_right_context_at_end=prompt_config.get("place_short_right_context_at_end", True),
        short_right_context_max_lines=int(prompt_config.get("short_right_context_max_lines", 20)),
    )
    
    # Trim if needed
    trim_meta: Dict[str, Any] = {"trimmed": False, "method": "disabled"}
    if retrieval_config.get("trim_prompt", True):
        max_tokens = retrieval_config.get("trim_max_tokens", 8192)
        prompt_lines, trim_meta = trim_prompt_lines(
            prompt_lines,
            max_tokens=max_tokens,
            token_counter=token_counter,
            random_seed=request.get("debug_request_path") or target_path,
        )
    
    prompt_time = time.perf_counter() - prompt_start
    print(f"[RTL-Repo Adapter] Built prompt with {len(prompt_lines)} lines in {prompt_time:.2f}s")
    prompt_text = render_prompt_text(prompt_lines)
    prompt_token_count, prompt_token_meta = count_prompt_tokens(prompt_text, token_counter)
    
    # -----------------------------------------------------------------------
    # 7. Call LLM backend
    # -----------------------------------------------------------------------
    generation_start = time.perf_counter()
    
    raw_output, backend_call_meta = call_llm_backend(
        prompt_lines=prompt_lines,
        suffix=generation_suffix,
        backend_config=backend_config,
        retrieval_config=retrieval_config,
    )
    
    generation_time = time.perf_counter() - generation_start
    print(f"[RTL-Repo Adapter] LLM generation took {generation_time:.2f}s")
    
    # -----------------------------------------------------------------------
    # 8. Process output
    # -----------------------------------------------------------------------
    valid_lines, postprocess_meta = process_completion_output(
        raw_output,
        request=request,
        is_fim=fim_config.get("enabled", False),
        postprocess_config=completion_postprocess_config,
    )
    completion = "\n".join(valid_lines)

    fallback_reason = detect_bad_completion_reason(
        request=request,
        valid_lines=valid_lines,
        postprocess_meta=postprocess_meta,
        fallback_config=retrieval_fallback_config,
    )
    fallback_meta = {
        "enabled": bool(retrieval_fallback_config.get("enabled", False)),
        "used": False,
        "trigger_reason": fallback_reason,
    }
    if fallback_reason and retrieval_fallback_config.get("enabled", False):
        fallback_candidates = collect_retrieval_fallback_candidate_items(
            local_blocks=local_blocks,
            query_tokens=query_tokens,
            retrieval_inspection=retrieval_inspection,
            fallback_config=retrieval_fallback_config,
        )
        fallback_completion, fallback_meta = build_retrieval_fallback_completion(
            request=request,
            candidate_items=fallback_candidates,
            search_seed=query_text,
            fallback_config=retrieval_fallback_config,
            postprocess_config=completion_postprocess_config,
        )
        if fallback_meta.get("used", False):
            completion = fallback_completion
            valid_lines = [line for line in completion.splitlines() if line.strip()]
            postprocess_meta["retrieval_fallback_used"] = True
            postprocess_meta["retrieval_fallback_meta"] = fallback_meta
        else:
            postprocess_meta["retrieval_fallback_used"] = False
            postprocess_meta["retrieval_fallback_meta"] = fallback_meta
    total_time = time.perf_counter() - start_time
    
    postprocess_meta["bad_completion_reason"] = fallback_reason

    return {
        "completion": completion,
        "meta": {
            "adapter": "rtlrepo_adapter",
            "local_blocks_count": len(local_blocks),
            "retrieved_blocks_count": count_rendered_retrieval_blocks(local_lines),
            "external_blocks_count": count_rendered_retrieval_blocks(external_lines),
            "doc_blocks_count": count_rendered_retrieval_blocks(doc_lines),
            "infile_blocks_count": count_rendered_retrieval_blocks(infile_lines),
            "prompt_lines_count": len(prompt_lines),
            "prompt_text": prompt_text,
            "prompt_token_count": prompt_token_count,
            "prompt_token_meta": prompt_token_meta,
            "completion_lines_count": len(valid_lines),
            "postprocess_meta": postprocess_meta,
            "completion_postprocess": completion_postprocess_config,
            "fim_mode": {
                "enabled": bool(fim_config.get("enabled", False)),
                "suffix_mode": fim_config.get("suffix_mode", "right_context"),
                "generation_suffix_line_count": len([line for line in generation_suffix.splitlines() if line.strip()]),
            },
            "timing": {
                "local_block_build_seconds": build_time,
                "retrieval_seconds": retrieval_time,
                "prompt_build_seconds": prompt_time,
                "generation_seconds": generation_time,
                "total_seconds": total_time,
            },
            "trim_meta": trim_meta,
            "backend_call_meta": backend_call_meta,
            "retrieval_fallback_used": bool(fallback_meta.get("used", False)),
            "retrieval_fallback_meta": fallback_meta,
            "total_time_seconds": total_time,
            "backend_type": backend_config.get("type"),
            "backend_model": backend_config.get("model_name") or backend_config.get("model_path"),
            "external_retrieval_enabled": enable_external,
            "doc_retrieval_requested_docs": len(docs_md),
            "doc_retrieval_selected_chunks": 0 if doc_backend == "full_file" else len(doc_results),
            "doc_injection_mode": doc_backend,
            "doc_retrieval_backend": doc_backend,
            "right_context_mode": "full_suffix" if is_block_level_mask_request(request) else "legacy_slice",
            "gate_diagnostics": gate_diagnostics,
            "rtlrepo_prompt_length": len(rtlrepo_prompt),
            "iteration_rag": {
                **iteration_rag_meta,
                **iteration_prompt_meta,
                "masked_type": masked_type,
                "masked_type_retrieval_boost_enabled": enable_masked_type_retrieval_boost,
            },
        },
    }


def generate_completion_with_meta(request: Dict[str, Any]) -> Dict[str, Any]:
    """
    Alternative adapter function that returns completion with metadata.
    
    This can be useful for debugging and analysis.
    
    Args:
        request: RealBench completion request dict
    
    Returns:
        Dict with completion and metadata
    """
    start_time = time.perf_counter()
    
    # Extract components
    target = request.get("target", {})
    context = request.get("context", {})
    
    prefix = target.get("prefix", "")
    suffix = target.get("suffix", "")
    whole_file = target.get("whole_file", "")
    target_path = target.get("path", "unknown")
    verilog_files = context.get("verilog_files", [])
    docs_md = context.get("docs_md", [])
    retrieval_config = resolve_doc_retrieval_config()
    backend_config = resolve_backend_config()
    retrieval_fallback_config = resolve_retrieval_fallback_config()
    prompt_config = resolve_prompt_construction_config()
    fim_config = resolve_fim_config(request)
    visible_prefix, visible_suffix = build_visible_infile_context(
        whole_file=whole_file,
        prefix=prefix,
        suffix=suffix,
        header_max_lines=int(retrieval_config.get("infile_header_max_lines", 80)),
        left_keep_lines=int(retrieval_config.get("infile_keep_left_lines", 150)),
        right_keep_lines=int(retrieval_config.get("infile_keep_right_lines", 150)),
    )
    
    # Build RTL-Repo format prompt
    rtlrepo_prompt = convert_realbench_to_rtlrepo_prompt(request)
    previous_output = resolve_iteration_rag_previous_output(request)
    rtlrepo_prompt, iteration_prompt_meta = augment_rtlrepo_prompt_with_previous_output(
        rtlrepo_prompt,
        request,
        previous_output,
    )
    
    # Query for gating and local retrieval. Keep the target file out of the retrievable corpus.
    query_text = build_local_query_text(prefix, suffix, min_lines=30)
    query_text, iteration_rag_meta = augment_query_text_with_previous_output(query_text, previous_output)
    masked_type = get_masked_type(request)
    query_text, masked_type_query_meta = augment_query_text_with_masked_type(
        query_text,
        masked_type,
    )
    query_tokens = tokenize_verilog(query_text)
    
    # Build local blocks from context files only, excluding the target file itself.
    local_block_start = time.perf_counter()
    local_blocks = build_local_blocks_from_context(
        verilog_files,
        exclude_file_paths=[target_path],
        window_size=30,
        step=10,
    )
    local_blocks = build_token_counter(local_blocks)
    infile_blocks = build_token_counter(
        build_infile_remote_blocks(
            whole_file=whole_file,
            prefix=prefix,
            suffix=suffix,
            target_path=target_path,
            window_size=int(retrieval_config.get("infile_window_size", 30)),
            step=int(retrieval_config.get("infile_window_step", 10)),
            left_keep_lines=int(retrieval_config.get("infile_keep_left_lines", 150)),
            right_keep_lines=int(retrieval_config.get("infile_keep_right_lines", 150)),
        )
    )
    local_block_time = time.perf_counter() - local_block_start
    
    # External retrieval with gating
    external_lines = []
    local_lines = []
    infile_lines = []
    doc_lines = []
    doc_results = []
    doc_backend = "disabled"
    gate_diagnostics = None
    retrieval_inspection = {}
    
    enable_local = retrieval_config.get("enable_local_retrieval", True)
    enable_external = retrieval_config.get("enable_external_retrieval", False)
    enable_gating = retrieval_config.get("enable_external_retrieval_gating", True)
    enable_masked_type_retrieval_boost = retrieval_config.get("enable_masked_type_retrieval_boost", True)
    external_corpus_path = retrieval_config.get("external_retrieval_path", "")
    
    retrieval_start = time.perf_counter()
    if enable_external and external_corpus_path:
        if enable_gating and local_blocks:
            gate_diagnostics = build_retrieval_gate_diagnostics(
                local_blocks=local_blocks,
                target_file_path=target_path,
                search_seed=query_text,
                config=retrieval_config,
            )
            external_prepend = gate_diagnostics.get("resolved_external_prepend_blocks", 0)
        else:
            external_prepend = retrieval_config.get("external_prepend_blocks", 3)
        
        if external_prepend > 0:
            external_lines, retrieval_inspection = retrieve_external_blocks(
                rtlrepo_prompt=rtlrepo_prompt,
                target_file_path=target_path,
                external_corpus_path=external_corpus_path,
                external_prepend_blocks=external_prepend,
                config=retrieval_config,
                local_blocks=local_blocks,
                masked_type=masked_type if enable_masked_type_retrieval_boost else "",
            )
            
            # Get local blocks from inspection
            ordered_local_items = retrieval_inspection.get("ordered_local_items", [])
            if ordered_local_items:
                local_lines = BM25search._render_selected_items(ordered_local_items)
        elif enable_local and local_blocks:
            top_k = retrieval_config.get("bm25_top_k_blocks", 10)
            block_order = retrieval_config.get("bm25_block_order", "ascending")
            local_lines = retrieve_top_k_blocks(
                blocks=local_blocks,
                query_tokens=query_tokens,
                top_k=top_k,
                block_order=block_order,
            )
    elif enable_local and local_blocks:
        # No external retrieval, just do local retrieval
        top_k = retrieval_config.get("bm25_top_k_blocks", 10)
        block_order = retrieval_config.get("bm25_block_order", "ascending")
        local_lines = retrieve_top_k_blocks(
            blocks=local_blocks,
            query_tokens=query_tokens,
            top_k=top_k,
            block_order=block_order,
        )

    if infile_blocks:
        infile_lines = retrieve_top_k_blocks(
            blocks=infile_blocks,
            query_tokens=query_tokens,
            top_k=int(retrieval_config.get("infile_top_k_blocks", 3)),
            block_order=retrieval_config.get("bm25_block_order", "ascending"),
            rich_render=True,
            retriever_name="in_file_bm25",
        )

    # Markdown doc retrieval
    if DOC_RETRIEVAL_AVAILABLE and retrieval_config.get("enable_doc_retrieval", False):
        doc_injection_mode = str(retrieval_config.get("doc_injection_mode", "retrieved_chunks") or "retrieved_chunks").strip().lower()
        doc_chunks = []
        requested_doc_backend = retrieval_config.get("doc_retrieval_backend", "hybrid")
        doc_backend = requested_doc_backend
        if doc_injection_mode == "full_file":
            doc_lines = render_full_doc_lines(docs_md)
            doc_results = list(docs_md)
            doc_backend = "full_file"
        else:
            doc_chunks = build_doc_chunks(
                docs_md,
                int(retrieval_config.get("doc_chunk_max_chars", 1200)),
            )
            fallback_backend = retrieval_config.get("doc_codebert_fallback_backend", "bm25")
            doc_query = build_query_text(
                request,
                int(retrieval_config.get("doc_query_prefix_lines", 30)),
                int(retrieval_config.get("doc_query_suffix_lines", 20)),
            )

            if doc_chunks:
                if doc_backend == "bm25":
                    doc_results = retrieve_docs_bm25(
                        doc_query,
                        doc_chunks,
                        int(retrieval_config.get("doc_retrieval_top_k", 3)),
                    )
                elif doc_backend in {"hybrid", "codebert"}:
                    model_path = retrieval_config.get(
                        "doc_codebert_model_path",
                        str(RTL_REPO_ROOT / "models" / "codebert-base"),
                    )
                    runtime = get_codebert_runtime(model_path)
                    if runtime is None:
                        if fallback_backend == "bm25":
                            doc_backend = "bm25"
                            doc_results = retrieve_docs_bm25(
                                doc_query,
                                doc_chunks,
                                int(retrieval_config.get("doc_retrieval_top_k", 3)),
                            )
                    else:
                        try:
                            if doc_backend == "hybrid":
                                doc_results = retrieve_docs_bm25_then_codebert(
                                    request=request,
                                    chunks=doc_chunks,
                                    top_k=int(retrieval_config.get("doc_retrieval_top_k", 3)),
                                    bm25_candidate_k=int(retrieval_config.get("doc_bm25_candidate_k", 12)),
                                    model_path=model_path,
                                    batch_size=int(retrieval_config.get("doc_codebert_batch_size", 8)),
                                    max_length=int(retrieval_config.get("doc_codebert_max_length", 256)),
                                    prefix_lines=int(retrieval_config.get("doc_query_prefix_lines", 30)),
                                    suffix_lines=int(retrieval_config.get("doc_query_suffix_lines", 20)),
                                    request_path_for_cache=request.get("debug_request_path", "") or target_path,
                                    use_cache=True,
                                )
                            else:
                                doc_results = retrieve_docs_codebert(
                                    request=request,
                                    chunks=doc_chunks,
                                    top_k=int(retrieval_config.get("doc_retrieval_top_k", 3)),
                                    model_path=model_path,
                                    batch_size=int(retrieval_config.get("doc_codebert_batch_size", 8)),
                                    max_length=int(retrieval_config.get("doc_codebert_max_length", 256)),
                                    prefix_lines=int(retrieval_config.get("doc_query_prefix_lines", 30)),
                                    suffix_lines=int(retrieval_config.get("doc_query_suffix_lines", 20)),
                                    request_path_for_cache=request.get("debug_request_path", "") or target_path,
                                    use_cache=True,
                                )
                        except Exception:
                            if fallback_backend == "bm25":
                                doc_backend = "bm25"
                                doc_results = retrieve_docs_bm25(
                                    doc_query,
                                    doc_chunks,
                                    int(retrieval_config.get("doc_retrieval_top_k", 3)),
                                )
                            else:
                                raise
                elif doc_backend in {"none", "off", "disabled"}:
                    doc_results = []

            doc_lines = render_retrieved_doc_lines(doc_results)
    retrieval_time = time.perf_counter() - retrieval_start
    
    # Combine retrieved lines
    combined_retrieved_lines = []
    if external_lines:
        combined_retrieved_lines.extend(external_lines)
        combined_retrieved_lines.append("")
    if local_lines:
        combined_retrieved_lines.extend(local_lines)
        combined_retrieved_lines.append("")
    if infile_lines:
        combined_retrieved_lines.extend(infile_lines)

    prompt_prefix_mode = prompt_config.get("prompt_prefix_mode", "retrieval")
    if prompt_prefix_mode == "formatted_prompt":
        doc_lines = []
        combined_retrieved_lines = build_formatted_prompt_lines_from_request(request)
    elif prompt_prefix_mode == "none":
        doc_lines = []
        combined_retrieved_lines = []
    
    # Prompt
    prompt_start = time.perf_counter()
    include_suffix = prompt_config.get("include_right_context", True) and not fim_config.get("enabled", False)
    generation_suffix = resolve_generation_suffix(request, visible_suffix, fim_config)
    prompt_lines = build_completion_prompt(
        request=request,
        prefix=visible_prefix,
        suffix=visible_suffix,
        retrieved_lines=combined_retrieved_lines,
        doc_lines=doc_lines,
        response_lines=retrieval_config.get("response_lines", 20),
        include_suffix=include_suffix,
        include_shape_hint=prompt_config.get("include_shape_hint", True),
        use_strict_boundary_constraints=prompt_config.get("use_strict_boundary_constraints", True),
        place_short_right_context_at_end=prompt_config.get("place_short_right_context_at_end", True),
        short_right_context_max_lines=int(prompt_config.get("short_right_context_max_lines", 20)),
    )
    
    token_counter = build_backend_token_counter(backend_config)
    trim_meta = {
        "trimmed": False,
        "method": "disabled",
        "max_tokens": retrieval_config.get("trim_max_tokens", 8192),
    }
    if retrieval_config.get("trim_prompt", True):
        prompt_lines, trim_meta = trim_prompt_lines(
            prompt_lines,
            max_tokens=retrieval_config.get("trim_max_tokens", 8192),
            token_counter=token_counter,
            random_seed=request.get("debug_request_path") or target_path,
        )
    prompt_lines = normalize_prompt_lines(prompt_lines)
    prompt_text = render_prompt_text(prompt_lines)
    prompt_token_count, prompt_token_meta = count_prompt_tokens(prompt_text, token_counter)
    prompt_build_time = time.perf_counter() - prompt_start
    
    # Generation
    generation_start = time.perf_counter()
    raw_output, backend_call_meta = call_llm_backend(
        prompt_lines=prompt_lines,
        suffix=generation_suffix,
        backend_config=backend_config,
        retrieval_config=retrieval_config,
    )
    generation_time = time.perf_counter() - generation_start
    
    valid_lines, postprocess_meta = process_completion_output(
        raw_output,
        request=request,
        is_fim=fim_config.get("enabled", False),
    )
    completion = "\n".join(valid_lines)
    fallback_reason = detect_bad_completion_reason(
        request=request,
        valid_lines=valid_lines,
        postprocess_meta=postprocess_meta,
        fallback_config=retrieval_fallback_config,
    )
    fallback_meta = {
        "enabled": bool(retrieval_fallback_config.get("enabled", False)),
        "used": False,
        "trigger_reason": fallback_reason,
    }
    if fallback_reason and retrieval_fallback_config.get("enabled", False):
        fallback_candidates = collect_retrieval_fallback_candidate_items(
            local_blocks=local_blocks,
            query_tokens=query_tokens,
            retrieval_inspection=retrieval_inspection,
            fallback_config=retrieval_fallback_config,
        )
        fallback_completion, fallback_meta = build_retrieval_fallback_completion(
            request=request,
            candidate_items=fallback_candidates,
            search_seed=query_text,
            fallback_config=retrieval_fallback_config,
        )
        if fallback_meta.get("used", False):
            completion = fallback_completion
            valid_lines = [line for line in completion.splitlines() if line.strip()]
            postprocess_meta["retrieval_fallback_used"] = True
            postprocess_meta["retrieval_fallback_meta"] = fallback_meta
        else:
            postprocess_meta["retrieval_fallback_used"] = False
            postprocess_meta["retrieval_fallback_meta"] = fallback_meta
    total_time = time.perf_counter() - start_time
    
    postprocess_meta["bad_completion_reason"] = fallback_reason

    return {
        "completion": completion,
        "meta": {
            "adapter": "rtlrepo_adapter",
            "local_blocks_count": len(local_blocks),
            "retrieved_blocks_count": count_rendered_retrieval_blocks(local_lines),
            "external_blocks_count": count_rendered_retrieval_blocks(external_lines),
            "doc_blocks_count": count_rendered_retrieval_blocks(doc_lines),
            "infile_blocks_count": count_rendered_retrieval_blocks(infile_lines),
            "prompt_lines_count": len(prompt_lines),
            "prompt_text": prompt_text,
            "prompt_token_count": prompt_token_count,
            "prompt_token_meta": prompt_token_meta,
            "trim_meta": trim_meta,
            "completion_lines_count": len(valid_lines),
            "postprocess_meta": postprocess_meta,
            "backend_call_meta": backend_call_meta,
            "fim_mode": {
                "enabled": bool(fim_config.get("enabled", False)),
                "suffix_mode": fim_config.get("suffix_mode", "right_context"),
                "generation_suffix_line_count": len([line for line in generation_suffix.splitlines() if line.strip()]),
            },
            "retrieval_fallback_used": bool(fallback_meta.get("used", False)),
            "retrieval_fallback_meta": fallback_meta,
            "total_time_seconds": total_time,
            "backend_type": backend_config.get("type"),
            "backend_model": backend_config.get("model_name") or backend_config.get("model_path"),
            "timing": {
                "local_block_build_seconds": local_block_time,
                "retrieval_seconds": retrieval_time,
                "prompt_build_seconds": prompt_build_time,
                "generation_seconds": generation_time,
                "total_seconds": total_time,
            },
            "external_retrieval_enabled": enable_external,
            "doc_retrieval_requested_docs": len(docs_md),
            "doc_retrieval_selected_chunks": 0 if doc_backend == "full_file" else len(doc_results),
            "doc_injection_mode": doc_backend,
            "doc_retrieval_backend": doc_backend,
            "right_context_mode": "full_suffix" if is_block_level_mask_request(request) else "legacy_slice",
            "gate_diagnostics": gate_diagnostics,
            "rtlrepo_prompt_length": len(rtlrepo_prompt),
            "iteration_rag": {
                **iteration_rag_meta,
                **iteration_prompt_meta,
                "masked_type": masked_type,
                "masked_type_retrieval_boost_enabled": enable_masked_type_retrieval_boost,
                "masked_type_query": masked_type_query_meta,
            },
            "retrieval_inspection_present": bool(retrieval_inspection),
            "timing": {
                "local_block_build_seconds": local_block_time,
                "retrieval_seconds": retrieval_time,
                "prompt_build_seconds": prompt_build_time,
                "generation_seconds": generation_time,
                "total_seconds": total_time,
            },
        },
    }


def build_prompt_text_only(request: Dict[str, Any]) -> Dict[str, Any]:
    """Build the completion prompt without calling the LLM backend."""
    start_time = time.perf_counter()
    target = request.get("target", {})
    context = request.get("context", "")

    prefix = target.get("prefix", "")
    suffix = target.get("suffix", "")
    whole_file = target.get("whole_file", "")
    target_path = target.get("path", "unknown")
    verilog_files = context.get("verilog_files", [])
    docs_md = context.get("docs_md", [])

    retrieval_config = resolve_doc_retrieval_config()
    visible_prefix, visible_suffix = build_visible_infile_context(
        whole_file=whole_file,
        prefix=prefix,
        suffix=suffix,
        header_max_lines=int(retrieval_config.get("infile_header_max_lines", 80)),
        left_keep_lines=int(retrieval_config.get("infile_keep_left_lines", 150)),
        right_keep_lines=int(retrieval_config.get("infile_keep_right_lines", 150)),
    )
    prompt_config = resolve_prompt_construction_config()
    fim_config = resolve_fim_config(request)

    build_start = time.perf_counter()
    generation_suffix = resolve_generation_suffix(request, visible_suffix, fim_config)
    rtlrepo_prompt = convert_realbench_to_rtlrepo_prompt(request)
    previous_output = resolve_iteration_rag_previous_output(request)
    rtlrepo_prompt, iteration_prompt_meta = augment_rtlrepo_prompt_with_previous_output(
        rtlrepo_prompt,
        request,
        previous_output,
    )
    build_time = time.perf_counter() - build_start

    query_text = build_local_query_text(prefix, suffix, min_lines=30)
    query_text, iteration_rag_meta = augment_query_text_with_previous_output(query_text, previous_output)
    masked_type = get_masked_type(request)
    query_text, masked_type_query_meta = augment_query_text_with_masked_type(
        query_text,
        masked_type,
    )
    query_tokens = tokenize_verilog(query_text)

    local_blocks = build_local_blocks_from_context(
        verilog_files,
        exclude_file_paths=[target_path],
        window_size=30,
        step=10,
    )
    local_blocks = build_token_counter(local_blocks)
    infile_blocks = build_token_counter(
        build_infile_remote_blocks(
            whole_file=whole_file,
            prefix=prefix,
            suffix=suffix,
            target_path=target_path,
            window_size=int(retrieval_config.get("infile_window_size", 30)),
            step=int(retrieval_config.get("infile_window_step", 10)),
            left_keep_lines=int(retrieval_config.get("infile_keep_left_lines", 150)),
            right_keep_lines=int(retrieval_config.get("infile_keep_right_lines", 150)),
        )
    )

    external_lines = []
    local_lines = []
    infile_lines = []
    doc_lines = []
    doc_results = []
    doc_backend = "disabled"
    gate_diagnostics = None
    retrieval_inspection = {}

    enable_local = retrieval_config.get("enable_local_retrieval", True)
    enable_external = retrieval_config.get("enable_external_retrieval", False)
    enable_gating = retrieval_config.get("enable_external_retrieval_gating", True)
    enable_masked_type_retrieval_boost = retrieval_config.get("enable_masked_type_retrieval_boost", True)
    external_corpus_path = retrieval_config.get("external_retrieval_path", "")

    retrieval_start = time.perf_counter()
    if enable_external and external_corpus_path:
        if enable_gating and local_blocks:
            gate_diagnostics = build_retrieval_gate_diagnostics(
                local_blocks=local_blocks,
                target_file_path=target_path,
                search_seed=query_text,
                config=retrieval_config,
            )
            external_prepend = gate_diagnostics.get("resolved_external_prepend_blocks", 0)
        else:
            external_prepend = retrieval_config.get("external_prepend_blocks", 3)

        if external_prepend > 0:
            external_lines, retrieval_inspection = retrieve_external_blocks(
                rtlrepo_prompt=rtlrepo_prompt,
                target_file_path=target_path,
                external_corpus_path=external_corpus_path,
                external_prepend_blocks=external_prepend,
                config=retrieval_config,
                local_blocks=local_blocks,
                masked_type=masked_type if enable_masked_type_retrieval_boost else "",
            )

            ordered_local_items = retrieval_inspection.get("ordered_local_items", [])
            if ordered_local_items:
                local_lines = BM25search._render_selected_items(ordered_local_items)
        elif enable_local and local_blocks:
            top_k = retrieval_config.get("bm25_top_k_blocks", 10)
            block_order = retrieval_config.get("bm25_block_order", "ascending")
            local_lines = retrieve_top_k_blocks(
                blocks=local_blocks,
                query_tokens=query_tokens,
                top_k=top_k,
                block_order=block_order,
            )
    elif enable_local and local_blocks:
        # No external retrieval, just do local retrieval
        top_k = retrieval_config.get("bm25_top_k_blocks", 10)
        block_order = retrieval_config.get("bm25_block_order", "ascending")
        local_lines = retrieve_top_k_blocks(
            blocks=local_blocks,
            query_tokens=query_tokens,
            top_k=top_k,
            block_order=block_order,
        )

    if infile_blocks:
        infile_lines = retrieve_top_k_blocks(
            blocks=infile_blocks,
            query_tokens=query_tokens,
            top_k=int(retrieval_config.get("infile_top_k_blocks", 3)),
            block_order=retrieval_config.get("bm25_block_order", "ascending"),
            rich_render=True,
            retriever_name="in_file_bm25",
        )

    if DOC_RETRIEVAL_AVAILABLE and retrieval_config.get("enable_doc_retrieval", False):
        doc_injection_mode = str(retrieval_config.get("doc_injection_mode", "retrieved_chunks") or "retrieved_chunks").strip().lower()
        doc_chunks = []
        requested_doc_backend = retrieval_config.get("doc_retrieval_backend", "hybrid")
        doc_backend = requested_doc_backend
        if doc_injection_mode == "full_file":
            doc_lines = render_full_doc_lines(docs_md)
            doc_results = list(docs_md)
            doc_backend = "full_file"
        else:
            doc_chunks = build_doc_chunks(
                docs_md,
                int(retrieval_config.get("doc_chunk_max_chars", 1200)),
            )
            fallback_backend = retrieval_config.get("doc_codebert_fallback_backend", "bm25")
            doc_query = build_query_text(
                request,
                int(retrieval_config.get("doc_query_prefix_lines", 30)),
                int(retrieval_config.get("doc_query_suffix_lines", 20)),
            )

            if doc_chunks:
                if doc_backend == "bm25":
                    doc_results = retrieve_docs_bm25(
                        doc_query,
                        doc_chunks,
                        int(retrieval_config.get("doc_retrieval_top_k", 3)),
                    )
                elif doc_backend in {"hybrid", "codebert"}:
                    model_path = retrieval_config.get(
                        "doc_codebert_model_path",
                        str(RTL_REPO_ROOT / "models" / "codebert-base"),
                    )
                    runtime = get_codebert_runtime(model_path)
                    if runtime is None:
                        if fallback_backend == "bm25":
                            doc_backend = "bm25"
                            doc_results = retrieve_docs_bm25(
                                doc_query,
                                doc_chunks,
                                int(retrieval_config.get("doc_retrieval_top_k", 3)),
                            )
                    else:
                        try:
                            if doc_backend == "hybrid":
                                doc_results = retrieve_docs_bm25_then_codebert(
                                    request=request,
                                    chunks=doc_chunks,
                                    top_k=int(retrieval_config.get("doc_retrieval_top_k", 3)),
                                    bm25_candidate_k=int(retrieval_config.get("doc_bm25_candidate_k", 12)),
                                    model_path=model_path,
                                    batch_size=int(retrieval_config.get("doc_codebert_batch_size", 8)),
                                    max_length=int(retrieval_config.get("doc_codebert_max_length", 256)),
                                    prefix_lines=int(retrieval_config.get("doc_query_prefix_lines", 30)),
                                    suffix_lines=int(retrieval_config.get("doc_query_suffix_lines", 20)),
                                    request_path_for_cache=request.get("debug_request_path", "") or target_path,
                                    use_cache=True,
                                )
                            else:
                                doc_results = retrieve_docs_codebert(
                                    request=request,
                                    chunks=doc_chunks,
                                    top_k=int(retrieval_config.get("doc_retrieval_top_k", 3)),
                                    model_path=model_path,
                                    batch_size=int(retrieval_config.get("doc_codebert_batch_size", 8)),
                                    max_length=int(retrieval_config.get("doc_codebert_max_length", 256)),
                                    prefix_lines=int(retrieval_config.get("doc_query_prefix_lines", 30)),
                                    suffix_lines=int(retrieval_config.get("doc_query_suffix_lines", 20)),
                                    request_path_for_cache=request.get("debug_request_path", "") or target_path,
                                    use_cache=True,
                                )
                        except Exception:
                            if fallback_backend == "bm25":
                                doc_backend = "bm25"
                                doc_results = retrieve_docs_bm25(
                                    doc_query,
                                    doc_chunks,
                                    int(retrieval_config.get("doc_retrieval_top_k", 3)),
                                )
                            else:
                                raise
                elif doc_backend in {"none", "off", "disabled"}:
                    doc_results = []

            doc_lines = render_retrieved_doc_lines(doc_results)

    retrieval_time = time.perf_counter() - retrieval_start

    combined_retrieved_lines = []
    if external_lines:
        combined_retrieved_lines.extend(external_lines)
        combined_retrieved_lines.append("")
    if local_lines:
        combined_retrieved_lines.extend(local_lines)
        combined_retrieved_lines.append("")
    if infile_lines:
        combined_retrieved_lines.extend(infile_lines)

    prompt_prefix_mode = prompt_config.get("prompt_prefix_mode", "retrieval")
    if prompt_prefix_mode == "formatted_prompt":
        doc_lines = []
        combined_retrieved_lines = build_formatted_prompt_lines_from_request(request)
    elif prompt_prefix_mode == "none":
        doc_lines = []
        combined_retrieved_lines = []

    include_suffix = prompt_config.get("include_right_context", True) and not fim_config.get("enabled", False)
    generation_suffix = resolve_generation_suffix(request, suffix, fim_config)

    prompt_start = time.perf_counter()
    prompt_lines = build_completion_prompt(
        request=request,
        prefix=visible_prefix,
        suffix=visible_suffix,
        retrieved_lines=combined_retrieved_lines,
        doc_lines=doc_lines,
        response_lines=retrieval_config.get("response_lines", 20),
        include_suffix=include_suffix,
        include_shape_hint=prompt_config.get("include_shape_hint", True),
        use_strict_boundary_constraints=prompt_config.get("use_strict_boundary_constraints", True),
    )

    if retrieval_config.get("trim_prompt", True):
        prompt_lines, _trim_meta = trim_prompt_lines(
            prompt_lines,
            max_tokens=retrieval_config.get("trim_max_tokens", 8192),
            random_seed=request.get("debug_request_path") or target_path,
        )
    prompt_build_time = time.perf_counter() - prompt_start

    prompt_text = render_prompt_text(prompt_lines)
    request["_rtlrepo_last_prompt_text"] = prompt_text
    total_time = time.perf_counter() - start_time

    return {
        "prompt_text": prompt_text,
        "meta": {
            "adapter": "rtlrepo_adapter",
            "local_blocks_count": len(local_blocks),
            "retrieved_blocks_count": count_rendered_retrieval_blocks(local_lines),
            "external_blocks_count": count_rendered_retrieval_blocks(external_lines),
            "doc_blocks_count": count_rendered_retrieval_blocks(doc_lines),
            "infile_blocks_count": count_rendered_retrieval_blocks(infile_lines),
            "prompt_lines_count": len(prompt_lines),
            "trim_meta": _trim_meta,
            "fim_mode": {
                "enabled": bool(fim_config.get("enabled", False)),
                "suffix_mode": fim_config.get("suffix_mode", "right_context"),
                "generation_suffix": generation_suffix,
                "generation_suffix_line_count": len([line for line in generation_suffix.splitlines() if line.strip()]),
            },
            "external_retrieval_enabled": enable_external,
            "doc_retrieval_requested_docs": len(docs_md),
            "doc_retrieval_selected_chunks": 0 if doc_backend == "full_file" else len(doc_results),
            "doc_injection_mode": doc_backend,
            "doc_retrieval_backend": doc_backend,
            "timing": {
                "local_block_build_seconds": build_time,
                "retrieval_seconds": retrieval_time,
                "prompt_build_seconds": prompt_build_time,
                "total_seconds": total_time,
            },
            "right_context_mode": "full_suffix" if is_block_level_mask_request(request) else "legacy_slice",
            "gate_diagnostics": gate_diagnostics,
            "rtlrepo_prompt_length": len(rtlrepo_prompt),
            "iteration_rag": {
                **iteration_rag_meta,
                **iteration_prompt_meta,
                "masked_type": masked_type,
                "masked_type_retrieval_boost_enabled": enable_masked_type_retrieval_boost,
            },
            "retrieval_inspection_present": bool(retrieval_inspection),
        },
    }


# ---------------------------------------------------------------------------
# CLI Entry Point (for testing)
# ---------------------------------------------------------------------------

def main():
    """CLI entry point for testing the adapter."""
    import argparse
    
    parser = argparse.ArgumentParser(description="RTL-Repo Adapter for RealBench")
    parser.add_argument(
        "--request-json",
        type=Path,
        default=None,
        help="Path to normalized RealBench request JSON file",
    )
    parser.add_argument(
        "--target-file",
        type=Path,
        default=None,
        help="Target masked .v file used to build a normalized request on the fly",
    )
    parser.add_argument(
        "--repo-root",
        type=Path,
        default=Path(__file__).resolve().parents[1],
        help="RealBench repository root used with --target-file",
    )
    parser.add_argument(
        "--context-policy",
        type=str,
        default="recursive_upstream",
        help="Context policy used with --target-file",
    )
    parser.add_argument(
        "--max-context-files",
        type=int,
        default=32,
        help="Maximum number of context files used with --target-file",
    )
    parser.add_argument(
        "--seed",
        type=int,
        default=1,
        help="Random seed used with --target-file",
    )
    parser.add_argument(
        "--include-docs",
        type=str,
        default="auto",
        help="Doc inclusion mode used with --target-file",
    )
    parser.add_argument(
        "--target-meta",
        type=Path,
        default=None,
        help="Optional explicit metadata path used with --target-file",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=None,
        help="Path to write completion output",
    )
    parser.add_argument(
        "--prompt-only",
        action="store_true",
        help="Build and output prompt text only without calling the LLM backend",
    )
    parser.add_argument(
        "--print-completion",
        action="store_true",
        help="Print completion to stdout",
    )
    parser.add_argument(
        "--with-meta",
        action="store_true",
        help="Return completion with metadata",
    )
    
    args = parser.parse_args()
    
    # Load or build request
    if args.target_file is not None:
        from rb_blackbox_completion_platform import build_request

        if not args.target_file.is_file():
            print(f"Error: Target file not found: {args.target_file}")
            sys.exit(1)
        if not args.repo_root.is_dir():
            print(f"Error: Repo root not found: {args.repo_root}")
            sys.exit(1)

        request = build_request(
            target_file=args.target_file.resolve(),
            repo_root=args.repo_root.resolve(),
            context_policy=args.context_policy,
            max_context_files=args.max_context_files,
            seed=args.seed,
            include_docs=args.include_docs,
            explicit_doc_paths=[],
            include_images="none",
            explicit_image_paths=[],
            custom_context_list=None,
            explicit_meta_path=None if args.target_meta is None else args.target_meta.resolve(),
        )
        request["debug_request_path"] = str(args.target_file.resolve())
    else:
        if args.request_json is None or not args.request_json.is_file():
            print("Error: Provide either --request-json or --target-file with a valid file")
            sys.exit(1)

        request = json.loads(args.request_json.read_text(encoding="utf-8"))
    
    # Generate completion or prompt
    if args.prompt_only:
        result = build_prompt_text_only(request)
        completion = result["prompt_text"]
        meta = result.get("meta", {})
    elif args.with_meta:
        result = generate_completion_with_meta(request)
        completion = result["completion"]
        meta = result.get("meta", {})
    else:
        completion = generate_completion(request)
        meta = {}
    
    # Output
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        if args.with_meta and not args.prompt_only:
            args.output.write_text(
                json.dumps({"completion": completion, "meta": meta}, indent=2),
                encoding="utf-8",
            )
        else:
            args.output.write_text(completion, encoding="utf-8")
        print(f"Completion written to: {args.output}")
    
    if args.print_completion:
        print(completion)
    
    if args.with_meta and meta:
        print("\n--- Metadata ---")
        for key, value in meta.items():
            print(f"{key}: {value}")


if __name__ == "__main__":
    main()
