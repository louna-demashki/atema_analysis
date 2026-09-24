// checking changes to treatment during implementation 
// Date: December 9th, 2024 (Sara M.)

clear all
set matsize 6000
set more off 
global dir "D:\SECURE\data 2024\analysis\atema" 
global input "$dir\data" 
global output "$dir\output"

cap log close 
log using "$output\Logs\treatment_changes math.txt", replace text 

use "${input}\master_khan_student_combined", clear 

keep if math_score!=.

gen same_sc = 0
	replace same_sc = 1 if school_21 == SCHOOL_CODE

drop treat1 treat2 treat_info

merge m:1 SCHOOL_CODE using "D:\SECURE\data 2024\prepare\build\input\treatment_control_atema", gen(rand)
drop if rand==2
drop rand

gen ta1_22=1 if treat1==1 & treat_info==0 & ACADEMIC_YEAR_ID_FK==2022
gen ta2_22=1 if treat1==1 & treat_info==1 & ACADEMIC_YEAR_ID_FK==2022
gen ta3_22=1 if treat2==1 & treat_info==0 & ACADEMIC_YEAR_ID_FK==2022
gen ta4_22=1 if treat2==1 & treat_info==1 & ACADEMIC_YEAR_ID_FK==2022
gen c_22=1 if treat1==0 & treat2==0 & treat_info==0 & ACADEMIC_YEAR_ID_FK==2022

gen ta1_23=1 if treat1==1 & treat_info==0 & ACADEMIC_YEAR_ID_FK==2023
gen ta2_23=1 if treat1==1 & treat_info==1 & ACADEMIC_YEAR_ID_FK==2023
gen ta3_23=1 if treat2==1 & treat_info==0 & ACADEMIC_YEAR_ID_FK==2023
gen ta4_23=1 if treat2==1 & treat_info==1 & ACADEMIC_YEAR_ID_FK==2023
gen c_23=1 if treat1==0 & treat2==0 & treat_info==0 & ACADEMIC_YEAR_ID_FK==2023

bys SMAX_STUDENT_ID: egen s_ta1_22=max(ta1_22)
bys SMAX_STUDENT_ID: egen s_ta2_22=max(ta2_22)
bys SMAX_STUDENT_ID: egen s_ta3_22=max(ta3_22)
bys SMAX_STUDENT_ID: egen s_ta4_22=max(ta4_22)
bys SMAX_STUDENT_ID: egen s_c_22=max(c_22)

bys SMAX_STUDENT_ID: egen s_ta1_23=max(ta1_23)
bys SMAX_STUDENT_ID: egen s_ta2_23=max(ta2_23)
bys SMAX_STUDENT_ID: egen s_ta3_23=max(ta3_23)
bys SMAX_STUDENT_ID: egen s_ta4_23=max(ta4_23)
bys SMAX_STUDENT_ID: egen s_c_23=max(c_23)

foreach i in 1 2 3 4{
	replace s_ta`i'_22=0 if s_ta`i'_22==.
	replace s_ta`i'_23=0 if s_ta`i'_23==.
	}
	replace s_c_22=0 if s_c_22==.
	replace s_c_23=0 if s_c_23==.
	
save "$input\interim\transfers_math", replace

use "$input\interim\atema_treatment", clear 

duplicates drop SMAX_STAFF_IDMATH, force

ren SCHOOL_CODE school_21 
ren ACADEMIC_YEAR_ID_FK base_year

merge 1:m SMAX_STAFF_ID using "D:\SECURE\data 2024\prepare\temp\class_teacher_student_end", gen(teach_m) keepusing(ACADEMIC_YEAR_ID_FK SCHOOL_CODE)
drop if teach_m ==2
drop teach_m 

drop treat1 treat2 treat_info

merge m:1 SCHOOL_CODE using "D:\SECURE\data 2024\prepare\build\input\treatment_control_atema", gen(rand)
drop if rand==2
drop rand

keep if ACADEMIC_YEAR_ID_FK==2022 | ACADEMIC_YEAR_ID_FK==2023 | ACADEMIC_YEAR_ID_FK==.

gen ta1_22=1 if treat1==1 & treat_info==0 & ACADEMIC_YEAR_ID_FK==2022
gen ta2_22=1 if treat1==1 & treat_info==1 & ACADEMIC_YEAR_ID_FK==2022
gen ta3_22=1 if treat2==1 & treat_info==0 & ACADEMIC_YEAR_ID_FK==2022
gen ta4_22=1 if treat2==1 & treat_info==1 & ACADEMIC_YEAR_ID_FK==2022
gen c_22=1 if treat1==0 & treat2==0 & treat_info==0 & ACADEMIC_YEAR_ID_FK==2022

gen ta1_23=1 if treat1==1 & treat_info==0 & ACADEMIC_YEAR_ID_FK==2023
gen ta2_23=1 if treat1==1 & treat_info==1 & ACADEMIC_YEAR_ID_FK==2023
gen ta3_23=1 if treat2==1 & treat_info==0 & ACADEMIC_YEAR_ID_FK==2023
gen ta4_23=1 if treat2==1 & treat_info==1 & ACADEMIC_YEAR_ID_FK==2023
gen c_23=1 if treat1==0 & treat2==0 & treat_info==0 & ACADEMIC_YEAR_ID_FK==2023

bys SMAX_STAFF_IDMATH: egen t_ta1_22=max(ta1_22)
bys SMAX_STAFF_IDMATH: egen t_ta2_22=max(ta2_22)
bys SMAX_STAFF_IDMATH: egen t_ta3_22=max(ta3_22)
bys SMAX_STAFF_IDMATH: egen t_ta4_22=max(ta4_22)
bys SMAX_STAFF_IDMATH: egen t_c_22=max(c_22)

bys SMAX_STAFF_IDMATH: egen t_ta1_23=max(ta1_23)
bys SMAX_STAFF_IDMATH: egen t_ta2_23=max(ta2_23)
bys SMAX_STAFF_IDMATH: egen t_ta3_23=max(ta3_23)
bys SMAX_STAFF_IDMATH: egen t_ta4_23=max(ta4_23)
bys SMAX_STAFF_IDMATH: egen t_c_23=max(c_23)


foreach i in 1 2 3 4{
	replace teach_treat`i'=0 if teach_treat`i'==.
	replace t_ta`i'_22=0 if t_ta`i'_22==.
	replace t_ta`i'_23=0 if t_ta`i'_23==.
	}
	replace teach_control=0 if teach_control==.
	replace t_c_22=0 if t_c_22==.
	replace t_c_23=0 if t_c_23==.
	
save "$input\interim\transfer_teacher", replace
	


// treatment in 2022 
use "$input\interim\transfers_math", clear 

drop if ACADEMIC_YEAR_ID_FK == 2023

local s_treat "s_ta1_22 s_ta2_22 s_ta3_22 s_ta4_22 s_c_22" 


local format "%9.3fc"

