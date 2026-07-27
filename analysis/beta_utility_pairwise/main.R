rm(list = ls())

#### SETUP ####

library(here)
library(tidyverse)
library(cmdstanr)
library(posterior)
library(ggdist)

project_root  <- here::here()
code_dir      <- file.path(project_root, "analysis", "beta_utility_pairwise", "code")
artifacts_dir <- file.path(project_root, "analysis", "beta_utility_pairwise", "artifacts")
output_dir    <- file.path(project_root, "analysis", "beta_utility_pairwise", "output")
data_path     <- file.path(project_root, "data", "processed")
model_path    <- file.path(project_root, "models", "bradley_terry_model", "beta_utility.stan")

#### EXECUTE PIPELINE ####

source(file.path(code_dir, "prep_data.R"))
source(file.path(code_dir, "fit_model.R"))
source(file.path(code_dir, "summarise_posterior.R"))
source(file.path(code_dir, "plot_utility_vs_likert.R"))
source(file.path(code_dir, "plot_beta_posterior.R"))
source(file.path(code_dir, "plot_utility_vs_choice_rate.R"))
