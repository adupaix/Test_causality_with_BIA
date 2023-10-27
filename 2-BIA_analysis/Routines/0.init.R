#'#*******************************************************************************************************************
#'@author : Amael DUPAIX
#'@update : 2023-02-03
#'@email : 
#'#*******************************************************************************************************************
#'@description :  Initialization script
#'                       Load required packages
#'                       Load need functions
#'                       Save the names of the objects toKeep
#'                       Save a log file
#'                       
#'#*******************************************************************************************************************
#'@revisions : 
#'
#'#*******************************************************************************************************************

###FONCTIONS NECESSAIRES
source(file.path(FUNC_PATH,'avdth_position_conversion.R'))

BIA_main_output_file <- file.path(OUTPUT_PATH,
                                  "MAIN-Phase_angle_per_set.csv")
MAIN_merged_file <- file.path(MAIN_OUTPUT_PATH,
                              "Phase_angle_with_NFob.csv")

#' Save the objects to keep between routines
toKeepInTwo <- c("toKeep",
                 "toKeepInTwo",
                 ls())

if (reset){
  unlink(OUTPUT_PATH,
         recursive = T,
         force = T)
}

#' Save a log file
t <- format(Sys.time(), ("%Y-%m-%d_%H:%M:%S"))
log_file_name <- paste0("Summary_BIA_",t, ".txt")
text_title <- paste0("Calculation of phase angle\n============================\n",t,"\n")
text_arguments <- paste0("Arguments:\n----------",
                    "\nYEARS: ", paste(YEARS, collapse = ","),
                    "\nRESET: ", reset)
text_data <- paste0("Datasets used:\n-------------",
               "\nBIA_FILE: ", basename(BIA_FILE))
text_output <- paste0("Outputs saved in: ", OUTPUT_PATH)

try(dir.create(OUTPUT_PATH, recursive = T, showWarnings = F))

sink(file = file.path(OUTPUT_PATH, log_file_name))
cat(paste(text_title,
          text_arguments,
          text_data,
          text_output,
          sep = "\n\n"))
sink()

rm(list = ls()[!ls() %in% toKeepInTwo])