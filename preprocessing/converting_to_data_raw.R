# Read and combine all CSV files from data/collected into a single data file

library(readr)
library(tidyverse)

# Define paths
collected_dir <- file.path("data", "collected")
output_dir <- file.path("data", "raw")

# Create output directory if it doesn't exist
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)

# List all CSV files in the collected directory
csv_files <- list.files(collected_dir, pattern = "\\.csv$", full.names = TRUE)

if (length(csv_files) == 0) {
  stop("No CSV files found in ", collected_dir)
}

# Read and combine all CSV files
combined_data <- map_df(csv_files, read_csv, .id = "source_file")

# Save the combined data
output_file <- file.path(output_dir, "data_raw.csv")
write_csv(combined_data, output_file)

cat("Combined", length(csv_files), "CSV files into", output_file, "\n")
