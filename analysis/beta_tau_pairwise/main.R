rm(list = ls())

#### SETUP ####

library(here)
library(tidyverse)
library(cmdstanr)
library(posterior)
library(ggdist)
library(patchwork)

project_root  <- here::here()
code_dir      <- file.path(project_root, "analysis", "beta_tau_pairwise", "code")
artifacts_dir <- file.path(project_root, "analysis", "beta_tau_pairwise", "artifacts")
output_dir    <- file.path(project_root, "analysis", "beta_tau_pairwise", "output")
data_path     <- file.path(project_root, "data", "processed")
model_path    <- file.path(project_root, "models", "bradley_terry_beta_tau", "bradley_terry_beta_tau.stan")

#### EXECUTE PIPELINE ####

source(file.path(code_dir, "prep_data.R"))
source(file.path(code_dir, "fit_model.R"))
source(file.path(code_dir, "summarise_posterior.R"))
source(file.path(code_dir, "plot_beta_posterior.R"))
source(file.path(code_dir, "plot_tau_posterior.R"))
source(file.path(code_dir, "prep_clinical_report.R"))
source(file.path(code_dir, "prep_burden_threshold.R"))
source(file.path(code_dir, "prep_consistency.R"))
source(file.path(code_dir, "plot_clinical_report.R"))
