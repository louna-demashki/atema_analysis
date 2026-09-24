//----------------------------------------------------------------------------//
// File name: AV_table
// Last updated: May 2, 2025
//----------------------------------------------------------------------------//

clear all
set matsize 6000
set more off 
global dir "D:\SECURE\data 2024\analysis\atema" 
global input "$dir\data" 
global output "$dir\output"

cap log close
log using "$output\Logs\tables\main\av_table_2sls.txt", text replace

use "$input\master_controls", clear 

gen control_pooled = 0
	replace control_pooled = 1 if (control==1 | treat_arm_3==1 | treat_arm_4==1) & ///
	ACADEMIC_YEAR_ID_FK==2022
	replace control_pooled = 1 if control==1 & ACADEMIC_YEAR_ID_FK==2022
	
drop if math_score==.

// Keeping only short-term outcomes
drop if atema_lt == 1 | atema_pe_lt == 1
	
	
// FE dummy variables
	// strata FE 
		global strata_FE " "
		forvalues i = 1/84 {
			global strata_FE "$strata_FE strata`i'" 
		}
	
	global grade_FE "grade3 grade4 grade5 grade6 grade7 grade8"



//============================================================================//
// 2SLS + First Stage
//============================================================================//

local format "%9.3fc" 
global controls_1 "b_math_21 missing_b_math_21 gender b_special_ed"
global controls_2 "b_math_21 missing_b_math_21 gender b_special_ed b_math_19 missing_b_math_19"
global controls_3 "b_math_21 missing_b_math_21 gender b_special_ed b_math_19 missing_b_math_19 b_spa_19 missing_b_spa_19 missing_b_spa_21 b_eng_21 b_eng_21_sq missing_b_eng_21 missing_b_eng_19"
global controls_4 "b_math_21 missing_b_math_21 gender b_special_ed b_math_19 missing_b_math_19 b_spa_19 missing_b_spa_19 missing_b_spa_21 b_eng_21 b_eng_21_sq missing_b_eng_21 missing_b_eng_19 b_GPA missing_b_GPA"
global controls_5 "b_math_21 missing_b_math_21 gender b_special_ed b_math_19 missing_b_math_19 b_spa_19 missing_b_spa_19 missing_b_spa_21 b_eng_21 b_eng_21_sq missing_b_eng_21 missing_b_eng_19 b_GPA missing_b_GPA b_GPA_mate missing_b_GPA_mate b_GPA_espa missing_b_GPA_espa missing_b_GPA_ingl b_ABSENCE_COUNT_YEAR b_ABSENCE_COUNT_YEAR_sq b_ANNUAL_INCOME missing_b_ANNUAL_INCOME"
global controls_6 "b_math_21 missing_b_math_21 gender b_special_ed b_math_19 missing_b_math_19 b_spa_19 missing_b_spa_19 missing_b_spa_21 b_eng_21 b_eng_21_sq missing_b_eng_21 missing_b_eng_19 b_GPA missing_b_GPA b_GPA_mate missing_b_GPA_mate b_GPA_espa missing_b_GPA_espa missing_b_GPA_ingl b_ABSENCE_COUNT_YEAR b_ABSENCE_COUNT_YEAR_sq b_ANNUAL_INCOME missing_b_ANNUAL_INCOME b_gr38_avg missing_b_gr38_avg"
global controls_7 "b_math_21 missing_b_math_21 gender b_special_ed b_math_19 missing_b_math_19 b_spa_19 missing_b_spa_19 missing_b_spa_21 b_eng_21 b_eng_21_sq missing_b_eng_21 missing_b_eng_19 b_GPA missing_b_GPA b_GPA_mate missing_b_GPA_mate b_GPA_espa missing_b_GPA_espa missing_b_GPA_ingl b_ABSENCE_COUNT_YEAR b_ABSENCE_COUNT_YEAR_sq b_ANNUAL_INCOME missing_b_ANNUAL_INCOME b_gr38_avg missing_b_gr38_avg x_math_19_gpa x_eng_21_gpa_m x_eng_21_eng_19 x_eng_21_gpa_e x_eng_21_gpa_s x_eng_21_sp_ed x_gpa_m_gpa_s x_gpa_m_gpa_e x_gpa_m_income x_gpa_s_sp_ed x_gpa_sp_ed"
	
	qui: sum takeup if control_pooled == 1 
    local takeup_control: display `format' r(mean)

	qui: sum math_score if control_pooled == 1
	local math_score_control: display `format' r(mean)
	
	
	// Model 1
	ivreg2 math_score $controls_1 $strata_FE $grade_FE (takeup = atema_st atema_pe_st), ///
	first savefirst cluster(school_21)

		local b1: display `format' _b[takeup]
		scalar t_stat1 = _b[takeup]/_se[takeup]
		scalar df1 = e(df_r)
		scalar pval1 = 2 * ttail(df1, abs(t_stat1))
		if pval1 < 0.01 local math_score_b1 = strtrim("`b1'") + "\sym{***}"
		else if pval1 < 0.05 local math_score_b1 = strtrim("`b1'") + "\sym{**}"
		else if pval1 < 0.1 local math_score_b1 = strtrim("`b1'") + "\sym{*}"
		else local math_score_b1 = strtrim("`b1'")
		local se1: display `format' _se[takeup]
		local math_score_se1 = "(" + strtrim("`se1'") + ")"
		
	estimates dir
	estimates restore _ivreg2_takeup
	
		local b1_1: display `format' _b[atema_st] 
		scalar t_stat1_1 = _b[atema_st]/_se[atema_st]
		scalar df1_1 = e(df_r)
		scalar pval1_1 = 2 * ttail(df1_1, abs(t_stat1_1))
		if pval1_1 <0.01 local takeup_b1_1 = strtrim("`b1_1'") + "\sym{***}"
		else if pval1_1 <0.05 local takeup_b1_1 = strtrim("`b1_1'") + "\sym{**}"
		else if pval1_1 <0.1 local takeup_b1_1 = strtrim("`b1_1'") + "\sym{*}"
		else local takeup_b1_1 = strtrim("`b1_1'")
		local se1_1: display `format' _se[atema_st]
		local takeup_se1_1 = "(" + strtrim("`se1_1'") + ")" 
		
		local b2_1: display `format' _b[atema_pe_st] 
		scalar t_stat2_1 = _b[atema_pe_st]/_se[atema_pe_st]
		scalar df2_1 = e(df_r)
		scalar pval2_1 = 2 * ttail(df2_1, abs(t_stat2_1))
		if pval2_1 <0.01 local takeup_b2_1 = strtrim("`b2_1'") + "\sym{***}"
		else if pval2_1 <0.05 local takeup_b2_1 = strtrim("`b2_1'") + "\sym{**}"
		else if pval2_1 <0.1 local takeup_b2_1 = strtrim("`b2_1'") + "\sym{*}"
		else local takeup_b2_1 = strtrim("`b2_1'")
		local se2_1: display `format' _se[atema_pe_st]
		local takeup_se2_1 = "(" + strtrim("`se2_1'") + ")" 
								
		local math_score_obs1: display %9.0fc e(N)
		
	
	// Model 2
	ivreg2 math_score $controls_2 $strata_FE $grade_FE (takeup = atema_st atema_pe_st), ///
	first savefirst cluster(school_21)
		
		local b2: display `format' _b[takeup]
		scalar t_stat2 = _b[takeup]/_se[takeup]
		scalar df2 = e(df_r)
		scalar pval2 = 2 * ttail(df2, abs(t_stat2))
		if pval2 < 0.01 local math_score_b2 = strtrim("`b2'") + "\sym{***}"
		else if pval2 < 0.05 local math_score_b2 = strtrim("`b2'") + "\sym{**}"
		else if pval2 < 0.1 local math_score_b2 = strtrim("`b2'") + "\sym{*}"
		else local math_score_b2 = strtrim("`b2'")
		local se2: display `format' _se[takeup]
		local math_score_se2 = "(" + strtrim("`se2'") + ")"
		
	estimates dir
	estimates restore _ivreg2_takeup
	
		local b1_2: display `format' _b[atema_st] 
		scalar t_stat1_2 = _b[atema_st]/_se[atema_st]
		scalar df1_2 = e(df_r)
		scalar pval1_2 = 2 * ttail(df1_2, abs(t_stat1_2))
		if pval1_2 <0.01 local takeup_b1_2 = strtrim("`b1_2'") + "\sym{***}"
		else if pval1_2 <0.05 local takeup_b1_2 = strtrim("`b1_2'") + "\sym{**}"
		else if pval1_2 <0.1 local takeup_b1_2 = strtrim("`b1_2'") + "\sym{*}"
		else local takeup_b1_2 = strtrim("`b1_2'")
		local se1_2: display `format' _se[atema_st]
		local takeup_se1_2 = "(" + strtrim("`se1_2'") + ")" 
		
		local b2_2: display `format' _b[atema_pe_st] 
		scalar t_stat2_2 = _b[atema_pe_st]/_se[atema_pe_st]
		scalar df2_2 = e(df_r)
		scalar pval2_2 = 2 * ttail(df2_2, abs(t_stat2_2))
		if pval2_2 <0.01 local takeup_b2_2 = strtrim("`b2_2'") + "\sym{***}"
		else if pval2_2 <0.05 local takeup_b2_2 = strtrim("`b2_2'") + "\sym{**}"
		else if pval2_2 <0.1 local takeup_b2_2 = strtrim("`b2_2'") + "\sym{*}"
		else local takeup_b2_2 = strtrim("`b2_2'")
		local se2_2: display `format' _se[atema_pe_st]
		local takeup_se2_2 = "(" + strtrim("`se2_2'") + ")" 
						
		local math_score_obs2: display %9.0fc e(N)
		
		
	// Model 3
	ivreg2 math_score $controls_3 $strata_FE $grade_FE (takeup = atema_st atema_pe_st), ///
	first savefirst cluster(school_21)
		
		local b3: display `format' _b[takeup]
		scalar t_stat3 = _b[takeup]/_se[takeup]
		scalar df3 = e(df_r)
		scalar pval3 = 2 * ttail(df3, abs(t_stat3))
		if pval3 < 0.01 local math_score_b3 = strtrim("`b3'") + "\sym{***}"
		else if pval3 < 0.05 local math_score_b3 = strtrim("`b3'") + "\sym{**}"
		else if pval3 < 0.1 local math_score_b3 = strtrim("`b3'") + "\sym{*}"
		else local math_score_b3 = strtrim("`b3'")
		local se3: display `format' _se[takeup]
		local math_score_se3 = "(" + strtrim("`se3'") + ")"
		
	estimates dir
	estimates restore _ivreg2_takeup
	
		local b1_3: display `format' _b[atema_st] 
		scalar t_stat1_3 = _b[atema_st]/_se[atema_st]
		scalar df1_3 = e(df_r)
		scalar pval1_3 = 2 * ttail(df1_3, abs(t_stat1_3))
		if pval1_3 <0.01 local takeup_b1_3 = strtrim("`b1_3'") + "\sym{***}"
		else if pval1_3 <0.05 local takeup_b1_3 = strtrim("`b1_3'") + "\sym{**}"
		else if pval1_3 <0.1 local takeup_b1_3 = strtrim("`b1_3'") + "\sym{*}"
		else local takeup_b1_3 = strtrim("`b1_3'")
		local se1_3: display `format' _se[atema_st]
		local takeup_se1_3 = "(" + strtrim("`se1_3'") + ")" 
		
		local b2_3: display `format' _b[atema_pe_st] 
		scalar t_stat2_3 = _b[atema_pe_st]/_se[atema_pe_st]
		scalar df2_3 = e(df_r)
		scalar pval2_3 = 2 * ttail(df2_3, abs(t_stat2_3))
		if pval2_3 <0.01 local takeup_b2_3 = strtrim("`b2_3'") + "\sym{***}"
		else if pval2_3 <0.05 local takeup_b2_3 = strtrim("`b2_3'") + "\sym{**}"
		else if pval2_3 <0.1 local takeup_b2_3 = strtrim("`b2_3'") + "\sym{*}"
		else local takeup_b2_3 = strtrim("`b2_3'")
		local se2_3: display `format' _se[atema_pe_st]
		local takeup_se2_3 = "(" + strtrim("`se2_3'") + ")" 
						
		local math_score_obs3: display %9.0fc e(N)
		
		
	// Model 4
	ivreg2 math_score $controls_4 $strata_FE $grade_FE (takeup = atema_st atema_pe_st), ///
	first savefirst cluster(school_21)
		
		local b4: display `format' _b[takeup]
		scalar t_stat4 = _b[takeup]/_se[takeup]
		scalar df4 = e(df_r)
		scalar pval4 = 2 * ttail(df4, abs(t_stat4))
		if pval4 < 0.01 local math_score_b4 = strtrim("`b4'") + "\sym{***}"
		else if pval4 < 0.05 local math_score_b4 = strtrim("`b4'") + "\sym{**}"
		else if pval4 < 0.1 local math_score_b4 = strtrim("`b4'") + "\sym{*}"
		else local math_score_b4 = strtrim("`b4'")
		local se4: display `format' _se[takeup]
		local math_score_se4 = "(" + strtrim("`se4'") + ")"
		
	estimates dir
	estimates restore _ivreg2_takeup
	
		local b1_4: display `format' _b[atema_st] 
		scalar t_stat1_4 = _b[atema_st]/_se[atema_st]
		scalar df1_4 = e(df_r)
		scalar pval1_4 = 2 * ttail(df1_4, abs(t_stat1_4))
		if pval1_4 <0.01 local takeup_b1_4 = strtrim("`b1_4'") + "\sym{***}"
		else if pval1_4 <0.05 local takeup_b1_4 = strtrim("`b1_4'") + "\sym{**}"
		else if pval1_4 <0.1 local takeup_b1_4 = strtrim("`b1_4'") + "\sym{*}"
		else local takeup_b1_4 = strtrim("`b1_4'")
		local se1_4: display `format' _se[atema_st]
		local takeup_se1_4 = "(" + strtrim("`se1_4'") + ")" 
		
		local b2_4: display `format' _b[atema_pe_st] 
		scalar t_stat2_4 = _b[atema_pe_st]/_se[atema_pe_st]
		scalar df2_4 = e(df_r)
		scalar pval2_4 = 2 * ttail(df2_4, abs(t_stat2_4))
		if pval2_4 <0.01 local takeup_b2_4 = strtrim("`b2_4'") + "\sym{***}"
		else if pval2_4 <0.05 local takeup_b2_4 = strtrim("`b2_4'") + "\sym{**}"
		else if pval2_4 <0.1 local takeup_b2_4 = strtrim("`b2_4'") + "\sym{*}"
		else local takeup_b2_4 = strtrim("`b2_4'")
		local se2_4: display `format' _se[atema_pe_st]
		local takeup_se2_4 = "(" + strtrim("`se2_4'") + ")" 
						
		local math_score_obs4: display %9.0fc e(N)
		
				
	// Model 5
	ivreg2 math_score $controls_5 $strata_FE $grade_FE (takeup = atema_st atema_pe_st), ///
	first savefirst cluster(school_21)
		
		local b5: display `format' _b[takeup]
		scalar t_stat5 = _b[takeup]/_se[takeup]
		scalar df5 = e(df_r)
		scalar pval5 = 2 * ttail(df5, abs(t_stat5))
		if pval5 < 0.01 local math_score_b5 = strtrim("`b5'") + "\sym{***}"
		else if pval5 < 0.05 local math_score_b5 = strtrim("`b5'") + "\sym{**}"
		else if pval5 < 0.1 local math_score_b5 = strtrim("`b5'") + "\sym{*}"
		else local math_score_b5 = strtrim("`b5'")
		local se5: display `format' _se[takeup]
		local math_score_se5 = "(" + strtrim("`se5'") + ")"
		
	estimates dir
	estimates restore _ivreg2_takeup
	
		local b1_5: display `format' _b[atema_st] 
		scalar t_stat1_5 = _b[atema_st]/_se[atema_st]
		scalar df1_5 = e(df_r)
		scalar pval1_5 = 2 * ttail(df1_5, abs(t_stat1_5))
		if pval1_5 <0.01 local takeup_b1_5 = strtrim("`b1_5'") + "\sym{***}"
		else if pval1_5 <0.05 local takeup_b1_5 = strtrim("`b1_5'") + "\sym{**}"
		else if pval1_5 <0.1 local takeup_b1_5 = strtrim("`b1_5'") + "\sym{*}"
		else local takeup_b1_5 = strtrim("`b1_5'")
		local se1_5: display `format' _se[atema_st]
		local takeup_se1_5 = "(" + strtrim("`se1_5'") + ")" 
		
		local b2_5: display `format' _b[atema_pe_st] 
		scalar t_stat2_5 = _b[atema_pe_st]/_se[atema_pe_st]
		scalar df2_5 = e(df_r)
		scalar pval2_5 = 2 * ttail(df2_5, abs(t_stat2_5))
		if pval2_5 <0.01 local takeup_b2_5 = strtrim("`b2_5'") + "\sym{***}"
		else if pval2_5 <0.05 local takeup_b2_5 = strtrim("`b2_5'") + "\sym{**}"
		else if pval2_5 <0.1 local takeup_b2_5 = strtrim("`b2_5'") + "\sym{*}"
		else local takeup_b2_5 = strtrim("`b2_5'")
		local se2_5: display `format' _se[atema_pe_st]
		local takeup_se2_5 = "(" + strtrim("`se2_5'") + ")" 
						
		local math_score_obs5: display %9.0fc e(N)
		
		
	// Model 6
	ivreg2 math_score $controls_6 $strata_FE $grade_FE (takeup = atema_st atema_pe_st), ///
	first savefirst cluster(school_21)
		
		local b6: display `format' _b[takeup]
		scalar t_stat6 = _b[takeup]/_se[takeup]
		scalar df6 = e(df_r)
		scalar pval6 = 2 * ttail(df6, abs(t_stat6))
		if pval6 < 0.01 local math_score_b6 = strtrim("`b6'") + "\sym{***}"
		else if pval6 < 0.05 local math_score_b6 = strtrim("`b6'") + "\sym{**}"
		else if pval6 < 0.1 local math_score_b6 = strtrim("`b6'") + "\sym{*}"
		else local math_score_b6 = strtrim("`b6'")
		local se6: display `format' _se[takeup]
		local math_score_se6 = "(" + strtrim("`se6'") + ")"
		
	estimates dir
	estimates restore _ivreg2_takeup
	
		local b1_6: display `format' _b[atema_st] 
		scalar t_stat1_6 = _b[atema_st]/_se[atema_st]
		scalar df1_6 = e(df_r)
		scalar pval1_6 = 2 * ttail(df1_6, abs(t_stat1_6))
		if pval1_6 <0.01 local takeup_b1_6 = strtrim("`b1_6'") + "\sym{***}"
		else if pval1_6 <0.05 local takeup_b1_6 = strtrim("`b1_6'") + "\sym{**}"
		else if pval1_6 <0.1 local takeup_b1_6 = strtrim("`b1_6'") + "\sym{*}"
		else local takeup_b1_6 = strtrim("`b1_6'")
		local se1_6: display `format' _se[atema_st]
		local takeup_se1_6 = "(" + strtrim("`se1_6'") + ")" 
		
		local b2_6: display `format' _b[atema_pe_st] 
		scalar t_stat2_6 = _b[atema_pe_st]/_se[atema_pe_st]
		scalar df2_6 = e(df_r)
		scalar pval2_6 = 2 * ttail(df2_6, abs(t_stat2_6))
		if pval2_6 <0.01 local takeup_b2_6 = strtrim("`b2_6'") + "\sym{***}"
		else if pval2_6 <0.05 local takeup_b2_6 = strtrim("`b2_6'") + "\sym{**}"
		else if pval2_6 <0.1 local takeup_b2_6 = strtrim("`b2_6'") + "\sym{*}"
		else local takeup_b2_6 = strtrim("`b2_6'")
		local se2_6: display `format' _se[atema_pe_st]
		local takeup_se2_6 = "(" + strtrim("`se2_6'") + ")" 
						
		local math_score_obs6: display %9.0fc e(N)
		
		
	// Model 7
	ivreg2 math_score $controls_7 $strata_FE $grade_FE (takeup = atema_st atema_pe_st), ///
	first savefirst cluster(school_21)
		
		local b7: display `format' _b[takeup]
		scalar t_stat7 = _b[takeup]/_se[takeup]
		scalar df7 = e(df_r)
		scalar pval7 = 2 * ttail(df7, abs(t_stat7))
		if pval7 < 0.01 local math_score_b7 = strtrim("`b7'") + "\sym{***}"
		else if pval7 < 0.05 local math_score_b7 = strtrim("`b7'") + "\sym{**}"
		else if pval7 < 0.1 local math_score_b7 = strtrim("`b7'") + "\sym{*}"
		else local math_score_b7 = strtrim("`b7'")
		local se7: display `format' _se[takeup]
		local math_score_se7 = "(" + strtrim("`se7'") + ")"
		
	estimates dir
	estimates restore _ivreg2_takeup
	
		local b1_7: display `format' _b[atema_st] 
		scalar t_stat1_7 = _b[atema_st]/_se[atema_st]
		scalar df1_7 = e(df_r)
		scalar pval1_7 = 2 * ttail(df1_7, abs(t_stat1_7))
		if pval1_7 <0.01 local takeup_b1_7 = strtrim("`b1_7'") + "\sym{***}"
		else if pval1_7 <0.05 local takeup_b1_7 = strtrim("`b1_7'") + "\sym{**}"
		else if pval1_7 <0.1 local takeup_b1_7 = strtrim("`b1_7'") + "\sym{*}"
		else local takeup_b1_7 = strtrim("`b1_7'")
		local se1_7: display `format' _se[atema_st]
		local takeup_se1_7 = "(" + strtrim("`se1_7'") + ")" 
		
		local b2_7: display `format' _b[atema_pe_st] 
		scalar t_stat2_7 = _b[atema_pe_st]/_se[atema_pe_st]
		scalar df2_7 = e(df_r)
		scalar pval2_7 = 2 * ttail(df2_7, abs(t_stat2_7))
		if pval2_7 <0.01 local takeup_b2_7 = strtrim("`b2_7'") + "\sym{***}"
		else if pval2_7 <0.05 local takeup_b2_7 = strtrim("`b2_7'") + "\sym{**}"
		else if pval2_7 <0.1 local takeup_b2_7 = strtrim("`b2_7'") + "\sym{*}"
		else local takeup_b2_7 = strtrim("`b2_7'")
		local se2_7: display `format' _se[atema_pe_st]
		local takeup_se2_7 = "(" + strtrim("`se2_7'") + ")" 
						
		local math_score_obs7: display %9.0fc e(N)
	
	
	
