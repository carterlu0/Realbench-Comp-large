#!/usr/bin/env python3

from __future__ import annotations

import json
import os
import argparse
import random
import re
import subprocess
import sys
from dataclasses import dataclass, asdict
from pathlib import Path
from typing import Any, Iterable, Iterator, Mapping, Sequence

from benchmark_info import benchmark_info as BENCHMARK_INFO


BASE_DIR = Path(__file__).resolve().parents[1]
IN_DIR = BASE_DIR / "annotated_units"
OUT_DIR_BASENAME = "masked_units"
SYSTEM_YOSYS_BIN = "/usr/bin/yosys"

# Configuration Options
MODE = "weighted"  # "random", "complex", "decl", "body", "head_only", "weighted", "group_only", "block_only"
TASK_SCOPE = "core60"  # "core60" or "all82"
DATASET_TAG = "maincore_rich_v3"  # appended to output dir name, empty string disables tag suffix
MAX_MASK = 1       # Max masks per file
FIXED_MASK = False # If True, strictly mask 1 per file (overrides MAX_MASK)
RANDOM_MASK_COUNT = False  # If True, per-file mask count is randomized in [1, MAX_MASK]
# Default dataset seed. Use --seed at runtime when you want to target a different weight
# without editing this file.
SEED = 2
TYPE_CAP_RATIO = 0.15  # Soft cap ratio for a single type in weighted mode.
RARITY_ALPHA = 0.8     # Rarity boost strength in weighted mode (higher => more boost for rare types).
MANDATORY_TYPE_MIN_COUNTS: dict[str, int] = {
    "fsm": 4,
    "fsm_block": 2,
    "function": 5,
    "generate": 3,
    "case": 5,
    "handshake_block": 2,
    "counter_cluster_block": 2,
    "cdcsync_block": 2,
}
COMPLEX_TYPE_BOOSTS: dict[str, float] = {
    "fsm": 3.0,
    "fsm_block": 3.5,
    "function": 2.0,
    "case": 2.0,
    "generate": 1.5,
    "task": 2.0,
    "handshake_block": 3.0,
    "counter_cluster_block": 3.0,
    "cdcsync_block": 3.0,
}
COMPLEX_GROUP_BLOCK_PARENT_TYPES = {"fsm", "handshake", "counter_cluster", "cdcsync"}
COMPLEX_GROUP_BLOCK_ALLOWED_BLOCK_TYPES = {
    "always",
    "always_comb",
    "always_ff",
    "always_latch",
    "assign",
    "begin_end",
    "case",
}
COMPLEX_GROUP_BLOCK_ALWAYS_ONLY_PARENT_TYPES = {"fsm", "handshake", "counter_cluster"}
COMPLEX_GROUP_BLOCK_VARIANTS = ("whole", "body_to_tail", "head_to_tail")
COMPLEX_GROUP_BLOCK_VARIANTS_BY_PARENT_TYPE = {
    "fsm": ("whole", "body_to_tail"),
    "handshake": ("whole",),
    "counter_cluster": ("whole", "body_to_tail"),
}
COMPLEX_GROUP_BLOCK_PARENT_BOOSTS: dict[str, float] = {
    "fsm": 2.5,
    "handshake": 1.8,
    "counter_cluster": 1.6,
    "cdcsync": 1.5,
}
RARE_TYPE_MULTI_FORCE_LIMITS: dict[str, int] = {
    "function": 2,
    "generate": 2,
    "fsm": 1,
    "fsm_block": 2,
    "handshake_block": 2,
    "counter_cluster_block": 2,
    "cdcsync_block": 2,
}
FSM_SPECIAL_TYPES = ("fsm", "fsm_block")
FSM_SPECIAL_FILE_EXTRA_VARIANTS = 3
OVERLAP_EXEMPT_GROUPS = {"fsm", "counter_cluster"}
PURE_FSM_PRIORITY_FILES = {
    "sdc/sd_cmd_master/sd_cmd_master.v",
    "sdc/sd_cmd_serial_host/sd_cmd_serial_host.v",
    "sdc/sd_data_master/sd_data_master.v",
    "sdc/sd_data_serial_host/sd_data_serial_host.v",
}
MAX_VARIANTS_PER_FILE = 3  # Base per-source-file max number of generated questions.
ADAPTIVE_VARIANT_POLICY = "maincore_rich_v3"  # "off", "maincore_rich", or "maincore_rich_v3"
ADAPTIVE_MAX_VARIANTS_PER_FILE = 7  # Upper bound used by adaptive per-file expansion.
TARGET_TOTAL_QUESTIONS = 200  # Global stop limit for generated questions (0 means unlimited).
PREFER_NON_CONTAINER_SPANS = True  # In multi-variant generation, prefer non-container spans first.
NON_CONTAINER_PREFERENCE_PROB = 0.7  # Probability to prefer non-container spans when enabled.
# Legacy weight-file hook kept only for compatibility. The effective weighted
# sampling policy for this release is defined by the script logic below.
WEIGHTS_JSON = str(BASE_DIR / "rb_mask_weights.json")
PER_FILE_JSON_SUFFIX = ".json"  # sidecar json: <file>.v.json
GLOBAL_EXCLUSION_BLACKLIST_JSON = BASE_DIR / "global_exclusion_blacklist.json"
BLACKLIST_OVERLAP_MIN_RATIO = 0.8  # Require substantial line overlap before treating a nearby span as blacklisted.

# Post-generation fixed workflow.
RUN_POST_GENERATION_PIPELINE = True
PIPELINE_VERIFY_STAGE = "stage2"
PIPELINE_VERIFY_TASK_LEVEL = "module"
PIPELINE_VERIFY_TIMEOUT_SEC = 300
PIPELINE_EXCLUDED_JSON_NAME = "excluded_forever.json"
PIPELINE_MANIFEST_JSON_NAME = "dataset_manifest.json"
PIPELINE_MANIFEST_MD_NAME = "dataset_manifest.md"
PIPELINE_ALL_SAMPLES_JSON_NAME = "all_samples_manifest.json"
PIPELINE_SUMMARY_JSON_NAME = "dataset_summary.json"

PLACEHOLDER_LINE = "// <masked:to be completed>\n"
PLACEHOLDER_STATEMENT_LINE = "begin end // <masked:to be completed>\n"

# Main leaderboard filter (weighted + core60 only).
# "strict": exclude types that were found to be weak as core evaluation samples.
# "off": keep full weighted behavior.
MAIN_EVAL_FILTER = "strict"  # "strict" or "off"
MAIN_EVAL_EXCLUDED_GROUP_TYPES = {"port_section", "param_decl", "internal_signal"}
MAIN_EVAL_EXCLUDED_BLOCK_TYPES: set[str] = set()
MAIN_EVAL_EXCLUDED_BLOCK_PREFIXES = ("pp_",)
MAIN_EVAL_WEAK_FILE_TYPE_EXCLUSIONS: dict[str, set[str]] = {
    "sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v": {"always", "instantiation", "assign"},
    "sdc/sd_bd/sd_bd.v": {"begin_end"},
    "aes/aes_key_expand_128/aes_key_expand_128.v": {"reg_cluster", "assign_cluster", "instantiation"},
    "aes/aes_cipher_top/aes_cipher_top.v": {"always"},
    "aes/aes_inv_cipher_top/aes_inv_cipher_top.v": {"counter_cluster"},
    "e203_hbirdv2/e203_biu/e203_biu.v": {"handshake"},
    "e203_hbirdv2/e203_cpu/e203_cpu.v": {"instantiation"},
    "e203_hbirdv2/e203_dtcm_ram/e203_dtcm_ram.v": {"instantiation"},
    "e203_hbirdv2/e203_exu_alu_csrctrl/e203_exu_alu_csrctrl.v": {"assign"},
    "e203_hbirdv2/e203_exu_alu_lsuagu/e203_exu_alu_lsuagu.v": {"bus_cluster"},
    "e203_hbirdv2/e203_exu_decode/e203_exu_decode.v": {"assign"},
    "e203_hbirdv2/e203_exu_excp/e203_exu_excp.v": {"assign"},
    "e203_hbirdv2/e203_exu_longpwbck/e203_exu_longpwbck.v": {"assign"},
    "e203_hbirdv2/e203_exu_regfile/e203_exu_regfile.v": {"assign", "instantiation"},
    "e203_hbirdv2/e203_irq_sync/e203_irq_sync.v": {"assign_cluster"},
    "e203_hbirdv2/e203_itcm_ram/e203_itcm_ram.v": {"instantiation"},
    "e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v": {"instantiation"},
    "e203_hbirdv2/e203_srams/e203_srams.v": {"instantiation"},
}
MAIN_EVAL_FILE_MAX_VARIANTS: dict[str, int] = {
    "sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v": 2,
    "aes/aes_key_expand_128/aes_key_expand_128.v": 4,
    "aes/aes_cipher_top/aes_cipher_top.v": 6,
    "e203_hbirdv2/e203_exu_decode/e203_exu_decode.v": 4,
    "e203_hbirdv2/e203_exu_alu/e203_exu_alu.v": 5,
    "e203_hbirdv2/e203_exu_excp/e203_exu_excp.v": 4,
}
MAIN_EVAL_FILE_VARIANT_BONUSES: dict[str, int] = {
    "sdc/sd_controller_wb/sd_controller_wb.v": 2,
    "aes/aes_key_expand_128/aes_key_expand_128.v": 2,
    "aes/aes_cipher_top/aes_cipher_top.v": 2,
    "aes/aes_inv_cipher_top/aes_inv_cipher_top.v": 2,
    "e203_hbirdv2/e203_exu_alu/e203_exu_alu.v": 2,
    "e203_hbirdv2/e203_exu_alu_lsuagu/e203_exu_alu_lsuagu.v": 2,
    "e203_hbirdv2/e203_exu_decode/e203_exu_decode.v": 2,
    "e203_hbirdv2/e203_irq_sync/e203_irq_sync.v": 2,
    "e203_hbirdv2/e203_lsu_ctrl/e203_lsu_ctrl.v": 2,
    "e203_hbirdv2/e203_ifu_ifetch/e203_ifu_ifetch.v": 1,
    "e203_hbirdv2/e203_ifu_ift2icb/e203_ifu_ift2icb.v": 1,
    "e203_hbirdv2/e203_exu_csr/e203_exu_csr.v": 1,
    "e203_hbirdv2/e203_exu_oitf/e203_exu_oitf.v": 1,
    "e203_hbirdv2/e203_exu_alu_dpath/e203_exu_alu_dpath.v": 1,
    "e203_hbirdv2/e203_reset_ctrl/e203_reset_ctrl.v": 1,
    "sdc/sd_cmd_master/sd_cmd_master.v": 4,
    "sdc/sd_cmd_serial_host/sd_cmd_serial_host.v": 4,
    "sdc/sd_data_master/sd_data_master.v": 3,
    "sdc/sd_data_serial_host/sd_data_serial_host.v": 3,
    "sdc/sd_rx_fifo/sd_rx_fifo.v": 1,
    "sdc/sd_tx_fifo/sd_tx_fifo.v": 1,
}

# Restrictive modes: when no eligible span in a file, skip writing this file.
SKIP_IF_EMPTY_CANDIDATE_MODES = {"body", "head_only", "decl", "complex", "group_only", "block_only"}

# Strict category families (avoid cross-category mixing).
DECL_GROUP_TYPES = {"port_section", "param_decl", "internal_signal"}
BEHAVIOR_GROUP_TYPES = {"assign_cluster", "reg_cluster", "comb_cluster", "counter_cluster", "handshake", "bus_cluster", "cdcsync", "fsm"}
COMPLEX_BLOCK_TYPES = {"function", "task", "case", "casex", "casez", "generate", "fork"}
PROCEDURAL_BLOCK_TYPES = {
    "always",
    "always_comb",
    "always_ff",
    "always_latch",
    "initial",
    "final",
    "function",
    "task",
    "case",
    "casex",
    "casez",
    "begin_end",
    "fork",
    "generate",
}

# One-line block expansion (for block-level completion positioning).
# If a candidate is a compact one-line behavioral block (e.g. instantiation/always/
# assign/pp-branch), include nearby one-line neighbor blocks above/below to reduce
# trivial line-level holes.
EXPAND_ONE_LINE_BLOCK_CONTEXT = True
ONE_LINE_CONTEXT_NEIGHBORS_EACH_SIDE = 2
ONE_LINE_CONTEXT_MAX_GAP_LINES = 6
ONE_LINE_CONTEXT_CENTER_TYPES = {
    "instantiation",
    "assign",
    "always",
    "always_comb",
    "always_ff",
    "always_latch",
    "pp_ifdef_branch",
    "pp_ifndef_branch",
    "pp_else_branch",
}


_CUT_RE = re.compile(
    r"^//__RB_CUT_(?P<tag>BEGIN|HEAD|BODY|TAIL|END)__\s+type=(?P<type>\S+)\s+id=(?P<id>\S+)\s+file=(?P<file>\S+)\s+lines=(?P<s>\d+)-(?P<e>\d+)\s*$"
)
_GROUP_RE = re.compile(
    r"^//__RB_CUT_GROUP_(?P<tag>BEGIN|END)__\s+type=(?P<type>\S+)\s+id=(?P<id>\S+)\s+file=(?P<file>\S+)\s+lines=(?P<s>\d+)-(?P<e>\d+)\s*$"
)


@dataclass(frozen=True)
class CutBlock:
    block_type: str
    block_id: str
    file: str
    span_lines: tuple[int, int]
    markers: dict[str, int]


@dataclass(frozen=True)
class CutGroup:
    group_type: str
    group_id: str
    file: str
    span_lines: tuple[int, int]
    markers: dict[str, int]


@dataclass(frozen=True)
class MaskSpan:
    kind: str  # block | group
    unit_type: str
    unit_id: str
    file: str
    span_lines: tuple[int, int]
    start_idx: int
    end_idx: int
    region: str  # whole | body
    parent_group_type: str | None = None
    parent_group_id: str | None = None


def _mask_signature_record(
    file: str,
    masked_kind: str,
    masked_type: str,
    span_lines: str,
    region: str,
    parent_group_type: str = "",
) -> dict[str, str]:
    return {
        "file": str(file),
        "masked_kind": str(masked_kind),
        "masked_type": str(masked_type),
        "masked_span_lines": str(span_lines),
        "region": str(region),
        "parent_group_type": str(parent_group_type),
    }


def _mask_signature_key(record: Mapping[str, Any]) -> str:
    return "|".join(
        [
            str(record.get("file", "")),
            str(record.get("masked_kind", "")),
            str(record.get("masked_type", "")),
            str(record.get("masked_span_lines", "")),
            str(record.get("region", "")),
            str(record.get("parent_group_type", "")),
        ]
    )


def _mask_location_key(record: Mapping[str, Any]) -> str:
    return "|".join(
        [
            str(record.get("file", "")),
            str(record.get("masked_span_lines", "")),
            str(record.get("region", "")),
        ]
    )


def _parse_span_lines(span_lines: Any) -> tuple[int, int] | None:
    text = str(span_lines or "").strip()
    match = re.fullmatch(r"(\d+)-(\d+)", text)
    if not match:
        return None
    start = int(match.group(1))
    end = int(match.group(2))
    if end < start:
        start, end = end, start
    return start, end


