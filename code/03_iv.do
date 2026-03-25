****************************************************
* EC338 Spain Reform - IV analysis
****************************************************

do "$code_dir/00_setup.do"

use "$raw_data", clear

drop if province_code == 20
drop if population_2007 > 5000
keep if inlist(year, 1999, 2003, 2007, 2011)

gen treated = (population_2011 >= 3000)
gen post = (year >= 2011)
gen instrument = treated * post

keep if elected == 1

gen female_elected = female_candidate
gen female_mayor_candidate = (mayor == 1 & female_candidate == 1)

collapse (max) female_mayor = female_mayor_candidate ///
         (sum) female_elected (sum) total_elected = elected ///
         (max) treated (max) instrument, ///
         by(municipality_code year)

gen share_female_councillors = female_elected / total_elected

xtset municipality_code year

regress female_mayor share_female_councillors i.year, ///
    vce(cluster municipality_code)
estimates store q4_ols

xtreg share_female_councillors instrument i.year, fe ///
    vce(cluster municipality_code)
local first_stage_coef = _b[instrument]
testparm instrument

xtreg female_mayor instrument i.year, fe vce(cluster municipality_code)
local reduced_form_coef = _b[instrument]

local wald_estimate = `reduced_form_coef' / `first_stage_coef'
display "Wald IV estimate = " `wald_estimate'

xtivreg female_mayor i.year ///
    (share_female_councillors = instrument), fe ///
    vce(cluster municipality_code)
estimates store iv_fe
