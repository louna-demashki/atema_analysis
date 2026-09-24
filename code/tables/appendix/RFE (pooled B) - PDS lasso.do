//----------------------------------------------------------------------------//
// File name: 3. RFE (pooled B)
// Last updated: October 25, 2024 by Sara Mostafa
//----------------------------------------------------------------------------//


clear all
set matsize 6000
set more off 
global dir "D:\SECURE\data 2024\analysis\atema" 
global input "$dir\data" 
global output "$dir\output"

cap log close
log using "$output\Logs\tables\appendix\RFE (PDS lasso).txt", text replace


use "$input\master_controls", clear 

//selected controls -- from control_selection.do
global s_controls "x_eng_21_math_19 x_eng_21_eng_19 x_eng_21_sp_ed x_eng_21_p_teach x_pov_21_gpa x_pov_21_p_teach x_math_19_gpa_e x_eng_19_gpa_s x_spa_19_gpa x_spa_19_gpa_e x_spa_19_gpa_s x_spa_19_p_teach x_gpa_sp_ed x_p_teach_e_38 b_eng_21 b_poverty_21 b_math_19 b_spa_19 b_poverty_19 b_GPA b_GPA_mate b_special_ed b_ABSENCE_COUNT_YEAR b_math_21 missing_b_math_21 missing_b_eng_21 missing_b_spa_21 missing_b_poverty_21 b_eng_21_sq missing_b_math_19 missing_b_eng_19 missing_b_GPA missing_b_GPA_ingl missing_b_GPA_espa missing_b_spa_19 missing_b_ingles_38avg missing_b_poverty_19 missing_b_GPA_mate missing_b_ABSENCE_COUNT_YEAR"



//============================================================================//
// Year-Specific 
//============================================================================//
local format "%9.3fc" 
local usage "math_score"


foreach depvar of local usage {

	summarize `depvar' if control==1 | (treat_arm_3==1 & ACADEMIC_YEAR_ID_FK==2022) | ///
	(treat_arm_4==1 & ACADEMIC_YEAR_ID_FK==2022)
    local `depvar'c_M: display `format' r(mean)
    local sd: display `format' r(sd)
    local `depvar'c_SD = "[" + strtrim("`sd'") + "]"
	
	}

 


