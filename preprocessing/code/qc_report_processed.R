#### QC REPORT: PROCESSED DATA (AFTER EXCLUSION) ####

likert_processed <- read_csv(file.path(processed_dir, "likert_processed.csv"), show_col_types = FALSE)
pairwise_processed <- read_csv(file.path(processed_dir, "pairwise_processed.csv"), show_col_types = FALSE)

qc_report(likert_processed, "likert", "processed")
qc_report(pairwise_processed, "pairwise", "processed")
