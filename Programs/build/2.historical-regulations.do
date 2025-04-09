* ==============================================================================
* historical-regulations.do
* Build main historical regulation database
* Last updated on April 9, 2025
* ============================================================================== 

* Get a list of historical regulation files.
local file_list: dir "$data/Policies" files "*.xlsx"
local file_list_sorted: list sort file_list
local first: word 1 of `file_list_sorted'

* Stack occupation-specific files.
foreach file in `file_list_sorted' {

  di "`file'"
  import excel "$data/Policies/`file'", sheet("Regulations") first allstring clear
  qui drop if missing(OccupationTitle)
  rename OccupationTitle occupation
  rename Code code
  
  if ("`file'" == "`first'") qui tempfile working
  if ("`file'" != "`first'") qui append using `working'
  qui save `working', replace

}

* ------------------------------------------------------------------------------
* Process variables
* ------------------------------------------------------------------------------

* State FIPS code.
use `working', clear
rename State state_name
merge m:1 state_name using "$data/Crosswalks/states.dta", nogen keep(master matched) keepusing(statefip)
replace statefip = 0 if state_name == "Federal"
label define statefip 0 "Federal", add
label var statefip "State FIPS code"
assert !missing(statefip)

* Flag unknown/imputed enactment dates.
gen dateflag = strpos(Date, "*")>0
label define dateflag 0 "No" 1 "Yes"
label values dateflag dateflag
label var dateflag "Enactment date flag"
egen temp = max(dateflag), by(occupation code statefip)
replace dateflag = temp
assert !missing(dateflag)
drop temp

* Effective dates.
destring Date, ignore("*") force replace
rename Date effective
label var effective "Effective date"
assert !missing(effective)

* Enactment dates. 
gen enacted=substr(Citation, 1,4)
destring enacted, replace
label var enacted "Enactment date"
assert !missing(enacted)

* Event type.
gen event = .
replace event = 0 if Event == "Enactment"
replace event = 1 if Event == "Amendment"
replace event = 2 if Event == "Replacement"
replace event = 3 if Event == "Repeal"
replace event = 4 if Event == "Other"
labmask event, values(Event)
label var event "Type of event"
assert !missing(event)
drop Event

* Format practice restrictions. 
gen practice = .
replace practice = 0 if Practice == "Unregulated"
replace practice = 1 if Practice == "Partial"
replace practice = 2 if Practice == "Complete"
replace practice = 3 if Practice == "Prohibited"
labmask practice, values(Practice) 
label var practice "Right-to-practice"
assert !missing(practice)
drop Practice 

* Format title restrictions.
gen title = . 
replace title = 0 if Title == "Unregulated"
replace title = 1 if Title == "Weak"
replace title = 2 if Title == "Strong"
replace title = 3 if Title == "Implied"
labmask title, values(Title)
label var title "Right-to-title"
assert !missing(title)
drop Title

* Format direct regulation flag. 
gen direct = .
replace direct = -1 if Direct == "N/A"
replace direct =  0 if Direct == "No"
replace direct =  1 if Direct == "Yes"
labmask direct, values(Direct)
label var direct "Direct regulation"
assert !missing(direct)
drop Direct

* Format agency variable. 
gen agency = .
replace agency = -1 if Agency == "N/A"
replace agency =  0 if Agency == "Private"
replace agency =  1 if Agency == "Local"
replace agency =  2 if Agency == "State"
replace agency =  3 if Agency == "Federal"
labmask agency, values(Agency)
label var agency "Agency issuing credential"
assert !missing(agency)
drop Agency

* Format statewide indicator. 
gen statewide = .
replace statewide = -1 if Statewide == "N/A"
replace statewide =  0 if Statewide == "No"
replace statewide =  1 if Statewide == "Yes"
labmask statewide, values(Statewide)
label var statewide "Law applies statewide"
assert !missing(statewide)
drop Statewide

* Format qualifications indicator. 
gen qualifications = .
replace qualifications = -1 if Qualifications == "N/A"
replace qualifications =  0 if Qualifications == "No"
replace qualifications =  1 if Qualifications == "Yes"
labmask qualification, values(Qualifications)
label var qualifications "Requires education, training, or examination"
assert !missing(qualifications)
drop Qualifications

* Format multiple credential levels indicator. 
gen levels = .
replace levels = -1 if Levels == "N/A"
replace levels =  0 if Levels == "No"
replace levels =  1 if Levels == "Yes"
labmask levels, values(Levels)
label var levels "Multiple credential levels"
assert !missing(levels)
drop Levels

* Format source indicator. 
gen source = .
replace source = 1 if Source == "Regulations"
replace source = 2 if Source == "Statutes"
replace source = 3 if Source == "Other"
labmask source, values(Source)
label var source "Source of law"
assert !missing(source)
drop Source

* Format citation. 
rename Citation citation
label var citation "Citation"
assert !missing(citation)

* Check logic of variables.
assert enacted > 0
assert effective > 0
assert effective >= enacted
assert practice > 0 if title == 3
assert practice == 0 if event == 3
assert title == 0 if event == 3
assert direct == -1 if event == 3
assert agency == -1 if event == 3
assert statewide == -1 if event == 3
assert qualifications == -1 if event == 3
assert levels == -1 if event == 3

* Clean up. 
label var code "Occupation code"
label var occupation "Occupation title"
keep occupation code statefip enacted effective dateflag event practice title direct agency statewide qualifications levels source citation
compress

* ------------------------------------------------------------------------------
* Define methods of regulation
* ------------------------------------------------------------------------------

* Define binary regulation indicator. 
gen regulated = (practice>0 | title>0)
label define regulated 0 "No" 1 "Yes"
label values regulated regulated
label var regulated "Any occupational regulation"
assert !missing(regulated)

* Define general method of regulation. 
gen regulation = .
replace regulation = 0 if  practice == 0 & title == 0
replace regulation = 1 if (practice >  0 | title >  0)  & agency == 0
replace regulation = 2 if (practice >  0 | title >  0)  & agency >= 1 & qualifications == 0 
replace regulation = 3 if  practice == 0 & title == 1   & agency >= 1 & qualifications >  0
replace regulation = 4 if (practice >  0 | title >= 2)  & agency >= 1 & qualifications >  0
replace regulation = 5 if  practice == 3
assert !missing(regulation)

* Assign descriptive labels for general method of regulation. 
label define regulation ///
  0 "Unregulated" ///
  1 "Private" ///
  2 "Registration" ///
  3 "Certification" ///
  4 "Licensure" ///
  5 "Prohibited"
label values regulation regulation
label var regulation "General method of regulation"

* Define detailed method of regulation. 
gen regulation_detail = .
replace regulation_detail = 0 if practice == 0 & title == 0
replace regulation_detail = 1 if practice == 0 & title >  0 & agency == 0
replace regulation_detail = 2 if practice >  0              & agency == 0
replace regulation_detail = 3 if practice == 0 & title >  0 & agency >= 1 & qualifications == 0
replace regulation_detail = 4 if practice >  0              & agency >= 1 & qualifications == 0
replace regulation_detail = 5 if practice == 0 & title == 1 & agency >= 1 & qualifications >  0
replace regulation_detail = 6 if practice == 0 & title >= 2 & agency >= 1 & qualifications >  0
replace regulation_detail = 7 if practice == 1              & agency >= 1 & qualifications >  0
replace regulation_detail = 8 if practice == 2              & agency >= 1 & qualifications >  0
replace regulation_detail = 9 if practice == 3
assert !missing(regulation_detail)

* Assign descriptive labels for detailed method of regulation. 
label define regulation_detail ///
  0 "Unregulated" ///
  1 "Deceptive advertising" ///
  2 "Private credentialing" ///
  3 "Voluntary registration" ///
  4 "Mandatory registration" ///
  5 "Voluntary certification" ///
  6 "Effective licensure" ///
  7 "Quasi-mandatory licensure" ////
  8 "Mandatory licensure" ///
  9 "Prohibited" 
label values regulation_detail regulation_detail
label var regulation_detail "Detailed method of regulation"
compress

* Clean, sort, and save. 
keep  code occupation statefip event effective enacted regulated regulation regulation_detail practice title direct agency statewide qualifications levels source dateflag source citation
order code occupation statefip event effective enacted regulated regulation regulation_detail practice title direct agency statewide qualifications levels source dateflag source citation
sort code statefip enacted
label data "Historical Regulation Data"
save "$data/build/historical-regulations.dta", replace

* ============================================================================== 
* Done
* ============================================================================== 