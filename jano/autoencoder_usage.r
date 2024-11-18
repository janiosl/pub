library(devtools)
library(ggpubr)
#loading DAL
#Current version
source("https://raw.githubusercontent.com/cefet-rj-dal/daltoolbox/main/jupyter.R")

#loading DAL
load_library("daltoolbox")


#Install package
#install.packages("devtools")
library(devtools)
#devtools::install_github("cefet-rj-dal/event_datasets", force=TRUE)
library(dalevents)

#Load a series
data(oil_3w_Type_1)

series <- oil_3w_Type_1$Type_1
series <- series$`WELL-00001_20140124213136`

#Use the loaded series
summary(series)
series$T_JUS_CKGL <- NULL

head(series)

plot(as.ts(series))

data <- series[,1:7]
labels <- series$class

head(data)

samp <- ts_sample(data, test_size = as.integer(nrow(data)*0.3))
train <- as.data.frame(samp$train)
test <- as.data.frame(samp$test)
features <- names(train)

head(train)
head(test)


# DNS Autoencoder -------------------------------------------------------------
reticulate::source_python("~/cefet/cefet/doc/ae_cpd/dns_autoencoder.py")

#Model creation and fit
dns <- dns_ae_create(length(train),1)
dns <- dns_fit(dns, train)

#Decoder
result <- dns_encode_decode(dns, data)

result <- as.data.frame(result)
names(result) <- features

#Latent space
ls <- dns_encode(dns, data)
ls <- as.data.frame(ls)


# Visual (simple version) -------------------------------------------------
#Test
plot(as.ts(test),
     main = "Input Layer: X")

#Complete
plot(as.ts(data),
     main = "Input Layer: X")
#abline(v = nrow(train), col = "gray", lty = 2, lwd = 2)

#Output Layer X'
plot(as.ts(result),
     main = "Output Layer: X´")
#abline(v = nrow(train), col = "gray", lty = 2, lwd = 2)

#Latent Space
plot(as.ts(ls),
     main="Latent Space")

#CPD using ls
load_library("harbinger")

# establishing change point method 
model <- hcp_amoc()

# fitting the model
model <- fit(model, ls$V1)

# making detections
detection <- detect(model, ls$V1)

grf <- har_plot(model, ls$V1, detection)
plot(grf)


# establishing change point method 
model <- hcp_binseg(Q=2)
model <- fit(model, ls$V1)
detection <- detect(model, ls$V1)

grf <- har_plot(model, ls$V1, detection)
plot(grf)


#Labels
labels[labels == 1] = 0.5
labels[labels == 101] = 1
plot(as.ts(labels))
