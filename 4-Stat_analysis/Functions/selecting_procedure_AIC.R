#'#***************************************************************************
#'@author : Amael DUPAIX
#'@update : 2025-02-21
#'@email : 
#'#***************************************************************************
#'@description :  Perform stepAIC for the non-linear model
#'#***************************************************************************
#'@revisions
#'
#'#***************************************************************************


selecting.procedure.AIC <- function(my_data,
                                    dir,
                                    output_path,
                                    threshold = 2){
  
  X <- model.matrix(~ quarter, data=my_data)[,-1]
  my_data <- dplyr::bind_cols(my_data, X)
  
  # variables
  all_variables <- c("nfob", "fl", "chla", "q")
  all_params_nfob = c('a','b','c')
  
  k = 1
  df <- list()
  
  #while k!=0
  
  while (k != 0){
    if ('q' %in% all_variables){
      vars <- c(all_variables[-which(all_variables == 'q')],
                "q2", "q3", "q4")
    }
    init_aic <- get_model_aic(vars = vars,
                              params_nfob = all_params_nfob,
                              data = my_data)
    df[[k]] <- data.frame(Iteration = k,
                          Variables = paste(all_variables, collapse = ','),
                          Nfob_parameters = paste(all_params_nfob, collapse = ','),
                          AIC = init_aic)
    
    # remove all variables except NFob
    for (i in 2:length(all_variables)){
      vars.i <- all_variables[-i]
      if ('q' %in% vars.i){
        vars.i_split <- c(vars.i[-which(vars.i == 'q')],
                          "q2", "q3", "q4")
      }
      params_nfob <- all_params_nfob
      aic.i <- get_model_aic(vars = vars.i_split,
                             params_nfob = all_params_nfob,
                             data = my_data)
      df[[k]] <- rbind(df[[k]],
                       c(k,
                         paste(vars.i, collapse = ','),
                         paste(all_params_nfob, collapse = ','),
                         AIC = aic.i))
    }
    # remove NFob parameters
    if (length(all_params_nfob) > 2){
      for (j in 1:length(all_params_nfob)){
        params_nfob <- all_params_nfob[-j]
        aic.j <- get_model_aic(vars = vars,
                               params_nfob = params_nfob,
                               data = my_data)
        df[[k]] <- rbind(df[[k]],
                         c(k,
                           paste(all_variables, collapse = ','),
                           paste(params_nfob, collapse = ','),
                           AIC = aic.j))
      }
    }
    df[[k]]$AIC <- as.numeric(df[[k]]$AIC)
    df[[k]]$diff_AIC <- df[[k]]$AIC - df[[k]]$AIC[1]
    
    if(any(df[[k]]$diff_AIC <= -threshold)){
      all_variables <- unlist(strsplit(df[[k]]$Variables[df[[k]]$diff_AIC == min(df[[k]]$diff_AIC)],
                                       split = ','))
      all_params_nfob = unlist(strsplit(df[[k]]$Nfob_parameters[df[[k]]$diff_AIC == min(df[[k]]$diff_AIC)],
                                        split = ','))
      k = k+1
    } else {
      k = 0
    }
  }
  
  df <- bind_rows(df)
  
  write.csv(df,
            file = file.path(output_path, dir, 'Step_AIC.csv'),
            row.names = F)
  
}


remove.rep <- function(x, pattern = ','){
  x <- gsub(paste0(pattern, '+'),
            pattern,
            x)
  x <- gsub(paste0(pattern, '$'),
            '',
            x)
  x <- gsub(paste0('^', pattern),
            '',
            x)
}

nfob_formula <- function(params){
  if('a' %in% params & 'b' %in% params & 'c' %in% params){
    return('(nfob+parS$a)/(parS$b*nfob+parS$c)')
  } else if ('a' %in% params & 'b' %in% params & !('c' %in% params)){
    return('(nfob+parS$a)/(parS$b*nfob)')
  } else if ('a' %in% params & !('b' %in% params) & 'c' %in% params){
    return('(nfob+parS$a)/(parS$c)')
  } else if (!('a' %in% params) & 'b' %in% params & 'c' %in% params){
    return('(nfob)/(parS$b*nfob+parS$c)')
  }
}
nfob_start <- function(params){
  if('a' %in% params & 'b' %in% params & 'c' %in% params){
    return('a=80, b=0.1, c=0.1')
  } else if ('a' %in% params & 'b' %in% params & !('c' %in% params)){
    return('a=80, b=0.1')
  } else if ('a' %in% params & !('b' %in% params) & 'c' %in% params){
    return('a=80, c=0.1')
  } else if (!('a' %in% params) & 'b' %in% params & 'c' %in% params){
    return('b=0.1, c=0.1')
  } else if (length(params) == 1){
    if(params == 'a'){
      return('a=80')
    } else if (params == 'b'){
      return('b=0.1')
    } else if (params == 'c'){
      return('c=0.1')
    }
  }
}

