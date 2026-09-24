//----------------------------------------------------------------------------//
// File: 1.appendix. pairwise differences.do 
// Uses: master_khan_student_combined.dta
// Last update: Nov 7, 2024 by Sara Mostafa
//----------------------------------------------------------------------------//

clear all
set matsize 6000
set more off 
global dir "D:\SECURE\data 2024\analysis\atema" 
global input "$dir\data\" 
global output "$dir\output"

cap log close
log using "$output\Logs\pairwaise differences", text replace

use "$input\interim\atema_treatment", clear

merge 1:m SMAX_STUDENT_ID using "$input\master_khan_student_combined.dta", gen(baseline) ///
keepusing(b_math_19 b_math_21 b_eng_21 b_spa_21)

bys SMAX_STUDENT_ID: gen student=_n
keep if student==1
drop if (treat_arm_1==. & treat_arm_2==. & treat_arm_3==. & treat_arm_4==. & control==.)
drop math_21 eng_21 spa_21
ren (b_math_21 b_math_19 b_eng_21 b_spa_21) (math_21 math_19 eng_21 spa_21)
drop if (treat_arm_1==. & treat_arm_2==. & treat_arm_3==. & treat_arm_4==. & control==.)

foreach i in 1 2 3 4{
	replace treat_arm_`i'=0 if treat_arm_`i'==.
	replace teach_treat`i'=0 if teach_treat`i'==.
	}
	replace control=0 if control==.
	replace teach_control=0 if teach_control==.

bysort SCHOOL_CODE: gen school=_n
bys SMAX_STAFF_IDMATH: gen teacher=_n

//adding a dummy for school that took the WMS 
gen wms=0 
	replace wms=1 if management!=. & people!=. & targets!=. & monitoring!=. & operations!=.
	 

local format "%9.3fc" 

local student "gender sa_age special_ed math_21 eng_21 spa_21 poverty math_19 GPA GPA_mate"
	
// balance test estimates -- student level 

