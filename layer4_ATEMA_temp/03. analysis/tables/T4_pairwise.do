* ==============================================================================
* T4_pairwise.do  --  Table 4: pairwise differences between arms at baseline
* Replaces  appendix. pairwise differences.do, pairwise - pooled.do,
*           appendix. pairwise differences (teachers).do
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
atema_log T4_pairwise

* >>> [CLEAN] 4-arm and pooled versions in one loop
foreach design in 4arms pooled {
	if "`design'" == "4arms" {
		local sarms "treat_arm_1 treat_arm_2 treat_arm_3 treat_arm_4"
		local tarms "teach_treat1 teach_treat2 teach_treat3 teach_treat4"
		local names "1 2 3 4"
	}
	else {
		local sarms "treat_arm_1 treat_arm_2 treat_arm_34"
		local tarms "teach_treat1 teach_treat2 teach_treat34"
		local names "1 2 3+4"
	}
	local na : word count `sarms'
	local cl ""
	forvalues i = 1/`=`na'-1' {
		forvalues j = `=`i'+1'/`na' {
			local ni : word `i' of `names'
			local nj : word `j' of `names'
			local cl `"`cl' "TA`ni' - TA`nj'""'
		}
	}
	local cl `"`cl' "N""'
	local ncol = `na' * (`na' - 1) / 2 + 1

	atema_res_open T4_pairwise_`design'
	local row 0
	foreach panel in STUDENT SCHOOL TEACHER {
		if "`panel'" == "STUDENT" {
			use "$ATEMA_DATA/atema_baseline.dta", clear
			local arms `sarms'
			local fe "strata grade_21"
			local head "Panel A: Individual characteristics"
		}
		if "`panel'" == "SCHOOL" {
			* >>> [FIX] one row per school; strata FE only (same as T1)
			use "$ATEMA_DATA/atema_schools.dta", clear
			local arms `sarms'
			local fe "strata"
			local head "Panel B: School characteristics"
		}
		if "`panel'" == "TEACHER" {
			cap confirm file "$ATEMA_DATA/atema_teachers.dta"
			if _rc continue
			* >>> [FIX] old teacher version read D:\SECURE\data-feb2023 (an old data tree)
			* >>>       and put "control" next to all four arms (perfectly collinear)
			use "$ATEMA_DATA/atema_teachers.dta", clear
			local arms `tarms'
			local fe "strata"
			local head "Panel C: Teacher characteristics"
		}
		local ++row
		atema_post, row(`row') col(1) stat(head) label("`head'")
		foreach item of global BAL_`panel' {
			gettoken v lab : item, parse("|")
			local lab : subinstr local lab "|" ""
			cap confirm variable `v', exact
			if _rc continue
			local ++row
			quietly reghdfe `v' `arms', absorb(`fe') vce(cluster $CLUSTER)
			local df = e(df_r)
			local c 0
			forvalues i = 1/`=`na'-1' {
				forvalues j = `=`i'+1'/`na' {
					local ++c
					local ai : word `i' of `arms'
					local aj : word `j' of `arms'
					if $LEGACY {
						* >>> [LEGACY] old formula: ignores that both coefficients share the
						* >>>          same control group (their covariance)
						local d  = _b[`ai'] - _b[`aj']
						local se = sqrt(_se[`ai']^2 + _se[`aj']^2)
						local dfl = `df'
					}
					else {
						* >>> [FIX] lincom uses the full covariance matrix: correct SE
						quietly lincom `ai' - `aj'
						local d  = r(estimate)
						local se = r(se)
						local dfl = r(df)
					}
					local p = .
					if `se' > 0 & `se' < . {
						if `dfl' < . local p = 2 * ttail(`dfl', abs(`d' / `se'))
						else         local p = 2 * normal(-abs(`d' / `se'))
					}
					atema_post, row(`row') col(`c') stat(coef) label("`lab'") b(`d') se(`se') p(`p')
				}
			}
			atema_post, row(`row') col(`ncol') stat(N) label("`lab'") b(`=e(N)')
		}
	}
	atema_res_close
	atema_tex using "$ATEMA_OUT/tables/T4_pairwise_`design'.tex", ///
		title("Pairwise differences between treatment arms at baseline") ///
		collabels(`cl') ///
		notes("Differences between arm coefficients of the balance regressions (stratum fixed effects, and baseline-grade fixed effects for students). Standard errors of the differences from the full covariance matrix, clustered by baseline school. * p<0.10, ** p<0.05, *** p<0.01.")
}

atema_log_close
