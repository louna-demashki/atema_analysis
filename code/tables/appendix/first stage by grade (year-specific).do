//----------------------------------------------------------------------------//
// File name: first stage by grade (year-specific)
// Last updated: Dec. 10, 2024 by Sara Mostafa
//----------------------------------------------------------------------------//


clear all
set matsize 6000
set more off 
global dir "D:\SECURE\data 2024\analysis\atema" 
global input "$dir\data\" 
global output "$dir\output"

cap log close
log using "$output\Logs\first stage by grade (year-specific).txt", text replace


use "$input\master_khan_student_combined", clear 


rename total_math_learning_minutes learn_min 
rename total_skills_leveled_up skills
rename total_upskill_familiar familiar
	

//============================================================================//
// Year-Specific 
//============================================================================//
local format "%9.3fc" 
local usage "student_login takeup learn_min skills familiar"
local grade_22 "4 5 6 7 8"

replace grade_21=3 if grade_21==5
replace grade_21=4 if grade_21==6 
replace grade_21=5 if grade_21==7
replace grade_21=6 if grade_21==8 
replace grade_21=7 if grade_21==9
replace grade_21=8 if grade_21==10


// AY 2022

foreach depvar of local usage {
	foreach i of local grade_22{

	// by 2021 grade
	qui: summarize `depvar' if (control==1 | treat_arm_3==1 | treat_arm_4==1) & ///
	ACADEMIC_YEAR_ID_FK == 2022 & grade_21==`i'
    local `depvar'c_M22_`i': display `format' r(mean)
    local sd_`i': display `format' r(sd)
    local `depvar'c_SD22_`i' = "[" + strtrim("`sd_`i''") + "]"
	
	}
}


// AY 2022
foreach depvar of local usage {
	foreach i of local grade_22{

	// by 2021 grade 
		reghdfe `depvar' treat_arm_1 treat_arm_2 treat_arm_3 treat_arm_4 if ///
		ACADEMIC_YEAR_ID_FK == 2022 & grade_21==`i', ///
		absorb(strata) vce(clustervar school_21)
		
		local b1_22_`i': display `format' _b[treat_arm_1]
		scalar t_stat1_22_`i' = _b[treat_arm_1]/_se[treat_arm_1]
		scalar df1_22_`i' = e(df_r)
		scalar pval1_22_`i' = 2 * ttail(df1_22_`i', abs(t_stat1_22_`i'))
		if pval1_22_`i' < 0.01 local `depvar'_b1_22_`i' = strtrim("`b1_22_`i''") + "\sym{***}"
		else if pval1_22_`i' < 0.05 local `depvar'_b1_22_`i' = strtrim("`b1_22_`i''") + "\sym{**}"
		else if pval1_22_`i' < 0.1 local `depvar'_b1_22_`i' = strtrim("`b1_22_`i''") + "\sym{*}"
		else local `depvar'_b1_22_`i' = strtrim("`b1_22_`i''")
		local se1_22_`i': display `format' _se[treat_arm_1]
		local `depvar'_se1_22_`i' = "(" + strtrim("`se1_22_`i''") + ")"
		
		local b2_22_`i': display `format' _b[treat_arm_2]
		scalar t_stat2_22_`i' = _b[treat_arm_2]/_se[treat_arm_2]
		scalar df2_22_`i' = e(df_r)
		scalar pval2_22_`i' = 2 * ttail(df2_22_`i', abs(t_stat2_22_`i'))
		if pval2_22_`i' < 0.01 local `depvar'_b2_22_`i' = strtrim("`b2_22_`i''") + "\sym{***}"
		else if pval2_22_`i' < 0.05 local `depvar'_b2_22_`i' = strtrim("`b2_22_`i''") + "\sym{**}"
		else if pval2_22_`i' < 0.1 local `depvar'_b2_22_`i' = strtrim("`b2_22_`i''") + "\sym{*}"
		else local `depvar'_b2_22_`i' = strtrim("`b2_22_`i''")
		local se2_22_`i': display `format' _se[treat_arm_2]
		local `depvar'_se2_22_`i' = "(" + strtrim("`se2_22_`i''") + ")"
		
		local b3_22_`i': display `format' _b[treat_arm_3]
		scalar t_stat3_22_`i' = _b[treat_arm_3]/_se[treat_arm_3]
		scalar df3_22_`i' = e(df_r)
		scalar pval3_22_`i' = 2 * ttail(df3_22_`i', abs(t_stat3_22_`i'))
		if pval3_22_`i' < 0.01 local `depvar'_b3_22_`i' = strtrim("`b3_22_`i''") + "\sym{***}"
		else if pval3_22_`i' < 0.05 local `depvar'_b3_22_`i' = strtrim("`b3_22_`i''") + "\sym{**}"
		else if pval3_22_`i' < 0.1 local `depvar'_b3_22_`i' = strtrim("`b3_22_`i''") + "\sym{*}"
		else local `depvar'_b3_22_`i' = strtrim("`b3_22_`i''")
		local se3_22_`i': display `format' _se[treat_arm_3]
		local `depvar'_se3_22_`i' = "(" + strtrim("`se3_22_`i''") + ")"

		local b4_22_`i': display `format' _b[treat_arm_4]
		scalar t_stat4_22_`i' = _b[treat_arm_4]/_se[treat_arm_4]
		scalar df4_22_`i' = e(df_r)
		scalar pval4_22_`i' = 2 * ttail(df4_22_`i', abs(t_stat4_22_`i'))
		if pval4_22_`i' < 0.01 local `depvar'_b4_22_`i' = strtrim("`b4_22_`i''") + "\sym{***}"
		else if pval4_22_`i' < 0.05 local `depvar'_b4_22_`i' = strtrim("`b4_22_`i''") + "\sym{**}"
		else if pval4_22_`i' < 0.1 local `depvar'_b4_22_`i' = strtrim("`b4_22_`i''") + "\sym{*}"
		else local `depvar'_b4_22_`i' = strtrim("`b4_22_`i''")
		local se4_22_`i': display `format' _se[treat_arm_4]
		local `depvar'_se4_22_`i' = "(" + strtrim("`se4_22_`i''") + ")"

		local `depvar'obs_22_`i': display %9.0fc e(N)
		
		}
}



