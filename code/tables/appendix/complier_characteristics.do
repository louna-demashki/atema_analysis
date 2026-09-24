//----------------------------------------------------------------------------//
// File: complier_characteristics.do 
// Last update: Nov 4, 2024 by Sara Mostafa
//----------------------------------------------------------------------------//

clear all
set matsize 6000
set maxvar 120000
set more off 
global dir "D:\SECURE\data 2024\analysis\atema" 
global input "$dir\data" 
global output "$dir\output"

cap log close
log using "$output\Logs\complier_characteristics", text replace

	
use "$input\master_khan_student_combined", clear 

drop if ACADEMIC_YEAR_ID_FK==.

gen control_pooled = 0 
	replace control_pooled = 1 if (control == 1 | (treat_arm_3 == 1 & ACADEMIC_YEAR_ID_FK == 2022) ///
	| (treat_arm_4 == 1 & ACADEMIC_YEAR_ID_FK == 2022))

// teacher 
gen t_control_pooled = 0 
	replace t_control_pooled = 1 if (teach_control == 1 | (teach_treat3 == 1 & ACADEMIC_YEAR_ID_FK == 2022) ///
	| (teach_treat4 == 1 & ACADEMIC_YEAR_ID_FK == 2022))
	
ren b_math_19 math_19	

global student_cov "gender sa_age special_ed poverty_21 math_21 eng_21 spa_21 math_19 GPA GPA_mate"

global student_charac " "
foreach i in $student_cov{
	gen `i'_t = `i'*takeup
		global student_charac "${student_charac} `i'_t"
	}
	

//----------------------------------------------------------------------------//
// Student Characteristics
//----------------------------------------------------------------------------//

local format "%9.3fc" 

foreach i in $student_charac{
	ivreghdfe `i' (takeup = atema_st) if (atema_st==1 | control_pooled==1), ///
	absorb(strata GRADE_ID_FK) cluster(SCHOOL_CODE)

		local b1: display `format' _b[takeup]
		else local `i'_b1 = strtrim("`b1'")
		local se1: display `format' _se[takeup]
		local `i'_se1 = "(" + strtrim("`se1'") + ")"
		local `i'obs1: display %9.0fc e(N)
		
		
	ivreghdfe `i' (takeup = atema_pe_st) if (atema_pe_st==1 | control_pooled==1), ///
	absorb(strata GRADE_ID_FK) cluster(SCHOOL_CODE)

		local b2: display `format' _b[takeup]
		else local `i'_b2 = strtrim("`b2'")
		local se2: display `format' _se[takeup]
		local `i'_se2 = "(" + strtrim("`se2'") + ")"
		local `i'obs2: display %9.0fc e(N)
		

}


//----------------------------------------------------------------------------//
// Teacher Characteristics
//----------------------------------------------------------------------------//

bys SMAX_STAFF_IDMATH: egen teacher_takeup1 = max(takeup)
bys SMAX_STAFF_IDMATH: gen total_students = _N
bys SMAX_STAFF_IDMATH: egen total_takeup=sum(takeup)
bys SMAX_STAFF_IDMATH: gen perc_takeup = (total_takeup/total_students)*100
bys SMAX_STAFF_IDMATH: gen teacher_takeup2 = (perc_takeup>=10)
bys SMAX_STAFF_IDMATH: gen teacher=_n

global teacher_cov "female_teach ps_teach ms_teach permanent teach_exp02 teach_exp36 teach_exp7"

global teacher_charac1 " "
foreach i in $teacher_cov{
	gen `i'_t1 = `i'*teacher_takeup1
		global teacher_charac1 "${teacher_charac1} `i'_t1"
	}
	
global teacher_charac2 " "
foreach i in $teacher_cov{
	gen `i'_t2 = `i'*teacher_takeup2
		global teacher_charac2 "${teacher_charac2} `i'_t2"
	}

local format "%9.3fc" 

