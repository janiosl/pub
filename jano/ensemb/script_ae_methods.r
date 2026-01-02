#AE Methods

#Load libraries ----
library(daltoolbox)
library(daltoolboxdp)
library(tspredit)
library(harbinger)


#Load datasets ----
library(united)


## ------------------------------------------------------------
## 1) Preparação dos métodos (modelos) ----
## ------------------------------------------------------------
metodos_ae <- list(
  han_autoencoder(3,2, autoenc_ed), #Vanilla AE
  han_autoencoder(3,2, autoenc_denoise_ed), #Denoising AE
  han_autoencoder(3,2, autoenc_stacked_ed), #Stacked AE
  han_autoencoder(3,2, autoenc_conv_ed), #Convolutional AE
  han_autoencoder(3,2, autoenc_lstm_ed), #LSTM AE
  han_autoencoder(3,2, autoenc_adv_ed) #Adversarial AE
  #han_autoencoder(3,2, autoenc_variational_ed) #Variational AE #ERRO
)

#Autoencoder methods
#names(metodos_ae) <- c("vanilla_AE", "denoising_AE", "stacked_AE",
#                       "convolutional_AE", "lstm_AE", "adversarial_AE",
#                       "variational_AE")

#Remoção do Variational AE devido problemas na execução
names(metodos_ae) <- c("vanilla_AE", "denoising_AE", "stacked_AE",
                       "convolutional_AE", "lstm_AE", "adversarial_AE")


## ------------------------------------------------------------
## 2) Preparação dos dados ----
## ------------------------------------------------------------
nome_base <- "gecco"
data(gecco)  # carrega a base 'gecco' no ambiente

# Fatiamos cada série no mesmo intervalo [16500:18000]
# OBS: ajuste este recorte se o tamanho das séries variar.
#Basic verification with just one series
series_ts <- vector("list", length(gecco) - 1)
#series_ts <- vector("list", 1)

for (i in seq_along(series_ts)) {
  serie_nome <- names(gecco)[i]
  # Verificação de limites para evitar erro se a série for menor
  n <- nrow(gecco[[i]])
  inicio <- 16500L
  fim    <- 18000L
  if (is.null(n)) {
    stop(sprintf("Objeto %s não é um data.frame/ts esperado.", serie_nome))
  }
  if (fim > n) {
    stop(sprintf("Série %s tem apenas %d linhas; ajuste o recorte (%d:%d).",
                 serie_nome, n, inicio, fim))
  }
  series_ts[[i]] <- gecco[[i]][inicio:fim, ]
  names(series_ts)[i] <- serie_nome
}

## Garante diretório de resultados
getwd()
setwd("DSc/pipeline_exp")

dir.create("results", showWarnings = FALSE, recursive = TRUE)


## ------------------------------------------------------------
## 3) Detecção detalhada (com cache por método) ----
## ------------------------------------------------------------
detalhes_todos_ae <- list()

for (j in seq_along(metodos_ae)) {                 # percorre métodos
  modelo_atual_ae   <- metodos_ae[[j]]
  nome_modelo_ae    <- names(metodos_ae)[j]
  detalhes_modelo_ae <- list()                     # resultados por série deste método
  
  # Caminho do arquivo de cache para este método
  arq_cache <- file.path("results", sprintf("%s_exp_detail_%s.RData", nome_base, nome_modelo_ae))
  
  
  # Se existir resultado pré-computado, carregar para continuar de onde parou
  if (file.exists(arq_cache)) {
    load(file = arq_cache)  # carrega objeto 'detalhes_modelo_ae' se salvo anteriormente
  }
  
  for (i in seq_along(series_ts)) {             # percorre séries
    dados_serie <- series_ts[[i]]
    nome_serie  <- names(series_ts)[i]
    
    #Train and test split
    #Bloco adicionado para treinamento de autoencoders e ML models
    samp <- ts_sample(dados_serie, test_size = as.integer(nrow(dados_serie)*0.2))
    train <- as.data.frame(samp$train)
    #test <- as.data.frame(samp$test)
    features <- names(train)
    
    # Se ainda não existe resultado para esta série, processa
    if (is.null(detalhes_modelo_ae[i][[1]])) {
      tryCatch({
        ## 3.1 Ajuste (fit)
        inicio_tempo <- Sys.time()
        #modelo_ajustado_ae <- fit(modelo_atual_ae, dados_serie$value)
        #Fit using train sample
        modelo_ajustado_ae <- fit(modelo_atual_ae, train$value) 
        tempo_ajuste <- as.double(Sys.time() - inicio_tempo, units = "secs")
        
        ## 3.2 Detecção (detect)
        inicio_tempo <- Sys.time()
        resultado_detec <- detect(modelo_ajustado_ae, dados_serie$value)
        tempo_deteccao <- as.double(Sys.time() - inicio_tempo, units = "secs")
        
        ## 3.3 Empacota resultado desta série
        detalhes_modelo_ae[[i]] <- list(
          md          = modelo_ajustado_ae,
          rs          = resultado_detec,
          dataref     = i,                 # índice da série no objeto series_ts
          modelname   = nome_modelo_ae,
          datasetname = nome_base,
          seriesname  = nome_serie,
          time_fit    = tempo_ajuste,
          time_detect = tempo_deteccao
        )
        names(detalhes_modelo_ae)[i] <- sprintf("%s_%s", nome_base, nome_serie)
        
        ## 3.4 Salva cache incremental (permite retomar em execuções futuras)
        save(detalhes_modelo_ae, file = arq_cache, compress = "xz")
        
      }, error = function(e) {
        message(sprintf("Erro em %s - %s: %s", nome_modelo_ae, nome_serie, e$message))
      })
    }
  }
  
  ## Acumula os detalhes deste método no agregado geral
  detalhes_todos_ae <- c(detalhes_todos_ae, detalhes_modelo_ae)
}


## ------------------------------------------------------------
## 4) Sumário de desempenho (tempo e métricas) ----
## ------------------------------------------------------------
linhas_resumo_ae <- vector("list", length(detalhes_todos_ae))

for (k in seq_along(detalhes_todos_ae)) {
  exp_k   <- detalhes_todos_ae[[k]]
  dados_k <- series_ts[[exp_k$dataref]]
  
  # Avaliação "soft" com janela deslizante (ajuste sw_size conforme o caso)
  avaliacao_soft <- evaluate(har_eval_soft(sw_size = 30),
                             exp_k$rs$event, dados_k$event)
  
  # Linha do resumo para esta série e método
  linhas_resumo_ae[[k]] <- data.frame(
    method      = exp_k$modelname,
    dataset     = exp_k$datasetname,
    series      = exp_k$seriesname,
    time_fit    = exp_k$time_fit,
    time_detect = exp_k$time_detect,
    precision   = avaliacao_soft$precision,
    recall      = avaliacao_soft$recall,
    f1          = avaliacao_soft$F1,
    stringsAsFactors = FALSE
  )
}

resumo_experimentos_ae <- do.call(rbind, linhas_resumo_ae)


## ------------------------------------------------------------
## 5) Persistência do sumário ----
## ------------------------------------------------------------
exp <- "ae_methods"
filename <- sprintf("%s_%s_exp_summary.RData", nome_base, exp)

save(resumo_experimentos_ae,
     file = file.path("results", filename),
     compress = "xz")
