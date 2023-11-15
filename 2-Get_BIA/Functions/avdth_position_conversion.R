#' @name avdth_position_conversion
#' @title AVDTH database position conversion
#' @url: https://github.com/OB7-IRD/furdeb/blob/main/R/avdth_position_conversion.R
#' @description Convert position format in AVDTH to decimal format.
#' @param data {\link[base]{data.frame}} expected. A R data frame.
#' @param latitude {\link[base]{character}} expected. Column name of latitude data.
#' @param longitude {\link[base]{character}} expected. Column name of longitude data.
#' @param quadrant {\link[base]{character}} expected. Column name of quadrant data.
#' @return This function add two column to the input data frame, longitude_dec and latitude_dec, with longitude and latitude data in decimal format.
#' @export
#' @modified 2023/10/12 (Amael Dupaix)
avdth_position_conversion <- function(data,
                                      latitude = "latitude",
                                      longitude = "longitude",
                                      quadrant = "Quadrant") {
  # 1 - Arguments verification ----
  # data argument
  if (missing(x = data)) {
    stop(format(x = Sys.time(),
                "%Y-%m-%d %H:%M:%S"),
         " - Error, missing \"data\" argument.\n")
  }
  # latitude argument
  if (!(is.character(latitude)&length(latitude)==1)) {
    stop(format(x = Sys.time(),
                "%Y-%m-%d %H:%M:%S"),
         " - Error, provided latitude argument not in the right format\n")
  }
  if (! latitude %in% names(x = data)) {
    stop(format(x = Sys.time(),
                "%Y-%m-%d %H:%M:%S"),
         " - Error, column \"",
         latitude,
         "\" not present in the input data.\n")
  }
  # longitude argument
  if (!(is.character(longitude)&length(longitude)==1)) {
    stop(format(x = Sys.time(),
                "%Y-%m-%d %H:%M:%S"),
         " - Error, provided longitude argument not in the right format\n")
  }
  if (! longitude %in% names(x = data)) {
    stop(format(x = Sys.time(),
                "%Y-%m-%d %H:%M:%S"),
         " - Error, column \"",
         longitude,
         "\" not present in the input data.\n")
  }
  # quadrant argument
  if (!(is.character(quadrant)&length(quadrant)==1)) {
    stop(format(x = Sys.time(),
                "%Y-%m-%d %H:%M:%S"),
         " - Error, provided quadrant argument not in the right format\n")
  }
  if (! quadrant %in% names(data)) {
    stop(format(x = Sys.time(),
                "%Y-%m-%d %H:%M:%S"),
         " - Error, column \"",
         quadrant,
         "\" not present in the input data.\n")
  }
  # 2 - Global process ----
  data[, "longitude_dec"] <- ifelse(data[, quadrant] %in% c(1, 2),
                                    trunc(data[, longitude] * (10 ^ -2)) + ((data[, longitude] * (10 ^ -2) - trunc(data[, longitude] * (10 ^ -2))) / 60 * 100),
                                    as.numeric(paste0("-",
                                                      trunc(data[, longitude] * (10 ^ -2)) + ((data[, longitude] * (10 ^ -2) - trunc(data[, longitude] * (10 ^ -2))) / 60 * 100))))
  data[, "latitude_dec"] <- ifelse(data[, quadrant] %in% c(1, 4),
                                   trunc(data[, latitude] * (10 ^ -2)) + ((data[, latitude] * (10 ^ -2) - trunc(data[, latitude] * (10 ^ -2))) / 60 * 100),
                                   as.numeric(paste0("-",
                                                     trunc(data[, latitude] * (10 ^ -2)) + ((data[, latitude] * (10 ^ -2) - trunc(data[, latitude] * (10 ^ -2))) / 60 * 100))))
  
  # put NAs in position when one of quadrant/longitude/latitude is missing
  data[,"latitude_dec"] <- apply(data, 1, function(x) ifelse(
    is.na(x[quadrant])|is.na(x[latitude]),
    NA, as.numeric(x["latitude_dec"])))
  data[,"longitude_dec"] <- apply(data, 1, function(x) ifelse(
    is.na(x[quadrant])|is.na(x[longitude]),
    NA, as.numeric(x["longitude_dec"])))
  
  return(data)
}