get_model_aic <- function(vars,
                          params_nfob,
                          data){
  
  # function to compare observation with predictions
  l1 <- paste0("residFun <- function(p, observed,",
               paste(vars, collapse = ','),
               ") observed - getPred(p,",
               paste(vars, collapse = ','),
               ")")
  
  # function to get predictions of the model
  l2 <- paste('getPred <- function(parS,',
              paste(vars, collapse = ', '),
              '){',
              remove.rep(paste(ifelse('nfob' %in% vars,
                                      nfob_formula(params_nfob),
                                      ''),
                               ifelse('fl' %in% vars,
                                      'parS$d * fl',
                                      ''),
                               ifelse('chla' %in% vars,
                                      'parS$e * chla',
                                      ''),
                               ifelse(any(grepl('q', vars)),
                                      'parS$f2 * q2 + parS$f3 * q3 + parS$f4 * q4',
                                      ''),
                               sep = '+'),
                         pattern = "\\+"),
              '}')
  
  # list of starting parameters
  l3 <- paste("parStart <- list(",
              remove.rep(paste(ifelse('nfob' %in% vars,
                                      nfob_start(params_nfob),
                                      ''),
                               ifelse('fl' %in% vars,
                                      'd=-1',
                                      ''),
                               ifelse('chla' %in% vars,
                                      'e = 10',
                                      ''),
                               ifelse(any(grepl('q', vars)),
                                      'f2 = 6, f3 = 0.2, f4 = 7',
                                      ''),
                               sep = ',')),
              ")")
  
  
  ## build model
  l4 <- paste("model <- nls.lm(par=parStart, fn = residFun, observed = data$phase_angle_deg,",
              "lower = c(",
              remove.rep(paste(ifelse('nfob' %in% vars,
                                      paste0(rep(0,length(params_nfob)),
                                             collapse = ','),
                                      ''),
                               ifelse('fl' %in% vars,
                                      '-Inf',
                                      ''),
                               ifelse('chla' %in% vars,
                                      '-Inf',
                                      ''),
                               ifelse(any(grepl('q', vars)),
                                      '-Inf,-Inf,-Inf',
                                      ''),
                               sep = ',')),
              '), ',
              remove.rep(paste(ifelse('nfob' %in% vars,
                                      'nfob = data$NFob',
                                      ''),
                               ifelse('fl' %in% vars,
                                      'fl = data$Length',
                                      ''),
                               ifelse('chla' %in% vars,
                                      'chla = data$chla',
                                      ''),
                               ifelse(any(grepl('q', vars)),
                                      'q2 = data$quarter2, q3 = data$quarter3, q4 = data$quarter4',
                                      ''),
                               sep = ',')),
              ', control = nls.lm.control(maxiter = 200))')
  
  # get model predictions
  l5 <- paste('pred_nlm <- getPred(model$par,',
              remove.rep(paste(ifelse('nfob' %in% vars,
                                      'nfob = data$NFob',
                                      ''),
                               ifelse('fl' %in% vars,
                                      'fl = data$Length',
                                      ''),
                               ifelse('chla' %in% vars,
                                      'chla = data$chla',
                                      ''),
                               ifelse(any(grepl('q', vars)),
                                      'q2 = data$quarter2, q3 = data$quarter3, q4 = data$quarter4',
                                      ''),
                               sep = ',')),
              ')')
  
  eval(parse(text = l1))
  eval(parse(text = l2))
  eval(parse(text = l3))
  eval(parse(text = l4))
  eval(parse(text = l5))
  
  #residual sum of squares
  rss_nlm <- sum((data$phase_angle_deg - pred_nlm)^2)
  
  #AIC
  n_params_nlm <- length(coef(model))
  aic <- 2*n_params_nlm + nrow(data)*(log(2*pi) + 1 + log(rss_nlm/nrow(data)))
  return(aic)
  
}