#!/usr/bin/env python3

from __future__ import annotations

import bisect
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Iterator, Sequence

from pyverilog.vparser.lexer import VerilogLexer


BASE_DIR = Path(__file__).resolve().parents[1]
TARGET_DIRS = [
    "sdc",
    "aes",
    "e203_hbirdv2",
]
OUT_DIRNAME = "annotated_units"


@dataclass(frozen=True)
class CutBlock:
    block_type: str
    block_id: str
    span_start_line: int
    span_end_line: int
    begin_before_line: int
    head_before_line: int | None
    body_before_line: int | None
    tail_before_line: int | None
    tail_after_line: int | None
    end_before_line: int | None
    end_after_line: int | None


@dataclass(frozen=True)
class CutGroup:
    group_type: str
    group_id: str
    start_line: int
    end_line: int


def _tokenize(text: str, filename: str) -> list:
    def err(msg: str, line: int) -> None:
        raise SyntaxError(f"{filename}:{line}: {msg}")

    lexer = VerilogLexer(err)
    lexer.build()
    lexer.reset_lineno()
    lexer.input(text)
    out = []
    while True:
        t = lexer.token()
        if t is None:
            break
        out.append(t)
    return out


def _build_line_starts(text: str) -> list[int]:
    starts = [0]
    i = 0
    while True:
        j = text.find("\n", i)
        if j < 0:
            break
        starts.append(j + 1)
        i = j + 1
    return starts


def _pos_to_line(line_starts: Sequence[int], pos: int) -> int:
    p = max(0, min(pos, (line_starts[-1] if line_starts else 0)))
    return bisect.bisect_right(line_starts, p)


def _token_idx_after_pos(lexposes: Sequence[int], pos: int) -> int:
    return bisect.bisect_right(lexposes, pos)


def _token_idx_at_or_after_pos(lexposes: Sequence[int], pos: int) -> int:
    return bisect.bisect_left(lexposes, pos)


def _scan_skip(text: str, pos: int) -> int:
    n = len(text)
    i = max(0, pos)
    while i < n:
        ch = text[i]
        if ch.isspace():
            i += 1
            continue
        if ch == "/" and i + 1 < n and text[i + 1] == "/":
            j = text.find("\n", i + 2)
            if j < 0:
                return n
            i = j + 1
            continue
        if ch == "/" and i + 1 < n and text[i + 1] == "*":
            j = text.find("*/", i + 2)
            if j < 0:
                return n
            i = j + 2
            continue
        if ch == '"':
            i += 1
            while i < n:
                if text[i] == "\\" and i + 1 < n:
                    i += 2
                    continue
                if text[i] == '"':
                    i += 1
                    break
                i += 1
            continue
        return i
    return n


def _scan_balanced(text: str, open_pos: int, open_ch: str, close_ch: str) -> int:
    if open_pos < 0 or open_pos >= len(text) or text[open_pos] != open_ch:
        raise ValueError(f"expected {open_ch} at pos {open_pos}")
    n = len(text)
    depth = 1
    i = open_pos + 1
    in_string = False
    while i < n and depth > 0:
        ch = text[i]
        if in_string:
            if ch == "\\" and i + 1 < n:
                i += 2
                continue
            if ch == '"':
                in_string = False
            i += 1
            continue
        if ch == "/" and i + 1 < n and text[i + 1] == "/":
            j = text.find("\n", i + 2)
            if j < 0:
                return n - 1
            i = j + 1
            continue
        if ch == "/" and i + 1 < n and text[i + 1] == "*":
            j = text.find("*/", i + 2)
            if j < 0:
                return n - 1
            i = j + 2
            continue
        if ch == '"':
            in_string = True
            i += 1
            continue
        if ch == open_ch:
            depth += 1
        elif ch == close_ch:
            depth -= 1
        i += 1
    if depth != 0:
        raise ValueError(f"unbalanced {open_ch}/{close_ch}")
    return i - 1


_WORD_RE = re.compile(r"[A-Za-z_][A-Za-z0-9_$]*")
_IDENT_RE2 = re.compile(r"[A-Za-z_][A-Za-z0-9_$]*")


def _read_word(text: str, pos: int) -> tuple[str, int, int] | None:
    i = _scan_skip(text, pos)
    if i >= len(text):
        return None
    if text[i] == "`":
        j = i + 1
        m = _WORD_RE.match(text, j)
        if not m:
            return None
        return f"`{m.group(0)}", i, m.end()
    m = _WORD_RE.match(text, i)
    if not m:
        return None
    return m.group(0), i, m.end()


def _iter_words(text: str) -> Iterator[tuple[str, int, int]]:
    n = len(text)
    i = 0
    in_block_comment = False
    in_string = False
    while i < n:
        ch = text[i]
        if in_string:
            if ch == "\\" and i + 1 < n:
                i += 2
                continue
            if ch == '"':
                in_string = False
            i += 1
            continue
        if in_block_comment:
            j = text.find("*/", i)
            if j < 0:
                return
            i = j + 2
            in_block_comment = False
            continue
        if ch == "/" and i + 1 < n and text[i + 1] == "/":
            j = text.find("\n", i + 2)
            if j < 0:
                return
            i = j + 1
            continue
        if ch == "/" and i + 1 < n and text[i + 1] == "*":
            in_block_comment = True
            i += 2
            continue
        if ch == '"':
            in_string = True
            i += 1
            continue
        if ch == "`":
            m = _WORD_RE.match(text, i + 1)
            if m:
                i = m.end()
                continue
            i += 1
            continue
        m = _WORD_RE.match(text, i)
        if m:
            w = m.group(0)
            yield w.lower(), m.start(), m.end()
            i = m.end()
            continue
        i += 1


def _scan_stmt_end_pos_text(text: str, pos: int) -> int:
    p = _scan_skip(text, pos)
    if p >= len(text):
        return p
    if text[p] in {"@", "#"}:
        p = _scan_event_delay_prefix(text, p)
        p = _scan_skip(text, p)
        if p >= len(text):
            return p

    w0 = _read_word(text, p)
    if w0 is not None:
        w, ws, we = w0
        wl = w.lower()
        if wl == "begin":
            depth = 1
            i = we
            while i < len(text) and depth > 0:
                nxt = _read_word(text, i)
                if nxt is None:
                    i += 1
                    continue
                ww, s, e = nxt
                wwl = ww.lower()
                if wwl == "begin":
                    depth += 1
                elif wwl == "end":
                    depth -= 1
                i = e
            return i
        if wl in {"case", "casex", "casez"}:
            depth = 1
            i = we
            while i < len(text) and depth > 0:
                nxt = _read_word(text, i)
                if nxt is None:
                    i += 1
                    continue
                ww, s, e = nxt
                wwl = ww.lower()
                if wwl in {"case", "casex", "casez"}:
                    depth += 1
                elif wwl == "endcase":
                    depth -= 1
                i = e
            return i
        if wl == "fork":
            depth = 1
            i = we
            while i < len(text) and depth > 0:
                nxt = _read_word(text, i)
                if nxt is None:
                    i += 1
                    continue
                ww, s, e = nxt
                wwl = ww.lower()
                if wwl == "fork":
                    depth += 1
                elif wwl in {"join", "join_any", "join_none"}:
                    depth -= 1
                i = e
            return i
        if wl == "generate":
            depth = 1
            i = we
            while i < len(text) and depth > 0:
                nxt = _read_word(text, i)
                if nxt is None:
                    i += 1
                    continue
                ww, s, e = nxt
                wwl = ww.lower()
                if wwl == "generate":
                    depth += 1
                elif wwl == "endgenerate":
                    depth -= 1
                i = e
            return i
        if wl == "if":
            p2 = _scan_skip(text, we)
            if p2 < len(text) and text[p2] == "(":
                close = _scan_balanced(text, p2, "(", ")")
                then_end = _scan_stmt_end_pos_text(text, close + 1)
                q = _scan_skip(text, then_end)
                nxt = _read_word(text, q)
                if nxt is not None and nxt[0].lower() == "else":
                    return _scan_stmt_end_pos_text(text, nxt[2])
                return then_end
        if wl in {"for", "while", "repeat", "wait"}:
            p2 = _scan_skip(text, we)
            if p2 < len(text) and text[p2] == "(":
                close = _scan_balanced(text, p2, "(", ")")
                return _scan_stmt_end_pos_text(text, close + 1)

    semi = _scan_to_semicolon(text, p)
    return semi + 1

