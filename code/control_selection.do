//----------------------------------------------------------------------------//
// File name: control_selection
// Last updated: October 25, 2024 by Sara Mostafa
//----------------------------------------------------------------------------//


clear all
set matsize 6000
set more off 
global dir "D:\SECURE\data 2024\analysis\atema" 
global input "$dir\data" 
global output "$dir\output"

//cap log close
//log using "$output\Logs\control_selection.txt", text replace

use "$input\master_khan_student_combined", clear 

ren strata old_strata
egen strata = group(old_strata ACADEMIC_YEAR_ID_FK)
	
// FE dummy variables 
	// grade FE
		gen grade4 = (grade_21 == 6)
		gen grade5 = (grade_21 == 7) 
		gen grade6 = (grade_21 == 8) 
		gen grade7 = (grade_21 == 9) 
		gen grade8 = (grade_21 == 10)
		global grade_FE "grade4 grade5 grade6 grade7 grade8"
		
		// strata FE 
		levelsof strata, local(unique_strata)
		global strata_FE " "
		foreach val of local unique_strata{
			gen strata`val' = (strata == `val')
			global strata_FE "${strata_FE} strata`val'"
		}
	

	
	
// program for the lasso cleaning process 	
program isvar, rclass  
	version 8 
	syntax anything 
	
	foreach v of local anything { 
		capture unab V : `v' 
		if _rc == 0 local varlist `varlist' `V' 
		else        local badlist `badlist' `v' 
	}

	di 

	if "`varlist'" != "" { 
		local n : word count `varlist' 
		local what = plural(`n', "variable") 
		di as txt "{p}`what': " as res "`varlist'{p_end}" 
		return local varlist "`varlist'" 
	}	
	
	if "`badlist'" != "" {
		local n : word count `badlist' 
		local what = plural(`n', "not variable") 
		di as txt "{p}`what': " as res "`badlist'{p_end}" 
		return local badlist "`badlist'" 
	}	
end 


//-------- CONTROLS FROM 2019 & 2021 BASELINE --------//
	
// 1. Identifying controls to be included
rename (b_Español_38avg b_Matemáticas_38avg b_Inglés_38avg) (b_espanol_38avg b_matematicas_38avg b_ingles_38avg)
	
	
global controls "b_math_21 b_eng_21 b_spa_21 b_poverty_21 b_math_19 b_eng_19 b_spa_19 b_poverty_19 b_GPA b_GPA_mate b_GPA_ingl b_GPA_espa b_ANNUAL_INCOME b_INTERNET_AT_HOME b_adult_flag b_s_total_graduated b_s_total_dropped b_students_enrolled b_special_ed b_total_enrollment b_pupil_teacher_ratio b_city b_suburb b_town_rural b_female_teach b_ps_teach b_ms_teach b_permanent b_teach_exp02 b_teach_exp36 b_teach_exp7 b_displaced_student b_ABSENCE_COUNT_YEAR b_espanol_38avg b_matematicas_38avg b_ingles_38avg b_gr38_avg b_ARECIBO b_BAYAMON b_CAGUAS b_HUMACAO b_MAYAGUEZ b_PONCE b_SANJUAN"


// 2. standardize 

foreach y of global controls{
	egen std_`y' = std(`y')
	replace `y' = std_`y' 
	drop std_`y'
}



// 3. Controlling for missing values and replacing them with zeros //

global m_controls " "
foreach y of global controls {
	qui: gen missing_`y'= 0
	qui: replace missing_`y'=1 if `y' == .
	global m_controls "${m_controls} missing_`y'"
}



foreach y of global controls{

	replace `y' = 0 if missing_`y' == 1
		
}


	//check that all missing variables are replaced 
	foreach y of global controls{
	count if `y' == . 
	}
	// no more missing observations for controls


	
// 5. Squared variables 
global sq_controls " "
foreach var of global controls {
		qui: gen `var'_sq= `var'^2
		global sq_controls "${sq_controls} `var'_sq"
	}


global controls_1 "${controls} ${m_controls} ${sq_controls}"

