// File: clean_ka_22_23
// Desc: keeping only relevant observations in the Khan data 
// Last updated: October 25, 2024 by Sara Mostafa
//-----------------------------------------------------------------------------//
clear all 

//cap log close
//log using "D:\SECURE\data 2024\analysis\atema\output\Logs\clean_ka_22_23", text replace

global input "D:\SECURE\data 2024\analysis\atema\01. build\input"
global output "D:\SECURE\data 2024\analysis\atema\01. build\output"

use "$input\khan_data_clean", clear 

order SMAX_STUDENT_ID

// one record per student with aggregated minutes and skills over the year 
// construction of variables used for first stage analysis

replace math_learning_minutes=0 if math_learning_minutes==.
replace total_minutes=0 if total_minutes==. 
replace math_learning_minutes_on_exercis=0 if math_learning_minutes_on_exercis==. 
replace math_learning_minutes_on_video=0 if math_learning_minutes_on_video==. 
replace math_learning_minutes_on_article=0 if math_learning_minutes_on_article==. 
replace math_skills_practiced=0 if math_skills_practiced==.
replace math_skills_leveled_up_net=0 if math_skills_leveled_up_net==.
replace math_skills_leveled_up_to_famili=0 if math_skills_leveled_up_to_famili==. 
replace math_skills_leveled_up_to_profic=0 if math_skills_leveled_up_to_profic==. 
replace math_skills_leveled_up_to_master=0 if math_skills_leveled_up_to_master==. 
replace math_skill_points_earned=0 if math_skill_points_earned==. 

duplicates drop SMAX_STUDENT_ID district district_abbrv student_kaid student_email ///
teacher_uuid teacher_kaid teacher_email teacher_roster_status licensed_math_class ///
teacher_joined_ts student_joined_ts interval_start_date interval_end_date week_of ///
total_minutes learning_minutes math_minutes math_learning_minutes math_learning_minutes_on_exercis ///
math_learning_minutes_on_video math_learning_minutes_on_article math_skills_practiced ///
math_skills_leveled_up_net math_skills_leveled_up_to_famili math_skills_leveled_up_to_profic ///
math_skills_leveled_up_to_master math_skill_points_earned, force

duplicates tag SMAX_STUDENT_ID week_of math_learning_minutes total_minutes math_learning_minutes_on_exercis ///
math_learning_minutes_on_video math_learning_minutes_on_article math_skills_practiced math_skills_leveled_up_net ///
math_skills_leveled_up_to_famili math_skills_leveled_up_to_profic math_skills_leveled_up_to_master ///
math_skill_points_earned, gen(dup)

duplicates drop SMAX_STUDENT_ID week_of math_learning_minutes total_minutes math_learning_minutes_on_exercis ///
math_learning_minutes_on_video math_learning_minutes_on_article math_skills_practiced math_skills_leveled_up_net ///
math_skills_leveled_up_to_famili math_skills_leveled_up_to_profic math_skills_leveled_up_to_master ///
math_skill_points_earned, force

duplicates tag SMAX_STUDENT_ID week_of, gen(dup_week)
tab dup_week


gen total_min = round(total_minutes, 0.0001)
bysort SMAX_STUDENT_ID week_of: egen max_min = max(total_min) if dup_week>0
bysort SMAX_STUDENT_ID week_of: gen flag_drop = 1 if (max_min != total_min) & dup_week>0

drop if flag_drop == 1
drop dup_week

duplicates tag SMAX_STUDENT_ID week_of, gen(dup_week)
tab dup_week

drop total_min max_min flag_drop dup_week