def _parse_begin_end(tokens: Sequence, begin_idx: int) -> int:
    if tokens[begin_idx].type != "BEGIN":
        raise ValueError("expected BEGIN")
    depth = 1
    i = begin_idx + 1
    while i < len(tokens) and depth > 0:
        tt = tokens[i].type
        if tt == "BEGIN":
            depth += 1
        elif tt == "END":
            depth -= 1
        i += 1
    if depth != 0:
        raise ValueError("unbalanced BEGIN/END")
    return i - 1


def _parse_case(tokens: Sequence, case_idx: int) -> int:
    if tokens[case_idx].type not in {"CASE", "CASEX", "CASEZ"}:
        raise ValueError("expected CASE/CASEX/CASEZ")
    depth = 1
    i = case_idx + 1
    while i < len(tokens) and depth > 0:
        tt = tokens[i].type
        if tt in {"CASE", "CASEX", "CASEZ"}:
            depth += 1
        elif tt == "ENDCASE":
            depth -= 1
        i += 1
    if depth != 0:
        raise ValueError("unbalanced CASE/ENDCASE")
    return i - 1


def _scan_to_semicolon(text: str, start_pos: int) -> int:
    n = len(text)
    i = max(0, start_pos)
    paren = 0
    bracket = 0
    brace = 0
    in_string = False
    while i < n:
        ch = text[i]
        if in_string:
            if ch == "\\" and i + 1 < n:
                i += 2
                continue
            if ch == '"':
                in_string = False
            i += 1
            continue
        if ch == "/" and i + 1 < n and text[i + 1] == "/":
            j = text.find("\n", i + 2)
            if j < 0:
                return n - 1
            i = j + 1
            continue
        if ch == "/" and i + 1 < n and text[i + 1] == "*":
            j = text.find("*/", i + 2)
            if j < 0:
                return n - 1
            i = j + 2
            continue
        if ch == '"':
            in_string = True
            i += 1
            continue
        if ch == "(":
            paren += 1
        elif ch == ")":
            paren = max(paren - 1, 0)
        elif ch == "[":
            bracket += 1
        elif ch == "]":
            bracket = max(bracket - 1, 0)
        elif ch == "{":
            brace += 1
        elif ch == "}":
            brace = max(brace - 1, 0)
        elif ch == ";" and paren == 0 and bracket == 0 and brace == 0:
            return i
        i += 1
    raise ValueError("statement missing semicolon")


def _parse_stmt_end_pos(tokens: Sequence, start_idx: int, text: str, lexposes: Sequence[int]) -> int:
    if start_idx >= len(tokens):
        raise ValueError("unexpected EOF while parsing statement")
    tt = tokens[start_idx].type
    if tt == "ID" and start_idx + 1 < len(tokens) and tokens[start_idx + 1].type == "COLON":
        return _parse_stmt_end_pos(tokens, start_idx + 2, text, lexposes)
    if tt == "BEGIN":
        end_i = _parse_begin_end(tokens, start_idx)
        return int(tokens[end_i].lexpos) + len(str(tokens[end_i].value))
    if tt in {"CASE", "CASEX", "CASEZ"}:
        end_i = _parse_case(tokens, start_idx)
        return int(tokens[end_i].lexpos) + len(str(tokens[end_i].value))
    if tt == "FORK":
        depth = 1
        i = start_idx + 1
        while i < len(tokens) and depth > 0:
            tti = tokens[i].type
            if tti == "FORK":
                depth += 1
            elif tti in {"JOIN", "JOIN_ANY", "JOIN_NONE"}:
                depth -= 1
            i += 1
        if depth != 0:
            raise ValueError("unbalanced FORK/JOIN")
        end_i = i - 1
        return int(tokens[end_i].lexpos) + len(str(tokens[end_i].value))
    if tt == "HASH":
        pos = _scan_skip(text, int(tokens[start_idx].lexpos) + 1)
        if pos < len(text) and text[pos] == "(":
            close = _scan_balanced(text, pos, "(", ")")
            stmt_idx = _token_idx_at_or_after_pos(lexposes, close + 1)
            return _parse_stmt_end_pos(tokens, stmt_idx, text, lexposes)
        j = pos
        while j < len(text) and not text[j].isspace():
            if text[j] in {";", "\n"}:
                break
            j += 1
        stmt_idx = _token_idx_at_or_after_pos(lexposes, j)
        return _parse_stmt_end_pos(tokens, stmt_idx, text, lexposes)
    if tt == "AT":
        pos = _scan_skip(text, int(tokens[start_idx].lexpos) + 1)
        if pos < len(text) and text[pos] == "(":
            close = _scan_balanced(text, pos, "(", ")")
            stmt_idx = _token_idx_at_or_after_pos(lexposes, close + 1)
            return _parse_stmt_end_pos(tokens, stmt_idx, text, lexposes)
        stmt_idx = _token_idx_at_or_after_pos(lexposes, pos)
        return _parse_stmt_end_pos(tokens, stmt_idx, text, lexposes)
    if tt in {"IF", "FOR", "WHILE", "REPEAT", "WAIT"}:
        kw_len = len(str(tokens[start_idx].value))
        pos = _scan_skip(text, int(tokens[start_idx].lexpos) + kw_len)
        if pos < len(text) and text[pos] == "(":
            close = _scan_balanced(text, pos, "(", ")")
            stmt_idx = _token_idx_at_or_after_pos(lexposes, close + 1)
            end1 = _parse_stmt_end_pos(tokens, stmt_idx, text, lexposes)
            if tt == "IF":
                else_idx = _token_idx_after_pos(lexposes, end1)
                if else_idx < len(tokens) and tokens[else_idx].type == "ELSE":
                    return _parse_stmt_end_pos(tokens, else_idx + 1, text, lexposes)
            return end1
        raise ValueError(f"missing condition parentheses after {tt}")
    semi = _scan_to_semicolon(text, int(tokens[start_idx].lexpos))
    return semi + 1


_IDENT_RE = re.compile(r"[A-Za-z_][A-Za-z0-9_$]*")


