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

if (reset){
  unlink(OUTPUT_PATH,
         recursive = T,
         force = T)
}

#' Save a log file
t <- format(Sys.time(), ("%Y-%m-%d_%H:%M:%S"))
log_file_name <- paste0("Summary_enviro_",t, ".txt")
text_title <- paste0("Extraction of environmental variables\n============================\n",t,"\n")
text_arguments <- paste0("Arguments:\n----------",
                    "\nYEARS: ", paste(YEARS, collapse = ","),
                    "\nRESET: ", reset)
text_data <- paste0("Datasets used:\n-------------",
                    "\nCHLA_NC_DIR: ", basename(CHLA_NC_DIR),
                    "\n   Chla files: ", paste(list.files(CHLA_NC_DIR),
                                             collapse = "\n             "),
                    "\nSST_NC_FILE: ", basename(SST_NC_FILE))
text_output <- paste0("Outputs saved in: ", OUTPUT_PATH)

try(dir.create(OUTPUT_PATH, recursive = T, showWarnings = F))

sink(file = file.path(OUTPUT_PATH, log_file_name))
cat(paste(text_title,
          text_arguments,
          text_data,
          text_output,
          sep = "\n\n"))
sink()