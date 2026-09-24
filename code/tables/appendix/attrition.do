clear all 
set more off

cap log close 
log using "D:\SECURE\data 2024\analysis\atema\output\Logs\attrition", replace text


use "D:\SECURE\data 2024\analysis\atema\data\master_khan_student_combined.dta", clear

replace SCHOOL_CODE = . if SCHOOL_CODE >= 100000

gen att = 1 if SCHOOL_CODE==.
	replace att = 0 if SCHOOL_CODE!=. 
	
gen m_math = 1 if math_score==. & SCHOOL_CODE!=. 
	replace m_math = 0 if math_score!=. & SCHOOL_CODE!=.
	
gen comb = 1 if (att==1 | m_math==1)
	replace comb = 0 if att==0 & m_math==0
	
local indep "att m_math comb"
local format "%9.3fc"


//============================================================================//
// GENERAL 
//============================================================================//
foreach i of local indep{
	
	reghdfe `i' treat_arm_1 treat_arm_2 treat_arm_3 treat_arm_4, ///
	absorb(strata grade_21) vce(clustervar school_21)
	
		local b1: display `format' _b[treat_arm_1]
		scalar t_stat1 = _b[treat_arm_1]/_se[treat_arm_1]
		scalar df1 = e(df_r)
		scalar pval1 = 2 * ttail(df1, abs(t_stat1))
		if pval1 < 0.01 local `i'_b1 = strtrim("`b1'") + "\sym{***}"
		else if pval1 < 0.05 local `depvar'_b1 = strtrim("`b1'") + "\sym{**}"
		else if pval1 < 0.1 local `depvar'_b1 = strtrim("`b1'") + "\sym{*}"
		else local `i'_b1 = strtrim("`b1'")
		local se1: display `format' _se[treat_arm_1]
		local `i'_se1 = "(" + strtrim("`se1'") + ")"

		local b2: display `format' _b[treat_arm_2]
		scalar t_stat2 = _b[treat_arm_2]/_se[treat_arm_2]
		scalar df2 = e(df_r)
		scalar pval2 = 2 * ttail(df2, abs(t_stat2))
		if pval2 < 0.01 local `i'_b2 = strtrim("`b2'") + "\sym{***}"
		else if pval2 < 0.05 local `i'_b2 = strtrim("`b2'") + "\sym{**}"
		else if pval2 < 0.1 local `i'_b2 = strtrim("`b2'") + "\sym{*}"
		else local `i'_b2 = strtrim("`b2'")
		local se2: display `format' _se[treat_arm_2]
		local `i'_se2 = "(" + strtrim("`se2'") + ")"
		
		local b3: display `format' _b[treat_arm_3]
		scalar t_stat3 = _b[treat_arm_3]/_se[treat_arm_3]
		scalar df3 = e(df_r)
		scalar pval3 = 2 * ttail(df3, abs(t_stat3))
		if pval3 < 0.01 local `i'_b3 = strtrim("`b3'") + "\sym{***}"
		else if pval3 < 0.05 local `i'_b3 = strtrim("`b3'") + "\sym{**}"
		else if pval3 < 0.1 local `i'_b3 = strtrim("`b3'") + "\sym{*}"
		else local `i'_b3 = strtrim("`b3'")
		local se3: display `format' _se[treat_arm_3]
		local `i'_se3 = "(" + strtrim("`se3'") + ")"
		
		local b4: display `format' _b[treat_arm_4]
		scalar t_stat4 = _b[treat_arm_4]/_se[treat_arm_4]
		scalar df4 = e(df_r)
		scalar pval4 = 2 * ttail(df4, abs(t_stat4))
		if pval4 < 0.01 local `i'_b4 = strtrim("`b4'") + "\sym{***}"
		else if pval4 < 0.05 local `i'_b4 = strtrim("`b4'") + "\sym{**}"
		else if pval4 < 0.1 local `i'_b4 = strtrim("`b4'") + "\sym{*}"
		else local `i'_b4 = strtrim("`b4'")
		local se4: display `format' _se[treat_arm_4]
		local `i'_se4 = "(" + strtrim("`se4'") + ")"
		
		local `i'_obs=e(N)
		
		qui: sum `i' if control==1 
		local `i'_b5: display `format' r(mean)
		
}


