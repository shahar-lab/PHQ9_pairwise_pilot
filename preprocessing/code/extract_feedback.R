#### EXTRACT OPEN FEEDBACK ####

data_raw <- read_csv(file.path(raw_dir, "data_raw.csv"), show_col_types = FALSE)

feedback_raw <- data_raw |>
  filter(phase == "feedback") |>
  select(participant_id, prolific_pid, session, feedback_text) |>
  arrange(participant_id)

feedback_file <- file.path(raw_dir, "feedback_raw.csv")
write_csv(feedback_raw, feedback_file)

cat("Wrote", nrow(feedback_raw), "feedback rows to", feedback_file, "\n")
