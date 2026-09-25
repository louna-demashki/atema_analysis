* ==============================================================================
* run_atema.do  --  Layer 4 / ATEMA: THE MASTER FILE (the only file you run)
*
* Purpose   Rebuilds every dataset, table and figure of "Adopting Computer
*           Assisted Learning at Scale" (ATEMA, experiment 1) from scratch:
*             0. setup      config.do, paths, parameters, helper programs, packages
*             1. synthetic  (local clone only) fake PRDE export + experiment files
*             2. upstream   (local clone only) Layers 0, 1, 2A, 2B, 3 and TVA
*             3. build      Khan usage, analysis panel, event panel, frames, transfers
*             4. prepare    baseline controls and their selection
*             5. tables     Tables 1-7 of the paper, the TOT, the appendix tables
*             6. figures    coefficient plot, event studies, matched event studies
*             7. compare    (server only) new vs old analysis files, aggregates only
* Where     <2026_server>/01. Code/06. Layer 4/ATEMA/
*
* Flags     >>> [NEW] did not exist   >>> [CLEAN] same numbers, cleaner/reproducible
*           >>> [CRASH] old code stopped here   >>> [FIX] bug, changes numbers
*           >>> [LEGACY] LEGACY 1 restores the old behaviour   >>> [DECIDE] PI choice
* ==============================================================================

* >>> [NEW] no master file existed: scripts were run by hand, in an order nobody wrote down
version 15.1
clear all
set more off
set varabbrev off
cap log close _all

* ------------------------------------------------------------------------------
* A. Replication switch -- set BEFORE setup.
* ------------------------------------------------------------------------------
* >>> [LEGACY] 1 = reproduce the old tables (bugs that change numbers are kept,
* >>>          crash bugs are still fixed); 0 = the corrected analysis.
* >>>          README section 9: run 1 first, check the old tables come back,
* >>>          then run 0 and explain every change in writing.
global LEGACY 0

* ------------------------------------------------------------------------------
* A2. Data source -- set BEFORE setup.
* ------------------------------------------------------------------------------
* >>> [NEW] "old" = read the OLD server files in D:\SECURE\data 2024 (prepare\build\output,
* >>>           analysis\atema\01. build, prepare\input\RAW), the same files the old
* >>>           scripts read.  Use this to check that the code runs while Layers 3-4
* >>>           of the 2026 Paper tree are not ready.  Server only.
* >>>       "new" = read the 2026 Paper tree through config.do (the final setup).
global DATA_SOURCE "old"

* >>> [NEW] only used when DATA_SOURCE is "old":
* >>>   ATEMA_CODE_DIR  the folder where you saved these .do files (run_atema.do is in it)
* >>>   OLD_OUT_ROOT    where the new datasets, tables, figures and logs are written.
* >>>                   NEVER a folder inside prepare\ or analysis\atema\ (read-only, README 12)
global ATEMA_CODE_DIR "D:/SECURE/data 2024/2026 Paper/01. Code/06. Layer 4/ATEMA"
global OLD_OUT_ROOT   "D:/SECURE/data 2024/2026 Paper/04. Output/ATEMA_oldinputs"

* >>> [NEW] 1 = quick "does it run" test: DDML with 2 repetitions and 2 folds, matching
* >>>       with 1 neighbour only.  Set 0 for real estimates.
global QUICK_TEST 1

* ------------------------------------------------------------------------------
* B. Find the 2026_server root and load setup (same search order as the README)
* ------------------------------------------------------------------------------
global ATEMA_SETUP ""
if "$DATA_SOURCE" == "old" {
	* >>> [NEW] old-data mode: no config.do needed
	cap confirm file "$ATEMA_CODE_DIR/00_setup.do"
	if _rc {
		di as error "run_atema.do: 00_setup.do not found in ATEMA_CODE_DIR ($ATEMA_CODE_DIR)"
		exit 601
	}
	do "$ATEMA_CODE_DIR/00_setup.do"
}
else {
* >>> [NEW] replaces the hard-coded D:\SECURE\... paths of every old script
local _r ""
cap confirm file "D:/SECURE/data 2024/2026 Paper/config.do"
if !_rc local _r "D:/SECURE/data 2024/2026 Paper"
if "`_r'" == "" local _r : environment PRDE_ROOT
if "`_r'" == "" {
	local _h : environment HOME
	if "`_h'" == "" local _h : environment USERPROFILE
	foreach _d in "Documents/2026_server" "Documents/GitHub/2026_server" ///
	              "Projects/2026_server" "code/2026_server" "2026_server" {
		cap confirm file "`_h'/`_d'/config.do"
		if !_rc & "`_r'" == "" local _r "`_h'/`_d'"
	}
}
if "`_r'" == "" {
	di as error "run_atema.do: cannot find the 2026_server clone (set PRDE_ROOT)"
	exit 601
}
do "`_r'/01. Code/06. Layer 4/ATEMA/00_setup.do" "`_r'"
}

