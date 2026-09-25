* ==============================================================================
* T1_balance.do  --  Table 1: descriptive statistics and balance
* Ported from  balance.do and balance_pooled.do
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
atema_log T1_balance

* >>> [CLEAN] 4 arms and pooled 3+4 in one loop (old: two 450-line files)
foreach design in 4arms pooled {
	if "`design'" == "4arms" {
		local sarms "treat_arm_1 treat_arm_2 treat_arm_3 treat_arm_4"
		local tarms "teach_treat1 teach_treat2 teach_treat3 teach_treat4"
		local cl `" "Control mean" "TA1 - C" "TA2 - C" "TA3 - C" "TA4 - C" "N" "'
	}
	else {
		local sarms "treat_arm_1 treat_arm_2 treat_arm_34"
		local tarms "teach_treat1 teach_treat2 teach_treat34"
		local cl `" "Control mean" "TA1 - C" "TA2 - C" "TA3+4 - C" "N" "'
	}
	local na : word count `sarms'
	local ncol = `na' + 2

	atema_res_open T1_balance_`design'
	local row 0
	foreach panel in STUDENT SCHOOL TEACHER {
		if "`panel'" == "STUDENT" {
			use "$ATEMA_DATA/atema_baseline.dta", clear
			local arms `sarms'
			local ctl "control"
			local fe "strata grade_21"
			local head "Panel A: Individual characteristics"
		}
		if "`panel'" == "SCHOOL" {
			* >>> [FIX] one row per school (old: an arbitrary student's row)
			use "$ATEMA_DATA/atema_schools.dta", clear
			local arms `sarms'
			local ctl "control"
			* >>> [FIX] no grade FE for schools (old absorbed a random student's grade)
			local fe "strata"
			local head "Panel B: School characteristics"
		}
		if "`panel'" == "TEACHER" {
			cap confirm file "$ATEMA_DATA/atema_teachers.dta"
			if _rc continue
			* >>> [FIX] one row per real teacher; no phantom "missing-id" teacher
			use "$ATEMA_DATA/atema_teachers.dta", clear
			local arms `tarms'
			local ctl "teach_control"
			local fe "strata"
			local head "Panel C: Teacher characteristics"
		}
		local ++row
		atema_post, row(`row') col(1) stat(head) label("`head'")
		foreach item of global BAL_`panel' {
			gettoken v lab : item, parse("|")
			local lab : subinstr local lab "|" ""
			cap confirm variable `v', exact
			if _rc {
				di as text "  `panel': `v' not in the data, row skipped"
				continue
			}
			local ++row
			atema_post_mean `v' if `ctl' == 1, row(`row') col(1) label("`lab'")
			* >>> [CLEAN] vce(cluster ...) instead of the non-standard vce(clustervar ...)
			quietly reghdfe `v' `arms', absorb(`fe') vce(cluster $CLUSTER)
			local j 1
			foreach a of local arms {
				local ++j
				atema_post_coef `a', row(`row') col(`j') label("`lab'")
			}
			atema_post, row(`row') col(`ncol') stat(N) label("`lab'") b(`=e(N)')
		}
	}
	atema_res_close
	atema_tex using "$ATEMA_OUT/tables/T1_balance_`design'.tex", ///
		title("Descriptive statistics and balance tests") ///
		collabels(`cl') ///
		notes("Control means with standard deviations in brackets. Differences from control adjusted for stratum fixed effects (and baseline-grade fixed effects for students). Standard errors clustered by baseline school in parentheses. * p<0.10, ** p<0.05, *** p<0.01.")
}

atema_log_close
