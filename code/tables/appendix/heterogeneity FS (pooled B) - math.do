//----------------------------------------------------------------------------//
// File name: 5. heterogeneity FS (pooled B)
// Last updated: Nov 4, 2024 by Sara Mostafa
//----------------------------------------------------------------------------//


clear all
set matsize 6000
set more off 
global dir "D:\SECURE\data 2024\analysis\atema" 
global input "$dir\data" 
global output "$dir\output"

cap log close
log using "$output\Logs\tables\appendix\heterogeneity FS (pooled B) math.txt", text replace


use "$input\master_khan_student_combined", clear 
	
keep if math_score!=.	
	
rename strata old_strata
egen strata = group(old_strata ACADEMIC_YEAR_ID_FK)
	
gen control_pooled = 0 
	replace control_pooled = 1 if (control == 1 | (treat_arm_3 == 1 & ACADEMIC_YEAR_ID_FK == 2022) ///
	| (treat_arm_4 == 1 & ACADEMIC_YEAR_ID_FK == 2022))
	

//============================================================================//
// Year-Specific 
//============================================================================//
local format "%9.3fc" 
local usage "takeup"


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

	// primary school 
		reghdfe `depvar' atema_st atema_pe_st atema_lt atema_pe_lt ///
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
		test atema_st = atema_lt 
		local `depvar'p2_ps: display `format' r(p)
		test atema_pe_st = atema_pe_lt 
		local `depvar'p3_ps: display `format' r(p)
		
		local `depvar'obsps_23: display %9.0fc e(N)
		
		reghdfe `depvar' atema_st atema_pe_st atema_lt atema_pe_lt ///
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
		reghdfe `depvar' atema_st atema_pe_st atema_lt atema_pe_lt if inrange(GRADE_ID_FK,9,10), ///
		absorb(GRADE_ID_FK strata) vce(clustervar school_21)
		
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
		test atema_st = atema_lt 
		local `depvar'p2_ms: display `format' r(p)
		test atema_pe_st = atema_pe_lt 
		local `depvar'p3_ms: display `format' r(p)
		
		local `depvar'obsms_23: display %9.0fc e(N)
		
	} 
	
	
foreach depvar of local usage {
	
	// female 
		reghdfe `depvar' atema_st atema_pe_st atema_lt atema_pe_lt if gender==1, ///
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
		test atema_st = atema_lt 
		local `depvar'p2_f: display `format' r(p)
		test atema_pe_st = atema_pe_lt 
		local `depvar'p3_f: display `format' r(p)
		
		local `depvar'obsf_23: display %9.0fc e(N)
		
	// male 
		reghdfe `depvar' atema_st atema_pe_st atema_lt atema_pe_lt if gender==0, ///
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
		test atema_st = atema_lt 
		local `depvar'p2_m: display `format' r(p)
		test atema_pe_st = atema_pe_lt 
		local `depvar'p3_m: display `format' r(p)
		
		local `depvar'obsm_23: display %9.0fc e(N)
	
}
	

foreach depvar of local usage { 

	// above-median 
		reghdfe `depvar' atema_st atema_pe_st atema_lt atema_pe_lt if above_median==1, ///
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
		test atema_st = atema_lt 
		local `depvar'p2_am: display `format' r(p)
		test atema_pe_st = atema_pe_lt 
		local `depvar'p3_am: display `format' r(p)

		local `depvar'obsam_23: display %9.0fc e(N)
	
	// below-median 
		reghdfe `depvar' atema_st atema_pe_st atema_lt atema_pe_lt if above_median==0, ///
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
		test atema_st = atema_lt 
		local `depvar'p2_bm: display `format' r(p)
		test atema_pe_st = atema_pe_lt 
		local `depvar'p3_bm: display `format' r(p)

		
		local `depvar'obsbm_23: display %9.0fc e(N)
	
}
 


texdoc init "$output\tables\appendix\heterogeneity FS (pooled B) math.tex", replace force 
	tex \begin{table}[htbp]
	tex \centering
	tex \resizebox{\linewidth}{!}{%
	tex \begin{threeparttable}
	tex \caption{\textbf{First Stage}}
	tex \fontsize{10}{11}\selectfont
	tex \begin{tabular}{l*{6}c}
	tex \hline\hline
	tex &\multicolumn{1}{c}{Female} &\multicolumn{1}{c}{Male} &\multicolumn{1}{c}{Primary school} &\multicolumn{1}{c}{Middle school} &\multicolumn{1}{c}{Above-median school} &\multicolumn{1}{c}{Below-median school}\\
	tex &\multicolumn{1}{c}{(1)} &\multicolumn{1}{c}{(2)} &\multicolumn{1}{c}{(3)} &\multicolumn{1}{c}{(4)} &\multicolumn{1}{c}{(5)} &\multicolumn{1}{c}{(6)} \\

	tex \hline \\
	tex [1ex]
	
	tex \multicolumn{7}{c}{\textbf{At least 5 minutes per week}} \\
	tex [1ex] 
		
	tex $\beta_1$: Treatment (Short-term) & `takeup_b1f_23' & `takeup_b1m_23' & `takeup_b1ps_23' & `takeup_b1ms_23' & `takeup_b1am_23' & `takeup_b1bm_23' \\
	tex & `takeup_se1f_23' & `takeup_se1m_23' & `takeup_se1ps_23' & `takeup_se1ms_23' & `takeup_se1am_23' & `takeup_se1bm_23' \\
	tex [1ex] 
	
	tex $\beta_2$: Parental engagement (Short-term) & `takeup_b2f_23' & `takeup_b2m_23' & `takeup_b2ps_23' & `takeup_b2ms_23' & `takeup_b2am_23' & `takeup_b2bm_23' \\
	tex & `takeup_se2f_23' & `takeup_se2m_23' & `takeup_se2ps_23' & `takeup_se2ms_23' & `takeup_se2am_23' & `takeup_se2bm_23' \\
	tex [1ex] 
	
	tex $\beta_3$: Treatment (Long-term) & `takeup_b3f_23' & `takeup_b3m_23' & `takeup_b3ps_23' & `takeup_b3ms_23' & `takeup_b3am_23' & `takeup_b3bm_23' \\
	tex & `takeup_se3f_23' & `takeup_se3m_23' & `takeup_se3ps_23' & `takeup_se3ms_23' & `takeup_se3am_23' & `takeup_se3bm_23' \\
	tex [1ex] 
	
	tex $\beta_4$: Parental engagement (Long-term) & `takeup_b4f_23' & `takeup_b4m_23' & `takeup_b4ps_23' & `takeup_b4ms_23' & `takeup_b4am_23' & `takeup_b4bm_23' \\
	tex & `takeup_se4f_23' & `takeup_se4m_23' & `takeup_se4ps_23' & `takeup_se4ms_23' & `takeup_se4am_23' & `takeup_se4bm_23' \\
	tex [1ex] 
	
	tex \hline \\ 
	tex [1ex] 
	
	tex $\H_0: \beta_1 = \beta_2$ & `takeupp1_f' & `takeupp1_m' & `takeupp1_ps' & `takeupp1_ms' & `takeupp1_am' & `takeupp1_bm'
	tex[1ex] 
	
	tex $\H_0: \beta_1 = \beta_3$ & `takeupp2_f' & `takeupp2_m' & `takeupp2_ps' & `takeupp2_ms' & `takeupp2_am' & `takeupp2_bm'
	tex[1ex]
	
	tex $\H_0: \beta_2 = \beta_4$ & `takeupp3_f' & `takeupp3_m' & `takeupp3_ps' & `takeupp3_ms' & `takeupp3_am' & `takeupp3_bm'
	tex[1ex]
	
	tex \hline \\ 
	tex [1ex] 
	
	tex Control mean & `takeupc_Mf' & `takeupc_Mm' & `takeupc_Mps' & `takeupc_Mms' & `takeupc_Mam' & `takeupc_Mbm' \\
	tex & `takeupc_SDf' & `takeupc_SDm' & `takeupc_SDps' & `takeupc_SDms' & `takeupc_SDam' & `takeupc_SDbm' \\
	tex [1ex]
	
	tex N & `takeupobsf_23' & `takeupobsm_23' & `takeupobsps_23' & `takeupobsms_23' & `takeupobsam_23' & `takeupobsbm_23' \\
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





