#'#*******************************************************************************************************************
#'@author : Amael DUPAIX
#'@update : 2023-02-03
#'@email : 
#'#*******************************************************************************************************************
#'@description :  Script to merge the 2 first outputs and calculate the number of FOBs
#'                in RESOLUTION x RESOLUTION degree cells
#'#*******************************************************************************************************************
#'@revisions : 
#'
#'#*******************************************************************************************************************


NFad_df <- read.csv2(file.path(OUTPUT_PATH1, nfad_file_name))
Ratio_df <- read.csv2(file.path(OUTPUT_PATH2, ratio_file_name))

main_df <- merge(NFad_df, Ratio_df)

main_df %>% dplyr::mutate(NLog = NFad * Log_over_Fad,
                          se_NLog = se_NFad * Log_over_Fad,
                          NFob = NFad * (1 + Log_over_Fad),
                          se_NFob = se_NFad * (1 + Log_over_Fad)) %>%
  dplyr::select(-ndays) %>%
  dplyr::select(year, timescale, x, y, NFad, se_NFad, Log_over_Fad, NLog, se_NLog, NFob, se_NFob) %>%
  dplyr::arrange(year, timescale, x, y)-> main_df

write.csv2(main_df, FOB_number_main_output_file, row.names = F)

toKeep <- c(toKeep, "FOB_number_main_output_file")

rm(list = ls()[!ls() %in% toKeep])
