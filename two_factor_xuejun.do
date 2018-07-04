* estimate historical beta and error variance

cd ""

clear

local namelist apa apc cop cvx hes mro oxy xom

foreach v in `namelist' {

	use "./Data/`v'.dta", clear

	reshape wide ret, i(date) j(name) string

	tsset date
	rolling _b e(rmse), window(60) clear: regress ret`v' retspx

	drop start _b_cons
	rename (end _b_retspx _eq2_stat_1) (date beta sig)
	gen name="`v'"
	replace sig=sig*sqrt(252)
	
	save "./Data/hist_beta_err_`v'.dta", replace
	
	* historical rolling return variances
	
	use "./Data/`v'.dta", clear

	reshape wide ret, i(date) j(name) string

	tsset date
	rolling r(Var), window(60) clear: sum ret`v'

	drop start
	rename (end _stat_1) (date var_ret)
	gen name="`v'"
	replace var_ret=var_ret*252

	save "./Data/hist_var_`v'.dta", replace

}

foreach v in `namelist' {

	use "./Data/hist_var_`v'.dta", clear
	sort date
	save "./Data/hist_var_`v'.dta", replace
	
	use "./Data/hist_beta_err_`v'.dta", clear
	sort date
	merge 1:1 date using "./Data/hist_var_`v'.dta", sorted
	
	keep if _merge==3
	drop _merge
	
	save "./Data/hist_beta_err_`v'.dta", replace
	
}
