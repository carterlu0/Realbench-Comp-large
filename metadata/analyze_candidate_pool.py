#!/usr/bin/env python3

from __future__ import annotations

import argparse
import json
import re
from collections import Counter, defaultdict
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Iterator, Mapping, Sequence

from benchmark_info import benchmark_info as BENCHMARK_INFO

GLOBAL_EXCLUSION_BLACKLIST_JSON = Path(__file__).resolve().parents[1] / "global_exclusion_blacklist.json"
DEFAULT_ADAPTIVE_VARIANT_POLICY = "maincore_rich_v3"
DEFAULT_BASE_MAX_VARIANTS_PER_FILE = 3
DEFAULT_ADAPTIVE_MAX_VARIANTS_PER_FILE = 7
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
    "sdc/sd_cmd_master/sd_cmd_master.v": 1,
    "sdc/sd_data_master/sd_data_master.v": 1,
    "sdc/sd_data_serial_host/sd_data_serial_host.v": 1,
    "sdc/sd_rx_fifo/sd_rx_fifo.v": 1,
    "sdc/sd_tx_fifo/sd_tx_fifo.v": 1,
}


CUT_RE = re.compile(
    r"^//__RB_CUT_(?P<tag>BEGIN|HEAD|BODY|TAIL|END)__\s+type=(?P<type>\S+)\s+id=(?P<id>\S+)\s+file=(?P<file>\S+)\s+lines=(?P<s>\d+)-(?P<e>\d+)\s*$"
)
GROUP_RE = re.compile(
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
    region: str
    parent_group_type: str | None = None
    parent_group_id: str | None = None


def mask_signature_record(
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


def mask_signature_key(record: Mapping[str, Any]) -> str:
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


def span_signature_record(rel_file: str, span: MaskSpan) -> dict[str, str]:
    return mask_signature_record(
        file=rel_file,
        masked_kind=span.kind,
        masked_type=span.unit_type,
        span_lines=f"{span.span_lines[0]}-{span.span_lines[1]}",
        region=span.region,
        parent_group_type=span.parent_group_type or "",
    )


def load_global_exclusion_blacklist(path: Path) -> tuple[list[dict[str, Any]], set[str]]:
    if not path.exists():
        return [], set()
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except Exception:
        return [], set()
    entries = list(data.get("entries", []))
    keys = {mask_signature_key(entry) for entry in entries}
    return entries, keys


def iter_verilog_files(root: Path) -> Iterator[Path]:
    for p in root.rglob("*.v"):
        if p.is_file():
            yield p


def core60_task_set() -> set[tuple[str, str]]:
    return {
        (system_name, task_name)
        for system_name, modules in BENCHMARK_INFO.items()
        for task_name in modules.keys()
    }


def is_core60_file(rel: Path, core60_tasks: set[tuple[str, str]]) -> bool:
    parts = rel.as_posix().split("/")
    if len(parts) != 3:
        return False
    system_name, task_name, filename = parts
    if (system_name, task_name) not in core60_tasks:
        return False
    return filename == f"{task_name}.v"


def filter_files_by_scope(
    files: Sequence[Path],
    input_root: Path,
    task_scope: str,
    core60_tasks: set[tuple[str, str]],
) -> list[Path]:
    if task_scope == "all82":
        return list(files)
    if task_scope != "core60":
        raise ValueError(f"Unsupported task_scope={task_scope!r}, expected core60/all82")
    out: list[Path] = []
    for path in files:
        rel = path.relative_to(input_root)
        if is_core60_file(rel, core60_tasks):
            out.append(path)
    return out


def filter_excluded_spans(
    spans: Sequence[MaskSpan],
    rel_file: str,
    excluded_signature_keys: set[str],
) -> list[MaskSpan]:
    if not excluded_signature_keys:
        return list(spans)
    out: list[MaskSpan] = []
    for span in spans:
        key = mask_signature_key(span_signature_record(rel_file, span))
        if key in excluded_signature_keys:
            continue
        out.append(span)
    return out


def parse_units(lines: Sequence[str]) -> tuple[dict[str, CutBlock], dict[str, CutGroup]]:
    blocks: dict[str, dict[str, Any]] = {}
    groups: dict[str, dict[str, Any]] = {}
    for i, raw in enumerate(lines):
        s = raw.rstrip("\n")

        m = CUT_RE.match(s)
        if m:
            tid = m.group("id")
            d = blocks.setdefault(
                tid,
                {
                    "type": m.group("type"),
                    "file": m.group("file"),
                    "span": (int(m.group("s")), int(m.group("e"))),
                    "markers": {},
                },
            )
            d["markers"][m.group("tag")] = i
            continue

        mg = GROUP_RE.match(s)
        if mg:
            tid = mg.group("id")
            d = groups.setdefault(
                tid,
                {
                    "type": mg.group("type"),
                    "file": mg.group("file"),
                    "span": (int(mg.group("s")), int(mg.group("e"))),
                    "markers": {},
                },
            )
            d["markers"][mg.group("tag")] = i

    out_blocks: dict[str, CutBlock] = {
        bid: CutBlock(d["type"], bid, d["file"], d["span"], dict(d["markers"])) for bid, d in blocks.items()
    }
    out_groups: dict[str, CutGroup] = {
        gid: CutGroup(d["type"], gid, d["file"], d["span"], dict(d["markers"])) for gid, d in groups.items()
    }
    return out_blocks, out_groups


def span_nonempty(start_idx: int, end_idx: int) -> bool:
    return 0 <= start_idx <= end_idx


def mk_block_span(b: CutBlock, start_idx: int, end_idx: int, region: str) -> list[MaskSpan]:
    if not span_nonempty(start_idx, end_idx):
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


def build_spans_for_block(b: CutBlock, mode: str, lines: Sequence[str]) -> list[MaskSpan]:
    m = b.markers
    if "BEGIN" not in m or "END" not in m:
        return []
    begin_i = m["BEGIN"]
    end_i = m["END"]

    if mode == "whole":
        return mk_block_span(b, begin_i + 1, end_i - 1, "whole")

    if mode == "body":
        if "BODY" not in m or "TAIL" not in m:
            return []
        return mk_block_span(b, m["BODY"] + 1, m["TAIL"] - 1, "body")

    if mode == "body_to_tail":
        if "BODY" not in m or "TAIL" not in m:
            return []
        return mk_block_span(b, m["BODY"] + 1, m["TAIL"] - 1, "body_to_tail")

    if mode == "head_to_tail":
        if "HEAD" not in m or "TAIL" not in m:
            return []
        return mk_block_span(b, m["HEAD"] + 1, m["TAIL"] - 1, "head_to_tail")

    if mode == "head_only":
        if "HEAD" not in m or "BODY" not in m:
            return []
        return mk_block_span(b, m["HEAD"] + 1, m["BODY"] - 1, "head")

    return []


def build_spans_for_group(g: CutGroup, lines: Sequence[str]) -> list[MaskSpan]:
    m = g.markers
    if "BEGIN" not in m or "END" not in m:
        return []
    s = m["BEGIN"] + 1
    e = m["END"] - 1
    if not span_nonempty(s, e):
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


def span_is_within_group(span: MaskSpan, group: CutGroup) -> bool:
    return span.start_idx >= group.markers["BEGIN"] + 1 and span.end_idx <= group.markers["END"] - 1


def clone_span_with_parent_group(span: MaskSpan, group: CutGroup) -> MaskSpan:
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


def build_spans_for_complex_group_blocks(
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
                variants.extend(build_spans_for_block(block, variant, lines))
            for span in variants:
                if not span_is_within_group(span, group):
                    continue
                cloned = clone_span_with_parent_group(span, group)
                if not passes_complex_group_block_semantic_filter(cloned, lines):
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


def block_is_pp_block(t: str) -> bool:
    return t.startswith("pp_") and t.endswith("_block")


DECL_GROUP_TYPES = {"port_section", "param_decl", "internal_signal"}
BEHAVIOR_GROUP_TYPES = {"assign_cluster", "reg_cluster", "comb_cluster", "counter_cluster", "handshake", "bus_cluster", "cdcsync", "fsm"}
COMPLEX_BLOCK_TYPES = {"function", "task", "case", "casex", "casez", "generate", "fork"}
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
    "fsm": ("whole",),
    "handshake": ("whole",),
}
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

# One-line block expansion (align with rb_mask_verilog.py).
# For compact one-line behavioral blocks, include nearby one-line neighbors
# to reduce trivial line-level holes in block-level completion datasets.
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

# Main leaderboard filter (align with rb_mask_verilog.py).
MAIN_EVAL_EXCLUDED_GROUP_TYPES = {"port_section", "param_decl", "internal_signal"}
MAIN_EVAL_EXCLUDED_BLOCK_TYPES: set[str] = set()
MAIN_EVAL_EXCLUDED_BLOCK_PREFIXES = ("pp_",)


def span_source_len(span: MaskSpan) -> int:
    return max(0, int(span.span_lines[1]) - int(span.span_lines[0]) + 1)


def build_ordered_whole_block_spans(
    blocks: Mapping[str, CutBlock], lines: Sequence[str]
) -> list[MaskSpan]:
    out: list[MaskSpan] = []
    for b in blocks.values():
        out.extend(build_spans_for_block(b, "whole", lines))
    out.sort(key=lambda s: (s.start_idx, s.end_idx, s.unit_id))
    return out


def expand_single_line_block_span(
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
    if span_source_len(span) != 1:
        return span

    center_idx = index_by_unit_id.get(span.unit_id)
    if center_idx is None:
        return span

    selected = [ordered_whole_block_spans[center_idx]]

    i = center_idx - 1
    picked = 0
    prev_start_line = ordered_whole_block_spans[center_idx].span_lines[0]
    while i >= 0 and picked < ONE_LINE_CONTEXT_NEIGHBORS_EACH_SIDE:
        cand = ordered_whole_block_spans[i]
        gap = prev_start_line - cand.span_lines[1]
        if span_source_len(cand) == 1 and gap <= ONE_LINE_CONTEXT_MAX_GAP_LINES:
            selected.append(cand)
            picked += 1
            prev_start_line = cand.span_lines[0]
            i -= 1
            continue
        break

    i = center_idx + 1
    picked = 0
    next_end_line = ordered_whole_block_spans[center_idx].span_lines[1]
    while i < len(ordered_whole_block_spans) and picked < ONE_LINE_CONTEXT_NEIGHBORS_EACH_SIDE:
        cand = ordered_whole_block_spans[i]
        gap = cand.span_lines[0] - next_end_line
        if span_source_len(cand) == 1 and gap <= ONE_LINE_CONTEXT_MAX_GAP_LINES:
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


def expand_one_line_block_contexts(
    spans: Sequence[MaskSpan], blocks: Mapping[str, CutBlock], lines: Sequence[str]
) -> list[MaskSpan]:
    if not EXPAND_ONE_LINE_BLOCK_CONTEXT:
        return list(spans)
    ordered_whole_block_spans = build_ordered_whole_block_spans(blocks, lines)
    index_by_unit_id = {s.unit_id: i for i, s in enumerate(ordered_whole_block_spans)}
    out: list[MaskSpan] = []
    for span in spans:
        out.append(expand_single_line_block_span(span, ordered_whole_block_spans, index_by_unit_id))
    return out


def is_main_eval_excluded_span(span: MaskSpan) -> bool:
    if span.kind == "group":
        return span.unit_type in MAIN_EVAL_EXCLUDED_GROUP_TYPES
    if span.kind == "block":
        if span.unit_type in MAIN_EVAL_EXCLUDED_BLOCK_TYPES:
            return True
        return any(span.unit_type.startswith(prefix) for prefix in MAIN_EVAL_EXCLUDED_BLOCK_PREFIXES)
    return False


def apply_main_eval_filter_to_spans(
    spans: Sequence[MaskSpan], apply_main_eval_filter: bool
) -> list[MaskSpan]:
    if not apply_main_eval_filter:
        return list(spans)
    return [s for s in spans if not is_main_eval_excluded_span(s)]


IDENT_RE = re.compile(r"[A-Za-z_][A-Za-z0-9_$]*")
ASSIGN_RHS_RE = re.compile(r"=\s*(.*?)\s*;\s*$", re.S)
CONTROL_KEYWORD_RE = re.compile(r"\b(if|case|casex|casez|for|while|repeat|forever)\b")
FSM_SIGNAL_RE = re.compile(r"\b(?:state|next_state|nstate|cur_state|fsm|st_[A-Za-z0-9_$]*)\b", re.I)
COUNTER_SIGNAL_RE = re.compile(r"\b(?:cnt|count|counter|timer|tick|idx|index)\w*\b", re.I)
COMPLEX_EXPR_TOKENS = (
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
RAM_LIKE_NAME_RE = re.compile(r"\b\w*(?:sram|ram)\w*\b", re.I)
ADAPTIVE_STRONG_TYPES = (
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
ADAPTIVE_SEMANTIC_TYPES = ("case", "fsm", "function", "generate")


def span_source_lines(span: MaskSpan, lines: Sequence[str]) -> list[str]:
    out: list[str] = []
    for i in range(span.start_idx, span.end_idx + 1):
        if i < 0 or i >= len(lines):
            continue
        line = lines[i]
        s = line.lstrip()
        if s.startswith("//__RB_CUT_") or s.startswith("//__RB_CUT_GROUP_"):
            continue
        out.append(line)
    return out


def span_nonempty_source_lines(span: MaskSpan, lines: Sequence[str]) -> list[str]:
    return [line for line in span_source_lines(span, lines) if line.strip()]


def span_source_text(span: MaskSpan, lines: Sequence[str]) -> str:
    return "".join(span_source_lines(span, lines))


def contains_complex_expr(text: str) -> bool:
    return any(tok in text for tok in COMPLEX_EXPR_TOKENS)


def is_complex_assign_span(span: MaskSpan, lines: Sequence[str]) -> bool:
    src_lines = span_nonempty_source_lines(span, lines)
    if len(src_lines) >= 2:
        return True
    text = span_source_text(span, lines)
    rhs_match = ASSIGN_RHS_RE.search(text)
    rhs = rhs_match.group(1) if rhs_match else text
    if contains_complex_expr(rhs):
        return True
    return len(set(IDENT_RE.findall(rhs))) >= 2


def is_meaningful_assign_cluster(span: MaskSpan, lines: Sequence[str]) -> bool:
    src_lines = span_nonempty_source_lines(span, lines)
    text = span_source_text(span, lines)
    assign_stmt_count = len(re.findall(r"\bassign\b", text))
    if assign_stmt_count >= 3:
        return True
    if assign_stmt_count >= 2 and (contains_complex_expr(text) or len(src_lines) >= 4):
        return True
    return False


def is_complex_instantiation(span: MaskSpan, lines: Sequence[str]) -> bool:
    src_lines = span_nonempty_source_lines(span, lines)
    text = span_source_text(span, lines)
    if len(src_lines) < 3:
        return False
    if RAM_LIKE_NAME_RE.search(text):
        return False
    named_ports = len(re.findall(r"\.\s*[A-Za-z_][A-Za-z0-9_$]*\s*\(", text))
    if named_ports >= 4:
        return True
    return text.count(",") >= 5 and len(src_lines) >= 4


def is_control_begin_end(span: MaskSpan, lines: Sequence[str]) -> bool:
    return bool(CONTROL_KEYWORD_RE.search(span_source_text(span, lines)))


def is_fsm_like_block(span: MaskSpan, lines: Sequence[str]) -> bool:
    text = span_source_text(span, lines)
    if not text.strip():
        return False
    if re.search(r"\bnext_state\b|\bnstate\b", text) and CONTROL_KEYWORD_RE.search(text):
        return True
    if re.search(r"\bcase\b", text) and re.search(r"\bnext_state\b|\bnstate\b", text):
        return True
    if re.search(
        r"\b(?:state|cur_state|[A-Za-z_][A-Za-z0-9_$]*_state)\b\s*<=\s*(?:next_state|nstate|[A-Za-z_][A-Za-z0-9_$]*_state)\b",
        text,
    ):
        return True
    return False


def is_counter_like_block(span: MaskSpan, lines: Sequence[str]) -> bool:
    text = span_source_text(span, lines)
    if not text.strip() or not COUNTER_SIGNAL_RE.search(text):
        return False
    if re.search(r"\bif\b|\bcase\b", text) and re.search(r"\+\s*1|\-\s*1|\b1\s*\+|\b1\s*\-|\+\+|\-\-", text):
        return True
    if re.search(r"<=?\s*\d+'[bdh][0-9a-f_xz]+|<=?\s*'0|<=?\s*\{?\s*1'b0", text, re.I):
        return True
    if re.search(r"[<>!=]=?|==", text) and COUNTER_SIGNAL_RE.search(text):
        return True
    return False


def passes_complex_group_block_semantic_filter(span: MaskSpan, lines: Sequence[str]) -> bool:
    if span.parent_group_type == "fsm":
        return is_fsm_like_block(span, lines)
    if span.parent_group_type == "counter_cluster":
        return is_counter_like_block(span, lines)
    return True


def is_zero_candidate_fallback_instantiation(span: MaskSpan, lines: Sequence[str]) -> bool:
    if span.unit_type != "instantiation":
        return False
    src_lines = span_nonempty_source_lines(span, lines)
    text = span_source_text(span, lines)
    named_ports = len(re.findall(r"\.\s*[A-Za-z_][A-Za-z0-9_$]*\s*\(", text))
    if len(src_lines) < 8 or named_ports < 8:
        return False
    if "#(" in text:
        return True
    if RAM_LIKE_NAME_RE.search(text):
        return True
    return bool(re.search(r"\be203_\w+_ram\b", text))


def passes_main_eval_quality_filter(span: MaskSpan, lines: Sequence[str]) -> bool:
    if span.parent_group_type in COMPLEX_GROUP_BLOCK_PARENT_TYPES:
        if span.unit_type == "assign":
            return is_complex_assign_span(span, lines)
        return True
    if span.unit_type == "assign":
        return is_complex_assign_span(span, lines)
    if span.unit_type == "assign_cluster":
        return is_meaningful_assign_cluster(span, lines)
    if span.unit_type == "instantiation":
        return is_complex_instantiation(span, lines)
    if span.unit_type == "begin_end":
        return is_control_begin_end(span, lines)
    return True


def main_eval_zero_candidate_fallback(
    spans: Sequence[MaskSpan], lines: Sequence[str]
) -> list[MaskSpan]:
    fallback = [s for s in spans if is_zero_candidate_fallback_instantiation(s, lines)]
    fallback.sort(key=lambda s: (s.start_idx, s.end_idx, s.unit_id))
    return fallback


def postprocess_candidate_spans(
    spans: Sequence[MaskSpan],
    blocks: Mapping[str, CutBlock],
    lines: Sequence[str],
    apply_main_eval_filter: bool,
) -> list[MaskSpan]:
    expanded = expand_one_line_block_contexts(spans, blocks, lines)
    filtered = apply_main_eval_filter_to_spans(expanded, apply_main_eval_filter)
    if not apply_main_eval_filter:
        return filtered
    quality = [s for s in filtered if passes_main_eval_quality_filter(s, lines)]
    if quality:
        return quality
    return main_eval_zero_candidate_fallback(filtered, lines)


def count_spans_by_type(spans: Sequence[MaskSpan]) -> dict[str, int]:
    counts: dict[str, int] = {}
    for span in spans:
        counts[span.unit_type] = counts.get(span.unit_type, 0) + 1
    return counts


def adaptive_variant_cap_for_spans(
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
            f"Unsupported adaptive_variant_policy={policy!r}, expected off/maincore_rich/maincore_rich_v3"
        )

    counts = count_spans_by_type(spans)
    strong_total = sum(counts.get(t, 0) for t in ADAPTIVE_STRONG_TYPES)
    distinct_strong = sum(1 for t in ADAPTIVE_STRONG_TYPES if counts.get(t, 0) > 0)
    semantic_total = sum(counts.get(t, 0) for t in ADAPTIVE_SEMANTIC_TYPES)
    weak_total = counts.get("assign", 0) + counts.get("instantiation", 0)
    assign_cluster_count = counts.get("assign_cluster", 0)
    handshake_count = counts.get("handshake", 0)
    begin_end_count = counts.get("begin_end", 0)
    always_count = counts.get("always", 0)
    fallback_only_instantiation = (
        set(counts.keys()) == {"instantiation"}
        and all(is_zero_candidate_fallback_instantiation(span, lines) for span in spans)
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


def apply_file_specific_main_eval_refinements(
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


def effective_file_variant_cap(rel_file: str, cap: int, apply_main_eval_filter: bool) -> int:
    if cap <= 0 or not apply_main_eval_filter:
        return cap
    cap += max(0, int(MAIN_EVAL_FILE_VARIANT_BONUSES.get(rel_file, 0)))
    override = MAIN_EVAL_FILE_MAX_VARIANTS.get(rel_file)
    if override is None:
        return cap
    return min(cap, max(1, int(override)))


def candidate_spans(
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
                spans.extend(build_spans_for_group(g, lines))
        return postprocess_candidate_spans(spans, blocks, lines, apply_main_eval_filter)

    if mode in {"complex"}:
        for b in blocks.values():
            if b.block_type in COMPLEX_BLOCK_TYPES:
                spans.extend(build_spans_for_block(b, "whole", lines))
        for g in groups.values():
            if g.group_type in {"fsm", "counter_cluster", "cdcsync"}:
                spans.extend(build_spans_for_group(g, lines))
        return postprocess_candidate_spans(spans, blocks, lines, apply_main_eval_filter)

    if mode in {"body"}:
        for b in blocks.values():
            if b.block_type in PROCEDURAL_BLOCK_TYPES:
                spans.extend(build_spans_for_block(b, "body", lines))
        return postprocess_candidate_spans(spans, blocks, lines, apply_main_eval_filter)

    if mode in {"head_only"}:
        for g in groups.values():
            if g.group_type in DECL_GROUP_TYPES:
                spans.extend(build_spans_for_group(g, lines))
        for b in blocks.values():
            if b.block_type in {"function", "task"}:
                spans.extend(build_spans_for_block(b, "head_only", lines))
        return postprocess_candidate_spans(spans, blocks, lines, apply_main_eval_filter)

    if mode in {"weighted"}:
        for g in groups.values():
            spans.extend(build_spans_for_group(g, lines))
        for b in blocks.values():
            variants: list[MaskSpan] = []
            variants.extend(build_spans_for_block(b, "whole", lines))
            variants.extend(build_spans_for_block(b, "body_to_tail", lines))
            variants.extend(build_spans_for_block(b, "head_to_tail", lines))
            seen: set[tuple[int, int, str]] = set()
            for v in variants:
                k = (v.start_idx, v.end_idx, v.region)
                if k in seen:
                    continue
                seen.add(k)
                spans.append(v)
            spans.extend(build_spans_for_complex_group_blocks(blocks, groups, lines))
        return postprocess_candidate_spans(spans, blocks, lines, apply_main_eval_filter)

    if mode in {"random"}:
        for g in groups.values():
            if g.group_type == "assign_cluster":
                spans.extend(build_spans_for_group(g, lines))
            elif g.group_type in {"reg_cluster", "comb_cluster", "counter_cluster", "handshake", "bus_cluster", "cdcsync", "fsm"}:
                spans.extend(build_spans_for_group(g, lines))
            elif g.group_type in {"port_section", "param_decl", "internal_signal"}:
                spans.extend(build_spans_for_group(g, lines))
        for b in blocks.values():
            bt = b.block_type
            if bt == "instantiation" or bt in {"function", "task"} or block_is_pp_block(bt):
                spans.extend(build_spans_for_block(b, "whole", lines))
            elif bt in {"begin_end", "case", "generate", "fork", "assign"} or bt.startswith("always"):
                spans.extend(build_spans_for_block(b, "whole", lines))
        return postprocess_candidate_spans(spans, blocks, lines, apply_main_eval_filter)

    if mode in {"group_only"}:
        for g in groups.values():
            if g.group_type in BEHAVIOR_GROUP_TYPES:
                spans.extend(build_spans_for_group(g, lines))
        return postprocess_candidate_spans(spans, blocks, lines, apply_main_eval_filter)

    if mode in {"block_only"}:
        for b in blocks.values():
            spans.extend(build_spans_for_block(b, "whole", lines))
        return postprocess_candidate_spans(spans, blocks, lines, apply_main_eval_filter)

    return postprocess_candidate_spans(spans, blocks, lines, apply_main_eval_filter)


def question_type_name(span: MaskSpan) -> str:
    if span.parent_group_type in COMPLEX_GROUP_BLOCK_PARENT_TYPES and span.kind == "block":
        return f"{span.parent_group_type}_block"
    return span.unit_type


RECOMMENDED_PROBLEM_POOL_QUESTION_TYPES = {
    "fsm",
    "function",
    "task",
    "assign_cluster",
    "reg_cluster",
    "comb_cluster",
    "counter_cluster",
    "handshake",
    "bus_cluster",
    "cdcsync",
    "case",
    "fsm_block",
    "counter_cluster_block",
    "handshake_block",
    "cdcsync_block",
}

RECOMMENDED_PROBLEM_POOL_NOTES = {
    "fsm": "whole FSM group",
    "function": "whole function body",
    "task": "whole task body",
    "assign_cluster": "clustered assignment logic",
    "reg_cluster": "clustered sequential register logic",
    "comb_cluster": "clustered combinational logic",
    "counter_cluster": "whole counter cluster group",
    "handshake": "whole handshake group",
    "bus_cluster": "whole bus-related cluster",
    "cdcsync": "whole CDC synchronization group",
    "case": "whole case block",
    "fsm_block": "important always block inside FSM group",
    "counter_cluster_block": "important always block inside counter cluster",
    "handshake_block": "important block inside handshake group",
    "cdcsync_block": "important block inside CDC sync group",
}

RECOMMENDED_PROBLEM_POOL_STRUCTURAL_COUNT_TYPES = {
    "fsm_block",
    "counter_cluster_block",
    "handshake_block",
    "cdcsync_block",
}


def structural_unique_key(span: MaskSpan) -> str:
    if span.parent_group_type in COMPLEX_GROUP_BLOCK_PARENT_TYPES and span.kind == "block":
        return f"{span.file}:{span.parent_group_id or ''}:{span.unit_id}"
    return f"{span.file}:{span.kind}:{span.unit_id}"


def build_stats(input_dir: Path, mode: str, task_scope: str, main_eval_filter: str) -> dict[str, Any]:
    span_count_by_type: Counter[str] = Counter()
    unique_unit_ids_by_type: dict[str, set[str]] = defaultdict(set)
    span_count_by_question_type: Counter[str] = Counter()
    unique_unit_ids_by_question_type: dict[str, set[str]] = defaultdict(set)
    structural_unique_ids_by_question_type: dict[str, set[str]] = defaultdict(set)
    count_by_kind: Counter[str] = Counter()
    count_by_region: Counter[str] = Counter()

    all_files = sorted(iter_verilog_files(input_dir))
    scoped_files = filter_files_by_scope(
        all_files, input_dir, task_scope.strip().lower(), core60_task_set()
    )
    blacklist_entries, excluded_signature_keys = load_global_exclusion_blacklist(
        GLOBAL_EXCLUSION_BLACKLIST_JSON
    )
    files_total_scanned = len(all_files)
    files_in_scope = len(scoped_files)
    files_skipped_by_scope = files_total_scanned - files_in_scope

    files_total = 0
    files_with_candidates = 0
    total_candidate_spans = 0
    projected_variant_cap_by_file: dict[str, int] = {}
    projected_variant_cap_distribution: Counter[str] = Counter()
    projected_total_variant_budget = 0

    mode_norm = mode.strip().lower()
    task_scope_norm = task_scope.strip().lower()
    filter_norm = main_eval_filter.strip().lower()
    if filter_norm not in {"off", "strict"}:
        raise ValueError(f"Unsupported main_eval_filter={main_eval_filter!r}, expected strict/off")
    apply_main_eval_filter = (
        filter_norm == "strict" and mode_norm == "weighted" and task_scope_norm == "core60"
    )

    for vf in scoped_files:
        files_total += 1
        rel = str(vf.relative_to(input_dir).as_posix())
        lines = vf.read_text(encoding="utf-8", errors="ignore").splitlines(keepends=True)
        blocks, groups = parse_units(lines)
        spans = candidate_spans(
            blocks,
            groups,
            lines,
            mode,
            apply_main_eval_filter=apply_main_eval_filter,
        )
        spans = apply_file_specific_main_eval_refinements(
            spans,
            rel,
            apply_main_eval_filter=apply_main_eval_filter,
        )
        spans = filter_excluded_spans(spans, rel, excluded_signature_keys)
        if spans:
            files_with_candidates += 1
            projected_cap = adaptive_variant_cap_for_spans(
                spans,
                lines,
                DEFAULT_BASE_MAX_VARIANTS_PER_FILE,
                apply_main_eval_filter=apply_main_eval_filter,
                policy=DEFAULT_ADAPTIVE_VARIANT_POLICY,
                max_cap=DEFAULT_ADAPTIVE_MAX_VARIANTS_PER_FILE,
            )
            projected_cap = effective_file_variant_cap(
                rel,
                projected_cap,
                apply_main_eval_filter=apply_main_eval_filter,
            )
            projected_variant_cap_by_file[rel] = projected_cap
            projected_variant_cap_distribution[str(projected_cap)] += 1
            projected_total_variant_budget += projected_cap

        total_candidate_spans += len(spans)
        for s in spans:
            span_count_by_type[s.unit_type] += 1
            unique_unit_ids_by_type[s.unit_type].add(f"{s.kind}:{s.unit_id}")
            qtype = question_type_name(s)
            span_count_by_question_type[qtype] += 1
            structural_unique_ids_by_question_type[qtype].add(structural_unique_key(s))
            unique_unit_ids_by_question_type[qtype].add(
                f"{s.kind}:{s.parent_group_id or ''}:{s.unit_id}:{s.region}:{s.start_idx}-{s.end_idx}"
            )
            count_by_kind[s.kind] += 1
            count_by_region[s.region] += 1

    unique_unit_count_by_type = {
        t: len(ids) for t, ids in sorted(unique_unit_ids_by_type.items(), key=lambda x: x[0])
    }
    unique_unit_count_by_question_type = {
        t: len(ids) for t, ids in sorted(unique_unit_ids_by_question_type.items(), key=lambda x: x[0])
    }
    structural_unique_unit_count_by_question_type = {
        t: len(ids) for t, ids in sorted(structural_unique_ids_by_question_type.items(), key=lambda x: x[0])
    }
    recommended_problem_pool = []
    for qtype in sorted(RECOMMENDED_PROBLEM_POOL_QUESTION_TYPES):
        span_count = int(span_count_by_question_type.get(qtype, 0))
        structural_unique_count = int(structural_unique_unit_count_by_question_type.get(qtype, 0))
        recommended_count = (
            structural_unique_count
            if qtype in RECOMMENDED_PROBLEM_POOL_STRUCTURAL_COUNT_TYPES
            else span_count
        )
        if recommended_count <= 0:
            continue
        recommended_problem_pool.append(
            {
                "question_type": qtype,
                "recommended_count": recommended_count,
                "recommended_count_basis": (
                    "structural_unique_count"
                    if qtype in RECOMMENDED_PROBLEM_POOL_STRUCTURAL_COUNT_TYPES
                    else "span_count"
                ),
                "span_count": span_count,
                "structural_unique_count": structural_unique_count,
                "notes": RECOMMENDED_PROBLEM_POOL_NOTES.get(qtype, "recommended high-value problem type"),
            }
        )

    return {
        "mode": mode_norm,
        "task_scope": task_scope_norm,
        "main_eval_filter": filter_norm,
        "main_eval_filter_active": apply_main_eval_filter,
        "main_eval_excluded_group_types": sorted(MAIN_EVAL_EXCLUDED_GROUP_TYPES),
        "main_eval_excluded_block_types": sorted(MAIN_EVAL_EXCLUDED_BLOCK_TYPES),
        "main_eval_excluded_block_prefixes": list(MAIN_EVAL_EXCLUDED_BLOCK_PREFIXES),
        "main_eval_weak_file_type_exclusions": {
            k: sorted(v) for k, v in sorted(MAIN_EVAL_WEAK_FILE_TYPE_EXCLUSIONS.items())
        },
        "main_eval_file_max_variants": dict(sorted(MAIN_EVAL_FILE_MAX_VARIANTS.items())),
        "global_exclusion_blacklist_json": str(GLOBAL_EXCLUSION_BLACKLIST_JSON),
        "global_exclusion_blacklist_entry_count": len(blacklist_entries),
        "input_dir": str(input_dir),
        "files_total": files_total,
        "files_total_scanned": files_total_scanned,
        "files_in_scope": files_in_scope,
        "files_skipped_by_scope": files_skipped_by_scope,
        "files_with_candidates": files_with_candidates,
        "total_candidate_spans": total_candidate_spans,
        "adaptive_variant_policy": DEFAULT_ADAPTIVE_VARIANT_POLICY,
        "adaptive_base_max_variants_per_file": DEFAULT_BASE_MAX_VARIANTS_PER_FILE,
        "adaptive_max_variants_per_file": DEFAULT_ADAPTIVE_MAX_VARIANTS_PER_FILE,
        "projected_total_variant_budget": projected_total_variant_budget,
        "projected_variant_cap_distribution": dict(sorted(projected_variant_cap_distribution.items())),
        "projected_variant_cap_by_file": dict(sorted(projected_variant_cap_by_file.items())),
        "candidate_span_count_by_type": dict(sorted(span_count_by_type.items())),
        "candidate_unique_unit_count_by_type": unique_unit_count_by_type,
        "candidate_span_count_by_question_type": dict(sorted(span_count_by_question_type.items())),
        "candidate_unique_unit_count_by_question_type": unique_unit_count_by_question_type,
        "candidate_structural_unique_unit_count_by_question_type": structural_unique_unit_count_by_question_type,
        "recommended_problem_pool": recommended_problem_pool,
        "candidate_count_by_kind": dict(sorted(count_by_kind.items())),
        "candidate_count_by_region": dict(sorted(count_by_region.items())),
    }


def main() -> int:
    parser = argparse.ArgumentParser(description="Count candidate mask pool distribution for annotated Verilog files.")
    parser.add_argument("--input-dir", type=Path, default=Path(__file__).resolve().parents[1] / "annotated_units")
    parser.add_argument(
        "--mode",
        type=str,
        default="weighted",
        choices=["random", "complex", "decl", "body", "head_only", "weighted", "group_only", "block_only"],
    )
    parser.add_argument(
        "--task-scope",
        type=str,
        default="core60",
        choices=["core60", "all82"],
        help="File scope: core60 uses benchmark_info main-task files only; all82 uses all annotated .v files.",
    )
    parser.add_argument(
        "--main-eval-filter",
        type=str,
        default="strict",
        choices=["strict", "off"],
        help="When strict, weighted+core60 excludes non-core sample types (pp_* and declaration groups).",
    )
    parser.add_argument("--output", type=Path, default=None, help="Optional output JSON path.")
    args = parser.parse_args()

    stats = build_stats(args.input_dir.resolve(), args.mode, args.task_scope, args.main_eval_filter)

    text = json.dumps(stats, ensure_ascii=False, indent=2) + "\n"
    if args.output is not None:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(text, encoding="utf-8")
        print(f"wrote: {args.output}")
    else:
        print(text, end="")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
