* ==============================================================================
* 00_setup.do  --  loads everything a Layer 4 / ATEMA script needs
* Called by run_atema.do and, when run on their own, by every script.
* ==============================================================================
* >>> [NEW] whole file
version 15.1
args root_arg

* >>> [NEW] DATA_SOURCE "old": read the old D:\SECURE\data 2024 files, no config.do needed
if "$DATA_SOURCE" == "" global DATA_SOURCE "new"

if "$DATA_SOURCE" == "old" {
	if "$ATEMA_CODE_DIR" == "" {
		di as error "00_setup.do: DATA_SOURCE is old but ATEMA_CODE_DIR is not set (see run_atema.do)"
		exit 198
	}
	global ATEMA_CODE "$ATEMA_CODE_DIR"
}
else {
	if "$root" == "" {
		if "`root_arg'" == "" {
			di as error "00_setup.do: pass the 2026_server root as its argument"
			exit 198
		}
		do "`root_arg'/config.do"
	}
	global ATEMA_CODE "$root/01. Code/06. Layer 4/ATEMA"
}

do "$ATEMA_CODE/00_paths.do"
do "$ATEMA_CODE/00_params.do"
do "$ATEMA_CODE/00_programs.do"
do "$ATEMA_CODE/00_packages.do"

* >>> [CLEAN] one seed and one sort seed for the whole run (old: seeds only in the DDML files;
* >>>         bysort ties resolved differently from run to run)
set seed $SEED
set sortseed $SEED
* >>> [CRASH] old files used "set matsize 6000" without cap, which errors on Stata BE
cap set maxvar 10000
cap set matsize 11000

global ATEMA_SETUP "1"
