****************************************************
* EC338 Spain Reform - master replication script
****************************************************

do "code/00_setup.do"

log using "$logs_dir/master.log", replace text

di as text "Running EC338 Spain Reform pipeline from $project_root"

do "$code_dir/01_did_event_study.do"
do "$code_dir/02_rdd.do"
do "$code_dir/03_iv.do"

log close