foreach depvar of local student {

    reghdfe `depvar' treat_arm_1 treat_arm_2 treat_arm_3 treat_arm_4, absorb(GRADE_ID_FK strata) vce(clustervar SCHOOL_CODE)  

	// TA1 - TA2
    local diff1: display `format' _b[treat_arm_1] - _b[treat_arm_2]
	local sdiff1: display `format' sqrt(_se[treat_arm_1]^2 + _se[treat_arm_2]^2)
	scalar t_stat1 = (_b[treat_arm_1] - _b[treat_arm_2])/ (sqrt(_se[treat_arm_1]^2 + _se[treat_arm_2]^2))
	scalar df1 = e(df_r)
	scalar pval_1 = 2 * ttail(df1, abs(t_stat1))
	if pval_1 < 0.01 local `depvar'diff1 = strtrim("`diff1'") + "\sym{***}"
	else if pval_1 < 0.05 local `depvar'diff1 = strtrim("`diff1'") + "\sym{**}"
	else if pval_1 < 0.1 local `depvar'diff1 = strtrim("`diff1'") + "\sym{*}"
    else local `depvar'diff1 = strtrim("`diff1'")
    local `depvar'sdiff1 = "(" + strtrim("`sdiff1'") + ")"
	test treat_arm_1 = treat_arm_2 
	local `depvar'pval1: display `format' r(p)

	
	// TA1 - TA3 
    local diff2: display `format' _b[treat_arm_1] - _b[treat_arm_3]
	local sdiff2: display `format' sqrt(_se[treat_arm_1]^2 + _se[treat_arm_3]^2)
	scalar t_stat2 = (_b[treat_arm_1] - _b[treat_arm_3])/ (sqrt(_se[treat_arm_1]^2 + _se[treat_arm_3]^2))
	scalar df2 = e(df_r)
	scalar pval_2 = 2 * ttail(df2, abs(t_stat2))
	if pval_2 < 0.01 local `depvar'diff2 = strtrim("`diff2'") + "\sym{***}"
	else if pval_2 < 0.05 local `depvar'diff2 = strtrim("`diff2'") + "\sym{**}"
	else if pval_2 < 0.1 local `depvar'diff2 = strtrim("`diff2'") + "\sym{*}"
    else local `depvar'diff2 = strtrim("`diff2'")
    local `depvar'sdiff2 = "(" + strtrim("`sdiff2'") + ")"
	test treat_arm_1 = treat_arm_3
	local `depvar'pval2: display `format' r(p)
	
	
	// TA1 - TA4 
    local diff3: display `format' _b[treat_arm_1] - _b[treat_arm_4]
	local sdiff3: display `format' sqrt(_se[treat_arm_1]^2 + _se[treat_arm_4]^2)
	scalar t_stat3 = (_b[treat_arm_1] - _b[treat_arm_4])/ (sqrt(_se[treat_arm_1]^2 + _se[treat_arm_4]^2))
	scalar df3 = e(df_r)
	scalar pval_3 = 2 * ttail(df3, abs(t_stat3))
	if pval_3 < 0.01 local `depvar'diff3 = strtrim("`diff3'") + "\sym{***}"
	else if pval_3 < 0.05 local `depvar'diff3 = strtrim("`diff3'") + "\sym{**}"
	else if pval_3 < 0.1 local `depvar'diff3 = strtrim("`diff3'") + "\sym{*}"
    else local `depvar'diff3 = strtrim("`diff3'")
    local `depvar'sdiff3 = "(" + strtrim("`sdiff3'") + ")"
	test treat_arm_1 = treat_arm_4 
	local `depvar'pval3: display `format' r(p)
	
	
	// TA2 - TA3 
    local diff4: display `format' _b[treat_arm_2] - _b[treat_arm_3]
	local sdiff4: display `format' sqrt(_se[treat_arm_2]^2 + _se[treat_arm_3]^2)
	scalar t_stat4 = (_b[treat_arm_2] - _b[treat_arm_3])/ (sqrt(_se[treat_arm_2]^2 + _se[treat_arm_3]^2))
	scalar df4 = e(df_r)
	scalar pval_4 = 2 * ttail(df4, abs(t_stat4))
	if pval_4 < 0.01 local `depvar'diff4 = strtrim("`diff4'") + "\sym{***}"
	else if pval_4 < 0.05 local `depvar'diff4 = strtrim("`diff4'") + "\sym{**}"
	else if pval_4 < 0.1 local `depvar'diff4 = strtrim("`diff4'") + "\sym{*}"
    else local `depvar'diff4 = strtrim("`diff4'")
    local `depvar'sdiff4 = "(" + strtrim("`sdiff4'") + ")"
	test treat_arm_2 = treat_arm_3
	local `depvar'pval4: display `format' r(p)
	
	
	// TA2 - TA4
    local diff5: display `format' _b[treat_arm_2] - _b[treat_arm_4]
	local sdiff5: display `format' sqrt(_se[treat_arm_2]^2 + _se[treat_arm_4]^2)
	scalar t_stat5 = (_b[treat_arm_2] - _b[treat_arm_4])/ (sqrt(_se[treat_arm_2]^2 + _se[treat_arm_4]^2))
	scalar df5 = e(df_r)
	scalar pval_5 = 2 * ttail(df5, abs(t_stat5))
	if pval_5 < 0.01 local `depvar'diff5 = strtrim("`diff5'") + "\sym{***}"
	else if pval_5 < 0.05 local `depvar'diff5 = strtrim("`diff5'") + "\sym{**}"
	else if pval_5 < 0.1 local `depvar'diff5 = strtrim("`diff5'") + "\sym{*}"
    else local `depvar'diff5 = strtrim("`diff5'")
    local `depvar'sdiff5 = "(" + strtrim("`sdiff5'") + ")"
	test treat_arm_2 = treat_arm_4
	local `depvar'pval5: display `format' r(p)
	
	
	// TA3 - TA4
    local diff6: display `format' _b[treat_arm_3] - _b[treat_arm_4]
	local sdiff6: display `format' sqrt(_se[treat_arm_3]^2 + _se[treat_arm_4]^2)
	scalar t_stat6 = (_b[treat_arm_3] - _b[treat_arm_4])/ (sqrt(_se[treat_arm_3]^2 + _se[treat_arm_4]^2))
	scalar df6 = e(df_r)
	scalar pval_6 = 2 * ttail(df6, abs(t_stat6))
	if pval_6 < 0.01 local `depvar'diff6 = strtrim("`diff6'") + "\sym{***}"
	else if pval_6 < 0.05 local `depvar'diff6 = strtrim("`diff6'") + "\sym{**}"
	else if pval_6 < 0.1 local `depvar'diff6 = strtrim("`diff6'") + "\sym{*}"
    else local `depvar'diff6 = strtrim("`diff6'")
    local `depvar'sdiff6 = "(" + strtrim("`sdiff6'") + ")"
	test treat_arm_3 = treat_arm_4
	local `depvar'pval6: display `format' r(p)
	
	
	// observations 
	local `depvar'obs: display %9.0fc e(N)			

}



//----------------------------- SCHOOL-LEVEL DATA -----------------------------//

rename Español_38avg esp_38avg 
rename Matemáticas_38avg ma_38avg 
rename Inglés_38avg ing_38avg
rename GR11EspañolPromedio GR11espanol
rename GR11MatemáticasPromedio GR11math 
rename GR11InglésPromedio GR11ing

local school "total_enrollment town_rural pupil_teacher_ratio class_size esp_38avg ma_38avg ing_38avg wms"


// balance test estimates -- student level 

foreach depvar of local school {

    reghdfe `depvar' treat_arm_1 treat_arm_2 treat_arm_3 treat_arm_4  ///
	if school == 1, absorb(GRADE_ID_FK strata) vce(clustervar SCHOOL_CODE)  

	// TA1 - TA2
    local diff1: display `format' _b[treat_arm_1] - _b[treat_arm_2]
	local sdiff1: display `format' sqrt(_se[treat_arm_1]^2 + _se[treat_arm_2]^2)
	scalar t_stat1 = (_b[treat_arm_1] - _b[treat_arm_2])/ (sqrt(_se[treat_arm_1]^2 + _se[treat_arm_2]^2))
	scalar df1 = e(df_r)
	scalar pval_1 = 2 * ttail(df1, abs(t_stat1))
	if pval_1 < 0.01 local `depvar'diff1 = strtrim("`diff1'") + "\sym{***}"
	else if pval_1 < 0.05 local `depvar'diff1 = strtrim("`diff1'") + "\sym{**}"
	else if pval_1 < 0.1 local `depvar'diff1 = strtrim("`diff1'") + "\sym{*}"
    else local `depvar'diff1 = strtrim("`diff1'")
    local `depvar'sdiff1 = "(" + strtrim("`sdiff1'") + ")"
	test treat_arm_1 = treat_arm_2 
	local `depvar'pval1: display `format' r(p)

	
	// TA1 - TA3 
    local diff2: display `format' _b[treat_arm_1] - _b[treat_arm_3]
	local sdiff2: display `format' sqrt(_se[treat_arm_1]^2 + _se[treat_arm_3]^2)
	scalar t_stat2 = (_b[treat_arm_1] - _b[treat_arm_3])/ (sqrt(_se[treat_arm_1]^2 + _se[treat_arm_3]^2))
	scalar df2 = e(df_r)
	scalar pval_2 = 2 * ttail(df2, abs(t_stat2))
	if pval_2 < 0.01 local `depvar'diff2 = strtrim("`diff2'") + "\sym{***}"
	else if pval_2 < 0.05 local `depvar'diff2 = strtrim("`diff2'") + "\sym{**}"
	else if pval_2 < 0.1 local `depvar'diff2 = strtrim("`diff2'") + "\sym{*}"
    else local `depvar'diff2 = strtrim("`diff2'")
    local `depvar'sdiff2 = "(" + strtrim("`sdiff2'") + ")"
	test treat_arm_1 = treat_arm_3
	local `depvar'pval2: display `format' r(p)
	
	
	// TA1 - TA4 
    local diff3: display `format' _b[treat_arm_1] - _b[treat_arm_4]
	local sdiff3: display `format' sqrt(_se[treat_arm_1]^2 + _se[treat_arm_4]^2)
	scalar t_stat3 = (_b[treat_arm_1] - _b[treat_arm_4])/ (sqrt(_se[treat_arm_1]^2 + _se[treat_arm_4]^2))
	scalar df3 = e(df_r)
	scalar pval_3 = 2 * ttail(df3, abs(t_stat3))
	if pval_3 < 0.01 local `depvar'diff3 = strtrim("`diff3'") + "\sym{***}"
	else if pval_3 < 0.05 local `depvar'diff3 = strtrim("`diff3'") + "\sym{**}"
	else if pval_3 < 0.1 local `depvar'diff3 = strtrim("`diff3'") + "\sym{*}"
    else local `depvar'diff3 = strtrim("`diff3'")
    local `depvar'sdiff3 = "(" + strtrim("`sdiff3'") + ")"
	test treat_arm_1 = treat_arm_4 
	local `depvar'pval3: display `format' r(p)
	
	
	// TA2 - TA3 
    local diff4: display `format' _b[treat_arm_2] - _b[treat_arm_3]
	local sdiff4: display `format' sqrt(_se[treat_arm_2]^2 + _se[treat_arm_3]^2)
	scalar t_stat4 = (_b[treat_arm_2] - _b[treat_arm_3])/ (sqrt(_se[treat_arm_2]^2 + _se[treat_arm_3]^2))
	scalar df4 = e(df_r)
	scalar pval_4 = 2 * ttail(df4, abs(t_stat4))
	if pval_4 < 0.01 local `depvar'diff4 = strtrim("`diff4'") + "\sym{***}"
	else if pval_4 < 0.05 local `depvar'diff4 = strtrim("`diff4'") + "\sym{**}"
	else if pval_4 < 0.1 local `depvar'diff4 = strtrim("`diff4'") + "\sym{*}"
    else local `depvar'diff4 = strtrim("`diff4'")
    local `depvar'sdiff4 = "(" + strtrim("`sdiff4'") + ")"
	test treat_arm_2 = treat_arm_3
	local `depvar'pval4: display `format' r(p)
	
	
	// TA2 - TA4
    local diff5: display `format' _b[treat_arm_2] - _b[treat_arm_4]
	local sdiff5: display `format' sqrt(_se[treat_arm_2]^2 + _se[treat_arm_4]^2)
	scalar t_stat5 = (_b[treat_arm_2] - _b[treat_arm_4])/ (sqrt(_se[treat_arm_2]^2 + _se[treat_arm_4]^2))
	scalar df5 = e(df_r)
	scalar pval_5 = 2 * ttail(df5, abs(t_stat5))
	if pval_5 < 0.01 local `depvar'diff5 = strtrim("`diff5'") + "\sym{***}"
	else if pval_5 < 0.05 local `depvar'diff5 = strtrim("`diff5'") + "\sym{**}"
	else if pval_5 < 0.1 local `depvar'diff5 = strtrim("`diff5'") + "\sym{*}"
    else local `depvar'diff5 = strtrim("`diff5'")
    local `depvar'sdiff5 = "(" + strtrim("`sdiff5'") + ")"
	test treat_arm_2 = treat_arm_4
	local `depvar'pval5: display `format' r(p)
	
	
	// TA3 - TA4
    local diff6: display `format' _b[treat_arm_3] - _b[treat_arm_4]
	local sdiff6: display `format' sqrt(_se[treat_arm_3]^2 + _se[treat_arm_4]^2)
	scalar t_stat6 = (_b[treat_arm_3] - _b[treat_arm_4])/ (sqrt(_se[treat_arm_3]^2 + _se[treat_arm_4]^2))
	scalar df6 = e(df_r)
	scalar pval_6 = 2 * ttail(df6, abs(t_stat6))
	if pval_6 < 0.01 local `depvar'diff6 = strtrim("`diff6'") + "\sym{***}"
	else if pval_6 < 0.05 local `depvar'diff6 = strtrim("`diff6'") + "\sym{**}"
	else if pval_6 < 0.1 local `depvar'diff6 = strtrim("`diff6'") + "\sym{*}"
    else local `depvar'diff6 = strtrim("`diff6'")
    local `depvar'sdiff6 = "(" + strtrim("`sdiff6'") + ")"
	test treat_arm_3 = treat_arm_4
	local `depvar'pval6: display `format' r(p)
	
	
	// observations 
	local `depvar'obs: display %9.0fc e(N)			

}


// balance test estimates -- teacher level 
local teacher "female_teach permanent ps_teach ms_teach teach_exp02 teach_exp36 teach_exp7 math_teach eng_teach spa_teach"

foreach depvar of local teacher {

    reghdfe `depvar' teach_treat1 teach_treat2 teach_treat3 teach_treat4 if teacher==1, absorb(GRADE_ID_FK strata) vce(clustervar SCHOOL_CODE)  

	// TA1 - TA2
    local diff1: display `format' _b[teach_treat1] - _b[teach_treat2]
	local sdiff1: display `format' sqrt(_se[teach_treat1]^2 + _se[teach_treat2]^2)
	scalar t_stat1 = (_b[teach_treat1] - _b[teach_treat2])/ (sqrt(_se[teach_treat1]^2 + _se[teach_treat2]^2))
	scalar df1 = e(df_r)
	scalar pval_1 = 2 * ttail(df1, abs(t_stat1))
	if pval_1 < 0.01 local `depvar'diff1 = strtrim("`diff1'") + "\sym{***}"
	else if pval_1 < 0.05 local `depvar'diff1 = strtrim("`diff1'") + "\sym{**}"
	else if pval_1 < 0.1 local `depvar'diff1 = strtrim("`diff1'") + "\sym{*}"
    else local `depvar'diff1 = strtrim("`diff1'")
    local `depvar'sdiff1 = "(" + strtrim("`sdiff1'") + ")"
	test teach_treat1 = teach_treat2 
	local `depvar'pval1: display `format' r(p)

	
	// TA1 - TA3 
    local diff2: display `format' _b[teach_treat1] - _b[teach_treat3]
	local sdiff2: display `format' sqrt(_se[teach_treat1]^2 + _se[teach_treat3]^2)
	scalar t_stat2 = (_b[teach_treat1] - _b[teach_treat3])/ (sqrt(_se[teach_treat1]^2 + _se[teach_treat3]^2))
	scalar df2 = e(df_r)
	scalar pval_2 = 2 * ttail(df2, abs(t_stat2))
	if pval_2 < 0.01 local `depvar'diff2 = strtrim("`diff2'") + "\sym{***}"
	else if pval_2 < 0.05 local `depvar'diff2 = strtrim("`diff2'") + "\sym{**}"
	else if pval_2 < 0.1 local `depvar'diff2 = strtrim("`diff2'") + "\sym{*}"
    else local `depvar'diff2 = strtrim("`diff2'")
    local `depvar'sdiff2 = "(" + strtrim("`sdiff2'") + ")"
	test teach_treat1 = teach_treat3
	local `depvar'pval2: display `format' r(p)
	
	
	// TA1 - TA4 
    local diff3: display `format' _b[teach_treat1] - _b[teach_treat4]
	local sdiff3: display `format' sqrt(_se[teach_treat1]^2 + _se[teach_treat4]^2)
	scalar t_stat3 = (_b[teach_treat1] - _b[teach_treat4])/ (sqrt(_se[teach_treat1]^2 + _se[teach_treat4]^2))
	scalar df3 = e(df_r)
	scalar pval_3 = 2 * ttail(df3, abs(t_stat3))
	if pval_3 < 0.01 local `depvar'diff3 = strtrim("`diff3'") + "\sym{***}"
	else if pval_3 < 0.05 local `depvar'diff3 = strtrim("`diff3'") + "\sym{**}"
	else if pval_3 < 0.1 local `depvar'diff3 = strtrim("`diff3'") + "\sym{*}"
    else local `depvar'diff3 = strtrim("`diff3'")
    local `depvar'sdiff3 = "(" + strtrim("`sdiff3'") + ")"
	test teach_treat1 = teach_treat4 
	local `depvar'pval3: display `format' r(p)
	
	
	// TA2 - TA3 
    local diff4: display `format' _b[teach_treat2] - _b[teach_treat3]
	local sdiff4: display `format' sqrt(_se[teach_treat2]^2 + _se[teach_treat3]^2)
	scalar t_stat4 = (_b[teach_treat2] - _b[teach_treat3])/ (sqrt(_se[teach_treat2]^2 + _se[teach_treat3]^2))
	scalar df4 = e(df_r)
	scalar pval_4 = 2 * ttail(df4, abs(t_stat4))
	if pval_4 < 0.01 local `depvar'diff4 = strtrim("`diff4'") + "\sym{***}"
	else if pval_4 < 0.05 local `depvar'diff4 = strtrim("`diff4'") + "\sym{**}"
	else if pval_4 < 0.1 local `depvar'diff4 = strtrim("`diff4'") + "\sym{*}"
    else local `depvar'diff4 = strtrim("`diff4'")
    local `depvar'sdiff4 = "(" + strtrim("`sdiff4'") + ")"
	test teach_treat2 = teach_treat3
	local `depvar'pval4: display `format' r(p)
	
	
	// TA2 - TA4
    local diff5: display `format' _b[teach_treat2] - _b[teach_treat4]
	local sdiff5: display `format' sqrt(_se[teach_treat2]^2 + _se[teach_treat4]^2)
	scalar t_stat5 = (_b[teach_treat2] - _b[teach_treat4])/ (sqrt(_se[teach_treat2]^2 + _se[teach_treat4]^2))
	scalar df5 = e(df_r)
	scalar pval_5 = 2 * ttail(df5, abs(t_stat5))
	if pval_5 < 0.01 local `depvar'diff5 = strtrim("`diff5'") + "\sym{***}"
	else if pval_5 < 0.05 local `depvar'diff5 = strtrim("`diff5'") + "\sym{**}"
	else if pval_5 < 0.1 local `depvar'diff5 = strtrim("`diff5'") + "\sym{*}"
    else local `depvar'diff5 = strtrim("`diff5'")
    local `depvar'sdiff5 = "(" + strtrim("`sdiff5'") + ")"
	test teach_treat2 = teach_treat4
	local `depvar'pval5: display `format' r(p)
	
	
	// TA3 - TA4
    local diff6: display `format' _b[teach_treat3] - _b[teach_treat4]
	local sdiff6: display `format' sqrt(_se[teach_treat3]^2 + _se[teach_treat4]^2)
	scalar t_stat6 = (_b[teach_treat3] - _b[teach_treat4])/ (sqrt(_se[teach_treat3]^2 + _se[teach_treat4]^2))
	scalar df6 = e(df_r)
	scalar pval_6 = 2 * ttail(df6, abs(t_stat6))
	if pval_6 < 0.01 local `depvar'diff6 = strtrim("`diff6'") + "\sym{***}"
	else if pval_6 < 0.05 local `depvar'diff6 = strtrim("`diff6'") + "\sym{**}"
	else if pval_6 < 0.1 local `depvar'diff6 = strtrim("`diff6'") + "\sym{*}"
    else local `depvar'diff6 = strtrim("`diff6'")
    local `depvar'sdiff6 = "(" + strtrim("`sdiff6'") + ")"
	test teach_treat3 = teach_treat4
	local `depvar'pval6: display `format' r(p)
	
	
	// observations 
	local `depvar'obs: display %9.0fc e(N)			

}



// Balance test table: 

texdoc init "$output\tables\appendix\1. appendix. pairwise differences.tex", replace force

	tex \begin{table}[htbp]
	tex \centering
	tex \resizebox{\linewidth}{!}{%
	tex \begin{threeparttable}
	tex \fontsize{9}{10}\selectfont
	tex \caption{Pairwise Differences}
	tex \begin{tabular}{l*{7}c}
	tex \hline\hline 

	tex &\multicolumn{3}{c}{Difference between TA 1 and} &\multicolumn{2}{c}{Difference between TA 2 and} &\multicolumn{1}{c}{Difference between} &\multicolumn{1}{c}{N} \\
	tex &\multicolumn{1}{c}{TA 2} &\multicolumn{1}{c}{TA 3} &\multicolumn{1}{c}{TA 4} &\multicolumn{1}{c}{TA 3} &\multicolumn{1}{c}{TA 4} &\multicolumn{1}{c}{TA 3 and TA 4} &\multicolumn{1}{c}{}\\
	tex &\multicolumn{1}{c}{(1)} &\multicolumn{1}{c}{(2)} &\multicolumn{1}{c}{(3)} &\multicolumn{1}{c}{(4)} &\multicolumn{1}{c}{(5)} &\multicolumn{1}{c}{(6)} &\multicolumn{1}{c}{(7)}\\

	tex \hline \\ 
	tex [1ex]
	tex \multicolumn{8}{l}{\textit{Panel A: Individual Characteristics}} \\
	
	
	tex Female & `genderdiff1' & `genderdiff2' & `genderdiff3' & `genderdiff4' & `genderdiff5' & `genderdiff6' & `genderobs' \\
	tex & `gendersdiff1' & `gendersdiff2' & `gendersdiff3' & `gendersdiff4' & `gendersdiff5' & `gendersdiff6' & \\
	tex[1ex] 

	tex Age & `sa_agediff1' & `sa_agediff2' & `sa_agediff3' & `sa_agediff4' & `sa_agediff5' & `sa_agediff6' & `sa_ageobs' \\
	tex & `sa_agesdiff1' & `sa_agesdiff2' & `sa_agesdiff3' & `sa_agesdiff4' & `sa_agesdiff5' & `sa_agesdiff6' & \\
	tex[1ex]  
	
	tex Special education & `special_eddiff1' & `special_eddiff2' & `special_eddiff3' & `special_eddiff4' & `special_eddiff5' & `special_eddiff6' & `special_edobs' \\
	tex & `special_edsdiff1' & `special_edsdiff2' & `special_edsdiff3' & `special_edsdiff4' & `special_edsdiff5' & `special_edsdiff6' & \\
	tex[1ex] 
	
	tex Poverty & `povertydiff1' & `povertydiff2' & `povertydiff3' & `povertydiff4' & `povertydiff5' & `povertydiff6' & `povertyobs' \\
	tex & `povertysdiff1' & `povertysdiff2' & `povertysdiff3' & `povertysdiff4' & `povertysdiff5' & `povertysdiff6' & \\
	tex[1ex] 
	
	tex Math score (2021) & `math_21diff1' & `math_21diff2' & `math_21diff3' & `math_21diff4' & `math_21diff5' & `math_21diff6' & `math_21obs' \\
	tex & `math_21sdiff1' & `math_21sdiff2' & `math_21sdiff3' & `math_21sdiff4' & `math_21sdiff5' & `math_21sdiff6' & \\
	tex[1ex] 
	
	tex English score (2021) & `eng_21diff1' & `eng_21diff2' & `eng_21diff3' & `eng_21diff4' & `eng_21diff5' & `eng_21diff6' & `eng_21obs' \\
	tex & `eng_21sdiff1' & `eng_21sdiff2' & `eng_21sdiff3' & `eng_21sdiff4' & `eng_21sdiff5' & `eng_21sdiff6' & \\
	tex[1ex] 
	
	tex Spanish score (2021) & `spa_21diff1' & `spa_21diff2' & `spa_21diff3' & `spa_21diff4' & `spa_21diff5' & `spa_21diff6' & `spa_21obs' \\
	tex & `spa_21sdiff1' & `spa_21sdiff2' & `spa_21sdiff3' & `spa_21sdiff4' & `spa_21sdiff5' & `spa_21sdiff6' & \\
	tex[1ex] 
	
	tex Math score (2019) & `math_19diff1' & `math_19diff2' & `math_19diff3' & `math_19diff4' & `math_19diff5' & `math_19diff6' & `math_19obs' \\
	tex & `math_19sdiff1' & `math_19sdiff2' & `math_19sdiff3' & `math_19sdiff4' & `math_19sdiff5' & `math_19sdiff6' & \\
	tex[1ex] 

	tex GPA (2021) & `GPAdiff1' & `GPAdiff2' & `GPAdiff3' & `GPAdiff4' & `GPAdiff5' & `GPAdiff6' & `GPAobs' \\
	tex & `GPAsdiff1' & `GPAsdiff2' & `GPAsdiff3' & `GPAsdiff4' & `GPAsdiff5' & `sdiff6' & \\
	tex[1ex] 
	
	tex Math GPA (2021) & `GPA_matediff1' & `GPA_matediff2' & `GPA_matediff3' & `GPA_matediff4' & `GPA_matediff5' & `GPA_matediff6' & `GPA_mateobs' \\
	tex & `GPA_matesdiff1' & `GPA_matesdiff2' & `GPA_matesdiff3' & `GPA_matesdiff4' & `GPA_matesdiff5' & `GPA_matesdiff6' & \\
	tex[1ex] 
	
				
	tex \hline \\
	tex [1ex]
	tex \multicolumn{8}{l}{\textit{Panel B: School Characteristics}} \\
	
	tex Total enrollment & `total_enrollmentdiff1' & `total_enrollmentdiff2' & `total_enrollmentdiff3' & `total_enrollmentdiff4' & `total_enrollmentdiff5' & `total_enrollmentdiff6' & `total_enrollmentobs' \\
	tex & `total_enrollmentsdiff1' & `total_enrollmentsdiff2' & `total_enrollmentsdiff3' & `total_enrollmentsdiff4' & `total_enrollmentsdiff5' & `total_enrollmentsdiff6' & \\
	tex[1ex] 

	tex Student-to-teacher ratio & `pupil_teacher_ratiodiff1' & `pupil_teacher_ratiodiff2' & `pupil_teacher_ratiodiff3' & `pupil_teacher_ratiodiff4' & `pupil_teacher_ratiodiff5' & `pupil_teacher_ratiodiff6' & `pupil_teacher_ratioobs' \\
	tex & `pupil_teacher_ratiosdiff1' & `pupil_teacher_ratiosdiff2' & `pupil_teacher_ratiosdiff3' & `pupil_teacher_ratiosdiff4' & `pupil_teacher_ratiosdiff5' & `pupil_teacher_ratiosdiff6' & \\
	tex[1ex] 
		
	tex Rural & `town_ruraldiff1' & `town_ruraldiff2' & `town_ruraldiff3' & `town_ruraldiff4' & `town_ruraldiff5' & `town_ruraldiff6' & `town_ruralobs' \\
	tex & `town_ruralsdiff1' & `town_ruralsdiff2' & `town_ruralsdiff3' & `town_ruralsdiff4' & `town_ruralsdiff5' & `town_ruralsdiff6' & \\
	tex[1ex] 
		
	tex Spanish average (grades 3-8) & `esp_38avgdiff1' & `esp_38avgdiff2' & `esp_38avgdiff3' & `esp_38avgdiff4' & `esp_38avgdiff5' & `esp_38avgdiff6' & `esp_38avgobs' \\
	tex & `esp_38avgsdiff1' & `esp_38avgsdiff2' & `esp_38avgsdiff3' & `esp_38avgsdiff4' & `esp_38avgsdiff5' & `esp_38avgsdiff6' & \\
	tex[1ex] 
	
	tex Math average (grades 3-8) & `ma_38avgdiff1' & `ma_38avgdiff2' & `ma_38avgdiff3' & `ma_38avgdiff4' & `ma_38avgdiff5' & `ma_38avgdiff6' & `ma_38avgobs' \\
	tex & `ma_38avgsdiff1' & `ma_38avgsdiff2' & `ma_38avgsdiff3' & `ma_38avgsdiff4' & `ma_38avgsdiff5' & `ma_38avgsdiff6' & \\
	tex[1ex] 
	
	tex English average (grades 3-8) & `ing_38avgdiff1' & `ing_38avgdiff2' & `ing_38avgdiff3' & `ing_38avgdiff4' & `ing_38avgdiff5' & `ing_38avgdiff6' & `ing_38avgobs' \\
	tex & `ing_38avgsdiff1' & `ing_38avgsdiff2' & `ing_38avgsdiff3' & `ing_38avgsdiff4' & `ing_38avgsdiff5' & `ing_38avgsdiff6' & \\
	tex[1ex] 

	tex WMS & `wmsdiff1' & `wmsdiff2' & `wmsdiff3' & `wmsdiff4' & `wmsdiff5' & `wmsdiff6' & `wmsobs' \\
	tex & `wmssdiff1' & `wmssdiff2' & `wmssdiff3' & `wmssdiff4' & `wmssdiff5' & `wmssdiff6' & \\
	tex[1ex] 
	
	tex \hline \\
	tex [1ex]
	tex \multicolumn{8}{l}{\textit{Panel C: Teacher Characteristics}} \\
	
	tex Female & `female_teachdiff1' & `female_teachdiff2' & `female_teachdiff3' & `female_teachdiff4' & `female_teachdiff5' & `female_teachdiff6' & `female_teachobs' \\
	tex & `female_teachsdiff1' & `female_teachsdiff2' & `female_teachsdiff3' & `female_teachsdiff4' & `female_teachsdiff5' & `female_teachsdiff6' & \\
	tex[1ex]  
	
	tex Primary school & `ps_teachdiff1' & `ps_teachdiff2' & `ps_teachdiff3' & `ps_teachdiff4' & `ps_teachdiff5' & `ps_teachdiff6' & `ps_teachobs' \\
	tex & `ps_teachsdiff1' & `ps_teachsdiff2' & `ps_teachsdiff3' & `ps_teachsdiff4' & `ps_teachsdiff5' & `ps_teachsdiff6' & \\
	tex[1ex] 
	
	tex Middle school & `ms_teachdiff1' & `ms_teachdiff2' & `ms_teachdiff3' & `ms_teachdiff4' & `ms_teachdiff5' & `ms_teachdiff6' & `ms_teachobs' \\
	tex & `ms_teachsdiff1' & `ms_teachsdiff2' & `ms_teachsdiff3' & `ms_teachsdiff4' & `ms_teachsdiff5' & `ms_teachsdiff6' & \\
	tex[1ex] 
	
	tex Permanent & `permanentdiff1' & `permanentdiff2' & `permanentdiff3' & `permanentdiff4' & `permanentdiff5' & `permanentdiff6' & `permanentobs' \\
	tex & `permanentsdiff1' & `permanentsdiff2' & `permanentsdiff3' & `permanentsdiff4' & `permanentsdiff5' & `permanentsdiff6' & \\
	tex[1ex] 
	
	tex 0-2 years of experience & `teach_exp02diff1' & `teach_exp02diff2' & `teach_exp02diff3' & `teach_exp02diff4' & `teach_exp02diff5' & `teach_exp02diff6' & `teach_exp02obs' \\
	tex & `teach_exp02sdiff1' & `teach_exp02sdiff2' & `teach_exp02sdiff3' & `teach_exp02sdiff4' & `teach_exp02sdiff5' & `teach_exp02sdiff6' & \\
	tex[1ex] 
	
	tex 3-6 years of experience & `teach_exp36diff1' & `teach_exp36diff2' & `teach_exp36diff3' & `teach_exp36diff4' & `teach_exp36diff6' & `teach_exp36diff6' & `teach_exp36obs' \\
	tex & `teach_exp36sdiff1' & `teach_exp36sdiff2' & `teach_exp36sdiff3' & `teach_exp36sdiff4' & `teach_exp36sdiff5' & `teach_exp36sdiff6' & \\
	tex[1ex] 
	
	tex 7+ years of experience &  `teach_exp7diff1' & `teach_exp7diff2' & `teach_exp7diff3' & `teach_exp7diff4' & `teach_exp7diff5' & `teach_exp7diff6' & `teach_exp7obs' \\
	tex &`teach_exp7sdiff1' & `teach_exp7sdiff2' & `teach_exp7sdiff3' & `teach_exp7sdiff4' & `teach_exp7sdiff5' & `teach_exp7sdiff6' & \\
	tex[1ex] 

	tex Math & `math_teachdiff1' & `math_teachdiff2' & `math_teachdiff3' & `math_teachdiff4' & `math_teachdiff5' & `math_teachdiff6' & `math_teachobs' \\
	tex & `math_teachsdiff1' & `math_teachsdiff2' & `math_teachsdiff3' & `math_teachsdiff4' & `math_teachsdiff5' & `math_teachsdiff6' & \\
	tex[1ex] 

	tex English & `eng_teachdiff1' & `eng_teachdiff2' & `eng_teachdiff3' & `eng_teachdiff4' & `eng_teachdiff5' & `eng_teachdiff6' & `eng_teachobs' \\
	tex & `eng_teachsdiff1' & `eng_teachsdiff2' & `eng_teachsdiff3' & `eng_teachsdiff4' & `eng_teachsdiff5' & `eng_teachsdiff6' & \\
	tex[1ex] 
	
	tex Spanish & `spa_teachdiff1' & `spa_teachdiff2' & `spa_teachdiff3' & `spa_teachdiff4' & `spa_teachdiff5' & `spa_teachdiff6' & `spa_teachobs' \\
	tex & `spa_teachsdiff1' & `spa_teachsdiff2' & `spa_teachsdiff3' & `spa_teachsdiff4' & `spa_teachsdiff5' & `spa_teachsdiff6' & \\
	tex[1ex] 
	
	tex \hline\hline
	tex \end{tabular}
	tex \begin{tablenotes}[para, flushleft]
	tex \scriptsize
	tex \note Standard deviations of variables are reported in brackets. Robust standard errors are clustered by school and reported in parentheses. \sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\). Differences are adjusted for stratum and grade fixed effects.
	tex \end{tablenotes}
	tex \end{threeparttable}
	tex }
	tex \end{table}	

	
texdoc close


	
	











