//----------------------------------------------------------------------------//
// File: 3. RFE ddml (pooled B) - math.do 
// Uses: master_khan_student
// Last update: May 13, 2025 by Sara Mostafa
//----------------------------------------------------------------------------//

clear all
set matsize 6000
set maxvar 120000
set java_heapmax 1g
set more off 
global dir "D:\SECURE\data 2024\analysis\atema" 
global input "$dir\data" 
global output "$dir\output"

cap log close
log using "$output\Logs\tables\main\IV_ddml_method (1)", text replace

	
use "$input\master_controls", clear

		global strata_FE " "
		forvalues i = 2/84 {
			global strata_FE "$strata_FE strata`i'" 
		}
	
	global grade_FE "grade4 grade5 grade6 grade7 grade8"
	
gen control_pooled = 0 
	replace control_pooled = 1 if (treat_arm_3 == 1 & ACADEMIC_YEAR_ID_FK == 2022) | ///
	(treat_arm_4 == 1 & ACADEMIC_YEAR_ID_FK == 2022) | control == 1

global controls_clean "gender above_median b_math_21 missing_b_math_21 b_special_ed gender b_math_19 missing_b_math_19 b_spa_19 missing_b_spa_19 missing_b_spa_21 b_eng_21 missing_b_eng_21 b_eng_21_sq b_GPA missing_b_GPA b_ABSENCE_COUNT_YEAR b_ABSENCE_COUNT_YEAR_sq b_GPA_mate missing_b_GPA_mate b_GPA_espa missing_b_GPA_espa b_ANNUAL_INCOME missing_b_ANNUAL_INCOME b_gr38_avg missing_b_gr38_avg x_adult_r_PO x_eng_21_eng_19 x_eng_21_gpa_m x_eng_21_gpa_e x_eng_21_gpa_s x_eng_21_sp_ed x_math_19_gpa x_gpa_sp_ed x_gpa_m_gpa_e x_gpa_m_gpa_s x_gpa_m_income x_gpa_s_sp_ed" 
		
		
global baseline "b_math_21 missing_b_math_21 b_GPA_mate missing_b_GPA_mate b_math_19 missing_b_math_19"


keep SMAX_STUDENT_ID school_21 ACADEMIC_YEAR_ID_FK GRADE_ID_FK strata math_score ///
atema_st atema_pe_st atema_lt atema_pe_lt control_pooled takeup ${controls_clean} ///
${baseline} ${strata_FE} ${grade_FE}

keep if math_score !=.
drop if atema_lt == 1 | atema_pe_lt == 1

// ddml (all students)
set seed 12345
ddml init iv, kfolds(5) reps(200) fcluster(school_21)

// add machine learners 
ddml E[Y|X]: ivreg math_score $strata_FE $grade_FE $baseline $controls_clean, cluster(school_21)
ddml E[Y|X]: rlasso math_score $strata_FE $grade_FE $baseline $controls_clean, partial($baseline $strata_FE $grade_FE) cluster(school_21)
ddml E[D|X]: ivreg takeup $strata_FE $grade_FE $baseline $controls_clean, cluster(school_21)
ddml E[D|X]: rlasso takeup $strata_FE $grade_FE $baseline $controls_clean, partial($baseline $strata_FE $grade_FE) cluster(school_21)
ddml E[Z|X]: ivreg atema_st $strata_FE $grade_FE $baseline $controls_clean, cluster(school_21)
ddml E[Z|X]: rlasso atema_st $strata_FE $grade_FE $baseline $controls_clean, partial($baseline $strata_FE $grade_FE) cluster(school_21)
ddml E[Z|X]: ivreg atema_pe_st $strata_FE $grade_FE $baseline $controls_clean, cluster(school_21)
ddml E[Z|X]: rlasso atema_pe_st $strata_FE $grade_FE $baseline $controls_clean, partial($baseline $strata_FE $grade_FE) cluster(school_21)


// check applied learners 
ddml describe

// cross-fitting
ddml crossfit, shortstack

// exporting table (all students) 
ddml estimate, robust
estimates store m1


// adding estimates
estadd scalar obs=e(N)

qui: sum math_score if control_pooled==1 
local m=r(mean) 
estadd scalar cmean = `m'


esttab m1 using "$output\tables\main\IV ddml method (1).tex", ///
style(tab) mlabels(none) label collabels(none) cells(b(star fmt(%9.3f)) se(par)) ///
stats(obs cmean, ///
fmt(%9.0fc %9.3fc) ///
labels("obs" "cmean")) ///
drop(o.*, relax) order(takeup, relax) replace starlevels(* 0.10 ** 0.05 *** 0.01)

clear
set obs 7
gen variable = "takeuup"
gen coef_all = .
gen se_all = .
gen pval_all = .

local vars "takeup"
foreach var of local vars {
    replace variable = "`var'" in `row'
    replace coef_all = _b[`var'] in `row'
    replace se_all = _se[`var'] in `row'
}


save "$output\data\IV ddml (method (1).dta", replace