// total yearly data per student
bysort SMAX_STUDENT_ID: egen total_math_learning_minutes=sum(math_learning_minutes) 
bysort SMAX_STUDENT_ID: egen total_minutes_year=sum(total_minutes) 
bysort SMAX_STUDENT_ID: egen total_min_exercise=sum(math_learning_minutes_on_exercis) 
bysort SMAX_STUDENT_ID: egen total_min_video=sum(math_learning_minutes_on_video)
bysort SMAX_STUDENT_ID: egen total_min_article=sum(math_learning_minutes_on_article) 
bysort SMAX_STUDENT_ID: egen total_skills_practiced=sum(math_skills_practiced)
bysort SMAX_STUDENT_ID: egen total_skills_leveled_up=sum(math_skills_leveled_up_net) 
bysort SMAX_STUDENT_ID: egen total_upskill_familiar=sum(math_skills_leveled_up_to_famili) 
bysort SMAX_STUDENT_ID: egen total_upskill_proficient=sum(math_skills_leveled_up_to_profic) 
bysort SMAX_STUDENT_ID: egen total_upskill_master=sum(math_skills_leveled_up_to_master)
bysort SMAX_STUDENT_ID: egen total_skill_points=sum(math_skill_points_earned) 

gen student_login=0
replace student_login=1 if total_minutes_year>0


// average weekly data per student
bysort SMAX_STUDENT_ID: egen avg_weekly_learn_min=mean(math_learning_minutes) 
bysort SMAX_STUDENT_ID: egen avg_weekly_min=mean(total_minutes) 
bysort SMAX_STUDENT_ID: egen avg_weekly_exercise=mean(math_learning_minutes_on_exercis) 
bysort SMAX_STUDENT_ID: egen avg_weekly_video=mean(math_learning_minutes_on_video)
bysort SMAX_STUDENT_ID: egen avg_weekly_article=mean(math_learning_minutes_on_article) 
bysort SMAX_STUDENT_ID: egen avg_weekly_practiced=mean(math_skills_practiced)
bysort SMAX_STUDENT_ID: egen avg_weekly_levelup=mean(math_skills_leveled_up_net) 
bysort SMAX_STUDENT_ID: egen avg_weekly_familiar=mean(math_skills_leveled_up_to_famili) 
bysort SMAX_STUDENT_ID: egen avg_weekly_proficient=mean(math_skills_leveled_up_to_profic) 
bysort SMAX_STUDENT_ID: egen avg_weekly_master=mean(math_skills_leveled_up_to_master)
bysort SMAX_STUDENT_ID: egen avg_weekly_points=mean(math_skill_points_earned) 


// labeling variables (individual yearly) 
label variable total_math_learning_minutes "Total math minutes practiced per year"
label var total_minutes_year "total minutes logged in per year" 
label var total_min_exercise "total minutes on math exercises per year" 
label var total_min_video "total minutes on math videos per year" 
label var total_min_article "total minutes on math articles per year"
label var total_skills_practiced "total skills practiced per year" 
label var total_skills_leveled_up "Total net skills leveled up per year"
label var total_upskill_familiar "total skills leveled up to familiar per year" 
label var total_upskill_proficient "total skills leveled up to proficient per year" 
label var total_upskill_master "total skills leveled up to master per year" 
label var total_skill_points "total skill points earned per year"


/* creating a dataset with one record per student including the usage variables (averages across the year)
collapse (first) week_of total_minutes learning_minutes math_minutes math_learning_minutes ///
 math_learning_minutes_on_exercis math_learning_minutes_on_video math_learning_minutes_on_article ///
 math_skills_practiced math_skills_leveled_up_net math_skills_leveled_up_to_famili ///
 math_skills_leveled_up_to_profic math_skills_leveled_up_to_master math_skill_points_earned ///
 STAFF_EMPLOYEE_ID student_login total_math_learning_minutes total_minutes_year ///
 total_min_exercise total_min_video total_min_article total_skills_practiced total_skills_leveled_up ///
 total_upskill_familiar total_upskill_proficient total_upskill_master total_skill_points ///
 avg_weekly_learn_min avg_weekly_min avg_weekly_exercise ///
 avg_weekly_video avg_weekly_article avg_weekly_practiced avg_weekly_levelup avg_weekly_familiar ///
 avg_weekly_proficient avg_weekly_master avg_weekly_points, by(SMAX_STUDENT_ID)
 
 * this creates a dataset with one unique observation for each student (8,246) */

rename (student_login total_math_learning_minutes total_skills_leveled_up total_upskill_familiar) ///
(login_22 min_22 skill_22 familiar_22)

save "$output\khan_2022", replace 




use "D:\SECURE\data 2024\prepare\input\RAW\FILE_KHAN_ACADEMY_PR_DATA", clear 

