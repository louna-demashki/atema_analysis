# Layer 4 / ATEMA: the analysis pipeline

These do-files rebuild every dataset, table and figure of *Adopting Computer Assisted Learning at Scale* (ATEMA, experiment 1).
They replace the old server scripts in `analysis\atema\` (the `code/` folder of the `atema_analysis` repository), which are kept unchanged for reference.

The pipeline runs in two setups:

| | Stata 15.1 (the secure server) | Stata 16 or newer, with the original `ddml` package |
|---|---|---|
| DDML engine | `manual`: built-in partially linear DDML, written in plain Stata | `ddml`: the `ddml` package (Ahrens, Hansen, Schaffer, Wiemann) |
| Chosen by | `DDML_ENGINE` in `00_params.do`, automatic | `DDML_ENGINE` in `00_params.do`, automatic |
| Extra install | none | `ddml` (from SSC) |

You don't switch anything by hand. `00_params.do` picks `"ddml"` when `c(stata_version) >= 16` and `"manual"` otherwise.
The same files work in both setups.

---

## 1. Contents of the zip

```
ATEMA/                                  <- rename the unzipped "layer4_ATEMA" folder to "ATEMA"
  run_atema.do                          the master file: the only file you run
  00_setup.do                           loads everything below, in order
  00_paths.do                           every input and output path (old server files or the 2026 Paper tree)
  00_params.do                          every analysis decision (FE, cluster, take-up, samples, controls, DDML)
  00_programs.do                        helper programs: tables, results, Khan merge, DDML (both engines)
  00_packages.do                        checks the user-written packages are installed
  01. build/
    00_khan_usage.do                    Khan usage per student-year, rebuilt within academic year
    01_analysis_panel.do                analysis panel: baseline students x AY 2021-22, 2022-23
    02_event_panel.do                   2017-2023 panel for the event studies
    03_frames.do                        one row per student / school / math teacher (balance)
    04_transfers.do                     where students (teachers) were after baseline
  02. prepare/
    01_controls.do                      control candidates + selection (post-double-selection)
  03. analysis/
    tables/   T1_balance  T2_first_stage  T3_T7_rf_pds  T3_T7_rf_ddml  T4_pairwise
              T5_T6_first_stage_detail  T8_tot  A1_attrition  A2_complier_chars
              A3_treatment_changes  A4_spec_curve
    figures/  F1_rf_coefplot  F2_event_study  F3_matching
    99_compare_old.do                   server only: new analysis panel vs the old one (aggregates only)
  README.md                             this file
