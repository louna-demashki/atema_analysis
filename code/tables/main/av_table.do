//----------------------------------------------------------------------------//
// File name: AV_table
// Last updated: Apr 29, 2025
//----------------------------------------------------------------------------//

clear all
set matsize 6000
set more off 
global dir "D:\SECURE\data 2024\analysis\atema" 
global input "$dir\data" 
global output "$dir\output"

cap log close
log using "$output\Logs\tables\main\av_table.txt", text replace

use "$input\master_controls", clear 

gen control_pooled = 0
	replace control_pooled = 1 if (control==1 | treat_arm_3==1 | treat_arm_4==1) & ///
	ACADEMIC_YEAR_ID_FK==2022
	replace control_pooled = 1 if control==1 & ACADEMIC_YEAR_ID_FK==2022
	
drop if math_score==.

//============================================================================//
// First Stage
//============================================================================//
local format "%9.3fc" 

	qui: sum takeup if control_pooled == 1 
    local takeup_control: display `format' r(mean)

	reghdfe takeup atema_st atema_pe_st atema_lt atema_pe_lt, ///
	absorb(grade_21 strata) vce(clustervar school_21)

		local b1_fs: display `format' _b[atema_st]
		scalar t_stat1_fs = _b[atema_st]/_se[atema_st]
		scalar df1_fs = e(df_r)
		scalar pval1_fs = 2 * ttail(df1_fs, abs(t_stat1_fs))
		if pval1_fs < 0.01 local takeup_b1 = strtrim("`b1_fs'") + "\sym{***}"
		else if pval1_fs < 0.05 local takeup_b1 = strtrim("`b1_fs'") + "\sym{**}"
		else if pval1_fs < 0.1 local takeup_b1 = strtrim("`b1_fs'") + "\sym{*}"
		else local takeup_b1 = strtrim("`b1_fs'")
		local se1_fs: display `format' _se[atema_st]
		local takeup_se1 = "(" + strtrim("`se1_fs'") + ")"
		
		local b2_fs: display `format' _b[atema_pe_st]
		scalar t_stat2_fs = _b[atema_pe_st]/_se[atema_pe_st]
		scalar df2_fs = e(df_r)
		scalar pval2_fs = 2 * ttail(df2_fs, abs(t_stat2_fs))
		if pval2_fs < 0.01 local takeup_b2 = strtrim("`b2_fs'") + "\sym{***}"
		else if pval2_fs < 0.05 local takeup_b2 = strtrim("`b2_fs'") + "\sym{**}"
		else if pval2_fs < 0.1 local takeup_b2 = strtrim("`b2_fs'") + "\sym{*}"
		else local takeup_b2 = strtrim("`b2_fs'")
		local se2_fs: display `format' _se[atema_pe_st]
		local takeup_se2 = "(" + strtrim("`se2_fs'") + ")"
		
		local b3_fs: display `format' _b[atema_lt]
		scalar t_stat3_fs = _b[atema_lt]/_se[atema_lt]
		scalar df3_fs = e(df_r)
		scalar pval3_fs = 2 * ttail(df3_fs, abs(t_stat3_fs))
		if pval3_fs < 0.01 local takeup_b3 = strtrim("`b3_fs'") + "\sym{***}"
		else if pval3_fs < 0.05 local takeup_b3 = strtrim("`b3_fs'") + "\sym{**}"
		else if pval3_fs < 0.1 local takeup_b3 = strtrim("`b3_fs'") + "\sym{*}"
		else local takeup_b3 = strtrim("`b3_fs'")
		local se3_fs: display `format' _se[atema_lt]
		local takeup_se3 = "(" + strtrim("`se3_fs'") + ")"

		local b4_fs: display `format' _b[atema_pe_lt]
		scalar t_stat4_fs = _b[atema_pe_lt]/_se[atema_pe_lt]
		scalar df4_fs = e(df_r)
		scalar pval4_fs = 2 * ttail(df4_fs, abs(t_stat4_fs))
		if pval4_fs < 0.01 local takeup_b4 = strtrim("`b4_fs'") + "\sym{***}"
		else if pval4_fs < 0.05 local takeup_b4 = strtrim("`b4_fs'") + "\sym{**}"
		else if pval4_fs < 0.1 local takeup_b4 = strtrim("`b4_fs'") + "\sym{*}"
		else local takeup_b4 = strtrim("`b4_fs'")
		local se4_fs: display `format' _se[atema_pe_lt]
		local takeup_se4 = "(" + strtrim("`se4_fs'") + ")"
		
		local takeup_obs: display %9.0fc e(N)
		
		test atema_st = atema_pe_st
		local takeup_pval1: display `format' r(p)
		
		test atema_st = atema_lt
		local takeup_pval2: display `format' r(p)
		
		test atema_pe_st = atema_pe_lt
		local takeup_pval3: display `format' r(p)

		
		
//============================================================================//
// 2SLS
//============================================================================//

global s_controls "x_eng_21_eng_19 missing_b_eng_21 missing_b_eng_19 x_eng_21_gpa_m missing_b_GPA_mate x_eng_21_gpa_e missing_b_GPA_ingl x_eng_21_gpa_s missing_b_GPA_espa x_eng_21_sp_ed x_math_19_gpa missing_b_GPA missing_b_math_19 x_gpa_sp_ed x_gpa_m_gpa_e x_gpa_m_gpa_s x_gpa_m_income missing_b_ANNUAL_INCOME x_gpa_s_sp_ed b_eng_21 b_math_19 b_spa_19 missing_b_spa_19 b_GPA b_GPA_mate b_GPA_espa b_ANNUAL_INCOME b_special_ed b_ABSENCE_COUNT_YEAR b_gr38_avg missing_b_gr38_avg b_math_21 missing_b_math_21 missing_b_spa_21 b_eng_21_sq b_ABSENCE_COUNT_YEAR_sq"

	qui: sum math_score if control_pooled == 1
	local score_control: display `format' r(mean)
	
	ivreghdfe math_score $s_controls (takeup = atema_st atema_pe_st), ///
	absorb(grade_21 strata) cluster(school_21)
		
		local b: display `format' _b[takeup]
		scalar t_stat = _b[takeup]/_se[takeup]
		scalar df = e(df_r)
		scalar pval = 2 * ttail(df, abs(t_stat))
		if pval < 0.01 local score_b = strtrim("`b'") + "\sym{***}"
		else if pval < 0.05 local score_b = strtrim("`b'") + "\sym{**}"
		else if pval < 0.1 local score_b = strtrim("`b'") + "\sym{*}"
		else local score_b = strtrim("`b'")
		local se: display `format' _se[takeup]
		local score_se = "(" + strtrim("`se'") + ")"
						
		local score_obs: display %9.0fc e(N)
		
		// Angrist-Pischke F-stat
		ivreg2 math_score $s_controls $strata_FE $grade_FE (takeup = atema_st atema_pe_st), ///
		cluster(school_21) first 
		
		matrix list e(first)
		matrix score_fstat = e(first)
		local score_f: display `format' score_fstat[15,1]		


//============================================================================//
// DDML
//============================================================================//
		
use "$output\data\03. RFE ddml (all).dta", clear 

	qui: sum coef_all if variable == "atema_st"
	local b1: display `format' r(mean)
	qui: sum se_all if variable == "atema_st"
	local se1: display `format' r(mean) 
	local t1 = `b1' / `se1'
    local p1 = 2 * (1 - normal(abs(`t1')))
		if `p1' < 0.01 local score_b1 = strtrim("`b1'") + "\sym{***}"
		else if `p1' < 0.05 local score_b1 = strtrim("`b1'") + "\sym{**}"
		else if `p1' < 0.1 local score_b1 = strtrim("`b1'") + "\sym{*}"
		else local score_b1 = strtrim("`b1'")

	
	qui: sum coef_all if variable == "atema_pe_st"
	local b2: display `format' r(mean)
	qui: sum se_all if variable == "atema_pe_st"
	local se2: display `format' r(mean) 
	local t2 = `b2' / `se2'
    local p2 = 2 * (1 - normal(abs(`t2')))
		if `p2' < 0.01 local score_b2 = strtrim("`b2'") + "\sym{***}"
		else if `p2' < 0.05 local score_b2 = strtrim("`b2'") + "\sym{**}"
		else if `p2' < 0.1 local score_b2 = strtrim("`b2'") + "\sym{*}"
		else local score_b2 = strtrim("`b2'")

		
	qui: sum coef_all if variable == "atema_lt"
	local b3: display `format' r(mean)
	qui: sum se_all if variable == "atema_lt"
	local se3: display `format' r(mean) 
	local t3 = `b3' / `se3'
    local p3 = 2 * (1 - normal(abs(`t3')))
		if `p3' < 0.01 local score_b3 = strtrim("`b3'") + "\sym{***}"
		else if `p3' < 0.05 local score_b3 = strtrim("`b3'") + "\sym{**}"
		else if `p3' < 0.1 local score_b3 = strtrim("`b3'") + "\sym{*}"
		else local score_b3 = strtrim("`b3'")
	
	qui: sum coef_all if variable == "atema_pe_lt"
	local b4: display `format' r(mean)
	qui: sum se_all if variable == "atema_pe_lt"
	local se4: display `format' r(mean) 
	local t4 = `b4' / `se4'
    local p4 = 2 * (1 - normal(abs(`t4')))
		if `p4' < 0.01 local score_b4 = strtrim("`b4'") + "\sym{***}"
		else if `p4' < 0.05 local score_b4 = strtrim("`b4'") + "\sym{**}"
		else if `p4' < 0.1 local score_b4 = strtrim("`b4'") + "\sym{*}"
		else local score_b4 = strtrim("`b4'")
	
	qui: sum pval_all if variable == "Test: atema_st = atema_pe_st"
	local score_pval1: display `format' r(mean)
	
	qui: sum pval_all if variable == "Test: atema_st = atema_lt"
	local score_pval2: display `format' r(mean)
	
	qui: sum pval_all if variable == "Test: atema_pe_st = atema_pe_lt"
	local score_pval3: display `format' r(mean)
	
	
	
//============================================================================//
// Table
//============================================================================//

texdoc init "$output\tables\main\av_table", replace force

	tex \begin{table}[htbp]
	tex \centering
	tex \resizebox{\linewidth}{!}{%
	tex \begin{threeparttable}
	tex \caption{\textbf{Main Results}}
	tex \fontsize{10}{11}\selectfont
	tex \begin{tabular}{l*{3}c}
	tex \hline\hline
	tex &\multicolumn{1}{c}{First} &\multicolumn{1}{c}{DDML} &\multicolumn{1}{c}{} \\
	tex &\multicolumn{1}{c}{Stage} &\multicolumn{1}{c}{RFE} &\multicolumn{1}{c}{2SLS} \\
	tex &\multicolumn{1}{c}{(1)} &\multicolumn{1}{c}{(2)} &\multicolumn{1}{c}{(3)} \\
	tex \hline \\
	tex $\beta_1$: Treatment (short-term) & `takeup_b1' & `score_b1' &  \\
	tex & `takeup_se1' & `score_se1' &  \\
	tex [1ex]
	tex $\beta_2$: Parental engagement (short-term) & `takeup_b2' & `score_b2' &  \\
	tex & `takeup_se2' & `score_se2' &  \\
	tex [1ex]
	tex $\beta_3$: Treatment (long-term) & `takeup_b3' & `score_b3' &  \\
	tex & `takeup_se3' & `score_se3' &  \\
	tex [1ex]
	tex $\beta_4$: Parental engagement (long-term) & `takeup_b4' & `score_b4' &  \\
	tex & `takeup_se4' & `score_se4' &  \\
	tex [1ex]
	tex $\beta_5$: Treatment + Parental engagement (short-term) &  &  & `score_b' \\
	tex &  &  & `score_se' \\
	tex [1ex] 
	tex \hline \\
	tex [1ex]
	tex $H_0: \beta_1 = \beta_2$ & `takeup_pval1' & `score_pval1' &  \\
	tex [1ex]
	tex $H_0: \beta_1 = \beta_3$ & `takeup_pval2' & `score_pval2' &  \\
	tex [1ex] 
	tex $H_0: \beta_2 = \beta_4$ & `takeup_pval3' & `score_pval3' &  \\
	tex [1ex]
	tex AP F-stat &  &  & `score_f' \\
	tex [1ex] 
	tex \hline \\ 
	tex [1ex]
	tex Control mean & `takeup_control' & `score_control' & `score_control' \\
	tex N & `takeup_obs' & `score_obs' & `score_obs' \\
	tex [1ex]
	tex \hline \hline \\ 
	tex \end{tabular}
	tex \begin{tablenotes}[flushleft]
	tex \scriptsize
	tex \item
	tex \textbf{Notes:} Column (1) of this table reports the short and long-term first stage effects of take-up which is defined as 5 or more minutes of Khan Academy usage per week and being in the treatment group (eligible to enroll in the ATEMA program) and the parental engagement group (parents receiving information through email under the ATEMA program). The control group is defined as students in schools that were not eligible for enrollment in the ATEMA program. Column (2) reports the short and long-term effects of being in the Treatment or Parental engagement group on students' Math test scores. Column (3) reports the effects of take-up on students' Math test scores. Take-up is instrumented through eligibility in the ATEMA program in the short-term only. All regressions control for stratum-year and grade fixed effects and regressions in columns (2) and (3) include a set of covariates defined using the DDML procedure and post-double selections lasso, respectively, including students' baseline test scores, GPA and characteristics. Standard errors of variables are clustered at the school-level and reported in parentheses. * \(p<0.10\), ** \(p<0.05\), *** \(p<0.01\). 
	tex \end{tablenotes}
	tex \end{threeparttable}
	tex }
	tex \end{table}


texdoc close











