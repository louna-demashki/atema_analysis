# ATEMA analysis — code guide

ATEMA is a cluster-randomized evaluation of teacher coaching for Khan Academy (KA) in Puerto
Rico public schools, grades 4–8. There are four arms plus control: TA1
(ATEMA 2021-22), TA2 (ATEMA + parental engagement 2021-22), TA3/TA4 (ATEMA
2022-23) and control. Randomization was within 42 strata (school level × region
× above/below-median performance).

This file describes:

1. what each Stata do file in `code/` does;
2. what each R script does (the R scripts are kept on the server, not in this
   repository);
3. how the R scripts can be replaced by do files, and which ones.

Conventions used by all files:

- **Data.** The data live on the PRDE secure server under
  `D:\SECURE\data 2024\analysis\atema`: `data/` holds the datasets, `output/`
  holds tables, logs and graphs.
- **Treatment indicators.** They follow equation (1) of the paper:
  - `atema_st`: TA1 in 2021-22, and TA3/TA4 in 2022-23;
  - `atema_pe_st`: TA2 in 2021-22;
  - `atema_lt`: TA1 in 2022-23;
  - `atema_pe_lt`: TA2 in 2022-23.
- **Fixed effects.** `strata` is re-coded as stratum × academic year.
- **Standard errors.** Clustered at the baseline school (`school_21`).
- **Take-up.** `takeup` means at least 5 minutes per week of KA use (≥145
  minutes in 2021-22, ≥155 in 2022-23).

---

## 1. Stata do files

### Data build

| File | What it does | Main output |
|---|---|---|
| `code/clean_ka_22_23.do` | Cleans the weekly KA exports for 2021-22 and 2022-23: removes duplicate export rows, sums minutes and skills to one row per student and year, and flags logins. Merges usage into the end-of-year PRDE student records, then onto the September 2021 roster with random assignment (students stay in their original school). Standardizes math, English and Spanish scale scores within grade and year against the comparison group (after 1% winsorizing). Builds `takeup` and the four treatment indicators. | `master_khan_student_combined.dta` |
| `code/clean_ka_17_23.do` | Builds a 2017–2023 student panel (2017–2019 and 2022–2023 test years) with KA usage, take-up flags, grade-standardized math scores, and a version of the score set to missing for students who repeated or skipped a grade. Used only by the event-study graphs. | `master_2017_2023.dta` |
| `code/control_selection.do` | Builds the set of candidate controls from 44 baseline (2019/2021) variables: standardizes them, adds missing-value indicators (missing values set to 0), adds squares, and drops constant and collinear terms. Then adds all two-way interactions and drops collinear terms again. Runs `rlasso` (clustered by school, strata and grade FE partialled out) of the math score and each treatment indicator on the candidates, and hard-codes the selected controls in `s_controls`. | `master_controls.dta` |

### Main tables

| File | What it does | Paper table |
|---|---|---|
| `code/tables/main/balance.do` | Regresses baseline student, school and teacher characteristics on the four arms, with stratum and grade FE and clustered SEs. Reports the control mean and each arm's difference from control. | Table 1 |
| `code/tables/main/balance_pooled.do` | Same as `balance.do`, with TA3 and TA4 pooled into one arm. | not in paper |
| `code/tables/main/first stage.do` | Effects of the four treatment indicators on KA usage: login, take-up (≥5 min/week), minutes and skills leveled up. Take-up is also split by above-/below-median schools. Includes control means for 2021-22 and 2022-23 and tests of β1=β2, β1=β3 and β2=β4. | Table 2, Table 3 col. 1 |
| `code/tables/main/heterogeneity RFE (pooled).do` | Reduced-form effects on math scores (`reghdfe` with the lasso-selected controls, grade and stratum FE, clustered SEs) for all students; primary and middle grades; female and male; above- and below-median schools. | Table 7 panel A (PDS lasso) |
| `code/tables/main/RFE (pds lasso) - excluding grade 6.do` | Same as the heterogeneity file, but drops 2022-23 scores of students who were in grade 6 in 2021-22. | robustness, not in paper |
| `code/tables/main/RFE ddml.do` | Double/debiased machine learning (partially linear model, `ddml` package) of math scores on the four treatment indicators. Uses OLS + rlasso learners with short-stacking, an optional random forest, 5 folds × 200 repetitions, and cross-fitting folds split by school. Loops over all students, above-/below-median, female and male. Saves a `.tex` table and a coefficient `.dta` for each sample. | Table 3 cols. 2–4, Table 7 panel B |
| `code/tables/main/av_table.do` | Main results table: first stage of take-up; 2SLS of math scores on take-up instrumented by `atema_st` and `atema_pe_st` (`ivreghdfe`, lasso controls, with the Angrist–Pischke F); and the DDML estimates read from `03. RFE ddml (all).dta`. | TOT (treatment-on-the-treated) results |
| `code/tables/main/av_table (first stage).do` | First stage of take-up, adding control sets one at a time (7 columns). | robustness |
| `code/tables/main/av_table (RFE).do` | Reduced form on math scores with the same step-by-step control sets. | robustness |
| `code/tables/main/av_table (2SLS).do` | 2SLS of math scores on take-up with the same step-by-step control sets. | robustness |
| `code/tables/main/IV ddml - method 1.do` | DDML instrumental-variables estimate of the effect of take-up on math scores, instrumented by short-term assignment. Long-term arms are dropped, 5 folds × 200 repetitions, OLS + rlasso learners, lasso-selected controls. | TOT (DDML) |
| `code/tables/main/IV ddml - method 2.do` | Same as method 1, but with a much larger control set (all interactions involving the selected baseline variables). | robustness |
| `code/tables/main/2sls_5min.do` | Draft of an interactive-IV DDML for take-up. It keeps only 1,000 observations and stops at a deliberate `stoop` line. | work in progress |