```

Every change from the old code is flagged in the code:
- `>>> [NEW]`: code that didn't exist before;
- `>>> [CLEAN]`: same results, written once or made reproducible;
- `>>> [CRASH]`: the old code stopped at this point;
- `>>> [FIX]`: a methodological fix that changes numbers;
- `>>> [LEGACY]`: the old behaviour, restored by `LEGACY 1`;
- `>>> [DECIDE]`: a choice for the PIs.

---

## 2. Requirements

### Both setups

- User-written packages, from SSC:

  | Package | Commands used |
  |---|---|
  | `reghdfe` | `reghdfe`; needs `ftools` |
  | `ftools` | used by `reghdfe` |
  | `ivreg2` | `ivreg2`; needs `ranktest` |
  | `ranktest` | used by `ivreg2` |
  | `ivreghdfe` | `ivreghdfe` |
  | `lassopack` | `rlasso` |
  | `pdslasso` | checked at start-up |
  | `winsor` | `winsor` (the one package, not `winsor2`) |

  `texdoc` and `coefplot` are **not** needed.
- In your LaTeX preamble, for the tables: `\usepackage{adjustbox}`.

### Stata 16 or newer: the original `ddml` package

- Install it once:
  ```stata
  ssc install ddml, replace
  ```
  `ddml` uses `lassopack` for the `rlasso` learner. The pipeline uses only the `reg` and `rlasso` learners, so `pystacked` (and Python) are **not** needed.
- Check the installed version and syntax:
  ```stata
  which ddml
  help ddml
  ```
  The pipeline calls `ddml estimate, vce(cluster school_21)`. If your version of `ddml` doesn't accept `vce(cluster ...)`, change that option in both `atema_ddml_rf` and `atema_ddml_iv` in `00_programs.do`. It is flagged `>>> [DECIDE]` there.
- Locally, `00_packages.do` installs missing packages from SSC when `global ATEMA_AUTOINSTALL 1` (the default). On the server nothing is downloaded: it stops and names the missing package.

### Stata 15.1 (the server)

- `ddml` is **not** required, and is not checked at start-up. The manual engine in `00_programs.do` (`atema_ddml_manual`) does the estimation.

---

## 3. Install

1. Unzip into `<2026_server>/01. Code/06. Layer 4/`.
2. Rename the unzipped folder `layer4_ATEMA` to `ATEMA`. The scripts look for `.../06. Layer 4/ATEMA/`.
3. For old-data mode (section 4.A), you can put the folder anywhere. Set `ATEMA_CODE_DIR` in `run_atema.do` to that folder.

---

## 4. Run

Open `run_atema.do`, set the switches at the top, and run it.
Always start from a clean session (`clear all` and `macro drop _all`, or restart Stata). Otherwise Stata may keep old versions of the helper programs in memory.

### A. Old server data (check that the code runs while Layers 3–4 are not ready)

```stata
global LEGACY         1          // reproduce the old tables
global DATA_SOURCE    "old"      // read the old files in D:\SECURE\data 2024
global ATEMA_CODE_DIR "D:/.../ATEMA"     // folder where you saved these .do files
global OLD_OUT_ROOT   "D:/SECURE/data 2024/2026 Paper/04. Output/ATEMA_oldinputs"
global QUICK_TEST     1          // 2 DDML reps / 2 folds / OLS learner only, 1 matching neighbour
```

The inputs are exactly the files the old scripts read (all read-only):

| Input | Old file |
|---|---|
| baseline sample | `prepare\build\output\atema_treatment` |
| end-of-year records | `prepare\build\output\student_end_enrollment` |
| Khan usage per student-year | `analysis\atema\01. build\output\khan_per_student_combined` |
| Khan weeks, AY 2021-22 | `analysis\atema\01. build\input\khan_data_clean` |
| Khan weeks, AY 2022-23 | `prepare\input\RAW\FILE_KHAN_ACADEMY_PR_DATA` |
| arms by school | `prepare\build\input\treatment_control_atema` |

Notes:
- With `LEGACY 1`, Khan usage comes from the old per-student file, so the two raw weekly files are not needed.
- Teacher transfers are off in this mode, because the old teacher link no longer exists.
- All outputs go to `OLD_OUT_ROOT`, never inside `prepare\` or `analysis\atema\`.

### B. The 2026 Paper tree (the final setup)

```stata
global DATA_SOURCE "new"         // paths from config.do: $L2A $L2B $L3 $experiments
global QUICK_TEST  0
global LEGACY      0             // after LEGACY 1 has reproduced the old tables
```

Locally (in your clone), the master also runs `synthetic/gen_raw_inputs.py`, `synthetic/gen_experiments.py` and `tools/run_layers.sh` first.
Synthetic numbers are **not** results; they only show that the code runs.

To hook the pipeline into the tree's `master.do`, add to its NEW WORK section:
```stata
if $run_ATEMA do "$code/06. Layer 4/ATEMA/run_atema.do"
```

### C. Running DDML with the original package (Stata 16+)

Nothing to change: on Stata 16+ `DDML_ENGINE` is `"ddml"`, and `T3_T7_rf_ddml.do` and `T8_tot.do` call the `ddml` package:

```stata
ddml init partial if ..., kfolds($DDML_K) reps($DDML_REPS) fcluster(school_21)
ddml E[Y|X]: reg    math_score <FE dummies> <forced> <candidates>
ddml E[Y|X]: rlasso math_score ..., partial(<FE dummies> <forced>) cluster(school_21)
ddml E[D|X]: reg / rlasso    for each of atema_st atema_pe_st atema_lt atema_pe_lt
ddml crossfit
ddml estimate, vce(cluster school_21)
```
The TOT uses `ddml init iv`, with `E[Y|X]`, `E[D|X]` and one `E[Z|X]` for each instrument.

Options:

- **Force an engine** by adding a line after `00_setup.do` has run, or editing `00_params.do`:
  ```stata
  global DDML_ENGINE "ddml"      // or "manual"
  ```
- **Full estimates** (as in the paper): `QUICK_TEST 0`. This gives `DDML_REPS` 200 and `DDML_K` 5 on the server, and 2 repetitions locally; edit these in `00_params.do`. 200 repetitions take hours.
- **Running only the DDML tables on a Stata 16+ machine**: first build the datasets (steps 3–4 of `run_atema.do`), wherever the data are allowed. Then:
  ```stata
  clear all
  macro drop _all
  global DATA_SOURCE    "old"            // or "new"
  global ATEMA_CODE_DIR "<folder with these files>"
  global OLD_OUT_ROOT   "<output folder>"
  global QUICK_TEST     0
  do "$ATEMA_CODE_DIR/00_setup.do"
  do "$ATEMA_CODE_DIR/03. analysis/tables/T3_T7_rf_ddml.do"
  do "$ATEMA_CODE_DIR/03. analysis/tables/T8_tot.do"
  do "$ATEMA_CODE_DIR/03. analysis/tables/A4_spec_curve.do"      // uses the DDML results
  do "$ATEMA_CODE_DIR/03. analysis/figures/F1_rf_coefplot.do"    // uses the DDML results
  ```
  Real data never leave the secure server (data README, section 12). Use a Stata 16+ installation **on the server** or approved by Jeancarlo; don't copy the datasets elsewhere.

**Manual vs package.** Both estimate the same partially linear model in the same way:
- folds split by baseline school;
- OLS and rlasso learners, keeping the better one per equation;
- median across repetitions;
- standard errors clustered by school.

Their estimates will be close but not identical, because the random fold draws differ. The table notes say which engine produced them.

---

## 5. Settings (`00_params.do`)

| Setting | Default | Meaning |
|---|---|---|
| `LEGACY` | 0 (set in `run_atema.do`) | 1 = reproduce the old tables |
| `DATA_SOURCE` | set in `run_atema.do` | `"old"` server files / `"new"` 2026 Paper tree |
| `QUICK_TEST` | set in `run_atema.do` | 1 = fast trial run (estimates are not results) |
| `KHAN_SOURCE` | `"rebuilt"` (`"L3"` if LEGACY) | usage summed within academic year / old per-student file |
| `CLUSTER` | `school_21` | baseline school, the randomization unit |
| `GRADE_FE` | `GRADE_ID_FK` | [DECIDE] or `grade_21` |
| `TAKEUP_MINWK`, `WEEKS_2022`, `WEEKS_2023` | 5, 29, 31 | take-up = at least 5 min/week on average |
| `FS_SAMPLE`, `FS_CONTROLS` | `"all"`, 1 | [DECIDE] first-stage sample and controls |
| `CONTROLS` | `"pds"` (`"legacy"` if LEGACY) | control selection |
| `DDML_ENGINE` | `"ddml"` on 16+, `"manual"` on 15 | see section 4.C |
| `DDML_LEARNERS` | `"reg rlasso"` (`"reg"` in quick test) | learners of the manual engine |
| `DDML_K`, `DDML_REPS` | 5, 200 on server (2, 2 in quick test) | folds, repetitions |
| `LT_DROP_INELIGIBLE` | 0 | [DECIDE] drop long-term rows never eligible in year 1 |

---

## 6. Outputs

| Where | What |
|---|---|
| `$ATEMA_DATA` | `master_khan_student_combined`, `master_controls`, `controls_globals.do`, `master_2017_2023`, the frames, the transfer files |
| `$ATEMA_OUT/tables` | one `.tex` per table, Overleaf-ready |
| `$ATEMA_OUT/results` | every estimate as a `.dta` (plus `.ster` for DDML), read by the figures and A4 |
| `$ATEMA_OUT/figures` | `.png` figures |
| `ATEMA_CODE_DIR/01. Logs` | one log per script, plus the master log |

In old-data mode, `$ATEMA_DATA` is `OLD_OUT_ROOT/data` and `$ATEMA_OUT` is `OLD_OUT_ROOT`.

**Overleaf.** Upload the `.tex` files and write, for example:
```latex
\input{tables/T2_first_stage}
```
Refer to a table with `\ref{tab:T2_first_stage}`. Real-data tables are server output: check that no cell is below 11 and ask Jeancarlo before downloading them.

---

## 7. Old script to new script

| Old (`code/`) | New |
|---|---|
| `clean_ka_22_23.do`, first half | `01. build/00_khan_usage.do` |
| `clean_ka_22_23.do`, second half | `01. build/01_analysis_panel.do` |
| `clean_ka_17_23.do` | `01. build/02_event_panel.do` |
| frames inside `balance*.do`, `pairwise*.do` | `01. build/03_frames.do` |
| data half of `treatment_changes*.do` | `01. build/04_transfers.do` |
| `control_selection.do` | `02. prepare/01_controls.do` |
| `balance.do`, `balance_pooled.do` | `T1_balance.do` |
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
| `graph_RFE.do` | `F1_rf_coefplot.do` |
| `event_study_by_grade.do`, `DiD (all students).do` | `F2_event_study.do` |
| `event_study_matching*.do` (6 files) | `F3_matching.do` |
| `2sls_5min.do`, `compliance_by_cohort.do` | dropped (debugging leftovers / empty) |

---

