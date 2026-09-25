* ==============================================================================
* 00_params.do  --  every analysis decision, in ONE place
* ==============================================================================
* >>> [NEW] whole file: the old scripts re-made these choices in every file,
* >>>       often inconsistently
if "$LEGACY" == "" global LEGACY 0

* --- Khan usage source --------------------------------------------------------------
* >>> [FIX] "rebuilt" = usage summed within academic year (see 00_khan_usage.do)
* >>> [LEGACY] "L3" = Layer 3 file, which reproduces the old (cross-year) sums
global KHAN_SOURCE "rebuilt"
* >>> [CLEAN] the old code's unexplained week numbers, now named: Stata dates of
* >>>         22 Nov 2021, 20 Dec 2021, 27 Dec 2021, 3 Jan 2022, 11 Apr 2022,
* >>>         21 Nov 2022, 19 Dec 2022, 26 Dec 2022, 2 Jan 2023 (holiday weeks)
global KHAN_DROP_WEEKS "22605 22633 22640 22647 22745 22969 22997 23004 23011"

* --- design (from the paper) -------------------------------------------------------
global OUT_YEARS  "2022 2023"
global OUT_GRADES "6 7 8 9 10"
* >>> [FIX] always the baseline school (old: SCHOOL_CODE = current school in RFE ddml
* >>>       above-median and complier_characteristics)
global CLUSTER    "school_21"
* >>> [DECIDE] old files mixed grade_21 (first stage, av tables) and GRADE_ID_FK (DDML,
* >>>          heterogeneity).  One choice for all tables now.
global GRADE_FE   "GRADE_ID_FK"
global FE_ABSORB  "strata_yr grade_fe"
global WINSOR_P   0.01

* --- take-up -------------------------------------------------------------------------
* >>> [DECIDE] paper says ">=5 min per week"; the code uses total >= 5 x weeks.
* >>> [FIX] one definition everywhere (old: >=145/155 in clean_ka_22_23, >145/145 in
* >>>       clean_ka_17_23, >=145/145 in the event studies)
global TAKEUP_MINWK 5
global WEEKS_2022   29
global WEEKS_2023   31

* --- samples ---------------------------------------------------------------------------
* >>> [DECIDE] first stage on all baseline students (usage 0 if not found) or found only
global FS_SAMPLE    "all"
* >>> [DECIDE] Table 2 says "Controls: Yes"; old first stage.do had none
global FS_CONTROLS  1
* >>> [DECIDE] Table 1 caption says grades 4-8; old code also kept 3rd graders
global BALANCE_GRADES "6 7 8 9 10"
* >>> [DECIDE] arm 1-2 students in 3rd grade in 2021-22 are coded long-term treated
* >>>          but were never eligible in year 1; 1 = drop those rows everywhere
global LT_DROP_INELIGIBLE 0
* >>> [FIX] Table 5, AY 2021-22: comparison group = the group of the control mean
global T5_REF2022 "pooled"

* --- controls ----------------------------------------------------------------------------
* >>> [FIX] "pds" = real post-double-selection per outcome
* >>> [LEGACY] "legacy" = the list typed by hand in the old control_selection.do
global CONTROLS "pds"
global FORCED_CONTROLS "b_math_21 missing_b_math_21 b_math_19 missing_b_math_19 b_GPA_mate missing_b_GPA_mate"
global PDS_OUTCOMES "math_score eng_score spa_score ka_login ka_minutes ka_skills ka_familiar takeup"