_SV_KEYWORDS = {
    "always",
    "always_comb",
    "always_ff",
    "always_latch",
    "and",
    "assign",
    "automatic",
    "begin",
    "buf",
    "case",
    "casex",
    "casez",
    "cell",
    "config",
    "deassign",
    "default",
    "defparam",
    "design",
    "disable",
    "edge",
    "else",
    "end",
    "endcase",
    "endconfig",
    "endfunction",
    "endgenerate",
    "endmodule",
    "endprimitive",
    "endspecify",
    "endtable",
    "endtask",
    "event",
    "final",
    "for",
    "force",
    "forever",
    "fork",
    "function",
    "generate",
    "genvar",
    "if",
    "ifdef",
    "ifndef",
    "include",
    "initial",
    "inout",
    "input",
    "integer",
    "join",
    "join_any",
    "join_none",
    "localparam",
    "logic",
    "macromodule",
    "module",
    "negedge",
    "nor",
    "not",
    "or",
    "output",
    "parameter",
    "posedge",
    "primitive",
    "pull0",
    "pull1",
    "real",
    "realtime",
    "reg",
    "release",
    "repeat",
    "rnmos",
    "rpmos",
    "rtran",
    "rtranif0",
    "rtranif1",
    "specify",
    "supply0",
    "supply1",
    "table",
    "task",
    "time",
    "tran",
    "tranif0",
    "tranif1",
    "tri",
    "tri0",
    "tri1",
    "triand",
    "trior",
    "trireg",
    "wait",
    "while",
    "wire",
    "xnor",
    "xor",
}


def _scan_identifier(text: str, pos: int) -> tuple[str, int] | None:
    i = _scan_skip(text, pos)
    if i >= len(text):
        return None
    if text[i] == "\\":
        j = i + 1
        while j < len(text) and not text[j].isspace():
            j += 1
        return text[i:j], j
    m = _IDENT_RE.match(text, i)
    if not m:
        return None
    return m.group(0), m.end()


def _try_parse_instantiation_semicolon(text: str, start_pos: int) -> int | None:
    pos = _scan_skip(text, start_pos)
    mod = _scan_identifier(text, pos)
    if mod is None:
        return None
    _, end_mod = mod
    pos = _scan_skip(text, end_mod)
    if pos < len(text) and text[pos] == "#":
        pos = _scan_skip(text, pos + 1)
        if pos >= len(text) or text[pos] != "(":
            return None
        pos = _scan_balanced(text, pos, "(", ")") + 1
        pos = _scan_skip(text, pos)
    inst = _scan_identifier(text, pos)
    if inst is None:
        return None
    inst_name, end_inst = inst
    if inst_name.lower() in _SV_KEYWORDS:
        return None
    pos = _scan_skip(text, end_inst)
    if pos >= len(text) or text[pos] != "(":
        return None
    close = _scan_balanced(text, pos, "(", ")")
    pos = _scan_skip(text, close + 1)
    while pos < len(text) and text[pos] == ",":
        pos = _scan_skip(text, pos + 1)
        inst2 = _scan_identifier(text, pos)
        if inst2 is None:
            return None
        inst2_name, inst2_end = inst2
        if inst2_name.lower() in _SV_KEYWORDS:
            return None
        pos = _scan_skip(text, inst2_end)
        if pos >= len(text) or text[pos] != "(":
            return None
        close2 = _scan_balanced(text, pos, "(", ")")
        pos = _scan_skip(text, close2 + 1)
    if pos >= len(text) or text[pos] != ";":
        return None
    return pos


_ALWAYS_ID_VALUES = {"always_comb", "always_ff", "always_latch"}
_DECL_START_TYPES = {
    "INTEGER",
    "REAL",
    "REALTIME",
    "TIME",
    "REG",
    "LOGIC",
    "EVENT",
    "PARAMETER",
    "LOCALPARAM",
    "GENVAR",
    "WIRE",
    "TRI",
    "SUPPLY0",
    "SUPPLY1",
}


def _cut_id(prefix: str, kind: str, counter: int) -> str:
    return f"{prefix}:{kind}:{counter:06d}"


def _group_id(prefix: str, kind: str, counter: int) -> str:
    return f"{prefix}:grp:{kind}:{counter:06d}"


def _extract_identifiers(text: str) -> set[str]:
    keywords = {
        "module",
        "endmodule",
        "begin",
        "end",
        "if",
        "else",
        "case",
        "casex",
        "casez",
        "endcase",
        "for",
        "while",
        "repeat",
        "wait",
        "always",
        "always_comb",
        "always_ff",
        "always_latch",
        "initial",
        "final",
        "assign",
        "function",
        "endfunction",
        "task",
        "endtask",
        "wire",
        "reg",
        "logic",
        "input",
        "output",
        "inout",
        "parameter",
        "localparam",
        "generate",
        "endgenerate",
        "fork",
        "join",
        "join_any",
        "join_none",
    }
    out: set[str] = set()
    for m in _IDENT_RE2.finditer(text):
        w = m.group(0)
        wl = w.lower()
        if wl in keywords:
            continue
        out.add(w)
    return out


_SEP_COMMENT_RE = re.compile(r"^\s*//\s*([/=*_\\-]{6,})\s*$")


def _is_separator_comment_line(s: str) -> bool:
    if not s:
        return False
    m = _SEP_COMMENT_RE.match(s)
    if m:
        return True
    if s.startswith("//"):
        payload = s[2:].strip()
        if len(payload) >= 12 and len(set(payload)) == 1 and payload[0] in "/-=*_":
            return True
    if s.startswith("/*") and s.endswith("*/"):
        payload = s[2:-2].strip()
        if len(payload) >= 12 and len(set(payload)) == 1 and payload[0] in "/-=*_":
            return True
    return False


def _gap_only(lines: Sequence[str], a_end: int, b_start: int) -> bool:
    if b_start <= a_end + 1:
        return True
    for ln in range(a_end + 1, b_start):
        s = lines[ln - 1].strip()
        if not s:
            continue
        if _is_separator_comment_line(s):
            return False
        if s.startswith("//"):
            continue
        return False
    return True


def _parse_clk_rst(header: str) -> tuple[str | None, str | None]:
    edges = re.findall(r"\b(posedge|negedge)\s+([A-Za-z_][A-Za-z0-9_$]*)", header)
    clk = edges[0][1] if edges else None
    rst = edges[1][1] if len(edges) > 1 else None
    return clk, rst


def _always_kind(block_type: str, header: str) -> str:
    bt = block_type.lower()
    if bt == "always_ff":
        return "seq"
    if bt in {"always_comb", "always_latch"}:
        return "comb"
    h = header.lower()
    if "posedge" in h or "negedge" in h:
        return "seq"
    if re.search(r"@\s*\(\s*\*\s*\)", h) or re.search(r"@\s*\*", h):
        return "comb"
    return "comb"


@dataclass(frozen=True)
class _Atomic:
    kind: str  # assign | always
    subkind: str  # comb | seq | other
    start_line: int
    end_line: int
    block_id: str
    ids: set[str]
    clk: str | None
    rst: str | None
    text: str


def _extract_sensitivity(block_text: str) -> str:
    at = block_text.find("@")
    if at < 0:
        return block_text[:256]
    pos = _scan_skip(block_text, at + 1)
    if pos < len(block_text) and block_text[pos] == "(":
        try:
            close = _scan_balanced(block_text, pos, "(", ")")
            return block_text[at : close + 1]
        except Exception:
            pass
    nl = block_text.find("\n", at)
    if nl < 0:
        return block_text[at:]
    return block_text[at:nl]