order SMAX_STUDENT_ID week_of

rename week week_
rename week_of week
rename week_ week_of
drop if week == "22605" | week == "22633" | week == "22640" | week == "22647" | week == "22745" | ///
week == "23004" | week == "22969" | week == "22997" | week == "23011"

drop if SMAX_STUDENT_ID == ""

save "$output\khan_data_clean_23", replace 

// one record per student with aggregated minutes and skills over the year 
// construction of variables used for first stage analysis

replace math_learning_minutes=0 if math_learning_minutes==.
replace total_minutes=0 if total_minutes==. 
replace math_learning_minutes_on_exercis=0 if math_learning_minutes_on_exercis==. 
replace math_learning_minutes_on_video=0 if math_learning_minutes_on_video==. 
replace math_learning_minutes_on_article=0 if math_learning_minutes_on_article==. 
replace math_skills_practiced=0 if math_skills_practiced==.
replace math_skills_leveled_up_net=0 if math_skills_leveled_up_net==.
replace math_skills_leveled_up_to_famili=0 if math_skills_leveled_up_to_famili==. 
replace math_skills_leveled_up_to_profic=0 if math_skills_leveled_up_to_profic==. 
replace math_skills_leveled_up_to_master=0 if math_skills_leveled_up_to_master==. 
replace math_skill_points_earned=0 if math_skill_points_earned==. 

duplicates drop SMAX_STUDENT_ID district district_abbrv student_kaid student_email ///
teacher_uuid teacher_kaid teacher_email teacher_roster_status licensed_math_class ///
teacher_joined_ts student_joined_ts interval_start_date interval_end_date week_of ///
total_minutes learning_minutes math_minutes math_learning_minutes math_learning_minutes_on_exercis ///
math_learning_minutes_on_video math_learning_minutes_on_article math_skills_practiced ///
math_skills_leveled_up_net math_skills_leveled_up_to_famili math_skills_leveled_up_to_profic ///
math_skills_leveled_up_to_master math_skill_points_earned STAFF_EMPLOYEE_ID, force

duplicates tag SMAX_STUDENT_ID week_of math_learning_minutes total_minutes math_learning_minutes_on_exercis ///
math_learning_minutes_on_video math_learning_minutes_on_article math_skills_practiced math_skills_leveled_up_net ///
math_skills_leveled_up_to_famili math_skills_leveled_up_to_profic math_skills_leveled_up_to_master ///
math_skill_points_earned, gen(dup)

duplicates drop SMAX_STUDENT_ID week_of math_learning_minutes total_minutes math_learning_minutes_on_exercis ///
math_learning_minutes_on_video math_learning_minutes_on_article math_skills_practiced math_skills_leveled_up_net ///
math_skills_leveled_up_to_famili math_skills_leveled_up_to_profic math_skills_leveled_up_to_master ///
math_skill_points_earned, force

duplicates tag SMAX_STUDENT_ID week_of, gen(dup_week)
tab dup_week

gen total_min = round(total_minutes, 0.0001)
bysort SMAX_STUDENT_ID week_of: egen max_min = max(total_min) if dup_week>0
bysort SMAX_STUDENT_ID week_of: gen flag_drop = 1 if (max_min != total_min) & dup_week>0

drop if flag_drop == 1
drop dup_week

duplicates tag SMAX_STUDENT_ID week_of, gen(dup_week)
tab dup_week 

drop total_min max_min flag_drop dup_week


// total yearly data per student
bysort SMAX_STUDENT_ID: egen total_math_learning_minutes=sum(math_learning_minutes) 
bysort SMAX_STUDENT_ID: egen total_minutes_year=sum(total_minutes) 
bysort SMAX_STUDENT_ID: egen total_min_exercise=sum(math_learning_minutes_on_exercis) 
bysort SMAX_STUDENT_ID: egen total_min_video=sum(math_learning_minutes_on_video)
bysort SMAX_STUDENT_ID: egen total_min_article=sum(math_learning_minutes_on_article) 
bysort SMAX_STUDENT_ID: egen total_skills_practiced=sum(math_skills_practiced)
bysort SMAX_STUDENT_ID: egen total_skills_leveled_up=sum(math_skills_leveled_up_net) 
bysort SMAX_STUDENT_ID: egen total_upskill_familiar=sum(math_skills_leveled_up_to_famili) 
bysort SMAX_STUDENT_ID: egen total_upskill_proficient=sum(math_skills_leveled_up_to_profic) 
bysort SMAX_STUDENT_ID: egen total_upskill_master=sum(math_skills_leveled_up_to_master)
bysort SMAX_STUDENT_ID: egen total_skill_points=sum(math_skill_points_earned) 

