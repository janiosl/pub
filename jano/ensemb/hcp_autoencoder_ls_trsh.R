#'@title Autoencoder Latent Space CPD method
#'@description Change-point detection method that focus on identify change
#'points in a latent space created by an autoencoder
#'@param input_size The auotencoder input layer size
#'@param encode_size The auotencoder latent space size
#'@param encoderclass The autoencoder class
#'@param cpd The CPD method class used in CPD step
#'@return `hcp_autoencoder_ls` object
#'@examples
#'library(daltoolbox)
#'
#'#loading the example database
#'data(examples_changepoints)
#'
#'#Using simple example
#'dataset <- examples_changepoints$simple
#'head(dataset)
#'
#'# setting up change point method
#'model <- hcp_autoencoder_ls(7,1)
#'
#'# fitting the model
#'model <- fit(model, dataset$serie)
#'
#'# execute the detection method
#'detection <- detect(model, dataset$serie)
#'
#'# filtering detected events
#'print(detection[(detection$event),])
#'
#'@export
hcp_autoencoder_ls <- function(input_size, encode_size, cpd,
                               encoderclass=autoenc_e, threshold=0.5, ...) {
  obj <- harbinger()
  obj$input_size <- input_size
  obj$encode_size <- encode_size
  obj$threshold <- threshold
  obj$cpd <- cpd
  
  obj$model <- encoderclass(obj$input_size, obj$encode_size, ...)
  
  obj$preproc <- tspredit::ts_norm_gminmax()
  
  class(obj) <- append("hcp_autoencoder_ls", class(obj))
  
  return(obj)
}


#'@importFrom stats na.omit
#'@export
fit.hcp_autoencoder_ls <- function(obj, serie, ...) {
  if(is.null(serie)) stop("No data was provided for computation",call. = FALSE)
  
  serie <- stats::na.omit(serie)
  ts <- ts_data(serie, obj$input_size)
  
  obj$preproc <- fit(obj$preproc, ts)
  ts <- transform(obj$preproc, ts)
  ts <- as.data.frame(ts)
  
  obj$model <- fit(obj$model, ts)
  
  return(obj)
}


#'@import daltoolbox
#'@import harbinger
#'@importFrom stats na.omit
#'@export
detect.hcp_autoencoder_ls <- function(obj, serie, ...) {
  if(is.null(serie)) stop("No data was provided for computation", call. = FALSE)
  ls <- transform(obj$model, serie)
  ls <- as.data.frame(ls)
  if (length(ls) > 1){
    #Multivariate
    #CPD with multidimensional latent space
    det <- list()
    threshold <- obj$threshold
    #Detection for each latent space neuron
    for (i in 1:obj$encode_size){
      det[[i]] <- detect(obj$cpd, ls[[i]])
    }
    #Consolidation
    detection <- det[[1]]
    detection$type <- NULL
    for (i in 2:length(det)){
      #Detections based on threshold
      detection$proximo <- det[[2]]$event
      names(detection)[length(detection)] <- paste("event", i, sep = "")
    }
    #Votes
    last <- length(det) + 1
    detection$votes <- rowSums(detection[,2:last])
    #Candidates analysis - Threshold application
    detection$cpd <- FALSE
    detection$cpd[(detection$votes/length(det))>threshold] <- TRUE
    #Final result
    detection <- detection[,c("idx", "cpd")]
    names(detection) <- c("idx", "event")
  } else {
    #Univariate
    detection <- detect(obj$cpd, ls[[1]])
  }
  detection$type <- ""
  detection$type[detection$event==TRUE] <- "changepoint"
  
  return(detection)
}