* ==============================================================================
* F2_event_study.do  --  users vs non-users, 2017-2023, by baseline-grade cohort
* Ported from  event_study_by_grade.do and DiD (all students).do
* DESCRIPTIVE: take-up is a choice, not an assignment.  Not in the draft.
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
atema_log F2_event_study

use "$ATEMA_DATA/master_2017_2023.dta", clear
* >>> [LEGACY] old: only year x cohort FE -- no user effect at all, so the base-year gap
* >>>          was forced to 0 and every other point was a LEVEL gap, not a change
* >>> [FIX]    student FE: each point = change since the base year, users vs non-users
local fe = cond($LEGACY, "ay_grade", "ay_grade SMAX_STUDENT_ID")
local types "takeup_only1 takeup_only2 takeup_both"
local years "2017 2018 2019 2022 2023"

* >>> [CLEAN] one loop over outcome x cohort x user type (old: ~2,800 pasted lines)
atema_res_open F2_event_study
local oi 0
foreach y in math_score_adj math_score {
	local ++oi
	forvalues g = 5/10 {
		local base = cond(`g' >= 8, 2019, 2022)
		local ti 0
		foreach t of local types {
			local ++ti
			quietly count if grade_21 == `g' & `t' == 1 & !missing(`y')
			if r(N) == 0 continue
			* >>> [CLEAN] factor-variable interactions (old: dummies built by hand per year)
			cap noisily reghdfe `y' ib`base'.ACADEMIC_YEAR_ID_FK#1.`t' if grade_21 == `g', ///
				absorb(`fe') vce(cluster $CLUSTER)
			if _rc continue
			foreach yr of local years {
				if `yr' == `base' {
					atema_post, row(`yr') col(`=`oi'*1000 + `g'*10 + `ti'') stat(coef) label("`t'") b(0) se(0)
					continue
				}
				atema_post_coef `yr'.ACADEMIC_YEAR_ID_FK#1.`t', row(`yr') col(`=`oi'*1000 + `g'*10 + `ti'') label("`t'")
			}
		}
	}
}
atema_res_close

use "$ATEMA_OUT/results/F2_event_study.dta", clear
gen int oi   = floor(col / 1000)
gen int g    = floor(mod(col, 1000) / 10)
gen int ti   = mod(col, 10)
gen int year = row
gen double lo = b - 1.96 * se
gen double hi = b + 1.96 * se
gen double xp = year + (ti - 2) * 0.15
quietly levelsof oi, local(ois)
foreach o of local ois {
	local yname = cond(`o' == 1, "math_score_adj", "math_score")
	quietly levelsof g if oi == `o', local(gs)
	foreach gg of local gs {
		twoway (rcap lo hi xp if oi == `o' & g == `gg' & ti == 1, lcolor(navy)) ///
		       (connected b xp if oi == `o' & g == `gg' & ti == 1, color(navy)) ///
		       (rcap lo hi xp if oi == `o' & g == `gg' & ti == 2, lcolor(maroon)) ///
		       (connected b xp if oi == `o' & g == `gg' & ti == 2, color(maroon)) ///
		       (rcap lo hi xp if oi == `o' & g == `gg' & ti == 3, lcolor(forest_green)) ///
		       (connected b xp if oi == `o' & g == `gg' & ti == 3, color(forest_green)), ///
		       xlabel(2017 2018 2019 2022 2023) xtitle("Academic year (end year)") ///
		       ytitle("Users minus non-users (SD)") yline(0, lcolor(gs10)) ///
		       legend(order(2 "Year 1 only" 4 "Year 2 only" 6 "Both years") rows(1)) ///
		       title("Grade `=`gg'-2' in 2021-22 (`yname')") graphregion(color(white))
		graph export "$ATEMA_OUT/figures/F2_event_`yname'_g`=`gg'-2'.png", as(png) replace width(2000)
	}
}

atema_log_close
