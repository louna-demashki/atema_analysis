* ==============================================================================
* 04_transfers.do  --  where students (teachers) were after baseline
* Ported from  the data half of treatment_changes.do and treatment_changes - math.do
* Writes  transfers_students.dta, transfers_teachers.dta (if enabled)
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
atema_log 04_transfers

* >>> [FIX] arms from Layer 3 school_arms (old: prepare\build\input\treatment_control_atema)
* >>> [FIX] prefix stripped, so 33-prefixed schools no longer look like "left the system"
use "$IN_SCHOOL_ARMS", clear
* >>> [NEW] the old file (treatment_control_atema) has treat1 / treat2 / treat_info
* >>>       instead of atema_arm: build the arm (0 control, 1-4) the way the old
* >>>       treatment_changes.do did
cap confirm variable atema_arm
if _rc {
	gen byte atema_arm = 0
	replace atema_arm = 1 if treat1 == 1 & treat_info == 0
	replace atema_arm = 2 if treat1 == 1 & treat_info == 1
	replace atema_arm = 3 if treat2 == 1 & treat_info == 0
	replace atema_arm = 4 if treat2 == 1 & treat_info == 1
}
keep SCHOOL_CODE atema_arm
replace SCHOOL_CODE = real(substr(string(SCHOOL_CODE, "%12.0f"), 3, .)) if SCHOOL_CODE >= 100000 & !missing(SCHOOL_CODE)
drop if missing(SCHOOL_CODE)
duplicates drop SCHOOL_CODE, force
rename atema_arm cur_arm
tempfile arms
save `arms'

* --- students --------------------------------------------------------------------------------
use SMAX_STUDENT_ID ACADEMIC_YEAR_ID_FK school_21 grade_21 SCHOOL_CODE found_eoy ///
    treat_arm_1 treat_arm_2 treat_arm_3 treat_arm_4 control math_score ///
    using "$ATEMA_DATA/master_khan_student_combined.dta", clear
gen byte base_arm = 1*treat_arm_1 + 2*treat_arm_2 + 3*treat_arm_3 + 4*treat_arm_4
merge m:1 SCHOOL_CODE using `arms', keep(master match) nogen
replace cur_arm = . if !found_eoy

* >>> [CLEAN] six mutually exclusive categories (old: ~2,900 lines of per-grade copies)
gen byte tr_notfound   = !found_eoy
gen byte tr_same_sch   = found_eoy & SCHOOL_CODE == school_21
gen byte tr_same_arm   = found_eoy & !tr_same_sch & cur_arm == base_arm
gen byte tr_to_control = found_eoy & !tr_same_sch & cur_arm == 0 & base_arm != 0
gen byte tr_to_treated = found_eoy & !tr_same_sch & inrange(cur_arm, 1, 4) & cur_arm != base_arm
gen byte tr_outside    = found_eoy & !tr_same_sch & missing(cur_arm)
* >>> [NEW] every row in exactly one category
assert tr_notfound + tr_same_sch + tr_same_arm + tr_to_control + tr_to_treated + tr_outside == 1
label var tr_notfound   "Not found at end of year"
label var tr_same_sch   "Same school"
label var tr_same_arm   "Other school, same arm"
label var tr_to_control "Moved to a control school"
label var tr_to_treated "Moved to a school of another treated arm"
label var tr_outside    "Moved to a school outside the experiment"
compress
* >>> [FIX] one file (old: the math and non-math versions saved the same interim file
* >>>       "transfer_teacher" and overwrote each other)
save "$ATEMA_DATA/transfers_students.dta", replace

* --- teachers -----------------------------------------------------------------------------------
* >>> [CRASH] old read prepare\temp\class_teacher_student_end, which no longer exists;
* >>>         now the Layer 2B link (README section 9)
* >>> [DECIDE] enable after checking the link's variable names in schemas.json
if $DO_TEACHER_TRANSFERS {
	use SMAX_STAFF_ID SCHOOL_CODE ACADEMIC_YEAR_ID_FK $L2B_KEEP using "$IN_L2B_LINK" ///
		if inlist(ACADEMIC_YEAR_ID_FK, 2022, 2023), clear
	keep if $L2B_MATH_FILTER
	replace SCHOOL_CODE = real(substr(string(SCHOOL_CODE, "%12.0f"), 3, .)) if SCHOOL_CODE >= 100000 & !missing(SCHOOL_CODE)
	contract SMAX_STAFF_ID SCHOOL_CODE ACADEMIC_YEAR_ID_FK, freq(n_students)
	bysort SMAX_STAFF_ID ACADEMIC_YEAR_ID_FK (n_students SCHOOL_CODE): keep if _n == _N
	merge m:1 SCHOOL_CODE using `arms', keep(master match) nogen
	rename SMAX_STAFF_ID SMAX_STAFF_IDMATH
	* >>> [FIX] old made SMAX_STAFF_IDMATH unique but merged on SMAX_STAFF_ID
	merge m:1 SMAX_STAFF_IDMATH using "$ATEMA_DATA/atema_teachers.dta", keep(match) ///
		keepusing(school_21 teach_treat1 teach_treat2 teach_treat3 teach_treat4) nogen
	gen byte base_arm = 1*teach_treat1 + 2*teach_treat2 + 3*teach_treat3 + 4*teach_treat4
	gen byte tr_same_sch   = SCHOOL_CODE == school_21
	gen byte tr_same_arm   = !tr_same_sch & cur_arm == base_arm
	gen byte tr_to_control = !tr_same_sch & cur_arm == 0 & base_arm != 0
	gen byte tr_to_treated = !tr_same_sch & inrange(cur_arm, 1, 4) & cur_arm != base_arm
	gen byte tr_outside    = !tr_same_sch & missing(cur_arm)
	compress
	save "$ATEMA_DATA/transfers_teachers.dta", replace
}
else {
	di as text "  teacher transfers skipped (DO_TEACHER_TRANSFERS = 0 in 00_params.do)"
	cap erase "$ATEMA_DATA/transfers_teachers.dta"
}

atema_log_close
