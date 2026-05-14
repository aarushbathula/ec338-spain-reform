****************************************************
* EC338 Assignment 2 — Gender Quotas in Spanish Local Elections
* Jamie Chan (5534070) Aarush Bathula (5513578), Edward Chamberlain (5526786), Will Murphy (2204888)
* Group Number: [T]
* Last Updated: [16/12] - Q1-4 codes
****************************************************

clear all
set more off
set varabbrev off
set scheme s1color  

* Locate project path
cd "~/Desktop"
use assignment_2.dta, clear

* Create log file
log using "EC338_Assignment_2_Group[T]_Spain.log", replace

****************************************************
* Question 2
****************************************************

/// Q2(a) - DiD ///

* Clean dataset
drop if province_code == 20

drop if population_2007 > 5000

* Include 1999 and 2003 for event study
keep if inlist(year, 1999, 2003, 2007, 2011)

* Generate group for municipalities greater or equal to 3000
gen treated = (population_2011 >= 3000)

* Generate group after election
gen post = (year >= 2011)

keep if elected == 1

gen female_elected = female_candidate * elected

* Collapse dataset into municipality level for municipality analysis
collapse (sum) female_elected (sum) total_elected = elected, by(municipality_code year treated post)

gen share_elected = female_elected/total_elected

* Simple DiD with clustering at municipality levels
reg share_elected i.treated##i.post, vce(cluster municipality_code)
estimates store did_ols

xtset municipality_code year

* Extending DiD for within-municipality fixed-effects
xtreg share_elected i.treated##i.post, fe vce(cluster municipality_code)
estimates store did_fe

/// Q2(b) - Event Study ///

* Reload dataset for Event Study analysis (and for any subparts hereafter)

clear
use assignment_2.dta, clear

drop if province_code == 20
drop if population_2007 > 5000

keep if inlist(year, 1999, 2003, 2007, 2011)

keep if elected == 1

gen treated = (population_2011 >= 3000)

gen female_elected = female_candidate * elected

collapse (sum) female_elected (sum) total_elected = elected, ///
    by(municipality_code year treated)

gen share_elected = female_elected/total_elected

xtset municipality_code year 

* Full event study model (2007 is the omitted baseline)
xtreg share_elected i.treated##ib(2007).year, fe vce(cluster municipality_code)
estimates store did_event

