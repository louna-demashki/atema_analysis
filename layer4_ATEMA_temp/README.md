# Layer 4 / ATEMA — the analysis pipeline

This folder replaces the old server scripts in `code/`, which are kept unchanged for reference.
It goes into the data tree as `2026_server/01. Code/06. Layer 4/ATEMA/`.

## Run it

1. Copy this folder to `<2026_server>/01. Code/06. Layer 4/ATEMA/`.
2. Open `run_atema.do` and set `global LEGACY` (1 = reproduce the old tables, 0 = the corrected analysis).
3. Run `run_atema.do`. Locally it:
   - generates the synthetic data,
   - rebuilds Layers 0–3,
   - runs the whole ATEMA chain.

   On the server it runs only the ATEMA chain and the comparison with the old files.
4. Add a switch to the NEW WORK section of the tree's `master.do`:
   ```stata
   if $run_ATEMA do "$code/06. Layer 4/ATEMA/run_atema.do"
   ```

Every analysis choice (fixed effects, cluster, take-up threshold, samples, controls, DDML repetitions) is in `00_params.do`.
Every input path is in `00_paths.do`.

## Old script → new script

| Old (`code/`) | New |
|---|---|
| `clean_ka_22_23.do`, first half | `01. build/00_khan_usage.do` (rebuild + check against Layer 3 script 05) |
| `clean_ka_22_23.do`, second half | `01. build/01_analysis_panel.do` |
| `clean_ka_17_23.do` | `01. build/02_event_panel.do` |
| frames inside `balance*.do`, `pairwise*.do` | `01. build/03_frames.do` |
| data half of `treatment_changes*.do` | `01. build/04_transfers.do` |
| `control_selection.do` | `02. prepare/01_controls.do` |
| `balance.do`, `balance_pooled.do` | `03. analysis/tables/T1_balance.do` |
| `first stage.do` | `T2_first_stage.do` |
| `heterogeneity RFE (pooled).do`, `RFE (pooled B) - PDS lasso.do`, `RFE (pds lasso) - excluding grade 6.do` | `T3_T7_rf_pds.do` |
| `RFE ddml.do` | `T3_T7_rf_ddml.do` |
| `appendix. pairwise differences*.do`, `pairwise - pooled.do` | `T4_pairwise.do` |
| `appendix. first stage (year-specific)*.do`, `first stage by grade*.do`, `heterogeneity FS*.do` | `T5_T6_first_stage_detail.do` |
| `IV ddml - method 1/2.do`, 2SLS part of `av_table*.do` | `T8_tot.do` |
| `attrition.do` | `A1_attrition.do` |
| `complier_characteristics.do` | `A2_complier_chars.do` |
| `treatment_changes*.do` | `A3_treatment_changes.do` |
| `av_table (first stage/RFE/2SLS).do`, `av_table.do` | `A4_spec_curve.do` |
| `graph_RFE.do` | `03. analysis/figures/F1_rf_coefplot.do` |
| `event_study_by_grade.do`, `DiD (all students).do` | `F2_event_study.do` |
| `event_study_matching*.do` (6 files) | `F3_matching.do` |
| `2sls_5min.do`, `compliance_by_cohort.do` | dropped (debugging leftovers / empty) |
| — | `03. analysis/99_compare_old.do` (server: new vs old, aggregates only) |

## Status

These scripts have **not been run yet**. They were written without Stata or data.

- First run them on the synthetic data in your clone, and fix what breaks.
- Then run them on the server with `LEGACY 1` and compare against the old outputs.
- Items to verify are marked `>>> [DECIDE]` in the code. They are mainly:
  - the variable names in `atema_treatment`, `school_arms` and the Layer 2B link;
  - the `ddml estimate, vce(cluster ...)` syntax of the installed `ddml`.

## Overleaf

`atema_tex` (in `00_programs.do`) writes one complete table per `.tex` file into `04. Output/ATEMA/tables/`.
It escapes `_`, `<` and `>`, shrinks wide tables to the page width, and adds `\label{tab:<table name>}`.

To use the tables:
1. Add `\usepackage{adjustbox}` to your preamble.
2. Upload the `.tex` files.
3. Pull each one in with `\input{tables/T2_first_stage}`.
4. Refer to it in the text with `\ref{tab:T2_first_stage}`.

Real-data tables are server output: check that no cell is below 11 and ask Jeancarlo before downloading them.

## Testing on the old server data (before Layers 3–4 are ready)

At the top of `run_atema.do`:
```stata
global DATA_SOURCE    "old"      // read the old files in D:\SECURE\data 2024
global ATEMA_CODE_DIR "..."      // folder where you saved these .do files
global OLD_OUT_ROOT   "..."      // a NEW folder for outputs (never inside prepare\ or analysis\atema\)
global QUICK_TEST     1          // 2 DDML repetitions / 2 folds, 1 matching neighbour
global LEGACY         1          // reproduce the old tables
```

The inputs are exactly the files the old scripts read:
- `prepare\build\output\atema_treatment`
- `prepare\build\output\student_end_enrollment`
- `analysis\atema\01. build\output\khan_per_student_combined`
- `analysis\atema\01. build\input\khan_data_clean`
- `prepare\input\RAW\FILE_KHAN_ACADEMY_PR_DATA`
- `prepare\build\input\treatment_control_atema`

Teacher transfers are off in this mode, because the old teacher link no longer exists.
To run one script on its own, first set `DATA_SOURCE` and `ATEMA_CODE_DIR` in the Stata session.