local grade_23 "3 4 5 6 7"

// AY 2023
foreach depvar of local usage {
	foreach i of local grade_23{
	
	// by 2021 grade
	qui: summarize `depvar' if control==1 & ACADEMIC_YEAR_ID_FK == 2023 & grade_21==`i'
    local `depvar'c_M23_`i': display `format' r(mean)
    local sd_`i': display `format' r(sd)
    local `depvar'c_SD23_`i' = "[" + strtrim("`sd_`i''") + "]"
	
	}
}


// AY 2023
foreach depvar of local usage {
	foreach i of local grade_23{

		reghdfe `depvar' treat_arm_1 treat_arm_2 treat_arm_3 treat_arm_4 if ///
		ACADEMIC_YEAR_ID_FK == 2023 & grade_21==`i', ///
		absorb(strata) vce(clustervar school_21)
		
		local b1_23_`i': display `format' _b[treat_arm_1]
		scalar t_stat1_23_`i' = _b[treat_arm_1]/_se[treat_arm_1]
		scalar df1_23_`i' = e(df_r)
		scalar pval1_23_`i' = 2 * ttail(df1_23_`i', abs(t_stat1_23_`i'))
		if pval1_23_`i' < 0.01 local `depvar'_b1_23_`i' = strtrim("`b1_23_`i''") + "\sym{***}"
		else if pval1_23_`i' < 0.05 local `depvar'_b1_23_`i' = strtrim("`b1_23_`i''") + "\sym{**}"
		else if pval1_23_`i' < 0.1 local `depvar'_b1_23_`i' = strtrim("`b1_23_`i''") + "\sym{*}"
		else local `depvar'_b1_23_`i' = strtrim("`b1_23_`i''")
		local se1_23_`i': display `format' _se[treat_arm_1]
		local `depvar'_se1_23_`i' = "(" + strtrim("`se1_23_`i''") + ")"
		
		local b2_23_`i': display `format' _b[treat_arm_2]
		scalar t_stat2_23_`i' = _b[treat_arm_2]/_se[treat_arm_2]
		scalar df2_23_`i' = e(df_r)
		scalar pval2_23_`i' = 2 * ttail(df2_23_`i', abs(t_stat2_23_`i'))
		if pval2_23_`i' < 0.01 local `depvar'_b2_23_`i' = strtrim("`b2_23_`i''") + "\sym{***}"
		else if pval2_23_`i' < 0.05 local `depvar'_b2_23_`i' = strtrim("`b2_23_`i''") + "\sym{**}"
		else if pval2_23_`i' < 0.1 local `depvar'_b2_23_`i' = strtrim("`b2_23_`i''") + "\sym{*}"
		else local `depvar'_b2_23_`i' = strtrim("`b2_23_`i''")
		local se2_23_`i': display `format' _se[treat_arm_2]
		local `depvar'_se2_23_`i' = "(" + strtrim("`se2_23_`i''") + ")"
		
		local b3_23_`i': display `format' _b[treat_arm_3]
		scalar t_stat3_23_`i' = _b[treat_arm_3]/_se[treat_arm_3]
		scalar df3_23_`i' = e(df_r)
		scalar pval3_23_`i' = 2 * ttail(df3_23_`i', abs(t_stat3_23_`i'))
		if pval3_23_`i' < 0.01 local `depvar'_b3_23_`i' = strtrim("`b3_23_`i''") + "\sym{***}"
		else if pval3_23_`i' < 0.05 local `depvar'_b3_23_`i' = strtrim("`b3_23_`i''") + "\sym{**}"
		else if pval3_23_`i' < 0.1 local `depvar'_b3_23_`i' = strtrim("`b3_23_`i''") + "\sym{*}"
		else local `depvar'_b3_23_`i' = strtrim("`b3_23_`i''")
		local se3_23_`i': display `format' _se[treat_arm_3]
		local `depvar'_se3_23_`i' = "(" + strtrim("`se3_23_`i''") + ")"

		local b4_23_`i': display `format' _b[treat_arm_4]
		scalar t_stat4_23_`i' = _b[treat_arm_4]/_se[treat_arm_4]
		scalar df4_23_`i' = e(df_r)
		scalar pval4_23_`i' = 2 * ttail(df4_23_`i', abs(t_stat4_23_`i'))
		if pval4_23_`i' < 0.01 local `depvar'_b4_23_`i' = strtrim("`b4_23_`i''") + "\sym{***}"
		else if pval4_23_`i' < 0.05 local `depvar'_b4_23_`i' = strtrim("`b4_23_`i''") + "\sym{**}"
		else if pval4_23_`i' < 0.1 local `depvar'_b4_23_`i' = strtrim("`b4_23_`i''") + "\sym{*}"
		else local `depvar'_b4_23_`i' = strtrim("`b4_23_`i''")
		local se4_23_`i': display `format' _se[treat_arm_4]
		local `depvar'_se4_23_`i' = "(" + strtrim("`se4_23_`i''") + ")"

		local `depvar'obs_23_`i': display %9.0fc e(N)
		
		}
}
	

