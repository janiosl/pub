#Basic Methods

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
exp <- "ml_methods"

metodos_ml <- list(
  hanr_ml_conv1d_model <- hanr_ml(ts_conv1d(ts_norm_gminmax(), input_size=4, epochs=5000))  # Método 1: CONV1D
)
names(metodos_ml) <- c("ml_conv1d")


## ------------------------------------------------------------
## 2) Preparação dos dados ----
## ------------------------------------------------------------
dir <- "DSc/pipeline_exp"
setwd(dir=dir)
load(file="data/yahoo_sample.RData")


#Rodar para cada grupo NAB
#nome_base <- paste("yahoo", names(yahoo_sample[1]), sep = "_")
#nome_base <- paste("yahoo", names(yahoo_sample[2]), sep = "_")
nome_base <- paste("yahoo", names(yahoo_sample[3]), sep = "_")


# Fatiamos cada série no mesmo intervalo
# OBS: ajuste este recorte se o tamanho das séries variar.
#Yahoo A1 -> [1:1420] - Demais não necessitam (já são iguais)
#series_ts <- vector("list", length(yahoo_sample[[1]]))
#series_ts <- vector("list", length(yahoo_sample[[2]]))
series_ts <- vector("list", length(yahoo_sample[[3]]))


for (i in seq_along(series_ts)) {
  #serie_nome <- names(yahoo_sample[[1]])[i]
  #serie_nome <- names(yahoo_sample[[2]])[i]
  serie_nome <- names(yahoo_sample[[3]])[i]
  

  # Verificação de limites para evitar erro se a série for menor
  #n <- nrow(yahoo_sample[[1]][[i]])
  #n <- nrow(yahoo_sample[[2]][[i]])
  n <- nrow(yahoo_sample[[3]][[i]])

  #Filtro do intervalo desejado para manter execuções com mesmo tamanho
  #Na base Yahoo filtro apenas para A1 - demais já estão adequadas
  #inicio <- 1L
  #fim    <- 1420L
  
  if (is.null(n)) {
    stop(sprintf("Objeto %s não é um data.frame/ts esperado.", serie_nome))
  }
  #if (fim > n) {
  #  stop(sprintf("Série %s tem apenas %d linhas; ajuste o recorte (%d:%d).",
  #               serie_nome, n, inicio, fim))
  #}

  #Trecho ajustado para séries Yahoo
  #series_ts[[i]] <- yahoo_sample[[1]][[i]][inicio:fim, ]
  #series_ts[[i]] <- yahoo_sample[[2]][[i]]
  series_ts[[i]] <- yahoo_sample[[3]][[i]]
  
  names(series_ts)[i] <- serie_nome
}


## ------------------------------------------------------------
## 3) Detecção detalhada (com cache por método) ----
## ------------------------------------------------------------
detalhes_todos_ml <- list()

for (j in seq_along(metodos_ml)) {                 # percorre métodos
  modelo_atual_ml   <- metodos_ml[[j]]
  nome_modelo_ml    <- names(metodos_ml)[j]
  detalhes_modelo_ml <- list()                     # resultados por série deste método
  
  # Caminho do arquivo de cache para este método
  arq_cache <- file.path("results", sprintf("%s_exp_detail_%s.RData", nome_base, nome_modelo_ml))
  
  
  # Se existir resultado pré-computado, carregar para continuar de onde parou
  if (file.exists(arq_cache)) {
    load(file = arq_cache)  # carrega objeto 'detalhes_modelo_ml' se salvo anteriormente
  }
  
  for (i in seq_along(series_ts)) {             # percorre séries
    dados_serie <- series_ts[[i]]
    nome_serie  <- names(series_ts)[i]
    
    #Train and test split
    #Bloco adicionado para treinamento de modelos autoencoderes e ML
    samp <- ts_sample(dados_serie, test_size = as.integer(nrow(dados_serie)*0.4))
    train <- as.data.frame(samp$train)
    features <- names(train)
    
    # Se ainda não existe resultado para esta série, processa
    if (is.null(detalhes_modelo_ml[i][[1]])) {
      tryCatch({
        ## 3.1 Ajuste (fit)
        inicio_tempo <- Sys.time()
        #modelo_ajustado_ml <- fit(modelo_atual_ml, dados_serie$value)
        modelo_ajustado_ml <- fit(modelo_atual_ml, train$value)
        tempo_ajuste <- as.double(Sys.time() - inicio_tempo, units = "secs")
        
        ## 3.2 Detecção (detect)
        inicio_tempo <- Sys.time()
        resultado_detec <- detect(modelo_ajustado_ml, dados_serie$value)
        tempo_deteccao <- as.double(Sys.time() - inicio_tempo, units = "secs")
        
        ## 3.3 Empacota resultado desta série
        detalhes_modelo_ml[[i]] <- list(
          md          = modelo_ajustado_ml,
          rs          = resultado_detec,
          dataref     = i,                 # índice da série no objeto series_ts
          modelname   = nome_modelo_ml,
          datasetname = nome_base,
          seriesname  = nome_serie,
          time_fit    = tempo_ajuste,
          time_detect = tempo_deteccao
        )
        names(detalhes_modelo_ml)[i] <- sprintf("%s_%s", nome_base, nome_serie)
        
        ## 3.4 Salva cache incremental (permite retomar em execuções futuras)
        save(detalhes_modelo_ml, file = arq_cache, compress = "xz")
        
      }, error = function(e) {
        message(sprintf("Erro em %s - %s: %s", nome_modelo_ml, nome_serie, e$message))
      })
    }
  }
  
  ## Acumula os detalhes deste método no agregado geral
  detalhes_todos_ml <- c(detalhes_todos_ml, detalhes_modelo_ml)
}

#Persistência doss detalhes no agregado geral
filename_detalhes <- sprintf("%s_%s_exp_det.RData", nome_base, exp)
save(detalhes_todos_ml,
     file = file.path("results", filename_detalhes),
     compress = "xz")


## ------------------------------------------------------------
## 4) Sumário de desempenho (tempo e métricas) ----
## ------------------------------------------------------------
linhas_resumo_ml <- vector("list", length(detalhes_todos_ml))

for (k in seq_along(detalhes_todos_ml)) {
  exp_k   <- detalhes_todos_ml[[k]]
  dados_k <- series_ts[[exp_k$dataref]]
  
  # Avaliação "soft" com janela deslizante (ajuste sw_size conforme o caso)
  avaliacao_soft <- evaluate(har_eval_soft(sw_size = 30), #Ajustado para 30 no dataset NAB
                             exp_k$rs$event, dados_k$event)
  
  # Linha do resumo para esta série e método
  linhas_resumo_ml[[k]] <- data.frame(
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

resumo_experimentos_ml <- do.call(rbind, linhas_resumo_ml)


## ------------------------------------------------------------
## 5) Persistência do sumário ----
## ------------------------------------------------------------
filename <- sprintf("%s_%s_exp_summary.RData", nome_base, exp)

save(resumo_experimentos_ml,
     file = file.path("results", filename),
     compress = "xz")
