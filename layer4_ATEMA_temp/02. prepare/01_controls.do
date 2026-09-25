* ==============================================================================
* 01_controls.do  --  baseline control candidates and their selection
* Ported from  control_selection.do
* Writes  $ATEMA_DATA/master_controls.dta, $ATEMA_DATA/controls_globals.do
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
atema_log 01_controls

* >>> [FIX] reads the panel the build just wrote (old read $dir\data, a different folder
* >>>       from where clean_ka_22_23 saved it)
use "$ATEMA_DATA/master_khan_student_combined.dta", clear

* >>> [FIX] FE dummies built from the data (old: strata1-strata84 typed in other scripts;
* >>>       a different number of strata would silently drop or break FE)
* >>> [CLEAN] strata x year already built in the panel (old renamed strata here AND
* >>>         downstream, which crashed the heterogeneity scripts)
quietly tab strata_yr, gen(sy_)
drop sy_1
quietly tab grade_fe, gen(gd_)
drop gd_1
unab fe : sy_* gd_*
global FE_DUMMIES `fe'

* 1. same steps as old: standardize, missing flag, set missing to 0, square
* >>> [CLEAN] one loop (old: four loops and two renames)
atema_keep_existing $BASE_CONTROLS
local base `r(varlist)'
local miss ""
local sq ""
foreach v of local base {
	quietly egen double _z = std(`v')
	quietly replace `v' = _z
	drop _z
	quietly gen byte missing_`v' = missing(`v')
	quietly replace `v' = 0 if missing_`v' == 1
	quietly gen double `v'_sq = `v'^2
	local miss `miss' missing_`v'
	local sq   `sq' `v'_sq
}

* 2. two-way interactions with the same short names as old
* >>> [CLEAN] built straight from the name map (old renamed 43 variables back and forth)
local L $CTRL_LONG
local S $CTRL_SHORT
local K : word count `L'
local inter ""
forvalues i = 1/`=`K'-1' {
	local li : word `i' of `L'
	cap confirm variable `li', exact
	if _rc continue
	local si : word `i' of `S'
	forvalues j = `=`i'+1'/`K' {
		local lj : word `j' of `L'
		cap confirm variable `lj', exact
		if _rc continue
		local sj : word `j' of `S'
		quietly gen float x_`si'_`sj' = `li' * `lj'
		local inter `inter' x_`si'_`sj'
	}
}

* 3. drop constants, then exact collinearities
* >>> [FIX] gender added as a candidate (old typed it into the final list without it
* >>>       ever being a candidate)
atema_keep_existing gender
local cand `r(varlist)' `base' `miss' `sq' `inter'
local keep ""
foreach v of local cand {
	quietly summarize `v', meanonly
	if r(min) == r(max) drop `v'
	else local keep `keep' `v'
}
* >>> [CLEAN] forcedrop: omitted terms leave the list (old compared lists by hand)
_rmcoll `keep', forcedrop
global CTRL_POOL `r(varlist)'
local npool : word count $CTRL_POOL
di as text "  candidate controls after cleaning: `npool'"

* 4. selection
atema_keep_existing $FORCED_CONTROLS
local forced `r(varlist)'
if "$CONTROLS" == "legacy" {
	* >>> [LEGACY] old hand-typed list, same for every outcome
	atema_keep_existing $LEGACY_CONTROLS
	local leg `r(varlist)'
	foreach y of global PDS_OUTCOMES {
		global CTRL_`y' `leg'
	}
}
else {
	* >>> [FIX] real post-double-selection, per outcome: union of the lasso picks for the
	* >>>       outcome AND for all four treatment dummies, on that outcome's sample.
	* >>>       Old: lasso on math + atema_st only, then OVERWRITTEN by a typed list, reused
	* >>>       for usage outcomes and subgroups.
	foreach y of global PDS_OUTCOMES {
		cap confirm variable `y'
		if _rc continue
		local sel ""
		foreach d in `y' atema_st atema_pe_st atema_lt atema_pe_lt {
			quietly rlasso `d' $FE_DUMMIES $CTRL_POOL if !missing(`y') $SAMPLE_IF, ///
				partial($FE_DUMMIES) cluster($CLUSTER)
			local sel `sel' `e(selected)'
		}
		local sel : list uniq sel
		local sel : list sel - fe
		local s `forced' `sel'
		local s : list uniq s
		global CTRL_`y' `s'
		local ns : word count `s'
		di as text "  `y': `ns' controls selected"
	}
}

* 5. save the selection
* >>> [FIX] old kept it in a global that vanished when Stata closed, so every table
* >>>       typed its own list (five different lists).  Now written to a file that every
* >>>       table script runs.
tempname fh
file open `fh' using "$ATEMA_DATA/controls_globals.do", write replace text
file write `fh' "* written by 02. prepare/01_controls.do on `c(current_date)' -- do not edit by hand" _n
file write `fh' `"global CONTROLS_MODE "$CONTROLS""' _n
file write `fh' `"global FE_DUMMIES "$FE_DUMMIES""' _n
file write `fh' `"global CTRL_POOL "$CTRL_POOL""' _n
foreach y of global PDS_OUTCOMES {
	file write `fh' `"global CTRL_`y' "${CTRL_`y'}""' _n
}
file close `fh'

compress
label data "Layer 4 ATEMA: analysis panel + control candidates, mode $CONTROLS (`c(current_date)')"
save "$ATEMA_DATA/master_controls.dta", replace

atema_log_close
