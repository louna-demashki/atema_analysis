* ==============================================================================
* 00_packages.do  --  checks that every user-written command is installed
* ==============================================================================
* >>> [NEW] old scripts assumed the packages were there
* >>> [CLEAN] texdoc and coefplot no longer needed
if "$ATEMA_AUTOINSTALL" == "" global ATEMA_AUTOINSTALL 1

local cmds "reghdfe ftools ivreg2 ranktest ivreghdfe ddml pdslasso rlasso winsor"
local pkgs "reghdfe ftools ivreg2 ranktest ivreghdfe ddml pdslasso lassopack winsor"
local n : word count `cmds'
forvalues i = 1/`n' {
	local c : word `i' of `cmds'
	local p : word `i' of `pkgs'
	cap which `c'
	if _rc {
		if "$ATEMA_ENV" == "local" & "$ATEMA_AUTOINSTALL" == "1" {
			ssc install `p', replace
		}
		else {
			di as error "Package `p' (command `c') is not installed."
			exit 199
		}
	}
}