def _span_overlap_ratio(a: tuple[int, int], b: tuple[int, int]) -> float:
    overlap_start = max(a[0], b[0])
    overlap_end = min(a[1], b[1])
    if overlap_end < overlap_start:
        return 0.0
    overlap_len = overlap_end - overlap_start + 1
    a_len = max(1, a[1] - a[0] + 1)
    b_len = max(1, b[1] - b[0] + 1)
    return max(overlap_len / a_len, overlap_len / b_len)


def _location_key_components(location_key: str) -> tuple[str, tuple[int, int] | None, str]:
    parts = str(location_key).split("|", 2)
    if len(parts) != 3:
        return "", None, ""
    file, span_lines, region = parts
    return file, _parse_span_lines(span_lines), region


def _is_location_blocked(
    record: Mapping[str, Any],
    excluded_location_keys: set[str],
    excluded_location_index: Mapping[tuple[str, str], Sequence[tuple[int, int]]],
) -> bool:
    location_key = _mask_location_key(record)
    if location_key in excluded_location_keys:
        return True
    file = str(record.get("file", ""))
    region = str(record.get("region", ""))
    candidate_span = _parse_span_lines(record.get("masked_span_lines"))
    if candidate_span is None:
        return False
    for blocked_span in excluded_location_index.get((file, region), []):
        if _span_overlap_ratio(candidate_span, blocked_span) >= BLACKLIST_OVERLAP_MIN_RATIO:
            return True
    return False


def _span_signature_record(rel_file: str, span: MaskSpan) -> dict[str, str]:
    return _mask_signature_record(
        file=rel_file,
        masked_kind=span.kind,
        masked_type=span.unit_type,
        span_lines=f"{span.span_lines[0]}-{span.span_lines[1]}",
        region=span.region,
        parent_group_type="None" if span.parent_group_type in {None, ""} else str(span.parent_group_type),
    )


def _question_type_name(masked_kind: str, masked_type: str, parent_group_type: str = "") -> str:
    if parent_group_type in COMPLEX_GROUP_BLOCK_PARENT_TYPES and masked_kind == "block":
        return f"{parent_group_type}_block"
    return masked_type


def _selection_type_name(span: MaskSpan) -> str:
    return _question_type_name(span.kind, span.unit_type, span.parent_group_type or "")


def _masked_item_signature_record(masked_item: Mapping[str, Any]) -> dict[str, str]:
    return _mask_signature_record(
        file=str(masked_item.get("file", "")),
        masked_kind=str(masked_item.get("kind", "")),
        masked_type=str(masked_item.get("type", "")),
        span_lines=str(masked_item.get("span_lines", "")),
        region=str(masked_item.get("region", "")),
        parent_group_type=str(masked_item.get("parent_group_type", "")),
    )


def _load_global_exclusion_blacklist(path: Path) -> tuple[list[dict[str, Any]], set[str], set[str]]:
    if not path.exists():
        return [], set(), set()
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except Exception:
        return [], set(), set()
    entries = list(data.get("entries", []))
    keys = {_mask_signature_key(entry) for entry in entries}
    location_keys = {_mask_location_key(entry) for entry in entries}
    return entries, keys, location_keys


def _build_excluded_location_index(location_keys: set[str]) -> dict[tuple[str, str], list[tuple[int, int]]]:
    index: dict[tuple[str, str], list[tuple[int, int]]] = {}
    for location_key in location_keys:
        file, span, region = _location_key_components(location_key)
        if not file or not region or span is None:
            continue
        index.setdefault((file, region), []).append(span)
    return index


def _write_global_exclusion_blacklist(path: Path, entries: Sequence[Mapping[str, Any]]) -> None:
    dedup: dict[str, dict[str, Any]] = {}
    for entry in entries:
        dedup[_mask_signature_key(entry)] = dict(entry)
    payload = {
        "version": 1,
        "entries": [dedup[key] for key in sorted(dedup.keys())],
    }
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def _iter_verilog_files(root: Path) -> Iterator[Path]:
    for p in root.rglob("*.v"):
        if p.is_file():
            yield p


def _core60_task_set() -> set[tuple[str, str]]:
    return {
        (system_name, task_name)
        for system_name, modules in BENCHMARK_INFO.items()
        for task_name in modules.keys()
    }


def _is_core60_file(rel: Path, core60_tasks: set[tuple[str, str]]) -> bool:
    parts = rel.as_posix().split("/")
    if len(parts) != 3:
        return False
    system_name, task_name, filename = parts
    if (system_name, task_name) not in core60_tasks:
        return False
    return filename == f"{task_name}.v"


def _filter_files_by_scope(
    files: Sequence[Path],
    input_root: Path,
    task_scope: str,
    core60_tasks: set[tuple[str, str]],
) -> list[Path]:
    if task_scope == "all82":
        return list(files)
    if task_scope != "core60":
        raise ValueError(f"Unsupported TASK_SCOPE={task_scope!r}, expected core60/all82")
    out: list[Path] = []
    for path in files:
        rel = path.relative_to(input_root)
        if _is_core60_file(rel, core60_tasks):
            out.append(path)
    return out


def _parse_units(lines: Sequence[str]) -> tuple[dict[str, CutBlock], dict[str, CutGroup], list[dict[str, Any]]]:
    blocks: dict[str, dict[str, Any]] = {}
    groups: dict[str, dict[str, Any]] = {}
    all_units: list[dict[str, Any]] = []
    for i, raw in enumerate(lines):
        s = raw.rstrip("\n")
        m = _CUT_RE.match(s)
        if m:
            tag = m.group("tag")
            tid = m.group("id")
            ttype = m.group("type")
            f = m.group("file")
            span = (int(m.group("s")), int(m.group("e")))
            d = blocks.setdefault(tid, {"type": ttype, "file": f, "span": span, "markers": {}})
            d["markers"][tag] = i
            continue
        mg = _GROUP_RE.match(s)
        if mg:
            tag = mg.group("tag")
            tid = mg.group("id")
            ttype = mg.group("type")
            f = mg.group("file")
            span = (int(mg.group("s")), int(mg.group("e")))
            d = groups.setdefault(tid, {"type": ttype, "file": f, "span": span, "markers": {}})
            d["markers"][tag] = i
            continue
    out_blocks: dict[str, CutBlock] = {}
    for bid, d in blocks.items():
        out_blocks[bid] = CutBlock(d["type"], bid, d["file"], d["span"], dict(d["markers"]))
        all_units.append({"kind": "block", "type": d["type"], "id": bid, "file": d["file"], "lines": f"{d['span'][0]}-{d['span'][1]}"})
    out_groups: dict[str, CutGroup] = {}
    for gid, d in groups.items():
        out_groups[gid] = CutGroup(d["type"], gid, d["file"], d["span"], dict(d["markers"]))
        all_units.append({"kind": "group", "type": d["type"], "id": gid, "file": d["file"], "lines": f"{d['span'][0]}-{d['span'][1]}"})
    all_units.sort(key=lambda x: (x["kind"], x["type"], x["id"]))
    return out_blocks, out_groups, all_units


def _span_nonempty(start_idx: int, end_idx: int) -> bool:
    return 0 <= start_idx <= end_idx


def _mk_block_span(b: CutBlock, start_idx: int, end_idx: int, region: str) -> list[MaskSpan]:
    if not _span_nonempty(start_idx, end_idx):
        return []
    return [
        MaskSpan(
            kind="block",
            unit_type=b.block_type,
            unit_id=b.block_id,
            file=b.file,
            span_lines=b.span_lines,
            start_idx=start_idx,
            end_idx=end_idx,
            region=region,
        )
    ]


def _build_spans_for_block(b: CutBlock, mode: str, lines: Sequence[str]) -> list[MaskSpan]:
    m = b.markers
    if "BEGIN" not in m or "END" not in m:
        return []
    begin_i = m["BEGIN"]
    end_i = m["END"]

    if mode == "whole":
        return _mk_block_span(b, begin_i + 1, end_i - 1, "whole")

    if mode == "body":
        # Keep legacy body-only behavior: prefer BODY..TAIL interior.
        if "BODY" not in m or "TAIL" not in m:
            return []
        return _mk_block_span(b, m["BODY"] + 1, m["TAIL"] - 1, "body")

    if mode == "body_to_tail":
        # From BODY marker to just before TAIL marker (exclude tail section itself).
        if "BODY" not in m or "TAIL" not in m:
            return []
        return _mk_block_span(b, m["BODY"] + 1, m["TAIL"] - 1, "body_to_tail")

    if mode == "head_to_tail":
        # From HEAD marker to just before TAIL marker (exclude tail section itself).
        if "HEAD" not in m or "TAIL" not in m:
            return []
        return _mk_block_span(b, m["HEAD"] + 1, m["TAIL"] - 1, "head_to_tail")

    if mode == "head_only":
        if "HEAD" not in m or "BODY" not in m:
            return []
        return _mk_block_span(b, m["HEAD"] + 1, m["BODY"] - 1, "head")

    return []


def _build_spans_for_group(g: CutGroup, lines: Sequence[str]) -> list[MaskSpan]:
    m = g.markers
    if "BEGIN" not in m or "END" not in m:
        return []
    s = m["BEGIN"] + 1
    e = m["END"] - 1
    if not _span_nonempty(s, e):
        return []
    return [
        MaskSpan(
            kind="group",
            unit_type=g.group_type,
            unit_id=g.group_id,
            file=g.file,
            span_lines=g.span_lines,
            start_idx=s,
            end_idx=e,
            region="whole",
        )
    ]


def _span_is_within_group(span: MaskSpan, group: CutGroup) -> bool:
    return span.start_idx >= group.markers["BEGIN"] + 1 and span.end_idx <= group.markers["END"] - 1


def _clone_span_with_parent_group(span: MaskSpan, group: CutGroup) -> MaskSpan:
    return MaskSpan(
        kind=span.kind,
        unit_type=span.unit_type,
        unit_id=span.unit_id,
        file=span.file,
        span_lines=span.span_lines,
        start_idx=span.start_idx,
        end_idx=span.end_idx,
        region=span.region,
        parent_group_type=group.group_type,
        parent_group_id=group.group_id,
    )


def _build_spans_for_complex_group_blocks(
    blocks: Mapping[str, CutBlock],
    groups: Mapping[str, CutGroup],
    lines: Sequence[str],
) -> list[MaskSpan]:
    out: list[MaskSpan] = []
    seen: set[tuple[str, str, int, int, str, str]] = set()
    target_groups = [g for g in groups.values() if g.group_type in COMPLEX_GROUP_BLOCK_PARENT_TYPES]
    if not target_groups:
        return out

    for group in target_groups:
        variants_for_parent = COMPLEX_GROUP_BLOCK_VARIANTS_BY_PARENT_TYPE.get(
            group.group_type,
            COMPLEX_GROUP_BLOCK_VARIANTS,
        )
        for block in blocks.values():
            if block.file != group.file:
                continue
            if group.group_type in COMPLEX_GROUP_BLOCK_ALWAYS_ONLY_PARENT_TYPES and not block.block_type.startswith("always"):
                continue
            if block.block_type not in COMPLEX_GROUP_BLOCK_ALLOWED_BLOCK_TYPES and not block.block_type.startswith("always"):
                continue
            variants: list[MaskSpan] = []
            for variant in variants_for_parent:
                variants.extend(_build_spans_for_block(block, variant, lines))
            for span in variants:
                if not _span_is_within_group(span, group):
                    continue
                cloned = _clone_span_with_parent_group(span, group)
                if not _passes_complex_group_block_semantic_filter(cloned, lines):
                    continue
                key = (
                    cloned.unit_id,
                    group.group_id,
                    cloned.start_idx,
                    cloned.end_idx,
                    cloned.region,
                    group.group_type,
                )
                if key in seen:
                    continue
                seen.add(key)
                out.append(cloned)
    out.sort(key=lambda s: (s.start_idx, s.end_idx, s.unit_id, s.parent_group_id or ""))
    return out


def _span_source_len(span: MaskSpan) -> int:
    return max(0, int(span.span_lines[1]) - int(span.span_lines[0]) + 1)


def _build_ordered_whole_block_spans(
    blocks: Mapping[str, CutBlock], lines: Sequence[str]
) -> list[MaskSpan]:
    out: list[MaskSpan] = []
    for b in blocks.values():
        out.extend(_build_spans_for_block(b, "whole", lines))
    out.sort(key=lambda s: (s.start_idx, s.end_idx, s.unit_id))
    return out


def _expand_single_line_block_span(
    span: MaskSpan,
    ordered_whole_block_spans: Sequence[MaskSpan],
    index_by_unit_id: Mapping[str, int],
) -> MaskSpan:
    if not EXPAND_ONE_LINE_BLOCK_CONTEXT:
        return span
    if span.kind != "block" or span.region != "whole":
        return span
    if span.unit_type not in ONE_LINE_CONTEXT_CENTER_TYPES:
        return span
    if _span_source_len(span) != 1:
        return span

    center_idx = index_by_unit_id.get(span.unit_id)
    if center_idx is None:
        return span

    selected = [ordered_whole_block_spans[center_idx]]

    # Collect preceding one-line neighbors.
    i = center_idx - 1
    picked = 0
    prev_start_line = ordered_whole_block_spans[center_idx].span_lines[0]
    while i >= 0 and picked < ONE_LINE_CONTEXT_NEIGHBORS_EACH_SIDE:
        cand = ordered_whole_block_spans[i]
        gap = prev_start_line - cand.span_lines[1]
        if _span_source_len(cand) == 1 and gap <= ONE_LINE_CONTEXT_MAX_GAP_LINES:
            selected.append(cand)
            picked += 1
            prev_start_line = cand.span_lines[0]
            i -= 1
            continue
        break

    # Collect following one-line neighbors.
    i = center_idx + 1
    picked = 0
    next_end_line = ordered_whole_block_spans[center_idx].span_lines[1]
    while i < len(ordered_whole_block_spans) and picked < ONE_LINE_CONTEXT_NEIGHBORS_EACH_SIDE:
        cand = ordered_whole_block_spans[i]
        gap = cand.span_lines[0] - next_end_line
        if _span_source_len(cand) == 1 and gap <= ONE_LINE_CONTEXT_MAX_GAP_LINES:
            selected.append(cand)
            picked += 1
            next_end_line = cand.span_lines[1]
            i += 1
            continue
        break

    if len(selected) <= 1:
        return span

    return MaskSpan(
        kind=span.kind,
        unit_type=span.unit_type,
        unit_id=span.unit_id,
        file=span.file,
        span_lines=(
            min(s.span_lines[0] for s in selected),
            max(s.span_lines[1] for s in selected),
        ),
        start_idx=min(s.start_idx for s in selected),
        end_idx=max(s.end_idx for s in selected),
        region=span.region,
    )


def _expand_one_line_block_contexts(
    spans: Sequence[MaskSpan], blocks: Mapping[str, CutBlock], lines: Sequence[str]
) -> list[MaskSpan]:
    if not EXPAND_ONE_LINE_BLOCK_CONTEXT:
        return list(spans)
    ordered_whole_block_spans = _build_ordered_whole_block_spans(blocks, lines)
    index_by_unit_id = {s.unit_id: i for i, s in enumerate(ordered_whole_block_spans)}
    out: list[MaskSpan] = []
    for span in spans:
        out.append(_expand_single_line_block_span(span, ordered_whole_block_spans, index_by_unit_id))
    return out


