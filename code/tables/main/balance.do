//----------------------------------------------------------------------------//
// File: balance_student_school.do 
// Uses: master_khan_student_combined.dta
// Output: balance_table.tex
// Last update: November 7, 2024 by Sara Mostafa
//----------------------------------------------------------------------------//

clear all
set matsize 6000
set more off 
global dir "D:\SECURE\data 2024\analysis\atema" 
global input "$dir\data" 
global output "$dir\output"

cap log close
log using "$output\Logs\tables\main\balance", text replace

use "$input\interim\atema_treatment", clear

merge 1:m SMAX_STUDENT_ID using "$input\master_khan_student_combined.dta", gen(baseline) ///
keepusing(b_math_19 b_math_21 b_eng_21 b_spa_21)

bys SMAX_STUDENT_ID: gen student=_n
keep if student==1
drop if (treat_arm_1==. & treat_arm_2==. & treat_arm_3==. & treat_arm_4==. & control==.)
drop math_21 eng_21 spa_21
ren (b_math_21 b_math_19 b_eng_21 b_spa_21) (math_21 math_19 eng_21 spa_21)

bysort SCHOOL_CODE: gen school=_n
bys SMAX_STAFF_IDMATH: gen teacher=_n

foreach i in 1 2 3 4{
	replace treat_arm_`i'=0 if treat_arm_`i'==.
	replace teach_treat`i'=0 if teach_treat`i'==.
	}
	replace control=0 if control==.
	replace teach_control=0 if teach_control==. 


//adding a dummy for school that took the WMS 
gen wms=0 
	replace wms=1 if management!=. & people!=. & targets!=. & monitoring!=. & operations!=.
	

local format "%9.3fc" 

local student "gender sa_age special_ed math_21 eng_21 spa_21 poverty math_19 GPA GPA_mate"
	
// balance test estimates -- student level t

