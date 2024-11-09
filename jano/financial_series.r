install.packages("devtools")
library(devtools)
devtools::install_github("cefet-rj-dal/event_datasets", force=TRUE)

#Load a series using package - Recommended
#Load package
library(dalevents)

data(fi_br)

#Select subset inflation and IPCA index
inflation <- fi_br$Inflation
test <- inflation$IPCA
test <- na.omit(test)

#Plotting original series
plot(ts(test), type = "l",
     ylab="value",
     xlab = "time")


plot(ts(fi_br$Commodity$`Oil Brent`), type = "l")
