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
cat(crayon::bold("2. Getting values of environmental variables\n"))
cat(crayon::bold("----------------------------------------------\n"))

WD <- file.path(STUDY_DIR, "3-Get_enviro")
OUTPUT_PATH <- file.path(MAIN_OUTPUT_PATH, "3-Get_enviro_Outputs")
dir.create(OUTPUT_PATH, showWarnings = F)
ROUT_PATH <- file.path(WD, "Routines")
FUNC_PATH <- file.path(WD, "Functions")

#' Arguments:
#' **********
#' 
#' specified in ../main.R

#' Whether to delete outputs to calculate all anew
reset <- RESET[3]

###Output names
BIA_with_chla_file <- file.path(OUTPUT_PATH,
                                "Phase_angle_per_set_with_chla.csv")
BIA_with_chla_SST_file <- file.path(OUTPUT_PATH,
                                    "Phase_angle_per_set_with_chla_SST.csv")

#' Save the objects to keep between directory
toKeep <- c("toKeep", ls())

if (GET_ENVIRO){
  #' 0. run the initialization script
  cat('   3.0 - Initializing\n')
  source(file.path(ROUT_PATH, "0.init.R"))
  
  
  #' 1. Extract chlorophyll values
  cat('\n   3.1 - Getting chlorophyll values\n')
  source(file.path(ROUT_PATH, "1.Chla.R"))
  
  #' 1. Extract SST values
  cat('\n   3.2 - Getting SST values\n')
  source(file.path(ROUT_PATH, "2.SST.R"))
  
}

rm(list = ls()[!ls() %in% toKeep])