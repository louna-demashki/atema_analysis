* ==============================================================================
* T3_T7_rf_ddml.do  --  reduced form with DDML (preferred estimates)
* Ported from  RFE ddml.do
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
atema_log T3_T7_rf_ddml

* >>> [CLEAN] reads the prepared controls (old rebuilt all ~1,000 candidates inside this file)
use "$ATEMA_DATA/master_controls.dta", clear
do "$ATEMA_DATA/controls_globals.do"
atema_keep_existing $FORCED_CONTROLS
local forced `r(varlist)'

* >>> [CRASH] old line 211 "stop" halted the script here -- removed
local terms "atema_st atema_pe_st atema_lt atema_pe_lt"
local labs  `" "b1: Treatment (short-term)" "b2: Parental engagement (short-term)" "b3: Treatment (long-term)" "b4: Parental engagement (long-term)" "'
local groups `" "1" "above_median == 1" "above_median == 0" "gender == 1" "gender == 0" "inrange(GRADE_ID_FK, 6, 8)" "inrange(GRADE_ID_FK, 9, 10)" "'

atema_res_open T3_T7_rf_ddml
local col 0
foreach g of local groups {
	local ++col
	di as text _n "DDML reduced form, subgroup: `g'"
	* >>> [CRASH] old cleared the data after the first model, so every subgroup model ran
	* >>>         on a 7-row results table.  The data is never cleared now.
	* >>> [FIX]   cluster = baseline school for every subgroup (old above-median: SCHOOL_CODE)
	* >>> [NEW]   primary / middle columns (Table 7 panel B)
	atema_ddml_rf math_score if (`g') & !missing(math_score) $SAMPLE_IF, ///
		treat(`terms') pool($CTRL_POOL) forced(`forced')
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
	* >>> [FIX] control means restricted to the right year (old above/below-median "2022" mean
	* >>>       included arm 3-4 students already treated in 2023, and the "2023" mean
	* >>>       included 2022 controls)
	atema_post_mean math_score if ref == 1 & ACADEMIC_YEAR_ID_FK == 2022 & (`g') $SAMPLE_IF, row(8) col(`col') label("Control mean (short-term, AY 2021-22)")
	atema_post_mean math_score if ref == 1 & ACADEMIC_YEAR_ID_FK == 2023 & (`g') $SAMPLE_IF, row(9) col(`col') label("Control mean (long-term, AY 2022-23)")
	* >>> [NEW] full estimates saved (old saved a hand-built 7-row dataset)
	estimates save "$ATEMA_OUT/results/ddml_rf_col`col'.ster", replace
}
atema_res_close
atema_tex using "$ATEMA_OUT/tables/T3_T7_rf_ddml.tex", ///
	title("Reduced-form effects on math scores (DDML)") ///
	collabels(`" "All" "Above-median" "Below-median" "Female" "Male" "Primary" "Middle" "') ///
	notes("Double/debiased machine learning, partially linear model, OLS and rlasso learners, $DDML_K folds by baseline school, $DDML_REPS repetitions. Stratum-by-year and grade fixed effects partialled out. Standard errors clustered by baseline school. * p<0.10, ** p<0.05, *** p<0.01.")

atema_log_close
