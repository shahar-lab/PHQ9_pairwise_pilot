#### COMBINE COLLECTED CSVs ####

# Session files only - collected_dir also holds the Prolific demographic export
csv_files <- list.files(collected_dir, pattern = "_SESSION_.*\\.csv$", full.names = TRUE)

combined_data <- map_df(csv_files, read_csv, .id = "source_file")

data_raw_file <- file.path(raw_dir, "data_raw.csv")
write_csv(combined_data, data_raw_file)

cat("Combined", length(csv_files), "CSV files into", data_raw_file, "\n")
