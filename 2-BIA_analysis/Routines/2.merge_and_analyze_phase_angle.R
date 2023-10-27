#'#*******************************************************************************************************************
#'@author : Amael DUPAIX
#'@update : 2023-10-27
#'@email : 
#'#*******************************************************************************************************************
#'@description :  Get FOB density associated with BIA values of sets
#'#*******************************************************************************************************************
#'@revisions
#'
#'#*******************************************************************************************************************

main_outputs <- list.files(MAIN_OUTPUT_PATH,
                           pattern = "MAIN",
                           recursive = T,
                           full.names = T)

FOB_data <- read.csv2(main_outputs[grepl("NFob", main_outputs)])

BIA_data %>%
  dplyr::mutate(x = floor(longitude_dec/RESOLUTION)*RESOLUTION + RESOLUTION/2,
                y = floor(latitude_dec/RESOLUTION)*RESOLUTION + RESOLUTION/2,
                year = lubridate::year(Date),
                timescale = lubridate::month(Date)) -> BIA_data

if (TIMESCALE == "quarter"){
  BIA_data$timescale <- ceiling(BIA_data$timescale/3)
}

merge(BIA_data, FOB_data,
      by = c("x","y","year","timescale"),
      all.x = T, all.y = F) -> data

write.csv2(data,
           MAIN_merged_file,
           row.names = F)

ggplot(data, aes(x=NFob,
                 y=PA,
                 color=Code.FAO))+
  facet_wrap(~Fishing_mode)+
  geom_point()+
  scale_color_brewer("Species",
                     palette = "Set1")