texdoc init "$output\tables\appendix\first stage by grade (year-specific).tex", replace force 
	tex \begin{table}[htbp]
	tex \centering
	tex \resizebox{\linewidth}{!}{%
	tex \begin{threeparttable}
	tex \caption{\textbf{First Stage by 2021 Grade} (Academic Year 2021-2022)}
	tex \fontsize{5}{6}\selectfont
	tex \begin{tabular}{l*{5}c}
	tex \hline\hline
	tex &\multicolumn{1}{c}{Student login} &\multicolumn{1}{c}{At least 5 minutes} &\multicolumn{1}{c}{Number of} &\multicolumn{1}{c}{Skills} &\multicolumn{1}{c}{Familiar} \\
	tex &\multicolumn{1}{c}{} &\multicolumn{1}{c}{per week} &\multicolumn{1}{c}{minutes} &\multicolumn{1}{c}{} &\multicolumn{1}{c}{} \\
	tex &\multicolumn{1}{c}{(1)} &\multicolumn{1}{c}{(2)} &\multicolumn{1}{c}{(3)} &\multicolumn{1}{c}{(4)} &\multicolumn{1}{c}{(5)} \\

	tex \hline
	tex [1ex]
	tex \multicolumn{6}{l}{\textbf{Grade 4}} \\
	tex [1ex] 
	
	tex Treatment arm 1 & `student_login_b1_22_4' & `takeup_b1_22_4' & `learn_min_b1_22_4' & `skills_b1_22_4' & `familiar_b1_22_4' \\
	tex & `student_login_se1_22_4' & `takeup_se1_22_4' & `learn_min_se1_22_4' & `skills_se1_22_4' & `familiar_se1_22_4' \\
	tex [1ex] 
	
	tex Treatment arm 2 & `student_login_b2_22_4' & `takeup_b2_22_4' & `learn_min_b2_22_4' & `skills_b2_22_4' & `familiar_b2_22_4' \\
	tex & `student_login_se2_22_4' & `takeup_se2_22_4' & `learn_min_se2_22_4' & `skills_se2_22_4' & `familiar_se2_22_4' \\
	tex [1ex] 
	
	tex Control & `student_loginc_M22_4' & `takeupc_M22_4' & `learn_minc_M22_4' & `skillsc_M22_4' & `familiarc_M22_4' \\
	tex [1ex]
	
	tex N & `student_loginobs_22_4' & `takeupobs_22_4' & `learn_minobs_22_4' & `skillsobs_22_4' & `familiarobs_22_4' \\
	tex[1ex] 
	
	tex \multicolumn{6}{l}{\textbf{Grade 5}} \\
	tex [1ex] 
	
	tex Treatment arm 1 & `student_login_b1_22_5' & `takeup_b1_22_5' & `learn_min_b1_22_5' & `skills_b1_22_5' & `familiar_b1_22_5' \\
	tex & `student_login_se1_22_5' & `takeup_se1_22_5' & `learn_min_se1_22_5' & `skills_se1_22_5' & `familiar_se1_22_5' \\
	tex [1ex] 
	
	tex Treatment arm 2 & `student_login_b2_22_5' & `takeup_b2_22_5' & `learn_min_b2_22_5' & `skills_b2_22_5' & `familiar_b2_22_5' \\
	tex & `student_login_se2_22_5' & `takeup_se2_22_5' & `learn_min_se2_22_5' & `skills_se2_22_5' & `familiar_se2_22_5' \\
	tex [1ex] 
	
	tex Control & `student_loginc_M22_5' & `takeupc_M22_5' & `learn_minc_M22_5' & `skillsc_M22_5' & `familiarc_M22_5' \\
	tex [1ex]
	
	tex N & `student_loginobs_22_5' & `takeupobs_22_5' & `learn_minobs_22_5' & `skillsobs_22_5' & `familiarobs_22_5' \\
	tex[1ex] 
	
	tex \multicolumn{6}{l}{\textbf{Grade 6}} \\
	tex [1ex] 
	
	tex Treatment arm 1 & `student_login_b1_22_6' & `takeup_b1_22_6' & `learn_min_b1_22_6' & `skills_b1_22_6' & `familiar_b1_22_6' \\
	tex & `student_login_se1_22_6' & `takeup_se1_22_6' & `learn_min_se1_22_6' & `skills_se1_22_6' & `familiar_se1_22_6' \\
	tex [1ex] 
	
	tex Treatment arm 2 & `student_login_b2_22_6' & `takeup_b2_22_6' & `learn_min_b2_22_6' & `skills_b2_22_6' & `familiar_b2_22_6' \\
	tex & `student_login_se2_22_6' & `takeup_se2_22_6' & `learn_min_se2_22_6' & `skills_se2_22_6' & `familiar_se2_22_6' \\
	tex [1ex] 
	
	tex Control & `student_loginc_M22_6' & `takeupc_M22_6' & `learn_minc_M22_6' & `skillsc_M22_6' & `familiarc_M22_6' \\
	tex [1ex]
	
	tex N & `student_loginobs_22_6' & `takeupobs_22_6' & `learn_minobs_22_6' & `skillsobs_22_6' & `familiarobs_22_6' \\
	tex[1ex] 
	
	tex \multicolumn{6}{l}{\textbf{Grade 7}} \\
	tex [1ex] 
	
	tex Treatment arm 1 & `student_login_b1_22_7' & `takeup_b1_22_7' & `learn_min_b1_22_7' & `skills_b1_22_7' & `familiar_b1_22_7' \\
	tex & `student_login_se1_22_7' & `takeup_se1_22_7' & `learn_min_se1_22_7' & `skills_se1_22_7' & `familiar_se1_22_7' \\
	tex [1ex] 
	
	tex Treatment arm 2 & `student_login_b2_22_7' & `takeup_b2_22_7' & `learn_min_b2_22_7' & `skills_b2_22_7' & `familiar_b2_22_7' \\
	tex & `student_login_se2_22_7' & `takeup_se2_22_7' & `learn_min_se2_22_7' & `skills_se2_22_7' & `familiar_se2_22_7' \\
	tex [1ex] 
	
	tex Control & `student_loginc_M22_7' & `takeupc_M22_7' & `learn_minc_M22_7' & `skillsc_M22_7' & `familiarc_M22_7' \\
	tex [1ex]
	
	tex N & `student_loginobs_22_7' & `takeupobs_22_7' & `learn_minobs_22_7' & `skillsobs_22_7' & `familiarobs_22_7' \\
	tex[1ex] 
	
	tex \multicolumn{6}{l}{\textbf{Grade 8}} \\
	tex [1ex] 
	
	tex Treatment arm 1 & `student_login_b1_22_8' & `takeup_b1_22_8' & `learn_min_b1_22_8' & `skills_b1_22_8' & `familiar_b1_22_8' \\
	tex & `student_login_se1_22_8' & `takeup_se1_22_8' & `learn_min_se1_22_8' & `skills_se1_22_8' & `familiar_se1_22_8' \\
	tex [1ex] 
	
	tex Treatment arm 2 & `student_login_b2_22_8' & `takeup_b2_22_8' & `learn_min_b2_22_8' & `skills_b2_22_8' & `familiar_b2_22_8' \\
	tex & `student_login_se2_22_8' & `takeup_se2_22_8' & `learn_min_se2_22_8' & `skills_se2_22_8' & `familiar_se2_22_8' \\
	tex [1ex] 
	
	tex Control & `student_loginc_M22_8' & `takeupc_M22_8' & `learn_minc_M22_8' & `skillsc_M22_8' & `familiarc_M22_8' \\
	tex [1ex]
	
	tex N & `student_loginobs_22_8' & `takeupobs_22_8' & `learn_minobs_22_8' & `skillsobs_22_8' & `familiarobs_22_8' \\
	tex[1ex] 
	
	tex \hline\hline
	
	tex \end{tabular}
	tex \begin{tablenotes}[para, flushleft]
	tex \scriptsize
	tex \note Robust standard errors of variables are clustered by school and reported in brackets. \sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\). Adjusted for stratum and grade fixed effects. Regressions include controls for students' gender, age, and special education status, school total enrollment and student-to-teacher ratio, and teachers' gender.   
	tex \end{tablenotes}
	tex \end{threeparttable}
	tex }
	tex \end{table}	
	
	tex \clearpage
	
	tex \begin{table}[htbp]
	tex \centering
	tex \resizebox{\linewidth}{!}{%
	tex \begin{threeparttable}
	tex \caption{\textbf{First Stage by 2021 Grade} (Academic Year 2022-2023)}
	tex \fontsize{5}{6}\selectfont
	tex \begin{tabular}{l*{5}c}
	tex \hline\hline
	tex &\multicolumn{1}{c}{Student login} &\multicolumn{1}{c}{At least 5 minutes} &\multicolumn{1}{c}{Number of} &\multicolumn{1}{c}{Skills} &\multicolumn{1}{c}{Familiar} \\
	tex &\multicolumn{1}{c}{} &\multicolumn{1}{c}{per week} &\multicolumn{1}{c}{minutes} &\multicolumn{1}{c}{} &\multicolumn{1}{c}{} \\
	tex &\multicolumn{1}{c}{(1)} &\multicolumn{1}{c}{(2)} &\multicolumn{1}{c}{(3)} &\multicolumn{1}{c}{(4)} &\multicolumn{1}{c}{(5)} \\

	tex \hline
	tex [1ex]
	tex \multicolumn{6}{l}{\textbf{Grade 3}} \\
	tex [1ex] 
	
	tex Treatment arm 1 & `student_login_b1_23_3' & `takeup_b1_23_3' & `learn_min_b1_23_3' & `skills_b1_23_3' & `familiar_b1_23_3' \\
	tex & `student_login_se1_23_3' & `takeup_se1_23_3' & `learn_min_se1_23_3' & `skills_se1_23_3' & `familiar_se1_23_3' \\
	tex [1ex] 
	
	tex Treatment arm 2 & `student_login_b2_23_3' & `takeup_b2_23_3' & `learn_min_b2_23_3' & `skills_b2_23_3' & `familiar_b2_23_3' \\
	tex & `student_login_se2_23_3' & `takeup_se2_23_3' & `learn_min_se2_23_3' & `skills_se2_23_3' & `familiar_se2_23_3' \\
	tex [1ex] 
	
	tex Treatment arm 3 & `student_login_b3_23_3' & `takeup_b3_23_3' & `learn_min_b3_23_3' & `skills_b3_23_3' & `familiar_b3_23_3' \\
	tex & `student_login_se3_23_3' & `takeup_se3_23_3' & `learn_min_se3_23_3' & `skills_se3_23_3' & `familiar_se3_23_3' \\
	tex [1ex] 
	
	tex Treatment arm 4 & `student_login_b4_23_3' & `takeup_b4_23_3' & `learn_min_b4_23_3' & `skills_b4_23_3' & `familiar_b4_23_3' \\
	tex & `student_login_se4_23_3' & `takeup_se4_23_3' & `learn_min_se4_23_3' & `skills_se4_23_3' & `familiar_se4_23_3' \\
	tex [1ex] 
	
	tex Control & `student_loginc_M23_3' & `takeupc_M23_3' & `learn_minc_M23_3' & `skillsc_M23_3' & `familiarc_M23_3' \\
	tex [1ex]
		
	tex N & `student_loginobs_23_3' & `takeupobs_23_3' & `learn_minobs_23_3' & `skillsobs_23_3' & `familiarobs_23_3' \\
	tex[1ex] 
	
	tex \multicolumn{6}{l}{\textbf{Grade 4}} \\
	tex [1ex] 
	
	tex Treatment arm 1 & `student_login_b1_23_4' & `takeup_b1_23_4' & `learn_min_b1_23_4' & `skills_b1_23_4' & `familiar_b1_23_4' \\
	tex & `student_login_se1_23_4' & `takeup_se1_23_4' & `learn_min_se1_23_4' & `skills_se1_23_4' & `familiar_se1_23_4' \\
	tex [1ex] 
	
	tex Treatment arm 2 & `student_login_b2_23_4' & `takeup_b2_23_4' & `learn_min_b2_23_4' & `skills_b2_23_4' & `familiar_b2_23_4' \\
	tex & `student_login_se2_23_4' & `takeup_se2_23_4' & `learn_min_se2_23_4' & `skills_se2_23_4' & `familiar_se2_23_4' \\
	tex [1ex] 
	
	tex Treatment arm 3 & `student_login_b3_23_4' & `takeup_b3_23_4' & `learn_min_b3_23_4' & `skills_b3_23_4' & `familiar_b3_23_4' \\
	tex & `student_login_se3_23_4' & `takeup_se3_23_4' & `learn_min_se3_23_4' & `skills_se3_23_4' & `familiar_se3_23_4' \\
	tex [1ex] 
	
	tex Treatment arm 4 & `student_login_b4_23_4' & `takeup_b4_23_4' & `learn_min_b4_23_4' & `skills_b4_23_4' & `familiar_b4_23_4' \\
	tex & `student_login_se4_23_4' & `takeup_se4_23_4' & `learn_min_se4_23_4' & `skills_se4_23_4' & `familiar_se4_23_4' \\
	tex [1ex] 
	
	tex Control & `student_loginc_M23_4' & `takeupc_M23_4' & `learn_minc_M23_4' & `skillsc_M23_4' & `familiarc_M23_4' \\
	tex [1ex]
		
	tex N & `student_loginobs_23_4' & `takeupobs_23_4' & `learn_minobs_23_4' & `skillsobs_23_4' & `familiarobs_23_4' \\
	tex[1ex] 
	
	tex \multicolumn{6}{l}{\textbf{Grade 5}} \\
	tex [1ex] 
	
	tex Treatment arm 1 & `student_login_b1_23_5' & `takeup_b1_23_5' & `learn_min_b1_23_5' & `skills_b1_23_5' & `familiar_b1_23_5' \\
	tex & `student_login_se1_23_5' & `takeup_se1_23_5' & `learn_min_se1_23_5' & `skills_se1_23_5' & `familiar_se1_23_5' \\
	tex [1ex] 
	
	tex Treatment arm 2 & `student_login_b2_23_5' & `takeup_b2_23_5' & `learn_min_b2_23_5' & `skills_b2_23_5' & `familiar_b2_23_5' \\
	tex & `student_login_se2_23_5' & `takeup_se2_23_5' & `learn_min_se2_23_5' & `skills_se2_23_5' & `familiar_se2_23_5' \\
	tex [1ex] 
	
	tex Treatment arm 3 & `student_login_b3_23_5' & `takeup_b3_23_5' & `learn_min_b3_23_5' & `skills_b3_23_5' & `familiar_b3_23_5' \\
	tex & `student_login_se3_23_5' & `takeup_se3_23_5' & `learn_min_se3_23_5' & `skills_se3_23_5' & `familiar_se3_23_5' \\
	tex [1ex] 
	
	tex Treatment arm 4 & `student_login_b4_23_5' & `takeup_b4_23_5' & `learn_min_b4_23_5' & `skills_b4_23_5' & `familiar_b4_23_5' \\
	tex & `student_login_se4_23_5' & `takeup_se4_23_5' & `learn_min_se4_23_5' & `skills_se4_23_5' & `familiar_se4_23_5' \\
	tex [1ex] 
	
	tex Control & `student_loginc_M23_5' & `takeupc_M23_5' & `learn_minc_M23_5' & `skillsc_M23_5' & `familiarc_M23_5' \\
	tex [1ex]
		
	tex N & `student_loginobs_23_5' & `takeupobs_23_5' & `learn_minobs_23_5' & `skillsobs_23_5' & `familiarobs_23_5' \\
	tex[1ex] 
	
	tex \multicolumn{6}{l}{\textbf{Grade 6}} \\
	tex [1ex] 
	
	tex Treatment arm 1 & `student_login_b1_23_6' & `takeup_b1_23_6' & `learn_min_b1_23_6' & `skills_b1_23_6' & `familiar_b1_23_6' \\
	tex & `student_login_se1_23_6' & `takeup_se1_23_6' & `learn_min_se1_23_6' & `skills_se1_23_6' & `familiar_se1_23_6' \\
	tex [1ex] 
	
	tex Treatment arm 2 & `student_login_b2_23_6' & `takeup_b2_23_6' & `learn_min_b2_23_6' & `skills_b2_23_6' & `familiar_b2_23_6' \\
	tex & `student_login_se2_23_6' & `takeup_se2_23_6' & `learn_min_se2_23_6' & `skills_se2_23_6' & `familiar_se2_23_6' \\
	tex [1ex] 
	
	tex Treatment arm 3 & `student_login_b3_23_6' & `takeup_b3_23_6' & `learn_min_b3_23_6' & `skills_b3_23_6' & `familiar_b3_23_6' \\
	tex & `student_login_se3_23_6' & `takeup_se3_23_6' & `learn_min_se3_23_6' & `skills_se3_23_6' & `familiar_se3_23_6' \\
	tex [1ex] 
	
	tex Treatment arm 4 & `student_login_b4_23_6' & `takeup_b4_23_6' & `learn_min_b4_23_6' & `skills_b4_23_6' & `familiar_b4_23_6' \\
	tex & `student_login_se4_23_6' & `takeup_se4_23_6' & `learn_min_se4_23_6' & `skills_se4_23_6' & `familiar_se4_23_6' \\
	tex [1ex] 
	
	tex Control & `student_loginc_M23_6' & `takeupc_M23_6' & `learn_minc_M23_6' & `skillsc_M23_6' & `familiarc_M23_6' \\
	tex [1ex]
		
	tex N & `student_loginobs_23_6' & `takeupobs_23_6' & `learn_minobs_23_6' & `skillsobs_23_6' & `familiarobs_23_6' \\
	tex[1ex] 
	
	tex \multicolumn{6}{l}{\textbf{Grade 7}} \\
	tex [1ex] 
	
	tex Treatment arm 1 & `student_login_b1_23_7' & `takeup_b1_23_7' & `learn_min_b1_23_7' & `skills_b1_23_7' & `familiar_b1_23_7' \\
	tex & `student_login_se1_23_7' & `takeup_se1_23_7' & `learn_min_se1_23_7' & `skills_se1_23_7' & `familiar_se1_23_7' \\
	tex [1ex] 
	
	tex Treatment arm 2 & `student_login_b2_23_7' & `takeup_b2_23_7' & `learn_min_b2_23_7' & `skills_b2_23_7' & `familiar_b2_23_7' \\
	tex & `student_login_se2_23_7' & `takeup_se2_23_7' & `learn_min_se2_23_7' & `skills_se2_23_7' & `familiar_se2_23_7' \\
	tex [1ex] 
	
	tex Treatment arm 3 & `student_login_b3_23_7' & `takeup_b3_23_7' & `learn_min_b3_23_7' & `skills_b3_23_7' & `familiar_b3_23_7' \\
	tex & `student_login_se3_23_7' & `takeup_se3_23_7' & `learn_min_se3_23_7' & `skills_se3_23_7' & `familiar_se3_23_7' \\
	tex [1ex] 
	
	tex Treatment arm 4 & `student_login_b4_23_7' & `takeup_b4_23_7' & `learn_min_b4_23_7' & `skills_b4_23_7' & `familiar_b4_23_7' \\
	tex & `student_login_se4_23_7' & `takeup_se4_23_7' & `learn_min_se4_23_7' & `skills_se4_23_7' & `familiar_se4_23_7' \\
	tex [1ex] 
	
	tex Control & `student_loginc_M23_7' & `takeupc_M23_7' & `learn_minc_M23_7' & `skillsc_M23_7' & `familiarc_M23_7' \\
	tex [1ex]
		
	tex N & `student_loginobs_23_7' & `takeupobs_23_7' & `learn_minobs_23_7' & `skillsobs_23_7' & `familiarobs_23_7' \\
	tex[1ex] 
	tex \hline\hline
	
	tex \end{tabular}
	tex \begin{tablenotes}[para, flushleft]
	tex \scriptsize
	tex \note Robust standard errors of variables are clustered by school and reported in brackets. \sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\). Adjusted for stratum and grade fixed effects. Regressions include controls for students' gender, age, and special education status, school total enrollment and student-to-teacher ratio, and teachers' gender.   
	tex \end{tablenotes}
	tex \end{threeparttable}
	tex }
	tex \end{table}	
	
	
texdoc close




