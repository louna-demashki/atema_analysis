* ==============================================================================
* 00_khan_usage.do  --  Khan Academy usage per student-year, rebuilt
* Ported from  clean_ka_22_23.do lines 13-308 (= Layer 3 script 05)
* Reads   $IN_KHAN_2022, $IN_KHAN_RAW, $IN_KHAN_L3 (comparison only)
* Writes  $ATEMA_DATA/khan_per_student_rebuilt.dta
* ==============================================================================
version 15.1
* >>> [NEW] setup block: lets the script run on its own (same block in every script)
if "$ATEMA_SETUP" != "1" & "$DATA_SOURCE" == "old" {
	* >>> [NEW] old-data mode: set DATA_SOURCE and ATEMA_CODE_DIR as in run_atema.do first
	do "$ATEMA_CODE_DIR/00_setup.do"
}
if "$ATEMA_SETUP" != "1" {
	local _r ""
	cap confirm file "D:/SECURE/data 2024/2026 Paper/config.do"
	if !_rc local _r "D:/SECURE/data 2024/2026 Paper"
	if "`_r'" == "" local _r : environment PRDE_ROOT
	if "`_r'" == "" {
		local _h : environment HOME
		if "`_h'" == "" local _h : environment USERPROFILE
		foreach _d in "Documents/2026_server" "Documents/GitHub/2026_server" "Projects/2026_server" "code/2026_server" "2026_server" {
			cap confirm file "`_h'/`_d'/config.do"
			if !_rc & "`_r'" == "" local _r "`_h'/`_d'"
		}
	}
	do "`_r'/01. Code/06. Layer 4/ATEMA/00_setup.do" "`_r'"
}
* >>> [NEW] log (old: commented out)
atema_log 00_khan_usage

* >>> [CLEAN] one cleaning routine for both files (old: the same 120 lines twice)
cap program drop _khan_weeks
program define _khan_weeks
	* >>> [CLEAN] finds the week date whether it is numeric or a string of digits
	* >>>         (old code swapped the names week / week_of by hand)
	cap confirm numeric variable week_of
	if !_rc {
		gen double wkdate = week_of
	}
	else {
		cap confirm numeric variable week
		if !_rc gen double wkdate = week
		else    gen double wkdate = real(week_of)
	}
	replace wkdate = dofc(wkdate) if wkdate > 100000 & !missing(wkdate)
	format wkdate %td
	quietly count if missing(wkdate)
	if r(N) > 0 di as text "  share of rows without a week date (dropped): " %6.4f r(N)/_N
	drop if missing(wkdate)

	* >>> [FIX] blank ids were dropped only from the 2022-23 file before
	drop if missing(SMAX_STUDENT_ID)
	local m "math_learning_minutes total_minutes math_skills_leveled_up_net math_skills_leveled_up_to_famili math_skills_practiced"
	foreach v of local m {
		replace `v' = 0 if missing(`v')
	}
	duplicates drop
	duplicates drop SMAX_STUDENT_ID wkdate `m', force
	* same rule as old: keep the record with most minutes in a student-week...
	gen double _tm = round(total_minutes, .0001)
	bysort SMAX_STUDENT_ID wkdate: egen double _mx = max(_tm)
	drop if _tm < _mx
	* >>> [FIX] ...then exactly ONE record (old kept ties and summed both = double counting)
	bysort SMAX_STUDENT_ID wkdate (math_learning_minutes math_skills_leveled_up_net): keep if _n == _N
	drop _tm _mx

	* >>> [FIX] academic year from the week: Aug-Dec belong to the next end-year.
	* >>>       Old: May-Aug 2022 got NO year (lost) and all of 2023 counted as AY 2022-23.
	gen int ACADEMIC_YEAR_ID_FK = year(wkdate) + (month(wkdate) >= 7)
end

* --- AY 2021-22: cleaned file ------------------------------------------------------
use "$IN_KHAN_2022", clear
_khan_weeks
quietly count if ACADEMIC_YEAR_ID_FK != 2022
di as text "  2021-22 file: share of weeks outside AY 2021-22 (dropped): " %6.4f r(N)/_N
keep if ACADEMIC_YEAR_ID_FK == 2022
tempfile y22
save `y22'

