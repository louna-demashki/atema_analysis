//----------------------------------------------------------------------------//
// File: 01. clean_ka_17_23
// Desc.: merging PRDE data with Khan data and keeping years 2017 to 2023 in a 
//			panel dataset
// Last updated: Jan 24, 2025 by Sara Mostafa
//----------------------------------------------------------------------------//

clear all
set matsize 6000
set more off 
global dir "D:\SECURE\data 2024\analysis\atema" 
global input "$dir\01. build\input" 
global output "$dir\01. build\output"

//cap log close
//log using "$output\Logs\clean_ka_17_23", text replace

// merging PRDE data with khan data for treatment assignment
use "D:\SECURE\data 2024\prepare\build\output\student_end_enrollment.dta", clear 
merge 1:1 SMAX_STUDENT_ID ACADEMIC_YEAR_ID_FK using "$output\khan_per_student_combined", gen(_m_ka)

/* 
    Result                           # of obs.
    -----------------------------------------
    not matched                     5,334,615
        from master                 5,333,555  (_m_ka==1)
        from using                      1,060  (_m_ka==2)

    matched                            22,075  (_m_ka==3)
    -----------------------------------------
*/ 

drop if _m_ka == 2  // dropping unmatched observations from KA
tab ACADEMIC_YEAR_ID_FK  // data from 2010 to 2023 

// keeping only relevant grades in relevant years 
drop if ACADEMIC_YEAR_ID_FK < 2017

replace total_math_learning_minutes=0 if total_math_learning_minutes==.
replace total_minutes_year=0 if total_minutes_year==. 
replace total_min_exercise=0 if total_min_exercise==. 
replace total_min_video=0 if total_min_video==. 
replace total_min_article=0 if total_min_article==. 
replace total_skills_practiced=0 if total_skills_practiced==. 
replace total_skills_leveled_up=0 if total_skills_leveled_up==. 
replace total_upskill_familiar=0 if total_upskill_familiar==. 
replace total_upskill_proficient=0 if total_upskill_proficient==. 
replace total_upskill_master=0 if total_upskill_master==. 
replace total_skill_points=0 if total_skill_points==. 
replace student_login=0 if  student_login==. 
replace avg_weekly_learn_min=0 if avg_weekly_learn_min==.
replace avg_weekly_min=0 if avg_weekly_min==. 
replace avg_weekly_exercise=0 if avg_weekly_exercise==.
replace avg_weekly_video=0 if avg_weekly_video==. 
replace avg_weekly_article=0 if avg_weekly_article==. 
replace avg_weekly_practiced=0 if avg_weekly_practiced==.
replace avg_weekly_levelup=0 if avg_weekly_levelup==.
replace avg_weekly_familiar=0 if avg_weekly_familiar==.
replace avg_weekly_proficient=0 if avg_weekly_proficient==. 
replace avg_weekly_master=0 if avg_weekly_master==. 
replace avg_weekly_points=0 if avg_weekly_points==.


tab ACADEMIC_YEAR_ID_FK 

	
keep if (ACADEMIC_YEAR_ID_FK == 2017 & inrange(GRADE_ID_FK,3,5)) | ///
(ACADEMIC_YEAR_ID_FK == 2018 & inrange(GRADE_ID_FK,3,6)) | ///
(ACADEMIC_YEAR_ID_FK == 2019 & inrange(GRADE_ID_FK,3,7)) | ///
(ACADEMIC_YEAR_ID_FK == 2022 & inrange(GRADE_ID_FK,5,10)) | ///
(ACADEMIC_YEAR_ID_FK == 2023 & inrange(GRADE_ID_FK,6,11)) 



save "$output\student_temp_17_23", replace


// merging with treatment assignment 
use "D:\SECURE\data 2024\analysis\atema\data\interim\atema_treatment", clear

ren ACADEMIC_YEAR_ID_FK base_year
ren SCHOOL_CODE school_21
ren GRADE_ID_FK grade_21

//renaming here to keep from end of year records and identify reasons for attrition
ren english_name english_name_21

foreach i in 1 2 3 4 {
	replace treat_arm_`i'=0 if treat_arm_`i'==. 
	replace teach_treat`i'=0 if teach_treat`i'==.
	}
	replace control=0 if control==.
	replace teach_control=0 if teach_control==.
	
merge 1:m SMAX_STUDENT_ID using "$output\student_temp_17_23.dta", ///
gen(match_21) keepusing(MATH_SCALE_SCORE MATH_score_norm ACADEMIC_YEAR_ID_FK GRADE_ID_FK SCHOOL_CODE english_name total_math_learning_minutes total_skills_leveled_up total_upskill_familiar)
keep if match_21 == 3
drop match_21


// defining the take-up measure 
gen takeup_1 = 0 
	replace takeup_1 = 1 if total_math_learning_minutes > 145 & ACADEMIC_YEAR_ID_FK==2022
	
gen takeup_2 = 0 
	replace takeup_2 = 1 if total_math_learning_minutes > 145 & ACADEMIC_YEAR_ID_FK==2023
	
