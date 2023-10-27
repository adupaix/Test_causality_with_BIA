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
source(file.path(FUNC_PATH,'1.nDaysPerMonth.R'))
source(file.path(FUNC_PATH,'2.PrepObs.R'))
source(file.path(FUNC_PATH, "2.RatioLogOverFad.R"))

FOB_number_main_output_file <- file.path(OUTPUT_PATH,
                                         "MAIN-NFob_from_IOTC.csv")

#' Save the objects to keep between routines
toKeepInOne <- c("toKeep",
                 "toKeepInOne",
                 ls())
toKeep <- c(toKeep, "FOB_number_main_output_file")

if (reset){
  unlink(OUTPUT_PATH,
         recursive = T,
         force = T)
}

#' Save a log file
t <- format(Sys.time(), ("%Y-%m-%d_%H:%M:%S"))
log_file_name <- paste0("Summary_NFob_from_IOTC_data_",t, ".txt")
text_title <- paste0("Calculation of NFob\n=======================\n",t,"\n")
text_arguments <- paste0("Arguments:\n----------",
                    "\nRESOLUTION: ", RESOLUTION,
                    "\nYEARS: ", paste(YEARS, collapse = ","),
                    "\nRESET: ", reset)
text_data <- paste0("Datasets used:\n-------------",
               "\nIOTC_3BU_FILE: ", basename(IOTC_3BU_FILE),
               "\nIOTC_CELLREF_FILE: ", basename(IOTC_CELLREF_FILE),
               "\nOBSERVERS_FOBFILE: ", basename(OBSERVERS_FOBFILE),
               "\nOBSERVERS_ACTIVITYFILE: ", basename(OBSERVERS_ACTIVITYFILE))
text_output <- paste0("Outputs saved in: ", OUTPUT_PATH)

try(dir.create(OUTPUT_PATH, recursive = T, showWarnings = F))

sink(file = file.path(OUTPUT_PATH, log_file_name))
cat(paste(text_title,
          text_arguments,
          text_data,
          text_output,
          sep = "\n\n"))
sink()

rm(list = ls()[!ls() %in% toKeepInOne])
