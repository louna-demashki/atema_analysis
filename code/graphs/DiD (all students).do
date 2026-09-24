clear all
set matsize 6000
set more off 
global dir "D:\SECURE\data 2024\analysis\atema" 
global input "$dir\data" 
global output "$dir\output"

cap log close
log using "$output\Logs\event_study_by_grade (all students)", text replace


//----------------------------------------------------------------------------//
// DiD by 2021 grade
//----------------------------------------------------------------------------//

use "$input\master_2017_2023", clear

// Grade 3 (baseline 2022)
reghdfe math_score ay_2017_takeup1 ay_2018_takeup1 ay_2019_takeup1 o.ay_2022_takeup1 ///
ay_2023_takeup1 if grade_21 == 5, absorb(ay_grade) vce(clustervar school_21) noconstant

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


// Take-up year 1 only
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


reghdfe math_score ay_2017_takeup2 ay_2018_takeup2 ay_2019_takeup2 o.ay_2022_takeup2 ///
ay_2023_takeup2 if grade_21 == 5, absorb(ay_grade) vce(clustervar school_21) noconstant

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


// Take-up year 2 only
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


reghdfe math_score ay_2017_takeup3 ay_2018_takeup3 ay_2019_takeup3 o.ay_2022_takeup3 ///
ay_2023_takeup3 if grade_21 == 5, absorb(ay_grade) vce(clustervar school_21) noconstant

// saving estimates for the plot
matrix list = e(b) 
matrix list = e(V)

matrix b_3 = e(b) 
matrix V3 = vecdiag(e(V))
matrix list V3
matrix list b_3

matrix se3 = J(1, colsof(V3), .)
forvalues i = 1/`=colsof(V3)' {
    matrix se3[1, `i'] = sqrt(V3[1, `i'])
}
matrix list se3

matrix b3 = J(5, 1, .)
matrix ci_lower3 = J(5, 1, .)
matrix ci_upper3 = J(5, 1, .)


