#'#*******************************************************************************************************************
#'@author : Amael DUPAIX
#'@update : 2023-02-03
#'@email : 
#'#*******************************************************************************************************************
#'@description :  Script to get the quarterly mean number of FADs from IOTC data
#'                in RESOLUTION x RESOLUTION degree cells
#'#*******************************************************************************************************************
#'@revisions : Check if SD calculation can be improved with IOTC data
#'
#'#*******************************************************************************************************************


OUTPUT_PATH1 <- file.path(OUTPUT_PATH, paste("1.NFad_from_IOTC"))
try(dir.create(OUTPUT_PATH1, recursive = T, showWarnings = F))

# buoys data from https://iotc.org/WGFAD/03/Data/04-BU
n_buoys <- read.csv(IOTC_3BU_FILE,
                    sep = ";",
                    stringsAsFactors = F)
# GRID1x1 sheet from the xls file from https://iotc.org/WGFAD/03/Data/00-CWP
ref_cells <- read.csv(IOTC_CELLREF_FILE,
                      sep = ";",
                      stringsAsFactors = F)

data <- merge(n_buoys, ref_cells, by = "FISHING_GROUND_CODE")
data <- data.frame(apply(data, 2, function(chr) sub(pattern = ",", replacement = ".", x = chr)))
data <- data.frame(apply(data, 2, function(fct) as.numeric(as.character(fct))))

## save the id of the ground cells which are missing in the data
dir.create(file.path(OUTPUT_PATH, "missing_ground_codes"), showWarnings = F)
n_buoys[!n_buoys$FISHING_GROUND_CODE %in% data$FISHING_GROUND_CODE,"FISHING_GROUND_CODE"] -> ground_codes_not_in_ref
write.csv2(as.data.frame(ground_codes_not_in_ref), file = file.path(OUTPUT_PATH, "missing_ground_codes", "missing_FISHING_GROUND_CODE_in_ref_file.csv"),
           row.names = F)
# also save the data for which the ground codes are not referenced
n_buoys %>% dplyr::filter(FISHING_GROUND_CODE %in% ground_codes_not_in_ref) -> not_referenced_data
write.csv2(not_referenced_data, file = file.path(OUTPUT_PATH, "missing_ground_codes", "data_with_missing_FISHING_GROUND_CODE_in_ref_file.csv"),
           row.names = F)

rm(ground_codes_not_in_ref, not_referenced_data, n_buoys, ref_cells)

##
data %>% dplyr::mutate(degraded_lat = floor(CENTER_LAT/RESOLUTION)*RESOLUTION + RESOLUTION/2,
                       degraded_lon = floor(CENTER_LON/RESOLUTION)*RESOLUTION + RESOLUTION/2,
                       id_unique = paste(YEAR, MONTH, degraded_lat, degraded_lon, sep = "_")) -> data

## degrade the resolution (and sum the number of buoys per cell)
data <- plyr::ddply(data, .variables = c("YEAR", "MONTH",
                                         "degraded_lon", "degraded_lat", "id_unique"),
                    .fun = function(x){
                      x %>% dplyr::select(-FISHING_GROUND_CODE, -YEAR, -MONTH,
                                   -degraded_lat, -degraded_lon, -id_unique,
                                   -CENTER_LON, -CENTER_LAT) -> x
                      
                      return(apply(x, MARGIN = 2, sum, na.rm = T))
            })

write.csv2(data, file = file.path(OUTPUT_PATH1, "Intermediate_NFad_dataframe.csv"), row.names = F)

data <- read.csv2(file = file.path(OUTPUT_PATH1, "Intermediate_NFad_dataframe.csv"))

## Calculate SD for each month
#' @see if we can get the sd from the secretariat
#'      else, for now we calculate the SD with the upper quartile and the lower one
#'      then take the mean of the 2 (sd_NFad)

data %>% dplyr::mutate(sd_NFad_LQ = (N_BUOYS_MEDIAN - N_BUOYS_LQ) / 0.675,
                       sd_NFad_UQ = (N_BUOYS_UQ - N_BUOYS_MEDIAN) / 0.675,
                       sd_NFad = (sd_NFad_LQ + sd_NFad_UQ)/2,
                       ndays = mapply(nDaysPerMonth, MONTH, YEAR),
                       se_NFad = sd_NFad / sqrt(ndays)) -> data


# average by resolution
data %>% 
  plyr::ddply(.variables = c("YEAR","MONTH","degraded_lon","degraded_lat"),
              function(x){
                y <- data.frame(NFad = sum(x$N_BUOYS_MEAN, na.rm = T),
                                ndays = unique(x$ndays),
                                se_NFad = sum(x$se_NFad, na.rm = T))
                return(y)
              }) -> data
if (TIMESCALE == "quarter"){
  data %>%
    dplyr::mutate(timescale = ceiling(MONTH/3)) -> data
} else if (TIMESCALE == "month"){
  data %>%
    dplyr::mutate(timescale = MONTH) -> data
}
# average by timescale
data %>%
  plyr::ddply(.variables = c("YEAR", "timescale", "degraded_lon", "degraded_lat"),
              function(x){
                y <- data.frame(NFad = mean(x$NFad, na.rm = T),
                                ndays = sum(x$ndays),
                                se_NFad = mean(x$se_NFad, na.rm = T)
                                #sd_NFad = sqrt(sum(x$sd_NFad**2)))
                                # propagation de l'erreur: SEtot = sqrt(sum(SEm**2))
                                )
                # y$se_NFad = y$sd_NFad / sqrt(y$ndays)
                return(y)
              }) %>%
  dplyr::rename("year" = "YEAR",
                "x" = "degraded_lon",
                "y" = "degraded_lat") -> data

nfad_file_name <- "NFad_table.csv"

write.csv2(data, file = file.path(OUTPUT_PATH1, nfad_file_name), row.names = F)
