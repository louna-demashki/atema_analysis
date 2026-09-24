//----------------------------------------------------------------------------//
// File name: 02. first stage
// Last updated: Nov. 7, 2024 by Sara Mostafa
//----------------------------------------------------------------------------//


clear all
set matsize 6000
set more off 
global dir "D:\SECURE\data 2024\analysis\atema" 
global input "$dir\data" 
global output "$dir\output"

cap log close
log using "$output\Logs\tables\main\02. first stage.txt", text replace


use "$input\master_khan_student_combined", clear 

rename total_math_learning_minutes learn_min 
rename total_skills_leveled_up skills
//rename total_upskill_familiar familiar

	
rename strata old_strata
egen strata = group(old_strata ACADEMIC_YEAR_ID_FK)
			

//============================================================================//
// Control means
//============================================================================//
local format "%9.3fc" 
local usage "student_login takeup learn_min skills"


foreach depvar of local usage {

	qui: sum `depvar' if (control==1 | treat_arm_3==1 | treat_arm_4==1) & ///
	ACADEMIC_YEAR_ID_FK==2022
    local `depvar'c_22: display `format' r(mean)
	
	qui: sum `depvar' if control==1 & ACADEMIC_YEAR_ID_FK==2023
    local `depvar'c_23: display `format' r(mean)
	
	}
	
	qui: sum takeup if (control==1 | treat_arm_3==1 | treat_arm_4==1) & ///
	ACADEMIC_YEAR_ID_FK==2022 & above_median==1
    local takeupc_22_am: display `format' r(mean)
	
	qui: sum takeup if (control==1 | treat_arm_3==1 | treat_arm_4==1) & ///
	ACADEMIC_YEAR_ID_FK==2022 & above_median==0
    local takeupc_22_bm: display `format' r(mean)
	
	qui: sum takeup if control==1 & ACADEMIC_YEAR_ID_FK==2023 & above_median==1
    local takeupc_23_am: display `format' r(mean)
	
	qui: sum takeup if control==1 & ACADEMIC_YEAR_ID_FK==2023 & above_median==0
    local takeupc_23_bm: display `format' r(mean)

 

//============================================================================//
// All Students
//============================================================================//

foreach depvar of local usage {

		reghdfe `depvar' atema_st atema_pe_st atema_lt atema_pe_lt, ///
		absorb(grade_21 strata) vce(clustervar school_21)
		
		local b1: display `format' _b[atema_st]
		scalar t_stat1 = _b[atema_st]/_se[atema_st]
		scalar df1 = e(df_r)
		scalar pval1 = 2 * ttail(df1, abs(t_stat1))
		if pval1 < 0.01 local `depvar'_b1 = strtrim("`b1'") + "\sym{***}"
		else if pval1 < 0.05 local `depvar'_b1 = strtrim("`b1'") + "\sym{**}"
		else if pval1 < 0.1 local `depvar'_b1 = strtrim("`b1'") + "\sym{*}"
		else local `depvar'_b1 = strtrim("`b1'")
		local se1: display `format' _se[atema_st]
		local `depvar'_se1 = "(" + strtrim("`se1'") + ")"
		
		local b2: display `format' _b[atema_pe_st]
		scalar t_stat2 = _b[atema_pe_st]/_se[atema_pe_st]
		scalar df2 = e(df_r)
		scalar pval2 = 2 * ttail(df2, abs(t_stat2))
		if pval2 < 0.01 local `depvar'_b2 = strtrim("`b2'") + "\sym{***}"
		else if pval2 < 0.05 local `depvar'_b2 = strtrim("`b2'") + "\sym{**}"
		else if pval2 < 0.1 local `depvar'_b2 = strtrim("`b2'") + "\sym{*}"
		else local `depvar'_b2 = strtrim("`b2'")
		local se2: display `format' _se[atema_pe_st]
		local `depvar'_se2 = "(" + strtrim("`se2'") + ")"
		
		local b3: display `format' _b[atema_lt]
		scalar t_stat3 = _b[atema_lt]/_se[atema_lt]
		scalar df3 = e(df_r)
		scalar pval3 = 2 * ttail(df3, abs(t_stat3))
		if pval3 < 0.01 local `depvar'_b3 = strtrim("`b3'") + "\sym{***}"
		else if pval3 < 0.05 local `depvar'_b3 = strtrim("`b3'") + "\sym{**}"
		else if pval3 < 0.1 local `depvar'_b3 = strtrim("`b3'") + "\sym{*}"
		else local `depvar'_b3 = strtrim("`b3'")
		local se3: display `format' _se[atema_lt]
		local `depvar'_se3 = "(" + strtrim("`se3'") + ")"

		local b4: display `format' _b[atema_pe_lt]
		scalar t_stat4 = _b[atema_pe_lt]/_se[atema_pe_lt]
		scalar df4 = e(df_r)
		scalar pval4 = 2 * ttail(df4, abs(t_stat4))
		if pval4 < 0.01 local `depvar'_b4 = strtrim("`b4'") + "\sym{***}"
		else if pval4 < 0.05 local `depvar'_b4 = strtrim("`b4'") + "\sym{**}"
		else if pval4 < 0.1 local `depvar'_b4 = strtrim("`b4'") + "\sym{*}"
		else local `depvar'_b4 = strtrim("`b4'")
		local se4: display `format' _se[atema_pe_lt]
		local `depvar'_se4 = "(" + strtrim("`se4'") + ")"
		
		local `depvar'obs: display %9.0fc e(N)
		
		test atema_st=atema_pe_st
		local `depvar'p1: di `format' r(p)
		
		test atema_st=atema_lt
		local `depvar'p2: di `format' r(p)
		
		test atema_pe_st=atema_pe_lt
		local `depvar'p3: di `format' r(p)
		
}



