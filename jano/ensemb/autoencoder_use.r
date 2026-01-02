#Autoencoders

#Load libraries ----
library(daltoolbox)
library(daltoolboxdp)
library(tspredit)
library(harbinger)

#Load datasets ----
library(united)


data("oil_3w_Type_1")
data <- oil_3w_Type_1$`WELL-00001_20140124213136`
data <- data[2:9]
serie <- data[1:7]

plot(as.ts(data))

samp <- ts_sample(serie, test_size = as.integer(nrow(serie)*0.2))
train <- as.data.frame(samp$train)
test <- as.data.frame(samp$test)
features <- names(train)

is <- length(data)-1

# CPD ----
source("hcp_autoencoder_ls_trsh.R")

# -------------------------------------------------
# 2. Criar modelo de Autoencoder + CPD simples
# -------------------------------------------------
# Detector (CPD)
#model <- hcp_cusum()
model <- hcp_binseg(Q=2)

# Objeto para passar para função
#obj <- list(model=autoenc$model, cpd=cpd, encode_size=3)
# Aqui vou usar um autoencoder do daltoolbox para exemplo
# e um detector de mudança da harbinger
ae_cpd <- hcp_autoencoder_ls(is,1, cpd=model)
ae_cpd <- fit(ae_cpd, train)

# -------------------------------------------------
# 3. Testar cada uma das funções
# -------------------------------------------------
result <- detect(ae_cpd, serie)

#Anomaly detection ----
#Model
model <- han_autoencoder(3,2)
  
#Train
model <- fit(model, data$value)

#Detect
result <- detect(model, data$value)

#Plot ----
grf <- har_plot(ae_cpd, data$p_tpt, result, data$event)
grf <- har_plot(model, data$value, result, data$event)
plot(grf)
