#### FILTER BAD TRIALS AND SAVE PROCESSED DATA ####

likert <- read_csv(file.path(raw_dir, "likert.csv"), show_col_types = FALSE)
pairwise <- read_csv(file.path(raw_dir, "pairwise.csv"), show_col_types = FALSE)

#### PARTICIPANT-LEVEL EXCLUSION ####
# Excluded if: any window abort (likert or pairwise), or >10 skipped pairwise trials

window_aborts <- bind_rows(
  likert |> select(participant_id, window_status),
  pairwise |> select(participant_id, window_status)
) |>
  group_by(participant_id) |>
  summarise(n_window_aborted = sum(window_status != "ok", na.rm = TRUE), .groups = "drop")

skip_counts <- pairwise |>
  group_by(participant_id) |>
  summarise(n_skipped = sum(skipped, na.rm = TRUE), .groups = "drop")

participant_exclusion <- window_aborts |>
  left_join(skip_counts, by = "participant_id") |>
  mutate(
    excluded = n_window_aborted > 0 | n_skipped > 10
  )

excluded_participants <- participant_exclusion |>
  filter(excluded) |>
  pull(participant_id)

cat("Participants excluded:", length(excluded_participants),
    "of", nrow(participant_exclusion), "\n")
if (length(excluded_participants) > 0) {
  print(participant_exclusion |> filter(excluded))
}

#### APPLY EXCLUSION AND DROP SKIPPED TRIALS ####

likert_processed <- likert |>
  filter(!participant_id %in% excluded_participants)

pairwise_processed <- pairwise |>
  filter(!participant_id %in% excluded_participants, !skipped)

cat("likert:   ", nrow(likert), "->", nrow(likert_processed),
    "rows (", nrow(likert) - nrow(likert_processed), "removed )\n")
cat("pairwise: ", nrow(pairwise), "->", nrow(pairwise_processed),
    "rows (", nrow(pairwise) - nrow(pairwise_processed), "removed )\n")

write_csv(likert_processed, file.path(processed_dir, "likert_processed.csv"))
write_csv(pairwise_processed, file.path(processed_dir, "pairwise_processed.csv"))
