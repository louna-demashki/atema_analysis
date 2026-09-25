* ==============================================================================
* A2_complier_chars.do  --  mean baseline characteristics of compliers
* Ported from  complier_characteristics.do
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
atema_log A2_complier_chars

use "$ATEMA_DATA/master_khan_student_combined.dta", clear
* same sample logic as old (assigned arm vs not-yet-treated), made explicit
keep if atema_lt == 0 & atema_pe_lt == 0

local items `" "gender|Female" "sa_age|Age" "special_ed|Special education" "b_poverty_21|Poverty (2021)" "b_math_21|Math score (2021)" "b_eng_21|English score (2021)" "b_spa_21|Spanish score (2021)" "b_math_19|Math score (2019)" "b_GPA|GPA (2021)" "b_GPA_mate|Math GPA (2021)" "'

atema_res_open A2_complier_chars
local row 0
foreach item of local items {
	gettoken v lab : item, parse("|")
	local lab : subinstr local lab "|" ""
	cap confirm variable `v', exact
	if _rc continue
	local ++row
	* >>> [NEW] all-student mean for comparison
	atema_post_mean `v' if !missing(`v') $SAMPLE_IF, row(`row') col(1) label("`lab'")
	quietly gen double _xt = `v' * takeup
	local c 1
	foreach z in atema_st atema_pe_st {
		local ++c
		* >>> [FIX] cluster by baseline school (old: current SCHOOL_CODE);
		* >>>       stratum x year FE (old: strata only)
		quietly ivreghdfe _xt (takeup = `z') if (`z' == 1 | ref == 1) & !missing(`v') $SAMPLE_IF, ///
			absorb($FE_ABSORB) cluster($CLUSTER)
		atema_post_coef takeup, row(`row') col(`c') label("`lab'")
	}
	drop _xt
}
* >>> [FIX] old teacher block dropped: it used an arbitrary student row per teacher and
* >>>       pooled all students without a teacher id into one "teacher"
atema_res_close
atema_tex using "$ATEMA_OUT/tables/A2_complier_chars.tex", ///
	title("Baseline characteristics of compliers") ///
	collabels(`" "All students" "Compliers: ATEMA" "Compliers: ATEMA + PE" "') ///
	notes("Complier means estimated as the 2SLS coefficient of take-up in a regression of X times take-up, instrumented by assignment, on short-term rows (assigned arm vs not-yet-treated). Stratum-by-year and grade fixed effects. Standard errors clustered by baseline school.")

atema_log_close
