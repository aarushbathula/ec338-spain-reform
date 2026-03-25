# EC338 Spain Reform

This repository is being shaped into a lightweight academic replication package for the Spain reform assignment. It now includes the submitted PDF, the original Stata do-file, and the saved Stata log, but it is still not yet a fully executable replication repo because the analysis workflow has not been modularised into a reproducible project pipeline.

## What Is Here

- `paper/`: the compiled assignment PDF, saved Stata log, and any future manuscript sources
- `data/`: local-only raw data files and documentation
- `code/`: the original Stata do-file plus space for a future cleaned replication pipeline
- `output/`: reserved for generated figures, tables, and logs

## Current State

The repository now contains the original assignment script, which is useful provenance, but it still does not contain a cleaned end-to-end replication pipeline. That means a third party can inspect the submission materials and core source script, but may still need manual setup work before reproducing the analysis from scratch.

## Reproducibility Workflow

Once code is added, the intended workflow is:

1. Place the raw dataset in `data/`
2. Start from `code/EC338_Assignment_2_Group[T]_Spain.do`
3. Refactor that script into a repo-relative master workflow
4. Review the saved assignment PDF and log under `paper/`
5. Keep the raw data local and out of Git

Until the scripts exist, the repository is best understood as a structured archive of the assignment materials rather than a complete replication package.

## Data Notes

The raw `.dta` files remain on disk in `data/`, but they are intentionally excluded from Git. The repository tracks the assignment do-file, the submitted PDF, and the saved log as reproducibility artifacts while keeping the underlying dataset local-only.

## Contributing Toward Reproducibility

The next useful additions would be:

- a `code/master.do` or equivalent orchestration script
- a short methods note on the reform design and identifying assumptions
- a data dictionary or file manifest
- a brief output specification describing which tables and figures should be regenerated