def _build_atomics(cuts: Sequence[CutBlock], lines: Sequence[str], file_text: str, line_starts: Sequence[int]) -> list[_Atomic]:
    out: list[_Atomic] = []
    for c in cuts:
        bt = c.block_type
        if bt == "assign":
            s, e = c.span_start_line, c.span_end_line
            assign_text = "".join(lines[s - 1 : e])
            out.append(_Atomic("assign", "comb", s, e, c.block_id, _extract_identifiers(assign_text), None, None, assign_text))
        elif bt in {"always", "always_comb", "always_ff", "always_latch"}:
            s, e = c.span_start_line, c.span_end_line
            body_text = "".join(lines[s - 1 : e])
            header = _extract_sensitivity(body_text)
            kind = _always_kind(bt, header)
            clk, rst = _parse_clk_rst(header) if kind == "seq" else (None, None)
            out.append(_Atomic("always", kind, s, e, c.block_id, _extract_identifiers(body_text), clk, rst, body_text))
    out.sort(key=lambda x: (x.start_line, x.end_line))
    return out


def _looks_like_state_name(name: str) -> bool:
    n = name.lower()
    if "state" in n or "fsm" in n:
        return True
    if re.search(r"(^|_)(cs|ns|ps|cur|next|st)(_|$)", n):
        return True
    return False


def _state_ids_in_atomic(a: _Atomic) -> set[str]:
    out = {x for x in a.ids if _looks_like_state_name(x)}
    for m in re.finditer(r"\b([A-Za-z_][A-Za-z0-9_$]*)\s*<=", a.text):
        lhs = m.group(1)
        if _looks_like_state_name(lhs):
            out.add(lhs)
    for m in re.finditer(r"\bcase(?:x|z)?\s*\(([^\)]*)\)", a.text, flags=re.IGNORECASE | re.DOTALL):
        expr = m.group(1)
        for x in _extract_identifiers(expr):
            if _looks_like_state_name(x):
                out.add(x)
    return out


def _overlap_lines(a: tuple[int, int], b: tuple[int, int]) -> bool:
    return not (a[1] < b[0] or b[1] < a[0])


def _normalize_groups(groups: Sequence[CutGroup]) -> list[CutGroup]:
    g = sorted(groups, key=lambda x: (x.start_line, -x.end_line, x.group_type, x.group_id))
    out: list[CutGroup] = []
    stack: list[CutGroup] = []
    for cur in g:
        while stack and cur.start_line > stack[-1].end_line:
            stack.pop()
        if stack and cur.start_line <= stack[-1].end_line < cur.end_line:
            continue
        out.append(cur)
        stack.append(cur)
    uniq: dict[tuple[str, int, int], CutGroup] = {}
    for gg in out:
        uniq[(gg.group_type, gg.start_line, gg.end_line)] = gg
    return list(uniq.values())


