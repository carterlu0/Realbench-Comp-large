#!/usr/bin/env python3
"""
Run one-shot verification directly on DUT files.

Supported DUT sources:
  - original RTL under sdc/aes/e203_hbirdv2
  - masked completion dataset files under masked_units_1hole_weight_1

Scoring logic follows run_verify.py:
  - syntax: testbench compile/sim invocation success
  - function: mismatch-free simulation output
"""

import json
import math
import os
import re
import shutil
import subprocess
import tempfile
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from collections import Counter
from glob import glob
from typing import Dict, List, Optional, Tuple

from benchmark_info import benchmark_info, system_info


BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DEFAULT_CONDA_ENV_NAME = "realbench"
# =========================
# Explicit in-script config
# =========================
# Change these values directly in this file if needed.
CONFIG_BENCHMARK_PATH = str(Path(__file__).resolve().parents[1])
CONFIG_RTL_SOURCE_MODE = "masked"  # one of: original, masked
CONFIG_MASKED_UNITS_DIR = str(Path(__file__).resolve().parents[1] / "Realbench-Comp_weighted_001")
CONFIG_MASKED_SELECTION = "all"  # one of: all, first
CONFIG_ALLOW_MISSING_MASKED_TASKS = True  # when True, skip benchmark tasks missing from a masked dataset
CONFIG_TASK_LEVEL = "module"  # one of: module, system, all
CONFIG_STAGE = "stage2"  # one of: stage1, stage2
CONFIG_MAX_TASKS = None  # set int for smoke run, or None for full run
CONFIG_TIMEOUT_SEC = 300
CONFIG_OUTPUT_JSON = str(Path(__file__).resolve().parents[1] / "Realbench-Comp_weighted_001_report.json")
CONFIG_SEGFAULT_RETRIES = 6
CONFIG_ENABLE_DATASET_POLICY = True
CONFIG_CONDA_ENV_NAME = DEFAULT_CONDA_ENV_NAME
CONFIG_TOTAL_WORKERS = 0
CONFIG_VERILATOR_JOBS = "auto"
CONFIG_ENABLE_TRACE = "0"
CONFIG_ENABLE_COVERAGE = "0"

# Explicit make-time build environment for reproducibility.
# These values are passed directly to `make all` via subprocess env.
CONFIG_MAKE_ENV = {
    "MAKEFLAGS": "-e",
    "CXX": "g++-10",
    "CFG_CXXFLAGS_STD": "-std=gnu++20",
    "CFG_CXXFLAGS_COROUTINES": "-fcoroutines",
    "OPT_FAST": "-O0",
    "OPT_SLOW": "-O0",
    "OPT_GLOBAL": "-O0",
    "ENABLE_TRACE": CONFIG_ENABLE_TRACE,
    "ENABLE_COVERAGE": CONFIG_ENABLE_COVERAGE,
}

# Per-task make-time overrides (kept minimal to avoid global side effects).
TASK_MAKE_ENV_OVERRIDES = {
    "sd_clock_divider": {"CXXFLAGS": "-DVL_URANDOM_RANGE_Q=VL_URANDOM_RANGE_I"},
    "aes_key_expand_128": {"OPT_FAST": "-Os", "OPT_SLOW": "-Os", "OPT_GLOBAL": "-Os"},
    "aes_inv_cipher_top": {"OPT_FAST": "-O1", "OPT_SLOW": "-O1", "OPT_GLOBAL": "-O1"},
    "e203_core": {"OPT_FAST": "-O1", "OPT_SLOW": "-O1", "OPT_GLOBAL": "-O1"},
    "e203_exu_nice": {"OPT_FAST": "-O1", "OPT_SLOW": "-O1", "OPT_GLOBAL": "-O1"},
}

# Some benchmark entries have trimmed stubs in one location but complete RTL in another.
# Keep source files untouched, and only redirect read-path for verification input.
TASK_RTL_PATH_OVERRIDES = {
    "e203_exu_alu_muldiv": "e203_hbirdv2/e203_exu_alu_muldiv/verification/e203_exu_alu_muldiv_top.sv",
}

STAGE2_TASK_MACROS = {
    "e203_extend_csr": ["E203_HAS_CSR_NICE"],
    "e203_srams": ["E203_HtAS_ITCM"],
}

MASK_FILE_RE = re.compile(r"^(?P<task>[A-Za-z0-9_]+)__mask(?P<mask_id>\d+)\.v$")


