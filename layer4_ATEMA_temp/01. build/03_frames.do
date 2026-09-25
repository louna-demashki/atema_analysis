* ==============================================================================
* 03_frames.do  --  one row per student, per school, per math teacher (for balance)
* Replaces the "first student of each school/teacher" trick in the old balance scripts
* Writes  atema_baseline.dta, atema_schools.dta, atema_teachers.dta
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
atema_log 03_frames

* >>> [FIX] read atema_treatment directly from Layer 3 (old balance read data\interim and
* >>>       merged master_khan_student_combined 1:m just to get b_ scores, then kept a
* >>>       random row; the b_ scores are already in atema_treatment)
use "$IN_ATEMA_TREATMENT", clear
isid SMAX_STUDENT_ID
rename (SCHOOL_CODE GRADE_ID_FK) (school_21 grade_21)
foreach v in treat_arm_1 treat_arm_2 treat_arm_3 treat_arm_4 control ///
             teach_treat1 teach_treat2 teach_treat3 teach_treat4 teach_control {
	cap replace `v' = 0 if missing(`v')
}
* >>> [CLEAN] pooled arm made once (old: balance_pooled and pairwise-pooled each rebuilt it)
gen byte treat_arm_34 = inlist(1, treat_arm_3, treat_arm_4)
cap gen byte teach_treat34 = inlist(1, teach_treat3, teach_treat4)
cap rename Español_38avg     espanol_38avg
cap rename Matemáticas_38avg matematicas_38avg
cap rename Inglés_38avg      ingles_38avg
cap gen byte wms = !missing(management, people, targets, monitoring, operations)
cap label var wms "School took the management survey (WMS)"
tempfile all
save `all'

* --- students --------------------------------------------------------------------------
* >>> [DECIDE] BALANCE_GRADES: 4th-8th grade by default (old kept 3rd grade too, while
* >>>          the table title said grades 4 to 8)
local gl : subinstr global BALANCE_GRADES " " ",", all
keep if inlist(grade_21, `gl')
compress
label data "Layer 4 ATEMA: baseline students, one row each (`c(current_date)')"
save "$ATEMA_DATA/atema_baseline.dta", replace

* --- schools -------------------------------------------------------------------------------
use `all', clear
* >>> [NEW] arms and strata must be constant within school
foreach v in treat_arm_1 treat_arm_2 treat_arm_3 treat_arm_4 control strata {
	bysort school_21 (`v'): assert `v'[1] == `v'[_N]
}
* >>> [FIX] one row per school, picked the same way every run (old: bysort SCHOOL_CODE:
* >>>       gen school=_n, a different "first student" each run)
bysort school_21 (SMAX_STUDENT_ID): keep if _n == 1
local sv ""
foreach item of global BAL_SCHOOL {
	gettoken v rest : item, parse("|")
	local sv `sv' `v'
}
atema_keep_existing `sv' above_median
keep school_21 strata treat_arm_1 treat_arm_2 treat_arm_3 treat_arm_4 treat_arm_34 control `r(varlist)'
isid school_21
compress
label data "Layer 4 ATEMA: baseline schools, one row each (`c(current_date)')"
save "$ATEMA_DATA/atema_schools.dta", replace

* --- teachers ------------------------------------------------------------------------------
use `all', clear
cap confirm variable SMAX_STAFF_IDMATH teach_treat1
if _rc {
	di as error "  no SMAX_STAFF_IDMATH / teach_treat* in atema_treatment: teacher frame skipped"
}
else {
	* >>> [FIX] students with no teacher id are not a "teacher" (old: they formed one
	* >>>       extra phantom teacher in the balance table)
	drop if missing(SMAX_STAFF_IDMATH)
	* >>> [FIX] a teacher's school = where most of their students are (old: an arbitrary
	* >>>       student's school, grade and cluster)
	bysort SMAX_STAFF_IDMATH school_21: gen long _ns = _N
	bysort SMAX_STAFF_IDMATH (_ns school_21 SMAX_STUDENT_ID): keep if _n == _N
	local tv ""
	foreach item of global BAL_TEACHER {
		gettoken v rest : item, parse("|")
		local tv `tv' `v'
	}
	atema_keep_existing `tv'
	keep SMAX_STAFF_IDMATH school_21 strata teach_treat1 teach_treat2 teach_treat3 teach_treat4 ///
	     teach_treat34 teach_control `r(varlist)'
	isid SMAX_STAFF_IDMATH
	compress
	label data "Layer 4 ATEMA: baseline math teachers, one row each (`c(current_date)')"
	save "$ATEMA_DATA/atema_teachers.dta", replace
}

atema_log_close