// Take-up years 1 & 2
forvalues i = 1/5 {
	matrix b3[`i', 1] = b_3[1, `i'] 
    matrix ci_lower3[`i', 1] = b_3[1, `i'] - 1.96 * se3[1, `i']
    matrix ci_upper3[`i', 1] = b_3[1, `i'] + 1.96 * se3[1, `i']
}

// Checking matrices
matrix list b3
matrix list se3
matrix list ci_lower3
matrix list ci_upper3


clear 
set obs 5
gen year = 2017 + _n - 1

replace year = 2022 if year == 2020
replace year = 2023 if year == 2021

// Take-up in year 1 only
gen b1 = .
gen ci_lower1 = .
gen ci_upper1 = .

forvalues i = 1/5 {
    replace b1 = b1[`i', 1] in `i'
    replace ci_lower1 = ci_lower1[`i', 1] in `i'
    replace ci_upper1 = ci_upper1[`i', 1] in `i'
}

// Take-up in year 2 only
gen b2 = .
gen ci_lower2 = .
gen ci_upper2 = .

forvalues i = 1/5 {
    replace b2 = b2[`i', 1] in `i'
    replace ci_lower2 = ci_lower2[`i', 1] in `i'
    replace ci_upper2 = ci_upper2[`i', 1] in `i'
}	
	

// Take-up in years 1 & 2
gen b3 = .
gen ci_lower3 = .
gen ci_upper3 = .

forvalues i = 1/5 {
    replace b3 = b3[`i', 1] in `i'
    replace ci_lower3 = ci_lower3[`i', 1] in `i'
    replace ci_upper3 = ci_upper3[`i', 1] in `i'
}	

	
sort year

gen year_b1 = year - 0.2
gen year_b2 = year
gen year_b3 = year + 0.2

gen year_ci1 = year - 0.2 
gen year_ci2 = year 
gen year_ci3 = year + 0.2


twoway ///
       (rcap ci_lower1 ci_upper1 year_ci1, lcolor(blue)) ///
       (scatter b1 year_b1, msymbol(circle) mcolor(blue)) ///
       (rcap ci_lower2 ci_upper2 year_ci2, lcolor(red)) ///
       (scatter b2 year_b2, msymbol(circle) mcolor(red)) ///
       (rcap ci_lower3 ci_upper3 year_ci3, lcolor(black)) ///
       (scatter b3 year_b3, msymbol(circle) mcolor(black)), ///
       legend(label(1 "95% CI for Take-up in Year 1") label(2 "Coef for Take-up in Year 1") ///
              label(3 "95% CI for Take-up in Year 2") label(4 "Coef for Take-up in Year 2") ///
              label(5 "95% CI for Take-up in Years 1 & 2") label(6 "Coef for Take-up in Years 1 & 2") size(small)) ///
       ytitle("Coefficient and 95% CI") xtitle("Year") ///
       title("All Students (Grade 3)") graphregion(color(white)) ///
       xline(2022, lpattern(dash) lcolor(blue)) ///
       xline(2023, lpattern(dash) lcolor(red))	   

graph save Graph "$output\graphs\all students\event_study (all students - grade 3).gph", replace




// Grade 4 (2021) (baseline 2022)
use "$input\master_2017_2023", clear

reghdfe math_score ay_2017_takeup1 ay_2018_takeup1 ay_2019_takeup1 o.ay_2022_takeup1 ///
ay_2023_takeup1 if grade_21 == 6, absorb(ay_grade) vce(clustervar school_21) noconstant

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


// Take-up year 1 only
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


reghdfe math_score ay_2017_takeup2 ay_2018_takeup2 ay_2019_takeup2 o.ay_2022_takeup2 ///
ay_2023_takeup2 if grade_21 == 6, absorb(ay_grade) vce(clustervar school_21) noconstant

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


// Take-up year 2 only
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


reghdfe math_score ay_2017_takeup3 ay_2018_takeup3 ay_2019_takeup3 o.ay_2022_takeup3 ///
ay_2023_takeup3 if grade_21 == 6, absorb(ay_grade) vce(clustervar school_21) noconstant

// saving estimates for the plot
matrix list = e(b) 
matrix list = e(V)

matrix b_3 = e(b) 
matrix V3 = vecdiag(e(V))
matrix list V3
matrix list b_3

matrix se3 = J(1, colsof(V3), .)
forvalues i = 1/`=colsof(V3)' {
    matrix se3[1, `i'] = sqrt(V3[1, `i'])
}
matrix list se3

matrix b3 = J(5, 1, .)
matrix ci_lower3 = J(5, 1, .)
matrix ci_upper3 = J(5, 1, .)


// Take-up years 1 & 2
forvalues i = 1/5 {
	matrix b3[`i', 1] = b_3[1, `i'] 
    matrix ci_lower3[`i', 1] = b_3[1, `i'] - 1.96 * se3[1, `i']
    matrix ci_upper3[`i', 1] = b_3[1, `i'] + 1.96 * se3[1, `i']
}

// Checking matrices
matrix list b3
matrix list se3
matrix list ci_lower3
matrix list ci_upper3


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


// Take-up in years 1 & 2
gen b3 = .
gen ci_lower3 = .
gen ci_upper3 = .

forvalues i = 1/5 {
    replace b3 = b3[`i', 1] in `i'
    replace ci_lower3 = ci_lower3[`i', 1] in `i'
    replace ci_upper3 = ci_upper3[`i', 1] in `i'
}	

	
sort year 

gen year_b1 = year - 0.2
gen year_b2 = year
gen year_b3 = year + 0.2

gen year_ci1 = year - 0.2 
gen year_ci2 = year 
gen year_ci3 = year + 0.2


twoway ///
       (rcap ci_lower1 ci_upper1 year_ci1, lcolor(blue)) ///
       (scatter b1 year_b1, msymbol(circle) mcolor(blue)) ///
       (rcap ci_lower2 ci_upper2 year_ci2, lcolor(red)) ///
       (scatter b2 year_b2, msymbol(circle) mcolor(red)) ///
       (rcap ci_lower3 ci_upper3 year_ci3, lcolor(black)) ///
       (scatter b3 year_b3, msymbol(circle) mcolor(black)), ///
       legend(label(1 "95% CI for Take-up in Year 1") label(2 "Coef for Take-up in Year 1") ///
              label(3 "95% CI for Take-up in Year 2") label(4 "Coef for Take-up in Year 2") ///
              label(5 "95% CI for Take-up in Years 1 & 2") label(6 "Coef for Take-up in Years 1 & 2") size(small)) ///
       ytitle("Coefficient and 95% CI") xtitle("Year") ///
       title("All Students (Grade 4)") graphregion(color(white)) ///
       xline(2022, lpattern(dash) lcolor(blue)) ///
       xline(2023, lpattern(dash) lcolor(red))	   

	   
graph save Graph "$output\graphs\all students\event_study (all students - grade 4).gph", replace




// Grade 5 (2021) (baseline 2022)
use "$input\master_2017_2023", clear

reghdfe math_score ay_2017_takeup1 ay_2018_takeup1 ay_2019_takeup1 o.ay_2022_takeup1 ///
ay_2023_takeup1 if grade_21 == 7, absorb(ay_grade) vce(clustervar school_21) noconstant

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


// Take-up year 1 only
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


reghdfe math_score ay_2017_takeup2 ay_2018_takeup2 ay_2019_takeup2 o.ay_2022_takeup2 ///
ay_2023_takeup2 if grade_21 == 7, absorb(ay_grade) vce(clustervar school_21) noconstant

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


// Take-up year 2 only
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


reghdfe math_score ay_2017_takeup3 ay_2018_takeup3 ay_2019_takeup3 o.ay_2022_takeup3 ///
ay_2023_takeup3 if grade_21 == 7, absorb(ay_grade) vce(clustervar school_21) noconstant

// saving estimates for the plot
matrix list = e(b) 
matrix list = e(V)

matrix b_3 = e(b) 
matrix V3 = vecdiag(e(V))
matrix list V3
matrix list b_3

matrix se3 = J(1, colsof(V3), .)
forvalues i = 1/`=colsof(V3)' {
    matrix se3[1, `i'] = sqrt(V3[1, `i'])
}
matrix list se3

matrix b3 = J(5, 1, .)
matrix ci_lower3 = J(5, 1, .)
matrix ci_upper3 = J(5, 1, .)


// Take-up years 1 & 2
forvalues i = 1/5 {
	matrix b3[`i', 1] = b_3[1, `i'] 
    matrix ci_lower3[`i', 1] = b_3[1, `i'] - 1.96 * se3[1, `i']
    matrix ci_upper3[`i', 1] = b_3[1, `i'] + 1.96 * se3[1, `i']
}

// Checking matrices
matrix list b3 
matrix list se3
matrix list ci_lower3
matrix list ci_upper3




clear 
set obs 5
gen year = 2017 + _n - 1

replace year = 2022 if year == 2020
replace year = 2023 if year == 2021


// Take-up in year 1 only
gen b1 = .
gen ci_lower1 = .
gen ci_upper1 = .

forvalues i = 1/5 {
    replace b1 = b1[`i', 1] in `i'
    replace ci_lower1 = ci_lower1[`i', 1] in `i'
    replace ci_upper1 = ci_upper1[`i', 1] in `i'
}

// Take-up in year 2 only
gen b2 = .
gen ci_lower2 = .
gen ci_upper2 = .

forvalues i = 1/5 {
    replace b2 = b2[`i', 1] in `i'
    replace ci_lower2 = ci_lower2[`i', 1] in `i'
    replace ci_upper2 = ci_upper2[`i', 1] in `i'
}	


// Take-up in years 1 & 2
gen b3 = .
gen ci_lower3 = .
gen ci_upper3 = .

forvalues i = 1/5 {
    replace b3 = b3[`i', 1] in `i'
    replace ci_lower3 = ci_lower3[`i', 1] in `i'
    replace ci_upper3 = ci_upper3[`i', 1] in `i'
}	


	
sort year 

gen year_b1 = year - 0.2
gen year_b2 = year
gen year_b3 = year + 0.2

gen year_ci1 = year - 0.2 
gen year_ci2 = year 
gen year_ci3 = year + 0.2


twoway ///
       (rcap ci_lower1 ci_upper1 year_ci1, lcolor(blue)) ///
       (scatter b1 year_b1, msymbol(circle) mcolor(blue)) ///
       (rcap ci_lower2 ci_upper2 year_ci2, lcolor(red)) ///
       (scatter b2 year_b2, msymbol(circle) mcolor(red)) ///
       (rcap ci_lower3 ci_upper3 year_ci3, lcolor(black)) ///
       (scatter b3 year_b3, msymbol(circle) mcolor(black)), ///
       legend(label(1 "95% CI for Take-up in Year 1") label(2 "Coef for Take-up in Year 1") ///
              label(3 "95% CI for Take-up in Year 2") label(4 "Coef for Take-up in Year 2") ///
              label(5 "95% CI for Take-up in Years 1 & 2") label(6 "Coef for Take-up in Years 1 & 2") size(small)) ///
       ytitle("Coefficient and 95% CI") xtitle("Year") ///
       title("All Students (Grade 5)") graphregion(color(white)) ///
       xline(2022, lpattern(dash) lcolor(blue)) ///
       xline(2023, lpattern(dash) lcolor(red))	   

	   
graph save Graph "$output\graphs\all students\event_study (all students - grade 5).gph", replace





// Grade 6 (2021) (baseline 2019)
use "$input\master_2017_2023", clear

reghdfe math_score ay_2017_takeup1 ay_2018_takeup1 o.ay_2019_takeup1 ay_2022_takeup1 ///
ay_2023_takeup1 if grade_21 == 8, absorb(ay_grade) vce(clustervar school_21) noconstant

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


// Take-up year 1 only
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


reghdfe math_score ay_2017_takeup2 ay_2018_takeup2 o.ay_2019_takeup2 ay_2022_takeup2 ///
ay_2023_takeup2 if grade_21 == 8, absorb(ay_grade) vce(clustervar school_21) noconstant

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


// Take-up year 2 only
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


reghdfe math_score ay_2017_takeup3 ay_2018_takeup3 o.ay_2019_takeup3 ay_2022_takeup3 ///
ay_2023_takeup3 if grade_21 == 8, absorb(ay_grade) vce(clustervar school_21) noconstant

// saving estimates for the plot
matrix list = e(b) 
matrix list = e(V)

matrix b_3 = e(b) 
matrix V3 = vecdiag(e(V))
matrix list V3
matrix list b_3

matrix se3 = J(1, colsof(V3), .)
forvalues i = 1/`=colsof(V3)' {
    matrix se3[1, `i'] = sqrt(V3[1, `i'])
}
matrix list se3

matrix b3 = J(5, 1, .)
matrix ci_lower3 = J(5, 1, .)
matrix ci_upper3 = J(5, 1, .)


// Take-up years 1 & 2
forvalues i = 1/5 {
	matrix b3[`i', 1] = b_3[1, `i'] 
    matrix ci_lower3[`i', 1] = b_3[1, `i'] - 1.96 * se3[1, `i']
    matrix ci_upper3[`i', 1] = b_3[1, `i'] + 1.96 * se3[1, `i']
}

// Checking matrices
matrix list b3 
matrix list se3
matrix list ci_lower3
matrix list ci_upper3


clear 
set obs 5
gen year = 2017 + _n - 1

replace year = 2022 if year == 2020
replace year = 2023 if year == 2021


// Take-up in year 1 only
gen b1 = .
gen ci_lower1 = .
gen ci_upper1 = .

forvalues i = 1/5 {
    replace b1 = b1[`i', 1] in `i'
    replace ci_lower1 = ci_lower1[`i', 1] in `i'
    replace ci_upper1 = ci_upper1[`i', 1] in `i'
}

// Take-up in year 2 only
gen b2 = .
gen ci_lower2 = .
gen ci_upper2 = .

forvalues i = 1/5 {
    replace b2 = b2[`i', 1] in `i'
    replace ci_lower2 = ci_lower2[`i', 1] in `i'
    replace ci_upper2 = ci_upper2[`i', 1] in `i'
}	

// Take-up in years 1 & 2
gen b3 = .
gen ci_lower3 = .
gen ci_upper3 = .

forvalues i = 1/5 {
    replace b3 = b3[`i', 1] in `i'
    replace ci_lower3 = ci_lower3[`i', 1] in `i'
    replace ci_upper3 = ci_upper3[`i', 1] in `i'
}	

	
sort year 

gen year_b1 = year - 0.2
gen year_b2 = year
gen year_b3 = year + 0.2

gen year_ci1 = year - 0.2 
gen year_ci2 = year 
gen year_ci3 = year + 0.2


twoway ///
       (rcap ci_lower1 ci_upper1 year_ci1, lcolor(blue)) ///
       (scatter b1 year_b1, msymbol(circle) mcolor(blue)) ///
       (rcap ci_lower2 ci_upper2 year_ci2, lcolor(red)) ///
       (scatter b2 year_b2, msymbol(circle) mcolor(red)) ///
       (rcap ci_lower3 ci_upper3 year_ci3, lcolor(black)) ///
       (scatter b3 year_b3, msymbol(circle) mcolor(black)), ///
       legend(label(1 "95% CI for Take-up in Year 1") label(2 "Coef for Take-up in Year 1") ///
              label(3 "95% CI for Take-up in Year 2") label(4 "Coef for Take-up in Year 2") ///
              label(5 "95% CI for Take-up in Years 1 & 2") label(6 "Coef for Take-up in Years 1 & 2") size(small)) ///
       ytitle("Coefficient and 95% CI") xtitle("Year") ///
       title("All Students (Grade 6)") graphregion(color(white)) ///
       xline(2022, lpattern(dash) lcolor(blue)) ///
       xline(2023, lpattern(dash) lcolor(red))	   

	   
graph save Graph "$output\graphs\all students\event_study (all students - grade 6).gph", replace




// Grade 7 (2021) (baseline 2019)
use "$input\master_2017_2023", clear


reghdfe math_score ay_2017_takeup1 ay_2018_takeup1 o.ay_2019_takeup1 ay_2022_takeup1 ///
ay_2023_takeup1 if grade_21 == 9, absorb(ay_grade) vce(clustervar school_21) noconstant

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


reghdfe math_score ay_2017_takeup2 ay_2018_takeup2 o.ay_2019_takeup2 ay_2022_takeup2 ///
ay_2023_takeup2 if grade_21 == 9, absorb(ay_grade) vce(clustervar school_21) noconstant

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


reghdfe math_score ay_2017_takeup3 ay_2018_takeup3 o.ay_2019_takeup3 ay_2022_takeup3 ///
ay_2023_takeup3 if grade_21 == 9, absorb(ay_grade) vce(clustervar school_21) noconstant

// saving estimates for the plot
matrix list = e(b) 
matrix list = e(V)

matrix b_3 = e(b) 
matrix V3 = vecdiag(e(V))
matrix list V3
matrix list b_3

matrix se3 = J(3, colsof(V3), .)
forvalues i = 1/`=colsof(V3)' {
    matrix se3[1, `i'] = sqrt(V3[1, `i'])
}
matrix list se3

matrix b3 = J(5, 1, .)
matrix ci_lower3 = J(5, 1, .)
matrix ci_upper3 = J(5, 1, .)


// Take-up years 1 & 2
forvalues i = 1/5 {
	matrix b3[`i', 1] = b_3[1, `i'] 
    matrix ci_lower3[`i', 1] = b_3[1, `i'] - 1.96 * se3[1, `i']
    matrix ci_upper3[`i', 1] = b_3[1, `i'] + 1.96 * se3[1, `i']
}

// Checking matrices
matrix list b3 
matrix list se3
matrix list ci_lower3
matrix list ci_upper3




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

// Take-up in years 1 & 2
gen b3 = .
gen ci_lower3 = .
gen ci_upper3 = .

forvalues i = 1/5 {
    replace b3 = b3[`i', 1] in `i'
    replace ci_lower3 = ci_lower3[`i', 1] in `i'
    replace ci_upper3 = ci_upper3[`i', 1] in `i'
}	

	
sort year 

gen year_b1 = year - 0.2
gen year_b2 = year
gen year_b3 = year + 0.2

gen year_ci1 = year - 0.2 
gen year_ci2 = year 
gen year_ci3 = year + 0.2


twoway ///
       (rcap ci_lower1 ci_upper1 year_ci1, lcolor(blue)) ///
       (scatter b1 year_b1, msymbol(circle) mcolor(blue)) ///
       (rcap ci_lower2 ci_upper2 year_ci2, lcolor(red)) ///
       (scatter b2 year_b2, msymbol(circle) mcolor(red)) ///
       (rcap ci_lower3 ci_upper3 year_ci3, lcolor(black)) ///
       (scatter b3 year_b3, msymbol(circle) mcolor(black)), ///
       legend(label(1 "95% CI for Take-up in Year 1") label(2 "Coef for Take-up in Year 1") ///
              label(3 "95% CI for Take-up in Year 2") label(4 "Coef for Take-up in Year 2") ///
              label(5 "95% CI for Take-up in Years 1 & 2") label(6 "Coef for Take-up in Years 1 & 2") size(small)) ///
       ytitle("Coefficient and 95% CI") xtitle("Year") ///
       title("All Students (Grade 7)") graphregion(color(white)) ///
       xline(2022, lpattern(dash) lcolor(blue)) ///
       xline(2023, lpattern(dash) lcolor(red))	   

	   
graph save Graph "$output\graphs\all students\event_study (all students - grade 7).gph", replace


// Grade 8 (2021) 
use "$input\master_2017_2023", clear	
	
reghdfe math_score ay_2017_takeup1 ay_2018_takeup1 o.ay_2019_takeup1 ay_2022_takeup1 ///
ay_2023_takeup1 if grade_21 == 10, absorb(ay_grade) vce(clustervar school_21) noconstant

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


// Take-up year 1 only
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


reghdfe math_score ay_2017_takeup2 ay_2018_takeup2 o.ay_2019_takeup2 ay_2022_takeup2 ///
ay_2023_takeup2 if grade_21 == 10, absorb(ay_grade) vce(clustervar school_21) noconstant

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


// Take-up year 2 only
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


reghdfe math_score ay_2017_takeup3 ay_2018_takeup3 o.ay_2019_takeup3 ay_2022_takeup3 ///
ay_2023_takeup3 if grade_21 == 10, absorb(ay_grade) vce(clustervar school_21) noconstant

// saving estimates for the plot
matrix list = e(b) 
matrix list = e(V)

matrix b_3 = e(b) 
matrix V3 = vecdiag(e(V))
matrix list V3
matrix list b_3

matrix se3 = J(1, colsof(V3), .)
forvalues i = 1/`=colsof(V3)' {
    matrix se3[1, `i'] = sqrt(V3[1, `i'])
}
matrix list se3

matrix b3 = J(5, 1, .)
matrix ci_lower3 = J(5, 1, .)
matrix ci_upper3 = J(5, 1, .)


// Take-up year 1 only
forvalues i = 1/5 {
	matrix b3[`i', 1] = b_3[1, `i'] 
    matrix ci_lower3[`i', 1] = b_3[1, `i'] - 1.96 * se3[1, `i']
    matrix ci_upper3[`i', 1] = b_3[1, `i'] + 1.96 * se3[1, `i']
}

// Checking matrices
matrix list b3 
matrix list se3
matrix list ci_lower3
matrix list ci_upper3


clear 
set obs 5
gen year = 2017 + _n - 1

replace year = 2022 if year == 2020


// Take-up in year 1 only
gen b1 = .
gen ci_lower1 = .
gen ci_upper1 = .

forvalues i = 1/5 {
    replace b1 = b1[`i', 1] in `i'
    replace ci_lower1 = ci_lower1[`i', 1] in `i'
    replace ci_upper1 = ci_upper1[`i', 1] in `i'
}

// Take-up in year 2 only
gen b2 = .
gen ci_lower2 = .
gen ci_upper2 = .

forvalues i = 1/5 {
    replace b2 = b2[`i', 1] in `i'
    replace ci_lower2 = ci_lower2[`i', 1] in `i'
    replace ci_upper2 = ci_upper2[`i', 1] in `i'
}	

// Take-up in years 1 & 2
gen b3 = .
gen ci_lower3 = .
gen ci_upper3 = .

forvalues i = 1/5 {
    replace b3 = b3[`i', 1] in `i'
    replace ci_lower3 = ci_lower3[`i', 1] in `i'
    replace ci_upper3 = ci_upper3[`i', 1] in `i'
}	

	
sort year 

gen year_b1 = year - 0.2
gen year_b2 = year
gen year_b3 = year + 0.2

gen year_ci1 = year - 0.2 
gen year_ci2 = year 
gen year_ci3 = year + 0.2


twoway ///
       (rcap ci_lower1 ci_upper1 year_ci1, lcolor(blue)) ///
       (scatter b1 year_b1, msymbol(circle) mcolor(blue)) ///
       (rcap ci_lower2 ci_upper2 year_ci2, lcolor(red)) ///
       (scatter b2 year_b2, msymbol(circle) mcolor(red)) ///
       (rcap ci_lower3 ci_upper3 year_ci3, lcolor(black)) ///
       (scatter b3 year_b3, msymbol(circle) mcolor(black)), ///
       legend(label(1 "95% CI for Take-up in Year 1") label(2 "Coef for Take-up in Year 1") ///
              label(3 "95% CI for Take-up in Year 2") label(4 "Coef for Take-up in Year 2") ///
              label(5 "95% CI for Take-up in Years 1 & 2") label(6 "Coef for Take-up in Years 1 & 2") size(small)) ///
       ytitle("Coefficient and 95% CI") xtitle("Year") ///
       title("All Students (Grade 8)") graphregion(color(white)) ///
       xline(2022, lpattern(dash) lcolor(blue)) ///
       xline(2023, lpattern(dash) lcolor(red))	   

	   
graph save Graph "$output\graphs\all students\event_study (all students - grade 8).gph", replace





// POOLED 

use "$input\master_2017_2023", clear

reghdfe math_score ay_2017_takeup1 ay_2018_takeup1 o.ay_2019_takeup1 ay_2022_takeup1 ///
ay_2023_takeup1, absorb(ay_grade) vce(clustervar school_21) noconstant

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


// Take-up year 1 only
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


reghdfe math_score ay_2017_takeup2 ay_2018_takeup2 o.ay_2019_takeup2 ay_2022_takeup2 ///
ay_2023_takeup2, absorb(ay_grade) vce(clustervar school_21) noconstant

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


// Take-up year 2 only
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


reghdfe math_score ay_2017_takeup3 ay_2018_takeup3 o.ay_2019_takeup3 ay_2022_takeup3 ///
ay_2023_takeup3, absorb(ay_grade) vce(clustervar school_21) noconstant

// saving estimates for the plot
matrix list = e(b) 
matrix list = e(V)

matrix b_3 = e(b) 
matrix V3 = vecdiag(e(V))
matrix list V3
matrix list b_3

matrix se3 = J(1, colsof(V3), .)
forvalues i = 1/`=colsof(V3)' {
    matrix se3[1, `i'] = sqrt(V3[1, `i'])
}
matrix list se3

matrix b3 = J(5, 1, .)
matrix ci_lower3 = J(5, 1, .)
matrix ci_upper3 = J(5, 1, .)


// Take-up years 1 & 2
forvalues i = 1/5 {
	matrix b3[`i', 1] = b_3[1, `i'] 
    matrix ci_lower3[`i', 1] = b_3[1, `i'] - 1.96 * se3[1, `i']
    matrix ci_upper3[`i', 1] = b_3[1, `i'] + 1.96 * se3[1, `i']
}

// Checking matrices
matrix list b1 
matrix list se1
matrix list ci_lower1
matrix list ci_upper1



clear 
set obs 5
gen year = 2017 + _n - 1

replace year = 2022 if year == 2020
replace year = 2023 if year == 2021


// Take-up in year 1 only
gen b1 = .
gen ci_lower1 = .
gen ci_upper1 = .

forvalues i = 1/5 {
    replace b1 = b1[`i', 1] in `i'
    replace ci_lower1 = ci_lower1[`i', 1] in `i'
    replace ci_upper1 = ci_upper1[`i', 1] in `i'
}

// Take-up in year 2 only
gen b2 = .
gen ci_lower2 = .
gen ci_upper2 = .

forvalues i = 1/5 {
    replace b2 = b2[`i', 1] in `i'
    replace ci_lower2 = ci_lower2[`i', 1] in `i'
    replace ci_upper2 = ci_upper2[`i', 1] in `i'
}	


// Take-up in years 1 & 2
gen b3 = .
gen ci_lower3 = .
gen ci_upper3 = .

forvalues i = 1/5 {
    replace b3 = b3[`i', 1] in `i'
    replace ci_lower3 = ci_lower3[`i', 1] in `i'
    replace ci_upper3 = ci_upper3[`i', 1] in `i'
}	


	
sort year 

gen year_b1 = year - 0.2
gen year_b2 = year
gen year_b3 = year + 0.2

gen year_ci1 = year - 0.2 
gen year_ci2 = year 
gen year_ci3 = year + 0.2


twoway ///
       (rcap ci_lower1 ci_upper1 year_ci1, lcolor(blue)) ///
       (scatter b1 year_b1, msymbol(circle) mcolor(blue)) ///
       (rcap ci_lower2 ci_upper2 year_ci2, lcolor(red)) ///
       (scatter b2 year_b2, msymbol(circle) mcolor(red)) ///
       (rcap ci_lower3 ci_upper3 year_ci3, lcolor(black)) ///
       (scatter b3 year_b3, msymbol(circle) mcolor(black)), ///
       legend(label(1 "95% CI for Take-up in Year 1") label(2 "Coef for Take-up in Year 1") ///
              label(3 "95% CI for Take-up in Year 2") label(4 "Coef for Take-up in Year 2") ///
              label(5 "95% CI for Take-up in Years 1 & 2") label(6 "Coef for Take-up in Years 1 & 2") size(small)) ///
       ytitle("Coefficient and 95% CI") xtitle("Year") ///
       title("All Students") graphregion(color(white)) ///
       xline(2022, lpattern(dash) lcolor(blue)) ///
       xline(2023, lpattern(dash) lcolor(red))	   

	   
graph save Graph "$output\graphs\all students\event_study (all students).gph", replace



















