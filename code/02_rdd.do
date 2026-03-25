****************************************************
* EC338 Spain Reform - RDD analysis
****************************************************

do "$code_dir/00_setup.do"

use "$raw_data", clear

drop if province_code == 20
drop if population_2007 > 5000
keep if inlist(year, 2007, 2011)
keep if elected == 1

gen female_elected = female_candidate * elected

collapse (sum) female_elected (sum) total_elected = elected ///
        (mean) population_2011 population_2007, ///
        by(municipality_code year)

gen share_elected = female_elected / total_elected

preserve
    keep if year == 2007
    keep municipality_code share_elected
    rename share_elected share_elected_2007
    tempfile lag2007
    save `lag2007'
restore

keep if year == 2011
merge 1:1 municipality_code using `lag2007', nogen

gen pop_c = population_2011 - 3000

rdrobust share_elected pop_c, c(0) p(1) kernel(triangular)

rdplot share_elected pop_c if inrange(pop_c, -1111.475, 1111.475), ///
    c(0) p(1) h(1111.475 1111.475) kernel(triangular)
graph save "$figures_dir/rdplot_share_female_councillors_2011_16dec.gph", replace
graph export "$figures_dir/rdplot_share_female_councillors_2011_16dec.pdf", replace

rddensity pop_c, c(0) plot
graph save "$figures_dir/rddensity_population_3000_16dec.gph", replace
graph export "$figures_dir/rddensity_population_3000_16dec.pdf", replace

rdrobust share_elected_2007 pop_c, c(0) p(1) kernel(triangular)
rdplot share_elected_2007 pop_c, c(0) p(1)
graph save "$figures_dir/rdplot_share_female_councillors_2007_placebo_16dec.gph", replace
graph export "$figures_dir/rdplot_share_female_councillors_2007_placebo_16dec.pdf", replace
