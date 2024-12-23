#Install package
#install.packages("devtools")
#devtools::install_github("cefet-rj-dal/event_datasets", force=TRUE)

library(devtools)
library(dalevents)

#Load a series
data(oil_3w_Type_1)

series <- oil_3w_Type_1$Type_1 #Group selection
series <- series$`WELL-00001_20140124213136` #Series of a specific well

summary(series)
series$T_JUS_CKGL <- NULL #Remove NA variable

head(series)

# Data --------------------------------------------------------------------
data <- series[,1:7]
head(data)


# Label treatment ---------------------------------------------------------
labels <- as.data.frame(series$class)
names(labels) <- "class"
head(labels)

plot(as.ts(labels),
     main="Original Classes")

labels$trans <- 0


nas <- is.na(labels$class)
labels$trans[nas] <- 1

length(labels$trans)
sum(labels$trans)


plot(as.ts(labels$trans),
     main="Transition interval")


labels$cpd <- 0
head(labels)

cp = FALSE
for (i in 1:nrow(labels)){
  if (cp == FALSE){
    if(!is.na(labels$class[i]) && labels$class[i] != 0){
      print("Ponto de mudança localizado em:")
      print(i)
      labels$cpd[i] <- 1
      cp_idx <- i
      cp <- TRUE
    }
  }
}

cp_idx <- cp_idx+1
cp = FALSE


cp = FALSE
for (i in cp_idx:nrow(labels)){
  if (cp == FALSE){
    if(!is.na(labels$class[i]) && labels$class[i] != 101){
      print("Ponto de mudança localizado em:")
      print(i)
      labels$cpd[i] <- 1
      cp_idx <- i
      cp  <- TRUE
    }
  }
}

sum(labels$cpd)

plot(as.ts(labels$cpd),
     main="Change Points")


#Save
well <- "~/cefet/cefet/doc/ae_cpd/data/WELL_00001_20140124213136"

write.csv(data, file=paste(well,"_data.csv",sep=""), row.names = FALSE)
write.csv(labels, file=paste(well,"_labels.csv",sep=""), row.names = FALSE)