def _is_main_eval_excluded_span(span: MaskSpan) -> bool:
    if span.kind == "group":
        return span.unit_type in MAIN_EVAL_EXCLUDED_GROUP_TYPES
    if span.kind == "block":
        if span.unit_type in MAIN_EVAL_EXCLUDED_BLOCK_TYPES:
            return True
        return any(span.unit_type.startswith(prefix) for prefix in MAIN_EVAL_EXCLUDED_BLOCK_PREFIXES)
    return False


def _apply_main_eval_filter_to_spans(
    spans: Sequence[MaskSpan], apply_main_eval_filter: bool
) -> list[MaskSpan]:
    if not apply_main_eval_filter:
        return list(spans)
    return [s for s in spans if not _is_main_eval_excluded_span(s)]


_IDENT_RE = re.compile(r"[A-Za-z_][A-Za-z0-9_$]*")
_ASSIGN_RHS_RE = re.compile(r"=\s*(.*?)\s*;\s*$", re.S)
_CONTROL_KEYWORD_RE = re.compile(r"\b(if|case|casex|casez|for|while|repeat|forever)\b")
_FSM_SIGNAL_RE = re.compile(r"\b(?:state|next_state|nstate|cur_state|fsm|st_[A-Za-z0-9_$]*)\b", re.I)
_COUNTER_SIGNAL_RE = re.compile(r"\b(?:cnt|count|counter|timer|tick|idx|index)\w*\b", re.I)
_COMPLEX_EXPR_TOKENS = (
    "?",
    "{",
    "[",
    "<<",
    ">>",
    "<<<",
    ">>>",
    "&&",
    "||",
    "==",
    "!=",
    "<=",
    ">=",
    "+",
    "-",
    "*",
    "/",
    "%",
    "&",
    "|",
    "^",
)
_RAM_LIKE_NAME_RE = re.compile(r"\b\w*(?:sram|ram)\w*\b", re.I)
_ADAPTIVE_STRONG_TYPES = (
    "assign_cluster",
    "handshake",
    "bus_cluster",
    "reg_cluster",
    "case",
    "fsm",
    "function",
    "generate",
    "always",
    "begin_end",
)
_ADAPTIVE_SEMANTIC_TYPES = ("case", "fsm", "function", "generate")


def _span_source_lines(span: MaskSpan, lines: Sequence[str]) -> list[str]:
    out: list[str] = []
    for i in range(span.start_idx, span.end_idx + 1):
        if i < 0 or i >= len(lines):
            continue
        line = lines[i]
        if _strip_markers(line):
            continue
        out.append(line)
    return out


def _span_nonempty_source_lines(span: MaskSpan, lines: Sequence[str]) -> list[str]:
    return [line for line in _span_source_lines(span, lines) if line.strip()]


def _span_source_text(span: MaskSpan, lines: Sequence[str]) -> str:
    return "".join(_span_source_lines(span, lines))


def _contains_complex_expr(text: str) -> bool:
    return any(tok in text for tok in _COMPLEX_EXPR_TOKENS)


def _is_complex_assign_span(span: MaskSpan, lines: Sequence[str]) -> bool:
    src_lines = _span_nonempty_source_lines(span, lines)
    if len(src_lines) >= 2:
        return True
    text = _span_source_text(span, lines)
    rhs_match = _ASSIGN_RHS_RE.search(text)
    rhs = rhs_match.group(1) if rhs_match else text
    if _contains_complex_expr(rhs):
        return True
    return len(set(_IDENT_RE.findall(rhs))) >= 2


def _is_meaningful_assign_cluster(span: MaskSpan, lines: Sequence[str]) -> bool:
    src_lines = _span_nonempty_source_lines(span, lines)
    text = _span_source_text(span, lines)
    assign_stmt_count = len(re.findall(r"\bassign\b", text))
    if assign_stmt_count >= 3:
        return True
    if assign_stmt_count >= 2 and (_contains_complex_expr(text) or len(src_lines) >= 4):
        return True
    return False


def _is_complex_instantiation(span: MaskSpan, lines: Sequence[str]) -> bool:
    src_lines = _span_nonempty_source_lines(span, lines)
    text = _span_source_text(span, lines)
    if len(src_lines) < 3:
        return False
    if _RAM_LIKE_NAME_RE.search(text):
        return False
    named_ports = len(re.findall(r"\.\s*[A-Za-z_][A-Za-z0-9_$]*\s*\(", text))
    if named_ports >= 4:
        return True
    return text.count(",") >= 5 and len(src_lines) >= 4


def _is_control_begin_end(span: MaskSpan, lines: Sequence[str]) -> bool:
    return bool(_CONTROL_KEYWORD_RE.search(_span_source_text(span, lines)))


def _is_fsm_like_block(span: MaskSpan, lines: Sequence[str]) -> bool:
    text = _span_source_text(span, lines)
    if not text.strip():
        return False
    if re.search(r"\bnext_state\b|\bnstate\b", text) and _CONTROL_KEYWORD_RE.search(text):
        return True
    if re.search(r"\bcase\b", text) and re.search(r"\bnext_state\b|\bnstate\b", text):
        return True
    if re.search(
        r"\b(?:state|cur_state|[A-Za-z_][A-Za-z0-9_$]*_state)\b\s*<=\s*(?:next_state|nstate|[A-Za-z_][A-Za-z0-9_$]*_state)\b",
        text,
    ):
        return True
    return False


def _is_counter_like_block(span: MaskSpan, lines: Sequence[str]) -> bool:
    text = _span_source_text(span, lines)
    if not text.strip() or not _COUNTER_SIGNAL_RE.search(text):
        return False
    if re.search(r"\bif\b|\bcase\b", text) and re.search(r"\+\s*1|\-\s*1|\b1\s*\+|\b1\s*\-|\+\+|\-\-", text):
        return True
    if re.search(r"<=?\s*\d+'[bdh][0-9a-f_xz]+|<=?\s*'0|<=?\s*\{?\s*1'b0", text, re.I):
        return True
    if re.search(r"[<>!=]=?|==", text) and _COUNTER_SIGNAL_RE.search(text):
        return True
    return False


def _passes_complex_group_block_semantic_filter(span: MaskSpan, lines: Sequence[str]) -> bool:
    if span.parent_group_type == "fsm":
        if span.region == "body_to_tail":
            return True
        return _is_fsm_like_block(span, lines)
    if span.parent_group_type == "counter_cluster":
        if span.region == "body_to_tail":
            return True
        return _is_counter_like_block(span, lines)
    if span.parent_group_type in {"handshake", "cdcsync"}:
        return True
    return True


def _is_zero_candidate_fallback_instantiation(span: MaskSpan, lines: Sequence[str]) -> bool:
    if span.unit_type != "instantiation":
        return False
    src_lines = _span_nonempty_source_lines(span, lines)
    text = _span_source_text(span, lines)
    named_ports = len(re.findall(r"\.\s*[A-Za-z_][A-Za-z0-9_$]*\s*\(", text))
    if len(src_lines) < 8 or named_ports < 8:
        return False
    if "#(" in text:
        return True
    if _RAM_LIKE_NAME_RE.search(text):
        return True
    return bool(re.search(r"\be203_\w+_ram\b", text))


def _passes_main_eval_quality_filter(span: MaskSpan, lines: Sequence[str]) -> bool:
    if span.parent_group_type in COMPLEX_GROUP_BLOCK_PARENT_TYPES:
        if span.unit_type == "assign":
            return _is_complex_assign_span(span, lines)
        return True
    if span.unit_type == "assign":
        return _is_complex_assign_span(span, lines)
    if span.unit_type == "assign_cluster":
        return _is_meaningful_assign_cluster(span, lines)
    if span.unit_type == "instantiation":
        return _is_complex_instantiation(span, lines)
    if span.unit_type == "begin_end":
        return _is_control_begin_end(span, lines)
    return True


def _main_eval_zero_candidate_fallback(
    spans: Sequence[MaskSpan], lines: Sequence[str]
) -> list[MaskSpan]:
    fallback = [s for s in spans if _is_zero_candidate_fallback_instantiation(s, lines)]
    fallback.sort(key=lambda s: (s.start_idx, s.end_idx, s.unit_id))
    return fallback


def _postprocess_candidate_spans(
    spans: Sequence[MaskSpan],
    blocks: Mapping[str, CutBlock],
    lines: Sequence[str],
    apply_main_eval_filter: bool,
) -> list[MaskSpan]:
    expanded = _expand_one_line_block_contexts(spans, blocks, lines)
    filtered = _apply_main_eval_filter_to_spans(expanded, apply_main_eval_filter)
    if not apply_main_eval_filter:
        return filtered
    quality = [s for s in filtered if _passes_main_eval_quality_filter(s, lines)]
    if quality:
        return quality
    return _main_eval_zero_candidate_fallback(filtered, lines)


def _span_count_by_type(spans: Sequence[MaskSpan]) -> dict[str, int]:
    counts: dict[str, int] = {}
    for span in spans:
        counts[span.unit_type] = counts.get(span.unit_type, 0) + 1
    return counts


def _adaptive_variant_cap_for_spans(
    spans: Sequence[MaskSpan],
    lines: Sequence[str],
    base_cap: int,
    apply_main_eval_filter: bool,
    policy: str,
    max_cap: int,
) -> int:
    if base_cap <= 0:
        return base_cap
    policy_norm = str(policy or "off").strip().lower()
    if policy_norm == "off" or not apply_main_eval_filter or not spans:
        return base_cap
    if policy_norm not in {"maincore_rich", "maincore_rich_v3"}:
        raise ValueError(
            f"Unsupported ADAPTIVE_VARIANT_POLICY={policy!r}, expected off/maincore_rich/maincore_rich_v3"
        )

    counts = _span_count_by_type(spans)
    strong_total = sum(counts.get(t, 0) for t in _ADAPTIVE_STRONG_TYPES)
    distinct_strong = sum(1 for t in _ADAPTIVE_STRONG_TYPES if counts.get(t, 0) > 0)
    semantic_total = sum(counts.get(t, 0) for t in _ADAPTIVE_SEMANTIC_TYPES)
    weak_total = counts.get("assign", 0) + counts.get("instantiation", 0)
    assign_cluster_count = counts.get("assign_cluster", 0)
    handshake_count = counts.get("handshake", 0)
    begin_end_count = counts.get("begin_end", 0)
    always_count = counts.get("always", 0)
    fallback_only_instantiation = (
        set(counts.keys()) == {"instantiation"}
        and all(_is_zero_candidate_fallback_instantiation(span, lines) for span in spans)
    )

    cap = base_cap
    if fallback_only_instantiation:
        return min(max_cap, cap)

    if (
        strong_total >= 5
        or semantic_total >= 1
        or assign_cluster_count >= 3
        or handshake_count >= 3
        or begin_end_count >= 10
        or always_count >= 6
    ):
        cap = max(cap, base_cap + 1)

    if (
        (strong_total >= 12 and distinct_strong >= 2)
        or semantic_total >= 2
        or assign_cluster_count >= 6
        or handshake_count >= 4
        or (begin_end_count >= 20 and always_count >= 4)
    ):
        cap = max(cap, base_cap + 2)

    if (
        semantic_total >= 6
        or (strong_total >= 35 and distinct_strong >= 3 and weak_total <= (strong_total * 3))
        or (begin_end_count >= 40 and always_count >= 8 and weak_total <= (strong_total * 2 + 12))
    ):
        cap = max(cap, base_cap + 3)

    if (
        policy_norm == "maincore_rich_v3"
        and (
            semantic_total >= 8
            or (strong_total >= 48 and distinct_strong >= 4 and weak_total <= (strong_total * 2 + 8))
            or (assign_cluster_count >= 10 and begin_end_count >= 12)
        )
    ):
        cap = max(cap, base_cap + 4)

    return min(max_cap, cap)


def _apply_file_specific_main_eval_refinements(
    spans: Sequence[MaskSpan],
    rel_file: str,
    apply_main_eval_filter: bool,
) -> list[MaskSpan]:
    if not apply_main_eval_filter:
        return list(spans)
    excluded_types = MAIN_EVAL_WEAK_FILE_TYPE_EXCLUSIONS.get(rel_file, set())
    if not excluded_types:
        return list(spans)
    return [span for span in spans if span.unit_type not in excluded_types]


def _effective_file_variant_cap(rel_file: str, cap: int, apply_main_eval_filter: bool) -> int:
    if cap <= 0 or not apply_main_eval_filter:
        return cap
    cap += max(0, int(MAIN_EVAL_FILE_VARIANT_BONUSES.get(rel_file, 0)))
    override = MAIN_EVAL_FILE_MAX_VARIANTS.get(rel_file)
    if override is None:
        return cap
    return min(cap, max(1, int(override)))


def _block_is_pp_block(t: str) -> bool:
    return t.startswith("pp_") and t.endswith("_block")


def _default_weights() -> dict[str, float]:
    return {
        "instantiation": 0.55,
        "pp_block": 0.25,
        "function": 1.0,
        "task": 1.0,
        "fsm": 1.0,
        "assign_cluster": 1.0,
        "reg_cluster": 0.8,
        "comb_cluster": 0.8,
        "counter_cluster": 0.6,
        "handshake": 0.6,
        "bus_cluster": 0.6,
        "cdcsync": 0.6,
        "port_section": 0.6,
        "param_decl": 0.6,
        "internal_signal": 0.25,
        "generate": 0.3,
        "case": 0.3,
        "fork": 0.2,
        "begin_end": 0.08,
        "always": 0.2,
        "assign": 0.03,
        "pp_ifdef_branch": 0.05,
        "pp_ifndef_branch": 0.05,
        "pp_else_branch": 0.05,
        "pp_elsif_branch": 0.05,
    }


def _load_weights(path: str | None) -> dict[str, float]:
    w = _default_weights()
    if not path:
        return w
    p = Path(path)
    if not p.exists():
        return w
    data = json.loads(p.read_text(encoding="utf-8"))
    if isinstance(data, dict):
        for k, v in data.items():
            try:
                w[str(k)] = float(v)
            except Exception:
                continue
    return w


