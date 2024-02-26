#'#*******************************************************************************************************************
#'@author : Amael DUPAIX
#'@update : 2023-10-27
#'@email : 
#'#*******************************************************************************************************************
#'@description :  Merge FOB and phase angle data and perform analysis
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

p <- ggplot(data, aes(x=NFob,
                 y=PA,
                 color=Code.FAO))+
  facet_wrap(~Fishing_mode)+
  geom_errorbar(aes(ymin = PA - PA_se,
                    ymax = PA + PA_se))+
  geom_errorbarh(aes(xmin = NFob - se_NFob,
                     xmax = NFob + se_NFob))+
  geom_point()+
  scale_color_brewer("Species",
                     palette = "Set1")+
  xlab("FOB density (number of FOBs per 2° cell)")+
  ylab("Phase angle (°)")

ggsave(file.path(OUTPUT_PATH, "PA_vs_density.png"),
       p, width = 10, height = 6)

p2 <- ggplot(data %>% dplyr::filter(Fishing_mode == "FAD"),
            aes(x=NFob,
                y=PA,
                color=Code.FAO))+
  facet_wrap(~Code.FAO,
             ncol = 1)+
  geom_errorbar(aes(ymin = PA - PA_se,
                    ymax = PA + PA_se))+
  geom_errorbarh(aes(xmin = NFob - se_NFob,
                     xmax = NFob + se_NFob))+
  geom_point()+
  scale_color_brewer("Species",
                     palette = "Set1")+
  xlab("FOB density (number of FOBs per 2° cell)")+
  ylab("Phase angle (°)")

ggsave(file.path(OUTPUT_PATH, "PA_vs_density_DFAD.png"),
       p2, width = 8, height = 10)


#'**************************************************

data_per_fish <- read.csv2(BIA_fish_file)

data_per_fish %>%
  dplyr::mutate(Date = as.Date(Date)) %>%
  dplyr::mutate(x = floor(longitude_dec/RESOLUTION)*RESOLUTION + RESOLUTION/2,
                y = floor(latitude_dec/RESOLUTION)*RESOLUTION + RESOLUTION/2,
                year = lubridate::year(Date),
                timescale = lubridate::month(Date)) -> data_per_fish

if (TIMESCALE == "quarter"){
  data_per_fish$timescale <- ceiling(data_per_fish$timescale/3)
}

merge(data_per_fish, FOB_data,
      by = c("x","y","year","timescale"),
      all.x = T, all.y = F) -> data_per_fish


data_per_fish %>%
  # count the number of samples per set
  plyr::ddply(c("set_id", "Code.FAO"), function(x) nrow(x)) %>%
  dplyr::rename("sample_size" = "V1") %>%
  dplyr::right_join(data_per_fish, by = c("set_id", "Code.FAO")) %>%
  # and filter the sets with too few samples (<10)
  dplyr::filter(sample_size >=10,
                Fishing_mode == "FAD") %>%
  ggplot()+
  geom_boxplot(aes(x = NFob, y = phase_angle_deg,
                   group = NFob, color = Code.FAO),
               width = 5)+
  facet_wrap(~Code.FAO, ncol = 1)+
  scale_color_brewer("Species",
                     palette = "Set1")+
  xlab("FOB density (number of FOBs per 2° cell)")+
  ylab("Phase angle (°)") -> p3

ggsave(file.path(OUTPUT_PATH, "boxplot_PA_vs_density_DFAD.png"),
       p3, width = 8, height = 10)