def _find_groups(prefix: str, relpath: str, lines: Sequence[str], cuts: Sequence[CutBlock]) -> list[CutGroup]:
    text = "".join(lines)
    line_starts = _build_line_starts(text)
    atomics = _build_atomics(cuts, lines, text, line_starts)
    groups: list[CutGroup] = []
    counters: dict[str, int] = {}

    def add(gtype: str, s: int, e: int) -> None:
        if e < s:
            return
        counters[gtype] = counters.get(gtype, 0) + 1
        groups.append(CutGroup(gtype, _group_id(prefix, gtype, counters[gtype]), s, e))

    nlines = len(lines)

    def _is_blank_or_comment(s: str) -> bool:
        if not s:
            return True
        if s.startswith("//"):
            return True
        if s.startswith("/*") and s.endswith("*/"):
            return True
        return False

    def _pp_kind(s: str) -> str | None:
        if not s.startswith("`"):
            return None
        m = re.match(r"^`(ifdef|ifndef|elsif|else|endif|include|define)\b", s)
        return m.group(1) if m else None

    def _is_pp(s: str) -> bool:
        return _pp_kind(s) is not None

    def _is_ignorable(s: str) -> bool:
        return _is_blank_or_comment(s) or _is_pp(s)

    def _is_module(s: str) -> bool:
        return re.match(r"^module\b", s) is not None

    def _is_endmodule(s: str) -> bool:
        return re.match(r"^endmodule\b", s) is not None

    def _is_port_decl(s: str) -> bool:
        return re.match(r"^(input|output|inout)\b", s) is not None

    def _is_param_decl(s: str) -> bool:
        if re.match(r"^(parameter|localparam)\b", s) is not None:
            return True
        return s.startswith("`define")

    def _is_internal_signal(s: str) -> bool:
        return re.match(r"^(reg|wire)\b", s) is not None

    mi = 1
    while mi <= nlines:
        ms = lines[mi - 1].strip()
        if not _is_module(ms):
            mi += 1
            continue
        mj = mi + 1
        while mj <= nlines and not _is_endmodule(lines[mj - 1].strip()):
            mj += 1
        mend = mj if mj <= nlines else nlines

        open_line: int | None = None
        close_line: int | None = None
        in_param = False
        param_depth = 0
        scan = mi
        while scan <= mend:
            raw = lines[scan - 1]
            s = raw.split("//", 1)[0]
            if not in_param:
                idx = s.find("#(")
                j = idx + 2 if idx >= 0 else 0
                if idx >= 0:
                    in_param = True
                    param_depth = 1
            else:
                j = 0
            while j < len(s):
                ch = s[j]
                if in_param:
                    if ch == "(":
                        param_depth += 1
                    elif ch == ")":
                        param_depth -= 1
                        if param_depth <= 0:
                            in_param = False
                            param_depth = 0
                    j += 1
                    continue
                if open_line is None and ch == "(":
                    open_line = scan
                    break
                j += 1
            if open_line is not None:
                if re.search(r"\)\s*;\s*$", s) or re.search(r"\);\s*$", s):
                    close_line = scan
                    break
            scan += 1
        if open_line is not None and close_line is not None and close_line > open_line:
            add("port_section", open_line + 1, close_line - 1)
        elif open_line is not None and close_line is not None and close_line == open_line:
            s = mi + 1
            last_port: int | None = None
            k = s
            while k < mend:
                t = lines[k - 1].strip()
                if _is_ignorable(t):
                    k += 1
                    continue
                if _is_port_decl(t):
                    last_port = k
                    k += 1
                    continue
                break
            if last_port is not None and last_port >= s:
                add("port_section", s, last_port)

        s = mi + 1
        e = mend - 1
        run_s: int | None = None
        last: int | None = None
        for ln in range(s, e + 1):
            t = lines[ln - 1].strip()
            if _is_param_decl(t):
                if run_s is None:
                    run_s = ln
                last = ln
                continue
            if _is_ignorable(t):
                if run_s is not None and _is_pp(t):
                    last = ln
                continue
            if run_s is not None and last is not None:
                add("param_decl", run_s, last)
            run_s = None
            last = None
        if run_s is not None and last is not None:
            add("param_decl", run_s, last)

        run_s = None
        last = None
        for ln in range(s, e + 1):
            t = lines[ln - 1].strip()
            if _is_internal_signal(t):
                if run_s is None:
                    run_s = ln
                last = ln
                continue
            if _is_ignorable(t):
                if run_s is not None and _is_pp(t):
                    last = ln
                continue
            if run_s is not None and last is not None:
                add("internal_signal", run_s, last)
            run_s = None
            last = None
        if run_s is not None and last is not None:
            add("internal_signal", run_s, last)

        mi = mend + 1

    # assign_cluster
    run: list[_Atomic] = []
    for a in atomics:
        if a.kind != "assign":
            if len(run) >= 2:
                add("assign_cluster", run[0].start_line, run[-1].end_line)
            run = []
            continue
        if not run:
            run = [a]
            continue
        if _gap_only(lines, run[-1].end_line, a.start_line):
            run.append(a)
        else:
            if len(run) >= 2:
                add("assign_cluster", run[0].start_line, run[-1].end_line)
            run = [a]
    if len(run) >= 2:
        add("assign_cluster", run[0].start_line, run[-1].end_line)

    # reg_cluster
    run = []
    for a in atomics:
        if a.kind != "always" or a.subkind != "seq" or a.clk is None:
            if len(run) >= 2:
                add("reg_cluster", run[0].start_line, run[-1].end_line)
            run = []
            continue
        if not run:
            run = [a]
            continue
        same = (a.clk, a.rst) == (run[-1].clk, run[-1].rst)
        if same and _gap_only(lines, run[-1].end_line, a.start_line):
            run.append(a)
        else:
            if len(run) >= 2:
                add("reg_cluster", run[0].start_line, run[-1].end_line)
            run = [a]
    if len(run) >= 2:
        add("reg_cluster", run[0].start_line, run[-1].end_line)

    # comb_cluster
    run = []
    for a in atomics:
        if a.kind != "always" or a.subkind != "comb":
            if len(run) >= 2:
                add("comb_cluster", run[0].start_line, run[-1].end_line)
            run = []
            continue
        if not run:
            run = [a]
            continue
        inter = len(run[-1].ids & a.ids)
        if _gap_only(lines, run[-1].end_line, a.start_line) and inter >= 3:
            run.append(a)
        else:
            if len(run) >= 2:
                add("comb_cluster", run[0].start_line, run[-1].end_line)
            run = [a]
    if len(run) >= 2:
        add("comb_cluster", run[0].start_line, run[-1].end_line)

    # fsm (precision-first): build strong seq/comb pairs sharing state IDs,
    # then deduplicate overlapping candidates and keep only one FSM per file.
    always_blocks = [a for a in atomics if a.kind == "always"]
    seq_blocks = [a for a in always_blocks if a.subkind == "seq"]
    comb_blocks = [a for a in always_blocks if a.subkind == "comb"]

    seq_state_ids = {a.block_id: _state_ids_in_atomic(a) for a in seq_blocks}
    comb_state_ids = {a.block_id: _state_ids_in_atomic(a) for a in comb_blocks}

    fsm_candidates: list[tuple[int, int, int]] = []  # (start, end, score)
    for sa in seq_blocks:
        sids = seq_state_ids.get(sa.block_id, set())
        if not sids:
            continue
        for cb in comb_blocks:
            cids = comb_state_ids.get(cb.block_id, set())
            if not cids:
                continue
            shared = sids & cids
            if not shared:
                continue
            if abs(cb.start_line - sa.start_line) > 140:
                continue

            s = min(sa.start_line, cb.start_line)
            e = max(sa.end_line, cb.end_line)

            has_case = bool(re.search(r"\bcase(?:x|z)?\b", cb.text, flags=re.IGNORECASE))
            score = len(shared) * 10 + (5 if has_case else 0)
            fsm_candidates.append((s, e, score))

    # Merge overlapping FSM candidates to avoid multiple envelopes for one FSM.
    fsm_candidates.sort(key=lambda x: (x[0], x[1]))
    merged: list[list[tuple[int, int, int]]] = []
    for c in fsm_candidates:
        if not merged:
            merged.append([c])
            continue
        last_cluster = merged[-1]
        cur_rng = (c[0], c[1])
        cluster_rng = (min(x[0] for x in last_cluster), max(x[1] for x in last_cluster))
        if _overlap_lines(cur_rng, cluster_rng):
            last_cluster.append(c)
        else:
            merged.append([c])

    # File-level unique FSM unit: keep only the best representative candidate.
    best_fsm: tuple[int, int, int] | None = None
    for cluster in merged:
        # prefer higher score; tie-breaker prefers shorter span.
        local_best = max(cluster, key=lambda x: (x[2], -(x[1] - x[0])))
        if best_fsm is None or (local_best[2], -(local_best[1] - local_best[0])) > (
            best_fsm[2],
            -(best_fsm[1] - best_fsm[0]),
        ):
            best_fsm = local_best

    if best_fsm is not None:
        add("fsm", best_fsm[0], best_fsm[1])
    else:
        # Conservative fallback: keep at most one local window candidate.
        fallback_best: tuple[int, int, int] | None = None
        for i in range(len(always_blocks)):
            win = always_blocks[i : i + 8]
            if len(win) < 2:
                continue
            has_seq = any(a.subkind == "seq" for a in win)
            has_comb = any(a.subkind == "comb" for a in win)
            if not (has_seq and has_comb):
                continue

            state_ids = set()
            has_case = False
            for a in win:
                state_ids |= _state_ids_in_atomic(a)
                if a.subkind == "comb" and re.search(r"\bcase(?:x|z)?\b", a.text, flags=re.IGNORECASE):
                    has_case = True

            if not state_ids:
                continue
            if not has_case:
                continue

            s = win[0].start_line
            e = win[-1].end_line
            score = len(state_ids) * 10 + 5 - (e - s)
            cand = (s, e, score)
            if fallback_best is None or cand[2] > fallback_best[2]:
                fallback_best = cand

        if fallback_best is not None:
            add("fsm", fallback_best[0], fallback_best[1])

    # counter_cluster (heuristic)
    for a in always_blocks:
        cand = [x for x in a.ids if any(k in x.lower() for k in ("cnt", "count", "counter"))]
        if not cand:
            continue
        s = a.start_line
        e = a.end_line
        for b in atomics:
            if b is a:
                continue
            if b.start_line < s - 30 or b.end_line > e + 30:
                continue
            if cand and (b.ids & set(cand)):
                s = min(s, b.start_line)
                e = max(e, b.end_line)
        if e > s:
            add("counter_cluster", s, e)

    # handshake (heuristic)
    hs_keys = {"valid", "ready", "req", "ack"}
    cur: list[_Atomic] = []
    for a in atomics:
        if not any(k in x.lower() for x in a.ids for k in hs_keys):
            if len(cur) >= 2:
                add("handshake", cur[0].start_line, cur[-1].end_line)
            cur = []
            continue
        if not cur:
            cur = [a]
            continue
        if _gap_only(lines, cur[-1].end_line, a.start_line):
            cur.append(a)
        else:
            if len(cur) >= 2:
                add("handshake", cur[0].start_line, cur[-1].end_line)
            cur = [a]
    if len(cur) >= 2:
        add("handshake", cur[0].start_line, cur[-1].end_line)

    # bus_cluster (heuristic)
    bus_keys = {
        "addr",
        "wdata",
        "rdata",
        "cmd",
        "rsp",
        "resp",
        "read",
        "write",
        "icb",
        "axi",
        "apb",
        "ahb",
    }
    cur = []
    for a in atomics:
        if not any(any(k in x.lower() for k in bus_keys) for x in a.ids):
            if len(cur) >= 3:
                add("bus_cluster", cur[0].start_line, cur[-1].end_line)
            cur = []
            continue
        if not cur:
            cur = [a]
            continue
        if _gap_only(lines, cur[-1].end_line, a.start_line):
            cur.append(a)
        else:
            if len(cur) >= 3:
                add("bus_cluster", cur[0].start_line, cur[-1].end_line)
            cur = [a]
    if len(cur) >= 3:
        add("bus_cluster", cur[0].start_line, cur[-1].end_line)

    # cdcsync (heuristic)
    for a in always_blocks:
        if a.subkind != "seq":
            continue
        blk_text = "".join(lines[a.start_line - 1 : a.end_line])
        assigns = re.findall(r"\b([A-Za-z_][A-Za-z0-9_$]*)\s*<=\s*([A-Za-z_][A-Za-z0-9_$]*)\b", blk_text)
        if len(assigns) < 2:
            continue
        pairs = {(l, r) for l, r in assigns}
        ok = False
        for (l1, r1) in pairs:
            for (l2, r2) in pairs:
                if r2 == l1 and (("sync" in l1.lower()) or ("sync" in l2.lower()) or l1.lower().endswith("ff1")):
                    ok = True
                    break
            if ok:
                break
        if ok:
            add("cdcsync", a.start_line, a.end_line)

    return _normalize_groups(groups)


