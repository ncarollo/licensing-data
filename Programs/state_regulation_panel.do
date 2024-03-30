* ==============================================================================
* state_regulation_panel.do
* Reshape the historical regulation data into a balanced panel
* Last updated on March 30, 2024
* ==============================================================================

/* This code transforms the historical regulation data into a balanced panel. It
also de-duplicates overlapping state and federal laws to identify the binding
requirements for each state-occupation cell. By default, the panel covers 1870-2020 
and policies are assigned based on enactment dates. To change these parameters, 
edit the macros below. */

local initial enacted
local start 1870
local end 2020

* ------------------------------------------------------------------------------
* Create a balanced state-by-occupation panel
* ------------------------------------------------------------------------------

* Construct all state-by-occupation pairs in the data. 
use "$data/historical_regulation_data.dta", clear
gcontract code occupation statefip, freq(temp)
reshape wide temp, i(occupation code) j(statefip)
reshape long
drop temp

* Expand to panel. 
expand (`end' - `start') + 1
bysort code occupation statefip: gen year=`start' + (_n-1)
order code occupation statefip year
sort code statefip year
label var year "Year"
tempfile working
save `working', replace

* ------------------------------------------------------------------------------
* Reshape the regulation data into a panel structure
* ------------------------------------------------------------------------------

* Find the last policy enacted before panel starts.
use "$data/historical_regulation_data.dta", clear
egen temp=max(`initial') if `initial'<=`start', by(occupation code statefip)
drop if `initial' != temp & ! missing(temp)
replace `initial' = `start' if !missing(temp)
rename `initial' year
drop temp

* Merge with panel and set initial conditions.
merge 1:1 statefip code occupation year using `working', nogen keep(matched using)
drop event effective citation

foreach xx in regulated regulation regulation_detail practice title dateflag {
  replace `xx'=0 if missing(`xx') & year==`start'
}

foreach xx in direct agency statewide qualifications levels source {
  replace `xx'=-1 if missing(`xx') & year==`start'
}

* Recode source if not regulated.
replace source=-1 if regulated==0
label define source -1 "N/A", modify

* Populate panel by filling down data between events.
foreach xx in regulated regulation regulation_detail practice title direct agency statewide qualifications levels dateflag source {
  bysort code statefip (year): replace `xx'=`xx'[_n-1] if missing(`xx')
}

* Set aside.
tempfile working
save `working', replace

* ------------------------------------------------------------------------------
* De-duplicate overlapping state and federal laws
* ------------------------------------------------------------------------------

* Get federal regulations.
use if statefip==0 & regulated==1 using `working', clear
gen federal=1

* Expand federal regulations to cover all states.
drop statefip
cross using "$data/Crosswalks/states.dta"
drop state_name state region division
append using `working'
drop if statefip==0

* Occupations regulated at the federal level only.
duplicates tag statefip occupation code year, gen(flag)
drop if flag>0 & regulated==0
drop flag

* Update agency variable when state and federal laws overlap. 
duplicates tag statefip occupation code year, gen(flag)
replace agency=4 if flag==1
label define agency 4 "Multiple", modify
drop flag

* Keep binding level of regulation.
gsort code statefip year -regulation_detail federal
bysort code statefip year: keep if _n==1
drop federal
compress 

* Clean up and save.
label var statefip "State FIPS code"
order code occupation statefip year regulated regulation regulation_detail practice title direct agency statewide qualifications levels source dateflag
label data "State Regulation Panel (Built $S_DATE $S_TIME)"
save "$data/state_regulation_panel.dta", replace

* ============================================================================== 
* DONE
* ============================================================================== 