# Historical Data on U.S. Occupational Regulation

This repository contains data on the history of U.S. occupational regulation for a subset of occupations described in the paper "Historical Data on Occupational Regulation in the United States." Data for the full set of occupation categories along with crosswalk and metadata files will be posted for public use once final review and cleaning of the database is complete. If you find this dataset useful, please cite the following paper: 

Carollo, Nicholas A. 2024. "Historical Data on Occupational Regulation in the United States." *Working paper* (revised March 2024).  

### Data setup

The original policy data collected for this project can be found in `./Data/Policies.` These spreadsheets contain notes on sources and coding decisions that users may wish to review prior to working with the data. 

The file `./Programs/setup.do` sets up the policy data in Stata format and also builds a balanced state-occupation panel from 1870 to 2020. Certain variables, including the classification of policies as licensing, certification, or registration requirements are derived from practice and title restrictions recorded in `./Data/Policies.` These derived variables do not appear in the underlying Excel spreadsheets. 
 
### Revisions and potential errors

The data posted on this page are subject to revision. If you believe you have found an error in the data, please open an issue with the title "Potential error in data for [occupation]." In the body of the issue, describe which state(s) have errors for the occupation, the variable(s) are incorrect, and the correction that should be considered. Please provide supporting documentation, ideally from primary legal sources. 

### Disclaimer

**This data is provided for research purposes only. Users interested in regulatory requirements for legal purposes should consult their state's statutes and regulations directly.**