//============================================================================//
// Above-median schools take-up
//============================================================================//

reghdfe takeup atema_st atema_pe_st atema_lt atema_pe_lt if above_median==1, ///
absorb(grade_21 strata) vce(clustervar school_21)
		
		local b1_am: display `format' _b[atema_st]
		scalar t_stat1_am = _b[atema_st]/_se[atema_st]
		scalar df1_am = e(df_r)
		scalar pval1_am = 2 * ttail(df1_am, abs(t_stat1_am))
		if pval1_am < 0.01 local takeup_b1_am = strtrim("`b1_am'") + "\sym{***}"
		else if pval1_am < 0.05 local takeup_b1_am = strtrim("`b1_am'") + "\sym{**}"
		else if pval1_am < 0.1 local takeup_b1_am = strtrim("`b1_am'") + "\sym{*}"
		else local takeup_b1_am = strtrim("`b1_am'")
		local se1_am: display `format' _se[atema_st]
		local takeup_se1_am = "(" + strtrim("`se1_am'") + ")"
		
		local b2_am: display `format' _b[atema_pe_st]
		scalar t_stat2_am = _b[atema_pe_st]/_se[atema_pe_st]
		scalar df2_am = e(df_r)
		scalar pval2_am = 2 * ttail(df2_am, abs(t_stat2_am))
		if pval2_am < 0.01 local takeup_b2_am = strtrim("`b2_am'") + "\sym{***}"
		else if pval2_am < 0.05 local takeup_b2_am = strtrim("`b2_am'") + "\sym{**}"
		else if pval2_am < 0.1 local takeup_b2_am = strtrim("`b2_am'") + "\sym{*}"
		else local takeup_b2_am = strtrim("`b2_am'")
		local se2_am: display `format' _se[atema_pe_st]
		local takeup_se2_am = "(" + strtrim("`se2_am'") + ")"
		
		local b3_am: display `format' _b[atema_lt]
		scalar t_stat3_am = _b[atema_lt]/_se[atema_lt]
		scalar df3_am = e(df_r)
		scalar pval3_am = 2 * ttail(df3_am, abs(t_stat3_am))
		if pval3_am < 0.01 local takeup_b3_am = strtrim("`b3_am'") + "\sym{***}"
		else if pval3_am < 0.05 local takeup_b3_am = strtrim("`b3_am'") + "\sym{**}"
		else if pval3_am < 0.1 local takeup_b3_am = strtrim("`b3_am'") + "\sym{*}"
		else local takeup_b3_am = strtrim("`b3_am'")
		local se3_am: display `format' _se[atema_lt]
		local takeup_se3_am = "(" + strtrim("`se3_am'") + ")"

		local b4_am: display `format' _b[atema_pe_lt]
		scalar t_stat4_am = _b[atema_pe_lt]/_se[atema_pe_lt]
		scalar df4_am = e(df_r)
		scalar pval4_am = 2 * ttail(df4_am, abs(t_stat4_am))
		if pval4_am < 0.01 local takeup_b4_am = strtrim("`b4_am'") + "\sym{***}"
		else if pval4_am < 0.05 local takeup_b4_am = strtrim("`b4_am'") + "\sym{**}"
		else if pval4_am < 0.1 local takeup_b4_am = strtrim("`b4_am'") + "\sym{*}"
		else local takeup_b4_am = strtrim("`b4_am'")
		local se4_am: display `format' _se[atema_pe_lt]
		local takeup_se4_am = "(" + strtrim("`se4_am'") + ")"
		
		local takeupobs_am: display %9.0fc e(N)
		
		test atema_st=atema_pe_st
		local takeupp1_am: di `format' r(p)
		
		test atema_st=atema_lt
		local takeupp2_am: di `format' r(p)
		
		test atema_pe_st=atema_pe_lt
		local takeupp3_am: di `format' r(p)
		




//============================================================================//
// Below-median schools take-up
//============================================================================//

reghdfe takeup atema_st atema_pe_st atema_lt atema_pe_lt if above_median==0, ///
absorb(grade_21 strata) vce(clustervar school_21)
		
		local b1_bm: display `format' _b[atema_st]
		scalar t_stat1_bm = _b[atema_st]/_se[atema_st]
		scalar df1_bm = e(df_r)
		scalar pval1_bm = 2 * ttail(df1_bm, abs(t_stat1_bm))
		if pval1_bm < 0.01 local takeup_b1_bm = strtrim("`b1_bm'") + "\sym{***}"
		else if pval1_bm < 0.05 local takeup_b1_bm = strtrim("`b1_bm'") + "\sym{**}"
		else if pval1_bm < 0.1 local takeup_b1_bm = strtrim("`b1_bm'") + "\sym{*}"
		else local takeup_b1_bm = strtrim("`b1_bm'")
		local se1_bm: display `format' _se[atema_st]
		local takeup_se1_bm = "(" + strtrim("`se1_bm'") + ")"
		
		local b2_bm: display `format' _b[atema_pe_st]
		scalar t_stat2_bm = _b[atema_pe_st]/_se[atema_pe_st]
		scalar df2_bm = e(df_r)
		scalar pval2_bm = 2 * ttail(df2_bm, abs(t_stat2_bm))
		if pval2_bm < 0.01 local takeup_b2_bm = strtrim("`b2_bm'") + "\sym{***}"
		else if pval2_bm < 0.05 local takeup_b2_bm = strtrim("`b2_bm'") + "\sym{**}"
		else if pval2_bm < 0.1 local takeup_b2_bm = strtrim("`b2_bm'") + "\sym{*}"
		else local takeup_b2_bm = strtrim("`b2_bm'")
		local se2_bm: display `format' _se[atema_pe_st]
		local takeup_se2_bm = "(" + strtrim("`se2_bm'") + ")"
		
		local b3_bm: display `format' _b[atema_lt]
		scalar t_stat3_bm = _b[atema_lt]/_se[atema_lt]
		scalar df3_bm = e(df_r)
		scalar pval3_bm = 2 * ttail(df3_bm, abs(t_stat3_bm))
		if pval3_bm < 0.01 local takeup_b3_bm = strtrim("`b3_bm'") + "\sym{***}"
		else if pval3_bm < 0.05 local takeup_b3_bm = strtrim("`b3_bm'") + "\sym{**}"
		else if pval3_bm < 0.1 local takeup_b3_bm = strtrim("`b3_bm'") + "\sym{*}"
		else local takeup_b3_bm = strtrim("`b3_bm'")
		local se3_bm: display `format' _se[atema_lt]
		local takeup_se3_bm = "(" + strtrim("`se3_bm'") + ")"

		local b4_bm: display `format' _b[atema_pe_lt]
		scalar t_stat4_bm = _b[atema_pe_lt]/_se[atema_pe_lt]
		scalar df4_bm = e(df_r)
		scalar pval4_bm = 2 * ttail(df4_bm, abs(t_stat4_bm))
		if pval4_bm < 0.01 local takeup_b4_bm = strtrim("`b4_bm'") + "\sym{***}"
		else if pval4_bm < 0.05 local takeup_b4_bm = strtrim("`b4_bm'") + "\sym{**}"
		else if pval4_bm < 0.1 local takeup_b4_bm = strtrim("`b4_bm'") + "\sym{*}"
		else local takeup_b4_bm = strtrim("`b4_bm'")
		local se4_bm: display `format' _se[atema_pe_lt]
		local takeup_se4_bm = "(" + strtrim("`se4_bm'") + ")"
		
		local takeupobs_bm: display %9.0fc e(N)
		
		test atema_st=atema_pe_st
		local takeupp1_bm: di `format' r(p)
		
		test atema_st=atema_lt
		local takeupp2_bm: di `format' r(p)
		
		test atema_pe_st=atema_pe_lt
		local takeupp3_bm: di `format' r(p)
		

	

texdoc init "$output\tables\main\02. first stage.tex", replace force 

	tex \begin{table}[htbp]
	tex \centering
	tex \resizebox{\linewidth}{!}{%
	tex \begin{threeparttable}
	tex \caption{\textbf{First-Stage Effects on Khan Academy Usage}}
	tex \fontsize{10}{11}\selectfont
	tex \begin{tabular}{l*{6}c}
	tex \hline\hline
	tex &\multicolumn{1}{c}{Student} &\multicolumn{3}{c}{At least 5 mins} &\multicolumn{1}{c}{Number} &\multicolumn{1}{c}{Skills} \\
	tex &\multicolumn{1}{c}{login} &\multicolumn{1}{c}{per week} &\multicolumn{1}{c}{of mins} &\multicolumn{1}{c}{leveled up} \\
	tex \cmidrule(lr){3-5}
	tex &\multicolumn{1}{c}{} &\multicolumn{1}{c}{All} &\multicolumn{1}{c}{Above-median} &\multicolumn{1}{c}{Below-median} &\multicolumn{1}{c}{} &\multicolumn{1}{c}{} \\
	tex &\multicolumn{1}{c}{(1)} &\multicolumn{1}{c}{(2)} &\multicolumn{1}{c}{(3)} &\multicolumn{1}{c}{(4)} &\multicolumn{1}{c}{(5)} &\multicolumn{1}{c}{(6)} \\
	tex \hline \\
	tex \beta_1: Treatment (short-term) & `student_login_b1' & `takeup_b1' & `takeup_b1_am' & `takeup_b1_bm' & `learn_min_b1' & `skills_b1' \\
	tex & `student_login_se1' & `takeup_se1' & `takeup_se1_am' & `takeup_se1_bm' & `learn_min_se1' & `skills_se1' \\
	tex [1ex]
	tex \beta_2: Parental engagement (short-term) & `student_login_b2' & `takeup_b2' & `takeup_b2_am' & `takeup_b2_bm' & `learn_min_b2' & `skills_b2' \\
	tex & `student_login_se2' & `takeup_se2' & `takeup_se2_am' & `takeup_se2_bm' & `learn_min_se2' & `skills_se2' \\
	tex [1ex]
	tex \beta_3: Treatment (long-term) & `student_login_b3' & `takeup_b3' & `takeup_b3_am' & `takeup_b3_bm' & `learn_min_b3' & `skills_b3' \\
	tex & `student_login_se3' & `takeup_se3' & `takeup_se3_am' & `takeup_se3_bm' & `learn_min_se3' & `skills_se3' \\
	tex [1ex]
	tex \beta_4: Parental engagement (long-term) & `student_login_b4' & `takeup_b4' & `takeup_b4_am' & `takeup_b4_bm' & `learn_min_b4' & `skills_b4' \\
	tex & `student_login_se4' & `takeup_se4' & `takeup_se4_am' & `takeup_se4_bm' & `learn_min_se4' & `skills_se4' \\
	tex [1ex]
	tex \hline \\
	tex [1ex]
	tex H_0: \beta_1 = \beta_2 & `student_loginp1' & `takeupp1' & `takeupp1_am' & `takeupp1_bm' & `learn_minp1' & `skillsp1' \\
	tex [1ex]
	tex H_0: \beta_1 = \beta_3 & `student_loginp2' & `takeupp2' & `takeupp2_am' & `takeupp2_bm' & `learn_minp2' & `skillsp2' \\
	tex [1ex]
	tex H_0: \beta_2 = \beta_4 & `student_loginp3' & `takeupp3' & `takeupp3_am' & `takeupp3_bm' & `learn_minp3' & `skillsp3' \\
	tex [1ex]
	tex \hline \\
	tex [1ex]
	tex Control mean (short-term) & `student_loginc_22' & `takeupc_22' & `takeupc_22_am' & `takeupc_22_bm' & `learn_minc_22' & `skillsc_22' \\
	tex [1ex]
	tex Control mean (long-term) & `student_loginc_23' & `takeupc_23' & `takeupc_23_am' & `takeupc_23_bm' & `learn_minc_23' & `skillsc_23' \\
	tex [1ex]
	tex N & `student_loginobs' & `takeupobs' & `takeupobs_am' & `takeupobs_bm' & `learn_minobs' & `skillsobs' \\
	tex [1ex]
	tex \hline
	tex \end{tabular}
	tex \begin{tablenotes}[flushleft]
	tex \scriptsize
	tex \item
	tex \textbf{Notes:} This table reports the short and long-term first stage effects of being in the treatment group (eligible to enrol in the ATEMA program) and the parental engagement group (parents receiving information through email under the ATEMA program). The "familiar" status indicates that a student completed an exercise with 70 percent or higher correct answers. The control group is defined as students in schools that were not eligible for enrollment in the ATEMA program. All regressions control for stratum-year and grade fixed effects. Standard errors of variables are clustered at the school-level and reported in parentheses. * \(p<0.10\), ** \(p<0.05\), *** \(p<0.01\). 
	tex \end{tablenotes}
	tex \end{threeparttable}
	tex }
	tex \end{table}

	
texdoc close	





