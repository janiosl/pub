#Replace this line using your own path
caminho <- "E://Users//janio//Documents//Education//Mestrado e Doutorado//CEFET//2. Pesquisa//DAL_Events//GitHub//dal//event_datasets_etl//original_datasets//3W//data//grouped"
setwd(caminho)


# Type0 -------------------------------------------------------------------
load("oil_3w_Type_0.RData")

sample_3w_tp0 <- oil_3w_Type_0$Type_0[1:3]

out <- "sample_3w_type0.RData"
save(sample_3w_tp0, file=out)

load(out)

series <- sample_3w_tp0[[3]]
summary(series)
series$T_JUS_CKGL <- NULL

head(series)

plot(as.ts(series[,1:7]),
     main="Type 0 - Series 3")

plot(as.ts(series$class),
     main="Type 0 - Series 3 - Labels")


# Arquivos Parquet - Datasets ausentes ------------------------------------
#install.packages("arrow")
library(arrow)


#Type 3 -------------------------------
#Simulated
files <- c("SIMULATED_00001", "SIMULATED_00002", "SIMULATED_00003")

#Sample
data_3w_tp3_sample <- list()

for (i in 1:3){
  data_3w_tp3_sample[[i]] <- read_parquet(paste("parquet/", files[i], ".parquet", sep=""))
}

names(data_3w_tp3_sample) <- files

#Plot
plot(as.ts(data_3w_tp3_sample$SIMULATED_00001$`T-TPT`))

#Save Rdata
out_tp3 <- "parquet/data_3w_tp3_sample.RData"
save(data_3w_tp3_sample, file=out_tp3)


#Real-world
files <- c("WELL-00001_20170320120025", "WELL-00014_20170917190000", "WELL-00014_20170917140000")

#Sample
data_3w_tp3_real_sample <- list()

for (i in 1:3){
  data_3w_tp3_real_sample[[i]] <- read_parquet(paste("parquet/3/", files[i], ".parquet", sep=""))
}

names(data_3w_tp3_real_sample) <- files

#Plot
plot(as.ts(data_3w_tp3_real_sample$`WELL-00001_20170320120025`$`T-TPT`))

#Save Rdata
out_tp3_real <- "parquet/data_3w_tp3_real_sample.RData"
save(data_3w_tp3_real_sample, file=out_tp3_real)

names(data_3w_tp3_real_sample$`WELL-00001_20170320120025`)


#Features selection
features_paper <- c("P-PDG","P-TPT", "T-TPT", "P-MON-CKP",
                    "P-JUS-CKP", "P-JUS-CKGL", "QGL", "class")


d1 <- data_3w_tp3_real_sample$`WELL-00001_20170320120025`[,features_paper]
summary(d1)

d2 <- data_3w_tp3_real_sample$`WELL-00014_20170917190000`[,features_paper]
summary(d2)

d3 <- data_3w_tp3_real_sample$`WELL-00014_20170917140000`[,features_paper]
summary(d3)

data_3w_tp3_real_sample_exp <- list()
data_3w_tp3_real_sample_exp[[1]] <- d1
data_3w_tp3_real_sample_exp[[2]] <- d2
data_3w_tp3_real_sample_exp[[3]] <- d3

names(data_3w_tp3_real_sample_exp) <- files

#Save Rdata
out_tp3_real_exp <- "parquet/3/data_3w_tp3_real_sample_exp.RData"
save(data_3w_tp3_real_sample_exp, file=out_tp3_real_exp)

#Type 4 -------------------------------
files <- c("WELL-00001_20170316110203", "WELL-00001_20170316130000", "WELL-00001_20170316150005")

#Sample
data_3w_tp4_sample <- list()

for (i in 1:3){
  data_3w_tp4_sample[[i]] <- read_parquet(paste("parquet/4/", files[i], ".parquet", sep=""))
}

names(data_3w_tp4_sample) <- files


#Plot
plot(as.ts(data_3w_tp4_sample$`WELL-00001_20170316110203`$`P-TPT`))

#Save Rdata
out_tp4 <- "parquet/4/data_3w_tp4_sample.RData"
save(data_3w_tp4_sample, file=out_tp4)



#Type 9 -------------------------------
files <- c("SIMULATED_00001", "SIMULATED_00002", "SIMULATED_00003")

#Sample
data_3w_tp9_sample <- list()

for (i in 1:3){
  data_3w_tp9_sample[[i]] <- read_parquet(paste("parquet/9/", files[i], ".parquet", sep=""))
}

names(data_3w_tp9_sample) <- files

#Plot
plot(as.ts(data_3w_tp9_sample$SIMULATED_00001$`T-TPT`))

#Save Rdata
out_tp9 <- "parquet/9/data_3w_tp9_sample.RData"
save(data_3w_tp9_sample, file=out_tp9)