//============================================================================//
// MAY 2023
//============================================================================//
foreach i of local indep{
	
	reghdfe `i' treat_arm_1 treat_arm_2 treat_arm_3 treat_arm_4 if ///
	ACADEMIC_YEAR_ID_FK==2023, absorb(strata grade_21) vce(clustervar school_21)
	
		local b1_23: display `format' _b[treat_arm_1]
		scalar t_stat1_23 = _b[treat_arm_1]/_se[treat_arm_1]
		scalar df1_23 = e(df_r)
		scalar pval1_23 = 2 * ttail(df1_23, abs(t_stat1_23))
		if pval1_23 < 0.01 local `i'_b1_23 = strtrim("`b1_23'") + "\sym{***}"
		else if pval1_23 < 0.05 local `depvar'_b1_23 = strtrim("`b1_23'") + "\sym{**}"
		else if pval1_23 < 0.1 local `depvar'_b1_23 = strtrim("`b1_23'") + "\sym{*}"
		else local `i'_b1_23 = strtrim("`b1_23'")
		local se1_23: display `format' _se[treat_arm_1]
		local `i'_se1_23 = "(" + strtrim("`se1_23'") + ")"

		local b2_23: display `format' _b[treat_arm_2]
		scalar t_stat2_23 = _b[treat_arm_2]/_se[treat_arm_2]
		scalar df2_23 = e(df_r)
		scalar pval2_23 = 2 * ttail(df2_23, abs(t_stat2_23))
		if pval2_23 < 0.01 local `i'_b2_23 = strtrim("`b2_23'") + "\sym{***}"
		else if pval2_23 < 0.05 local `i'_b2_23 = strtrim("`b2_23'") + "\sym{**}"
		else if pval2_23 < 0.1 local `i'_b2_23 = strtrim("`b2_23'") + "\sym{*}"
		else local `i'_b2_23 = strtrim("`b2_23'")
		local se2_23: display `format' _se[treat_arm_2]
		local `i'_se2_23 = "(" + strtrim("`se2_23'") + ")"
		
		local b3_23: display `format' _b[treat_arm_3]
		scalar t_stat3_23 = _b[treat_arm_3]/_se[treat_arm_3]
		scalar df3_23 = e(df_r)
		scalar pval3_23 = 2 * ttail(df3_23, abs(t_stat3_23))
		if pval3_23 < 0.01 local `i'_b3_23 = strtrim("`b3_23'") + "\sym{***}"
		else if pval3_23 < 0.05 local `i'_b3_23 = strtrim("`b3_23'") + "\sym{**}"
		else if pval3_23 < 0.1 local `i'_b3_23 = strtrim("`b3_23'") + "\sym{*}"
		else local `i'_b3_23 = strtrim("`b3_23'")
		local se3_23: display `format' _se[treat_arm_3]
		local `i'_se3_23 = "(" + strtrim("`se3_23'") + ")"
		
		local b4_23: display `format' _b[treat_arm_4]
		scalar t_stat4_23 = _b[treat_arm_4]/_se[treat_arm_4]
		scalar df4_23 = e(df_r)
		scalar pval4_23 = 2 * ttail(df4_23, abs(t_stat4_23))
		if pval4_23 < 0.01 local `i'_b4_23 = strtrim("`b4_23'") + "\sym{***}"
		else if pval4_23 < 0.05 local `i'_b4_23 = strtrim("`b4_23'") + "\sym{**}"
		else if pval4_23 < 0.1 local `i'_b4_23 = strtrim("`b4_23'") + "\sym{*}"
		else local `i'_b4_23 = strtrim("`b4_23'")
		local se4_23: display `format' _se[treat_arm_4]
		local `i'_se4_23 = "(" + strtrim("`se4_23'") + ")"
		
		local `i'_obs_23=e(N)
		
		qui: sum `i' if control==1 & ACADEMIC_YEAR_ID_FK==2023
		local `i'_b5_23: display `format' r(mean)
}



//============================================================================//
// MAY 2022
//============================================================================//

