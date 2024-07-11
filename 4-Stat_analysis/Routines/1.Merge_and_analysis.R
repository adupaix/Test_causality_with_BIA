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

ggplot(data %>% dplyr::filter(Fishing_mode == "FAD"))+
  geom_boxplot(aes(x = NFob, y = phase_angle_deg,
                   group = NFob, color = Code.FAO),
               width = 5)+
  facet_wrap(~Code.FAO, ncol = 1)+
  scale_y_continuous(limits = c(0,NA))+
  scale_color_brewer("Species",
                     palette = "Set1",
                     direction = -1)+
  xlab("FOB density (number of FOBs per 2° cell)")+
  ylab("Phase angle (°)") -> p4

ggsave(file.path(OUTPUT_PATH, "boxplot_PA_vs_density.png"),
       p3, width = 6, height = 8)
ggsave(file.path(OUTPUT_PATH, "boxplot_PA_vs_density_DFAD.png"),
       p4, width = 6, height = 8)

#' ***************
#' Spearman + models
#' ***************

#' kept variables: chla
#'                 quarter (visible variations when plotting PA per set vs month)
#'                 NFob (@todo: tests with NFad)
#'                 sst removed (strong correlation with chla)

dir.create(file.path(OUTPUT_PATH,
                       "skj"),
             recursive = T,
             showWarnings = F)
dir.create(file.path(OUTPUT_PATH,
                     "yft"),
           recursive = T,
           showWarnings = F)



data %>%
  dplyr::mutate(Date = as.Date(Date)) %>%
  dplyr::mutate(quarter = as.factor(lubridate::quarter(Date)),
                set_id = as.factor(set_id)) %>%
  dplyr::filter(!is.na(NFob),
                Fishing_mode == "FAD") %>%
  dplyr::mutate(NFob_s = as.numeric(scale(NFob, center = F)),
                chla_s = as.numeric(scale(chla, center = F)),
                Length_s = scale(Length, center = F))-> data

data %>% dplyr::filter(Code.FAO == "YFT") -> data_yft
data %>% dplyr::filter(Code.FAO == "SKJ") -> data_skj
data_yft %>%
  dplyr::filter(phase_angle_deg < 40) -> data_yft_nooutliers
data_skj %>%
  dplyr::filter(phase_angle_deg < 40) -> data_skj_nooutliers

ggplot(data_yft)+
  geom_boxplot(aes(x = NFob, y = phase_angle_deg,
                   group = NFob),
               color = "red",
               width = 5, outlier.color = "red",
               outlier.alpha = 0.5)+
  scale_y_continuous(limits = c(0,NA))+
  xlab("FOB density (number of FOBs per 2° cell)")+
  ylab("Phase angle (°)")+
  theme(panel.background = element_rect(fill = "white",
                                        color = "black"),
        panel.grid = element_line(linetype = "dashed",
                                  linewidth = 0.5,
                                  color = "grey")) -> boxplot_yft

ggsave(file.path(OUTPUT_PATH, "boxplot_PA_vs_density_yft.png"),
       boxplot_yft, width = 6, height = 6)

# Spearman correlation tests
sink(file.path(OUTPUT_PATH, "yft", "spearman.txt"))
print(cor.test(data_yft$phase_angle_deg,
               data_yft$NFob,
               method = "spearman"))
sink()
sink(file.path(OUTPUT_PATH, "yft_nooutliers", "spearman.txt"))
print(cor.test(data_yft_nooutliers$phase_angle_deg,
               data_yft_nooutliers$NFob,
               method = "spearman"))
sink()

sink(file.path(OUTPUT_PATH, "skj", "spearman.txt"))
print(cor.test(data_skj$phase_angle_deg,
               data_skj$NFob,
               method = "spearman"))
sink()
sink(file.path(OUTPUT_PATH, "skj_nooutliers", "spearman.txt"))
print(cor.test(data_skj_nooutliers$phase_angle_deg,
               data_skj_nooutliers$NFob,
               method = "spearman"))
sink()

# Build all models for YFT and SKJ
#      with whole datasets and removing outliers (with PA values above 40)
build.and.compare.models(data_yft, dir = "yft",
                         output_path = OUTPUT_PATH)
build.and.compare.models(data_yft %>%
                           dplyr::filter(phase_angle_deg < 40),
                         dir = "yft_nooutliers",
                         output_path = OUTPUT_PATH)

build.and.compare.models(data_skj, dir = "skj",
                         output_path = OUTPUT_PATH)
build.and.compare.models(data_skj %>%
                           dplyr::filter(phase_angle_deg < 40),
                         dir = "skj_nooutliers",
                         output_path = OUTPUT_PATH)