foreach depvar of local usage {

	//all grades 
		reghdfe `depvar' atema_st atema_pe_st atema_lt atema_pe_lt $s_controls, ///
		absorb(GRADE_ID_FK strata) vce(clustervar school_21)
		
		local b1_23: display `format' _b[atema_st]
		scalar t_stat1_23 = _b[atema_st]/_se[atema_st]
		scalar df1_23 = e(df_r)
		scalar pval1_23 = 2 * ttail(df1_23, abs(t_stat1_23))
		if pval1_23 < 0.01 local `depvar'_b1_23 = strtrim("`b1_23'") + "\sym{***}"
		else if pval1_23 < 0.05 local `depvar'_b1_23 = strtrim("`b1_23'") + "\sym{**}"
		else if pval1_23 < 0.1 local `depvar'_b1_23 = strtrim("`b1_23'") + "\sym{*}"
		else local `depvar'_b1_23 = strtrim("`b1_23'")
		local se1_23: display `format' _se[atema_st]
		local `depvar'_se1_23 = "(" + strtrim("`se1_23'") + ")"
		
		local b2_23: display `format' _b[atema_pe_st]
		scalar t_stat2_23 = _b[atema_pe_st]/_se[atema_pe_st]
		scalar df2_23 = e(df_r)
		scalar pval2_23 = 2 * ttail(df2_23, abs(t_stat2_23))
		if pval2_23 < 0.01 local `depvar'_b2_23 = strtrim("`b2_23'") + "\sym{***}"
		else if pval2_23 < 0.05 local `depvar'_b2_23 = strtrim("`b2_23'") + "\sym{**}"
		else if pval2_23 < 0.1 local `depvar'_b2_23 = strtrim("`b2_23'") + "\sym{*}"
		else local `depvar'_b2_23 = strtrim("`b2_23'")
		local se2_23: display `format' _se[atema_pe_st]
		local `depvar'_se2_23 = "(" + strtrim("`se2_23'") + ")"
		
		local b3_23: display `format' _b[atema_lt]
		scalar t_stat3_23 = _b[atema_lt]/_se[atema_lt]
		scalar df3_23 = e(df_r)
		scalar pval3_23 = 2 * ttail(df3_23, abs(t_stat3_23))
		if pval3_23 < 0.01 local `depvar'_b3_23 = strtrim("`b3_23'") + "\sym{***}"
		else if pval3_23 < 0.05 local `depvar'_b3_23 = strtrim("`b3_23'") + "\sym{**}"
		else if pval3_23 < 0.1 local `depvar'_b3_23 = strtrim("`b3_23'") + "\sym{*}"
		else local `depvar'_b3_23 = strtrim("`b3_23'")
		local se3_23: display `format' _se[atema_lt]
		local `depvar'_se3_23 = "(" + strtrim("`se3_23'") + ")"

		local b4_23: display `format' _b[atema_pe_lt]
		scalar t_stat4_23 = _b[atema_pe_lt]/_se[atema_pe_lt]
		scalar df4_23 = e(df_r)
		scalar pval4_23 = 2 * ttail(df4_23, abs(t_stat4_23))
		if pval4_23 < 0.01 local `depvar'_b4_23 = strtrim("`b4_23'") + "\sym{***}"
		else if pval4_23 < 0.05 local `depvar'_b4_23 = strtrim("`b4_23'") + "\sym{**}"
		else if pval4_23 < 0.1 local `depvar'_b4_23 = strtrim("`b4_23'") + "\sym{*}"
		else local `depvar'_b4_23 = strtrim("`b4_23'")
		local se4_23: display `format' _se[atema_pe_lt]
		local `depvar'_se4_23 = "(" + strtrim("`se4_23'") + ")"
		
		local `depvar'obs_23: display %9.0fc e(N)
}


// this table includes space for ddml results which comes from another code
texdoc init "$output\tables\appendix\RFE (pooled - pds lasso).tex", replace force 
	tex \begin{table}[htbp]
	tex \centering
	tex \resizebox{\linewidth}{!}{%
	tex \begin{threeparttable}
	tex \caption{\textbf{Reduced Form Effects}}
	tex \fontsize{10}{11}\selectfont
	tex \begin{tabular}{l*{6}c}
	tex \hline\hline 
	tex &\multicolumn{2}{c}{Math} &\multicolumn{2}{c}{English} &\multicolumn{2}{c}{Spanish} \\
	tex &\multicolumn{1}{c}{PDS lasso} &\multicolumn{1}{c}{DDML} &\multicolumn{1}{c}{PDS lasso} &\multicolumn{1}{c}{DDML} &\multicolumn{1}{c}{PDS lasso} &\multicolumn{1}{c}{DDML} \\
	tex &\multicolumn{1}{c}{(1)} &\multicolumn{1}{c}{(2)} &\multicolumn{1}{c}{(3)} &\multicolumn{1}{c}{(4)} &\multicolumn{1}{c}{(5)} &\multicolumn{1}{c}{(6)} \\
	
	tex \hline \\
	tex [1ex] 
	
	tex ATEMA (Short-term) & `math_score_b1_23' &  & `eng_score_b1_23' &  & `spa_score_b1_23' &   \\
	tex & `math_score_se1_23' &  & `eng_score_se1_23' &  & `spa_score_se1_23' &  \\
	tex [1ex] 
	
	tex ATEMA + PE (Short-term) & `math_score_b2_23' &  & `eng_score_b2_23' &  & `spa_score_b2_23' &  \\
	tex & `math_score_se2_23' &  & `eng_score_se2_23' &  & `spa_score_se2_23' &  \\
	tex [1ex] 
	
	tex ATEMA (Long-term) & `math_score_b3_23' &  & `eng_score_b3_23' &  & `spa_score_b3_23' &  \\
	tex & `math_score_se3_23' &  & `eng_score_se3_23' &  & `spa_score_se3_23' &  \\
	tex [1ex] 
	
	tex ATEMA + PE (Long-term) & `math_score_b4_23' &  & `eng_score_b4_23' &  & `spa_score_b4_23' &  \\
	tex & `math_score_se4_23' &  & `eng_score_se4_23' &  & `spa_score_se4_23' &  \\
	tex [1ex] 
	
	tex Control & `math_scorec_M' &  & `eng_scorec_M' &  & `spa_scorec_M' &  \\
	tex & `math_scorec_SD' &  & `eng_scorec_SD' &  & `spa_scorec_SD' &  \\
	tex [1ex]
	
	tex \hline \\
	tex [1ex]
		
	tex N & `math_scoreobs_23' &  & `eng_scoreobs_23' &  & `spa_scoreobs_23' &  \\
	tex[1ex] 
	tex \hline
	
	tex \end{tabular}
	tex \begin{tablenotes}[para, flushleft]
	tex \scriptsize
	tex \note Robust standard errors of variables are clustered by school and reported in brackets. \sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\). Adjusted for stratum-year and grade fixed effects.  
	tex \end{tablenotes}
	tex \end{threeparttable}
	tex }
	tex \end{table}	
	
texdoc close	