def _candidate_spans(
    blocks: Mapping[str, CutBlock],
    groups: Mapping[str, CutGroup],
    lines: Sequence[str],
    mode: str,
    apply_main_eval_filter: bool = False,
) -> list[MaskSpan]:
    spans: list[MaskSpan] = []

    if mode in {"decl"}:
        for g in groups.values():
            if g.group_type in DECL_GROUP_TYPES:
                spans.extend(_build_spans_for_group(g, lines))
        return _postprocess_candidate_spans(spans, blocks, lines, apply_main_eval_filter)

    if mode in {"complex"}:
        # Strict complex-mode: control-heavy structures only.
        for b in blocks.values():
            if b.block_type in COMPLEX_BLOCK_TYPES:
                spans.extend(_build_spans_for_block(b, "whole", lines))
        for g in groups.values():
            if g.group_type in {"fsm", "counter_cluster", "cdcsync"}:
                spans.extend(_build_spans_for_group(g, lines))
        return _postprocess_candidate_spans(spans, blocks, lines, apply_main_eval_filter)

    if mode in {"body"}:
        # Strict body-mode: only procedural/control block bodies.
        for b in blocks.values():
            if b.block_type in PROCEDURAL_BLOCK_TYPES:
                spans.extend(_build_spans_for_block(b, "body", lines))
        return _postprocess_candidate_spans(spans, blocks, lines, apply_main_eval_filter)

    if mode in {"head_only"}:
        # Merge sparse head-only with declaration-style questions.
        for g in groups.values():
            if g.group_type in DECL_GROUP_TYPES:
                spans.extend(_build_spans_for_group(g, lines))
        for b in blocks.values():
            if b.block_type in {"function", "task"}:
                spans.extend(_build_spans_for_block(b, "head_only", lines))
        return _postprocess_candidate_spans(spans, blocks, lines, apply_main_eval_filter)

    if mode in {"weighted"}:
        # Pure full weighted mode: include all detectable groups and blocks.
        # Keep only syntax-preserving block variants. Partial block variants like
        # body_to_tail/head_to_tail break surrounding always/if/case structure when
        # replaced by a placeholder line, causing masked-sample verification to fail
        # before the normal simulation-based filtering stage can run.
        for g in groups.values():
            spans.extend(_build_spans_for_group(g, lines))
        for b in blocks.values():
            variants: list[MaskSpan] = []
            variants.extend(_build_spans_for_block(b, "whole", lines))
            seen: set[tuple[int, int, str]] = set()
            for v in variants:
                k = (v.start_idx, v.end_idx, v.region)
                if k in seen:
                    continue
                seen.add(k)
                spans.append(v)
            spans.extend(_build_spans_for_complex_group_blocks(blocks, groups, lines))
        return _postprocess_candidate_spans(spans, blocks, lines, apply_main_eval_filter)

    if mode in {"random"}:
        for g in groups.values():
            if g.group_type == "assign_cluster":
                spans.extend(_build_spans_for_group(g, lines))
            elif g.group_type in {"reg_cluster", "comb_cluster", "counter_cluster", "handshake", "bus_cluster", "cdcsync", "fsm"}:
                spans.extend(_build_spans_for_group(g, lines))
            elif g.group_type in {"port_section", "param_decl", "internal_signal"}:
                spans.extend(_build_spans_for_group(g, lines))
        for b in blocks.values():
            bt = b.block_type
            if bt == "instantiation" or bt in {"function", "task"} or _block_is_pp_block(bt):
                spans.extend(_build_spans_for_block(b, "whole", lines))
            elif bt in {"begin_end", "case", "generate", "fork", "assign"} or bt.startswith("always"):
                spans.extend(_build_spans_for_block(b, "whole", lines))
        return _postprocess_candidate_spans(spans, blocks, lines, apply_main_eval_filter)

    if mode in {"group_only"}:
        # Strict group-only: behavior groups only (exclude decl groups).
        for g in groups.values():
            if g.group_type in BEHAVIOR_GROUP_TYPES:
                spans.extend(_build_spans_for_group(g, lines))
        return _postprocess_candidate_spans(spans, blocks, lines, apply_main_eval_filter)

    if mode in {"block_only"}:
        for b in blocks.values():
            spans.extend(_build_spans_for_block(b, "whole", lines))
        return _postprocess_candidate_spans(spans, blocks, lines, apply_main_eval_filter)

    return _postprocess_candidate_spans(spans, blocks, lines, apply_main_eval_filter)


def _weight_key(kind: str, unit_type: str) -> str:
    if kind == "block" and _block_is_pp_block(unit_type):
        return "pp_block"
    return unit_type


def _span_effective_weight(
    span: MaskSpan,
    weights: Mapping[str, float],
    complex_type_boosts: Mapping[str, float] | None,
) -> float:
    selection_type = _selection_type_name(span)
    weight_key = _weight_key(span.kind, selection_type)
    weight = float(weights.get(weight_key, 1.0))
    if complex_type_boosts:
        weight *= max(0.0, float(complex_type_boosts.get(selection_type, complex_type_boosts.get(span.unit_type, 1.0))))
    if span.parent_group_type:
        weight *= max(0.0, float(COMPLEX_GROUP_BLOCK_PARENT_BOOSTS.get(span.parent_group_type, 1.0)))
    return weight


def _weighted_pick_index(items_len: int, weights: Sequence[float], rng: random.Random) -> int | None:
    if items_len <= 0:
        return None
    total = sum(weights)
    if total <= 0:
        return rng.randrange(items_len)
    r = rng.random() * total
    acc = 0.0
    for i, w in enumerate(weights):
        acc += w
        if acc >= r:
            return i
    return items_len - 1


def _pick_preferred_span_for_forced_types(
    eligible: Sequence[MaskSpan],
    force_types: set[str],
    rng: random.Random,
) -> MaskSpan | None:
    forced = [span for span in eligible if _selection_type_name(span) in force_types]
    if not forced:
        return None

    def _score(span: MaskSpan) -> tuple[int, int, str, str, int, int]:
        selection_type = _selection_type_name(span)
        parent_penalty = 1 if span.parent_group_type is not None else 0
        region_penalty = 0 if span.region == "whole" else 1
        return (
            parent_penalty,
            region_penalty,
            selection_type,
            span.unit_type,
            span.start_idx,
            span.end_idx,
        )

    best_score: tuple[int, int, str, str, int, int] | None = None
    best_spans: list[MaskSpan] = []
    for span in forced:
        score = _score(span)
        if best_score is None or score < best_score:
            best_score = score
            best_spans = [span]
        elif score == best_score:
            best_spans.append(span)
    return rng.choice(best_spans) if best_spans else None


def _overlaps(a: MaskSpan, b: MaskSpan) -> bool:
    return not (a.end_idx < b.start_idx or b.end_idx < a.start_idx)


def _group_overlap_exempt(a: MaskSpan, b: MaskSpan) -> bool:
    if not _overlaps(a, b):
        return False

    def _exempt_group(span: MaskSpan) -> str | None:
        selection_type = _selection_type_name(span)
        if selection_type in OVERLAP_EXEMPT_GROUPS:
            return selection_type
        parent = span.parent_group_type or ""
        if parent in OVERLAP_EXEMPT_GROUPS:
            return parent
        if selection_type.endswith("_block"):
            base = selection_type[: -len("_block")]
            if base in OVERLAP_EXEMPT_GROUPS:
                return base
        return None

    return _exempt_group(a) is not None or _exempt_group(b) is not None


def _fsm_special_variant_budget(spans: list[MaskSpan]) -> int:
    def _mask_types(span: MaskSpan) -> set[str]:
        types = {span.unit_type, _selection_type_name(span)}
        if span.parent_group_type:
            types.add(span.parent_group_type)
            types.add(f"{span.parent_group_type}_block")
        return types

    present = {mask_type for span in spans for mask_type in _mask_types(span)}
    if all(mask_type in present for mask_type in FSM_SPECIAL_TYPES):
        return FSM_SPECIAL_FILE_EXTRA_VARIANTS
    return 0


def _pick_priority_pure_fsm_span(rel_file: str, spans: Sequence[MaskSpan]) -> MaskSpan | None:
    if rel_file not in PURE_FSM_PRIORITY_FILES:
        return None

    pure_fsm_spans = [span for span in spans if _selection_type_name(span) == "fsm"]
    if not pure_fsm_spans:
        return None

    def _score(span: MaskSpan) -> tuple[int, int, int, int]:
        region_penalty = 0 if span.region == "whole" else 1
        parent_penalty = 1 if span.parent_group_type is not None else 0
        width = span.end_idx - span.start_idx
        return (region_penalty, parent_penalty, -width, span.start_idx)

    return min(pure_fsm_spans, key=_score)


def _select_spans(
    spans: list[MaskSpan],
    mode: str,
    max_mask: int,
    fixed_one: bool,
    random_mask_count: bool,
    weights: Mapping[str, float],
    rng: random.Random,
    selected_type_counts: Mapping[str, int] | None = None,
    global_selected_total: int = 0,
    candidate_unit_count_by_type: Mapping[str, int] | None = None,
    type_cap_ratio: float = 0.0,
    rarity_alpha: float = 0.0,
    force_types: set[str] | None = None,
    complex_type_boosts: Mapping[str, float] | None = None,
) -> list[MaskSpan]:
    if not spans:
        return []
    if fixed_one:
        target = 1
    elif random_mask_count:
        upper = max(1, int(max_mask))
        target = rng.randint(1, upper)
    else:
        target = max_mask
    target = max(0, target)
    selected: list[MaskSpan] = []

    def can_add(x: MaskSpan) -> bool:
        for y in selected:
            if _overlaps(x, y) and not _group_overlap_exempt(x, y):
                return False
        return True

    pool = list(spans)
    if mode == "weighted":
        # Weighted unit-first selection to avoid over-sampling units that have
        # multiple span variants (e.g. whole/body_to_tail/head_to_tail).
        unit_to_spans: dict[tuple[str, str], list[MaskSpan]] = {}
        for s in pool:
            unit_to_spans.setdefault((s.kind, s.unit_id), []).append(s)

        force_types = set(force_types or set())
        max_candidate_count = 1
        if candidate_unit_count_by_type:
            max_candidate_count = max(1, max(int(v) for v in candidate_unit_count_by_type.values()))

        local_type_counts: dict[str, int] = {}
        while len(selected) < target and unit_to_spans:
            unit_keys = list(unit_to_spans.keys())

            if force_types:
                forced_keys = [k for k in unit_keys if _selection_type_name(unit_to_spans[k][0]) in force_types]
                if forced_keys:
                    unit_keys = forced_keys

            unit_weights: list[float] = []
            for k in unit_keys:
                first = unit_to_spans[k][0]
                unit_type = _selection_type_name(first)
                w = max(0.0, _span_effective_weight(first, weights, complex_type_boosts))

                if candidate_unit_count_by_type and rarity_alpha > 0:
                    c = max(1, int(candidate_unit_count_by_type.get(unit_type, 1)))
                    rarity_boost = (max_candidate_count / c) ** rarity_alpha
                    w *= rarity_boost

                prior = int((selected_type_counts or {}).get(unit_type, 0)) + int(local_type_counts.get(unit_type, 0))
                w /= (1.0 + prior)

                if type_cap_ratio > 0:
                    projected_total = max(1, global_selected_total + len(selected) + 1)
                    cap = max(1, int(projected_total * type_cap_ratio))
                    if prior >= cap:
                        w *= 0.02

                unit_weights.append(w)

            pick_i = _weighted_pick_index(len(unit_keys), unit_weights, rng)
            if pick_i is None:
                break
            pick_key = unit_keys[pick_i]
            variants = unit_to_spans.pop(pick_key)

            eligible = [v for v in variants if can_add(v)]
            if not eligible:
                continue

            pick = _pick_preferred_span_for_forced_types(eligible, force_types, rng)
            if pick is None:
                pick = rng.choice(eligible)
            selected.append(pick)
            pick_type = _selection_type_name(pick)
            local_type_counts[pick_type] = local_type_counts.get(pick_type, 0) + 1
            if pick_type in force_types:
                force_types.discard(pick_type)
        return selected

    while len(selected) < target and pool:
        # random and other non-weighted modes should use uniform random pick.
        pick = rng.choice(pool)
        if pick is None:
            break
        pool = [p for p in pool if not (p.kind == pick.kind and p.unit_id == pick.unit_id)]
        if can_add(pick):
            selected.append(pick)
    return selected


def _strip_markers(line: str) -> bool:
    s = line.lstrip()
    if s.startswith("//__RB_CUT_"):
        return True
    if s.startswith("//__RB_CUT_GROUP_"):
        return True
    return False


def _compute_indent(lines: Sequence[str], start_idx: int, end_idx: int) -> str:
    for i in range(start_idx, end_idx + 1):
        ln = lines[i]
        if _strip_markers(ln):
            continue
        if not ln.strip():
            continue
        return re.match(r"^\s*", ln).group(0)
    return ""


def _placeholder_line_for_span(span: MaskSpan) -> str:
    return PLACEHOLDER_LINE


def _apply_masks(lines: list[str], spans: Sequence[MaskSpan]) -> tuple[list[str], list[dict[str, Any]]]:
    masked_items: list[dict[str, Any]] = []
    mark = [False] * len(lines)
    spans_sorted = sorted(spans, key=lambda x: (x.start_idx, -x.end_idx))
    for s in spans_sorted:
        for i in range(s.start_idx, s.end_idx + 1):
            mark[i] = True

    covered = set()
    for s in spans_sorted:
        key = (s.start_idx, s.end_idx)
        if key in covered:
            continue
        covered.add(key)
        answer_lines = [lines[i] for i in range(s.start_idx, s.end_idx + 1) if not _strip_markers(lines[i])]
        answer = "".join(answer_lines)
        indent = _compute_indent(lines, s.start_idx, s.end_idx)
        masked_items.append(
            {
                "kind": s.kind,
                "type": s.unit_type,
                "question_type": _question_type_name(
                    s.kind,
                    s.unit_type,
                    s.parent_group_type or "",
                ),
                "id": s.unit_id,
                "file": s.file,
                "span_lines": f"{s.span_lines[0]}-{s.span_lines[1]}",
                "region": s.region,
                "parent_group_type": s.parent_group_type,
                "parent_group_id": s.parent_group_id,
                "answer": answer,
            }
        )
        lines[s.start_idx] = indent + _placeholder_line_for_span(s).lstrip()
        for i in range(s.start_idx + 1, s.end_idx + 1):
            lines[i] = ""

    out = [ln for ln in lines if ln != ""]
    out = [ln for ln in out if not _strip_markers(ln)]
    return out, masked_items


def _related_docs(base_dir: Path, rel_verilog: str) -> list[str]:
    p = Path(rel_verilog)
    stem = p.stem
    candidates: list[Path] = []
    here = (base_dir / p).parent
    candidates.extend(here.glob("*.md"))
    cand = here / f"{stem}.md"
    if cand.exists():
        candidates.insert(0, cand)
    parent = here.parent
    if parent.exists():
        candidates.extend(parent.glob("*.md"))
    uniq: list[str] = []
    seen: set[str] = set()
    for c in candidates:
        try:
            r = str(c.relative_to(base_dir))
        except Exception:
            continue
        if r not in seen:
            seen.add(r)
            uniq.append(r)
    return uniq[:10]


def _variant_out_file(base_out_file: Path, variant_index: int) -> Path:
    return base_out_file.with_name(f"{base_out_file.stem}__mask{variant_index:04d}{base_out_file.suffix}")


def _cleanup_existing_mask_variants(
    out_dir: Path,
    scoped_files: Sequence[Path],
    input_root: Path,
) -> None:
    for in_file in scoped_files:
        rel = in_file.relative_to(input_root)
        out_base = out_dir / rel
        out_parent = out_base.parent
        if not out_parent.exists():
            continue

        for stale_verilog in out_parent.glob(f"{out_base.stem}__mask*{out_base.suffix}"):
            stale_verilog.unlink()
            stale_json = Path(str(stale_verilog) + PER_FILE_JSON_SUFFIX)
            if stale_json.exists():
                stale_json.unlink()


def _filter_excluded_spans(
    spans: Sequence[MaskSpan],
    rel_file: str,
    excluded_signature_keys: set[str],
    excluded_location_keys: set[str],
) -> list[MaskSpan]:
    if not excluded_signature_keys and not excluded_location_keys:
        return list(spans)
    excluded_location_index = _build_excluded_location_index(excluded_location_keys)
    out: list[MaskSpan] = []
    for span in spans:
        record = _span_signature_record(rel_file, span)
        key = _mask_signature_key(record)
        if key in excluded_signature_keys or _is_location_blocked(
            record,
            excluded_location_keys,
            excluded_location_index,
        ):
            continue
        out.append(span)
    return out


