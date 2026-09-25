* ==============================================================================
* T8_tot.do  --  treatment-on-the-treated: 2SLS and DDML-IV
* Ported from  IV ddml - method 1/2.do and the 2SLS in av_table*.do;
*              2sls_5min.do dropped (debugging leftovers)
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
atema_log T8_tot

use "$ATEMA_DATA/master_controls.dta", clear
do "$ATEMA_DATA/controls_globals.do"
atema_keep_existing $FORCED_CONTROLS
local forced `r(varlist)'
* >>> [FIX] short-term rows only.  Old av_table.do kept long-term rows, where arm 1-2
* >>>       students had instrument = 0 but could still use Khan: broken instrument.
keep if atema_lt == 0 & atema_pe_lt == 0
* >>> [FIX] the saved selection (old: a typed list; method 2 a typed ~400-term list)
local X ${CTRL_math_score}

foreach d of global TOT_ENDOG {
	atema_res_open T8_tot_`d'
	local touse "!missing(math_score) $SAMPLE_IF"

	* >>> [NEW] first stage shown next to the 2SLS
	quietly reghdfe `d' atema_st atema_pe_st `X' if `touse', absorb($FE_ABSORB) vce(cluster $CLUSTER)
	atema_post_coef atema_st,    row(2) col(1) label("ATEMA (short-term)")
	atema_post_coef atema_pe_st, row(3) col(1) label("ATEMA + parental engagement (short-term)")
	atema_post, row(6) col(1) stat(N) label("N") b(`=e(N)')

	forvalues c = 2/3 {
		local ctl ""
		if `c' == 2 local ctl `X'
		quietly ivreghdfe math_score `ctl' (`d' = atema_st atema_pe_st) if `touse', ///
			absorb($FE_ABSORB) cluster($CLUSTER)
		atema_post_coef `d', row(1) col(`c') label("Take-up (`d')")
		* >>> [FIX] Kleibergen-Paap F from e(widstat) (old: a hard-coded matrix cell [15,1])
		atema_post, row(4) col(`c') stat(test) label("First-stage F (Kleibergen-Paap)") b(`e(widstat)')
		* >>> [NEW] overidentification test (two instruments, one endogenous variable)
		atema_post, row(5) col(`c') stat(test) label("Overidentification p-value (Hansen J)") b(`e(jp)')
		atema_post, row(6) col(`c') stat(N) label("N") b(`=e(N)')
	}

	* >>> [CRASH] old IV ddml failed at the save (undefined row counter) -- fixed in the helper
	atema_ddml_iv math_score if `touse', endog(`d') inst(atema_st atema_pe_st) pool($CTRL_POOL) forced(`forced')
	atema_post_coef `d', row(1) col(4) label("Take-up (`d')")
	atema_post, row(6) col(4) stat(N) label("N") b(`=e(N)')
	estimates save "$ATEMA_OUT/results/ddml_iv_`d'.ster", replace

	atema_post_mean math_score if ref == 1 & `touse', row(7) col(2) label("Control mean of the outcome")
	atema_res_close
	atema_tex using "$ATEMA_OUT/tables/T8_tot_`d'.tex", ///
		title("Treatment-on-the-treated: effect of Khan Academy take-up on math scores") ///
		collabels(`" "First stage" "2SLS" "2SLS, no controls" "DDML-IV" "') ///
		notes("Short-term rows only. Take-up instrumented by assignment to ATEMA and to ATEMA + parental engagement. Stratum-by-year and grade fixed effects. Standard errors clustered by baseline school. * p<0.10, ** p<0.05, *** p<0.01.")
}

atema_log_close
