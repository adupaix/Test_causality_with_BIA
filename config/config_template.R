#'#*******************************************************************************************************************
#'@author : Amael DUPAIX
#'@update : 2023-03-24
#'@email : amael.dupaix@ird.fr
#'#*******************************************************************************************************************
#'@description :  
#'#*******************************************************************************************************************
#'@revision
#'#*******************************************************************************************************************


#' generate basic paths
DATA_PATH <- file.path(STUDY_DIR,'0-Data') #should not change
FUNC_PATH <- file.path(STUDY_DIR, "0-Functions") #should not change

#' Main output directory
#' ********************
MAIN_OUTPUT_PATH <- file.path(STUDY_DIR, "Outputs")

#' Arguments
#' **********
#' @MAIN 
#' 
#' resolution of the grid used for the FOB number estimation
RESOLUTION <- 2

#' Years to perform the study on (based on the dates of the BIA measurments)
YEARS <- 2021:2023

#' Temporal resolution (either month or quarter)
TIMESCALE <- "month"

#' Reset output ?
#' Each element of RESET vector chooses for the corresponding Sud-directory
RESET <- rep(F, 2)

#' Execute the different sub-routines ?
#' If F, the corresponding RESET argument is ignored
CALCULATE_FOB_NUMBER            <- T # sub-directory 1
ANALYZE_BIA                     <- T # sub-directory 2


#' @sub_directory_1: FOB numbers 
#' Buoys data files from IOTC:
#' buoys data from https://iotc.org/WGFAD/03/Data/04-BU (or equivalent)
IOTC_3BU_FILE <- "full_path/to/IOTC/3BU_file.csv"
#' GRID1x1 sheet from the xls file from https://iotc.org/WGFAD/03/Data/00-CWP (or equivalent)
IOTC_CELLREF_FILE <- "full_path/to/IOTC/CELLREF_file.csv"

#' Observers data from Ob7. Two files are needed:
#' One containing all the operations on floating objects
OBSERVERS_FOBFILE <- "full_path/to/Ob7/fob_operations_file.csv"
#' One containing all the vessel activities (operations on FOBs, but also sets, etc.)
OBSERVERS_ACTIVITYFILE <- "full_path/to/Ob7/all_activities_file.csv"

#' @sub_directory_2: BIA values
#' Bioelectrical Impedance Analysis data from MANFAD project
BIA_FILE <- "full_path/to/BIA_measurments.csv"
