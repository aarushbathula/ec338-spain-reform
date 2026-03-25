****************************************************
* EC338 Spain Reform - DiD and event study
****************************************************

do "$code_dir/00_setup.do"

use "$raw_data", clear

drop if province_code == 20
drop if population_2007 > 5000
keep if inlist(year, 1999, 2003, 2007, 2011)
keep if elected == 1

gen treated = (population_2011 >= 3000)
gen post = (year >= 2011)
gen female_elected = female_candidate * elected

collapse (sum) female_elected (sum) total_elected = elected, ///
    by(municipality_code year treated post)

gen share_elected = female_elected / total_elected

reg share_elected i.treated##i.post, vce(cluster municipality_code)
estimates store did_ols

xtset municipality_code year
xtreg share_elected i.treated##i.post, fe vce(cluster municipality_code)
estimates store did_fe

* Rebuild the collapsed panel for the event-study specification.
use "$raw_data", clear

drop if province_code == 20
drop if population_2007 > 5000
keep if inlist(year, 1999, 2003, 2007, 2011)
keep if elected == 1

gen treated = (population_2011 >= 3000)
gen female_elected = female_candidate * elected

collapse (sum) female_elected (sum) total_elected = elected, ///
    by(municipality_code year treated)

gen share_elected = female_elected / total_elected

xtset municipality_code year
xtreg share_elected i.treated##ib(2007).year, fe vce(cluster municipality_code)
estimates store did_event

coefplot, keep(1.treated#*.year) vertical yline(0) ///
    rename(1.treated#([0-9]+).year = \1) ///
    title("Event Study: Policy Impact and Pre-Trends") ///
    xtitle("Year") ytitle("Coef. Estimate")

graph save "$figures_dir/q2_event_study_16dec.gph", replace
graph export "$figures_dir/q2_event_study_16dec.pdf", replace