gen student_login=0
replace student_login=1 if total_minutes_year>0


// average weekly data per student
bysort SMAX_STUDENT_ID: egen avg_weekly_learn_min=mean(math_learning_minutes) 
bysort SMAX_STUDENT_ID: egen avg_weekly_min=mean(total_minutes) 
bysort SMAX_STUDENT_ID: egen avg_weekly_exercise=mean(math_learning_minutes_on_exercis) 
bysort SMAX_STUDENT_ID: egen avg_weekly_video=mean(math_learning_minutes_on_video)
bysort SMAX_STUDENT_ID: egen avg_weekly_article=mean(math_learning_minutes_on_article) 
bysort SMAX_STUDENT_ID: egen avg_weekly_practiced=mean(math_skills_practiced)
bysort SMAX_STUDENT_ID: egen avg_weekly_levelup=mean(math_skills_leveled_up_net) 
bysort SMAX_STUDENT_ID: egen avg_weekly_familiar=mean(math_skills_leveled_up_to_famili) 
bysort SMAX_STUDENT_ID: egen avg_weekly_proficient=mean(math_skills_leveled_up_to_profic) 
bysort SMAX_STUDENT_ID: egen avg_weekly_master=mean(math_skills_leveled_up_to_master)
bysort SMAX_STUDENT_ID: egen avg_weekly_points=mean(math_skill_points_earned) 


// labeling variables (individual yearly) 
label variable total_math_learning_minutes "Total math minutes practiced per year"
label var total_minutes_year "total minutes logged in per year" 
label var total_min_exercise "total minutes on math exercises per year" 
label var total_min_video "total minutes on math videos per year" 
label var total_min_article "total minutes on math articles per year"
label var total_skills_practiced "total skills practiced per year" 
label var total_skills_leveled_up "Total net skills leveled up per year"
label var total_upskill_familiar "total skills leveled up to familiar per year" 
label var total_upskill_proficient "total skills leveled up to proficient per year" 
label var total_upskill_master "total skills leveled up to master per year" 
label var total_skill_points "total skill points earned per year"

gen year = year(week_of) 
gen month = month(week_of)

gen ACADEMIC_YEAR_ID_FK = 2022 if (year == 2021) | (year == 2022 & inrange(month,1,4))
	replace ACADEMIC_YEAR_ID_FK = 2023 if (year == 2023) | (year == 2022 & inrange(month,9,12))


global khan "student_login total_math_learning_minutes total_minutes_year total_min_exercise total_min_video total_min_article total_skills_practiced total_skills_leveled_up total_upskill_familiar total_upskill_proficient total_upskill_master total_skill_points"