foreach i in $teacher_charac1{
	ivreghdfe `i' (teacher_takeup1 = t_atema_st) if (t_atema_st==1 | t_control_pooled==1) & teacher==1, ///
	absorb(GRADE_ID_FK strata) cluster(SCHOOL_CODE) 

		local b1: display `format' _b[teacher_takeup1]
		else local `i'_b1 = strtrim("`b1'")
		local se1: display `format' _se[teacher_takeup1]
		local `i'_se1 = "(" + strtrim("`se1'") + ")"
		local `i'obs1: display %9.0fc e(N)
				
		
	ivreghdfe `i' (teacher_takeup1 = t_atema_pe_st) if (t_atema_pe_st==1 | t_control_pooled==1) & teacher==1, ///
	absorb(GRADE_ID_FK strata) cluster(SCHOOL_CODE)

		local b2: display `format' _b[teacher_takeup1]
		else local `i'_b2 = strtrim("`b2'")
		local se2: display `format' _se[teacher_takeup1]
		local `i'_se2 = "(" + strtrim("`se2'") + ")"
		local `i'obs2: display %9.0fc e(N)
		
}
		
foreach i in $teacher_charac2{		
	ivreghdfe `i' (teacher_takeup2 = t_atema_st) if (t_atema_st==1 | t_control_pooled==1) & teacher==1, ///
	absorb(GRADE_ID_FK strata) cluster(SCHOOL_CODE) 

		local b1: display `format' _b[teacher_takeup2]
		else local `i'_b1 = strtrim("`b1'")
		local se1: display `format' _se[teacher_takeup2]
		local `i'_se1 = "(" + strtrim("`se1'") + ")"
		local `i'obs1: display %9.0fc e(N)
				
		
	ivreghdfe `i' (teacher_takeup2 = t_atema_pe_st) if (t_atema_pe_st==1 | t_control_pooled==1) & teacher==1, ///
	absorb(GRADE_ID_FK strata) cluster(SCHOOL_CODE)

		local b2: display `format' _b[teacher_takeup2]
		else local `i'_b2 = strtrim("`b2'")
		local se2: display `format' _se[teacher_takeup2]
		local `i'_se2 = "(" + strtrim("`se2'") + ")"
		local `i'obs2: display %9.0fc e(N)
		
}



//----------------------------------------------------------------------------//
// Table
//----------------------------------------------------------------------------//

texdoc init "$output\tables\main\complier_characteristics.tex", replace force
	
	tex \begin{table}[htbp]
	tex \centering
	tex \resizebox{\linewidth}{!}{%
	tex \begin{threeparttable}
	tex \fontsize{10}{11}\selectfont
	tex \caption{\textbf{Complier Characteristics}}
	tex \begin{tabular}{l*{4}c}
	tex \hline\hline
	tex &\multicolumn{2}{c}{Treatment} &\multicolumn{2}{c}{Parental Engagement} \\
	tex \cmidrule(lr){2-3} 
	tex \cmidrule(lr){4-5}
	tex &\multicolumn{1}{c}{2SLS} &\multicolumn{1}{c}{N} &\multicolumn{1}{c}{2SLS} &\multicolumn{1}{c}{N}\\
	tex &\multicolumn{1}{c}{(1)} &\multicolumn{1}{c}{(2)} &\multicolumn{1}{c}{(3)} &\multicolumn{1}{c}{(4)}\\
	tex \hline \\
	tex[1ex]
	
	tex \multicolumn{5}{l}{\textbf{Panel A: Student Characteristics}} \\
	tex[1ex] 
	
	tex Female & `gender_t_b1' & `gender_tobs1' & `gender_t_b2' & `gender_tobs2' \\
	tex & `gender_t_se1' &  & `gender_t_se2' &  \\
	tex[1ex]  
	
	tex Age & `sa_age_t_b1' & `sa_age_tobs1' & `sa_age_t_b2' & `sa_age_tobs2' \\
	tex & `sa_age_t_se1' &  & `sa_age_t_se2' &  \\
	tex[1ex]   
	
	tex Special education (2021) & `special_ed_t_b1' & `special_ed_tobs1' & `special_ed_t_b2' & `special_ed_tobs2' \\
	tex & `special_ed_t_se1' &  & `special_ed_t_se2' &  \\
	tex[1ex]  
	
	tex Poverty (2021) & `poverty_21_t_b1' & `poverty_21_tobs1' & `poverty_21_t_b2' & `poverty_21_tobs2' \\
	tex & `poverty_21_t_se1' &  & `poverty_21_t_se2' &  \\
	tex[1ex]  
	
	tex Math score (2021) & `math_21_t_b1' & `math_21_tobs1' & `math_21_t_b2' & `math_21_tobs2' \\
	tex & `math_21_t_se1' &  & `math_21_t_se2' & \\
	tex[1ex]  
		
	tex English score (2021) & `eng_21_t_b1' & `eng_21_tobs1' & `eng_21_t_b2' & `eng_21_tobs2' \\
	tex & `eng_21_t_se1' &  & `eng_21_t_se2' &  \\
	tex[1ex]  
	
	tex Spanish score (2021) & `spa_21_t_b1' & `spa_21_tobs1' & `spa_21_t_b2' & `spa_21_tobs2' \\
	tex & `spa_21_t_se1' &  & `spa_21_t_se2' & \\
	tex[1ex]  
	
	tex Math score (2019) & `math_19_t_b1' & `math_19_tobs1' & `math_19_t_b2' & `math_19_tobs2' \\
	tex & `math_19_t_se1' &  & `math_19_t_se2' &  \\
	tex[1ex]  
	
	tex GPA (2021) & `GPA_t_b1' & `GPA_tobs1' & `GPA_t_b2' & `GPA_tobs2' \\
	tex & `GPA_t_se1' &  & `GPA_t_se2' &  \\
	tex[1ex]  
	
	tex Math GPA (2021) & `GPA_mate_t_b1' & `GPA_mate_tobs1' & `GPA_mate_t_b2' & `GPA_mate_tobs2' \\
	tex & `GPA_mate_t_se1' &  & `GPA_mate_t_se2' & \\
	tex[1ex]
	
	tex \hline \\
	tex[1ex]
	
	tex \multicolumn{5}{l}{\textbf{Panel B: Teacher Characteristics}} \\
	tex[1ex] 
	
	tex \multicolumn{5}{l}{\textit{At least one student with take-up}} \\
	tex[1ex] 
	
	tex Female & `female_teach_t1_b1' & `female_teach_t1obs1' & `female_teach_t1_b2' & `female_teach_t1obs2' \\
	tex & `female_teach_t1_se1' &  & `female_teach_t1_se2' & \\
	tex[1ex]
	
	tex Primary school & `ps_teach_t1_b1' & `ps_teach_t1obs1' & `ps_teach_t1_b2' & `ps_teach_t1obs2' \\
	tex & `ps_teach_t1_se1' &  & `ps_teach_t1_se2' & \\
	tex[1ex]
	
	tex Middle school & `ms_teach_t1_b1' & `ms_teach_t1obs1' & `ms_teach_t1_b2' & `ms_teach_t1obs2' \\
	tex & `ms_teach_t1_se1' &  & `ms_teach_t1_se2' & \\
	tex[1ex]
	
	tex Permanent & `permanent_t1_b1' & `permanent_t1obs1' & `permanent_t1_b2' & `permanent_t1obs2' \\
	tex & `permanent_t1_se1' &  & `permanent_t1_se2' & \\
	tex[1ex]
	
	tex 0-2 years of experience & `teach_exp02_t1_b1' & `teach_exp02_t1obs1' & `teach_exp02_t1_b2' & `teach_exp02_t1obs2' \\
	tex & `teach_exp02_t1_se1' &  & `teach_exp02_t1_se2' & \\
	tex[1ex]
	
	tex 3-6 years of experience & `teach_exp36_t1_b1' & `teach_exp36_t1obs1' & `teach_exp36_t1_b2' & `teach_exp36_t1obs2' \\
	tex & `teach_exp36_t1_se1' &  & `teach_exp36_t1_se2' & \\
	tex[1ex]
	
	tex 7+ years of experience & `teach_exp7_t1_b1' & `teach_exp7_t1obs1' & `teach_exp7_t1_b2' & `teach_exp7_t1obs2' \\
	tex & `teach_exp7_t1_se1' &  & `teach_exp7_t1_se2' & \\
	tex[1ex]
		
	tex English & `eng_teach_t1_b1' & `eng_teach_t1obs1' & `eng_teach_t1_b2' & `eng_teach_t1obs2' \\
	tex & `eng_teach_t1_se1' &  & `eng_teach_t1_se2' & \\
	tex[1ex]
	
	tex Spanish & `spa_teach_t1_b1' & `spa_teach_t1obs1' & `spa_teach_t1_b2' & `spa_teach_t1obs2' \\
	tex & `spa_teach_t1_se1' &  & `spa_teach_t1_se2' & \\
	tex[1ex]
	
	tex \hline \\
	tex[1ex]
	
	tex \multicolumn{5}{l}{\textit{At least 10 percent of students with take-up}} \\
	tex[1ex] 
	
	tex Female & `female_teach_t2_b1' & `female_teach_t2obs1' & `female_teach_t2_b2' & `female_teach_t2obs2' \\
	tex & `female_teach_t2_se1' &  & `female_teach_t2_se2' & \\
	tex[1ex]
	
	tex Primary school & `ps_teach_t2_b1' & `ps_teach_t2obs1' & `ps_teach_t2_b2' & `ps_teach_t2obs2' \\
	tex & `ps_teach_t2_se1' &  & `ps_teach_t2_se2' & \\
	tex[1ex]
	
	tex Middle school & `ms_teach_t2_b1' & `ms_teach_t2obs1' & `ms_teach_t2_b2' & `ms_teach_t2obs2' \\
	tex & `ms_teach_t2_se1' &  & `ms_teach_t2_se2' & \\
	tex[1ex]
	
	tex Permanent & `permanent_t2_b1' & `permanent_t2obs1' & `permanent_t2_b2' & `permanent_t2obs2' \\
	tex & `permanent_t2_se1' &  & `permanent_t2_se2' & \\
	tex[1ex]
	
	tex 0-2 years of experience & `teach_exp02_t2_b1' & `teach_exp02_t2obs1' & `teach_exp02_t2_b2' & `teach_exp02_t2obs2' \\
	tex & `teach_exp02_t2_se1' &  & `teach_exp02_t2_se2' & \\
	tex[1ex]
	
	tex 3-6 years of experience & `teach_exp36_t2_b1' & `teach_exp36_t2obs1' & `teach_exp36_t2_b2' & `teach_exp36_t2obs2' \\
	tex & `teach_exp36_t2_se1' &  & `teach_exp36_t2_se2' & \\
	tex[1ex]
	
	tex 7+ years of experience & `teach_exp7_t2_b1' & `teach_exp7_t2obs1' & `teach_exp7_t2_b2' & `teach_exp7_t2obs2' \\
	tex & `teach_exp7_t2_se1' &  & `teach_exp7_t2_se2' & \\
	tex[1ex]
	
	tex English & `eng_teach_t2_b1' & `eng_teach_t2obs1' & `eng_teach_t2_b2' & `eng_teach_t2obs2' \\
	tex & `eng_teach_t2_se1' &  & `eng_teach_t2_se2' & \\
	tex[1ex]
	
	tex Spanish & `spa_teach_t2_b1' & `spa_teach_t2obs1' & `spa_teach_t2_b2' & `spa_teach_t2obs2' \\
	tex & `spa_teach_t2_se1' &  & `spa_teach_t2_se2' & \\
	tex[1ex]
	
	tex \hline\hline
	tex \end{tabular}
	tex \singlespacing
	tex \begin{tablenotes}[flushleft] \scriptsize \item \textbf{Notes:} This table reports the means of student and teacher characteristics for compliers. Regressions include strata-year and grade fixed effects. Standard errors are clustered at the school-level and reported in parantheses. * \(p<0.10\), ** \(p<0.05\), *** \(p<0.01\). 
	tex \end{tablenotes}
	tex \end{threeparttable}
	tex }
	tex \end{table}
	
texdoc close 


