* Plot the event study
coefplot, keep(1.treated#*.year) vertical yline(0) ///
    rename(1.treated#([0-9]+).year = \1) ///
    title("Event Study: Policy Impact and Pre-Trends") ///
    xtitle("Year") ytitle("Coef. Estimate")

graph save "q2_event_study_16dec.gph", replace


****************************************************
* Q3 — RDD Analysis & Diagnostics
****************************************************

* Required packages to be installed (remove comments once installed)
* ssc install rdrobust
* ssc install rddensity
* ssc install lpdensity

* Reload dataset
clear all
set more off
set varabbrev off
cd "~/Desktop"

use assignment_2.dta, clear

drop if province_code == 20
drop if population_2007 > 5000
keep if inlist(year, 2007, 2011)
keep if elected == 1

gen female_elected = female_candidate * elected

collapse (sum) female_elected (sum) total_elected = elected ///
        (mean) population_2011 population_2007, ///
        by(municipality_code year)

gen share_elected = female_elected/total_elected

* Construct 2007 lagged outcome
preserve
    keep if year == 2007
    keep municipality_code share_elected
    rename share_elected share_elected_2007
    tempfile lag2007
    save `lag2007'
restore

* 2011 cross-section for RDD
keep if year == 2011
merge 1:1 municipality_code using `lag2007', nogen

* Running variable centered at 3000
gen pop_c = population_2011 - 3000

/// Q3(a) - Main RD Estimate & Plot ///

* Local linear RD, triangular kernel, CCT bandwidth
rdrobust share_elected pop_c, c(0) p(1) kernel(triangular)

* RD plot (customised bandwidth)
rdplot share_elected pop_c if inrange(pop_c, -1111.475, 1111.475), c(0) p(1) h(1111.475 1111.475) kernel(triangular)

* Save RD plot
graph save "~/Desktop/rdplot_share_female_councillors_2011_16dec.gph", replace

/// Q3(b) - Validity Checks ///

* Density test of running variable around 3000
rddensity pop_c, c(0) plot

* Save density plot
graph save "~/Desktop/rddensity_population_3000_16dec.gph", replace

* Placebo RD on lagged (2007) outcome
rdrobust share_elected_2007 pop_c, c(0) p(1) kernel(triangular)

* RD plot for 2007 lag (placebo)
rdplot share_elected_2007 pop_c, c(0) p(1)

graph save "~/Desktop/rdplot_share_female_councillors_2007_placebo_16dec.gph", replace


****************************************************
* Q4 — Instrumental Variables (IV) Analysis
****************************************************

* Reload dataset
clear all
set more off
set varabbrev off
cd "~/Desktop"

use assignment_2.dta, clear

drop if province_code == 20

drop if population_2007 > 5000

keep if inlist(year, 1999, 2003, 2007, 2011)

gen treated = (population_2011 >= 3000)

gen post = (year >= 2011)

* Instrument (Z) - DiD interaction term
gen instrument = treated * post


* Variable Creation (Candidate Level)

keep if elected == 1 

* Endogenous Variable (X) component: 1 if candidate is female councilor
gen female_elected  = female_candidate

* Outcome Variable (Y): 1 if the mayor is female
gen female_mayor_candidate = (mayor == 1 & female_candidate == 1)


* Collapse to Municipality level

collapse (max) female_mayor = female_mayor_candidate /// // Q4 Outcome (Y)
         (sum) female_elected (sum) total_elected = elected /// Q4 Endogenous (X) Components
         (max) treated (max) instrument, ///
         by(municipality_code year)

gen share_female_councillors = female_elected / total_elected // Endogenous Variable (X)

xtset municipality_code year


* ------------------------------------------------------------------
* Q4(a) OLS (Naive) - Identification based on observables
* ------------------------------------------------------------------

* Linear Probability Model with year fixed effects and clustered errors
regress female_mayor share_female_councillors i.year, vce(cluster municipality_code)
estimates store q4_ols



* ------------------------------------------------------------------
* Q4(b) DiD-IV Components (Fixed Effects) - For Manual Wald Estimate
* ------------------------------------------------------------------

* (i) First stage: Checks Relevance. Quota (Z) -> Councillors (X)
* The first stage should be a Fixed Effects DiD model
xtreg share_female_councillors instrument i.year, fe vce(cluster municipality_code)
local first_stage_coef = _b[instrument] // Save for Wald estimate
testparm instrument

* (ii) Reduced form: Measures the total effect of the Quota (Z) on Mayor (Y)
* The reduced form should also be a Fixed Effects DiD model
xtreg female_mayor instrument i.year, fe vce(cluster municipality_code)
local reduced_form_coef = _b[instrument] // Save for Wald estimate


* (iii) Wald estimate: IV = Reduced Form / First Stage
local wald_estimate = `reduced_form_coef' / `first_stage_coef'
display "Wald IV estimate = " `wald_estimate'


* ------------------------------------------------------------------
* Q4(c) 2SLS Estimate (Fixed Effects) - The Final Answer
* ------------------------------------------------------------------

* This command provides the same IV estimate as the Wald ratio, plus correct standard errors.
xtivreg female_mayor i.year (share_female_councillors = instrument), fe vce(cluster municipality_code)
estimates store iv_fe

* ------------------------------------------------------------------
* Exporting graphs
* ------------------------------------------------------------------

* 1. Main 2011 RD plot
graph use "~/Desktop/rdplot_share_female_councillors_2011_16dec.gph"
graph export "~/Desktop/rdplot_share_female_councillors_2011_16dec.pdf", replace

* 2. Density plot of running variable
graph use "~/Desktop/rddensity_population_3000_16dec.gph"
graph export "~/Desktop/rddensity_population_3000_16dec.pdf", replace

* 3. 2007 placebo RD plot
graph use "~/Desktop/rdplot_share_female_councillors_2007_placebo_16dec.gph"
graph export "~/Desktop/rdplot_share_female_councillors_2007_placebo_16dec.pdf", replace

* 4. Q2 event study plot
graph use "~/Desktop/q2_event_study_16dec.gph"
graph export "~/Desktop/q2_event_study_16dec.pdf", replace

log close