foreach i of global khan {
	replace `i' = . if ACADEMIC_YEAR_ID_FK == 2022
	}
	
drop year month ACADEMIC_YEAR_ID_FK

save "$output\khan_2023", replace 


 merge 1:1 SMAX_STUDENT_ID week_of using "$output\khan_2022", gen(m_week)

 /* 
 
    Result                           # of obs.
    -----------------------------------------
    not matched                       521,115
        from master                   521,115  (m_week==1)
        from using                          0  (m_week==2)

    matched                           239,134  (m_week==3)
	-----------------------------------------

	
*/ 


save "$output\khan_per_student_temp", replace

drop m_week

gen year = year(week_of) 
gen month = month(week_of)

gen ACADEMIC_YEAR_ID_FK = 2022 if (year == 2021) | (year == 2022 & inrange(month,1,4))
	replace ACADEMIC_YEAR_ID_FK = 2023 if (year == 2023) | (year == 2022 & inrange(month,9,12))
	
replace total_math_learning_minutes = min_22 if ACADEMIC_YEAR_ID_FK == 2022
replace total_skills_leveled_up = skill_22 if ACADEMIC_YEAR_ID_FK == 2022
replace student_login = login_22 if ACADEMIC_YEAR_ID_FK == 2022
replace total_upskill_familiar = familiar_22 if ACADEMIC_YEAR_ID_FK == 2022

drop min_22 skill_22 login_22 familiar_22
	
collapse (first) week_of total_minutes learning_minutes math_minutes math_learning_minutes ///
 math_learning_minutes_on_exercis math_learning_minutes_on_video math_learning_minutes_on_article ///
 math_skills_practiced math_skills_leveled_up_net math_skills_leveled_up_to_famili ///
 math_skills_leveled_up_to_profic math_skills_leveled_up_to_master math_skill_points_earned ///
 STAFF_EMPLOYEE_ID student_login total_math_learning_minutes total_minutes_year ///
 total_min_exercise total_min_video total_min_article total_skills_practiced total_skills_leveled_up ///
 total_upskill_familiar total_upskill_proficient total_upskill_master total_skill_points ///
 avg_weekly_learn_min avg_weekly_min avg_weekly_exercise ///
 avg_weekly_video avg_weekly_article avg_weekly_practiced avg_weekly_levelup avg_weekly_familiar ///
 avg_weekly_proficient avg_weekly_master avg_weekly_points, by(SMAX_STUDENT_ID ACADEMIC_YEAR_ID_FK)
 
 tab ACADEMIC_YEAR_ID_FK
	// 2022: 8,246 
	// 2023: 14,889

save "$output\khan_per_student_combined", replace 


//merge student data with khan data
use "D:\SECURE\data 2024\prepare\build\output\student_end_enrollment.dta", clear 

//merge with khan data (per student data) 
merge 1:1 SMAX_STUDENT_ID ACADEMIC_YEAR_ID_FK using ///
"$output\khan_per_student_combined", gen(_m_ka) 

//merge 1:1 SMAX_STUDENT_ID ACADEMIC_YEAR_ID_FK using ///
//"D:\SECURE\data 2024\analysis\atema\data\interim\khan_per_student_combined_temp", gen(_m_ka)

/*

    Result                           # of obs.
    -----------------------------------------
    not matched                     5,334,615
        from master                 5,333,555  (_m_ka==1)
        from using                      1,060  (_m_ka==2)

    matched                            22,075  (_m_ka==3)
    -----------------------------------------

	
*/


keep if inrange(ACADEMIC_YEAR_ID_FK,2022,2023) & inrange(GRADE_ID_FK,6,10)
	
drop if _m_ka == 2


//variable measuring takeup  
label var student_login "Students that have khan activity in licensed classes" 


//preparing variables for analysis -- students in control schools have missing values
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

//drop if treat_arm_1==. & treat_arm_2==. & treat_arm_3==. & treat_arm_4==. & control==.

/*foreach i in 1 2 3 4{	
	replace treat_arm_`i'=0 if treat_arm_`i'==.
	}
	replace control=0 if control==.
	
reghdfe matched treat_arm_1 treat_arm_2 treat_arm_3 treat_arm_4, absorb(strata GRADE_ID_FK) vce(clustervar SCHOOL_CODE)
estimates store m1

esttab m1 using "D:\SECURE\data 2024\analysis\atema\output\tables\matching_rates.tex", ///
style(tab) mlabels("Matched" "Matched") label collabels(none) ///
cells(b(star fmt(%9.3f)) se(par)) stats(N, fmt(%9.0fc) ///
labels("Observations")) replace 
*/

save "$output\master_khan_student_combined_temp", replace 


// merging into september 2021 student list 
use "D:\SECURE\data 2024\prepare\build\output\atema_treatment", clear

ren ACADEMIC_YEAR_ID_FK base_year
ren SCHOOL_CODE school_21
ren GRADE_ID_FK grade_21

//renaming here to keep from end of year records and identify reasons for attrition
ren english_name english_name_21

// keeping the scores from end of year 
drop SPANISH_SCALE_SCORE SPANISH_score_norm MATH_SCALE_SCORE MATH_score_norm ENGLISH_SCALE_SCORE ENGLISH_score_norm 

