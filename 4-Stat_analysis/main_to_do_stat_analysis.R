#'#*******************************************************************************************************************
#'@author : Amael DUPAIX
#'@update : 2023-02-03
#'@email : 
#'#*******************************************************************************************************************
#'@description :  This is the main script to extract environmental variables values
#'#*******************************************************************************************************************
#'@revisions
#'
#'#*******************************************************************************************************************

cat('\14')
cat(crayon::bold("4. Performing statistical analysis of phase angle\n"))
cat(crayon::bold("----------------------------------------------\n"))

WD <- file.path(STUDY_DIR, "4-Stat_analysis")
OUTPUT_PATH <- file.path(MAIN_OUTPUT_PATH, "4-Stat_analysis_Outputs")
dir.create(OUTPUT_PATH, showWarnings = F)
ROUT_PATH <- file.path(WD, "Routines")
FUNC_PATH <- file.path(WD, "Functions")

#' Arguments:
#' **********
#' 
#' specified in ../main.R

#' Whether to delete outputs to calculate all anew
reset <- RESET[4]

#' Save the objects to keep between directory
toKeep <- c("toKeep", ls())

if (STAT_ANALYSIS){
  #' 0. run the initialization script
  cat('   4.0 - Initializing\n')
  source(file.path(ROUT_PATH, "0.init.R"))
  
  
  #' 1. Extract chlorophyll values
  cat('\n   4.1 - Merging and performing analysis\n')
  source(file.path(ROUT_PATH, "1.Merge_and_analysis.R"))
  
}

# rm(list = ls()[!ls() %in% toKeep])
