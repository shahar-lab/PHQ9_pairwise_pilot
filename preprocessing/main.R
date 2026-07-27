rm(list = ls())

#### SETUP ####

library(here)
library(tidyverse)
library(readr)
library(gridExtra)
library(grid)

project_root  <- here::here()
collected_dir <- file.path(project_root, "data", "collected")
raw_dir       <- file.path(project_root, "data", "raw")
processed_dir <- file.path(project_root, "data", "processed")
code_dir      <- file.path(project_root, "preprocessing", "code")
output_dir    <- file.path(project_root, "preprocessing", "output")

#### EXECUTE PIPELINE ####

source(file.path(code_dir, "converting_to_data_raw.R"))
source(file.path(code_dir, "build_item_lookup.R"))
source(file.path(code_dir, "converting_likert_pairwise.R"))
source(file.path(code_dir, "qc_report_fn.R"))
source(file.path(code_dir, "qc_report_raw.R"))
source(file.path(code_dir, "filter_bad_trials.R"))
source(file.path(code_dir, "qc_report_processed.R"))
