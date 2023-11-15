#'#*******************************************************************************************************************
#'@author : Amael DUPAIX
#'@update : 2023-02-03
#'@email : 
#'#*******************************************************************************************************************
#'@description :  This is the main script to generate the table of NFob number for ABBI calculation, from IOTC buoys
#'                data
#'#*******************************************************************************************************************
#'@revisions
#'
#'#*******************************************************************************************************************

cat('\14')
cat(crayon::bold("2. Calculation of the Phase Angle and analysis\n"))
cat(crayon::bold("----------------------------------------------\n"))

WD <- file.path(STUDY_DIR, "2-BIA_analysis")
OUTPUT_PATH <- file.path(MAIN_OUTPUT_PATH, "2-BIA_analysis_Outputs")
dir.create(OUTPUT_PATH, showWarnings = F)
ROUT_PATH <- file.path(WD, "Routines")
FUNC_PATH <- file.path(WD, "Functions")

#' Arguments:
#' **********
#' 
#' specified in ../main.R
#' 
# Should not modify, as ABBI runs at 10 degrees resolution
# RESOLUTION <- 10

#' For the Observers data. Should be 2020:2021
# YEARS = 2020:2021

#' Whether to delete outputs to calculate all anew
reset <- RESET[2]

#' 0. rune the initialization script
cat('   2.0 - Initializing\n')
source(file.path(ROUT_PATH, "0.init.R"))


#' 1. Calculate mean phase angle per set
cat('\n   2.1 - Calculating phase angle\n')
source(file.path(ROUT_PATH, "1.calculate_phase_angle.R"))

#' 1. Calculate mean phase angle per set
cat('\n   2.2 - Merge and analyze phase angle\n')
source(file.path(ROUT_PATH, "2.merge_and_analyze_phase_angle.R"))
