* ==============================================================================
* 01_analysis_panel.do  --  the analysis dataset (student x AY 2022, 2023)
* Ported from  clean_ka_22_23.do lines 312-657
* Reads   $IN_ATEMA_TREATMENT, $IN_END_ENROLLMENT, Khan usage
* Writes  $ATEMA_DATA/master_khan_student_combined.dta
* Normalization  raw scores winsorized 1/99 within year x GRADE_ID_FK over every
*   student expected to test, standardized on the not-yet-treated of the cell
*   (control + arms 3-4 in 2021-22; control in 2022-23)
* ==============================================================================
version 15.1
* >>> [NEW] setup block
if "$ATEMA_SETUP" != "1" & "$DATA_SOURCE" == "old" {
	* >>> [NEW] old-data mode: set DATA_SOURCE and ATEMA_CODE_DIR as in run_atema.do first
	do "$ATEMA_CODE_DIR/00_setup.do"
}
if "$ATEMA_SETUP" != "1" {
	local _r ""
	cap confirm file "D:/SECURE/data 2024/2026 Paper/config.do"
	if !_rc local _r "D:/SECURE/data 2024/2026 Paper"
	if "`_r'" == "" local _r : environment PRDE_ROOT
	if "`_r'" == "" {
		local _h : environment HOME
		if "`_h'" == "" local _h : environment USERPROFILE
		foreach _d in "Documents/2026_server" "Documents/GitHub/2026_server" "Projects/2026_server" "code/2026_server" "2026_server" {
			cap confirm file "`_h'/`_d'/config.do"
			if !_rc & "`_r'" == "" local _r "`_h'/`_d'"
		}
	}
	do "`_r'/01. Code/06. Layer 4/ATEMA/00_setup.do" "`_r'"
}
atema_log 01_analysis_panel

* 1. Baseline sample, one copy per outcome year
* >>> [FIX] read from Layer 3 (old read prepare\build\output; other scripts a different copy)
use "$IN_ATEMA_TREATMENT", clear
* >>> [NEW] guarantee one row per student before duplicating
isid SMAX_STUDENT_ID
rename (ACADEMIC_YEAR_ID_FK SCHOOL_CODE GRADE_ID_FK) (base_year school_21 grade_21)
* >>> [FIX] keep the baseline flag under its own name, so it cannot be mistaken for
* >>>       the outcome-year flag (the old bug, see step 3)
cap rename flag_no_tests_expected b_flag_no_tests_expected
cap rename english_name english_name_21
foreach v in MATH_SCALE_SCORE ENGLISH_SCALE_SCORE SPANISH_SCALE_SCORE SCIENCE_SCALE_SCORE ///
             MATH_score_norm ENGLISH_score_norm SPANISH_score_norm SCIENCE_score_norm {
	cap drop `v'
}
* >>> [CLEAN] accented names -> ASCII once (old: renamed separately in 4 scripts)
cap rename b_Español_38avg    b_espanol_38avg
cap rename b_Matemáticas_38avg b_matematicas_38avg
cap rename b_Inglés_38avg     b_ingles_38avg
foreach v in treat_arm_1 treat_arm_2 treat_arm_3 treat_arm_4 control ///
             teach_treat1 teach_treat2 teach_treat3 teach_treat4 teach_control {
	cap replace `v' = 0 if missing(`v')
}
* >>> [NEW] every baseline student has exactly one arm
assert treat_arm_1 + treat_arm_2 + treat_arm_3 + treat_arm_4 + control == 1

