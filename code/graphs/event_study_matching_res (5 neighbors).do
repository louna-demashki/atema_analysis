clear all
set matsize 6000
set more off 
global dir "D:\SECURE\data 2024\analysis\atema" 
global input "$dir\data" 
global output "$dir\output"

cap log close
log using "$output\Logs\event_study_matching_res_5", text replace

use "$input\interim\matching_data_res", clear 

// matching within grade and cohort
	// could only match for those in grades 6, 7, and 8 in September 2021 because
	// they had baseline scores in 2019 

	// cohort 1 (unrestricted matching) 
	bys SMAX_STUDENT_ID: egen score_2023 = max(math_s_23)
	keep if ACADEMIC_YEAR_ID_FK == 2022 & inrange(grade_21,8,10) 
	ren math_score_adj score_2022

		sort SMAX_STUDENT_ID 
		gen row_num = _n
		tempfile t0
		save `t0', replace 
		
		// 5 neighbors
		foreach g in 8 9 10{
		preserve
		keep if grade_21 == `g'		
			if `g' == 10{
			global score_vars "score_2017 score_2018 score_2019"
			}
			if `g' == 9{
			global score_vars "score_2018 score_2019"
			}
			if `g' == 8{
			global score_vars "score_2019"
			}

		teffects nnmatch (score_2022 ${score_vars}) (takeup1), ematch(grade_21) ate ///
		metric(ivar) gen(rn_neighbor_) nneighbor(5) osample(nmatch_all) vce(iid)
		keep SMAX_STUDENT_ID ACADEMIC_YEAR_ID_FK takeup1 rn_neighbor_1-rn_neighbor_5 row_num
		keep if takeup1 == 1
		gen match_group = SMAX_STUDENT_ID
		gen rn_neighbor_0 = row_num
		reshape long rn_neighbor_, i(SMAX_STUDENT_ID takeup1 row_num) ///
		j(neighbor)
		ren rn_neighbor_ rn_neighbor
		keep row_num rn_neighbor neighbor match_group
		order row_num rn_neighbor neighbor match_group
		drop row_num
		ren rn_neighbor row_num
		tempfile t1
		save `t1', replace 
		
		use `t0', clear 
		merge 1:m row_num using `t1', gen(m_match)
		keep if m_match == 3
		drop m_match
		keep SMAX_STUDENT_ID neighbor match_group takeup1 ///
		grade_21 school_21 score_*
		keep if neighbor<=5
		reshape long score_, i(SMAX_STUDENT_ID neighbor match_group) j(year) 
		ren score_ math_score_adj
		egen m_period = group(match_group year)
		save "$input\interim\matched_2022_res_`g'_5.dta", replace
		restore
		}

	use "$input\interim\matched_2022_res_8_5.dta", clear
	append using "$input\interim\matched_2022_res_9_5.dta" 
	append using "$input\interim\matched_2022_res_10_5.dta" 
	save "$input\interim\matched_2022_res_5.dta", replace 
	
	//cohort 2 (restricted matching)
	use "$input\interim\matching_data_res", clear 
	bys SMAX_STUDENT_ID: egen score_2022 = max(math_s_22)
	keep if ACADEMIC_YEAR_ID_FK == 2023 & inrange(grade_21,8,9)
	ren math_score_adj score_2023

	sort SMAX_STUDENT_ID 
		gen row_num = _n
		tempfile t2
		save `t2', replace 
		
	foreach g in 8 9 {
	preserve
	keep if grade_21 == `g'		
		if `g' == 9{
		global score_vars "score_2018 score_2019"
		}
		if `g' == 8{
		global score_vars "score_2019"
		}
		
		teffects nnmatch (score_2023 ${score_vars}) (takeup2), ematch(grade_21) ate ///
		metric(ivar) gen(rn_neighbor_) nneighbor(5) osample(nmatch_all) vce(iid)
		keep SMAX_STUDENT_ID ACADEMIC_YEAR_ID_FK takeup2 rn_neighbor_1-rn_neighbor_5 row_num
		keep if takeup2 == 1
		gen match_group = SMAX_STUDENT_ID
		gen rn_neighbor_0 = row_num
		reshape long rn_neighbor_, i(SMAX_STUDENT_ID takeup2 row_num) ///
		j(neighbor)
		ren rn_neighbor_ rn_neighbor
		keep row_num rn_neighbor neighbor match_group
		order row_num rn_neighbor neighbor match_group
		drop row_num
		ren rn_neighbor row_num
		tempfile t3
		save `t3', replace 
		
		use `t2', clear 
		merge 1:m row_num using `t3', gen(m_match)
		keep if m_match == 3
		drop m_match
		keep SMAX_STUDENT_ID neighbor match_group takeup2 ///
		grade_21 school_21 score_*
		keep if neighbor<=5
		reshape long score_, i(SMAX_STUDENT_ID neighbor match_group) j(year) 
		ren score_ math_score_adj
		egen m_period = group(match_group year)
		save "$input\interim\matched_2023_res_`g'_5.dta", replace
		restore
		}
		
	use "$input\interim\matched_2023_res_8_5.dta", clear
	append using "$input\interim\matched_2023_res_9_5.dta"    
	save "$input\interim\matched_2023_res_5.dta", replace 
		
	use "$input\interim\matched_2022_res_5.dta", clear
	append using "$input\interim\matched_2023_res_5.dta"
	save "$input\interim\matched_res_5.dta", replace 
	
		// interaction terms 
		foreach year in 17 18 19 22 23{
			gen ay_`year' = 0
				replace ay_`year' = 1 if year == 20`year'
		}
		
		foreach year in 17 18 19 22 23{
			gen ay_`year'_1 = ay_`year' * takeup1
			gen ay_`year'_2 = ay_`year' * takeup2
			}
		
	save "$input\interim\matched_res_5.dta", replace