bys SMAX_STUDENT_ID: egen takeup1=max(takeup_1)
bys SMAX_STUDENT_ID: egen takeup2=max(takeup_2)
	
drop takeup_1 takeup_2
	
/*gen takeup_1 = 0 
	replace takeup_1 = 1 if t1==1 & t2==0
	
gen takeup_2 = 0 
	replace takeup_2 = 1 if t1==0 & t2==1
	
gen takeup_3 = 0 
	replace takeup_3 = 1 if t1==1 & t2==1
	
drop t1 t2
*/

save "$output\master_2017_2023_temp", replace	

	
//----------------------------------------------------------------------------//
// Normalizing math score by grade
//----------------------------------------------------------------------------//

gen math_score = .
gen mean_math = . 
gen sd_math = .

// grade 3
local years "2022"
local grades "5"

foreach year of local years {
        
        winsor MATH_SCALE_SCORE if ACADEMIC_YEAR_ID_FK == `year' & flag_no_tests_expected == 0 & ///
        grade_21 == `grades', gen(math_test) p(0.01)
        
        sum math_test if ACADEMIC_YEAR_ID_FK == `year' & flag_no_tests_expected == 0 & ///
        grade_21 == `grades', detail
        
        replace mean_math = r(mean) if ACADEMIC_YEAR_ID_FK == `year' & flag_no_tests_expected == 0 & ///
        grade_21 == `grades'
        replace sd_math = r(sd) if ACADEMIC_YEAR_ID_FK == `year' & flag_no_tests_expected == 0 & ///
        grade_21 == `grades'
        
        replace math_score = (math_test - mean_math) / sd_math if ACADEMIC_YEAR_ID_FK == `year' & ///
		flag_no_tests_expected == 0 & grade_21 == `grades'
        
        drop math_test
}	

	
// grade 4
local years "2022 2023"
local grades "6"

foreach year of local years {
        
        winsor MATH_SCALE_SCORE if ACADEMIC_YEAR_ID_FK == `year' & flag_no_tests_expected == 0 & ///
        grade_21 == `grades', gen(math_test) p(0.01)
        
        sum math_test if ACADEMIC_YEAR_ID_FK == `year' & flag_no_tests_expected == 0 & ///
        grade_21 == `grades', detail
        
        replace mean_math = r(mean) if ACADEMIC_YEAR_ID_FK == `year' & flag_no_tests_expected == 0 & ///
        grade_21 == `grades'
        replace sd_math = r(sd) if ACADEMIC_YEAR_ID_FK == `year' & flag_no_tests_expected == 0 & ///
        grade_21 == `grades'
        
        replace math_score = (math_test - mean_math) / sd_math if ACADEMIC_YEAR_ID_FK == `year' & flag_no_tests_expected == 0 & ///
        grade_21 == `grades'
        
        drop math_test
}	


// grade 5 
local years "2022 2023"
local grades "7"

foreach year of local years {
        
        winsor MATH_SCALE_SCORE if ACADEMIC_YEAR_ID_FK == `year' & flag_no_tests_expected == 0 & ///
        grade_21 == `grades', gen(math_test) p(0.01)
        
        sum math_test if ACADEMIC_YEAR_ID_FK == `year' & flag_no_tests_expected == 0 & ///
        grade_21 == `grades', detail
        
        replace mean_math = r(mean) if ACADEMIC_YEAR_ID_FK == `year' & flag_no_tests_expected == 0 & ///
        grade_21 == `grades'
        replace sd_math = r(sd) if ACADEMIC_YEAR_ID_FK == `year' & flag_no_tests_expected == 0 & ///
        grade_21 == `grades'
        
        replace math_score = (math_test - mean_math) / sd_math if ACADEMIC_YEAR_ID_FK == `year' & flag_no_tests_expected == 0 & ///
        grade_21 == `grades'
        
        drop math_test
}	


// grade 6 
local years "2019 2022 2023"
local grades "8"

foreach year of local years {
        
        winsor MATH_SCALE_SCORE if ACADEMIC_YEAR_ID_FK == `year' & flag_no_tests_expected == 0 & ///
        grade_21 == `grades', gen(math_test) p(0.01)
        
        sum math_test if ACADEMIC_YEAR_ID_FK == `year' & flag_no_tests_expected == 0 & ///
        grade_21 == `grades', detail
        
        replace mean_math = r(mean) if ACADEMIC_YEAR_ID_FK == `year' & flag_no_tests_expected == 0 & ///
        grade_21 == `grades'
        replace sd_math = r(sd) if ACADEMIC_YEAR_ID_FK == `year' & flag_no_tests_expected == 0 & ///
        grade_21 == `grades'
        
        replace math_score = (math_test - mean_math) / sd_math if ACADEMIC_YEAR_ID_FK == `year' & flag_no_tests_expected == 0 & ///
        grade_21 == `grades'
        
        drop math_test
}	

// grade 7 
local years "2018 2019 2022 2023"
local grades "9"

