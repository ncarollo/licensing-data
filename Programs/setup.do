* ==============================================================================
* setup.do
* Build historical occupational regulation datasets
* Last updated on March 30, 2024
* ==============================================================================

/* This code sets up the historical occupational regulation data in Stata format.
User paths are defined relative to the location of this .do file. If starting 
from a different working directory, first navigate to ~/Programs before running 
this code or manually set the paths below.  */

* ------------------------------------------------------------------------------
* Set paths and working directory
* ------------------------------------------------------------------------------

if regexm("`c(pwd)'", "(.+)/Programs(/[^/]*)?$") {
  global project `=regexs(1)'
}
else {
  disp as error "Could not verify project directory. Exit Stata and reopen file or navigate to ~/Programs." _n
  exit = 9
}

global data     "$project/Data"
global programs "$project/Programs"

clear all
set more off
cd "$project"

* ------------------------------------------------------------------------------
* Install user-written programs
* ------------------------------------------------------------------------------

* Update ado files.
capture ssc install gzsave,   replace  // Load/save compressed .dta files
capture ssc install gtools,   replace  // Fast collapse and egen
capture ssc install gr0034,   replace  // Strings to labels

* ------------------------------------------------------------------------------
* Setup historical regulation data
* ------------------------------------------------------------------------------

do "$programs/historical_regulation_data.do"
do "$programs/state_regulation_panel.do"

* ==============================================================================
* DONE
* ==============================================================================