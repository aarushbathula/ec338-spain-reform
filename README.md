# EC338 Spain Reform

This repository is being shaped into a lightweight academic replication package for the Spain reform assignment. It now includes the submitted PDF, the original Stata do-file, the saved Stata log, and a modular Stata pipeline that mirrors the structure used in the other economics repos.

## What Is Here

- `paper/`: the compiled assignment PDF, saved Stata log, Overleaf sources, and any future manuscript sources
- `data/`: local-only raw data files and documentation
- `code/`: modular Stata scripts plus the original monolithic submission script for provenance
- `output/`: generated figures, tables, and logs

## Current State

The repository now contains a cleaned repo-relative workflow:

1. `code/00_setup.do`
2. `code/01_did_event_study.do`
3. `code/02_rdd.do`
4. `code/03_iv.do`
5. `code/master.do`

The original submission script is still kept in the repo as provenance, but the modular pipeline is now the preferred entry point.

## Reproducibility Workflow

Run the full project from the repository root in Stata with:

```stata
do code/master.do
```

The pipeline expects the raw dataset in `data/` and writes generated figures and logs into `output/`.

## Data Notes

The raw `.dta` files remain on disk in `data/`, but they are intentionally excluded from Git. The repository tracks the assignment do-file, the submitted PDF, and the saved log as reproducibility artifacts while keeping the underlying dataset local-only.

## Contributing Toward Reproducibility

The next useful additions would be:

- a short methods note on the reform design and identifying assumptions
- a data dictionary or file manifest
- regression table export for the DiD, RDD, and IV results