foreach i in `s_treat'{
	reghdfe `i' treat_arm_1 treat_arm_2 treat_arm_3 treat_arm_4 control, absorb(GRADE_ID_FK strata) ///
	vce(clustervar school_21)
	
		local b1: display `format' _b[treat_arm_1] 
		scalar t_stat1 = _b[treat_arm_1]/_se[treat_arm_1]
		scalar df1 = e(df_r)
		scalar pval1 = 2 * ttail(df1, abs(t_stat1))
		if pval1 < 0.01 local `i'_b1 = strtrim("`b1'") + "\sym{***}"
		else if pval1 < 0.05 local `i'_b1 = strtrim("`b1'") + "\sym{**}"
		else if pval1 < 0.1 local `i'_b1 = strtrim("`b1'") + "\sym{*}"
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
		
		local b5: display `format' _b[control] 
		scalar t_stat5 = _b[control]/_se[control]
		scalar df5 = e(df_r)
		scalar pval5 = 2 * ttail(df5, abs(t_stat5))
		if pval5 < 0.01 local `i'_b5 = strtrim("`b5'") + "\sym{***}"
		else if pval5 < 0.05 local `i'_b5 = strtrim("`b5'") + "\sym{**}"
		else if pval5 < 0.1 local `i'_b5 = strtrim("`b5'") + "\sym{*}"
		else local `i'_b5 = strtrim("`b5'")
		local se5: display `format' _se[control]
		local `i'_se5 = "(" + strtrim("`se5'") + ")"
		
		local `i'_obs = e(N)
		
	}
	
	
use "$input\interim\transfer_teacher", clear
	
drop if ACADEMIC_YEAR_ID_FK == 2023
	
local t_treat "t_ta1_22 t_ta2_22 t_ta3_22 t_ta4_22 t_c_22"

drop if SMAX_STAFF_IDMATH==.	
bys SMAX_STAFF_IDMATH: gen teacher=_n

		
foreach i in `t_treat'{
	reghdfe `i' teach_treat1 teach_treat2 teach_treat3 teach_treat4 teach_control if teacher==1, ///
	absorb(GRADE_ID_FK strata) vce(clustervar school_21)
	
		local b1t: display `format' _b[teach_treat1] 
		scalar t_stat1t = _b[teach_treat1]/_se[teach_treat1]
		scalar df1t = e(df_r)
		scalar pval1t = 2 * ttail(df1t, abs(t_stat1t))
		if pval1t < 0.01 local `i'_b1t = strtrim("`b1t'") + "\sym{***}"
		else if pval1t < 0.05 local `i'_b1t = strtrim("`b1t'") + "\sym{**}"
		else if pval1t < 0.1 local `i'_b1t = strtrim("`b1t'") + "\sym{*}"
		else local `i'_b1t = strtrim("`b1t'")
		local se1t: display `format' _se[teach_treat1]
		local `i'_se1t = "(" + strtrim("`se1t'") + ")"

		local b2t: display `format' _b[teach_treat2] 
		scalar t_stat2t = _b[teach_treat2]/_se[teach_treat2]
		scalar df2t = e(df_r)
		scalar pval2t = 2 * ttail(df2t, abs(t_stat2t))
		if pval2t < 0.01 local `i'_b2t = strtrim("`b2t'") + "\sym{***}"
		else if pval2t < 0.05 local `i'_b2t = strtrim("`b2t'") + "\sym{**}"
		else if pval2t < 0.1 local `i'_b2t = strtrim("`b2t'") + "\sym{*}"
		else local `i'_b2t = strtrim("`b2t'")
		local se2t: display `format' _se[teach_treat2]
		local `i'_se2t = "(" + strtrim("`se2t'") + ")"

		local b3t: display `format' _b[teach_treat3] 
		scalar t_stat3t = _b[teach_treat3]/_se[teach_treat3]
		scalar df3t = e(df_r)
		scalar pval3t = 2 * ttail(df3t, abs(t_stat3t))
		if pval3t < 0.01 local `i'_b3t = strtrim("`b3t'") + "\sym{***}"
		else if pval3t < 0.05 local `i'_b3t = strtrim("`b3t'") + "\sym{**}"
		else if pval3t < 0.1 local `i'_b3t = strtrim("`b3t'") + "\sym{*}"
		else local `i'_b3t = strtrim("`b3t'")
		local se3t: display `format' _se[teach_treat3]
		local `i'_se3t = "(" + strtrim("`se3t'") + ")"
		
		local b4t: display `format' _b[teach_treat4] 
		scalar t_stat4t = _b[teach_treat4]/_se[teach_treat4]
		scalar df4t = e(df_r)
		scalar pval4t = 2 * ttail(df4t, abs(t_stat4t))
		if pval4t < 0.01 local `i'_b4t = strtrim("`b4t'") + "\sym{***}"
		else if pval4t < 0.05 local `i'_b4t = strtrim("`b4t'") + "\sym{**}"
		else if pval4t < 0.1 local `i'_b4t = strtrim("`b4t'") + "\sym{*}"
		else local `i'_b4t = strtrim("`b4t'")
		local se4t: display `format' _se[teach_treat4]
		local `i'_se4t = "(" + strtrim("`se4t'") + ")"
		
		local b5t: display `format' _b[teach_control] 
		scalar t_stat5t = _b[teach_control]/_se[teach_control]
		scalar df5t = e(df_r)
		scalar pval5t = 2 * ttail(df5t, abs(t_stat5t))
		if pval5t < 0.01 local `i'_b5t = strtrim("`b5t'") + "\sym{***}"
		else if pval5t < 0.05 local `i'_b5t = strtrim("`b5t'") + "\sym{**}"
		else if pval5t < 0.1 local `i'_b5t = strtrim("`b5t'") + "\sym{*}"
		else local `i'_b5t = strtrim("`b5t'")
		local se5t: display `format' _se[teach_control]
		local `i'_se5t = "(" + strtrim("`se5t'") + ")"
		
		local `i'_obs = e(N)
		
	}
		
		
		
		
texdoc init "$output\tables\appendix\treatment_changes_22 - math.tex", replace force 

	tex \begin{table}[htbp]
	tex \centering
	tex \resizebox{\linewidth}{!}{%
	tex \begin{threeparttable}
	tex \caption{\textbf{May 2022 Treatment Changes}}
	tex \fontsize{10}{11}\selectfont
	tex \begin{tabular}{l*{5}c}
	tex \hline\hline
	tex &\multicolumn{1}{c}{TA 1} &\multicolumn{1}{c}{TA 2} &\multicolumn{1}{c}{TA 3} &\multicolumn{1}{c}{TA 4} &\multicolumn{1}{c}{Control} &\multicolumn{1}{c}{N} \\
	tex &\multicolumn{1}{c}{(1)} &\multicolumn{1}{c}{(2)} &\multicolumn{1}{c}{(3)} &\multicolumn{1}{c}{(4)} &\multicolumn{1}{c}{(5)} &\multicolumn{1}{c}{(6)} \\
	tex \hline \\
	tex [1ex] 
	
	tex &\multicolumn{4}{l}{textbf{Treatment status in September 2021}} \\
	tex [1ex]
	
	tex &\multicolumn{4}{l}{textit{Panel A: Student transfers}} \\
	tex [1ex]
	
	tex TA 1 & `s_ta1_22_b1' & `s_ta1_22_b2' & `s_ta1_22_b3' & `s_ta1_22_b4' & \\
	tex & `s_ta1_22_se1' & `s_ta1_22_se2' & `s_ta1_22_se3' & `s_ta1_22_se4' & \\
	tex [1ex]
	
	tex TA 2 & `s_ta2_22_b1' & `s_ta2_22_b2' & `s_ta2_22_b3' & `s_ta2_22_b4' & \\
	tex & `s_ta2_22_se1' & `s_ta2_22_se2' & `s_ta2_22_se3' & `s_ta2_22_se4' &\\
	tex [1ex]
	
	tex TA 3 & `s_ta3_22_b1' & `s_ta3_22_b2' & `s_ta3_22_b3' & `s_ta3_22_b4' & \\
	tex & `s_ta3_22_se1' & `s_ta3_22_se2' & `s_ta3_22_se3' & `s_ta3_22_se4' & \\
	tex [1ex]
	
	tex TA 4 & `s_ta4_22_b1' & `s_ta4_22_b2' & `s_ta4_22_b3' & `s_ta4_22_b4' & \\
	tex & `s_ta4_22_se1' & `s_ta4_22_se2' & `s_ta4_22_se3' & `s_ta4_22_se4' & \\
	tex [1ex]
		
	tex N & & & & & `s_ta1_22_obs' \\
	
	tex &&&&&& \\
	
	tex &\multicolumn{4}{l}{textit{Panel B: Teacher transfers}} \\
	tex [1ex]
	
	tex TA 1 & `t_ta1_22_b1t' & `t_ta1_22_b2t' & `t_ta1_22_b3t' & `t_ta1_22_b4t' & \\
	tex & `t_ta1_22_se1t' & `t_ta1_22_se2t' & `t_ta1_22_se3t' & `t_ta1_22_se4t' & \\
	tex [1ex]
	
	tex TA 2 & `t_ta2_22_b1t' & `t_ta2_22_b2t' & `t_ta2_22_b3t' & `t_ta2_22_b4t' & \\
	tex & `t_ta2_22_se1t' & `t_ta2_22_se2t' & `t_ta2_22_se3t' & `t_ta2_22_se4t' & \\
	tex [1ex]
	
	tex TA 3 & `t_ta3_22_b1t' & `t_ta3_22_b2t' & `t_ta3_22_b3t' & `t_ta3_22_b4t' & \\
	tex & `t_ta3_22_se1t' & `t_ta3_22_se2t' & `t_ta3_22_se3t' & `t_ta3_22_se4t' & \\
	tex [1ex]
	
	tex TA 4 & `t_ta4_22_b1t' & `t_ta4_22_b2t' & `t_ta4_22_b3t' & `t_ta4_22_b4t' & \\
	tex & `t_ta4_22_se1t' & `t_ta4_22_se2t' & `t_ta4_22_se3t' & `t_ta4_22_se4t' & \\
	tex [1ex]
	
	tex N & & & & `t_ta1_22_obs' \\

	tex \hline \hline \\
	tex \end{tabular}
	tex \end{threeparttable}
	tex }
	tex \end{table}

	
texdoc close	
		
		
// treatment in 2023
use "$input\interim\transfers_math", clear 

drop if ACADEMIC_YEAR_ID_FK==2022

local s_treat "s_ta1_23 s_ta2_23 s_ta3_23 s_ta4_23 s_c_23"
		

local format "%9.3fc"

foreach i in `s_treat'{
	reghdfe `i' treat_arm_1 treat_arm_2 treat_arm_3 treat_arm_4, absorb(GRADE_ID_FK strata) ///
	vce(clustervar school_21)
	
		local b1: display `format' _b[treat_arm_1] 
		scalar t_stat1 = _b[treat_arm_1]/_se[treat_arm_1]
		scalar df1 = e(df_r)
		scalar pval1 = 2 * ttail(df1, abs(t_stat1))
		if pval1 < 0.01 local `i'_b1 = strtrim("`b1'") + "\sym{***}"
		else if pval1 < 0.05 local `i'_b1 = strtrim("`b1'") + "\sym{**}"
		else if pval1 < 0.1 local `i'_b1 = strtrim("`b1'") + "\sym{*}"
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
				
		local `i'_obs = e(N)
		
	}

use "$input\interim\transfer_teacher", clear

drop if ACADEMIC_YEAR_ID_FK == 2022
	
local t_treat "t_ta1_23 t_ta2_23 t_ta3_23 t_ta4_23 t_c_23" 
	
drop if SMAX_STAFF_IDMATH==.	
bys SMAX_STAFF_IDMATH: gen teacher=_n
	
		
foreach i in `t_treat'{
	reghdfe `i' teach_treat1 teach_treat2 teach_treat3 teach_treat4 if teacher==1, ///
	absorb(GRADE_ID_FK strata) vce(clustervar school_21)
	
		local b1t: display `format' _b[teach_treat1] 
		scalar t_stat1t = _b[teach_treat1]/_se[teach_treat1]
		scalar df1t = e(df_r)
		scalar pval1t = 2 * ttail(df1t, abs(t_stat1t))
		if pval1t < 0.01 local `i'_b1t = strtrim("`b1t'") + "\sym{***}"
		else if pval1t < 0.05 local `i'_b1t = strtrim("`b1t'") + "\sym{**}"
		else if pval1t < 0.1 local `i'_b1t = strtrim("`b1t'") + "\sym{*}"
		else local `i'_b1t = strtrim("`b1t'")
		local se1t: display `format' _se[teach_treat1]
		local `i'_se1t = "(" + strtrim("`se1t'") + ")"

		local b2t: display `format' _b[teach_treat2] 
		scalar t_stat2t = _b[teach_treat2]/_se[teach_treat2]
		scalar df2t = e(df_r)
		scalar pval2t = 2 * ttail(df2t, abs(t_stat2t))
		if pval2t < 0.01 local `i'_b2t = strtrim("`b2t'") + "\sym{***}"
		else if pval2t < 0.05 local `i'_b2t = strtrim("`b2t'") + "\sym{**}"
		else if pval2t < 0.1 local `i'_b2t = strtrim("`b2t'") + "\sym{*}"
		else local `i'_b2t = strtrim("`b2t'")
		local se2t: display `format' _se[teach_treat2]
		local `i'_se2t = "(" + strtrim("`se2t'") + ")"

		local b3t: display `format' _b[teach_treat3] 
		scalar t_stat3t = _b[teach_treat3]/_se[teach_treat3]
		scalar df3t = e(df_r)
		scalar pval3t = 2 * ttail(df3t, abs(t_stat3t))
		if pval3t < 0.01 local `i'_b3t = strtrim("`b3t'") + "\sym{***}"
		else if pval3t < 0.05 local `i'_b3t = strtrim("`b3t'") + "\sym{**}"
		else if pval3t < 0.1 local `i'_b3t = strtrim("`b3t'") + "\sym{*}"
		else local `i'_b3t = strtrim("`b3t'")
		local se3t: display `format' _se[teach_treat3]
		local `i'_se3t = "(" + strtrim("`se3t'") + ")"
		
		local b4t: display `format' _b[teach_treat4] 
		scalar t_stat4t = _b[teach_treat4]/_se[teach_treat4]
		scalar df4t = e(df_r)
		scalar pval4t = 2 * ttail(df4t, abs(t_stat4t))
		if pval4t < 0.01 local `i'_b4t = strtrim("`b4t'") + "\sym{***}"
		else if pval4t < 0.05 local `i'_b4t = strtrim("`b4t'") + "\sym{**}"
		else if pval4t < 0.1 local `i'_b4t = strtrim("`b4t'") + "\sym{*}"
		else local `i'_b4t = strtrim("`b4t'")
		local se4t: display `format' _se[teach_treat4]
		local `i'_se4t = "(" + strtrim("`se4t'") + ")"
				
		local `i'_obs = e(N)
		
	}
		
		
		
		
texdoc init "$output\tables\appendix\treatment_changes_23 - math.tex", replace force 

	tex \begin{table}[htbp]
	tex \centering
	tex \resizebox{\linewidth}{!}{%
	tex \begin{threeparttable}
	tex \caption{\textbf{May 2023 Treatment Changes}}
	tex \fontsize{10}{11}\selectfont
	tex \begin{tabular}{l*{5}c}
	tex \hline\hline
	tex &\multicolumn{1}{c}{TA 1} &\multicolumn{1}{c}{TA 2} &\multicolumn{1}{c}{TA 3} &\multicolumn{1}{c}{TA 4} &\multicolumn{1}{c}{N} \\
	tex &\multicolumn{1}{c}{(1)} &\multicolumn{1}{c}{(2)} &\multicolumn{1}{c}{(3)} &\multicolumn{1}{c}{(4)} &\multicolumn{1}{c}{(5)} \\
	tex \hline \\
	tex [1ex] 
	
	tex &\multicolumn{4}{l}{textbf{Treatment status in September 2021}} \\
	tex [1ex]
	
	tex &\multicolumn{4}{l}{textit{Panel A: Student transfers}} \\
	tex [1ex]
	
	tex TA 1 & `s_ta1_23_b1' & `s_ta1_23_b2' & `s_ta1_23_b3' & `s_ta1_23_b4' & \\
	tex & `s_ta1_23_se1' & `s_ta1_23_se2' & `s_ta1_23_se3' & `s_ta1_23_se4' & \\
	tex [1ex]
	
	tex TA 2 & `s_ta2_23_b1' & `s_ta2_23_b2' & `s_ta2_23_b3' & `s_ta2_23_b4' & \\
	tex & `s_ta2_23_se1' & `s_ta2_23_se2' & `s_ta2_23_se3' & `s_ta2_23_se4' &\\
	tex [1ex]
	
	tex TA 3 & `s_ta3_23_b1' & `s_ta3_23_b2' & `s_ta3_23_b3' & `s_ta3_23_b4' & \\
	tex & `s_ta3_23_se1' & `s_ta3_23_se2' & `s_ta3_23_se3' & `s_ta3_23_se4' & \\
	tex [1ex]
	
	tex TA 4 & `s_ta4_23_b1' & `s_ta4_23_b2' & `s_ta4_23_b3' & `s_ta4_23_b4' & \\
	tex & `s_ta4_23_se1' & `s_ta4_23_se2' & `s_ta4_23_se3' & `s_ta4_23_se4' & \\
	tex [1ex]
	
	tex N & & & & & `s_ta1_23_obs' \\
	
	tex &&&&&& \\
	
	tex &\multicolumn{4}{l}{textit{Panel B: Teacher transfers}} \\
	tex [1ex]
	
	tex TA 1 & `t_ta1_23_b1t' & `t_ta1_23_b2t' & `t_ta1_23_b3t' & `t_ta1_23_b4t' & \\
	tex & `t_ta1_23_se1t' & `t_ta1_23_se2t' & `t_ta1_23_se3t' & `t_ta1_23_se4t' & \\
	tex [1ex]
	
	tex TA 2 & `t_ta2_23_b1t' & `t_ta2_23_b2t' & `t_ta2_23_b3t' & `t_ta2_23_b4t' & \\
	tex & `t_ta2_23_se1t' & `t_ta2_23_se2t' & `t_ta2_23_se3t' & `t_ta2_23_se4t' & \\
	tex [1ex]
	
	tex TA 3 & `t_ta3_23_b1t' & `t_ta3_23_b2t' & `t_ta3_23_b3t' & `t_ta3_23_b4t' & \\
	tex & `t_ta3_23_se1t' & `t_ta3_23_se2t' & `t_ta3_23_se3t' & `t_ta3_23_se4t' & \\
	tex [1ex]
	
	tex TA 4 & `t_ta4_23_b1t' & `t_ta4_23_b2t' & `t_ta4_23_b3t' & `t_ta4_23_b4t' & \\
	tex & `t_ta4_23_se1t' & `t_ta4_23_se2t' & `t_ta4_23_se3t' & `t_ta4_23_se4t' & \\
	tex [1ex]
		
	tex N & & & & `t_ta1_23_obs' \\

	tex \hline \hline \\
	tex \end{tabular}
	tex \end{threeparttable}
	tex }
	tex \end{table}

	
texdoc close	
		
	
	
//============================================================================//
// CHECKING 2023 STUDENT TRANSFERS BY GRADE
//============================================================================//

// treatment in 2023
use "$input\interim\transfers_math", clear 

drop if ACADEMIC_YEAR_ID_FK==2022

local s_treat "s_ta1_23 s_ta2_23 s_ta3_23 s_ta4_23 s_c_23"
		

local format "%9.3fc"

foreach i in `s_treat'{
	reghdfe `i' treat_arm_1 treat_arm_2 treat_arm_3 treat_arm_4 if grade_21==5, absorb(strata) ///
	vce(clustervar school_21)
	
		local b1_3: display `format' _b[treat_arm_1] 
		scalar t_stat1_3 = _b[treat_arm_1]/_se[treat_arm_1]
		scalar df1_3 = e(df_r)
		scalar pval1_3 = 2 * ttail(df1_3, abs(t_stat1_3))
		if pval1_3 < 0.01 local `i'_b1_3 = strtrim("`b1_3'") + "\sym{***}"
		else if pval1_3 < 0.05 local `i'_b1_3 = strtrim("`b1_3'") + "\sym{**}"
		else if pval1_3 < 0.1 local `i'_b1_3 = strtrim("`b1_3'") + "\sym{*}"
		else local `i'_b1_3 = strtrim("`b1_3'")
		local se1_3: display `format' _se[treat_arm_1]
		local `i'_se1_3 = "(" + strtrim("`se1_3'") + ")"

		local b2_3: display `format' _b[treat_arm_2] 
		scalar t_stat2_3 = _b[treat_arm_2]/_se[treat_arm_2]
		scalar df2_3 = e(df_r)
		scalar pval2_3 = 2 * ttail(df2_3, abs(t_stat2_3))
		if pval2_3 < 0.01 local `i'_b2_3 = strtrim("`b2_3'") + "\sym{***}"
		else if pval2_3 < 0.05 local `i'_b2_3 = strtrim("`b2_3'") + "\sym{**}"
		else if pval2_3 < 0.1 local `i'_b2_3 = strtrim("`b2_3'") + "\sym{*}"
		else local `i'_b2_3 = strtrim("`b2_3'")
		local se2_3: display `format' _se[treat_arm_2]
		local `i'_se2_3 = "(" + strtrim("`se2_3'") + ")"

		local b3_3: display `format' _b[treat_arm_3] 
		scalar t_stat3_3 = _b[treat_arm_3]/_se[treat_arm_3]
		scalar df3_3 = e(df_r)
		scalar pval3_3 = 2 * ttail(df3_3, abs(t_stat3_3))
		if pval3_3 < 0.01 local `i'_b3_3 = strtrim("`b3_3'") + "\sym{***}"
		else if pval3_3 < 0.05 local `i'_b3_3 = strtrim("`b3_3'") + "\sym{**}"
		else if pval3_3 < 0.1 local `i'_b3_3 = strtrim("`b3_3'") + "\sym{*}"
		else local `i'_b3_3 = strtrim("`b3_3'")
		local se3_3: display `format' _se[treat_arm_3]
		local `i'_se3_3 = "(" + strtrim("`se3_3'") + ")"
		
		local b4_3: display `format' _b[treat_arm_4] 
		scalar t_stat4_3 = _b[treat_arm_4]/_se[treat_arm_4]
		scalar df4_3 = e(df_r)
		scalar pval4_3 = 2 * ttail(df4_3, abs(t_stat4_3))
		if pval4_3 < 0.01 local `i'_b4_3 = strtrim("`b4_3'") + "\sym{***}"
		else if pval4_3 < 0.05 local `i'_b4_3 = strtrim("`b4_3'") + "\sym{**}"
		else if pval4_3 < 0.1 local `i'_b4_3 = strtrim("`b4_3'") + "\sym{*}"
		else local `i'_b4_3 = strtrim("`b4_3'")
		local se4_3: display `format' _se[treat_arm_4]
		local `i'_se4_3 = "(" + strtrim("`se4_3'") + ")"
				
		local `i'_obs_3 = e(N)
		
		
		
		// grade 5 in 2023
	reghdfe `i' treat_arm_1 treat_arm_2 treat_arm_3 treat_arm_4 if grade_21==6, absorb(strata) ///
	vce(clustervar school_21)
	
		local b1_4: display `format' _b[treat_arm_1] 
		scalar t_stat1_4 = _b[treat_arm_1]/_se[treat_arm_1]
		scalar df1_4 = e(df_r)
		scalar pval1_4 = 2 * ttail(df1_4, abs(t_stat1_4))
		if pval1_4 < 0.01 local `i'_b1_4 = strtrim("`b1_4'") + "\sym{***}"
		else if pval1_4 < 0.05 local `i'_b1_4 = strtrim("`b1_4'") + "\sym{**}"
		else if pval1_4 < 0.1 local `i'_b1_4 = strtrim("`b1_4'") + "\sym{*}"
		else local `i'_b1_4 = strtrim("`b1_4'")
		local se1_4: display `format' _se[treat_arm_1]
		local `i'_se1_4 = "(" + strtrim("`se1_4'") + ")"

		local b2_4: display `format' _b[treat_arm_2] 
		scalar t_stat2_4 = _b[treat_arm_2]/_se[treat_arm_2]
		scalar df2_4 = e(df_r)
		scalar pval2_4 = 2 * ttail(df2_4, abs(t_stat2_4))
		if pval2_4 < 0.01 local `i'_b2_4 = strtrim("`b2_4'") + "\sym{***}"
		else if pval2_4 < 0.05 local `i'_b2_4 = strtrim("`b2_4'") + "\sym{**}"
		else if pval2_4 < 0.1 local `i'_b2_4 = strtrim("`b2_4'") + "\sym{*}"
		else local `i'_b2_4 = strtrim("`b2_4'")
		local se2_4: display `format' _se[treat_arm_2]
		local `i'_se2_4 = "(" + strtrim("`se2_4'") + ")"

		local b3_4: display `format' _b[treat_arm_3] 
		scalar t_stat3_4 = _b[treat_arm_3]/_se[treat_arm_3]
		scalar df3_4 = e(df_r)
		scalar pval3_4 = 2 * ttail(df3_4, abs(t_stat3_4))
		if pval3_4 < 0.01 local `i'_b3_4 = strtrim("`b3_4'") + "\sym{***}"
		else if pval3_4 < 0.05 local `i'_b3_4 = strtrim("`b3_4'") + "\sym{**}"
		else if pval3_4 < 0.1 local `i'_b3_4 = strtrim("`b3_4'") + "\sym{*}"
		else local `i'_b3_4 = strtrim("`b3_4'")
		local se3_4: display `format' _se[treat_arm_3]
		local `i'_se3_4 = "(" + strtrim("`se3_4'") + ")"
		
		local b4_4: display `format' _b[treat_arm_4] 
		scalar t_stat4_4 = _b[treat_arm_4]/_se[treat_arm_4]
		scalar df4_4 = e(df_r)
		scalar pval4_4 = 2 * ttail(df4_4, abs(t_stat4_4))
		if pval4_4 < 0.01 local `i'_b4_4 = strtrim("`b4_4'") + "\sym{***}"
		else if pval4_4 < 0.05 local `i'_b4_4 = strtrim("`b4_4'") + "\sym{**}"
		else if pval4_4 < 0.1 local `i'_b4_4 = strtrim("`b4_4'") + "\sym{*}"
		else local `i'_b4_4 = strtrim("`b4_4'")
		local se4_4: display `format' _se[treat_arm_4]
		local `i'_se4_4 = "(" + strtrim("`se4_4'") + ")"
				
		local `i'_obs_4 = e(N)
		
	
		// grade 6 in 2023
	reghdfe `i' treat_arm_1 treat_arm_2 treat_arm_3 treat_arm_4 if grade_21==7, absorb(strata) ///
	vce(clustervar school_21)
	
		local b1_5: display `format' _b[treat_arm_1] 
		scalar t_stat1_5 = _b[treat_arm_1]/_se[treat_arm_1]
		scalar df1_5 = e(df_r)
		scalar pval1_5 = 2 * ttail(df1_5, abs(t_stat1_5))
		if pval1_5 < 0.01 local `i'_b1_5 = strtrim("`b1_5'") + "\sym{***}"
		else if pval1_5 < 0.05 local `i'_b1_5 = strtrim("`b1_5'") + "\sym{**}"
		else if pval1_5 < 0.1 local `i'_b1_5 = strtrim("`b1_5'") + "\sym{*}"
		else local `i'_b1_5 = strtrim("`b1_5'")
		local se1_5: display `format' _se[treat_arm_1]
		local `i'_se1_5 = "(" + strtrim("`se1_5'") + ")"

		local b2_5: display `format' _b[treat_arm_2] 
		scalar t_stat2_5 = _b[treat_arm_2]/_se[treat_arm_2]
		scalar df2_5 = e(df_r)
		scalar pval2_5 = 2 * ttail(df2_5, abs(t_stat2_5))
		if pval2_5 < 0.01 local `i'_b2_5 = strtrim("`b2_5'") + "\sym{***}"
		else if pval2_5 < 0.05 local `i'_b2_5 = strtrim("`b2_5'") + "\sym{**}"
		else if pval2_5 < 0.1 local `i'_b2_5 = strtrim("`b2_5'") + "\sym{*}"
		else local `i'_b2_5 = strtrim("`b2_5'")
		local se2_5: display `format' _se[treat_arm_2]
		local `i'_se2_5 = "(" + strtrim("`se2_5'") + ")"

		local b3_5: display `format' _b[treat_arm_3] 
		scalar t_stat3_5 = _b[treat_arm_3]/_se[treat_arm_3]
		scalar df3_5 = e(df_r)
		scalar pval3_5 = 2 * ttail(df3_5, abs(t_stat3_5))
		if pval3_5 < 0.01 local `i'_b3_5 = strtrim("`b3_5'") + "\sym{***}"
		else if pval3_5 < 0.05 local `i'_b3_5 = strtrim("`b3_5'") + "\sym{**}"
		else if pval3_5 < 0.1 local `i'_b3_5 = strtrim("`b3_5'") + "\sym{*}"
		else local `i'_b3_5 = strtrim("`b3_5'")
		local se3_5: display `format' _se[treat_arm_3]
		local `i'_se3_5 = "(" + strtrim("`se3_5'") + ")"
		
		local b4_5: display `format' _b[treat_arm_4] 
		scalar t_stat4_5 = _b[treat_arm_4]/_se[treat_arm_4]
		scalar df4_5 = e(df_r)
		scalar pval4_5 = 2 * ttail(df4_5, abs(t_stat4_5))
		if pval4_5 < 0.01 local `i'_b4_5 = strtrim("`b4_5'") + "\sym{***}"
		else if pval4_5 < 0.05 local `i'_b4_5 = strtrim("`b4_5'") + "\sym{**}"
		else if pval4_5 < 0.1 local `i'_b4_5 = strtrim("`b4_5'") + "\sym{*}"
		else local `i'_b4_5 = strtrim("`b4_5'")
		local se4_5: display `format' _se[treat_arm_4]
		local `i'_se4_5 = "(" + strtrim("`se4_5'") + ")"
				
		local `i'_obs_5 = e(N)
		
		
		// grade 7 in 2023
	reghdfe `i' treat_arm_1 treat_arm_2 treat_arm_3 treat_arm_4 if grade_21==8, absorb(strata) ///
	vce(clustervar school_21)
	
		local b1_6: display `format' _b[treat_arm_1] 
		scalar t_stat1_6 = _b[treat_arm_1]/_se[treat_arm_1]
		scalar df1_6 = e(df_r)
		scalar pval1_6 = 2 * ttail(df1_6, abs(t_stat1_6))
		if pval1_6 < 0.01 local `i'_b1_6 = strtrim("`b1_6'") + "\sym{***}"
		else if pval1_6 < 0.05 local `i'_b1_6 = strtrim("`b1_6'") + "\sym{**}"
		else if pval1_6 < 0.1 local `i'_b1_6 = strtrim("`b1_6'") + "\sym{*}"
		else local `i'_b1_6 = strtrim("`b1_6'")
		local se1_6: display `format' _se[treat_arm_1]
		local `i'_se1_6 = "(" + strtrim("`se1_6'") + ")"

		local b2_6: display `format' _b[treat_arm_2] 
		scalar t_stat2_6 = _b[treat_arm_2]/_se[treat_arm_2]
		scalar df2_6 = e(df_r)
		scalar pval2_6 = 2 * ttail(df2_6, abs(t_stat2_6))
		if pval2_6 < 0.01 local `i'_b2_6 = strtrim("`b2_6'") + "\sym{***}"
		else if pval2_6 < 0.05 local `i'_b2_6 = strtrim("`b2_6'") + "\sym{**}"
		else if pval2_6 < 0.1 local `i'_b2_6 = strtrim("`b2_6'") + "\sym{*}"
		else local `i'_b2_6 = strtrim("`b2_6'")
		local se2_6: display `format' _se[treat_arm_2]
		local `i'_se2_6 = "(" + strtrim("`se2_6'") + ")"

		local b3_6: display `format' _b[treat_arm_3] 
		scalar t_stat3_6 = _b[treat_arm_3]/_se[treat_arm_3]
		scalar df3_6 = e(df_r)
		scalar pval3_6 = 2 * ttail(df3_6, abs(t_stat3_6))
		if pval3_6 < 0.01 local `i'_b3_6 = strtrim("`b3_6'") + "\sym{***}"
		else if pval3_6 < 0.05 local `i'_b3_6 = strtrim("`b3_6'") + "\sym{**}"
		else if pval3_6 < 0.1 local `i'_b3_6 = strtrim("`b3_6'") + "\sym{*}"
		else local `i'_b3_6 = strtrim("`b3_6'")
		local se3_6: display `format' _se[treat_arm_3]
		local `i'_se3_6 = "(" + strtrim("`se3_6'") + ")"
		
		local b4_6: display `format' _b[treat_arm_4] 
		scalar t_stat4_6 = _b[treat_arm_4]/_se[treat_arm_4]
		scalar df4_6 = e(df_r)
		scalar pval4_6 = 2 * ttail(df4_6, abs(t_stat4_6))
		if pval4_6 < 0.01 local `i'_b4_6 = strtrim("`b4_6'") + "\sym{***}"
		else if pval4_6 < 0.05 local `i'_b4_6 = strtrim("`b4_6'") + "\sym{**}"
		else if pval4_6 < 0.1 local `i'_b4_6 = strtrim("`b4_6'") + "\sym{*}"
		else local `i'_b4_6 = strtrim("`b4_6'")
		local se4_6: display `format' _se[treat_arm_4]
		local `i'_se4_6 = "(" + strtrim("`se4_6'") + ")"
				
		local `i'_obs_6 = e(N)
		
		
		
		// grade 8 in 2023
	reghdfe `i' treat_arm_1 treat_arm_2 treat_arm_3 treat_arm_4 if grade_21==9, absorb(strata) ///
	vce(clustervar school_21)
	
		local b1_7: display `format' _b[treat_arm_1] 
		scalar t_stat1_7 = _b[treat_arm_1]/_se[treat_arm_1]
		scalar df1_7 = e(df_r)
		scalar pval1_7 = 2 * ttail(df1_7, abs(t_stat1_7))
		if pval1_7 < 0.01 local `i'_b1_7 = strtrim("`b1_7'") + "\sym{***}"
		else if pval1_7 < 0.05 local `i'_b1_7 = strtrim("`b1_7'") + "\sym{**}"
		else if pval1_7 < 0.1 local `i'_b1_7 = strtrim("`b1_7'") + "\sym{*}"
		else local `i'_b1_7 = strtrim("`b1_7'")
		local se1_7: display `format' _se[treat_arm_1]
		local `i'_se1_7 = "(" + strtrim("`se1_7'") + ")"

		local b2_7: display `format' _b[treat_arm_2] 
		scalar t_stat2_7 = _b[treat_arm_2]/_se[treat_arm_2]
		scalar df2_7 = e(df_r)
		scalar pval2_7 = 2 * ttail(df2_7, abs(t_stat2_7))
		if pval2_7 < 0.01 local `i'_b2_7 = strtrim("`b2_7'") + "\sym{***}"
		else if pval2_7 < 0.05 local `i'_b2_7 = strtrim("`b2_7'") + "\sym{**}"
		else if pval2_7 < 0.1 local `i'_b2_7 = strtrim("`b2_7'") + "\sym{*}"
		else local `i'_b2_7 = strtrim("`b2_7'")
		local se2_7: display `format' _se[treat_arm_2]
		local `i'_se2_7 = "(" + strtrim("`se2_7'") + ")"

		local b3_7: display `format' _b[treat_arm_3] 
		scalar t_stat3_7 = _b[treat_arm_3]/_se[treat_arm_3]
		scalar df3_7 = e(df_r)
		scalar pval3_7 = 2 * ttail(df3_7, abs(t_stat3_7))
		if pval3_7 < 0.01 local `i'_b3_7 = strtrim("`b3_7'") + "\sym{***}"
		else if pval3_7 < 0.05 local `i'_b3_7 = strtrim("`b3_7'") + "\sym{**}"
		else if pval3_7 < 0.1 local `i'_b3_7 = strtrim("`b3_7'") + "\sym{*}"
		else local `i'_b3_7 = strtrim("`b3_7'")
		local se3_7: display `format' _se[treat_arm_3]
		local `i'_se3_7 = "(" + strtrim("`se3_7'") + ")"
		
		local b4_7: display `format' _b[treat_arm_4] 
		scalar t_stat4_7 = _b[treat_arm_4]/_se[treat_arm_4]
		scalar df4_7 = e(df_r)
		scalar pval4_7 = 2 * ttail(df4_7, abs(t_stat4_7))
		if pval4_7 < 0.01 local `i'_b4_7 = strtrim("`b4_7'") + "\sym{***}"
		else if pval4_7 < 0.05 local `i'_b4_7 = strtrim("`b4_7'") + "\sym{**}"
		else if pval4_7 < 0.1 local `i'_b4_7 = strtrim("`b4_7'") + "\sym{*}"
		else local `i'_b4_7 = strtrim("`b4_7'")
		local se4_7: display `format' _se[treat_arm_4]
		local `i'_se4_7 = "(" + strtrim("`se4_7'") + ")"
				
		local `i'_obs_7 = e(N)
		
	}


texdoc init "$output\tables\appendix\treatment_changes_23_by_grade - math.tex", replace force 

	tex \begin{table}[htbp]
	tex \centering
	tex \resizebox{\linewidth}{!}{%
	tex \begin{threeparttable}
	tex \caption{\textbf{May 2023 Treatment Changes by Grade}}
	tex \fontsize{4}{5}\selectfont
	tex \begin{tabular}{l*{5}c}
	tex \hline\hline
	tex &\multicolumn{1}{c}{TA 1} &\multicolumn{1}{c}{TA 2} &\multicolumn{1}{c}{TA 3} &\multicolumn{1}{c}{TA 4} &\multicolumn{1}{c}{N} \\
	tex &\multicolumn{1}{c}{(1)} &\multicolumn{1}{c}{(2)} &\multicolumn{1}{c}{(3)} &\multicolumn{1}{c}{(4)} &\multicolumn{1}{c}{(5)} \\
	tex \hline \\
	tex [1ex] 
	
	tex &\multicolumn{4}{l}{textbf{Treatment status in September 2021}} \\
	tex [1ex]
	
	tex &\multicolumn{4}{l}{textit{Panel A: Grade 3}} \\
	tex [1ex]
	
	tex TA 1 & `s_ta1_23_b1_3' & `s_ta1_23_b2_3' & `s_ta1_23_b3_3' & `s_ta1_23_b4_3' & \\
	tex & `s_ta1_23_se1_3' & `s_ta1_23_se2_3' & `s_ta1_23_se3_3' & `s_ta1_23_se4_3' & \\
	tex [1ex]
	
	tex TA 2 & `s_ta2_23_b1_3' & `s_ta2_23_b2_3' & `s_ta2_23_b3_3' & `s_ta2_23_b4_3' & \\
	tex & `s_ta2_23_se1_3' & `s_ta2_23_se2_3' & `s_ta2_23_se3_3' & `s_ta2_23_se4_3' &\\
	tex [1ex]
	
	tex TA 3 & `s_ta3_23_b1_3' & `s_ta3_23_b2_3' & `s_ta3_23_b3_3' & `s_ta3_23_b4_3' & \\
	tex & `s_ta3_23_se1_3' & `s_ta3_23_se2_3' & `s_ta3_23_se3_3' & `s_ta3_23_se4_3' & \\
	tex [1ex]
	
	tex TA 4 & `s_ta4_23_b1_3' & `s_ta4_23_b2_3' & `s_ta4_23_b3_3' & `s_ta4_23_b4_3' & \\
	tex & `s_ta4_23_se1_3' & `s_ta4_23_se2_3' & `s_ta4_23_se3_3' & `s_ta4_23_se4_3' & \\
	tex [1ex]
	
	tex N & & & & & `s_ta1_23_obs_3' \\
	
	tex &&&&&& \\
	
	tex &\multicolumn{4}{l}{textit{Panel B: Grade 4}} \\
	tex [1ex]
	
	tex TA 1 & `s_ta1_23_b1_4' & `s_ta1_23_b2_4' & `s_ta1_23_b3_4' & `s_ta1_23_b4_4' & \\
	tex & `s_ta1_23_se1_4' & `s_ta1_23_se2_4' & `s_ta1_23_se3_4' & `s_ta1_23_se4_4' & \\
	tex [1ex]
	
	tex TA 2 & `s_ta2_23_b1_4' & `s_ta2_23_b2_4' & `s_ta2_23_b3_4' & `s_ta2_23_b4_4' & \\
	tex & `s_ta2_23_se1_4' & `s_ta2_23_se2_4' & `s_ta2_23_se3_4' & `s_ta2_23_se4_4' &\\
	tex [1ex]
	
	tex TA 3 & `s_ta3_23_b1_4' & `s_ta3_23_b2_4' & `s_ta3_23_b3_4' & `s_ta3_23_b4_4' & \\
	tex & `s_ta3_23_se1_4' & `s_ta3_23_se2_4' & `s_ta3_23_se3_4' & `s_ta3_23_se4_4' & \\
	tex [1ex]
	
	tex TA 4 & `s_ta4_23_b1_4' & `s_ta4_23_b2_4' & `s_ta4_23_b3_4' & `s_ta4_23_b4_4' & \\
	tex & `s_ta4_23_se1_4' & `s_ta4_23_se2_4' & `s_ta4_23_se3_4' & `s_ta4_23_se4_4' & \\
	tex [1ex]
	
	tex N & & & & & `s_ta1_23_obs_4' \\
	
	tex &&&&&& \\
	
	tex &\multicolumn{4}{l}{textit{Panel C: Grade 5}} \\
	tex [1ex]
	
	tex TA 1 & `s_ta1_23_b1_5' & `s_ta1_23_b2_5' & `s_ta1_23_b3_5' & `s_ta1_23_b4_5' & \\
	tex & `s_ta1_23_se1_5' & `s_ta1_23_se2_5' & `s_ta1_23_se3_5' & `s_ta1_23_se4_5' & \\
	tex [1ex]
	
	tex TA 2 & `s_ta2_23_b1_5' & `s_ta2_23_b2_5' & `s_ta2_23_b3_5' & `s_ta2_23_b4_5' & \\
	tex & `s_ta2_23_se1_5' & `s_ta2_23_se2_5' & `s_ta2_23_se3_5' & `s_ta2_23_se4_5' &\\
	tex [1ex]
	
	tex TA 3 & `s_ta3_23_b1_5' & `s_ta3_23_b2_5' & `s_ta3_23_b3_5' & `s_ta3_23_b4_5' & \\
	tex & `s_ta3_23_se1_5' & `s_ta3_23_se2_5' & `s_ta3_23_se3_5' & `s_ta3_23_se4_5' & \\
	tex [1ex]
	
	tex TA 4 & `s_ta4_23_b1_5' & `s_ta4_23_b2_5' & `s_ta4_23_b3_5' & `s_ta4_23_b4_5' & \\
	tex & `s_ta4_23_se1_5' & `s_ta4_23_se2_5' & `s_ta4_23_se3_5' & `s_ta4_23_se4_5' & \\
	tex [1ex]
	
	tex N & & & & & `s_ta1_23_obs_5' \\
	
	tex &&&&&& \\
	
	tex &\multicolumn{4}{l}{textit{Panel D: Grade 6}} \\
	tex [1ex]
	
	tex TA 1 & `s_ta1_23_b1_6' & `s_ta1_23_b2_6' & `s_ta1_23_b3_6' & `s_ta1_23_b4_6' & \\
	tex & `s_ta1_23_se1_6' & `s_ta1_23_se2_6' & `s_ta1_23_se3_6' & `s_ta1_23_se4_6' & \\
	tex [1ex]
	
	tex TA 2 & `s_ta2_23_b1_6' & `s_ta2_23_b2_6' & `s_ta2_23_b3_6' & `s_ta2_23_b4_6' & \\
	tex & `s_ta2_23_se1_6' & `s_ta2_23_se2_6' & `s_ta2_23_se3_6' & `s_ta2_23_se4_6' &\\
	tex [1ex]
	
	tex TA 3 & `s_ta3_23_b1_6' & `s_ta3_23_b2_6' & `s_ta3_23_b3_6' & `s_ta3_23_b4_6' & \\
	tex & `s_ta3_23_se1_6' & `s_ta3_23_se2_6' & `s_ta3_23_se3_6' & `s_ta3_23_se4_6' & \\
	tex [1ex]
	
	tex TA 4 & `s_ta4_23_b1_6' & `s_ta4_23_b2_6' & `s_ta4_23_b3_6' & `s_ta4_23_b4_6' & \\
	tex & `s_ta4_23_se1_6' & `s_ta4_23_se2_6' & `s_ta4_23_se3_6' & `s_ta4_23_se4_6' & \\
	tex [1ex]
	
	tex N & & & & & `s_ta1_23_obs_6' \\
	
	tex &&&&&& \\
	
	tex &\multicolumn{4}{l}{textit{Panel E: Grade 7}} \\
	tex [1ex]
	
	tex TA 1 & `s_ta1_23_b1_7' & `s_ta1_23_b2_7' & `s_ta1_23_b3_7' & `s_ta1_23_b4_7' & \\
	tex & `s_ta1_23_se1_7' & `s_ta1_23_se2_7' & `s_ta1_23_se3_7' & `s_ta1_23_se4_7' & \\
	tex [1ex]
	
	tex TA 2 & `s_ta2_23_b1_7' & `s_ta2_23_b2_7' & `s_ta2_23_b3_7' & `s_ta2_23_b4_7' & \\
	tex & `s_ta2_23_se1_7' & `s_ta2_23_se2_7' & `s_ta2_23_se3_7' & `s_ta2_23_se4_7' &\\
	tex [1ex]
	
	tex TA 3 & `s_ta3_23_b1_7' & `s_ta3_23_b2_7' & `s_ta3_23_b3_7' & `s_ta3_23_b4_7' & \\
	tex & `s_ta3_23_se1_7' & `s_ta3_23_se2_7' & `s_ta3_23_se3_7' & `s_ta3_23_se4_7' & \\
	tex [1ex]
	
	tex TA 4 & `s_ta4_23_b1_7' & `s_ta4_23_b2_7' & `s_ta4_23_b3_7' & `s_ta4_23_b4_7' & \\
	tex & `s_ta4_23_se1_7' & `s_ta4_23_se2_7' & `s_ta4_23_se3_7' & `s_ta4_23_se4_7' & \\
	tex [1ex]
	
	tex N & & & & & `s_ta1_23_obs_7' \\
	
	tex &&&&&& \\
	tex \hline \hline \\
	tex \end{tabular}
	tex \end{threeparttable}
	tex }
	tex \end{table}

	