foreach i in 1 2 3 4 {
	replace treat_arm_`i'=0 if treat_arm_`i'==. 
	replace teach_treat`i'=0 if teach_treat`i'==.
	}
	replace control=0 if control==.
	replace teach_control=0 if teach_control==.

expand 2 

bys SMAX_STUDENT_ID: gen num = _n

gen ACADEMIC_YEAR_ID_FK = 2022 if num == 1
	replace ACADEMIC_YEAR_ID_FK = 2023 if num == 2

merge 1:1 SMAX_STUDENT_ID ACADEMIC_YEAR_ID_FK using ///
"$output\master_khan_student_combined_temp.dta", ///
gen(match_21) keepusing(SPANISH_SCALE_SCORE SPANISH_score_norm ENGLISH_SCALE_SCORE ENGLISH_score_norm MATH_SCALE_SCORE MATH_score_norm student_login GRADE_ID_FK SCHOOL_CODE english_name total_math_learning_minutes total_skills_leveled_up total_upskill_familiar)


/* 

    Result                           # of obs.
    -----------------------------------------
    not matched                        57,805
        from master                    49,191  (match_21==1)
        from using                      8,614  (match_21==2)

    matched                           188,279  (match_21==3)
    -----------------------------------------


*/


drop if match_21 == 2

count if b_math_19!=. & match_21==3
count if b_math_21!=. & match_21 == 3
count if b_GPA!=. & match_21==3


// checking those that only match for one year
replace SCHOOL_CODE = real(substr(string(SCHOOL_CODE), 3, .)) if !missing(MATH_SCALE_SCORE) & SCHOOL_CODE >= 100000

order SMAX_STUDENT_ID ACADEMIC_YEAR_ID_FK school_21 SCHOOL_CODE
sort SMAX_STUDENT_ID ACADEMIC_YEAR_ID_FK

replace GRADE_ID_FK = (grade_21) if match_21==1 & ACADEMIC_YEAR_ID_FK==2022
replace GRADE_ID_FK = (grade_21 + 1) if match_21==1 & ACADEMIC_YEAR_ID_FK==2023

drop if GRADE_ID_FK == 11 | GRADE_ID_FK == 5

local ka "student_login total_math_learning_minutes total_skills_leveled_up total_upskill_familiar"
foreach i of local ka{
	replace `i' = 0 if `i' ==.
	}

// Normalizing math scores 

	// AY 2022 
gen math_score_22 = .
gen sd_math = . 
gen mean_math = .
gen eng_score_22 = . 
gen sd_eng = .
gen mean_eng = .
gen spa_score_22 = . 
gen sd_spa = .
gen mean_spa = .

local grades "6 7 8 9 10"

