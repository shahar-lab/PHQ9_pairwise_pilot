#### LOAD DATA ####

data_raw_file <- file.path(raw_dir, "data_raw.csv")
data_raw <- read_csv(data_raw_file, show_col_types = FALSE, guess_max = Inf)

item_lookup <- read_csv(file.path(raw_dir, "item_lookup.csv"), show_col_types = FALSE) |>
  select(item_code, item)

#### BUILD LIKERT ####
likert <- data_raw |>
  filter(!is.na(phase) & phase == "likert") |>
  select(
    participant_id,
    trial               = phase_trial_num,
    item_phq_number     = item_number,
    item_phq_text       = item_text,
    likert_response_lable = response_label,
    likert_response     = response_score,
    rt,
    window_status
  ) |>
  left_join(item_lookup, by = c("item_phq_number" = "item_code")) |>
  select(
    participant_id, trial, item, likert_response, likert_response_lable, rt,
    window_status, item_phq_number, item_phq_text
  )

#### BUILD PAIRWISE ####
pairwise <- data_raw |>
  filter(!is.na(phase) & phase == "pairwise") |>
  # right_item_number/right_item_text hold the right item's number/text
  # (mirrors left_item_number/left_item_text), not a Likert rating - no such
  # rating exists in the raw pairwise data
  select(
    participant_id,
    trial                = phase_trial_num,
    left_item_phq_number  = left_item_number,
    left_item_phq_text    = left_item_text,
    right_item_phq_number = right_item_number,
    right_item_phq_text   = right_item_text,
    chosen_side,
    chosen_item_phq_number = chosen_item_number,
    chosen_item_phq_text   = chosen_item_text,
    skipped,
    rt,
    window_status
  ) |>
  left_join(item_lookup, by = c("left_item_phq_number" = "item_code")) |>
  rename(left_item = item) |>
  left_join(item_lookup, by = c("right_item_phq_number" = "item_code")) |>
  rename(right_item = item) |>
  left_join(item_lookup, by = c("chosen_item_phq_number" = "item_code")) |>
  rename(chosen_item = item) |>
  select(
    participant_id, trial, left_item, right_item, chosen_item,
    rt, skipped, window_status,
    left_item_phq_number, right_item_phq_number,
    left_item_phq_text, right_item_phq_text,
    chosen_side, chosen_item_phq_number, chosen_item_phq_text
  )

#### WRITE OUTPUTS ####
write_csv(likert, file.path(raw_dir, "likert.csv"))
write_csv(pairwise, file.path(raw_dir, "pairwise.csv"))

#### VALIDATION SUMMARY ####
cat("likert.csv:", nrow(likert), "rows,", n_distinct(likert$participant_id), "participants\n")
cat("pairwise.csv:", nrow(pairwise), "rows,", n_distinct(pairwise$participant_id), "participants\n")
