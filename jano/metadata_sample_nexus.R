setwd("~/GitHub/rDS/cefet/sample_nexus")

# #Gecco ------------------------------------------------------------------
load("gecco_sample.RData")

meta_gecco <- data.frame(
  series = names(gecco_sample)[1:9]
)

meta_gecco$rows <- nrow(gecco_sample)
meta_gecco$events <- sum(gecco_sample$event)

meta_gecco
summary(meta_gecco)

head(gecco_sample)
plot(as.ts(gecco_sample[,1:9]))
plot(as.ts(gecco_sample$event))

# #NAB --------------------------------------------------------------------
load("nab_sample.RData")

meta_nab <- data.frame(
  series = names(nab_sample)
)

nr <- c()
j = 1
for (j in 1:length(nab_sample)){
  #print(nrow(nab_sample[[j]]))
  nr <- append(nr, nrow(nab_sample[[j]]))
}

meta_nab$rows <- nr

ev <- c()
j = 1
for(j in 1:length(nab_sample)){
  #print(sum(nab_sample[[j]]$event))
  ev <- append(ev, sum(nab_sample[[j]]$event))
}

meta_nab$events <- ev

meta_nab
summary(meta_nab)

head(nab_sample[[9]])
plot(as.ts(nab_sample[[9]]$value))

plot(as.ts(nab_sample[[9]]$event))

# #UCR --------------------------------------------------------------------
load("ucr_sample.RData")

meta_ucr <- data.frame(
  series = names(ucr_sample)
)

nr <- c()
j = 1
for (j in 1:length(ucr_sample)){
  #print(nrow(ucr_sample[[j]]))
  nr <- append(nr, nrow(ucr_sample[[j]]))
}

meta_ucr$rows <- nr


ev <- c()
j = 1
for(j in 1:length(ucr_sample)){
  #print(sum(ucr_sample[[j]]$event))
  ev <- append(ev, sum(ucr_sample[[j]]$event))
}

meta_ucr$events <- ev

meta_ucr
summary(meta_ucr)

#Series example
head(ucr_sample[[7]])
plot(as.ts(ucr_sample[[7]]$series))
plot(as.ts(ucr_sample[[7]]$event))


# #3W ---------------------------------------------------------------------
load("oil_3w_sample.RData")

meta_3w <- data.frame(
  series = names(oil_3w_sample)
)

nr <- c()
j = 1
for (j in 1:length(oil_3w_sample)){
  #print(nrow(oil_3w_sample[[j]]))
  nr <- append(nr, nrow(oil_3w_sample[[j]]))
}

meta_3w$rows <- nr



#Rótulos usados com abordagem de problema de detecção como classificação binária
#0 = normal, 1 = evento.
#https://www.sciencedirect.com/science/article/pii/S0920410519306357?via%3Dihub
#Seção 4 - Proposed benchmarks e 4.2 - Anomaly detection

ev <- c()
j = 1
for(j in 1:length(oil_3w_sample)){
  #print(sum(oil_3w_sample[[j]]$event))
  ev <- append(ev, sum(oil_3w_sample[[j]]$event))
}

meta_3w$events <- ev

meta_3w
summary(meta_3w)

#Séries com eventos
meta_3w[meta_3w$events > 0,]
summary(meta_3w[meta_3w$events > 0,])

#Exceto séries inválidas (sem observações)
meta_3w[meta_3w$rows > 0,]
summary(meta_3w[meta_3w$rows > 0,])


head(oil_3w_sample[[5]])
plot(as.ts(oil_3w_sample[[9]]$series))
plot(as.ts(oil_3w_sample[[9]]$event))

plot(as.ts(oil_3w_sample[[13]]$series))
plot(as.ts(oil_3w_sample[[13]]$event))

# #RARE -------------------------------------------------------------------
#Do not use until usage problems are corrected

load("rare_sample.RData")

meta_rare <- data.frame(
  series = names(rare_sample)[1:20]
)

meta_rare$rows <- nrow(rare_sample)
meta_rare$events <- sum(rare_sample$event)

meta_rare
summary(meta_rare)

head(rare_sample)
plot(as.ts(rare_sample[8]))


#Dataset might be better used as multivariate time series
#Instead of selecting features it is better do use all features and sample
#rows
#Visual examples of problems with the dataset
plot(as.ts(rare_sample[,1:9]))
plot(as.ts(rare_sample[,10:19]))
plot(as.ts(rare_sample[20]))



# #YAHOO ------------------------------------------------------------------
#Do not use until usage problems are corrected
#Series with errors on change point labels
meta_yahoo <- data.frame(
  series = names(yahoo_sample)
)

nr <- c()
j = 1
for (j in 1:length(yahoo_sample)){
  #print(nrow(yahoo_sample[[j]]))
  nr <- append(nr, nrow(yahoo_sample[[j]]))
}

meta_yahoo$rows <- nr


ev <- c()
j = 1
for(j in 1:length(yahoo_sample)){
  #print(sum(yahoo_sample[[j]]$event))
  ev <- append(ev, sum(yahoo_sample[[j]]$event))
}

meta_yahoo$events <- ev

meta_yahoo
summary(meta_yahoo)
