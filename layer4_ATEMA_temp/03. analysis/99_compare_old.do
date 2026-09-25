* ==============================================================================
* 99_compare_old.do  --  SERVER ONLY: does the new analysis panel match the old one?
*
* Purpose   README section 9, "reproduce first": compare the new
*           master_khan_student_combined with the old server file, and print
*           AGGREGATES ONLY (shares, means, correlations; never a count), so the
*           log can come back by paste (README section 12).
* Reads     $OLD_MASTER (read-only), $ATEMA_DATA/master_khan_student_combined.dta
* Writes    nothing but its log
* How to use  run once with LEGACY = 1 (differences should be only the ones the
*           README expects: b_ scores, teacher block), then with LEGACY = 0 and
*           write down, in words, what each fix moved.
* ==============================================================================
* >>> [NEW] whole file: the README's "reproduce first" check, made a script
version 15.1
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
if "$ATEMA_ENV" != "server" {
	di as text "99_compare_old.do runs on the server only; nothing to do here."
	exit
}
atema_log 99_compare_old

use SMAX_STUDENT_ID ACADEMIC_YEAR_ID_FK math_score takeup total_math_learning_minutes ///
    treat_arm_1 treat_arm_2 treat_arm_3 treat_arm_4 control using "$OLD_MASTER", clear
drop if missing(ACADEMIC_YEAR_ID_FK)
rename (math_score takeup total_math_learning_minutes) (old_math old_takeup old_minutes)
gen byte old_arm = 1*treat_arm_1 + 2*treat_arm_2 + 3*treat_arm_3 + 4*treat_arm_4
drop treat_arm_* control
duplicates drop SMAX_STUDENT_ID ACADEMIC_YEAR_ID_FK, force
tempfile old
save `old'

use SMAX_STUDENT_ID ACADEMIC_YEAR_ID_FK math_score takeup ka_minutes ///
    treat_arm_1 treat_arm_2 treat_arm_3 treat_arm_4 using "$ATEMA_DATA/master_khan_student_combined.dta", clear
gen byte new_arm = 1*treat_arm_1 + 2*treat_arm_2 + 3*treat_arm_3 + 4*treat_arm_4
merge 1:1 SMAX_STUDENT_ID ACADEMIC_YEAR_ID_FK using `old', gen(_m)

di as result _n "=== rows ==="
foreach y in 2022 2023 {
	quietly count if ACADEMIC_YEAR_ID_FK == `y'
	local t = r(N)
	quietly count if ACADEMIC_YEAR_ID_FK == `y' & _m == 3
	local b = r(N)
	quietly count if ACADEMIC_YEAR_ID_FK == `y' & _m == 1
	local n = r(N)
	quietly count if ACADEMIC_YEAR_ID_FK == `y' & _m == 2
	local o = r(N)
	di as result "AY `y': share in both " %6.4f `b'/`t' "  new only " %6.4f `n'/`t' "  old only " %6.4f `o'/`t'
}

di as result _n "=== shared rows ==="
quietly count if _m == 3 & new_arm == old_arm
local a = r(N)
quietly count if _m == 3
di as result "arm agreement: " %6.4f `a'/r(N)
foreach y in 2022 2023 {
	quietly corr math_score old_math if _m == 3 & ACADEMIC_YEAR_ID_FK == `y'
	di as result "AY `y': corr(math_score new, old) " %6.4f r(rho)
	quietly corr ka_minutes old_minutes if _m == 3 & ACADEMIC_YEAR_ID_FK == `y'
	di as result "        corr(minutes new, old)    " %6.4f r(rho)
	quietly count if _m == 3 & ACADEMIC_YEAR_ID_FK == `y' & takeup == old_takeup
	local a = r(N)
	quietly count if _m == 3 & ACADEMIC_YEAR_ID_FK == `y'
	di as result "        take-up agreement          " %6.4f `a'/r(N)
	quietly count if _m == 3 & ACADEMIC_YEAR_ID_FK == `y' & missing(math_score) != missing(old_math)
	local a = r(N)
	quietly count if _m == 3 & ACADEMIC_YEAR_ID_FK == `y'
	di as result "        score present in one only  " %6.4f `a'/r(N)
}

di as result _n "=== means by arm (shared rows) ==="
forvalues arm = 0/4 {
	foreach y in 2022 2023 {
		quietly summarize math_score if _m == 3 & new_arm == `arm' & ACADEMIC_YEAR_ID_FK == `y', meanonly
		local mn = r(mean)
		quietly summarize old_math if _m == 3 & new_arm == `arm' & ACADEMIC_YEAR_ID_FK == `y', meanonly
		di as result "arm `arm', AY `y': mean math new " %7.4f `mn' "  old " %7.4f r(mean)
	}
}

atema_log_close