* --- AY 2022-23: raw file ----------------------------------------------------------
use "$IN_KHAN_RAW", clear
_khan_weeks
* same holiday weeks as the old code (now named in 00_params.do)
foreach w of global KHAN_DROP_WEEKS {
	drop if wkdate == `w'
}
* >>> [FIX] only AY 2022-23 weeks from the raw file. Old: the yearly sum ran over ALL of a
* >>>       student's weeks, so 2022-23 minutes also contained 2021-22 minutes.
keep if ACADEMIC_YEAR_ID_FK == 2023

append using `y22'

* >>> [FIX] (sum) within student x year.  Old: egen sum over all weeks, then
* >>>       collapse (first), which took whatever week came first.
collapse (sum) ka_minutes = math_learning_minutes ka_total_min = total_minutes ///
               ka_skills = math_skills_leveled_up_net ka_familiar = math_skills_leveled_up_to_famili ///
               ka_practiced = math_skills_practiced ///
         (count) ka_weeks = wkdate, by(SMAX_STUDENT_ID ACADEMIC_YEAR_ID_FK)
gen byte ka_login = ka_total_min > 0
label var ka_minutes   "Math learning minutes in the year"
label var ka_total_min "All minutes logged in the year"
label var ka_skills    "Net math skills leveled up in the year"
label var ka_familiar  "Math skills leveled up to familiar in the year"
label var ka_practiced "Math skills practiced in the year"
label var ka_weeks     "Weeks with a usage record"
label var ka_login     "Logged in to Khan Academy during the year"
* >>> [NEW] guarantee one row per student-year
isid SMAX_STUDENT_ID ACADEMIC_YEAR_ID_FK
compress
label data "Layer 4 ATEMA: Khan usage per student-year, rebuilt (`c(current_date)')"
save "$ATEMA_DATA/khan_per_student_rebuilt.dta", replace

* >>> [NEW] how far is the Layer 3 file (= old code) from the rebuilt one?  Rates only,
* >>>       so the log can leave the server (README section 12).  Take this to Jeancarlo.
cap confirm file "$IN_KHAN_L3"
if !_rc {
	use "$ATEMA_DATA/khan_per_student_rebuilt.dta", clear
	merge 1:1 SMAX_STUDENT_ID ACADEMIC_YEAR_ID_FK using "$IN_KHAN_L3", ///
		keepusing(total_math_learning_minutes total_skills_leveled_up) gen(_m)
	foreach y in 2022 2023 {
		quietly count if ACADEMIC_YEAR_ID_FK == `y'
		local tot = r(N)
		if `tot' == 0 continue
		quietly count if ACADEMIC_YEAR_ID_FK == `y' & _m == 3
		local both = r(N)
		quietly count if ACADEMIC_YEAR_ID_FK == `y' & _m == 3 & abs(ka_minutes - total_math_learning_minutes) > 0.5
		local diff = r(N)
		di as result "  AY `y': share of student-years in both files " %6.4f `both'/`tot' ///
			"; of those, share whose minutes differ " %6.4f cond(`both' > 0, `diff'/`both', .)
		if `both' > 1 {
			quietly corr ka_minutes total_math_learning_minutes if ACADEMIC_YEAR_ID_FK == `y' & _m == 3
			di as result "           correlation of minutes " %6.4f r(rho)
		}
	}
	quietly count if missing(ACADEMIC_YEAR_ID_FK) & _m == 2
	di as result "  Layer 3 rows with no academic year (lost weeks): share " %6.4f r(N)/_N
}

atema_log_close
