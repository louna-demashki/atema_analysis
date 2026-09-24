//----------------------------------------------------------------------------//
// File name: 6. heterogeneity RFE (pooled B)
// Last updated: Nov. 7, 2024 by Sara Mostafa
//----------------------------------------------------------------------------//


clear all
set matsize 6000
set more off 
global dir "D:\SECURE\data 2024\analysis\atema" 
global input "$dir\data" 
global output "$dir\output"

cap log close
log using "$output\Logs\tables\appendix\heterogeneity RFE (pooled B).txt", text replace


use "$input\master_controls", clear 

	
rename strata old_strata
egen strata = group(old_strata ACADEMIC_YEAR_ID_FK)
	
	
gen control_pooled = 0 
	replace control_pooled = 1 if (control == 1 | (treat_arm_3 == 1 & ACADEMIC_YEAR_ID_FK == 2022) ///
	| (treat_arm_4 == 1 & ACADEMIC_YEAR_ID_FK == 2022))

	
//selected controls -- from control_selection.do
global s_controls "x_eng_21_math_19 x_eng_21_eng_19 x_eng_21_gpa_m x_eng_21_gpa_e x_eng_21_gpa_s x_eng_21_sp_ed x_math_19_gpa x_math_19_gpa_m x_spa_19_gpa_s x_gpa_sp_ed x_gpa_m_gpa_s x_gpa_m_income x_gpa_s_sp_ed x_gpa_s_gr38 x_s_disp_gr38 b_eng_21 b_math_19 b_spa_19 b_GPA b_GPA_mate b_GPA_espa b_ANNUAL_INCOME b_special_ed b_ABSENCE_COUNT_YEAR b_gr38_avg b_math_21 missing_b_math_19 missing_b_eng_19 missing_b_GPA_mate missing_b_GPA_ingl missing_b_GPA_espa missing_b_ANNUAL_INCOME missing_b_gr38_avg missing_b_spa_19 missing_b_GPA missing_b_gr38_avg missing_b_math_21 missing_b_eng_21 missing_b_spa_21 b_eng_21_sq b_ABSENCE_COUNT_YEAR_sq"



local format "%9.3fc" 
local usage "math_score"

foreach depvar of local usage {

	summarize `depvar' if control_pooled==1 
    local `depvar'c_M: display `format' r(mean)
    local sd: display `format' r(sd)
    local `depvar'c_SD = "[" + strtrim("`sd'") + "]"
	
	}


