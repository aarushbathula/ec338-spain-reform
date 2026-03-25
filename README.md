# EC338 - Spanish Gender Quota Reform

This repository is a replication package for an economics assignment on the effect of Spanish local-election gender quotas on female political representation.

## How to Replicate

- Software: Stata 18
- Command: `do code/master.do`
- Input data: place `assignment_2.dta` or `assignment 2.dta` in `data/`
- Outputs: generated tables, figures, and logs are written to `output/`

Run the full project from the repository root in Stata:

```stata
do code/master.do
```

## Project Overview

- `paper/`: compiled assignment PDF, saved Stata log, Overleaf sources, and manuscript assets
- `data/`: local-only raw data files and documentation
- `code/`: modular Stata scripts plus the original monolithic submission script for provenance
- `output/`: generated figures, tables, and logs

The preferred workflow is:

1. `code/00_setup.do`
2. `code/01_did_event_study.do`
3. `code/02_rdd.do`
4. `code/03_iv.do`
5. `code/master.do`

## Methods and Data Note

The project studies a 3,000-population cutoff tied to quota exposure in Spanish local elections. The design uses treated-by-post DiD specifications, event-study checks, threshold-based RDD estimates, and an IV setup built from quota exposure. The main outcomes are the female share of elected councillors and whether the mayor is female, and the working sample applies the repository's existing municipality, year, and election-status filters before estimation.

## Data and Paper Assets

- The raw `.dta` files remain local-only in `data/`
- The repository tracks the assignment do-file, the submitted PDF, the saved log, and Overleaf paper assets
- Generated figures, tables, and logs are written to `output/`

## Software and Dependencies

- Stata 18
- User-written Stata packages: `coefplot`, `rdrobust`, `rddensity`, `lpdensity`, `estout`
- The modular pipeline uses repo-relative paths rather than a machine-specific working directory

## Outputs

Expected generated outputs include:

- `output/tables/table_q2_did.tex`
- `output/tables/table_q2_event_study.tex`
- `output/tables/table_q3_rdd.tex`
- `output/tables/table_q4_iv.tex`
- `output/figures/q2_event_study_16dec.pdf`
- `output/figures/rdplot_share_female_councillors_2011_16dec.pdf`
- `output/figures/rddensity_population_3000_16dec.pdf`
- `output/figures/rdplot_share_female_councillors_2007_placebo_16dec.pdf`
- `output/logs/master.log`

## PROJECT_STATUS

- Replication workflow: ready
- Data availability: local-only
- Paper assets: included
- Known gaps: this is still an assignment-scale replication package and remains lighter than the larger course projects

## Limitations

- The raw dataset is not redistributed through this repository
- Full replication depends on placing the local `.dta` file in `data/` and having the required Stata user-written packages installed
- The project is now runnable and documented, but it remains narrower in scope than the larger empirical replication packages in the portfolio