foreach i of local indep{
	
	reghdfe `i' treat_arm_1 treat_arm_2 treat_arm_3 treat_arm_4 ///
	if ACADEMIC_YEAR_ID_FK==2022, absorb(strata grade_21) vce(clustervar school_21)
	
		local b1_22: display `format' _b[treat_arm_1]
		scalar t_stat1_22 = _b[treat_arm_1]/_se[treat_arm_1]
		scalar df1_22 = e(df_r)
		scalar pval1_22 = 2 * ttail(df1_22, abs(t_stat1_22))
		if pval1_22 < 0.01 local `i'_b1_22 = strtrim("`b1_22'") + "\sym{***}"
		else if pval1_22 < 0.05 local `depvar'_b1_22 = strtrim("`b1_22'") + "\sym{**}"
		else if pval1_22 < 0.1 local `depvar'_b1_22 = strtrim("`b1_22'") + "\sym{*}"
		else local `i'_b1_22 = strtrim("`b1_22'")
		local se1_22: display `format' _se[treat_arm_1]
		local `i'_se1_22 = "(" + strtrim("`se1_22'") + ")"

		local b2_22: display `format' _b[treat_arm_2]
		scalar t_stat2_22 = _b[treat_arm_2]/_se[treat_arm_2]
		scalar df2_22 = e(df_r)
		scalar pval2_22 = 2 * ttail(df2_22, abs(t_stat2_22))
		if pval2_22 < 0.01 local `i'_b2_22 = strtrim("`b2_22'") + "\sym{***}"
		else if pval2_22 < 0.05 local `i'_b2_22 = strtrim("`b2_22'") + "\sym{**}"
		else if pval2_22 < 0.1 local `i'_b2_22 = strtrim("`b2_22'") + "\sym{*}"
		else local `i'_b2_22 = strtrim("`b2_22'")
		local se2_22: display `format' _se[treat_arm_2]
		local `i'_se2_22 = "(" + strtrim("`se2_22'") + ")"
		
		local b3_22: display `format' _b[treat_arm_3]
		scalar t_stat3_22 = _b[treat_arm_3]/_se[treat_arm_3]
		scalar df3_22 = e(df_r)
		scalar pval3_22 = 2 * ttail(df3_22, abs(t_stat3_22))
		if pval3_22 < 0.01 local `i'_b3_22 = strtrim("`b3_22'") + "\sym{***}"
		else if pval3_22 < 0.05 local `i'_b3_22 = strtrim("`b3_22'") + "\sym{**}"
		else if pval3_22 < 0.1 local `i'_b3_22 = strtrim("`b3_22'") + "\sym{*}"
		else local `i'_b3_22 = strtrim("`b3_22'")
		local se3_22: display `format' _se[treat_arm_3]
		local `i'_se3_22 = "(" + strtrim("`se3_22'") + ")"
		
		local b4_22: display `format' _b[treat_arm_4]
		scalar t_stat4_22 = _b[treat_arm_4]/_se[treat_arm_4]
		scalar df4_22 = e(df_r)
		scalar pval4_22 = 2 * ttail(df4_22, abs(t_stat4_22))
		if pval4_22 < 0.01 local `i'_b4_22 = strtrim("`b4_22'") + "\sym{***}"
		else if pval4_22 < 0.05 local `i'_b4_22 = strtrim("`b4_22'") + "\sym{**}"
		else if pval4_22 < 0.1 local `i'_b4_22 = strtrim("`b4_22'") + "\sym{*}"
		else local `i'_b4_22 = strtrim("`b4_22'")
		local se4_22: display `format' _se[treat_arm_4]
		local `i'_se4_22 = "(" + strtrim("`se4_22'") + ")"
		
		local `i'_obs_22=e(N)
		
		qui: sum `i' if control==1 & ACADEMIC_YEAR_ID_FK==2022
		local `i'_b5_22: display `format' r(mean)
}





