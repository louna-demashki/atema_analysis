* ==============================================================================
* T5_T6_first_stage_detail.do  --  Tables 5, 6 and first stage by baseline grade
* Replaces  appendix. first stage (year-specific) (+ math), first stage by grade
*           (year-specific) (+ math), heterogeneity FS (pooled B) (+ math)
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
atema_log T5_T6_first_stage_detail

use "$ATEMA_DATA/master_controls.dta", clear
do "$ATEMA_DATA/controls_globals.do"
local fs = cond("$FS_SAMPLE" == "found", "found_eoy == 1", "1")
* >>> [CLEAN] a new variable (old overwrote grade_21 in place with 3..8)
gen byte grade_base = grade_21 - 2

local outcomes "ka_login takeup ka_minutes ka_skills ka_familiar"
local olabs `" "Login" "Take-up" "Minutes" "Skills" "Familiar" "'

* >>> [CLEAN] "all" and "math-score" samples in one loop (old: six near-identical files)
foreach smp in all math {
	local sm = cond("`smp'" == "math", "!missing(math_score)", "1")
	local base "`fs' & `sm' $SAMPLE_IF"

	* ------------------------------------------------------------ Table 5 --------
	atema_res_open T5_first_stage_year_`smp'
	local col 0
	foreach y of local outcomes {
		local ++col
		local row 1
		atema_post, row(`row') col(1) stat(head) label("Panel A: AY 2021-22")
		* >>> [FIX] the comparison group matches the reported control mean
		* >>> [LEGACY] "pure": arm 3/4 dummies kept, so arms 1-2 vs control only, while the
		* >>>          reported mean pooled control + arms 3-4
		if "$T5_REF2022" == "pooled" local arms22 "treat_arm_1 treat_arm_2"
		else                         local arms22 "treat_arm_1 treat_arm_2 treat_arm_3 treat_arm_4"
		quietly reghdfe `y' `arms22' if ACADEMIC_YEAR_ID_FK == 2022 & `base', absorb(strata grade_fe) vce(cluster $CLUSTER)
		local k 1
		foreach a of local arms22 {
			local ++k
			local n = substr("`a'", -1, 1)
			atema_post_coef `a', row(`k') col(`col') label("Treatment arm `n'")
		}
		atema_post, row(6) col(`col') stat(N) label("N") b(`=e(N)')
		local c22 = cond("$T5_REF2022" == "pooled", "ref == 1", "control == 1")
		atema_post_mean `y' if ACADEMIC_YEAR_ID_FK == 2022 & `c22' & `base', row(7) col(`col') label("Control mean")
		atema_post, row(10) col(1) stat(head) label("Panel B: AY 2022-23")
		quietly reghdfe `y' treat_arm_1 treat_arm_2 treat_arm_3 treat_arm_4 if ACADEMIC_YEAR_ID_FK == 2023 & `base', ///
			absorb(strata grade_fe) vce(cluster $CLUSTER)
		forvalues a = 1/4 {
			atema_post_coef treat_arm_`a', row(`=10+`a'') col(`col') label("Treatment arm `a'")
		}
		atema_post, row(16) col(`col') stat(N) label("N") b(`=e(N)')
		atema_post_mean `y' if ACADEMIC_YEAR_ID_FK == 2023 & control == 1 & `base', row(17) col(`col') label("Control mean")
	}
	atema_res_close
	atema_tex using "$ATEMA_OUT/tables/T5_first_stage_year_`smp'.tex", ///
		title("Year-specific first-stage effects on Khan Academy usage (sample: `smp')") ///
		collabels(`olabs') ///
		notes("One regression per year, stratum and grade fixed effects. AY 2021-22 comparison group: $T5_REF2022. Standard errors clustered by baseline school. * p<0.10, ** p<0.05, *** p<0.01.")

	* ------------------------------------------------------------ Table 6 --------
	* >>> [FIX] primary = grades 4-6 for all four coefficients (old took the long-term
	* >>>       primary coefficients from a separate grades 5-6 regression)
	local groups `" "gender == 1" "gender == 0" "inrange(GRADE_ID_FK, 6, 8)" "inrange(GRADE_ID_FK, 9, 10)" "above_median == 1" "above_median == 0" "'
	foreach y in takeup ka_minutes {
		atema_res_open T6_first_stage_het_`smp'_`y'
		local col 0
		foreach g of local groups {
			local ++col
			local X ""
			* >>> [DECIDE] controls follow FS_CONTROLS (old: none)
			if $FS_CONTROLS local X ${CTRL_`y'}
			quietly reghdfe `y' atema_st atema_pe_st atema_lt atema_pe_lt `X' if (`g') & `base', ///
				absorb($FE_ABSORB) vce(cluster $CLUSTER)
			atema_post_coef atema_st,    row(1) col(`col') label("Treatment (short-term)")
			atema_post_coef atema_pe_st, row(2) col(`col') label("Parental engagement (short-term)")
			atema_post_coef atema_lt,    row(3) col(`col') label("Treatment (long-term)")
			atema_post_coef atema_pe_lt, row(4) col(`col') label("Parental engagement (long-term)")
			atema_post, row(7) col(`col') stat(N) label("N") b(`=e(N)')
			* >>> [FIX] separate short/long-term control means
			atema_post_mean `y' if ref == 1 & ACADEMIC_YEAR_ID_FK == 2022 & (`g') & `base', row(5) col(`col') label("Control mean (short-term)")
			atema_post_mean `y' if ref == 1 & ACADEMIC_YEAR_ID_FK == 2023 & (`g') & `base', row(6) col(`col') label("Control mean (long-term)")
		}
		atema_res_close
		atema_tex using "$ATEMA_OUT/tables/T6_first_stage_het_`smp'_`y'.tex", ///
			title("Heterogeneous first-stage effects on `y' (sample: `smp')") ///
			collabels(`" "Female" "Male" "Primary" "Middle" "Above-median" "Below-median" "') ///
			notes("Primary: grades 4-6 in the outcome year; middle: grades 7-8. Stratum-by-year and grade fixed effects. Standard errors clustered by baseline school. * p<0.10, ** p<0.05, *** p<0.01.")
	}

	* ------------------------------------------------ first stage by baseline grade ----
	foreach yr in 2022 2023 {
		atema_res_open A_first_stage_grade_`yr'_`smp'
		quietly levelsof grade_base if ACADEMIC_YEAR_ID_FK == `yr' & `base', local(gs)
		local cl ""
		local col 0
		foreach gb of local gs {
			local ++col
			local cl `"`cl' "Grade `gb' in 2021-22""'
			local armsg "treat_arm_1 treat_arm_2 treat_arm_3 treat_arm_4"
			* >>> [FIX] same comparison-group rule as Table 5
			if `yr' == 2022 & "$T5_REF2022" == "pooled" local armsg "treat_arm_1 treat_arm_2"
			quietly reghdfe takeup `armsg' ///
				if ACADEMIC_YEAR_ID_FK == `yr' & grade_base == `gb' & `base', absorb(strata) vce(cluster $CLUSTER)
			foreach a of local armsg {
				local n = substr("`a'", -1, 1)
				atema_post_coef `a', row(`n') col(`col') label("Treatment arm `n'")
			}
			atema_post, row(6) col(`col') stat(N) label("N") b(`=e(N)')
			local cm = cond(`yr' == 2022 & "$T5_REF2022" == "pooled", "ref == 1", "control == 1")
			atema_post_mean takeup if ACADEMIC_YEAR_ID_FK == `yr' & grade_base == `gb' & `cm' & `base', row(5) col(`col') label("Control mean")
		}
		atema_res_close
		atema_tex using "$ATEMA_OUT/tables/A_first_stage_grade_`yr'_`smp'.tex", ///
			title("First stage on take-up by baseline grade, AY `=`yr'-1'-`=`yr'-2000' (sample: `smp')") ///
			collabels(`cl') ///
			notes("Stratum fixed effects. Standard errors clustered by baseline school.")
	}
}

atema_log_close
