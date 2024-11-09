library(dalevents)

#Datasets documentation: https://github.com/cefet-rj-dal/event_datasets
#Loading series Numenta Anomaly Benchmark (NAB)
#Artificial data with anomalies
data(numenta_artificialWithAnomaly)

#Series contained in the dataset
names(numenta_artificialWithAnomaly[[1]])
#"art_daily_flatmidd"       "art_daily_jumpsdo"        "art_daily_jumps"
#"art_daily_noju"          "art_increase_spike_densi"


#Selecting one univariate series
daily_flatmidd <- numenta_artificialWithAnomaly[[1]]$art_daily_flatmidd
series <- daily_flatmidd$value
labels <- daily_flatmidd$event

#Plotting series
plot(as.ts(series))


#Train, validation and test split
ts_split <- function(series, size=0.8) {
  split <- list()
  
  #Indexes positions
  n <- length(series)
  splt <- as.integer(n*size)
  train_end <- as.integer(splt*size)
  
  #Train and validation sample
  split$train <- series[1:train_end]
  split$val <- series[(train_end+1):splt]
  
  #Test sample
  split$test <- series[(splt+1):length(series)]
  
  return(split)
}


#Train, validation and test split
sample <- ts_split(series)

#Plotting series slices
plot(as.ts(sample$train))
plot(as.ts(sample$val))
plot(as.ts(sample$test))

#Check data
head(sample$train)
head(sample$val)
head(sample$test)

#Labels split
reference <- ts_split(labels)

plot(as.ts(reference$train))
plot(as.ts(reference$val))
plot(as.ts(reference$test))
