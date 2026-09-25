* ==============================================================================
* A3_treatment_changes.do  --  where students / teachers were after baseline
* Ported from  treatment_changes.do and treatment_changes - math.do
* ==============================================================================
version 15.1
* >>> [NEW] setup block
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
atema_log A3_treatment_changes

local cats "tr_same_sch tr_same_arm tr_to_control tr_to_treated tr_outside tr_notfound"
local cl `" "Same school" "Other school, same arm" "To control" "To other treated arm" "Outside experiment" "Not found" "'
local armlab `" "Control" "Arm 1" "Arm 2" "Arm 3" "Arm 4" "'

* >>> [CLEAN] all / math-score samples, by arm and by grade, in loops
* >>>         (old: ~2,900 lines across two files)
* >>> [FIX] one control definition for both samples (old math version added treat_info==0)
foreach smp in all math {
	use "$ATEMA_DATA/transfers_students.dta", clear
	if "`smp'" == "math" keep if !missing(math_score)
	foreach yr in 2022 2023 {
		atema_res_open A3_changes_students_`yr'_`smp'
		forvalues a = 0/4 {
			local lab : word `=`a'+1' of `armlab'
			local col 0
			foreach c of local cats {
				local ++col
				atema_post_mean `c' if ACADEMIC_YEAR_ID_FK == `yr' & base_arm == `a', row(`=`a'+1') col(`col') label("`lab'")
			}
		}
		atema_res_close
		atema_tex using "$ATEMA_OUT/tables/A3_changes_students_`yr'_`smp'.tex", ///
			title("Where baseline students were at the end of AY `=`yr'-1'-`=`yr'-2000' (sample: `smp')") ///
			collabels(`cl') notes("Shares of students by baseline arm; standard deviations in brackets.")

		atema_res_open A3_changes_students_`yr'_`smp'_grade
		quietly levelsof grade_21, local(gs)
		local r 0
		foreach g of local gs {
			local ++r
			local col 0
			foreach c of local cats {
				local ++col
				atema_post_mean `c' if ACADEMIC_YEAR_ID_FK == `yr' & grade_21 == `g' & base_arm > 0, ///
					row(`r') col(`col') label("Grade `=`g'-2' in 2021-22, treated arms")
			}
		}
		atema_res_close
		atema_tex using "$ATEMA_OUT/tables/A3_changes_students_`yr'_`smp'_grade.tex", ///
			title("Where treated-arm students were at the end of AY `=`yr'-1'-`=`yr'-2000', by baseline grade (sample: `smp')") ///
			collabels(`cl') notes("Shares of students of arms 1-4; standard deviations in brackets.")
	}
}

cap confirm file "$ATEMA_DATA/transfers_teachers.dta"
if !_rc {
	use "$ATEMA_DATA/transfers_teachers.dta", clear
	local tcats "tr_same_sch tr_same_arm tr_to_control tr_to_treated tr_outside"
	foreach yr in 2022 2023 {
		atema_res_open A3_changes_teachers_`yr'
		forvalues a = 0/4 {
			local lab : word `=`a'+1' of `armlab'
			local col 0
			foreach c of local tcats {
				local ++col
				atema_post_mean `c' if ACADEMIC_YEAR_ID_FK == `yr' & base_arm == `a', row(`=`a'+1') col(`col') label("`lab'")
			}
		}
		atema_res_close
		atema_tex using "$ATEMA_OUT/tables/A3_changes_teachers_`yr'.tex", ///
			title("Where baseline math teachers taught in AY `=`yr'-1'-`=`yr'-2000'") ///
			collabels(`" "Same school" "Other school, same arm" "To control" "To other treated arm" "Outside experiment" "') ///
			notes("Shares of teachers by baseline arm; a teacher's school is the school of most of their math students that year.")
	}
}

atema_log_close
