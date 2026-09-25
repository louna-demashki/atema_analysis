* ==============================================================================
* 00_programs.do  --  small helpers used by every ATEMA script
* ==============================================================================
* >>> [CLEAN] whole file: ~80% of the old 20,800 lines were the same
* >>>         "coefficient -> stars -> string" block pasted again and again.
* >>> [FIX]   several pasted copies had typos (stars written into the wrong macro,
* >>>         leaving blank cells); written once here, they cannot drift.

cap program drop atema_log
program define atema_log
	args name
	cap log close atema_script
	local stamp : display %tdCCYY-NN-DD date(c(current_date), "DMY")
	local time = subinstr("`c(current_time)'", ":", "", .)
	log using "$ATEMA_CODE/01. Logs/`name'_`stamp'_`time'.log", text replace name(atema_script)
	di as text "`name' | env $ATEMA_ENV | LEGACY $LEGACY | `c(current_date)' `c(current_time)'"
end

cap program drop atema_log_close
program define atema_log_close
	cap log close atema_script
end

* >>> [NEW] fail early with a clear message instead of a mid-script r(601)
cap program drop atema_check_inputs
program define atema_check_inputs
	local bad ""
	foreach g in IN_ATEMA_TREATMENT IN_KHAN_L3 IN_SCHOOL_ARMS IN_END_ENROLLMENT IN_KHAN_2022 IN_KHAN_RAW {
		cap confirm file "${`g'}"
		if _rc {
			di as error "  missing input `g': ${`g'}"
			local bad 1
		}
	}
	if "`bad'" == "1" {
		di as error "Build the upstream layers first (tools/run_layers.sh) or fix 00_paths.do."
		exit 601
	}
end

* >>> [NEW] if Layer 3 renames a variable, the table skips that row and says so
cap program drop atema_keep_existing
program define atema_keep_existing, rclass
	syntax anything(name=vars)
	local ok ""
	local miss ""
	foreach v of local vars {
		cap confirm variable `v', exact
		if !_rc local ok `ok' `v'
		else    local miss `miss' `v'
	}
	if "`miss'" != "" di as text "  [atema] not in the data, skipped: `miss'"
	return local varlist `ok'
end

* >>> [CLEAN] one Khan merge for the analysis panel and the event panel (old: two copies)
* >>> [CLEAN] short names ka_* (old names were too long for control globals)
cap program drop atema_merge_khan
program define atema_merge_khan
	if "$KHAN_SOURCE" == "rebuilt" {
		merge m:1 SMAX_STUDENT_ID ACADEMIC_YEAR_ID_FK using "$ATEMA_DATA/khan_per_student_rebuilt.dta", ///
			keep(master match) keepusing(ka_login ka_minutes ka_skills ka_familiar) nogen
	}
	else {
		preserve
		use SMAX_STUDENT_ID ACADEMIC_YEAR_ID_FK student_login total_math_learning_minutes ///
			total_skills_leveled_up total_upskill_familiar using "$IN_KHAN_L3", clear
		drop if missing(ACADEMIC_YEAR_ID_FK)
		rename (student_login total_math_learning_minutes total_skills_leveled_up total_upskill_familiar) ///
		       (ka_login ka_minutes ka_skills ka_familiar)
		tempfile k
		save `k'
		restore
		merge m:1 SMAX_STUDENT_ID ACADEMIC_YEAR_ID_FK using `k', keep(master match) nogen
	}
	* same as old: no usage record = 0 usage (includes every control school)
	foreach v in ka_login ka_minutes ka_skills ka_familiar {
		replace `v' = 0 if missing(`v')
	}
	label var ka_login    "Logged in to Khan Academy during the year"
	label var ka_minutes  "Math learning minutes in the year"
	label var ka_skills   "Net math skills leveled up in the year"
	label var ka_familiar "Math skills leveled up to familiar in the year"
end

* ---------------------------------------------------------------- results --------
* >>> [NEW] every estimate is saved to 04. Output/ATEMA/results/<table>.dta, so figures
* >>>       and later tables read numbers instead of retyping them (old graph_RFE.do)
cap program drop atema_res_open
program define atema_res_open
	args table
	cap postclose ATEMA_PF
	global ATEMA_RES_FILE "$ATEMA_OUT/results/`table'.dta"
	* >>> [NEW] table name, used for \label{tab:...} in the LaTeX output
	global ATEMA_RES_TABLE "`table'"
	postfile ATEMA_PF str244 label int row int col str8 stat double(b se p n) ///
		using "$ATEMA_RES_FILE", replace
