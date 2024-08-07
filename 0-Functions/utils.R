#'#*******************************************************************************************************************
#'@author : Amael DUPAIX
#'@update : 2023-03-30
#'@email : 
#'#*******************************************************************************************************************
#'@description :  Small functions used in several directories
#'#*******************************************************************************************************************
#'@revisions
#'
#'#*******************************************************************************************************************

get.ref.cells <- function(res){
  rbind(expand.grid(x = seq(50 + res/2,70 - res/2,res),
                    y = seq(0 + res/2,10 - res/2,res)),
        expand.grid(x = seq(40 + res/2,70 - res/2,res),
                    y = seq(-10+ res/2,0 - res/2,res))) %>%
    dplyr::mutate(zone = seq(1, length(x))) -> ref_zone
  return(ref_zone)
}

