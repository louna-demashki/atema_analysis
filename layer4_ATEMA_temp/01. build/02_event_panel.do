* ==============================================================================
* 02_event_panel.do  --  2017-2023 panel for the event studies
* Ported from  clean_ka_17_23.do
* Reads   $IN_END_ENROLLMENT, $IN_ATEMA_TREATMENT, Khan usage
* Writes  $ATEMA_DATA/master_2017_2023.dta
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
atema_log 02_event_panel

* >>> [FIX] same baseline file as the analysis panel (old read analysis\atema\data\interim,
* >>>       a different copy than clean_ka_22_23 used)
use SMAX_STUDENT_ID SCHOOL_CODE GRADE_ID_FK strata treat_arm_1 treat_arm_2 treat_arm_3 treat_arm_4 control ///
    using "$IN_ATEMA_TREATMENT", clear
isid SMAX_STUDENT_ID
rename (SCHOOL_CODE GRADE_ID_FK) (school_21 grade_21)
foreach v in treat_arm_1 treat_arm_2 treat_arm_3 treat_arm_4 control {
	replace `v' = 0 if missing(`v')
}
tempfile b
save `b'

* >>> [CLEAN] load only the needed years (old loaded 2010-2023 then dropped)
use SMAX_STUDENT_ID ACADEMIC_YEAR_ID_FK GRADE_ID_FK SCHOOL_CODE MATH_SCALE_SCORE flag_no_tests_expected ///
    using "$IN_END_ENROLLMENT" if inlist(ACADEMIC_YEAR_ID_FK, 2017, 2018, 2019, 2022, 2023), clear
* same grade windows as old
keep if (ACADEMIC_YEAR_ID_FK == 2017 & inrange(GRADE_ID_FK, 3, 5)) | ///
        (ACADEMIC_YEAR_ID_FK == 2018 & inrange(GRADE_ID_FK, 3, 6)) | ///
        (ACADEMIC_YEAR_ID_FK == 2019 & inrange(GRADE_ID_FK, 3, 7)) | ///
        (ACADEMIC_YEAR_ID_FK == 2022 & inrange(GRADE_ID_FK, 5, 10)) | ///
        (ACADEMIC_YEAR_ID_FK == 2023 & inrange(GRADE_ID_FK, 6, 11))
isid SMAX_STUDENT_ID ACADEMIC_YEAR_ID_FK
atema_merge_khan
merge m:1 SMAX_STUDENT_ID using `b', keep(match) nogen

gen byte _tk = 0
foreach y in 2022 2023 {
	* >>> [LEGACY] old: minutes > 145 in both years
	* >>> [FIX] same threshold as the analysis panel
	if $LEGACY replace _tk = (ka_minutes > 145) if ACADEMIC_YEAR_ID_FK == `y'
	else       replace _tk = (ka_minutes >= $TAKEUP_MINWK * ${WEEKS_`y'}) if ACADEMIC_YEAR_ID_FK == `y'
}
bysort SMAX_STUDENT_ID: egen byte takeup1 = max(_tk * (ACADEMIC_YEAR_ID_FK == 2022))
bysort SMAX_STUDENT_ID: egen byte takeup2 = max(_tk * (ACADEMIC_YEAR_ID_FK == 2023))
drop _tk
* >>> [CLEAN] user types built once here (old event_study_by_grade.do rebuilt them itself)
gen byte takeup_only1 = takeup1 == 1 & takeup2 == 0
gen byte takeup_only2 = takeup1 == 0 & takeup2 == 1
gen byte takeup_both  = takeup1 == 1 & takeup2 == 1
label var takeup1 "Took up in AY 2021-22"
label var takeup2 "Took up in AY 2022-23"

* >>> [CLEAN] one loop replaces six pasted blocks; same formula (all students of the cell)
gen double math_score = .
foreach y in 2017 2018 2019 2022 2023 {
	forvalues g = 5/10 {
		if `g' == 10 & `y' == 2023 continue
		* >>> [LEGACY] the old script never normalized 4th graders of 2022-23 (omission)
		if $LEGACY & `g' == 5 & `y' == 2023 continue
		local c "ACADEMIC_YEAR_ID_FK == `y' & grade_21 == `g' & flag_no_tests_expected == 0 & !missing(MATH_SCALE_SCORE)"
		quietly count if `c'
		if r(N) < 2 continue
		quietly winsor MATH_SCALE_SCORE if `c', gen(_w) p($WINSOR_P)
		quietly summarize _w if `c'
		quietly replace math_score = (_w - r(mean)) / r(sd) if `c'
		drop _w
	}
}
label var math_score "Math score, SD within year x baseline grade (all students)"

foreach y in 17 18 19 22 23 {
	gen _g = GRADE_ID_FK if ACADEMIC_YEAR_ID_FK == 20`y'
	bysort SMAX_STUDENT_ID: egen grade_`y' = max(_g)
	drop _g
}
gen double math_score_adj = math_score
replace math_score_adj = . if ACADEMIC_YEAR_ID_FK == 2023 & grade_23 != grade_21 + 1
replace math_score_adj = . if ACADEMIC_YEAR_ID_FK == 2019 & grade_19 != grade_21 - 3
replace math_score_adj = . if ACADEMIC_YEAR_ID_FK == 2018 & grade_18 != grade_21 - 4
replace math_score_adj = . if ACADEMIC_YEAR_ID_FK == 2017 & grade_17 != grade_21 - 5
* >>> [LEGACY] old: a missing 2019 grade made this true, wiping the 2022 score of every
* >>>          student with no 2019 record (the whole 3rd-grade cohort, all new entrants)
* >>> [FIX] only compare when a 2019 grade exists
if $LEGACY replace math_score_adj = . if ACADEMIC_YEAR_ID_FK == 2022 & grade_22 != grade_19 + 3
else       replace math_score_adj = . if ACADEMIC_YEAR_ID_FK == 2022 & !missing(grade_19) & grade_22 != grade_19 + 3
replace math_score_adj = . if inlist(grade_21, 5, 6, 7) & inlist(ACADEMIC_YEAR_ID_FK, 2017, 2018, 2019)
replace math_score_adj = . if grade_21 == 8 & inlist(ACADEMIC_YEAR_ID_FK, 2017, 2018)
replace math_score_adj = . if grade_21 == 9 & ACADEMIC_YEAR_ID_FK == 2017
label var math_score_adj "Math score, students on their cohort's grade path"

egen int ay_grade = group(ACADEMIC_YEAR_ID_FK grade_21)
label var ay_grade "Year x baseline grade"

* >>> [NEW] check
isid SMAX_STUDENT_ID ACADEMIC_YEAR_ID_FK
sort SMAX_STUDENT_ID ACADEMIC_YEAR_ID_FK
compress
label data "Layer 4 ATEMA: 2017-2023 panel for event studies (`c(current_date)')"
save "$ATEMA_DATA/master_2017_2023.dta", replace

atema_log_close
