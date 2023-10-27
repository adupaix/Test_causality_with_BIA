#'#*******************************************************************************************************************
#'@author : Amael DUPAIX
#'@update : 2023-10-27
#'@email : 
#'#*******************************************************************************************************************
#'@description :  Script to calculate the mean phase angle per set from
#'                BIA data of MANFAD project
#'#*******************************************************************************************************************
#'@revisions
#'
#'#*******************************************************************************************************************

data <- read.csv2(BIA_FILE)

# FISHING_MODE = "FAD"

# SPECIES = "SKJ"

# PLOT_CHECK = F

data <- avdth_position_conversion(data,
                                  latitude = "latitude",
                                  longitude = "longitude",
                                  quadrant = "Quadrant")

# missing_positions <- c(longitude = sum(is.na(data$longitude_dec)),
#                        latitude = sum(is.na(data$latitude_dec)))
# cat("Number of missing positions:\n")
# print(missing_positions)

data %>%
  # filter missing positions
  dplyr::filter(!(is.na(longitude_dec)|is.na(latitude_dec))) %>%
  #calculate phase angle
  dplyr::mutate(Reactance = as.numeric(as.character(Reactance)),
                Resistance = as.numeric(as.character(Resistance)),
                phase_angle = atan(Reactance / Resistance),
                phase_angle_deg = phase_angle * 360 / (2 * pi)) %>%
  # put date in Date format
  dplyr::mutate(Date = as.Date(as.character(Date),
                               format = "%d/%m/%Y"),
                set_id = as.factor(paste(format(Date,"%Y%m%d"),
                                         Quadrant,longitude,latitude,
                                         sep = "_"))) -> data

# if (PLOT_CHECK){
#   ggplot(data)+
#     geom_histogram(aes(x=phase_angle_deg,
#                        fill = Code.FAO),
#                    color = "black",
#                    binwidth = 2)+
#     xlab("Phase angle (deg)")+
#     ylab("Number of measurements")
#   
#   ggplot(data)+
#     geom_histogram(aes(x=as.factor(Date),
#                        fill = Code.FAO),
#                    color = "black",
#                    stat = "count")+
#     theme(axis.text.x = element_text(angle = 90,
#                                      hjust=0.5,
#                                      vjust=0.5),
#           plot.title = element_text(hjust = 0.5))+
#     xlab("Sampling date")+
#     ylab("Number of measurements")+
#     ggtitle("Species")
#   
#   ggplot(data)+
#     geom_histogram(aes(x=as.factor(Date),
#                        fill = set_id),
#                    color = "black",
#                    stat = "count")+
#     theme(axis.text.x = element_text(angle = 90,
#                                      hjust=0.5,
#                                      vjust=0.5),
#           legend.position = "none",
#           plot.title = element_text(hjust = 0.5))+
#     xlab("Sampling date")+
#     ylab("Number of measurements")+
#     ggtitle("Set id")
#   
#   outliers <- c(quantile(data$phase_angle_deg, seq(0,1,.025))["2.5%"],
#                 quantile(data$phase_angle_deg, seq(0,1,.025))["97.5%"])
#   
#   ggplot(data)+
#     geom_histogram(aes(x=phase_angle_deg,
#                        fill = Sampler),
#                    color = "black",
#                    binwidth = 2)+
#     scale_fill_brewer(palette = "Set1")+
#     geom_vline(xintercept = outliers)+
#     xlab("Phase angle (deg)")+
#     ylab("Number of measurements")
#   
#   data %>% dplyr::filter(phase_angle_deg <= outliers[1] | phase_angle_deg >= outliers[2]) -> data_outliers
# }

# # Keep only fishing mode and species of interest
# data %>%
#   dplyr::filter(Fishing_mode == FISHING_MODE,
#                 Code.FAO == SPECIES) -> data_species

ddply(data, c("Code.FAO","set_id"),
      function(x) mean(x$phase_angle_deg)) %>%
  dplyr::rename("PA" = "V1") %>%
  dplyr::left_join(
    ddply(data, c("Code.FAO","set_id"),
          function(x) sd(x$phase_angle_deg)/sqrt(nrow(x))),
    by = c("Code.FAO","set_id")) %>%
  dplyr::rename("PA_se" = "V1") %>%
  dplyr::left_join(
    ddply(data, c("Code.FAO","set_id"),
          function(x) nrow(x)),
    by = c("Code.FAO","set_id")) %>%
  dplyr::rename("Sample_size" = "V1") %>%
  dplyr::left_join(data, by = c("Code.FAO","set_id")) %>%
  dplyr::filter(!duplicated(set_id)) %>%
  dplyr::select(set_id:Sample_size, Boat_code:Fishing_mode,
                Code.FAO, longitude_dec, latitude_dec) %>%
  dplyr::filter(Sample_size >= 10) -> BIA_data

write.csv2(BIA_data,
           BIA_main_output_file,
           row.names = F)
