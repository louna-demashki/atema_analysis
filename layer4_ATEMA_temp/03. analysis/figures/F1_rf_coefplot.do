* ==============================================================================
* F1_rf_coefplot.do  --  DDML reduced-form effects by subgroup, as bars
* Ported from  graph_RFE.do
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
atema_log F1_rf_coefplot

local gnames `" "All" "Above-median" "Below-median" "Female" "Male" "Primary" "Middle" "'

foreach term in short long {
	* >>> [FIX] coefficients read from the saved DDML results.  Old: typed in by hand, and
	* >>>       already stale (0.018 / 0.022 vs 0.024 / 0.028 in the draft)
	use "$ATEMA_OUT/results/T3_T7_rf_ddml.dta", clear
	keep if stat == "coef"
	if "`term'" == "short" keep if inlist(row, 1, 2)
	else                   keep if inlist(row, 3, 4)
	gen byte arm = cond(inlist(row, 1, 3), 1, 2)
	gen double x  = (col - 1) * 3 + arm
	gen double lo = b - 1.96 * se
	gen double hi = b + 1.96 * se
	local xl ""
	quietly levelsof col, local(cols)
	foreach c of local cols {
		local nm : word `c' of `gnames'
		local xl `"`xl' `=(`c'-1)*3+1.5' "`nm'""'
	}
	* >>> [NEW] long-term panel (old graphed short-term, and long-term only by hand)
	twoway (bar b x if arm == 1, barwidth(0.9) color(navy)) ///
	       (bar b x if arm == 2, barwidth(0.9) color(maroon)) ///
	       (rcap lo hi x, lcolor(gs6)), ///
	       xlabel(`xl', noticks labsize(small)) xtitle("") ///
	       ytitle("Effect on math score (SD)") yline(0, lcolor(gs10)) ///
	       legend(order(1 "ATEMA" 2 "ATEMA + parental engagement") rows(1)) ///
	       title("`=proper("`term'")'-term effects (DDML)") graphregion(color(white))
	graph export "$ATEMA_OUT/figures/F1_rf_`term'_term.png", as(png) replace width(2000)
}

atema_log_close
