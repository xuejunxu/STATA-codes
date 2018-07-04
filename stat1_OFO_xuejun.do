cd "C:/Users/xx2757/STATA files/Forward Beta"

use "./Data/sig_OFO_data.dta", clear

tsset date

rolling _b e(rmse), window(60) clear: regress ret ret_spx

drop start _b_cons
rename (end _b_ret_spx _eq2_stat_1) (date beta sig)
replace sig=sig*sqrt(252)
	
save "./Data/hist_beta_err_OFO.dta", replace


* historical rolling return variances

use "./Data/sig_OFO_data.dta", clear

tsset date

rolling r(Var), window(60) clear: sum ret

drop start
rename (end _stat_1) (date var_ret)
replace var_ret=var_ret*252

save "./Data/hist_var_OFO.dta", replace

use "./Data/hist_var_OFO.dta", clear

gen sig2=sig*sig
sort date 
by date: egen stat1=sig2/var_ret

keep date stat1
duplicates drop date stat1, force
save "./Data/stat1_OFO.dta", replace

export excel using "./Results/stat1_OFO.xlsx", firstrow(variable) replace
