* ==============================================================================
* A4_spec_curve.do  --  sensitivity to the control set
* Ported from  av_table.do, av_table (first stage).do, av_table (RFE).do, av_table (2SLS).do
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
atema_log A4_spec_curve

use "$ATEMA_DATA/master_controls.dta", clear
do "$ATEMA_DATA/controls_globals.do"
* same sample as old: students with a math score
keep if !missing(math_score)
forvalues k = 1/7 {
	atema_keep_existing ${SPEC_`k'}
	local set`k' `r(varlist)'
}
* >>> [NEW] 8th column: the saved selection
local set8 ${CTRL_math_score}
local cl `" "(1)" "(2)" "(3)" "(4)" "(5)" "(6)" "(7)" "Selected" "'

* >>> [CLEAN] first stage and reduced form in one loop (old: two 530-line files)
foreach part in fs rf {
	local y = cond("`part'" == "fs", "takeup", "math_score")
	atema_res_open A4_spec_`part'
	forvalues k = 1/8 {
		quietly reghdfe `y' atema_st atema_pe_st atema_lt atema_pe_lt `set`k'' if 1 $SAMPLE_IF, ///
			absorb($FE_ABSORB) vce(cluster $CLUSTER)
		atema_post_coef atema_st,    row(1) col(`k') label("Treatment (short-term)")
		atema_post_coef atema_pe_st, row(2) col(`k') label("Parental engagement (short-term)")
		atema_post_coef atema_lt,    row(3) col(`k') label("Treatment (long-term)")
		atema_post_coef atema_pe_lt, row(4) col(`k') label("Parental engagement (long-term)")
		atema_post, row(7) col(`k') stat(N) label("N") b(`=e(N)')
		local nc : word count `set`k''
		atema_post, row(8) col(`k') stat(N) label("Number of controls") b(`nc')
	}
	* >>> [FIX] old "control_pooled" wrote the 2021-22 condition twice, so 2022-23 control
	* >>>       students never entered the control mean; now ref == 1 by year
	atema_post_mean `y' if ref == 1 & ACADEMIC_YEAR_ID_FK == 2022 $SAMPLE_IF, row(5) col(1) label("Control mean (short-term)")
	atema_post_mean `y' if ref == 1 & ACADEMIC_YEAR_ID_FK == 2023 $SAMPLE_IF, row(6) col(1) label("Control mean (long-term)")
	local clp `"`cl'"'
	if "`part'" == "rf" {
		* >>> [CRASH] old DDML column read a file that RFE ddml.do never finished writing;
		* >>>         now read from T3_T7_rf_ddml's saved results
		cap confirm file "$ATEMA_OUT/results/T3_T7_rf_ddml.dta"
		if !_rc {
			preserve
			use "$ATEMA_OUT/results/T3_T7_rf_ddml.dta", clear
			keep if col == 1 & inrange(row, 1, 4)
			local nr = _N
			forvalues i = 1/`nr' {
				local rr`i' = row[`i']
				local bb`i' = b[`i']
				local ss`i' = se[`i']
				local pp`i' = p[`i']
				local ll`i' = label[`i']
			}
			restore
			forvalues i = 1/`nr' {
				atema_post, row(`rr`i'') col(9) stat(coef) label("`ll`i''") b(`bb`i'') se(`ss`i'') p(`pp`i'')
			}
			local clp `"`cl' "DDML""'
		}
	}
	atema_res_close
	local what "reduced form on math scores"
	if "`part'" == "fs" local what "first stage on take-up"
	atema_tex using "$ATEMA_OUT/tables/A4_spec_`part'.tex", ///
		title("Sensitivity to the control set: `what'") ///
		collabels(`clp') ///
		notes("Columns (1)-(7): the nested control sets of 00_params.do (SPEC_1-SPEC_7); Selected: the post-selection controls. Stratum-by-year and grade FE; SE clustered by baseline school. * p<0.10, ** p<0.05, *** p<0.01.")
}

* >>> [FIX] 2SLS on short-term rows only (see T8_tot.do)
keep if atema_lt == 0 & atema_pe_lt == 0
atema_res_open A4_spec_iv
forvalues k = 1/8 {
	quietly ivreghdfe math_score `set`k'' (takeup = atema_st atema_pe_st) if 1 $SAMPLE_IF, ///
		absorb($FE_ABSORB) cluster($CLUSTER)
	atema_post_coef takeup, row(1) col(`k') label("Take-up")
	* >>> [FIX] F from e(widstat), not a hard-coded matrix cell
	atema_post, row(2) col(`k') stat(test) label("First-stage F (Kleibergen-Paap)") b(`e(widstat)')
	atema_post, row(3) col(`k') stat(N) label("N") b(`=e(N)')
}
atema_res_close
atema_tex using "$ATEMA_OUT/tables/A4_spec_iv.tex", ///
	title("Sensitivity to the control set: 2SLS effect of take-up on math scores") ///
	collabels(`cl') ///
	notes("Short-term rows only; take-up instrumented by the two short-term assignments. Stratum-by-year and grade FE; SE clustered by baseline school.")

atema_log_close
