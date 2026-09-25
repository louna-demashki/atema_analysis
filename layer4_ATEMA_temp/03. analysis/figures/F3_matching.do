* ==============================================================================
* F3_matching.do  --  matched event studies (nearest neighbours on past scores)
* Replaces the six event_study_matching*.do files
* DESCRIPTIVE (selection on observables).  Not in the draft.
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
atema_log F3_matching

* >>> [CRASH] the matching data is built here.  Old: this step was commented out in all six
* >>>         files, and they read it from two different folders.
use "$ATEMA_DATA/master_2017_2023.dta", clear
foreach yr in 2017 2018 2019 2022 2023 {
	gen double _s = math_score_adj if ACADEMIC_YEAR_ID_FK == `yr'
	bysort SMAX_STUDENT_ID: egen double score_`yr' = max(_s)
	drop _s
}
keep SMAX_STUDENT_ID ACADEMIC_YEAR_ID_FK grade_21 school_21 control takeup1 takeup2 score_*
tempfile md
save `md'

* >>> [CLEAN] one loop over restricted / unrestricted x 1, 3, 5 neighbours (old: 6 files)
atema_res_open F3_matching
foreach restr in 0 1 {
	foreach nn of global MATCH_NN {
		foreach coh in 1 2 {
			local yr = 2021 + `coh'
			local grades = cond(`coh' == 1, "8 9 10", "8 9")
			foreach g of local grades {
				use `md', clear
				if `restr' keep if takeup1 == 1 | takeup2 == 1 | control == 1
				keep if ACADEMIC_YEAR_ID_FK == `yr' & grade_21 == `g'
				local pre = cond(`g' == 10, "score_2017 score_2018 score_2019", cond(`g' == 9, "score_2018 score_2019", "score_2019"))
				* >>> [FIX] rows numbered AFTER selecting the grade.  teffects returns neighbours
				* >>>       as row numbers of the data in memory; old numbered rows BEFORE
				* >>>       keeping one grade, so users were paired with the wrong students.
				gen long row = _n
				cap noisily teffects nnmatch (score_`yr' `pre') (takeup`coh'), ate ///
					nneighbor(`nn') metric(ivar) gen(nb_) vce(iid)
				if _rc continue
				tempfile sub pairs
				save `sub'
				keep if takeup`coh' == 1
				keep row nb_*
				rename row match_group
				gen long nb_0 = match_group
				reshape long nb_, i(match_group) j(k)
				* >>> [FIX] ties can give more than k neighbours; keep exactly k
				drop if missing(nb_) | k > `nn'
				rename nb_ row
				merge m:1 row using `sub', keep(match) keepusing(SMAX_STUDENT_ID school_21 score_*) nogen
				gen byte user = (k == 0)
				reshape long score_, i(match_group k) j(year)
				rename score_ math_score_adj
				drop if missing(math_score_adj)
				egen long m_period = group(match_group year)
				local col = `restr' * 1000 + `nn' * 100 + `coh' * 10 + (`g' - 7)
				* same model as old: match-group x year FE + student FE
				cap noisily reghdfe math_score_adj ib2019.year#1.user, absorb(m_period SMAX_STUDENT_ID) vce(cluster $CLUSTER)
				if _rc continue
				foreach y in 2017 2018 2019 2022 2023 {
					if `y' == 2019 {
						atema_post, row(`y') col(`col') stat(coef) label("users vs matched") b(0) se(0)
						continue
					}
					atema_post_coef `y'.year#1.user, row(`y') col(`col') label("users vs matched")
				}
			}
		}
	}
}
atema_res_close

use "$ATEMA_OUT/results/F3_matching.dta", clear
drop if missing(b)
gen double lo = b - 1.96 * se
gen double hi = b + 1.96 * se
quietly levelsof col, local(cols)
foreach c of local cols {
	local restr = floor(`c' / 1000)
	local nn    = floor(mod(`c', 1000) / 100)
	local coh   = floor(mod(`c', 100) / 10)
	local g     = mod(`c', 10) + 7
	local tag = cond(`restr', "r", "u")
	twoway (rcap lo hi row if col == `c', lcolor(navy)) (connected b row if col == `c', color(navy)), ///
	       xlabel(2017 2018 2019 2022 2023) xtitle("Academic year (end year)") ///
	       ytitle("Users minus matched non-users (SD)") yline(0, lcolor(gs10)) legend(off) ///
	       title("Cohort `coh', grade `=`g'-2' in 2021-22, `nn' neighbour(s), `=cond(`restr', "restricted", "unrestricted")'") ///
	       graphregion(color(white))
	graph export "$ATEMA_OUT/figures/F3_match_`tag'_nn`nn'_c`coh'_g`=`g'-2'.png", as(png) replace width(2000)
}

atema_log_close
