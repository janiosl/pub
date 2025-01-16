library(devtools)
library(ggpubr)
#loading DAL
#Current version
source("https://raw.githubusercontent.com/cefet-rj-dal/daltoolbox/main/jupyter.R")

#loading DAL
load_library("daltoolbox")

# Data --------------------------------------------------------------------
library(devtools)
#devtools::install_github("cefet-rj-dal/event_datasets", force=TRUE)
library(dalevents)

#Load a series
data(oil_3w_Type_1)

#Example selection --------------------------------
series <- oil_3w_Type_1$Type_1
series <- series$`WELL-00001_20140124213136` #Easy
series <- series$`WELL-00002_20140126200050` #Easy
series <- series$`WELL-00006_20170801063614` #Medium


series <- oil_3w_Type_2$Type_2
series <- series$`WELL-00002_20131104014101` #Easy
series <- series$`WELL-00003_20141122214325` #Medium-Easy
series <- series$`WELL-00003_20170728150240` #Medium


series <- oil_3w_Type_5$Type_5[[1]] #Good example
series <- oil_3w_Type_5$Type_5[[2]] #Medium-Hard
series <- oil_3w_Type_5$Type_5[[3]] #Medium

#Use the loaded series -------------------------------
head(series)
#summary(series)
series$T_JUS_CKGL <- NULL

head(series)

plot(as.ts(series[,1:7]))

plot(as.ts(series$class))

data <- series[,1:7]
head(data)

samp <- ts_sample(data, test_size = as.integer(nrow(data)*0.2))

train <- as.data.frame(samp$train)
test <- as.data.frame(samp$test)
features <- names(train)

head(train)

# Visual ------------------------------------------------------------------
#Plots (Lucas template)
pred_data <- rbind(train, test)
head(pred_data)


#rec_data <- res_wrj
#head(rec_data)


ts_df <- data
ts_df$index <- as.numeric(rownames(data))
head(ts_df)


pred_plot_data <- rec_data
#names(pred_plot_data) <- features
#head(pred_plot_data)


ts_df$pred <- 0
pred_plot_data$test_sample <- ts_df$test_sample
pred_plot_data$pred <- 1
pred_plot_data$index <- as.numeric(rownames(pred_plot_data))
rownames(pred_plot_data) <- rownames(ts_df)


plot_data <- ts_df
#plot_data <- rbind(ts_df, pred_plot_data)
#output_features <- names(rec_data)

plot_features <- features
#plot_features <- c(features, output_features)


#Input ===================================================
ae_type <- 'encoder'

if (ae_type == 'encoder'){
  input_features <- names(ts_df[,1:7])
  plot_data <- pred_data
  names(plot_data) <- input_features
  plot_data$index <- ts_df$index
  
  plot_features <- c(input_features)
  
  plotList <- lapply(
    plot_features,
    function(key) {
      plt <- ggplot(plot_data, aes(x=index, y=eval(parse(text=key)))) +
        geom_line() +
        xlab('') +
        ylab(key) + 
        geom_vline(xintercept = 5805, #CPD 1 - START
                   color = "black",
                   linetype = "dashed",
                   size = 0.5) +
        geom_vline(xintercept = 5863, #CPD 1 - END
                   color = "gray",
                   linetype = "solid",
                   size = 0.5) +
#        geom_vline(xintercept = 10717, #CPD 2 - START
#                   color = "black",
#                   linetype = "dashed",
#                   size = 0.5) +
#        geom_vline(xintercept = 10725, #CPD 2 - END
#                   color = "gray",
#                   linetype = "solid",
#                   size = 0.5) +
        theme_classic()
      
      plt
    }
  )
  
  ggarrange(
    plotlist=plotList,
    align='v',
    ncol=1, nrow=length(plot_features))
}
