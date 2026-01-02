#Setup cefet
install.packages("daltoolbox")
install.packages("daltoolboxdp")
install.packages("tspredit")
install.packages("harbinger")


#Load libraries
library(daltoolbox)
library(daltoolboxdp)
library(tspredit)
library(harbinger)


#Install datasets
library(devtools)

#Credentials setting
#gitcreds::gitcreds_set()
#Help: https://github.com/orgs/community/discussions/140956

timeout <- options()$timeout
options(timeout=1200)
devtools::install_github("cefet-rj-dal/united", upgrade="never")
options(timeout=timeout)


#Load datasets
library(united)
