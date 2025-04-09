* ==============================================================================
* metadata.do
* Build metadata file for regulated occupations
* Last updated on April 9, 2025
* ============================================================================== 

* Read in Excel file.
import excel "$data/Occupation Metadata.xlsx", sheet("Occupations") first clear
drop if missing(Type)
rename OccupationTitle occupation
rename Code code

* ------------------------------------------------------------------------------
* Process variables
* ------------------------------------------------------------------------------

* Code type.
gen type = . 
replace type = 1 if Type == "Primary"
replace type = 2 if Type == "Specialty"
replace type = 3 if Type == "Limited"
replace type = 4 if Type == "Residual"
replace type = 5 if Type == "Other"
labmask type, values(Type)
label var type "Code type"
assert !missing(type)
drop Type

* Job class.
gen job_class = .
replace job_class = 0  if JobClass == "Any class"
replace job_class = 10 if JobClass == "Private"
replace job_class = 11 if JobClass == "Contractor"
replace job_class = 12 if JobClass == "Own business"
replace job_class = 13 if JobClass == "Wage/salary"
replace job_class = 20 if JobClass == "Government"
labmask job_class, values(JobClass)
label var job_class "Class of worker restriction"
assert !missing(job_class)
drop JobClass

* Regulating jurisdiction.
gen jurisdiction = .
replace jurisdiction = 1 if Jurisdiction == "State"
replace jurisdiction = 2 if Jurisdiction == "Quasi-federal"
replace jurisdiction = 3 if Jurisdiction == "Federal"
labmask jurisdiction, values(Jurisdiction)
label var jurisdiction "Highest level of government regulation"
assert !missing(jurisdiction)
drop Jurisdiction

* Year added to the CAI.
rename CensusIndex census_index
destring census_index, ignore("N/A") replace
replace census_index = 0 if missing(census_index)
label define census_index 0 "N/A"
label values census_index census_index
label var census_index "Year added to Census Classified Index"
assert !missing(census_index)

* Clean up and set aside.
keep  code occupation type job_class jurisdiction census_index
order code occupation type job_class jurisdiction census_index
tempfile working
save `working', replace

* ------------------------------------------------------------------------------
* Attach occupation group codes
* ------------------------------------------------------------------------------

* Get major_group labels from SOC. 
use major_group major_title using "$data/Crosswalks/soc2010-structure.dta", clear
replace major_group = substr(major_group, 1, 2)
destring major_group, replace
duplicates drop
tempfile a
save `a', replace

* Attach major occupation groups. 
use `working', clear
gen major_group = substr(code, 1, 2)
destring major_group, replace
merge m:1 major_group using `a', nogen keep(master matched) assert(2 3)
labmask major_group, values(major_title)
drop major_title

* Aggregate major occupation groups. 
gen aggregate_group = .
replace aggregate_group = 0 if inlist(major_group, 11)
replace aggregate_group = 1 if inlist(major_group, 13, 23)
replace aggregate_group = 2 if inlist(major_group, 15, 17, 19)
replace aggregate_group = 3 if inlist(major_group, 25, 27)
replace aggregate_group = 4 if inlist(major_group, 21, 29, 31)
replace aggregate_group = 5 if inlist(major_group, 33, 35, 37, 39)
replace aggregate_group = 6 if inlist(major_group, 41, 43)
replace aggregate_group = 7 if inlist(major_group, 45, 51)
replace aggregate_group = 8 if inlist(major_group, 47, 49)
replace aggregate_group = 9 if inlist(major_group, 53)
assert !missing(aggregate_group)

* Assign labels to major occupation groups. 
label define aggregate_group ///
  0 "Management Occupations" ///
  1 "Financial and Legal Occupations" ///
  2 "Computer, Engineering, and Scientific Occupations" ///
  3 "Arts, Education, and Media Occupations" ///
  4 "Healthcare and Social Service Occupations" ///
  5 "Other Service Occupations" ///
  6 "Administrative and Sales Occupations" ///
  7 "Agricultural and Production Occupations" ///
  8 "Construction and Maintenance Occupations" ///
  9 "Transportation and Material Moving Occupations" 
label values aggregate_group aggregate_group
compress

* Set aside.
order code occupation aggregate_group major_group
tempfile working
save `working', replace

* ------------------------------------------------------------------------------
* Flag occupations in the main regulation database
* ------------------------------------------------------------------------------

* Get historical regulation file layout.
import excel "$data/Historical Regulation File Layout.xlsx", sheet("Occupations") first clear
drop if missing(Updated)
keep Code OccupationTitle
rename OccupationTitle occupation
rename Code code
tempfile a
save `a', replace

* Attach historical regulation flag. 
use `working', clear
merge 1:1 code occupation using `a', assert(1 3)
gen history=(_merge==3)
label define history 0 "No" 1 "Yes"
label values history history
drop _merge

* Variable labels.
label var code            "Occupation code"
label var occupation      "Occupation title"
label var aggregate_group "Aggregate occupation group"
label var major_group     "Major occupation group"
label var history         "Included in historical regulation data"

* Clean up and save.
order code occupation aggregate_group major_group history
label data "Occupation Metadata"
save "$data/Build/metadata.dta", replace

* ============================================================================== 
* Done
* ============================================================================== 