* ------------------------------------------------------------------------------
* C. Run switches.  On the server everything that WRITES upstream stays 0.
* ------------------------------------------------------------------------------
* >>> [NEW] switches, as in the tree's master.do
global DO_SYNTH     = ("$ATEMA_ENV" == "local")   // fake data, clone only
global DO_UPSTREAM  = ("$ATEMA_ENV" == "local")   // Layers 0-3 + TVA, clone only
* >>> [NEW] old-data mode reads existing server files: nothing to generate or rebuild
if "$DATA_SOURCE" == "old" {
	global DO_SYNTH    0
	global DO_UPSTREAM 0
}
global DO_BUILD     1
global DO_PREPARE   1
global DO_TABLES    1
global DO_FIGURES   1
global DO_COMPARE   = ("$ATEMA_ENV" == "server")  // old vs new, server only

* ------------------------------------------------------------------------------
* D. Master log
* ------------------------------------------------------------------------------
* >>> [NEW] the old scripts had their logs commented out
local stamp : display %tdCCYY-NN-DD date(c(current_date), "DMY")
local time = subinstr("`c(current_time)'", ":", "", .)
log using "$ATEMA_CODE/01. Logs/00_run_atema_`stamp'_`time'.log", text replace name(atema_master)
di as text "ATEMA pipeline | data: $DATA_SOURCE | env: $ATEMA_ENV | LEGACY: $LEGACY | quick test: $QUICK_TEST | Khan source: $KHAN_SOURCE | controls: $CONTROLS"
* >>> [NEW] records Stata and package versions, so a result can be traced to its software
about
foreach c in reghdfe ivreghdfe ivreg2 ddml rlasso winsor {
	cap noi which `c'
}
timer clear 1
timer on 1

* ------------------------------------------------------------------------------
* 1. Synthetic data (clone only).  Stata 15 has no python: block, so shell out.
* ------------------------------------------------------------------------------
* >>> [NEW] the master creates the fake data itself
if $DO_SYNTH {
	shell python3 "$root/synthetic/gen_raw_inputs.py"
	shell python3 "$root/synthetic/gen_experiments.py"
}

* ------------------------------------------------------------------------------
* 2. Upstream layers (clone only)
* ------------------------------------------------------------------------------
* >>> [NEW] rebuilds Layers 0-3 + TVA locally; never on the server
if $DO_UPSTREAM {
	shell bash "$root/tools/run_layers.sh" L0 L1 L2A L2B L3 TVA
}
* >>> [NEW] stops with a clear message if an input file is missing
atema_check_inputs

* ------------------------------------------------------------------------------
* 3-7. The ATEMA chain, in dependency order
* ------------------------------------------------------------------------------
* >>> [NEW] the order that the old files only implied (e.g. av_table needed RFE ddml first)
local B "$ATEMA_CODE/01. build"
local P "$ATEMA_CODE/02. prepare"
local T "$ATEMA_CODE/03. analysis/tables"
local F "$ATEMA_CODE/03. analysis/figures"

if $DO_BUILD {
	do "`B'/00_khan_usage.do"
	do "`B'/01_analysis_panel.do"
	do "`B'/02_event_panel.do"
	do "`B'/03_frames.do"
	do "`B'/04_transfers.do"
}
if $DO_PREPARE {
	do "`P'/01_controls.do"
}
if $DO_TABLES {
	do "`T'/T1_balance.do"
	do "`T'/T2_first_stage.do"
	do "`T'/T3_T7_rf_pds.do"
	do "`T'/T3_T7_rf_ddml.do"
	do "`T'/T4_pairwise.do"
	do "`T'/T5_T6_first_stage_detail.do"
	do "`T'/T8_tot.do"
	do "`T'/A1_attrition.do"
	do "`T'/A2_complier_chars.do"
	do "`T'/A3_treatment_changes.do"
	do "`T'/A4_spec_curve.do"
}
if $DO_FIGURES {
	do "`F'/F1_rf_coefplot.do"
	do "`F'/F2_event_study.do"
	do "`F'/F3_matching.do"
}
* >>> [NEW] server-only check that the new files reproduce the old ones
if $DO_COMPARE {
	do "$ATEMA_CODE/03. analysis/99_compare_old.do"
}

timer off 1
timer list 1
di as result "ATEMA pipeline finished."
cap log close atema_master
