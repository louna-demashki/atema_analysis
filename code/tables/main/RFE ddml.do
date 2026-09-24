//----------------------------------------------------------------------------//
// File: 3. RFE ddml (pooled B) - math.do 
// Uses: master_khan_student
// Last update: Oct. 31, 2024 by Sara Mostafa
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
log using "$output\Logs\tables\main\RFE_ddml_m", text replace

	
use "$input\master_khan_student_combined", clear 

drop if ACADEMIC_YEAR_ID_FK==.

rename strata old_strata
egen strata = group(old_strata ACADEMIC_YEAR_ID_FK)

	
		// FE dummy variables 
		// grade FE
		gen grade4 = (GRADE_ID_FK == 6)
		gen grade5 = (GRADE_ID_FK == 7) 
		gen grade6 = (GRADE_ID_FK == 8) 
		gen grade7 = (GRADE_ID_FK == 9) 
		gen grade8 = (GRADE_ID_FK == 10)
		
		// strata FE 
		levelsof strata, local(unique_strata)
		foreach val of local unique_strata{
			gen strata`val' = (strata == `val')
		}
		
	global grade_FE "grade4 grade5 grade6 grade7 grade8"
	global strata_FE "strata1 strata2 strata3 strata4 strata5 strata6 strata7 strata8 strata9 strata10 strata11 strata12 strata13 strata14 strata15 strata16 strata17 strata18 strata19 strata20 strata21 strata22 strata23 strata24 strata25 strata26 strata27 strata28 strata29 strata30 strata31 strata32 strata33 strata34 strata35 strata36 strata37 strata38 strata39 strata40 strata41 strata42 strata43 strata44 strata45 strata46 strata47 strata48 strata49 strata50 strata51 strata52 strata53 strata54 strata55 strata56 strata57 strata58 strata59 strata60 strata61 strata62 strata63 strata64 strata65 strata66 strata67 strata68 strata69 strata70 strata71 strata72 strata73 strata74 strata75 strata76 strata77 strata78 strata79 strata80 strata81 strata82 strata83 strata84"

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

//-------- CONTROLS FROM 2019 and 2021 BASELINE --------//
	
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
drop math_21 eng_21 spa_21
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

global baseline "b_math_21 missing_b_math_21 b_GPA_mate missing_b_GPA_mate b_math_19 missing_b_math_19"

	stop

keep SMAX_STUDENT_ID school_21 ACADEMIC_YEAR_ID_FK GRADE_ID_FK strata math_score ///
treat_arm_1 treat_arm_2 treat_arm_3 treat_arm_4 ///
atema_st atema_pe_st atema_lt atema_pe_lt control gender above_median ${controls_clean} ///
${strata_FE} ${grade_FE} ${baseline} 


// ddml (all students)
set seed 12345
ddml init partial if math_score!=., kfolds(5) reps(200) fcluster(school_21) 

//add machine learners (all students)
ddml E[Y|X]: reg math_score $strata_FE $grade_FE $baseline $controls_clean, cluster(school_21)
ddml E[Y|X]: rlasso math_score $strata_FE $grade_FE $baseline $controls_clean, partial($baseline $strata_FE $grade_FE)  
ddml E[D|X]: reg atema_st $strata_FE $grade_FE $baseline $controls_clean, cluster(school_21)
ddml E[D|X]: rlasso atema_st $strata_FE $grade_FE $baseline $controls_clean, partial($baseline $strata_FE $grade_FE)  
ddml E[D|X]: reg atema_pe_st $strata_FE $grade_FE $baseline $controls_clean, cluster(school_21)
ddml E[D|X]: rlasso atema_pe_st $strata_FE $grade_FE $baseline $controls_clean, partial($baseline $strata_FE $grade_FE)  
ddml E[D|X]: reg atema_lt $strata_FE $grade_FE $baseline $controls_clean, cluster(school_21)
ddml E[D|X]: rlasso atema_lt $strata_FE $grade_FE $baseline $controls_clean, partial($baseline $strata_FE $grade_FE)  
ddml E[D|X]: reg atema_pe_lt $strata_FE $grade_FE $baseline $controls_clean, cluster(school_21)
ddml E[D|X]: rlasso atema_pe_lt $strata_FE $grade_FE $baseline $controls_clean, partial($baseline $strata_FE $grade_FE)  


