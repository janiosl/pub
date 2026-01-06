# Environment ----
library(devtools)
library(ggpubr)
library(united)
library(daltoolbox)
library(daltoolboxdp)
library(harbinger)
library(tspredit)


## Methods ----
methods <- list()

methods[[1]] <- hanr_fbiad()
methods[[2]] <- hanr_arima()

names(methods) <- c("fbiad", "arima")

mt=1 #Method selection

# Metrics and results objects ----
## Empty metrics object
experiment <- data.frame(method=names(methods)[mt],
                             dataset="Gecco",
                             series="?",
                             time_fit=0,
                             time_detection=0,
                             precision=0,
                             recall=0,
                             f1=0)

head(experiment)

## Empty result history
cons_res <- list()

# Data ----
data(gecco)
data <- gecco$multi
data <- data[16500:18000,]
features <- names(data[2:10])

plot(as.ts(data[,2:11]))

#series <- data$tp
#plot(as.ts(series))

# Detection ----
## Detection
i=2
s=length(data)-2


for (i in 2:s){
  series <- data[i]
  
  #Detection history
  j <- i-1
  cons_res[[j]] <- list()
  
  #Model
  model <- methods[[mt]]
  cons_res[[j]][[1]] <- model
  
  #Fit and detect
  model <- fit(model, series)
  result <- detect(model, series)
  
  #Result
  cons_res[[j]][[2]] <- result
  
  names(cons_res[[j]]) <- c("md", "rs")
  rm(model)
}

## Record detection
names(cons_res) <- features
#save(cons_res,
#     file="~/cefet/janio/DSc/pipeline_exp/results/cons_res.RData",
#     compress = "xz")


# Results analysis ----
# Evaluate - Manual analysis
ev_soft <- evaluate(har_eval_soft(sw_size=90),
                    cons_res[[1]]$rs$event,
                    data$event)

ev_soft$confMatrix

ev_soft$precision
ev_soft$recall
ev_soft$F1

#Register metrics
experiment$series[1] <- features[1]
experiment$precision[1] <- ev_soft$precision
experiment$recall[1] <- ev_soft$recall
experiment$f1[1] <- ev_soft$F1


#Update experiment to restart ----
for (i in 2:length(features)){
  #Evaluate
  rm(ev_soft)
  ev_soft <- evaluate(har_eval_soft(sw_size=90),
                      cons_res[[i]]$rs$event,
                      data$event)
  
  #Update experiment analysis
  experiment <- rbind(experiment,
                      c(method=names(methods)[mt],
                        dataset="Gecco",
                        series=features[i],
                        time_fit=0,
                        time_detection=0,
                        precision=ev_soft$precision,
                        recall=ev_soft$recall,
                        f1=ev_soft$F1))
  
}

head(experiment)

#Record metrics
#save(experiment,
#     file="~/cefet/janio/DSc/pipeline_exp/results/pipe_experiment.RData",
#     compress = "xz")