texdoc close	
		



//============================================================================//
// CHECKING 2022 STUDENT TRANSFERS BY GRADE
//============================================================================//

// treatment in 2023
use "$input\interim\transfers_math", clear 

drop if ACADEMIC_YEAR_ID_FK==2023

local s_treat "s_ta1_22 s_ta2_22 s_ta3_22 s_ta4_22 s_c_22"
		

local format "%9.3fc"

foreach i in `s_treat'{

		// grade 4
	reghdfe `i' treat_arm_1 treat_arm_2 treat_arm_3 treat_arm_4 if grade_21==6, absorb(strata) ///
	vce(clustervar school_21)
	
		local b1_41: display `format' _b[treat_arm_1] 
		scalar t_stat1_41 = _b[treat_arm_1]/_se[treat_arm_1]
		scalar df1_41 = e(df_r)
		scalar pval1_41 = 2 * ttail(df1_41, abs(t_stat1_41))
		if pval1_41 < 0.01 local `i'_b1_41 = strtrim("`b1_41'") + "\sym{***}"
		else if pval1_41 < 0.05 local `i'_b1_41 = strtrim("`b1_41'") + "\sym{**}"
		else if pval1_41 < 0.1 local `i'_b1_41 = strtrim("`b1_41'") + "\sym{*}"
		else local `i'_b1_41 = strtrim("`b1_41'")
		local se1_41: display `format' _se[treat_arm_1]
		local `i'_se1_41 = "(" + strtrim("`se1_41'") + ")"

		local b2_41: display `format' _b[treat_arm_2] 
		scalar t_stat2_41 = _b[treat_arm_2]/_se[treat_arm_2]
		scalar df2_41 = e(df_r)
		scalar pval2_41 = 2 * ttail(df2_41, abs(t_stat2_41))
		if pval2_41 < 0.01 local `i'_b2_41 = strtrim("`b2_41'") + "\sym{***}"
		else if pval2_41 < 0.05 local `i'_b2_41 = strtrim("`b2_41'") + "\sym{**}"
		else if pval2_41 < 0.1 local `i'_b2_41 = strtrim("`b2_41'") + "\sym{*}"
		else local `i'_b2_41 = strtrim("`b2_41'")
		local se2_41: display `format' _se[treat_arm_2]
		local `i'_se2_41 = "(" + strtrim("`se2_41'") + ")"

		local b3_41: display `format' _b[treat_arm_3] 
		scalar t_stat3_41 = _b[treat_arm_3]/_se[treat_arm_3]
		scalar df3_41 = e(df_r)
		scalar pval3_41 = 2 * ttail(df3_41, abs(t_stat3_41))
		if pval3_41 < 0.01 local `i'_b3_41 = strtrim("`b3_41'") + "\sym{***}"
		else if pval3_41 < 0.05 local `i'_b3_41 = strtrim("`b3_41'") + "\sym{**}"
		else if pval3_41 < 0.1 local `i'_b3_41 = strtrim("`b3_41'") + "\sym{*}"
		else local `i'_b3_41 = strtrim("`b3_41'")
		local se3_41: display `format' _se[treat_arm_3]
		local `i'_se3_41 = "(" + strtrim("`se3_41'") + ")"
		
		local b4_41: display `format' _b[treat_arm_4] 
		scalar t_stat4_41 = _b[treat_arm_4]/_se[treat_arm_4]
		scalar df4_41 = e(df_r)
		scalar pval4_41 = 2 * ttail(df4_41, abs(t_stat4_41))
		if pval4_41 < 0.01 local `i'_b4_41 = strtrim("`b4_41'") + "\sym{***}"
		else if pval4_41 < 0.05 local `i'_b4_41 = strtrim("`b4_41'") + "\sym{**}"
		else if pval4_41 < 0.1 local `i'_b4_41 = strtrim("`b4_41'") + "\sym{*}"
		else local `i'_b4_41 = strtrim("`b4_41'")
		local se4_41: display `format' _se[treat_arm_4]
		local `i'_se4_41 = "(" + strtrim("`se4_41'") + ")"
				
		local `i'_obs_41 = e(N)
		
	
		// grade 5
	reghdfe `i' treat_arm_1 treat_arm_2 treat_arm_3 treat_arm_4 if grade_21==7, absorb(strata) ///
	vce(clustervar school_21)
	
		local b1_51: display `format' _b[treat_arm_1] 
		scalar t_stat1_51 = _b[treat_arm_1]/_se[treat_arm_1]
		scalar df1_51 = e(df_r)
		scalar pval1_51 = 2 * ttail(df1_51, abs(t_stat1_51))
		if pval1_51 < 0.01 local `i'_b1_51 = strtrim("`b1_51'") + "\sym{***}"
		else if pval1_51 < 0.05 local `i'_b1_51 = strtrim("`b1_51'") + "\sym{**}"
		else if pval1_51 < 0.1 local `i'_b1_51 = strtrim("`b1_51'") + "\sym{*}"
		else local `i'_b1_51 = strtrim("`b1_51'")
		local se1_51: display `format' _se[treat_arm_1]
		local `i'_se1_51 = "(" + strtrim("`se1_51'") + ")"

		local b2_51: display `format' _b[treat_arm_2] 
		scalar t_stat2_51 = _b[treat_arm_2]/_se[treat_arm_2]
		scalar df2_51 = e(df_r)
		scalar pval2_51 = 2 * ttail(df2_51, abs(t_stat2_51))
		if pval2_51 < 0.01 local `i'_b2_51 = strtrim("`b2_51'") + "\sym{***}"
		else if pval2_51 < 0.05 local `i'_b2_51 = strtrim("`b2_51'") + "\sym{**}"
		else if pval2_51 < 0.1 local `i'_b2_51 = strtrim("`b2_51'") + "\sym{*}"
		else local `i'_b2_51 = strtrim("`b2_51'")
		local se2_51: display `format' _se[treat_arm_2]
		local `i'_se2_51 = "(" + strtrim("`se2_51'") + ")"

		local b3_51: display `format' _b[treat_arm_3] 
		scalar t_stat3_51 = _b[treat_arm_3]/_se[treat_arm_3]
		scalar df3_51 = e(df_r)
		scalar pval3_51 = 2 * ttail(df3_51, abs(t_stat3_51))
		if pval3_51 < 0.01 local `i'_b3_51 = strtrim("`b3_51'") + "\sym{***}"
		else if pval3_51 < 0.05 local `i'_b3_51 = strtrim("`b3_51'") + "\sym{**}"
		else if pval3_51 < 0.1 local `i'_b3_51 = strtrim("`b3_51'") + "\sym{*}"
		else local `i'_b3_51 = strtrim("`b3_51'")
		local se3_51: display `format' _se[treat_arm_3]
		local `i'_se3_51 = "(" + strtrim("`se3_51'") + ")"
		
		local b4_51: display `format' _b[treat_arm_4] 
		scalar t_stat4_51 = _b[treat_arm_4]/_se[treat_arm_4]
		scalar df4_51 = e(df_r)
		scalar pval4_51 = 2 * ttail(df4_51, abs(t_stat4_51))
		if pval4_51 < 0.01 local `i'_b4_51 = strtrim("`b4_51'") + "\sym{***}"
		else if pval4_51 < 0.05 local `i'_b4_51 = strtrim("`b4_51'") + "\sym{**}"
		else if pval4_51 < 0.1 local `i'_b4_51 = strtrim("`b4_51'") + "\sym{*}"
		else local `i'_b4_51 = strtrim("`b4_51'")
		local se4_51: display `format' _se[treat_arm_4]
		local `i'_se4_51 = "(" + strtrim("`se4_51'") + ")"
				
		local `i'_obs_51 = e(N)
		
		
		// grade 6 
	reghdfe `i' treat_arm_1 treat_arm_2 treat_arm_3 treat_arm_4 if grade_21==8, absorb(strata) ///
	vce(clustervar school_21)
	
		local b1_61: display `format' _b[treat_arm_1] 
		scalar t_stat1_61 = _b[treat_arm_1]/_se[treat_arm_1]
		scalar df1_61 = e(df_r)
		scalar pval1_61 = 2 * ttail(df1_61, abs(t_stat1_61))
		if pval1_61 < 0.01 local `i'_b1_61 = strtrim("`b1_61'") + "\sym{***}"
		else if pval1_61 < 0.05 local `i'_b1_61 = strtrim("`b1_61'") + "\sym{**}"
		else if pval1_61 < 0.1 local `i'_b1_61 = strtrim("`b1_61'") + "\sym{*}"
		else local `i'_b1_61 = strtrim("`b1_61'")
		local se1_61: display `format' _se[treat_arm_1]
		local `i'_se1_61 = "(" + strtrim("`se1_61'") + ")"

		local b2_61: display `format' _b[treat_arm_2] 
		scalar t_stat2_61 = _b[treat_arm_2]/_se[treat_arm_2]
		scalar df2_61 = e(df_r)
		scalar pval2_61 = 2 * ttail(df2_61, abs(t_stat2_61))
		if pval2_61 < 0.01 local `i'_b2_61 = strtrim("`b2_61'") + "\sym{***}"
		else if pval2_61 < 0.05 local `i'_b2_61 = strtrim("`b2_61'") + "\sym{**}"
		else if pval2_61 < 0.1 local `i'_b2_61 = strtrim("`b2_61'") + "\sym{*}"
		else local `i'_b2_61 = strtrim("`b2_61'")
		local se2_61: display `format' _se[treat_arm_2]
		local `i'_se2_61 = "(" + strtrim("`se2_61'") + ")"

		local b3_61: display `format' _b[treat_arm_3] 
		scalar t_stat3_61 = _b[treat_arm_3]/_se[treat_arm_3]
		scalar df3_61 = e(df_r)
		scalar pval3_61 = 2 * ttail(df3_61, abs(t_stat3_61))
		if pval3_61 < 0.01 local `i'_b3_61 = strtrim("`b3_61'") + "\sym{***}"
		else if pval3_61 < 0.05 local `i'_b3_61 = strtrim("`b3_61'") + "\sym{**}"
		else if pval3_61 < 0.1 local `i'_b3_61 = strtrim("`b3_61'") + "\sym{*}"
		else local `i'_b3_61 = strtrim("`b3_61'")
		local se3_61: display `format' _se[treat_arm_3]
		local `i'_se3_61 = "(" + strtrim("`se3_61'") + ")"
		
		local b4_61: display `format' _b[treat_arm_4] 
		scalar t_stat4_61 = _b[treat_arm_4]/_se[treat_arm_4]
		scalar df4_61 = e(df_r)
		scalar pval4_61 = 2 * ttail(df4_61, abs(t_stat4_61))
		if pval4_61 < 0.01 local `i'_b4_61 = strtrim("`b4_61'") + "\sym{***}"
		else if pval4_61 < 0.05 local `i'_b4_61 = strtrim("`b4_61'") + "\sym{**}"
		else if pval4_61 < 0.1 local `i'_b4_61 = strtrim("`b4_61'") + "\sym{*}"
		else local `i'_b4_61 = strtrim("`b4_61'")
		local se4_61: display `format' _se[treat_arm_4]
		local `i'_se4_61 = "(" + strtrim("`se4_61'") + ")"
				
		local `i'_obs_61 = e(N)
		
		
		
		// grade 7
	reghdfe `i' treat_arm_1 treat_arm_2 treat_arm_3 treat_arm_4 if grade_21==9, absorb(strata) ///
	vce(clustervar school_21)
	
		local b1_71: display `format' _b[treat_arm_1] 
		scalar t_stat1_71 = _b[treat_arm_1]/_se[treat_arm_1]
		scalar df1_71 = e(df_r)
		scalar pval1_71 = 2 * ttail(df1_71, abs(t_stat1_71))
		if pval1_71 < 0.01 local `i'_b1_71 = strtrim("`b1_71'") + "\sym{***}"
		else if pval1_71 < 0.05 local `i'_b1_71 = strtrim("`b1_71'") + "\sym{**}"
		else if pval1_71 < 0.1 local `i'_b1_71 = strtrim("`b1_71'") + "\sym{*}"
		else local `i'_b1_71 = strtrim("`b1_71'")
		local se1_71: display `format' _se[treat_arm_1]
		local `i'_se1_71 = "(" + strtrim("`se1_71'") + ")"

		local b2_71: display `format' _b[treat_arm_2] 
		scalar t_stat2_71 = _b[treat_arm_2]/_se[treat_arm_2]
		scalar df2_71 = e(df_r)
		scalar pval2_71 = 2 * ttail(df2_71, abs(t_stat2_71))
		if pval2_71 < 0.01 local `i'_b2_71 = strtrim("`b2_71'") + "\sym{***}"
		else if pval2_71 < 0.05 local `i'_b2_71 = strtrim("`b2_71'") + "\sym{**}"
		else if pval2_71 < 0.1 local `i'_b2_71 = strtrim("`b2_71'") + "\sym{*}"
		else local `i'_b2_71 = strtrim("`b2_71'")
		local se2_71: display `format' _se[treat_arm_2]
		local `i'_se2_71 = "(" + strtrim("`se2_71'") + ")"

		local b3_71: display `format' _b[treat_arm_3] 
		scalar t_stat3_71 = _b[treat_arm_3]/_se[treat_arm_3]
		scalar df3_71 = e(df_r)
		scalar pval3_71 = 2 * ttail(df3_71, abs(t_stat3_71))
		if pval3_71 < 0.01 local `i'_b3_71 = strtrim("`b3_71'") + "\sym{***}"
		else if pval3_71 < 0.05 local `i'_b3_71 = strtrim("`b3_71'") + "\sym{**}"
		else if pval3_71 < 0.1 local `i'_b3_71 = strtrim("`b3_71'") + "\sym{*}"
		else local `i'_b3_71 = strtrim("`b3_71'")
		local se3_71: display `format' _se[treat_arm_3]
		local `i'_se3_71 = "(" + strtrim("`se3_71'") + ")"
		
		local b4_71: display `format' _b[treat_arm_4] 
		scalar t_stat4_71 = _b[treat_arm_4]/_se[treat_arm_4]
		scalar df4_71 = e(df_r)
		scalar pval4_71 = 2 * ttail(df4_71, abs(t_stat4_71))
		if pval4_71 < 0.01 local `i'_b4_71 = strtrim("`b4_71'") + "\sym{***}"
		else if pval4_71 < 0.05 local `i'_b4_71 = strtrim("`b4_71'") + "\sym{**}"
		else if pval4_71 < 0.1 local `i'_b4_71 = strtrim("`b4_71'") + "\sym{*}"
		else local `i'_b4_71 = strtrim("`b4_71'")
		local se4_71: display `format' _se[treat_arm_4]
		local `i'_se4_71 = "(" + strtrim("`se4_71'") + ")"
				
		local `i'_obs_71 = e(N)
		
		// grade 8
	reghdfe `i' treat_arm_1 treat_arm_2 treat_arm_3 treat_arm_4 if grade_21==10, absorb(strata) ///
	vce(clustervar school_21)
	
		local b1_81: display `format' _b[treat_arm_1] 
		scalar t_stat1_81 = _b[treat_arm_1]/_se[treat_arm_1]
		scalar df1_81 = e(df_r)
		scalar pval1_81 = 2 * ttail(df1_81, abs(t_stat1_81))
		if pval1_81 < 0.01 local `i'_b1_81 = strtrim("`b1_81'") + "\sym{***}"
		else if pval1_81 < 0.05 local `i'_b1_81 = strtrim("`b1_81'") + "\sym{**}"
		else if pval1_81 < 0.1 local `i'_b1_81 = strtrim("`b1_81'") + "\sym{*}"
		else local `i'_b1_81 = strtrim("`b1_81'")
		local se1_81: display `format' _se[treat_arm_1]
		local `i'_se1_81 = "(" + strtrim("`se1_81'") + ")"

		local b2_81: display `format' _b[treat_arm_2] 
		scalar t_stat2_81 = _b[treat_arm_2]/_se[treat_arm_2]
		scalar df2_81 = e(df_r)
		scalar pval2_81 = 2 * ttail(df2_81, abs(t_stat2_81))
		if pval2_81 < 0.01 local `i'_b2_81 = strtrim("`b2_81'") + "\sym{***}"
		else if pval2_81 < 0.05 local `i'_b2_81 = strtrim("`b2_81'") + "\sym{**}"
		else if pval2_81 < 0.1 local `i'_b2_81 = strtrim("`b2_81'") + "\sym{*}"
		else local `i'_b2_81 = strtrim("`b2_81'")
		local se2_81: display `format' _se[treat_arm_2]
		local `i'_se2_81 = "(" + strtrim("`se2_81'") + ")"

		local b3_81: display `format' _b[treat_arm_3] 
		scalar t_stat3_81 = _b[treat_arm_3]/_se[treat_arm_3]
		scalar df3_81 = e(df_r)
		scalar pval3_81 = 2 * ttail(df3_81, abs(t_stat3_81))
		if pval3_81 < 0.01 local `i'_b3_81 = strtrim("`b3_81'") + "\sym{***}"
		else if pval3_81 < 0.05 local `i'_b3_81 = strtrim("`b3_81'") + "\sym{**}"
		else if pval3_81 < 0.1 local `i'_b3_81 = strtrim("`b3_81'") + "\sym{*}"
		else local `i'_b3_81 = strtrim("`b3_81'")
		local se3_81: display `format' _se[treat_arm_3]
		local `i'_se3_81 = "(" + strtrim("`se3_81'") + ")"
		
		local b4_81: display `format' _b[treat_arm_4] 
		scalar t_stat4_81 = _b[treat_arm_4]/_se[treat_arm_4]
		scalar df4_81 = e(df_r)
		scalar pval4_81 = 2 * ttail(df4_81, abs(t_stat4_81))
		if pval4_81 < 0.01 local `i'_b4_81 = strtrim("`b4_81'") + "\sym{***}"
		else if pval4_81 < 0.05 local `i'_b4_81 = strtrim("`b4_81'") + "\sym{**}"
		else if pval4_81 < 0.1 local `i'_b4_81 = strtrim("`b4_81'") + "\sym{*}"
		else local `i'_b4_81 = strtrim("`b4_81'")
		local se4_81: display `format' _se[treat_arm_4]
		local `i'_se4_81 = "(" + strtrim("`se4_81'") + ")"
				
		local `i'_obs_81 = e(N)
		
		
	}


texdoc init "$output\tables\appendix\treatment_changes_22_by_grade - math.tex", replace force 

	tex \begin{table}[htbp]
	tex \centering
	tex \resizebox{\linewidth}{!}{%
	tex \begin{threeparttable}
	tex \caption{\textbf{May 2022 Treatment Changes by Grade}}
	tex \fontsize{4}{5}\selectfont
	tex \begin{tabular}{l*{5}c}
	tex \hline\hline
	tex &\multicolumn{1}{c}{TA 1} &\multicolumn{1}{c}{TA 2} &\multicolumn{1}{c}{TA 3} &\multicolumn{1}{c}{TA 4} &\multicolumn{1}{c}{N} \\
	tex &\multicolumn{1}{c}{(1)} &\multicolumn{1}{c}{(2)} &\multicolumn{1}{c}{(3)} &\multicolumn{1}{c}{(4)} &\multicolumn{1}{c}{(5)} \\
	tex \hline \\
	tex [1ex] 
	
	tex &\multicolumn{4}{l}{textbf{Treatment status in September 2021}} \\
	tex [1ex]
		
	tex &\multicolumn{4}{l}{textit{Panel A: Grade 4}} \\
	tex [1ex]
	
	tex TA 1 & `s_ta1_22_b1_41' & `s_ta1_22_b2_41' & `s_ta1_22_b3_41' & `s_ta1_22_b4_41' & \\
	tex & `s_ta1_22_se1_41' & `s_ta1_22_se2_41' & `s_ta1_22_se3_41' & `s_ta1_22_se4_41' & \\
	tex [1ex]
	
	tex TA 2 & `s_ta2_22_b1_41' & `s_ta2_22_b2_41' & `s_ta2_22_b3_41' & `s_ta2_22_b4_41' & \\
	tex & `s_ta2_22_se1_41' & `s_ta2_22_se2_41' & `s_ta2_22_se3_41' & `s_ta2_22_se4_41' &\\
	tex [1ex]
	
	tex TA 3 & `s_ta3_22_b1_41' & `s_ta3_22_b2_41' & `s_ta3_22_b3_41' & `s_ta3_22_b4_41' & \\
	tex & `s_ta3_22_se1_41' & `s_ta3_22_se2_41' & `s_ta3_22_se3_41' & `s_ta3_22_se4_41' & \\
	tex [1ex]
	
	tex TA 4 & `s_ta4_22_b1_41' & `s_ta4_22_b2_41' & `s_ta4_22_b3_41' & `s_ta4_22_b4_41' & \\
	tex & `s_ta4_22_se1_41' & `s_ta4_22_se2_41' & `s_ta4_22_se3_41' & `s_ta4_22_se4_41' & \\
	tex [1ex]
	
	tex N & & & & & `s_ta1_22_obs_41' \\
	
	tex &&&&&& \\
	
	tex &\multicolumn{4}{l}{textit{Panel B: Grade 5}} \\
	tex [1ex]
	
	tex TA 1 & `s_ta1_22_b1_51' & `s_ta1_22_b2_51' & `s_ta1_22_b3_51' & `s_ta1_22_b4_51' & \\
	tex & `s_ta1_22_se1_51' & `s_ta1_22_se2_51' & `s_ta1_22_se3_51' & `s_ta1_22_se4_51' & \\
	tex [1ex]
	
	tex TA 2 & `s_ta2_22_b1_51' & `s_ta2_22_b2_51' & `s_ta2_22_b3_51' & `s_ta2_22_b4_51' & \\
	tex & `s_ta2_22_se1_51' & `s_ta2_22_se2_51' & `s_ta2_22_se3_51' & `s_ta2_22_se4_51' &\\
	tex [1ex]
	
	tex TA 3 & `s_ta3_22_b1_51' & `s_ta3_22_b2_51' & `s_ta3_22_b3_51' & `s_ta3_22_b4_51' & \\
	tex & `s_ta3_22_se1_51' & `s_ta3_22_se2_51' & `s_ta3_22_se3_51' & `s_ta3_22_se4_51' & \\
	tex [1ex]
	
	tex TA 4 & `s_ta4_22_b1_51' & `s_ta4_22_b2_51' & `s_ta4_22_b3_51' & `s_ta4_22_b4_51' & \\
	tex & `s_ta4_22_se1_51' & `s_ta4_22_se2_51' & `s_ta4_22_se3_51' & `s_ta4_22_se4_51' & \\
	tex [1ex]
	
	tex N & & & & & `s_ta1_22_obs_51' \\
	
	tex &&&&&& \\
	
	tex &\multicolumn{4}{l}{textit{Panel C: Grade 6}} \\
	tex [1ex]
	
	tex TA 1 & `s_ta1_22_b1_61' & `s_ta1_22_b2_61' & `s_ta1_22_b3_61' & `s_ta1_22_b4_61' & \\
	tex & `s_ta1_22_se1_61' & `s_ta1_22_se2_61' & `s_ta1_22_se3_61' & `s_ta1_22_se4_61' & \\
	tex [1ex]
	
	tex TA 2 & `s_ta2_22_b1_61' & `s_ta2_22_b2_61' & `s_ta2_22_b3_61' & `s_ta2_22_b4_61' & \\
	tex & `s_ta2_22_se1_61' & `s_ta2_22_se2_61' & `s_ta2_22_se3_61' & `s_ta2_22_se4_61' &\\
	tex [1ex]
	
	tex TA 3 & `s_ta3_22_b1_61' & `s_ta3_22_b2_61' & `s_ta3_22_b3_61' & `s_ta3_22_b4_61' & \\
	tex & `s_ta3_22_se1_61' & `s_ta3_22_se2_61' & `s_ta3_22_se3_61' & `s_ta3_22_se4_61' & \\
	tex [1ex]
	
	tex TA 4 & `s_ta4_22_b1_61' & `s_ta4_22_b2_61' & `s_ta4_22_b3_61' & `s_ta4_22_b4_61' & \\
	tex & `s_ta4_22_se1_61' & `s_ta4_22_se2_61' & `s_ta4_22_se3_61' & `s_ta4_22_se4_61' & \\
	tex [1ex]
	
	tex N & & & & & `s_ta1_22_obs_61' \\
	
	tex &&&&&& \\
	
	tex &\multicolumn{4}{l}{textit{Panel D: Grade 7}} \\
	tex [1ex]
	
	tex TA 1 & `s_ta1_22_b1_71' & `s_ta1_22_b2_71' & `s_ta1_22_b3_71' & `s_ta1_22_b4_71' & \\
	tex & `s_ta1_22_se1_71' & `s_ta1_22_se2_71' & `s_ta1_22_se3_71' & `s_ta1_22_se4_71' & \\
	tex [1ex]
	
	tex TA 2 & `s_ta2_22_b1_71' & `s_ta2_22_b2_71' & `s_ta2_22_b3_71' & `s_ta2_22_b4_71' & \\
	tex & `s_ta2_22_se1_71' & `s_ta2_22_se2_71' & `s_ta2_22_se3_71' & `s_ta2_22_se4_71' &\\
	tex [1ex]
	
	tex TA 3 & `s_ta3_22_b1_71' & `s_ta3_22_b2_71' & `s_ta3_22_b3_71' & `s_ta3_22_b4_71' & \\
	tex & `s_ta3_22_se1_71' & `s_ta3_22_se2_71' & `s_ta3_22_se3_71' & `s_ta3_22_se4_71' & \\
	tex [1ex]
	
	tex TA 4 & `s_ta4_22_b1_71' & `s_ta4_22_b2_71' & `s_ta4_22_b3_71' & `s_ta4_22_b4_71' & \\
	tex & `s_ta4_22_se1_71' & `s_ta4_22_se2_71' & `s_ta4_22_se3_71' & `s_ta4_22_se4_71' & \\
	tex [1ex]
	
	tex N & & & & & `s_ta1_22_obs_71' \\
	
	tex &&&&&& \\ 
	
	tex &\multicolumn{4}{l}{textit{Panel E: Grade 8}} \\
	tex [1ex]
	
	tex TA 1 & `s_ta1_22_b1_81' & `s_ta1_22_b2_81' & `s_ta1_22_b3_81' & `s_ta1_22_b4_81' & \\
	tex & `s_ta1_22_se1_81' & `s_ta1_22_se2_81' & `s_ta1_22_se3_81' & `s_ta1_22_se4_81' & \\
	tex [1ex]
	
	tex TA 2 & `s_ta2_22_b1_81' & `s_ta2_22_b2_81' & `s_ta2_22_b3_81' & `s_ta2_22_b4_81' & \\
	tex & `s_ta2_22_se1_81' & `s_ta2_22_se2_81' & `s_ta2_22_se3_81' & `s_ta2_22_se4_81' &\\
	tex [1ex]
	
	tex TA 3 & `s_ta3_22_b1_81' & `s_ta3_22_b2_81' & `s_ta3_22_b3_81' & `s_ta3_22_b4_81' & \\
	tex & `s_ta3_22_se1_81' & `s_ta3_22_se2_81' & `s_ta3_22_se3_81' & `s_ta3_22_se4_81' & \\
	tex [1ex]
	
	tex TA 4 & `s_ta4_22_b1_81' & `s_ta4_22_b2_81' & `s_ta4_22_b3_81' & `s_ta4_22_b4_81' & \\
	tex & `s_ta4_22_se1_81' & `s_ta4_22_se2_81' & `s_ta4_22_se3_81' & `s_ta4_22_se4_81' & \\
	tex [1ex]
	
	tex N & & & & & `s_ta1_22_obs_81' \\
	
	tex &&&&&& \\
	tex \hline \hline \\
	tex \end{tabular}
	tex \end{threeparttable}
	tex }
	tex \end{table}

	
texdoc close	
		