foreach grade of local grades {
	//math
	winsor MATH_SCALE_SCORE if ACADEMIC_YEAR_ID_FK == 2022 & ///
	flag_no_tests_expected == 0 & GRADE_ID_FK == `grade', ///
	gen(math_test) p(0.01)
	
	sum math_test if ACADEMIC_YEAR_ID_FK == 2022 & ///
	flag_no_tests_expected == 0 & GRADE_ID_FK == `grade' & ///
	(control == 1 | treat_arm_3 == 1 | treat_arm_4 == 1), detail 
	
	replace mean_math = r(mean) if ACADEMIC_YEAR_ID_FK == 2022 & ///
	flag_no_tests_expected == 0 & GRADE_ID_FK == `grade'
	replace sd_math = r(sd) if ACADEMIC_YEAR_ID_FK == 2022 & ///
	flag_no_tests_expected == 0 & GRADE_ID_FK == `grade'
	
	replace math_score_22 = (math_test - mean_math)/sd_math if ///
	flag_no_tests_expected == 0 & GRADE_ID_FK == `grade' & ///
	ACADEMIC_YEAR_ID_FK == 2022
	
	drop math_test
	
	//english
	winsor ENGLISH_SCALE_SCORE if ACADEMIC_YEAR_ID_FK == 2022 & ///
	flag_no_tests_expected == 0 & GRADE_ID_FK == `grade', ///
	gen(eng_test) p(0.01)
	
	sum eng_test if ACADEMIC_YEAR_ID_FK == 2022 & ///
	flag_no_tests_expected == 0 & GRADE_ID_FK == `grade' & ///
	(control == 1 | treat_arm_3 == 1 | treat_arm_4 == 1), detail 
	
	replace mean_eng = r(mean) if ACADEMIC_YEAR_ID_FK == 2022 & ///
	flag_no_tests_expected == 0 & GRADE_ID_FK == `grade'
	replace sd_eng = r(sd) if ACADEMIC_YEAR_ID_FK == 2022 & ///
	flag_no_tests_expected == 0 & GRADE_ID_FK == `grade'
	
	replace eng_score_22 = (eng_test - mean_eng)/sd_eng if ///
	flag_no_tests_expected == 0 & GRADE_ID_FK == `grade' & ///
	ACADEMIC_YEAR_ID_FK == 2022
	
	drop eng_test
	
	//spanish
	winsor SPANISH_SCALE_SCORE if ACADEMIC_YEAR_ID_FK == 2022 & ///
	flag_no_tests_expected == 0 & GRADE_ID_FK == `grade', ///
	gen(spa_test) p(0.01)
	
	sum spa_test if ACADEMIC_YEAR_ID_FK == 2022 & ///
	flag_no_tests_expected == 0 & GRADE_ID_FK == `grade' & ///
	(control == 1 | treat_arm_3 == 1 | treat_arm_4 == 1), detail 
	
	replace mean_spa = r(mean) if ACADEMIC_YEAR_ID_FK == 2022 & ///
	flag_no_tests_expected == 0 & GRADE_ID_FK == `grade'
	replace sd_spa = r(sd) if ACADEMIC_YEAR_ID_FK == 2022 & ///
	flag_no_tests_expected == 0 & GRADE_ID_FK == `grade'
	
	replace spa_score_22 = (spa_test - mean_spa)/sd_spa if ///
	flag_no_tests_expected == 0 & GRADE_ID_FK == `grade' & ///
	ACADEMIC_YEAR_ID_FK == 2022
	
	drop spa_test
	}

sum math_score_22, detail
sum eng_score_22, detail
sum spa_score_22, detail


// AY 2023
gen math_score_23 = .
gen eng_score_23 = .
gen spa_score_23 = . 

foreach grade of local grades {
	//math
	winsor MATH_SCALE_SCORE if ACADEMIC_YEAR_ID_FK == 2023 & ///
	flag_no_tests_expected == 0 & GRADE_ID_FK == `grade', ///
	gen(math_test) p(0.01)
	
	sum math_test if ACADEMIC_YEAR_ID_FK == 2023 & ///
	flag_no_tests_expected == 0 & GRADE_ID_FK == `grade' & ///
	control == 1, detail 
	
	replace mean_math = r(mean) if ACADEMIC_YEAR_ID_FK == 2023 & ///
	flag_no_tests_expected == 0 & GRADE_ID_FK == `grade'
	replace sd_math = r(sd) if ACADEMIC_YEAR_ID_FK == 2023 & ///
	flag_no_tests_expected == 0 & GRADE_ID_FK == `grade'
	
	replace math_score_23 = (math_test - mean_math)/sd_math if ///
	flag_no_tests_expected == 0 & GRADE_ID_FK == `grade' & ///
	ACADEMIC_YEAR_ID_FK == 2023
	
	drop math_test
	
	//english
	winsor ENGLISH_SCALE_SCORE if ACADEMIC_YEAR_ID_FK == 2023 & ///
	flag_no_tests_expected == 0 & GRADE_ID_FK == `grade', ///
	gen(eng_test) p(0.01)
	
	sum eng_test if ACADEMIC_YEAR_ID_FK == 2023 & ///
	flag_no_tests_expected == 0 & GRADE_ID_FK == `grade' & ///
	control == 1, detail 
	
	replace mean_eng = r(mean) if ACADEMIC_YEAR_ID_FK == 2023 & ///
	flag_no_tests_expected == 0 & GRADE_ID_FK == `grade'
	replace sd_eng = r(sd) if ACADEMIC_YEAR_ID_FK == 2023 & ///
	flag_no_tests_expected == 0 & GRADE_ID_FK == `grade'
	
	replace eng_score_23 = (eng_test - mean_eng)/sd_eng if ///
	flag_no_tests_expected == 0 & GRADE_ID_FK == `grade' & ///
	ACADEMIC_YEAR_ID_FK == 2023
	
	drop eng_test
	
	//spanish
	winsor SPANISH_SCALE_SCORE if ACADEMIC_YEAR_ID_FK == 2023 & ///
	flag_no_tests_expected == 0 & GRADE_ID_FK == `grade', ///
	gen(spa_test) p(0.01)
	
	sum spa_test if ACADEMIC_YEAR_ID_FK == 2023 & ///
	flag_no_tests_expected == 0 & GRADE_ID_FK == `grade' & ///
	control == 1, detail 
	
	replace mean_spa = r(mean) if ACADEMIC_YEAR_ID_FK == 2023 & ///
	flag_no_tests_expected == 0 & GRADE_ID_FK == `grade'
	replace sd_spa = r(sd) if ACADEMIC_YEAR_ID_FK == 2023 & ///
	flag_no_tests_expected == 0 & GRADE_ID_FK == `grade'
	
	replace spa_score_23 = (spa_test - mean_spa)/sd_spa if ///
	flag_no_tests_expected == 0 & GRADE_ID_FK == `grade' & ///
	ACADEMIC_YEAR_ID_FK == 2023
	
	drop spa_test
}