def copy_verification_template(template_dir: str, temp_dir: str) -> None:
    for name in os.listdir(template_dir):
        src = os.path.join(template_dir, name)
        if not os.path.isfile(src):
            continue
        shutil.copy2(src, os.path.join(temp_dir, name))


def get_conda_run_prefix() -> List[str]:
    conda_exe = shutil.which("conda")
    if not conda_exe:
        return []
    return [conda_exe, "run", "-n", CONFIG_CONDA_ENV_NAME]


def full_task_display(system_name: str, task_display: str) -> str:
    return f"{system_name}/{task_display}"


def get_dir_from_system(system_name: str) -> str:
    for directory in ("sdc", "aes", "e203_hbirdv2"):
        if directory[:4] in system_name:
            return directory
    raise ValueError(f"Cannot infer source directory for system: {system_name}")


def load_code(filepath: str) -> str:
    with open(filepath, "r", encoding="utf-8") as f:
        return f.read()


def build_verification_env(make_env: Optional[Dict[str, str]] = None) -> Dict[str, str]:
    env = os.environ.copy()
    env.pop("VERILATOR_ROOT", None)
    if make_env:
        env.update(make_env)

    configured_jobs = str(env.get("VERILATOR_JOBS", CONFIG_VERILATOR_JOBS)).strip() or CONFIG_VERILATOR_JOBS
    _, resolved_jobs, _ = resolve_parallelism(CONFIG_TOTAL_WORKERS, configured_jobs)
    env["VERILATOR_JOBS"] = str(resolved_jobs)
    return env


def resolve_yosys_bin(configured_yosys_bin: str) -> str:
    if os.path.isabs(configured_yosys_bin):
        if not os.path.isfile(configured_yosys_bin):
            raise FileNotFoundError(f"Configured yosys binary not found: {configured_yosys_bin}")
        if not os.access(configured_yosys_bin, os.X_OK):
            raise PermissionError(f"Configured yosys binary is not executable: {configured_yosys_bin}")
        return configured_yosys_bin

    resolved = shutil.which(configured_yosys_bin)
    if not resolved:
        raise FileNotFoundError(f"Unable to resolve yosys binary from PATH: {configured_yosys_bin}")
    return resolved


def detect_host_resources() -> Tuple[int, int]:
    cpu_count = os.cpu_count() or 1
    mem_total_bytes = 0
    meminfo_path = "/proc/meminfo"
    try:
        with open(meminfo_path, "r", encoding="utf-8") as f:
            for line in f:
                if line.startswith("MemTotal:"):
                    parts = line.split()
                    if len(parts) >= 2:
                        mem_total_bytes = int(parts[1]) * 1024
                    break
    except OSError:
        mem_total_bytes = 0
    return cpu_count, mem_total_bytes


