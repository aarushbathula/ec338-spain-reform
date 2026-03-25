****************************************************
* EC338 Spain Reform - shared setup
****************************************************

clear all
set more off
set varabbrev off
set scheme s1color

local pwd `"`c(pwd)'"'

if regexm(`"`pwd'"', "/code$") {
    global project_root = regexr(`"`pwd'"', "/code$", "")
}
else {
    global project_root `"`pwd'"'
}

global code_dir    "$project_root/code"
global data_dir    "$project_root/data"
global output_dir  "$project_root/output"
global figures_dir "$output_dir/figures"
global tables_dir  "$output_dir/tables"
global logs_dir    "$output_dir/logs"
global paper_dir   "$project_root/paper"

cap mkdir "$output_dir"
cap mkdir "$figures_dir"
cap mkdir "$tables_dir"
cap mkdir "$logs_dir"

global raw_data "$data_dir/assignment_2.dta"
capture confirm file "$raw_data"
if _rc {
    global raw_data "$data_dir/assignment 2.dta"
}

capture confirm file "$raw_data"
if _rc {
    di as error "Could not find assignment_2.dta or assignment 2.dta in $data_dir"
    exit 601
}
