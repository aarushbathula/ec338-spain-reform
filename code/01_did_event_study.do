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

esttab did_ols did_fe using "$tables_dir/table_q2_did.tex", replace ///
    se star(* 0.10 ** 0.05 *** 0.01) label ///
    mtitles("DiD OLS" "DiD FE") ///
    keep(1.treated 1.post 1.treated#1.post) ///
    stats(N r2, labels("Observations" "R-squared"))

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

esttab did_event using "$tables_dir/table_q2_event_study.tex", replace ///
    se star(* 0.10 ** 0.05 *** 0.01) label ///
    keep(1.treated#1999.year 1.treated#2003.year 1.treated#2011.year) ///
    order(1.treated#1999.year 1.treated#2003.year 1.treated#2011.year) ///
    coeflabels(1.treated#1999.year "Treated x 1999" ///
               1.treated#2003.year "Treated x 2003" ///
               1.treated#2011.year "Treated x 2011") ///
    stats(N r2_w, labels("Observations" "Within R-squared"))

coefplot, keep(1.treated#*.year) vertical yline(0) ///
    rename(1.treated#([0-9]+).year = \1) ///
    title("Event Study: Policy Impact and Pre-Trends") ///
    xtitle("Year") ytitle("Coef. Estimate")

graph save "$figures_dir/q2_event_study_16dec.gph", replace
graph export "$figures_dir/q2_event_study_16dec.pdf", replace