global BASE_CONTROLS "b_math_21 b_eng_21 b_spa_21 b_poverty_21 b_math_19 b_eng_19 b_spa_19 b_poverty_19 b_GPA b_GPA_mate b_GPA_ingl b_GPA_espa b_ANNUAL_INCOME b_INTERNET_AT_HOME b_adult_flag b_s_total_graduated b_s_total_dropped b_students_enrolled b_special_ed b_total_enrollment b_pupil_teacher_ratio b_city b_suburb b_town_rural b_female_teach b_ps_teach b_ms_teach b_permanent b_teach_exp02 b_teach_exp36 b_teach_exp7 b_displaced_student b_ABSENCE_COUNT_YEAR b_espanol_38avg b_matematicas_38avg b_ingles_38avg b_gr38_avg b_ARECIBO b_BAYAMON b_CAGUAS b_HUMACAO b_MAYAGUEZ b_PONCE b_SANJUAN"
* >>> [CLEAN] same short names as the old rename, so old interaction names still work
global CTRL_LONG  "b_math_21 b_eng_21 b_spa_21 b_poverty_21 b_math_19 b_eng_19 b_spa_19 b_GPA b_GPA_mate b_GPA_ingl b_GPA_espa b_ANNUAL_INCOME b_INTERNET_AT_HOME b_adult_flag b_s_total_graduated b_s_total_dropped b_students_enrolled b_pupil_teacher_ratio b_special_ed b_city b_suburb b_town_rural b_female_teach b_ps_teach b_ms_teach b_permanent b_teach_exp02 b_teach_exp36 b_teach_exp7 b_displaced_student b_ABSENCE_COUNT_YEAR b_espanol_38avg b_matematicas_38avg b_ingles_38avg b_gr38_avg b_poverty_19 b_ARECIBO b_BAYAMON b_CAGUAS b_HUMACAO b_MAYAGUEZ b_PONCE b_SANJUAN"
global CTRL_SHORT "math_21 eng_21 spa_21 pov_21 math_19 eng_19 spa_19 gpa gpa_m gpa_e gpa_s income internet adult t_grad t_drop t_enrol pt_ratio sp_ed cit sub rural t_female p_teach m_teach perm_t t_02 t_36 t_7 s_disp abs_y s_38 m_38 e_38 gr38 pov_19 r_AR r_BA r_CA r_HU r_MA r_PO r_SJ"
* >>> [LEGACY] old control_selection.do line 235, copied exactly
global LEGACY_CONTROLS "b_math_21 missing_b_math_21 b_special_ed missing_b_special_ed gender b_math_19 missing_b_math_19 b_spa_19 missing_b_spa_19 missing_b_spa_21 b_eng_21 missing_b_eng_21 b_eng_21_sq b_GPA missing_b_GPA b_ABSENCE_COUNT_YEAR missing_b_ABSENCE_COUNT_YEAR b_ABSENCE_COUNT_YEAR_sq b_GPA_mate missing_b_GPA_mate b_GPA_espa missing_b_GPA_espa b_ANNUAL_INCOME missing_b_ANNUAL_INCOME b_gr38_avg missing_b_gr38_avg x_adult_r_PO x_eng_21_eng_19 x_eng_21_gpa_m x_eng_21_gpa_e x_eng_21_gpa_s x_eng_21_sp_ed x_math_19_gpa x_gpa_sp_ed x_gpa_m_gpa_e x_gpa_m_gpa_s x_gpa_m_income x_gpa_s_sp_ed"

* >>> [CLEAN] the seven nested sets of the old av_table (RFE).do, typed once
global SPEC_1 "b_math_21 missing_b_math_21 gender b_special_ed"
global SPEC_2 "$SPEC_1 b_math_19 missing_b_math_19"
global SPEC_3 "$SPEC_2 b_spa_19 missing_b_spa_19 missing_b_spa_21 b_eng_21 b_eng_21_sq missing_b_eng_21 missing_b_eng_19"
global SPEC_4 "$SPEC_3 b_GPA missing_b_GPA"
global SPEC_5 "$SPEC_4 b_GPA_mate missing_b_GPA_mate b_GPA_espa missing_b_GPA_espa missing_b_GPA_ingl b_ABSENCE_COUNT_YEAR b_ABSENCE_COUNT_YEAR_sq b_ANNUAL_INCOME missing_b_ANNUAL_INCOME"
global SPEC_6 "$SPEC_5 b_gr38_avg missing_b_gr38_avg"
global SPEC_7 "$SPEC_6 x_math_19_gpa x_eng_21_gpa_m x_eng_21_eng_19 x_eng_21_gpa_e x_eng_21_gpa_s x_eng_21_sp_ed x_gpa_m_gpa_s x_gpa_m_gpa_e x_gpa_m_income x_gpa_s_sp_ed x_gpa_sp_ed"

