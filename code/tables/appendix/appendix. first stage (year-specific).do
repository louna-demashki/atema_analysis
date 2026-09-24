//----------------------------------------------------------------------------//
// File name: 2.a. first stage (year-specific)
// Last updated: Nov 7, 2024 by Sara Mostafa
//----------------------------------------------------------------------------//


clear all
set matsize 6000
set more off 
global dir "D:\SECURE\data 2024\analysis\atema" 
global input "$dir\data\" 
global output "$dir\output"

cap log close
log using "$output\Logs\2.a. first stage (year-specific).txt", text replace


use "$input\master_khan_student_combined", clear 

rename total_math_learning_minutes learn_min 
rename total_skills_leveled_up skills
rename total_upskill_familiar familiar
	

//============================================================================//
// Year-Specific 
//============================================================================//
local format "%9.3fc" 
local usage "student_login takeup learn_min skills familiar"

	// AY 2022
foreach depvar of local usage {

	summarize `depvar' if (control==1 | treat_arm_3==1 | treat_arm_4==1) & ///
	ACADEMIC_YEAR_ID_FK == 2022
    local `depvar'c_M22: display `format' r(mean)
    local sd: display `format' r(sd)
    local `depvar'c_SD22 = "[" + strtrim("`sd'") + "]"
	
}

	// AY 2023
foreach depvar of local usage {

	summarize `depvar' if control==1 & ACADEMIC_YEAR_ID_FK == 2023
    local `depvar'c_M23: display `format' r(mean)
    local sd: display `format' r(sd)
    local `depvar'c_SD23 = "[" + strtrim("`sd'") + "]"
	
}


