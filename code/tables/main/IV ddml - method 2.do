//----------------------------------------------------------------------------//
// File: 3. RFE ddml (pooled B) - math.do 
// Uses: master_khan_student
// Last update: May 14, 2025 by Sara Mostafa
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
log using "$output\Logs\tables\main\IV_ddml_method (2)", text replace

	
use "$input\master_controls", clear

		global strata_FE " "
		forvalues i = 2/84 {
			global strata_FE "$strata_FE strata`i'" 
		}
	
	global grade_FE "grade4 grade5 grade6 grade7 grade8"
	
gen control_pooled = 0 
	replace control_pooled = 1 if (treat_arm_3 == 1 & ACADEMIC_YEAR_ID_FK == 2022) | ///
	(treat_arm_4 == 1 & ACADEMIC_YEAR_ID_FK == 2022) | control == 1

global controls_clean "b_math_21 missing_b_math_21 b_math_21_sq x_math_21_eng_21 x_math_21_spa_21 x_math_21_pov_21 x_math_21_math_19 x_math_21_eng_19 x_math_21_spa_19 x_math_21_gpa x_math_21_gpa_m x_math_21_gpa_e x_math_21_gpa_s x_math_21_income x_math_21_internet x_math_21_adult x_math_21_t_grad x_math_21_t_drop x_math_21_t_enrol x_math_21_pt_ratio x_math_21_sp_ed x_math_21_cit x_math_21_sub x_math_21_rural x_math_21_t_female x_math_21_p_teach x_math_21_m_teach x_math_21_perm_t x_math_21_t_02 x_math_21_t_36 x_math_21_t_7 x_math_21_s_disp x_math_21_abs_y x_math_21_s_38 x_math_21_m_38 x_math_21_e_38 x_math_21_gr38 x_math_21_pov_19 x_math_21_r_AR x_math_21_r_BA x_math_21_r_CA x_math_21_r_HU x_math_21_r_MA x_math_21_r_PO x_math_21_r_SJ b_special_ed b_special_ed_sq x_math_21_sp_ed x_eng_21_sp_ed x_spa_21_sp_ed x_pov_21_sp_ed x_math_19_sp_ed x_eng_19_sp_ed x_spa_19_sp_ed x_gpa_sp_ed x_gpa_m_sp_ed x_gpa_e_sp_ed x_gpa_s_sp_ed x_income_sp_ed x_internet_sp_ed x_adult_sp_ed x_t_grad_sp_ed x_t_drop_sp_ed x_t_enrol_sp_ed x_pt_ratio_sp_ed x_sp_ed_cit x_sp_ed_sub x_sp_ed_rural x_sp_ed_t_female x_sp_ed_p_teach x_sp_ed_m_teach x_sp_ed_perm_t x_sp_ed_t_02 x_sp_ed_t_36 x_sp_ed_t_7 x_sp_ed_s_disp x_sp_ed_abs_y x_sp_ed_s_38 x_sp_ed_m_38 x_sp_ed_e_38 x_sp_ed_gr38 x_sp_ed_pov_19 x_sp_ed_r_AR x_sp_ed_r_BA x_sp_ed_r_CA x_sp_ed_r_HU x_sp_ed_r_MA x_sp_ed_r_PO x_sp_ed_r_SJ gender b_math_19 missing_b_math_19 b_math_19_sq x_math_21_math_19 x_eng_21_math_19 x_spa_21_math_19 x_pov_21_math_19 x_math_19_eng_19 x_math_19_spa_19 x_math_19_gpa x_math_19_gpa_m x_math_19_gpa_e x_math_19_gpa_s x_math_19_income x_math_19_internet x_math_19_adult x_math_19_t_grad x_math_19_t_drop x_math_19_t_enrol x_math_19_pt_ratio x_math_19_sp_ed x_math_19_cit x_math_19_sub x_math_19_rural x_math_19_t_female x_math_19_p_teach x_math_19_m_teach x_math_19_perm_t x_math_19_t_02 x_math_19_t_36 x_math_19_t_7 x_math_19_s_disp x_math_19_abs_y x_math_19_s_38 x_math_19_m_38 x_math_19_e_38 x_math_19_gr38 x_math_19_pov_19 x_math_19_r_AR x_math_19_r_BA x_math_19_r_CA x_math_19_r_HU x_math_19_r_MA x_math_19_r_PO x_math_19_r_SJ b_spa_19 missing_b_spa_19 b_spa_19_sq x_math_21_spa_19 x_eng_21_spa_19 x_spa_21_spa_19 x_pov_21_spa_19 x_math_19_spa_19 x_eng_19_spa_19 x_spa_19_gpa x_spa_19_gpa_m x_spa_19_gpa_e x_spa_19_gpa_s x_spa_19_income x_spa_19_internet x_spa_19_adult x_spa_19_t_grad x_spa_19_t_drop x_spa_19_t_enrol x_spa_19_pt_ratio x_spa_19_sp_ed x_spa_19_cit x_spa_19_sub x_spa_19_rural x_spa_19_t_female x_spa_19_p_teach x_spa_19_m_teach x_spa_19_perm_t x_spa_19_t_02 x_spa_19_t_36 x_spa_19_t_7 x_spa_19_s_disp x_spa_19_abs_y x_spa_19_s_38 x_spa_19_m_38 x_spa_19_e_38 x_spa_19_gr38 x_spa_19_pov_19 x_spa_19_r_AR x_spa_19_r_BA x_spa_19_r_CA x_spa_19_r_HU x_spa_19_r_MA x_spa_19_r_PO x_spa_19_r_SJ missing_b_spa_21 b_eng_21 missing_b_eng_21 b_eng_21_sq x_math_21_eng_21 x_eng_21_spa_21 x_eng_21_pov_21 x_eng_21_math_19 x_eng_21_eng_19 x_eng_21_spa_19 x_eng_21_gpa x_eng_21_gpa_m x_eng_21_gpa_e x_eng_21_gpa_s x_eng_21_income x_eng_21_internet x_eng_21_adult x_eng_21_t_grad x_eng_21_t_drop x_eng_21_t_enrol x_eng_21_pt_ratio x_eng_21_sp_ed x_eng_21_cit x_eng_21_sub x_eng_21_rural x_eng_21_t_female x_eng_21_p_teach x_eng_21_m_teach x_eng_21_perm_t x_eng_21_t_02 x_eng_21_t_36 x_eng_21_t_7 x_eng_21_s_disp x_eng_21_abs_y x_eng_21_s_38 x_eng_21_m_38 x_eng_21_e_38 x_eng_21_gr38 x_eng_21_pov_19 x_eng_21_r_AR x_eng_21_r_BA x_eng_21_r_CA x_eng_21_r_HU x_eng_21_r_MA x_eng_21_r_PO x_eng_21_r_SJ b_GPA missing_b_GPA b_GPA_sq x_math_21_gpa x_eng_21_gpa x_spa_21_gpa x_pov_21_gpa x_math_19_gpa x_eng_19_gpa x_spa_19_gpa x_gpa_gpa_m x_gpa_gpa_e x_gpa_gpa_s x_gpa_income x_gpa_internet x_gpa_adult x_gpa_t_grad x_gpa_t_drop x_gpa_t_enrol x_gpa_pt_ratio x_gpa_sp_ed x_gpa_cit x_gpa_sub x_gpa_rural x_gpa_t_female x_gpa_p_teach x_gpa_m_teach x_gpa_perm_t x_gpa_t_02 x_gpa_t_36 x_gpa_t_7 x_gpa_s_disp x_gpa_abs_y x_gpa_s_38 x_gpa_m_38 x_gpa_e_38 x_gpa_gr38 x_gpa_pov_19 x_gpa_r_AR x_gpa_r_BA x_gpa_r_CA x_gpa_r_HU x_gpa_r_MA x_gpa_r_PO x_gpa_r_SJ b_ABSENCE_COUNT_YEAR b_ABSENCE_COUNT_YEAR_sq x_math_21_abs_y x_eng_21_abs_y x_spa_21_abs_y x_pov_21_abs_y x_math_19_abs_y x_eng_19_abs_y x_spa_19_abs_y x_gpa_abs_y x_gpa_m_abs_y x_gpa_e_abs_y x_gpa_s_abs_y x_income_abs_y x_internet_abs_y x_adult_abs_y x_t_grad_abs_y x_t_drop_abs_y x_t_enrol_abs_y x_pt_ratio_abs_y x_sp_ed_abs_y x_cit_abs_y x_sub_abs_y x_rural_abs_y x_t_female_abs_y x_p_teach_abs_y x_m_teach_abs_y x_perm_t_abs_y x_t_02_abs_y x_t_36_abs_y x_t_7_abs_y x_s_disp_abs_y x_abs_y_s_38 x_abs_y_m_38 x_abs_y_e_38 x_abs_y_gr38 x_abs_y_pov_19 x_abs_y_r_AR x_abs_y_r_BA x_abs_y_r_CA x_abs_y_r_HU x_abs_y_r_MA x_abs_y_r_PO x_abs_y_r_SJ b_GPA_mate missing_b_GPA_mate b_GPA_mate_sq x_math_21_gpa_m x_eng_21_gpa_m x_spa_21_gpa_m x_pov_21_gpa_m x_math_19_gpa_m x_eng_19_gpa_m x_spa_19_gpa_m x_gpa_gpa_m x_gpa_m_teach x_gpa_m_38 x_gpa_m_gpa_e x_gpa_m_gpa_s x_gpa_m_income x_gpa_m_internet x_gpa_m_adult x_gpa_m_t_grad x_gpa_m_t_drop x_gpa_m_t_enrol x_gpa_m_pt_ratio x_gpa_m_sp_ed x_gpa_m_cit x_gpa_m_sub x_gpa_m_rural x_gpa_m_t_female x_gpa_m_p_teach x_gpa_m_m_teach x_gpa_m_perm_t x_gpa_m_t_02 x_gpa_m_t_36 x_gpa_m_t_7 x_gpa_m_s_disp x_gpa_m_abs_y x_gpa_m_s_38 x_gpa_m_m_38 x_gpa_m_e_38 x_gpa_m_gr38 x_gpa_m_pov_19 x_gpa_m_r_AR x_gpa_m_r_BA x_gpa_m_r_CA x_gpa_m_r_HU x_gpa_m_r_MA x_gpa_m_r_PO x_gpa_m_r_SJ b_GPA_espa missing_b_GPA_espa b_GPA_espa_sq x_math_21_gpa_s x_eng_21_gpa_s x_spa_21_gpa_s x_pov_21_gpa_s x_math_19_gpa_s x_eng_19_gpa_s x_spa_19_gpa_s x_gpa_gpa_s x_gpa_s_disp x_gpa_m_gpa_s x_gpa_e_gpa_s x_gpa_s_income x_gpa_s_internet x_gpa_s_adult x_gpa_s_t_grad x_gpa_s_t_drop x_gpa_s_t_enrol x_gpa_s_pt_ratio x_gpa_s_sp_ed x_gpa_s_cit x_gpa_s_sub x_gpa_s_rural x_gpa_s_t_female x_gpa_s_p_teach x_gpa_s_m_teach x_gpa_s_perm_t x_gpa_s_t_02 x_gpa_s_t_36 x_gpa_s_t_7 x_gpa_s_s_disp x_gpa_s_abs_y x_gpa_s_s_38 x_gpa_s_m_38 x_gpa_s_e_38 x_gpa_s_gr38 x_gpa_s_pov_19 x_gpa_s_r_AR x_gpa_s_r_BA x_gpa_s_r_CA x_gpa_s_r_HU x_gpa_s_r_MA x_gpa_s_r_PO x_gpa_s_r_SJ b_ANNUAL_INCOME missing_b_ANNUAL_INCOME b_ANNUAL_INCOME_sq x_math_21_income x_eng_21_income x_spa_21_income x_pov_21_income x_math_19_income x_eng_19_income x_spa_19_income x_gpa_income x_gpa_m_income x_gpa_e_income x_gpa_s_income x_income_internet x_income_adult x_income_t_grad x_income_t_drop x_income_t_enrol x_income_pt_ratio x_income_sp_ed x_income_cit x_income_sub x_income_rural x_income_t_female x_income_p_teach x_income_m_teach x_income_perm_t x_income_t_02 x_income_t_36 x_income_t_7 x_income_s_disp x_income_abs_y x_income_s_38 x_income_m_38 x_income_e_38 x_income_gr38 x_income_pov_19 x_income_r_AR x_income_r_BA x_income_r_CA x_income_r_HU x_income_r_MA x_income_r_PO x_income_r_SJ b_gr38_avg missing_b_gr38_avg b_gr38_avg_sq x_math_21_gr38 x_eng_21_gr38 x_spa_21_gr38 x_pov_21_gr38 x_math_19_gr38 x_eng_19_gr38 x_spa_19_gr38 x_gpa_gr38 x_gpa_m_gr38 x_gpa_e_gr38 x_gpa_s_gr38 x_income_gr38 x_internet_gr38 x_adult_gr38 x_t_grad_gr38 x_t_drop_gr38 x_t_enrol_gr38 x_pt_ratio_gr38 x_sp_ed_gr38 x_cit_gr38 x_sub_gr38 x_rural_gr38 x_t_female_gr38 x_p_teach_gr38 x_m_teach_gr38 x_perm_t_gr38 x_t_02_gr38 x_t_36_gr38 x_t_7_gr38 x_s_disp_gr38 x_abs_y_gr38 x_s_38_gr38 x_m_38_gr38 x_e_38_gr38 x_gr38_pov_19 x_gr38_r_AR x_gr38_r_BA x_gr38_r_CA x_gr38_r_HU x_gr38_r_MA x_gr38_r_PO x_gr38_r_SJ x_adult_r_PO"		
		
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


esttab m1 using "$output\tables\main\IV ddml method (2).tex", ///
style(tab) mlabels(none) label collabels(none) cells(b(star fmt(%9.3f)) se(par)) ///
stats(obs cmean, ///
fmt(%9.0fc %9.3fc) ///
labels("obs" "cmean")) ///
drop(o.*, relax) order(takeup, relax) replace starlevels(* 0.10 ** 0.05 *** 0.01)

clear
set obs 7
gen variable = "takeup"
gen coef_all = .
gen se_all = .
gen pval_all = .

local vars "takeup"
foreach var of local vars {
    replace variable = "`var'" in `row'
    replace coef_all = _b[`var'] in `row'
    replace se_all = _se[`var'] in `row'
}


save "$output\data\IV ddml (method (2).dta", replace





