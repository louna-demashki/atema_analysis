//============================================================================//
// Comparing cohort 1 compliers with cohort 2 compliers 
//============================================================================//

clear all
set matsize 6000
set more off 
global dir "D:\SECURE\data 2024\analysis\atema" 
global input "$dir\data" 
global output "$dir\output"

cap log close
log using "$output\Logs\tables\appendix\comparing_compliance_by_cohort.txt", text replace


use "$input\master_controls", clear 

	