// AY 2022
foreach depvar of local usage {

	//all grades 
		reghdfe `depvar' treat_arm_1 treat_arm_2 treat_arm_3 treat_arm_4 if ///
		ACADEMIC_YEAR_ID_FK == 2022, ///
		absorb(GRADE_ID_FK strata) vce(clustervar school_21)
		
		local b1_22: display `format' _b[treat_arm_1]
		scalar t_stat1_22 = _b[treat_arm_1]/_se[treat_arm_1]
		scalar df1_22 = e(df_r)
		scalar pval1_22 = 2 * ttail(df1_22, abs(t_stat1_22))
		if pval1_22 < 0.01 local `depvar'_b1_22 = strtrim("`b1_22'") + "\sym{***}"
		else if pval1_22 < 0.05 local `depvar'_b1_22 = strtrim("`b1_22'") + "\sym{**}"
		else if pval1_22 < 0.1 local `depvar'_b1_22 = strtrim("`b1_22'") + "\sym{*}"
		else local `depvar'_b1_22 = strtrim("`b1_22'")
		local se1_22: display `format' _se[treat_arm_1]
		local `depvar'_se1_22 = "(" + strtrim("`se1_22'") + ")"
		
		local b2_22: display `format' _b[treat_arm_2]
		scalar t_stat2_22 = _b[treat_arm_2]/_se[treat_arm_2]
		scalar df2_22 = e(df_r)
		scalar pval2_22 = 2 * ttail(df2_22, abs(t_stat2_22))
		if pval2_22 < 0.01 local `depvar'_b2_22 = strtrim("`b2_22'") + "\sym{***}"
		else if pval2_22 < 0.05 local `depvar'_b2_22 = strtrim("`b2_22'") + "\sym{**}"
		else if pval2_22 < 0.1 local `depvar'_b2_22 = strtrim("`b2_22'") + "\sym{*}"
		else local `depvar'_b2_22 = strtrim("`b2_22'")
		local se2_22: display `format' _se[treat_arm_2]
		local `depvar'_se2_22 = "(" + strtrim("`se2_22'") + ")"
		
		local b3_22: display `format' _b[treat_arm_3]
		scalar t_stat3_22 = _b[treat_arm_3]/_se[treat_arm_3]
		scalar df3_22 = e(df_r)
		scalar pval3_22 = 2 * ttail(df3_22, abs(t_stat3_22))
		if pval3_22 < 0.01 local `depvar'_b3_22 = strtrim("`b3_22'") + "\sym{***}"
		else if pval3_22 < 0.05 local `depvar'_b3_22 = strtrim("`b3_22'") + "\sym{**}"
		else if pval3_22 < 0.1 local `depvar'_b3_22 = strtrim("`b3_22'") + "\sym{*}"
		else local `depvar'_b3_22 = strtrim("`b3_22'")
		local se3_22: display `format' _se[treat_arm_3]
		local `depvar'_se3_22 = "(" + strtrim("`se3_22'") + ")"

		local b4_22: display `format' _b[treat_arm_4]
		scalar t_stat4_22 = _b[treat_arm_4]/_se[treat_arm_4]
		scalar df4_22 = e(df_r)
		scalar pval4_22 = 2 * ttail(df4_22, abs(t_stat4_22))
		if pval4_22 < 0.01 local `depvar'_b4_22 = strtrim("`b4_22'") + "\sym{***}"
		else if pval4_22 < 0.05 local `depvar'_b4_22 = strtrim("`b4_22'") + "\sym{**}"
		else if pval4_22 < 0.1 local `depvar'_b4_22 = strtrim("`b4_22'") + "\sym{*}"
		else local `depvar'_b4_22 = strtrim("`b4_22'")
		local se4_22: display `format' _se[treat_arm_4]
		local `depvar'_se4_22 = "(" + strtrim("`se4_22'") + ")"
		
		local `depvar'obs_22: display %9.0fc e(N)
}


// AY 2023
foreach depvar of local usage {

	//all grades 
		reghdfe `depvar' treat_arm_1 treat_arm_2 treat_arm_3 treat_arm_4 if ///
		ACADEMIC_YEAR_ID_FK == 2023, ///
		absorb(GRADE_ID_FK strata) vce(clustervar school_21)
		
		local b1_23: display `format' _b[treat_arm_1]
		scalar t_stat1_23 = _b[treat_arm_1]/_se[treat_arm_1]
		scalar df1_23 = e(df_r)
		scalar pval1_23 = 2 * ttail(df1_23, abs(t_stat1_23))
		if pval1_23 < 0.01 local `depvar'_b1_23 = strtrim("`b1_23'") + "\sym{***}"
		else if pval1_23 < 0.05 local `depvar'_b1_23 = strtrim("`b1_23'") + "\sym{**}"
		else if pval1_23 < 0.1 local `depvar'_b1_23 = strtrim("`b1_23'") + "\sym{*}"
		else local `depvar'_b1_23 = strtrim("`b1_23'")
		local se1_23: display `format' _se[treat_arm_1]
		local `depvar'_se1_23 = "(" + strtrim("`se1_23'") + ")"
		
		local b2_23: display `format' _b[treat_arm_2]
		scalar t_stat2_23 = _b[treat_arm_2]/_se[treat_arm_2]
		scalar df2_23 = e(df_r)
		scalar pval2_23 = 2 * ttail(df2_23, abs(t_stat2_23))
		if pval2_23 < 0.01 local `depvar'_b2_23 = strtrim("`b2_23'") + "\sym{***}"
		else if pval2_23 < 0.05 local `depvar'_b2_23 = strtrim("`b2_23'") + "\sym{**}"
		else if pval2_23 < 0.1 local `depvar'_b2_23 = strtrim("`b2_23'") + "\sym{*}"
		else local `depvar'_b2_23 = strtrim("`b2_23'")
		local se2_23: display `format' _se[treat_arm_2]
		local `depvar'_se2_23 = "(" + strtrim("`se2_23'") + ")"
		
		local b3_23: display `format' _b[treat_arm_3]
		scalar t_stat3_23 = _b[treat_arm_3]/_se[treat_arm_3]
		scalar df3_23 = e(df_r)
		scalar pval3_23 = 2 * ttail(df3_23, abs(t_stat3_23))
		if pval3_23 < 0.01 local `depvar'_b3_23 = strtrim("`b3_23'") + "\sym{***}"
		else if pval3_23 < 0.05 local `depvar'_b3_23 = strtrim("`b3_23'") + "\sym{**}"
		else if pval3_23 < 0.1 local `depvar'_b3_23 = strtrim("`b3_23'") + "\sym{*}"
		else local `depvar'_b3_23 = strtrim("`b3_23'")
		local se3_23: display `format' _se[treat_arm_3]
		local `depvar'_se3_23 = "(" + strtrim("`se3_23'") + ")"

		local b4_23: display `format' _b[treat_arm_4]
		scalar t_stat4_23 = _b[treat_arm_4]/_se[treat_arm_4]
		scalar df4_23 = e(df_r)
		scalar pval4_23 = 2 * ttail(df4_23, abs(t_stat4_23))
		if pval4_23 < 0.01 local `depvar'_b4_23 = strtrim("`b4_23'") + "\sym{***}"
		else if pval4_23 < 0.05 local `depvar'_b4_23 = strtrim("`b4_23'") + "\sym{**}"
		else if pval4_23 < 0.1 local `depvar'_b4_23 = strtrim("`b4_23'") + "\sym{*}"
		else local `depvar'_b4_23 = strtrim("`b4_23'")
		local se4_23: display `format' _se[treat_arm_4]
		local `depvar'_se4_23 = "(" + strtrim("`se4_23'") + ")"
		
		local `depvar'obs_23: display %9.0fc e(N)
}
	

texdoc init "$output\tables\appendix\2. appendix. first stage (year-specific).tex", replace force 
	tex \begin{table}[htbp]
	tex \centering
	tex \resizebox{\linewidth}{!}{%
	tex \begin{threeparttable}
	tex \caption{\textbf{First Stage} (Year-specific)}
	tex \fontsize{10}{11}\selectfont
	tex \begin{tabular}{l*{5}c}
	tex \hline\hline
	tex &\multicolumn{1}{c}{Student login} &\multicolumn{1}{c}{At least 5 minutes} &\multicolumn{1}{c}{Number of} &\multicolumn{1}{c}{Skills} &\multicolumn{1}{c}{Familiar} \\
	tex &\multicolumn{1}{c}{} &\multicolumn{1}{c}{per week} &\multicolumn{1}{c}{minutes} &\multicolumn{1}{c}{} &\multicolumn{1}{c}{} \\
	tex &\multicolumn{1}{c}{(1)} &\multicolumn{1}{c}{(2)} &\multicolumn{1}{c}{(3)} &\multicolumn{1}{c}{(4)} &\multicolumn{1}{c}{(5)} \\

	tex \hline
	tex [1ex]
	tex \multicolumn{6}{l}{\textbf{AY 2021-2022}} \\
	tex [1ex] 
	
	tex Treatment arm 1 & `student_login_b1_22' & `takeup_b1_22' & `learn_min_b1_22' & `skills_b1_22' & `familiar_b1_22' \\
	tex & `student_login_se1_22' & `takeup_se1_22' & `learn_min_se1_22' & `skills_se1_22' & `familiar_se1_22' \\
	tex [1ex] 
	
	tex Treatment arm 2 & `student_login_b2_22' & `takeup_b2_22' & `learn_min_b2_22' & `skills_b2_22' & `familiar_b2_22' \\
	tex & `student_login_se2_22' & `takeup_se2_22' & `learn_min_se2_22' & `skills_se2_22' & `familiar_se2_22' \\
	tex [1ex] 
	
	tex Control & `student_loginc_M22' & `takeupc_M22' & `learn_minc_M22' & `skillsc_M22' & `familiarc_M22' \\
	tex & `student_loginc_SD22' & `takeupc_SD22' & `learn_minc_SD22' & `skillsc_SD22' & `familiarc_SD22' \\
	tex [1ex]
	
	tex N & `student_loginobs_22' & `takeupobs_22' & `learn_minobs_22' & `skillsobs_22' & `familiarobs_22' \\
	tex[1ex] 
	
	tex \multicolumn{6}{l}{\textbf{AY 2022-2023}} \\
	tex [1ex] 
		
	tex Treatment arm 1 & `student_login_b1_23' & `takeup_b1_23' & `learn_min_b1_23' & `skills_b1_23' & `familiar_b1_23' \\
	tex & `student_login_se1_23' & `takeup_se1_23' & `learn_min_se1_23' & `skills_se1_23' & `familiar_se1_23' \\
	tex [1ex] 
	
	tex Treatment arm 2 & `student_login_b2_23' & `takeup_b2_23' & `learn_min_b2_23' & `skills_b2_23' & `familiar_b2_23' \\
	tex & `student_login_se2_23' & `takeup_se2_23' & `learn_min_se2_23' & `skills_se2_23' & `familiar_se2_23' \\
	tex [1ex] 
	
	tex Treatment arm 3 & `student_login_b3_23' & `takeup_b3_23' & `learn_min_b3_23' & `skills_b3_23' & `familiar_b3_23' \\
	tex & `student_login_se3_23' & `takeup_se3_23' & `learn_min_se3_23' & `skills_se3_23' & `familiar_se3_23' \\
	tex [1ex] 
	
	tex Treatment arm 4 & `student_login_b4_23' & `takeup_b4_23' & `learn_min_b4_23' & `skills_b4_23' & `familiar_b4_23' \\
	tex & `student_login_se4_23' & `takeup_se4_23' & `learn_min_se4_23' & `skills_se4_23' & `familiar_se4_23' \\
	tex [1ex] 
	
	tex Control & `student_loginc_M23' & `takeupc_M23' & `learn_minc_M23' & `skillsc_M23' & `familiarc_M23' \\
	tex & `student_loginc_SD23' & `takeupc_SD23' & `learn_minc_SD23' & `skillsc_SD23' & `familiarc_SD23' \\
	tex [1ex]
		
	tex N & `student_loginobs_23' & `takeupobs_23' & `learn_minobs_23' & `skillsobs_23' & `familiarobs_23' \\
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