//============================================================================//
// Table
//============================================================================//

texdoc init "$output\tables\main\av_table_2sls", replace force

	tex \begin{table}[htbp]
	tex \centering
	tex \resizebox{\linewidth}{!}{%
	tex \begin{threeparttable}
	tex \caption{\textbf{2SLS Effect of Take-up on Math Scores}}
	tex \fontsize{10}{11}\selectfont
	tex \begin{tabular}{l*{7}c}
	tex \hline\hline
	tex &\multicolumn{1}{c}{Model 1} &\multicolumn{1}{c}{Model 2} &\multicolumn{1}{c}{Model 3} &\multicolumn{1}{c}{Model 4} &\multicolumn{1}{c}{Model 5} &\multicolumn{1}{c}{Model 6} &\multicolumn{1}{c}{Model 7}\\
	tex &\multicolumn{1}{c}{(1)} &\multicolumn{1}{c}{(2)} &\multicolumn{1}{c}{(3)} &\multicolumn{1}{c}{(4)} &\multicolumn{1}{c}{(5)} &\multicolumn{1}{c}{(6)} &\multicolumn{1}{c}{(7)} \\
	tex \hline \\
	tex Take-up (Treatment) & `takeup_b1_1' & `takeup_b1_2' & `takeup_b1_3' & `takeup_b1_4' & `takeup_b1_5' & `takeup_b1_6' & `takeup_b1_7' \\
	tex & `takeup_se1_1' & `takeup_se1_2' & `takeup_se1_3' & `takeup_se1_4' & `takeup_se1_5' & `takeup_se1_6' & `takeup_se1_7' \\
	tex [1ex]
	tex Take-up (Parental engagement) & `takeup_b2_1' & `takeup_b2_2' & `takeup_b2_3' & `takeup_b2_4' & `takeup_b2_5' & `takeup_b2_6' & `takeup_b2_7' \\
	tex & `takeup_se2_1' & `takeup_se2_2' & `takeup_se2_3' & `takeup_se2_4' & `takeup_se2_5' & `takeup_se2_6' & `takeup_se2_7' \\
	tex [1ex]
	tex Math score & `math_score_b1' & `math_score_b2' & `math_score_b3' & `math_score_b4' & `math_score_b5' & `math_score_b6' & `math_score_b7' \\
	tex & `math_score_se1' & `math_score_se2' & `math_score_se3' & `math_score_se4' & `math_score_se5' & `math_score_se6' & `math_score_se7' \\
	tex [1ex]
	tex Strata by year fixed effects & \ding{51} & \ding{51} & \ding{51} & \ding{51} & \ding{51} & \ding{51} & \ding{51} \\
	tex \hline \\
	tex [1ex]
	tex Take-up (Control) & `takeup_control' & `takeup_control' & `takeup_control' & `takeup_control' & `takeup_control' & `takeup_control' & `takeup_control' \\
	tex [1ex]
	tex Math score (Control) & `math_score_control' & `math_score_control' & `math_score_control' & `math_score_control' & `math_score_control' & `math_score_control' & `math_score_control' \\
	tex N & `math_score_obs1' & `math_score_obs2' & `math_score_obs3' & `math_score_obs4' & `math_score_obs5' & `math_score_obs6' & `math_score_obs7' \\
	tex [1ex]
	tex \hline \hline \\ 
	tex \end{tabular}
	tex \begin{tablenotes}[flushleft]
	tex \scriptsize
	tex \item
	tex \textbf{Notes:} This table reports the short-term first stage effects of take-up which is defined as 5 or more minutes of Khan Academy usage per week and being in the treatment group (eligible to enroll in the ATEMA program) and the parental engagement group (parents receiving information through email under the ATEMA program). The control group is defined as students in schools that were not eligible for enrollment in the ATEMA program. It reports the effects of take-up on students' Math test scores. Take-up is instrumented through eligibility in the ATEMA program in the short-term only. Standard errors of variables are clustered at the school-level and reported in parentheses. * \(p<0.10\), ** \(p<0.05\), *** \(p<0.01\).
	tex \end{tablenotes}
	tex \end{threeparttable}
	tex }
	tex \end{table}


texdoc close











