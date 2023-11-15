#'#*******************************************************************************************************************
#'@author : Amael DUPAIX
#'@update : 2023-11-15
#'@email : amael.dupaix@ird.fr
#'#*******************************************************************************************************************
#'@description :  extraction of Chla values at set position and dates
#'#*******************************************************************************************************************
#'@revision
#'#*******************************************************************************************************************

chla_files <- list.files(CHLA_NC_DIR,
                         full.names = T)

BIA_data <- read.csv2(BIA_main_output_file)

new_data <- list()
for (i in 1:length(YEARS)){
  year.i <- YEARS[i]
  chla_file.i <- grep(year.i, chla_files,
                      value = T)
  
  BIA_data.i <- BIA_data %>%
    dplyr::mutate(Date = as.Date(Date)) %>%
    dplyr::filter(lubridate::year(Date) == year.i)
  
  #open the NetCDF file
  nc <- ncdf4::nc_open(chla_file.i)
  
  lon <- ncdf4::ncvar_get(nc, "lon")
  lat <- ncdf4::ncvar_get(nc, "lat")
  time<-ncdf4::ncvar_get(nc, "time")
  
  t_units <- ncdf4::ncatt_get(nc, "time", "units")
  
  # convert time -- split the time units string into fields
  t_ustr <- strsplit(t_units$value, " ")
  t_dstr <- strsplit(unlist(t_ustr)[3], "-")
  t_month <- as.integer(unlist(t_dstr)[2])
  t_day <- as.integer(unlist(t_dstr)[3])
  t_year <- as.integer(unlist(t_dstr)[1])
  mydate<-chron(time,origin=c(t_month, t_day, t_year))
  
  mydate<-as.Date(mydate,'%m/%d/%Y')
  
  lon_indices <- mapply(function(x) which(abs(lon - x) == min(abs(lon - x))),
    BIA_data.i$longitude_dec)
  lat_indices <- mapply(function(y) which(abs(lat - y) == min(abs(lat - y))),
                        BIA_data.i$latitude_dec)
  date_indices <- mapply(function(t) which(mydate == t),
                        BIA_data.i$Date)
  
  BIA_data.i$chla <- mapply(function(lon_index, lat_index, date_index){
    ncdf4::ncvar_get(nc, "CHL",
                     start = c(lon_index, lat_index, date_index),
                     count = rep(1,3))
  },
  lon_indices, lat_indices, date_indices)
  
  new_data[[i]] <- BIA_data.i
  
  ncdf4::nc_close(nc)
}

new_data <- dplyr::bind_rows(new_data)

write.csv2(new_data,
           BIA_with_chla_file,
           row.names = F)

