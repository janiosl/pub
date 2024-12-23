#Replace this line using your own path
caminho <- "E://Users//janio//Documents//Education//Mestrado e Doutorado//CEFET//2. Pesquisa//DAL_Events//GitHub//dal//event_datasets_etl//original_datasets//3W//data//grouped"
setwd(caminho)

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