expand 2
bysort SMAX_STUDENT_ID: gen int ACADEMIC_YEAR_ID_FK = 2021 + _n
tempfile base
save `base'

* 2. Outcome-year records
* >>> [CLEAN] load only the needed rows/columns (old merged all 5.3 million rows first)
* >>> [FIX] the outcome-year flag_no_tests_expected is now loaded (old keepusing() left it out)
use SMAX_STUDENT_ID ACADEMIC_YEAR_ID_FK SCHOOL_CODE GRADE_ID_FK MATH_SCALE_SCORE ///
    ENGLISH_SCALE_SCORE SPANISH_SCALE_SCORE flag_no_tests_expected ///
    using "$IN_END_ENROLLMENT" if inlist(ACADEMIC_YEAR_ID_FK, 2022, 2023) & inrange(GRADE_ID_FK, 6, 10), clear
isid SMAX_STUDENT_ID ACADEMIC_YEAR_ID_FK
rename flag_no_tests_expected eoy_flag_no_tests
if $LEGACY {
	* >>> [LEGACY] old rule: strip the 33 prefix only when there is a math score
	replace SCHOOL_CODE = real(substr(string(SCHOOL_CODE, "%12.0f"), 3, .)) ///
		if SCHOOL_CODE >= 100000 & !missing(SCHOOL_CODE) & !missing(MATH_SCALE_SCORE)
}
else {
	* >>> [FIX] strip the 33 prefix from every school code
	replace SCHOOL_CODE = real(substr(string(SCHOOL_CODE, "%12.0f"), 3, .)) ///
		if SCHOOL_CODE >= 100000 & !missing(SCHOOL_CODE)
}
atema_merge_khan
tempfile eoy
save `eoy'

* 3. Put them together
use `base', clear
merge 1:1 SMAX_STUDENT_ID ACADEMIC_YEAR_ID_FK using `eoy', keep(master match) gen(_m)
gen byte found_eoy = (_m == 3)
drop _m
label var found_eoy "Found in the end-of-year file, grades 4-8"
* same as old: students not found keep the grade they would have reached
replace GRADE_ID_FK = grade_21 + (ACADEMIC_YEAR_ID_FK - 2022) if !found_eoy
keep if inrange(GRADE_ID_FK, 6, 10)
foreach v in ka_login ka_minutes ka_skills ka_familiar {
	replace `v' = 0 if missing(`v')
}
* >>> [LEGACY] old: baseline (2021-22 start-of-year) flag used for BOTH outcome years
* >>> [FIX]    new: the outcome year's own flag
if $LEGACY gen byte flag_test = b_flag_no_tests_expected
else       gen byte flag_test = cond(found_eoy, eoy_flag_no_tests, 1)
label var flag_test "1 = no valid test expected (outcome year)"

* 4. Outcomes
gen byte ref = (control == 1) | (inlist(1, treat_arm_3, treat_arm_4) & ACADEMIC_YEAR_ID_FK == 2022)
label var ref "Not yet treated (normalization and control-mean group)"

* >>> [CLEAN] one loop replaces six pasted blocks (3 subjects x 2 years); same formula
foreach pair in "MATH math" "ENGLISH eng" "SPANISH spa" {
	tokenize `pair'
	gen double `2'_score = .
	foreach y of global OUT_YEARS {
		foreach g of global OUT_GRADES {
			local c "ACADEMIC_YEAR_ID_FK == `y' & GRADE_ID_FK == `g' & flag_test == 0 & !missing(`1'_SCALE_SCORE)"
			* >>> [NEW] a cell too small to standardize is left missing, with a message
			quietly count if `c' & ref
			if r(N) < 2 {
				di as text "  `1' `y' grade `g': reference cell too small, left missing"
				continue
			}
			quietly winsor `1'_SCALE_SCORE if `c', gen(_w) p($WINSOR_P)
			quietly summarize _w if `c' & ref
			quietly replace `2'_score = (_w - r(mean)) / r(sd) if `c'
			drop _w
		}
	}
	label var `2'_score "`1' score, SD of the not-yet-treated in year x grade"
}