// check applied learners 
ddml describe

// cross-fitting
ddml crossfit, shortstack

// exporting table (all students) 
ddml estimate
estimates store m1


// adding estimates
estadd scalar obs=e(N)

qui: sum math_score if control==1 | (treat_arm_3==1 & ACADEMIC_YEAR_ID_FK==2022) | ///
(treat_arm_4==1 & ACADEMIC_YEAR_ID_FK==2022)
local m=r(mean) 
estadd scalar cmean = `m'

test atema_st = atema_pe_st
local p1=r(p)
estadd scalar pval1=`p1'

test atema_st = atema_lt
local p2=r(p)
estadd scalar pval2=`p2'

test atema_pe_st = atema_pe_lt
local p3=r(p)
estadd scalar pval3=`p3'


esttab m1 using "$output\tables\main\03. RFE ddml (all).tex", ///
style(tab) mlabels(none) label collabels(none) cells(b(star fmt(%9.3f)) se(par)) ///
stats(obs cmean pval1 pval2 pval3, ///
fmt(%9.0fc %9.3fc %9.3fc %9.3fc %9.3fc) ///
labels("obs" "cmean" "pval1" "pval2" "pval3")) ///
drop(o.*, relax) order(atema_st atema_pe_st atema_lt atema_pe_lt, relax) replace starlevels(* 0.10 ** 0.05 *** 0.01)

clear
set obs 7
gen variable = ""
gen coef_all = .
gen se_all = .
gen pval_all = .

