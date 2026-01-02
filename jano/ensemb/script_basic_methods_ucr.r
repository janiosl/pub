#Basic Methods

#Load libraries ----
library(daltoolbox)
#library(daltoolboxdp)
library(tspredit)
library(harbinger)


#Load datasets ----
library(united)


## ------------------------------------------------------------
## 1) Preparação dos métodos (modelos) ----
## ------------------------------------------------------------
exp <- "basic_methods"

metodos <- list(
  hanr_arima(),   # Método 1: ARIMA
  hanr_fbiad()#,  # Método 2: FBIAD
)

names(metodos) <- c("fbiad", "arima")


## ------------------------------------------------------------
## 2) Preparação dos dados ----
## ------------------------------------------------------------
#dir <- "DSc/pipeline_exp"
#setwd(dir=dir)
load(file="data/ucr_sample.RData")
names(ucr_sample)

#Rodar para cada grupo NAB
#nome_base <- paste("ucr1", names(ucr_sample[1]), sep = "_")
#nome_base <- paste("ucr2", names(ucr_sample[2]), sep = "_")
#nome_base <- paste("ucr3", names(ucr_sample[3]), sep = "_")
nome_base <- paste("ucr4", names(ucr_sample[4]), sep = "_")


# Fatiamos cada série no mesmo intervalo Gecco -> [16500:18000]
# OBS: ajuste este recorte se o tamanho das séries variar.
#series_ts <- vector("list", length(ucr_sample[[1]]))
#series_ts <- vector("list", length(ucr_sample[[2]]))
#series_ts <- vector("list", length(ucr_sample[[3]]))
series_ts <- vector("list", length(ucr_sample[[4]]))


for (i in seq_along(series_ts)) {
  #serie_nome <- names(ucr_sample[[1]])[i]
  #serie_nome <- names(ucr_sample[[2]])[i]
  #serie_nome <- names(ucr_sample[[3]])[i]
  serie_nome <- names(ucr_sample[[4]])[i]

  # Verificação de limites para evitar erro se a série for menor
  #n <- nrow(ucr_sample[[1]][[i]])
  #n <- nrow(ucr_sample[[2]][[i]])
  #n <- nrow(ucr_sample[[3]][[i]])
  n <- nrow(ucr_sample[[4]][[i]])

  #Trecho desativado para UCR, pois não faz sentido cortes tendo em vista
  #forma como as anomalias são distribuídas neste datasets de maneira distinta
  #para cada série.
  
  if (is.null(n)) {
    stop(sprintf("Objeto %s não é um data.frame/ts esperado.", serie_nome))
  }

  #Trecho ajustado para séries UCR
  #series_ts[[i]] <- ucr_sample[[1]][[i]]
  #series_ts[[i]] <- ucr_sample[[2]][[i]]
  #series_ts[[i]] <- ucr_sample[[3]][[i]]
  series_ts[[i]] <- ucr_sample[[4]][[i]]
  
  names(series_ts)[i] <- serie_nome
}


## ------------------------------------------------------------
## 3) Detecção detalhada (com cache por método) ----
## ------------------------------------------------------------
detalhes_todos <- list()

for (j in seq_along(metodos)) {                 # percorre métodos
  modelo_atual   <- metodos[[j]]
  nome_modelo    <- names(metodos)[j]
  detalhes_modelo <- list()                     # resultados por série deste método
  
  # Caminho do arquivo de cache para este método
  arq_cache <- file.path("results", sprintf("%s_exp_detail_%s.RData", nome_base, nome_modelo))
  
  # Se existir resultado pré-computado, carregar para continuar de onde parou
  if (file.exists(arq_cache)) {
    load(file = arq_cache)  # carrega objeto 'detalhes_modelo' se salvo anteriormente
  }
  
  for (i in seq_along(series_ts)) {             # percorre séries
    dados_serie <- series_ts[[i]]
    nome_serie  <- names(series_ts)[i]
    
    # Se ainda não existe resultado para esta série, processa
    if (is.null(detalhes_modelo[i][[1]])) {
      tryCatch({
        ## 3.1 Ajuste (fit)
        inicio_tempo <- Sys.time()
        modelo_ajustado <- fit(modelo_atual, dados_serie$value)
        tempo_ajuste <- as.double(Sys.time() - inicio_tempo, units = "secs")
        
        ## 3.2 Detecção (detect)
        inicio_tempo <- Sys.time()
        resultado_detec <- detect(modelo_ajustado, dados_serie$value)
        tempo_deteccao <- as.double(Sys.time() - inicio_tempo, units = "secs")
        
        ## 3.3 Empacota resultado desta série
        detalhes_modelo[[i]] <- list(
          md          = modelo_ajustado,
          rs          = resultado_detec,
          dataref     = i,                 # índice da série no objeto series_ts
          modelname   = nome_modelo,
          datasetname = nome_base,
          seriesname  = nome_serie,
          time_fit    = tempo_ajuste,
          time_detect = tempo_deteccao
        )
        names(detalhes_modelo)[i] <- sprintf("%s_%s", nome_base, nome_serie)
        
        ## 3.4 Salva cache incremental (permite retomar em execuções futuras)
        save(detalhes_modelo, file = arq_cache, compress = "xz")
        
      }, error = function(e) {
        message(sprintf("Erro em %s - %s: %s", nome_modelo, nome_serie, e$message))
      })
    }
  }
  
  ## Acumula os detalhes deste método no agregado geral
  detalhes_todos <- c(detalhes_todos, detalhes_modelo)
}

#Persistência doss detalhes no agregado geral
filename_detalhes <- sprintf("%s_%s_exp_det.RData", nome_base, exp)

save(detalhes_todos,
     file = file.path("results", filename_detalhes),
     compress = "xz")


## ------------------------------------------------------------
## 4) Sumário de desempenho (tempo e métricas) ----
## ------------------------------------------------------------
linhas_resumo <- vector("list", length(detalhes_todos))

for (k in seq_along(detalhes_todos)) {
  exp_k   <- detalhes_todos[[k]]
  dados_k <- series_ts[[exp_k$dataref]]
  
  # Avaliação "soft" com janela deslizante (ajuste sw_size conforme o caso)
  avaliacao_soft <- evaluate(har_eval_soft(sw_size = 30), #Rodar novamente exemplo nab1
                             exp_k$rs$event, dados_k$event)
  
  # Linha do resumo para esta série e método
  linhas_resumo[[k]] <- data.frame(
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

resumo_experimentos <- do.call(rbind, linhas_resumo)


## ------------------------------------------------------------
## 5) Persistência do sumário ----
## ------------------------------------------------------------
filename <- sprintf("%s_%s_exp_summary.RData", nome_base, exp)

save(resumo_experimentos,
     file = file.path("results", filename),
     compress = "xz")