end

cap program drop atema_post
program define atema_post
	syntax , row(integer) col(integer) stat(string) [label(string) b(string) se(string) p(string) n(string)]
	post ATEMA_PF (`"`label'"') (`row') (`col') ("`stat'") (real("`b'")) (real("`se'")) (real("`p'")) (real("`n'"))
end

* >>> [CLEAN] replaces the 12-line pasted star block
cap program drop atema_post_coef
program define atema_post_coef
	syntax anything(name=term), row(integer) col(integer) [label(string)]
	cap local b = _b[`term']
	if _rc {
		atema_post, row(`row') col(`col') stat(coef) label(`"`label'"')
		exit
	}
	local se = _se[`term']
	local df = e(df_r)
	local p = .
	if `se' > 0 & `se' < . {
		if `df' < . local p = 2 * ttail(`df', abs(`b' / `se'))
		* >>> [FIX] normal p-values when the estimator has no df (DDML)
		else        local p = 2 * normal(-abs(`b' / `se'))
	}
	atema_post, row(`row') col(`col') stat(coef) label(`"`label'"') b(`b') se(`se') p(`p') n(`=e(N)')
end

cap program drop atema_post_mean
program define atema_post_mean
	syntax varname [if], row(integer) col(integer) [label(string)]
	quietly summarize `varlist' `if'
	atema_post, row(`row') col(`col') stat(mean) label(`"`label'"') b(`r(mean)') se(`r(sd)') n(`r(N)')
end

cap program drop atema_res_close
program define atema_res_close
	postclose ATEMA_PF
end

* >>> [CLEAN] LaTeX writer; replaces texdoc (one fewer package) and ~300 lines of
* >>>         "tex ..." per table.  Backslash pairs written with _char(92).
* >>> [FIX]   Overleaf-ready: escapes _ and < > in titles, notes, labels and column
* >>>         headers (they stop LaTeX or print as the wrong character); shrinks wide
* >>>         tables to the page width (needs \usepackage{adjustbox} in the preamble);
* >>>         adds \label{tab:<table name>} so the paper can \ref it.
cap program drop atema_tex
program define atema_tex
	syntax using/ [, title(string) collabels(string asis) notes(string)]

	foreach m in title notes {
		local `m' : subinstr local `m' "_" "\_", all
		local `m' : subinstr local `m' "<" "\textless{}", all
		local `m' : subinstr local `m' ">" "\textgreater{}", all
	}
	local collabels : subinstr local collabels "_" "\_", all

	preserve
	quietly {
		use "$ATEMA_RES_FILE", clear
		gen long _i = _n
		replace label = subinstr(label, "_", "\_", .)
		gen str244 c1 = ""
		gen str244 c2 = ""
		gen str3 _st = cond(p < .01, "***", cond(p < .05, "**", cond(p < .10, "*", "")))
		replace c1 = strtrim(string(b, "%9.3f")) + cond(_st != "", "\textsuperscript{" + _st + "}", "") if stat == "coef" & !missing(b)
		replace c2 = "(" + strtrim(string(se, "%9.3f")) + ")" if stat == "coef" & !missing(se)
		replace c1 = strtrim(string(b, "%9.3f")) if inlist(stat, "mean", "test") & !missing(b)
		replace c2 = "[" + strtrim(string(se, "%9.3f")) + "]" if stat == "mean" & !missing(se)
		replace c1 = strtrim(string(b, "%12.0fc")) if stat == "N" & !missing(b)
		summarize col, meanonly
		local ncol = r(max)
	}
	tempname fh
	file open `fh' using `"`using'"', write replace text
	file write `fh' "\begin{table}[htbp]\centering" _n "\caption{`title'}" _n
	file write `fh' "\label{tab:$ATEMA_RES_TABLE}" _n
	file write `fh' "\begin{adjustbox}{max width=\textwidth}" _n
	file write `fh' "\begin{tabular}{l*{`ncol'}{c}}" _n "\hline\hline" _n
	local h ""
	foreach c of local collabels {
		local h `"`h' & `c'"'
	}
	file write `fh' `"`h'"' _char(92) _char(92) _n
	local h ""
	forvalues j = 1/`ncol' {
		local h "`h' & (`j')"
	}
	file write `fh' "`h'" _char(92) _char(92) _n "\hline" _n
	quietly levelsof row, local(rows)
	foreach r of local rows {
		quietly summarize _i if row == `r', meanonly
		local lab = label[r(min)]
		local ishead = (stat[r(min)] == "head")
		if `ishead' {
			file write `fh' "\multicolumn{`=`ncol'+1'}{l}{\textit{`lab'}}" _char(92) _char(92) _n
			continue
		}
		local l1 "`lab'"
		local l2 ""
		local any2 0
		forvalues j = 1/`ncol' {
			quietly summarize _i if row == `r' & col == `j', meanonly
			local a ""
			local z ""
			if r(N) > 0 {
				local a = c1[r(min)]
				local z = c2[r(min)]
			}
			local l1 "`l1' & `a'"
			local l2 "`l2' & `z'"
			if "`z'" != "" local any2 1
		}
		file write `fh' "`l1'" _char(92) _char(92) _n
		if `any2' file write `fh' "`l2'" _char(92) _char(92) "[0.5ex]" _n
	}
	file write `fh' "\hline\hline" _n "\end{tabular}" _n "\end{adjustbox}" _n
	if `"`notes'"' != "" file write `fh' "\par\footnotesize{`notes'}" _n
	file write `fh' "\end{table}" _n
	file close `fh'
	restore
	di as text "  table written: `using'"