//----------------------------------------------------------------------------//
// DiD by 2021 grade (excluing students who skipped or repeated a year)
//----------------------------------------------------------------------------//

// Grade 6 (2021) (baseline 2019)
use "$input\interim\matched_res_5.dta", clear

reghdfe math_score_adj ay_17_1 ay_18_1 o.ay_19_1 ay_22_1 ay_23_1 if grade_21 == 8, ///
absorb(m_period SMAX_STUDENT_ID) vce(clustervar school_21) noconstant

// saving estimates for the plot
matrix list = e(b) 
matrix list = e(V)

matrix b_1 = e(b) 
matrix V1 = vecdiag(e(V))
matrix list V1
matrix list b_1

matrix se1 = J(1, colsof(V1), .)
forvalues i = 1/`=colsof(V1)' {
    matrix se1[1, `i'] = sqrt(V1[1, `i'])
}
matrix list se1

matrix b1 = J(5, 1, .)
matrix ci_lower1 = J(5, 1, .)
matrix ci_upper1 = J(5, 1, .)


// Take-up year 1 
forvalues i = 1/5 {
	matrix b1[`i', 1] = b_1[1, `i'] 
    matrix ci_lower1[`i', 1] = b_1[1, `i'] - 1.96 * se1[1, `i']
    matrix ci_upper1[`i', 1] = b_1[1, `i'] + 1.96 * se1[1, `i']
}

// Checking matrices
matrix list b1 
matrix list se1
matrix list ci_lower1
matrix list ci_upper1


reghdfe math_score_adj ay_17_2 ay_18_2 o.ay_19_2 ay_22_2 ay_23_2 if grade_21 == 8, ///
absorb(m_period SMAX_STUDENT_ID) vce(clustervar school_21) noconstant

// saving estimates for the plot
matrix list = e(b) 
matrix list = e(V)

matrix b_2 = e(b) 
matrix V2 = vecdiag(e(V))
matrix list V2
matrix list b_2

matrix se2 = J(1, colsof(V2), .)
forvalues i = 1/`=colsof(V2)' {
    matrix se2[1, `i'] = sqrt(V2[1, `i'])
}
matrix list se2

matrix b2 = J(5, 1, .)
matrix ci_lower2 = J(5, 1, .)
matrix ci_upper2 = J(5, 1, .)


