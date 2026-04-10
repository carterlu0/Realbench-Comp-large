# Realbench-Comp

Realbench-Comp is the open-source block-level RTL completion benchmark and evaluation pipeline released with our paper. It is built on top of the RealBench infrastructure, but is reconstructed for multi-module RTL code completion with functional evaluation.

This release keeps the completion benchmark pipeline only. It does not include the original code generation workflow.

## What Is Included

- `Realbench-Comp_weighted_001/`: the main benchmark split used in our experiments
- `aes/`, `sdc/`, `e203_hbirdv2/`: source trees used in benchmark construction and evaluation
- `platform/`: black-box request construction and adapter invocation
- `evaluation/`: single-sample and batch completion evaluation
- `dataset_tools/`: dataset construction and legality validation
- `adapters/`: reference adapter wiring to RTLC^2
- `metadata/`: weighted selection statistics and helper scripts

## Environment

Realbench-Comp is intended to run on Linux with Python 3.10.

Before using the benchmark or rebuilding custom subsets, prepare the following:

- Python 3.10 environment
- dependencies required by the evaluation and dataset scripts
- Verilator for syntax and functional verification
- Yosys for legality checking
- GPG for markdown document encryption and decryption

The repository includes `conda_env.yml` as the base environment description.

If you plan to run the full evaluation or dataset construction pipeline, make sure the external toolchain is available from the shell environment used to launch the scripts.

## Installation

Create the base environment from `conda_env.yml`, then install any additional Python packages required by your completion backend and verification flow.

## Quick Start

### Single Sample

Run RTLC^2 on one masked sample through the black-box adapter:

```bash
python platform/run_completion_adapter.py \
  --adapter adapters/rtlc2_adapter.py:generate_completion \
  --target-file Realbench-Comp_weighted_001/aes/aes_cipher_top/aes_cipher_top__mask0001.v \
  --repo-root . \
  --context-policy recursive_upstream \
  --include-docs auto \
  --request-out /tmp/request.json \
  --response-out /tmp/response.json \
  --print-completion
```

Then evaluate the completion:

```bash
python evaluation/evaluate_single_completion.py \
  --target-file Realbench-Comp_weighted_001/aes/aes_cipher_top/aes_cipher_top__mask0001.v \
  --response /tmp/response.json \
  --repo-root . \
  --print-result
```

### Batch Evaluation

If your responses are stored in a directory that mirrors the dataset tree, run:

```bash
python evaluation/evaluate_batch.py \
  --dataset-dir Realbench-Comp_weighted_001 \
  --response-dir /path/to/responses \
  --repo-root . \
  --output-json /tmp/realbench_comp_batch_eval.json \
  --print-summary
```

For a target such as `Realbench-Comp_weighted_001/e203_hbirdv2/e203_exu_alu/e203_exu_alu__mask0001.v`, the evaluator looks for responses such as:

- `/path/to/responses/e203_hbirdv2/e203_exu_alu/e203_exu_alu__mask0001.json`
- `/path/to/responses/e203_hbirdv2/e203_exu_alu/e203_exu_alu__mask0001.txt`
- `/path/to/responses/e203_hbirdv2/e203_exu_alu/e203_exu_alu__mask0001.response.json`
- `/path/to/responses/e203_hbirdv2/e203_exu_alu/e203_exu_alu__mask0001.response.txt`

## Benchmark Construction

Realbench-Comp is constructed by masking selected Verilog regions from repository source files and evaluating whether a completion system can correctly recover the removed code under cross-file context.

The public dataset construction entry is:

- `dataset_tools/build_masked_dataset.py`

The released benchmark follows four main steps:

1. annotate candidate block-level and grouped semantic regions
2. expand candidate spans into masking variants
3. apply weighted sampling that favors structurally important and semantically richer targets
4. retain only masked samples that fail functional simulation

Samples that do not satisfy the functional-failure requirement are excluded through a global blacklist, which also propagates to other masking variants sharing the same underlying target span.

## Weighted Selection Policy

The weighted policy used for the public benchmark is defined by the dataset construction script logic. The effective strategy is controlled by:

- weighted candidate sampling
- type balancing over structurally important targets
- strict filtering for functionally meaningful masked samples
- variant allocation for richer grouped regions

## Main Dataset

The main dataset `Realbench-Comp_weighted_001` contains 200 completion tasks. All released samples fail functional simulation in their masked form.

## Custom Subsets

This release includes the blacklist, candidate-pool statistics helpers, annotated assets, and the full masked-dataset construction path needed to derive custom subsets.

The intended workflow is:

1. annotate and collect candidate spans
2. build a masked dataset with the weighted construction logic
3. apply blacklist and legality constraints
4. validate the resulting subset with the legality checker

Typical assets involved in this flow are:

- `annotated_units/`
- `dataset_tools/verilog_unit_annotator.py`
- `dataset_tools/build_masked_dataset.py`
- `global_exclusion_blacklist.json`
- `dataset_tools/validate_dataset_legality.py`
- `dataset_tools/analyze_candidate_pool.py`

## Evaluation

This repository keeps the full RTL completion evaluation chain:

1. build request objects
2. run a completion system through the black-box adapter interface
3. stitch completion text back into masked RTL
4. evaluate exactness and edit similarity
5. run syntax and functional verification

Realbench-Comp is intended for text-level and functional evaluation of block-level RTL completion under realistic engineering constraints.

## Documentation Encryption

Module-level markdown documents from the source trees are distributed in encrypted form using the same GPG-based workflow as the original RealBench repository.

Use `make encrypt` and `make decrypt` for the markdown documentation workflow.

## Integration

The reference adapter in `adapters/rtlc2_adapter.py` connects this benchmark to the RTLC^2 completion system.

The intended public pairing is:

1. prepare RTLC^2 with `RTL-Repo/` and retrieval cache assets
2. build a completion request with `platform/run_completion_adapter.py`
3. run the adapter-backed completion system
4. evaluate outputs with `evaluation/evaluate_single_completion.py` or `evaluation/evaluate_batch.py`
