# Historical Data on U.S. Occupational Regulation

This repository contains the main dataset described in the paper "Historical Data on Occupational Regulation in the United States" (Carollo 2025). 


## Data setup

The original policy data collected for this project can be found in `./Data/Policies.` These spreadsheets contain notes on sources and coding decisions that users may wish to review prior to working with the data. 

The file `./Programs/main.do` sets up the policy data in Stata format and also builds a balanced state-occupation panel from 1870 to 2020. Certain variables, including the classification of policies as licensing, certification, or registration requirements are derived from practice and title restrictions recorded in `./Data/Policies.` These derived variables do not appear in the source spreadsheets. 
 
### Revisions and potential errors

The data posted on this page are subject to revision. If you believe you have found an error in the data that you would like to report, please open an issue with the title "Potential error in data for [occupation]." In the body of the issue, describe which jurisdictions(s) have errors for the occupation, the variable(s) are incorrect, and the correction that should be reviewed. Please provide supporting documentation from primary sources. 

## Citation information

#### If you find this dataset useful, please cite the following paper: 

Carollo, Nicholas A. 2025. "Historical Data on Occupational Regulation in the United States." *Working paper* (revised January 2025).  

#### My other work based on this data:

Carollo, Nicholas A., Jason F. Hicks, Andrew Karch, and Morris M. Kleiner. 2025. "The Origins and Evolution of Occupational Licensing in the United States." *NBER Working Paper No. 33580*.

Carollo, Nicholas A. 2025. "The Labor Market Effects of Occupational Licensing." *Working paper* (revised April 2025)

Carollo, Nicholas A. and Jason F. Hicks. "Occupational Licensing in the U.S. Progressive Era." (in progress).

## Disclaimer

**This dataset is provided for research purposes only. Users interested in regulatory requirements for legal purposes should consult their state's statutes and regulations directly.**
