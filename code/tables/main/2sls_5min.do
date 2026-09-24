//----------------------------------------------------------------------------//
// File name: 4.a. 2sls_5min
// Desc.: first stage and 2sls using 5 min per week as IV (DDML)
// Last updated: May 6, 2025 by Sara Mostafa
//----------------------------------------------------------------------------//

clear all
set matsize 6000
set maxvar 120000
set more off 
global dir "D:\SECURE\data 2024\analysis\atema" 
global input "$dir\data" 
global output "$dir\output"

//cap log close
//log using "$output\Logs\tables\main\2sls_5min_ddml.txt", text replace

use "$input\master_controls", clear 



//----------------------------------------------------------------------------//
// Including controls
//----------------------------------------------------------------------------//

// FE dummy variables
	// grade FE
		gen grade3 = (grade_21 == 5)
	
	// strata FE 
		global strata_FE " "
		forvalues i = 1/84 {
			global strata_FE "$strata_FE strata`i'" 
		}
	
	global grade_FE "grade3 grade4 grade5 grade6 grade7 grade8"
	
gen control_pooled = 0
	replace control_pooled = 1 if control == 1
	replace control_pooled = 1 if (treat_arm_3==1 & ACADEMIC_YEAR_ID_FK==2022) | ///
	(treat_arm_4==1 & ACADEMIC_YEAR_ID_FK==2022)

//-------- CONTROLS FROM 2019 BASELINE --------//
	
// Identifying controls to be included (interactions, baseline, missing controls)
unab all_vars : _all
local selected_vars

foreach var of local all_vars {
    if inlist(substr("`var'", 1, 2), "b_", "x_") | substr("`var'", 1, 8) == "missing_" {
        local selected_vars `selected_vars' `var'
    }
}
global cov `selected_vars'

global controls "gender above_median ${cov}"


keep SMAX_STUDENT_ID SCHOOL_CODE ACADEMIC_YEAR_ID_FK grade_21 strata math_score ///
atema_st atema_pe_st atema_lt atema_pe_lt control_pooled takeup gender above_median ///
school_21 ${controls} ${strata_FE} ${grade_FE}

// keeping only short term outcomes
drop if atema_lt == 1 | atema_pe_lt == 1
drop if math_score == .


//---------------------------------------------------------------------------//
// 2SLS (DDML)
//---------------------------------------------------------------------------//

global Y "math_score"
global X "${controls} ${strata_FE} ${grade_FE}"
global Z1 "atema_st"
global Z2 "atema_pe_st"
global D "takeup"

gen total = _n
drop if total > 1000
drop total
stoop

set seed 12345
ddml init interactiveiv, kfolds(2) fcluster(school_21) 


// add machine learners 
ddml E[Y|X,Z]: reg $Y $X 
ddml E[Y|X,Z]: rlasso $Y $X, partial($strata_FE $grade_FE)
ddml E[Y|X,Z]: ridge $Y $X, method(ridgecv)

ddml E[D|X,Z]: reg $D $X 
ddml E[D|X,Z]: rlasso $D $X, partial($strata_FE $grade_FE)
ddml E[D|X,Z]: ridge $D $X, method(ridgecv)

ddml E[Z|X]: reg $Z2 $X 
ddml E[Z|X]: rlasso $Z2 $X, partial($strata_FE $grade_FE)
ddml E[Z|X]: ridge $Z2 $X, method(ridgecv)


/* add machine learners 
ddml E[Y|X]: reghdfe $Y $X, absorb(strata grade_21) 
ddml E[Y|X], type(none): rforest $Y $X, type(reg) prname(pred_y)
ddml E[D|X]: reghdfe $D $X, absorb(strata grade_21)
ddml E[D|X], type(none): rforest $D $X, type(reg) prname(pred_d)
ddml E[Z|X]: reghdfe $Z1 $X, absorb(strata grade_21)
ddml E[Z|X], type(none): rforest $Z1 $X, type(reg) prname(pred_z1)
ddml E[Z|X]: reghdfe $Z2 $X, absorb(strata grade_21)
ddml E[Z|X], type(none): rforest $Z2 $X, type(reg) prname(pred_z2)
*/

// check applied learners
ddml describe 

// cross-fitting
ddml crossfit, shortstack

// exporting table
ddml estimate, robust
estimates store m1 

// adding estimates 
estadd scalar obs=e(N)

qui: sum math_score if control_pooled==1 
local m=r(mean)
estadd scalar cmean = `m'

test atema = atema_pe
local p1=r(p)
estadd scalar pval==`p1'

esttab m1 using "$output\tables\main\04. 2sls_all.tex", ///
style(tab) mlabels(none) label collabels(none) cells(b(star fmt(%99.3f)) se(par)) ///
stats(obs pval, fmt(%9.0fc %9.3fc) labels("obs" "pval")) ///
drop(o.*, relax) order(takeup, relax) replace starlevels(* 0.10 ** 0.05 *** 0.01)