def resolve_parallelism(
    configured_total_workers: int,
    configured_verilator_jobs: str,
) -> Tuple[int, str, Dict[str, int]]:
    cpu_count, mem_total_bytes = detect_host_resources()
    mem_total_gb = mem_total_bytes / float(1024 ** 3) if mem_total_bytes else 0.0

    if configured_total_workers > 0:
        total_workers = configured_total_workers
    else:
        cpu_budget = max(1, cpu_count // 6)
        mem_budget = max(1, int(mem_total_gb // 24)) if mem_total_gb else cpu_budget
        total_workers = max(1, min(cpu_budget, mem_budget, 24))

    if configured_verilator_jobs != "auto":
        verilator_jobs = configured_verilator_jobs
        verilator_jobs_int = max(1, int(configured_verilator_jobs))
    else:
        jobs_by_cpu = max(1, cpu_count // total_workers)
        jobs_by_mem = max(1, int(mem_total_gb // max(total_workers, 1) // 3)) if mem_total_gb else jobs_by_cpu
        verilator_jobs_int = max(1, min(jobs_by_cpu, jobs_by_mem, 8))
        verilator_jobs = str(verilator_jobs_int)

    diagnostics = {
        "cpu_count": cpu_count,
        "mem_total_gb": int(math.floor(mem_total_gb)) if mem_total_gb else 0,
        "verilator_jobs_int": verilator_jobs_int,
    }
    return total_workers, verilator_jobs, diagnostics


def load_mask_metadata(meta_path: Optional[str]) -> Dict[str, str]:
    if not meta_path or not os.path.exists(meta_path):
        return {}
    try:
        with open(meta_path, "r", encoding="utf-8") as f:
            meta = json.load(f)
    except Exception:
        return {}

    masked = meta.get("masked", [])
    first = masked[0] if masked else {}
    return {
        "masked_kind": str(first.get("kind", "")),
        "masked_type": str(first.get("type", "")),
        "masked_span_lines": str(first.get("span_lines", "")),
        "variant_id": str(meta.get("variant_id", "")),
        "variants_for_source_file": str(meta.get("variants_for_source_file", "")),
    }


def extract_mask_metadata(meta_path: Optional[str]) -> Dict[str, str]:
    return load_mask_metadata(meta_path)


def load_json_file(path: str) -> Dict[str, object]:
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def load_dataset_policy(masked_units_dir: str, enabled: bool) -> Dict[str, object]:
    policy = {
        "enabled": False,
        "dataset_dir": masked_units_dir,
        "excluded_path": None,
        "excluded_task_displays": set(),
        "excluded_task_pairs": set(),
        "excluded_entries": [],
    }
    if not enabled:
        return policy

    excluded_path = os.path.join(masked_units_dir, "excluded_forever.json")
    if not os.path.exists(excluded_path):
        return policy

    excluded_payload = load_json_file(excluded_path)
    excluded_entries = list(excluded_payload.get("entries", []))
    policy["excluded_path"] = excluded_path

    policy["enabled"] = True
    policy["excluded_entries"] = excluded_entries
    policy["excluded_task_displays"] = {
        str(entry.get("task_display", "")) for entry in excluded_entries if entry.get("task_display")
    }
    policy["excluded_task_pairs"] = {
        (str(entry.get("system", "")), str(entry.get("task", "")))
        for entry in excluded_entries
        if entry.get("system") and entry.get("task") and not entry.get("variant")
    }
    return policy


def apply_dataset_policy_to_tasks(
    tasks: List[Dict[str, object]], dataset_policy: Dict[str, object]
) -> Tuple[List[Dict[str, object]], List[Dict[str, object]]]:
    if not dataset_policy.get("enabled"):
        return tasks, []
    excluded_task_displays = set(dataset_policy.get("excluded_task_displays", set()))
    excluded_task_pairs = set(dataset_policy.get("excluded_task_pairs", set()))
    filtered: List[Dict[str, object]] = []
    skipped: List[Dict[str, object]] = []
    for task in tasks:
        full_display = full_task_display(str(task["system"]), task_display_name(task))
        task_pair = (str(task["system"]), str(task["task"]))
        if full_display in excluded_task_displays or task_pair in excluded_task_pairs:
            skipped.append(
                {
                    "system": task["system"],
                    "task": task["task"],
                    "task_display": full_display,
                    "variant": task.get("variant"),
                    "reason": "excluded_forever",
                }
            )
            continue
        filtered.append(task)
    return filtered, skipped


def run_testbench_once(
    code: str,
    template_dir: str,
    top_filename: str,
    make_env: Optional[Dict[str, str]] = None,
    segfault_retries: int = 0,
    timeout_sec: int = 300,
) -> Tuple[int, int, str, str]:
    """
    Returns (syntax, function, syntax_info, function_info), aligned with run_verify.py.
    """
    with tempfile.TemporaryDirectory() as temp_dir:
        copy_verification_template(template_dir, temp_dir)

        top_filepath = os.path.join(temp_dir, top_filename)
        if os.path.exists(top_filepath):
            os.remove(top_filepath)

        with open(top_filepath, "w", encoding="utf-8") as f:
            f.write(code)

        env = build_verification_env(make_env)

        ret = None
        attempts = segfault_retries + 1
        for attempt in range(1, attempts + 1):
            try:
                ret = subprocess.run(
                    ["make", "all"],
                    cwd=temp_dir,
                    timeout=timeout_sec,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE,
                    text=True,
                    env=env,
                )
            except subprocess.TimeoutExpired:
                return 0, 0, "TIMEOUT\n", ""

            if ret.returncode == 0:
                break
            if "Segmentation fault" not in (ret.stderr or ""):
                break
            if attempt < attempts:
                subprocess.run(
                    ["rm", "-rf", "obj_dir", "logs", "coverage.dat", "wave.vcd"],
                    cwd=temp_dir,
                    check=False,
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                )

        syntax_info = ""
        function_info = ""

        if ret.stderr:
            for line in ret.stderr.splitlines():
                if line.startswith("%Error") or line.startswith("%Warning"):
                    syntax_info += line + "\n"

            if not syntax_info.strip():
                raw_err = ret.stderr.strip()
                raw_out = ret.stdout.strip()
                syntax_info = raw_err if raw_err else raw_out
                if not syntax_info:
                    syntax_info = f"make all failed (returncode={ret.returncode})"
                syntax_info += "\n"
            return 0, 0, syntax_info, function_info

        for line in ret.stdout.splitlines():
            if "Hint: Output" in line and "no mismatches" in line:
                continue
            if "Hint: Output" in line and "mismatches" in line:
                function_info += line[6:] + "\n"

        syntax = 1
        function = 1 if function_info == "" else 0
        return syntax, function, syntax_info, function_info


def iter_module_tasks(
    benchmark_path: str,
    rtl_source_mode: str,
    masked_units_dir: str,
    masked_selection: str,
    allow_missing_masked_tasks: bool = False,
) -> List[Dict[str, object]]:
    tasks: List[Dict[str, object]] = []
    skipped_missing_tasks: List[Tuple[str, str, str]] = []
    for system_name, modules in benchmark_info.items():
        for module_name in modules.keys():
            template_dir = os.path.join(benchmark_path, system_name, module_name, "verification")

            if rtl_source_mode == "original":
                override_path = TASK_RTL_PATH_OVERRIDES.get(module_name)
                if override_path:
                    rtl_path = os.path.join(benchmark_path, override_path)
                else:
                    rtl_path = os.path.join(
                        benchmark_path, system_name, module_name, f"{module_name}.v"
                    )
                tasks.append(
                    {
                        "level": "module",
                        "system": system_name,
                        "task": module_name,
                        "rtl_path": rtl_path,
                        "template_dir": template_dir,
                        "top_filename": f"{module_name}_top.sv",
                        "variant": None,
                        "meta_path": None,
                    }
                )
                continue

            masked_task_dir = os.path.join(masked_units_dir, system_name, module_name)
            pattern = os.path.join(masked_task_dir, f"{module_name}__mask*.v")
            masked_files = sorted(glob(pattern))
            if not masked_files:
                if allow_missing_masked_tasks:
                    skipped_missing_tasks.append((system_name, module_name, pattern))
                    continue
                raise FileNotFoundError(
                    f"No masked DUT files found for {system_name}/{module_name} (pattern: {pattern})"
                )
            if masked_selection == "first":
                masked_files = masked_files[:1]

            for rtl_path in masked_files:
                filename = os.path.basename(rtl_path)
                match = MASK_FILE_RE.match(filename)
                variant = f"mask{match.group('mask_id')}" if match else None
                tasks.append(
                    {
                        "level": "module",
                        "system": system_name,
                        "task": module_name,
                        "rtl_path": rtl_path,
                        "template_dir": template_dir,
                        "top_filename": f"{module_name}_top.sv",
                        "variant": variant,
                        "meta_path": rtl_path + ".json",
                    }
                )

    if skipped_missing_tasks:
        preview = ", ".join(f"{s}/{m}" for s, m, _ in skipped_missing_tasks[:10])
        print(
            f"Skipped {len(skipped_missing_tasks)} masked benchmark tasks with no DUT files"
            f" because CONFIG_ALLOW_MISSING_MASKED_TASKS=True: {preview}"
        )
        if len(skipped_missing_tasks) > 10:
            print(f"... and {len(skipped_missing_tasks) - 10} more missing tasks")

    return tasks


def iter_system_tasks(benchmark_path: str) -> List[Dict[str, object]]:
    tasks: List[Dict[str, object]] = []
    for system_name in system_info.keys():
        src_dir = get_dir_from_system(system_name)
        rtl_path = os.path.join(benchmark_path, src_dir, system_name, f"{system_name}.v")
        template_dir = os.path.join(benchmark_path, "system", system_name)
        tasks.append(
            {
                "level": "system",
                "system": src_dir,
                "task": system_name,
                "rtl_path": rtl_path,
                "template_dir": template_dir,
                "top_filename": f"{system_name}_top.sv",
                "variant": None,
                "meta_path": None,
            }
        )
    return tasks


def validate_paths(task: Dict[str, object]) -> None:
    rtl_path = str(task["rtl_path"])
    template_dir = str(task["template_dir"])
    if not os.path.exists(rtl_path):
        raise FileNotFoundError(f"Missing RTL file: {rtl_path}")
    if not os.path.isdir(template_dir):
        raise FileNotFoundError(f"Missing verification template directory: {template_dir}")


def format_percent(numerator: int, denominator: int) -> float:
    if denominator == 0:
        return 0.0
    return (numerator / denominator) * 100.0


def apply_stage_macros(code: str, task_name: str, stage: str) -> Tuple[str, List[str]]:
    if stage != "stage2":
        return code, []
    macros = STAGE2_TASK_MACROS.get(task_name, [])
    if not macros:
        return code, []
    prefix = "\n".join(f"`define {macro}" for macro in macros) + "\n"
    return prefix + code, macros


def summarize_masked_dataset(masked_units_dir: str) -> Dict[str, object]:
    all_v = sorted(glob(os.path.join(masked_units_dir, "**", "*.v"), recursive=True))
    benchmark_tasks = {
        (system_name, module_name)
        for system_name, modules in benchmark_info.items()
        for module_name in modules.keys()
    }

    aligned_per_task: Counter[Tuple[str, str]] = Counter()
    auxiliary_per_dir: Counter[Tuple[str, str]] = Counter()

    for path in all_v:
        rel = os.path.relpath(path, masked_units_dir)
        parts = rel.split(os.sep)
        if len(parts) < 3:
            continue
        system_name, module_dir = parts[0], parts[1]
        filename = os.path.basename(path)
        match = MASK_FILE_RE.match(filename)
        masked_task_name = match.group("task") if match else None
        aligned = (system_name, module_dir) in benchmark_tasks and masked_task_name == module_dir
        if aligned:
            aligned_per_task[(system_name, module_dir)] += 1
        else:
            auxiliary_per_dir[(system_name, module_dir)] += 1

    aligned_variant_count_distribution = Counter(aligned_per_task.values())
    aligned_file_count = sum(aligned_per_task.values())
    auxiliary_file_count = sum(auxiliary_per_dir.values())
    missing_benchmark_tasks = sorted(benchmark_tasks - set(aligned_per_task.keys()))

    return {
        "total_v_files": len(all_v),
        "benchmark_task_count": len(benchmark_tasks),
        "aligned_mask_file_count": aligned_file_count,
        "aligned_task_count": len(aligned_per_task),
        "aligned_variant_count_distribution": dict(aligned_variant_count_distribution),
        "missing_benchmark_task_count": len(missing_benchmark_tasks),
        "missing_benchmark_tasks": [
            {"system": system_name, "task": task_name}
            for system_name, task_name in missing_benchmark_tasks
        ],
        "auxiliary_file_count": auxiliary_file_count,
        "auxiliary_top_dirs": [
            {"system": k[0], "module_dir": k[1], "count": v}
            for k, v in auxiliary_per_dir.most_common(10)
        ],
    }


def task_display_name(task: Dict[str, object]) -> str:
    variant = task.get("variant")
    if variant:
        return f"{task['task']}[{variant}]"
    return str(task["task"])


def run_single_task(
    idx: int,
    total_tasks: int,
    task: Dict[str, object],
    stage: str,
    make_env: Dict[str, str],
    segfault_retries: int,
    timeout_sec: int,
    dataset_policy: Dict[str, object],
) -> Dict[str, object]:
    task_name = str(task["task"])
    task_name_for_log = task_display_name(task)

    code = load_code(str(task["rtl_path"]))
    code, injected_macros = apply_stage_macros(code, task_name, stage)

    task_make_env = dict(make_env)
    task_make_env.update(TASK_MAKE_ENV_OVERRIDES.get(task_name, {}))

    syntax, function, syntax_info, function_info = run_testbench_once(
        code=code,
        template_dir=str(task["template_dir"]),
        top_filename=str(task["top_filename"]),
        make_env=task_make_env,
        segfault_retries=segfault_retries,
        timeout_sec=timeout_sec,
    )

    result: Dict[str, object] = {
        "index": idx,
        "level": task["level"],
        "system": task["system"],
        "task": task_name,
        "task_display": task_name_for_log,
        "rtl_path": task["rtl_path"],
        "stage": stage,
        "rtl_source_mode": task.get("rtl_source_mode", "masked"),
        "variant": task.get("variant"),
        "meta_path": task.get("meta_path"),
        "injected_macros": injected_macros,
        "syntax": syntax,
        "function": function,
        "syntax_info": syntax_info,
        "function_info": function_info,
    }
    result["full_task_display"] = full_task_display(str(task["system"]), task_name_for_log)
    result["effective_function"] = function
    result["final_decision"] = "success" if syntax == 1 and function == 1 else "failure"
    if task.get("meta_path"):
        result["mask_meta"] = load_mask_metadata(str(task["meta_path"]))

    if injected_macros:
        print(
            f"[{idx:>3}/{total_tasks}] macro-inject {task_name_for_log}: "
            + ", ".join(injected_macros)
        )
    if task_name in TASK_MAKE_ENV_OVERRIDES:
        print(
            f"[{idx:>3}/{total_tasks}] make-env override {task_name_for_log}: "
            + ", ".join(f"{k}={v}" for k, v in TASK_MAKE_ENV_OVERRIDES[task_name].items())
        )
    print(f"[{idx:>3}/{total_tasks}] {task_name_for_log}: syntax={syntax}, function={function}")
    return result


def main() -> None:
    benchmark_path = os.path.abspath(CONFIG_BENCHMARK_PATH)
    rtl_source_mode = CONFIG_RTL_SOURCE_MODE
    masked_units_dir = os.path.abspath(CONFIG_MASKED_UNITS_DIR)
    masked_selection = CONFIG_MASKED_SELECTION
    allow_missing_masked_tasks = CONFIG_ALLOW_MISSING_MASKED_TASKS
    task_level = CONFIG_TASK_LEVEL
    stage = CONFIG_STAGE
    max_tasks = CONFIG_MAX_TASKS
    timeout_sec = CONFIG_TIMEOUT_SEC
    output_json = CONFIG_OUTPUT_JSON
    total_workers, resolved_verilator_jobs, parallelism_diag = resolve_parallelism(
        CONFIG_TOTAL_WORKERS,
        CONFIG_VERILATOR_JOBS,
    )
    make_env = {k: str(v) for k, v in CONFIG_MAKE_ENV.items()}
    make_env["VERILATOR_JOBS"] = resolved_verilator_jobs
    segfault_retries = CONFIG_SEGFAULT_RETRIES
    enable_dataset_policy = CONFIG_ENABLE_DATASET_POLICY

    if rtl_source_mode not in ("original", "masked"):
        raise ValueError(
            f"Invalid CONFIG_RTL_SOURCE_MODE={rtl_source_mode!r}, expected original/masked"
        )
    if masked_selection not in ("all", "first"):
        raise ValueError(
            f"Invalid CONFIG_MASKED_SELECTION={masked_selection!r}, expected all/first"
        )
    if not isinstance(allow_missing_masked_tasks, bool):
        raise ValueError(
            "Invalid CONFIG_ALLOW_MISSING_MASKED_TASKS="
            f"{allow_missing_masked_tasks!r}, expected bool"
        )
    if task_level not in ("module", "system", "all"):
        raise ValueError(
            f"Invalid CONFIG_TASK_LEVEL={task_level!r}, expected module/system/all"
        )
    if stage not in ("stage1", "stage2"):
        raise ValueError(
            f"Invalid CONFIG_STAGE={stage!r}, expected stage1/stage2"
        )
    if not isinstance(CONFIG_TOTAL_WORKERS, int) or CONFIG_TOTAL_WORKERS < 0:
        raise ValueError(
            f"Invalid CONFIG_TOTAL_WORKERS={CONFIG_TOTAL_WORKERS!r}, expected int >= 0"
        )
    if CONFIG_VERILATOR_JOBS != "auto":
        try:
            if int(CONFIG_VERILATOR_JOBS) < 1:
                raise ValueError
        except ValueError as exc:
            raise ValueError(
                f"Invalid CONFIG_VERILATOR_JOBS={CONFIG_VERILATOR_JOBS!r}, expected 'auto' or int >= 1"
            ) from exc
    if rtl_source_mode == "masked" and task_level in ("system", "all"):
        raise ValueError(
            "masked source mode currently supports CONFIG_TASK_LEVEL='module' only."
        )

    tasks: List[Dict[str, object]] = []
    if task_level in ("module", "all"):
        tasks.extend(
            iter_module_tasks(
                benchmark_path=benchmark_path,
                rtl_source_mode=rtl_source_mode,
                masked_units_dir=masked_units_dir,
                masked_selection=masked_selection,
                allow_missing_masked_tasks=allow_missing_masked_tasks,
            )
        )
    if task_level in ("system", "all"):
        tasks.extend(iter_system_tasks(benchmark_path))

    dataset_policy = load_dataset_policy(masked_units_dir, enable_dataset_policy and rtl_source_mode == "masked")
    skipped_by_dataset_policy: List[Dict[str, object]] = []
    if rtl_source_mode == "masked" and dataset_policy.get("enabled"):
        tasks, skipped_by_dataset_policy = apply_dataset_policy_to_tasks(tasks, dataset_policy)

    if max_tasks is not None:
        tasks = tasks[: max_tasks]

    if not tasks:
        raise RuntimeError("No tasks found to verify.")

    for task in tasks:
        validate_paths(task)

    dataset_summary: Optional[Dict[str, object]] = None
    print(
        "Start one-shot verification: "
        f"stage={stage}, task_level={task_level}, rtl_source_mode={rtl_source_mode}, total_tasks={len(tasks)}"
    )
    if rtl_source_mode == "masked":
        dataset_summary = summarize_masked_dataset(masked_units_dir)
        print("Masked dataset summary:")
        print(f"  path={masked_units_dir}")
        print(f"  total_v_files={dataset_summary['total_v_files']}")
        print(f"  benchmark_task_count={dataset_summary['benchmark_task_count']}")
        print(f"  aligned_mask_file_count={dataset_summary['aligned_mask_file_count']}")
        print(f"  aligned_task_count={dataset_summary['aligned_task_count']}")
        print(
            f"  missing_benchmark_task_count={dataset_summary['missing_benchmark_task_count']}"
        )
        print(
            "  aligned_variant_count_distribution="
            f"{dataset_summary['aligned_variant_count_distribution']}"
        )
        print(f"  auxiliary_file_count={dataset_summary['auxiliary_file_count']}")
        top_dirs = dataset_summary.get("auxiliary_top_dirs", [])
        if top_dirs:
            print("  auxiliary_top_dirs:")
            for row in top_dirs:
                print(f"    - {row['system']}/{row['module_dir']}: {row['count']}")
        if dataset_policy.get("enabled"):
            print("Dataset policy:")
            print(f"  excluded_path={dataset_policy.get('excluded_path')}")
            print(f"  excluded_forever_count={len(dataset_policy.get('excluded_entries', []))}")
            if skipped_by_dataset_policy:
                print(f"  skipped_by_dataset_policy_count={len(skipped_by_dataset_policy)}")

    print("Make environment:")
    for key in sorted(make_env.keys()):
        print(f"  {key}={make_env[key]}")
    print("Host resources:")
    print(f"  cpu_count={parallelism_diag['cpu_count']}")
    print(f"  mem_total_gb={parallelism_diag['mem_total_gb']}")
    print(f"Total workers: {total_workers}")
    print(f"Resolved VERILATOR_JOBS: {parallelism_diag['verilator_jobs_int']}")
    print(f"Segfault retries: {segfault_retries}")

    start_ts = time.time()
    results_by_index: Dict[int, Dict[str, object]] = {}
    with ThreadPoolExecutor(max_workers=total_workers) as executor:
        future_map = {
            executor.submit(
                run_single_task,
                idx,
                len(tasks),
                {**task, "rtl_source_mode": rtl_source_mode},
                stage,
                make_env,
                segfault_retries,
                timeout_sec,
                dataset_policy,
            ): idx
            for idx, task in enumerate(tasks, start=1)
        }
        for future in as_completed(future_map):
            result = future.result()
            results_by_index[int(result["index"])] = result

    results = [results_by_index[idx] for idx in range(1, len(tasks) + 1)]

    for result in results:
        result["effective_function"] = result["function"]
        result["final_decision"] = "success" if result["syntax"] == 1 and result["function"] == 1 else "failure"

    elapsed = time.time() - start_ts
    total = len(results)
    syntax_pass = sum(1 for r in results if r["syntax"] == 1)
    raw_function_pass = sum(1 for r in results if r["function"] == 1)
    raw_full_pass = sum(1 for r in results if r["syntax"] == 1 and r["function"] == 1)
    function_pass = sum(1 for r in results if int(r.get("effective_function", 0)) == 1)
    full_pass = sum(
        1
        for r in results
        if r["syntax"] == 1 and int(r.get("effective_function", 0)) == 1
    )

    syntax_score = format_percent(syntax_pass, total)
    function_score = format_percent(function_pass, total)
    single_test_score = format_percent(full_pass, total)

    print("\n===== One-Shot Score =====")
    print(f"Total tasks: {total}")
    print(f"Syntax pass:   {syntax_pass}/{total} ({syntax_score:.2f})")
    print(f"Function pass: {function_pass}/{total} ({function_score:.2f})")
    print(f"Single score:  {full_pass}/{total} ({single_test_score:.2f})")
    print(f"Elapsed sec:   {elapsed:.2f}")
    if rtl_source_mode == "masked":
        print(
            "Masked expectation note: syntax may pass, but function pass should be near 0 "
            "when one-hole removals impact behavior."
        )

    failed = [
        r
        for r in results
        if not (r["syntax"] == 1 and int(r.get("effective_function", 0)) == 1)
    ]
    if failed:
        print("\nFailed tasks:")
        for r in failed:
            print(f"- [{r['level']}] {r['system']}/{r['task_display']}")
            if str(r["syntax_info"]).strip():
                print(f"  syntax_info: {str(r['syntax_info']).strip()}")
            if str(r["function_info"]).strip():
                print(f"  function_info: {str(r['function_info']).strip()}")
            if r.get("final_decision") == "infrastructure_error":
                print("  final_decision: infrastructure_error")
    else:
        print("\nAll tasks passed. Full score achieved.")

    unexpected_function_pass: List[Dict[str, object]] = []
    if rtl_source_mode == "masked":
        unexpected_function_pass = [r for r in results if r["function"] == 1]
        if unexpected_function_pass:
            print(
                "\nMasked-mode tasks with function=1 "
                "(unexpected in strict one-hole assumption):"
            )
            for r in unexpected_function_pass[:30]:
                mask_meta = r.get("mask_meta", {})
                meta_desc = ""
                if mask_meta:
                    meta_desc = (
                        f", masked_kind={mask_meta.get('masked_kind', '')}"
                        f", masked_type={mask_meta.get('masked_type', '')}"
                        f", span={mask_meta.get('masked_span_lines', '')}"
                    )
                print(f"- [{r['level']}] {r['system']}/{r['task_display']}{meta_desc}")
            if len(unexpected_function_pass) > 30:
                print(f"... and {len(unexpected_function_pass) - 30} more")

    if output_json:
        report = {
            "benchmark_path": benchmark_path,
            "task_level": task_level,
            "stage": stage,
            "rtl_source_mode": rtl_source_mode,
            "masked_units_dir": masked_units_dir if rtl_source_mode == "masked" else None,
            "masked_selection": masked_selection if rtl_source_mode == "masked" else None,
            "allow_missing_masked_tasks": allow_missing_masked_tasks
            if rtl_source_mode == "masked"
            else None,
            "total_tasks": total,
            "syntax_pass": syntax_pass,
            "function_pass": function_pass,
            "full_pass": full_pass,
            "syntax_score": syntax_score,
            "function_score": function_score,
            "single_test_score": single_test_score,
            "raw_function_pass": raw_function_pass,
            "raw_full_pass": raw_full_pass,
            "elapsed_sec": elapsed,
            "make_env": make_env,
            "task_make_env_overrides": TASK_MAKE_ENV_OVERRIDES,
            "task_rtl_path_overrides": TASK_RTL_PATH_OVERRIDES if rtl_source_mode == "original" else {},
            "segfault_retries": segfault_retries,
            "masked_dataset_summary": dataset_summary,
            "dataset_policy": {
                "enabled": bool(dataset_policy.get("enabled")),
                "excluded_path": dataset_policy.get("excluded_path"),
                "excluded_forever_count": len(dataset_policy.get("excluded_entries", [])),
                "skipped_by_dataset_policy_count": len(skipped_by_dataset_policy),
                "skipped_by_dataset_policy": skipped_by_dataset_policy,
            },
            "unexpected_function_pass_count": len(unexpected_function_pass),
            "unexpected_function_pass_tasks": [
                {
                    "system": r["system"],
                    "task": r["task"],
                    "task_display": r["task_display"],
                    "variant": r.get("variant"),
                    "mask_meta": r.get("mask_meta", {}),
                }
                for r in unexpected_function_pass
            ],
            "results": results,
        }
        out_path = os.path.abspath(output_json)
        out_dir = os.path.dirname(out_path)
        if out_dir:
            os.makedirs(out_dir, exist_ok=True)
        with open(out_path, "w", encoding="utf-8") as f:
            json.dump(report, f, ensure_ascii=False, indent=2)
        print(f"\nDetailed report saved to: {out_path}")


if __name__ == "__main__":
    main()
