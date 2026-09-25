* ==============================================================================
* 00_paths.do  --  every file the ATEMA chain reads or writes, in ONE place
* ==============================================================================
* >>> [FIX] the old scripts read "the same" file from six folders
* >>>       (01. build\output, data, data\interim, prepare\build\output,
* >>>       prepare\temp, data-feb2023), so two tables could use two different
* >>>       samples.  Each input now has exactly one path.

* --- where are we? -------------------------------------------------------------
* >>> [NEW] server = the D:\SECURE tree exists
cap confirm file "D:/SECURE/data 2024/prepare/build/output/atema_treatment.dta"
local _old = (_rc == 0)
cap confirm file "D:/SECURE/data 2024/2026 Paper/config.do"
global ATEMA_ENV = cond(_rc == 0 | `_old', "server", "local")

* --- old outputs, server only, read-only (99_compare_old.do) ------------------------
global OLD_ATEMA          "D:/SECURE/data 2024/analysis/atema"
global OLD_MASTER         "$OLD_ATEMA/data/master_khan_student_combined.dta"

if "$DATA_SOURCE" == "old" {
	* ---------------------------------------------------------------------------------
	* >>> [NEW] OLD DATA: the exact files the old server scripts read (read-only).
	* >>>       Use this to check that the code runs before Layers 3-4 are ready.
	* ---------------------------------------------------------------------------------
	local D "D:/SECURE/data 2024"
	* old clean_ka_22_23.do line 390
	global IN_ATEMA_TREATMENT "`D'/prepare/build/output/atema_treatment.dta"
	* old clean_ka_22_23.do line 312, clean_ka_17_23.do line 19
	global IN_END_ENROLLMENT  "`D'/prepare/build/output/student_end_enrollment.dta"
	* old clean_ka_22_23.do line 308 wrote it here; clean_ka_17_23.do read it here
	global IN_KHAN_L3         "`D'/analysis/atema/01. build/output/khan_per_student_combined.dta"
	* old clean_ka_22_23.do lines 10 and 13
	global IN_KHAN_2022       "`D'/analysis/atema/01. build/input/khan_data_clean.dta"
	* old clean_ka_22_23.do line 134
	global IN_KHAN_RAW        "`D'/prepare/input/RAW/FILE_KHAN_ACADEMY_PR_DATA.dta"
	* old treatment_changes.do: arms by school (treat1, treat2, treat_info; no atema_arm,
	* 04_transfers.do builds it)
	global IN_SCHOOL_ARMS     "`D'/prepare/build/input/treatment_control_atema.dta"
	* the old teacher link (prepare\temp\class_teacher_student_end) no longer exists:
	* teacher transfers stay off in this mode
	global IN_L2B_LINK        ""

	* outputs: a NEW folder, never inside prepare\ or analysis\atema\ (README section 12)
	global ATEMA_DATA "$OLD_OUT_ROOT/data"
	global ATEMA_OUT  "$OLD_OUT_ROOT"
	cap mkdir "$OLD_OUT_ROOT"
}
else {
	* --- inputs (2026 Paper tree, from config.do; read-only) -------------------------
	global IN_ATEMA_TREATMENT "$L3/atema_treatment.dta"
	global IN_KHAN_L3         "$L3/khan_per_student_combined.dta"
	global IN_SCHOOL_ARMS     "$L3/school_arms.dta"
	* >>> [DECIDE] verify this sub-folder name in your clone
	global IN_END_ENROLLMENT  "$L2A/Students/student_end_enrollment.dta"
	* >>> [FIX] replaces prepare\temp\class_teacher_student_end, which no longer exists
	global IN_L2B_LINK        "$L2B/teacher_student_link_wide_2019_2023.dta"
	global IN_KHAN_2022       "$experiments/khan_data_clean.dta"
	global IN_KHAN_RAW        "$root/02. Data/03. Intermediate/01. Layer 0/Students/FILE_KHAN_ACADEMY_PR_DATA.dta"

	* --- outputs (README: Layer 4 never writes into 03. Intermediate or analysis\atema)
	global ATEMA_DATA "$analysis/ATEMA"
	global ATEMA_OUT  "$root/04. Output/ATEMA"
}

foreach d in "$ATEMA_DATA" "$ATEMA_OUT" "$ATEMA_OUT/tables" "$ATEMA_OUT/figures" ///
             "$ATEMA_OUT/results" "$ATEMA_CODE/01. Logs" {
	cap mkdir "`d'"
}