drop mean_* sd_*

sum math_score_23, detail
sum eng_score_23, detail 
sum spa_score_23, detail

replace math_score_22 = math_score_23 if ACADEMIC_YEAR_ID_FK == 2023
rename math_score_22 math_score 
drop math_score_23

replace eng_score_22 = eng_score_23 if ACADEMIC_YEAR_ID_FK == 2023
rename eng_score_22 eng_score 
drop eng_score_23

replace spa_score_22 = spa_score_23 if ACADEMIC_YEAR_ID_FK == 2023
rename spa_score_22 spa_score 
drop spa_score_23

tab ACADEMIC_YEAR_ID_FK

gen takeup = 0 
	replace takeup = 1 if total_math_learning_minutes >= 145 & ACADEMIC_YEAR_ID_FK==2022
	replace takeup = 1 if total_math_learning_minutes >= 155 & ACADEMIC_YEAR_ID_FK==2023
	
save "$output\master_khan_student_combined.dta", replace


gen atema_st = 0 
	replace atema_st=1 if (treat_arm_1==1 & ACADEMIC_YEAR_ID_FK==2022) | (treat_arm_3==1 & ///
	ACADEMIC_YEAR_ID_FK==2023) | (treat_arm_4==1 & ACADEMIC_YEAR_ID_FK==2023) 
gen atema_pe_st = 0 
	replace atema_pe_st = 1 if treat_arm_2==1 & ACADEMIC_YEAR_ID_FK==2022 
gen atema_lt = 0 
	replace atema_lt = 1 if treat_arm_1==1 & ACADEMIC_YEAR_ID_FK==2023
gen atema_pe_lt = 0 
	replace atema_pe_lt = 1 if treat_arm_2==1 & ACADEMIC_YEAR_ID_FK==2023
	
gen t_atema_st = 0 
	replace t_atema_st=1 if (teach_treat1==1 & ACADEMIC_YEAR_ID_FK==2022) | (teach_treat3==1 & ///
	ACADEMIC_YEAR_ID_FK==2023) | (teach_treat4==1 & ACADEMIC_YEAR_ID_FK==2023) 
gen t_atema_pe_st = 0 
	replace t_atema_pe_st = 1 if teach_treat2==1 & ACADEMIC_YEAR_ID_FK==2022 
gen t_atema_lt = 0 
	replace t_atema_lt = 1 if teach_treat1==1 & ACADEMIC_YEAR_ID_FK==2023
gen t_atema_pe_lt = 0 
	replace t_atema_pe_lt = 1 if teach_treat2==1 & ACADEMIC_YEAR_ID_FK==2023


save "$output\master_khan_student_combined.dta", replace
















