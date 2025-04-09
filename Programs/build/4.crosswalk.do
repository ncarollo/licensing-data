* ==============================================================================
* crosswalk.do
* Build crosswalk file for regulated occupations
* Last updated on April 9, 2025
* ============================================================================== 

* Read in Excel file. 
import excel "$data/Standard Occupational Classification Crosswalk.xlsx", sheet("Crosswalk") first clear
drop if missing(SOC2010)
rename Code code
rename OccupationTitle occupation
rename SOC2010 soc2010
rename NAICS2012 naics2012

* Format SOC 2010 codes. 
replace Title2010 =  "(" + soc2010 + ") " + Title2010
destring soc2010, ignore("-") force replace
labmask soc2010, values(Title2010)
label variable soc2010 "Occupation code (SOC 2010)"
drop Title2010

* Format NAICS 2012 codes. 
replace naics2012 = "000000" if naics2012=="N/A"
replace IndustryTitle2012 = "(" + naics2012 + ") " + IndustryTitle2012
destring naics2012, replace
labmask naics2012, values(IndustryTitle2012)
drop IndustryTitle2012

* Format SOC level. 
gen level = .
replace level = 1 if SOCLevel == "Detailed"
replace level = 2 if SOCLevel == "Partition"
replace level = 3 if SOCLevel == "Component"
labmask level, values(SOCLevel)
format level %12.0f
assert !missing(level)
drop SOCLevel

* Format industry indicator.
gen industry = .
replace industry = 0 if Industry=="No"
replace industry = 1 if Industry=="Yes"
labmask industry, values(Industry)
assert !missing(industry)
drop Industry

* Define variable labels. 
label variable code       "Occupation code" 
label variable occupation "Occupation title"
label variable level      "Classification level"
label variable industry   "Identifiable with addition of industry"
label variable soc2010    "Occupation code (SOC 2010)"
label variable naics2012  "Industry code (NAICS 2012)"
compress

* Save crosswalk file. 
keep  code occupation level soc2010 industry naics2012
order code occupation level soc2010 industry naics2012
label data "Historical Regulation Crosswalk (SOC 2010)" 
sort code soc2010 naics2012
save "$data/Build/crosswalk.dta", replace

* ============================================================================== 
* Done
* ============================================================================== 