end

* ---------------------------------------------------------------- DDML -----------
* >>> [CLEAN] one DDML call instead of the same 15 lines pasted per subgroup
* >>> [FIX] strata/grade dummies come from the data (old: typed strata1-strata84)
* >>> [FIX] folds AND standard errors clustered by baseline school (old: fcluster only
* >>>       split the folds; SEs were default or robust, inconsistently)
cap program drop atema_ddml_rf
program define atema_ddml_rf
	syntax varname [if], treat(varlist) pool(string) [forced(string)]
	local pool : list pool - forced
	set seed $SEED
	ddml init partial `if', kfolds($DDML_K) reps($DDML_REPS) fcluster($CLUSTER)
	ddml E[Y|X]: reg `varlist' $FE_DUMMIES `forced' `pool'
	ddml E[Y|X]: rlasso `varlist' $FE_DUMMIES `forced' `pool', partial($FE_DUMMIES `forced') cluster($CLUSTER)
	foreach d of local treat {
		ddml E[D|X]: reg `d' $FE_DUMMIES `forced' `pool'
		ddml E[D|X]: rlasso `d' $FE_DUMMIES `forced' `pool', partial($FE_DUMMIES `forced') cluster($CLUSTER)
	}
	ddml crossfit
	* >>> [DECIDE] verify that the installed ddml accepts vce(cluster ...)
	ddml estimate, vce(cluster $CLUSTER)
end

* >>> [FIX] old IV ddml used "ivreg" as a learner and failed when saving (undefined row)
cap program drop atema_ddml_iv
program define atema_ddml_iv
	syntax varname [if], endog(varname) inst(varlist) pool(string) [forced(string)]
	local pool : list pool - forced
	set seed $SEED
	ddml init iv `if', kfolds($DDML_K) reps($DDML_REPS) fcluster($CLUSTER)
	ddml E[Y|X]: reg `varlist' $FE_DUMMIES `forced' `pool'
	ddml E[Y|X]: rlasso `varlist' $FE_DUMMIES `forced' `pool', partial($FE_DUMMIES `forced') cluster($CLUSTER)
	ddml E[D|X]: reg `endog' $FE_DUMMIES `forced' `pool'
	ddml E[D|X]: rlasso `endog' $FE_DUMMIES `forced' `pool', partial($FE_DUMMIES `forced') cluster($CLUSTER)
	foreach z of local inst {
		ddml E[Z|X]: reg `z' $FE_DUMMIES `forced' `pool'
		ddml E[Z|X]: rlasso `z' $FE_DUMMIES `forced' `pool', partial($FE_DUMMIES `forced') cluster($CLUSTER)
	}
	ddml crossfit
	ddml estimate, vce(cluster $CLUSTER)
end
