#'#*******************************************************************************************************************
#'@author : Amael DUPAIX
#'@update : 2023-10-27
#'@email : 
#'#*******************************************************************************************************************
#'@description :  Merge FOB, phase angle and enviro data and perform analysis
#'#*******************************************************************************************************************
#'@revisions
#'
#'#*******************************************************************************************************************

#' ********************
#' Merge data frames
#' ********************

FOB_data <- read.csv2(FOB_number_main_output_file)
BIA_data <- read.csv2(BIA_fish_file)
Enviro_data <- read.csv2(BIA_with_chla_SST_file)

BIA_data %>%
  dplyr::mutate(Date = as.Date(Date))%>%
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

merge(data, Enviro_data,
      all.x = T, all.y = F) -> data

write.csv2(data,
           MAIN_merged_file,
           row.names = F)
data <- read.csv2(MAIN_merged_file)

#' ***************
#' Build plots
#' ***************

data %>%
  dplyr::filter(!is.na(Sample_size),
                !Code.FAO == "BET") -> data


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
  ylab("Phase angle (°)")+
  ggtitle("DFAD sets only")+
  theme(plot.title = element_text(hjust = 0.5))

ggsave(file.path(OUTPUT_PATH, "PA_vs_density_DFAD.png"),
       p2, width = 8, height = 10)


ggplot(data)+
  geom_boxplot(aes(x = NFob, y = phase_angle_deg,
                   group = NFob, color = paste(Code.FAO,Fishing_mode)),
               width = 5)+
  facet_wrap(~Code.FAO, ncol = 1)+
  scale_y_continuous(limits = c(0,NA))+
  scale_color_brewer("Species",
                     palette = "Set1")+
  xlab("FOB density (number of FOBs per 2° cell)")+
  ylab("Phase angle (°)") -> p3

ggsave(file.path(OUTPUT_PATH, "boxplot_PA_vs_density_DFAD.png"),
       p3, width = 8, height = 10)

#' ***************
#' Build GAMM
#' ***************

#' kept variables: chla
#'                 quarter (visible variations when plotting PA per set vs month)
#'                 NFob (@todo: tests with NFad)
#'                 sst removed (strong correlation with chla)
#'                 set_id as a random effect

data %>%
  dplyr::mutate(Date = as.Date(Date)) %>%
  dplyr::mutate(quarter = as.factor(lubridate::quarter(Date)),
                set_id = as.factor(set_id)) %>%
  dplyr::filter(!is.na(NFob)) -> data

data %>% dplyr::filter(Code.FAO == "YFT") -> data_yft

# gamm_yft <- mgcv::gamm(phase_angle_deg ~ s(NFob) + s(chla) + quarter,
#                        random = list(set_id=~1),
#                        data = data_yft)
# 
# gam_yft <- mgcv::gam(phase_angle_deg ~ s(NFob) + s(chla) + s(Length) + quarter + s(set_id, bs = "re"),
#                      data = data_yft)

glm_yft <- glm(phase_angle_deg ~ NFob + chla + Length + quarter, data = data_yft)

summary(glm_yft)

data_yft2 <- data_yft[-c(184,192,214),]

glm_yft2 <- glm(phase_angle_deg ~ NFob + chla + Length + quarter, data = data_yft2)

data %>% dplyr::filter(Code.FAO == "SKJ") -> data_skj

# gamm_skj <- mgcv::gamm(phase_angle_deg ~ s(NFob) + s(chla) + quarter,
#                        random = list(set_id=~1),
#                        data = data_skj)
# 
# gam_skj <- mgcv::gam(phase_angle_deg ~ s(NFob) + s(chla) + quarter + s(set_id, bs = "re"),
#                      data = data_skj)

glm_skj <- glm(phase_angle_deg ~ NFob + chla + quarter, data = data_skj)

saveRDS(list(glm_yft2, glm_skj),
        file = file.path(OUTPUT_PATH, "glms.rds"))
