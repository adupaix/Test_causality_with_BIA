#'#*******************************************************************************************************************
#'@author : Amael DUPAIX
#'@update : 2023-02-03
#'@email : 
#'#*******************************************************************************************************************
#'@description :  Script to calculate the ratio LOG/FAD from Ob7 data. A global ratio for both
#'                log types (NLOG and ALOG) is calculated
#'#*******************************************************************************************************************
#'@revisions
#'
#'#*******************************************************************************************************************
#' This ratio will be used to determine the number of LOG (NLOG + ALOG) as follow:
#' NLog = NFad * Log_over_Fad
#'                        NFad: obtained from IOTC data
#'                        Log_over_Fad: obtained above


OUTPUT_PATH2 <- file.path(OUTPUT_PATH, "2.LOG_over_FAD_from_Ob7")
try(dir.create(OUTPUT_PATH2, recursive = T, showWarnings = F))

Ob7<-read.csv(OBSERVERS_FOBFILE, header=T, sep=",")
Ob7 <- prep.obs(Ob7)

ttob7 <- read.csv(OBSERVERS_ACTIVITYFILE, header = T, sep = ",")

ratio <- list()


for (i in 1:length(YEARS)){
  year.i <- YEARS[i]
# get the multiplication factor (FAD + NLOG)/NLOG
  r = ratio.log.fad(Ob7, ttob7, year = year.i, log.type = "LOG", gsize = RESOLUTION,
                    Ob7_preped = T)

  ratio[[i]] <- as.data.frame(r, xy = T) %>%
    dplyr::mutate(year = year.i)

}

df <- bind_rows(ratio) %>%
  dplyr::filter(!is.na(ratio)) %>%
  dplyr::rename("Log_over_Fad" = "ratio") -> df

ratio_file_name <- paste0("LOG_over_FAD_",
                          paste0("res", RESOLUTION, "_"),
                          paste(YEARS[1],YEARS[length(YEARS)], sep = "-"),
                          ".csv")

write.csv2(df, file.path(OUTPUT_PATH2, ratio_file_name),
          row.names = F)




toKeepInOne <- c(toKeepInOne, "OUTPUT_PATH2", "ratio_file_name")

rm(list = ls()[!ls() %in% toKeepInOne])

