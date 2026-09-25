* ==============================================================================
* A1_attrition.do  --  attrition by arm
* Ported from  attrition.do
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
atema_log A1_attrition

use "$ATEMA_DATA/master_khan_student_combined.dta", clear
* >>> [FIX] attrition = not found in the end-of-year file (old: school code missing, after
* >>>       setting every 33-prefixed code to missing, so enrolled students counted as attriters)
gen byte att_notfound = !found_eoy
* >>> [LEGACY] old rule
if $LEGACY replace att_notfound = 1 if SCHOOL_CODE >= 100000 & !missing(SCHOOL_CODE)
gen byte att_noscore = missing(math_score) if !att_notfound
gen byte att_either  = att_notfound | missing(math_score)

atema_res_open A1_attrition
local col 0
local cl ""
foreach smp in pooled 2022 2023 {
	if "`smp'" == "pooled" {
		local cond "1"
		* >>> [FIX] stratum x year FE in the pooled model (old: strata only)
		local fe "$FE_ABSORB"
	}
	else {
		local cond "ACADEMIC_YEAR_ID_FK == `smp'"
		local fe "strata grade_fe"
	}
	foreach y in att_notfound att_noscore att_either {
		local ++col
		local cl `"`cl' "`y' (`smp')""'
		quietly reghdfe `y' treat_arm_1 treat_arm_2 treat_arm_3 treat_arm_4 if `cond' $SAMPLE_IF, ///
			absorb(`fe') vce(cluster $CLUSTER)
		* >>> [FIX] stars via the helper (old typo wrote arm-1 stars for 0.01<=p<0.10 into
		* >>>       an unused macro, leaving those cells blank)
		forvalues a = 1/4 {
			atema_post_coef treat_arm_`a', row(`a') col(`col') label("Treatment arm `a'")
		}
		atema_post, row(6) col(`col') stat(N) label("N") b(`=e(N)')
		* >>> [NEW] joint test that attrition does not differ by arm
		quietly test treat_arm_1 treat_arm_2 treat_arm_3 treat_arm_4
		atema_post, row(7) col(`col') stat(test) label("p-value, all arms = 0") b(`r(p)')
		atema_post_mean `y' if control == 1 & `cond' $SAMPLE_IF, row(5) col(`col') label("Control mean")
	}
}
atema_res_close
* >>> [FIX] no manual "\_" escaping here any more: atema_tex escapes underscores itself
* >>>       (escaping twice would break the LaTeX)
atema_tex using "$ATEMA_OUT/tables/A1_attrition.tex", ///
	title("Attrition by treatment arm") ///
	collabels(`cl') ///
	notes("not found: not in the end-of-year file in grades 4-8; no score: found without a math score; either: one of the two. Pooled: stratum-by-year and grade FE; by year: stratum and grade FE. Standard errors clustered by baseline school.")

atema_log_close
