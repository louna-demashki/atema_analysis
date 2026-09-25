* ==============================================================================
* T2_first_stage.do  --  Table 2 (usage) and Table 3 column 1 (skills)
* Ported from  first stage.do
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
atema_log T2_first_stage

use "$ATEMA_DATA/master_controls.dta", clear
* >>> [FIX] the one saved control selection
do "$ATEMA_DATA/controls_globals.do"
* >>> [DECIDE] FS_SAMPLE: "all" (old behaviour) or "found"
local fs = cond("$FS_SAMPLE" == "found", "found_eoy == 1", "1")

local terms "atema_st atema_pe_st atema_lt atema_pe_lt"
local labs  `" "b1: Treatment (short-term)" "b2: Parental engagement (short-term)" "b3: Treatment (long-term)" "b4: Parental engagement (long-term)" "'

* >>> [CLEAN] one loop over the six columns (old: four pasted blocks + two special cases)
local specs `" "ka_login|1" "takeup|1" "takeup|above_median == 1" "takeup|above_median == 0" "ka_minutes|1" "ka_skills|1" "'

atema_res_open T2_first_stage
local col 0
foreach s of local specs {
	gettoken y cond : s, parse("|")
	local cond : subinstr local cond "|" ""
	local ++col
	local X ""
	* >>> [DECIDE] Table 2 says "Controls: Yes"; old script had none (LEGACY: none)
	if $FS_CONTROLS local X ${CTRL_`y'}
	local touse "(`cond') & `fs' $SAMPLE_IF"

	* >>> [FIX] grade FE from 00_params.do, the same as every other table (old: grade_21
	* >>>       here, GRADE_ID_FK in the DDML table)
	quietly reghdfe `y' `terms' `X' if `touse', absorb($FE_ABSORB) vce(cluster $CLUSTER)
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
	* control means as in the paper: not-yet-treated 2021-22; control 2022-23
	atema_post_mean `y' if ref == 1 & ACADEMIC_YEAR_ID_FK == 2022 & `touse', row(8) col(`col') label("Control mean (short-term, AY 2021-22)")
	atema_post_mean `y' if ref == 1 & ACADEMIC_YEAR_ID_FK == 2023 & `touse', row(9) col(`col') label("Control mean (long-term, AY 2022-23)")
}
atema_res_close
local ctl = cond($FS_CONTROLS, "and the selected baseline controls", "and no other controls")
atema_tex using "$ATEMA_OUT/tables/T2_first_stage.tex", ///
	title("Effects of ATEMA and ATEMA + parental engagement on Khan Academy usage") ///
	collabels(`" "Login" "Take-up" "Take-up, above-median" "Take-up, below-median" "Minutes" "Skills" "') ///
	notes("Take-up: at least $TAKEUP_MINWK minutes per week on average over the year. All regressions include stratum-by-year and grade fixed effects `ctl'. Control group: not-yet-treated students (control and arms 3-4 in AY 2021-22; control in AY 2022-23). Standard errors clustered by baseline school. * p<0.10, ** p<0.05, *** p<0.01.")

atema_log_close
