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
cat(crayon::bold("2. Calculation of the Phase Angle\n"))
cat(crayon::bold("----------------------------------------------\n"))

WD <- file.path(STUDY_DIR, "2-Get_BIA")
OUTPUT_PATH <- file.path(MAIN_OUTPUT_PATH, "2-Get_BIA_Outputs")
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

###FONCTIONS NECESSAIRES
source(file.path(FUNC_PATH,'avdth_position_conversion.R'))

### Output names
BIA_fish_file <- file.path(OUTPUT_PATH,
                           "Phase_angle_per_fish.csv")
BIA_main_output_file <- file.path(OUTPUT_PATH,
                                  "MAIN-Phase_angle_per_set.csv")
# MAIN_merged_file <- file.path(MAIN_OUTPUT_PATH,
#                               "Phase_angle_with_NFob.csv")

#' Save the objects to keep between sub-directory
toKeep <- c("toKeep", ls())


if (GET_BIA){
#' 0. run the initialization script
  cat('   2.0 - Initializing\n')
  source(file.path(ROUT_PATH, "0.init.R"))


  #' 1. Calculate mean phase angle per set
  cat('\n   2.1 - Calculating phase angle\n')
  source(file.path(ROUT_PATH, "1.calculate_phase_angle.R"))
}


rm(list = ls()[!ls() %in% toKeep])