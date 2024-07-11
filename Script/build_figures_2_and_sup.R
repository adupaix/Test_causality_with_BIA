#' ***********************************
#' Build figures for K model
#' ***********************************

rm(list = ls())

output_path <- "/home/adupaix/Documents/These/Axe_3/article_model_K_BIA/Figures"

library(ggplot2)
library(tidyr)
library(dplyr)

theme_replace(legend.key = element_blank()) 

#' Functions
#'**********

phi <- function(n, args){
  list2env(args, .GlobalEnv)
  
  return(eM/eP)
  
}

## Associated
R_ <- function(n, args){
  list2env(args, .GlobalEnv)
  
  N = (n * muP * muM * alphaA) + (muM * gammaP * alphaF) + (muM * alphaF * alphaA) + (muP * epsilonF * alphaA)
  D = (n * muP * muM * epsilonA) + (muM * epsilonA * alphaF) + (muP * epsilonF * gammaM) + (muP * epsilonF * epsilonA)
    
    return(N/D)
}
eA <- function(n, args){
  list2env(args, .GlobalEnv)
  
  return(
    eP*(1 + phi(n, args) * R_(n, args))/(1 + R_(n, args))
  )
}

## Free-swimming
T_ <- function(n, args){
  list2env(args, .GlobalEnv)
  
  N = (n * alphaA * muP * gammaM) + (gammaP * epsilonA * alphaF) + (gammaM * alphaF * alphaA) + (gammaM * gammaP * alphaF)
  D = (n * epsilonA * gammaP * muM ) + (epsilonF * gammaP * gammaM) + (alphaA * epsilonF * gammaM) + (epsilonF * epsilonA * gammaP)
  
  return(N/D)
}
eF <- function(n, args){
  list2env(args, .GlobalEnv)
  
  return(
    eP*(1 + phi(n, args) * T_(n, args))/(1 + T_(n, args))
  )
}

calculate_models_ouputs <- function(arguments, nmax = 100, nmin = 0){
  eAsso <- c()
  eFree <- c()
  for (n.i in nmin:nmax){
    eAsso[n.i+1] <- eA(n = n.i, args = arguments)
    eFree[n.i+1] <- eF(n = n.i, args = arguments)
  }
  
  df <- data.frame(n = 0:nmax,
                   eA = eAsso,
                   eF = eFree,
                   arguments)
  return(df)
  
}

#arguments
my_args_H1 <- list(alphaA = 10**-2,
                   alphaF = 10**-3,
                   epsilonA = 10**-3,
                   epsilonF = 10**-2,
                   muP = 10**-2,
                   muM = 10**-2,
                   gammaP = 10**-2,
                   gammaM = 10**-2,
                   eP = 100,
                   eM = 1)

my_args_H2 <- list(alphaA = 10**-2,
                   alphaF = 10**-2,
                   epsilonA = 10**-2,
                   epsilonF = 10**-2,
                   muP = 10**-3,
                   muM = 10**-2,
                   gammaP = 10**-2,
                   gammaM = 10**-3,
                   eP = 100,
                   eM = 1)

df_H1 <- calculate_models_ouputs(my_args_H1, nmax = 50)
df_H2 <- calculate_models_ouputs(my_args_H2, nmax = 50)

df_H1 %>% dplyr::mutate(H = "H1") -> df_H1
df_H2 %>% dplyr::mutate(H = "H2") -> df_H2
  
dplyr::bind_rows(df_H1,df_H2) %>%
  dplyr::select(n, eA, eF, H) %>%
  pivot_longer(cols = -c(n,H),
               names_to = "pop_fraction",
               values_to = "mean_condition") -> df

f_labeller <- function(variable, value){return(f_names[value])}
f_names <- list('eA' = expression(paste("Associated (", e[A],")")),
                'eF' = expression(paste("Free-swimming (", e[F],")")))

ggplot(df)+
  geom_line(aes(x=n, y=mean_condition, color = H, linetype = H))+
  facet_grid(~pop_fraction, labeller = f_labeller)+
  ylab("Mean physiological condition at equilibrium")+
  xlab("Number of DFADs (n)")+
  scale_color_brewer("Hypothesis",
                     palette = "Set1")+
  scale_linetype("Hypothesis")+
  scale_y_continuous(limits = c(eM,eP),
                     breaks = c(eM,eP),
                     labels = c(expression(e^"-"),
                                expression(e^"+")))+
  theme(panel.background = element_rect(color = "black",
                                        fill = "white"),
        axis.text = element_text(size = 11))

ggsave(filename = file.path(output_path,"Figure2.png"),
       width = 7, height = 4.5)

my_args_1 <- list(alphaA = 10**-2,
                   alphaF = 10**-3,
                   epsilonA = 10**-3,
                   epsilonF = 10**-2,
                   muP = 10**-1,
                   muM = 10**-1,
                   gammaP = 10**-1,
                   gammaM = 10**-1,
                   eP = 100,
                   eM = 1)
my_args_2 <- my_args_1
my_args_2$muP = my_args_2$muM = my_args_2$gammaP = my_args_2$gammaM = 10**-2
my_args_3 <- my_args_1
my_args_3$muP = my_args_3$muM = my_args_3$gammaP = my_args_3$gammaM = 10**-3
my_args_4 <- my_args_1
my_args_4$muP = my_args_4$muM = my_args_4$gammaP = my_args_4$gammaM = 10**-4
my_args_5 <- my_args_1
my_args_5$muP = my_args_5$muM = my_args_5$gammaP = my_args_5$gammaM = 10**-5

df_1 <- calculate_models_ouputs(my_args_1, nmax = 50)
df_2 <- calculate_models_ouputs(my_args_2, nmax = 50)
df_3 <- calculate_models_ouputs(my_args_3, nmax = 50)
df_4 <- calculate_models_ouputs(my_args_4, nmax = 50)
df_5 <- calculate_models_ouputs(my_args_5, nmax = 50)

dplyr::bind_rows(df_1, df_2, df_3, df_4, df_5) %>%
  dplyr::select(n, eA, eF, muM) %>%
  pivot_longer(cols = -c(n,muM),
               names_to = "pop_fraction",
               values_to = "mean_condition") -> df

f_labeller <- function(variable, value){return(f_names[value])}
f_names <- list('eA' = expression(paste("Associated (", e[A],")")),
                'eF' = expression(paste("Free-swimming (", e[F],")")))

ggplot(df)+
  geom_line(aes(x=n, y=mean_condition,
                color = as.factor(muM)))+
  facet_grid(~pop_fraction, labeller = f_labeller)+
  ylab("Mean physiological condition at equilibrium")+
  xlab("Number of DFADs (n)")+
  scale_color_viridis_d(expression(mu),
                        direction = -1)+
  scale_y_continuous(limits = c(eM,eP),
                     breaks = c(eM,eP),
                     labels = c(expression(e^"-"),
                                expression(e^"+")))+
  theme(panel.background = element_rect(color = "black",
                                        fill = "grey95"),
        axis.text = element_text(size = 11),
        panel.grid = element_blank())

ggsave(filename = file.path(output_path,"FigureSup.png"),
       width = 7, height = 4.5)