foreach year of local years {
        
        winsor MATH_SCALE_SCORE if ACADEMIC_YEAR_ID_FK == `year' & flag_no_tests_expected == 0 & ///
        grade_21 == `grades', gen(math_test) p(0.01)
        
        sum math_test if ACADEMIC_YEAR_ID_FK == `year' & flag_no_tests_expected == 0 & ///
        grade_21 == `grades', detail
        
        replace mean_math = r(mean) if ACADEMIC_YEAR_ID_FK == `year' & flag_no_tests_expected == 0 & ///
        grade_21 == `grades'
        replace sd_math = r(sd) if ACADEMIC_YEAR_ID_FK == `year' & flag_no_tests_expected == 0 & ///
        grade_21 == `grades'
        
        replace math_score = (math_test - mean_math) / sd_math if ACADEMIC_YEAR_ID_FK == `year' & flag_no_tests_expected == 0 & ///
        grade_21 == `grades'
        
        drop math_test
}	


// grade 8
local years "2017 2018 2019 2022"
local grades "10"

foreach year of local years {
        
        winsor MATH_SCALE_SCORE if ACADEMIC_YEAR_ID_FK == `year' & flag_no_tests_expected == 0 & ///
        grade_21 == `grades', gen(math_test) p(0.01)
        
        sum math_test if ACADEMIC_YEAR_ID_FK == `year' & flag_no_tests_expected == 0 & ///
        grade_21 == `grades', detail
        
        replace mean_math = r(mean) if ACADEMIC_YEAR_ID_FK == `year' & flag_no_tests_expected == 0 & ///
        grade_21 == `grades'
        replace sd_math = r(sd) if ACADEMIC_YEAR_ID_FK == `year' & flag_no_tests_expected == 0 & ///
        grade_21 == `grades'
        
        replace math_score = (math_test - mean_math) / sd_math if ACADEMIC_YEAR_ID_FK == `year' & flag_no_tests_expected == 0 & ///
        grade_21 == `grades'
        
        drop math_test
}	


drop mean_math sd_math


// Dummy variables for years 
levelsof ACADEMIC_YEAR_ID_FK, local(years)

foreach ay of local years {
	gen ay_`ay' = (ACADEMIC_YEAR_ID_FK == `ay')
}

	
// grade-academic year variable for fixed effects for 2021 grades
egen ay_grade = group(ACADEMIC_YEAR_ID_FK grade_21)


// Interaction 
	// Cohort 1 & 2
	local year_var ay_2017 ay_2018 ay_2019 ay_2022 ay_2023
	
		foreach year of local year_var {
			gen `year'_takeup1 = `year' * takeup1
			gen `year'_takeup2 = `year' * takeup2
		}	
		
save "$output\master_2017_2023_temp", replace	
		
		
// replacing math_score with missing values for students who are held back or skip a grade
		
	// replacing test scores with missing for students repeating grades
	local year "17 18 19 22 23"

	foreach i of local year{
		gen grade`i' = GRADE_ID_FK if ACADEMIC_YEAR_ID_FK==20`i'
		bys SMAX_STUDENT_ID: egen grade_`i' = max(grade`i')
		drop grade`i'
		}
		
	gen math_score_adj = math_score
	
	replace math_score_adj = . if grade_23 != grade_21+1 & ACADEMIC_YEAR_ID_FK == 2023
	replace math_score_adj = . if grade_19 != grade_21-3 & ACADEMIC_YEAR_ID_FK == 2019
	replace math_score_adj = . if grade_18 != grade_21-4 & ACADEMIC_YEAR_ID_FK == 2018
	replace math_score_adj = . if grade_17 != grade_21-5 & ACADEMIC_YEAR_ID_FK == 2017
	replace math_score_adj = . if grade_22 != grade_19+3 & ACADEMIC_YEAR_ID_FK == 2022
	
	// grade 3 (2021)
	replace math_score_adj = . if grade_21 == 5 & (ACADEMIC_YEAR_ID_FK == 2019 | ///
	ACADEMIC_YEAR_ID_FK == 2018 | ACADEMIC_YEAR_ID_FK == 2017)

	// grade 4 (2021) 
	replace math_score_adj = . if grade_21 == 6 & (ACADEMIC_YEAR_ID_FK == 2019 | ///
	ACADEMIC_YEAR_ID_FK == 2018 | ACADEMIC_YEAR_ID_FK == 2017)

	// grade 5 (2021)
	replace math_score_adj = . if grade_21 == 7 & (ACADEMIC_YEAR_ID_FK == 2019 | ///
	ACADEMIC_YEAR_ID_FK == 2018 | ACADEMIC_YEAR_ID_FK == 2017)
	
	// grade 6 (2021)
	replace math_score_adj = . if grade_21 == 8 & (ACADEMIC_YEAR_ID_FK == 2018 | ///
	ACADEMIC_YEAR_ID_FK == 2017)
	
	// grade 7 (2021)
	replace math_score_adj = . if grade_21 == 9 & ACADEMIC_YEAR_ID_FK == 2017 
	
	
	
save "$output\master_2017_2023", replace	
	
	
	
	
	
	
	
	
	