local vars "atema_st atema_pe_st atema_lt atema_pe_lt"
local row = 1
foreach var of local vars {
    replace variable = "`var'" in `row'
    replace coef_all = _b[`var'] in `row'
    replace se_all = _se[`var'] in `row'
    local row = `row' + 1
}

replace variable = "Test: atema_st = atema_pe_st" in 5
replace pval_all = `p1' in 5

replace variable = "Test: atema_st = atema_lt" in 6
replace pval_all = `p2' in 6

replace variable = "Test: atema_pe_st = atema_pe_lt" in 7
replace pval_all = `p3' in 7

save "$output\data\03. RFE ddml (all).dta", replace

//============================================================================//
// By school performance
//============================================================================//

// reset 
keep SMAX_STUDENT_ID SCHOOL_CODE ACADEMIC_YEAR_ID_FK GRADE_ID_FK strata math_score ///
atema_st atema_pe_st atema_lt atema_pe_lt control treat_arm_3 treat_arm_4 gender above_median ${controls_clean} ///
${strata_FE} ${grade_FE} ${baseline} 


//add machine learners (above-median)
set seed 12345
ddml init partial if above_median==1 & math_score!=., kfolds(5) reps(200) fcluster(SCHOOL_CODE)

ddml E[Y|X]: reg math_score $strata_FE $grade_FE $baseline $controls_clean, cluster(SCHOOL_CODE)
ddml E[Y|X]: rlasso math_score $strata_FE $grade_FE $baseline $controls_clean, partial($baseline $strata_FE $grade_FE)  
ddml E[D|X]: reg atema_st $strata_FE $grade_FE $baseline $controls_clean, cluster(SCHOOL_CODE)
ddml E[D|X]: rlasso atema_st $strata_FE $grade_FE $baseline $controls_clean, partial($baseline $strata_FE $grade_FE)  
ddml E[D|X]: reg atema_pe_st $strata_FE $grade_FE $baseline $controls_clean, cluster(SCHOOL_CODE)
ddml E[D|X]: rlasso atema_pe_st $strata_FE $grade_FE $baseline $controls_clean, partial($baseline $strata_FE $grade_FE)  
ddml E[D|X]: reg atema_lt $strata_FE $grade_FE $baseline $controls_clean, cluster(SCHOOL_CODE)
ddml E[D|X]: rlasso atema_lt $strata_FE $grade_FE $baseline $controls_clean, partial($baseline $strata_FE $grade_FE)  
ddml E[D|X]: reg atema_pe_lt $strata_FE $grade_FE $baseline $controls_clean, cluster(SCHOOL_CODE)
ddml E[D|X]: rlasso atema_pe_lt $strata_FE $grade_FE $baseline $controls_clean, partial($baseline $strata_FE $grade_FE)  


// check applied learners 
ddml describe

// cross-fitting
ddml crossfit, shortstack

// exporting table  
ddml estimate, robust
estimates store m2


// adding estimates
estadd scalar obs=e(N)

qui: sum math_score if (control==1 | treat_arm_3==1 | treat_arm_4==1) & above_median==1
local m=r(mean) 
estadd scalar cmean_22 = `m'
qui: sum math_score if control==1 & above_median==1
local m=r(mean) 
estadd scalar cmean_23 = `m'

test atema_st = atema_pe_st
local p1=r(p)
estadd scalar pval1=`p1'

test atema_st = atema_lt
local p2=r(p)
estadd scalar pval2=`p2'

test atema_pe_st = atema_pe_lt
local p3=r(p)
estadd scalar pval3=`p3'


esttab m2 using "$output\tables\main\03. RFE ddml (above-median).tex", ///
style(tab) mlabels(none) label collabels(none) cells(b(star fmt(%9.3f)) se(par)) ///
stats(obs cmean_22 cmean_23 pval1 pval2 pval3, ///
fmt(%9.0fc %9.3fc %9.3fc %9.3fc %9.3fc %9.3fc) ///
labels("obs" "cmean_22" "cmean23" "pval1" "pval2" "pval3")) ///
drop(o.*, relax) order(atema_st atema_pe_st atema_lt atema_pe_lt, relax) replace starlevels(* 0.10 ** 0.05 *** 0.01)
 

clear
set obs 7
gen variable = ""
gen coef_all = .
gen se_all = .
gen pval_all = .

local vars "atema_st atema_pe_st atema_lt atema_pe_lt"
local row = 1
foreach var of local vars {
    replace variable = "`var'" in `row'
    replace coef_all = _b[`var'] in `row'
    replace se_all = _se[`var'] in `row'
    local row = `row' + 1
}

replace variable = "Test: atema_st = atema_pe_st" in 5
replace pval_all = `p1' in 5

replace variable = "Test: atema_st = atema_lt" in 6
replace pval_all = `p2' in 6

replace variable = "Test: atema_pe_st = atema_pe_lt" in 7
replace pval_all = `p3' in 7

save "$output\data\03. RFE ddml (above-median).dta", replace



// reset 
keep SMAX_STUDENT_ID school_21 ACADEMIC_YEAR_ID_FK GRADE_ID_FK strata math_score ///
atema_st atema_pe_st atema_lt atema_pe_lt control gender above_median ${controls_clean} ///
${strata_FE} ${grade_FE} ${baseline} 


//add machine learners (below-median)
set seed 12345
ddml init partial if above_median==0 & math_score!=., kfolds(5) reps(200) fcluster(school_21)

ddml E[Y|X]: reg math_score $strata_FE $grade_FE $baseline $controls_clean, cluster(school_21)
ddml E[Y|X]: rlasso math_score $strata_FE $grade_FE $baseline $controls_clean, partial($baseline $strata_FE $grade_FE)  
ddml E[D|X]: reg atema_st $strata_FE $grade_FE $baseline $controls_clean, cluster(school_21)
ddml E[D|X]: rlasso atema_st $strata_FE $grade_FE $baseline $controls_clean, partial($baseline $strata_FE $grade_FE)  
ddml E[D|X]: reg atema_pe_st $strata_FE $grade_FE $baseline $controls_clean, cluster(school_21)
ddml E[D|X]: rlasso atema_pe_st $strata_FE $grade_FE $baseline $controls_clean, partial($baseline $strata_FE $grade_FE)  
ddml E[D|X]: reg atema_lt $strata_FE $grade_FE $baseline $controls_clean, cluster(school_21)
ddml E[D|X]: rlasso atema_lt $strata_FE $grade_FE $baseline $controls_clean, partial($baseline $strata_FE $grade_FE)  
ddml E[D|X]: reg atema_pe_lt $strata_FE $grade_FE $baseline $controls_clean, cluster(school_21)
ddml E[D|X]: rlasso atema_pe_lt $strata_FE $grade_FE $baseline $controls_clean, partial($baseline $strata_FE $grade_FE)  


// check applied learners 
ddml describe

// cross-fitting
ddml crossfit, shortstack

// exporting table 
ddml estimate, robust
estimates store m3

// adding estimates
estadd scalar obs=e(N)

//qui: sum math_score if (control==1 | treat_arm_3==1 | treat_arm_4==1) & above_median==0 & ACADEMIC_YEAR_ID_FK==2022
//local m22=r(mean) 
//estadd scalar cmean_22 = `m22'
qui: sum math_score if control==1 & above_median==0 & ACADEMIC_YEAR_ID_FK==2023
local m23=r(mean) 
estadd scalar cmean_23 = `m23'

test atema_st = atema_pe_st
local p1=r(p)
estadd scalar pval1=`p1'

test atema_st = atema_lt
local p2=r(p)
estadd scalar pval2=`p2'

test atema_pe_st = atema_pe_lt
local p3=r(p)
estadd scalar pval3=`p3'


esttab m3 using "$output\tables\main\03. RFE ddml (below-median).tex", ///
style(tab) mlabels(none) label collabels(none) cells(b(star fmt(%9.3f)) se(par)) ///
stats(obs cmean_22 cmean_23 pval1 pval2 pval3, ///
fmt(%9.0fc %9.3fc %9.3fc %9.3fc %9.3fc %9.3fc) ///
labels("obs" "cmean_22" "cmean23" "pval1" "pval2" "pval3")) ///
drop(o.*, relax) order(atema_st atema_pe_st atema_lt atema_pe_lt, relax) replace starlevels(* 0.10 ** 0.05 *** 0.01)

clear
set obs 7
gen variable = ""
gen coef_bm = .
gen se_bm = .
gen pval_bm = .

local vars "atema_st atema_pe_st atema_lt atema_pe_lt"
local row = 1
foreach var of local vars {
    replace variable = "`var'" in `row'
    replace coef_bm = _b[`var'] in `row'
    replace se_bm = _se[`var'] in `row'
    local row = `row' + 1
}

replace variable = "Test: atema_st = atema_pe_st" in 5
replace pval_bm = `p1' in 5

replace variable = "Test: atema_st = atema_lt" in 6
replace pval_bm = `p2' in 6

replace variable = "Test: atema_pe_st = atema_pe_lt" in 7
replace pval_bm = `p3' in 7

save "$output\data\03. RFE ddml (below-median).dta", replace




//============================================================================//
// By gender
//============================================================================//

// reset 
keep SMAX_STUDENT_ID school_21 ACADEMIC_YEAR_ID_FK GRADE_ID_FK strata math_score ///
atema_st atema_pe_st atema_lt atema_pe_lt control gender above_median treat_arm_1 ///
treat_arm_2 treat_arm_3 treat_arm_4 ${controls_clean} ///
${strata_FE} ${grade_FE} ${baseline} 


//add machine learners (female)
set seed 12345
ddml init partial if gender==1 & math_score!=., kfolds(5) reps(200) fcluster(school_21)

ddml E[Y|X]: reg math_score $strata_FE $grade_FE $baseline $controls_clean, cluster(school_21)
ddml E[Y|X]: rlasso math_score $strata_FE $grade_FE $baseline $controls_clean, partial($baseline $strata_FE $grade_FE)  
ddml E[D|X]: reg atema_st $strata_FE $grade_FE $baseline $controls_clean, cluster(school_21)
ddml E[D|X]: rlasso atema_st $strata_FE $grade_FE $baseline $controls_clean, partial($baseline $strata_FE $grade_FE)  
ddml E[D|X]: reg atema_pe_st $strata_FE $grade_FE $baseline $controls_clean, cluster(school_21)
ddml E[D|X]: rlasso atema_pe_st $strata_FE $grade_FE $baseline $controls_clean, partial($baseline $strata_FE $grade_FE)  
ddml E[D|X]: reg atema_lt $strata_FE $grade_FE $baseline $controls_clean, cluster(school_21)
ddml E[D|X]: rlasso atema_lt $strata_FE $grade_FE $baseline $controls_clean, partial($baseline $strata_FE $grade_FE)  
ddml E[D|X]: reg atema_pe_lt $strata_FE $grade_FE $baseline $controls_clean, cluster(school_21)
ddml E[D|X]: rlasso atema_pe_lt $strata_FE $grade_FE $baseline $controls_clean, partial($baseline $strata_FE $grade_FE)  


// check applied learners 
ddml describe

// cross-fitting
ddml crossfit, shortstack

// exporting table 
ddml estimate, robust
estimates store m4


// adding estimates
estadd scalar obs=e(N)

qui: sum math_score if (control==1 | treat_arm_3==1 | treat_arm_4==1) & gender==1 & ACADEMIC_YEAR_ID_FK==2022
local m=r(mean) 
estadd scalar cmean_22 = `m'
qui: sum math_score if control==1 & gender==1 & ACADEMIC_YEAR_ID_FK==2023
local m=r(mean) 
estadd scalar cmean_23 = `m'

test atema_st = atema_pe_st
local p1=r(p)
estadd scalar pval1=`p1'

test atema_st = atema_lt
local p2=r(p)
estadd scalar pval2=`p2'

test atema_pe_st = atema_pe_lt
local p3=r(p)
estadd scalar pval3=`p3'


esttab m4 using "$output\tables\main\03. RFE ddml (female).tex", ///
style(tab) mlabels(none) label collabels(none) cells(b(star fmt(%9.3f)) se(par)) ///
stats(obs cmean_22 cmean_23 pval1 pval2 pval3, ///
fmt(%9.0fc %9.3fc %9.3fc %9.3fc %9.3fc %9.3fc) ///
labels("obs" "cmean_22" "cmean23" "pval1" "pval2" "pval3")) ///
drop(o.*, relax) order(atema_st atema_pe_st atema_lt atema_pe_lt, relax) replace starlevels(* 0.10 ** 0.05 *** 0.01)

clear
set obs 7
gen variable = ""
gen coef_f = .
gen se_f = .
gen pval_f = .

local vars "atema_st atema_pe_st atema_lt atema_pe_lt"
local row = 1
foreach var of local vars {
    replace variable = "`var'" in `row'
    replace coef_f = _b[`var'] in `row'
    replace se_f = _se[`var'] in `row'
    local row = `row' + 1
}

replace variable = "Test: atema_st = atema_pe_st" in 5
replace pval_f = `p1' in 5

replace variable = "Test: atema_st = atema_lt" in 6
replace pval_f = `p2' in 6

replace variable = "Test: atema_pe_st = atema_pe_lt" in 7
replace pval_f = `p3' in 7

save "$output\data\03. RFE ddml (female).dta", replace



// reset 
keep SMAX_STUDENT_ID school_21 ACADEMIC_YEAR_ID_FK GRADE_ID_FK strata math_score ///
atema_st atema_pe_st atema_lt atema_pe_lt control gender above_median treat_arm_1 ///
treat_arm_2 treat_arm_3 treat_arm_4 ${controls_clean} ///
${strata_FE} ${grade_FE} ${baseline} 


//add machine learners (female)
set seed 12345
ddml init partial if gender==0 & math_score!=., kfolds(5) reps(200) fcluster(school_21)

ddml E[Y|X]: reg math_score $strata_FE $grade_FE $baseline $controls_clean, cluster(school_21)
ddml E[Y|X]: rlasso math_score $strata_FE $grade_FE $baseline $controls_clean, partial($baseline $strata_FE $grade_FE)  
ddml E[D|X]: reg atema_st $strata_FE $grade_FE $baseline $controls_clean, cluster(school_21)
ddml E[D|X]: rlasso atema_st $strata_FE $grade_FE $baseline $controls_clean, partial($baseline $strata_FE $grade_FE)  
ddml E[D|X]: reg atema_pe_st $strata_FE $grade_FE $baseline $controls_clean, cluster(school_21)
ddml E[D|X]: rlasso atema_pe_st $strata_FE $grade_FE $baseline $controls_clean, partial($baseline $strata_FE $grade_FE)  
ddml E[D|X]: reg atema_lt $strata_FE $grade_FE $baseline $controls_clean, cluster(school_21)
ddml E[D|X]: rlasso atema_lt $strata_FE $grade_FE $baseline $controls_clean, partial($baseline $strata_FE $grade_FE)  
ddml E[D|X]: reg atema_pe_lt $strata_FE $grade_FE $baseline $controls_clean, cluster(school_21)
ddml E[D|X]: rlasso atema_pe_lt $strata_FE $grade_FE $baseline $controls_clean, partial($baseline $strata_FE $grade_FE)  


// check applied learners 
ddml describe

// cross-fitting
ddml crossfit, shortstack

// exporting table 
ddml estimate, robust
estimates store m5


// adding estimates
estadd scalar obs=e(N)

qui: sum math_score if (control==1 | treat_arm_3==1 | treat_arm_4==1) & gender==0 & ACADEMIC_YEAR_ID_FK==2022
local m=r(mean) 
estadd scalar cmean_22 = `m'
qui: sum math_score if control==1 & gender==0 & ACADEMIC_YEAR_ID_FK==2023
local m=r(mean) 
estadd scalar cmean_23 = `m'

test atema_st = atema_pe_st
local p1=r(p)
estadd scalar pval1=`p1'

test atema_st = atema_lt
local p2=r(p)
estadd scalar pval2=`p2'

test atema_pe_st = atema_pe_lt
local p3=r(p)
estadd scalar pval3=`p3'


esttab m5 using "$output\tables\main\03. RFE ddml (male).tex", ///
style(tab) mlabels(none) label collabels(none) cells(b(star fmt(%9.3f)) se(par)) ///
stats(obs cmean_22 cmean_23 pval1 pval2 pval3, ///
fmt(%9.0fc %9.3fc %9.3fc %9.3fc %9.3fc %9.3fc) ///
labels("obs" "cmean_22" "cmean23" "pval1" "pval2" "pval3")) ///
drop(o.*, relax) order(atema_st atema_pe_st atema_lt atema_pe_lt, relax) replace starlevels(* 0.10 ** 0.05 *** 0.01)

clear
set obs 7
gen variable = ""
gen coef_f = .
gen se_f = .
gen pval_f = .

local vars "atema_st atema_pe_st atema_lt atema_pe_lt"
local row = 1
foreach var of local vars {
    replace variable = "`var'" in `row'
    replace coef_f = _b[`var'] in `row'
    replace se_f = _se[`var'] in `row'
    local row = `row' + 1
}

replace variable = "Test: atema_st = atema_pe_st" in 5
replace pval_f = `p1' in 5

replace variable = "Test: atema_st = atema_lt" in 6
replace pval_f = `p2' in 6

replace variable = "Test: atema_pe_st = atema_pe_lt" in 7
replace pval_f = `p3' in 7

save "$output\data\03. RFE ddml (male).dta", replace