texdoc init "D:\SECURE\data 2024\analysis\atema\output\\tables\appendix\attrition.tex", replace force 

	tex \begin{table}[htbp]
	tex \centering
	tex \resizebox{\linewidth}{!}{%
	tex \begin{threeparttable}
	tex \caption{\textbf{Pooled Attrition}}
	tex \fontsize{10}{11}\selectfont
	tex \begin{tabular}{l*{3}c}
	tex \hline\hline
	tex &\multicolumn{1}{c}{Not matched} &\multicolumn{1}{c}{Missing} &\multicolumn{1}{c}{}  \\
	tex &\multicolumn{1}{c}{with data} &\multicolumn{1}{c}{Math score} &\multicolumn{1}{c}{Combined}  \\
	tex &\multicolumn{1}{c}{(1)} &\multicolumn{1}{c}{(2)} &\multicolumn{1}{c}{(3)} \\
	tex \hline \\
	tex[1ex] 
	tex \multicolumn{4}{l}{\textbf{Assignment in September 2021}} \\
	tex[1ex] 
	
	tex \multicolumn{4}{l}{\textit{Panel A: Pooled May 2022 and May 2023}} \\
	tex Treatment arm 1 & `att_b1' & `m_math_b1' & `comb_b1' \\
	tex & `att_se1' & `m_math_se1' & `comb_se1' \\
	tex [1ex]
	
	tex Treatment arm 2 & `att_b2' & `m_math_b2' & `comb_b2' \\
	tex & `att_se2' & `m_math_se2' & `comb_se2' \\
	tex [1ex]
	
	tex Treatment arm 3 & `att_b3' & `m_math_b3' & `comb_b3' \\
	tex & `att_se3' & `m_math_se3' & `comb_se3' \\
	tex [1ex]
	
	tex Treatment arm 4 & `att_b4' & `m_math_b4' & `comb_b4' \\
	tex & `att_se4' & `m_math_se4' & `comb_se4' \\
	tex [1ex]
	
	tex &&&& \\
	
	tex Control mean & `att_b5' & `m_math_b5' & `comb_b5' \\
	tex[1ex] 
	
	tex N & `att_obs' & `m_math_obs' & `comb_obs' \\
	tex[1ex]
	
	tex \hline \\
	tex[1ex] 
	
	tex \multicolumn{4}{l}{\textit{Panel B: May 2022}} \\
	tex Treatment arm 1 & `att_b1_22' & `m_math_b1_22' & `comb_b1_22' \\
	tex & `att_se1_22' & `m_math_se1_22' & `comb_se1_22' \\
	tex [1ex]
	
	tex Treatment arm 2 & `att_b2_22' & `m_math_b2_22' & `comb_b2_22' \\
	tex & `att_se2_22' & `m_math_se2_22' & `comb_se2_22' \\
	tex [1ex]
	
	tex Treatment arm 3 & `att_b3_22' & `m_math_b3_22' & `comb_b3_22' \\
	tex & `att_se3_22' & `m_math_se3_22' & `comb_se3_22' \\
	tex [1ex]
	
	tex Treatment arm 4 & `att_b4_22' & `m_math_b4_22' & `comb_b4_22' \\
	tex & `att_se4_22' & `m_math_se4_22' & `comb_se4_22' \\
	tex [1ex]
	
	tex &&&& \\
	
	tex Control mean & `att_b5_22' & `m_math_b5_22' & `comb_b5_22' \\
	tex[1ex] 
	
	tex N & `att_obs_22' & `m_math_obs_22' & `comb_obs_22' \\
	tex[1ex]

	tex \hline \\
	tex[1ex] 
	
	tex \multicolumn{4}{l}{\textit{Panel C: May 2023}} \\
	tex Treatment arm 1 & `att_b1_23' & `m_math_b1_23' & `comb_b1_23' \\
	tex & `att_se1_23' & `m_math_se1_23' & `comb_se1_23' \\
	tex [1ex]
	
	tex Treatment arm 2 & `att_b2_23' & `m_math_b2_23' & `comb_b2_23' \\
	tex & `att_se2_23' & `m_math_se2_23' & `comb_se3_23' \\
	tex [1ex]
	
	tex Treatment arm 3 & `att_b3_23' & `m_math_b3_23' & `comb_b3_23' \\
	tex & `att_se3_23' & `m_math_se3_23' & `comb_se3_23' \\
	tex [1ex]
	
	tex Treatment arm 4 & `att_b4_23' & `m_math_b4_23' & `comb_b4_23' \\
	tex & `att_se4_23' & `m_math_se4_23' & `comb_se4_23' \\
	tex [1ex]
	
	tex &&&& \\
	
	tex Control mean & `att_b5_23' & `m_math_b5_23' & `comb_b5_23' \\
	tex[1ex] 
	
	tex N & `att_obs_23' & `m_math_obs_23' & `comb_obs_23' \\
	tex[1ex]

	tex \hline \hline
	tex \end{tabular}
	tex \end{threeparttable}
	tex }
	tex \end{table}

	
texdoc close	