foreach depvar of local student {

    // control -- mean and standard deviation
    summarize `depvar' if control == 1
    local `depvar'controlM: display `format' r(mean)
    local sd: display `format' r(sd)
    local `depvar'controlSD = "[" + strtrim("`sd'") + "]"


    // TA1 - control (difference and se)
    reghdfe `depvar' treat_arm_1 treat_arm_2 treat_arm_3 treat_arm_4, ///
	absorb(GRADE_ID_FK strata) vce(clustervar SCHOOL_CODE)  

    local diff1: display `format' _b[treat_arm_1]
	scalar t_stat1 = _b[treat_arm_1] / _se[treat_arm_1]
	scalar df1 = e(df_r)
	scalar pval_1 = 2 * ttail(df1, abs(t_stat1))
	if pval_1 < 0.01 local `depvar'diff1 = strtrim("`diff1'") + "\sym{***}"
	else if pval_1 < 0.05 local `depvar'diff1 = strtrim("`diff1'") + "\sym{**}"
	else if pval_1 < 0.1 local `depvar'diff1 = strtrim("`diff1'") + "\sym{*}"
    else local `depvar'diff1 = strtrim("`diff1'")
    local se1: display `format' _se[treat_arm_1]
    local `depvar'se1 = "(" + strtrim("`se1'") + ")"
	
	//TA2 - control (difference and se) 

    local diff2: display `format' _b[treat_arm_2]
	scalar t_stat2 = _b[treat_arm_2] / _se[treat_arm_2]
	scalar df2 = e(df_r)
	scalar pval_2 = 2 * ttail(df2, abs(t_stat2))
	if pval_2 < 0.01 local `depvar'diff2 = strtrim("`diff2'") + "\sym{***}"
	else if pval_2 < 0.05 local `depvar'diff2 = strtrim("`diff2'") + "\sym{**}"
	else if pval_2 < 0.1 local `depvar'diff2 = strtrim("`diff2'") + "\sym{*}"
    else local `depvar'diff2 = strtrim("`diff2'")
    local se2: display `format' _se[treat_arm_2]
    local `depvar'se2 = "(" + strtrim("`se2'") + ")"
	
	
	//TA3 - control (difference and se) 

    local diff3: display `format' _b[treat_arm_3]
	scalar t_stat3 = _b[treat_arm_3] / _se[treat_arm_3]
	scalar df3 = e(df_r)
	scalar pval_3 = 2 * ttail(df3, abs(t_stat3))
	if pval_3 < 0.01 local `depvar'diff3 = strtrim("`diff3'") + "\sym{***}"
	else if pval_3 < 0.05 local `depvar'diff3 = strtrim("`diff3'") + "\sym{**}"
	else if pval_3 < 0.1 local `depvar'diff3 = strtrim("`diff3'") + "\sym{*}"
    else local `depvar'diff3 = strtrim("`diff3'")
    local se3: display `format' _se[treat_arm_3]
    local `depvar'se3 = "(" + strtrim("`se3'") + ")"
	
	
	//TA4 - control (difference and se) 

    local diff4: display `format' _b[treat_arm_4]
	scalar t_stat4 = _b[treat_arm_4] / _se[treat_arm_4]
	scalar df4 = e(df_r)
	scalar pval_4 = 2 * ttail(df4, abs(t_stat4))
	if pval_4 < 0.01 local `depvar'diff4 = strtrim("`diff4'") + "\sym{***}"
	else if pval_4 < 0.05 local `depvar'diff4 = strtrim("`diff4'") + "\sym{**}"
	else if pval_4 < 0.1 local `depvar'diff4 = strtrim("`diff4'") + "\sym{*}"
    else local `depvar'diff4 = strtrim("`diff4'")
    local se4: display `format' _se[treat_arm_4]
    local `depvar'se4 = "(" + strtrim("`se4'") + ")"
	
	
	// observations 
	local `depvar'obs: display %9.0fc e(N)			

}



//----------------------------- SCHOOL-LEVEL DATA -----------------------------//

rename Español_38avg esp_38avg 
rename Matemáticas_38avg ma_38avg 
rename Inglés_38avg ing_38avg
rename GR11EspañolPromedio GR11espanol
rename GR11MatemáticasPromedio GR11math 
rename GR11InglésPromedio GR11ing

local school "total_enrollment town_rural pupil_teacher_ratio class_size esp_38avg ma_38avg ing_38avg wms"


// school-level data
foreach depvar of local school {

    // control -- mean and standard deviation
    summarize `depvar' if control == 1 & school==1
    local `depvar'controlM: display `format' r(mean)
    local sd: display `format' r(sd)
    local `depvar'controlSD = "[" + strtrim("`sd'") + "]"


    // TA1 - control (difference and se)
    reghdfe `depvar' treat_arm_1 treat_arm_2 treat_arm_3 treat_arm_4 if school==1, ///
	absorb(GRADE_ID_FK strata) vce(clustervar SCHOOL_CODE) 

    local diff1: display `format' _b[treat_arm_1]
	scalar t_stat1 = _b[treat_arm_1] / _se[treat_arm_1]
	scalar df1 = e(df_r)
	scalar pval_1 = 2 * ttail(df1, abs(t_stat1))
	if pval_1 < 0.01 local `depvar'diff1 = strtrim("`diff1'") + "\sym{***}"
	else if pval_1 < 0.05 local `depvar'diff1 = strtrim("`diff1'") + "\sym{**}"
	else if pval_1 < 0.1 local `depvar'diff1 = strtrim("`diff1'") + "\sym{*}"
    else local `depvar'diff1 = strtrim("`diff1'")
    local se1: display `format' _se[treat_arm_1]
    local `depvar'se1 = "(" + strtrim("`se1'") + ")"
	
	//TA2 - control (difference and se) 

    local diff2: display `format' _b[treat_arm_2]
	scalar t_stat2 = _b[treat_arm_2] / _se[treat_arm_2]
	scalar df2 = e(df_r)
	scalar pval_2 = 2 * ttail(df2, abs(t_stat2))
	if pval_2 < 0.01 local `depvar'diff2 = strtrim("`diff2'") + "\sym{***}"
	else if pval_2 < 0.05 local `depvar'diff2 = strtrim("`diff2'") + "\sym{**}"
	else if pval_2 < 0.1 local `depvar'diff2 = strtrim("`diff2'") + "\sym{*}"
    else local `depvar'diff2 = strtrim("`diff2'")
    local se2: display `format' _se[treat_arm_2]
    local `depvar'se2 = "(" + strtrim("`se2'") + ")"
	
	
	//TA3 - control (difference and se) 

    local diff3: display `format' _b[treat_arm_3]
	scalar t_stat3 = _b[treat_arm_3] / _se[treat_arm_3]
	scalar df3 = e(df_r)
	scalar pval_3 = 2 * ttail(df3, abs(t_stat3))
	if pval_3 < 0.01 local `depvar'diff3 = strtrim("`diff3'") + "\sym{***}"
	else if pval_3 < 0.05 local `depvar'diff3 = strtrim("`diff3'") + "\sym{**}"
	else if pval_3 < 0.1 local `depvar'diff3 = strtrim("`diff3'") + "\sym{*}"
    else local `depvar'diff3 = strtrim("`diff3'")
    local se3: display `format' _se[treat_arm_3]
    local `depvar'se3 = "(" + strtrim("`se3'") + ")"
	
	
	//TA4 - control (difference and se) 

    local diff4: display `format' _b[treat_arm_4]
	scalar t_stat4 = _b[treat_arm_4] / _se[treat_arm_4]
	scalar df4 = e(df_r)
	scalar pval_4 = 2 * ttail(df4, abs(t_stat4))
	if pval_4 < 0.01 local `depvar'diff4 = strtrim("`diff4'") + "\sym{***}"
	else if pval_4 < 0.05 local `depvar'diff4 = strtrim("`diff4'") + "\sym{**}"
	else if pval_4 < 0.1 local `depvar'diff4 = strtrim("`diff4'") + "\sym{*}"
    else local `depvar'diff4 = strtrim("`diff4'")
    local se4: display `format' _se[treat_arm_4]
    local `depvar'se4 = "(" + strtrim("`se4'") + ")"
	
	
	// observations 
	local `depvar'obs: display %9.0fc e(N) 		

}


//========================= TEACHER-LEVEL DATA ==========================//
local teacher "female_teach permanent ps_teach ms_teach teach_exp02 teach_exp36 teach_exp7 math_teach eng_teach spa_teach"


foreach depvar of local teacher {

    // control -- mean and standard deviation
    summarize `depvar' if teach_control == 1 & teacher==1
    local `depvar'controlM: display `format' r(mean)
    local sd: display `format' r(sd)
    local `depvar'controlSD = "[" + strtrim("`sd'") + "]"


    // TA1 - control (difference and se)
    reghdfe `depvar' teach_treat1 teach_treat2 teach_treat3 teach_treat4 if teacher==1, ///
	absorb(GRADE_ID_FK strata) vce(clustervar SCHOOL_CODE) 

    local diff1: display `format' _b[teach_treat1]
	scalar t_stat1 = _b[teach_treat1] / _se[teach_treat1]
	scalar df1 = e(df_r)
	scalar pval_1 = 2 * ttail(df1, abs(t_stat1))
	if pval_1 < 0.01 local `depvar'diff1 = strtrim("`diff1'") + "\sym{***}"
	else if pval_1 < 0.05 local `depvar'diff1 = strtrim("`diff1'") + "\sym{**}"
	else if pval_1 < 0.1 local `depvar'diff1 = strtrim("`diff1'") + "\sym{*}"
    else local `depvar'diff1 = strtrim("`diff1'")
    local se1: display `format' _se[teach_treat1]
    local `depvar'se1 = "(" + strtrim("`se1'") + ")"
	
	//TA2 - control (difference and se) 

    local diff2: display `format' _b[teach_treat2]
	scalar t_stat2 = _b[teach_treat2] / _se[teach_treat2]
	scalar df2 = e(df_r)
	scalar pval_2 = 2 * ttail(df2, abs(t_stat2))
	if pval_2 < 0.01 local `depvar'diff2 = strtrim("`diff2'") + "\sym{***}"
	else if pval_2 < 0.05 local `depvar'diff2 = strtrim("`diff2'") + "\sym{**}"
	else if pval_2 < 0.1 local `depvar'diff2 = strtrim("`diff2'") + "\sym{*}"
    else local `depvar'diff2 = strtrim("`diff2'")
    local se2: display `format' _se[teach_treat2]
    local `depvar'se2 = "(" + strtrim("`se2'") + ")"
	
	
	//TA3 - control (difference and se) 

    local diff3: display `format' _b[teach_treat3]
	scalar t_stat3 = _b[teach_treat3] / _se[teach_treat3]
	scalar df3 = e(df_r)
	scalar pval_3 = 2 * ttail(df3, abs(t_stat3))
	if pval_3 < 0.01 local `depvar'diff3 = strtrim("`diff3'") + "\sym{***}"
	else if pval_3 < 0.05 local `depvar'diff3 = strtrim("`diff3'") + "\sym{**}"
	else if pval_3 < 0.1 local `depvar'diff3 = strtrim("`diff3'") + "\sym{*}"
    else local `depvar'diff3 = strtrim("`diff3'")
    local se3: display `format' _se[teach_treat3]
    local `depvar'se3 = "(" + strtrim("`se3'") + ")"
	
	
	//TA4 - control (difference and se) 

    local diff4: display `format' _b[teach_treat4]
	scalar t_stat4 = _b[teach_treat4] / _se[teach_treat4]
	scalar df4 = e(df_r)
	scalar pval_4 = 2 * ttail(df4, abs(t_stat4))
	if pval_4 < 0.01 local `depvar'diff4 = strtrim("`diff4'") + "\sym{***}"
	else if pval_4 < 0.05 local `depvar'diff4 = strtrim("`diff4'") + "\sym{**}"
	else if pval_4 < 0.1 local `depvar'diff4 = strtrim("`diff4'") + "\sym{*}"
    else local `depvar'diff4 = strtrim("`diff4'")
    local se4: display `format' _se[teach_treat4]
    local `depvar'se4 = "(" + strtrim("`se4'") + ")"

	// observations 
	local `depvar'obs: display %9.0fc e(N)			

}


// Balance test table: 

texdoc init "$output\tables\main\01. balance.tex", replace force

	tex \begin{landscape}
	tex \begin{table}[htbp] \centering \onehalfspacing
	tex \fontsize{10}{11}\selectfont
	tex \caption{\textbf{Balance tests (Grades 4 to 8)}}
	tex \begin{tabular}{l*{6}c}
	tex \hline\hline
	

	tex &\multicolumn{1}{c}{Control mean} &\multicolumn{1}{c}{TA 1 - Control} &\multicolumn{1}{c}{TA 2 - Control} &\multicolumn{1}{c}{TA 3 - Control} &\multicolumn{1}{c}{TA 4 - Control} &\multicolumn{1}{c}{N} \\
	
	tex &\multicolumn{1}{c}{(1)} &\multicolumn{1}{c}{(2)} &\multicolumn{1}{c}{(3)} &\multicolumn{1}{c}{(4)} &\multicolumn{1}{c}{(5)} &\multicolumn{1}{c}{(6)} \\
	
	tex \hline
	tex \multicolumn{7}{l}{\textit{Panel A: Individual Characteristics}} \\
	
	
	tex Female & `gendercontrolM' & `genderdiff1' & `genderdiff2' & `genderdiff3' & `genderdiff4' & `genderobs'\\
	tex & `gendercontrolSD' & `genderse1' & `genderse2' & `genderse3' & `genderse4' & \\
	tex[1ex] 

	tex Age & `sa_agecontrolM' & `sa_agediff1' & `sa_agediff2' & `sa_agediff3' & `sa_agediff4'  & `sa_ageobs' \\
	tex & `sa_agecontrolSD' & `sa_agese1' & `sa_agese2' & `sa_agese3' & `sa_agese4' & \\
	tex[1ex]  
	
	tex Special education & `special_edcontrolM' & `special_eddiff1' & `special_eddiff2' & `special_eddiff3' & `special_eddiff4' & `special_edobs' \\
	tex & `special_edcontrolSD' & `special_edse1' & `special_edse2' & `special_edse3' & `special_edse4' & \\
	tex[1ex] 
	
	tex Poverty  & `povertycontrolM' & `povertydiff1' & `povertydiff2' & `povertydiff3' & `povertydiff4' & `povertyobs' \\
	tex & `povertycontrolSD' & `povertyse1' & `povertyse2' & `povertyse3' & `povertyse4' & \\
	tex[1ex] 
	
	tex Math score (2021) & `math_21controlM' & `math_21diff1' & `math_21diff2' & `math_21diff3' & `math_21diff4' & `math_21obs' \\
	tex & `math_21controlSD' & `math_21se1' & `math_21se2' & `math_21se3' & `math_21se4' & \\
	tex[1ex] 
	
	tex English score (2021) & `eng_21controlM' & `eng_21diff1' & `eng_21diff2' & `eng_21diff3' & `eng_21diff4' & `eng_21obs' \\
	tex & `eng_21controlSD' & `eng_21se1' & `eng_21se2' & `eng_21se3' & `eng_21se4' & \\
	tex[1ex] 
	
	tex Spanish score (2021) & `spa_21controlM' & `spa_21diff1' & `spa_21diff2' & `spa_21diff3' & `spa_21diff4' & `spa_21obs' \\
	tex & `spa_21controlSD' & `spa_21se1' & `spa_21se2' & `spa_21se3' & `spa_21se4' & \\
	tex[1ex] 
	
	tex Math score (2019) & `math_19controlM' & `math_19diff1' & `math_19diff2' & `math_19diff3' & `math_19diff4' & `math_19obs'  \\
	tex & `math_19controlSD' & `math_19se1' & `math_19se2' & `math_19se3' & `math_19se4' & \\
	tex[1ex] 

	tex GPA (2021) & `GPAcontrolM' & `GPAdiff1' & `GPAdiff2' & `GPAdiff3' & `GPAdiff4' & `GPAobs' \\
	tex & `GPAcontrolSD' & `GPAse1' & `GPAse2' & `GPAse3' & `GPAse4' & \\
	tex[1ex] 
	
	tex Math GPA (2021) & `GPA_matecontrolM' & `GPA_matediff1' & `GPA_matediff2' & `GPA_matediff3' & `GPA_matediff4' & `GPA_mateobs' \\
	tex & `GPA_matecontrolSD' & `GPA_matese1' & `GPA_matese2' & `GPA_matese3' & `GPA_matese4' & \\
	tex[1ex] 
	
		
	tex \hline \\
	tex [1ex]
	tex \multicolumn{7}{l}{\textit{Panel B: School Characteristics}} \\
	
	tex Total enrollment & `total_enrollmentcontrolM' & `total_enrollmentdiff1' & `total_enrollmentdiff2' & `total_enrollmentdiff3' & `total_enrollmentdiff4' & `total_enrollmentobs' \\
	tex & `total_enrollmentcontrolSD' & `total_enrollmentse1' & `total_enrollmentse2' & `total_enrollmentse3' & `total_enrollmentse4' & \\
	tex[1ex] 

	tex Student-to-teacher ratio & `pupil_teacher_ratiocontrolM' & `pupil_teacher_ratiodiff1' & `pupil_teacher_ratiodiff2' & `pupil_teacher_ratiodiff3' & `pupil_teacher_ratiodiff4' & `pupil_teacher_ratioobs' \\
	tex & `pupil_teacher_ratiocontrolSD' & `pupil_teacher_ratiose1' & `pupil_teacher_ratiose2' & `pupil_teacher_ratiose3' & `pupil_teacher_ratiose4' & \\
	tex[1ex] 
	
	tex Class size & `class_sizecontrolM' & `class_sizediff1' & `class_sizediff2' & `class_sizediff3' & `class_sizediff4' & `class_sizeobs' \\
	tex & `class_sizecontrolSD' & `class_sizese1' & `class_sizese2' & `class_sizese3' & `class_sizese4' & \\
	tex[1ex] 
		
	tex Rural & `town_ruralcontrolM' & `town_ruraldiff1' & `town_ruraldiff2' & `town_ruraldiff3' & `town_ruraldiff4' & `town_ruralobs' \\
	tex & `town_ruralcontrolSD' & `town_ruralse1' & `town_ruralse2' & `town_ruralse3' & `town_ruralse4' & \\
	tex[1ex] 
		
	tex Spanish average (grades 3-8) & `esp_38avgcontrolM' & `esp_38avgdiff1' & `esp_38avgdiff2' & `esp_38avgdiff3' & `esp_38avgdiff4' & `esp_38avgobs' \\
	tex & `esp_38avgcontrolSD' & `esp_38avgse1' & `esp_38avgse2' & `esp_38avgse3' & `esp_38avgse4' & \\
	tex[1ex] 
	
	tex Math average (grades 3-8) & `ma_38avgcontrolM' & `ma_38avgdiff1' & `ma_38avgdiff2' & `ma_38avgdiff3' & `ma_38avgdiff4' & `ma_38avgobs' \\
	tex & `ma_38avgcontrolSD' & `ma_38avgse1' & `ma_38avgse2' & `ma_38avgse3' & `ma_38avgse4' & \\
	tex[1ex] 
	
	tex English average (grades 3-8) & `ing_38avgcontrolM' & `ing_38avgdiff1' & `ing_38avgdiff2' & `ing_38avgdiff3' & `ing_38avgdiff4' & `ing_38avgobs' \\
	tex & `ing_38avgcontrolSD' & `ing_38avgse1' & `ing_38avgse2' & `ing_38avgse3' & `ing_38avgse4' & \\
	tex[1ex] 

	tex WMS & `wmscontrolM' & `wmsdiff1' & `wmsdiff2' & `wmsdiff3' & `wmsdiff4' & `wmsobs' \\
	tex & `wmscontrolSD' & `wmsse1' & `wmsse2' & `wmsse3' & `wmsse4' & \\
	tex[1ex] 
	
	tex \hline \\ 
	tex[1ex] 
	tex \multicolumn{7}{l}{\textit{Panel C: Teacher Characteristics}} \\


	tex Female & `female_teachcontrolM' & `female_teachdiff1' & `female_teachdiff2' & `female_teachdiff3' & `female_teachdiff4' & `female_teachobs' \\
	tex & `female_teachcontrolSD' & `female_teachse1' & `female_teachse2' & `female_teachse3' & `female_teachse4' & \\
	tex[1ex]  
	
	tex Primary school & `ps_teachcontrolM' & `ps_teachdiff1' & `ps_teachdiff2' & `ps_teachdiff3' & `ps_teachdiff4' & `ps_teachobs' \\
	tex & `ps_teachcontrolSD' & `ps_teachse1' & `ps_teachse2' & `ps_teachse3' & `ps_teachse4' & \\
	tex[1ex] 
	
	tex Middle school & `ms_teachcontrolM' & `ms_teachdiff1' & `ms_teachdiff2' & `ms_teachdiff3' & `ms_teachdiff4' & `ms_teachobs' \\
	tex & `ms_teachcontrolSD' & `ms_teachse1' & `ms_teachse2' & `ms_teachse3' & `ms_teachse4' & \\
	tex[1ex] 
	
	tex b_permanent & `permanentcontrolM' & `permanentdiff1' & `permanentdiff2' & `permanentdiff3' & `permanentdiff4' & `permanentobs' \\
	tex & `permanentcontrolSD' & `permanentse1' & `permanentse2' & `permanentse3' & `permanentse4' & \\
	tex[1ex] 
	
	tex 0-2 years of experience & `teach_exp02controlM' & `teach_exp02diff1' & `teach_exp02diff2' & `teach_exp02diff3' & `teach_exp02diff4' & `teach_exp02obs' \\
	tex & `teach_exp02controlSD' & `teach_exp02se1' & `teach_exp02se2' & `teach_exp02se3' & `teach_exp02se4' & \\
	tex[1ex] 
	
	tex 3-6 years of experience & `teach_exp36controlM' & `teach_exp36diff1' & `teach_exp36diff2' & `teach_exp36diff3' & `teach_exp36diff4' & `teach_exp36obs' \\
	tex & `teach_exp36controlSD' & `teach_exp36se1' & `teach_exp36se2' & `teach_exp36se3' & `teach_exp36se4' & \\
	tex[1ex] 
	
	tex 7+ years of experience & `teach_exp7controlM' & `teach_exp7diff1' & `teach_exp7diff2' & `teach_exp7diff3' & `teach_exp7diff4' & `teach_exp7obs' \\
	tex & `teach_exp7controlSD' & `teach_exp7se1' & `teach_exp7se2' & `teach_exp7se3' & `teach_exp7se4' & \\
	tex[1ex] 

	tex Math & `math_teachcontrolM' & `math_teachdiff1' & `math_teachdiff2' & `math_teachdiff3' & `math_teachdiff4' & `math_teachobs' \\
	tex & `math_teachcontrolSD' & `math_teachse1' & `math_teachse2' & `math_teachse3' & `math_teachse4' & \\
	tex[1ex] 

	tex English & `eng_teachcontrolM' & `eng_teachdiff1' & `eng_teachdiff2' & `eng_teachdiff3' & `eng_teachdiff4' & `eng_teachobs' \\
	tex & `eng_teachcontrolSD' & `eng_teachse1' & `eng_teachse2' & `eng_teachse3' & `eng_teachse4' & \\
	tex[1ex] 
	
	tex Spanish & `spa_teachcontrolM' & `spa_teachdiff1' & `spa_teachdiff2' & `spa_teachdiff3' & `spa_teachdiff4' & `spa_teachobs' \\
	tex & `spa_teachcontrolSD' & `spa_teachse1' & `spa_teachse2' & `spa_teachse3' & `spa_teachse4' & \\
	tex[1ex] 

	tex \hline\hline
	tex \end{tabular}
	tex \singlespacing
	tex \begin{tablenotes}[para, flushleft] \scriptsize \note Standard deviations of variables are reported in brackets. Robust standard errors are clustered by school and reported in parentheses. \sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\). Differences are adjusted for stratum and grade fixed effects. 
	tex \end{tablenotes}
	tex \end{table}
	tex \end{landscape}
	

	
texdoc close


	
	











