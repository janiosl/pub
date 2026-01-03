#Dataset selection
library(united)

#Gecco ----
data(gecco)
gecco_sample <- gecco$multi
gecco_sample <- gecco_sample[16500:18000,]


#UCR ----
data("ucr_ecg")
data("ucr_int_bleeding")
data("ucr_power_demand")
data("ucr_nasa")
ucr_sample <- list()
ucr_sample[[1]] <- ucr_ecg
ucr_sample[[2]] <- ucr_int_bleeding
ucr_sample[[3]] <- ucr_power_demand[1:10]
ucr_sample[[4]] <- ucr_nasa[1:10]
names(ucr_sample) <- c("ecg", "int_bleeding", "power_demand", "nasa")


#Yahoo ----
data("A1Benchmark")
data("A2Benchmark")
data("A3Benchmark")

yahoo_sample <- list()
yahoo_sample[[1]] <- A1Benchmark[1:10]
yahoo_sample[[2]] <- A2Benchmark[1:10]
yahoo_sample[[3]] <- A3Benchmark[1:10]

names(yahoo_sample) <- c("A1","A2","A3")


#NAB ----
data("nab_realAWSCloudwatch")
data("nab_realAdExchange")
data("nab_artificialWithAnomaly")

nab_sample <- list()
nab_sample[[1]] <- nab_realAWSCloudwatch
nab_sample[[2]] <- nab_realAdExchange
nab_sample[[3]] <- nab_artificialWithAnomaly
names(nab_sample) <- c("AWSCloudwatch", "AdExchange", "artificialWithAnomaly")


#Record ----
dir <- "DSc/pipeline_exp"
setwd(dir=dir)

save(gecco_sample, file="data/gecco_sample.RData", compress = "xz")
save(ucr_sample, file="data/ucr_sample.RData", compress = "xz")
save(yahoo_sample, file="data/yahoo_sample.RData", compress = "xz")
save(nab_sample, file="data/nab_sample.RData", compress = "xz")


#Load samples ----
load(file="data/gecco_sample.RData")
load(file="data/ucr_sample.RData")
load(file="data/yahoo_sample.RData")
load(file="data/nab_sample.RData")