// Take-up year 2 
forvalues i = 1/5 {
	matrix b2[`i', 1] = b_2[1, `i'] 
    matrix ci_lower2[`i', 1] = b_2[1, `i'] - 1.96 * se2[1, `i']
    matrix ci_upper2[`i', 1] = b_2[1, `i'] + 1.96 * se2[1, `i']
}

// Checking matrices
matrix list b2
matrix list se2
matrix list ci_lower2
matrix list ci_upper2

preserve
clear 
set obs 5
gen year = 2017 + _n - 1

replace year = 2022 if year == 2020
replace year = 2023 if year == 2021


// Take-up in year 1 
gen b1 = .
gen ci_lower1 = .
gen ci_upper1 = .

forvalues i = 1/5 {
    replace b1 = b1[`i', 1] in `i'
    replace ci_lower1 = ci_lower1[`i', 1] in `i'
    replace ci_upper1 = ci_upper1[`i', 1] in `i'
}

// Take-up in year 2 
gen b2 = .
gen ci_lower2 = .
gen ci_upper2 = .

forvalues i = 1/5 {
    replace b2 = b2[`i', 1] in `i'
    replace ci_lower2 = ci_lower2[`i', 1] in `i'
    replace ci_upper2 = ci_upper2[`i', 1] in `i'
}	

	
sort year 

gen year_b1 = year - 0.1
gen year_b2 = year + 0.1

gen year_ci1 = year - 0.1
gen year_ci2 = year + 0.1


twoway ///
       (rcap ci_lower1 ci_upper1 year_ci1, lcolor(blue)) ///
       (scatter b1 year_b1, msymbol(circle) mcolor(blue)) ///
       (rcap ci_lower2 ci_upper2 year_ci2, lcolor(red)) ///
       (scatter b2 year_b2, msymbol(circle) mcolor(red)), ///
       legend(label(1 "95% CI for Take-up in Year 1") label(2 "Coef for Take-up in Year 1") ///
              label(3 "95% CI for Take-up in Year 2") label(4 "Coef for Take-up in Year 2") size(small)) ///
       ytitle("Coefficient and 95% CI") xtitle("Year") ///
       title("Restricted (Grade 6)") graphregion(color(white)) ///
       xline(2022, lpattern(dash) lcolor(blue)) ///
       xline(2023, lpattern(dash) lcolor(red)) ///  
	   xlabel(2017(1)2023)
	   
restore 
	   
graph save Graph "$output\graphs\event_study_res_match_5 (grade 6).gph", replace



// Grade 7 in September 2021

reghdfe math_score_adj ay_17_1 ay_18_1 o.ay_19_1 ay_22_1 ay_23_1 if grade_21 == 9, ///
absorb(m_period SMAX_STUDENT_ID) vce(clustervar school_21) noconstant

// saving estimates for the plot
matrix list = e(b) 
matrix list = e(V)

matrix b_1 = e(b) 
matrix V1 = vecdiag(e(V))
matrix list V1
matrix list b_1

matrix se1 = J(1, colsof(V1), .)
forvalues i = 1/`=colsof(V1)' {
    matrix se1[1, `i'] = sqrt(V1[1, `i'])
}
matrix list se1

matrix b1 = J(5, 1, .)
matrix ci_lower1 = J(5, 1, .)
matrix ci_upper1 = J(5, 1, .)


// Take-up year 1 
forvalues i = 1/5 {
	matrix b1[`i', 1] = b_1[1, `i'] 
    matrix ci_lower1[`i', 1] = b_1[1, `i'] - 1.96 * se1[1, `i']
    matrix ci_upper1[`i', 1] = b_1[1, `i'] + 1.96 * se1[1, `i']
}

// Checking matrices
matrix list b1 
matrix list se1
matrix list ci_lower1
matrix list ci_upper1


reghdfe math_score_adj ay_17_2 ay_18_2 o.ay_19_2 ay_22_2 ay_23_2 if grade_21 == 9, ///
absorb(m_period SMAX_STUDENT_ID) vce(clustervar school_21) noconstant

// saving estimates for the plot
matrix list = e(b) 
matrix list = e(V)

matrix b_2 = e(b) 
matrix V2 = vecdiag(e(V))
matrix list V2
matrix list b_2

matrix se2 = J(1, colsof(V2), .)
forvalues i = 1/`=colsof(V2)' {
    matrix se2[1, `i'] = sqrt(V2[1, `i'])
}
matrix list se2

matrix b2 = J(5, 1, .)
matrix ci_lower2 = J(5, 1, .)
matrix ci_upper2 = J(5, 1, .)


// Take-up year 2 
forvalues i = 1/5 {
	matrix b2[`i', 1] = b_2[1, `i'] 
    matrix ci_lower2[`i', 1] = b_2[1, `i'] - 1.96 * se2[1, `i']
    matrix ci_upper2[`i', 1] = b_2[1, `i'] + 1.96 * se2[1, `i']
}

// Checking matrices
matrix list b2
matrix list se2
matrix list ci_lower2
matrix list ci_upper2

preserve
clear 
set obs 5
gen year = 2017 + _n - 1

replace year = 2022 if year == 2020
replace year = 2023 if year == 2021


// Take-up in year 1 
gen b1 = .
gen ci_lower1 = .
gen ci_upper1 = .

forvalues i = 1/5 {
    replace b1 = b1[`i', 1] in `i'
    replace ci_lower1 = ci_lower1[`i', 1] in `i'
    replace ci_upper1 = ci_upper1[`i', 1] in `i'
}

// Take-up in year 2 
gen b2 = .
gen ci_lower2 = .
gen ci_upper2 = .

forvalues i = 1/5 {
    replace b2 = b2[`i', 1] in `i'
    replace ci_lower2 = ci_lower2[`i', 1] in `i'
    replace ci_upper2 = ci_upper2[`i', 1] in `i'
}	

	
sort year 

gen year_b1 = year - 0.1
gen year_b2 = year + 0.1

gen year_ci1 = year - 0.1
gen year_ci2 = year + 0.1


twoway ///
       (rcap ci_lower1 ci_upper1 year_ci1, lcolor(blue)) ///
       (scatter b1 year_b1, msymbol(circle) mcolor(blue)) ///
       (rcap ci_lower2 ci_upper2 year_ci2, lcolor(red)) ///
       (scatter b2 year_b2, msymbol(circle) mcolor(red)), ///
       legend(label(1 "95% CI for Take-up in Year 1") label(2 "Coef for Take-up in Year 1") ///
              label(3 "95% CI for Take-up in Year 2") label(4 "Coef for Take-up in Year 2") size(small)) ///
       ytitle("Coefficient and 95% CI") xtitle("Year") ///
       title("Restricted (Grade 7)") graphregion(color(white)) ///
       xline(2022, lpattern(dash) lcolor(blue)) ///
       xline(2023, lpattern(dash) lcolor(red)) ///  
	   xlabel(2017(1)2023)
	   
restore 
	   
graph save Graph "$output\graphs\event_study_res_match_5 (grade 7).gph", replace



// Grade 8 (2021) 
reghdfe math_score_adj ay_17_1 ay_18_1 o.ay_19_1 ay_22_1 ay_23_1 if grade_21 == 10, ///
absorb(m_period SMAX_STUDENT_ID) vce(clustervar school_21) noconstant

// saving estimates for the plot
matrix list = e(b) 
matrix list = e(V)

matrix b_1 = e(b) 
matrix V1 = vecdiag(e(V))
matrix list V1
matrix list b_1

matrix se1 = J(1, colsof(V1), .)
forvalues i = 1/`=colsof(V1)' {
    matrix se1[1, `i'] = sqrt(V1[1, `i'])
}
matrix list se1

matrix b1 = J(5, 1, .)
matrix ci_lower1 = J(5, 1, .)
matrix ci_upper1 = J(5, 1, .)


// Take-up year 1 
forvalues i = 1/5 {
	matrix b1[`i', 1] = b_1[1, `i'] 
    matrix ci_lower1[`i', 1] = b_1[1, `i'] - 1.96 * se1[1, `i']
    matrix ci_upper1[`i', 1] = b_1[1, `i'] + 1.96 * se1[1, `i']
}

// Checking matrices
matrix list b1 
matrix list se1
matrix list ci_lower1
matrix list ci_upper1


preserve
clear 
set obs 5
gen year = 2017 + _n - 1

replace year = 2022 if year == 2020
replace year = 2023 if year == 2021


// Take-up in year 1 
gen b1 = .
gen ci_lower1 = .
gen ci_upper1 = .

forvalues i = 1/5 {
    replace b1 = b1[`i', 1] in `i'
    replace ci_lower1 = ci_lower1[`i', 1] in `i'
    replace ci_upper1 = ci_upper1[`i', 1] in `i'
}

	
sort year 

gen year_b1 = year - 0.1

gen year_ci1 = year - 0.1


twoway ///
       (rcap ci_lower1 ci_upper1 year_ci1, lcolor(blue)) ///
       (scatter b1 year_b1, msymbol(circle) mcolor(blue)), ///
       legend(label(1 "95% CI for Take-up in Year 1") label(2 "Coef for Take-up in Year 1") size(small)) ///
       ytitle("Coefficient and 95% CI") xtitle("Year") ///
       title("Restricted (Grade 8)") graphregion(color(white)) ///
       xline(2022, lpattern(dash) lcolor(blue)) ///
       xline(2023, lpattern(dash) lcolor(red)) ///  
	   xlabel(2017(1)2023)
	   
restore 
	   
graph save Graph "$output\graphs\event_study_res_match_5 (grade 8).gph", replace





// POOLED (grades 6 to 8)

reghdfe math_score_adj ay_17_1 ay_18_1 o.ay_19_1 ay_22_1 ay_23_1 if inrange(grade_21,8,10), ///
absorb(m_period SMAX_STUDENT_ID) vce(clustervar school_21) noconstant

// saving estimates for the plot
matrix list = e(b) 
matrix list = e(V)

matrix b_1 = e(b) 
matrix V1 = vecdiag(e(V))
matrix list V1
matrix list b_1

matrix se1 = J(1, colsof(V1), .)
forvalues i = 1/`=colsof(V1)' {
    matrix se1[1, `i'] = sqrt(V1[1, `i'])
}
matrix list se1

matrix b1 = J(5, 1, .)
matrix ci_lower1 = J(5, 1, .)
matrix ci_upper1 = J(5, 1, .)


// Take-up year 1 
forvalues i = 1/5 {
	matrix b1[`i', 1] = b_1[1, `i'] 
    matrix ci_lower1[`i', 1] = b_1[1, `i'] - 1.96 * se1[1, `i']
    matrix ci_upper1[`i', 1] = b_1[1, `i'] + 1.96 * se1[1, `i']
}

// Checking matrices
matrix list b1 
matrix list se1
matrix list ci_lower1
matrix list ci_upper1


reghdfe math_score_adj ay_17_2 ay_18_2 o.ay_19_2 ay_22_2 ay_23_2 if inrange(grade_21,8,10), ///
absorb(m_period SMAX_STUDENT_ID) vce(clustervar school_21) noconstant

// saving estimates for the plot
matrix list = e(b) 
matrix list = e(V)

matrix b_2 = e(b) 
matrix V2 = vecdiag(e(V))
matrix list V2
matrix list b_2

matrix se2 = J(1, colsof(V2), .)
forvalues i = 1/`=colsof(V2)' {
    matrix se2[1, `i'] = sqrt(V2[1, `i'])
}
matrix list se2

matrix b2 = J(5, 1, .)
matrix ci_lower2 = J(5, 1, .)
matrix ci_upper2 = J(5, 1, .)


// Take-up year 2 
forvalues i = 1/5 {
	matrix b2[`i', 1] = b_2[1, `i'] 
    matrix ci_lower2[`i', 1] = b_2[1, `i'] - 1.96 * se2[1, `i']
    matrix ci_upper2[`i', 1] = b_2[1, `i'] + 1.96 * se2[1, `i']
}

// Checking matrices
matrix list b2
matrix list se2
matrix list ci_lower2
matrix list ci_upper2

preserve
clear 
set obs 5
gen year = 2017 + _n - 1

replace year = 2022 if year == 2020
replace year = 2023 if year == 2021


// Take-up in year 1 
gen b1 = .
gen ci_lower1 = .
gen ci_upper1 = .

forvalues i = 1/5 {
    replace b1 = b1[`i', 1] in `i'
    replace ci_lower1 = ci_lower1[`i', 1] in `i'
    replace ci_upper1 = ci_upper1[`i', 1] in `i'
}

// Take-up in year 2 
gen b2 = .
gen ci_lower2 = .
gen ci_upper2 = .

forvalues i = 1/5 {
    replace b2 = b2[`i', 1] in `i'
    replace ci_lower2 = ci_lower2[`i', 1] in `i'
    replace ci_upper2 = ci_upper2[`i', 1] in `i'
}	

	
sort year 

gen year_b1 = year - 0.1
gen year_b2 = year + 0.1

gen year_ci1 = year - 0.1
gen year_ci2 = year + 0.1


twoway ///
       (rcap ci_lower1 ci_upper1 year_ci1, lcolor(blue)) ///
       (scatter b1 year_b1, msymbol(circle) mcolor(blue)) ///
       (rcap ci_lower2 ci_upper2 year_ci2, lcolor(red)) ///
       (scatter b2 year_b2, msymbol(circle) mcolor(red)), ///
       legend(label(1 "95% CI for Take-up in Year 1") label(2 "Coef for Take-up in Year 1") ///
              label(3 "95% CI for Take-up in Year 2") label(4 "Coef for Take-up in Year 2") size(small)) ///
       ytitle("Coefficient and 95% CI") xtitle("Year") ///
       title("Restricted (Grades 6-8)") graphregion(color(white)) ///
       xline(2022, lpattern(dash) lcolor(blue)) ///
       xline(2023, lpattern(dash) lcolor(red)) ///  
	   xlabel(2017(1)2023)
	   
restore 
	   
graph save Graph "$output\graphs\event_study_res_match_5 (all).gph", replace












