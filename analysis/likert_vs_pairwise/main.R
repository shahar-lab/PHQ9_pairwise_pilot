rm(list = ls())

#### SETUP ####

library(here)
library(tidyverse)

project_root  <- here::here()
code_dir      <- file.path(project_root, "analysis", "likert_vs_pairwise", "code")
artifacts_dir <- file.path(project_root, "analysis", "likert_vs_pairwise", "artifacts")
output_dir    <- file.path(project_root, "analysis", "likert_vs_pairwise", "output")
data_path     <- file.path(project_root, "data", "processed")

#### EXECUTE PIPELINE ####

source(file.path(code_dir, "prep_data.R"))
source(file.path(code_dir, "plot_likert_vs_pairwise.R"))
