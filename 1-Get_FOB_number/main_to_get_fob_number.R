#'#*******************************************************************************************************************
#'@author : Amael DUPAIX
#'@update : 2023-02-03
#'@email : 
#'#*******************************************************************************************************************
#'@description :  This is the main script to generate the table of NFob number for ABBI calculation, from IOTC buoys
#'                data
#'#*******************************************************************************************************************
#'@revisions
#'
#'#*******************************************************************************************************************

cat('\14')
cat(crayon::bold("1. Calculation of the FOB number from IOTC and Ob7 data\n"))
cat(crayon::bold("-------------------------------------------------------\n"))

WD <- file.path(STUDY_DIR, "1-Get_FOB_number")
OUTPUT_PATH <- file.path(MAIN_OUTPUT_PATH, "1-FOB_number_Outputs")
dir.create(OUTPUT_PATH, showWarnings = F)
ROUT_PATH <- file.path(WD, "Routines")
FUNC_PATH <- file.path(WD, "Functions")

#' Arguments:
#' **********
#' 
#' specified in ../main.R
#' 
# Should not modify, as ABBI runs at 10 degrees resolution
# RESOLUTION <- 10

#' For the Observers data. Should be 2020:2021
# YEARS = 2020:2021

#' Whether to delete outputs to calculate all anew
reset <- RESET[1]

#' 0. rune the initialization script
cat('   1.0 - Initializing\n')
source(file.path(ROUT_PATH, "0.init.R"))


#' 1. Use the IOTC data to have a number of buoys (proxy of the number of DFADs, noted NFad) per cell per quarter
cat('\n   1.1 - Getting FAD number from IOTC datasets\n')
source(file.path(ROUT_PATH, "1.get_fad_number.R"))


#' 2. Use the French observers data to have an estimation of the ratio between DFADs and other logs (raising factor)
cat('\n   1.2 - Getting multiplication factor from Ob7 datasets\n\n')
source(file.path(ROUT_PATH, "2.get_multiplication_factor.R"))


#' 3. Merge the outputs from the 2 first routines and calculate the number of FOBs
#' @ATTENTION: script a modifier. Pour l'instant c'est une version de developpement
#'             adaptee au fait que je n'ai pas encore recu les donnees Ob7 des bonnes annees
cat('\n   1.3 - Getting FOB number from 1.1 and 1.2 outputs\n')
source(file.path(ROUT_PATH, "3.get_FOB_number.R"))
