library(stringr)

## ------------------------------------------------------------
## 1) Carga dos dados ----
## ------------------------------------------------------------

#Local
dir <- "DSc/pipeline_exp/results"
setwd(dir=dir)

#Apontar para o arquivo .RData com o sumuário de resultados
summary_file <- "gecco_ae_methods_exp_summary.RData"
file_name <- str_sub(summary_file, 1, -7)

load(file=sprintf("%s.RData", file_name))


## ------------------------------------------------------------
## 2) Transformação em CSV ----
## ------------------------------------------------------------
## Garante diretório de resultados
dir.create("csv", showWarnings = FALSE, recursive = TRUE)

#Mudar nome para a variável com o sumário de resultados
write.csv(resumo_experimentos_ae,
          file = sprintf("csv/%s.csv", file_name),
          na = "NaN", row.names = FALSE)
