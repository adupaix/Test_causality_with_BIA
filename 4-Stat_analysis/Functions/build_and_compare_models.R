#'#*******************************************************************************************************************
#'@author : Amael DUPAIX
#'@update : 2024-05-24
#'@email : 
#'#*******************************************************************************************************************
#'@description :  Build the models and calculate comparison metrics
#'#*******************************************************************************************************************
#'@revisions
#'
#'#*******************************************************************************************************************


build.and.compare.models <- function(my_data, suffix = "_yft",
                                     output_path = OUTPUT_PATH){
  # LINEAR MODEL
  my_lm <- lm(phase_angle_deg ~ NFob + chla + Length + quarter, data = my_data)
  
  # NON-LINEAR MODEL 1
  X <- model.matrix(~ quarter, data=my_data)[,-1]
  my_data <- dplyr::bind_cols(my_data, X)
  residFun1 <- function(p, observed, nfob, fl, chla, q2, q3, q4) observed - getPred1(p,nfob,fl,chla,q2,q3,q4)
  getPred1 <- function(parS, nfob, fl, chla, q2, q3, q4){
    (nfob+parS$a)/(parS$b*nfob+parS$c) + parS$d * fl + parS$e * chla +  parS$f2 * q2 + parS$f3 * q3 + parS$f4 * q4
  }
  
  parStart <- list(a=80, b=0.1, c=0.1, d=-1, e = 10, f2 = 6, f3 = 0.2, f4 = 7)
  my_nlm1 <- nls.lm(par=parStart, fn = residFun1, observed = my_data$phase_angle_deg,
                    lower = c(0,0,0,rep(-Inf,5)),
                    nfob = my_data$NFob, fl = my_data$Length,
                    chla = my_data$chla, q2 = my_data$quarter2,
                    q3 = my_data$quarter3, q4 = my_data$quarter4,
                    control = nls.lm.control(maxiter = 100))
  
  
  # NON-LINEAR MODEL 2
  residFun2 <- function(p, observed, nfob, fl, chla, q2, q3, q4) observed - getPred2(p,nfob,fl,chla,q2,q3,q4)
  getPred2 <- function(parS, nfob, fl, chla, q2, q3, q4){
    (nfob+parS$a)/(parS$b*nfob) + parS$d * fl + parS$e * chla +  parS$f2 * q2 + parS$f3 * q3 + parS$f4 * q4
  }
  
  parStart <- list(a=80, b=0.1, d=-1, e = 10, f2 = 6, f3 = 0.2, f4 = 7)
  my_nlm2 <- nls.lm(par=parStart, fn = residFun2, observed = my_data$phase_angle_deg,
                    lower = c(0,0,rep(-Inf,5)),
                    nfob = my_data$NFob, fl = my_data$Length,
                    chla = my_data$chla, q2 = my_data$quarter2,
                    q3 = my_data$quarter3, q4 = my_data$quarter4,
                    control = nls.lm.control(maxiter = 100))
  summary(my_nlm2)
  
  # MODEL COMPARISON
  tss <- sum((my_data$phase_angle_deg - mean(my_data$phase_angle_deg))^2)
  
  # For linear model
  pred_lm <- predict(my_lm, my_data)
  rss_lm <- sum((my_data$phase_angle_deg - pred_lm)^2)
  r_squared_lm <- 1 - (rss_lm / tss)
  rmse_lm <- sqrt(mean((my_data$phase_angle_deg - pred_lm)^2))
  
  ## For non-linear model 1
  pred_nlm1 <- getPred1(my_nlm1$par, nfob = my_data$NFob, fl = my_data$Length,
                        chla = my_data$chla, q2 = my_data$quarter2,
                        q3 = my_data$quarter3, q4 = my_data$quarter4)
  #residual sum of squares
  rss_nlm1 <- sum((my_data$phase_angle_deg - pred_nlm1)^2)
  #r2
  r_squared_nlm1 <- 1 - (rss_nlm1 / tss)
  # root mean square error
  rmse_nlm1 <- sqrt(mean((my_data$phase_angle_deg - pred_nlm1)^2))
  
  
  ## For non-linear model 2
  pred_nlm2 <- getPred2(my_nlm2$par, nfob = my_data$NFob, fl = my_data$Length,
                        chla = my_data$chla, q2 = my_data$quarter2,
                        q3 = my_data$quarter3, q4 = my_data$quarter4)
  #residual sum of squares
  rss_nlm2 <- sum((my_data$phase_angle_deg - pred_nlm2)^2)
  #r2
  r_squared_nlm2 <- 1 - (rss_nlm2 / tss)
  # root mean square error
  rmse_nlm2 <- sqrt(mean((my_data$phase_angle_deg - pred_nlm2)^2))
  
  ### Calcul des AIC
  aic_lm <- AIC(my_lm)
  n_params_nlm1 <- length(coef(my_nlm1))
  n_params_nlm2 <- length(coef(my_nlm2))
  
  aic_nlm1 <- 2*n_params_nlm1 + nrow(my_data)*(log(2*pi) + 1 + log(rss_nlm1/nrow(my_data)))
  aic_nlm2 <- 2*n_params_nlm2 + nrow(my_data)*(log(2*pi) + 1 + log(rss_nlm2/nrow(my_data)))
  
  # summary of the results
  aic_results <- data.frame(
    Model = c("Linear Model", "Non-linear Model 1", "Non-linear Model 2"),
    R2 = c(r_squared_lm, r_squared_nlm1, r_squared_nlm2),
    RMSE = c(rmse_lm, rmse_nlm1, rmse_nlm2),
    AIC = c(aic_lm, aic_nlm1, aic_nlm2)
  )
  
  write.csv(x = aic_results,
            file = file.path(output_path,
                             paste0("models_comparison",suffix,".csv")))
  list_models <- list(my_lm, my_nlm1, my_nlm2)
  names(list_models) <- paste0(c("lm","nlm","nlm"),suffix,c("","1","2"))
  saveRDS(list_models,
          file = file.path(output_path,
                           paste0("models",suffix,".rds")))
}