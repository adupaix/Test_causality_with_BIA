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


build.and.compare.models <- function(my_data, dir = "yft",
                                     output_path = OUTPUT_PATH){
  
  dir.create(file.path(output_path, dir),
             recursive = T,
             showWarnings = F)
  
  # LINEAR MODEL
  my_lm <- lm(phase_angle_deg ~ NFob + chla + Length + quarter, data = my_data)
  comp_lm <- build.model(my_data, which.model = "lm",
                         return.comparison.metrics = T)
  
  png(filename = file.path(output_path, dir, "diagnostic_plots_lm.png"))
  par(mfrow = c(2,2))
  plot(my_lm)
  dev.off()
  
  # NON-LINEAR MODEL 1
  my_nlm1 <- build.model(my_data, which.model = "nlm1")
  comp_nlm1 <- build.model(my_data, which.model = "nlm1",
                         return.comparison.metrics = T)
  
  # NON-LINEAR MODEL 2
  my_nlm2 <- build.model(my_data, which.model = "nlm2")
  comp_nlm2 <- build.model(my_data, which.model = "nlm2",
                         return.comparison.metrics = T)
  
  
  # summary of the results
  aic_results <- data.frame(
    Model = c("Linear Model", "Non-linear Model 1", "Non-linear Model 2"),
    R2 = c(comp_lm[1], comp_nlm1[1], comp_nlm2[1]),
    RMSE = c(comp_lm[2], comp_nlm1[2], comp_nlm2[2]),
    AIC = c(comp_lm[3], comp_nlm1[3], comp_nlm2[3])
  )
  
  # save model comparison
  write.csv(x = aic_results,
            file = file.path(output_path, dir,
                             "models_comparison.csv"),
            row.names = F)
  list_models <- list(my_lm, my_nlm1, my_nlm2)
  names(list_models) <- paste0(c("lm","nlm","nlm"),dir,c("","1","2"))
  saveRDS(list_models,
          file = file.path(output_path, dir,
                           "models.rds"))
  
  sink(file.path(output_path, dir, "summary_models.txt"))
  cat("### LINEAR MODEL ###\n\n")
  print(summary(my_lm))
  cat("\n\n### NON LINEAR MODEL 1 ###\n\n")
  print(summary(my_nlm1))
  cat("\n\n### NON LINEAR MODEL 2 ###\n\n")
  print(summary(my_nlm2))
  sink()
  
  # Leave-one-out cross validation
  model_types <- c("lm","nlm1","nlm2")
  for (j in 1:length(model_types)){
    coeff_model <- names(coefficients(list_models[[j]]))
    data_lm <- data.frame(matrix(nrow = 0,
                                 ncol = 2*length(coeff_model)+4))
    names(data_lm) <- c("removed",
                        paste(rep(coeff_model, each = 2),
                              c("",".p"), sep = ""),
                        "r_squared", "rmse","AIC")
    for (i in 1:dim(my_data)[1]){
      my_data.i <- my_data[-i,]
      model_ <- build.model(my_data.i, which.model = model_types[j])
      pvalues <- summary(model_)$coefficients[,4]
      coeff_values <- summary(model_)$coefficients[,1]
      
      data_lm[i,] <- c(i, c(rbind(coeff_values,pvalues)),
                       build.model(my_data.i,
                                   which.model = model_types[j],
                                   return.comparison.metrics = T))
    }
    write.csv(data_lm,
              file.path(output_path, dir, paste0("loocv_",model_types[j],".csv")),
              row.names = F)
    rm(data_lm)
  }
  
  
  
  
  
  
}

