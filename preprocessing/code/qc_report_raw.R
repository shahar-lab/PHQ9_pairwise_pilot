#### QC REPORT: RAW DATA (BEFORE EXCLUSION) ####

likert <- read_csv(file.path(raw_dir, "likert.csv"), show_col_types = FALSE)
pairwise <- read_csv(file.path(raw_dir, "pairwise.csv"), show_col_types = FALSE)

qc_report(likert, "likert", "raw")
qc_report(pairwise, "pairwise", "raw")
