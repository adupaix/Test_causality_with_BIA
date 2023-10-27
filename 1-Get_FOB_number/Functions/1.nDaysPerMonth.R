#'# Nombre de jour par mois, en fonction de l'annee
#'  (pour prendre en compte les annees bisextiles)
#' Used in routine @1
#' ********************
nDaysPerMonth <- function(month, year){
  if (month %in% c(1,3,5,7,8,10,12)){
    return(31)
  } else if (month %in% c(4,6,9,11)){
    return(30)
  } else if (month == 2){
    if (is.leap(year)){
      return(29)
    } else {
      return(28)
    }
  }
}

is.leap <- function(yr) {
  return((yr %% 4 == 0 & yr %% 100 != 0) | (yr %% 400 == 0))
}