#Load libraries ----
library(daltoolbox)
library(daltoolboxdp)
library(tspredit)
library(harbinger)

#Load datasets ----
library(united)

data(gecco)
data <- gecco$multi
data <- data[16500:18000,]

plot(as.ts(data[,2:10]))

#Anomaly detection ----
#Model
model <- hanr_fbiad()

#Train
model <- fit(model, data$ph)

#Detect
result <- detect(model, data$ph)


#Plot ----
grf <- har_plot(model, data$ph, result, data$event)
plot(grf)


#Evaluate ----
ev_soft <- evaluate(har_eval_soft(), result$event, data$event)
ev_soft$confMatrix
ev_soft$F1
ev_soft$precision
ev_soft$recall
