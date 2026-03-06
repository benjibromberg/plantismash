# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**plantiSMASH** is a Python-based bioinformatics tool for automated identification and analysis of biosynthetic gene clusters (BGCs) in plant genomes. It is a specialized extension of antiSMASH with plant-specific detection rules, comparative genomics, and visualization. Version 2.0.4.

## Commands

```bash
# Run analysis on a GenBank file
plantismash [options] <input_sequence.gbk>
# or directly:
python run_antismash.py [options] <input_sequence.gbk>

# Download/update databases (Pfam + ClusterBlast from Zenodo)
plantismash_download_databases
# or: python download_databases.py

# Run unit tests
make unit

# Run unit tests with coverage report (output: cover/)
make coverage

# Run integration tests
make integration

# All tests + coverage
make all

# Docker build
docker build -t plantismash:latest .

# Create conda environment
conda env create -f environment.yml
```

## Architecture

### Entry Points

- `run_antismash.py` — Main pipeline orchestrator (~1,100 lines). Loads plugins dynamically via `straight.plugin`, manages module execution pipeline.
- `download_databases.py` — Downloads Pfam and ClusterBlast databases from Zenodo.
- Package entry points: `plantismash` and `plantismash_download_databases` (defined in `pyproject.toml`).

### Core Package (`antismash/`)

- `config/` — Configuration management, `default.cfg` with Glimmer/HMMer/TFBS/BioSQL settings
- `generic_modules/` — Core analysis modules:
  - `active_site_finder/`, `clusterblast/`, `fullhmmer/`, `genefinding/` (Glimmer, Prodigal), `gff_parser/`, `hmm_detection/`, `knownclusterblast/`, `smcogs/`, `subclusterblast/`, `subgroup/`, `tfbs_finder/`, `coexpress/`
- `generic_genome_modules/` — Genome-level modules (e.g., `metabolicmodel/` for FBA)
- `specific_modules/` — Plant-specific modules (`plant_cyclopeptides/`)
- `output_modules/` — Output generators (GenBank, HTML, SVG, TXT, XLS)
- `lib/` — Utility libraries (hmmscanparser, pysvg, etc.)
- `db/` — Database modules (BioSQL, extradata)
- `utils.py` — Shared utility functions
- `test/` — Test suite (unit & integration, uses `nosetests`)

### Key Configuration Files

- `pyproject.toml` — Package config; requires Python >=3.8,<3.9
- `environment.yml` — Conda environment (conda-forge + bioconda channels)
- `Dockerfile` — Container build (base: `condaforge/miniforge3:26.1.0-0`)
- `Makefile` — Test runner targets (unit, coverage, integration)
- `antismash/config/default.cfg` — Runtime defaults (Glimmer params, HMMer evalue, TFBS, BioSQL, solver)
- `.prospector.yaml` — Linting config (ignores pysvg, indigo)

### External Tool Dependencies (via Conda)

Glimmer/GlimmerHMM, HMMER 3.3.2, HMMer2, DIAMOND 2.0.15, BLAST 2.12.0, Prodigal 2.6.3, MUSCLE 3.8.31, FastTree 2.1.11, CD-HIT 4.8.1, PPlacer, NCBI Datasets CLI.

## Important Patterns

- **Python 3.8 only**: Strict requirement `>=3.8,<3.9` in pyproject.toml.
- **Plugin architecture**: Modules are loaded dynamically via `straight.plugin`. Each module directory follows a convention with `__init__.py` exposing standard entry points.
- **Testing**: Uses `nosetests` (not pytest) via the Makefile. Integration tests are regex-matched by `(?:^|[\b_\./-])[Ii]ntegration`.
- **Commit messages**: Format is `(#1234) component: Short imperative description` with `fixes #1234` or `implements #1234` footer.
- **PEP8**: Follow PEP8; use `git diff --check` for whitespace; prospector for linting.
- **Branch model**: Topic branches from `master`, one logical unit per commit.
- **Security**: `.agent/rules/snyk_rules.md` requires Snyk scanning on all code changes.
- **gitignored**: `*.pyc`, `cover/`, test datasets, HMMER databases, clusterBLAST databases, downloaded TFBS data.

## Docker Build Notes

- **Fork context**: This is a fork of `plantismash/plantismash` maintained at `benjibromberg/plantismash`. Docker image published as `benjibromberg/plantismash:2.0.4`.
- **Local source install**: The Dockerfile uses `COPY . /tmp/plantismash && pip install /tmp/plantismash` instead of `pip install plantismash==2.0.4` from PyPI. This is required because the PyPI package is missing critical data files (knownclusterblast `.fasta`/`.dmnd`, subgroup `.afa` alignments).
- **Package-data fix**: `pyproject.toml` has comprehensive `[tool.setuptools.package-data]` patterns to include all non-Python data files that ship with the source tree but were excluded from the wheel.
- **Cross-platform build**: Must use `docker build --platform linux/amd64` on Apple Silicon since bioconda packages are linux-64 only.
- **`.dockerignore`**: Excludes `.git` (~275MB), `.github`, `cover/`, test artifacts, and other non-essential files to keep the build context small.
