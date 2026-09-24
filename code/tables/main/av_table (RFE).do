//----------------------------------------------------------------------------//
// File name: AV_table
// Last updated: May 1, 2025
//----------------------------------------------------------------------------//

clear all
set matsize 6000
set more off 
global dir "D:\SECURE\data 2024\analysis\atema" 
global input "$dir\data" 
global output "$dir\output"

cap log close
log using "$output\Logs\tables\main\av_table_RFE.txt", text replace

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
global controls_1 "b_math_21 missing_b_math_21 gender b_special_ed"
global controls_2 "b_math_21 missing_b_math_21 gender b_special_ed b_math_19 missing_b_math_19"
global controls_3 "b_math_21 missing_b_math_21 gender b_special_ed b_math_19 missing_b_math_19 b_spa_19 missing_b_spa_19 missing_b_spa_21 b_eng_21 b_eng_21_sq missing_b_eng_21 missing_b_eng_19"
global controls_4 "b_math_21 missing_b_math_21 gender b_special_ed b_math_19 missing_b_math_19 b_spa_19 missing_b_spa_19 missing_b_spa_21 b_eng_21 b_eng_21_sq missing_b_eng_21 missing_b_eng_19 b_GPA missing_b_GPA"
global controls_5 "b_math_21 missing_b_math_21 gender b_special_ed b_math_19 missing_b_math_19 b_spa_19 missing_b_spa_19 missing_b_spa_21 b_eng_21 b_eng_21_sq missing_b_eng_21 missing_b_eng_19 b_GPA missing_b_GPA b_GPA_mate missing_b_GPA_mate b_GPA_espa missing_b_GPA_espa missing_b_GPA_ingl b_ABSENCE_COUNT_YEAR b_ABSENCE_COUNT_YEAR_sq b_ANNUAL_INCOME missing_b_ANNUAL_INCOME"
global controls_6 "b_math_21 missing_b_math_21 gender b_special_ed b_math_19 missing_b_math_19 b_spa_19 missing_b_spa_19 missing_b_spa_21 b_eng_21 b_eng_21_sq missing_b_eng_21 missing_b_eng_19 b_GPA missing_b_GPA b_GPA_mate missing_b_GPA_mate b_GPA_espa missing_b_GPA_espa missing_b_GPA_ingl b_ABSENCE_COUNT_YEAR b_ABSENCE_COUNT_YEAR_sq b_ANNUAL_INCOME missing_b_ANNUAL_INCOME b_gr38_avg missing_b_gr38_avg"
global controls_7 "b_math_21 missing_b_math_21 gender b_special_ed b_math_19 missing_b_math_19 b_spa_19 missing_b_spa_19 missing_b_spa_21 b_eng_21 b_eng_21_sq missing_b_eng_21 missing_b_eng_19 b_GPA missing_b_GPA b_GPA_mate missing_b_GPA_mate b_GPA_espa missing_b_GPA_espa missing_b_GPA_ingl b_ABSENCE_COUNT_YEAR b_ABSENCE_COUNT_YEAR_sq b_ANNUAL_INCOME missing_b_ANNUAL_INCOME b_gr38_avg missing_b_gr38_avg x_math_19_gpa x_eng_21_gpa_m x_eng_21_eng_19 x_eng_21_gpa_e x_eng_21_gpa_s x_eng_21_sp_ed x_gpa_m_gpa_s x_gpa_m_gpa_e x_gpa_m_income x_gpa_s_sp_ed x_gpa_sp_ed"
	
	qui: sum math_score if control_pooled == 1 
    local math_score_control: display `format' r(mean)

	// Model 1
	reghdfe math_score atema_st atema_pe_st atema_lt atema_pe_lt $controls_1, ///
	absorb(grade_21 strata) vce(clustervar school_21)

		local b1_1: display `format' _b[atema_st]
		scalar t_stat1_1 = _b[atema_st]/_se[atema_st]
		scalar df1_1 = e(df_r)
		scalar pval1_1 = 2 * ttail(df1_1, abs(t_stat1_1))
		if pval1_1 < 0.01 local math_score_b1_1 = strtrim("`b1_1'") + "\sym{***}"
		else if pval1_1 < 0.05 local math_score_b1_1 = strtrim("`b1_1'") + "\sym{**}"
		else if pval1_1 < 0.1 local math_score_b1_1 = strtrim("`b1_1'") + "\sym{*}"
		else local math_score_b1_1 = strtrim("`b1_1'")
		local se1_1: display `format' _se[atema_st]
		local math_score_se1_1 = "(" + strtrim("`se1_1'") + ")"
		
		local b2_1: display `format' _b[atema_pe_st]
		scalar t_stat2_1 = _b[atema_pe_st]/_se[atema_pe_st]
		scalar df2_1 = e(df_r)
		scalar pval2_1 = 2 * ttail(df2_1, abs(t_stat2_1))
		if pval2_1 < 0.01 local math_score_b2_1 = strtrim("`b2_1'") + "\sym{***}"
		else if pval2_1 < 0.05 local math_score_b2_1 = strtrim("`b2_1'") + "\sym{**}"
		else if pval2_1 < 0.1 local math_score_b2_1 = strtrim("`b2_1'") + "\sym{*}"
		else local math_score_b2_1 = strtrim("`b2_1'")
		local se2_1: display `format' _se[atema_pe_st]
		local math_score_se2_1 = "(" + strtrim("`se2_1'") + ")"
		
		local b3_1: display `format' _b[atema_lt]
		scalar t_stat3_1 = _b[atema_lt]/_se[atema_lt]
		scalar df3_1 = e(df_r)
		scalar pval3_1 = 2 * ttail(df3_1, abs(t_stat3_1))
		if pval3_1 < 0.01 local math_score_b3_1 = strtrim("`b3_1'") + "\sym{***}"
		else if pval3_1 < 0.05 local math_score_b3_1 = strtrim("`b3_1'") + "\sym{**}"
		else if pval3_1 < 0.1 local math_score_b3_1 = strtrim("`b3_1'") + "\sym{*}"
		else local math_score_b3_1 = strtrim("`b3_1'")
		local se3_1: display `format' _se[atema_lt]
		local math_score_se3_1 = "(" + strtrim("`se3_1'") + ")"

		local b4_1: display `format' _b[atema_pe_lt]
		scalar t_stat4_1 = _b[atema_pe_lt]/_se[atema_pe_lt]
		scalar df4_1 = e(df_r)
		scalar pval4_1 = 2 * ttail(df4_1, abs(t_stat4_1))
		if pval4_1 < 0.01 local math_score_b4_1 = strtrim("`b4_1'") + "\sym{***}"
		else if pval4_1 < 0.05 local math_score_b4_1 = strtrim("`b4_1'") + "\sym{**}"
		else if pval4_1 < 0.1 local math_score_b4_1 = strtrim("`b4_1'") + "\sym{*}"
		else local math_score_b4_1 = strtrim("`b4_1'")
		local se4_1: display `format' _se[atema_pe_lt]
		local math_score_se4_1 = "(" + strtrim("`se4_1'") + ")"
		
		local math_score_obs_1: display %9.0fc e(N)
		
		test atema_st = atema_pe_st
		local math_score_pval1_1: display `format' r(p)
		
		test atema_st = atema_lt
		local math_score_pval2_1: display `format' r(p)
		
		test atema_pe_st = atema_pe_lt
		local math_score_pval3_1: display `format' r(p)
		
		
		
	// Model 2
	reghdfe math_score atema_st atema_pe_st atema_lt atema_pe_lt $controls_2, ///
	absorb(grade_21 strata) vce(clustervar school_21)

		local b1_2: display `format' _b[atema_st]
		scalar t_stat1_2 = _b[atema_st]/_se[atema_st]
		scalar df1_2 = e(df_r)
		scalar pval1_2 = 2 * ttail(df1_2, abs(t_stat1_2))
		if pval1_2 < 0.01 local math_score_b1_2 = strtrim("`b1_2'") + "\sym{***}"
		else if pval1_2 < 0.05 local math_score_b1_2 = strtrim("`b1_2'") + "\sym{**}"
		else if pval1_2 < 0.1 local math_score_b1_2 = strtrim("`b1_2'") + "\sym{*}"
		else local math_score_b1_2 = strtrim("`b1_2'")
		local se1_2: display `format' _se[atema_st]
		local math_score_se1_2 = "(" + strtrim("`se1_2'") + ")"
		
		local b2_2: display `format' _b[atema_pe_st]
		scalar t_stat2_2 = _b[atema_pe_st]/_se[atema_pe_st]
		scalar df2_2 = e(df_r)
		scalar pval2_2 = 2 * ttail(df2_2, abs(t_stat2_2))
		if pval2_2 < 0.01 local math_score_b2_2 = strtrim("`b2_2'") + "\sym{***}"
		else if pval2_2 < 0.05 local math_score_b2_2 = strtrim("`b2_2'") + "\sym{**}"
		else if pval2_2 < 0.1 local math_score_b2_2 = strtrim("`b2_2'") + "\sym{*}"
		else local math_score_b2_2 = strtrim("`b2_2'")
		local se2_2: display `format' _se[atema_pe_st]
		local math_score_se2_2 = "(" + strtrim("`se2_2'") + ")"
		
		local b3_2: display `format' _b[atema_lt]
		scalar t_stat3_2 = _b[atema_lt]/_se[atema_lt]
		scalar df3_2 = e(df_r)
		scalar pval3_2 = 2 * ttail(df3_2, abs(t_stat3_2))
		if pval3_2 < 0.01 local math_score_b3_2 = strtrim("`b3_2'") + "\sym{***}"
		else if pval3_2 < 0.05 local math_score_b3_2 = strtrim("`b3_2'") + "\sym{**}"
		else if pval3_2 < 0.1 local math_score_b3_2 = strtrim("`b3_2'") + "\sym{*}"
		else local math_score_b3_2 = strtrim("`b3_2'")
		local se3_2: display `format' _se[atema_lt]
		local math_score_se3_2 = "(" + strtrim("`se3_2'") + ")"

		local b4_2: display `format' _b[atema_pe_lt]
		scalar t_stat4_2 = _b[atema_pe_lt]/_se[atema_pe_lt]
		scalar df4_2 = e(df_r)
		scalar pval4_2 = 2 * ttail(df4_2, abs(t_stat4_2))
		if pval4_2 < 0.01 local math_score_b4_2 = strtrim("`b4_2'") + "\sym{***}"
		else if pval4_2 < 0.05 local math_score_b4_2 = strtrim("`b4_2'") + "\sym{**}"
		else if pval4_2 < 0.1 local math_score_b4_2 = strtrim("`b4_2'") + "\sym{*}"
		else local math_score_b4_2 = strtrim("`b4_2'")
		local se4_2: display `format' _se[atema_pe_lt]
		local math_score_se4_2 = "(" + strtrim("`se4_2'") + ")"
		
		local math_score_obs_2: display %9.0fc e(N)
		
		test atema_st = atema_pe_st
		local math_score_pval1_2: display `format' r(p)
		
		test atema_st = atema_lt
		local math_score_pval2_2: display `format' r(p)
		
		test atema_pe_st = atema_pe_lt
		local math_score_pval3_2: display `format' r(p)
		
		
		
	// Model 3
	reghdfe math_score atema_st atema_pe_st atema_lt atema_pe_lt $controls_3, ///
	absorb(grade_21 strata) vce(clustervar school_21)

		local b1_3: display `format' _b[atema_st]
		scalar t_stat1_3 = _b[atema_st]/_se[atema_st]
		scalar df1_3 = e(df_r)
		scalar pval1_3 = 2 * ttail(df1_3, abs(t_stat1_3))
		if pval1_3 < 0.01 local math_score_b1_3 = strtrim("`b1_3'") + "\sym{***}"
		else if pval1_3 < 0.05 local math_score_b1_3 = strtrim("`b1_3'") + "\sym{**}"
		else if pval1_3 < 0.1 local math_score_b1_3 = strtrim("`b1_3'") + "\sym{*}"
		else local math_score_b1_3 = strtrim("`b1_3'")
		local se1_3: display `format' _se[atema_st]
		local math_score_se1_3 = "(" + strtrim("`se1_3'") + ")"
		
		local b2_3: display `format' _b[atema_pe_st]
		scalar t_stat2_3 = _b[atema_pe_st]/_se[atema_pe_st]
		scalar df2_3 = e(df_r)
		scalar pval2_3 = 2 * ttail(df2_3, abs(t_stat2_3))
		if pval2_3 < 0.01 local math_score_b2_3 = strtrim("`b2_3'") + "\sym{***}"
		else if pval2_3 < 0.05 local math_score_b2_3 = strtrim("`b2_3'") + "\sym{**}"
		else if pval2_3 < 0.1 local math_score_b2_3 = strtrim("`b2_3'") + "\sym{*}"
		else local math_score_b2_3 = strtrim("`b2_3'")
		local se2_3: display `format' _se[atema_pe_st]
		local math_score_se2_3 = "(" + strtrim("`se2_3'") + ")"
		
		local b3_3: display `format' _b[atema_lt]
		scalar t_stat3_3 = _b[atema_lt]/_se[atema_lt]
		scalar df3_3 = e(df_r)
		scalar pval3_3 = 2 * ttail(df3_3, abs(t_stat3_3))
		if pval3_3 < 0.01 local math_score_b3_3 = strtrim("`b3_3'") + "\sym{***}"
		else if pval3_3 < 0.05 local math_score_b3_3 = strtrim("`b3_3'") + "\sym{**}"
		else if pval3_3 < 0.1 local math_score_b3_3 = strtrim("`b3_3'") + "\sym{*}"
		else local math_score_b3_3 = strtrim("`b3_3'")
		local se3_3: display `format' _se[atema_lt]
		local math_score_se3_3 = "(" + strtrim("`se3_3'") + ")"

		local b4_3: display `format' _b[atema_pe_lt]
		scalar t_stat4_3 = _b[atema_pe_lt]/_se[atema_pe_lt]
		scalar df4_3 = e(df_r)
		scalar pval4_3 = 2 * ttail(df4_3, abs(t_stat4_3))
		if pval4_3 < 0.01 local math_score_b4_3 = strtrim("`b4_3'") + "\sym{***}"
		else if pval4_3 < 0.05 local math_score_b4_3 = strtrim("`b4_3'") + "\sym{**}"
		else if pval4_3 < 0.1 local math_score_b4_3 = strtrim("`b4_3'") + "\sym{*}"
		else local math_score_b4_3 = strtrim("`b4_3'")
		local se4_3: display `format' _se[atema_pe_lt]
		local math_score_se4_3 = "(" + strtrim("`se4_3'") + ")"
		
		local math_score_obs_3: display %9.0fc e(N)
		
		test atema_st = atema_pe_st
		local math_score_pval1_3: display `format' r(p)
		
		test atema_st = atema_lt
		local math_score_pval2_3: display `format' r(p)
		
		test atema_pe_st = atema_pe_lt
		local math_score_pval3_3: display `format' r(p)
		
		
		
	// Model 4
	reghdfe math_score atema_st atema_pe_st atema_lt atema_pe_lt $controls_4, ///
	absorb(grade_21 strata) vce(clustervar school_21)

		local b1_4: display `format' _b[atema_st]
		scalar t_stat1_4 = _b[atema_st]/_se[atema_st]
		scalar df1_4 = e(df_r)
		scalar pval1_4 = 2 * ttail(df1_4, abs(t_stat1_4))
		if pval1_4 < 0.01 local math_score_b1_4 = strtrim("`b1_4'") + "\sym{***}"
		else if pval1_4 < 0.05 local math_score_b1_4 = strtrim("`b1_4'") + "\sym{**}"
		else if pval1_4 < 0.1 local math_score_b1_4 = strtrim("`b1_4'") + "\sym{*}"
		else local math_score_b1_4 = strtrim("`b1_4'")
		local se1_4: display `format' _se[atema_st]
		local math_score_se1_4 = "(" + strtrim("`se1_4'") + ")"
		
		local b2_4: display `format' _b[atema_pe_st]
		scalar t_stat2_4 = _b[atema_pe_st]/_se[atema_pe_st]
		scalar df2_4 = e(df_r)
		scalar pval2_4 = 2 * ttail(df2_4, abs(t_stat2_4))
		if pval2_4 < 0.01 local math_score_b2_4 = strtrim("`b2_4'") + "\sym{***}"
		else if pval2_4 < 0.05 local math_score_b2_4 = strtrim("`b2_4'") + "\sym{**}"
		else if pval2_4 < 0.1 local math_score_b2_4 = strtrim("`b2_4'") + "\sym{*}"
		else local math_score_b2_4 = strtrim("`b2_4'")
		local se2_4: display `format' _se[atema_pe_st]
		local math_score_se2_4 = "(" + strtrim("`se2_4'") + ")"
		
		local b3_4: display `format' _b[atema_lt]
		scalar t_stat3_4 = _b[atema_lt]/_se[atema_lt]
		scalar df3_4 = e(df_r)
		scalar pval3_4 = 2 * ttail(df3_4, abs(t_stat3_4))
		if pval3_4 < 0.01 local math_score_b3_4 = strtrim("`b3_4'") + "\sym{***}"
		else if pval3_4 < 0.05 local math_score_b3_4 = strtrim("`b3_4'") + "\sym{**}"
		else if pval3_4 < 0.1 local math_score_b3_4 = strtrim("`b3_4'") + "\sym{*}"
		else local math_score_b3_4 = strtrim("`b3_4'")
		local se3_4: display `format' _se[atema_lt]
		local math_score_se3_4 = "(" + strtrim("`se3_4'") + ")"

		local b4_4: display `format' _b[atema_pe_lt]
		scalar t_stat4_4 = _b[atema_pe_lt]/_se[atema_pe_lt]
		scalar df4_4 = e(df_r)
		scalar pval4_4 = 2 * ttail(df4_4, abs(t_stat4_4))
		if pval4_4 < 0.01 local math_score_b4_4 = strtrim("`b4_4'") + "\sym{***}"
		else if pval4_4 < 0.05 local math_score_b4_4 = strtrim("`b4_4'") + "\sym{**}"
		else if pval4_4 < 0.1 local math_score_b4_4 = strtrim("`b4_4'") + "\sym{*}"
		else local math_score_b4_4 = strtrim("`b4_4'")
		local se4_4: display `format' _se[atema_pe_lt]
		local math_score_se4_4 = "(" + strtrim("`se4_4'") + ")"
		
		local math_score_obs_4: display %9.0fc e(N)
		
		test atema_st = atema_pe_st
		local math_score_pval1_4: display `format' r(p)
		
		test atema_st = atema_lt
		local math_score_pval2_4: display `format' r(p)
		
		test atema_pe_st = atema_pe_lt
		local math_score_pval3_4: display `format' r(p)		
		
		
		
	// Model 5
	reghdfe math_score atema_st atema_pe_st atema_lt atema_pe_lt $controls_5, ///
	absorb(grade_21 strata) vce(clustervar school_21)

		local b1_5: display `format' _b[atema_st]
		scalar t_stat1_5 = _b[atema_st]/_se[atema_st]
		scalar df1_5 = e(df_r)
		scalar pval1_5 = 2 * ttail(df1_5, abs(t_stat1_5))
		if pval1_5 < 0.01 local math_score_b1_5 = strtrim("`b1_5'") + "\sym{***}"
		else if pval1_5 < 0.05 local math_score_b1_5 = strtrim("`b1_5'") + "\sym{**}"
		else if pval1_5 < 0.1 local math_score_b1_5 = strtrim("`b1_5'") + "\sym{*}"
		else local math_score_b1_5 = strtrim("`b1_5'")
		local se1_5: display `format' _se[atema_st]
		local math_score_se1_5 = "(" + strtrim("`se1_5'") + ")"
		
		local b2_5: display `format' _b[atema_pe_st]
		scalar t_stat2_5 = _b[atema_pe_st]/_se[atema_pe_st]
		scalar df2_5 = e(df_r)
		scalar pval2_5 = 2 * ttail(df2_5, abs(t_stat2_5))
		if pval2_5 < 0.01 local math_score_b2_5 = strtrim("`b2_5'") + "\sym{***}"
		else if pval2_5 < 0.05 local math_score_b2_5 = strtrim("`b2_5'") + "\sym{**}"
		else if pval2_5 < 0.1 local math_score_b2_5 = strtrim("`b2_5'") + "\sym{*}"
		else local math_score_b2_5 = strtrim("`b2_5'")
		local se2_5: display `format' _se[atema_pe_st]
		local math_score_se2_5 = "(" + strtrim("`se2_5'") + ")"
		
		local b3_5: display `format' _b[atema_lt]
		scalar t_stat3_5 = _b[atema_lt]/_se[atema_lt]
		scalar df3_5 = e(df_r)
		scalar pval3_5 = 2 * ttail(df3_5, abs(t_stat3_5))
		if pval3_5 < 0.01 local math_score_b3_5 = strtrim("`b3_5'") + "\sym{***}"
		else if pval3_5 < 0.05 local math_score_b3_5 = strtrim("`b3_5'") + "\sym{**}"
		else if pval3_5 < 0.1 local math_score_b3_5 = strtrim("`b3_5'") + "\sym{*}"
		else local math_score_b3_5 = strtrim("`b3_5'")
		local se3_5: display `format' _se[atema_lt]
		local math_score_se3_5 = "(" + strtrim("`se3_5'") + ")"

		local b4_5: display `format' _b[atema_pe_lt]
		scalar t_stat4_5 = _b[atema_pe_lt]/_se[atema_pe_lt]
		scalar df4_5 = e(df_r)
		scalar pval4_5 = 2 * ttail(df4_5, abs(t_stat4_5))
		if pval4_5 < 0.01 local math_score_b4_5 = strtrim("`b4_5'") + "\sym{***}"
		else if pval4_5 < 0.05 local math_score_b4_5 = strtrim("`b4_5'") + "\sym{**}"
		else if pval4_5 < 0.1 local math_score_b4_5 = strtrim("`b4_5'") + "\sym{*}"
		else local math_score_b4_5 = strtrim("`b4_5'")
		local se4_5: display `format' _se[atema_pe_lt]
		local math_score_se4_5 = "(" + strtrim("`se4_5'") + ")"
		
		local math_score_obs_5: display %9.0fc e(N)
		
		test atema_st = atema_pe_st
		local math_score_pval1_5: display `format' r(p)
		
		test atema_st = atema_lt
		local math_score_pval2_5: display `format' r(p)
		
		test atema_pe_st = atema_pe_lt
		local math_score_pval3_5: display `format' r(p)	
		
		
		
	// Model 6
	reghdfe math_score atema_st atema_pe_st atema_lt atema_pe_lt $controls_6, ///
	absorb(grade_21 strata) vce(clustervar school_21)

		local b1_6: display `format' _b[atema_st]
		scalar t_stat1_6 = _b[atema_st]/_se[atema_st]
		scalar df1_6 = e(df_r)
		scalar pval1_6 = 2 * ttail(df1_6, abs(t_stat1_6))
		if pval1_6 < 0.01 local math_score_b1_6 = strtrim("`b1_6'") + "\sym{***}"
		else if pval1_6 < 0.05 local math_score_b1_6 = strtrim("`b1_6'") + "\sym{**}"
		else if pval1_6 < 0.1 local math_score_b1_6 = strtrim("`b1_6'") + "\sym{*}"
		else local math_score_b1_6 = strtrim("`b1_6'")
		local se1_6: display `format' _se[atema_st]
		local math_score_se1_6 = "(" + strtrim("`se1_6'") + ")"
		
		local b2_6: display `format' _b[atema_pe_st]
		scalar t_stat2_6 = _b[atema_pe_st]/_se[atema_pe_st]
		scalar df2_6 = e(df_r)
		scalar pval2_6 = 2 * ttail(df2_6, abs(t_stat2_6))
		if pval2_6 < 0.01 local math_score_b2_6 = strtrim("`b2_6'") + "\sym{***}"
		else if pval2_6 < 0.05 local math_score_b2_6 = strtrim("`b2_6'") + "\sym{**}"
		else if pval2_6 < 0.1 local math_score_b2_6 = strtrim("`b2_6'") + "\sym{*}"
		else local math_score_b2_6 = strtrim("`b2_6'")
		local se2_6: display `format' _se[atema_pe_st]
		local math_score_se2_6 = "(" + strtrim("`se2_6'") + ")"
		
		local b3_6: display `format' _b[atema_lt]
		scalar t_stat3_6 = _b[atema_lt]/_se[atema_lt]
		scalar df3_6 = e(df_r)
		scalar pval3_6 = 2 * ttail(df3_6, abs(t_stat3_6))
		if pval3_6 < 0.01 local math_score_b3_6 = strtrim("`b3_6'") + "\sym{***}"
		else if pval3_6 < 0.05 local math_score_b3_6 = strtrim("`b3_6'") + "\sym{**}"
		else if pval3_6 < 0.1 local math_score_b3_6 = strtrim("`b3_6'") + "\sym{*}"
		else local math_score_b3_6 = strtrim("`b3_6'")
		local se3_6: display `format' _se[atema_lt]
		local math_score_se3_6 = "(" + strtrim("`se3_6'") + ")"

		local b4_6: display `format' _b[atema_pe_lt]
		scalar t_stat4_6 = _b[atema_pe_lt]/_se[atema_pe_lt]
		scalar df4_6 = e(df_r)
		scalar pval4_6 = 2 * ttail(df4_6, abs(t_stat4_6))
		if pval4_6 < 0.01 local math_score_b4_6 = strtrim("`b4_6'") + "\sym{***}"
		else if pval4_6 < 0.05 local math_score_b4_6 = strtrim("`b4_6'") + "\sym{**}"
		else if pval4_6 < 0.1 local math_score_b4_6 = strtrim("`b4_6'") + "\sym{*}"
		else local math_score_b4_6 = strtrim("`b4_6'")
		local se4_6: display `format' _se[atema_pe_lt]
		local math_score_se4_6 = "(" + strtrim("`se4_6'") + ")"
		
		local math_score_obs_6: display %9.0fc e(N)
		
		test atema_st = atema_pe_st
		local math_score_pval1_6: display `format' r(p)
		
		test atema_st = atema_lt
		local math_score_pval2_6: display `format' r(p)
		
		test atema_pe_st = atema_pe_lt
		local math_score_pval3_6: display `format' r(p)	
		
		
		
	// Model 7
	reghdfe math_score atema_st atema_pe_st atema_lt atema_pe_lt $controls_7, ///
	absorb(grade_21 strata) vce(clustervar school_21)

		local b1_7: display `format' _b[atema_st]
		scalar t_stat1_7 = _b[atema_st]/_se[atema_st]
		scalar df1_7 = e(df_r)
		scalar pval1_7 = 2 * ttail(df1_7, abs(t_stat1_7))
		if pval1_7 < 0.01 local math_score_b1_7 = strtrim("`b1_7'") + "\sym{***}"
		else if pval1_7 < 0.05 local math_score_b1_7 = strtrim("`b1_7'") + "\sym{**}"
		else if pval1_7 < 0.1 local math_score_b1_7 = strtrim("`b1_7'") + "\sym{*}"
		else local math_score_b1_7 = strtrim("`b1_7'")
		local se1_7: display `format' _se[atema_st]
		local math_score_se1_7 = "(" + strtrim("`se1_7'") + ")"
		
		local b2_7: display `format' _b[atema_pe_st]
		scalar t_stat2_7 = _b[atema_pe_st]/_se[atema_pe_st]
		scalar df2_7 = e(df_r)
		scalar pval2_7 = 2 * ttail(df2_7, abs(t_stat2_7))
		if pval2_7 < 0.01 local math_score_b2_7 = strtrim("`b2_7'") + "\sym{***}"
		else if pval2_7 < 0.05 local math_score_b2_7 = strtrim("`b2_7'") + "\sym{**}"
		else if pval2_7 < 0.1 local math_score_b2_7 = strtrim("`b2_7'") + "\sym{*}"
		else local math_score_b2_7 = strtrim("`b2_7'")
		local se2_7: display `format' _se[atema_pe_st]
		local math_score_se2_7 = "(" + strtrim("`se2_7'") + ")"
		
		local b3_7: display `format' _b[atema_lt]
		scalar t_stat3_7 = _b[atema_lt]/_se[atema_lt]
		scalar df3_7 = e(df_r)
		scalar pval3_7 = 2 * ttail(df3_7, abs(t_stat3_7))
		if pval3_7 < 0.01 local math_score_b3_7 = strtrim("`b3_7'") + "\sym{***}"
		else if pval3_7 < 0.05 local math_score_b3_7 = strtrim("`b3_7'") + "\sym{**}"
		else if pval3_7 < 0.1 local math_score_b3_7 = strtrim("`b3_7'") + "\sym{*}"
		else local math_score_b3_7 = strtrim("`b3_7'")
		local se3_7: display `format' _se[atema_lt]
		local math_score_se3_7 = "(" + strtrim("`se3_7'") + ")"

		local b4_7: display `format' _b[atema_pe_lt]
		scalar t_stat4_7 = _b[atema_pe_lt]/_se[atema_pe_lt]
		scalar df4_7 = e(df_r)
		scalar pval4_7 = 2 * ttail(df4_7, abs(t_stat4_7))
		if pval4_7 < 0.01 local math_score_b4_7 = strtrim("`b4_7'") + "\sym{***}"
		else if pval4_7 < 0.05 local math_score_b4_7 = strtrim("`b4_7'") + "\sym{**}"
		else if pval4_7 < 0.1 local math_score_b4_7 = strtrim("`b4_7'") + "\sym{*}"
		else local math_score_b4_7 = strtrim("`b4_7'")
		local se4_7: display `format' _se[atema_pe_lt]
		local math_score_se4_7 = "(" + strtrim("`se4_7'") + ")"
		
		local math_score_obs_7: display %9.0fc e(N)
		
		test atema_st = atema_pe_st
		local math_score_pval1_7: display `format' r(p)
		
		test atema_st = atema_lt
		local math_score_pval2_7: display `format' r(p)
		
		test atema_pe_st = atema_pe_lt
		local math_score_pval3_7: display `format' r(p)			
	
	
//============================================================================//
// Table
//============================================================================//

texdoc init "$output\tables\main\av_table_RFE", replace force

	tex \begin{table}[htbp]
	tex \centering
	tex \resizebox{\linewidth}{!}{%
	tex \begin{threeparttable}
	tex \caption{\textbf{Reduced Form Effects on Math Scores}}
	tex \fontsize{10}{11}\selectfont
	tex \begin{tabular}{l*{7}c}
	tex \hline\hline
	tex &\multicolumn{1}{c}{Model 1} &\multicolumn{1}{c}{Model 2} &\multicolumn{1}{c}{Model 3} &\multicolumn{1}{c}{Model 4} &\multicolumn{1}{c}{Model 5} &\multicolumn{1}{c}{Model 6} &\multicolumn{1}{c}{Model 7}\\
	tex &\multicolumn{1}{c}{(1)} &\multicolumn{1}{c}{(2)} &\multicolumn{1}{c}{(3)} &\multicolumn{1}{c}{(4)} &\multicolumn{1}{c}{(5)} &\multicolumn{1}{c}{(6)} &\multicolumn{1}{c}{(7)}\\
	tex \hline \\
	tex $\beta_1$: Treatment (short-term) & `math_score_b1_1' & `math_score_b1_2' & `math_score_b1_3' & `math_score_b1_4' & `math_score_b1_5' & `math_score_b1_6' & `math_score_b1_7' \\
	tex & `math_score_se1_1' & `math_score_se1_2' & `math_score_se1_3' & `math_score_se1_4' & `math_score_se1_5' & `math_score_se1_6' & `math_score_se1_7' \\
	tex [1ex]
	tex $\beta_2$: Parental engagement (short-term) & `math_score_b2_1' & `math_score_b2_2' & `math_score_b2_3' & `math_score_b2_4' & `math_score_b2_5' & `math_score_b2_6' & `math_score_b2_7' \\
	tex & `math_score_se2_1' & `math_score_se2_2' & `math_score_se2_3' & `math_score_se2_4' & `math_score_se2_5' & `math_score_se2_6' & `math_score_se2_7' \\
	tex [1ex]
	tex $\beta_3$: Treatment (long-term) & `math_score_b3_1' & `math_score_b3_2' & `math_score_b3_3' & `math_score_b3_4' & `math_score_b3_5' & `math_score_b3_6' & `math_score_b3_7' \\
	tex & `math_score_se3_1' & `math_score_se3_2' & `math_score_se3_3' & `math_score_se3_4' & `math_score_se3_5' & `math_score_se3_6' & `math_score_se3_7' \\
	tex [1ex]
	tex $\beta_4$: Parental engagement (long-term) & `math_score_b4_1' & `math_score_b4_2' & `math_score_b4_3' & `math_score_b4_4' & `math_score_b4_5' & `math_score_b4_6' & `math_score_b4_7' \\
	tex & `math_score_se4_1' & `math_score_se4_2' & `math_score_se4_3' & `math_score_se4_4' & `math_score_se4_5' & `math_score_se4_6' & `math_score_se4_7' \\
	tex [1ex]
	tex Strata by year fixed effects & \ding{51} & \ding{51} & \ding{51} & \ding{51} & \ding{51} & \ding{51} & \ding{51} \\
	tex \hline \\
	tex [1ex]
	tex $H_0: \beta_1 = \beta_2$ & `math_score_pval1_1' & `math_score_pval1_2' & `math_score_pval1_3' & `math_score_pval1_4' & `math_score_pval1_5' & `math_score_pval1_6' & `math_score_pval1_7' \\
	tex [1ex]
	tex $H_0: \beta_1 = \beta_3$ & `math_score_pval2_1' & `math_score_pval2_2' & `math_score_pval2_3' & `math_score_pval2_4' & `math_score_pval2_5' & `math_score_pval2_6' & `math_score_pval2_7' \\
	tex [1ex] 
	tex $H_0: \beta_2 = \beta_4$ & `math_score_pval3_1' & `math_score_pval3_2' & `math_score_pval3_3' & `math_score_pval3_4' & `math_score_pval3_5' & `math_score_pval3_6' & `math_score_pval3_7' \\
	tex [1ex]
	tex \hline \\ 
	tex [1ex]
	tex Control mean & `math_score_control' & `math_score_control' & `math_score_control' & `math_score_control' & `math_score_control' & `math_score_control' & `math_score_control' \\
	tex N & `math_score_obs_1' & `math_score_obs_2' & `math_score_obs_3' & `math_score_obs_4' & `math_score_obs_5' & `math_score_obs_6' & `math_score_obs_7' \\
	tex [1ex]
	tex \hline \hline \\ 
	tex \end{tabular}
	tex \begin{tablenotes}[flushleft]
	tex \scriptsize
	tex \item
	tex \textbf{Notes:} This table reports the short and long-term first stage effects of being in the treatment group (eligible to enroll in the ATEMA program) and the parental engagement group (parents receiving information through email under the ATEMA program) on students' math scores. The control group is defined as students in schools that were not eligible for enrollment in the ATEMA program. Standard errors of variables are clustered at the school-level and reported in parentheses. * \(p<0.10\), ** \(p<0.05\), *** \(p<0.01\). 
	tex \end{tablenotes}
	tex \end{threeparttable}
	tex }
	tex \end{table}


texdoc close











