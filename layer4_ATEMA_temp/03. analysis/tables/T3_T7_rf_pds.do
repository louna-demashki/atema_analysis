* ==============================================================================
* T3_T7_rf_pds.do  --  reduced form with post-double-selection controls
* Replaces  heterogeneity RFE (pooled).do, RFE (pooled B) - PDS lasso.do,
*           RFE (pds lasso) - excluding grade 6.do
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
atema_log T3_T7_rf_pds

use "$ATEMA_DATA/master_controls.dta", clear
* >>> [CRASH] old started with "rename strata old_strata", which failed because
* >>>         master_controls already had old_strata (r(110)).  strata_yr is ready-made.
do "$ATEMA_DATA/controls_globals.do"

* >>> [CLEAN] one column-builder instead of the same block pasted per subgroup
cap program drop _rf_column
program define _rf_column
	syntax varname, col(integer) touse(string) [controls(string)]
	local terms "atema_st atema_pe_st atema_lt atema_pe_lt"
	local labs  `" "b1: Treatment (short-term)" "b2: Parental engagement (short-term)" "b3: Treatment (long-term)" "b4: Parental engagement (long-term)" "'
	quietly reghdfe `varlist' `terms' `controls' if `touse', absorb($FE_ABSORB) vce(cluster $CLUSTER)
	local k 0
	foreach t of local terms {
		local ++k
		local lab : word `k' of `labs'
		atema_post_coef `t', row(`k') col(`col') label("`lab'")
	}
	atema_post, row(10) col(`col') stat(N) label("N") b(`=e(N)')
	quietly test atema_st = atema_pe_st
	atema_post, row(5) col(`col') stat(test) label("p-value, b1 = b2") b(`r(p)')
	quietly test atema_st = atema_lt
	atema_post, row(6) col(`col') stat(test) label("p-value, b1 = b3") b(`r(p)')
	quietly test atema_pe_st = atema_pe_lt
	atema_post, row(7) col(`col') stat(test) label("p-value, b2 = b4") b(`r(p)')
	* >>> [FIX] separate short/long-term control means (old: one mean pooling both years)
	atema_post_mean `varlist' if ref == 1 & ACADEMIC_YEAR_ID_FK == 2022 & `touse', row(8) col(`col') label("Control mean (short-term, AY 2021-22)")
	atema_post_mean `varlist' if ref == 1 & ACADEMIC_YEAR_ID_FK == 2023 & `touse', row(9) col(`col') label("Control mean (long-term, AY 2022-23)")
end

* >>> [FIX] primary = grades 4-6 in the outcome year for BOTH short and long term (old
* >>>       silently used grades 5-6 for the long-term "primary" coefficient); the
* >>>       grade-4 long-term question is handled by LT_DROP_INELIGIBLE / column 4 below
local groups `" "1" "above_median == 1" "above_median == 0" "gender == 1" "gender == 0" "inrange(GRADE_ID_FK, 6, 8)" "inrange(GRADE_ID_FK, 9, 10)" "'
* >>> [NEW] English and Spanish (secondary outcomes in the paper) get the same table
foreach y in math_score eng_score spa_score {
	cap confirm variable `y'
	if _rc continue
	atema_res_open T3_T7_rf_pds_`y'
	local col 0
	foreach g of local groups {
		local ++col
		* >>> [FIX] each outcome uses its own selected controls (old: one typed list)
		_rf_column `y', col(`col') touse("(`g') $SAMPLE_IF") controls(${CTRL_`y'})
	}
	atema_res_close
	atema_tex using "$ATEMA_OUT/tables/T3_T7_rf_pds_`y'.tex", ///
		title("Reduced-form effects on `y' (post-double-selection controls)") ///
		collabels(`" "All" "Above-median" "Below-median" "Female" "Male" "Primary" "Middle" "') ///
		notes("Scores in standard deviations of the not-yet-treated students of the same year and grade. Stratum-by-year and grade fixed effects; controls selected by post-double-selection lasso ($CONTROLS_MODE). Standard errors clustered by baseline school. * p<0.10, ** p<0.05, *** p<0.01.")
}

* >>> [CLEAN] robustness checks in one table (old: separate "excluding grade 6" file)
atema_res_open T3_rf_robustness
_rf_column math_score, col(1) touse("1 $SAMPLE_IF") controls(${CTRL_math_score})
* >>> [NEW] no controls
_rf_column math_score, col(2) touse("1 $SAMPLE_IF")
* same restriction as the old "excluding grade 6" file
_rf_column math_score, col(3) touse("!(grade_21 == 7 & ACADEMIC_YEAR_ID_FK == 2023) $SAMPLE_IF") controls(${CTRL_math_score})
* >>> [NEW] long-term effect only for students eligible in year 1
_rf_column math_score, col(4) touse("lt_ineligible == 0") controls(${CTRL_math_score})
* >>> [NEW] only students found at the end of the year
_rf_column math_score, col(5) touse("found_eoy == 1 $SAMPLE_IF") controls(${CTRL_math_score})
atema_res_close
atema_tex using "$ATEMA_OUT/tables/T3_rf_robustness.tex", ///
	title("Reduced-form effects on math scores: robustness") ///
	collabels(`" "Main" "No controls" "No 6th grade in 2022-23" "Long-term: eligible in 2021-22" "Found at end of year" "') ///
	notes("Column 3 drops 2022-23 scores of students in 5th grade in 2021-22. Column 4 drops long-term rows of arm 1-2 students who were in 3rd grade in 2021-22. Standard errors clustered by baseline school.")

atema_log_close
