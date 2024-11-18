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