foreach depvar of local usage {
	
	summarize `depvar' if control_pooled == 1 & inrange(GRADE_ID_FK,6,8) 
    local `depvar'c_Mps: display `format' r(mean)
    local sdps: display `format' r(sd)
    local `depvar'c_SDps = "[" + strtrim("`sdps'") + "]"
	
	summarize `depvar' if control_pooled == 1 & inrange(GRADE_ID_FK,9,10) 
    local `depvar'c_Mms: display `format' r(mean)
    local sdms: display `format' r(sd)
    local `depvar'c_SDms = "[" + strtrim("`sdms'") + "]"
	
	summarize `depvar' if control_pooled == 1 & gender==1 
    local `depvar'c_Mf: display `format' r(mean)
    local sdf: display `format' r(sd)
    local `depvar'c_SDf = "[" + strtrim("`sdf'") + "]"
	
	summarize `depvar' if control_pooled == 1 & gender==0 
    local `depvar'c_Mm: display `format' r(mean)
    local sdm: display `format' r(sd)
    local `depvar'c_SDm = "[" + strtrim("`sdm'") + "]"
	
	summarize `depvar' if control_pooled == 1 & above_median==1 
    local `depvar'c_Mam: display `format' r(mean)
    local sd_am: display `format' r(sd)
    local `depvar'c_SDam = "[" + strtrim("`sd_am'") + "]"
	
	summarize `depvar' if control_pooled == 1 & above_median==0 
    local `depvar'c_Mbm: display `format' r(mean)
    local sd_bm: display `format' r(sd)
    local `depvar'c_SDbm = "[" + strtrim("`sd_bm'") + "]"
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
		
		test atema_st = atema_pe_st 
		local `depvar'p1_all: display `format' r(p)
		test atema_st=atema_lt
		local `depvar'p2_all: display `format' r(p)
		test atema_pe_st=atema_pe_lt
		local `depvar'p3_all: display `format' r(p)
		
		local `depvar'obs_23: display %9.0fc e(N)

		
	// primary school 
		reghdfe `depvar' atema_st atema_pe_st atema_lt atema_pe_lt $s_controls ///
		if inrange(GRADE_ID_FK,6,8), absorb(GRADE_ID_FK strata) vce(clustervar school_21)
		
		local b1ps_23: display `format' _b[atema_st]
		scalar t_stat1ps_23 = _b[atema_st]/_se[atema_st]
		scalar df1ps_23 = e(df_r)
		scalar pval1ps_23 = 2 * ttail(df1ps_23, abs(t_stat1ps_23))
		if pval1ps_23 < 0.01 local `depvar'_b1ps_23 = strtrim("`b1ps_23'") + "\sym{***}"
		else if pval1ps_23 < 0.05 local `depvar'_b1ps_23 = strtrim("`b1ps_23'") + "\sym{**}"
		else if pval1ps_23 < 0.1 local `depvar'_b1ps_23 = strtrim("`b1ps_23'") + "\sym{*}"
		else local `depvar'_b1ps_23 = strtrim("`b1ps_23'")
		local se1ps_23: display `format' _se[atema_st]
		local `depvar'_se1ps_23 = "(" + strtrim("`se1ps_23'") + ")"
		
		local b2ps_23: display `format' _b[atema_pe_st]
		scalar t_stat2ps_23 = _b[atema_pe_st]/_se[atema_pe_st]
		scalar df2ps_23 = e(df_r)
		scalar pval2ps_23 = 2 * ttail(df2ps_23, abs(t_stat2ps_23))
		if pval2ps_23 < 0.01 local `depvar'_b2ps_23 = strtrim("`b2ps_23'") + "\sym{***}"
		else if pval2ps_23 < 0.05 local `depvar'_b2ps_23 = strtrim("`b2ps_23'") + "\sym{**}"
		else if pval2ps_23 < 0.1 local `depvar'_b2ps_23 = strtrim("`b2ps_23'") + "\sym{*}"
		else local `depvar'_b2ps_23 = strtrim("`b2ps_23'")
		local se2ps_23: display `format' _se[atema_pe_st]
		local `depvar'_se2ps_23 = "(" + strtrim("`se2ps_23'") + ")"
		
		test atema_st = atema_pe_st 
		local `depvar'p1_ps: display `format' r(p)
		test atema_st=atema_lt
		local `depvar'p2_ps: display `format' r(p)
		test atema_pe_st=atema_pe_lt
		local `depvar'p3_ps: display `format' r(p)

		local `depvar'obsps_23: display %9.0fc e(N)
		
		
		reghdfe `depvar' atema_st atema_pe_st atema_lt atema_pe_lt $s_controls ///
		if inrange(GRADE_ID_FK,7,8), absorb(GRADE_ID_FK strata) vce(clustervar school_21)
		
		local b3ps_23: display `format' _b[atema_lt]
		scalar t_stat3ps_23 = _b[atema_lt]/_se[atema_lt]
		scalar df3ps_23 = e(df_r)
		scalar pval3ps_23 = 2 * ttail(df3ps_23, abs(t_stat3ps_23))
		if pval3ps_23 < 0.01 local `depvar'_b3ps_23 = strtrim("`b3ps_23'") + "\sym{***}"
		else if pval3ps_23 < 0.05 local `depvar'_b3ps_23 = strtrim("`b3ps_23'") + "\sym{**}"
		else if pval3ps_23 < 0.1 local `depvar'_b3ps_23 = strtrim("`b3ps_23'") + "\sym{*}"
		else local `depvar'_b3ps_23 = strtrim("`b3ps_23'")
		local se3ps_23: display `format' _se[atema_lt]
		local `depvar'_se3ps_23 = "(" + strtrim("`se3ps_23'") + ")"

		local b4ps_23: display `format' _b[atema_pe_lt]
		scalar t_stat4ps_23 = _b[atema_pe_lt]/_se[atema_pe_lt]
		scalar df4ps_23 = e(df_r)
		scalar pval4ps_23 = 2 * ttail(df4ps_23, abs(t_stat4ps_23))
		if pval4ps_23 < 0.01 local `depvar'_b4ps_23 = strtrim("`b4ps_23'") + "\sym{***}"
		else if pval4ps_23 < 0.05 local `depvar'_b4ps_23 = strtrim("`b4ps_23'") + "\sym{**}"
		else if pval4ps_23 < 0.1 local `depvar'_b4ps_23 = strtrim("`b4ps_23'") + "\sym{*}"
		else local `depvar'_b4ps_23 = strtrim("`b4ps_23'")
		local se4ps_23: display `format' _se[atema_pe_lt]
		local `depvar'_se4ps_23 = "(" + strtrim("`se4ps_23'") + ")"

		
	// middle school
		reghdfe `depvar' atema_st atema_pe_st atema_lt atema_pe_lt $s_controls ///
		if inrange(GRADE_ID_FK,9,10), absorb(GRADE_ID_FK strata) vce(clustervar school_21)
		
		local b1ms_23: display `format' _b[atema_st]
		scalar t_stat1ms_23 = _b[atema_st]/_se[atema_st]
		scalar df1ms_23 = e(df_r)
		scalar pval1ms_23 = 2 * ttail(df1ms_23, abs(t_stat1ms_23))
		if pval1ms_23 < 0.01 local `depvar'_b1ms_23 = strtrim("`b1ms_23'") + "\sym{***}"
		else if pval1ms_23 < 0.05 local `depvar'_b1ms_23 = strtrim("`b1ms_23'") + "\sym{**}"
		else if pval1ms_23 < 0.1 local `depvar'_b1ms_23 = strtrim("`b1ms_23'") + "\sym{*}"
		else local `depvar'_b1ms_23 = strtrim("`b1ms_23'")
		local se1ms_23: display `format' _se[atema_st]
		local `depvar'_se1ms_23 = "(" + strtrim("`se1ms_23'") + ")"
		
		local b2ms_23: display `format' _b[atema_pe_st]
		scalar t_stat2ms_23 = _b[atema_pe_st]/_se[atema_pe_st]
		scalar df2ms_23 = e(df_r)
		scalar pval2ms_23 = 2 * ttail(df2ms_23, abs(t_stat2ms_23))
		if pval2ms_23 < 0.01 local `depvar'_b2ms_23 = strtrim("`b2ms_23'") + "\sym{***}"
		else if pval2ms_23 < 0.05 local `depvar'_b2ms_23 = strtrim("`b2ms_23'") + "\sym{**}"
		else if pval2ms_23 < 0.1 local `depvar'_b2ms_23 = strtrim("`b2ms_23'") + "\sym{*}"
		else local `depvar'_b2ms_23 = strtrim("`b2ms_23'")
		local se2ms_23: display `format' _se[atema_pe_st]
		local `depvar'_se2ms_23 = "(" + strtrim("`se2ms_23'") + ")"
		
		local b3ms_23: display `format' _b[atema_lt]
		scalar t_stat3ms_23 = _b[atema_lt]/_se[atema_lt]
		scalar df3ms_23 = e(df_r)
		scalar pval3ms_23 = 2 * ttail(df3ms_23, abs(t_stat3ms_23))
		if pval3ms_23 < 0.01 local `depvar'_b3ms_23 = strtrim("`b3ms_23'") + "\sym{***}"
		else if pval3ms_23 < 0.05 local `depvar'_b3ms_23 = strtrim("`b3ms_23'") + "\sym{**}"
		else if pval3ms_23 < 0.1 local `depvar'_b3ms_23 = strtrim("`b3ms_23'") + "\sym{*}"
		else local `depvar'_b3ms_23 = strtrim("`b3ms_23'")
		local se3ms_23: display `format' _se[atema_lt]
		local `depvar'_se3ms_23 = "(" + strtrim("`se3ms_23'") + ")"
		
		local b4ms_23: display `format' _b[atema_pe_lt]
		scalar t_stat4ms_23 = _b[atema_pe_lt]/_se[atema_pe_lt]
		scalar df4ms_23 = e(df_r)
		scalar pval4ms_23 = 2 * ttail(df4ms_23, abs(t_stat4ms_23))
		if pval4ms_23 < 0.01 local `depvar'_b4ms_23 = strtrim("`b4ms_23'") + "\sym{***}"
		else if pval4ms_23 < 0.05 local `depvar'_b4ms_23 = strtrim("`b4ms_23'") + "\sym{**}"
		else if pval4ms_23 < 0.1 local `depvar'_b4ms_23 = strtrim("`b4ms_23'") + "\sym{*}"
		else local `depvar'_b4ms_23 = strtrim("`b4ms_23'")
		local se4ms_23: display `format' _se[atema_pe_lt]
		local `depvar'_se4ms_23 = "(" + strtrim("`se4ms_23'") + ")"
		
		test atema_st = atema_pe_st 
		local `depvar'p1_ms: display `format' r(p)
		test atema_st=atema_lt
		local `depvar'p2_ms: display `format' r(p)
		test atema_pe_st=atema_pe_lt
		local `depvar'p3_ms: display `format' r(p)

		
		local `depvar'obsms_23: display %9.0fc e(N)
		
	} 
	
	
foreach depvar of local usage {
	
	// female 
		reghdfe `depvar' atema_st atema_pe_st atema_lt atema_pe_lt $s_controls if gender==1, ///
		absorb(GRADE_ID_FK strata) vce(clustervar school_21)
		
		local b1f_23: display `format' _b[atema_st]
		scalar t_stat1f_23 = _b[atema_st]/_se[atema_st]
		scalar df1f_23 = e(df_r)
		scalar pval1f_23 = 2 * ttail(df1f_23, abs(t_stat1f_23))
		if pval1f_23 < 0.01 local `depvar'_b1f_23 = strtrim("`b1f_23'") + "\sym{***}"
		else if pval1f_23 < 0.05 local `depvar'_b1f_23 = strtrim("`b1f_23'") + "\sym{**}"
		else if pval1f_23 < 0.1 local `depvar'_b1f_23 = strtrim("`b1f_23'") + "\sym{*}"
		else local `depvar'_b1f_23 = strtrim("`b1f_23'")
		local se1f_23: display `format' _se[atema_st]
		local `depvar'_se1f_23 = "(" + strtrim("`se1f_23'") + ")"
		
		local b2f_23: display `format' _b[atema_pe_st]
		scalar t_stat2f_23 = _b[atema_pe_st]/_se[atema_pe_st]
		scalar df2f_23 = e(df_r)
		scalar pval2f_23 = 2 * ttail(df2f_23, abs(t_stat2f_23))
		if pval2f_23 < 0.01 local `depvar'_b2f_23 = strtrim("`b2f_23'") + "\sym{***}"
		else if pval2f_23 < 0.05 local `depvar'_b2f_23 = strtrim("`b2f_23'") + "\sym{**}"
		else if pval2f_23 < 0.1 local `depvar'_b2f_23 = strtrim("`b2f_23'") + "\sym{*}"
		else local `depvar'_b2f_23 = strtrim("`b2f_23'")
		local se2f_23: display `format' _se[atema_pe_st]
		local `depvar'_se2f_23 = "(" + strtrim("`se2f_23'") + ")"
		
		local b3f_23: display `format' _b[atema_lt]
		scalar t_stat3f_23 = _b[atema_lt]/_se[atema_lt]
		scalar df3f_23 = e(df_r)
		scalar pval3f_23 = 2 * ttail(df3f_23, abs(t_stat3f_23))
		if pval3f_23 < 0.01 local `depvar'_b3f_23 = strtrim("`b3f_23'") + "\sym{***}"
		else if pval3f_23 < 0.05 local `depvar'_b3f_23 = strtrim("`b3f_23'") + "\sym{**}"
		else if pval3f_23 < 0.1 local `depvar'_b3f_23 = strtrim("`b3f_23'") + "\sym{*}"
		else local `depvar'_b3f_23 = strtrim("`b3f_23'")
		local se3f_23: display `format' _se[atema_lt]
		local `depvar'_se3f_23 = "(" + strtrim("`se3f_23'") + ")"

		local b4f_23: display `format' _b[atema_pe_lt]
		scalar t_stat4f_23 = _b[atema_pe_lt]/_se[atema_pe_lt]
		scalar df4f_23 = e(df_r)
		scalar pval4f_23 = 2 * ttail(df4f_23, abs(t_stat4f_23))
		if pval4f_23 < 0.01 local `depvar'_b4f_23 = strtrim("`b4f_23'") + "\sym{***}"
		else if pval4f_23 < 0.05 local `depvar'_b4f_23 = strtrim("`b4f_23'") + "\sym{**}"
		else if pval4f_23 < 0.1 local `depvar'_b4f_23 = strtrim("`b4f_23'") + "\sym{*}"
		else local `depvar'_b4f_23 = strtrim("`b4f_23'")
		local se4f_23: display `format' _se[atema_pe_lt]
		local `depvar'_se4f_23 = "(" + strtrim("`se4f_23'") + ")"
		
		test atema_st = atema_pe_st 
		local `depvar'p1_f: display `format' r(p)
		test atema_st=atema_lt
		local `depvar'p2_f: display `format' r(p)
		test atema_pe_st=atema_pe_lt
		local `depvar'p3_f: display `format' r(p)

		
		local `depvar'obsf_23: display %9.0fc e(N)
		
	// male 
		reghdfe `depvar' atema_st atema_pe_st atema_lt atema_pe_lt $s_controls if gender==0, ///
		absorb(GRADE_ID_FK strata) vce(clustervar school_21)
		
		local b1m_23: display `format' _b[atema_st]
		scalar t_stat1m_23 = _b[atema_st]/_se[atema_st]
		scalar df1m_23 = e(df_r)
		scalar pval1m_23 = 2 * ttail(df1m_23, abs(t_stat1m_23))
		if pval1m_23 < 0.01 local `depvar'_b1m_23 = strtrim("`b1m_23'") + "\sym{***}"
		else if pval1m_23 < 0.05 local `depvar'_b1m_23 = strtrim("`b1m_23'") + "\sym{**}"
		else if pval1m_23 < 0.1 local `depvar'_b1m_23 = strtrim("`b1m_23'") + "\sym{*}"
		else local `depvar'_b1m_23 = strtrim("`b1m_23'")
		local se1m_23: display `format' _se[atema_st]
		local `depvar'_se1m_23 = "(" + strtrim("`se1m_23'") + ")"
		
		local b2m_23: display `format' _b[atema_pe_st]
		scalar t_stat2m_23 = _b[atema_pe_st]/_se[atema_pe_st]
		scalar df2m_23 = e(df_r)
		scalar pval2m_23 = 2 * ttail(df2m_23, abs(t_stat2m_23))
		if pval2m_23 < 0.01 local `depvar'_b2m_23 = strtrim("`b2m_23'") + "\sym{***}"
		else if pval2m_23 < 0.05 local `depvar'_b2m_23 = strtrim("`b2m_23'") + "\sym{**}"
		else if pval2m_23 < 0.1 local `depvar'_b2m_23 = strtrim("`b2m_23'") + "\sym{*}"
		else local `depvar'_b2m_23 = strtrim("`b2m_23'")
		local se2m_23: display `format' _se[atema_pe_st]
		local `depvar'_se2m_23 = "(" + strtrim("`se2m_23'") + ")"
		
		local b3m_23: display `format' _b[atema_lt]
		scalar t_stat3m_23 = _b[atema_lt]/_se[atema_lt]
		scalar df3m_23 = e(df_r)
		scalar pval3m_23 = 2 * ttail(df3m_23, abs(t_stat3m_23))
		if pval3m_23 < 0.01 local `depvar'_b3m_23 = strtrim("`b3m_23'") + "\sym{***}"
		else if pval3m_23 < 0.05 local `depvar'_b3m_23 = strtrim("`b3m_23'") + "\sym{**}"
		else if pval3m_23 < 0.1 local `depvar'_b3m_23 = strtrim("`b3m_23'") + "\sym{*}"
		else local `depvar'_b3m_23 = strtrim("`b3m_23'")
		local se3m_23: display `format' _se[atema_lt]
		local `depvar'_se3m_23 = "(" + strtrim("`se3m_23'") + ")"
		
		local b4m_23: display `format' _b[atema_pe_lt]
		scalar t_stat4m_23 = _b[atema_pe_lt]/_se[atema_pe_lt]
		scalar df4m_23 = e(df_r)
		scalar pval4m_23 = 2 * ttail(df4m_23, abs(t_stat4m_23))
		if pval4m_23 < 0.01 local `depvar'_b4m_23 = strtrim("`b4m_23'") + "\sym{***}"
		else if pval4m_23 < 0.05 local `depvar'_b4m_23 = strtrim("`b4m_23'") + "\sym{**}"
		else if pval4m_23 < 0.1 local `depvar'_b4m_23 = strtrim("`b4m_23'") + "\sym{*}"
		else local `depvar'_b4m_23 = strtrim("`b4m_23'")
		local se4m_23: display `format' _se[atema_pe_lt]
		local `depvar'_se4m_23 = "(" + strtrim("`se4m_23'") + ")"
		
		test atema_st = atema_pe_st 
		local `depvar'p1_m: display `format' r(p)
		test atema_st=atema_lt
		local `depvar'p2_m: display `format' r(p)
		test atema_pe_st=atema_pe_lt
		local `depvar'p3_m: display `format' r(p)

		
		local `depvar'obsm_23: display %9.0fc e(N)
	
}
	

foreach depvar of local usage { 

	// above-median 
		reghdfe `depvar' atema_st atema_pe_st atema_lt atema_pe_lt $s_controls if above_median==1, ///
		absorb(GRADE_ID_FK strata) vce(clustervar school_21)
		
		local b1am_23: display `format' _b[atema_st]
		scalar t_stat1am_23 = _b[atema_st]/_se[atema_st]
		scalar df1am_23 = e(df_r)
		scalar pval1am_23 = 2 * ttail(df1am_23, abs(t_stat1am_23))
		if pval1am_23 < 0.01 local `depvar'_b1am_23 = strtrim("`b1am_23'") + "\sym{***}"
		else if pval1am_23 < 0.05 local `depvar'_b1am_23 = strtrim("`b1am_23'") + "\sym{**}"
		else if pval1am_23 < 0.1 local `depvar'_b1am_23 = strtrim("`b1am_23'") + "\sym{*}"
		else local `depvar'_b1am_23 = strtrim("`b1am_23'")
		local se1am_23: display `format' _se[atema_st]
		local `depvar'_se1am_23 = "(" + strtrim("`se1am_23'") + ")"
		
		local b2am_23: display `format' _b[atema_pe_st]
		scalar t_stat2am_23 = _b[atema_pe_st]/_se[atema_pe_st]
		scalar df2am_23 = e(df_r)
		scalar pval2am_23 = 2 * ttail(df2am_23, abs(t_stat2am_23))
		if pval2am_23 < 0.01 local `depvar'_b2am_23 = strtrim("`b2am_23'") + "\sym{***}"
		else if pval2am_23 < 0.05 local `depvar'_b2am_23 = strtrim("`b2am_23'") + "\sym{**}"
		else if pval2am_23 < 0.1 local `depvar'_b2am_23 = strtrim("`b2am_23'") + "\sym{*}"
		else local `depvar'_b2am_23 = strtrim("`b2am_23'")
		local se2am_23: display `format' _se[atema_pe_st]
		local `depvar'_se2am_23 = "(" + strtrim("`se2am_23'") + ")"
		
		local b3am_23: display `format' _b[atema_lt]
		scalar t_stat3am_23 = _b[atema_lt]/_se[atema_lt]
		scalar df3am_23 = e(df_r)
		scalar pval3am_23 = 2 * ttail(df3am_23, abs(t_stat3am_23))
		if pval3am_23 < 0.01 local `depvar'_b3am_23 = strtrim("`b3am_23'") + "\sym{***}"
		else if pval3am_23 < 0.05 local `depvar'_b3am_23 = strtrim("`b3am_23'") + "\sym{**}"
		else if pval3am_23 < 0.1 local `depvar'_b3am_23 = strtrim("`b3am_23'") + "\sym{*}"
		else local `depvar'_b3am_23 = strtrim("`b3am_23'")
		local se3am_23: display `format' _se[atema_lt]
		local `depvar'_se3am_23 = "(" + strtrim("`se3am_23'") + ")"
		
		local b4am_23: display `format' _b[atema_pe_lt]
		scalar t_stat4am_23 = _b[atema_pe_lt]/_se[atema_pe_lt]
		scalar df4am_23 = e(df_r)
		scalar pval4am_23 = 2 * ttail(df4am_23, abs(t_stat4am_23))
		if pval4am_23 < 0.01 local `depvar'_b4am_23 = strtrim("`b4am_23'") + "\sym{***}"
		else if pval4am_23 < 0.05 local `depvar'_b4am_23 = strtrim("`b4am_23'") + "\sym{**}"
		else if pval4am_23 < 0.1 local `depvar'_b4am_23 = strtrim("`b4am_23'") + "\sym{*}"
		else local `depvar'_b4am_23 = strtrim("`b4am_23'")
		local se4am_23: display `format' _se[atema_pe_lt]
		local `depvar'_se4am_23 = "(" + strtrim("`se4am_23'") + ")"

		test atema_st = atema_pe_st 
		local `depvar'p1_am: display `format' r(p)
		test atema_st=atema_lt
		local `depvar'p2_am: display `format' r(p)
		test atema_pe_st=atema_pe_lt
		local `depvar'p3_am: display `format' r(p)

		local `depvar'obsam_23: display %9.0fc e(N)
	
	// below-median 
		reghdfe `depvar' atema_st atema_pe_st atema_lt atema_pe_lt $s_controls if above_median==0, ///
		absorb(GRADE_ID_FK strata) vce(clustervar school_21)
		
		local b1bm_23: display `format' _b[atema_st]
		scalar t_stat1bm_23 = _b[atema_st]/_se[atema_st]
		scalar df1bm_23 = e(df_r)
		scalar pval1bm_23 = 2 * ttail(df1bm_23, abs(t_stat1bm_23))
		if pval1bm_23 < 0.01 local `depvar'_b1bm_23 = strtrim("`b1bm_23'") + "\sym{***}"
		else if pval1bm_23 < 0.05 local `depvar'_b1bm_23 = strtrim("`b1bm_23'") + "\sym{**}"
		else if pval1bm_23 < 0.1 local `depvar'_b1bm_23 = strtrim("`b1bm_23'") + "\sym{*}"
		else local `depvar'_b1bm_23 = strtrim("`b1bm_23'")
		local se1bm_23: display `format' _se[atema_st]
		local `depvar'_se1bm_23 = "(" + strtrim("`se1bm_23'") + ")"
		
		local b2bm_23: display `format' _b[atema_pe_st]
		scalar t_stat2bm_23 = _b[atema_pe_st]/_se[atema_pe_st]
		scalar df2bm_23 = e(df_r)
		scalar pval2bm_23 = 2 * ttail(df2bm_23, abs(t_stat2bm_23))
		if pval2bm_23 < 0.01 local `depvar'_b2bm_23 = strtrim("`b2bm_23'") + "\sym{***}"
		else if pval2bm_23 < 0.05 local `depvar'_b2bm_23 = strtrim("`b2bm_23'") + "\sym{**}"
		else if pval2bm_23 < 0.1 local `depvar'_b2bm_23 = strtrim("`b2bm_23'") + "\sym{*}"
		else local `depvar'_b2bm_23 = strtrim("`b2bm_23'")
		local se2bm_23: display `format' _se[atema_pe_st]
		local `depvar'_se2bm_23 = "(" + strtrim("`se2bm_23'") + ")"
		
		local b3bm_23: display `format' _b[atema_lt]
		scalar t_stat3bm_23 = _b[atema_lt]/_se[atema_lt]
		scalar df3bm_23 = e(df_r)
		scalar pval3bm_23 = 2 * ttail(df3bm_23, abs(t_stat3bm_23))
		if pval3bm_23 < 0.01 local `depvar'_b3bm_23 = strtrim("`b3bm_23'") + "\sym{***}"
		else if pval3bm_23 < 0.05 local `depvar'_b3bm_23 = strtrim("`b3bm_23'") + "\sym{**}"
		else if pval3bm_23 < 0.1 local `depvar'_b3bm_23 = strtrim("`b3bm_23'") + "\sym{*}"
		else local `depvar'_b3bm_23 = strtrim("`b3bm_23'")
		local se3bm_23: display `format' _se[atema_lt]
		local `depvar'_se3bm_23 = "(" + strtrim("`se3bm_23'") + ")"
		
		local b4bm_23: display `format' _b[atema_pe_lt]
		scalar t_stat4bm_23 = _b[atema_pe_lt]/_se[atema_pe_lt]
		scalar df4bm_23 = e(df_r)
		scalar pval4bm_23 = 2 * ttail(df4bm_23, abs(t_stat4bm_23))
		if pval4bm_23 < 0.01 local `depvar'_b4bm_23 = strtrim("`b4bm_23'") + "\sym{***}"
		else if pval4bm_23 < 0.05 local `depvar'_b4bm_23 = strtrim("`b4bm_23'") + "\sym{**}"
		else if pval4bm_23 < 0.1 local `depvar'_b4bm_23 = strtrim("`b4bm_23'") + "\sym{*}"
		else local `depvar'_b4bm_23 = strtrim("`b4bm_23'")
		local se4bm_23: display `format' _se[atema_pe_lt]
		local `depvar'_se4bm_23 = "(" + strtrim("`se4bm_23'") + ")"

		test atema_st = atema_pe_st 
		local `depvar'p1_bm: display `format' r(p)
		test atema_st=atema_lt
		local `depvar'p2_bm: display `format' r(p)
		test atema_pe_st=atema_pe_lt
		local `depvar'p3_bm: display `format' r(p)
		
		local `depvar'obsbm_23: display %9.0fc e(N)
	
}



texdoc init "$output\tables\appendix\6. heterogeneity RFE (pooled B) new.tex", replace force 
	tex \begin{table}[htbp]
	tex \centering
	tex \resizebox{\linewidth}{!}{%
	tex \begin{threeparttable}
	tex \caption{\textbf{Reduced Form Effects on Math Scores}}
	tex \fontsize{10}{11}\selectfont
	tex \begin{tabular}{l*{6}c}
	tex \hline\hline
	tex &\multicolumn{1}{c}{All} &\multicolumn{1}{c}{Female} &\multicolumn{1}{c}{Male} &\multicolumn{1}{c}{Primary school} &\multicolumn{1}{c}{Middle school} &\multicolumn{1}{c}{Above-median school} &\multicolumn{1}{c}{Below-median school}  \\
	tex &\multicolumn{1}{c}{(1)} &\multicolumn{1}{c}{(2)} &\multicolumn{1}{c}{(3)} &\multicolumn{1}{c}{(4)} &\multicolumn{1}{c}{(5)} &\multicolumn{1}{c}{(6)} &\multicolumn{1}{c}{(7)} \\

	tex \hline \\
	tex [1ex] 
	
	tex $\beta_1$: Treatment (Short-term) & `math_score_b1_23' & `math_score_b1f_23' & `math_score_b1m_23' & `math_score_b1ps_23' & `math_score_b1ms_23' & `math_score_b1am_23' & `math_score_b1bm_23' \\
	tex & `math_score_se1_23' & `math_score_se1f_23' & `math_score_se1m_23' & `math_score_se1ps_23' & `math_score_se1ms_23' & `math_score_se1am_23' & `math_score_se1bm_23' \\
	tex [1ex] 
	
	tex $\beta_2$: Parental Engagement (Short-term) & `math_score_b2_23' & `math_score_b2f_23' & `math_score_b2m_23' & `math_score_b2ps_23' & `math_score_b2ms_23' & `math_score_b2am_23' & `math_score_b2bm_23' \\
	tex & `math_score_se2_23' & `math_score_se2f_23' & `math_score_se2m_23' & `math_score_se2ps_23' & `math_score_se2ms_23' & `math_score_se2am_23' & `math_score_se2bm_23' \\
	tex [1ex] 
	
	tex $\beta_3$: Treatment (Long-term) & `math_score_b3_23' & `math_score_b3f_23' & `math_score_b3m_23' & `math_score_b3ps_23' & `math_score_b3ms_23' & `math_score_b3am_23' & `math_score_b3bm_23' \\
	tex & `math_score_se3_23' & `math_score_se3f_23' & `math_score_se3m_23' & `math_score_se3ps_23' & `math_score_se3ms_23' & `math_score_se3am_23' & `math_score_se2bm_23' \\
	tex [1ex] 
	
	tex $\beta_4$: Parental Engagement (Long-term) & `math_score_b4_23' & `math_score_b4f_23' & `math_score_b4m_23' & `math_score_b4ps_23' & `math_score_b4ms_23' & `math_score_b4am_23' & `math_score_b4bm_23' \\
	tex & `math_score_se4_23' & `math_score_se4f_23' & `math_score_se4m_23' & `math_score_se4ps_23' & `math_score_se4ms_23' & `math_score_se4am_23' & `math_score_se4bm_23' \\
	tex [1ex]
	
	tex \hline \\
	tex [1ex] 
	
	tex $\H_0: \beta_1 = \beta_2$ & `math_scorep1_all' & `math_scorep1_f' & `math_scorep1_m' & `math_scorep1_ps' & `math_scorep1_ms' & `math_scorep1_am' & `math_scorep1_bm' \\
	tex [1ex] 
	
	tex $\H_0: \beta_1 = \beta_3$ & `math_scorep2_all' & `math_scorep2_f' & `math_scorep2_m' & `math_scorep2_ps' & `math_scorep2_ms' & `math_scorep2_am' & `math_scorep2_bm' \\
	tex [1ex] 
	
	tex $\H_0: \beta_2 = \beta_4$ & `math_scorep3_all' & `math_scorep3_f' & `math_scorep3_m' & `math_scorep3_ps' & `math_scorep3_ms' & `math_scorep3_am' & `math_scorep3_bm' \\
	tex [1ex] 
	
	tex \hline \\ 
	tex [1ex]
	
	tex Control mean & `math_scorec_M' & `math_scorec_Mf' & `math_scorec_Mm' & `math_scorec_Mps' & `math_scorec_Mms' & `math_scorec_Mam' & `math_scorec_Mbm' \\
	tex & `math_scorec_SD' & `math_scorec_SDf' & `math_scorec_SDm' & `math_scorec_SDps' & `math_scorec_SDms' & `math_scorec_SDam' & `math_scorec_SDbm' \\
	tex [1ex]
			
	tex N & `math_scoreobs_23' & `math_scoreobsf_23' & `math_scoreobsm_23' & `math_scoreobsps_23' & `math_scoreobsms_23' & `math_scoreobsam_23' & `math_scoreobsbm_23' \\
	tex[1ex] 
	tex \hline\hline
	
	tex \end{tabular}
	tex \begin{tablenotes}[para, flushleft]
	tex \scriptsize
	tex \note Robust standard errors of variables are clustered by school and reported in brackets. \sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\). Adjusted for stratum-year and grade fixed effects.  
	tex \end{tablenotes}
	tex \end{threeparttable}
	tex }
	tex \end{table}	
	
texdoc close	