def _find_text_cuts(text: str, line_starts: Sequence[int], prefix: str) -> list[CutBlock]:
    out: list[CutBlock] = []
    counters: dict[str, int] = {
        "begin_end": 0,
        "case": 0,
        "fork": 0,
        "generate": 0,
        "function": 0,
        "task": 0,
        "proc": 0,
    }
    begin_stack: list[int] = []
    case_stack: list[tuple[str, int, int]] = []
    fork_stack: list[int] = []
    gen_stack: list[int] = []
    func_stack: list[tuple[int, int]] = []
    task_stack: list[tuple[int, int]] = []

    for w, s, e in _iter_words(text):
        if w == "begin":
            begin_stack.append(s)
        elif w == "end":
            if begin_stack:
                bs = begin_stack.pop()
                counters["begin_end"] += 1
                head_line = _pos_to_line(line_starts, bs)
                tail_line = _pos_to_line(line_starts, s)
                body_line = None if head_line >= tail_line else head_line + 1
                out.append(
                    CutBlock(
                        block_type="begin_end",
                        block_id=_cut_id(prefix, "begin_end", counters["begin_end"]),
                        span_start_line=head_line,
                        span_end_line=tail_line,
                        begin_before_line=head_line,
                        head_before_line=None,
                        body_before_line=body_line,
                        tail_before_line=tail_line,
                        tail_after_line=None,
                        end_before_line=None,
                        end_after_line=tail_line,
                    )
                )
        elif w in {"case", "casex", "casez"}:
            case_stack.append((w, s, e))
        elif w == "endcase":
            if case_stack:
                open_w, os, oe = case_stack.pop()
                counters["case"] += 1
                head_line = _pos_to_line(line_starts, os)
                tail_line = _pos_to_line(line_starts, s)
                p = _scan_skip(text, oe)
                if p < len(text) and text[p] == "(":
                    close = _scan_balanced(text, p, "(", ")")
                    body_line = _pos_to_line(line_starts, close + 1)
                else:
                    body_line = head_line + 1
                if body_line >= tail_line:
                    body_line = None
                out.append(
                    CutBlock(
                        block_type=open_w,
                        block_id=_cut_id(prefix, "case", counters["case"]),
                        span_start_line=head_line,
                        span_end_line=tail_line,
                        begin_before_line=head_line,
                        head_before_line=None,
                        body_before_line=body_line,
                        tail_before_line=tail_line,
                        tail_after_line=None,
                        end_before_line=None,
                        end_after_line=tail_line,
                    )
                )
        elif w == "fork":
            fork_stack.append(s)
        elif w in {"join", "join_any", "join_none"}:
            if fork_stack:
                fs = fork_stack.pop()
                counters["fork"] += 1
                head_line = _pos_to_line(line_starts, fs)
                tail_line = _pos_to_line(line_starts, s)
                body_line = None if head_line >= tail_line else head_line + 1
                out.append(
                    CutBlock(
                        block_type="fork",
                        block_id=_cut_id(prefix, "fork", counters["fork"]),
                        span_start_line=head_line,
                        span_end_line=tail_line,
                        begin_before_line=head_line,
                        head_before_line=None,
                        body_before_line=body_line,
                        tail_before_line=tail_line,
                        tail_after_line=None,
                        end_before_line=None,
                        end_after_line=tail_line,
                    )
                )
        elif w == "generate":
            gen_stack.append(s)
        elif w == "endgenerate":
            if gen_stack:
                gs = gen_stack.pop()
                counters["generate"] += 1
                head_line = _pos_to_line(line_starts, gs)
                tail_line = _pos_to_line(line_starts, s)
                body_line = None if head_line >= tail_line else head_line + 1
                out.append(
                    CutBlock(
                        block_type="generate",
                        block_id=_cut_id(prefix, "generate", counters["generate"]),
                        span_start_line=head_line,
                        span_end_line=tail_line,
                        begin_before_line=head_line,
                        head_before_line=None,
                        body_before_line=body_line,
                        tail_before_line=tail_line,
                        tail_after_line=None,
                        end_before_line=None,
                        end_after_line=tail_line,
                    )
                )
        elif w == "function":
            func_stack.append((s, e))
        elif w == "endfunction":
            if func_stack:
                fs, fe = func_stack.pop()
                counters["function"] += 1
                head_line = _pos_to_line(line_starts, fs)
                tail_line = _pos_to_line(line_starts, s)
                header_semi = _scan_to_semicolon(text, fe)
                decl_pos = _scan_skip(text, header_semi + 1)
                body_pos = decl_pos
                decl_keywords = {
                    "input",
                    "output",
                    "inout",
                    "integer",
                    "real",
                    "realtime",
                    "time",
                    "reg",
                    "logic",
                    "wire",
                    "event",
                    "parameter",
                    "localparam",
                    "genvar",
                }
                while True:
                    nxt = _read_word(text, body_pos)
                    if nxt is None:
                        break
                    ww, ws, we = nxt
                    if ww.lower() not in decl_keywords:
                        break
                    semi = _scan_to_semicolon(text, ws)
                    body_pos = _scan_skip(text, semi + 1)
                body_line = _pos_to_line(line_starts, body_pos)
                decl_line = _pos_to_line(line_starts, decl_pos)
                head_before_line = decl_line if decl_line < body_line else None
                if body_line >= tail_line:
                    body_line = None
                out.append(
                    CutBlock(
                        block_type="function",
                        block_id=_cut_id(prefix, "function", counters["function"]),
                        span_start_line=head_line,
                        span_end_line=tail_line,
                        begin_before_line=head_line,
                        head_before_line=head_before_line,
                        body_before_line=body_line,
                        tail_before_line=tail_line,
                        tail_after_line=None,
                        end_before_line=None,
                        end_after_line=tail_line,
                    )
                )
        elif w == "task":
            task_stack.append((s, e))
        elif w == "endtask":
            if task_stack:
                ts, te = task_stack.pop()
                counters["task"] += 1
                head_line = _pos_to_line(line_starts, ts)
                tail_line = _pos_to_line(line_starts, s)
                header_semi = _scan_to_semicolon(text, te)
                decl_pos = _scan_skip(text, header_semi + 1)
                body_pos = decl_pos
                decl_keywords = {
                    "input",
                    "output",
                    "inout",
                    "integer",
                    "real",
                    "realtime",
                    "time",
                    "reg",
                    "logic",
                    "wire",
                    "event",
                    "parameter",
                    "localparam",
                    "genvar",
                }
                while True:
                    nxt = _read_word(text, body_pos)
                    if nxt is None:
                        break
                    ww, ws, we = nxt
                    if ww.lower() not in decl_keywords:
                        break
                    semi = _scan_to_semicolon(text, ws)
                    body_pos = _scan_skip(text, semi + 1)
                body_line = _pos_to_line(line_starts, body_pos)
                decl_line = _pos_to_line(line_starts, decl_pos)
                head_before_line = decl_line if decl_line < body_line else None
                if body_line >= tail_line:
                    body_line = None
                out.append(
                    CutBlock(
                        block_type="task",
                        block_id=_cut_id(prefix, "task", counters["task"]),
                        span_start_line=head_line,
                        span_end_line=tail_line,
                        begin_before_line=head_line,
                        head_before_line=head_before_line,
                        body_before_line=body_line,
                        tail_before_line=tail_line,
                        tail_after_line=None,
                        end_before_line=None,
                        end_after_line=tail_line,
                    )
                )
        elif w in {"always", "always_comb", "always_ff", "always_latch", "initial", "final"}:
            counters["proc"] += 1
            head_line = _pos_to_line(line_starts, s)
            body_pos = _scan_event_delay_prefix(text, e)
            body_line = _pos_to_line(line_starts, body_pos)
            end_pos = _scan_stmt_end_pos_text(text, body_pos)
            tail_line = _pos_to_line(line_starts, max(0, end_pos - 1))
            if body_line >= tail_line:
                body_line = None
            tail_after_line = tail_line if body_line is not None else None
            out.append(
                CutBlock(
                    block_type=w,
                    block_id=_cut_id(prefix, "proc", counters["proc"]),
                    span_start_line=head_line,
                    span_end_line=tail_line,
                    begin_before_line=head_line,
                    head_before_line=None,
                    body_before_line=body_line,
                    tail_before_line=None,
                    tail_after_line=tail_after_line,
                    end_before_line=None,
                    end_after_line=tail_line,
                )
            )
    return out