def _contains(a: MaskSpan, b: MaskSpan) -> bool:
    return a.start_idx <= b.start_idx and a.end_idx >= b.end_idx and (a.start_idx, a.end_idx) != (b.start_idx, b.end_idx)


def _non_container_spans(spans: Sequence[MaskSpan]) -> list[MaskSpan]:
    out: list[MaskSpan] = []
    for i, s in enumerate(spans):
        is_container = False
        for j, t in enumerate(spans):
            if i == j:
                continue
            if _contains(s, t):
                is_container = True
                break
        if not is_container:
            out.append(s)
    return out


def _process_file(
    in_file: Path,
    out_file: Path,
    mode: str,
    max_mask: int,
    fixed_one: bool,
    random_mask_count: bool,
    weights: Mapping[str, float],
    rng: random.Random,
    input_root: Path,
    docs_root: Path,
    output_root: Path,
    selected_type_counts: Mapping[str, int] | None = None,
    global_selected_total: int = 0,
    candidate_unit_count_by_type: Mapping[str, int] | None = None,
    type_cap_ratio: float = 0.0,
    rarity_alpha: float = 0.0,
    force_type_targets: Mapping[str, int] | None = None,
    max_variants_per_file: int = 0,
    adaptive_variant_policy: str = "off",
    adaptive_max_variants_per_file: int = 0,
    complex_type_boosts: Mapping[str, float] | None = None,
    apply_main_eval_filter: bool = False,
    excluded_signature_keys: set[str] | None = None,
    excluded_location_keys: set[str] | None = None,
) -> list[dict[str, Any]] | None:
    raw = in_file.read_text(encoding="utf-8", errors="ignore")
    lines = raw.splitlines(keepends=True)
    blocks, groups, all_units = _parse_units(lines)
    spans = _candidate_spans(blocks, groups, lines, mode, apply_main_eval_filter=apply_main_eval_filter)
    rel_file = str(in_file.relative_to(input_root).as_posix())
    spans = _apply_file_specific_main_eval_refinements(
        spans,
        rel_file,
        apply_main_eval_filter=apply_main_eval_filter,
    )
    spans = _filter_excluded_spans(
        spans,
        rel_file,
        excluded_signature_keys or set(),
        excluded_location_keys or set(),
    )

    if (not spans) and ((mode in SKIP_IF_EMPTY_CANDIDATE_MODES) or apply_main_eval_filter):
        return None

    related_docs = _related_docs(docs_root, rel_file)
    remaining_pool = list(spans)
    force_type_targets_remaining: dict[str, int] = {
        str(k): max(0, int(v)) for k, v in (force_type_targets or {}).items() if int(v) > 0
    }
    entries: list[dict[str, Any]] = []
    generated_pure_fsm_unit_ids: set[str] = set()
    variant_index = 0
    effective_max_variants_per_file = _adaptive_variant_cap_for_spans(
        spans,
        lines,
        max_variants_per_file,
        apply_main_eval_filter=apply_main_eval_filter,
        policy=adaptive_variant_policy,
        max_cap=adaptive_max_variants_per_file if adaptive_max_variants_per_file > 0 else max_variants_per_file,
    )
    effective_max_variants_per_file = _effective_file_variant_cap(
        rel_file,
        effective_max_variants_per_file,
        apply_main_eval_filter=apply_main_eval_filter,
    )
    effective_max_variants_per_file += _fsm_special_variant_budget(spans)

    def _mask_types(span: MaskSpan) -> set[str]:
        types = {span.unit_type, _selection_type_name(span)}
        if span.parent_group_type:
            types.add(span.parent_group_type)
            types.add(f"{span.parent_group_type}_block")
        return types

    priority_fsm_span = _pick_priority_pure_fsm_span(rel_file, remaining_pool)
    if priority_fsm_span is not None and (effective_max_variants_per_file <= 0 or variant_index < effective_max_variants_per_file):
        variant_index += 1
        v_out_file = _variant_out_file(out_file, variant_index)
        out_lines, masked_items = _apply_masks(list(lines), [priority_fsm_span])
        if priority_fsm_span.unit_id:
            generated_pure_fsm_unit_ids.add(str(priority_fsm_span.unit_id))
        entries.append(
            {
                "file": rel_file,
                "variant_index": variant_index,
                "output_file": str(v_out_file.relative_to(output_root).as_posix()),
                "mode": mode,
                "masked": masked_items,
                "all_units": all_units,
                "related_docs": related_docs,
                "_out_text": "".join(out_lines),
            }
        )
        remaining_pool = [
            p for p in remaining_pool if not _overlaps(p, priority_fsm_span) or _group_overlap_exempt(p, priority_fsm_span)
        ]
        if "fsm" in force_type_targets_remaining:
            force_type_targets_remaining["fsm"] -= 1
            if force_type_targets_remaining["fsm"] <= 0:
                force_type_targets_remaining.pop("fsm", None)

    while remaining_pool:
        if effective_max_variants_per_file > 0 and variant_index >= effective_max_variants_per_file:
            break

        selection_pool = list(remaining_pool)
        if (
            PREFER_NON_CONTAINER_SPANS
            and not force_type_targets_remaining
            and (effective_max_variants_per_file == 0 or effective_max_variants_per_file > 1)
            and rng.random() < NON_CONTAINER_PREFERENCE_PROB
        ):
            non_container = _non_container_spans(remaining_pool)
            if non_container:
                selection_pool = non_container

        selection_pool = [
            span
            for span in selection_pool
            if not (
                _selection_type_name(span) == "fsm"
                and span.unit_id is not None
                and str(span.unit_id) in generated_pure_fsm_unit_ids
            )
        ]
        if not selection_pool:
            break

        current_force_types = set(force_type_targets_remaining.keys())
        remaining_types = {mask_type for span in remaining_pool for mask_type in _mask_types(span)}
        current_force_types.update(remaining_types.intersection(FSM_SPECIAL_TYPES))
        selected = _select_spans(
            selection_pool,
            mode,
            max_mask,
            fixed_one,
            random_mask_count,
            weights,
            rng,
            selected_type_counts=selected_type_counts,
            global_selected_total=global_selected_total + sum(len(e.get("masked", [])) for e in entries),
            candidate_unit_count_by_type=candidate_unit_count_by_type,
            type_cap_ratio=type_cap_ratio,
            rarity_alpha=rarity_alpha,
            force_types=current_force_types,
            complex_type_boosts=complex_type_boosts,
        )
        if not selected:
            break

        variant_index += 1
        v_out_file = _variant_out_file(out_file, variant_index)
        out_lines, masked_items = _apply_masks(list(lines), selected)

        for s in selected:
            selected_type = _selection_type_name(s)
            if selected_type == "fsm" and s.unit_id is not None:
                generated_pure_fsm_unit_ids.add(str(s.unit_id))
            if selected_type in force_type_targets_remaining:
                force_type_targets_remaining[selected_type] -= 1
                if force_type_targets_remaining[selected_type] <= 0:
                    force_type_targets_remaining.pop(selected_type, None)

        entries.append(
            {
                "file": rel_file,
                "variant_index": variant_index,
                "output_file": str(v_out_file.relative_to(output_root).as_posix()),
                "mode": mode,
                "masked": masked_items,
                "all_units": all_units,
                "related_docs": related_docs,
                "_out_text": "".join(out_lines),
            }
        )

        selected_types = {mask_type for span in selected for mask_type in _mask_types(span)}

        def _keep_remaining_span(p: MaskSpan) -> bool:
            if all(not _overlaps(p, s) for s in selected):
                return True
            return any(_group_overlap_exempt(p, s) for s in selected if _overlaps(p, s))

        remaining_pool = [p for p in remaining_pool if _keep_remaining_span(p)]

    if not entries and mode not in SKIP_IF_EMPTY_CANDIDATE_MODES:
        v_out_file = _variant_out_file(out_file, 1)
        out_text = "".join([ln for ln in lines if not _strip_markers(ln)])
        entries.append(
            {
                "file": rel_file,
                "variant_index": 1,
                "output_file": str(v_out_file.relative_to(output_root).as_posix()),
                "mode": mode,
                "masked": [],
                "all_units": all_units,
                "related_docs": related_docs,
                "_out_text": out_text,
            }
        )

    if entries:
        total_variants_for_file = len(entries)
        for e in entries:
            e["variants_for_source_file"] = total_variants_for_file
            e["variant_id"] = f"{e['variant_index']}/{total_variants_for_file}"
            e["effective_max_variants_per_file"] = effective_max_variants_per_file
            e["adaptive_variant_policy"] = adaptive_variant_policy

    return entries if entries else None


def _mode_dir_token(mode: str) -> str:
    m = mode.strip().lower()
    if m == "weighted":
        return "weight"
    return re.sub(r"[^a-z0-9]+", "_", m).strip("_") or "mode"


def _hole_dir_token(max_mask: int, fixed_one: bool, random_mask_count: bool) -> str:
    if fixed_one:
        return "1hole"
    if random_mask_count:
        return "randomhole"
    return f"{max(0, int(max_mask))}hole"


def _dataset_tag_token(tag: str) -> str:
    t = str(tag or "").strip().lower()
    if not t:
        return ""
    return re.sub(r"[^a-z0-9]+", "_", t).strip("_")


def _collect_weighted_pool_stats(
    scoped_files: Sequence[Path],
    in_dir: Path,
    apply_main_eval_filter: bool = False,
    excluded_signature_keys: set[str] | None = None,
    excluded_location_keys: set[str] | None = None,
) -> tuple[dict[str, int], dict[str, set[str]], dict[str, int], dict[str, dict[str, int]]]:
    candidate_unit_count_by_type: dict[str, int] = {}
    file_types_map: dict[str, set[str]] = {}
    files_with_type_remaining: dict[str, int] = {}
    file_unit_count_by_type: dict[str, dict[str, int]] = {}

    for f in scoped_files:
        rel = str(f.relative_to(in_dir).as_posix())
        lines = f.read_text(encoding="utf-8", errors="ignore").splitlines(keepends=True)
        blocks, groups, _ = _parse_units(lines)
        spans = _candidate_spans(
            blocks,
            groups,
            lines,
            "weighted",
            apply_main_eval_filter=apply_main_eval_filter,
        )
        spans = _apply_file_specific_main_eval_refinements(
            spans,
            rel,
            apply_main_eval_filter=apply_main_eval_filter,
        )
        spans = _filter_excluded_spans(
            spans,
            rel,
            excluded_signature_keys or set(),
            excluded_location_keys or set(),
        )

        file_types: set[str] = set()
        seen_units: set[tuple[str, str]] = set()
        local_unit_counts: dict[str, int] = {}
        for s in spans:
            selection_type = _selection_type_name(s)
            file_types.add(selection_type)
            uk = (s.kind, s.unit_id)
            if uk in seen_units:
                continue
            seen_units.add(uk)
            candidate_unit_count_by_type[selection_type] = candidate_unit_count_by_type.get(selection_type, 0) + 1
            local_unit_counts[selection_type] = local_unit_counts.get(selection_type, 0) + 1

        file_types_map[rel] = file_types
        file_unit_count_by_type[rel] = local_unit_counts
        for t in file_types:
            files_with_type_remaining[t] = files_with_type_remaining.get(t, 0) + 1

    return candidate_unit_count_by_type, file_types_map, files_with_type_remaining, file_unit_count_by_type