### Graphs

| File | What it does |
|---|---|
| `code/graphs/graph_RFE.do` | Bar charts of the DDML short- and long-term effects on math scores, by subgroup. The coefficients and SEs are typed in by hand from the regression tables rather than read from saved results. |
| `code/graphs/event_study_by_grade.do` | Event studies (2017–2023) of math scores on take-up × year, by 2021 grade and for all students. Uses scores that exclude grade repeaters. |
| `code/graphs/DiD (all students).do` | The same event studies / difference-in-differences using the unadjusted math score. |
| `code/graphs/event_study_matching (1/3/5 neighbor(s)).do` | Matches students who took up KA to non-users on prior test scores (`teffects nnmatch`, exact on grade), then runs event studies on the matched samples. |
| `code/graphs/event_study_matching_res (1/3/5 neighbor(s)).do` | Same, with the comparison pool restricted to control-school students. |

The graphs are not part of the tables in the current draft of the paper.

---

## 2. R scripts (kept on the server)

The R scripts were earlier or parallel attempts at the same analyses. Several
of them do not run as written. The status column says which ones do.

| File | What it does | Status |
|---|---|---|
| `ddml.R` | First sketch of DDML with the `ddml` package: strata × year FE, grade dummies, rlasso + random forest + causal forest, 5 folds × 200 reps. | Does not run: data never loaded, empty control lists, calls `ddml$new()`, which does not exist |
| `ddml_R.R` | Installs about 140 packages from local zip files, then tries `ddml::ddml_ate` with glmnet on 1,000 rows. | Does not run: wrong `sample_folds` argument; duplicate and base-R package installs |
| `ddml_2.R` | DoubleML test on 2,000 rows with a custom class-weighted XGBoost learner. | Does not run: `learner_logit` undefined, weights never passed |
| `ddml_3.R` | DoubleML with a custom "forced controls" lasso learner, plus a one-off glmnet fit at λ = 0.1. | Does not run: `learner_logit` undefined, and the learner does not actually force controls |
| `ddml_R (all).R` | DoubleML with `cv_glmnet` + rpart on a 10,000-row sample, with LaTeX export. | Syntax error: unclosed `baseline <- c(`; `force_vars` is not a valid argument |
| `ddml (lasso only).R` | DoubleML partially linear model, one model per treatment: glmnet for the outcome (baseline scores, GPA, grade and strata dummies forced in with penalty 0), OLS for the treatment, 5 folds × 200 reps, clustered by school, all students. | Runs |
| `ddml_4.R` | Same as above, with a classification tree (rpart) for the treatment. | Runs (main R version) |
| `ddml_am`, `ddml_bm`, `ddml_f`, `ddml_m` | Copies of `ddml_4.R` restricted to above-median, below-median, female and male students. | Run |
| `IV_ddml` | DoubleML interactive IV: take-up instrumented by `short_term` (assigned to either short-term arm), long-term arms dropped, XGBoost learners, 5 folds × 100 reps. | Estimation runs; the code after `print(dml_iv)` fails (`ensemble_g`, `lambda_val` undefined) |
| `RFE controls.R` | R version of `control_selection.do`: standardize, missing indicators, squares, interactions, collinearity checks, `hdm::rlasso`, saves `master_controls_R.dta`. | Runs, but the squared terms are never created, the constant-variable check drops the wrong columns, and `rlasso` ignores `penalty.factor`, so FE are not forced in |
| `RFE (pds lasso)` | OLS with the lasso-selected controls and school-clustered SEs for the same 7 samples as the Stata heterogeneity table. | Runs, but the grade and strata FE are silently removed from the formula |
| `RFE (pds lasso) - 2` | Early attempt at post-double-selection with `hdm::rlassoEffects`. | Does not run: `lasso_model` and `treatment_results` undefined |