// removing variables that have the same value for everything
global drop " " 
foreach var of varlist $controls_1 {
	qui: sum `var'
	if r(min)==r(max) {
		global drop "${drop} `var'" 
		drop `var'
	}
}


global controls_2: list global(controls_1) - global(drop)

// 6. getting rid of perfectly collinear variables
_rmcoll $controls_2 
global omitted "`r(varlist)'"
global omit_vars : list global(controls_2) - global(omitted)
global controls_3 : list global(controls_2) - global(omit_vars)


	
/// 7. Two-way interactions
// renaming to shorten variable names and allow for interaction variable names
rename (b_math_21 b_eng_21 b_spa_21 b_poverty_21 b_math_19 b_eng_19 b_spa_19 ///
b_GPA b_GPA_mate b_GPA_ingl b_GPA_espa b_ANNUAL_INCOME b_INTERNET_AT_HOME b_adult_flag ///
b_s_total_graduated b_s_total_dropped b_students_enrolled b_pupil_teacher_ratio ///
b_special_ed b_city b_suburb b_town_rural b_female_teach b_ps_teach ///
b_ms_teach b_permanent b_teach_exp02 b_teach_exp36 b_teach_exp7 b_displaced_student ///
b_ABSENCE_COUNT_YEAR b_espanol_38avg b_matematicas_38avg ///
b_ingles_38avg b_gr38_avg b_poverty_19 b_ARECIBO b_BAYAMON b_CAGUAS b_HUMACAO b_MAYAGUEZ ///
b_PONCE b_SANJUAN) ///
(math_21 eng_21 spa_21 pov_21 math_19 eng_19 spa_19 gpa gpa_m gpa_e gpa_s income internet ///
adult t_grad t_drop t_enrol pt_ratio sp_ed cit sub rural t_female p_teach m_teach ///
perm_t t_02 t_36 t_7 s_disp abs_y s_38 m_38 e_38 gr38 pov_19 r_AR r_BA r_CA r_HU r_MA r_PO r_SJ)


global r_controls "math_21 eng_21 spa_21 pov_21 math_19 eng_19 spa_19 gpa gpa_m gpa_e gpa_s income internet adult t_grad t_drop t_enrol pt_ratio sp_ed cit sub rural t_female p_teach m_teach perm_t t_02 t_36 t_7 s_disp abs_y s_38 m_38 e_38 gr38 pov_19 r_AR r_BA r_CA r_HU r_MA r_PO r_SJ"

global drop ""
global int_controls " "
unab twoway: $r_controls 
local K: word count `twoway'
forv i=1(1)`=`K'-1' {
	forv j=`=`i'+1'(1)`K' {
		local y: word `i' of `twoway'
		local x: word `j' of `twoway'
		qui: gen x_`y'_`x'=`y'*`x'
		global int_controls "${int_controls} x_`y'_`x'"
	}
}
foreach var of varlist $int_controls {
	qui: sum `var'
	if r(min)==r(max) {
		global drop "${drop} `var'" 
		qui: drop `var'
	}
}

	//rename back to original name
rename (math_21 eng_21 spa_21 pov_21 math_19 eng_19 spa_19 gpa gpa_m gpa_e gpa_s income internet ///
adult t_grad t_drop t_enrol pt_ratio sp_ed cit sub rural t_female p_teach m_teach ///
perm_t t_02 t_36 t_7 s_disp abs_y s_38 m_38 e_38 gr38 pov_19 r_AR r_BA r_CA r_HU r_MA r_PO r_SJ) ///
(b_math_21 b_eng_21 b_spa_21 b_poverty_21 b_math_19 b_eng_19 b_spa_19 b_GPA b_GPA_mate b_GPA_ingl b_GPA_espa ///
b_ANNUAL_INCOME b_INTERNET_AT_HOME b_adult_flag b_s_total_graduated b_s_total_dropped ///
b_students_enrolled b_pupil_teacher_ratio b_special_ed b_city ///
b_suburb b_town_rural b_female_teach b_ps_teach b_ms_teach b_permanent b_teach_exp02 ///
b_teach_exp36 b_teach_exp7 b_displaced_student b_ABSENCE_COUNT_YEAR b_espanol_38avg ///
b_matematicas_38avg b_ingles_38avg b_gr38_avg b_poverty_19 b_ARECIBO b_BAYAMON ///
b_CAGUAS b_HUMACAO b_MAYAGUEZ b_PONCE b_SANJUAN)

global controls_4 "${int_controls} ${controls_3}"


// 8. Get rid of perfectly collinear variables including interactions

_rmcoll $controls_4
global drop "`r(varlist)'"
global flagged : list global(controls_4) - global(drop)
global controls_clean : list global(controls_4) - global(flagged)
di "${controls_clean}"



//Lasso 

	rlasso atema_st $strata_FE $grade_FE $controls_clean, partial($strata_FE $grade_FE) robust cluster(school_21)
		ereturn list
		global st: di e(selected) 
		
	rlasso atema_pe_st $strata_FE $grade_FE $controls_clean, partial($strata_FE $grade_FE) robust cluster(school_21)
		ereturn list
		global pe_st: di e(selected) 	// 0 selected
		
	rlasso atema_lt $strata_FE $grade_FE $controls_clean, partial($strata_FE $grade_FE) robust cluster(school_21)
		ereturn list
		global lt: di e(selected) 	// 0 selected

	rlasso atema_pe_lt $strata_FE $grade_FE $controls_clean, partial($strata_FE $grade_FE) robust cluster(school_21)
		ereturn list
		global pe_lt: di e(selected) 	// 0 selected
			
	rlasso math_score $strata_FE $grade_FE $controls_clean, partial($strata_FE $grade_FE) robust cluster(school_21)
		ereturn list 
		global score: di e(selected) 
		

global s_controls "${st} ${score}"
		
//selected controls -- i forced baseline math scores that were not selected
global s_controls "b_math_21 missing_b_math_21 b_special_ed missing_b_special_ed gender b_math_19 missing_b_math_19 b_spa_19 missing_b_spa_19 missing_b_spa_21 b_eng_21 missing_b_eng_21 b_eng_21_sq b_GPA missing_b_GPA b_ABSENCE_COUNT_YEAR missing_b_ABSENCE_COUNT_YEAR b_ABSENCE_COUNT_YEAR_sq b_GPA_mate missing_b_GPA_mate b_GPA_espa missing_b_GPA_espa b_ANNUAL_INCOME missing_b_ANNUAL_INCOME b_gr38_avg missing_b_gr38_avg x_adult_r_PO x_eng_21_eng_19 x_eng_21_gpa_m x_eng_21_gpa_e x_eng_21_gpa_s x_eng_21_sp_ed x_math_19_gpa x_gpa_sp_ed x_gpa_m_gpa_e x_gpa_m_gpa_s x_gpa_m_income x_gpa_s_sp_ed" 





 

save "$input\master_controls", replace	
	
	
	
	
	
	
	
	