def _load_json_file(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def _run_reference_verify(masked_units_dir: Path, output_json: Path, log_path: Path) -> None:
    code = f"""
import run_verify_reference as r
r.CONFIG_RTL_SOURCE_MODE = 'masked'
r.CONFIG_MASKED_UNITS_DIR = {str(masked_units_dir)!r}
r.CONFIG_MASKED_SELECTION = 'all'
r.CONFIG_ALLOW_MISSING_MASKED_TASKS = True
r.CONFIG_TASK_LEVEL = {PIPELINE_VERIFY_TASK_LEVEL!r}
r.CONFIG_STAGE = {PIPELINE_VERIFY_STAGE!r}
r.CONFIG_MAX_TASKS = None
r.CONFIG_TIMEOUT_SEC = {int(PIPELINE_VERIFY_TIMEOUT_SEC)}
r.CONFIG_OUTPUT_JSON = {str(output_json)!r}
r.main()
"""
    with log_path.open("w", encoding="utf-8") as logf:
        subprocess.run(
            [sys.executable, "-c", code],
            cwd=BASE_DIR,
            stdout=logf,
            stderr=subprocess.STDOUT,
            text=True,
            check=True,
        )


def _load_first_masked_item(meta_path: str) -> dict[str, Any]:
    meta = _load_json_file(Path(meta_path))
    masked = list(meta.get("masked", []))
    return dict(masked[0]) if masked else {}


def _build_policy_entry(
    report_result: Mapping[str, Any],
) -> dict[str, Any]:
    meta_path = Path(str(report_result["meta_path"]))
    if meta_path.exists():
        masked_item = _load_first_masked_item(str(meta_path))
    else:
        mask_meta = dict(report_result.get("mask_meta", {}))
        masked_item = {
            "type": mask_meta.get("masked_type"),
            "kind": mask_meta.get("masked_kind"),
            "span_lines": mask_meta.get("masked_span_lines"),
            "region": mask_meta.get("region"),
            "file": mask_meta.get("file"),
            "question_type": mask_meta.get("question_type"),
            "parent_group_type": mask_meta.get("parent_group_type"),
            "parent_group_id": mask_meta.get("parent_group_id"),
        }
    signature = _masked_item_signature_record(masked_item)
    return {
        "task_display": f"{report_result['system']}/{report_result['task']}[{report_result['variant']}]",
        "system": report_result["system"],
        "task": report_result["task"],
        "variant": report_result["variant"],
        "masked_type": masked_item.get("type", report_result.get("mask_meta", {}).get("masked_type")),
        "masked_kind": masked_item.get("kind", report_result.get("mask_meta", {}).get("masked_kind")),
        "masked_span_lines": masked_item.get("span_lines", report_result.get("mask_meta", {}).get("masked_span_lines")),
        "masked_region": masked_item.get("region", ""),
        "signature": signature,
        "signature_key": _mask_signature_key(signature),
        "rtl_path": report_result["rtl_path"],
        "meta_path": report_result["meta_path"],
        "simulation_status": {
            "syntax": report_result["syntax"],
            "function": report_result["function"],
            "stage": report_result["stage"],
            "rtl_source_mode": report_result["rtl_source_mode"],
        },
    }


def _task_pair(entry: Mapping[str, Any]) -> tuple[str, str] | None:
    system = str(entry.get("system", "")).strip()
    task = str(entry.get("task", "")).strip()
    if not system or not task:
        return None
    return system, task


def _merge_policy_entries(
    existing_entries: Sequence[Mapping[str, Any]],
    generated_entries: Sequence[Mapping[str, Any]],
) -> list[dict[str, Any]]:
    merged: dict[str, dict[str, Any]] = {}
    task_pair_keys: set[tuple[str, str]] = set()

    for entry in existing_entries:
        normalized = dict(entry)
        task_display = str(normalized.get("task_display", "")).strip()
        pair = _task_pair(normalized)
        if task_display:
            merged[f"display::{task_display}"] = normalized
        elif pair is not None:
            key = f"pair::{pair[0]}/{pair[1]}"
            merged[key] = normalized
            task_pair_keys.add(pair)

    for entry in generated_entries:
        normalized = dict(entry)
        task_display = str(normalized.get("task_display", "")).strip()
        pair = _task_pair(normalized)
        if task_display:
            key = f"display::{task_display}"
            if key not in merged:
                merged[key] = normalized
        elif pair is not None and pair not in task_pair_keys:
            key = f"pair::{pair[0]}/{pair[1]}"
            if key not in merged:
                merged[key] = normalized

    return sorted(
        merged.values(),
        key=lambda entry: (
            str(entry.get("system", "")),
            str(entry.get("task", "")),
            str(entry.get("variant", "")),
            str(entry.get("task_display", "")),
        ),
    )


def _build_group_type_counts(all_samples: Sequence[Mapping[str, Any]]) -> dict[str, dict[str, int]]:
    counts: dict[str, dict[str, int]] = {}
    for sample in all_samples:
        system = str(sample.get("source_group", sample.get("system", "unknown")))
        question_type = str(sample.get("question_type", sample.get("masked_type", "unknown")))
        bucket = counts.setdefault(system, {})
        bucket[question_type] = bucket.get(question_type, 0) + 1
    return {system: dict(sorted(type_counts.items())) for system, type_counts in sorted(counts.items())}


def _relative_to_dir_or_none(base_dir: Path, path_value: Any) -> str | None:
    if not path_value:
        return None
    try:
        return str(Path(str(path_value)).resolve().relative_to(base_dir.resolve()))
    except Exception:
        return None


def _build_all_samples_manifest(
    out_dir: Path,
    report_json: Path | None,
    excluded_entries: Sequence[Mapping[str, Any]],
) -> dict[str, Any]:
    excluded_by_task = {
        str(entry.get("task_display", "")): entry for entry in excluded_entries if entry.get("task_display")
    }
    excluded_by_pair = {
        pair: entry for entry in excluded_entries for pair in [_task_pair(entry)] if pair is not None
    }

    all_samples: list[dict[str, Any]] = []
    if report_json is not None:
        report = _load_json_file(report_json)
        for result in report.get("results", []):
            task_display = f"{result['system']}/{result['task']}[{result['variant']}]"
            meta_path = Path(str(result["meta_path"]))
            task_pair = (str(result["system"]), str(result["task"]))
            policy_entry = (
                excluded_by_task.get(task_display)
                or excluded_by_pair.get(task_pair)
            )
            if meta_path.exists():
                meta = _load_json_file(meta_path)
                masked_items = list(meta.get("masked", []))
                masked_item = dict(masked_items[0]) if masked_items else {}
            else:
                meta = {}
                masked_item = {
                    "type": result.get("mask_meta", {}).get("masked_type"),
                    "kind": result.get("mask_meta", {}).get("masked_kind"),
                    "span_lines": result.get("mask_meta", {}).get("masked_span_lines"),
                    "region": result.get("mask_meta", {}).get("region"),
                    "file": result.get("mask_meta", {}).get("file"),
                    "question_type": result.get("mask_meta", {}).get("question_type"),
                    "parent_group_type": result.get("mask_meta", {}).get("parent_group_type"),
                    "parent_group_id": result.get("mask_meta", {}).get("parent_group_id"),
                    "id": result.get("mask_meta", {}).get("masked_id"),
                    "answer": None,
                }

            all_samples.append(
                {
                    "task_display": task_display,
                    "source_group": result["system"],
                    "source_module": result["task"],
                    "variant": result["variant"],
                    "rtl_path": result.get("rtl_path"),
                    "meta_path": result.get("meta_path"),
                    "meta_file_present": meta_path.exists(),
                    "rtl_path_relative": _relative_to_dir_or_none(out_dir, result.get("rtl_path")),
                    "meta_path_relative": _relative_to_dir_or_none(out_dir, result.get("meta_path")),
                    "output_file": meta.get("output_file"),
                    "variant_id": meta.get("variant_id"),
                    "variants_for_source_file": meta.get("variants_for_source_file"),
                    "source_file": masked_item.get("file"),
                    "location": {
                        "source_file": masked_item.get("file"),
                        "span_lines": masked_item.get("span_lines"),
                        "region": masked_item.get("region"),
                        "kind": masked_item.get("kind"),
                        "type": masked_item.get("type"),
                        "parent_group_type": masked_item.get("parent_group_type"),
                        "parent_group_id": masked_item.get("parent_group_id"),
                        "unit_id": masked_item.get("id"),
                    },
                    "question_type": masked_item.get("question_type")
                    or _question_type_name(
                        str(masked_item.get("kind", "")),
                        str(masked_item.get("type", "unknown")),
                        "" if masked_item.get("parent_group_type") in {None, "None"} else str(masked_item.get("parent_group_type", "")),
                    ),
                    "masked_type": masked_item.get("type"),
                    "masked_kind": masked_item.get("kind"),
                    "masked_span_lines": masked_item.get("span_lines"),
                    "masked_region": masked_item.get("region"),
                    "parent_group_type": masked_item.get("parent_group_type"),
                    "answer": masked_item.get("answer"),
                    "related_docs": meta.get("related_docs", []),
                    "simulation_report": {
                        "syntax": result.get("syntax"),
                        "function": result.get("function"),
                        "stage": result.get("stage"),
                        "rtl_source_mode": result.get("rtl_source_mode"),
                        "syntax_info": result.get("syntax_info"),
                        "function_info": result.get("function_info"),
                    },
                    "policy": {
                        "excluded_forever": task_display in excluded_by_task or task_pair in excluded_by_pair,
                        "exclusion_reason": None if policy_entry is None else policy_entry.get("exclusion_reason"),
                    },
                }
            )
    else:
        for meta_path in sorted(out_dir.rglob("*__mask*.v.json")):
            meta = _load_json_file(meta_path)
            masked_items = list(meta.get("masked", []))
            masked_item = dict(masked_items[0]) if masked_items else {}
            output_file = meta.get("output_file")
            rtl_path = None if not output_file else str((out_dir / str(output_file)).resolve())
            variant_id = meta.get("variant_id")
            source_file = masked_item.get("file") or meta.get("source_file")
            source_group = str(source_file).split("/", 1)[0] if source_file else None
            source_module = Path(str(source_file)).stem if source_file else None
            task_display = f"{source_group}/{source_module}[{variant_id}]" if source_group and source_module and variant_id else str(meta_path.stem)
            task_pair = None if not source_group or not source_module else (str(source_group), str(source_module))
            policy_entry = (
                excluded_by_task.get(task_display)
                or (None if task_pair is None else excluded_by_pair.get(task_pair))
            )
            all_samples.append(
                {
                    "task_display": task_display,
                    "source_group": source_group,
                    "source_module": source_module,
                    "variant": variant_id,
                    "rtl_path": rtl_path,
                    "meta_path": str(meta_path.resolve()),
                    "meta_file_present": True,
                    "rtl_path_relative": _relative_to_dir_or_none(out_dir, rtl_path),
                    "meta_path_relative": _relative_to_dir_or_none(out_dir, str(meta_path.resolve())),
                    "output_file": output_file,
                    "variant_id": variant_id,
                    "variants_for_source_file": meta.get("variants_for_source_file"),
                    "source_file": source_file,
                    "location": {
                        "source_file": source_file,
                        "span_lines": masked_item.get("span_lines"),
                        "region": masked_item.get("region"),
                        "kind": masked_item.get("kind"),
                        "type": masked_item.get("type"),
                        "parent_group_type": masked_item.get("parent_group_type"),
                        "parent_group_id": masked_item.get("parent_group_id"),
                        "unit_id": masked_item.get("id"),
                    },
                    "question_type": masked_item.get("question_type")
                    or _question_type_name(
                        str(masked_item.get("kind", "")),
                        str(masked_item.get("type", "unknown")),
                        "" if masked_item.get("parent_group_type") in {None, "None"} else str(masked_item.get("parent_group_type", "")),
                    ),
                    "masked_type": masked_item.get("type"),
                    "masked_kind": masked_item.get("kind"),
                    "masked_span_lines": masked_item.get("span_lines"),
                    "masked_region": masked_item.get("region"),
                    "parent_group_type": masked_item.get("parent_group_type"),
                    "answer": masked_item.get("answer"),
                    "related_docs": meta.get("related_docs", []),
                    "simulation_report": {
                        "syntax": None,
                        "function": None,
                        "stage": None,
                        "rtl_source_mode": None,
                        "syntax_info": None,
                        "function_info": None,
                    },
                    "policy": {
                        "excluded_forever": task_display in excluded_by_task or (task_pair is not None and task_pair in excluded_by_pair),
                        "exclusion_reason": None if policy_entry is None else policy_entry.get("exclusion_reason"),
                    },
                }
            )

    all_samples.sort(key=lambda x: str(x["task_display"]))
    return {
        "dataset_id": out_dir.name,
        "dataset_dir": str(out_dir.resolve()),
        "report_json": None if report_json is None else str(report_json.resolve()),
        "sample_count": len(all_samples),
        "samples": all_samples,
    }


def _delete_excluded_dataset_files(
    out_dir: Path,
    excluded_entries: Sequence[Mapping[str, Any]],
) -> dict[str, Any]:
    out_dir_resolved = out_dir.resolve()
    deleted_files: list[str] = []
    missing_files: list[str] = []
    skipped_outside_dataset: list[str] = []

    for entry in excluded_entries:
        for key in ("rtl_path", "meta_path"):
            path_str = entry.get(key)
            if not path_str:
                continue
            path = Path(str(path_str)).resolve()
            try:
                path.relative_to(out_dir_resolved)
            except ValueError:
                skipped_outside_dataset.append(str(path))
                continue
            if path.exists():
                path.unlink()
                deleted_files.append(str(path))
            else:
                missing_files.append(str(path))

    return {
        "deleted_file_count": len(deleted_files),
        "deleted_files": deleted_files,
        "missing_file_count": len(missing_files),
        "missing_files": missing_files,
        "skipped_outside_dataset_count": len(skipped_outside_dataset),
        "skipped_outside_dataset_files": skipped_outside_dataset,
    }


def _clear_post_generation_policy_artifacts(out_dir: Path) -> None:
    stale_paths = [
        out_dir / PIPELINE_EXCLUDED_JSON_NAME,
        out_dir / PIPELINE_MANIFEST_JSON_NAME,
        out_dir / PIPELINE_MANIFEST_MD_NAME,
        out_dir / PIPELINE_ALL_SAMPLES_JSON_NAME,
        out_dir / PIPELINE_SUMMARY_JSON_NAME,
    ]
    for stale_path in stale_paths:
        try:
            if stale_path.exists():
                stale_path.unlink()
        except IsADirectoryError:
            continue


def _write_dataset_policy_artifacts(
    out_dir: Path,
    report_json: Path,
    stats_json: Path,
    global_blacklist_json: Path,
) -> dict[str, Any]:
    report = _load_json_file(report_json)
    excluded_path = out_dir / PIPELINE_EXCLUDED_JSON_NAME

    existing_excluded_entries = []
    if excluded_path.exists():
        existing_excluded_entries = list(_load_json_file(excluded_path).get("entries", []))

    excluded: list[dict[str, Any]] = []
    blacklist_entries_to_add: list[dict[str, Any]] = []

    for report_result in report.get("results", []):
        if int(report_result.get("function", 0) or 0) != 1:
            continue
        entry = _build_policy_entry(report_result)
        entry["exclusion_reason"] = "simulation_function_pass_excluded_by_policy"
        excluded.append(entry)
        blacklist_entry = dict(entry["signature"])
        blacklist_entry.update(
            {
                "task_display": entry["task_display"],
                "source_dataset_id": out_dir.name,
                "exclusion_reason": "simulation_function_pass_excluded_by_policy",
            }
        )
        blacklist_entries_to_add.append(blacklist_entry)

    excluded = _merge_policy_entries(existing_excluded_entries, excluded)

    existing_blacklist_entries, _, _ = _load_global_exclusion_blacklist(global_blacklist_json)
    _write_global_exclusion_blacklist(
        global_blacklist_json,
        [*existing_blacklist_entries, *blacklist_entries_to_add],
    )

    excluded_payload = {
        "dataset_id": out_dir.name,
        "rule": "These samples are permanently excluded from future dataset selection, including every sample that reaches simulation function=1.",
        "entries": excluded,
    }
    excluded_path.write_text(
        json.dumps(excluded_payload, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )

    deletion_summary = _delete_excluded_dataset_files(out_dir, excluded)

    stats = _load_json_file(stats_json)
    remaining_mask_file_count = len(list(out_dir.rglob("*__mask*.v")))
    all_samples_manifest = _build_all_samples_manifest(
        out_dir=out_dir,
        report_json=report_json,
        excluded_entries=excluded,
    )
    all_samples_manifest_path = out_dir / PIPELINE_ALL_SAMPLES_JSON_NAME
    all_samples_manifest_path.write_text(
        json.dumps(all_samples_manifest, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )

    dataset_summary = {
        "dataset_id": out_dir.name,
        "dataset_dir": str(out_dir.resolve()),
        "sample_count": len(all_samples_manifest["samples"]),
        "total_questions": int(stats.get("total_questions", 0)),
        "type_counts": dict(sorted(stats.get("type_counts", {}).items())),
        "question_type_counts": dict(sorted(stats.get("question_type_counts", {}).items())),
        "grouping_key": "source_group",
        "group_question_type_counts": _build_group_type_counts(all_samples_manifest["samples"]),
        "attached_files": {
            "all_samples_manifest_json": str(all_samples_manifest_path.resolve()),
            "excluded_forever_json": str(excluded_path.resolve()),
            "dataset_manifest_json": str((out_dir / PIPELINE_MANIFEST_JSON_NAME).resolve()),
            "dataset_manifest_md": str((out_dir / PIPELINE_MANIFEST_MD_NAME).resolve()),
        },
    }
    dataset_summary_path = out_dir / PIPELINE_SUMMARY_JSON_NAME
    dataset_summary_path.write_text(
        json.dumps(dataset_summary, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )

    manifest = {
        "manifest_version": 1,
        "dataset_id": out_dir.name,
        "dataset_dir": str(out_dir.resolve()),
        "dataset_stats_json": str(stats_json.resolve()),
        "dataset_report_json": str(report_json.resolve()),
        "all_samples_manifest_json": str(all_samples_manifest_path.resolve()),
        "dataset_summary_json": str(dataset_summary_path.resolve()),
        "global_exclusion_blacklist_json": str(global_blacklist_json.resolve()),
        "dataset_counts": {
            "generated_questions": int(stats.get("total_questions", 0)),
            "verified_tasks": int(report.get("total_tasks", 0)),
            "simulation_function_pass_count": int(report.get("function_pass", 0)),
            "excluded_forever_count": len(excluded),
            "normal_sim_only_count": int(report.get("total_tasks", 0)) - len(excluded),
            "effective_active_count": int(report.get("total_tasks", 0)) - len(excluded),
            "materialized_mask_file_count": remaining_mask_file_count,
            "physically_removed_excluded_file_count": int(deletion_summary["deleted_file_count"]),
        },
        "generation_config_snapshot": {
            "task_scope": stats.get("task_scope"),
            "mode": stats.get("mode"),
            "dataset_tag": stats.get("dataset_tag"),
            "seed": stats.get("seed"),
            "target_total_questions": stats.get("target_total_questions"),
            "adaptive_variant_policy": stats.get("adaptive_variant_policy"),
            "main_eval_filter": stats.get("main_eval_filter"),
        },
        "official_evaluation_policy": {
            "normal_samples": {
                "selection": "all released samples not listed in excluded_forever",
                "rule": "Stop at simulation. If syntax=1 and function=1, mark success. Otherwise mark failure.",
            },
        },
        "physical_cleanup": deletion_summary,
        "statistics": dataset_summary,
    }

    manifest_json_path = out_dir / PIPELINE_MANIFEST_JSON_NAME
    manifest_json_path.write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )

    md_lines = [
        f"# Dataset Manifest: {out_dir.name}",
        "",
        "## Summary",
        "",
        f"- Dataset id: `{out_dir.name}`",
        f"- Generated questions: `{manifest['dataset_counts']['generated_questions']}`",
        f"- Simulation function-pass cases excluded by policy: `{manifest['dataset_counts']['simulation_function_pass_count']}`",
        f"- Permanently excluded after simulation policy: `{manifest['dataset_counts']['excluded_forever_count']}`",
        f"- Normal sim-only samples: `{manifest['dataset_counts']['normal_sim_only_count']}`",
        f"- Remaining materialized masked RTL files: `{manifest['dataset_counts']['materialized_mask_file_count']}`",
        f"- All-samples manifest: `{PIPELINE_ALL_SAMPLES_JSON_NAME}`",
        f"- Permanent exclusion list: `{PIPELINE_EXCLUDED_JSON_NAME}`",
        f"- Dataset summary: `{PIPELINE_SUMMARY_JSON_NAME}`",
        f"- Global blacklist: `{global_blacklist_json.name}`",
        "",
        "## File Roles",
        "",
        f"- `{PIPELINE_ALL_SAMPLES_JSON_NAME}`: one record per sample, including correct answer, source location, question type, related docs, simulation result, and policy flags.",
        f"- `{PIPELINE_EXCLUDED_JSON_NAME}`: the subset permanently excluded from future official datasets, including all simulation function-pass samples under the current policy.",
        f"- `{PIPELINE_SUMMARY_JSON_NAME}`: summary-only counts for dataset-wide and per-group question types, plus attached file pointers.",
        f"- `{PIPELINE_MANIFEST_JSON_NAME}`: machine-readable top-level manifest tying all generated artifacts together.",
        "",
        "## Statistics",
        "",
        "### Question Type Counts",
        "",
    ]
    for key, value in dataset_summary["question_type_counts"].items():
        md_lines.append(f"- `{key}`: `{value}`")
    md_lines.extend(["", "### Group Question Type Counts", ""])
    for group_name, group_counts in dataset_summary["group_question_type_counts"].items():
        md_lines.append(f"- `{group_name}`")
        for key, value in group_counts.items():
            md_lines.append(f"  - `{key}`: `{value}`")
    md_lines.extend(
        [
            "",
        "## Official Evaluation Policy",
        "",
        "- Normal samples: stop at simulation; `syntax=1` and `function=1` means success.",
        "- Simulation function-pass samples are permanently excluded during dataset construction and are not kept for official evaluation.",
        "- Permanent exclusions: do not include these samples in future official datasets or future sample selection pools.",
        "",
        "## Physical Cleanup",
        "",
        f"- Deleted excluded dataset files: `{manifest['physical_cleanup']['deleted_file_count']}`",
        f"- Missing excluded dataset files at cleanup time: `{manifest['physical_cleanup']['missing_file_count']}`",
        f"- Skipped paths outside dataset root: `{manifest['physical_cleanup']['skipped_outside_dataset_count']}`",
        ]
    )
    (out_dir / PIPELINE_MANIFEST_MD_NAME).write_text("\n".join(md_lines) + "\n", encoding="utf-8")

    stats["post_generation_pipeline"] = {
        "enabled": True,
        "verify_report_json": str(report_json.resolve()),
        "dataset_manifest_json": str(manifest_json_path.resolve()),
        "all_samples_manifest_json": str(all_samples_manifest_path.resolve()),
        "excluded_forever_json": str(excluded_path.resolve()),
        "dataset_summary_json": str(dataset_summary_path.resolve()),
        "global_exclusion_blacklist_json": str(global_blacklist_json.resolve()),
        "excluded_forever_count": len(excluded),
        "physical_cleanup": deletion_summary,
    }
    stats_json.write_text(json.dumps(stats, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return manifest


def _write_generation_only_artifacts(
    out_dir: Path,
    stats_json: Path,
    global_blacklist_json: Path,
) -> dict[str, Any]:
    stats = _load_json_file(stats_json)
    all_samples_manifest = _build_all_samples_manifest(
        out_dir=out_dir,
        report_json=None,
        excluded_entries=[],
    )
    all_samples_manifest_path = out_dir / PIPELINE_ALL_SAMPLES_JSON_NAME
    all_samples_manifest_path.write_text(
        json.dumps(all_samples_manifest, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )

    dataset_summary = {
        "dataset_id": out_dir.name,
        "dataset_dir": str(out_dir.resolve()),
        "sample_count": len(all_samples_manifest["samples"]),
        "total_questions": int(stats.get("total_questions", 0)),
        "type_counts": dict(sorted(stats.get("type_counts", {}).items())),
        "question_type_counts": dict(sorted(stats.get("question_type_counts", {}).items())),
        "grouping_key": "source_group",
        "group_question_type_counts": _build_group_type_counts(all_samples_manifest["samples"]),
        "attached_files": {
            "all_samples_manifest_json": str(all_samples_manifest_path.resolve()),
            "excluded_forever_json": None,
            "dataset_manifest_json": str((out_dir / PIPELINE_MANIFEST_JSON_NAME).resolve()),
            "dataset_manifest_md": str((out_dir / PIPELINE_MANIFEST_MD_NAME).resolve()),
        },
    }
    dataset_summary_path = out_dir / PIPELINE_SUMMARY_JSON_NAME
    dataset_summary_path.write_text(
        json.dumps(dataset_summary, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )

    manifest = {
        "manifest_version": 1,
        "dataset_id": out_dir.name,
        "dataset_dir": str(out_dir.resolve()),
        "dataset_stats_json": str(stats_json.resolve()),
        "dataset_report_json": None,
        "all_samples_manifest_json": str(all_samples_manifest_path.resolve()),
        "dataset_summary_json": str(dataset_summary_path.resolve()),
        "global_exclusion_blacklist_json": str(global_blacklist_json.resolve()),
        "dataset_counts": {
            "generated_questions": int(stats.get("total_questions", 0)),
            "verified_tasks": None,
            "simulation_function_pass_count": None,
            "excluded_forever_count": 0,
            "normal_sim_only_count": len(all_samples_manifest["samples"]),
            "effective_active_count": len(all_samples_manifest["samples"]),
            "materialized_mask_file_count": len(list(out_dir.rglob("*__mask*.v"))),
            "physically_removed_excluded_file_count": 0,
        },
        "generation_config_snapshot": {
            "task_scope": stats.get("task_scope"),
            "mode": stats.get("mode"),
            "dataset_tag": stats.get("dataset_tag"),
            "seed": stats.get("seed"),
            "target_total_questions": stats.get("target_total_questions"),
            "adaptive_variant_policy": stats.get("adaptive_variant_policy"),
            "main_eval_filter": stats.get("main_eval_filter"),
        },
        "official_evaluation_policy": {
            "mode": "generation_only",
            "rule": "This manifest was generated without running simulation.",
        },
        "physical_cleanup": {
            "deleted_file_count": 0,
            "deleted_files": [],
            "missing_file_count": 0,
            "missing_files": [],
            "skipped_outside_dataset_count": 0,
            "skipped_outside_dataset_files": [],
        },
        "statistics": dataset_summary,
    }

    manifest_json_path = out_dir / PIPELINE_MANIFEST_JSON_NAME
    manifest_json_path.write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )

    md_lines = [
        f"# Dataset Manifest: {out_dir.name}",
        "",
        "## Summary",
        "",
        f"- Dataset id: `{out_dir.name}`",
        f"- Generated questions: `{manifest['dataset_counts']['generated_questions']}`",
        "- Verification status: `not_run`",
        f"- All-samples manifest: `{PIPELINE_ALL_SAMPLES_JSON_NAME}`",
        f"- Dataset summary: `{PIPELINE_SUMMARY_JSON_NAME}`",
        f"- Global blacklist: `{global_blacklist_json.name}`",
        "",
        "## Statistics",
        "",
        "### Question Type Counts",
        "",
    ]
    for key, value in dataset_summary["question_type_counts"].items():
        md_lines.append(f"- `{key}`: `{value}`")
    md_lines.extend(["", "### Group Question Type Counts", ""])
    for group_name, group_counts in dataset_summary["group_question_type_counts"].items():
        md_lines.append(f"- `{group_name}`")
        for key, value in group_counts.items():
            md_lines.append(f"  - `{key}`: `{value}`")
    md_lines.extend(
        [
            "",
            "## Evaluation Status",
            "",
            "- This dataset snapshot was generated without running simulation.",
        ]
    )
    (out_dir / PIPELINE_MANIFEST_MD_NAME).write_text("\n".join(md_lines) + "\n", encoding="utf-8")

    stats["post_generation_pipeline"] = {
        "enabled": False,
        "verify_report_json": None,
        "dataset_manifest_json": str(manifest_json_path.resolve()),
        "all_samples_manifest_json": str(all_samples_manifest_path.resolve()),
        "excluded_forever_json": None,
        "dataset_summary_json": str(dataset_summary_path.resolve()),
        "global_exclusion_blacklist_json": str(global_blacklist_json.resolve()),
        "excluded_forever_count": 0,
        "physical_cleanup": manifest["physical_cleanup"],
    }
    stats_json.write_text(json.dumps(stats, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return manifest


def _entry_types(entry: Mapping[str, Any]) -> set[str]:
    out: set[str] = set()
    for m in entry.get("masked", []):
        masked_type = str(m.get("type", "unknown"))
        out.add(
            str(
                m.get("question_type")
                or _question_type_name(
                    str(m.get("kind", "")),
                    masked_type,
                    "" if m.get("parent_group_type") in {None, "None"} else str(m.get("parent_group_type", "")),
                )
            )
        )
    return out


def _pure_fsm_unit_ids(entry: Mapping[str, Any]) -> set[str]:
    out: set[str] = set()
    for m in entry.get("masked", []):
        masked_type = str(m.get("type", "unknown"))
        qtype = str(
            m.get("question_type")
            or _question_type_name(
                str(m.get("kind", "")),
                masked_type,
                "" if m.get("parent_group_type") in {None, "None"} else str(m.get("parent_group_type", "")),
            )
        )
        if qtype != "fsm":
            continue
        unit_id = m.get("id")
        if unit_id:
            out.add(str(unit_id))
    return out


def _pick_best_entry_for_type(
    target_type: str,
    file_order: Sequence[str],
    generated_entries_by_file: Mapping[str, Sequence[Mapping[str, Any]]],
    selected_refs: set[tuple[str, int]],
    mandatory_remaining: Mapping[str, int],
    selected_pure_fsm_unit_ids: set[str],
) -> tuple[str, int] | None:
    best_ref: tuple[str, int] | None = None
    best_score: tuple[int, int, int, int] | None = None

    for rel_str in file_order:
        entries = generated_entries_by_file.get(rel_str, [])
        for i, entry in enumerate(entries):
            ref = (rel_str, i)
            if ref in selected_refs:
                continue
            if _pure_fsm_unit_ids(entry) & selected_pure_fsm_unit_ids:
                continue

            entry_types = _entry_types(entry)
            if target_type not in entry_types:
                continue

            other_unmet = sum(
                1
                for t in entry_types
                if t != target_type and int(mandatory_remaining.get(t, 0)) > 0
            )
            exact_match = 0 if entry_types == {target_type} else 1
            extra_types = max(0, len(entry_types) - 1)
            score = (other_unmet, exact_match, extra_types, i)

            if best_score is None or score < best_score:
                best_score = score
                best_ref = ref

    return best_ref


def _pick_pure_fsm_refs(
    file_order: Sequence[str],
    generated_entries_by_file: Mapping[str, Sequence[Mapping[str, Any]]],
    selected_refs: set[tuple[str, int]],
    target_count: int,
    selected_pure_fsm_unit_ids: set[str],
) -> list[tuple[str, int]]:
    picks: list[tuple[str, int]] = []
    used_files: set[str] = set()
    local_pure_fsm_unit_ids: set[str] = set()

    for rel_str in file_order:
        if len(picks) >= target_count:
            break
        entries = generated_entries_by_file.get(rel_str, [])
        for i, entry in enumerate(entries):
            ref = (rel_str, i)
            if ref in selected_refs or rel_str in used_files:
                continue
            pure_fsm_unit_ids = _pure_fsm_unit_ids(entry)
            if pure_fsm_unit_ids & selected_pure_fsm_unit_ids:
                continue
            if pure_fsm_unit_ids & local_pure_fsm_unit_ids:
                continue
            if _entry_types(entry) == {"fsm"}:
                picks.append(ref)
                used_files.add(rel_str)
                local_pure_fsm_unit_ids.update(pure_fsm_unit_ids)
                break

    if len(picks) >= target_count:
        return picks

    for rel_str in file_order:
        if len(picks) >= target_count:
            break
        entries = generated_entries_by_file.get(rel_str, [])
        for i, entry in enumerate(entries):
            ref = (rel_str, i)
            if ref in selected_refs or ref in picks:
                continue
            pure_fsm_unit_ids = _pure_fsm_unit_ids(entry)
            if pure_fsm_unit_ids & selected_pure_fsm_unit_ids:
                continue
            if pure_fsm_unit_ids & local_pure_fsm_unit_ids:
                continue
            if "fsm" in _entry_types(entry):
                picks.append(ref)
                local_pure_fsm_unit_ids.update(pure_fsm_unit_ids)
                break

    return picks


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--seed",
        type=int,
        default=SEED,
        help="Override the configured dataset seed for this run.",
    )
    args = parser.parse_args()
    # Keep the file-level SEED as the default, but allow one-off dataset reruns from CLI.
    run_seed = args.seed

    base_dir = BASE_DIR.resolve()
    in_dir = IN_DIR.resolve()
    mode = MODE.strip().lower()
    task_scope = TASK_SCOPE.strip().lower()
    main_eval_filter = MAIN_EVAL_FILTER.strip().lower()
    if main_eval_filter not in {"off", "strict"}:
        raise ValueError(
            f"Unsupported MAIN_EVAL_FILTER={MAIN_EVAL_FILTER!r}, expected strict/off"
        )
    main_eval_filter_active = (
        main_eval_filter == "strict" and mode == "weighted" and task_scope == "core60"
    )

    core60_tasks = _core60_task_set()
    all_files = sorted(_iter_verilog_files(in_dir))
    scoped_files = _filter_files_by_scope(all_files, in_dir, task_scope, core60_tasks)
    blacklist_entries, excluded_signature_keys, excluded_location_keys = _load_global_exclusion_blacklist(
        GLOBAL_EXCLUSION_BLACKLIST_JSON
    )
    files_total_scanned = len(all_files)
    files_in_scope = len(scoped_files)
    files_skipped_by_scope = files_total_scanned - files_in_scope

    hole_token = _hole_dir_token(MAX_MASK, FIXED_MASK, RANDOM_MASK_COUNT)
    dataset_tag_token = _dataset_tag_token(DATASET_TAG)
    out_dir_name = f"{OUT_DIR_BASENAME}_{task_scope}_{hole_token}_{_mode_dir_token(mode)}_{run_seed}"
    if dataset_tag_token:
        out_dir_name = f"{out_dir_name}_{dataset_tag_token}"
    out_dir = (base_dir / out_dir_name).resolve()
    rng = random.Random(run_seed)
    weights = _load_weights(WEIGHTS_JSON)

    out_dir.mkdir(parents=True, exist_ok=True)
    _cleanup_existing_mask_variants(out_dir, scoped_files, in_dir)

    candidate_unit_count_by_type: dict[str, int] = {}
    file_types_map: dict[str, set[str]] = {}
    files_with_type_remaining: dict[str, int] = {}
    file_unit_count_by_type: dict[str, dict[str, int]] = {}
    if mode == "weighted":
        (
            candidate_unit_count_by_type,
            file_types_map,
            files_with_type_remaining,
            file_unit_count_by_type,
        ) = _collect_weighted_pool_stats(
            scoped_files,
            in_dir,
            apply_main_eval_filter=main_eval_filter_active,
            excluded_signature_keys=excluded_signature_keys,
            excluded_location_keys=excluded_location_keys,
        )

    mandatory_remaining_for_generation = dict(MANDATORY_TYPE_MIN_COUNTS)
    selected_type_counts_global: dict[str, int] = {}
    global_selected_total = 0

    generated_entries_by_file: dict[str, list[dict[str, Any]]] = {}
    effective_variant_cap_by_file: dict[str, int] = {}
    file_order: list[str] = []

    for f in scoped_files:
        rel = f.relative_to(in_dir)
        rel_str = str(rel.as_posix())
        out_file = out_dir / rel

        force_type_targets: dict[str, int] = {}
        if mode == "weighted":
            ftypes = file_types_map.get(rel_str, set())
            local_unit_counts = file_unit_count_by_type.get(rel_str, {})
            for t, need in mandatory_remaining_for_generation.items():
                if need <= 0:
                    continue
                if t not in ftypes:
                    continue
                rem_files = int(files_with_type_remaining.get(t, 0))
                local_units = int(local_unit_counts.get(t, 0))
                if local_units <= 0:
                    continue

                force_count = 0
                # Deadline forcing: if remaining carrier files are not more than
                # the remaining required count, we must take this type now.
                if rem_files <= need:
                    force_count = 1

                # Pure FSM carriers are globally scarce. Once a file can carry
                # a pure fsm and quota is still unmet, force one pick from it
                # instead of letting sibling fsm_block-heavy files consume the slot.
                if t == "fsm" and need > 0:
                    force_count = max(force_count, 1)

                # Rare semantic types such as function/generate often live in
                # only a few files. Allow multiple forced picks from a strong
                # carrier file instead of capping at one per file.
                multi_limit = int(RARE_TYPE_MULTI_FORCE_LIMITS.get(t, 0))
                if multi_limit > 0 and need > 1 and local_units >= 2:
                    force_count = max(
                        force_count,
                        min(multi_limit, local_units, need),
                    )

                if force_count > 0:
                    force_type_targets[t] = max(force_type_targets.get(t, 0), force_count)

        entries = _process_file(
            f,
            out_file,
            mode,
            MAX_MASK,
            FIXED_MASK,
            RANDOM_MASK_COUNT,
            weights,
            rng,
            in_dir,
            base_dir,
            out_dir,
            selected_type_counts=selected_type_counts_global if mode == "weighted" else None,
            global_selected_total=global_selected_total if mode == "weighted" else 0,
            candidate_unit_count_by_type=candidate_unit_count_by_type if mode == "weighted" else None,
            type_cap_ratio=TYPE_CAP_RATIO if mode == "weighted" else 0.0,
            rarity_alpha=RARITY_ALPHA if mode == "weighted" else 0.0,
            force_type_targets=force_type_targets if mode == "weighted" else None,
            max_variants_per_file=MAX_VARIANTS_PER_FILE,
            adaptive_variant_policy=ADAPTIVE_VARIANT_POLICY if mode == "weighted" else "off",
            adaptive_max_variants_per_file=ADAPTIVE_MAX_VARIANTS_PER_FILE if mode == "weighted" else MAX_VARIANTS_PER_FILE,
            complex_type_boosts=COMPLEX_TYPE_BOOSTS if mode == "weighted" else None,
            apply_main_eval_filter=main_eval_filter_active,
            excluded_signature_keys=excluded_signature_keys,
            excluded_location_keys=excluded_location_keys,
        )
        if entries is None:
            continue

        generated_entries_by_file[rel_str] = entries
        effective_variant_cap_by_file[rel_str] = int(
            entries[0].get("effective_max_variants_per_file", MAX_VARIANTS_PER_FILE)
        )
        file_order.append(rel_str)

        # Update global balancing states during generation.
        for entry in entries:
            for t in _entry_types(entry):
                selected_type_counts_global[t] = selected_type_counts_global.get(t, 0) + 1
                global_selected_total += 1
                if t in mandatory_remaining_for_generation and mandatory_remaining_for_generation[t] > 0:
                    mandatory_remaining_for_generation[t] -= 1

        if mode == "weighted":
            for t in file_types_map.get(rel_str, set()):
                files_with_type_remaining[t] = max(0, int(files_with_type_remaining.get(t, 0)) - 1)

    # -------- Final question selection --------
    all_generated = sum(len(v) for v in generated_entries_by_file.values())
    target_questions = all_generated if TARGET_TOTAL_QUESTIONS <= 0 else min(TARGET_TOTAL_QUESTIONS, all_generated)

    selected_refs: set[tuple[str, int]] = set()
    selected_pure_fsm_unit_ids: set[str] = set()
    mandatory_remaining = dict(MANDATORY_TYPE_MIN_COUNTS)

    pure_fsm_target = max(0, int(mandatory_remaining.get("fsm", 0)))
    if pure_fsm_target > 0:
        pure_fsm_refs = _pick_pure_fsm_refs(
            file_order,
            generated_entries_by_file,
            selected_refs,
            pure_fsm_target,
            selected_pure_fsm_unit_ids,
        )
        for ref in pure_fsm_refs:
            if len(selected_refs) >= target_questions:
                break
            if ref in selected_refs:
                continue
            entry = generated_entries_by_file[ref[0]][ref[1]]
            pure_fsm_unit_ids = _pure_fsm_unit_ids(entry)
            if pure_fsm_unit_ids & selected_pure_fsm_unit_ids:
                continue
            selected_refs.add(ref)
            selected_pure_fsm_unit_ids.update(pure_fsm_unit_ids)
            mandatory_remaining["fsm"] = max(0, int(mandatory_remaining.get("fsm", 0)) - 1)

    # 1) Mandatory-first selection.
    for t, need in list(mandatory_remaining.items()):
        while need > 0:
            found = _pick_best_entry_for_type(
                t,
                file_order,
                generated_entries_by_file,
                selected_refs,
                mandatory_remaining,
                selected_pure_fsm_unit_ids,
            )
            if found is None:
                break
            selected_refs.add(found)
            selected_pure_fsm_unit_ids.update(_pure_fsm_unit_ids(generated_entries_by_file[found[0]][found[1]]))
            need -= 1
            mandatory_remaining[t] = need
            if len(selected_refs) >= target_questions:
                break
        if len(selected_refs) >= target_questions:
            break

    # 2) Prefer remaining unmet mandatory types, then round-robin fill for fairness across source files.
    if len(selected_refs) < target_questions:
        unmet_types = [t for t, need in mandatory_remaining.items() if need > 0]
        while unmet_types and len(selected_refs) < target_questions:
            progressed = False
            for t in list(unmet_types):
                while mandatory_remaining.get(t, 0) > 0 and len(selected_refs) < target_questions:
                    found = _pick_best_entry_for_type(
                        t,
                        file_order,
                        generated_entries_by_file,
                        selected_refs,
                        mandatory_remaining,
                        selected_pure_fsm_unit_ids,
                    )
                    if found is None:
                        break
                    selected_refs.add(found)
                    selected_pure_fsm_unit_ids.update(_pure_fsm_unit_ids(generated_entries_by_file[found[0]][found[1]]))
                    mandatory_remaining[t] = max(0, int(mandatory_remaining.get(t, 0)) - 1)
                    progressed = True
                if mandatory_remaining.get(t, 0) <= 0:
                    unmet_types.remove(t)
            if not progressed:
                break

    if len(selected_refs) < target_questions:
        max_variants = max((len(v) for v in generated_entries_by_file.values()), default=0)
        for vi in range(max_variants):
            for rel_str in file_order:
                entries = generated_entries_by_file.get(rel_str, [])
                if vi >= len(entries):
                    continue
                ref = (rel_str, vi)
                if ref in selected_refs:
                    continue
                if _pure_fsm_unit_ids(entries[vi]) & selected_pure_fsm_unit_ids:
                    continue
                selected_refs.add(ref)
                selected_pure_fsm_unit_ids.update(_pure_fsm_unit_ids(entries[vi]))
                if len(selected_refs) >= target_questions:
                    break
            if len(selected_refs) >= target_questions:
                break

    # Emit selected entries and collect final stats.
    total_source_files = 0
    total_questions = 0
    masked_questions = 0
    total_masks = 0
    type_counts: dict[str, int] = {}
    question_type_counts: dict[str, int] = {}
    questions_per_source_file: dict[str, int] = {}

    for rel_str in file_order:
        entries = generated_entries_by_file.get(rel_str, [])
        picked_entries: list[dict[str, Any]] = []
        for i, entry in enumerate(entries):
            if (rel_str, i) in selected_refs:
                picked_entries.append(entry)

        if not picked_entries:
            continue

        total_source_files += 1
        questions_per_source_file[rel_str] = len(picked_entries)
        for entry in picked_entries:
            total_questions += 1
            if entry["masked"]:
                masked_questions += 1
                for m in entry["masked"]:
                    t = str(m.get("type", "unknown"))
                    qtype = str(
                        m.get("question_type")
                        or _question_type_name(
                            str(m.get("kind", "")),
                            t,
                            "" if m.get("parent_group_type") in {None, "None"} else str(m.get("parent_group_type", "")),
                        )
                    )
                    type_counts[t] = type_counts.get(t, 0) + 1
                    question_type_counts[qtype] = question_type_counts.get(qtype, 0) + 1
                    total_masks += 1

            out_verilog = out_dir / str(entry["output_file"])
            out_verilog.parent.mkdir(parents=True, exist_ok=True)
            out_verilog.write_text(str(entry.get("_out_text", "")), encoding="utf-8")

            json_entry = dict(entry)
            json_entry.pop("_out_text", None)
            out_json = Path(str(out_verilog) + PER_FILE_JSON_SUFFIX)
            out_json.parent.mkdir(parents=True, exist_ok=True)
            out_json.write_text(json.dumps(json_entry, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    stats = {
        "task_scope": task_scope,
        "files_total_scanned": files_total_scanned,
        "files_in_scope": files_in_scope,
        "files_skipped_by_scope": files_skipped_by_scope,
        "mode": mode,
        "dataset_tag": dataset_tag_token,
        "main_eval_filter": main_eval_filter,
        "main_eval_filter_active": main_eval_filter_active,
        "main_eval_excluded_group_types": sorted(MAIN_EVAL_EXCLUDED_GROUP_TYPES),
        "main_eval_excluded_block_types": sorted(MAIN_EVAL_EXCLUDED_BLOCK_TYPES),
        "main_eval_excluded_block_prefixes": list(MAIN_EVAL_EXCLUDED_BLOCK_PREFIXES),
        "main_eval_weak_file_type_exclusions": {
            k: sorted(v) for k, v in sorted(MAIN_EVAL_WEAK_FILE_TYPE_EXCLUSIONS.items())
        },
        "main_eval_file_max_variants": dict(sorted(MAIN_EVAL_FILE_MAX_VARIANTS.items())),
        "seed": run_seed,
        "max_mask": MAX_MASK,
        "fixed_mask": FIXED_MASK,
        "random_mask_count": RANDOM_MASK_COUNT,
        "max_variants_per_file": MAX_VARIANTS_PER_FILE,
        "adaptive_variant_policy": ADAPTIVE_VARIANT_POLICY if mode == "weighted" else "off",
        "adaptive_max_variants_per_file": ADAPTIVE_MAX_VARIANTS_PER_FILE if mode == "weighted" else MAX_VARIANTS_PER_FILE,
        "target_total_questions": TARGET_TOTAL_QUESTIONS,
        "prefer_non_container_spans": PREFER_NON_CONTAINER_SPANS,
        "non_container_preference_prob": NON_CONTAINER_PREFERENCE_PROB,
        "total_source_files": total_source_files,
        "total_questions": total_questions,
        "masked_questions": masked_questions,
        "total_masks": total_masks,
        "type_counts": dict(sorted(type_counts.items())),
        "question_type_counts": dict(sorted(question_type_counts.items())),
        "questions_per_source_file": dict(sorted(questions_per_source_file.items())),
        "effective_max_variants_by_source_file": dict(sorted(effective_variant_cap_by_file.items())),
        "type_cap_ratio": TYPE_CAP_RATIO if mode == "weighted" else None,
        "rarity_alpha": RARITY_ALPHA if mode == "weighted" else None,
        "mandatory_type_min_counts": MANDATORY_TYPE_MIN_COUNTS if mode == "weighted" else {},
        "mandatory_type_remaining": mandatory_remaining if mode == "weighted" else {},
        "complex_type_boosts": COMPLEX_TYPE_BOOSTS if mode == "weighted" else {},
        "global_exclusion_blacklist_json": str(GLOBAL_EXCLUSION_BLACKLIST_JSON.resolve()),
        "global_exclusion_blacklist_entry_count": len(blacklist_entries),
    }
    stats_path = out_dir / "mask_type_stats.json"
    stats_path.write_text(
        json.dumps(stats, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )

    if RUN_POST_GENERATION_PIPELINE:
        report_json = base_dir / f"{out_dir.name}_report.json"
        verify_log = base_dir / f"{out_dir.name}_verify.log"

        _clear_post_generation_policy_artifacts(out_dir)
        _run_reference_verify(out_dir, report_json, verify_log)
        manifest = _write_dataset_policy_artifacts(
            out_dir=out_dir,
            report_json=report_json,
            stats_json=stats_path,
            global_blacklist_json=GLOBAL_EXCLUSION_BLACKLIST_JSON,
        )
        print(
            "post-generation pipeline complete: "
            f"report={report_json}, "
            f"excluded={manifest['dataset_counts']['excluded_forever_count']}"
        )
    else:
        _write_generation_only_artifacts(
            out_dir=out_dir,
            stats_json=stats_path,
            global_blacklist_json=GLOBAL_EXCLUSION_BLACKLIST_JSON,
        )

    print(
        f"scope {task_scope}: files_in_scope={files_in_scope}/{files_total_scanned}, "
        f"processed {total_source_files} source files, generated {total_questions} questions, "
        f"masked {masked_questions} questions, main_eval_filter_active={main_eval_filter_active}, "
        f"out_dir {out_dir}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
