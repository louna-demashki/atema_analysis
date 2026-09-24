//----------------------------------------------------------------------------//
// File name: 1. appendix. pairwise differences (teachers).do 
// Last updated: July 10, 2024  ||  Sara Mostafa
//----------------------------------------------------------------------------//

clear all
set matsize 6000
set more off 
global dir "D:\SECURE\data 2024\analysis\atema" 
global input "$dir\data\interim" 
global output "$dir\output"

cap log close
log using "$output\Logs\1. appendix. pairwise differences (teachers)", text replace


use "D:\SECURE\data-feb2023\analysis\atema\data\interim\teacher_khan.dta", clear 

local format "%9.3fc" 


local teacher "male dregular primary_teacher teach_cien teach_espa teach_mate"

foreach depvar of local teacher {

    reghdfe `depvar' treat_arm_1 treat_arm_2 treat_arm_3 treat_arm_4 control, absorb(grade* strata) vce(clustervar SCHOOL_CODE) keepsingleton 

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


texdoc init "$output\tables\1. appendix. pairwise differences (teachers).tex", replace force

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
	tex \multicolumn{8}{l}{\textit{Teacher Characteristics (Teacher-level)}} \\
	
	
	tex Male & `malediff1' & `malediff2' & `malediff3' & `malediff4' & `malediff5' & `malediff6' & `maleobs' \\
	tex & `malesdiff1' & `malesdiff2' & `malesdiff3' & `malesdiff4' & `malesdiff5' & `malesdiff6' & \\
	tex & [`malepval1'] & [`malepval2'] & [`malepval3'] & [`malepval4'] & [`malepval5'] & [`malepval6'] & \\
	tex[1ex] 

	tex Primary & `primary_teacherdiff1' & `primary_teacherdiff2' & `primary_teacherdiff3' & `primary_teacherdiff4' & `primary_teacherdiff5' & `primary_teacherdiff6' & `primary_teacherobs' \\
	tex & `primary_teachersdiff1' & `primary_teachersdiff2' & `primary_teachersdiff3' & `primary_teachersdiff4' & `primary_teachersdiff5' & `primary_teachersdiff6' & \\
	tex & [`primary_teacherpval1'] & [`primary_teacherpval2'] & [`primary_teacherpval3'] & [`primary_teacherpval4'] & [`primary_teacherpval5'] & [`primary_teacherpval6'] & \\
	tex[1ex]  
	
	tex Regular & `dregulardiff1' & `dregulardiff2' & `dregulardiff3' & `dregulardiff4' & `dregulardiff5' & `dregulardiff6' & `dregularobs' \\
	tex & `dregularsdiff1' & `dregularsdiff2' & `dregularsdiff3' & `dregularsdiff4' & `dregularsdiff5' & `dregularsdiff6' & \\
	tex & [`dregularpval1'] & [`dregularpval2'] & [`dregularpval3'] & [`dregularpval4'] & [`dregularpval5'] & [`dregularpval6'] & \\
	tex[1ex] 
	
	tex Science & `teach_ciendiff1' & `teach_ciendiff2' & `teach_ciendiff3' & `teach_ciendiff4' & `teach_ciendiff5' & `teach_ciendiff6' & `teach_cienobs' \\
	tex & `teach_ciensdiff1' & `teach_ciensdiff2' & `teach_ciensdiff3' & `teach_ciensdiff4' & `teach_ciensdiff5' & `teach_ciensdiff6' & \\
	tex & [`teach_cienpval1'] & [`teach_cienpval2'] & [`teach_cienpval3'] & [`teach_cienpval4'] & [`teach_cienpval5'] & [`teach_cienpval6'] \\
	tex[1ex] 
	
	tex Spanish & `teach_espadiff1' & `teach_espadiff2' & `teach_espadiff3' & `teach_espadiff4' & `teach_espadiff5' & `teach_espadiff6' & `teach_espaobs' \\
	tex & `teach_espasdiff1' & `teach_espasdiff2' & `teach_espasdiff3' & `teach_espasdiff4' & `teach_espasdiff5' & `teach_espasdiff6' & \\
	tex & [`teach_espapval1'] & [`teach_espapval2'] & [`teach_espapval3'] & [`teach_espapval4'] & [`teach_espapval5'] & [`teach_espapval6'] & \\
	tex[1ex] 
	
	tex Math & `teach_matediff1' & `teach_matediff2' & `teach_matediff3' & `teach_matediff4' & `teach_matediff5' & `teach_matediff6' & `teach_mateobs' \\
	tex & `teach_matesdiff1' & `teach_matesdiff2' & `teach_matesdiff3' & `teach_matesdiff4' & `teach_matesdiff5' & `teach_matesdiff6' & \\
	tex & [`teach_matepval1'] & [`teach_matepval2'] & [`teach_matepval3'] & [`teach_matepval4'] & [`teach_matepval5'] & [`teach_matepval6'] & \\
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