* 5. Take-up
* >>> [CLEAN] 145 / 155 now come from 00_params.do (5 minutes x weeks), not typed in
gen byte takeup = 0
foreach y of global OUT_YEARS {
	replace takeup = (ka_minutes >= $TAKEUP_MINWK * ${WEEKS_`y'}) if ACADEMIC_YEAR_ID_FK == `y'
}
label var takeup "Take-up: >= $TAKEUP_MINWK min/week on average (total over the year)"

* 6. Treatment indicators of equation (1) -- same definitions as old
gen byte atema_st    = (treat_arm_1 == 1 & ACADEMIC_YEAR_ID_FK == 2022) | (inlist(1, treat_arm_3, treat_arm_4) & ACADEMIC_YEAR_ID_FK == 2023)
gen byte atema_pe_st = (treat_arm_2 == 1 & ACADEMIC_YEAR_ID_FK == 2022)
gen byte atema_lt    = (treat_arm_1 == 1 & ACADEMIC_YEAR_ID_FK == 2023)
gen byte atema_pe_lt = (treat_arm_2 == 1 & ACADEMIC_YEAR_ID_FK == 2023)
label var atema_st    "Treatment (short-term)"
label var atema_pe_st "Parental engagement (short-term)"
label var atema_lt    "Treatment (long-term)"
label var atema_pe_lt "Parental engagement (long-term)"
cap confirm variable teach_treat1
if !_rc {
	gen byte t_atema_st    = (teach_treat1 == 1 & ACADEMIC_YEAR_ID_FK == 2022) | (inlist(1, teach_treat3, teach_treat4) & ACADEMIC_YEAR_ID_FK == 2023)
	gen byte t_atema_pe_st = (teach_treat2 == 1 & ACADEMIC_YEAR_ID_FK == 2022)
	gen byte t_atema_lt    = (teach_treat1 == 1 & ACADEMIC_YEAR_ID_FK == 2023)
	gen byte t_atema_pe_lt = (teach_treat2 == 1 & ACADEMIC_YEAR_ID_FK == 2023)
}
* >>> [DECIDE] flags long-term rows never eligible in year 1 (3rd graders of 2021-22);
* >>>          used only if LT_DROP_INELIGIBLE = 1 and in the robustness table
gen byte lt_ineligible = inlist(1, treat_arm_1, treat_arm_2) & ACADEMIC_YEAR_ID_FK == 2023 & grade_21 == 5
label var lt_ineligible "Long-term treated but not eligible in 2021-22 (3rd grade)"

* 7. Fixed effects, built ONCE here
* >>> [CLEAN] old: every table script re-made strata x year; some then crashed renaming it
egen int strata_yr = group(strata ACADEMIC_YEAR_ID_FK)
gen int grade_fe = $GRADE_FE
label var strata_yr "Stratum x year"
label var grade_fe  "Grade fixed effect ($GRADE_FE)"

* >>> [NEW] checks, and shares only (no counts) in the log
isid SMAX_STUDENT_ID ACADEMIC_YEAR_ID_FK
assert atema_st + atema_pe_st + atema_lt + atema_pe_lt <= 1
foreach y of global OUT_YEARS {
	quietly summarize found_eoy if ACADEMIC_YEAR_ID_FK == `y', meanonly
	di as result "  AY `y': share found at end of year " %6.4f r(mean)
	quietly count if ACADEMIC_YEAR_ID_FK == `y' & !missing(math_score)
	local k = r(N)
	quietly count if ACADEMIC_YEAR_ID_FK == `y'
	di as result "           share with a math outcome   " %6.4f `k'/r(N)
}

order SMAX_STUDENT_ID ACADEMIC_YEAR_ID_FK school_21 grade_21 SCHOOL_CODE GRADE_ID_FK found_eoy
sort SMAX_STUDENT_ID ACADEMIC_YEAR_ID_FK
compress
label data "Layer 4 ATEMA: analysis panel, baseline students x AY 2022-2023 (`c(current_date)')"
* >>> [CLEAN] one save (old saved before the treatment indicators existed, then again)
save "$ATEMA_DATA/master_khan_student_combined.dta", replace

atema_log_close