def _scan_event_delay_prefix(text: str, pos: int) -> int:
    p = _scan_skip(text, pos)
    while p < len(text):
        if text[p] == "@":
            p = _scan_skip(text, p + 1)
            if p < len(text) and text[p] == "(":
                p = _scan_balanced(text, p, "(", ")") + 1
            else:
                p = _scan_skip(text, p + 1)
            p = _scan_skip(text, p)
            continue
        if text[p] == "#":
            p = _scan_skip(text, p + 1)
            if p < len(text) and text[p] == "(":
                p = _scan_balanced(text, p, "(", ")") + 1
            else:
                while p < len(text) and not text[p].isspace():
                    if text[p] in {";", "\n"}:
                        break
                    p += 1
            p = _scan_skip(text, p)
            continue
        break
    return p


def _find_assign_cuts(
    tokens: Sequence, prefix: str, text: str, lexposes: Sequence[int], line_starts: Sequence[int]
) -> list[CutBlock]:
    out: list[CutBlock] = []
    counter = 0
    i = 0
    while i < len(tokens):
        if tokens[i].type != "ASSIGN":
            i += 1
            continue
        counter += 1
        head_line = int(tokens[i].lineno)
        semi = _scan_to_semicolon(text, int(tokens[i].lexpos))
        tail_line = _pos_to_line(line_starts, semi)
        out.append(
            CutBlock(
                block_type="assign",
                block_id=_cut_id(prefix, "assign", counter),
                span_start_line=head_line,
                span_end_line=tail_line,
                begin_before_line=head_line,
                head_before_line=None,
                body_before_line=None,
                tail_before_line=None,
                tail_after_line=None,
                end_before_line=None,
                end_after_line=tail_line,
            )
        )
        i = _token_idx_after_pos(lexposes, semi)
    return out


def _find_instantiation_cuts(
    tokens: Sequence, prefix: str, text: str, lexposes: Sequence[int], line_starts: Sequence[int]
) -> list[CutBlock]:
    out: list[CutBlock] = []
    counter = 0
    i = 0
    while i < len(tokens):
        if tokens[i].type != "ID":
            i += 1
            continue
        semi = _try_parse_instantiation_semicolon(text, int(tokens[i].lexpos))
        if semi is None:
            i += 1
            continue
        counter += 1
        head_line = int(tokens[i].lineno)
        tail_line = _pos_to_line(line_starts, semi)
        out.append(
            CutBlock(
                block_type="instantiation",
                block_id=_cut_id(prefix, "inst", counter),
                span_start_line=head_line,
                span_end_line=tail_line,
                begin_before_line=head_line,
                head_before_line=None,
                body_before_line=None,
                tail_before_line=None,
                tail_after_line=None,
                end_before_line=None,
                end_after_line=tail_line,
            )
        )
        i = _token_idx_after_pos(lexposes, semi)
    return out


_PP_DIRECTIVE_RE = re.compile(r"^\s*`(?P<kw>ifdef|ifndef|elsif|else|endif)\b")


def _find_preproc_cuts(prefix: str, relpath: str, lines: Sequence[str]) -> list[CutBlock]:
    out: list[CutBlock] = []
    blk_counter = 0

    @dataclass
    class _PPFrame:
        start_kw: str
        start_ln: int
        cur_kw: str
        cur_ln: int
        branches: list[tuple[str, int, int]]  # (kw, head_ln, tail_ln)

    stack: list[_PPFrame] = []
    in_block_comment = False
    nlines = len(lines) if lines else 1
    for ln, line in enumerate(lines, start=1):
        s = line
        if in_block_comment:
            if "*/" in s:
                in_block_comment = False
            continue
        stripped = s.lstrip()
        if stripped.startswith("/*"):
            if "*/" not in stripped:
                in_block_comment = True
            continue
        if stripped.startswith("//"):
            continue
        m = _PP_DIRECTIVE_RE.match(s)
        if not m:
            continue
        kw = m.group("kw")
        if kw in {"ifdef", "ifndef"}:
            stack.append(_PPFrame(start_kw=kw, start_ln=ln, cur_kw=kw, cur_ln=ln, branches=[]))
        elif kw in {"elsif", "else"}:
            if stack:
                f = stack[-1]
                tail_ln = max(f.cur_ln, ln - 1)
                f.branches.append((f.cur_kw, f.cur_ln, tail_ln))
                f.cur_kw = kw
                f.cur_ln = ln
        elif kw == "endif":
            if stack:
                f = stack.pop()
                tail_ln = max(f.cur_ln, ln - 1)
                f.branches.append((f.cur_kw, f.cur_ln, tail_ln))
                blk_counter += 1
                parent_id = _cut_id(prefix, "pp_blk", blk_counter)
                out.append(
                    CutBlock(
                        block_type=f"pp_{f.start_kw}_block",
                        block_id=parent_id,
                        span_start_line=f.start_ln,
                        span_end_line=ln,
                        begin_before_line=f.start_ln,
                        head_before_line=None,
                        body_before_line=(None if f.start_ln >= ln else min(f.start_ln + 1, nlines)),
                        tail_before_line=ln,
                        tail_after_line=None,
                        end_before_line=None,
                        end_after_line=ln,
                    )
                )
                if len(f.branches) > 1:
                    for idx, (bkw, bhead, btail) in enumerate(f.branches, start=1):
                        tl = max(bhead, min(btail, nlines))
                        bl = None if bhead >= tl else min(bhead + 1, tl)
                        out.append(
                            CutBlock(
                                block_type=f"pp_{bkw}_branch",
                                block_id=f"{parent_id}:br:{idx:06d}",
                                span_start_line=bhead,
                                span_end_line=tl,
                                begin_before_line=bhead,
                                head_before_line=None,
                                body_before_line=bl,
                                tail_before_line=None,
                                tail_after_line=tl,
                                end_before_line=None,
                                end_after_line=tl,
                            )
                        )
    return out


