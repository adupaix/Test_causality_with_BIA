#'#*******************************************************************************************************************
#'@author : Amael DUPAIX
#'@update : 2023-10-27
#'@email : amael.dupaix@ird.fr
#'#*******************************************************************************************************************
#'@description :  
#'#*******************************************************************************************************************
#'@revision
#'#*******************************************************************************************************************

#' Load libraries and utils functions
#' ***********************************
source(file.path(FUNC_PATH, "utils.R")) 
source(file.path(FUNC_PATH, "install_libraries.R"))

srcUsedPackages <- c("plyr", "dplyr", "raster", "crayon",
                     "ncdf4", "chron", "lubridate",
                     "ggplot2", "ggpubr", "sf", "spdep",
                     # "tictoc", "lattice", "readr", "ade4",
                     # "itsadug",
                     "mgcv", "gratia", "MASS", "caret",
                     "minpack.lm")

installAndLoad_packages(srcUsedPackages, loadPackages = TRUE)

#' Create output folder and file paths
#' ***********************************
MAIN_OUTPUT_PATH <- file.path(MAIN_OUTPUT_PATH,
                              paste0("res-",RESOLUTION,"_",TIMESCALE))
dir.create(MAIN_OUTPUT_PATH, recursive = T, showWarnings = F)

toKeep <- c("toKeep", ls())

#' Get FOB number
#' ***************
source(file.path(STUDY_DIR, "1-Get_FOB_number/main_to_get_fob_number.R"))


#' Get phase angle values
#' ********************
source(file.path(STUDY_DIR, "2-Get_BIA/main_to_get_BIA.R"))


#' Get environmental variables values
#' ***********************************
source(file.path(STUDY_DIR, "3-Get_enviro/main_to_get_enviro.R"))

#' Perform statistical analysis
#' ******************************
source(file.path(STUDY_DIR, "4-Stat_analysis/main_to_do_stat_analysis.R"))

