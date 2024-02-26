#'#*******************************************************************************************************************
#'@author : Amael DUPAIX
#'@update : 2023-11-15
#'@email : amael.dupaix@ird.fr
#'#*******************************************************************************************************************
#'@description :  extraction of sst values at set position and dates
#'#*******************************************************************************************************************
#'@revision
#'#*******************************************************************************************************************

BIA_data <- read.csv2(BIA_with_chla_file) %>%
  dplyr::mutate(Date = as.Date(Date))

#open the NetCDF file
nc <- ncdf4::nc_open(SST_NC_FILE)

lon <- ncdf4::ncvar_get(nc, "longitude")
lat <- ncdf4::ncvar_get(nc, "latitude")
time <- ncdf4::ncvar_get(nc, "time")

t_units <- ncdf4::ncatt_get(nc, "time", "units")

# convert time -- split the time units string into fields
t_ustr <- strsplit(t_units$value, " ")
t_dstr <- strsplit(unlist(t_ustr)[3], "-")
t_month <- as.integer(unlist(t_dstr)[2])
t_day <- as.integer(unlist(t_dstr)[3])
t_year <- as.integer(unlist(t_dstr)[1])
t_unit <- unlist(t_ustr)[1]

mydate<-as.Date(paste(t_year, t_month, t_day, sep = "-"))+
  as.difftime(time,units = t_unit)


lon_indices <- mapply(function(x) which(abs(lon - x) == min(abs(lon - x)))[1],
                      BIA_data$longitude_dec)
lat_indices <- mapply(function(y) which(abs(lat - y) == min(abs(lat - y)))[1],
                      BIA_data$latitude_dec)
date_indices <- mapply(function(t) which(abs(mydate - t) == min(abs(mydate - t)))[1],
                       BIA_data$Date)

BIA_data$sst <- mapply(function(lon_index, lat_index, date_index){
  ncdf4::ncvar_get(nc, "to",
                   start = c(lon_index, lat_index, 1, date_index),
                   count = rep(1,4))
},
lon_indices, lat_indices, date_indices)

ncdf4::nc_close(nc)

write.csv2(BIA_data,
           BIA_with_chla_SST_file,
           row.names = F)