def _collect_cut_insertions(
    cuts: Sequence[CutBlock], relpath: str, nlines: int
) -> tuple[dict[int, list[tuple[int, str]]], dict[int, list[tuple[int, str]]]]:
    before: dict[int, list[tuple[int, str]]] = {}
    after: dict[int, list[tuple[int, str]]] = {}
    for c in cuts:
        s = max(1, min(c.span_start_line, nlines))
        e = max(1, min(c.span_end_line, nlines))
        span = max(0, e - s)
        meta = f"type={c.block_type} id={c.block_id} file={relpath} lines={s}-{e}"

        bb = max(1, min(c.begin_before_line, nlines))
        before.setdefault(bb, []).append((-span, f"//__RB_CUT_BEGIN__ {meta}\n"))

        if c.head_before_line is not None:
            hl = max(1, min(c.head_before_line, nlines))
            if s < hl <= e:
                before.setdefault(hl, []).append((-span, f"//__RB_CUT_HEAD__ {meta}\n"))

        if c.body_before_line is not None:
            bl = max(1, min(c.body_before_line, nlines))
            if s < bl <= e:
                before.setdefault(bl, []).append((-span, f"//__RB_CUT_BODY__ {meta}\n"))

        if c.tail_before_line is not None:
            tlb = max(1, min(c.tail_before_line, nlines))
            if s <= tlb <= e:
                before.setdefault(tlb, []).append((-span, f"//__RB_CUT_TAIL__ {meta}\n"))

        if c.tail_after_line is not None:
            tla = max(1, min(c.tail_after_line, nlines))
            if s <= tla <= e:
                after.setdefault(tla, []).append((span, f"//__RB_CUT_TAIL__ {meta}\n"))

        if c.end_before_line is not None:
            eb = max(1, min(c.end_before_line, nlines))
            before.setdefault(eb, []).append((-span, f"//__RB_CUT_END__ {meta}\n"))

        if c.end_after_line is not None:
            ea = max(1, min(c.end_after_line, nlines))
            after.setdefault(ea, []).append((span, f"//__RB_CUT_END__ {meta}\n"))
    return before, after


def _collect_group_insertions(
    groups: Sequence[CutGroup], relpath: str, nlines: int
) -> tuple[dict[int, list[tuple[int, str]]], dict[int, list[tuple[int, str]]]]:
    before: dict[int, list[tuple[int, str]]] = {}
    after: dict[int, list[tuple[int, str]]] = {}
    bias = 1_000_000
    for g in groups:
        s = max(1, min(g.start_line, nlines))
        e = max(1, min(g.end_line, nlines))
        span = max(0, e - s)
        meta = f"type={g.group_type} id={g.group_id} file={relpath} lines={s}-{e}"
        before.setdefault(s, []).append((-(span + bias), f"//__RB_CUT_GROUP_BEGIN__ {meta}\n"))
        after.setdefault(e, []).append(((span + bias), f"//__RB_CUT_GROUP_END__ {meta}\n"))
    return before, after


def _render_with_insertions(
    lines: list[str],
    before: dict[int, list[tuple[int, str]]],
    after: dict[int, list[tuple[int, str]]],
    inline: dict[int, list[str]],
) -> list[str]:
    for k in list(before.keys()):
        before[k].sort(key=lambda x: x[0])
    for k in list(after.keys()):
        after[k].sort(key=lambda x: x[0])
    out: list[str] = []
    for i, line in enumerate(lines, start=1):
        if i in before:
            out.extend(t[1] for t in before[i])
        if i in inline:
            nl = "\n" if line.endswith("\n") else ""
            content = line[:-1] if nl else line
            for m in inline[i]:
                if content and not content.endswith((" ", "\t")):
                    content += " "
                content += m
            out.append(content + nl)
        else:
            out.append(line)
        if i in after:
            out.extend(t[1] for t in after[i])
    return out


def _should_exclude_file(path: Path) -> bool:
    p = str(path).lower()
    parts = [x.lower() for x in path.parts]
    for seg in parts:
        if seg in {"tb", "testbench", "tests", "test", "sim", "simulation", "bench", "verify", "verification"}:
            return True
    name = path.name.lower()
    if re.search(r"(^|[_\-.])(tb|testbench)([_\-.]|$)", name):
        return True
    if "testbench" in p or "tb" in parts:
        return True
    return False


def _iter_verilog_files(base_dir: Path, targets: Sequence[str]) -> Iterator[Path]:
    for t in targets:
        d = base_dir / t
        if not d.exists():
            continue
        for p in d.rglob("*.v"):
            if p.is_file() and not _should_exclude_file(p):
                yield p


def annotate_file(src_path: Path, out_path: Path, base_dir: Path) -> None:
    text = src_path.read_text(encoding="utf-8", errors="ignore")
    tokens = _tokenize(text, str(src_path))
    lexposes = [int(t.lexpos) for t in tokens]
    line_starts = _build_line_starts(text)
    relpath = str(src_path.relative_to(base_dir))
    unit_prefix = relpath.replace("\\", "/")
    lines = text.splitlines(keepends=True)
    nlines = len(lines) if lines else 1

    cuts: list[CutBlock] = []
    cuts.extend(_find_text_cuts(text, line_starts, unit_prefix))
    cuts.extend(_find_assign_cuts(tokens, unit_prefix, text, lexposes, line_starts))
    cuts.extend(_find_instantiation_cuts(tokens, unit_prefix, text, lexposes, line_starts))
    cuts.extend(_find_preproc_cuts(unit_prefix, relpath, lines))

    groups = _find_groups(unit_prefix, relpath, lines, cuts)

    cut_before, cut_after = _collect_cut_insertions(cuts, relpath, nlines)
    group_before, group_after = _collect_group_insertions(groups, relpath, nlines)
    merged_before: dict[int, list[tuple[int, str]]] = {}
    merged_after: dict[int, list[tuple[int, str]]] = {}
    for k, v in cut_before.items():
        merged_before.setdefault(k, []).extend(v)
    for k, v in cut_after.items():
        merged_after.setdefault(k, []).extend(v)
    for k, v in group_before.items():
        merged_before.setdefault(k, []).extend(v)
    for k, v in group_after.items():
        merged_after.setdefault(k, []).extend(v)

    annotated = _render_with_insertions(lines, merged_before, merged_after, {})
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text("".join(annotated), encoding="utf-8")


def main() -> int:
    base_dir = BASE_DIR.resolve()
    out_dir = base_dir / OUT_DIRNAME
    targets = [t for t in TARGET_DIRS if (base_dir / t).exists()]
    if not targets:
        raise SystemExit("no targets found")

    files = sorted(set(_iter_verilog_files(base_dir, targets)))
    failed = 0
    for f in files:
        rel = f.relative_to(base_dir)
        try:
            annotate_file(f, out_dir / rel, base_dir)
        except Exception as e:
            failed += 1
            print(f"[FAIL] {rel}: {e}")
    print(f"annotated {len(files) - failed}/{len(files)} files into {out_dir}")
    return 0 if failed == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())
