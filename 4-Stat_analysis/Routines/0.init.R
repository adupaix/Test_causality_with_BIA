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

main_outputs <- c(FOB_number_main_output_file,
                  BIA_fish_file,
                  BIA_with_chla_SST_file)

MAIN_merged_file <- file.path(OUTPUT_PATH,
                              "MAIN-merged_data_frame.csv")

source(file.path(FUNC_PATH, "build_and_compare_models.R"))

#' Save a log file
t <- format(Sys.time(), ("%Y-%m-%d_%H:%M:%S"))
log_file_name <- paste0("Summary_stat_analysis_",t, ".txt")
text_title <- paste0("Statistical analysis of PA\n============================\n",t,"\n")
text_arguments <- paste0("Arguments:\n----------",
                    "\nYEARS: ", paste(YEARS, collapse = ","),
                    "\nRESET: ", reset)
text_data <- paste0("Previous outputs used:\n-------------",
                    paste(file.path(basename(dirname(main_outputs)),
                                          basename(main_outputs)),
                          collapse = "\n"))
text_output <- paste0("Outputs saved in: ", OUTPUT_PATH)

try(dir.create(OUTPUT_PATH, recursive = T, showWarnings = F))

sink(file = file.path(OUTPUT_PATH, log_file_name))
cat(paste(text_title,
          text_arguments,
          text_data,
          text_output,
          sep = "\n\n"))
sink()