build.model <- function(my_data,
                        which.model = c("lm","nlm1","nlm2"),
                        return.comparison.metrics = F){
  if (which.model == "lm"){
    model <- lm(phase_angle_deg ~ NFob + chla + Length + quarter, data = my_data)
  } else if (which.model == "nlm1"){
    X <- model.matrix(~ quarter, data=my_data)[,-1]
    my_data <- dplyr::bind_cols(my_data, X)
    residFun1 <- function(p, observed, nfob, fl, chla, q2, q3, q4) observed - getPred1(p,nfob,fl,chla,q2,q3,q4)
    getPred1 <- function(parS, nfob, fl, chla, q2, q3, q4){
      (nfob+parS$a)/(parS$b*nfob+parS$c) + parS$d * fl + parS$e * chla +  parS$f2 * q2 + parS$f3 * q3 + parS$f4 * q4
    }
    
    parStart1 <- list(a=80, b=0.1, c=0.1, d=-1, e = 10, f2 = 6, f3 = 0.2, f4 = 7)
    model <- nls.lm(par=parStart1, fn = residFun1, observed = my_data$phase_angle_deg,
                      lower = c(0,0,0,rep(-Inf,5)),
                      nfob = my_data$NFob, fl = my_data$Length,
                      chla = my_data$chla, q2 = my_data$quarter2,
                      q3 = my_data$quarter3, q4 = my_data$quarter4,
                      control = nls.lm.control(maxiter = 200))
  } else if (which.model == "nlm2"){
    X <- model.matrix(~ quarter, data=my_data)[,-1]
    my_data <- dplyr::bind_cols(my_data, X)
    
    residFun2 <- function(p, observed, nfob, fl, chla, q2, q3, q4) observed - getPred2(p,nfob,fl,chla,q2,q3,q4)
    getPred2 <- function(parS, nfob, fl, chla, q2, q3, q4){
      (nfob+parS$a)/(parS$b*nfob) + parS$d * fl + parS$e * chla +  parS$f2 * q2 + parS$f3 * q3 + parS$f4 * q4
    }
    
    parStart2 <- list(a=80, b=0.1, d=-1, e = 10, f2 = 6, f3 = 0.2, f4 = 7)
    model <- nls.lm(par=parStart2, fn = residFun2, observed = my_data$phase_angle_deg,
                      lower = c(0,0,rep(-Inf,5)),
                      nfob = my_data$NFob, fl = my_data$Length,
                      chla = my_data$chla, q2 = my_data$quarter2,
                      q3 = my_data$quarter3, q4 = my_data$quarter4,
                      control = nls.lm.control(maxiter = 200))
  }
  if (return.comparison.metrics == F){
    return(model)
  } else {
    tss <- sum((my_data$phase_angle_deg - mean(my_data$phase_angle_deg))^2)
    
    if(which.model == "lm"){
      # For linear model
      pred_lm <- predict(model, my_data)
      rss_lm <- sum((my_data$phase_angle_deg - pred_lm)^2)
      r_squared <- 1 - (rss_lm / tss)
      rmse <- sqrt(mean((my_data$phase_angle_deg - pred_lm)^2))
      aic <- AIC(model)
      
    } else if (which.model == "nlm1"){
      ## For non-linear model 1
      pred_nlm1 <- getPred1(model$par, nfob = my_data$NFob, fl = my_data$Length,
                            chla = my_data$chla, q2 = my_data$quarter2,
                            q3 = my_data$quarter3, q4 = my_data$quarter4)
      #residual sum of squares
      rss_nlm1 <- sum((my_data$phase_angle_deg - pred_nlm1)^2)
      #r2
      r_squared <- 1 - (rss_nlm1 / tss)
      # root mean square error
      rmse <- sqrt(mean((my_data$phase_angle_deg - pred_nlm1)^2))
      
      #AIC
      n_params_nlm1 <- length(coef(model))
      aic <- 2*n_params_nlm1 + nrow(my_data)*(log(2*pi) + 1 + log(rss_nlm1/nrow(my_data)))
    } else if (which.model == "nlm2"){
      ## For non-linear model 2
      pred_nlm2 <- getPred2(model$par, nfob = my_data$NFob, fl = my_data$Length,
                            chla = my_data$chla, q2 = my_data$quarter2,
                            q3 = my_data$quarter3, q4 = my_data$quarter4)
      #residual sum of squares
      rss_nlm2 <- sum((my_data$phase_angle_deg - pred_nlm2)^2)
      #r2
      r_squared <- 1 - (rss_nlm2 / tss)
      # root mean square error
      rmse <- sqrt(mean((my_data$phase_angle_deg - pred_nlm2)^2))
      n_params_nlm2 <- length(coef(model))
      aic <- 2*n_params_nlm2 + nrow(my_data)*(log(2*pi) + 1 + log(rss_nlm2/nrow(my_data)))
    }
    
    return(c(r_squared, rmse, aic))
  }
}