Common issues in the R DDML scripts:

- `regr.glmnet` predicts at a fixed penalty rather than a cross-validated one.
- The strata regex skips some strata (15–19, 25–29, …).
- The grade dummies differ across scripts.
- The scripts read `master_controls.dta`, while the R PDS scripts read
  `master_controls_R.dta`.

---

## 3. Replacing the R scripts with do files

Every R analysis already has a Stata version in this repository. Nothing new
needs to be written except in two cases, marked below.

| R script(s) | Replaced by | What changes |
|---|---|---|
| `RFE controls.R` | `code/control_selection.do` | Same procedure. The Stata version creates the squared terms and forces strata/grade FE through `partial()`. Before the rename step, add `cap drop math_21 eng_21 spa_21` (as `RFE ddml.do` already does), or the rename can fail. |
| `RFE (pds lasso)` | `code/tables/main/heterogeneity RFE (pooled).do` | Same 7 samples. `reghdfe ... absorb(GRADE_ID_FK strata)` keeps the FE that the R version dropped. Choose one lasso-selected control list, because the R and Stata lists differ. `master_controls.dta` already contains `old_strata`, so guard the `rename strata old_strata` line. |
| `RFE (pds lasso) - 2` | `code/tables/main/heterogeneity RFE (pooled).do` | Superseded; nothing to port. |
| `ddml_4.R`, `ddml_am`, `ddml_bm`, `ddml_f`, `ddml_m` | `code/tables/main/RFE ddml.do` | One loop covers all 5 samples (5 folds × 200 reps, clustered by school). The Stata file estimates the four treatments jointly with OLS + rlasso learners; the R scripts ran one model per treatment with lasso and a classification tree. Table 7 panel B also needs primary/middle samples: add two conditions to the sample loop. |
| `ddml (lasso only).R` | `code/tables/main/RFE ddml.do` | The OLS learner already enters the short-stack. For the exact "lasso outcome / OLS treatment" variant as a robustness check, keep only those learner lines. |
| `ddml.R`, `ddml_R.R`, `ddml_2.R`, `ddml_3.R`, `ddml_R (all).R` | `code/tables/main/RFE ddml.do` | Drafts. `RFE ddml.do` does what they attempted. Archive them. The optional random forest in `RFE ddml.do` (`use_rf`, needs Python + `pystacked`) covers the random-forest learner from `ddml.R`. |
| `IV_ddml` | `code/tables/main/IV ddml - method 1.do` (**minor edit needed**) | The Stata file uses a partially linear IV (`ddml init iv`) with two instruments and OLS/lasso learners. The R script used an interactive IV with one pooled instrument and XGBoost. To match the R model: `gen short_term = (atema_st==1 \| atema_pe_st==1)`, `ddml init interactiveiv`, and learners `E[Y\|X,Z]`, `E[D\|X,Z]`, `E[Z\|X]` (syntax as in `2sls_5min.do`). Also fix the export block (`local row` is never defined, `"takeuup"` typo) and consider `vce(cluster school_21)` in place of `robust`. |
| — (no R equivalent) | Tables 4, 5 and 6 of the paper (**new do files needed**) | There is no script in either language for the pairwise balance differences (Table 4), year-specific first stage (Table 5) or heterogeneous first stage (Table 6). They follow the same `reghdfe` pattern as `balance.do` and `first stage.do`. |

Once these are in place, the R scripts are no longer needed to produce the
results. The Stata sequence is:

`clean_ka_22_23.do` → `control_selection.do` → `balance.do` →
`first stage.do` → `heterogeneity RFE (pooled).do` → `RFE ddml.do` →
`av_table.do` → `IV ddml - method 1.do`.