* --- balance rows "variable|label" ------------------------------------------------------
* >>> [DECIDE] verify names against atema_treatment (Layer 3 may rename teacher vars,
* >>>          e.g. permanent_asof; the old female_teach is flagged as wrong in the README)
* >>> [FIX] Poverty (2021) row now uses b_poverty_21 (old used "poverty")
* >>> [CLEAN] dropped rows that are always 1 (Math teacher) or not in the paper (class size)
global BAL_STUDENT `" "gender|Female" "sa_age|Age" "special_ed|Special education" "b_poverty_21|Poverty (2021)" "b_math_21|Math score (2021)" "b_eng_21|English score (2021)" "b_spa_21|Spanish score (2021)" "b_math_19|Math score (2019)" "b_GPA|GPA (2021)" "b_GPA_mate|Math GPA (2021)" "'
global BAL_SCHOOL  `" "total_enrollment|Total enrollment" "pupil_teacher_ratio|Student-to-teacher ratio" "town_rural|Rural" "espanol_38avg|Spanish average (grades 3-8)" "matematicas_38avg|Math average (grades 3-8)" "ingles_38avg|English average (grades 3-8)" "wms|WMS" "'
global BAL_TEACHER `" "female_teach|Female" "ps_teach|Primary school" "ms_teach|Middle school" "permanent|Permanent" "teach_exp02|0-2 years of experience" "teach_exp36|3-6 years of experience" "teach_exp7|7+ years of experience" "eng_teach|English" "spa_teach|Spanish" "'

* --- estimation --------------------------------------------------------------------------
global SEED      12345
global DDML_K    5
* >>> [CLEAN] 200 repetitions on the server (as before); 2 locally so a test run finishes
global DDML_REPS = cond("$ATEMA_ENV" == "server", 200, 2)
global TOT_ENDOG "takeup"
global MATCH_NN  "1 3 5"

* --- teacher transfers (needs Layer 2B variable names; check schemas.json) -----------------
* >>> [DECIDE] off until the names below are verified
global DO_TEACHER_TRANSFERS 0
global L2B_KEEP        "core_subject"
global L2B_MATH_FILTER `"core_subject == "MATH""'

* --- LEGACY overrides ------------------------------------------------------------------------
* >>> [LEGACY] reproduce the old tables
if $LEGACY {
	global KHAN_SOURCE    "L3"
	global CONTROLS       "legacy"
	global BALANCE_GRADES "5 6 7 8 9 10"
	global FS_CONTROLS    0
	global T5_REF2022     "pure"
}

* --- quick "does it run" test ------------------------------------------------------------
* >>> [NEW] set in run_atema.do; fewer DDML repetitions/folds and one matching variant, so
* >>>       a trial run finishes in reasonable time.  Estimates from it are NOT results.
if "$QUICK_TEST" == "" global QUICK_TEST 0
if $QUICK_TEST {
	global DDML_REPS 2
	global DDML_K    2
	global MATCH_NN  "1"
}

* --- old-data mode ---------------------------------------------------------------------------
* >>> [NEW] the old tree has no usable teacher link, so teacher transfers stay off.
* >>>       KHAN_SOURCE "L3" here means the OLD khan_per_student_combined file.
if "$DATA_SOURCE" == "old" {
	global DO_TEACHER_TRANSFERS 0
}

global SAMPLE_IF ""
if $LT_DROP_INELIGIBLE global SAMPLE_IF "& lt_ineligible == 0"
